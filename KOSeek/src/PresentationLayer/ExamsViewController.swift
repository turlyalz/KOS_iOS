//
//  ResultsViewController.swift
//  KOSeek
//
//  Created by Alzhan on 28.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class ExamsViewController: DropdownMenuViewController {
    
    private var selectedIndex: Int = 0
    private var subjects: [String] = []
    private let alertLoadingView = UIAlertController(title: "", message: "Downloading. Please Wait.", preferredStyle: UIAlertControllerStyle.Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let semester = SavedVariables.currentSemester, subs = Database.getSubjectsBy(semesterID: semester, context: SavedVariables.cdh.managedObjectContext) else {
            return
        }
        for subject in subs {
            if let code = subject.code {
                self.subjects.append(code)
            }
        }
        self.subjects.sortInPlace(<)
        self.subjects.insert("Please select subject", atIndex: 0)
        super.dropdownData = self.subjects
        super.didSelectItemHandler = { indexPath in
            self.didSelectItem(indexPath)
        }
        super.setupDropdownMenu()
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.frame = CGRect(x: 25, y: 30, width: 10, height: 10)
        activityIndicator.startAnimating()
        alertLoadingView.view.addSubview(activityIndicator)
        super.header = examHeader
        super.sizes = [6.0, 8.5, 7.5, 7.5, 6.0]
    }
    
    func didSelectItem(indexPath: Int) {
        if indexPath == self.selectedIndex || indexPath == 0 {
            return
        }
        self.selectedIndex = indexPath
        self.presentViewController(self.alertLoadingView, animated: true, completion: nil)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
            self.didSelectSubject(self.subjects[indexPath])
        })
    }
    
    func didSelectSubject(subjectCode: String) {
        var exams = Database.getExamsBy(subject: subjectCode, context: SavedVariables.cdh.backgroundContext!)
        if exams == nil {
            KOSAPI.downloadExamBy(subjectCode, context: SavedVariables.cdh.backgroundContext!)
            exams = Database.getExamsBy(subject: subjectCode, context: SavedVariables.cdh.backgroundContext!)
        }
        super.data = fromExamsToData(exams)
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.alertLoadingView.dismissViewControllerAnimated(true, completion: nil)
            if super.data.count == 0 {
                createAlertView("", text: "No available exams", viewController: self, handlers: ["OK": {_ in }])
            }
            return
        })
    }
}
