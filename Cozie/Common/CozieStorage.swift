//
//  CozieStorage.swift
//  Cozie
//
//  Created by Alexandr Chmal on 26.04.23.
//

import Foundation

protocol WSStorageProtocol {
    typealias SurveyInfo = (link: String, title: String)
    func selectedWSLink() -> SurveyInfo
    func saveWSLink(link: SurveyInfo)
    func externalWSLink() -> SurveyInfo
    func saveExternalWSLink(link: SurveyInfo)
    func maxHealthCutoffTimeInterval() -> Double
    func saveMaxHealthCutoffTimeInterval(_ interval: Double)
    func setDistanceFilter(_ distance: Float)
    func distanceFilter() -> Float
}

protocol WSStateStoregeProtocol {
    /// Participant ID sync status with device (Watch app)
    func pIDSynced() -> Bool
    
    /// Save participant ID sync status
    func savePIDSynced(_ synced: Bool)
    
    /// Experiment ID sync status with device (Watch app)
    func expIDSynced() -> Bool
    
    /// Save experiment ID sync status
    func saveExpIDSynced(_ synced: Bool)
    
    /// Watch survey sync status with device (Watch app)
    func surveySynced() -> Bool
    
    /// Save watch survey sync status
    func saveSurveySynced(_ synced: Bool)
    
    /// Save patizipent id
    func savePlayerID(_ id: String)
}

protocol UserDefaultsStoregeProtocol: CozieStorageProtocol, WSStorageProtocol, WSStateStoregeProtocol {}

class CozieStorage: UserDefaultsStoregeProtocol {

    enum CozieStorageKeys: String {
        case appConfigured = "CozieStorageAppConfiguredKey"
        case selectedURL = "CozieStorageSelectedURLKey"
        case selectedURLTitle = "CozieStorageSelectedURLTitleKey"
        case externalURL = "CozieStorageExternalURLKey"
        case externalURLTitle = "CozieStorageExternalURLTitleKey"
        case pIDSynced = "CozieStoragePIDSyncedKey"
        case expIDSynced = "CozieStorageExpIDSyncedKey"
        case surveySynced = "CozieStorageSurveySyncedKey"
        case playerID = "CozieStoragePlayerIDKey"
        
        // Health Kit
        case healthPrefixSyncedDateKey = "CozieStorageHealthSyncedDateKey"
        case healthLastSyncKey = "CozieStorageLastSyncTimestamp"
        // offline
        case healthLastSyncOffleinKey = "CozieStorageLastSyncTimestampOffline"
        
        // Location
        case locationLatKey = "location_lat"
        case locationLngKey = "location_lng"
        
        // Storage postfix
        case storagePostfixTime = "_storage_time"
        case storagePostfixTempTime = "_storage_temp_time"
        
        // offline
        case storagePostfixTimeOffline = "_offline_storage_time"
        case storagePostfixTempTimeOffline = "_offline_storage_temp_time"
        
        case firstLaunchTimeInterval = "firstLaunchTimeInterval"
        case maxHealthCutoffTime = "healthCutoffTimeTimeInterval"
        case distanceFilterKey = "distanceFilter"
    }
    
    static let shared = CozieStorage()
    
    /// Use this function to set distance filter.
    /// - Parameters:
    ///    - distance: Minimum distance for location tracking - (Float).
    func setDistanceFilter(_ distance: Float) {
        UserDefaults.standard.set(distance, forKey: CozieStorageKeys.distanceFilterKey.rawValue)
    }
    
    /// Use this function to get distance filter.
    func distanceFilter() -> Float {
        UserDefaults.standard.value(forKey: CozieStorageKeys.distanceFilterKey.rawValue) as? Float ?? 100.0
    }
    
    
    func playerID() -> String {
        UserDefaults.standard.value(forKey: CozieStorageKeys.playerID.rawValue) as? String ?? ""
    }
    
    func savePlayerID(_ id: String) {
        UserDefaults.standard.set(id, forKey: CozieStorageKeys.playerID.rawValue)
    }
    
    func selectedWSLink() -> SurveyInfo {
        (UserDefaults.standard.value(forKey: CozieStorageKeys.selectedURL.rawValue) as? String ?? "",
         UserDefaults.standard.value(forKey: CozieStorageKeys.selectedURLTitle.rawValue) as? String ?? "")
    }

    func saveWSLink(link: SurveyInfo) {
        UserDefaults.standard.set(link.link, forKey: CozieStorageKeys.selectedURL.rawValue)
        UserDefaults.standard.set(link.title, forKey: CozieStorageKeys.selectedURLTitle.rawValue)
    }
    
