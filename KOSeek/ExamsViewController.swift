//
//  ResultsViewController.swift
//  KOSeek
//
//  Created by Alzhan on 28.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class ExamsViewController: MainTableViewController {
    
    var subjects: [String] = []
    var exams: [Exam] = []
    var dropdownMenuView: BTNavigationDropdownMenu?
    let alertLoadingView = UIAlertController(title: "", message: "Downloading. Please Wait.", preferredStyle: UIAlertControllerStyle.Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.childFuncBeforeShowSideMenu =  {
            if self.dropdownMenuView?.getShown() == true {
                self.dropdownMenuView?.hideMenu()
                self.dropdownMenuView?.setShown(false)
            }
        }
        guard let semester = SavedVariables.currentSemester, subjects = Database.getSubjectsBy(semester: semester, context: SavedVariables.cdh.managedObjectContext) else {
            return
        }
        for subject in subjects {
            if let code = subject.code {
                self.subjects.append(code)
            }
        }
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.frame = CGRect(x: 25, y: 30, width: 10, height: 10)
        activityIndicator.startAnimating()
        alertLoadingView.view.addSubview(activityIndicator)
        setupDropdownMenu()
    }
    
    func setupDropdownMenu() {
        if let first = subjects.first {
            dropdownMenuView = BTNavigationDropdownMenu(title: first, items: subjects, navController: self.navigationController)
            dropdownMenuView?.cellHeight = DropdownMenuViewCellHeight
            dropdownMenuView?.cellBackgroundColor =  DropdownMenuView.cellBackgroundColor
            dropdownMenuView?.cellSelectionColor = DropdownMenuView.cellSelectionColor
            dropdownMenuView?.cellTextLabelColor = DropdownMenuView.cellTextLabelColor
            dropdownMenuView?.cellSeparatorColor = DropdownMenuView.cellSeparatorColor
            dropdownMenuView?.arrowPadding = DropdownMenuView.arrowPadding
            dropdownMenuView?.animationDuration = DropdownMenuView.animationDuration
            dropdownMenuView?.maskBackgroundColor = DropdownMenuView.maskBackgroundColor
            dropdownMenuView?.maskBackgroundOpacity = DropdownMenuView.maskBackgroundOpacity
            dropdownMenuView?.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
                self.presentViewController(self.alertLoadingView, animated: true, completion: nil)
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                    self.didSelectSubject(self.subjects[indexPath])
                })
            }
            self.navigationItem.titleView = dropdownMenuView
        }
    }
    
    func didSelectSubject(subjectCode: String) {
        if let exams = KOSAPI.downloadExamBy(subjectCode) {
            self.exams = exams
        } else {
            print("No exams")
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.alertLoadingView.dismissViewControllerAnimated(true, completion: nil)
            return
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        SavedVariables.sideMenuViewController?.view.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateValues()
        dropdownMenuView?.cellHeight = DropdownMenuViewCellHeight
        if dropdownMenuView?.getShown() == true {
            dropdownMenuView?.hideMenu()
            dropdownMenuView?.setShown(false)
        }
    }
    
}

