//
//  ProfileViewController.swift
//  KOSeek
//
//  Created by Alzhan on 12.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit
import SnapKit

class ProfileViewController: MainTableViewController {
    
    private var profileInfo: [String] = []
    private var progressView: UIProgressView!
    private var counter:Int = 0 {
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
            self.profileInfo.appendContentsOf([emailString + email, personalNumberString + personalNumber])
            self.title = firstName + " " + lastName
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        return 2
    }
    
    func startUpdate(action: UIAlertAction) {
        if (!Reachability.isConnectedToNetwork()) {
            createAlertView("", text: noInternetMessage, viewController: self, handlers: ["OK": { _ in }])
            return
        }
        self.progressView = UIProgressView(frame: CGRect(x: 35, y: 50, width: 200, height: 20))
        counter = 0
        let alertLoadingView = UIAlertController(title: "", message: downloadMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertLoadingView.view.addSubview(progressView)
        self.presentViewController(alertLoadingView, animated: true, completion: nil)
        Database.delete(context: SavedVariables.cdh.backgroundContext!, onlyUserData: true)
        SavedVariables.semesterIDNameDict = [:]
        KOSAPI.onComplete = {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        KOSAPI.increaseProgressBar = { value in
            self.counter += value
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            KOSAPI.downloadAllData(SavedVariables.cdh.backgroundContext!)
            OpenHoursDownloader.download()
        })
    }

    @IBAction func updateDataButtonPressed(sender: UIBarButtonItem) {
        createAlertView("", text: refreshAllDataMessage, viewController: self, handlers: [yesString: startUpdate, noString: {_ in} ])
    }
    
    func segmentedControlAction(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            KOSAPI.downloadLanguage = "cs"
        } else {
            KOSAPI.downloadLanguage = "en"
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40
        }
        return 0.7
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let line = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 0.7))
        line.backgroundColor = .grayColor()
        line.alpha = 0.5
        let view = UIView()
        view.addSubview(line)
        return view
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        if indexPath.section == 0 {
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: screenSize.width-15, height: 50))
            label.text = profileInfo[indexPath.row]
            label.textColor = .blackColor()
            cell.addSubview(label)
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
        } else {
            let label = UILabel()
            label.text = downloadLanguageString
            label.textColor = .blackColor()
            cell.addSubview(label)
            label.snp_remakeConstraints { (make) -> Void in
                make.left.equalTo(cell).offset(10)
                make.width.equalTo(cell).dividedBy(2)
                make.height.equalTo(cell)
            }
            let segmentedControl = UISegmentedControl(items: ["Český", "English"])
            if KOSAPI.downloadLanguage == "cs" {
                segmentedControl.selectedSegmentIndex = 0
            } else {
                segmentedControl.selectedSegmentIndex = 1
            }
            
            segmentedControl.addTarget(self, action: "segmentedControlAction:", forControlEvents: .ValueChanged)
            cell.addSubview(segmentedControl)
            segmentedControl.snp_remakeConstraints { (make) -> Void in
                make.left.equalTo(label.snp_right).offset(12)
                make.centerY.equalTo(cell.snp_centerY)
                make.width.equalTo(cell).dividedBy(3)
                make.height.equalTo(cell).dividedBy(2)
            }
        }
        return cell
    }
}
