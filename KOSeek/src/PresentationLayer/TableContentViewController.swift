//
//  TableContentViewController.swift
//  KOSeek
//
//  Created by Alzhan on 03.02.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//

import UIKit

/// Common class for view controllers with table content (drawing separators) 
class TableContentViewController: MainTableViewController {
    
    /// Table data
    var data: [[String]] = []
    
    /// Header strings
    var header: [String] = []
    var sizes = [CGFloat](count: 5, repeatedValue: 7.0)
    var offsets = [CGFloat](count: 5, repeatedValue: 8.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if array.count != sizes.count || array.count != offsets.count {
            print("Warning: sizes and offsets counts of row must be the same as array count!")
        }
        let view = UITableViewCell()
        view.selectionStyle = UITableViewCellSelectionStyle.None
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
                    make.left.equalTo(view).offset(offsets[index])
                } else {
                    make.left.equalTo(rightPoint).offset(offsets[index])
                }
                make.width.equalTo(view).dividedBy(sizes[index])
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
