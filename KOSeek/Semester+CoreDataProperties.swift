//
//  Semester+CoreDataProperties.swift
//  KOSeek
//
//  Created by Alzhan on 19.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Semester {

    @NSManaged var name: String?
    @NSManaged var id: String?

}
