//
//  CozieStorageProtocol.swift
//  Cozie
//
//  Created by Alexandr Chmal on 04.07.23.
//

import Foundation

protocol CozieStorageProtocol {
    func playerID() -> String
    
    func healthLastSyncedTimeInterval() -> Double
    
    func healthUpdateLastSyncedTimeInterval(_ interval: Double)
    func healthUpdateLastSyncedTimeInterval(_ interval: Double, key: String)
    
    func healthLastSyncedTimeInterval(key: String) -> Double
    
    func healthUpdateTempLastSyncedTimeInterval(_ interval: Double, key: String)
    func healthUpdateFromTempLastSyncedTimeInterval(key: String)
}
