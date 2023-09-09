//
//  CozieApp.swift
//  Cozie
//
//  Created by Denis on 10.02.2023.
//

import SwiftUI
import UIKit

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
        if CozieStorage.shared.healthLastSyncedTimeInterval() == 0.0 {
            
            let interval = Date().timeIntervalSince1970
            CozieStorage.shared.healthUpdateLastSyncedTimeInterval(interval)
            CozieStorage.shared.updatefirstLaunchTimeInterval(interval)
            
            healthKitInteractor.requestHealthAuth()
        }
        
        // Register Background Processing for delivery HealthKit info
        
        backgroundProcessing.registerBackgroundRefresh()
        backgroundProcessing.registerBackgroundProcessing {
            self.healthKitInteractor.sendData { success in
                debugPrint(success ? "Health data sended" : "Health data failed")
            }
        }
        
        locationManager.requestAuth()
        
        // init conection with watch
        _ = WatchConnectivityManagerPhone.shared
        return true
    }
    
    func startBGTasks() {
        // backgroundProcessing.test()
        backgroundProcessing.scheduleBgProcessing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.backgroundProcessing.scheduleBgTaskRefresh()
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
    
    var body: some Scene {
        WindowGroup {
            HomeCoordinatorView(coordinator: coordinator)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        // Delivery HealthKit info on application launch
                        appDelegate.healthKitInteractor.sendData(trigger: CommunicationKeys.appTrigger.rawValue, timeout: HealthKitInteractor.minInterval) { success in
                            debugPrint(success ? "Health data sended" : "Health data failed")
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
