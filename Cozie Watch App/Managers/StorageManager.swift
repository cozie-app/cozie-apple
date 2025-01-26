//
//  StorageManager.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 20.04.23.
//

import Foundation

class StorageManager: CozieStorageProtocol {
    typealias ApiInfo = (url: String, key: String)
    static let logFileName = "wlogs.txt"
    
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
        case sevedSurveyCount = "CozieSevedSurveyCount"
        case notSyncedSurvey = "CozieNotSyncedSurvey"
        case healthMaxCutoffTimeintervalKey = "CozieHealthMaxCutoffTimeintervalKey"
        
        // Storage postfix
        case storagePostfixTime = "_wstorage_time"
        case storagePostfixTempTime = "_wstorage_temp_time"
        
        case firstLaunchTimeInterval = "firstLaunchTimeIntervalWatch"
        
        case healthPrefixSyncedDateKey = "CozieStorageWatchHealthSyncedDateKey"
        case healthLastSyncKey = "CozieStorageWatchLastSyncTimestamp"
        
        // offline
        case storagePostfixTimeOffline = "_wstorage_offline_time"
        case storagePostfixTempTimeOffline = "_wstorage_temp_offline_time"
        case healthLastSyncOfflineKey = "CozieStorageWatchLastSyncTimestampOffline"
    }
    
    let storage = UserDefaults.standard
    
    static let shared = StorageManager()
    
    let semapfore = DispatchSemaphore(value: 1)
    let writeQueue = DispatchQueue.global(qos: .userInitiated)
    
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
    
    // MARK: Last survey send
    func saveHealthMaxCutoffTimeinterval(_ interval: Double) {
        UserDefaults.standard.set(interval, forKey: Keys.healthMaxCutoffTimeintervalKey.rawValue)
    }
    
    func healthMaxCutoffTimeinterval() -> Double {
        return (UserDefaults.standard.value(forKey: Keys.healthMaxCutoffTimeintervalKey.rawValue) as? Double) ?? 0
    }
    
    // MARK: Save survey logs
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func seveLogs(logs: String, surveyCount: Int? = nil) {
        let filename = getDocumentsDirectory().appendingPathComponent(StorageManager.logFileName)
        writeQueue.async { [weak self] in
            self?.semapfore.wait()
            do {
                var logsHistory = ""
                if FileManager.default.fileExists(atPath: filename.relativePath) {
                    logsHistory = try String(contentsOfFile: filename.relativePath)
                }
                if !logsHistory.isEmpty {
                    if let surveyCount = surveyCount, (logsHistory.range(of: "ws_survey_count\":\(surveyCount)") != nil) {
                        self?.semapfore.signal()
                        return
                    }
                    logsHistory.append(",")
                    logsHistory.append(logs)
                } else {
                    logsHistory.append(logs)
                }
                
                try logsHistory.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                self?.semapfore.signal()
                
            } catch let error {
                debugPrint(error)
                self?.semapfore.signal()
            }
        }
    }
    
    // MARK: Clear Logs
    func clearLogs() {
        let filename = getDocumentsDirectory().appendingPathComponent(StorageManager.logFileName)
        if FileManager.default.fileExists(atPath: filename.relativePath) {
            do {
                try FileManager.default.removeItem(atPath: filename.relativePath)
            } catch let error {
                debugPrint(error)
            }
        }
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
//            !api.key.isEmpty,
//            !api.url.isEmpty,
            !expirimentID().isEmpty,
            !userID().isEmpty,
            !paswordID().isEmpty {
            return true
        } else {
            return false
        }
    }
    
    // MARK: first lanch time interval
    func  firstLaunchTimeInterval() -> Double {
        return UserDefaults.standard.value(forKey: Keys.firstLaunchTimeInterval.rawValue) as? Double ?? 0.0
    }
    
    func updatefirstLaunchTimeInterval(_ interval: Double) {
        UserDefaults.standard.set(interval, forKey: Keys.firstLaunchTimeInterval.rawValue)
    }
    
    // MARK: HealthKit data storage
    
    func maxHealthCutoffInteval() -> Double {
        return healthMaxCutoffTimeinterval()
    }
    
    func healthLastSyncedTimeInterval(offline: Bool) -> Double {
        return UserDefaults.standard.value(forKey: offline ? Keys.healthLastSyncOfflineKey.rawValue : Keys.healthLastSyncKey.rawValue) as? Double ?? 0.0
    }
    
    func healthUpdateLastSyncedTimeInterval(_ interval: Double, offline: Bool) {
        UserDefaults.standard.set(interval, forKey: offline ? Keys.healthLastSyncOfflineKey.rawValue : Keys.healthLastSyncKey.rawValue)
    }
    
    func healthLastSyncedTimeInterval(key: String, offline: Bool) -> Double {
        let keyWithStorageID = key + (offline ? Keys.storagePostfixTimeOffline.rawValue : Keys.storagePostfixTime.rawValue)
        return UserDefaults.standard.value(forKey: keyWithStorageID) as? Double ?? firstLaunchTimeInterval()
    }
    
    func healthUpdateLastSyncedTimeInterval(_ interval: Double, key: String, offline: Bool) {
        let keyWithStorageID = key + (offline ? Keys.storagePostfixTimeOffline.rawValue : Keys.storagePostfixTime.rawValue)
        UserDefaults.standard.set(interval, forKey: keyWithStorageID)
    }
    
    func healthUpdateTempLastSyncedTimeInterval(_ interval: Double, key: String, offline: Bool) {
        let keyWithStorageID = key + (offline ? Keys.storagePostfixTempTimeOffline.rawValue : Keys.storagePostfixTempTime.rawValue)
        UserDefaults.standard.set(interval, forKey: keyWithStorageID)
    }
    
    func healthUpdateFromTempLastSyncedTimeInterval(key: String, offline: Bool) {
        let keyWithStorageID = key + (offline ? Keys.storagePostfixTimeOffline.rawValue : Keys.storagePostfixTime.rawValue)
        let tempKeyWithStorageID = key + (offline ? Keys.storagePostfixTempTimeOffline.rawValue : Keys.storagePostfixTempTime.rawValue)
        
        if let interval = UserDefaults.standard.value(forKey: tempKeyWithStorageID) as? Double, interval > 0 {
            UserDefaults.standard.set(interval, forKey: keyWithStorageID)
        }
    }
    
    func playerID() -> String {
        return self.userOneSignalID()
    }
}

extension StorageManager: LoggerProtocol {
    func logInfo(action: String, info: String) {
        seveLogs(logs: info)
    }
}

extension StorageManager: UserDataProtocol {
    var userInfo: CUserInfo? {
        return (userID(), paswordID(), expirimentID())
    }
}

extension StorageManager: BackendDataProtocol {
    var apiWriteInfo: WApiInfo? {
        return (watchSurveyAPI().url, watchSurveyAPI().key)
    }
}
