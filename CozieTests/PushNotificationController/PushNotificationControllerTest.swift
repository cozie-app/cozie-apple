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
        func parseLocalSavedCategory() throws {
            let controller = PushNotificationController(pushNotificationLogger: PushNotificationLoggerController(repository: PushNotificationRepositorySpy()), userData: UserDataSpy(), storage: CozieStorageSpy())
            
            let list = try controller.categoryList(plistName: "CategoryList", bundle: Bundle(for: PushNotificationController.self))
            
            #expect(list.count > 0)
        }
    }
    
    @Suite("PushNotification")
    struct PushNotificationControllerUTest {
        @Test("PushNotificationController send test action and logged PuchNotification",
            .tags(.parsing))
        func controllerSendTestActionAndLogPushNotification() async throws {
            let repositorySpy = PushNotificationRepositorySpy()
            let loggerController = PushNotificationLoggerController(repository: repositorySpy)
            
            let sut = PushNotificationController(pushNotificationLogger: loggerController, userData: UserDataSpy(), storage: CozieStorageSpy())
            
            _ = try #require(sut as UNUserNotificationCenterDelegate)
            await #expect(repositorySpy.savedNotificationInfo.isEmpty)
            
            try await sut.logPushNotificationAction(actionIdentifier: "Test", userInfo: ["test": 1.0])
            
            await #expect(repositorySpy.savedNotificationInfo.count == 1)
            
            try await sut.logPushNotificationAction(actionIdentifier: "Test", userInfo: ["test": 1.0])
            await #expect(repositorySpy.savedNotificationInfo.count == 2)
        }
        
        @Test("PushNotificationController send dismiss action and logged PuchNotification",
            .tags(.parsing))
        func controllerSendDismissTestActionAndLogPuchNotification() async throws {
            let repositorySpy = PushNotificationRepositorySpy()
            let loggerController = PushNotificationLoggerController(repository: repositorySpy)
            
            let sut = PushNotificationController(pushNotificationLogger: loggerController, userData: UserDataSpy(), storage: CozieStorageSpy())
            
            _ = try #require(sut as UNUserNotificationCenterDelegate)
            await #expect(repositorySpy.savedNotificationInfo.isEmpty)
            
            try await sut.logPushNotificationAction(actionIdentifier: UNNotificationDismissActionIdentifier, userInfo: ["test": 1.0])
            
            await #expect(repositorySpy.savedNotificationInfo.count == 1)
            
            try await sut.logPushNotificationAction(actionIdentifier: UNNotificationDismissActionIdentifier, userInfo: ["test": 1.0])
            await #expect(repositorySpy.savedNotificationInfo.count == 2)
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
    
    func maxHealthCutOffInterval() -> Double {
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
    var savedNotificationInfo: [[String : Any]] = []
    
    func saveNotificationInfo(info: [String : Any]) async throws {
        await withCheckedContinuation { continuation in
            savedNotificationInfo.append(info)
            continuation.resume()
        }
    }
    
    func saveAction(action: String) async throws {
    }
}

private extension Tag {
    @Tag static var parsing: Self
}
