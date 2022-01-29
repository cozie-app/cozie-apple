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
    
    func getDayString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let stringDate = dateFormatter.string(from: self)
        return stringDate
    }
    
    func getHour() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "H"
        return timeFormatter.string(from: self)
    }
    
    func getMinutes() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "mm"
        return timeFormatter.string(from: self)
    }
}

extension String {
    func date() -> Date {
        if self != "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            guard let date = dateFormatter.date(from: self) else { return Date() }
            return date
        } else {
            return Date()
        }
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

extension UITableView {
    func setupPadding() {
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
    }
}

extension UILabel {
    func calculateMaxLines(forText: String = "") -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        var text = (self.text ?? "") as NSString
        if forText != "" {
            text = forText as NSString
        }
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font as Any], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
