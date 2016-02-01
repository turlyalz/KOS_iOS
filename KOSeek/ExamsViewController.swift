//
//  ResultsViewController.swift
//  KOSeek
//
//  Created by Alzhan on 28.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class ExamsViewController: MainTableViewController {
    
    var selectedIndex: Int = 0
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
        self.subjects.append("Please select subject")
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
                if indexPath == self.selectedIndex {
                    return
                }
                self.selectedIndex = indexPath
                self.presentViewController(self.alertLoadingView, animated: true, completion: nil)
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                    self.didSelectSubject(self.subjects[indexPath])
                })
            }
            self.navigationItem.titleView = dropdownMenuView
        }
    }
    
    func didSelectSubject(subjectCode: String) {
        let exams: [Exam]? = KOSAPI.downloadExamBy(subjectCode)
        if exams != nil  {
            self.exams = exams!
        } else {
            print("No exams")
            self.exams = []
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.alertLoadingView.dismissViewControllerAnimated(true, completion: nil)
            if exams == nil {
                createAlertView("", text: "No available exams", viewController: self, handlers: ["OK": {_ in }])
            }
            return
        })
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
    
    func drawHSeparator(cell: UIView, leftLabel: UILabel) -> ConstraintItem {
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
    
    func setLabelParameters(label: UILabel, text: String?, color: UIColor = .blackColor()) {
        label.text = text
        label.font = .systemFontOfSize(13)
        label.textColor = color
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
                make.width.equalTo(cell).dividedBy(6)
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
            make.width.equalTo(cell).dividedBy(7)
            make.height.equalTo(cell)
        }
        
        rightPoint = drawHSeparator(cell, leftLabel: capacityLabel)

        let signinDeadlineLabel = UILabel()
        dateTuple = (date: "", time: "")
        if let cancelDeadline = exam.signinDeadline {
            dateTuple = formatDateString(cancelDeadline)
            setLabelParameters(signinDeadlineLabel, text: dateTuple.date)
            cell.addSubview(signinDeadlineLabel)
            signinDeadlineLabel.snp_remakeConstraints { (make) -> Void in
                make.left.equalTo(rightPoint).offset(8)
                make.width.equalTo(cell).dividedBy(6)
                make.height.equalTo(cell)
            }
        }
  
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView()
        view.backgroundColor = BGHeaderColor
        let startDateLabel = UILabel()
        setLabelParameters(startDateLabel, text: "Date", color: .whiteColor())
        view.addSubview(startDateLabel)
        startDateLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(8)
            make.width.equalTo(view).dividedBy(6)
            make.height.equalTo(view)
        }

        var rightPoint = drawHSeparator(view, leftLabel: startDateLabel)
        
        let startTimeLabel = UILabel()
        setLabelParameters(startTimeLabel, text: "Time", color: .whiteColor())
        view.addSubview(startTimeLabel)
        startTimeLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(rightPoint).offset(8)
            make.width.equalTo(view).dividedBy(8.5)
            make.height.equalTo(view)
        }
        
        rightPoint = drawHSeparator(view, leftLabel: startTimeLabel)
        
        let roomLabel = UILabel()
        setLabelParameters(roomLabel, text: "Place", color: .whiteColor())
        view.addSubview(roomLabel)
        roomLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(rightPoint).offset(8)
            make.width.equalTo(view).dividedBy(8)
            make.height.equalTo(view)
        }
        
        rightPoint = drawHSeparator(view, leftLabel: roomLabel)
        
        let capacityLabel = UILabel()
        setLabelParameters(capacityLabel, text: "Occ/Cap", color: .whiteColor())

        view.addSubview(capacityLabel)
        capacityLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(rightPoint).offset(8)
            make.width.equalTo(view).dividedBy(7)
            make.height.equalTo(view)
        }
        
        rightPoint = drawHSeparator(view, leftLabel: capacityLabel)
        
        let cancelDeadlineLabel = UILabel()
        setLabelParameters(cancelDeadlineLabel, text: "Deadline (total)", color: .whiteColor())
        view.addSubview(cancelDeadlineLabel)
        cancelDeadlineLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(rightPoint).offset(8)
            make.width.equalTo(view).dividedBy(6)
            make.height.equalTo(view)
        }
      
        return view
    }
    
    
}

