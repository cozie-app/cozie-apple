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
    
    var isParticipantID: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBtn.layer.cornerRadius = 5
        self.fillUpData()
    }
    
    func fillUpData() {
        switch self.isParticipantID {
        case 1:
            idLabel.text = "Participant ID"
            msgLabel.text = "Please fill your specified Participant ID"
            idTextField.text = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? ""
        case 2:
            idLabel.text = "Experiment ID"
            msgLabel.text = "Please fill your specified Experiment ID"
            idTextField.text = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? ""
        case 3:
            idLabel.text = "Set Goal"
            msgLabel.text = "Please enter the study goal"
            idTextField.text = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.studyGoal.rawValue) as? String ?? ""
        default:
            idLabel.text = "Not defined"
            msgLabel.text = "Note defined"
            idTextField.text = ""
        }
    }
    
    @IBAction func onClickSet(_ sender: Any) {
        switch self.isParticipantID {
        case 1:
            UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue, value: self.idTextField.text!)
            Utilities.getData { (isSuccess, data) in
                DispatchQueue.main.async {
                    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.setUpBackgroundDeliveryForDataTypes()
                }
            }
        case 2:
            UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue, value: self.idTextField.text!)
        case 3:
            UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.studyGoal.rawValue, value: Double(self.idTextField.text!))
        default:
            var a = 2
        }
        NavigationManager.dismiss(self)}
}
