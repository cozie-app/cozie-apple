//
//  CozieWatchApp.swift
//  Cozie Watch Watch App
//
//  Created by Alexandr Chmal on 17.04.23.
//

import SwiftUI
import WatchKit
import UserNotifications

@main
struct CozieWatchApp: App {
    static let notificationCategory = "cozie_notification_category"
    private(set) var pushNotificationController: PushNotificationControllerProtocol = PushNotificationController(pushNotificationLogger: PushNotificationLoggerController(repository: PushNotificationLoggerRepository(apiRepository: BaseRepository(), api: StorageManager.shared)), userData: StorageManager.shared, storage: StorageManager.shared)
    
    @Environment(\.scenePhase) var scenePhase

    let healthKitInteractor = HealthKitInteractor(storage: StorageManager.shared, userData: StorageManager.shared, backendData: StorageManager.shared, logger: StorageManager.shared)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    addNotificationCategory()
                    prepareHealthInteractor()
                }
        }
 
        WKNotificationScene(controller: NotificationController.self, category: CozieWatchApp.notificationCategory)
    }
    
    private func addNotificationCategory() {
        // custom notification action: register new notification category
        pushNotificationController.registerActionNotificationCategory()
    }
    
    private func prepareHealthInteractor() {
        
        if StorageManager.shared.healthLastSyncedTimeInterval(offline: false) == 0.0 {
            
            let interval = Date().timeIntervalSince1970
            StorageManager.shared.healthUpdateLastSyncedTimeInterval(interval, offline: false)
            StorageManager.shared.healthUpdateLastSyncedTimeInterval(interval, offline: true)
            StorageManager.shared.updateFirstLaunchTimeInterval(interval)
            
            healthKitInteractor.requestHealthAuth()
        }
    }
}
