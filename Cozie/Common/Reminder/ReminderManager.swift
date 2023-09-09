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
