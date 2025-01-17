//
//  PushNotificationController.swift
//  Cozie
//
//  Created by Alexandr Chmal on 22.10.24.
//

import Testing
import Foundation
@testable import Cozie
import UserNotifications

final class PushNotificationControllerTests {
    
    init() async throws {}
    deinit {}
    
    @Suite("Parsing")
    struct PushNotificationControllerParsing {
        @Test("Parsing Local Category", .tags(.parsing))
        func parseLocalSevedCategory() throws {
            let contr = PushNotificationController(pushNotificationLogger: PushNotificationLoggerController(repository: PushNotificationRepositorySpy()), userData: UserDataSpy(), storage: CozieStorageSpy())
            
            let list = try contr.categoryList(plistName: "CategoryList", bundel: Bundle(for: PushNotificationController.self))
            
            #expect(list.count > 0)
        }
    }
    
    @Suite("PushNotification")
    struct PushNotificationControllerUTest {
        @Test("PushNotificationController send test action and logged PuchNotification",
            .tags(.parsing))
        func controllerSendTestActionAndLogPuchNotification() async throws {
            let repositorySpy = PushNotificationRepositorySpy()
            let loggerController = PushNotificationLoggerController(repository: repositorySpy)
            
            let sut = PushNotificationController(pushNotificationLogger: loggerController, userData: UserDataSpy(), storage: CozieStorageSpy())
            
            _ = try #require(sut as UNUserNotificationCenterDelegate)
            await #expect(repositorySpy.savedeNotifInfo.isEmpty)
            
            try await sut.logPuchNotificationAction(actionIdentifier: "Test", userInfo: ["test": 1.0])
            
            await #expect(repositorySpy.savedeNotifInfo.count == 1)
            
            try await sut.logPuchNotificationAction(actionIdentifier: "Test", userInfo: ["test": 1.0])
            await #expect(repositorySpy.savedeNotifInfo.count == 2)
        }
        
        @Test("PushNotificationController send dismiss action and logged PuchNotification",
            .tags(.parsing))
        func controllerSendDismissTestActionAndLogPuchNotification() async throws {
            let repositorySpy = PushNotificationRepositorySpy()
            let loggerController = PushNotificationLoggerController(repository: repositorySpy)
            
            let sut = PushNotificationController(pushNotificationLogger: loggerController, userData: UserDataSpy(), storage: CozieStorageSpy())
            
            _ = try #require(sut as UNUserNotificationCenterDelegate)
            await #expect(repositorySpy.savedeNotifInfo.isEmpty)
            
            try await sut.logPuchNotificationAction(actionIdentifier: UNNotificationDismissActionIdentifier, userInfo: ["test": 1.0])
            
            await #expect(repositorySpy.savedeNotifInfo.count == 1)
            
            try await sut.logPuchNotificationAction(actionIdentifier: UNNotificationDismissActionIdentifier, userInfo: ["test": 1.0])
            await #expect(repositorySpy.savedeNotifInfo.count == 2)
        }
    }
}

fileprivate struct UserDataSpy: UserDataProtocol {
    var userInfo: Cozie.CUserInfo?
}

fileprivate struct CozieStorageSpy: CozieStorageProtocol {
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

actor PushNotificationRepositorySpy : PushNotificationRepositoryProtocol {
    var savedeNotifInfo: [[String : Any]] = []
    
    func saveNotifInfo(info: [String : Any]) async throws {
        await withCheckedContinuation { continuation in
            savedeNotifInfo.append(info)
            continuation.resume()
        }
    }
    
    func saveAction(action: String) async throws {
    }
}

private extension Tag {
    @Tag static var parsing: Self
}
