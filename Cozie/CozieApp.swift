//
//  CozieApp.swift
//  Cozie
//
//  Created by Denis on 10.02.2023.
//

import SwiftUI
import UIKit
import OneSignalFramework
import Combine

// MARK: AppDelegate: - Application initialisation / BGTasks
class AppDelegate: NSObject, UIApplicationDelegate {
    
    // move to global state
    let locationManager = LocationManager()
    let backgroundProcessing = BackgroundUpdateManager()
    let healthKitInteractor = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), logger: LoggerInteractor.shared)
    
    var launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    
    static private(set) var instance: AppDelegate! = nil
    
    private(set) var pushNotificationController: PushNotificationControllerProtocol = PushNotificationController(pushNotificationLogger: PushNotificationLoggerController(repository: PushNotificationLoggerRepository(apiRepository: BaseRepository(), api: BackendInteractor())), userData: UserInteractor(), storage: CozieStorage.shared)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        AppDelegate.instance = self
        self.launchOptions = launchOptions
        
        // update sync date if not exist
        if CozieStorage.shared.healthLastSyncedTimeInterval(offline: false) == 0.0 {
            
            let interval = Date().timeIntervalSince1970
            CozieStorage.shared.healthUpdateLastSyncedTimeInterval(interval, offline: false)
            CozieStorage.shared.healthUpdateLastSyncedTimeInterval(interval, offline: true)
            CozieStorage.shared.updateFirstLaunchTimeInterval(interval)
            
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
        
        // init connection with watch
        _ = WatchConnectivityManagerPhone.shared
        
        // custom notification action: register new notification category
        pushNotificationController.registerActionNotificationCategory()
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
}

@main
struct CozieApp: App {
    
    // MARK: Stored Properties
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var coordinator = HomeCoordinator(session: Session())
    @State private var showImportError = false
    @State private var importErrorMessage = ""
    
    let persistenceController = PersistenceController.shared
    var defaults = UserDefaults(suiteName: "group.app.cozie.ios")
    
    var body: some Scene {
        WindowGroup {
            HomeCoordinatorView(
                coordinator: coordinator,
                appDelegate: appDelegate
            )
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .task {
                    await restoreExpiredPause()
                    await uploadPendingPauseLogs()
                }
                .onReceive(
                    Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                ) { _ in
                    guard scenePhase == .active else { return }

                    Task { @MainActor in
                        await restoreExpiredPause()
                    }
                }
                .onReceive(
                    Timer.publish(every: 60, on: .main, in: .common).autoconnect()
                ) { _ in
                    guard scenePhase == .active else { return }

                    Task { @MainActor in
                        await uploadPendingPauseLogs()
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    
                    if newPhase == .active {
                        Task { @MainActor in
                            await refreshPauseScheduleOnActivation()
                            await uploadPendingPauseLogs()
                        }
                        
                        debugPrint(defaults?.value(forKey: "cozie_notification_infoKey") ?? "info ist empty")
                        debugPrint(defaults?.value(forKey: "cozie_notification_info_deleted_Key") ?? "info ist empty")
                        //defaults?.set(["test" : "info ist emptyTest"], forKey: "cozie_notification_info")
                        
                        // Delivery HealthKit info on application launch
                        appDelegate.healthKitInteractor.sendData(trigger: CommunicationKeys.appTrigger.rawValue, timeout: HealthKitInteractor.minInterval) { success in
                            debugPrint(success ? "Health data sent" : "Health data failed")
                        }
                        appDelegate.pushNotificationController.enablePushLogging(true)
                    } else if newPhase == .inactive {
                        debugPrint("Inactive")
                    } else if newPhase == .background {
                        appDelegate.startBGTasks()
                    }
                }
                .onOpenURL { incomingURL in
                    Task { @MainActor in
                        await handleIncomingURL(incomingURL)
                    }
                }
                .alert("Could not import settings", isPresented: $showImportError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(importErrorMessage)
                }
        }
    }
    
    @MainActor
    private func refreshPauseScheduleOnActivation() async {
        let service = coordinator.session.pauseService

        guard service.plan != nil, !service.isBusy else {
            return
        }

        do {
            let count = try await service.refreshRemindersFromSettings()

            print(
                "Pause reminder schedule checked. Requests: \(count)"
            )
        } catch {
            print(
                "Could not refresh pause reminders: \(error.localizedDescription)"
            )
        }
    }
    
    @MainActor
    private func restoreExpiredPause() async {
        do {
            let restored = try await coordinator.session.pauseService
                .restoreExpiredPauseIfNeeded()

            if restored {
                print("Pause expired. Original reminder schedule restored.")
            }
        } catch {
            print(
                "Could not restore pause reminders: \(error.localizedDescription)"
            )
        }
    }
    
    @MainActor
    private func uploadPendingPauseLogs() async {
        do {
            let store = try coordinator.session.pauseService
                .pauseManager.eventLogStore()

            let count = try await coordinator.session.pauseLogUploader
                .uploadPending(from: store)

            if count > 0 {
                print("Pause logs accepted by server: \(count)")
            }
        } catch {
            print(
                "Pause log upload failed: \(error.localizedDescription)"
            )
        }
    }
    
    @MainActor
    private func handleIncomingURL(_ url: URL) async {
        guard url.scheme == "cozie" else {
            return
        }

        guard let components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: true
        ),
        let base64String = components.queryItems?.first?.value,
        let data = Data(
            base64Encoded: base64String,
            options: .ignoreUnknownCharacters
        ) else {
            importErrorMessage = "The configuration link is invalid."
            showImportError = true
            return
        }

        do {
            let model = try JSONDecoder().decode(
                InitModel.self,
                from: data
            )

            try await coordinator.prepareSource(
                info: model,
                storage: CozieStorage(),
                appDelegate: appDelegate
            )
        } catch {
            importErrorMessage = error.localizedDescription
            showImportError = true
        }
    }
}
