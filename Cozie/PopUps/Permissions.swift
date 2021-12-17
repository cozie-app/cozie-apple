//
//  Permissions.swift
//  Cozie
//
//  Created by MAC on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class Permissions: UIViewController {

    @IBOutlet weak var noiseDataSwitch: UISwitch!
    @IBOutlet weak var motionDataSwitch: UISwitch!
    @IBOutlet weak var heartDataSwitch: UISwitch!
    @IBOutlet weak var locationDataSwitch: UISwitch!
    @IBOutlet weak var dataSwitch: UISwitch!
    @IBOutlet weak var wifiDataSwitch: UISwitch!
    @IBOutlet weak var bluetoothDataSwitch: UISwitch!
    @IBOutlet weak var setButton: UIButton!
    
    var permissions:[Bool] = [false,false,false,false,false,false,false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setButton.layer.cornerRadius = 5
        

    }
    
    @IBAction func permissionValueChanged(_ sender: UISwitch) {
        
        switch sender.tag {
        case 0:
            self.permissions[0] = noiseDataSwitch.isOn
        case 1:
            self.permissions[1] = heartDataSwitch.isOn
        case 2:
            self.permissions[2] = motionDataSwitch.isOn
        case 3:
            self.permissions[3] = locationDataSwitch.isOn
        case 4:
            self.permissions[4] = bluetoothDataSwitch.isOn
        case 5:
            self.permissions[5] = wifiDataSwitch.isOn
        case 6:
            self.permissions[6] = dataSwitch.isOn
            
        default:
            return
        }
    }
    
    
    @IBAction func onClickSet(_ sender: UIButton) {
        
    }
    
}
