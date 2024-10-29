//
//  PuschNotificationLoggerStorageTest.swift
//  Cozie
//
//  Created by Alexandr Chmal on 28.10.24.
//

import Testing
@testable import Cozie

struct PuschNotificationLoggerGroupStorageTest {
    
    @Test("Retrieve Stored Payloads")
    func retrieveStoredPayload() {
        let sut = PuschNotificationLoggerGroupStorage(storage: GroupStorageSpy())
        
        let list = sut.formattedPayloads()
        
        #expect(list.count > 0)
    }
    
    @Test("Retrieve Stored Actions")
    func retrieveStoredActions() {
        let sut = PuschNotificationLoggerGroupStorage(storage: GroupStorageSpy())
        
        let list = sut.formattedActions()
        
        #expect(list.count > 0)
    }
}

fileprivate final class GroupStorageSpy: GroupStorageProtocol {
    func clearPayloads() {
        //
    }
    
    func clearActions() {
        //
    }
    
    func payloads() -> [[String: Any]] {
        return [["test": "1"]]
    }
    
    func actions() -> [String] {
        return ["No thanks!"]
    }
}
