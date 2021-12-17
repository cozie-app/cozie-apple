//
//  NotificationFrequency.swift
//  Cozie
//
//  Created by Square Infosoft on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class NotificationFrequency: UIViewController {

    @IBOutlet weak var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFilledData()
    }
    
    private func setupFilledData() {
    }
    
    @IBAction func onClickSet(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
