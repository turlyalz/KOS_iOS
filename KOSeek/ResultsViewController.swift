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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self
            menuButton.action = "menuButtonPressed"
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("menuButtonPressed"))
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("menuButtonPressed"))
            rightSwipe.direction = .Right
            leftSwipe.direction = .Left
            self.view.addGestureRecognizer(rightSwipe)
            self.view.addGestureRecognizer(leftSwipe)
        }
        
        semesterIDNameDict = SavedVariables.semesterIDNameDict.sort({$0.0 < $1.0})
        for (_, semester) in semesterIDNameDict {
            semesters.append(semester)
        }
        updateSemesterNumber(semesters.count)
        
        setupDropdownMenu()
        let firstSemester = semesterIDNameDict.first!
        updateActualSubjects(firstSemester.0)
    }
    
    func menuButtonPressed() {
        if dropdownMenuView?.getShown() == true {
            dropdownMenuView?.hideMenu()
            dropdownMenuView?.setShown(false)
        }
        UIApplication.sharedApplication().sendAction("revealToggle:", to: self.revealViewController(), from: self, forEvent: nil)
    }
    
    func setupDropdownMenu() {
        dropdownMenuView = BTNavigationDropdownMenu(title: semesters.first!, items: semesters, navController: self.navigationController)
        dropdownMenuView?.cellHeight = DropdownMenuView.cellHeight
        dropdownMenuView?.cellBackgroundColor =  DropdownMenuView.cellBackgroundColor
        dropdownMenuView?.cellSelectionColor = DropdownMenuView.cellSelectionColor
        dropdownMenuView?.cellTextLabelColor = DropdownMenuView.cellTextLabelColor
        dropdownMenuView?.arrowPadding = DropdownMenuView.arrowPadding
        dropdownMenuView?.animationDuration = DropdownMenuView.animationDuration
        dropdownMenuView?.maskBackgroundColor = DropdownMenuView.maskBackgroundColor
        dropdownMenuView?.maskBackgroundOpacity = DropdownMenuView.maskBackgroundOpacity
        dropdownMenuView?.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
            let semester = self.semesterIDNameDict[indexPath].0
            self.updateActualSubjects(semester)
        }
        self.navigationItem.titleView = dropdownMenuView
    }
    
    override func viewDidAppear(animated: Bool) {
        SavedVariables.sideMenuViewController?.view.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    var actualSubjects: [Subject] = []
    
    func updateActualSubjects(semester: String) {
        if let subj = Database.getSubjectsBy(semester: semester) {
            //print(subj)
            actualSubjects = subj
            actualSubjects.sortInPlace({ $0.0.code < $0.1.code })
            tableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actualSubjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let subject = actualSubjects[indexPath.row]
        
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
        dropdownMenuView?.cellHeight = DropdownMenuView.cellHeight
        if dropdownMenuView?.getShown() == true {
            dropdownMenuView?.hideMenu()
            dropdownMenuView?.setShown(false)
        }
        tableView.reloadData()
    }
    
}

