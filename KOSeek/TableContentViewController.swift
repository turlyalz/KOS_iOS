//
//  TableContentViewController.swift
//  KOSeek
//
//  Created by Alzhan on 03.02.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class TableContentViewController: MainTableViewController {
    
    var data: [[String]] = []
    var header: [String] = []
    var sizes: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setLabelParameters(label: UILabel, text: String?, textColor: UIColor = .blackColor(), fontSize: CGFloat = 14, numberOfLines: Int = 2) {
        label.text = text
        label.font = .systemFontOfSize(fontSize)
        label.textColor = textColor
        label.textAlignment = .Center
        label.numberOfLines = numberOfLines
    }
    
    func drawHSeparator(view: UIView, leftView: UIView) -> ConstraintItem {
        let hLine = UIView()
        hLine.backgroundColor = .grayColor()
        view.addSubview(hLine)
        hLine.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(leftView.snp_right).offset(10)
            make.width.equalTo(0.7)
            make.height.equalTo(view)
        }
        return hLine.snp_right
    }
    
    private func getRow(array: [String], isHeader: Bool) -> UITableViewCell {
        if array.count != sizes.count {
            sizes = []
        }
        let view = UITableViewCell()
        if isHeader {
            view.backgroundColor = BGHeaderColor
        }
        var rightPoint = ConstraintItem(object: self, attributes: ConstraintAttributes.allZeros)
        for index in 0...array.count-1 {
            let label = UILabel()
            if isHeader {
                setLabelParameters(label, text: array[index], textColor: .whiteColor())
            } else {
                setLabelParameters(label, text: array[index])
            }
            view.addSubview(label)
            label.snp_remakeConstraints { (make) -> Void in
                if index == 0 {
                    make.left.equalTo(view).offset(8)
                } else {
                    make.left.equalTo(rightPoint).offset(8)
                }
                if sizes.count != 0 {
                    make.width.equalTo(view).dividedBy(sizes[index])
                } else {
                    make.width.equalTo(view).multipliedBy(1.0/7.0)
                }
                make.height.equalTo(view)
            }
            if index != array.count-1 {
                rightPoint = drawHSeparator(view, leftView: label)
            }
        }
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if header.count == 0 {
            return 0
        }
        return 40
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return getRow(header, isHeader: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return getRow(data[indexPath.row], isHeader: false)
    }
}
