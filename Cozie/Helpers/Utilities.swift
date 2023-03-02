//
//  Utilities.swift
//  Cozie
//
//  Created by Federico Tartarini on 13/7/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import HealthKit
import OneSignal

struct HealthData: Codable {
    let locationTimestamp: String
    let startTimestamp: String
    let endTimestamp: String
    let participantID: String
    let experimentID: String
    let ts_heartRate: [String: Double]?
    let ts_bloodPressureSystolic: [String: Double]?
    let ts_bloodPressureDiastolic: [String: Double]?
    let ts_hearingEnvironmentalExposure: [String: Double]?
    let deviceUUID: String
    let ts_bodyMass: [String: Double]?
    let ts_BMI: [String: Double]?
    let ts_oxygenSaturation: [String: Double]?
    let ts_stepCount: [String: Double]?
    let ts_standTime: [String: Double]?
    let ts_walkingDistance: [String: Double]?
    let ts_restingHeartRate: [String: Double]?

    enum CodingKeys: String, CodingKey {
        case locationTimestamp, ts_heartRate, ts_bloodPressureSystolic, ts_bloodPressureDiastolic, ts_hearingEnvironmentalExposure, ts_bodyMass, ts_BMI, ts_oxygenSaturation, ts_stepCount, ts_standTime, ts_walkingDistance, ts_restingHeartRate
        case startTimestamp = "timestamp_start"
        case participantID = "id_participant"
        case deviceUUID = "id_device"
        case experimentID = "id_experiment"
        case endTimestamp = "timestamp_end"
    }
}

class Utilities {

    static func styledTextField(_ textField: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        bottomLine.backgroundColor = UIColor.init(red: 255 / 255, green: 98 / 255, blue: 20 / 255, alpha: 1).cgColor
        textField.borderStyle = .none
        textField.layer.addSublayer(bottomLine)
    }

    static func alert(url: URL, title: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: "Are you sure you want to open this page in a new tab? This might take a few moments", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            (alert: UIAlertAction) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }

