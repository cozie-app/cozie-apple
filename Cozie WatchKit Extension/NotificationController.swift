//
//  NotificationController.swift
//  Cozie WatchKit Extension
//
//  Created by Federico Tartarini on 25/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications
import UIKit

class NotificationController: WKUserNotificationInterfaceController {
    
    enum NotificationOSKey: String{
        case aps, alert, title, subtitle, body, buttons, actionId = "i", actionTitle = "n"
    }
    
    /// List of available actions id
    private var actionListID:[String] = []
    
    @IBOutlet weak var notificationTitle: WKInterfaceLabel!
    @IBOutlet weak var notificationSubtitle: WKInterfaceLabel!
    @IBOutlet weak var notificationBody: WKInterfaceLabel!
    
    override init() {
        // Initialize variables here.
        super.init()

        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Custom notification UI
    override func didReceive(_ notification: UNNotification) {

        // set alert details
        if let info = notification.request.content.userInfo as? [String: Any],
           let aps = info[NotificationOSKey.aps.rawValue] as? [String: Any],
           let alert = aps[NotificationOSKey.alert.rawValue] as? [String: Any] {
            if let title = alert[NotificationOSKey.title.rawValue] as? String {
                notificationTitle.setText(title)
            } else {
                notificationTitle.setText(nil)
            }
            
            if let subtitle = alert[NotificationOSKey.subtitle.rawValue] as? String {
                notificationSubtitle.setText(subtitle)
            } else {
                notificationSubtitle.setText(nil)
            }
            
            if let body = alert[NotificationOSKey.body.rawValue] as? String {
                notificationBody.setText(body)
            } else {
                notificationBody.setText(nil)
            }
           
        }
        
        // create actions
        if let info = notification.request.content.userInfo as? [String: Any],
           let buttons = info[NotificationOSKey.buttons.rawValue] as? [[String: String]] {

            var actions: [UNNotificationAction] = []
            // clear action list
            actionListID.removeAll()
            
            for button in buttons {
                if let actionId = button[NotificationOSKey.actionId.rawValue],
                    let actionTitle = button[NotificationOSKey.actionTitle.rawValue] {
                    actions.append(UNNotificationAction(identifier: actionId, title: actionTitle, options: .foreground))
                    actionListID.append(actionId)
                } else {
                    continue
                }
            }
            
            notificationActions = actions
            UNUserNotificationCenter.current().delegate = self
        }
    }
}
 
extension NotificationController: UNUserNotificationCenterDelegate {
    
    // MARK: - Custom action for notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // set device UDID
        var uuid = UserDefaults.standard.string(forKey: "uuid") ?? "undefined"
        if (uuid == "undefined") {
            uuid = UUID().uuidString
            UserDefaults.standard.set(uuid, forKey: "uuid")
        }
        debugPrint("uuid: \(uuid)")
        if actionListID.firstIndex(where: { $0 == response.actionIdentifier }) != nil {
            // Send data to database
            do {
                let postMessage = try JSONEncoder().encode(FormatAPI(
                        timestamp_location: GetDateTimeISOString(),
                        timestamp_start: GetDateTimeISOString(),
                        timestamp_end: GetDateTimeISOString(),
                        id_participant: UserDefaults.standard.string(forKey: "participantID") ?? placeholderParticipantID,
                        id_experiment: UserDefaults.standard.string(forKey: "experimentID") ?? placeholdRrexperimentID,
                        responses: ["push_notification_action": "watch app -> " + response.actionIdentifier],
                        id_device: uuid))
                _ = PostRequest(message: postMessage)
            } catch let error {
                debugPrint("error (push notification): \(error.localizedDescription)")
            }
        }
        
        completionHandler()
    }
}
