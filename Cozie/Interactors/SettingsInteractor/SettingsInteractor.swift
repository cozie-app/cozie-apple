//
//  SettingsInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 05.04.23.
//

import Foundation
import CoreData

protocol SettingInteractorProtocol {
    func prepareSettingsData()
}

class SettingsInteractor: SettingInteractorProtocol {
    let persistenceController = PersistenceController.shared
    
    let backendInteractor = BackendInteractor()
    let loggerInteractor = LoggerInteractor.shared

    let baseRepo = BaseRepository()
    
    var currentSettings: SettingsData? {
        guard let settingsList = try? persistenceController.container.viewContext.fetch(SettingsData.fetchRequest()),
                let settings = settingsList.first else { return nil }
        
        return settings
    }
    
    func prepareSettingsData() {
        if let settingList = try? persistenceController.container.viewContext.fetch(SettingsData.fetchRequest()), let _ = settingList.first {
           debugPrint(settingList)
        } else {
            let settings = SettingsData(context: persistenceController.container.viewContext)
            settings.wss_title = Defaults.WSStitle
            settings.wss_goal = Defaults.WSSgoal
            settings.wss_time_out = Defaults.WSStimeOutTime
            settings.wss_reminder_enabeled = Defaults.WSSreminderEnabled
            settings.wss_reminder_interval = Defaults.WSSreminderInterval
            settings.wss_participation_days = Defaults.WSSparticipationDays
            settings.wss_participation_time_start = Defaults.WSSparticiaptionTimeStart
            settings.wss_participation_time_end = Defaults.WSSparticipationTimeEnd
            settings.pss_reminder_enabled = Defaults.PSSreminderEnabled
            settings.pss_reminder_days = Defaults.PSSreminderDays
            settings.pss_reminder_time = Defaults.PSSreminderTime
            
            try? persistenceController.container.viewContext.save()
        }
    }
    
    func prepareSettingsData(wssTitle: String = Defaults.WSStitle,
                             wssGoal: Int16 = Defaults.WSSgoal,
                             wssTimeout: Int16 = Defaults.WSStimeOutTime,
                             wssReminderEnabeled: Bool = Defaults.WSSreminderEnabled,
                             wssReminderInterval: Int16 = Defaults.WSSreminderInterval,
                             wssParticipationDays: String = "",
                             wssParticipationTimeStart: String = Defaults.WSSparticiaptionTimeStart,
                             wssParticipationTimeEnd: String = Defaults.WSSparticipationTimeEnd,
                             pssReminderEnabled: Bool = Defaults.PSSreminderEnabled,
                             pssReminderDays: String = Defaults.PSSreminderDays,
                             pssReminderTime: String = Defaults.PSSreminderTime) {
        if let settingList = try? persistenceController.container.viewContext.fetch(SettingsData.fetchRequest()), let model = settingList.first {
            model.wss_title = wssTitle
            model.wss_goal = Int16(wssGoal)
            model.wss_time_out = Int16(wssTimeout)
            model.wss_reminder_enabeled = wssReminderEnabeled
            model.wss_reminder_interval = Int16(wssReminderInterval)
            model.wss_participation_days = wssParticipationDays
            model.wss_participation_time_start = wssParticipationTimeStart
            model.wss_participation_time_end = wssParticipationTimeEnd
            model.pss_reminder_enabled = pssReminderEnabled
            model.pss_reminder_days = pssReminderDays
            model.pss_reminder_time = pssReminderTime
        } else {
            let settings = SettingsData(context: persistenceController.container.viewContext)
            settings.wss_title = wssTitle
            settings.wss_goal = Int16(wssGoal)
            settings.wss_time_out = Int16(wssTimeout)
            settings.wss_reminder_enabeled = wssReminderEnabeled
            settings.wss_reminder_interval = Int16(wssReminderInterval)
            settings.wss_participation_days = wssParticipationDays
            settings.wss_participation_time_start = wssParticipationTimeStart
            settings.wss_participation_time_end = wssParticipationTimeEnd
            settings.pss_reminder_enabled = pssReminderEnabled
            settings.pss_reminder_days = pssReminderDays
            settings.pss_reminder_time = pssReminderTime
            
            try? persistenceController.container.viewContext.save()
        }
    }
    
    func logSettingsData(name: String, expiriment: String, logs: Logs, completion: ((_ success: Bool)->())?) {
        if let backend = backendInteractor.currentBackendSettings {
            do {
                let bodyJson = try JSONEncoder().encode([logs])
                
                // log data
                let encoder = JSONEncoder()
                encoder.outputFormatting = .withoutEscapingSlashes
                let json = try? encoder.encode(logs)
                if let json {
                    self.loggerInteractor.logInfo(action: "", info: String(data: json, encoding: .utf8) ?? "")
                }
                
                baseRepo.post(url: backend.api_write_url ?? "", body: bodyJson, key: backend.api_write_key ?? "") { result in
                    switch result {
                    case .success(_):
                        completion?(true)
                    case .failure(_):
                        completion?(false)
                    }
                }
            } catch let error {
                debugPrint(error)
            }
        }
    }
}
