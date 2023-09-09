//
//  SettingCoordinator.swift
//  Cozie
//
//  Created by Denis on 02.04.2023.
//

import SwiftUI

class SettingCoordinator: ObservableObject, Identifiable {
    @Published var viewModel: SettingViewModel

    private unowned let parent: HomeCoordinator
    var title: String = ""
    var session: Session
    
    init(parent: HomeCoordinator, viewModel: SettingViewModel, title: String, session: Session) {
        self.parent = parent
        self.viewModel = viewModel
        self.title = title
        self.session = session
    }
    
}

