//
//  DataCoordinator.swift
//  Cozie
//
//  Created by Denis on 12.02.2023.
//

import Foundation

struct DataModel {
    
}

class CozieDataCoordinator: ObservableObject {
    let title: String
    
    init(title: String) {
        self.title = title
    }
}
