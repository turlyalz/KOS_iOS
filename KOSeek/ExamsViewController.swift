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
            self.exams = []
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
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
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        dropdownMenuView?.cellHeight = DropdownMenuViewCellHeight
        if dropdownMenuView?.getShown() == true {
            dropdownMenuView?.hideMenu()
            dropdownMenuView?.setShown(false)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exams.count
    }
    
    func drawHSeparator(cell: UITableViewCell, leftLabel: UILabel) -> ConstraintItem {
        let hLine = UIView()
        hLine.backgroundColor = .grayColor()
        cell.addSubview(hLine)
        hLine.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(leftLabel.snp_right).offset(10)
            make.width.equalTo(0.7)
            make.height.equalTo(cell)
        }
        return hLine.snp_right
    }
    
    func setLabelParameters(label: UILabel, text: String?) {
        label.text = text
        label.font = .systemFontOfSize(13)
        label.textColor = .blackColor()
        label.textAlignment = .Center
        label.numberOfLines = 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableView.scrollEnabled = true
        let cell = UITableViewCell()
        let exam = exams[indexPath.row]
        let startDateLabel = UILabel()
        var dateTuple: (date: String, time: String) = (date: "", time: "")
        if let startDate = exam.startDate {
            dateTuple = formatDateString(startDate)
            setLabelParameters(startDateLabel, text: dateTuple.date)
            cell.addSubview(startDateLabel)
            startDateLabel.snp_remakeConstraints { (make) -> Void in
                make.left.equalTo(cell).offset(8)
                make.width.equalTo(cell).dividedBy(7)
                make.height.equalTo(cell)
            }
        }
      
        var rightPoint = drawHSeparator(cell, leftLabel: startDateLabel)
        
        let startTimeLabel = UILabel()
        setLabelParameters(startTimeLabel, text: dateTuple.time)
        cell.addSubview(startTimeLabel)
        startTimeLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(rightPoint).offset(8)
            make.width.equalTo(cell).dividedBy(8.5)
            make.height.equalTo(cell)
        }
        
        rightPoint = drawHSeparator(cell, leftLabel: startTimeLabel)
        
        let roomLabel = UILabel()
        setLabelParameters(roomLabel, text: exam.room)
        cell.addSubview(roomLabel)
        roomLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(rightPoint).offset(8)
            make.width.equalTo(cell).dividedBy(8)
            make.height.equalTo(cell)
        }

        rightPoint = drawHSeparator(cell, leftLabel: roomLabel)

        let capacityLabel = UILabel()
        if let _ = exam.occupied, _ = exam.capacity {
            setLabelParameters(capacityLabel, text: exam.occupied! + "/" + exam.capacity!)
        }
        cell.addSubview(capacityLabel)
        capacityLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(rightPoint).offset(8)
            make.width.equalTo(cell).dividedBy(8)
            make.height.equalTo(cell)
        }
        
        rightPoint = drawHSeparator(cell, leftLabel: capacityLabel)
/*
        let cancelDeadlineLabel = UILabel()
        dateTuple = (date: "", time: "")
        if let cancelDeadline = exam.cancelDeadline {
            dateTuple = formatDateString(cancelDeadline)
            print(dateTuple)
            setLabelParameters(cancelDeadlineLabel, text: dateTuple.date)
            cell.addSubview(cancelDeadlineLabel)
            startDateLabel.snp_remakeConstraints { (make) -> Void in
                make.left.equalTo(rightPoint).offset(8)
                make.width.equalTo(cell).dividedBy(7.5)
                make.height.equalTo(cell)
            }
        }*/
  
        return cell
    }
    
    
}

