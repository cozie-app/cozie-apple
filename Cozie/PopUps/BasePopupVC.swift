//
//  BasePopupView.swift
//  Cozie
//
//  Created by Square Infosoft on 27/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class BasePopupVC: UIViewController {
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        NavigationManager.dismiss(self)
    }
}
