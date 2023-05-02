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
    let loggerInteractor = LoggerInteractor()

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
