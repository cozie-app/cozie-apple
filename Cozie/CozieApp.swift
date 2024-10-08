//
//  CozieApp.swift
//  Cozie
//
//  Created by Denis on 10.02.2023.
//

import SwiftUI
import UIKit
import OneSignalFramework

// MARK: AppDelegate: - Application initialization / BGTasks
class AppDelegate: NSObject, UIApplicationDelegate {
    let locationManager = LocationManager()
    let backgroundProcessing = BackgroundUpdateManager()
    let healthKitInteractor = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), loger: LoggerInteractor.shared)
    var launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    
    static private(set) var instance: AppDelegate! = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        AppDelegate.instance = self
        self.launchOptions = launchOptions
        
        // update sync date if not exist
        if CozieStorage.shared.healthLastSyncedTimeInterval(offline: false) == 0.0 {
            
            let interval = Date().timeIntervalSince1970
            CozieStorage.shared.healthUpdateLastSyncedTimeInterval(interval, offline: false)
            CozieStorage.shared.healthUpdateLastSyncedTimeInterval(interval, offline: true)
            CozieStorage.shared.updatefirstLaunchTimeInterval(interval)
            
            healthKitInteractor.requestHealthAuth()
        }
        
        // Register Background Processing for delivery HealthKit info
        
        backgroundProcessing.registerBackgroundRefresh()
        backgroundProcessing.registerBackgroundProcessing {
            self.healthKitInteractor.sendData { success in
                debugPrint(success ? "Health data sent" : "Health data failed")
            }
        }
        
        locationManager.requestAuth()
        
        // init conection with watch
        _ = WatchConnectivityManagerPhone.shared
        
        // custom notification action: register new notification category
        regiterActionNotifCategory()
        return true
    }
    
    // MARK: BGTask - Start
    
    func startBGTasks() {
        // backgroundProcessing.test()
        backgroundProcessing.scheduleBgProcessing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.backgroundProcessing.scheduleBgTaskRefresh()
        }
    }
    
    // MARK: Notification Helper - Regiter Notification Category
    private func regiterActionNotifCategory() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().setNotificationCategories([])
        
        UNUserNotificationCenter.current().getNotificationCategories { list in
            var categorys: Set<UNNotificationCategory> = []
            // cozie_notification_action_category_1
            if list.first(where: { $0.identifier == NotificationKeys.actionBaceNotificationCategory1.rawValue }) == nil {
                let listActionTitlesCategory = ["Helpful", "Not helpful"]
                categorys.insert(self.registerCategory(NotificationKeys.actionBaceNotificationCategory1.rawValue, actionList: listActionTitlesCategory))
            }
            // cozie_notification_action_category_2
            if list.first(where: { $0.identifier == NotificationKeys.actionBaceNotificationCategory2.rawValue }) == nil {
                let listActionTitlesCategory = ["I will do it", "I'll do my best", "Not relevant"]
                categorys.insert(self.registerCategory(NotificationKeys.actionBaceNotificationCategory2.rawValue, actionList: listActionTitlesCategory))
            }
            // cozie_notification_action_category_3
            if list.first(where: { $0.identifier == NotificationKeys.actionBaceNotificationCategory3.rawValue }) == nil {
                let listActionTitlesCategory = ["I may do it", "No thanks", "Not relevant"]
                categorys.insert(self.registerCategory(NotificationKeys.actionBaceNotificationCategory3.rawValue, actionList: listActionTitlesCategory))
            }
            
            UNUserNotificationCenter.current().setNotificationCategories(categorys)
        }
    }
    
    private func actionFromList(_ list: [String]) -> [UNNotificationAction] {
        var actions: [UNNotificationAction] = []
        for actionTitle in list {
            actions.append(UNNotificationAction(identifier: actionTitle,
                                                title: actionTitle,
                                                options: []))
        }
        return actions
    }
    
    private func registerCategory(_ id: String, actionList: [String]) -> UNNotificationCategory {
        return UNNotificationCategory(identifier: id,
                                              actions: actionFromList(actionList),
                                              intentIdentifiers: [],
                                              options: .customDismissAction)
    }
                                    
}

// MARK: NotificationDelegate: - Silent notification actions
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let surveyInteractor = WatchSurveyInteractor()
        if response.actionIdentifier != UNNotificationDefaultActionIdentifier {
            surveyInteractor.sendResponse(action: response.actionIdentifier) { success in
                if success {
                    debugPrint("iOS notification action sent")
                }
            }
        }
    }
}


@main
struct CozieApp: App {
    
    // MARK: Stored Properties
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var coordinator = HomeCoordinator(session: Session())
    let persistenceController = PersistenceController.shared
    var defaults = UserDefaults(suiteName: "group.app.cozie.ios")
    
    var body: some Scene {
        WindowGroup {
            HomeCoordinatorView(coordinator: coordinator)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onChange(of: scenePhase) { newPhase in
                    
                    if newPhase == .active {
                        
                        debugPrint(defaults?.value(forKey: "cozie_notification_infoKey") ?? "info ist empty")
                        debugPrint(defaults?.value(forKey: "cozie_notification_info_deleted_Key") ?? "info ist empty")
                        //defaults?.set(["test" : "info ist emptyTest"], forKey: "cozie_notification_info")
                        
                        // Delivery HealthKit info on application launch
                        appDelegate.healthKitInteractor.sendData(trigger: CommunicationKeys.appTrigger.rawValue, timeout: HealthKitInteractor.minInterval) { success in
                            debugPrint(success ? "Health data sent" : "Health data failed")
                        }
                    } else if newPhase == .inactive {
                        debugPrint("Inactive")
                    } else if newPhase == .background {
                        appDelegate.startBGTasks()
                    }
                }
                .onOpenURL { incomingURL in
                    handleIncomingURL(incomingURL)
                }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "cozie" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            debugPrint("Invalid URL")
            return
        }
        
        if let base64Str = components.queryItems?.first?.value,
           let base64DataEnc = Data(base64Encoded: base64Str, options: .ignoreUnknownCharacters) {
            do {
                let model = try JSONDecoder().decode(InitModel.self, from: base64DataEnc)
                coordinator.prepareSource(info: model)
            } catch let error {
                debugPrint(error)
            }
        }
    }
}
