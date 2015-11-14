//
//  SideMenuController.swift
//  KOSeek
//
//  Created by Alzhan on 27.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class SideMenuController: UITableViewController {
    
    private let menus = ["Username", "Timetable", "Semester", "Exams", "Results", "Search People", "LogOut"]
    
    private let BGHeaderColor = UIColor(red: 80/255.0, green: 85/255.0, blue: 90/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SavedVariables.sideMenuViewController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            
            if let username = SavedVariables.username {
                let response = DatabaseHelper.getProfileContent(username)
                if response.values.count >= 2 {
                    label.text = response.values[0] + " " + response.values[1]
                }
            }

            label.textColor = .whiteColor()
            
            cell.addSubview(label)
        }
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRect(x: 10, y: -10, width: 100, height: 50))
        let label: UILabel = UILabel(frame: CGRect(x: 10, y: 0, width: 100, height: 50))
        view.backgroundColor = BGHeaderColor
        
        label.text = "KOS ČVUT"
        label.textColor = .whiteColor()
        
        view.addSubview(label)
        
        return view
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        view.userInteractionEnabled = false
    }
    
    func logOutHandler(action: UIAlertAction) -> Void {
        self.performSegueWithIdentifier("logOut", sender: self)
        DatabaseHelper.delete()
        SavedVariables.username = nil
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
    
}
