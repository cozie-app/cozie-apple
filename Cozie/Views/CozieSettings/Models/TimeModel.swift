//
//  TimeModel.swift
//  Cozie
//
//  Created by Alexandr Chmal.
//

import Foundation

struct TimeModel {
    var hour: Int = 0
    var minute: Int = 0
    
    init() {
        self.minute = 0
        self.hour = 0
    }
    
    init(hour: Int, minute: Int) {
        self.minute = minute
        self.hour = hour
    }
    
    init(minute: Int) {
        if minute >= 60 {
            hour = Int(minute/60)
            self.minute = minute%60
        } else {
            hour = 0
            self.minute = minute
        }
    }
    
    func formattedMinString() -> String {
        let result = (hour * 60) + minute
        return "\(result) min"
    }
    
    func formattedHourMinString() -> String {
        let result = hour.toTimeString() + ":" + minute.toTimeString()
        return result
    }
    
    func timeInMinutes() -> Int {
        return (hour * 60) + minute
    }
}
