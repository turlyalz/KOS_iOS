//
//  Exam+CoreDataProperties.swift
//  KOSeek
//
//  Created by Alzhan on 14.02.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Exam {

    @NSManaged var name: String?
    @NSManaged var capacity: String?
    @NSManaged var occupied: String?
    @NSManaged var startDate: String?
    @NSManaged var room: String?
    @NSManaged var cancelDeadline: String?
    @NSManaged var signinDeadline: String?
    @NSManaged var termType: String?
    @NSManaged var subject: String?

}
