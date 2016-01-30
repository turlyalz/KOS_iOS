//
//  NSDateExtension.swift
//  KOSeek
//
//  Created by Alzhan on 05.12.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import Foundation

/// Extension for comparing two NSDate objects
extension NSDate {
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        return isGreater
    }
    func isLessThanDate(dateToCompare : NSDate) -> Bool {
        var isLess = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        return isLess
    }
}

