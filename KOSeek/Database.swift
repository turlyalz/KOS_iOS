//
//  Database.swift
//  KOSeek
//
//  Created by Alzhan on 12.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: Database
class Database {
    
    private init(){ }

    class func addNewPerson(firstName: String?, lastName: String?, username: String?, email: String?, personalNumber: String?) {
        let entityDescription = NSEntityDescription.entityForName("Person", inManagedObjectContext: SavedVariables.context)
        let user = Person(entity: entityDescription!, insertIntoManagedObjectContext: SavedVariables.context)
        user.firstName = firstName
        user.lastName = lastName
        user.username = username
        user.email = email
        user.personalNumber = personalNumber
        do {
            try SavedVariables.context.save()
        }
        catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func getPersonBy(username username: String) -> Person? {
        let request = NSFetchRequest(entityName: "Person")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "username == %@", username)
        do {
            let results = try SavedVariables.context.executeFetchRequest(request)
            if results.count > 0 {
                return results[0] as? Person
            }
        }
        catch let error as NSError {
            debugPrint(error)
        }
        return nil
    }
    
    // Delete all data from database.
    class func delete() {
        delete("Person")
        delete("Subject")
        delete("Semester")
        delete("SavedVariables")
    }
    
    private class func delete(entity: String) {
        let coord = SavedVariables.appDel.persistentStoreCoordinator
        let fetchRequest = NSFetchRequest(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try coord.executeRequest(deleteRequest, withContext: SavedVariables.context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func getSavedVariables() -> SavedVariablesContent {
        let request = NSFetchRequest(entityName: "SavedVariables")
        request.returnsObjectsAsFaults = false
        do {
            let results = try SavedVariables.context.executeFetchRequest(request)
            if results.count > 0 {
                let res = results[0] as! NSManagedObject
                let username = res.valueForKey("username") as! String
                let currentSemester = res.valueForKey("currentSemester") as! String
                return (username, currentSemester: currentSemester)
            }
        }
        catch let error as NSError {
            debugPrint(error)
        }
        
        return (nil, nil)
    }
    
    class func setSavedVariables(username: String, currentSemester: String) {
        let SV = NSEntityDescription.insertNewObjectForEntityForName("SavedVariables", inManagedObjectContext: SavedVariables.context)
        SV.setValue(username, forKey: "username")
        SV.setValue(currentSemester, forKey: "currentSemester")
        do {
            try SavedVariables.context.save()
        }
        catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func addNewSemester(name: String?, id: String?) {
        let entityDescription = NSEntityDescription.entityForName("Semester", inManagedObjectContext: SavedVariables.context)
        let semester = Semester(entity: entityDescription!, insertIntoManagedObjectContext: SavedVariables.context)
        semester.name = name
        semester.id = id
        do {
            try SavedVariables.context.save()
        }
        catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func getSemesters() -> [Semester]? {
        let request = NSFetchRequest(entityName: "Semester")
        request.returnsObjectsAsFaults = false
        do {
            let results = try SavedVariables.context.executeFetchRequest(request)
            if results.count > 0 {
                return results as? [Semester]
            }
        }
        catch let error as NSError {
            debugPrint(error)
        }
        return nil
    }
    
    class func getSubjectsBy(semester semester: String) -> [Subject]? {
        let request = NSFetchRequest(entityName: "Subject")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "semester == %@", semester)
        do {
            let results = try SavedVariables.context.executeFetchRequest(request)
            if results.count > 0 {
                return results as? [Subject]
            }
        }
        catch let error as NSError {
            debugPrint(error)
        }
        return nil
    }
    
    class func getSubjectsBy(code code: String) -> [Subject]? {
        let request = NSFetchRequest(entityName: "Subject")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "code == %@", code)
        do {
            let results = try SavedVariables.context.executeFetchRequest(request)
            if results.count > 0 {
                return results as? [Subject]
            }
        }
        catch let error as NSError {
            debugPrint(error)
        }
        return nil
    }
    
    class func addNewSubject(code: String?, name: String?, completed: NSNumber?, credits: String?, semester: String?) {
        let entityDescription = NSEntityDescription.entityForName("Subject", inManagedObjectContext: SavedVariables.context)
        let subject = Subject(entity: entityDescription!, insertIntoManagedObjectContext: SavedVariables.context)
        subject.code = code
        subject.name = name
        subject.completed = completed
        subject.credits = credits
        subject.semester = semester
        do {
            try SavedVariables.context.save()
        }
        catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func changeSubjectByCode(code: String?, name: String?, completed: NSNumber?, credits: String?, semester: String?) {
        print("Trying to change subject: \(code), \(name), \(credits)")
        if let _ = code {
            let subjects = getSubjectsBy(code: code!)
            if let subjs = subjects {
                for subject in subjs {
                    if let _ = name {
                        subject.name = name
                    }
                    if let _ = completed {
                        subject.completed = completed
                    }
                    if let _ = credits {
                        subject.credits = credits
                    }
                    if let _ = semester {
                        subject.semester = semester
                    }
                }
                do {
                    try SavedVariables.context.save()
                }
                catch let error as NSError {
                    debugPrint(error)
                }
            }
        }
    }
    
}

