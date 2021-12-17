//
//  QuestionFlow.swift
//  Cozie
//
//  Created by MAC on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class QuestionFlow: UIViewController {

    @IBOutlet weak var thermalBtn: UIButton!
    @IBOutlet weak var IDRPBtn: UIButton!
    @IBOutlet weak var PDPBtn: UIButton!
    @IBOutlet weak var MFBtn: UIButton!
    @IBOutlet weak var thermalMINIBtn: UIButton!
    @IBOutlet weak var IDRPMINIBtn: UIButton!
    @IBOutlet weak var PDPMINIBtn: UIButton!
    @IBOutlet weak var MFMINIBtn: UIButton!
    @IBOutlet weak var questionFlowSetBtn: UIButton!
    
    @IBOutlet weak var viewThermal: UIView!
    @IBOutlet weak var viewIDRP: UIView!
    @IBOutlet weak var viewPDP: UIView!
    @IBOutlet weak var viewMF: UIView!
    @IBOutlet weak var viewThermalMINI: UIView!
    @IBOutlet weak var viewIDRPMINI: UIView!
    @IBOutlet weak var viewPDPMINI: UIView!
    @IBOutlet weak var viewMFMINI: UIView!
    
    var questions:[Bool] = [false,false,false,false,false,false,false,false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questions = UserDefaults.

        questionFlowSetBtn.layer.cornerRadius = 5
    }
    
    @IBAction func questionValueChanged(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            self.questions[0] = sender.isSelected
            viewThermal.backgroundColor = UIColor.lightGray
        case 1:
            self.questions[1] = sender.isSelected
            viewIDRP.backgroundColor = UIColor.lightGray
        case 2:
            self.questions[2] = sender.isSelected
            viewPDP.backgroundColor = UIColor.lightGray
        case 3:
            self.questions[3] = sender.isSelected
            viewMF.backgroundColor = UIColor.lightGray
        case 4:
            self.questions[4] = sender.isSelected
            viewThermalMINI.backgroundColor = UIColor.lightGray
        case 5:
            self.questions[5] = sender.isSelected
            viewIDRPMINI.backgroundColor = UIColor.lightGray
        case 6:
            self.questions[6] = sender.isSelected
            viewPDPMINI.backgroundColor = UIColor.lightGray
        case 7:
            self.questions[7] = sender.isSelected
            viewMFMINI.backgroundColor = UIColor.lightGray
        default:
            return
        }
        
    }
    
    
    @IBAction func onClickSet(_ sender: Any) {
        
    }
    

}
