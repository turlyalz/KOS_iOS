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
        if let fn = firstName, ln = lastName, un = username, em = email, pn = personalNumber {
            user.setValue(fn, forKey: "firstName")
            user.setValue(ln, forKey: "lastName")
            user.setValue(un, forKey: "username")
            user.setValue(em, forKey: "email")
            user.setValue(pn, forKey: "personalNumber")
        }
        
        do {
            try context.save()
        }
        catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func getProfileContent(username: String) -> (names: [String], values: [String]) {
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
    
    class func deletePerson() {
        let coord = appDel.persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
}


