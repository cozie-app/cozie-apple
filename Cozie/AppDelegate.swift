//
//  AppDelegate.swift
//  Cozie
//
//  Created by Federico Tartarini on 25/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit
import OneSignal
import Firebase
import IQKeyboardManagerSwift
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let healthStore = HKHealthStore()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

        //START OneSignal initialization code
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: false]
        
        // Code needed for OneSignal to work properly
        OneSignal.initWithLaunchOptions(launchOptions,
          appId: "4d2b287e-603c-47db-a2b8-80b2a5d93473",
          handleNotificationAction: nil,
          settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;

        // The promptForPushNotifications function code will show the iOS push notification prompt.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
          print("User accepted notifications: \(accepted)")
        })
        //END OneSignal initialization code
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        LocalNotificationManager.shared.registerForPushNotifications()
        HealthKitSetupAssistant.authorizeHealthKit { (_, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            self.setUpBackgroundDeliveryForDataTypes()
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession:
            UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func setUpBackgroundDeliveryForDataTypes() {
        let types = ProfileDataStore.dataTypesToRead()
        for type in types {
            guard let sampleType = type as? HKSampleType else { print("ERROR: \(type) is not an HKSampleType"); continue }
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { (query, completionHandler, error) in
                debugPrint("observer query update handler called for type \(type), error: \(String(describing: error))")
                ProfileDataStore.queryForUpdates(type: type)
                completionHandler()
            }
            if ProfileDataStore.backgroundQuery == nil {
                ProfileDataStore.backgroundQuery = [query]
            } else {
                ProfileDataStore.backgroundQuery?.append(query)
            }
            if let query = ProfileDataStore.backgroundQuery?.last {
                healthStore.execute(query)
                healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { (success, error) in
                    debugPrint("enableBackgroundDeliveryForType handler called for \(type) - success: \(success), error: \(String(describing: error))")
                }
            } else {
                ProfileDataStore.queryForUpdates(type: type)
            }
        }
    }
}
