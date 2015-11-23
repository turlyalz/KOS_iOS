//
//  ProfileViewController.swift
//  KOSeek
//
//  Created by Alzhan on 12.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var profileInfo: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if let username = SavedVariables.username {
            profileInfo = Database.getPersonBy(username: username)
            if let _ = profileInfo?.firstName, _ = profileInfo?.lastName {
                self.title = (profileInfo?.firstName)! + " " + (profileInfo?.lastName)!
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        SavedVariables.sideMenuViewController?.view.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateValues()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let label: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 50))
        
        if indexPath.row == 1 {
            if let _ = profileInfo?.email, _ = profileInfo?.personalNumber {
                label.text = "Email: " + (profileInfo?.email)!
            }
        }
        else {
            if let _ = profileInfo?.email, _ = profileInfo?.personalNumber {
                label.text = "Personal number: " + (profileInfo?.personalNumber)!
            }
        }
        
        label.textColor = .blackColor()
        
        cell.addSubview(label)
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero

        return cell
    }
}
