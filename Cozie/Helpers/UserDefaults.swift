//
//  UserDefaults.swift
//  Cozie
//
//  Created by Square Infosoft on 16/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum UserDefaultKeys: String {
        case test
    }
    
    func setValue(for key: String, value: Any) {
        setValue(value, forKey: UserDefaultKeys.test.rawValue)
        synchronize()
    }
    
    func getValue(for key: String) -> Any {
        return (value(forKey: UserDefaultKeys.test.rawValue) ?? nil)
    }
}
