//
//  NotificationController.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 03.05.23.
//

import WatchKit
import SwiftUI
import UserNotifications

class NotificationController: WKUserNotificationHostingController<NotificationView> {

    var message: String?
    override var body: NotificationView {
        NotificationView(message: message ?? "Empty")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func didReceive(_ notification: UNNotification) {
        let notificationData =
            notification.request.content.userInfo as? [String: Any]
        
        let aps = notificationData?["aps"] as? [String: Any]
        let alert = aps?["alert"] as? [String: Any]

        message = alert?["body"] as? String
    }
}
