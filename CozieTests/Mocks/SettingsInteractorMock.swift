//
//  SettingsInteractorMock.swift
//  Cozie
//
//  Created by Alexandr Chmal.
//
@testable import Cozie

class SettingsInteractorMock: SettingsInteractorProtocol {
    var currentSettings: Cozie.SettingsData? = SettingsDataSpy()
    
    var prepareSettingsDataCallsCaunt = 0
    var prepareSettingsWithDataCallsCaunt = 0
    
    func prepareSettingsData() {
        prepareSettingsDataCallsCaunt += 1
    }
    
    func prepareSettingsData(wssTitle: String?, wssGoal: Int16?, wssTimeout: Int16?, wssReminderEnabled: Bool?, wssReminderInterval: Int16?, wssParticipationDays: String?, wssParticipationTimeStart: String?, wssParticipationTimeEnd: String?, pssReminderEnabled: Bool?, pssReminderDays: String?, pssReminderTime: String?) {
        prepareSettingsWithDataCallsCaunt += 1
        currentSettings?.wss_title = wssTitle
        currentSettings?.wss_goal = wssGoal ?? 0
        currentSettings?.wss_time_out = wssTimeout ?? 0
        currentSettings?.wss_reminder_enabled = wssReminderEnabled ?? false
        currentSettings?.wss_reminder_interval = wssReminderInterval ?? 0
        currentSettings?.wss_participation_days = wssParticipationDays
        currentSettings?.wss_participation_time_start = wssParticipationTimeStart
        currentSettings?.wss_participation_time_end = wssParticipationTimeEnd
        currentSettings?.pss_reminder_enabled = pssReminderEnabled ?? false
        currentSettings?.pss_reminder_days = pssReminderDays
        currentSettings?.pss_reminder_time = pssReminderTime
    }
}

class SettingsInteractorSpy: SettingsInteractor {
    override var currentSettings: SettingsData? {
        return SettingsDataSpy()
    }
}

class SettingsDataSpy: SettingsData {
    var wss_title_spy: String?
    var wss_time_out_spy: Int16 = 0
    var wss_reminder_interval_spy: Int16 = 0
    var wss_reminder_enabled_spy: Bool = false
    var ps_url_spy: String?
    var pss_reminder_days_spy: String?
    var pss_reminder_enabled_spy: Bool = false
    var pss_reminder_time_spy: String?
    var wss_goal_spy: Int16 = 0
    var wss_participation_days_spy: String?
    var wss_participation_time_end_spy: String?
    var wss_participation_time_start_spy: String?
    
    convenience init(wss_title: String  = "Test") {
        self.init()
    }
    
    override var wss_title: String? {
        get {
            wss_title_spy
        }
        set {
            wss_title_spy = newValue
        }
    }
    
    override var wss_time_out: Int16 {
        get {
            wss_time_out_spy
        }
        set {
            wss_time_out_spy = newValue
        }
    }
    
    override var wss_reminder_interval: Int16 {
        get {
            wss_reminder_interval_spy
        }
        set {
            wss_reminder_interval_spy = newValue
        }
    }
    
    override var wss_reminder_enabled: Bool {
        get {
            wss_reminder_enabled_spy
        }
        set {
            wss_reminder_enabled_spy = newValue
        }
    }
    
    override var ps_url: String? {
        get {
            ps_url_spy
        }
        set {
            ps_url_spy = newValue
        }
    }
    
    override var pss_reminder_days: String? {
        get {
            pss_reminder_days_spy
        }
        set {
            pss_reminder_days_spy = newValue
        }
    }
    
    override var pss_reminder_enabled: Bool {
        get {
            pss_reminder_enabled_spy
        }
        set {
            pss_reminder_enabled_spy = newValue
        }
    }
    
    override var pss_reminder_time: String? {
        get {
            pss_reminder_time_spy
        }
        set {
            pss_reminder_time_spy = newValue
        }
    }
    
    override var wss_goal: Int16 {
        get {
            wss_goal_spy
        }
        set {
            wss_goal_spy = newValue
        }
    }
    
    override var wss_participation_days: String? {
        get {
            wss_participation_days_spy
        }
        set {
            wss_participation_days_spy = newValue
        }
    }
    
    override var wss_participation_time_end: String? {
        get {
            wss_participation_time_end_spy
        }
        set {
            wss_participation_time_end_spy = newValue
        }
    }
    
    override var wss_participation_time_start: String? {
        get {
            wss_participation_time_start_spy
        }
        set {
            wss_participation_time_start_spy = newValue
        }
    }
}
