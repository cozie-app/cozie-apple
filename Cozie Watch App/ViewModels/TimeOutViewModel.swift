//
//  TimeOutViewModel.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 20.04.23.
//

import SwiftUI
import Foundation

class TimeOutViewModel: ObservableObject {
    private let storage = StorageManager.shared
    @Published var leftTime: Int = 0
    
    func updateLeftTime() {
        let lastUpdateInSeconds = Int(Date().timeIntervalSince1970) - storage.lastSurveySendInterval()
        let timeInterval = storage.timeInterval()
        if storage.lastSurveySendInterval() > 0, timeInterval > 0, (lastUpdateInSeconds - timeInterval) < 0 {
            leftTime = Int(ceil(Float(timeInterval - lastUpdateInSeconds)/60))
        } else {
            leftTime = -1
        }
    }
}
