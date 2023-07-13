//
//  HomeCoordinator.swift
//  Cozie
//
//  Created by Denis on 12.02.2023.
//

import Foundation

enum CozieTabs {
    case data, settings, backend
}

class HomeCoordinator: ObservableObject {
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
    
    func prepareSoucer() {
        backendInteractor.prepereBackendData()
        if let backend = backendInteractor.currentBackendSettings {
            userIntaractor.prepareUser(password: backend.participant_password ?? "1G8yOhPvMZ6m")
            settingsInteractor.prepereSettingsData()
        }
    }
}
