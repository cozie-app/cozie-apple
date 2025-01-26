//
//  LoggingPushTests.swift
//  Cozie
//
//  Created by Alexandr Chmal on 28.10.24.
//

import Testing
@testable import Cozie

struct PushNotificationLoggerTests {
    
    @Test("PushNotification info logging",
        .tags(.pushLog))
    func savePuschNotificationInfo() async {
        let spy = RepositorySpy()
        let sut = PushNotificationLoggerController(repository: spy)
        
        #expect(spy.info.isEmpty)
        try? await sut.pushNotificationDidReciv(payload: [:])
        
        #expect(spy.info.isEmpty)
        #expect(spy.actions.isEmpty)
        
        try? await sut.pushNotificationDidReciv(payload: ["test": 0])
        
        #expect(spy.info.count == 1)
        #expect(spy.actions.isEmpty)
    }
    
    @Test("PushNotification action logging",
        .tags(.pushLog))
    func savePuschNotificationAction() async {
        let spy = RepositorySpy()
        let sut = PushNotificationLoggerController(repository: spy)
        
        #expect(spy.actions.isEmpty)
        let stubAction = "Test"
        try? await sut.pushNotificationDidSelectAction("")
        
        #expect(spy.info.isEmpty)
        #expect(spy.actions.isEmpty)
        
        try? await sut.pushNotificationDidSelectAction(stubAction)
        
        #expect(spy.info.isEmpty)
        #expect(spy.actions.count == 1)
        #expect(spy.actions.first == stubAction)
    }
}

fileprivate final class RepositorySpy: PushNotificationRepositoryProtocol {
    var info: [String: Any] = [:]
    var actions: [String] = []
    
    func saveNotifInfo(info: [String: Any]) async throws {
        self.info = info
    }
    
    func saveAction(action: String) async throws {
        actions.append(action)
    }
}

fileprivate extension Tag {
    @Tag static var pushLog: Self
}
