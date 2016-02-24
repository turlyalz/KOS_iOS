//
//  SubjectDetailsViewController.swift
//  KOSeek
//
//  Created by Alzhan on 21.02.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class SubjectDetailsViewController: MainTableViewController {
    
    var closeSegue: String? = nil
    var code: String = "none"
    private var subject: Subject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = code
        subject = Database.getSubjectsBy(code: code, context: SavedVariables.cdh.managedObjectContext)?.first
        makePullToRefresh("refreshTableView")
    }

    @IBAction func close(sender: AnyObject) {
        guard let segue = closeSegue else {
            return
        }
        performSegueWithIdentifier(segue, sender: self)
    }
    
    
    func refreshTableView() {
        if (!Reachability.isConnectedToNetwork()) {
            self.endRefreshing()
            return
        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            Database.deleteSubjectDetails(code: self.code, context: SavedVariables.cdh.backgroundContext!)
            KOSAPI.downloadSubjectDetails(self.code, context: SavedVariables.cdh.backgroundContext!)
            self.subject = Database.getSubjectsBy(code: self.code, context: SavedVariables.cdh.backgroundContext!)?.first
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.endRefreshing()
            })
        })
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 40
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 40
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel?.font = .systemFontOfSize(13.5)
        cell.textLabel?.textColor = .blackColor()
        cell.textLabel?.textAlignment = NSTextAlignment.Left
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.numberOfLines = 0
        switch (indexPath.row) {
            case 0:
                let leftLabel = UILabel()
                let completion = completionString + ": " + getCompletionAbbr(subject?.completion)
                let season = "\n" + seasonString + ": " + getSeasonAbbr(subject?.season)
                setLabelParameters(leftLabel, text: completion + season, textAlignment: .Left)
                let rightLabel = UILabel()
                var text: String = ""
                if let range = subject?.range {
                    text = rangeString + ": " + range
                }
                if let credits = subject?.credits {
                    text += "\n" + creditsString + ": " + credits
                }
                setLabelParameters(rightLabel, text: text, textAlignment: .Left)
                cell.addSubview(leftLabel)
                leftLabel.snp_remakeConstraints { (make) -> Void in
                    make.left.equalTo(cell).offset(30)
                    make.width.equalTo(cell).dividedBy(2.5)
                    make.height.equalTo(cell)
                }
                cell.addSubview(rightLabel)
                rightLabel.snp_remakeConstraints { (make) -> Void in
                    make.left.equalTo(leftLabel.snp_right).offset(20)
                    make.width.equalTo(cell).dividedBy(2)
                    make.height.equalTo(cell)
            }
            case 1:
                let title = NSMutableAttributedString(string: descriptionString + "\n\n", attributes: titleAttributes)
                if let description = subject?.specification {
                    let text = NSMutableAttributedString(string: description, attributes: textAttributes)
                    title.appendAttributedString(text)
                }
                cell.textLabel?.attributedText = title
            case 2:
                let title = NSMutableAttributedString(string: lecturesContentString + "\n\n", attributes: titleAttributes)
                if let lecturesContent = subject?.lecturesContents {
                    let text = NSMutableAttributedString(string: lecturesContent, attributes: textAttributes)
                    title.appendAttributedString(text)
                }
                cell.textLabel?.attributedText = title
            case 3:
                let title = NSMutableAttributedString(string: tutorialsContentString + "\n\n", attributes: titleAttributes)
                if let tutorialsContent = subject?.tutorialsContents {
                    let text = NSMutableAttributedString(string: tutorialsContent, attributes: textAttributes)
                    title.appendAttributedString(text)
                }
                cell.textLabel?.attributedText = title
            default: break
        }
        return cell
    }

}
