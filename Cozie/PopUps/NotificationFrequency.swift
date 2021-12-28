//
//  NotificationFrequency.swift
//  Cozie
//
//  Created by Square Infosoft on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

protocol timeSetDelegate {
    func reload()
}

class NotificationFrequency: BasePopupVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    enum TimePickerType: String {
        case NotificationFrequency
        case From
        case To
    }
    var viewType = TimePickerType.NotificationFrequency
    var delegate: timeSetDelegate?
    var isForSubview = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFilledData()
        self.timePicker.minuteInterval = 5
    }
    
    func setupFilledData() {
        switch viewType {
        case .NotificationFrequency:
            self.timePicker.date = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.NotificationFrequency.rawValue) as? Date ?? defaultNotificationFrq
        case .From:
            self.timePicker.date = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.FromTime.rawValue) as? Date ?? defaultFromTime
            self.titleLabel.text = TimePickerType.From.rawValue
            self.titleLabel.textAlignment = .center
            self.subtitleLabel.isHidden = true
        case .To:
            self.timePicker.date = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.ToTime.rawValue) as? Date ?? defaultToTime
            self.titleLabel.text = TimePickerType.To.rawValue
            self.titleLabel.textAlignment = .center
            self.subtitleLabel.isHidden = true
        }
    }
    
    @IBAction func onClickSet(_ sender: Any) {
        switch viewType {
        case .NotificationFrequency:
            UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.NotificationFrequency.rawValue, value: self.timePicker.date)
        case .From:
            UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.FromTime.rawValue, value: self.timePicker.date)
        case .To:
            UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.ToTime.rawValue, value: self.timePicker.date)
        }
        NavigationManager.dismiss(self, isForSubview: isForSubview)
        self.delegate?.reload()
    }
}
