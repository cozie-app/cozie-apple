//
//  HomeCoordinator.swift
//  Cozie
//
//  Created by Denis on 12.02.2023.
//

import Foundation
import UIKit

enum CozieTabs {
    case data, settings, backend
}

protocol UserInteractorProtocol {
    var currentUser: User? { get }
    func prepareUser(participantID: String?, experimentID: String?, password: String?)
    func prepareUser(password: String)
}

protocol SettingsInteractorProtocol {
    var currentSettings: SettingsData? { get }
    func prepareSettingsData()
    func prepareSettingsData(wssTitle: String?,
                             wssGoal: Int16?,
                             wssTimeout: Int16?,
                             wssReminderEnabled: Bool?,
                             wssReminderInterval: Int16?,
                             wssParticipationDays: String?,
                             wssParticipationTimeStart: String?,
                             wssParticipationTimeEnd: String?,
                             pssReminderEnabled: Bool?,
                             pssReminderDays: String?,
                             pssReminderTime: String?)
}

final class HomeCoordinator: ObservableObject {
    
    // MARK: Private
    private let userInteractor: UserInteractorProtocol
    private let settingsInteractor: SettingsInteractorProtocol
    private let backendInteractor: BackendInteractorProtocol
    private let settingsViewModel: SettingViewModel
    private let watchSurveyInteractor: WatchSurveyInteractor
    weak var appDelegate: AppDelegate?
    
    static let didReceiveDeeplink = Notification.Name("Cozie.didReceiveDeeplink")
    
    @Published var tab = CozieTabs.data
    @Published var session: Session
    @Published var disableUI: Bool = false
    
    init(tab: CozieTabs = CozieTabs.data,
         session: Session,
         userInteractor: UserInteractorProtocol = UserInteractor(),
         settingsInteractor: SettingsInteractorProtocol = SettingsInteractor(),
         backendInteractor: BackendInteractorProtocol = BackendInteractor()) {
        self.tab = tab
        self.session = session
        
        self.userInteractor = userInteractor
        self.settingsInteractor = settingsInteractor
        self.backendInteractor = backendInteractor
        
        settingsViewModel = SettingViewModel(reminderManager: session.reminderManager)
        watchSurveyInteractor = WatchSurveyInteractor()
    }
    
    /// Create settings coordinator
    ///
    func loadSessionCoordinator() -> SettingCoordinator {
        return SettingCoordinator(parent: self,
                                  viewModel: settingsViewModel,
                                  title: "Cozie - Settings",
                                  session: session)
    }
    
    /// Use this function to apply new settings from QR-code/DeepLink
    ///
    func prepareSource(info: InitModel, storage: WSStateStorageProtocol & WSStorageProtocol, appDelegate: AppDelegate? = nil ) {
        // update backend data
        backendInteractor.prepareBackendData(apiReadUrl: info.apiReadURL, apiReadKey: info.apiReadKey, apiWriteUrl: info.apiWriteURL, apiWriteKey: info.apiWriteKey, oneSignalId: nil, participantPassword: info.idPassword, watchSurveyLink: info.apiWatchSurveyURL, phoneSurveyLink: info.apiPhoneSurveyURL)
        
        // update HealthKit cut off interval
        if let cuttoffTime = info.cutoffTime {
            storage.saveMaxHealthCutoffTimeInterval(cuttoffTime)
        }
        
        // update location distance filter
        if let distanceFilter = info.distanceFilter {
            storage.setDistanceFilter(Float(distanceFilter))
            appDelegate?.locationManager.updateLocationManager()
        }
        
        // update settings data
        if let backend = backendInteractor.currentBackendSettings {
            userInteractor.prepareUser(participantID: info.idParticipant, experimentID: info.idExperiment, password: backend.participant_password ?? "1G8yOhPvMZ6m")
            settingsInteractor.prepareSettingsData(wssTitle: info.wssTitle, wssGoal: info.wssGoal, wssTimeout: info.wssTimeOut, wssReminderEnabled: info.wssReminderEnabled, wssReminderInterval: info.wssReminderInterval, wssParticipationDays: info.wssParticipationDays, wssParticipationTimeStart: info.wssParticipationTimeStart, wssParticipationTimeEnd: info.wssParticipationTimeEnd, pssReminderEnabled: info.pssReminderEnabled, pssReminderDays: info.pssReminderDays, pssReminderTime: info.pssReminderTime)
            
            backendInteractor.updateOneSign(launchOptions: AppDelegate.instance?.launchOptions, surveyInteractor: WatchSurveyInteractor())
            // clear and update reminders via QR-code/DeepLink
            settingsViewModel.prepareRemindersIfNeeded()
            
            // reset sync device status
            storage.savePIDSynced(false)
            storage.saveExpIDSynced(false)
            storage.saveSurveySynced(false)
            
            // update selected survey
            if let selectedSurvey = QuestionViewModel.defaultQuestions.first(where: { $0.title == info.wssTitle }) {
                storage.saveWSLink(link: (selectedSurvey.link, selectedSurvey.title))
            } else {
                if let apiWatchSurveyURL = info.apiWatchSurveyURL, !apiWatchSurveyURL.isEmpty, let wssTitle = info.wssTitle {
                    Task { @MainActor in
                        storage.saveWSLink(link: (apiWatchSurveyURL, wssTitle))
                        settingsViewModel.questionViewModel.updateWithBackendSurvey(title: wssTitle, link: apiWatchSurveyURL)
                        settingsViewModel.prepareSelectedWSLinkUI(wssTitle)
                    }
                    // reload view settings after loading a new watch review
                    watchSurveyInteractor.loadSelectedWatchSurveyJSON { title, loadError in
                        Task { @MainActor in
                            NotificationCenter.default.post(name: HomeCoordinator.didReceiveDeeplink, object: nil)
                        }
                    }
                }
            }
        }
    }
    
    /// Use this function to prepare default data
    ///
    func prepareSource() {
        backendInteractor.prepareBackendData()
        if let backend = backendInteractor.currentBackendSettings {
            userInteractor.prepareUser(password: backend.participant_password ?? "1G8yOhPvMZ6m")
            settingsInteractor.prepareSettingsData()
            backendInteractor.updateOneSign(launchOptions: AppDelegate.instance?.launchOptions, surveyInteractor: WatchSurveyInteractor())
        }
    }
}
