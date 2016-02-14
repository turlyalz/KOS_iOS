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
        if let uCourseEvents = courseEvents {
            for courseEvent in uCourseEvents {
                var dateTuple: (date: String, time: String) = (date: "", time: "")
                if let startDate = courseEvent.startDate {
                    dateTuple = formatDateString(startDate)
                }
                var totalCap = ""
                if let occ = courseEvent.occupied, cap = courseEvent.capacity {
                    totalCap += occ + "/" + cap
                }
                let array = [dateTuple.date, dateTuple.time, unwrap(courseEvent.room), totalCap, unwrap(courseEvent.cancelDeadline)]
                super.data.append(array)
            }
        }
        super.header = ["Date", "Time", "Place", "Occ/Cap", "Cancel deadline"]
        super.sizes = [6.0, 8.5, 7.5, 7.5, 6.0]
    }
    
    func unwrap(value: String?) -> String {
        var result: String = ""
        if let val = value {
            result = val
        }
        return result
    }

}
