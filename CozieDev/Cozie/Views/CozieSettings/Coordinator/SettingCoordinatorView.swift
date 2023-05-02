//
//  SettingCoordinatorView.swift
//  Cozie
//
//  Created by Denis on 02.04.2023.
//

import SwiftUI

struct SettingCoordinatorView: View {
    
    @ObservedObject var coordinator: SettingCoordinator
    
    var body: some View {
        NavigationView {
            CozieSettingView(viewModel: coordinator.viewModel)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    CozieToolbarContent(title: "Cozie - Settings")
                })
                .background(Color.appBackground)
        }
    }
}

struct SettingCoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        SettingCoordinatorView(coordinator: SettingCoordinator(parent: HomeCoordinator(
                                                                                    session: Session()),
                                                               viewModel: SettingViewModel(reminderManager: Session().reminderManager),
                                                               title: "Cozie - Setting",
                                                               session: Session()))
    }
}
