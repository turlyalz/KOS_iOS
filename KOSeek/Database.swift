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

class Database {

    private static let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    private static let context = appDel.managedObjectContext
    
    private init(){ }

    class func setProfileContent(firstName: String?, lastName: String?, username: String?, email: String?, personalNumber: String?) {
        let user = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: context)
        user.setValue(firstName, forKey: "firstName")
        user.setValue(lastName, forKey: "lastName")
        user.setValue(username, forKey: "username")
        user.setValue(email, forKey: "email")
        user.setValue(personalNumber, forKey: "personalNumber")
        do {
            try context.save()
        }
        catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func getProfileContent(username: String) -> ProfileContent {
        let request = NSFetchRequest(entityName: "Person")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "username == %@", username)
        do {
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                let res = results[0] as! NSManagedObject
                let firstName = res.valueForKey("firstName") as! String
                let lastName = res.valueForKey("lastName") as! String
                let email = res.valueForKey("email") as! String
                let personalNumber = res.valueForKey("personalNumber") as! String
                return (["First name", "Last name", "Email", "Personal number"], [firstName, lastName, email, personalNumber])
            }
        }
        catch let error as NSError {
            debugPrint(error)
        }
        
        return ([], [])
    }
    
    class func delete() {
        delete("Person")
        delete("Subject")
        delete("Semester")
        delete("SavedVariables")
    }
    
    private class func delete(entity: String) {
        let coord = appDel.persistentStoreCoordinator
        let fetchRequest = NSFetchRequest(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func getSavedVariables() -> SavedVariablesContent {
        let request = NSFetchRequest(entityName: "SavedVariables")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.executeFetchRequest(request)
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
        let SV = NSEntityDescription.insertNewObjectForEntityForName("SavedVariables", inManagedObjectContext: context)
        SV.setValue(username, forKey: "username")
        SV.setValue(currentSemester, forKey: "currentSemester")
        do {
            try context.save()
        }
        catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func addNewSemester(name: String?, id: String?) {
        let entityDescription = NSEntityDescription.entityForName("Semester", inManagedObjectContext: context)
        let semester = Semester(entity: entityDescription!, insertIntoManagedObjectContext: context)
        semester.name = name
        semester.id = id
        do {
            try context.save()
        }
        catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func getSemesters() -> [Semester]? {
        let request = NSFetchRequest(entityName: "Semester")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.executeFetchRequest(request)
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
            let results = try context.executeFetchRequest(request)
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
            let results = try context.executeFetchRequest(request)
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
        let entityDescription = NSEntityDescription.entityForName("Subject", inManagedObjectContext: context)
        let subject = Subject(entity: entityDescription!, insertIntoManagedObjectContext: context)
        subject.code = code
        subject.name = name
        subject.completed = completed
        subject.credits = credits
        subject.semester = semester
        do {
            try context.save()
        }
        catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func changeSubjectByCode(code: String?, name: String?, completed: NSNumber?, credits: String?, semester: String?) {
        if let _ = code {
            let subjects = getSubjectsBy(code: code!)
            print(subjects)
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
                    try context.save()
                }
                catch let error as NSError {
                    debugPrint(error)
                }
            }
        }
    }
    
}
