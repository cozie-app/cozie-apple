//
//  TextView.swift
//  Cozie
//
//  Created by MAC on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class TextView: UIViewController {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var setBtn: UIButton!
    
    var isParticipantID: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBtn.layer.cornerRadius = 5
        self.fillUpData()

        // Do any additional setup after loading the view.
    }
    
    private func fillUpData(){
        switch isParticipantID {
        
        case true:
            idTextField.text = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? ""
            
        case false:
            idLabel.text = "Experiment ID"
            msgLabel.text = "Please fill your specified Experiment ID"
            
            idTextField.text = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue) as? String ?? ""
            
        default:
            return
        }
    }
    
    @IBAction func onClickSet(_ sender: Any) {
        
        if isParticipantID! {
            
            UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue, value: self.idTextField.text!)
            print("Set Participant ID")
        }else{
            
            UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.experimentID.rawValue, value: self.idTextField.text!)
            print("Set Experiment ID")
        }
        
    }
    
}
