//
//  SystemInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 11.04.23.
//

import UIKit

let testTag = Tags(idOnesignal: "", idParticipant: "", idPassword: "")

let testFields = Fields(wssGoal: 0, wssTitle: "", wssTimeOut: 0, wssReminderEnabeled: false, wssReminderInterval: 0, wssParticipationDays: "", wssParticipationTimeStart: "", wssParticipationTimeEnd: "", apiReadUrl: "", apiReadKey: "", apiWriteUrl: "", apiWriteKey: "", pssReminderEnabled: false, pssReminderTime: "", pssReminderDays: "", siIosVersion: "", siWatchosVersion: "", siIphoneModel: "", siWatchModel: "", siIphoneDeviceID: "", siWatchDeviceID: "", siIphoneBatteryChargeState: 0, siWatchBatteryChargeState: 0, siIphoneWifiSignalStrength: "", siWatchWifiSignalStrength: "", siIphoneCellularSignalStrength: "", siWatchCellularSignalStrength: "", siIphoneLocationServiceEnabled: false, siWatchLocationServiceEnabled: false, siIphoneLowBatteryModeEnabled: false, siWatchConnectedToPhone: false, appBundleName: "", appBundleBuildVersion: "", appBundleBuildNumber: "", appOneSignalAppID: "", apiPhoneSurveyURL: "", apiWatchSurveyURL: "", transmitTrigger: "")

let testLog = Logs(time: "2023-01-01T07:02:51.578Z", measurement: "dev", tags: testTag, fields: testFields)

class LogsSystemInteractor {
    let userIntaractor = UserInteractor()
    let settingsInteractor = SettingsInteractor()
    let backendInteractor = BackendInteractor()
    
    func logsData() -> Logs {
        guard let user = userIntaractor.currentUser, let settings = settingsInteractor.currentSettings, let backend = backendInteractor.currentBackendSettings else { return testLog }
        let tag = Tags(idOnesignal: CozieStorage.shared.playerID(), idParticipant: user.participantID ?? "", idPassword: user.passwordID ?? "")
        let fields = Fields(wssGoal: Int(settings.wss_goal),
                             wssTitle: settings.wss_title ?? "",
                             wssTimeOut: Int(settings.wss_time_out),
                             wssReminderEnabeled: settings.wss_reminder_enabeled,
                             wssReminderInterval: Int(settings.wss_reminder_interval),
                             wssParticipationDays: settings.wss_participation_days ?? "",
                             wssParticipationTimeStart: settings.wss_participation_time_start ?? "",
                             wssParticipationTimeEnd: settings.wss_participation_time_end ?? "",
                             apiReadUrl: backend.api_read_url ?? "",
                             apiReadKey: backend.api_read_key ?? "",
                             apiWriteUrl: backend.api_write_url ?? "",
                             apiWriteKey: backend.api_write_key ?? "",
                             pssReminderEnabled: settings.pss_reminder_enabled,
                             pssReminderTime: settings.pss_reminder_time ?? "",
                             pssReminderDays: settings.pss_reminder_days ?? "",
                             siIosVersion: UIDevice.current.systemVersion,
                             siWatchosVersion: "",
                             siIphoneModel: "",
                             siWatchModel: "",
                             siIphoneDeviceID: "",
                             siWatchDeviceID: "",
                             siIphoneBatteryChargeState: Int(UIDevice.current.batteryLevel * 100),
                             siWatchBatteryChargeState: 0,
                             siIphoneWifiSignalStrength: "",
                             siWatchWifiSignalStrength: "",
                             siIphoneCellularSignalStrength: "",
                             siWatchCellularSignalStrength: "",
                             siIphoneLocationServiceEnabled: false,
                             siWatchLocationServiceEnabled: false,
                             siIphoneLowBatteryModeEnabled: false,
                             siWatchConnectedToPhone: false,
                             appBundleName: "Coze - Dev",
                             appBundleBuildVersion: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
                             appBundleBuildNumber: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
                             appOneSignalAppID: backend.one_signal_id ?? "",
                             apiPhoneSurveyURL: backend.phone_survey_link ?? "",
                             apiWatchSurveyURL: backend.watch_survey_link ?? "",
                             transmitTrigger: "app_change_settings")
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.string(from: date)
        let logs = Logs(time: dateString, measurement: user.experimentID ?? "", tags: tag, fields: fields)
        
        return logs
    }
}
// MARK: - Settings
class Logs: Codable {
    var time, measurement: String
    var tags: Tags
    var fields: Fields

