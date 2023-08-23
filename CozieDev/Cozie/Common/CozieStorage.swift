//
//  CozieStorage.swift
//  Cozie
//
//  Created by Alexandr Chmal on 26.04.23.
//

import Foundation

class CozieStorage: CozieStorageProtocol {
    
    enum CozieStorageKeys: String {
        case appConfigured = "CozieStorageAppConfiguredKey"
        case selectedURL = "CozieStorageSelectedURLKey"
        case pIDSynced = "CozieStoragePIDSyncedKey"
        case expIDSynced = "CozieStorageExpIDSyncedKey"
        case surveySynced = "CozieStorageSurveySyncedKey"
        case playerID = "CozieStoragePlayerIDKey"
        
        // Health Kit
        case healthPrefixSyncedDateKey = "CozieStorageHealthSyncedDateKey"
        case healthLastSyncKey = "CozieStorageLastSyncTimestamp"
        
        // Location
        case locationLatKey = "location_lat"
        case locationLngKey = "location_lng"
        
        // Storage postfix
        case storagePostfixTime = "_storage_time"
        case storagePostfixTempTime = "_storage_temp_time"
        
        case firstLaunchTimeInterval = "firstLaunchTimeInterval"
    }
    
    static let shared = CozieStorage()
    
    func playerID() -> String {
        UserDefaults.standard.value(forKey: CozieStorageKeys.playerID.rawValue) as? String ?? ""
    }
    
    func savePlayerID(_ id: String) {
        UserDefaults.standard.set(id, forKey: CozieStorageKeys.playerID.rawValue)
    }
    
    func selectedWSLink() -> String {
        UserDefaults.standard.value(forKey: CozieStorageKeys.selectedURL.rawValue) as? String ?? ""
    }
    
    func saveWSLink(link: String) {
        UserDefaults.standard.set(link, forKey: CozieStorageKeys.selectedURL.rawValue)
    }
    
    func pIDSynced() -> Bool {
        UserDefaults.standard.value(forKey: CozieStorageKeys.pIDSynced.rawValue) as? Bool ?? false
    }
    
    func savePIDSynced(_ synced: Bool) {
        UserDefaults.standard.set(synced, forKey: CozieStorageKeys.pIDSynced.rawValue)
    }
    
    func expIDSynced() -> Bool {
        UserDefaults.standard.value(forKey: CozieStorageKeys.expIDSynced.rawValue) as? Bool ?? false
    }
    
    func saveExpIDSynced(_ synced: Bool) {
        UserDefaults.standard.set(synced, forKey: CozieStorageKeys.expIDSynced.rawValue)
    }
    
    func surveySynced() -> Bool {
        UserDefaults.standard.value(forKey: CozieStorageKeys.surveySynced.rawValue) as? Bool ?? false
    }
    
    func saveSurveySynced(_ synced: Bool) {
        UserDefaults.standard.set(synced, forKey: CozieStorageKeys.surveySynced.rawValue)
    }
    
    // MARK: Health kit
    func healthLastSyncedTimeInterval() -> Double {
        return UserDefaults.standard.value(forKey: CozieStorageKeys.healthLastSyncKey.rawValue) as? Double ?? 0.0
    }
    
    func healthUpdateLastSyncedTimeInterval(_ interval: Double) {
        UserDefaults.standard.set(interval, forKey: CozieStorageKeys.healthLastSyncKey.rawValue)
    }
    
    // MARK: first lanch time interval
    func  firstLaunchTimeInterval() -> Double {
        return UserDefaults.standard.value(forKey: CozieStorageKeys.firstLaunchTimeInterval.rawValue) as? Double ?? 0.0
    }
    
    func updatefirstLaunchTimeInterval(_ interval: Double) {
        UserDefaults.standard.set(interval, forKey: CozieStorageKeys.firstLaunchTimeInterval.rawValue)
    }
    
    // MARK: HealthKit data storage
    func healthLastSyncedTimeInterval(key: String) -> Double {
        let keyWithStorageID = key + CozieStorageKeys.storagePostfixTime.rawValue
        return UserDefaults.standard.value(forKey: keyWithStorageID) as? Double ?? firstLaunchTimeInterval()
    }
    
    func healthUpdateLastSyncedTimeInterval(_ interval: Double, key: String) {
        let keyWithStorageID = key + CozieStorageKeys.storagePostfixTime.rawValue
        UserDefaults.standard.set(interval, forKey: keyWithStorageID)
    }
    
    func healthUpdateTempLastSyncedTimeInterval(_ interval: Double, key: String) {
        let keyWithStorageID = key + CozieStorageKeys.storagePostfixTempTime.rawValue
        UserDefaults.standard.set(interval, forKey: keyWithStorageID)
    }
    
    func healthUpdateFromTempLastSyncedTimeInterval(key: String) {
        let keyWithStorageID = key + CozieStorageKeys.storagePostfixTime.rawValue
        let tempKeyWithStorageID = key + CozieStorageKeys.storagePostfixTempTime.rawValue
        
        if let interval = UserDefaults.standard.value(forKey: tempKeyWithStorageID) as? Double, interval > 0 {
            UserDefaults.standard.set(interval, forKey: keyWithStorageID)
        }
    }
    // location
    func updateLastLocation(lat: Double, lng: Double) {
        UserDefaults.standard.set(lat, forKey: CozieStorageKeys.locationLatKey.rawValue)
        UserDefaults.standard.set(lng, forKey: CozieStorageKeys.locationLngKey.rawValue)
    }
    
    func lastLocation() ->((lat: Double, lng: Double)?)  {
        if let lat = UserDefaults.standard.value(forKey: CozieStorageKeys.locationLatKey.rawValue) as? Double, let lng = UserDefaults.standard.value(forKey: CozieStorageKeys.locationLngKey.rawValue) as? Double {
            return (lat, lng)
        }
        return nil
    }
    
    func healthSyncedTypeKey(type: String) -> String {
        if !type.isEmpty {
            return CozieStorageKeys.healthPrefixSyncedDateKey.rawValue + type
        }
        return CozieStorageKeys.healthPrefixSyncedDateKey.rawValue
    }
}
