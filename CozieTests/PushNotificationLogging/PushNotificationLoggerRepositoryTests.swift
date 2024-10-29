//
//  PushNotificationLoggerRepositoryTests.swift
//  Cozie
//
//  Created by Alexandr Chmal on 28.10.24.
//

import Testing
@testable import Cozie
import Foundation

struct PushNotificationLoggerRepositoryTests {
    
    @Test("Send PushNotification info by API")
    func sendPuschNotificationInfoByAPI() async throws {
        let apiRepositorySpy = ApiRepositorySpy(triggerError: false)
        
        let testUrl = "test_url"
        let testKey = "test_key"
        
        let api = ApiDataStub(url: testUrl, key: testKey)
        let sut = PushNotificaitonLoggerRepository(apiRepository: apiRepositorySpy, api: api)
        #expect(apiRepositorySpy.calledPostUrl.isEmpty)
        #expect(apiRepositorySpy.calledPostKey.isEmpty)
        
        try await sut.saveNotifInfo(info: ["test": "test"])
        
        #expect(apiRepositorySpy.calledPostUrl == testUrl)
        #expect(apiRepositorySpy.calledPostKey == testKey)
    }
    
    @Test("Send PushNotification info by API")
    func sendPuschNotificationActionByAPI() async throws {
        let apiRepositorySpy = ApiRepositorySpy(triggerError: false)
        
        let testUrl = "test_url"
        let testKey = "test_key"
        
        let api = ApiDataStub(url: testUrl, key: testKey)
        let sut = PushNotificaitonLoggerRepository(apiRepository: apiRepositorySpy, api: api)
        #expect(apiRepositorySpy.calledPostUrl.isEmpty)
        #expect(apiRepositorySpy.calledPostKey.isEmpty)
        
        try await sut.saveAction(action: "No thenks!")
        
        #expect(apiRepositorySpy.calledPostUrl == testUrl)
        #expect(apiRepositorySpy.calledPostKey == testKey)
    }
}

fileprivate struct ApiDataStub: ApiDataProtocol {
    var url: String
    var key: String
}

fileprivate final class ApiRepositorySpy: ApiRepositoryProtocol {
    var triggerError: Bool
    // spy info
    var calledGetUrl: String = ""
    var infoGetParameters: [String : String] = [:]
    var calledGetKey: String = ""
    
    var calledPostUrl: String = ""
    var infoPostData: Data?
    var calledPostKey: String = ""
    
    init(triggerError: Bool) {
        self.triggerError = triggerError
    }
    
    func get(url: String, parameters: [String : String], key: String, completion: @escaping (Result<Data, any Error>) -> Void) {
        
        calledGetUrl = url
        infoGetParameters = parameters
        calledGetKey = key
        
        if !triggerError {
            completion(.success("success".data(using: .utf8) ?? Data()))
        } else {
            completion(.failure(ServiceError.responseStatusError(-1, "Some error")))
        }
    }
    
    func post(url: String, body: Data, key: String, completion: @escaping (Result<Data, any Error>) -> Void) {
        
        calledPostUrl = url
        calledPostKey = key
        infoPostData = body
        
        if !triggerError {
            completion(.success("success".data(using: .utf8) ?? Data()))
        } else {
            completion(.failure(ServiceError.responseStatusError(-1, "Some error")))
        }
    }
}
