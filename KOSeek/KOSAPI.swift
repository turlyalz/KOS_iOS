//
//  KOSAPI.swift
//  KOSeek
//
//  Created by Alzhan on 11.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class KOSAPI {
    
    static var onComplete: (() -> Void)!
    private static let baseURL = "https://kosapi.fit.cvut.cz/api/3"
    private static let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    private static let context = appDel.managedObjectContext
    
    private init(){ }
    
    class func downloadAllData() {
        downloadPersonInfo()
        onComplete()
    }
    
    private class func downloadPersonInfo() {
        let extensionURL = "/students/" + SavedVariables.username! + "?access_token=" + LoginHelper.accessToken + "&lang=cs"
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + extensionURL)!)
        request.HTTPMethod = "GET"
        print("Request = \(request)")
       
        var failed = false
        var running = false
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, _, error in
            
            if error != nil {
                print("error=\(error)")
                failed = true
                return
            }
            
            if let uData = data {
                let xml = SWXMLHash.parse(uData)
                let user = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: context)
                let firstName = xml["atom:entry"]["atom:content"]["firstName"].element?.text
                let lastName = xml["atom:entry"]["atom:content"]["lastName"].element?.text
                let username = xml["atom:entry"]["atom:content"]["username"].element?.text
                let email = xml["atom:entry"]["atom:content"]["email"].element?.text
                let personalNumber = xml["atom:entry"]["atom:content"]["personalNumber"].element?.text
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
            running = false
        }
        running = true
        task.resume()
        
        while running && !failed {
            //print("waiting for response...")
        }
        
        if failed || LoginHelper.errorOcurredIn(task.response) {
            print("Unable to download")
        }
    }
    
    class func getFullName() -> (firstName: String, lastName: String) {
        let request = NSFetchRequest(entityName: "Person")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                let res = results[0] as! NSManagedObject
                let firstName = res.valueForKey("firstName") as! String
                let lastName = res.valueForKey("lastName") as! String
                return (firstName, lastName)
            }
        }
        catch let error as NSError {
            debugPrint(error)
        }
        
        return ("nil", "nil")
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


