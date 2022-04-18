//
//  LoginViewController.swift
//  Cozie
//
//  Created by Federico Tartarini on 13/7/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }

    func setUpElements() {

        errorLabel.alpha = 0
        Utilities.styledTextField(emailTextField)
        Utilities.styledTextField(passwordTextField)
        Utilities.stylePrimaryButton(loginButton)

    }

    @IBAction func loginTapped(_ sender: Any) {

        let error = validateFields()

        if error != nil {
            // There is something wrong with the values the user entered
            showErrorMessage(error!)
        } else {

            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let error = error {

                    print("Error adding document: \(error)")
                    self.showErrorMessage("Could not Sign In, incorrect user or password")

                } else {

                    self.transitionToHomeViewController()

                }
            }

        }
    }

    // check that the data entered are correct. If so, return nil otherwise error
    func validateFields() -> String? {

        // check that all fields are filled in
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in your email"
        } else if passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in your password"
        }

        // check that the password is secure
        let cleanPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if Utilities.isValidPassword(cleanPassword) == false {
            return "Invalid password"
        }

        // check that the password is secure
        let cleanEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if Utilities.isValidEmail(testStr: cleanEmail) == false {
            return "Invalid email format"
        }

        return nil
    }

    func showErrorMessage(_ message: String) {

        errorLabel.text = message
        errorLabel.alpha = 1

    }

    func transitionToHomeViewController() {

        let homeViewController = storyboard?.instantiateViewController(identifier: ViewControllersNames.Storyboard.homeViewController)

        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()

    }
}