    func externalWSLink() -> SurveyInfo {
        (UserDefaults.standard.value(forKey: CozieStorageKeys.externalURL.rawValue) as? String ?? "",
         UserDefaults.standard.value(forKey: CozieStorageKeys.externalURLTitle.rawValue) as? String ?? "")
    }

    func saveExternalWSLink(link: SurveyInfo) {
        UserDefaults.standard.set(link.link, forKey: CozieStorageKeys.externalURL.rawValue)
        UserDefaults.standard.set(link.title, forKey: CozieStorageKeys.externalURLTitle.rawValue)
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

    // MARK: first lanch time interval
    func  firstLaunchTimeInterval() -> Double {
        return UserDefaults.standard.value(forKey: CozieStorageKeys.firstLaunchTimeInterval.rawValue) as? Double ?? 0.0
    }
    
    func updatefirstLaunchTimeInterval(_ interval: Double) {
        UserDefaults.standard.set(interval, forKey: CozieStorageKeys.firstLaunchTimeInterval.rawValue)
    }

    // MARK: - Health Cutoff Time
    
    func maxHealthCutoffTimeInterval() -> Double {
        return UserDefaults.standard.value(forKey: CozieStorageKeys.maxHealthCutoffTime.rawValue) as? Double ?? 3.0
    }
    
    func saveMaxHealthCutoffTimeInterval(_ interval: Double) {
        UserDefaults.standard.set(interval, forKey: CozieStorageKeys.maxHealthCutoffTime.rawValue)
    }
    
    // MARK: HealthKit data storage
    
    func maxHealthCutoffInteval() -> Double {
        return maxHealthCutoffTimeInterval()
    }
    
    func healthLastSyncedTimeInterval(offline: Bool) -> Double {
        return UserDefaults.standard.value(forKey: offline ? CozieStorageKeys.healthLastSyncOffleinKey.rawValue : CozieStorageKeys.healthLastSyncKey.rawValue) as? Double ?? 0.0
    }
    
    func healthUpdateLastSyncedTimeInterval(_ interval: Double, offline: Bool) {
        UserDefaults.standard.set(interval, forKey: offline ? CozieStorageKeys.healthLastSyncOffleinKey.rawValue : CozieStorageKeys.healthLastSyncKey.rawValue)
    }
    
    func healthLastSyncedTimeInterval(key: String, offline: Bool) -> Double {
        let keyWithStorageID: String
        if offline {
            keyWithStorageID = key + CozieStorageKeys.storagePostfixTimeOffline.rawValue
        } else {
            keyWithStorageID = key + CozieStorageKeys.storagePostfixTime.rawValue
        }
        return UserDefaults.standard.value(forKey: keyWithStorageID) as? Double ?? firstLaunchTimeInterval()
    }
    
    func healthUpdateLastSyncedTimeInterval(_ interval: Double, key: String, offline: Bool) {
        let keyWithStorageID: String
        if offline {
            keyWithStorageID = key + CozieStorageKeys.storagePostfixTimeOffline.rawValue
        } else {
            keyWithStorageID = key + CozieStorageKeys.storagePostfixTime.rawValue
        }
        UserDefaults.standard.set(interval, forKey: keyWithStorageID)
    }
    
    func healthUpdateTempLastSyncedTimeInterval(_ interval: Double, key: String, offline: Bool) {
        let keyWithStorageID: String
        if offline {
            keyWithStorageID = key + CozieStorageKeys.storagePostfixTempTimeOffline.rawValue
        } else {
            keyWithStorageID = key + CozieStorageKeys.storagePostfixTempTime.rawValue
        }
        
        UserDefaults.standard.set(interval, forKey: keyWithStorageID)
    }
    
    func healthUpdateFromTempLastSyncedTimeInterval(key: String, offline: Bool) {
        let keyWithStorageID: String
        let tempKeyWithStorageID: String
        
        if offline {
            keyWithStorageID = key + CozieStorageKeys.storagePostfixTimeOffline.rawValue
            tempKeyWithStorageID = key + CozieStorageKeys.storagePostfixTempTimeOffline.rawValue
        } else {
            keyWithStorageID = key + CozieStorageKeys.storagePostfixTime.rawValue
            tempKeyWithStorageID = key + CozieStorageKeys.storagePostfixTempTime.rawValue
        }
        
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

extension CozieStorage: SurveyStorageProtocol {
    func selectedWSInfoLink() -> String {
        return selectedWSLink().link
    }
}
