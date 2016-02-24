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
            super.header = openHoursHeader
        }
    }
    
    func refreshTableView() {
        if (!Reachability.isConnectedToNetwork()) {
            self.endRefreshing()
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
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView.numberOfRowsInSection(section) == 0 {
            tableView.scrollEnabled = true
            return nil
        }
        return super.tableView(tableView, viewForFooterInSection: section)
    }
}
