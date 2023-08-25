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
    static let updateNorification = Notification.Name("CozieUpdateView")
    
    @Published var tab = CozieTabs.data
    @Published var session: Session
    
    let userIntaractor = UserInteractor()
    let settingsInteractor = SettingsInteractor()
    let backendInteractor = BackendInteractor()
    let settingsViewModel: SettingViewModel
    
    init(tab: CozieTabs = CozieTabs.data,
         session: Session) {
        self.tab = tab
        self.session = session
        settingsViewModel = SettingViewModel(reminderManager: session.reminderManager)
    }
    
    func loadSessionCoodinator() -> SettingCoordinator {
        return SettingCoordinator(parent: self,
                                  viewModel: settingsViewModel,
                                  title: "Cozie - Settings",
                                  session: session)
    }
    
    func prepareSoucer(info: InitModel) {
        backendInteractor.prepareBackendData(apiReadUrl: info.apiReadURL, apiReadKey: info.apiReadKey, apiWriteUrl: info.apiWriteURL, apiWriteKey: info.apiWriteKey, oneSigmnalId: info.appOneSignalAppID, participantPassword: info.idPassword, watchSurveyLink: info.apiWatchSurveyURL, phoneSurveyLink: info.apiPhoneSurveyURL)
        if let backend = backendInteractor.currentBackendSettings {
            userIntaractor.prepareUser(participantID: info.idParticipant, experimentID: info.idExperiment, password: backend.participant_password ?? "1G8yOhPvMZ6m")
            settingsInteractor.prepareSettingsData(wssTitle: info.wssTitle, wssGoal: info.wssGoal, wssTimeout: info.wssTimeOut, wssReminderEnabeled: info.wssReminderEnabeled, wssReminderInterval: info.wssReminderInterval, wssParticipationDays: info.wssParticipationDays, wssParticipationTimeStart: info.wssParticipationTimeStart, wssParticipationTimeEnd: info.wssParticipationTimeEnd, pssReminderEnabled: info.pssReminderEnabled, pssReminderDays: info.pssReminderDays, pssReminderTime: info.pssReminderTime)
            
            backendInteractor.updateOneSign(launchOptions: AppDelegate.instance?.launchOptions)
            
            settingsViewModel.configureSettins()
            settingsViewModel.prepareRemindersIfNeeded()
            
            // update selected survey
            if let selectedSurvey = QuestionViewModel.defaultQuestions.first(where: { $0.title == info.wssTitle }) {
                CozieStorage.shared.saveWSLink(link: selectedSurvey.link)
            } else {
                if !info.apiWatchSurveyURL.isEmpty {
                    settingsViewModel.questionViewModel.updateWithBackendSurvey(title: info.wssTitle, link: info.apiWatchSurveyURL)
                    CozieStorage.shared.saveWSLink(link: info.apiWatchSurveyURL)
                }
            }
            
            CozieStorage.shared.savePIDSynced(false)
            CozieStorage.shared.saveExpIDSynced(false)
            CozieStorage.shared.saveSurveySynced(false)
            
            // trigger screens update
            NotificationCenter.default.post(name: HomeCoordinator.updateNorification, object: nil)
        }
    }
    
    func prepareSoucer() {
        backendInteractor.prepareBackendData()
        if let backend = backendInteractor.currentBackendSettings {
            userIntaractor.prepareUser(password: backend.participant_password ?? "1G8yOhPvMZ6m")
            settingsInteractor.prepareSettingsData()
            backendInteractor.updateOneSign(launchOptions: AppDelegate.instance?.launchOptions)
        }
    }
    
}
