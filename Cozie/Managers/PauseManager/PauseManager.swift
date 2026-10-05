//
//  PauseManager.swift
//  Cozie
//
//  Stores pause plans and records pause events

import Foundation
import Combine

enum PauseStatus{
    case noPause //not pause plan, or pause end
    case scheduled // saved the pause, but not start
    case active  // at the set pause time
}


struct PausePlan: Codable, Equatable {
    let id: UUID  // unique pause id
    var startDate: Date
    var endDate: Date
    var reason: String
    
    func status(at now: Date = Date()) -> PauseStatus {
        if now < endDate && now >= startDate {
            return .active
        }
        if now < startDate {
            return .scheduled
        }
        
        return .noPause
    }
}


enum PauseEventType: String, Codable {
    case saved = "pause_saved"
    case updated = "pause_updated"
    case cancelled = "pause_cancelled"
    case started = "pause_started"
    case ended = "pause_ended"
}

enum ResumeTrigger: String, Codable {
    case manual
    case scheduled
}

struct PauseEvent: Codable {
    let eventID: UUID
    let pauseID: UUID
    
    let eventType: PauseEventType
    let occurredAt: Date
    
    let pauseStartDate: Date
    let plannedEndDate: Date?
    let reason: String
    
    var previousStartDate: Date? = nil
    var previousEndDate: Date? = nil
    var previousReason: String? = nil
    var actualEndDate: Date? = nil
    var resumeTrigger: ResumeTrigger? = nil // only at the end of pause event
}

// show fail reason
struct PauseValidationError: LocalizedError{
    let message: String
    
    var errorDescription: String? {
        message
    }
}

class PauseManager: ObservableObject {
    @Published private(set) var plan: PausePlan?
    @Published private(set) var latestEvent: PauseEvent?
    @Published private(set) var storageError: String?
    
    private let defaults: UserDefaults
    private let planKey = "participation_pause_plan_v1"
    @MainActor
    private var pauseLogStore: PauseLogStore?

    @MainActor
    func eventLogStore() throws -> PauseLogStore {
        if let store = pauseLogStore {
            return store
        }

        let store = try PauseLogStore()
        pauseLogStore = store
        return store
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        guard let data = defaults.data(forKey: planKey) else {
            return
        }
        
        do{
            plan = try JSONDecoder().decode(
                PausePlan.self,
                from: data
            )
        } catch {
            storageError = "The saved pause plan could not be loaded."
        }
    }
    
    //no plan - status 'no pause'; planed - conditinal status
    func status(at now: Date = Date()) -> PauseStatus {
        guard let plan = plan else {
            return .noPause
        }
        return plan.status(at: now)
    }
    
    
    
    
    //log
    @MainActor
    private func recordEvent(_ event: PauseEvent) throws {
        guard let user = UserInteractor().currentUser,
              let participantID = user.participantID,
              !participantID.isEmpty,
              let experimentID = user.experimentID,
              !experimentID.isEmpty else {
            throw PauseValidationError(
                message: "Pause history could not be saved because participant information is missing."
            )
        }

        let record = PauseLogRecord(
            event: event,
            experimentID: experimentID,
            participantID: participantID,
            passwordID: user.passwordID ?? "",
            oneSignalID: CozieStorage.shared.playerID()
        )

        let backend = BackendInteractor().currentBackendSettings
        let destination = backend?.api_write_url?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let destinationURL: String?

        if let destination = destination, !destination.isEmpty {
            destinationURL = destination
        } else {
            destinationURL = nil
        }

        let data = try JSONEncoder().encode(record)
        let json = String(decoding: data, as: UTF8.self)

        // Save the durable history and pending-upload entry first.
        let store = try eventLogStore()
        try store.append(
            record,
            destinationURL: destinationURL
        )

        latestEvent = event

        // Also include the record in the existing local backup log.
        LoggerInteractor.shared.logInfo(
            action: "",
            info: json
        )
    }
    
    
    //Start date == nil, means start from now
    // true - change; false - no change
    // Verify and return the candidate plan without changing the saved data
    func preparePause(
        startDate: Date?,
        endDate: Date,
        reason: String,
        at now: Date = Date()
    ) throws -> PausePlan {
        guard storageError == nil else {
            throw PauseValidationError(
                message: "The saved pause plan could not be loaded."
            )
        }
        
        let trimmedReason = reason.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !trimmedReason.isEmpty else {
            throw PauseValidationError(
                message: "Please enter a pause reason."
            )
        }
        
        let existingPlan: PausePlan?
        if let currentPlan = plan,
           currentPlan.status(at: now) != .noPause {
            existingPlan = currentPlan
        } else {
            existingPlan = nil
        }
        
        let resolvedStart: Date
        
        if let existingPlan = existingPlan,
           existingPlan.status(at: now) == .active{
            if let requestedStart = startDate,
               requestedStart != existingPlan.startDate {
                throw PauseValidationError(
                    message: "The start time cannot be changed during a pause."
                )
            }
            
            guard trimmedReason == existingPlan.reason else{
                throw PauseValidationError(
                    message: "The reason cannot be changed during a pause."
                )
            }
            
            resolvedStart = existingPlan.startDate
        }else{
            resolvedStart = startDate ?? now
            
            guard resolvedStart >= now else{
                throw PauseValidationError(
                    message: "Choose Now or a future start time."
                )
            }
        }
        
        guard endDate > resolvedStart, endDate > now else {
                throw PauseValidationError(
                    message: "The end time must be in the future and after the start time."
                )
            }

            let newPlan = PausePlan(
                id: existingPlan?.id ?? UUID(),
                startDate: resolvedStart,
                endDate: endDate,
                reason: trimmedReason
        )
        
        return newPlan
    }
    
