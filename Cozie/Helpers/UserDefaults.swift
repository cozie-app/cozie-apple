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
//        case recentLeanBodyMass
        case recentRestingHeartRate
//        case recentBodyTemperature
//        case recentRespiratoryRate
        case recentStepCount
//        case recentDistanceCycling
//        case recentUVExposure
//        case recentFlightsClimbed
        case recentAppleStandTime
//        case recentHeadphoneAudioExposure
//        case recentDistanceSwimming
        case recentDistanceWalkingRunning
//        case recentVo2Max
//        case recentPeakExpiratoryFlowRate
//        case recentHeartRateVariabilitySDNN
//        case recentWalkingHeartRateAverage
        case recentBloodPressureSystolic
        case recentBloodPressureDiastolic
//        case recentBasalBodyTemperature
//        case recentDietaryWater
//        case recentWalkingSpeed
//        case recentWalkingStepLength
//        case recentSixMinuteWalkTestDistance
//        case recentWalkingAsymmetryPercentage
//        case recentWalkingDoubleSupportPercentage
//        case recentStairAscentSpeed
//        case recentStairDescentSpeed
//        case recentAppleWalkingSteadiness
    }

    func setValue(for key: String, value: Any) {
        setValue(value, forKey: key)
        do {
            let postMessage = try JSONEncoder().encode(FormatAPI(timestamp_location: GetDateTimeISOString(),
                    timestamp_start: GetDateTimeISOString(),
                    timestamp_end: GetDateTimeISOString(),
                    id_participant: getValue(for: UserDefaultKeys.participantID.rawValue) as? String ?? "",
                    id_experiment: getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "",
                    responses: ["settings_participation_days": "\(getValue(for: UserDefaultKeys.ParticipationDays.rawValue) as? [Bool] ?? [false])",
                                "settings_notification_frequency": "\(getValue(for: UserDefaultKeys.ReminderFrequency.rawValue) as? Date ?? defaultNotificationFrq) ",
                                "settings_participation_time_start": "\(getValue(for: UserDefaultKeys.FromTime.rawValue) as? Date ?? defaultFromTime)",
                                "settings_participation_time_end": "\(getValue(for: UserDefaultKeys.ToTime.rawValue) as? Date ?? defaultToTime)"],
                    id_device: UIDevice.current.identifierForVendor?.uuidString ?? "",
                    id_one_signal: OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId ?? "ID not yet retrieved"))
            _ = PostRequest(message: postMessage)
        } catch let error {
            print("error UD: \(error.localizedDescription)")
        }
        synchronize()
    }

    func getValue(for key: String) -> Any {
        return value(forKey: key) ?? 0
    }
}
