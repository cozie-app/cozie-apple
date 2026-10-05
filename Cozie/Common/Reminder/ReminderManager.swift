//
//  ReminderManager.swift
//  Cozie
//
//  Created by Denis on 27.03.2023.

import Foundation
import UserNotifications

struct Reminder {
    let identifier: String
    let title: String = "Survey reminder"
    let body: String = "Survey reminder"
    let day: DayModel
    let timeStart: Int
    let timeEnd: Int
    let interval: Int
}

struct PhoneReminder {
    let identifier: String
    let title: String = "Survey reminder"
    let body: String = "Survey reminder"
    let day: DayModel
    let timeStart: Int
}

// #96 pause button reminders calculate
struct WeeklyReminderSlot: Hashable {
    enum Kind: String, Hashable {
        case watch
        case phone
    }
    let kind: Kind
    
    //1 = Sun; 2 = Mon; 3 = Tue ......
    let weekday: Int
    let hour: Int
    let minute: Int
}

struct ReminderOccurrence {
    let slot: WeeklyReminderSlot
    let date: Date
}

// TODO: - Unit Tests
class ReminderManager: NSObject, ObservableObject {
    
    private let watchIndentifier = "watch-"
    private let phoneInderifier = "phone-"
    
    let center = UNUserNotificationCenter.current()
    let maxWatchRemindrCount: Int = {
        let maxReminderCount = 63 // max reminders which can be set
        let phoneReminderCount = 7 // 1 reminder on day
        return maxReminderCount - phoneReminderCount
    }()
    
    private var isAvailable: Bool = false
    
    // the same ReminderManager would not schedule two schedule
    @MainActor
    private var isReplacingSurveyReminders = false
    
    deinit {
        debugPrint("Deinit - ReminderManager")
    }
    
    func askForPermission(completion: @escaping (Result<Bool, Error>) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { isGranted, error in
            if let error = error {
                print("error: \(error)")
                completion(.failure(error))
            } else {
                completion(.success(isGranted))
            }
        }
    }
    
    func createReminderNotification(list: [Reminder]) {
        
        guard list.count > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Watch Survey"
        content.body = "Please fill out a survey on the watch."
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "watch-category"
        
        var reminderList = [UNNotificationRequest]()
        for reminder in list {
            var startTime = reminder.timeStart
            while startTime < reminder.timeEnd {
                
                let composed = retriveHourAndMinute(time: startTime)
                
                var dateComponents = DateComponents()
                dateComponents.weekday = reminder.day.dayIndex()
                dateComponents.hour = composed.hour
                dateComponents.minute = composed.minute
                
                let triger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                           repeats: true)
                let hourStr = composed.hour > 9 ? "\(composed.hour)" : "0\(composed.hour)"
                let minuteStr = composed.minute > 9 ? "\(composed.minute)" : "0\(composed.minute)"
                let requestIdentifier = watchIndentifier + "\(reminder.day.dayIndex())" + hourStr + minuteStr
                
                
                let request = UNNotificationRequest(identifier: requestIdentifier,
                                                    content: content,
                                                    trigger: triger)
                
                
                startTime += reminder.interval
                reminderList.append(request)
            }
        }
        
        /*let helpfulAction = UNNotificationAction(identifier: "watch-helpfulaction",
         title: "Helpful")
         let notHelpfulAction = UNNotificationAction(identifier: "watch-nothelpfulaction",
         title: "Not helpful")
         let category = UNNotificationCategory(identifier: "watch-category",
         actions: [helpfulAction, notHelpfulAction],
         intentIdentifiers: reminderList.map{ $0.identifier })*/
        
