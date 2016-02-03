//
//  StudentOfficeViewController.swift
//  KOSeek
//
//  Created by Alzhan on 01.02.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//

import Foundation

class StudentOfficeViewController: MainTableViewController {
    private var table: [[String]] = [[]]
    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let table = OpenHoursDownloader.table {
            self.table = table
            print(table)
        }
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return table.count
    }
    
    func setLabelParameters(label: UILabel, text: String?, fontSize: CGFloat = 14, numberOfLines: Int = 2) {
        label.text = text
        label.font = .systemFontOfSize(fontSize)
        label.textColor = .blackColor()
        label.textAlignment = .Center
        label.numberOfLines = numberOfLines
    }
    
    func drawHSeparator(cell: UIView, leftView: UIView) -> ConstraintItem {
        let hLine = UIView()
        hLine.backgroundColor = .grayColor()
        cell.addSubview(hLine)
        hLine.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(leftView.snp_right).offset(10)
            make.width.equalTo(0.7)
            make.height.equalTo(cell)
        }
        return hLine.snp_right
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var rightPoint = ConstraintItem(object: self, attributes: ConstraintAttributes.allZeros)
        for column in -1...table[indexPath.row].count-1 {
            let label = UILabel()
            if column == -1 {
                setLabelParameters(label, text: days[indexPath.row])
            } else {
                setLabelParameters(label, text: table[indexPath.row][column])
            }
            cell.addSubview(label)
            label.snp_remakeConstraints { (make) -> Void in
                if column == -1 {
                    make.left.equalTo(cell).offset(8)
                } else {
                    make.left.equalTo(rightPoint).offset(8)
                }
                make.width.equalTo(cell).dividedBy(6.5)
                make.height.equalTo(cell)
            }
            if column != table[indexPath.row].count-1 {
                rightPoint = drawHSeparator(cell, leftView: label)
            }
        }
        return cell
    }
}
