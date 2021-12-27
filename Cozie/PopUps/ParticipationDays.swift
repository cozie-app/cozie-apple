//
//  ParticipationDays.swift
//  Cozie
//
//  Created by Square Infosoft on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class ParticipationDays: BasePopupVC {

    @IBOutlet weak var switchMon: UISwitch!
    @IBOutlet weak var switchTue: UISwitch!
    @IBOutlet weak var switchWed: UISwitch!
    @IBOutlet weak var switchThu: UISwitch!
    @IBOutlet weak var switchFri: UISwitch!
    @IBOutlet weak var switchSat: UISwitch!
    @IBOutlet weak var switchSun: UISwitch!
    
    var days:[Bool] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFilledData()
    }
    
    private func setupFilledData() {
        self.days = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ParticipationDays.rawValue) as? [Bool] ?? [true,true,true,true,true,true,true]
        for i in Range(0...6) {
            switch i {
            case 0: switchMon.isOn = self.days[i]
            case 1: switchTue.isOn = self.days[i]
            case 2: switchWed.isOn = self.days[i]
            case 3: switchThu.isOn = self.days[i]
            case 4: switchFri.isOn = self.days[i]
            case 5: switchSat.isOn = self.days[i]
            case 6: switchSun.isOn = self.days[i]
            default:
                break
            }
        }
    }
    
    @IBAction func onClickSet(_ sender: Any) {
        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.ParticipationDays.rawValue, value: self.days)
        NavigationManager.dismiss(self)
    }
    
    @IBAction func daysValueChanged(_ sender: UISwitch) {
        switch sender.tag {
        case 0: self.days[0] = sender.isOn
        case 1: self.days[1] = sender.isOn
        case 2: self.days[2] = sender.isOn
        case 3: self.days[3] = sender.isOn
        case 4: self.days[4] = sender.isOn
        case 5: self.days[5] = sender.isOn
        case 6: self.days[6] = sender.isOn
        default:
            break
        }
    }
}
