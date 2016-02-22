//
//  Subject+CoreDataProperties.swift
//  KOSeek
//
//  Created by Alzhan on 15.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Subject {

    @NSManaged var code: String?
    @NSManaged var completed: NSNumber?
    @NSManaged var name: String?
    @NSManaged var credits: String?
    @NSManaged var completion: String?
    @NSManaged var season: String?
    @NSManaged var range: String?
    @NSManaged var specification: String?
    @NSManaged var lecturesContents: String?
    @NSManaged var tutorialsContents: String?
    @NSManaged var semester: Semester?

}
