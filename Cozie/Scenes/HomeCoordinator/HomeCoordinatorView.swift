//
//  HomeCoordinatorView.swift
//  Cozie
//
//  Created by Denis on 12.02.2023.
//

import SwiftUI

struct HomeCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @ObservedObject var coordinator: HomeCoordinator
    let healthKitInteractor = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), logger: LoggerInteractor.shared)
    
    init(coordinator: HomeCoordinator, appDelegate: AppDelegate? = nil) {
        self.coordinator = coordinator
        self.coordinator.appDelegate = appDelegate
    }
    
    var body: some View {
        TabView(selection: $coordinator.tab) {
            CozieDataListView().tabItem {
                HomeTabView(title: "Data",
                            imageName: "person.circle")
            }
            .tag(CozieTabs.data)
            
            SettingCoordinatorView(coordinator: coordinator.loadSessionCoordinator())
                .tabItem {
                    HomeTabView(title: "Settings", imageName: "gearshape.fill")
                }.tag(CozieTabs.settings)
            
            CozieBackendView().tabItem {
                HomeTabView(title: "Advanced", imageName: "cloud")
            }
            .tag(CozieTabs.backend)
            .environmentObject(coordinator)
        }
        .accentColor(.appOrange)
        .onAppear{
            coordinator.prepareSource()
            let _ = coordinator.session.reminderManager.askForPermission { result in
                switch result {
                case let .success(isGranted):
                    debugPrint("access: \(isGranted)")
                case let .failure(error):
                    debugPrint("access restricted: \(error)")
                }
            }
        }
        .disabled(coordinator.disableUI)
    }
}

struct HomeCoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCoordinatorView(coordinator: HomeCoordinator(session: Session()))
    }
}

struct HomeTabView: View {
    let title: String
    let imageName: String
    
    var body: some View {
        Image(systemName: imageName)
        Text(title)
    }
}
