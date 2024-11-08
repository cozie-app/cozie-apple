//
//  InitModel.swift
//  Cozie
//
//  Created by Alexandr Chmal on 11.05.23.
//

import Foundation

// MARK: - InitModel
class InitModel: Codable {
    var idParticipant, idExperiment, wssTitle: String
    var wssGoal, wssTimeOut: Int16
    var wssReminderEnabled: Bool
    var wssParticipationTimeStart, wssParticipationTimeEnd, wssParticipationDays: String
    var wssReminderInterval: Int16
    var pssReminderEnabled: Bool
    var pssReminderDays, pssReminderTime: String
    var apiReadURL: String
    var apiReadKey: String
    var apiWriteURL: String
    var apiWriteKey, appOneSignalAppID, idPassword: String
    var apiWatchSurveyURL: String
    var apiPhoneSurveyURL: String
    
    enum CodingKeys: String, CodingKey {
        case idParticipant = "id_participant"
        case idExperiment = "id_experiment"
        case wssTitle = "wss_title"
        case wssGoal = "wss_goal"
        case wssTimeOut = "wss_time_out"
        case wssReminderEnabled = "wss_reminder_enabled"
        case wssParticipationTimeStart = "wss_participation_time_start"
        case wssParticipationTimeEnd = "wss_participation_time_end"
        case wssParticipationDays = "wss_participation_days"
        case wssReminderInterval = "wss_reminder_interval"
        case pssReminderEnabled = "pss_reminder_enabled"
        case pssReminderDays = "pss_reminder_days"
        case pssReminderTime = "pss_reminder_time"
        case apiReadURL = "api_read_url"
        case apiReadKey = "api_read_key"
        case apiWriteURL = "api_write_url"
        case apiWriteKey = "api_write_key"
        case appOneSignalAppID = "app_one_signal_app_id"
        case idPassword = "id_password"
        case apiWatchSurveyURL = "api_watch_survey_url"
        case apiPhoneSurveyURL = "api_phone_survey_url"
    }
    
    init(idParticipant: String, idExperiment: String, wssTitle: String, wssGoal: Int16, wssTimeOut: Int16, wssReminderEnabled: Bool, wssParticipationTimeStart: String, wssParticipationTimeEnd: String, wssParticipationDays: String, wssReminderInterval: Int16, pssReminderEnabled: Bool, pssReminderDays: String, pssReminderTime: String, apiReadURL: String, apiReadKey: String, apiWriteURL: String, apiWriteKey: String, appOneSignalAppID: String, idPassword: String, apiWatchSurveyURL: String, apiPhoneSurveyURL: String) {
        self.idParticipant = idParticipant
        self.idExperiment = idExperiment
        self.wssTitle = wssTitle
        self.wssGoal = wssGoal
        self.wssTimeOut = wssTimeOut
        self.wssReminderEnabled = wssReminderEnabled
        self.wssParticipationTimeStart = wssParticipationTimeStart
        self.wssParticipationTimeEnd = wssParticipationTimeEnd
        self.wssParticipationDays = wssParticipationDays
        self.wssReminderInterval = wssReminderInterval
        self.pssReminderEnabled = pssReminderEnabled
        self.pssReminderDays = pssReminderDays
        self.pssReminderTime = pssReminderTime
        self.apiReadURL = apiReadURL
        self.apiReadKey = apiReadKey
        self.apiWriteURL = apiWriteURL
        self.apiWriteKey = apiWriteKey
        self.appOneSignalAppID = appOneSignalAppID
        self.idPassword = idPassword
        self.apiWatchSurveyURL = apiWatchSurveyURL
        self.apiPhoneSurveyURL = apiPhoneSurveyURL
    }
}
