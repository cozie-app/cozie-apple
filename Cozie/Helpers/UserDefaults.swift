//
//  UserDefaults.swift
//  Cozie
//
//  Created by Square Infosoft on 16/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static var shared = UserDefaults()
    
    enum UserDefaultKeys: String {
        case ParticipationDays
        case NotificationFrequency
        case FromTime
        case ToTime
        case NotificationEnable
        case questions
        case permissions
        case participantID
        case experimentID
        case totalValidResponse
        case dayData
        case recentHeartRate
        case recentNoise
        case recentBloodOxygen
    }
    
    func setValue(for key: String, value: Any) {
        setValue(value, forKey: key)
        do {
            let postMessage = try JSONEncoder().encode(APIFormate(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: self.getValue(for: UserDefaultKeys.participantID.rawValue) as? String ?? "", responses: ["question_participation_Days":"\(self.getValue(for: UserDefaultKeys.ParticipationDays.rawValue) as? [Bool] ?? [false])", "question_notification_frequency":"\(self.getValue(for: UserDefaultKeys.NotificationFrequency.rawValue) as? Date ?? defaultNotificationFrq) ","question_from_time":"\(self.getValue(for: UserDefaultKeys.FromTime.rawValue) as? Date ?? defaultFromTime)"]))
            PostRequest(message: postMessage)
        } catch let error {
            print(error.localizedDescription)
        }
        synchronize()
    }
    
    func getValue(for key: String) -> Any {
        return value(forKey: key) ?? 0
    }
}
