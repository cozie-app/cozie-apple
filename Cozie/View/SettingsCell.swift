//
//  SettingsCell.swift
//  SettingsTemplate
//
//  Created by Federico Tartarini on 25/6/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    // define settings cell properties
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else { return }
            textLabel?.text = sectionType.description
            switchControl.isHidden = !sectionType.constrainsSwitch
        }
    }

    // define initial state of the switch and color
    lazy var switchControl: UISwitch = {

        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.onTintColor = UIColor(red: 0 / 255, green: 181 / 255, blue: 32 / 255, alpha: 1)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)

        return switchControl
    }()

    // add switch control to settings
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // triggers an action when the switch button is pressed
    @objc func handleSwitchAction(sender: UISwitch){
        if sender.isOn {
            print("Turned On")
        } else {
            print("Turned Off")
        }

    }
    
}
