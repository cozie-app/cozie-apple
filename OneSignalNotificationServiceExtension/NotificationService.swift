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
    let pushLogger = PushNotificationLoggerController(repository: UserDefaults(suiteName: GroupCommonKeys.storageName.rawValue) ?? UserDefaults.standard)
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
//        defaults?.set(request.content.userInfo, forKey: "cozie_notification_infoKey")
//        defaults?.synchronize()
        
        Task {
            try? await pushLogger.pushNotificationDidReciv(payload: request.content.userInfo as? [String: Any] ?? [:])
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

extension UserDefaults: PuschNotificationRepositoryProtocol {
    func saveNotifInfo(info: [String: Any]) async throws {
        var storredInfo: [[String: Any]] = self.object(forKey: GroupCommonKeys.payloads.rawValue) as? [[String: Any]] ?? []
        storredInfo.append(info)
        self.set(storredInfo, forKey: GroupCommonKeys.payloads.rawValue)
    }
    
    func saveAction(action: String) async throws {
        var storredAction: [String] = self.object(forKey: GroupCommonKeys.actions.rawValue) as? [String] ?? []
        storredAction.append(action)
        self.set(storredAction, forKey: GroupCommonKeys.actions.rawValue)
    }
}
