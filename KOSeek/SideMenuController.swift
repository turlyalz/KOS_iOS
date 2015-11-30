//
//  SideMenuController.swift
//  KOSeek
//
//  Created by Alzhan on 27.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

// MARK: SideMenuConroller
class SideMenuController: UITableViewController {
    
    private let menus = ["Username", "Timetable", "Semester", "Exams", "Results", "Search People", "LogOut"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SavedVariables.sideMenuViewController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SavedVariables.canDropDownMenuShow = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        SavedVariables.canDropDownMenuShow = true
        print(SavedVariables.canDropDownMenuShow)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(menus[indexPath.row], forIndexPath: indexPath)
        
        if indexPath.row == 0 {
            let label: UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 50))
            
            if let username = SavedVariables.username, profileInfo = Database.getPersonBy(username: username, context: SavedVariables.cdh.managedObjectContext), firstName = profileInfo.firstName, lastName = profileInfo.lastName{
                label.text = firstName + " " + lastName
            }

            label.textColor = .whiteColor()
            cell.addSubview(label)
        }
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 10, y: -10, width: 100, height: 50))
        let label = UILabel(frame: CGRect(x: 50, y: 0, width: 100, height: 50))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 32, height: 24))
        imageView.image = UIImage(named: "KOS")
        view.backgroundColor = BGHeaderColor
        
        label.text = "KOS ČVUT"
        label.textColor = .whiteColor()
        
        view.addSubview(label)
        view.addSubview(imageView)
        
        return view
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        view.userInteractionEnabled = false
    }
    
    func logOutHandler(action: UIAlertAction) -> Void {
        self.performSegueWithIdentifier("logOut", sender: self)
        Database.delete(context: SavedVariables.cdh.managedObjectContext)
        SavedVariables.resetAll()
    }
    
    func logOutMessage(indexPath: NSIndexPath) {
        let alertLogOut = UIAlertController(title: "", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.Alert)
        alertLogOut.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: logOutHandler))
        alertLogOut.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default,
            handler: {
                action in
                self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        ))
        self.presentViewController(alertLogOut, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == menus.count-1 {
            logOutMessage(indexPath)
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateValues()
    }
    
}
