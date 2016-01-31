//
//  Exam.swift
//  KOSeek
//
//  Created by Alzhan on 04.12.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import Foundation

class Exam: NSObject {
    let capacity: String?
    let occupied: String?
    let room: String?
    let signinDeadline: String?
    let startDate: String?
    let cancelDeadline: String?
    let termType: String?
    
    init(capacity: String?, occupied: String?, room: String?, signinDeadline: String?, startDate: String?, cancelDeadline: String?, termType: String?) {
        self.capacity = capacity
        self.occupied = occupied
        self.room = room
        self.signinDeadline = signinDeadline
        self.startDate = startDate
        self.cancelDeadline = cancelDeadline
        self.termType = termType
    }
}