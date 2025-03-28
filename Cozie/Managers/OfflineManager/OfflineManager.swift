//
//  OfflineManager.swift
//  Cozie
//
//  Created by Alexandr Chmal on 26.02.24.
//

import Foundation
import CoreData

final class OfflineModeManager {
    private(set) var isEnabled: Bool = false
    
    func updateWith(apiInfo: WApiInfo) {
        if apiInfo.wKey.isEmpty || apiInfo.wUrl.isEmpty {
            isEnabled = true
        } else {
            isEnabled = false
        }
    }
}
