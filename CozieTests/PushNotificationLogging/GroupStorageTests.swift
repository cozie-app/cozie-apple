//
//  GroupStorageTests.swift
//  Cozie
//
//  Created by Alexandr Chmal on 30.10.24.
//
import Testing
@testable import Cozie
import Foundation

struct GroupStorageTests {
    
    @Suite("Payload", .serialized)
    struct PayloadTests {
        let sut = UserDefaults(suiteName: "PayloadTests") ?? UserDefaults()
        
        init() {
            setTestPayloads()
        }

        @Test("Get/Clear Payload from UserDefaults as group storage",
              .tags(.userDefaults))
        func payloadsFromGroupStorageGetAndClear() async throws {
            var payloads = sut.payloads()
            #expect(payloads.count == 2)
            
            sut.clearPayloads()
            payloads = sut.payloads()
            #expect(payloads.count == 0)
        }
        
        @Test("Delete Payload from UserDefaults as group storage",
              .tags(.userDefaults))
        func deletePayloadFromGroupStorage() async throws {
            setTestPayloads()
            var payloads = sut.payloads()
            #expect(payloads.count == 2)
            
            sut.delete(payloads.first ?? [:])
            payloads = sut.payloads()
            #expect(payloads.count == 1)
        }
        
        // MARK: - Helper
        private func setTestPayloads() {
            sut.set([[GroupCommon.timestamp.rawValue: 1], [GroupCommon.timestamp.rawValue: 2]], forKey: GroupCommon.payloads.rawValue)
        }
    }
    
   
    @Suite("Actions", .serialized)
    struct ActionsTests {
        let sut = UserDefaults(suiteName: "ActionsTests") ?? UserDefaults()
        
        init() {
            setTestActions()
        }

        @Test("Get/Clear Action from UserDefaults as group storage",
              .tags(.userDefaults))
        func actionsFromGroupStorageGetAndClear() async throws {
            
            var actions = sut.actions()
            #expect(actions.count == 2)
            
            sut.clearActions()
            actions = sut.actions()
            #expect(actions.count == 0)
        }
        
        @Test("Delete action from UserDefaults as group storage",
              .tags(.userDefaults))
        func deleteActionFromGroupStorage() async throws {
            setTestActions()
            var actions = sut.actions()
            #expect(actions.count == 2)
            
            sut.delete(actions.first ?? "")
            actions = sut.actions()
            #expect(actions.count == 1)
        }
        
        // MARK: - Helper
        private func setTestActions() {
            sut.set(["action1", "action2"], forKey: GroupCommon.actions.rawValue)
        }
    }
}

extension Tag {
    @Tag static var userDefaults: Self
}
