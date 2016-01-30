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
    var profileInfo: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        setProfileInfo()
    }
    
    func setProfileInfo() {
        if let username = SavedVariables.username, profileInfo = Database.getPersonBy(username: username, context: SavedVariables.cdh.managedObjectContext), firstName = profileInfo.firstName, lastName = profileInfo.lastName, email = profileInfo.email, personalNumber = profileInfo.personalNumber {
            self.profileInfo.appendContentsOf(["Email: " + email, "Personal number: " + personalNumber])
            self.title = firstName + " " + lastName
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
        return 3
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateValues()
        tableView.reloadData()
    }
    
    func updateDataButtonPressed(sender: UIButton!) {
        createAlertView("All your actual data will be removed and new data will be downloaded. Are you sure you want to continue?", viewController: self, handlerYes: {
            action in
            Database.deleteOnlyUserData(context: SavedVariables.cdh.backgroundContext!)
            KOSAPI.onComplete = {
                
            }
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), { KOSAPI.downloadAllData() })
            },
            handlerNo: {action in})
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if (indexPath.row == 2) {
            let button = UIButton(type: UIButtonType.System) as UIButton
            button.frame = CGRect(x: 15, y: 0, width: screenSize.width/3, height: 50)
            button.setTitle("Update all data", forState: .Normal)
            //button.setTitleColor(.blackColor(), forState: .Normal)
            button.addTarget(self, action: "updateDataButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.addSubview(button)
            return cell
        }
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: screenSize.width-15, height: 50))
        label.text = profileInfo[indexPath.row]
        label.textColor = .blackColor()
        cell.addSubview(label)
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
}
