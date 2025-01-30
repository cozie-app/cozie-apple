//
//  PushNotificationLoggerController.swift
//  Cozie
//
//  Created by Alexandr Chmal on 28.10.24.
//

import Foundation

enum LoggerErrorStatus: Int {
    case fatal = -1, server, validation
    
    var details: String {
        switch self {
        case .fatal:
            return "<.fatal>"
        default:
            return "<unknown>"
        }
    }
}

enum LoggerError: Error, LocalizedError {
    case statusError(LoggerErrorStatus, String)
    
    public var errorDescription: String? {
        switch self {
        case let .statusError(status, message):
            return "Error with status \(status.details) message: \(message)"
        }
    }
}

struct PushNotificationLoggerController {
    let repository: PushNotificationRepositoryProtocol
    
    func pushNotificationDidReceive(payload: [String: Any]) async throws {
        if payload.isEmpty {
            throw LoggerError.statusError(.fatal, "Fatal error.")
        }
        try await repository.saveNotificationInfo(info: payload)
    }
    
    func pushNotificationDidSelectAction(_ action: String) async throws {
        if action.isEmpty {
            throw LoggerError.statusError(.fatal, "Fatal error.")
        }
        try await repository.saveAction(action: action)
    }
}
