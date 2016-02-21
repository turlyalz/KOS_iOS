//
//  ViewController.swift
//  KOSeek
//
//  Created by Alzhan on 20.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
// 

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        SavedVariables.sideMenuViewController?.view.userInteractionEnabled = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButton(sender: UIButton) {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

