//
//  CozieWatchApp.swift
//  Cozie Watch Watch App
//
//  Created by Alexandr Chmal on 17.04.23.
//

import SwiftUI
import WatchKit
import UserNotifications

class NotificationViewModel {
    
    let watchSurveyInteractor = WatchSurveyInteractor()
    
    func sendResponce(_ info: String, completion: ((_ success: Bool)->())?) {
        watchSurveyInteractor.sendResponce(action: info) { success in
            completion?(success)
        }
    }
}

class CozieUserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    let notificationViewModel = NotificationViewModel()
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier || response.actionIdentifier == UNNotificationDismissActionIdentifier {
            completionHandler()
            return
        }
        
        notificationViewModel.sendResponce(response.actionIdentifier) { success in
            completionHandler()
        }
    }
}

@main
struct CozieWatchApp: App {
    static let notificationCategory = "cozie_notification_category"
    @Environment(\.scenePhase) var scenePhase
    
    let cozieUserNotificationCenterDelegate = CozieUserNotificationCenterDelegate()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    addNotifCategory()
                }
        }
 
        WKNotificationScene(controller: NotificationController.self, category: CozieWatchApp.notificationCategory)
    }
    
    private func addNotifCategory() {
        UNUserNotificationCenter.current().delegate = cozieUserNotificationCenterDelegate
        
        UNUserNotificationCenter.current().getNotificationCategories { list in
            if list.first(where: { $0.identifier == CozieWatchApp.notificationCategory }) == nil {
                let actionHelpful = UNNotificationAction(identifier: "Helpful",
                                                  title: "Helpful",
                                                  options: [])
                
                let actionNotHelpful = UNNotificationAction(identifier: "Not helpful",
                                                  title: "Not helpful",
                                                  options: [])
                
                let category = UNNotificationCategory(identifier: CozieWatchApp.notificationCategory,
                                                      actions: [actionHelpful, actionNotHelpful],
                                                      intentIdentifiers: [],
                                                      options: [])
                UNUserNotificationCenter.current().setNotificationCategories([category])
            }
        }
    }
}
