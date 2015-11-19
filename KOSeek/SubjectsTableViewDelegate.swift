//
//  SubjectsTableViewDelegate.swift
//  KOSeek
//
//  Created by Alzhan on 19.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class SubjectsTableViewDelegate: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var actualSubjects: [Subject] = []
    
    func updateActualSubjects(semester: String) {
        if let subj = Database.getSubjectsBy(semester: semester) {
            actualSubjects = subj
            actualSubjects.sortInPlace({ $0.0.code < $0.1.code })
            reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actualSubjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        
        return cell
    }
    
    override func reloadData() {
        super.reloadData()
    }
}
