//
//  StudentOfficeViewController.swift
//  KOSeek
//
//  Created by Alzhan on 01.02.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//

import Foundation

class StudentOfficeViewController: TableContentViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTable()
        makePullToRefresh("refreshTableView")
    }
    
    func setTable() {
        if let table = OpenHoursDownloader.table {
            super.data = table
            super.header = ["Day", "From", "Till", "From", "Till"]
        }
    }
    
    func refreshTableView() {
        if (!Reachability.isConnectedToNetwork()) {
            return
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            Database.delete("OpenHours", context: SavedVariables.cdh.backgroundContext!)
            OpenHoursDownloader.download()
            self.setTable()
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.endRefreshing()
            })
        })
    }
}
