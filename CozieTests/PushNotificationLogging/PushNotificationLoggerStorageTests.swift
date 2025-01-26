//
//  PuschNotificationLoggerStorageTest.swift
//  Cozie
//
//  Created by Alexandr Chmal on 28.10.24.
//

import Testing
@testable import Cozie

struct PushNotificationLoggerGroupStorageTest {
    
    @Test("Retrieve Stored Payloads")
    func retrieveStoredPayload() {
        let sut = PushNotificationLoggerGroupStorage(groupStorage: GroupStorageSpy(), localStorage: LocaleStorageSpy(), userData: UserDataSpy())
        
        let list = sut.formattedPayloads(categoryList: [CategoryInfo(id: "id", buttons: ["test1"])])
        
        #expect(list.count > 0)
    }
    
    @Test("Retrieve Stored Actions")
    func retrieveStoredActions() {
        let sut = PushNotificationLoggerGroupStorage(groupStorage: GroupStorageSpy(), localStorage: LocaleStorageSpy(), userData: UserDataSpy())
        
        let list = sut.formattedActions(categoryList: [], info: [:])
        
        #expect(list.count > 0)
    }
}

fileprivate final class GroupStorageSpy: GroupStorageProtocol {
    func delete(_ payloads: [String : Any]) {}
    
    func delete(_ action: String) {}
    
    func clearPayloads() {}
    
    func clearActions() {}
    
    func payloads() -> [[String: Any]] {
        return [[GroupCommon.timestamp.rawValue: 1.0,
                  "test": "1"]]
    }
    
    func actions() -> [String] {
        return ["No thanks!"]
    }
}

fileprivate struct UserDataSpy: UserDataProtocol {
    var userInfo: Cozie.CUserInfo? = Cozie.CUserInfo(("","",""))
}

fileprivate final class LocaleStorageSpy: CozieStorageProtocol {
    func playerID() -> String {
        "playerID"
    }
    
    func maxHealthCutoffInteval() -> Double {
        0.0
    }
    
    func healthLastSyncedTimeInterval(offline: Bool) -> Double {
        0.0
    }
    
    func healthUpdateLastSyncedTimeInterval(_ interval: Double, offline: Bool) {
    }
    
    func healthUpdateLastSyncedTimeInterval(_ interval: Double, key: String, offline: Bool) {
    }
    
    func healthLastSyncedTimeInterval(key: String, offline: Bool) -> Double {
        0.0
    }
    
    func healthUpdateTempLastSyncedTimeInterval(_ interval: Double, key: String, offline: Bool) {
    }
    
    func healthUpdateFromTempLastSyncedTimeInterval(key: String, offline: Bool) {
    }
}
