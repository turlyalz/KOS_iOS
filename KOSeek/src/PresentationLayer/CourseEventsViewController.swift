//
//  ResultsViewController.swift
//  KOSeek
//
//  Created by Alzhan on 14.02.16.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class CourseEventsViewController: TableContentViewController {
    private var courseEvents: [Exam]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseEvents = Database.getCourseEvents(SavedVariables.cdh.managedObjectContext)
        
        var header = examHeader
        header.removeLast()
        header.insert(NSLocalizedString("Subject", comment: "Subject"), atIndex: 0)
        super.data = fromExamsToData(courseEvents, courseEvents: true)
        super.header = header
        super.sizes = [5.7, 5.5, 9.0, 8.2, 6.2]
        makePullToRefresh("refreshTableView")
    }
       
    func refreshTableView() {
        if (!Reachability.isConnectedToNetwork()) {
            self.endRefreshing()
            return
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            Database.deleteObjects("Exam", context: SavedVariables.cdh.backgroundContext!, predicate: NSPredicate(format: "termType == %@", "COURSE_EVENT"))
            KOSAPI.downloadAllCourseEvents(SavedVariables.cdh.backgroundContext!)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.endRefreshing()
            })
        })
    }
}
