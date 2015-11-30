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

    class func addPersonTo(context context: NSManagedObjectContext, firstName: String?, lastName: String?, username: String?, email: String?, personalNumber: String?, title: String?) {
        let entityDescription = NSEntityDescription.entityForName("Person", inManagedObjectContext: context)
        let person = Person(entity: entityDescription!, insertIntoManagedObjectContext: context)
        person.firstName = firstName
        person.lastName = lastName
        person.username = username
        person.email = email
        person.personalNumber = personalNumber
        person.title = title
        saveContext(context)
    }
    
    class func getPersonBy(username username: String, context: NSManagedObjectContext) -> Person? {
        let request = NSFetchRequest(entityName: "Person")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "username == %@", username)
        do {
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                return results[0] as? Person
            }
        }
        catch let error as NSError {
            debugPrint(error)
        }
        return nil
    }
    
    class func getPersons(context: NSManagedObjectContext) -> [Person]? {
        let request = NSFetchRequest(entityName: "Person")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                return results as? [Person]
            }
        }
        catch let error as NSError {
            debugPrint(error)
        }
        return nil
    }
    
    // Delete all data from database.
    class func delete(context context: NSManagedObjectContext) {
        delete("Person", context: context)
        delete("Subject", context: context)
        delete("Semester", context: context)
        delete("SavedVariables", context: context)
    }
    
    private class func delete(entity: String, context: NSManagedObjectContext) {
        let coord = SavedVariables.cdh.store.persistentStoreCoordinator
        let fetchRequest = NSFetchRequest(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func getSavedVariablesFrom(context context: NSManagedObjectContext) -> SavedVariablesContent {
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
    
    class func setSavedVariables(context: NSManagedObjectContext, username: String, currentSemester: String) {
        let SV = NSEntityDescription.insertNewObjectForEntityForName("SavedVariables", inManagedObjectContext: context)
        SV.setValue(username, forKey: "username")
        SV.setValue(currentSemester, forKey: "currentSemester")
        saveContext(context)
    }
    
    class func addSemesterTo(context context: NSManagedObjectContext, name: String?, id: String?) {
        let entityDescription = NSEntityDescription.entityForName("Semester", inManagedObjectContext: context)
        let semester = Semester(entity: entityDescription!, insertIntoManagedObjectContext: context)
        semester.name = name
        semester.id = id
        saveContext(context)
    }
    
    class func getSemestersFrom(context context: NSManagedObjectContext) -> [Semester]? {
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
    
    class func getSubjectsBy(semester semester: String, context: NSManagedObjectContext) -> [Subject]? {
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
    
    class func getSubjectsBy(code code: String, context: NSManagedObjectContext) -> [Subject]? {
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
    
    class func addSubjectTo(context context: NSManagedObjectContext, code: String?, name: String?, completed: NSNumber?, credits: String?, semester: String?) {
        let entityDescription = NSEntityDescription.entityForName("Subject", inManagedObjectContext: context)
        let subject = Subject(entity: entityDescription!, insertIntoManagedObjectContext: context)
        subject.code = code
        subject.name = name
        subject.completed = completed
        subject.credits = credits
        subject.semester = semester
        saveContext(context)
    }
    
    class func changeSubjectBy(code code: String?, name: String?, completed: NSNumber?, credits: String?, semester: String?, context: NSManagedObjectContext) {
        if let uCode = code, subjects = getSubjectsBy(code: uCode, context: context) {
            for subject in subjects {
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
            saveContext(context)
        }
    }
    
    class func addSlotTo(context context: NSManagedObjectContext, type: String?, subject: String?, subjectName: String?, teacher: String?, day: NSNumber?, duration: NSNumber?, firstHour: NSNumber?, parity: String?, room: String?, person: Person?) {
        guard let uPerson = person else {
            return
        }
        let entityDescription = NSEntityDescription.entityForName("TimetableSlot", inManagedObjectContext: context)
        let slot = TimetableSlot(entity: entityDescription!, insertIntoManagedObjectContext: context)
        slot.person = uPerson
        slot.subject = subject
        slot.subjectName = subjectName
        slot.teacher = teacher
        slot.day = day
        slot.duration = duration
        slot.firstHour = firstHour
        slot.parity = parity
        slot.room = room
        slot.type = type
        uPerson.addSlot(slot)
        saveContext(context)
    }
    
    private class func saveContext(context: NSManagedObjectContext) {
        SavedVariables.cdh.saveContext(context)
    }
    
}

