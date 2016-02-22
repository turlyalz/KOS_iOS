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
        super.data = fromExamsToData(courseEvents)
        super.header = examHeader
        super.sizes = [6.0, 8.5, 7.5, 7.5, 6.0]
        makePullToRefresh("refreshTableView")
    }
       
    func refreshTableView() {
        if (!Reachability.isConnectedToNetwork()) {
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
