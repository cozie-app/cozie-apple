//
//  BackendInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 11.04.23.
//

import Foundation
import CoreData
import UIKit
import OneSignalFramework

protocol BackendInteractorProtocol {
    var currentBackendSettings: BackendInfo? { get }
    func prepareBackendData()
    func prepareBackendData(apiReadUrl: String?,
                            apiReadKey: String?,
                            apiWriteUrl: String?,
                            apiWriteKey: String?,
                            oneSigmnalId: String?,
                            participantPassword: String?,
                            watchSurveyLink: String?,
                            phoneSurveyLink: String?)
    func updateOneSign(launchOptions: [UIApplication.LaunchOptionsKey : Any]?,
                       surveyInteractor: WatchSurveyInteractor)
    func loadExternalWatchSurveyJSON(completion: ((_ error: Error?) -> ())?)
}

class BackendInteractor: BackendInteractorProtocol {
    let udStorage: UserDefaultsStoregeProtocol
    let dbStorage: DataBaseStorageProtocol
    
    let baseRepo = BaseRepository()
    
    let surveyManager = SurveyManager()
    let notifListner = CozieNotificationLifecycleListener()
    
    init(storage: UserDefaultsStoregeProtocol = CozieStorage.shared,
         dbStorage: DataBaseStorageProtocol = PersistenceController.shared) {
        
        self.udStorage = storage
        self.dbStorage = dbStorage
    }
    
    var currentBackendSettings: BackendInfo? {
        guard let settings = try? dbStorage.backendSetting() else { return nil }
        return settings
    }
    
    func prepareBackendData() {
        let backendInfo = try? dbStorage.backendSetting()
        if backendInfo == nil {
            prepareBackendData(apiReadUrl: Defaults.APIreadURL,
                               apiReadKey: Defaults.APIreadKey,
                               apiWriteUrl: Defaults.APIwriteURL,
                               apiWriteKey: Defaults.APIwriteKey,
                               oneSigmnalId: Defaults.OneSignalAppID,
                               participantPassword: Defaults.generatePasswordID(),
                               watchSurveyLink: Defaults.watchSurveyLink,
                               phoneSurveyLink: Defaults.phoneSurveyLink)
            
            // save default link
            udStorage.saveWSLink(link: (Defaults.watchSurveyLink, Defaults.WSStitle))
        }
    }
    
    func prepareBackendData(apiReadUrl: String?,
                            apiReadKey: String?,
                            apiWriteUrl: String?,
                            apiWriteKey: String?,
                            oneSigmnalId: String?,
                            participantPassword: String?,
                            watchSurveyLink: String?,
                            phoneSurveyLink: String?) {
        if let model = try? dbStorage.backendSetting() {
            
            if let apiReadUrl {
                model.api_read_url = apiReadUrl
            }
            if let apiReadKey {
                model.api_read_key = apiReadKey
            }
            if let apiWriteUrl {
                model.api_write_url = apiWriteUrl
            }
            if let apiWriteKey {
                model.api_write_key = apiWriteKey
            }
            
            model.one_signal_id = Defaults.OneSignalAppID //oneSigmnalId
            
            if let participantPassword {
                model.participant_password = participantPassword
            }
            
            if let watchSurveyLink {
                model.watch_survey_link = watchSurveyLink
            }
            
            if let phoneSurveyLink {
                model.phone_survey_link = phoneSurveyLink
            }
            
            try? dbStorage.saveViewContext()
            debugPrint(model)
        } else {
            try? dbStorage.createBackendSetting(apiReadUrl: apiReadUrl, apiReadKey: apiReadKey, apiWriteUrl: apiWriteUrl, apiWriteKey: apiWriteKey, oneSigmnalId: oneSigmnalId, participantPassword: participantPassword, watchSurveyLink: watchSurveyLink, phoneSurveyLink: phoneSurveyLink)
        }
    }
    