    init(time: String, measurement: String, tags: Tags, fields: Fields) {
        self.time = time
        self.measurement = measurement
        self.tags = tags
        self.fields = fields
    }
}

// MARK: - Fields
class Fields: Codable {
    var wssGoal: Int
    var wssTitle: String
    var wssTimeOut, wssReminderInterval: Int
    var wssParticipationDays, wssParticipationTimeStart, wssParticipationTimeEnd: String
    var apiReadUrl, apiReadKey, apiWriteUrl, apiWriteKey: String
    var pssReminderTime, pssReminderDays, siIosVersion, siWatchosVersion: String
    var siIphoneModel, siWatchModel, siIphoneDeviceID, siWatchDeviceID: String
    var siIphoneBatteryChargeState, siWatchBatteryChargeState: Int
    var siIphoneWifiSignalStrength, siWatchWifiSignalStrength, siIphoneCellularSignalStrength, siWatchCellularSignalStrength: String
    var wssReminderEnabeled, pssReminderEnabled, siIphoneLocationServiceEnabled, siWatchLocationServiceEnabled, siIphoneLowBatteryModeEnabled, siWatchConnectedToPhone: Bool
    var appBundleName, appBundleBuildVersion, appBundleBuildNumber, appOneSignalAppID: String
    var apiPhoneSurveyURL, apiWatchSurveyURL: String
    var transmitTrigger: String

    enum CodingKeys: String, CodingKey {
        case wssGoal = "wss_goal"
        case wssTitle = "wss_title"
        case wssTimeOut = "wss_time_out"
        case wssReminderEnabeled = "wss_reminder_enabeled"
        case wssReminderInterval = "wss_reminder_interval"
        case wssParticipationDays = "wss_participation_days"
        case wssParticipationTimeStart = "wss_participation_time_start"
        case wssParticipationTimeEnd = "wss_participation_time_end"
        case apiReadUrl = "api_read_url"
        case apiReadKey = "api_read_key"
        case apiWriteUrl = "api_write_url"
        case apiWriteKey = "api_write_key"
        case pssReminderEnabled = "pss_reminder_enabled"
        case pssReminderTime = "pss_reminder_time"
        case pssReminderDays = "pss_reminder_days"
        case siIosVersion = "si_ios_version"
        case siWatchosVersion = "si_watchos_version"
        case siIphoneModel = "si_iphone_model"
        case siWatchModel = "si_watch_model"
        case siIphoneDeviceID = "si_iphone_device_id"
        case siWatchDeviceID = "si_watch_device_id"
        case siIphoneBatteryChargeState = "si_iphone_battery_charge_state"
        case siWatchBatteryChargeState = "si_watch_battery_charge_state"
        case siIphoneWifiSignalStrength = "si_iphone_wifi_signal_strength"
        case siWatchWifiSignalStrength = "si_watch_wifi_signal_strength"
        case siIphoneCellularSignalStrength = "si_iphone_cellular_signal_strength"
        case siWatchCellularSignalStrength = "si_watch_cellular_signal_strength"
        case siIphoneLocationServiceEnabled = "si_iphone_location_service_enabled"
        case siWatchLocationServiceEnabled = "si_watch_location_service_enabled"
        case siIphoneLowBatteryModeEnabled = "si_iphone_low_battery_mode_enabled"
        case siWatchConnectedToPhone = "si_watch_connected_to_phone"
        case appBundleName = "app_bundle_name"
        case appBundleBuildVersion = "app_bundle_build_version"
        case appBundleBuildNumber = "app_bundle_build_number"
        case appOneSignalAppID = "app_one_signal_app_id"
        case apiPhoneSurveyURL = "api_phone_survey_url"
        case apiWatchSurveyURL = "api_watch_survey_url"
        case transmitTrigger = "transmit_trigger"
    }

