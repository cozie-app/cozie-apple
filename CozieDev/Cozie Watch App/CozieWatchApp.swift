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
    
    func sendResponse(_ info: String, completion: ((_ success: Bool)->())?) {
        watchSurveyInteractor.sendResponse(action: info) { success in
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
        
        notificationViewModel.sendResponse(response.actionIdentifier) { success in
            completionHandler()
        }
    }
}

@main
struct CozieWatchApp: App {
    static let notificationCategory = "cozie_notification_category"
    @Environment(\.scenePhase) var scenePhase
    
    let cozieUserNotificationCenterDelegate = CozieUserNotificationCenterDelegate()
    let healthKitInteractor = HealthKitInteractor(storage: StorageManager.shared, userData: StorageManager.shared, backendData: StorageManager.shared, loger: StorageManager.shared)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    addNotifCategory()
                    prepareHealthInteractor()
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
    
    private func prepareHealthInteractor() {
        if StorageManager.shared.healthLastSyncedTimeInterval() == 0.0 {
            
            let interval = Date().timeIntervalSince1970
            StorageManager.shared.healthUpdateLastSyncedTimeInterval(interval)
            StorageManager.shared.updatefirstLaunchTimeInterval(interval)
            
            healthKitInteractor.requestHealthAuth()
        }
    }
}
