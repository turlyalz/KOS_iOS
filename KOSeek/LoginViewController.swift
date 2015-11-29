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
        self.view.endEditing(true);
    }
    
    func loginFailedMessage(message: String) {
        let alertLoginFailed = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertLoginFailed.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertLoginFailed, animated: true, completion: nil)
    }
    
    @IBAction func loginButton(sender: UIButton) {
        if usernameField.text == "" {
            loginFailedMessage("Username cannot be empty!")
            return
        }
        if passwordField.text == "" {
            loginFailedMessage("Password cannot be empty!")
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

