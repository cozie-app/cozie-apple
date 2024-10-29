//
//  PuschNotificationLoggerGroupStorage.swift
//  Cozie
//
//  Created by Alexandr Chmal on 28.10.24.
//

protocol GroupStorageProtocol {
    func payloads() -> [[String: Any]]
    func clearPayloads()
    
    func actions() -> [String]
    func clearActions()
}

struct PuschNotificationLoggerGroupStorage {
    let storage: GroupStorageProtocol
    
    func formattedPayloads() -> [[String: Any]] {
        return storage.payloads()
    }
    
    func formattedActions() -> [String] {
        return storage.actions()
    }
}
