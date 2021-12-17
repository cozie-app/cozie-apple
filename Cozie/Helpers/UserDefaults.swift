//
//  UserDefaults.swift
//  Cozie
//
//  Created by Square Infosoft on 16/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static var shared = UserDefaults()
    
    enum UserDefaultKeys: String {
        case ParticipationDays
        case questions
        case participantID
        case experimentID
    }
    
    func setValue(for key: String, value: Any) {
        setValue(value, forKey: key)
        synchronize()
    }
    
    func getValue(for key: String) -> Any {
        return value(forKey: key) ?? 0
    }
}
