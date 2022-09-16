//
//  AppDelegate.swift
//  Cozie
//
//  Created by Federico Tartarini on 25/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit
import OneSignal
import IQKeyboardManagerSwift
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let healthStore = HKHealthStore()
    let backgroundProcessing = BackgroundUpdateController(service: HealthRepository())
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        // START OneSignal initialization code
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(OneSignalAppID)
        
        // The promptForPushNotifications function code will show the iOS push notification prompt.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            debugPrint("User accepted notifications: \(accepted)")
        })
        // END OneSignal initialization code
        IQKeyboardManager.shared.enable = true
        LocalNotificationManager.shared.registerForPushNotifications()
        
        // Delivery HealthKit info on application launch
        authorizeAndDeliveryHealthKitInfo()
        
        // Register Background Processing for delivery HealthKit info
        backgroundProcessing.setStartTemeRangeIfNeeded()
        
        backgroundProcessing.registerBackgroundRefresh()
        backgroundProcessing.registerBackgroundProcessing { [weak self] in
            self?.authorizeAndDeliveryHealthKitInfo()
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
//        backgroundProcessing.test()
        backgroundProcessing.scheduleBgProcessing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.backgroundProcessing.scheduleBgTaskRefresh()
        }
    }
}

// MARK: - Health Kit Delivery

extension AppDelegate {
    
    private func authorizeAndDeliveryHealthKitInfo() {
        HealthKitSetupAssistant.authorizeHealthKit { (_, error) in
            if let error = error {
                debugPrint("error app delegate: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.deliveryHealthKitInfo()
            }
        }
    }
    
    func deliveryHealthKitInfo() {
        let types = ProfileDataStore.dataTypesToRead()
        for type in types {
            guard let sampleType = type as? HKSampleType else {
                debugPrint("ERROR: \(type) is not an HKSampleType"); continue
            }
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { (query, completionHandler, error) in
                debugPrint("observer query update handler called for type \(type), error: \(String(describing: error))")
                DispatchQueue.global(qos: .background).async {
                    ProfileDataStore.queryForUpdates(type: type)
                }
                completionHandler()
            }
            if ProfileDataStore.backgroundQuery == nil || ProfileDataStore.backgroundQuery?.count == 0 {
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
