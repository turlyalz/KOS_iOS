//
//  SemesterViewController.swift
//  KOSeek
//
//  Created by Alzhan on 27.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class SemesterViewController: MainTableViewController {

    var subjects: [Subject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentSemester = SavedVariables.currentSemester, subj = Database.getSubjectsBy(semester: currentSemester, context: SavedVariables.cdh.managedObjectContext) else {
            return
        }
        subjects = subj
        self.title = SavedVariables.semesterIDNameDict[currentSemester]
        subjects.sortInPlace({ $0.0.code < $0.1.code })
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let subject = subjects[indexPath.row]
        let subjectCodeLabel = UILabel()
        subjectCodeLabel.text = subject.code
        subjectCodeLabel.numberOfLines = 2
        subjectCodeLabel.font = .systemFontOfSize(14)
        subjectCodeLabel.textColor = .blackColor()
        cell.addSubview(subjectCodeLabel)
        subjectCodeLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(cell).offset(10)
            make.width.equalTo(cell).dividedBy(5)
            make.height.equalTo(cell)
        }
        let subjectNameLabel = UILabel()
        subjectNameLabel.text = subject.name
        subjectNameLabel.numberOfLines = 2
        subjectNameLabel.font = .systemFontOfSize(15)
        subjectNameLabel.textColor = .blackColor()
        subjectNameLabel.textAlignment = NSTextAlignment.Center
        cell.addSubview(subjectNameLabel)
        subjectNameLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(subjectCodeLabel.snp_right).offset(6)
            make.width.equalTo(cell).multipliedBy(20.5/35.0)
            make.height.equalTo(cell)
        }
        let subjectCreditsLabel = UILabel()       
        subjectCreditsLabel.text = subject.credits
        subjectCreditsLabel.font = .systemFontOfSize(15)
        subjectCreditsLabel.textColor = .blackColor()
        subjectCreditsLabel.textAlignment = NSTextAlignment.Center
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
