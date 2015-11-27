//
//  SlotTableViewCell.swift
//  KOSeek
//
//  Created by Alzhan on 27.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class SlotTableViewCell: UITableViewCell {

    var timetableSlot: TimetableSlot? {
        didSet {
            let imageName = "search.jpg"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(frame: CGRect(x: 20, y: 12, width: 12, height: 12))
            imageView.image = image
            self.backgroundColor = .blackColor()
            self.addSubview(imageView)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
