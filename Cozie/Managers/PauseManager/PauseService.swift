//
//  PauseService.swift
//  Cozie
//  Verify, save the pause plan, and record events

import Foundation
import Combine
import UserNotifications

// All the pause operations are uniformly coordinated in main
@MainActor
final class PauseService: ObservableObject {
    let pauseManager: PauseManager
    let reminderManager: ReminderManager

    // Share the busy state to prevent different entrances from modifying the pause simultaneously
    @Published private(set) var isBusy = false

    private var subscriptions = Set<AnyCancellable>()
    // After the automatic recovery fails, avoid repeating attempts every second
    private var nextRestoreAttempt = Date.distantPast
    
    
    init(
        pauseManager: PauseManager,
        reminderManager: ReminderManager
    ) {
        self.pauseManager = pauseManager
        self.reminderManager = reminderManager

        // When internal plans change, also notify to observe the page refresh of this service
        pauseManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }

    var plan: PausePlan? {
        pauseManager.plan
    }

    var storageError: String? {
        pauseManager.storageError
    }

    func status(at date: Date = Date()) -> PauseStatus {
        pauseManager.status(at: date)
    }

    // Convert the original callback interface into an interface that can await
    private func availableCapacity() async -> Int {
        await withCheckedContinuation { continuation in
            reminderManager.availablePauseReminderCapacity { count in
                continuation.resume(returning: count)
            }
        }
    }

    @discardableResult
    func savePause(
        startDate: Date?,
        endDate: Date,
        reason: String
    ) async throws -> Bool {
        guard !isBusy else {
            throw PauseValidationError(
                message: "A pause operation is already in progress."
            )
        }

        isBusy = true
        defer {
            isBusy = false
        }

        let now = Date()
        let originalPlan = pauseManager.plan

        //Verify and generate a unique candidate plan
        let candidate = try pauseManager.preparePause(
            startDate: startDate,
            endDate: endDate,
            reason: reason,
            at: now
        )

        guard candidate != originalPlan else {
            return false
        }

        let available = await availableCapacity()
        let slots = try reminderManager.reminderSlotsForPause()

        let occurrences = try reminderManager.minimumRemindersForPause(
            slots: slots,
            pauseStart: candidate.startDate,
            pauseEnd: candidate.endDate,
            availableCapacity: available,
            now: Date()
        )

        let requests = reminderManager.makePauseNotificationRequests(
            from: occurrences
        )

        try await reminderManager.replaceSurveyReminderRequests(
            with: requests
        ) {
            guard candidate.endDate > Date() else {
                throw PauseValidationError(
                    message: "The pause end time has passed. Please choose a later time."
                )
            }

            //During the waiting period, the formal reminder Settings may be modified by other entrances
            let currentSlots = try self.reminderManager
                .reminderSlotsForPause()

            guard Set(currentSlots) == Set(slots) else {
                throw PauseValidationError(
                    message: "Reminder settings changed. Please try saving again."
                )
            }

            try self.pauseManager.commitPause(
                candidate,
                replacing: originalPlan,
                occurredAt: now
            )
        }

        return true
    }
    