    // Save the same candidate plan without recalculating the start time or generating a number
    // An expectedPlan is an old plan prepared for operation, used to check if any other modifications have occurred during the period.
    @MainActor
    @discardableResult
    func commitPause(
        _ candidate: PausePlan,
        replacing expectedPlan: PausePlan?,
        occurredAt: Date
    ) throws -> Bool {
        guard storageError == nil else {
            throw PauseValidationError(
                message: "The saved pause plan could not be loaded."
            )
        }

        guard plan == expectedPlan else {
            throw PauseValidationError(
                message: "The pause plan changed during this operation. Please try again."
            )
        }

        guard candidate != expectedPlan else {
            return false
        }

        // When encoding fails, the original data is not changed
        let data = try JSONEncoder().encode(candidate)

        let previousPlan: PausePlan?
        if let expectedPlan = expectedPlan,
           expectedPlan.id == candidate.id {
            previousPlan = expectedPlan
        } else {
            previousPlan = nil
        }

        let event = PauseEvent(
            eventID: UUID(),
            pauseID: candidate.id,
            eventType: previousPlan == nil ? .saved : .updated,
            occurredAt: occurredAt,
            pauseStartDate: candidate.startDate,
            plannedEndDate: candidate.endDate,
            reason: candidate.reason,
            previousStartDate: previousPlan?.startDate,
            previousEndDate: previousPlan?.endDate,
            previousReason: previousPlan?.reason
        )

        try recordEvent(event)

        defaults.set(data, forKey: planKey)
        plan = candidate

        return true
    }
    
    // After verification, save and record the event
    @MainActor
    @discardableResult
    func savePause(
        startDate: Date?,
        endDate: Date,
        reason: String
    ) throws -> Bool {
        let now = Date()
        let originalPlan = plan

        let candidate = try preparePause(
            startDate: startDate,
            endDate: endDate,
            reason: reason,
            at: now
        )

        return try commitPause(
            candidate,
            replacing: originalPlan,
            occurredAt: now
        )
    }
    
    
    // Cancel scheduled pause plan
    @MainActor
    func cancelPause() throws {
        let now = Date()
        
        guard let currentPlan = plan,
              currentPlan.status(at: now) == .scheduled else {
            throw PauseValidationError(
                message: "Only a scheduled pause can be cancelled."
            )
        }
        // storage the original plan
        let event = PauseEvent(
            eventID: UUID(),
            pauseID: currentPlan.id,
            eventType: .cancelled,
            occurredAt: now,
            pauseStartDate: currentPlan.startDate,
            plannedEndDate: currentPlan.endDate,
            reason: currentPlan.reason
        )
        try recordEvent(event)
        // clear the plan
        defaults.removeObject(forKey: planKey)
        plan = nil
        
    }
    
    
    // End now: end the pause immediately, when pause is actived
    @MainActor
    func endPauseNow() throws {
        let now = Date()

        guard let currentPlan = plan,
              currentPlan.status(at: now) == .active else {
            throw PauseValidationError(
                message: "Only an active pause can be ended now."
            )
        }

        let event = PauseEvent(
            eventID: UUID(),
            pauseID: currentPlan.id,
            eventType: .ended,
            occurredAt: now,
            pauseStartDate: currentPlan.startDate,
            plannedEndDate: currentPlan.endDate,
            reason: currentPlan.reason,
            actualEndDate: now,
            resumeTrigger: .manual
        )

        try recordEvent(event)

        defaults.removeObject(forKey: planKey)
        plan = nil
    }
    
    // Only after the restoration reminder is successful will the corresponding expired plans be cleared
    func clearExpiredPause(expectedPlan: PausePlan) throws {
        guard plan == expectedPlan else {
            throw PauseValidationError(
                message: "The pause plan changed during restoration."
            )
        }

        guard expectedPlan.endDate <= Date() else {
            throw PauseValidationError(
                message: "The pause has not ended yet."
            )
        }

        defaults.removeObject(forKey: planKey)
        plan = nil
    }


    
}
