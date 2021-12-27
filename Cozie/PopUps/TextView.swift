//
//  TextView.swift
//  Cozie
//
//  Created by MAC on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class TextView: BasePopupVC {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var setBtn: UIButton!
    
    var isParticipantID: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBtn.layer.cornerRadius = 5
        self.fillUpData()
    }
    
    func fillUpData() {
        switch self.isParticipantID {
        case true:
            idLabel.text = "Participant ID"
            msgLabel.text = "Please fill your specified Participant ID"
            idTextField.text = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? ""
        case false:
            idLabel.text = "Experiment ID"
            msgLabel.text = "Please fill your specified Experiment ID"
            idTextField.text = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? ""
        }
    }
    
    @IBAction func onClickSet(_ sender: Any) {
        if isParticipantID {
            UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue, value: self.idTextField.text!)
        } else {
            UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue, value: self.idTextField.text!)
        }
        NavigationManager.dismiss(self)
    }
}
