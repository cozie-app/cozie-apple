//
//  String+Lacalization.swift
//  Cozie
//
//  Created by Alexandr Chmal on 03.10.24.
//

import Foundation

extension String {
    public func localize() -> Self {
        return NSLocalizedString(self, comment: "")
    }
}