    // MARK: - Load WatchSurvey JSON
    // TODO: - Unit Tests
    func loadExternalWatchSurveyJSON(completion: ((_ error: Error?) -> ())?) {
        if let backend = currentBackendSettings {
            let surveyLink = backend.watch_survey_link ?? ""
            if surveyLink.isEmpty {
                completion?(WatchConnectivityManagerPhone.WatchConnectivityManagerError.surveyJSONError)
            }
            baseRepo.getFileContent(url: surveyLink, parameters: nil) { [weak self] result in
                
                guard let self = self else {
                    completion?(WatchConnectivityManagerPhone.WatchConnectivityManagerError.surveyJSONError)
                    return
                }
                
                switch result {
                case .success(let surveyListData):
                    self.surveyManager.update(surveyListData: surveyListData, storage: self.dbStorage, selected: false) { title, error in
                        if let surveyTitle = title {
                            // update external ws link after sync
                            self.udStorage.saveExternalWSLink(link: (surveyLink, surveyTitle))
                            completion?(error)
                        } else {
                            completion?(error)
                        }
                    }
                case .failure(let error):
                    completion?(WatchConnectivityManagerPhone.WatchConnectivityManagerError.surveyJSONError)
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Setup/Updaete OneSign
    func updateOneSign(launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil,
                       surveyInteractor: WatchSurveyInteractor = WatchSurveyInteractor()) {
        
        let healthKitInteractor: HealthKitInteractor = HealthKitInteractor(storage: udStorage, userData: UserInteractor(), backendData: self, loger: LoggerInteractor.shared)
        
        if let _ = currentBackendSettings {
            // Remove this method to stop OneSignal Debugging
            OneSignal.Debug.setLogLevel(.LL_VERBOSE)
            
            notifListner.healthKitInteractor = healthKitInteractor
            OneSignal.Notifications.addForegroundLifecycleListener(notifListner)
            
            // OneSignal initialization
            OneSignal.initialize(CommunicationKeys.oneSignalAppID.rawValue, withLaunchOptions: launchOptions)
            OneSignal.User.pushSubscription.optIn()
            
            if let delegate = AppDelegate.instance {
                OneSignal.User.addObserver(delegate)
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

class CozieNotificationLifecycleListener : NSObject, OSNotificationLifecycleListener {
    var healthKitInteractor: HealthKitInteractor? = nil
    func onWillDisplay(event: OSNotificationWillDisplayEvent) {
        event.preventDefault()
        healthKitInteractor?.sendData(trigger: CommunicationKeys.pushNotificationForegroundTrigger.rawValue, timeout: HealthKitInteractor.minInterval) { succces in
            debugPrint("On WillDisplay Notification")
        }
        // self?.testLog(trigger: CommunicationKeys.pushNotificationForegroundTrigger.rawValue, details: "(OneSignal) Notification Will Show In Foreground Handler!")
    }
}


extension AppDelegate: OSUserStateObserver {
    func onUserStateDidChange(state: OSUserChangedState) {
        // prints out all properties
        if let playerId = state.current.onesignalId {
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

extension BackendInteractor: ApiDataProtocol{
    var url: String {
        return currentBackendSettings?.api_write_url ?? ""
    }
    
    var key: String {
        return currentBackendSettings?.api_write_key ?? ""
    }
}

// MARK: - TEST: - OneSIgnal curl Alex_Segment
/*
 curl --include \
 --request POST \
 --header "Content-Type: application/json; charset=utf-8" \
 --header "Authorization: Basic NDRkODliNWUtZjdlMy00YmU1LWI2M2YtN2I1MTAzOTg5ZjU3"\
 --data-binary "{
 \"app_id\": \"17d346bf-bfe5-4422-be96-2a8e4ae4cc3d\",
 \"contents\": {\"en\": \"Alexs test for content\"},
 \"headings\": {\"en\": \"Alexs test for headings\"},
 \"subtitle\": {\"en\": \"Alexs test for subtitle\"},
 \"ios_category\": \"cozie_notification_action_category\",
 \"content_available\": true,
 \"included_segments\": [\"Alex_Segment\"]
 }" \
 https://api.onesignal.com/notifications
 */

