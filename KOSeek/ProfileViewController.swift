//
//  ProfileViewController.swift
//  KOSeek
//
//  Created by Alzhan on 12.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class ProfileViewController: MainTableViewController {
    
    var profileInfo: [String] = []
    var progressView: UIProgressView!
    var counter:Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            progressView.setProgress(fractionalProgress, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfileInfo()
    }
    
    func setProfileInfo() {
        if let username = SavedVariables.username, profileInfo = Database.getPersonBy(username: username, context: SavedVariables.cdh.managedObjectContext), firstName = profileInfo.firstName, lastName = profileInfo.lastName, email = profileInfo.email, personalNumber = profileInfo.personalNumber {
            self.profileInfo.appendContentsOf(["Email: " + email, "Personal number: " + personalNumber])
            self.title = firstName + " " + lastName
        }
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func startUpdate(action: UIAlertAction) {
        if (!Reachability.isConnectedToNetwork()) {
            createAlertView("", text: "You have no internet connection. Please check your settings and try again.", viewController: self, handlers: ["OK": { _ in }])
            return
        }
        self.progressView = UIProgressView(frame: CGRect(x: 35, y: 50, width: 200, height: 20))
        counter = 0
        let alertLoadingView = UIAlertController(title: "", message: "Downloading. Please Wait.", preferredStyle: UIAlertControllerStyle.Alert)
        alertLoadingView.view.addSubview(progressView)
        self.presentViewController(alertLoadingView, animated: true, completion: nil)
        Database.deleteOnlyUserData(context: SavedVariables.cdh.backgroundContext!)
        SavedVariables.semesterIDNameDict = [:]
        KOSAPI.onComplete = {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        KOSAPI.increaseProgressBar = { value in
            self.counter += value
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), { KOSAPI.downloadAllData() })
    }

    @IBAction func updateDataButtonPressed(sender: UIBarButtonItem) {
        createAlertView("", text: "All of your actual data will be removed and new data will be downloaded.\nAre you sure you want to continue?", viewController: self, handlers: ["Yes": startUpdate, "No": {_ in} ])
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: screenSize.width-15, height: 50))
        label.text = profileInfo[indexPath.row]
        label.textColor = .blackColor()
        cell.addSubview(label)
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
}
