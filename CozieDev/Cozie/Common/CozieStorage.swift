//
//  CozieStorage.swift
//  Cozie
//
//  Created by Alexandr Chmal on 26.04.23.
//

import Foundation
class CozieStorage {
    
    enum CozieStorageKeys: String {
        case selectedURL = "CozieStorageSelectedURLKey"
        case pIDSynced = "CozieStoragePIDSyncedKey"
        case expIDSynced = "CozieStorageExpIDSyncedKey"
        case surveySynced = "CozieStorageSurveySyncedKey"
    }
    
    static let shared = CozieStorage()
    
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
}
