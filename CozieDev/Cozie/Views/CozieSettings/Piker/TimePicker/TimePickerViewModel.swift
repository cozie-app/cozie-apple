//
//  TimePickerViewModel.swift
//  Cozie
//
//  Created by Denis on 16.03.2023.
//

import Foundation

class TimePickerViewModel: ObservableObject {
    @Published var selectedHour: Int = 10
    @Published var selectedMinures: Int = 10
    @Published var selectedSeconds: Int = 10
    
    let hourRange = 0...24
    let minutesRange = 0...60
    let secondsRange = 0...60
}

