//
//  SettingsInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 05.04.23.
//

import Foundation
import CoreData

class SettingsInteractor: SettingsInteractorProtocol {
    let dbStorage: DataBaseStorageProtocol
    
    let backendInteractor: BackendInteractorProtocol
    let loggerInteractor: LoggerProtocol

    let apiRepository: ApiRepositoryProtocol
    
    init(dbStorage: DataBaseStorageProtocol = PersistenceController.shared,
         backendInteractor: BackendInteractorProtocol = BackendInteractor(),
         loggerInteractor: LoggerProtocol = LoggerInteractor.shared,
         apiRepository: ApiRepositoryProtocol = BaseRepository()) {
        self.dbStorage = dbStorage
        self.backendInteractor = backendInteractor
        self.loggerInteractor = loggerInteractor
        self.apiRepository = apiRepository
    }
    
    var currentSettings: SettingsData? {
        guard let settings = try? dbStorage.settings() else { return nil }
        return settings
    }
    
    // TODO: - Unit Tests & move to db storage
    private func createDefaultSetting() {
        let settings = dbStorage.createSettingsData()
        settings.wss_title = Defaults.WSStitle
        settings.wss_goal = Defaults.WSSgoal
        settings.wss_time_out = Defaults.WSStimeOutTime
        settings.wss_reminder_enabled = Defaults.WSSreminderEnabled
        settings.wss_reminder_interval = Defaults.WSSreminderInterval
        settings.wss_participation_days = Defaults.WSSparticipationDays
        settings.wss_participation_time_start = Defaults.WSSparticiaptionTimeStart
        settings.wss_participation_time_end = Defaults.WSSparticipationTimeEnd
        settings.pss_reminder_enabled = Defaults.PSSreminderEnabled
        settings.pss_reminder_days = Defaults.PSSreminderDays
        settings.pss_reminder_time = Defaults.PSSreminderTime
        
        try? dbStorage.saveViewContext()
    }
    
    func prepareSettingsData() {
        if let setting = try? dbStorage.settings() {
           debugPrint(setting)
        } else {
            createDefaultSetting()
        }
    }

    // TODO: - Unit Tests
    func prepareSettingsData(wssTitle: String?,
                             wssGoal: Int16?,
                             wssTimeout: Int16?,
                             wssReminderEnabled: Bool?,
                             wssReminderInterval: Int16?,
                             wssParticipationDays: String?,
                             wssParticipationTimeStart: String?,
                             wssParticipationTimeEnd: String?,
                             pssReminderEnabled: Bool?,
                             pssReminderDays: String?,
                             pssReminderTime: String?) {
        if let model = try? dbStorage.settings() {
            model.wss_title = wssTitle ?? Defaults.WSStitle
            model.wss_goal = Int16(wssGoal ?? Defaults.WSSgoal)
            model.wss_time_out = Int16(wssTimeout ?? Defaults.WSStimeOutTime)
            model.wss_reminder_enabled = wssReminderEnabled ?? Defaults.WSSreminderEnabled
            model.wss_reminder_interval = Int16(wssReminderInterval ?? Defaults.WSSreminderInterval)
            model.wss_participation_days = wssParticipationDays ?? ""
            model.wss_participation_time_start = wssParticipationTimeStart ?? Defaults.WSSparticiaptionTimeStart
            model.wss_participation_time_end = wssParticipationTimeEnd ?? Defaults.WSSparticipationTimeEnd
            model.pss_reminder_enabled = pssReminderEnabled ?? Defaults.PSSreminderEnabled
            model.pss_reminder_days = pssReminderDays ?? Defaults.PSSreminderDays
            model.pss_reminder_time = pssReminderTime ?? Defaults.PSSreminderTime
            do {
                try dbStorage.saveViewContext()
            } catch {
                debugPrint(error.localizedDescription)
            }
        } else {
            createDefaultSetting()
        }
    }
    
    // TODO: - Unit Tests
    func logSettingsData(name: String, expiriment: String, logs: Logs, completion: ((_ success: Bool)->())?) {
        if let backend = backendInteractor.currentBackendSettings {
            if (backend.api_write_url?.isEmpty ?? true) || (backend.api_write_key?.isEmpty ?? true) {
                
                // log data
                let encoder = JSONEncoder()
                encoder.outputFormatting = .withoutEscapingSlashes
                let json = try? encoder.encode(logs)
                if let json {
                    self.loggerInteractor.logInfo(action: "", info: String(data: json, encoding: .utf8) ?? "")
                }
                
                completion?(false)
            }
            do {
                let bodyJson = try JSONEncoder().encode([logs])
                
                // log data
                let encoder = JSONEncoder()
                encoder.outputFormatting = .withoutEscapingSlashes
                let json = try? encoder.encode(logs)
                if let json {
                    self.loggerInteractor.logInfo(action: "", info: String(data: json, encoding: .utf8) ?? "")
                }
                
                apiRepository.post(url: backend.api_write_url ?? "", body: bodyJson, key: backend.api_write_key ?? "") { result in
                    switch result {
                    case .success(_):
                        completion?(true)
                    case .failure(_):
                        completion?(false)
                    }
                }
            } catch let error {
                debugPrint(error)
                completion?(false)
            }
        } else {
            completion?(false)
        }
    }
}
