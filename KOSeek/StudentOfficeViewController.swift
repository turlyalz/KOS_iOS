//
//  StudentOfficeViewController.swift
//  KOSeek
//
//  Created by Alzhan on 01.02.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//

import Foundation

class StudentOfficeViewController: MainTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        return cell
    }
}
