//
//  OfflineManagerTests.swift
//  Cozie
//
//  Created by Alexandr Chmal on 29.11.24.
//

import Testing
@testable import Cozie

struct OfflineManagerTests {
    @Test
    func offlineModeEnabledIfEmptyAPI() async throws {
        let sut = OfflineModeManager()
        
        sut.updateWith(apiInfo: ("", ""))
        
        #expect(sut.isEnabled == true)
    }
    
    @Test
    func offlineModeEnabledIfEmptyAPIKey() async throws {
        let sut = OfflineModeManager()
        
        sut.updateWith(apiInfo: ("https://test", ""))
        
        #expect(sut.isEnabled == true)
    }
    
    @Test
    func offlineModeEnabledIfEmptyAPIURL() async throws {
        let sut = OfflineModeManager()
        
        sut.updateWith(apiInfo: ("", "test"))
        
        #expect(sut.isEnabled == true)
    }
    
    @Test
    func offlineModeDisabled() async throws {
        let sut = OfflineModeManager()
        
        sut.updateWith(apiInfo: ("https://test", "test"))
        
        #expect(sut.isEnabled == false)
    }
    
}

