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
    
    @Test func test_parse_LocalSevedCategory() throws {
        let contr = PushCatgoryController()
        let list = try contr.categoryList(plistName: "CategoryList", bundel: Bundle(for: PushCatgoryController.self))
        
        #expect(list.count > 0)
    }
}
