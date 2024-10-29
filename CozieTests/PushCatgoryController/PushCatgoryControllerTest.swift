//
//  PushCatgoryControllerTest.swift
//  Cozie
//
//  Created by Alexandr Chmal on 22.10.24.
//

import Testing
import Foundation
@testable import Cozie

final class PushCatgoryControllerTest {
    
    init() async throws {}
    deinit {}
    
    @Suite("Parsing")
    struct PushCatgoryControllerST {
        @Test("Parsing Local Category", .tags(.parsing))
        func parseLocalSevedCategory() throws {
            let contr = PushCatgoryController(pushNotificationLogger: PushNotificationLoggerController(repository: PuschNotificationRepositorySpy()))
            
            let list = try contr.categoryList(plistName: "CategoryList", bundel: Bundle(for: PushCatgoryController.self))
            
            #expect(list.count > 0)
        }
    }
}

fileprivate struct PuschNotificationRepositorySpy : PuschNotificationRepositoryProtocol {
    func saveNotifInfo(info: [String : Any]) async throws {
    }
    
    func saveAction(action: String) async throws {
    }
}

private extension Tag {
    @Tag static var parsing: Self
}
