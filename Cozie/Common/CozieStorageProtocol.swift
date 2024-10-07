//
//  CozieStorageProtocol.swift
//  Cozie
//
//  Created by Alexandr Chmal on 04.07.23.
//

import Foundation

protocol CozieStorageProtocol {
    func playerID() -> String
    
    func maxHealthCutoffInteval() -> Double
    func healthLastSyncedTimeInterval(offline: Bool) -> Double
    
    func healthUpdateLastSyncedTimeInterval(_ interval: Double, offline: Bool)
    func healthUpdateLastSyncedTimeInterval(_ interval: Double, key: String, offline: Bool)
    
    func healthLastSyncedTimeInterval(key: String, offline: Bool) -> Double
    
    func healthUpdateTempLastSyncedTimeInterval(_ interval: Double, key: String, offline: Bool)
    func healthUpdateFromTempLastSyncedTimeInterval(key: String, offline: Bool)
}
