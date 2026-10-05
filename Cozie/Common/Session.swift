//
//  Session.swift
//  Cozie
//
//  Created by Denis on 27.03.2023.
//

import Foundation

class Session: ObservableObject {
    @Published var reminderManager = ReminderManager()

    @MainActor
    private(set) lazy var pauseService = PauseService(
        pauseManager: PauseManager(),
        reminderManager: reminderManager
    )
    @MainActor
    private(set) lazy var pauseLogUploader = PauseLogUploader()
}
