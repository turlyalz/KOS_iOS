//
//  TimetableViewController.swift
//  KOSeek
//
//  Created by Alzhan on 27.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class TimetableViewController: MainTableViewController {
    
    private var sideMenuVC: SideMenuController?
    private var slots: [TimetableSlot]?
    private var parity: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let person = Database.getPersonBy(username: SavedVariables.username!, context: SavedVariables.cdh.managedObjectContext)
        slots = person?.timetableSlots?.allObjects as? [TimetableSlot]
        parity = self.restorationIdentifier
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 16
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width-30, height: 30))
        view.backgroundColor = BGHeaderColor
        let days = [0: "Mon", 1: "Tue", 2: "Wed", 3: "Thu", 4: "Fri", 5: "Sat"]
        for i in 0...5 {
            let cellWidth = (screenSize.width-60)/6
            let x = 60+CGFloat(i)*cellWidth
            let label: UILabel = UILabel(frame: CGRect(x: x, y: 0, width: cellWidth-5, height: 30))
            label.text = days[i]
            label.adjustsFontSizeToFitWidth = true
            view.addSubview(label)
            label.textColor = .whiteColor()
        }
        //view.backgroundColor = .whiteColor()
        return view
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = SlotTableViewCell()
        cell.row = indexPath.row
        if let parity = self.parity {
            cell.parity = parity
        }
        cell.timetableSlots = slots
        return cell
    }
}

