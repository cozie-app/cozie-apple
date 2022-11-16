//
//  Permissions.swift
//  Cozie
//
//  Created by MAC on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class Permissions: BasePopupVC {
    
    enum PermissionsType: Int {
        case noiseDataSwitch, motionDataSwitch, heartDataSwitch, locationDataSwitch, dataSwitch, wifiDataSwitch, bluetoothDataSwitch
    }
    
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
        self.permissions = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.permissions.rawValue) as? [Bool] ?? [false,false,false,false,false,false,false]
        self.fillUpData()
    }
    
    private func fillUpData(){
        
        for type in PermissionsType.noiseDataSwitch.rawValue...PermissionsType.bluetoothDataSwitch.rawValue {
            switch type {
            case PermissionsType.noiseDataSwitch.rawValue:
                noiseDataSwitch.setOn(self.permissions[PermissionsType.noiseDataSwitch.rawValue], animated: true)
            case PermissionsType.heartDataSwitch.rawValue:
                heartDataSwitch.setOn(self.permissions[PermissionsType.heartDataSwitch.rawValue], animated: true)
            case 2: motionDataSwitch.setOn(self.permissions[2], animated: true)
            case 3: locationDataSwitch.setOn(self.permissions[3], animated: true)
            case 4: bluetoothDataSwitch.setOn(self.permissions[4], animated: true)
            case 5: wifiDataSwitch.setOn(self.permissions[5], animated: true)
            case 6: dataSwitch.setOn(self.permissions[6], animated: true)
            default:
                return
            }
        }
    }
    
    @IBAction func permissionValueChanged(_ sender: UISwitch) {
        
        switch sender.tag {
        case 0: self.permissions[0] = noiseDataSwitch.isOn
        case 1: self.permissions[1] = heartDataSwitch.isOn
        case 2: self.permissions[2] = motionDataSwitch.isOn
        case 3: self.permissions[3] = locationDataSwitch.isOn
        case 4: self.permissions[4] = bluetoothDataSwitch.isOn
        case 5: self.permissions[5] = wifiDataSwitch.isOn
        case 6: self.permissions[6] = dataSwitch.isOn
            
        default:
            return
        }
    }
    
    @IBAction func onClickSet(_ sender: UIButton) {
        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.permissions.rawValue, value: self.permissions)
        NavigationManager.dismiss(self)
    }
}
