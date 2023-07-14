//
//  StorageManager.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 20.04.23.
//

import Foundation

class StorageManager {
    typealias ApiInfo = (url: String, key: String)
    
    enum Keys: String {
        case jsonKey = "CozieWatchSyrveyJSON"
        case writeURL = "CozieApiWriteURL"
        case writeKey = "CozieApiWriteKey"
        case userIDKey = "CozieUserIDKey"
        case userOneSignalIDKey = "CozieOneSignalIDKey"
        case expirimentIDKey = "CozieExpirimentIDKey"
        case paswordIDKey = "CoziePaswordIDKey"
        case timeInterval = "CozieTimeIntervalKey"
        case lastSurveyTimeInterval = "CozieLastSurveyTimeIntervalKey"
        case sevedLogs = "CozieSevedLogsKey"
        case sevedSurveyCount = "CozieSevedSurveyCount"
        case notSyncedSurvey = "CozieNotSyncedSurvey"
    }
    
    let storage = UserDefaults.standard
    
    static let shared = StorageManager()
    
    // MARK: Watch Survey JSON
    func saveWatchSurveyJSON(data: Data) {
        UserDefaults.standard.set(data, forKey: Keys.jsonKey.rawValue)
    }
    
    func watchatchSurveyJSON() -> Data? {
        return UserDefaults.standard.value(forKey: Keys.jsonKey.rawValue) as? Data
    }
    
    // MARK: Write API url/key
    func saveWatchSurveyAPI(apiInfo: ApiInfo) {
        UserDefaults.standard.set(apiInfo.url, forKey: Keys.writeURL.rawValue)
        UserDefaults.standard.set(apiInfo.key, forKey: Keys.writeKey.rawValue)
    }
    
    func watchSurveyAPI() -> ApiInfo {
        return ((UserDefaults.standard.value(forKey: Keys.writeURL.rawValue) as? String) ?? "",
                (UserDefaults.standard.value(forKey: Keys.writeKey.rawValue) as? String) ?? "")
    }
    
    // MARK: User info
    func saveUserID(userID: String) {
        UserDefaults.standard.set(userID, forKey: Keys.userIDKey.rawValue)
    }
    
    func userID() -> String {
        return (UserDefaults.standard.value(forKey: Keys.userIDKey.rawValue) as? String) ?? ""
    }
    
    func saveUserOneSignalID(userID: String) {
        UserDefaults.standard.set(userID, forKey: Keys.userOneSignalIDKey.rawValue)
    }
    
    func userOneSignalID() -> String {
        return (UserDefaults.standard.value(forKey: Keys.userOneSignalIDKey.rawValue) as? String) ?? ""
    }
    
    func saveExpirimentID(expID: String) {
        UserDefaults.standard.set(expID, forKey: Keys.expirimentIDKey.rawValue)
    }
    
    func expirimentID() -> String {
        return (UserDefaults.standard.value(forKey: Keys.expirimentIDKey.rawValue) as? String) ?? ""
    }
    
    func savePaswordID(passwordID: String) {
        UserDefaults.standard.set(passwordID, forKey: Keys.paswordIDKey.rawValue)
    }
    
    func paswordID() -> String {
        return (UserDefaults.standard.value(forKey: Keys.paswordIDKey.rawValue) as? String) ?? ""
    }
    
    // MARK: Time interval betwin survey
    func saveTimeInterval(interval: Int) {
        UserDefaults.standard.set(interval, forKey: Keys.timeInterval.rawValue)
    }
    
    func timeInterval() -> Int {
        return (UserDefaults.standard.value(forKey: Keys.timeInterval.rawValue) as? Int) ?? 0
    }
    
    // MARK: Last survey send
    func saveLastSurveySend() {
        let timeInterval = Date().timeIntervalSince1970
        UserDefaults.standard.set(Int(timeInterval), forKey: Keys.lastSurveyTimeInterval.rawValue)
    }
    
    func lastSurveySendInterval() -> Int {
        return (UserDefaults.standard.value(forKey: Keys.lastSurveyTimeInterval.rawValue) as? Int) ?? 0
    }
    
    // MARK: Save survey logs
    func seveLogs(logs: String, surveyCount: Int? = nil) {
        var logsHistory = sevedLogs()
        if logsHistory.isEmpty {
            UserDefaults.standard.set(logs, forKey: Keys.sevedLogs.rawValue)
        } else {
            if let surveyCount = surveyCount, (logsHistory.range(of: "ws_survey_count\":\(surveyCount)") != nil) {
                return
            }
            logsHistory.append(",")
            logsHistory.append(logs)
            UserDefaults.standard.set(logsHistory, forKey: Keys.sevedLogs.rawValue)
        }
    }
    
    // MARK: Logs
    func sevedLogs() -> String {
        return (UserDefaults.standard.value(forKey: Keys.sevedLogs.rawValue) as? String) ?? ""
    }
    
    func clearLogs() {
        UserDefaults.standard.set("", forKey: Keys.sevedLogs.rawValue)
    }
    
    // MARK: Not Synced Survey
    func seveNotSyncedSurvey(history: SurveyHistory) {
        do {
            var notSyncedList = allNotSyncedSurveyList()
            notSyncedList.append(history)
            
            let surveyData = try JSONEncoder().encode(notSyncedList)
            UserDefaults.standard.set(surveyData, forKey: Keys.notSyncedSurvey.rawValue)
            
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func updateNotSyncedSurvey(list: [SurveyHistory]) {
        if list.isEmpty {
            UserDefaults.standard.set(nil, forKey: Keys.notSyncedSurvey.rawValue)
        } else {
            do {
                let surveyData = try JSONEncoder().encode(list)
                UserDefaults.standard.set(surveyData, forKey: Keys.notSyncedSurvey.rawValue)
                
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func allNotSyncedSurveyList() -> [SurveyHistory] {
        if let notSyncedListData = UserDefaults.standard.value(forKey: Keys.notSyncedSurvey.rawValue) as? Data {
            return (try? JSONDecoder().decode([SurveyHistory].self, from: notSyncedListData)) ?? []
        }
        return []
    }
    
    // MARK: Survey Count
    func surveyCount() -> Int {
        return (UserDefaults.standard.value(forKey: Keys.sevedSurveyCount.rawValue) as? Int) ?? 1
    }
    
    func updateSurveyCount() {
        var count = surveyCount()
        count += 1
        UserDefaults.standard.set(count, forKey: Keys.sevedSurveyCount.rawValue)
    }
    
    func resetSurveyCount() {
        UserDefaults.standard.set(0, forKey: Keys.sevedSurveyCount.rawValue)
    }
    
    func dataSynced() -> Bool {
        let api = watchSurveyAPI()
        if watchatchSurveyJSON() != nil,
            !api.key.isEmpty,
            !api.url.isEmpty,
            !expirimentID().isEmpty,
            !userID().isEmpty,
            !paswordID().isEmpty {
            return true
        } else {
            return false
        }
    }
}
