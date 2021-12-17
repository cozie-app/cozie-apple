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
    
    var isParticipantId:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBtn.layer.cornerRadius = 5
        
        if(!isParticipantId!){
            idLabel.text = "Experiment ID"
            msgLabel.text = "Please fill specified experiment ID"
        }else{
            
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickSet(_ sender: Any) {
        
        if(isParticipantId!){
            print("Set Participant ID")
        }else{
            print("Set Experiment ID")
        }
        
    }
    
}