    @discardableResult
    func refreshRemindersFromSettings(
        commit: () throws -> Void = {}
    ) async throws -> Int {
        guard pauseManager.storageError == nil else {
            throw PauseValidationError(
                message:
                    "The saved pause plan could not be loaded. "
                    + "Reminder settings have not been changed."
            )
        }
        guard !isBusy else {
            throw PauseValidationError(
                message: "A pause operation is already in progress."
            )
        }

        isBusy = true
        defer { isBusy = false }

        let originalPlan = pauseManager.plan
        let capacity = await availableCapacity()
        let slots = try reminderManager.reminderSlotsForPause()
        let now = Date()

        let requests: [UNNotificationRequest]
        let usesPauseSchedule: Bool

        if let plan = originalPlan, plan.endDate > now {
            usesPauseSchedule = true

            let occurrences = try reminderManager.minimumRemindersForPause(
                slots: slots,
                pauseStart: plan.startDate,
                pauseEnd: plan.endDate,
                availableCapacity: capacity,
                now: now
            )

            requests = reminderManager.makePauseNotificationRequests(
                from: occurrences
            )
        } else {
            usesPauseSchedule = false

            requests = reminderManager.makeRepeatingReminderRequests(
                from: slots
            )
        }

        try await reminderManager.replaceSurveyReminderRequests(
            with: requests
        ) {
            guard self.pauseManager.plan == originalPlan else {
                throw PauseValidationError(
                    message: "The pause plan changed. Please try again."
                )
            }

            let currentSlots = try self.reminderManager.reminderSlotsForPause()

            guard Set(currentSlots) == Set(slots) else {
                throw PauseValidationError(
                    message: "Reminder settings changed. Please try again."
                )
            }

            if usesPauseSchedule {
                guard let plan = originalPlan,
                      plan.endDate > Date() else {
                    throw PauseValidationError(
                        message: "The pause has expired. Please try again."
                    )
                }
            }

            try commit()

            if !usesPauseSchedule, let expiredPlan = originalPlan {
                try self.pauseManager.clearExpiredPause(
                    expectedPlan: expiredPlan
                )
            }
        }

        return requests.count
    }
    
    // Cancel the plans that have not yet started
    func cancelPause() async throws {
        try await finishPause(expectedStatus: .scheduled)
    }

    // End the ongoing pause ahead of schedule
    func endPauseNow() async throws {
        try await finishPause(expectedStatus: .active)
    }

    // Two manual operations share the recovery process
    private func finishPause(
        expectedStatus: PauseStatus
    ) async throws {
        guard !isBusy else {
            throw PauseValidationError(
                message: "A pause operation is already in progress."
            )
        }

        guard let originalPlan = pauseManager.plan,
              originalPlan.status() == expectedStatus else {
            throw PauseValidationError(
                message: "The pause status has changed. Please try again."
            )
        }

        isBusy = true
        defer {
            isBusy = false
        }

        try await restoreRepeatingReminders {
            guard self.pauseManager.plan == originalPlan,
                  self.pauseManager.status() == expectedStatus else {
                throw PauseValidationError(
                    message: "The pause changed during this operation. Please try again."
                )
            }

            switch expectedStatus {
            case .scheduled:
                try self.pauseManager.cancelPause()

            case .active:
                try self.pauseManager.endPauseNow()

            case .noPause:
                throw PauseValidationError(
                    message: "There is no pause to finish."
                )
            }
        }

        nextRestoreAttempt = .distantPast
    }

    // Resume duplicate scheduling upon expiration.
    // true：completed resume this time ；false：It is not needed or cannot be executed for the time being.
    @discardableResult
    func restoreExpiredPauseIfNeeded() async throws -> Bool {
        let now = Date()

        guard !isBusy,
              now >= nextRestoreAttempt,
              let expiredPlan = pauseManager.plan,
              expiredPlan.endDate <= now else {
            return false
        }

        isBusy = true
        defer {
            isBusy = false
        }

        do {
            try await restoreRepeatingReminders {
                try self.pauseManager.clearExpiredPause(
                    expectedPlan: expiredPlan
                )
            }

            nextRestoreAttempt = .distantPast
            return true
        } catch {
            nextRestoreAttempt = Date().addingTimeInterval(30)
            throw error
        }
    }

    // Restore duplicate reminders from the currently saved Settings.
    // The caller is responsible for holding isBusy to prevent cross-operation within the service.
    private func restoreRepeatingReminders(
        commit: () throws -> Void
    ) async throws {
        let slots = try reminderManager.reminderSlotsForPause()

        let requests = reminderManager.makeRepeatingReminderRequests(
            from: slots
        )

        try await reminderManager.replaceSurveyReminderRequests(
            with: requests
        ) {
            // Settings may be modified by other entries during the waiting period
            let currentSlots = try self.reminderManager
                .reminderSlotsForPause()

            guard Set(currentSlots) == Set(slots) else {
                throw PauseValidationError(
                    message: "Reminder settings changed. Please try again."
                )
            }

            try commit()
        }
    }
    
}

