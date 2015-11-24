//
//  SavedVariables.swift
//  KOSeek
//
//  Created by Alzhan on 30.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import Foundation
import CoreData

class SavedVariables {
    static var sideMenuViewController: SideMenuController?
    static var username: String?
    static var password: String?
    static var semesterIDNameDict: [String:String] = [:]
    static var currentSemester: String?
    static var subjectCodes: [String] = []
    static var coreDataStack: CoreDataStack?
    
    private init(){ }

    class func resetAll() {
        username = nil
        password = nil
        semesterIDNameDict = [:]
        currentSemester = nil
        subjectCodes = []
    }
}