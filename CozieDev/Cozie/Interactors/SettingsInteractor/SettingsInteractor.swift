//
//  SettingsInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 05.04.23.
//

import Foundation
import CoreData

protocol SettingInteractorProtocol {
    func prepereSettingsData()
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
    
    func prepereSettingsData() {
        if let settingList = try? persistenceController.container.viewContext.fetch(SettingsData.fetchRequest()), let _ = settingList.first {
           debugPrint(settingList)
        } else {
            let settings = SettingsData(context: persistenceController.container.viewContext)
            settings.wss_title = "Weather (short)"
            settings.wss_goal = 100
            settings.wss_time_out = 60*5
            settings.wss_reminder_enabeled = false
            settings.wss_reminder_interval = 0
            settings.wss_participation_days = ""
            settings.wss_participation_time_start = "00:00"
            settings.wss_participation_time_end = "23:00"
            settings.pss_reminder_enabled = false
            settings.pss_reminder_days = ""
            settings.pss_reminder_time = ""
            
            try? persistenceController.container.viewContext.save()
        }
    }
    
    func prepereSettingsData(wssTitle: String = "Weather (short)",
                             wssGoal: Int = 100,
                             wssTimeout: Int = 60*5,
                             wssReminderEnabeled: Bool = false,
                             wssReminderInterval: Int = 0,
                             wssParticipationDays: String = "",
                             wssParticipationTimeStart: String = "00:00",
                             wssParticipationTimeEnd: String = "23:00",
                             pssReminderEnabled: Bool = false,
                             pssReminderDays: String = "",
                             pssReminderTime: String = "") {
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
