//
//  DatabaseHelper.swift
//  KOSeek
//
//  Created by Alzhan on 12.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DatabaseHelper {

    private static let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    private static let context = appDel.managedObjectContext
    
    private init(){ }

    class func setProfileContent(firstName: String?, lastName: String?, username: String?, email: String?, personalNumber: String?) {
        let user = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: context)
        if let _ = firstName, _ = lastName, _ = username, _ = email, _ = personalNumber {
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
        deletePerson()
        deleteSavedVariables()
    }
    
    private class func deletePerson() {
        let coord = appDel.persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    private class func deleteSavedVariables() {
        let coord = appDel.persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest(entityName: "SavedVariables")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func getSavedVariables() -> String? {
        let request = NSFetchRequest(entityName: "SavedVariables")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                let res = results[0] as! NSManagedObject
                let username = res.valueForKey("username") as! String
                return username
            }
        }
        catch let error as NSError {
            debugPrint(error)
        }
        
        return nil
    }
    
    class func setSavedVariables(username: String) {
        let SV = NSEntityDescription.insertNewObjectForEntityForName("SavedVariables", inManagedObjectContext: context)
        SV.setValue(username, forKey: "username")
        do {
            try context.save()
        }
        catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func setSemesterContent(id: String?, name: String?) {
        if let _ = id, _ = name {
            let semester = NSEntityDescription.insertNewObjectForEntityForName("Semester", inManagedObjectContext: context)
            semester.setValue(id, forKey: "id")
            semester.setValue(name, forKey: "name")
            do {
                try context.save()
            }
            catch let error as NSError {
                debugPrint(error)
            }

        }
    }
    
    class func getSemesterContent(id: String) -> String?  {
        let request = NSFetchRequest(entityName: "Semester")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "id == %@", id)
        do {
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                let res = results[0] as! NSManagedObject
                let name = res.valueForKey("name") as! String
                return name
            }
        }
        catch let error as NSError {
            debugPrint(error)
        }
        
        return nil
    }
    
    
}


