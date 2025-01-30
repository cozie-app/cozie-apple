//
//  NotificationService.swift
//  OneSignalNotificationServiceExtension
//
//  Created by Alexandr Chmal on 12.01.24.
//

import UserNotifications
import OneSignalExtension

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?
    let pushLogger = PushNotificationLoggerController(repository: UserDefaults(suiteName: GroupCommon.storageName.rawValue) ?? UserDefaults.standard)
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        
        Task {
            var tempInfo = request.content.userInfo
            tempInfo[GroupCommon.timestamp.rawValue] = Date().timeIntervalSince1970
            try? await pushLogger.pushNotificationDidReceive(payload: tempInfo as? [String: Any] ?? [:])
        }
        
        if let bestAttemptContent = bestAttemptContent {
            OneSignalExtension.didReceiveNotificationExtensionRequest(self.receivedRequest, with: bestAttemptContent, withContentHandler: self.contentHandler)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        Task {
            try? await pushLogger.pushNotificationDidSelectAction("dismiss")
        }
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignalExtension.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
}

extension UserDefaults: PushNotificationRepositoryProtocol {
    func saveNotificationInfo(info: [String: Any]) async throws {
        var storedInfo: [[String: Any]] = self.object(forKey: GroupCommon.payloads.rawValue) as? [[String: Any]] ?? []
        
        if storedInfo.count > GroupCommon.payloadsLimit {
            storedInfo.removeFirst()
        }
        
        storedInfo.append(info)
        self.set(storedInfo, forKey: GroupCommon.payloads.rawValue)
    }
    
    func saveAction(action: String) async throws {
        var storedAction: [String] = self.object(forKey: GroupCommon.actions.rawValue) as? [String] ?? []
        
        if storedAction.count > GroupCommon.actionsLimit {
            storedAction.removeFirst()
        }
        
        storedAction.append(action)
        self.set(storedAction, forKey: GroupCommon.actions.rawValue)
    }
}