    static func createJSON(dic: [Response]) {
        var jsonString = ""
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(dic)
            jsonString = String(decoding: encoded, as: UTF8.self)
        } catch {
            print(error)
        }
        saveJSON(jsonString: jsonString)
    }

    static func saveJSON(jsonString: String) {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathWithFilename = documentDirectory.appendingPathComponent("data.json")
            do {
                try jsonString.write(to: pathWithFilename,
                        atomically: true,
                        encoding: .utf8)
            } catch {
                print("failed to write JSON file :\(error.localizedDescription)")
            }
        }
    }

    static func downloadData(_ sender: UIViewController) {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        sender.present(alert, animated: true, completion: nil)

        getData(isForDownload: true) { (isSuccess, data) in
            sender.dismiss(animated: false, completion: nil)
            if isSuccess {
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let pathWithFilename = documentDirectory.appendingPathComponent("data.json")
                    let activityItems = [pathWithFilename]
                    let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                    vc.popoverPresentationController?.sourceView = sender.view
                    sender.present(vc, animated: true, completion: nil)
                }
            }
        }
    }

    static func getData(isForDownload: Bool = false, completion: @escaping (Bool, [Response]) -> Void) {

        let param = [
            "id_participant": UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "ExternalTester",
            "id_experiment": UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "AppleStore",
            "weeks": "50"]

        let headers = ["x-api-key": AWSReadAPIKey, // Singapore API key
                       "Accept": "application/json",
                       "Content-Type": "application/json"]

        _ = Alamofire.request(AWSReadURL, method: .get, parameters: param, headers: headers).responseJSON { (response) in
            if let responseCode = response.response?.statusCode {
                if responseCode == 200 {
                    if let values = response.result.value as? NSArray, let dictionary = values.lastObject as? NSDictionary, let data = dictionary["data"] as? NSDictionary {
                        if isForDownload {
                            //                            self.saveJSON(jsonString: data)
                            completion(true, [Response]())
                        } else {
                            var totalData = [Response]()
                            data.forEach { element in
                                do {
                                    let data = try JSONSerialization.data(withJSONObject: element.value, options: .prettyPrinted)
                                    let responseData = try JSONDecoder().decode(Response.self, from: data)
                                    totalData.append(responseData)
                                } catch {
                                    print(error)
                                }
                            }
                            completion(true, totalData)
                        }
                    } else {
                        print("error")
                        completion(false, [])
                    }
                    if let values = response.result.value as? NSArray, let dictionary = values.firstObject as? NSDictionary, let date = dictionary["last_sync_timestamp"] as? Double {
                        UserDefaults.shared.setValue(for: "last_sync_timestamp", value: date)
                    }
                } else {
                    completion(false, [])
                }
            }
        }
    }

    static func sendHealthData(data: [String: String]) {
        do {
            let postMessage = try JSONEncoder().encode(FormatAPI(timestamp_location: GetDateTimeISOString(), timestamp_start: GetDateTimeISOString(), timestamp_end: GetDateTimeISOString(), id_participant: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", id_experiment: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", responses: data, id_device: UIDevice.current.identifierForVendor?.uuidString ?? ""))
            _ = PostRequest(message: postMessage)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    static func sendHealthData(data: [String: Double], type: healthType, samples: [HKQuantitySample]) {

        if (data == [:]) {
            return
        }

        do {
            var postMessage = Data()
            switch type {
            case .ts_body_mass:
                postMessage = try JSONEncoder().encode(HealthData(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", experimentID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", ts_heartRate: nil, ts_bloodPressureSystolic: nil, ts_bloodPressureDiastolic: nil, ts_hearingEnvironmentalExposure: nil, deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", ts_bodyMass: data, ts_BMI: nil, ts_oxygenSaturation: nil, ts_stepCount: nil, ts_standTime: nil, ts_walkingDistance: nil, ts_restingHeartRate: nil))
            case .ts_body_mass_index:
                postMessage = try JSONEncoder().encode(HealthData(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", experimentID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", ts_heartRate: nil, ts_bloodPressureSystolic: nil, ts_bloodPressureDiastolic: nil, ts_hearingEnvironmentalExposure: nil, deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", ts_bodyMass: nil, ts_BMI: data, ts_oxygenSaturation: nil, ts_stepCount: nil, ts_standTime: nil, ts_walkingDistance: nil, ts_restingHeartRate: nil))
                    //            case .ts_leanBodyMass:
                    //                break
            case .ts_heart_rate:
                postMessage = try JSONEncoder().encode(HealthData(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", experimentID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", ts_heartRate: data, ts_bloodPressureSystolic: nil, ts_bloodPressureDiastolic: nil, ts_hearingEnvironmentalExposure: nil, deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", ts_bodyMass: nil, ts_BMI: nil, ts_oxygenSaturation: nil, ts_stepCount: nil, ts_standTime: nil, ts_walkingDistance: nil, ts_restingHeartRate: nil))
            case .ts_resting_heart_rate:
                postMessage = try JSONEncoder().encode(HealthData(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", experimentID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", ts_heartRate: nil, ts_bloodPressureSystolic: nil, ts_bloodPressureDiastolic: nil, ts_hearingEnvironmentalExposure: nil, deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", ts_bodyMass: nil, ts_BMI: nil, ts_oxygenSaturation: nil, ts_stepCount: nil, ts_standTime: nil, ts_walkingDistance: nil, ts_restingHeartRate: data))
                    //            case .ts_bodyTemperature:
                    //                break
                    //            case .ts_respiratoryRate:
                    //                break
            case .ts_step_count:
                postMessage = try JSONEncoder().encode(HealthData(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", experimentID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", ts_heartRate: nil, ts_bloodPressureSystolic: nil, ts_bloodPressureDiastolic: nil, ts_hearingEnvironmentalExposure: nil, deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", ts_bodyMass: nil, ts_BMI: nil, ts_oxygenSaturation: nil, ts_stepCount: data, ts_standTime: nil, ts_walkingDistance: nil, ts_restingHeartRate: nil))
                    //            case .ts_distanceCycling:
                    //                break
                    //            case .ts_uvExposure:
                    //                postMessage = try JSONEncoder().encode(HealthData(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", ts_heartRate: nil, ts_bloodPressureSystolic: nil, ts_bloodPressureDiastolic: nil, ts_hearingEnvironmentalExposure: data, deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", ts_bodyMass: nil, ts_BMI: nil, ts_oxygenSaturation: nil, ts_stepCount: nil, ts_standTime: nil, ts_walkingDistance: nil, ts_restingHeartRate: nil))
                    //            case .ts_flightsClimbed:
                    //                break
            case .ts_stand_time:
                postMessage = try JSONEncoder().encode(HealthData(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", experimentID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", ts_heartRate: nil, ts_bloodPressureSystolic: nil, ts_bloodPressureDiastolic: nil, ts_hearingEnvironmentalExposure: nil, deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", ts_bodyMass: nil, ts_BMI: nil, ts_oxygenSaturation: nil, ts_stepCount: nil, ts_standTime: data, ts_walkingDistance: nil, ts_restingHeartRate: nil))
            case .ts_hearing_environmental_exposure:
                postMessage = try JSONEncoder().encode(HealthData(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", experimentID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", ts_heartRate: nil, ts_bloodPressureSystolic: nil, ts_bloodPressureDiastolic: nil, ts_hearingEnvironmentalExposure: data, deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", ts_bodyMass: nil, ts_BMI: nil, ts_oxygenSaturation: nil, ts_stepCount: nil, ts_standTime: nil, ts_walkingDistance: nil, ts_restingHeartRate: nil))
                    //            case .ts_headphoneAudioExposure:
                    //                break
                    //            case .ts_distanceSwimming:
                    //                break
            case .ts_distance_walking_running:
                postMessage = try JSONEncoder().encode(HealthData(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", experimentID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", ts_heartRate: nil, ts_bloodPressureSystolic: nil, ts_bloodPressureDiastolic: nil, ts_hearingEnvironmentalExposure: nil, deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", ts_bodyMass: nil, ts_BMI: nil, ts_oxygenSaturation: nil, ts_stepCount: nil, ts_standTime: nil, ts_walkingDistance: data, ts_restingHeartRate: nil))
                    //            case .ts_vo2Max:
                    //                break
                    //            case .ts_peakExpiratoryFlowRate:
                    //                break
                    //            case .ts_heartRateVariabilitySDNN:
                    //                break
                    //            case .ts_walkingHeartRateAverage:
                    //                break
            case .ts_oxygen_saturation:
                postMessage = try JSONEncoder().encode(HealthData(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", experimentID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", ts_heartRate: nil, ts_bloodPressureSystolic: nil, ts_bloodPressureDiastolic: nil, ts_hearingEnvironmentalExposure: nil, deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", ts_bodyMass: nil, ts_BMI: nil, ts_oxygenSaturation: data, ts_stepCount: nil, ts_standTime: nil, ts_walkingDistance: nil, ts_restingHeartRate: nil))
            case .ts_blood_pressure_systolic:
                postMessage = try JSONEncoder().encode(HealthData(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", experimentID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", ts_heartRate: nil, ts_bloodPressureSystolic: data, ts_bloodPressureDiastolic: nil, ts_hearingEnvironmentalExposure: nil, deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", ts_bodyMass: nil, ts_BMI: nil, ts_oxygenSaturation: nil, ts_stepCount: nil, ts_standTime: nil, ts_walkingDistance: nil, ts_restingHeartRate: nil))
            case .ts_blood_pressure_diastolic:
                postMessage = try JSONEncoder().encode(HealthData(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", experimentID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "", ts_heartRate: nil, ts_bloodPressureSystolic: nil, ts_bloodPressureDiastolic: data, ts_hearingEnvironmentalExposure: nil, deviceUUID: UIDevice.current.identifierForVendor?.uuidString ?? "", ts_bodyMass: nil, ts_BMI: nil, ts_oxygenSaturation: nil, ts_stepCount: nil, ts_standTime: nil, ts_walkingDistance: nil, ts_restingHeartRate: nil))
                    //            case .ts_basalBodyTemperature:
                    //                break
                    //            case .ts_dietaryWater:
                    //                break
                    //            case .ts_walkingSpeed:
                    //                break
                    //            case .ts_walkingStepLength:
                    //                break
                    //            case .ts_sixMinuteWalkTestDistance:
                    //                break
                    //            case .ts_walkingAsymmetryPercentage:
                    //                break
                    //            case .ts_walkingDoubleSupportPercentage:
                    //                break
                    //            case .ts_stairAscentSpeed:
                    //                break
                    //            case .ts_stairDescentSpeed:
                    //                break
                    //            case .ts_appleWalkingSteadiness:
                    //                break
            }
            DispatchQueue.global(qos: .background).async {
                let code = PostRequest(message: postMessage)
                if code == 200 {
                    samples
                            .forEach {
                                updateSyncDate(sample: $0)
                            }
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    static func updateSyncDate(sample: HKQuantitySample) {
        if var syncedData = UserDefaults.shared.getValue(for: "syncedData\(String(describing: sample.sampleType))") as? [String] {
            if syncedData.contains(sample.uuid.uuidString) {
                return
            } else {
                syncedData.append(sample.uuid.uuidString)
                UserDefaults.shared.setValue(for: "syncedData\(String(describing: sample.sampleType))", value: syncedData)
            }
        } else {
            UserDefaults.shared.setValue(for: "syncedData\(String(describing: sample.sampleType))", value: [sample.uuid.uuidString])
        }
    }
}

struct Response: Codable {
    let timestamp: String?
    let latitude: Double?
    let longitude: Double?
    let id_participant: String
    let vote_count: Int?

    func encode(to encoder: Encoder) throws {
        var val = encoder.container(keyedBy: CodingKeys.self)
        try val.encode(timestamp, forKey: .timestamp)
        try val.encode(latitude, forKey: .latitude)
        try val.encode(longitude, forKey: .longitude)
        try val.encode(id_participant, forKey: .id_participant)
        try val.encode(vote_count, forKey: .vote_count)
    }
}

enum healthType {
    case ts_body_mass
    case ts_body_mass_index
    //    case ts_leanBodyMass
    case ts_heart_rate
    case ts_resting_heart_rate
    //    case ts_bodyTemperature
    //    case ts_respiratoryRate
    case ts_step_count
    //    case ts_distanceCycling
    //    case ts_uvExposure
    //    case ts_flightsClimbed
    case ts_stand_time
    case ts_hearing_environmental_exposure
    //    case ts_headphoneAudioExposure
    //    case ts_distanceSwimming
    case ts_distance_walking_running
    //    case ts_vo2Max
    //    case ts_peakExpiratoryFlowRate
    //    case ts_heartRateVariabilitySDNN
    //    case ts_walkingHeartRateAverage
    case ts_oxygen_saturation
    case ts_blood_pressure_systolic
    case ts_blood_pressure_diastolic
    //    case ts_basalBodyTemperature
    //    case ts_dietaryWater
    //    case ts_walkingSpeed
    //    case ts_walkingStepLength
    //    case ts_sixMinuteWalkTestDistance
    //    case ts_walkingAsymmetryPercentage
    //    case ts_walkingDoubleSupportPercentage
    //    case ts_stairAscentSpeed
    //    case ts_stairDescentSpeed
    //    case ts_appleWalkingSteadiness
}

struct FormatAPI: Codable {
    let timestamp_location: String
    let timestamp_start: String
    let timestamp_end: String
    let id_participant: String
    let id_experiment: String
    let responses: [String: String]
    let id_device: String
    var id_one_signal: String = ""
}

public func PostRequestSettings() {
    do {
        let deviceState = OneSignal.getDeviceState()
        let player_id = deviceState?.userId

        let postMessage = try JSONEncoder().encode(FormatAPI(timestamp_location: GetDateTimeISOString(),
                timestamp_start: GetDateTimeISOString(),
                timestamp_end: GetDateTimeISOString(),
                id_participant: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "",
                id_experiment: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? "",
                responses: ["settings_participation_days": "\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ParticipationDays.rawValue) as? [Bool] ?? [false])",
                            "settings_notification_frequency": "\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ReminderFrequency.rawValue) as? Date ?? defaultNotificationFrq) ",
                            "settings_from_time": "\(UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.FromTime.rawValue) as? Date ?? defaultFromTime)"],
                id_device: UIDevice.current.identifierForVendor?.uuidString ?? "",
                id_one_signal: player_id ?? "ID not yet retrieved"))
        _ = PostRequest(message: postMessage)
    } catch let error {
        print("error UD: \(error.localizedDescription)")
    }
//    synchronize()
}


