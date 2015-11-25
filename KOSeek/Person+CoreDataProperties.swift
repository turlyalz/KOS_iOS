//
//  Person+CoreDataProperties.swift
//  KOSeek
//
//  Created by Alzhan on 23.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Person {

    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var isTeacher: NSNumber?
    @NSManaged var lastName: String?
    @NSManaged var personalNumber: String?
    @NSManaged var username: String?

}