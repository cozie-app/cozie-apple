//
//  DailyParticipation.swift
//  Cozie
//
//  Created by Square Infosoft on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class DailyParticipation: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        self.fromView.backgroundColor = .lightGray
        self.toView.backgroundColor = .systemBackground
        self.selected = .From
    }
    
    @objc private func onClickToView() {
        self.fromView.backgroundColor = .systemBackground
        self.toView.backgroundColor = .lightGray
        self.selected = .To
    }
    
    @IBAction func onClickSet(_ sender: Any) {
        if selected != .None {
            NavigationManager.openNotificationFrequency(self, for: self.selected == .To ? .To : .From)
        }
//        NavigationManager.dismiss(self)
    }
}
