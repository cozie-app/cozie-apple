//
//  Questions.swift
//  Cozie WatchKit Extension
//
//  Created by Federico Tartarini on 29/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import WatchKit
import Foundation

class Question {
    
    let title: String
    let options: Array<String>
    let icons: Array<UIImage>

    //MARK: Initialization
     
    init(title: String, options: Array<String>, icons: Array<UIImage>) {
        
        // Initialize stored properties.
        self.title = title
        self.options = options
        self.icons = icons
        
    }
    
}
