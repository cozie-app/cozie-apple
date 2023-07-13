//
//  CozieApp.swift
//  Cozie
//
//  Created by Denis on 10.02.2023.
//

import SwiftUI

@main
struct CozieApp: App {
    
    // MARK: Stored Properties
    @StateObject var coordinator = HomeCoordinator(session: Session())
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeCoordinatorView(coordinator: coordinator)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
