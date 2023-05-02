//
//  Int+Helper.swift
//  Cozie
//
//  Created by Denis on 30.03.2023.
//

import Foundation

extension Int {
    /// Format int value and return time string
    /// - Returns: if value bigger then 9 return value as String, else add 0 before number
    func toTimeString() -> String {
        let time = self > 9 ? "\(self)" : "0\(self)"
        return time
    }
}
