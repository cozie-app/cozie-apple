//
//  Extension.swift
//  Cozie
//
//  Created by Square Infosoft on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func get24FormateTimeString() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: self)
    }
}

extension UIView {
    @IBInspectable var cornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        }set {
            self.layer.cornerRadius = CGFloat(newValue)
        }
    }
}

extension UIButton {
    @IBInspectable var buttonCornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        }set {
            self.layer.cornerRadius = CGFloat(newValue)
        }
    }
}

extension UIViewController {
    func getControllerFromStack(_ vc: AnyClass) -> UIViewController? {
        guard let controllers = self.navigationController?.viewControllers else { return nil }
        for controller in controllers {
            if controller.isKind(of: vc) {
                return controller
            }
        }
        return nil
    }
}
