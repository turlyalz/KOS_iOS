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
        downloadSemester()
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
                
                let firstName = xml["atom:entry"]["atom:content"]["firstName"].element?.text
                let lastName = xml["atom:entry"]["atom:content"]["lastName"].element?.text
                let username = xml["atom:entry"]["atom:content"]["username"].element?.text
                let email = xml["atom:entry"]["atom:content"]["email"].element?.text
                let personalNumber = xml["atom:entry"]["atom:content"]["personalNumber"].element?.text
                DatabaseHelper.setProfileContent(firstName, lastName: lastName, username: username, email: email, personalNumber: personalNumber)
              
            }
            running = false
        }
        running = true
        task.resume()
        
        var count = 0
        while running && !failed && count < MAX_WAIT_FOR_RESPONSE {
            print("waiting for response...")
            sleep(1)
            count++
        }
        
        if failed || errorOcurredIn(task.response) || count >= MAX_WAIT_FOR_RESPONSE{
            print("Unable to download personal info.")
        }
    }
    
    private class func downloadSemester() {
        let extURL = "/students/" + SavedVariables.username!
        let extensionURL =  extURL + "/enrolledCourses" + "?access_token=" + LoginHelper.accessToken + "&lang=cs"
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
            print("Parsing semester")
            
            if let uData = data {
                let xml = SWXMLHash.parse(uData)
                let id = xml["atom:feed"]["atom:entry"][0]["atom:content"]["semester"].element?.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString("semesters/", withString: "")
                SavedVariables.currentSemester = id
                let name = xml["atom:feed"]["atom:entry"][0]["atom:content"]["semester"].element?.text
                DatabaseHelper.setSemesterContent(id, name: name)
            }
            running = false
        }
        running = true
        task.resume()
        
        var count = 0
        while running && !failed && count < MAX_WAIT_FOR_RESPONSE {
            print("waiting for response...")
            sleep(1)
            count++
        }
        
        if failed || errorOcurredIn(task.response) || count >= MAX_WAIT_FOR_RESPONSE{
            print("Unable to download semester info.")
        }
    }
    
}

