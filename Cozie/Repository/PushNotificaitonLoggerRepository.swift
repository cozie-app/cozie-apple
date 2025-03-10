//
//  PushNotificaitonLoggerRepository.swift
//  Cozie
//
//  Created by Alexandr Chmal on 28.10.24.
//

import Foundation

final class PushNotificaitonLoggerRepository: PushNotificationRepositoryProtocol {
    let apiRepository: ApiRepositoryProtocol
    let api: ApiDataProtocol
    let loggerInteractor: LoggerInteractor = LoggerInteractor.shared
    
    init(apiRepository: ApiRepositoryProtocol, api: ApiDataProtocol) {
        self.apiRepository = apiRepository
        self.api = api
    }
    
    func saveNotifInfo(info: [String : Any]) async throws {
        let json = try JSONSerialization.data(withJSONObject: info, options: .prettyPrinted)
        
        try await withCheckedThrowingContinuation { continuation in
            apiRepository.post(url: api.url, body: json, key: api.key) { [weak self] result in
                switch result {
                case .success(_):
                    // log data
                    if let jsonToLog = try? JSONSerialization.data(withJSONObject: info, options: .withoutEscapingSlashes) {
                        debugPrint(jsonToLog)
                        self?.loggerInteractor.logInfo(action: "", info: String(data: jsonToLog, encoding: .utf8) ?? "")
                    }
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func saveAction(action: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            apiRepository.post(url: api.url, body: Data(), key: api.key) { result in
                switch result {
                case .success(_):
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
