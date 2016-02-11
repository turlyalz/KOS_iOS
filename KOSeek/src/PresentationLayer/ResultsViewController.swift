//
//  ResultsViewController.swift
//  KOSeek
//
//  Created by Alzhan on 28.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class ResultsViewController: DropdownMenuViewController {

    private var semesterIDNameDict: [(String, String)] = []
    private var semesters: [String] = []
    private var subjects: [Subject] = []
    private var semesterCreditsEnrolled: Int = 0
    private var semesterCreditsObtained: Int = 0
    private var totalCreditsEnrolled: Int = 0
    private var totalCreditsObtained: Int = 0
    private var selectedSemester: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        semesterIDNameDict = SavedVariables.semesterIDNameDict.sort({$0.0 < $1.0})
        for (_, semester) in semesterIDNameDict {
            semesters.append(semester)
        }
        updateSemesterNumber(semesters.count)
        super.dropdownData = semesters
        super.didSelectItemHandler = { indexPath in
            self.didSelectItem(indexPath)
        }
        super.setupDropdownMenu()
        if let firstSemester = semesterIDNameDict.first {
            updateSubjects(firstSemester.0)
            selectedSemester = firstSemester.0
        }
        setTotalCreditsValues()
        makePullToRefresh("refreshTableView")
    }
    
    func setTotalCreditsValues() {
        guard let semesters = Database.getSemestersFrom(context: SavedVariables.cdh.managedObjectContext) else {
            return
        }
        for semester in semesters {
            guard let id = semester.id, subj = Database.getSubjectsBy(semesterID: id, context: SavedVariables.cdh.managedObjectContext) else {
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
    
    func didSelectItem(indexPath: Int) {
        let semester = self.semesterIDNameDict[indexPath].0
        selectedSemester = semester
        self.updateSubjects(semester)
    }
    
    func updateSubjects(semester: String) {
        if let subj = Database.getSubjectsBy(semesterID: semester, context: SavedVariables.cdh.managedObjectContext) {
            print(subj.last?.code)
            subjects = subj
            semesterCreditsEnrolled = 0
            semesterCreditsObtained = 0
            for subject in subjects {
                guard let credits = subject.credits, creditsInt = Int(credits) else {
                    continue
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
    
    func refreshTableView() {
        if (!Reachability.isConnectedToNetwork()) {
            return
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            Database.deleteObjects("Subject", context: SavedVariables.cdh.backgroundContext!, predicate: NSPredicate(format: "semester.id == %@", self.selectedSemester))
            KOSAPI.downloadEnrolledCourses(SavedVariables.cdh.backgroundContext!, semesterID: self.selectedSemester)
            KOSAPI.downloadSubjectsInfo(SavedVariables.cdh.backgroundContext!)
            guard let subj = Database.getSubjectsBy(semesterID: self.selectedSemester, context: SavedVariables.cdh.backgroundContext!) else {
                return
            }
            self.subjects = subj
            self.subjects.sortInPlace({ $0.0.code < $0.1.code })
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.endRefreshing()
            })
        })
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
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
        labelLeft.textAlignment = .Center
        
        labelRight.numberOfLines = 0
        labelRight.text = "Total enrolled: " + String(totalCreditsEnrolled) + "\nTotal obtained: " + String(totalCreditsObtained)
        labelRight.textColor = .whiteColor()
        labelRight.font = UIFont.systemFontOfSize(14)
        labelRight.textAlignment = .Center
        
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
        let subjectCodeLabel = UILabel()
        setLabelParameters(subjectCodeLabel, text: subject.code, fontSize: 14)
        cell.addSubview(subjectCodeLabel)
        subjectCodeLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(cell).offset(10)
            make.width.equalTo(cell).dividedBy(5)
            make.height.equalTo(cell)
        }
        let subjectNameLabel = UILabel()
        setLabelParameters(subjectNameLabel, text: subject.name)
        cell.addSubview(subjectNameLabel)
        subjectNameLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(subjectCodeLabel.snp_right).offset(6)
            make.width.equalTo(cell).multipliedBy(20.5/35.0)
            make.height.equalTo(cell)
        }
        let subjectCreditsLabel = UILabel()
        setLabelParameters(subjectCreditsLabel, text: subject.credits, numberOfLines: 1)
        cell.addSubview(subjectCreditsLabel)
        subjectCreditsLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(subjectNameLabel.snp_right).offset(6)
            make.width.equalTo(cell).dividedBy(7.5)
            make.height.equalTo(cell)
        }
        if subject.completed == 1 {
            cell.backgroundColor = SlotTutorialColor
        }
        return cell
    }    
}

