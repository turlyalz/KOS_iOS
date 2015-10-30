//
//  SideMenuController.swift
//  KOSeek
//
//  Created by Alzhan on 27.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class SideMenuController: UITableViewController {
    
    private let menus = ["Timetable", "Semester", "Exams", "Results", "Search People", "LogOut"]
    
    private let BGHeaderColor = UIColor(red: 80/255.0, green: 85/255.0, blue: 90/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SavedVariables.sideMenuViewController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(menus[indexPath.row], forIndexPath: indexPath)
        
        if indexPath.row == 0 {
            cell.frame.size.height -= 120
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation
*/
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        view.userInteractionEnabled = false
    }
    
    func logOutMessage(indexPath: NSIndexPath) {
        let alertLogOut = UIAlertController(title: "", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.Alert)
        alertLogOut.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default,
            handler: {
                action in
                self.performSegueWithIdentifier("logOut", sender: self)
            }
        ))
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
