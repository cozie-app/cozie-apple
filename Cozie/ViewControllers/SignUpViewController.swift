//
//  SignUpViewController.swift
//  Cozie
//
//  Created by Federico Tartarini on 13/7/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!

    @IBOutlet weak var lastNameTextField: UITextField!

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var signUpButton: UIButton!

    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }

    func setUpElements() {

        errorLabel.alpha = 0
        Utilities.styledTextField(firstNameTextField)
        Utilities.styledTextField(lastNameTextField)
        Utilities.styledTextField(emailTextField)
        Utilities.styledTextField(passwordTextField)
        Utilities.stylePrimaryButton(signUpButton)

    }

    // check that the data entered are correct. If so, return nil otherwise error
    func validateFields() -> String? {

        // check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                   lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                   emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                   passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields"
        }

        // check that the password is secure
        let cleanPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if Utilities.isValidPassword(cleanPassword) == false {
            return """
                   Please make sure your password is at least 8 characters long, 
                   contains a special character and a number
                   """
        }

        // check that the email format is correct
        let cleanEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if Utilities.isValidEmail(testStr: cleanEmail) == false {
            return """
                   The email you entered is not valid.
                   """
        }

        return nil
    }

    @IBAction func signUpTapped(_ sender: Any) {

        let error = validateFields()

        if error != nil {
            // There is something wrong with the values the user entered
            showErrorMessage(error!)
        } else {

            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in

                if error != nil {
                    // there was an error
                    self.showErrorMessage("Error creating user")
                } else {

                    // User was created successfully, now also store name and surname
                    let db = Firestore.firestore()

                    // Add a new document with a generated ID
                    var ref: DocumentReference? = nil
                    ref = db.collection("users").addDocument(data: [
                        "firstName": firstName,
                        "lastName": lastName,
                        "uid": result!.user.uid
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                            self.showErrorMessage("User data couldn't be added to the database. PLease contact the principal investigator.")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                    
                    self.transitionToHome()

                }

            }
        }

    }

    func showErrorMessage(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome () {
        
        let homeViewController = storyboard?.instantiateViewController(identifier: ViewControllersNames.Storyboard.homeViewController)
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()

    }

}
