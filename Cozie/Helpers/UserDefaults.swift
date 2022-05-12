//
//  UserDefaults.swift
//  Cozie
//
//  Created by Square Infosoft on 16/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import Foundation
import UIKit
import OneSignal

extension UserDefaults {

    static var shared = UserDefaults()

    enum UserDefaultKeys: String {
        case ParticipationDays
        case ReminderFrequency
        case FromTime
        case ToTime
        case NotificationEnable
        case selectedQuestionFlow
        case permissions
        case participantID
        case experimentID
        case studyGoal
        case totalValidResponse
        case dayData
        case recentHeartRate
        case recentNoise
        case recentBloodOxygen
        case recentBodyMass
        case recentBodyMassIndex
        case recentLeanBodyMass
        case recentRestingHeartRate
        case recentBodyTemperature
        case recentRespiratoryRate
        case recentStepCount
        case recentDistanceCycling
        case recentUVExposure
        case recentFlightsClimbed
        case recentAppleStandTime
        case recentHeadphoneAudioExposure
        case recentDistanceSwimming
        case recentDistanceWalkingRunning
        case recentVo2Max
        case recentPeakExpiratoryFlowRate
        case recentHeartRateVariabilitySDNN
        case recentWalkingHeartRateAverage
        case recentBloodPressureSystolic
        case recentBloodPressureDiastolic
        case recentBasalBodyTemperature
        case recentDietaryWater
        case recentWalkingSpeed
        case recentWalkingStepLength
        case recentSixMinuteWalkTestDistance
        case recentWalkingAsymmetryPercentage
        case recentWalkingDoubleSupportPercentage
        case recentStairAscentSpeed
        case recentStairDescentSpeed
        case recentAppleWalkingSteadiness
    }

    func setValue(for key: String, value: Any) {
        setValue(value, forKey: key)
        do {
            let postMessage = try JSONEncoder().encode(FormatAPI(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: getValue(for: UserDefaultKeys.participantID.rawValue) as? String ?? "", responses: ["settings_participation_Days": "\(getValue(for: UserDefaultKeys.ParticipationDays.rawValue) as? [Bool] ?? [false])", "settings_notification_frequency": "\(getValue(for: UserDefaultKeys.ReminderFrequency.rawValue) as? Date ?? defaultNotificationFrq) ", "settings_from_time": "\(getValue(for: UserDefaultKeys.FromTime.rawValue) as? Date ?? defaultFromTime)"], deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", oneSignalUserID: OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId))
            PostRequest(message: postMessage)
        } catch let error {
            print("error UD: \(error.localizedDescription)")
        }
        synchronize()
    }

    func getValue(for key: String) -> Any {
        return value(forKey: key) ?? 0
    }
}