    init(wssGoal: Int, wssTitle: String, wssTimeOut: Int, wssReminderEnabeled: Bool, wssReminderInterval: Int, wssParticipationDays: String, wssParticipationTimeStart: String, wssParticipationTimeEnd: String, apiReadUrl: String, apiReadKey: String, apiWriteUrl: String, apiWriteKey: String, pssReminderEnabled: Bool, pssReminderTime: String, pssReminderDays: String, siIosVersion: String, siWatchosVersion: String, siIphoneModel: String, siWatchModel: String, siIphoneDeviceID: String, siWatchDeviceID: String, siIphoneBatteryChargeState: Int, siWatchBatteryChargeState: Int, siIphoneWifiSignalStrength: String, siWatchWifiSignalStrength: String, siIphoneCellularSignalStrength: String, siWatchCellularSignalStrength: String, siIphoneLocationServiceEnabled: Bool, siWatchLocationServiceEnabled: Bool, siIphoneLowBatteryModeEnabled: Bool, siWatchConnectedToPhone: Bool, appBundleName: String, appBundleBuildVersion: String, appBundleBuildNumber: String, appOneSignalAppID: String, apiPhoneSurveyURL: String, apiWatchSurveyURL: String, transmitTrigger: String) {
        self.wssGoal = wssGoal
        self.wssTitle = wssTitle
        self.wssTimeOut = wssTimeOut
        self.wssReminderEnabeled = wssReminderEnabeled
        self.wssReminderInterval = wssReminderInterval
        self.wssParticipationDays = wssParticipationDays
        self.wssParticipationTimeStart = wssParticipationTimeStart
        self.wssParticipationTimeEnd = wssParticipationTimeEnd
        self.apiReadUrl = apiReadUrl
        self.apiReadKey = apiReadKey
        self.apiWriteUrl = apiWriteUrl
        self.apiWriteKey = apiWriteKey
        self.pssReminderEnabled = pssReminderEnabled
        self.pssReminderTime = pssReminderTime
        self.pssReminderDays = pssReminderDays
        self.siIosVersion = siIosVersion
        self.siWatchosVersion = siWatchosVersion
        self.siIphoneModel = siIphoneModel
        self.siWatchModel = siWatchModel
        self.siIphoneDeviceID = siIphoneDeviceID
        self.siWatchDeviceID = siWatchDeviceID
        self.siIphoneBatteryChargeState = siIphoneBatteryChargeState
        self.siWatchBatteryChargeState = siWatchBatteryChargeState
        self.siIphoneWifiSignalStrength = siIphoneWifiSignalStrength
        self.siWatchWifiSignalStrength = siWatchWifiSignalStrength
        self.siIphoneCellularSignalStrength = siIphoneCellularSignalStrength
        self.siWatchCellularSignalStrength = siWatchCellularSignalStrength
        self.siIphoneLocationServiceEnabled = siIphoneLocationServiceEnabled
        self.siWatchLocationServiceEnabled = siWatchLocationServiceEnabled
        self.siIphoneLowBatteryModeEnabled = siIphoneLowBatteryModeEnabled
        self.siWatchConnectedToPhone = siWatchConnectedToPhone
        self.appBundleName = appBundleName
        self.appBundleBuildVersion = appBundleBuildVersion
        self.appBundleBuildNumber = appBundleBuildNumber
        self.appOneSignalAppID = appOneSignalAppID
        self.apiPhoneSurveyURL = apiPhoneSurveyURL
        self.apiWatchSurveyURL = apiWatchSurveyURL
        self.transmitTrigger = transmitTrigger
    }
}
