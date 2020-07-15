//
//  Utilities.swift
//  Cozie
//
//  Created by Federico Tartarini on 13/7/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import Foundation
import UIKit

class Utilties {
    static func styledTextField(_ textField: UITextField) {
        let bottomLine = CALayer()

        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)

        bottomLine.backgroundColor = UIColor.init(red: 58 / 255, green: 134 / 255, blue: 255 / 255, alpha: 1).cgColor

        textField.borderStyle = .none

        textField.layer.addSublayer(bottomLine)
    }

    static func stylePrimaryButton(_ button: UIButton) {
        button.backgroundColor = UIColor.init(red: 58 / 255, green: 134 / 255, blue: 255 / 255, alpha: 1)

        button.layer.cornerRadius = 25

        button.tintColor = UIColor.black
    }

    static func styleSecondaryButton(_ button: UIButton) {
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25
        button.tintColor = UIColor.black
        button.backgroundColor = UIColor.init(red: 131 / 255, green: 56 / 255, blue: 236 / 255, alpha: 1)
    }

    static func isValidPassword(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")

        return passwordTest.evaluate(with: password)
    }

    static func isValidEmail(testStr: String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

}
