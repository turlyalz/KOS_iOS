//
//  SavedVariables.swift
//  KOSeek
//
//  Created by Alzhan on 30.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import Foundation
import CoreData

/// Static class that storing local data
class SavedVariables {
    static var sideMenuViewController: SideMenuController?
    static var searchViewController: SearchViewController?
    static var cdh: CoreDataHelper = CoreDataHelper()
    static var searchText: String? = nil
    static var username: String?
    static var password: String?
    static var semesterIDNameDict: [String:String] = [:]
    static var currentSemester: String?
    static var canDropDownMenuShow: Bool = false
    
    private init() {}

    class func resetAll() {
        username = nil
        password = nil
        semesterIDNameDict = [:]
        currentSemester = nil
    }
}