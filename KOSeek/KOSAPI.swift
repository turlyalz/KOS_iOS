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
        download("Person Info", extensionURL: "/students/" + SavedVariables.username! + "?access_token=" + LoginHelper.accessToken + "&lang=cs", parser: personParser)
        download("Current Semester", extensionURL: "/students/" + SavedVariables.username! + "/enrolledCourses?access_token=" + LoginHelper.accessToken + "&lang=cs", parser: currentSemesterParser)
        download("Enrolled Courses", extensionURL: "/students/" + SavedVariables.username! + "/enrolledCourses?access_token=" + LoginHelper.accessToken + "&sem=none&limit=1000&lang=cs", parser: semesterParser)
        
        var subjectExtensionURL = "/courses?access_token=" + LoginHelper.accessToken + "&limit=1000&lang=cs&query="
        for code in SavedVariables.subjectCodes {
            if code == SavedVariables.subjectCodes.last {
                subjectExtensionURL += "code=" + code
            }
            else {
                subjectExtensionURL += "code=" + code + ","
            }
        }
        download("Subjects Info", extensionURL: subjectExtensionURL, parser: subjectsDetailsParser)
        
        onComplete()
    }

    private class func currentSemesterParser(xml: XMLIndexer) {
        SavedVariables.currentSemester = xml["atom:feed"]["atom:entry"][0]["atom:content"]["semester"].element?.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString("semesters/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
        print("Current semester: \(SavedVariables.currentSemester)")
        if let currentSemester = SavedVariables.currentSemester {
            Database.setSavedVariables(SavedVariables.username!, currentSemester: currentSemester)
        }
    }
    
    private class func personParser(xml: XMLIndexer) {
        let firstName = xml["atom:entry"]["atom:content"]["firstName"].element?.text
        let lastName = xml["atom:entry"]["atom:content"]["lastName"].element?.text
        let username = xml["atom:entry"]["atom:content"]["username"].element?.text
        let email = xml["atom:entry"]["atom:content"]["email"].element?.text
        let personalNumber = xml["atom:entry"]["atom:content"]["personalNumber"].element?.text
        Database.setProfileContent(firstName, lastName: lastName, username: username, email: email, personalNumber: personalNumber)
    }

    private class func semesterParser(xml: XMLIndexer) {
        let subjectNumberStr = xml["atom:feed"]["osearch:totalResults"].element?.text
        if let uSubjectNumberStr = subjectNumberStr {
            if let subjectNumber = Int(uSubjectNumberStr) {
                for index in 0...subjectNumber-1 {
                    let semesterID = xml["atom:feed"]["atom:entry"][index]["atom:content"]["semester"].element?.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString("semesters/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
                    if let semID = semesterID {
                        if SavedVariables.semesterIDNameDict[semID] == nil {
                            let semesterName = xml["atom:feed"]["atom:entry"][index]["atom:content"]["semester"].element?.text
                            SavedVariables.semesterIDNameDict[semID] = semesterName
                        }
                    }
                    
                    let completedStr = xml["atom:feed"]["atom:entry"][index]["atom:content"]["completed"].element?.text
                    let subjectName = xml["atom:feed"]["atom:entry"][index]["atom:content"]["course"].element?.text
                    let code = xml["atom:feed"]["atom:entry"][index]["atom:content"]["course"].element?.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString("courses/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
                    var completed = 0
                    if completedStr == "true" {
                        completed = 1
                    }
                    else {
                        completed = 0
                    }
                    if let uCode = code {
                        SavedVariables.subjectCodes.append(uCode)
                    }
                    //print("Code: \(code), name: \(subjectName), semester: \(semesterID)")
                    Database.addNewSubject(code, name: subjectName, completed: completed, credits: nil, semester: semesterID)
                }
            }
        }
    }

    private class func subjectsDetailsParser(xml: XMLIndexer) {
        var number = 0
        if let numberStr = xml["atom:feed"]["osearch:totalResults"].element?.text {
            if let uNumber = Int(numberStr) {
                number = uNumber
            }
        }
        for index in 0...number-1 {
            let code = xml["atom:feed"]["atom:entry"][index]["atom:content"]["code"].element?.text
            let credits = xml["atom:feed"]["atom:entry"][index]["atom:content"]["credits"].element?.text
            Database.changeSubjectByCode(code, name: nil, completed: nil, credits: credits, semester: nil)
        }
    }
    
    private class func download(name: String, extensionURL: String, parser: (XMLIndexer) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + extensionURL)!)
        request.HTTPMethod = "GET"
        print("Request = \(request)")
        var failed = false
        var running = false
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, _, error in
            if error != nil {
                print("error=\(error)")
                failed = true
                return
            }
            if let uData = data {
                let xml = SWXMLHash.parse(uData)
                parser(xml)
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
            print("Unable to download \(name)")
        }
    }
    
}


