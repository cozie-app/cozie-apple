//
//  BackendInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 11.04.23.
//

import Foundation
import CoreData
import UIKit
import OneSignal

class BackendInteractor {
    let persistenceController = PersistenceController.shared
    let baseRepo = BaseRepository()
    let storage = CozieStorage.shared
    let surveyManager = SurveyManager()
    
    var currentBackendSettings: BackendInfo? {
        guard let settingsList = try? persistenceController.container.viewContext.fetch(BackendInfo.fetchRequest()),
              let settings = settingsList.first else { return nil }
        
        return settings
    }
    
    func prepereBackendData() {
        if let settingList = try? persistenceController.container.viewContext.fetch(BackendInfo.fetchRequest()), let _ = settingList.first {
            debugPrint(settingList)
        } else {
            let backend = BackendInfo(context: persistenceController.container.viewContext)
            backend.api_read_url = "https://at6x6b7v54hmoki6dlyew72csq0ihxrn.lambda-url.ap-southeast-1.on.aws"
            backend.api_read_key = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"
            backend.api_write_url = "https://43cb5nnwe3mejojyftbuaow4640nsrnd.lambda-url.ap-southeast-1.on.aws"
            backend.api_write_key = "5LkKVBO1Zp2pbYBbnkQsb8njmf8sGB5zhMrYQmPd"
            backend.one_sigmnal_id = "be00093b-ed75-4c2e-81af-d6b382587283"
            backend.participant_password = "1G8yOhPvMZ6m"
            backend.watch_survey_link = "https://raw.githubusercontent.com/mariofrei/cozie-test/main/watch_surveys/watch_survey_weather_short.txt"
            backend.phone_survey_link = "https://docs.google.com/forms/d/e/1FAIpQLSchX6cIqgx7tupV_47o5sYVs5IvEBqhwTMGuRLCjGxqbh_gTA/viewform?usp=pp_url&entry.247006640=dev&entry.932499052=dev01"
            
            // save default link
            storage.saveWSLink(link: "https://raw.githubusercontent.com/mariofrei/cozie-test/main/watch_surveys/watch_survey_weather_short.txt")
            
            try? persistenceController.container.viewContext.save()
        }
    }
    
    func prepereBackendData(apiReadUrl: String,
                            apiReadKey: String,
                            apiWriteUrl: String,
                            apiWriteKey: String,
                            oneSigmnalId: String,
                            participantPassword: String,
                            watchSurveyLink: String,
                            phoneSurveyLink: String) {
        if let settingList = try? persistenceController.container.viewContext.fetch(BackendInfo.fetchRequest()), let model = settingList.first {
            
            model.api_read_url = apiReadUrl
            model.api_read_key = apiReadKey
            model.api_write_url = apiWriteUrl
            model.api_write_key = apiWriteKey
            model.one_sigmnal_id = oneSigmnalId
            model.participant_password = participantPassword
            model.watch_survey_link = watchSurveyLink
            model.phone_survey_link = phoneSurveyLink
            
            try? persistenceController.container.viewContext.save()
            debugPrint(settingList)
        } else {
            let backend = BackendInfo(context: persistenceController.container.viewContext)
            backend.api_read_url = apiReadUrl
            backend.api_read_key = apiReadKey
            backend.api_write_url = apiWriteUrl
            backend.api_write_key = apiWriteKey
            backend.one_sigmnal_id = oneSigmnalId
            backend.participant_password = participantPassword
            backend.watch_survey_link = watchSurveyLink
            backend.phone_survey_link = phoneSurveyLink
            
            try? persistenceController.container.viewContext.save()
        }
    }
    
    // MARK: - Load WatchSurvey JSON
    func loadExternalWatchSurveyJSON(completion: ((_ success: Bool) -> ())?) {
        if let backend = currentBackendSettings {
            baseRepo.getFileContent(url: backend.watch_survey_link ?? "", parameters: nil) { [weak self] result in
                
                guard let self = self else {
                    completion?(false)
                    return
                }
                
                switch result {
                case .success(let surveyListData):
                    self.surveyManager.update(surveyListData: surveyListData, persistenceController: self.persistenceController, selected: false, completion: completion)
                case .failure(let error):
                    completion?(false)
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Setup/Updaete OneSign
    func updateOneSign(launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil,
                       surveyInteractor: WatchSurveyInteractor = WatchSurveyInteractor()) {
        
        let healthKitInteractor: HealthKitInteractor = HealthKitInteractor(storage: storage, userData: UserInteractor(), backendData: self, loger: LoggerInteractor.shared)
        
        if let _ = currentBackendSettings {
            // Remove this method to stop OneSignal Debugging
            OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
            
            let notificationOpenedBlock: OSNotificationOpenedBlock = { result in
                // This block gets called when the user reacts to a notification received
                if let actionID = result.action.actionId {
                    surveyInteractor.sendResponce(action: actionID) { success in
                        if success {
                            debugPrint("iOS notification action sent")
                        }
                    }
                }
            }
            
            OneSignal.setNotificationWillShowInForegroundHandler { /*[weak self]*/ notification, completion in
                // send health data
                healthKitInteractor.sendData(trigger: CommunicationKeys.pushNotificationForegroundTrigger.rawValue, timeout: HealthKitInteractor.minInterval) { succces in
                    completion(notification)
                }
                //self?.testLog(trigger: CommunicationKeys.pushNotificationForegroundTrigger.rawValue, details: "(OneSignal) Notification Will Show In Foreground Handler!")
            }
            
            OneSignal.setNotificationOpenedHandler(notificationOpenedBlock)
            
            // OneSignal initialization
            OneSignal.initWithLaunchOptions(launchOptions)
            OneSignal.setAppId(CommunicationKeys.oneSignalAppID.rawValue)
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                debugPrint("User accepted notifications: \(accepted)")
            })
            
            if let delegate = AppDelegate.instance {
                OneSignal.add(delegate as OSSubscriptionObserver)
            }
        }
    }
    
    // log test
//    private func testLog(trigger: String, details: String, state: String = "error") {
//        
//        let str =
//        """
//        {
//        "trigger": "\(trigger)",
//        "si_onesignal_state": "\(state)",
//        "si_onesignal_details": "\(details)",
//        }
//        """
//        LoggerInteractor.shared.logInfo(action: "", info: str)
//    }
}
 
extension AppDelegate: OSSubscriptionObserver {
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges) {
        if let playerId = stateChanges.to.userId {
            CozieStorage.shared.savePlayerID(playerId)
            debugPrint("Player id: \(playerId)")
        }
    }
}

extension BackendInteractor: BackendDataProtocol {
    var apiWriteInfo: WApiInfo? {
        guard let settings = self.currentBackendSettings else {
            return nil
        }
        return (settings.api_write_url ?? "", settings.api_write_key ?? "")
    }
}
