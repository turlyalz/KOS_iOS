//
//  ViewController.swift
//  KOSeek
//
//  Created by Alzhan on 20.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
// 

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.delegate = self
        usernameField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        SavedVariables.sideMenuViewController?.view.userInteractionEnabled = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func login() {
        if usernameField.text == "" {
            createAlertView("", text: usernameEmptyMessage, viewController: self, handlers: ["OK": { _ in }])
            return
        }
        if passwordField.text == "" {
            createAlertView("", text: passwordEmptyMessage, viewController: self, handlers: ["OK": { _ in }])
            return
        }
        SavedVariables.username = usernameField.text!
        SavedVariables.password = passwordField.text!
        self.performSegueWithIdentifier("logInButtonSegue", sender: nil)
    }

    
    @IBAction func loginButton(sender: UIButton) {
        login()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.passwordField {
            textField.resignFirstResponder();
            login();
        } else if (textField == self.usernameField) {
            self.passwordField.becomeFirstResponder();
        }
        return true
    }

}

