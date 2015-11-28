//
//  SlotTableViewCell.swift
//  KOSeek
//
//  Created by Alzhan on 27.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class SlotTableViewCell: UITableViewCell {

    private let times = [1: "7:30", 2: "9:00", 3: "9:15", 4: "10:45", 5: "11:00", 6: "12:30", 7: "12:45", 8: "14:15", 9: "14:30", 10: "16:00", 11: "16:15", 12: "17:45", 13: "18:00", 14: "19:30", 15: "19:45", 16: "21:15"]
    
    var row: Int = -1
    var timetableSlots: [TimetableSlot]? {
        didSet {
            setSlots()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setSlots() {
        let timeLabel = UILabel(frame: CGRect(x: 5, y: 10, width: 60, height: 30))
        timeLabel.text = times[row+1]
        self.addSubview(timeLabel)
        guard let slots = timetableSlots else {
            return
        }
        for slot in slots {
            guard let firstHour = slot.firstHour, let duration = slot.duration else {
                continue
            }
            let firstHourInt = Int(firstHour)
            let durationInt = Int(duration)
            if firstHourInt-1 == row || (firstHourInt-1 < row && firstHourInt+durationInt-1 > row) {
                guard let day = slot.day else {
                    continue
                }
                if day == 0 {
                    continue
                }
                let dayInt = Int(day)
                let imageView = UIView(frame: CGRect(x: 60+CGFloat(dayInt-1)*(screenSize.width-60)/6, y: 0, width: (screenSize.width-60)/6-15, height: 44))
                let subjectLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 30, height: 40))
                subjectLabel.text = slot.subject
                subjectLabel.numberOfLines = 0
                subjectLabel.font = UIFont.systemFontOfSize(10)
                imageView.addSubview(subjectLabel)
                if slot.type == "TUTORIAL" {
                    imageView.backgroundColor = UIColor.greenColor()
                }
                if slot.type == "LECTURE" {
                    imageView.backgroundColor = UIColor.yellowColor()
                }
                self.addSubview(imageView)
            }
        }
    }

}
