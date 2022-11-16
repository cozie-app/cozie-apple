//
//  NotificationHelper.swift
//  Cozie
//
//  Created by Amit Surani on 29/01/22.
//  Copyright © 2022 Federico Tartarini. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications


class LocalNotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = LocalNotificationManager()

    private override init() {}

    func registerForPushNotifications() {

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: { _, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }

    func scheduleReminderNotification() {
        clearNotifications()
        if (UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.NotificationEnable.rawValue) as? Bool ?? true) {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

            let allowedDays = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ParticipationDays.rawValue) as? [Bool] ?? [true, true, true, true, true, false, false]
            var fromTime = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.FromTime.rawValue) as? Date ?? defaultFromTime
            var toTime = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ToTime.rawValue) as? Date ?? defaultToTime
            var intervalTimeInMin: Int {
                get {
                    let tempInterTime = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ReminderFrequency.rawValue) as? Date ?? defaultNotificationFrq
                    let hours = Int(tempInterTime.getHour()) ?? 0
                    var minis = Int(tempInterTime.getMinutes()) ?? 0
                    minis = minis + (hours * 60)
                    return minis
                }
            }

            var fromTimeDateComponents = DateComponents()
            fromTimeDateComponents.timeZone = .current
            fromTimeDateComponents.hour = Calendar.current.component(.hour, from: fromTime)
            fromTimeDateComponents.minute = Calendar.current.component(.minute, from: fromTime)

            // Create date from components
            fromTime = Calendar.current.date(from: fromTimeDateComponents) ?? Date()

            var toTimeDateComponents = DateComponents()
            toTimeDateComponents.timeZone = .current
            toTimeDateComponents.hour = Calendar.current.component(.hour, from: toTime)
            toTimeDateComponents.minute = Calendar.current.component(.minute, from: toTime)

            // Create date from components
            toTime = Calendar.current.date(from: toTimeDateComponents) ?? Date()

            var times = [Date]()

            for _ in 0..<1440 {
                if fromTime > toTime {
                    break
                }

                times.append(fromTime)
                fromTime = Calendar.current.date(byAdding: .minute, value: intervalTimeInMin, to: fromTime) ?? Date()
            }

            for weekDay in DateFormatter().shortWeekdaySymbols {
                if weekDay == "Mon" && allowedDays[0] {
                    self.scheduleNotification(weekDay: 2, weekDayStr: weekDay, times: times)
                }

                if weekDay == "Tue" && allowedDays[1] {
                    self.scheduleNotification(weekDay: 3, weekDayStr: weekDay, times: times)
                }

                if weekDay == "Wed" && allowedDays[2] {
                    self.scheduleNotification(weekDay: 4, weekDayStr: weekDay, times: times)
                }

                if weekDay == "Thu" && allowedDays[3] {
                    self.scheduleNotification(weekDay: 5, weekDayStr: weekDay, times: times)
                }

                if weekDay == "Fri" && allowedDays[4] {
                    self.scheduleNotification(weekDay: 6, weekDayStr: weekDay, times: times)
                }

                if weekDay == "Sat" && allowedDays[5] {
                    self.scheduleNotification(weekDay: 7, weekDayStr: weekDay, times: times)
                }

                if weekDay == "Sun" && allowedDays[6] {
                    self.scheduleNotification(weekDay: 1, weekDayStr: weekDay, times: times)
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    private func scheduleNotification(weekDay: Int, weekDayStr: String, times: [Date]) {
        for time in times {
            let hr = time.getHour()
            let mi = time.getMinutes()
            var triggerDate = DateComponents()
            triggerDate.hour = Int(hr)
            triggerDate.minute = Int(mi)
            triggerDate.second = 00
            triggerDate.timeZone = .current
            triggerDate.weekday = weekDay
            let content = UNMutableNotificationContent()
            content.title = "Survey reminder"
            content.body = "Survey reminder"
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            let request = UNNotificationRequest(identifier: "\(weekDay)\(hr)\(mi)\(weekDayStr)\(Date().timeIntervalSinceNow)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { err in
                print(err?.localizedDescription ?? "")
            }
        }
    }

    func clearNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
