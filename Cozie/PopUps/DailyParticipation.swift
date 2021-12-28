//
//  DailyParticipation.swift
//  Cozie
//
//  Created by Square Infosoft on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

protocol TimePickerDelegate {
    func dailyPicker(selected type: NotificationFrequency.TimePickerType, view: UIViewController)
}

class DailyParticipation: BasePopupVC {

    @IBOutlet weak var fromView: UIView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toView: UIView!
    @IBOutlet weak var toLabel: UILabel!
    
    enum selectedType {
        case From
        case To
        case None
    }
    private var selected = selectedType.None
    var delegate: TimePickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupFilledData()
    }
    
    private func setup() {
        let fromViewGesture = UITapGestureRecognizer(target: self, action: #selector(onClickFromView))
        self.fromView.isUserInteractionEnabled = true
        self.fromView.addGestureRecognizer(fromViewGesture)
        let toViewGesture = UITapGestureRecognizer(target: self, action: #selector(onClickToView))
        self.toView.isUserInteractionEnabled = true
        self.toView.addGestureRecognizer(toViewGesture)
    }
    
    private func setupFilledData() {
        self.fromLabel.text = (UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.FromTime.rawValue) as? Date ?? Date()).get24FormateTimeString() + "hrs"
        self.toLabel.text = (UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ToTime.rawValue) as? Date ?? Date()).get24FormateTimeString() + "hrs"
    }
    
    @objc private func onClickFromView() {
        self.selected = .From
        self.onClickSet(0)
    }
    
    @objc private func onClickToView() {
        self.selected = .To
        self.onClickSet(0)
    }
    
    @IBAction func onClickSet(_ sender: Any) {
        if selected != .None {
            NavigationManager.openNotificationFrequency(self, for: self.selected == .To ? .To : .From, view: self, isForSubview: true)
        } else {
            NavigationManager.dismiss(self)
        }
    }
}

extension DailyParticipation: timeSetDelegate {
    func reload() {
        self.selected = .None
        self.setupFilledData()
    }
}
