//
//  PushNotificationLoggerController.swift
//  Cozie
//
//  Created by Alexandr Chmal on 28.10.24.
//

import Foundation

protocol PuschNotificationRepositoryProtocol {
    func saveNotifInfo(info: [String: Any]) async throws
    func saveAction(action: String) async throws
}

protocol ApiDataProtocol {
    var url: String { get }
    var key: String { get }
}

enum LoggerError: Error, LocalizedError {
    case statusError(Int, String)
    
    public var errorDescription: String? {
        switch self {
        case let .statusError(status, message):
            return "Error with status \(status) message: \(message)"
        }
    }
}

struct PushNotificationLoggerController {
    let repository: PuschNotificationRepositoryProtocol
    
    func pushNotificationDidReciv(payload: [String: Any]) async throws {
        if payload.isEmpty {
            throw LoggerError.statusError(-1, "Fatal error.")
        }
        try await repository.saveNotifInfo(info: payload)
    }
    
    func pushNotificationDidSelectAction(_ action: String) async throws {
        if action.isEmpty {
            throw LoggerError.statusError(-1, "Fatal error.")
        }
        try await repository.saveAction(action: action)
    }
}
