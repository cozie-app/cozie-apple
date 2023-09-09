//
//  Session.swift
//  Cozie
//
//  Created by Denis on 27.03.2023.
//

import Foundation

class Session: ObservableObject {
    @Published var reminderManager = ReminderManager()
}
