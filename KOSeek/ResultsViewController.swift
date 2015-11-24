//
//  ResultsViewController.swift
//  KOSeek
//
//  Created by Alzhan on 28.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class ResultsViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    var semesterIDNameDict: [(String, String)] = []
    var semesters: [String] = []
    var dropdownMenuView: BTNavigationDropdownMenu?
    var semesterCreditsEnrolled: Int = 0
    var semesterCreditsObtained: Int = 0
    var totalCreditsEnrolled: Int = 0
    var totalCreditsObtained: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self
            menuButton.action = "menuButtonPressed"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        semesterIDNameDict = SavedVariables.semesterIDNameDict.sort({$0.0 < $1.0})
        for (_, semester) in semesterIDNameDict {
            semesters.append(semester)
        }
        updateSemesterNumber(semesters.count)
        
        setupDropdownMenu()
        if let firstSemester = semesterIDNameDict.first {
            updateSubjects(firstSemester.0)
        }
        setTotalCreditsValues()
    }
    
    func menuButtonPressed() {
        if dropdownMenuView?.getShown() == true {
            dropdownMenuView?.hideMenu()
            dropdownMenuView?.setShown(false)
        }
        UIApplication.sharedApplication().sendAction("revealToggle:", to: self.revealViewController(), from: self, forEvent: nil)
    }
    
    func setupDropdownMenu() {
        if let _ = semesters.first {
            dropdownMenuView = BTNavigationDropdownMenu(title: semesters.first!, items: semesters, navController: self.navigationController)
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
                let semester = self.semesterIDNameDict[indexPath].0
                self.updateSubjects(semester)
            }
            self.navigationItem.titleView = dropdownMenuView
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        SavedVariables.sideMenuViewController?.view.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    var subjects: [Subject] = []
    
    func setTotalCreditsValues() {
        guard let semesters = Database.getSemesters() else {
            return
        }
        for semester in semesters {
            guard let id = semester.id, subj = Database.getSubjectsBy(semester: id) else {
                return
            }
            for subject in subj {
                guard let credits = subject.credits, creditsInt = Int(credits) else {
                    return
                }
                totalCreditsEnrolled += creditsInt
                if subject.completed == 1 {
                    totalCreditsObtained += creditsInt
                }
            }
        }
    }
    
    func updateSubjects(semester: String) {
        if let subj = Database.getSubjectsBy(semester: semester) {
            subjects = subj
            semesterCreditsEnrolled = 0
            semesterCreditsObtained = 0
            for subject in subjects {
                guard let credits = subject.credits, creditsInt = Int(credits) else {
                    return
                }
                semesterCreditsEnrolled += creditsInt
                if subject.completed == 1 {
                    semesterCreditsObtained += creditsInt
                }
            }
            subjects.sortInPlace({ $0.0.code < $0.1.code })
            tableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width-30, height: 60))
        let labelLeft: UILabel = UILabel(frame: CGRect(x: 10, y: -5, width: screenSize.width/2-20, height: 60))
        let labelRight: UILabel = UILabel(frame: CGRect(x: screenSize.width/2+10, y: -5, width: screenSize.width/2, height: 60))
        view.backgroundColor = BGHeaderColor
        
        labelLeft.numberOfLines = 0
        labelLeft.text = "Credits enrolled: " + String(semesterCreditsEnrolled) + "\nCredits obtained: " + String(semesterCreditsObtained)
        labelLeft.textColor = .whiteColor()
        labelLeft.font = UIFont.systemFontOfSize(14)
        
        labelRight.numberOfLines = 0
        labelRight.text = "Total enrolled: " + String(totalCreditsEnrolled) + "\nTotal obtained: " + String(totalCreditsObtained)
        labelRight.textColor = .whiteColor()
        labelRight.font = UIFont.systemFontOfSize(14)
        
        view.addSubview(labelLeft)
        view.addSubview(labelRight)
        
        return view
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let subject = subjects[indexPath.row]
        
        let subjectCodeLabel: UILabel = UILabel(frame: CGRect(x: 10, y: 0, width: SubjectCell.subjectCodeWidth, height: SubjectCell.height))
        subjectCodeLabel.text = subject.code
        subjectCodeLabel.numberOfLines = 2
        subjectCodeLabel.font = .systemFontOfSize(14)
        subjectCodeLabel.textColor = .blackColor()
        cell.addSubview(subjectCodeLabel)
        
        let subjectNameLabel: UILabel = UILabel(frame: CGRect(x: SubjectCell.subjectCodeWidth+7, y: 0, width: SubjectCell.subjectNameWidth, height: SubjectCell.height))
        subjectNameLabel.text = subject.name
        subjectNameLabel.numberOfLines = 2
        subjectNameLabel.font = .systemFontOfSize(15)
        subjectNameLabel.textColor = .blackColor()
        subjectNameLabel.textAlignment = NSTextAlignment.Center
        cell.addSubview(subjectNameLabel)
        
        let subjectCreditsLabel: UILabel = UILabel(frame: CGRect(x: SubjectCell.subjectCodeWidth+SubjectCell.subjectNameWidth+7, y: 0, width: SubjectCell.subjectCreditWidth, height: SubjectCell.height))
        subjectCreditsLabel.text = subject.credits
        subjectCreditsLabel.font = .systemFontOfSize(15)
        subjectCreditsLabel.textColor = .blackColor()
        subjectCreditsLabel.textAlignment = NSTextAlignment.Center
        cell.addSubview(subjectCreditsLabel)
        
        if subject.completed == 1 {
            cell.backgroundColor = UIColor(red: 155/255, green: 200/255, blue: 201/255, alpha: 1)
        }
        
        return cell
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateValues()
        dropdownMenuView?.cellHeight = DropdownMenuViewCellHeight
        if dropdownMenuView?.getShown() == true {
            dropdownMenuView?.hideMenu()
            dropdownMenuView?.setShown(false)
        }
        tableView.reloadData()
    }
    
}