        schedule(list: reminderList, category: nil)
    }
    
    func createPhoneReminder(list: [PhoneReminder]) {
        guard list.count > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Phone Survey"
        content.body = "Please fill out a survey on the phone."
        content.sound = UNNotificationSound.default
        
        var reminderList = [UNNotificationRequest]()
        for reminder in list {
            let composed = retriveHourAndMinute(time: reminder.timeStart)
            
            var dateComponents = DateComponents()
            dateComponents.weekday = reminder.day.dayIndex()
            dateComponents.hour = composed.hour
            dateComponents.minute = composed.minute
            
            let triger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                       repeats: true)
            let hourStr = composed.hour > 9 ? "\(composed.hour)" : "0\(composed.hour)"
            let minuteStr = composed.minute > 9 ? "\(composed.minute)" : "0\(composed.minute)"
            let requestIdentifier = phoneInderifier + "\(reminder.day.dayIndex())" + hourStr + minuteStr
            let request = UNNotificationRequest(identifier: requestIdentifier,
                                                content: content,
                                                trigger: triger)
            reminderList.append(request)
        }
        schedule(list: reminderList)
    }
    
    func removeWatchNotification(completion: (()->())?) {
        center.getPendingNotificationRequests {[weak self] requests in
            guard let self = self else {
                completion?()
                return
            }
            let filter = requests.filter { $0.identifier.hasPrefix(self.watchIndentifier) }
            let requestIds: [String] = filter.map {$0.identifier}
            self.center.removePendingNotificationRequests(withIdentifiers: requestIds)
            completion?()
        }
    }
    
    func removePhoneNotification(completion: (()->())?) {
        center.getPendingNotificationRequests {[weak self] requests in
            guard let self = self else {
                completion?()
                return
            }
            let filter = requests.filter { $0.identifier.hasPrefix(self.phoneInderifier) }
            let requestIds: [String] = filter.map {$0.identifier}
            self.center.removePendingNotificationRequests(withIdentifiers: requestIds)
            completion?()
        }
    }
    
    func schedule(list: [UNNotificationRequest], category: UNNotificationCategory? = nil) {
        center.delegate = self
        if let category = category {
            center.setNotificationCategories([category])
        }
        for request in list {
            center.add(request) { error in
                if let error = error {
                    print("error: \(error)")
                }
            }
        }
    }
    
    // #96 Pause button: get the weekly reminders setting, generate a weekly reminders list
    @MainActor
    func reminderSlotsForPause() throws -> [WeeklyReminderSlot] {
        guard let settings = SettingsInteractor().currentSettings else {
            throw PauseValidationError(
                message: "Reminder settings could not be loaded."
            )
        }

        // transfer "09:30" to 570 minutes
        func minutes(from text: String?) throws -> Int {
            let parts = (text ?? "").split(
                separator: ":",
                omittingEmptySubsequences: false
            )

            guard parts.count == 2,
                  let hour = Int(parts[0]),
                  let minute = Int(parts[1]),
                  (0...23).contains(hour),
                  (0...59).contains(minute) else {
                throw PauseValidationError(
                    message: "A saved reminder time is invalid."
                )
            }

            return hour * 60 + minute
        }

        // code weekdays
        func weekdays(from text: String?) throws -> [Int] {
            let availableDays = DaysViewModel().list

            let names = (text ?? "")
                .split(separator: ",")
                .map {
                    String($0).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                .filter { !$0.isEmpty }

            var result = Set<Int>()

            for name in names {
                guard let day = availableDays.first(where: {
                    $0.titleShort() == name
                }) else {
                    throw PauseValidationError(
                        message: "A saved reminder weekday is invalid."
                    )
                }

                result.insert(day.dayIndex())
            }

            return result.sorted()
        }

        var slots = Set<WeeklyReminderSlot>()

        // Watch: only count enabled reminder
        if settings.wss_reminder_enabled {
            let days = try weekdays(
                from: settings.wss_participation_days
            )

            if !days.isEmpty {
                let start = try minutes(
                    from: settings.wss_participation_time_start
                )
                let end = try minutes(
                    from: settings.wss_participation_time_end
                )
                let interval = Int(settings.wss_reminder_interval)

                guard interval > 0, end > start else {
                    throw PauseValidationError(
                        message: "The watch reminder interval or time range is invalid."
                    )
                }

                for weekday in days {
                    for time in stride(
                        from: start,
                        to: end,
                        by: interval
                    ) {
                        slots.insert(
                            WeeklyReminderSlot(
                                kind: .watch,
                                weekday: weekday,
                                hour: time / 60,
                                minute: time % 60
                            )
                        )
                    }
                }
            }
        }

        // Phone：one reminder a week
        if settings.pss_reminder_enabled {
            let days = try weekdays(
                from: settings.pss_reminder_days
            )

            if !days.isEmpty {
                let time = try minutes(
                    from: settings.pss_reminder_time
                )

                for weekday in days {
                    slots.insert(
                        WeeklyReminderSlot(
                            kind: .phone,
                            weekday: weekday,
                            hour: time / 60,
                            minute: time % 60
                        )
                    )
                }
            }
        }

        // Fix the sequence to facilitate the subsequent generation of scheduling and inspection results
        return slots.sorted {
            if $0.weekday != $1.weekday {
                return $0.weekday < $1.weekday
            }
            if $0.hour != $1.hour {
                return $0.hour < $1.hour
            }
            if $0.minute != $1.minute {
                return $0.minute < $1.minute
            }
            return $0.kind.rawValue < $1.kind.rawValue
        }
    }
    
    //#96 Pause button: Generate the earliest batch of reminders within the specified time range
    // Pause endDate < reminder < startDate
    func reminderOccurrences(
        for slots: [WeeklyReminderSlot],
        after start: Date,
        before end: Date,
        maximumCount: Int,
        includeStart: Bool = false,
        calendar: Calendar = .current
    ) -> [ReminderOccurrence] {
        guard end > start, maximumCount > 0 else {
            return []
        }
        var occurrences: [ReminderOccurrence] = []
        
        for slot in Set(slots) {
            var components = DateComponents()
                components.weekday = slot.weekday
                components.hour = slot.hour
                components.minute = slot.minute
                components.second = 0
            
            // nextDate only search date after cursor
            // -1s to cover start reminder
            var cursor = includeStart
                ? start.addingTimeInterval(-1)
                : start

            var count = 0

            while count < maximumCount {
                guard let nextDate = calendar.nextDate(
                    after: cursor,
                    matching: components,
                    matchingPolicy: .nextTime,
                    repeatedTimePolicy: .first,
                    direction: .forward
                ),
                nextDate < end else {
                    break
                }

                cursor = nextDate

                // start might include ms
                guard nextDate >= start else {
                    continue
                }

                occurrences.append(
                    ReminderOccurrence(
                        slot: slot,
                        date: nextDate
                    )
                )

                count += 1
            }
        }

        occurrences.sort {
            if $0.date != $1.date {
                return $0.date < $1.date
            }

            return $0.slot.kind.rawValue < $1.slot.kind.rawValue
        }

        return Array(occurrences.prefix(maximumCount))
    }
    
    // calculate available slot
    func availablePauseReminderCapacity(
        completion: @escaping (Int) -> Void
    ) {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            
            // replace old reminder schedule
            let otherCount = requests.filter { request in
                !request.identifier.hasPrefix(self.watchIndentifier)
                    && !request.identifier.hasPrefix(self.phoneInderifier)
            }.count

            let available = max(0, 63 - otherCount)
            
            DispatchQueue.main.async {
                completion(available)
            }
        }
    }
    
    
    // Calculate the minimum reminders that need to be arranged and check the capacity.
    func minimumRemindersForPause(
        slots: [WeeklyReminderSlot],
        pauseStart: Date,
        pauseEnd: Date,
        availableCapacity: Int,
        now: Date = Date(),
        calendar: Calendar = .current
    ) throws -> [ReminderOccurrence] {
        guard pauseEnd > pauseStart, pauseEnd > now else {
            throw PauseValidationError(
                message: "The pause end time must be after its start and in the future."
            )
        }
        guard (0...63).contains(availableCapacity) else {
            throw PauseValidationError(
                message: "The reminder capacity is invalid."
            )
        }
        
        // if no reminder
        guard !slots.isEmpty else{
            return []
        }
        
        // check capacity by +1
        let beforePause = reminderOccurrences(
            for: slots,
            after: now,
            before: pauseStart,
            maximumCount: availableCapacity + 1,
            calendar: calendar
        )
        
        guard beforePause.count <= availableCapacity else {
            throw PauseValidationError(
                message: "Too many reminders occur before this pause. Choose an earlier start."
            )
        }
        
        let remainingCapacity = availableCapacity - beforePause.count
        
        // reserve 3 calendar day after pause
        guard let threeDaysLater = calendar.date(
            byAdding: .day,
            value: 3,
            to: pauseEnd
        ),
        let searchEnd = calendar.date(
            byAdding: .day,
            value: 8,
            to: pauseEnd
        ) else {
            throw PauseValidationError(
                message: "The reminder coverage dates could not be calculated."
            )
        }
        
        // search the first reminder after pause
        let firstAfterPause = reminderOccurrences(
            for: slots,
            after: pauseEnd,
            before: searchEnd,
            maximumCount: 1,
            includeStart: true,
            calendar: calendar
        )
        
        guard let firstReminder = firstAfterPause.first else {
            throw PauseValidationError(
                message: "The next reminder could not be calculated."
            )
        }
        
        // at least cover 3 days
        let coverageEnd = max(
            threeDaysLater,
            firstReminder.date.addingTimeInterval(1)
        )
        
        let afterPause = reminderOccurrences(
            for: slots,
            after: pauseEnd,
            before: coverageEnd,
            maximumCount: remainingCapacity + 1,
            includeStart: true,
            calendar: calendar
        )
        
        guard afterPause.count <= remainingCapacity else {
            throw PauseValidationError(
                message: "There is not enough space for reminders after the pause. Try an earlier start; if it still fails, the reminder frequency exceeds the supported capacity."
            )
        }
        
        return beforePause + afterPause
    }
    
    // convert the reminder to single notification request
    func makePauseNotificationRequests(
        from occurrences: [ReminderOccurrence],
        calendar: Calendar = .current
    ) -> [UNNotificationRequest] {
        occurrences.map { occurrence in
            let content = UNMutableNotificationContent()
            content.sound = .default

            let prefix: String

            switch occurrence.slot.kind {
            case .watch:
                content.title = "Watch Survey"
                content.body = "Please fill out a survey on the watch."
                content.categoryIdentifier = "watch-category"
                prefix = watchIndentifier

            case .phone:
                content.title = "Phone Survey"
                content.body = "Please fill out a survey on the phone."
                prefix = phoneInderifier
            }

            // use specific date, not weekday
            var components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: occurrence.date
            )
            components.calendar = calendar
            components.timeZone = calendar.timeZone

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )

            // type + date
            let timestamp = Int64(
                occurrence.date.timeIntervalSince1970
            )
            let identifier = "\(prefix)pause-\(timestamp)"

            return UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
        }
    }
    
    // Generate weekly repetitive reminders according to the user's original Settings
    func makeRepeatingReminderRequests(
        from slots: [WeeklyReminderSlot]
    ) -> [UNNotificationRequest] {
        let sortedSlots = Set(slots).sorted {
            if $0.weekday != $1.weekday {
                return $0.weekday < $1.weekday
            }
            if $0.hour != $1.hour {
                return $0.hour < $1.hour
            }
            if $0.minute != $1.minute {
                return $0.minute < $1.minute
            }
            return $0.kind.rawValue < $1.kind.rawValue
        }

        return sortedSlots.map { slot in
            let content = UNMutableNotificationContent()
            content.sound = .default

            let prefix: String

            switch slot.kind {
            case .watch:
                content.title = "Watch Survey"
                content.body = "Please fill out a survey on the watch."
                content.categoryIdentifier = "watch-category"
                prefix = watchIndentifier

            case .phone:
                content.title = "Phone Survey"
                content.body = "Please fill out a survey on the phone."
                prefix = phoneInderifier
            }

            var components = DateComponents()
            components.weekday = slot.weekday
            components.hour = slot.hour
            components.minute = slot.minute
            components.second = 0

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: true
            )

            // keep the same numbering format as the original schedule
            let hourText = String(format: "%02d", slot.hour)
            let minuteText = String(format: "%02d", slot.minute)
            let identifier =
                "\(prefix)\(slot.weekday)\(hourText)\(minuteText)"

            return UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
        }
    }
    
    // replace Watch/ phone reminder, resume when unpdate failed
    @MainActor
    func replaceSurveyReminderRequests(
        with newRequests: [UNNotificationRequest],
        commit: () throws -> Void
    ) async throws {
        guard !isReplacingSurveyReminders else {
            throw PauseValidationError(
                message: "Reminders are being updated. Please try again shortly."
            )
        }

        isReplacingSurveyReminders = true
        defer {
            isReplacingSurveyReminders = false
        }

        func isSurveyReminder(_ request: UNNotificationRequest) -> Bool {
            request.identifier.hasPrefix(watchIndentifier)
                || request.identifier.hasPrefix(phoneInderifier)
        }

        //not allowed to modify other types of notification
        guard newRequests.allSatisfy({ isSurveyReminder($0) }) else {
            throw PauseValidationError(
                message: "The reminder list contains an unexpected notification."
            )
        }

        let newIDs = newRequests.map { $0.identifier }

        guard Set(newIDs).count == newIDs.count else {
            throw PauseValidationError(
                message: "The reminder list contains duplicate identifiers."
            )
        }

        // read the old schedule for capacity checking
        let pending = await center.pendingNotificationRequests()
        let oldRequests = pending.filter { isSurveyReminder($0) }
        let otherCount = pending.count - oldRequests.count

        guard newRequests.count <= max(0, 63 - otherCount) else {
            throw PauseValidationError(
                message: "Reminder capacity has changed. Please try saving again."
            )
        }

        //expired or are invalid cannot enter the new schedule
        let now = Date()
        guard newRequests.allSatisfy({
            guard let trigger = $0.trigger as? UNCalendarNotificationTrigger,
                  let date = trigger.nextTriggerDate() else {
                return false
            }
            return date > now
        }) else {
            throw PauseValidationError(
                message: "A reminder time has passed. Please try saving again."
            )
        }

        //Check whether requests that have not yet reached the sending time are still in the system queue
        func requestsArePresent(
            _ expected: [UNNotificationRequest]
        ) async -> Bool {
            let pending = await center.pendingNotificationRequests()

            // Only check survey reminders; leave other notifications alone.
            let actual = pending.filter { isSurveyReminder($0) }
            let checkTime = Date()

            func matches(
                _ saved: UNNotificationRequest,
                _ request: UNNotificationRequest
            ) -> Bool {
                saved.identifier == request.identifier
                    && saved.trigger?.isEqual(request.trigger) == true
                    && saved.content.isEqual(request.content)
            }

            // Every remaining survey reminder must belong to the expected schedule.
            let hasUnexpectedRequests = actual.contains { saved in
                !expected.contains { request in
                    matches(saved, request)
                }
            }

            guard !hasUnexpectedRequests else {
                return false
            }

            // Future reminders must be present.
            // Single reminders that became due during the operation may be gone.
            return expected.allSatisfy { request in
                guard let trigger =
                        request.trigger as? UNCalendarNotificationTrigger else {
                    return false
                }

                guard let nextDate = trigger.nextTriggerDate(),
                      nextDate > checkTime else {
                    return true
                }

                return actual.contains { saved in
                    matches(saved, request)
                }
            }
        }

        let oldIDs = oldRequests.map { $0.identifier }
        center.removePendingNotificationRequests(withIdentifiers: oldIDs)

        do {
            // Wait for the system to receive each item one by one; Failure will go into catch
            for request in newRequests {
                try await center.add(request)
            }

            guard await requestsArePresent(newRequests) else {
                throw PauseValidationError(
                    message: "Some reminders were not retained by the system."
                )
            }
            try commit()
        } catch {
            let updateError = error.localizedDescription

            // Delete some of the requests that may have been successfully added this time
            center.removePendingNotificationRequests(
                withIdentifiers: newIDs
            )

            var restoreFailed = false
            var requestsToRestore: [UNNotificationRequest] = []

            for request in oldRequests {
                // Expired single reminders will not be reissued
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
                    restoreFailed = true
                    continue
                }

                guard let nextDate = trigger.nextTriggerDate(),
                      nextDate > Date() else {
                    continue
                }

                requestsToRestore.append(request)

                do {
                    try await center.add(request)
                } catch {
                    restoreFailed = true
                }
            }

            let restored = await requestsArePresent(requestsToRestore)

            if restoreFailed || !restored {
                throw PauseValidationError(
                    message: "Reminder update failed, and the previous schedule could not be fully restored. \(updateError)"
                )
            }

            throw PauseValidationError(
                message: "Reminder update failed. The previous pending schedule was restored. \(updateError)"
            )
        }
    }
    
    #if DEBUG
    func debugCheckPauseCapacity() {
        // fix the date ans time
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        func date(_ day: Int, _ hour: Int = 0) -> Date {
            calendar.date(
                from: DateComponents(
                    year: 2026,
                    month: 9,
                    day: day,
                    hour: hour
                )
            )!
        }

        // everyday 09:00，one Phone reminder
        let slots = (1...7).map {
            WeeklyReminderSlot(
                kind: .phone,
                weekday: $0,
                hour: 9,
                minute: 0
            )
        }

        let now = date(21, 8)
        let pauseStart = date(22, 9)
        let pauseEnd = date(24, 9)

        do {
            let reminders = try minimumRemindersForPause(
                slots: slots,
                pauseStart: pauseStart,
                pauseEnd: pauseEnd,
                availableCapacity: 4,
                now: now,
                calendar: calendar
            )

            let expectedDates = [
                date(21, 9), // before pause
                date(24, 9), // after pause
                date(25, 9),
                date(26, 9)
            ]

            guard reminders.map({ $0.date }) == expectedDates else {
                print("FAIL: reminder dates do not match expectations")
                return
            }

            print("PASS: correct dates, including the pause-end boundary")
        } catch {
            print("FAIL: capacity 4 should be sufficient: \(error)")
            return
        }

        do {
            _ = try minimumRemindersForPause(
                slots: slots,
                pauseStart: pauseStart,
                pauseEnd: pauseEnd,
                availableCapacity: 3,
                now: now,
                calendar: calendar
            )

            print("FAIL: capacity 3 should be rejected")
        } catch {
            // This group only accepts the expected error of "insufficient capacity after recovery"
            let expectedMessage =
                "There is not enough space for reminders after the pause. Try an earlier start; if it still fails, the reminder frequency exceeds the supported capacity."

            if let validationError = error as? PauseValidationError,
               validationError.message == expectedMessage {
                print("PASS: insufficient capacity is rejected")
            } else {
                print("FAIL: unexpected error: \(error)")
            }
        }
    }
    #endif
        
        // MARK: - HELPRES
        func retriveHourAndMinute(time: Int) -> (hour: Int, minute: Int) {
            var hour = 0
            var minute = time
            if time > 60 {
                hour = time / 60
                minute = time - (hour * 60)
            }
            
            return (hour: hour, minute: minute)
        }
    }

// MARK: -  UNUserNotificationCenterDelegate

extension ReminderManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.banner)
    }
}
