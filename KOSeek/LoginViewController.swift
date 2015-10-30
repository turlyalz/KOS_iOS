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
        // Do any additional setup after loading the view, typically from a nib.
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
        SavedVariables.username = usernameField.text!
        let response = LoginHelper.getAuthToken(username: SavedVariables.username!, password: passwordField.text!)

       
        if response.success || response.tokenORerror == "Log in failed. Please try again. Error 401" {
           self.performSegueWithIdentifier("successLoginSegue", sender: nil)
        }
        
        else {
            loginFailedMessage(response.tokenORerror)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

