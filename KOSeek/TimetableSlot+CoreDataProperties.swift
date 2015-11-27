//
//  TimetableSlot+CoreDataProperties.swift
//  KOSeek
//
//  Created by Alzhan on 27.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TimetableSlot {

    @NSManaged var type: String?
    @NSManaged var day: NSNumber?
    @NSManaged var firstHour: NSNumber?
    @NSManaged var parity: String?
    @NSManaged var duration: NSNumber?
    @NSManaged var room: String?
    @NSManaged var subject: String?
    @NSManaged var subjectName: String?
    @NSManaged var teacher: String?
    @NSManaged var person: Person
    
}
