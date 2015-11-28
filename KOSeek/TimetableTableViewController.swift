//
//  TimetableViewController.swift
//  KOSeek
//
//  Created by Alzhan on 27.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class TimetableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var sideMenuVC: SideMenuController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        SavedVariables.sideMenuViewController?.view.userInteractionEnabled = true
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateValues()
        tableView.reloadData()
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
        return 16
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width-30, height: 30))
        let days = [0: "Mon", 1: "Tue", 2: "Wed", 3: "Thu", 4: "Fri", 5: "Sat"]
        for i in 0...5 {
            let label: UILabel = UILabel(frame: CGRect(x: 60+CGFloat(i)*(screenSize.width-60)/6, y: 0, width: (screenSize.width-60)/6-15, height: 30))
            label.text = days[i]
            view.addSubview(label)
        }
        view.backgroundColor = .whiteColor()
        return view
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = SlotTableViewCell()
        let person = Database.getPersonBy(username: SavedVariables.username!, context: SavedVariables.cdh!.managedObjectContext)
        let slots = person?.timetableSlots?.allObjects as? [TimetableSlot]
        cell.row = indexPath.row
        cell.timetableSlots = slots
        
        

        return cell
    }
}

