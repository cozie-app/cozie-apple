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

class HomeCoordinator: ObservableObject {
    static let didReceiveDeeplink = Notification.Name("Cozie.didReceiveDeeplink")
    
    @Published var tab = CozieTabs.data
    @Published var session: Session
    
    let userIntaractor = UserInteractor()
    let settingsInteractor = SettingsInteractor()
    let backendInteractor = BackendInteractor()
    let settingsViewModel: SettingViewModel
    let watchSurveyInteractor: WatchSurveyInteractor
    
    init(tab: CozieTabs = CozieTabs.data,
         session: Session) {
        self.tab = tab
        self.session = session
        settingsViewModel = SettingViewModel(reminderManager: session.reminderManager)
        watchSurveyInteractor = WatchSurveyInteractor()
    }
    
    func loadSessionCoodinator() -> SettingCoordinator {
        return SettingCoordinator(parent: self,
                                  viewModel: settingsViewModel,
                                  title: "Cozie - Settings",
                                  session: session)
    }
    
    func prepareSource(info: InitModel) {
        backendInteractor.prepareBackendData(apiReadUrl: info.apiReadURL, apiReadKey: info.apiReadKey, apiWriteUrl: info.apiWriteURL, apiWriteKey: info.apiWriteKey, oneSigmnalId: info.appOneSignalAppID, participantPassword: info.idPassword, watchSurveyLink: info.apiWatchSurveyURL, phoneSurveyLink: info.apiPhoneSurveyURL)
        if let backend = backendInteractor.currentBackendSettings {
            userIntaractor.prepareUser(participantID: info.idParticipant, experimentID: info.idExperiment, password: backend.participant_password ?? "1G8yOhPvMZ6m")
            settingsInteractor.prepareSettingsData(wssTitle: info.wssTitle, wssGoal: info.wssGoal, wssTimeout: info.wssTimeOut, wssReminderEnabled: info.wssReminderEnabled, wssReminderInterval: info.wssReminderInterval, wssParticipationDays: info.wssParticipationDays, wssParticipationTimeStart: info.wssParticipationTimeStart, wssParticipationTimeEnd: info.wssParticipationTimeEnd, pssReminderEnabled: info.pssReminderEnabled, pssReminderDays: info.pssReminderDays, pssReminderTime: info.pssReminderTime)
            
            backendInteractor.updateOneSign(launchOptions: AppDelegate.instance?.launchOptions)
            settingsViewModel.prepareRemindersIfNeeded()
            
            CozieStorage.shared.savePIDSynced(false)
            CozieStorage.shared.saveExpIDSynced(false)
            CozieStorage.shared.saveSurveySynced(false)
            
            // update selected survey
            if let selectedSurvey = QuestionViewModel.defaultQuestions.first(where: { $0.title == info.wssTitle }) {
                CozieStorage.shared.saveWSLink(link: (selectedSurvey.link, selectedSurvey.title))
            } else {
                if let apiWatchSurveyURL = info.apiWatchSurveyURL, !apiWatchSurveyURL.isEmpty, let wssTitle = info.wssTitle {
                    Task { @MainActor in
                        CozieStorage.shared.saveWSLink(link: (apiWatchSurveyURL, wssTitle))
                        settingsViewModel.questionViewModel.updateWithBackendSurvey(title: wssTitle, link: apiWatchSurveyURL)
                        settingsViewModel.prepareSelectedWSLinkUI(wssTitle)
                    }
                    watchSurveyInteractor.loadSelectedWatchSurveyJSON { title, loadError in
                        Task { @MainActor in
                            NotificationCenter.default.post(name: HomeCoordinator.didReceiveDeeplink, object: nil)
                        }
                    }
                }
            }
        }
    }
    
    func prepareSource() {
        backendInteractor.prepareBackendData()
        if let backend = backendInteractor.currentBackendSettings {
            userIntaractor.prepareUser(password: backend.participant_password ?? "1G8yOhPvMZ6m")
            settingsInteractor.prepareSettingsData()
            backendInteractor.updateOneSign(launchOptions: AppDelegate.instance?.launchOptions)
        }
    }
    
}
