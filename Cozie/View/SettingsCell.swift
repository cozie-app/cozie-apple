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
            switchControl.isOn = !sectionType.isSwitchEnable
            imageViewProperty.image = UIImage(named: sectionType.imageName)
            imageViewProperty.isHidden = !sectionType.imageView
            self.setupImage(image: UIImage(named: sectionType.imageName))
        }
    }

    // define initial state of the switch and color
    lazy var switchControl: UISwitch = {

        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.onTintColor = primaryColour
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)

        return switchControl
    }()
    
    // define initial state of imageView
    let imageViewProperty: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // add switch control to settings
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true

        addSubview(imageViewProperty)
        imageViewConstraints()
    }

    private func imageViewConstraints() {
        imageViewProperty.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        imageViewProperty.heightAnchor.constraint(equalToConstant: 30).isActive = true
        imageViewProperty.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageViewProperty.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
    }
    
    private func setupImage(image: UIImage?) {
        let heightConstraints = imageViewProperty.constraints.filter{$0.firstAttribute == .height}
        if let imageViewHeight = heightConstraints.first?.constant {
            let desiredImageViewWidth = (imageViewHeight / (image?.size.height ?? 30)) * (image?.size.width ?? 30)
            let widthConstraints = imageViewProperty.constraints.filter{$0.firstAttribute == .width}
            widthConstraints.first?.isActive = false
            imageViewProperty.widthAnchor.constraint(equalToConstant: desiredImageViewWidth).isActive = true
        }
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
