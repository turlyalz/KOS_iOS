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

// MARK: KOSAPI
class KOSAPI {
    
    // Function that calls when all downloads are completed
    static var onComplete: (() -> Void)!
    private static let baseURL = "https://kosapi.fit.cvut.cz/api/3"
    
    private init(){ }
    
    // Download all data
    class func downloadAllData() -> Bool{
        guard let accessToken = LoginHelper.getAuthToken() else {
            return false
        }
        if (!Reachability.isConnectedToNetwork()) {
            return false
        }
        download("User person Info", extensionURL: "/students/" + SavedVariables.username! + "?access_token=" + accessToken + "&lang=cs", parser: userParser)
        download("Current Semester", extensionURL: "/semesters/current?access_token=" + accessToken + "&lang=cs", parser: currentSemesterParser)
        download("Enrolled Courses", extensionURL: "/students/" + SavedVariables.username! + "/enrolledCourses?access_token=" + accessToken + "&sem=none&limit=1000&lang=cs", parser: semesterParser)

        download("Timetable slots", extensionURL: "/students/" + SavedVariables.username! + "/parallels?access_token=" + accessToken + "&limit=1000", parser: timetableSlotParser)
        
        download("Teachers", extensionURL: "/divisions/18000/teachers/?access_token=" + accessToken + "&limit=1000&lang=cs", parser: teachersParser)
        
        var subjectExtensionURL = "/courses?access_token=" + accessToken + "&limit=1000&lang=cs&query="
        for code in SavedVariables.subjectCodes {
            if code == SavedVariables.subjectCodes.last {
                subjectExtensionURL += "code=" + code
            }
            else {
                subjectExtensionURL += "code=" + code + ","
            }
        }
        download("Subjects Info", extensionURL: subjectExtensionURL, parser: subjectsDetailsParser)
        
        dispatch_async(dispatch_get_main_queue(), {
            SavedVariables.waitingViewController?.counter = 100
            return
        })

        onComplete()
        return true
    }
    
    class func downloadExamBy(subjectCode: String) -> [Exam]? {
        guard let currentSemester = SavedVariables.currentSemester, accessToken = LoginHelper.getAuthToken() else {
            return nil
        }
        var examsExtensionURL =  "/exams/?access_token=" + accessToken + "&query=semester='" + currentSemester
        examsExtensionURL += "';course='" + subjectCode + "'&limit=1000"
        return downloadExams("Exam for subject: " + subjectCode, extensionURL: examsExtensionURL)
    }

    private class func examsParser(xml: XMLIndexer) -> [Exam]? {
        guard let examNumber = getNumberFrom(xml) else {
            return nil
        }
        var exams: [Exam] = []
        for index in 0...examNumber-1 {
            let content = xml["atom:feed"]["atom:entry"][index]["atom:content"]
            let capacity = content["capacity"].element?.text
            let occupied = content["occupied"].element?.text
            let room = content["room"].element?.text
            let signinDeadline = content["signinDeadline"].element?.text
            let startDate = content["startDate"].element?.text
            let endDate = content["endDate"].element?.text
            let termType = content["termType"].element?.text
            exams.append(Exam(capacity: capacity, occupied: occupied, room: room, signinDeadline: signinDeadline, startDate: startDate, endDate: endDate, termType: termType))
        }
        return exams
    }
    
    private class func timetableSlotParser(xml: XMLIndexer) {
        guard let slotNumber = getNumberFrom(xml) else {
            return
        }
        let person = Database.getPersonBy(username: SavedVariables.username!, context: SavedVariables.cdh.backgroundContext!)
        for index in 0...slotNumber-1 {
            let content = xml["atom:feed"]["atom:entry"][index]["atom:content"]
            let subject = content["course"].element?.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString("courses/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
            let type = content["parallelType"].element?.text
            let teacher = content["teacher"].element?.text
            let slot = content["timetableSlot"]
            let dayStr = slot["day"].element?.text
            var day: NSNumber = 0
            if let uDay = dayStr, dayInt = Int(uDay) {
                day = dayInt
            }
            let durationStr = slot["duration"].element?.text
            var duration: NSNumber = 0
            if let uDuration = durationStr, durationInt = Int(uDuration) {
                duration = durationInt
            }
            let firstHourStr = slot["firstHour"].element?.text
            var firstHour: NSNumber = 0
            if let uFirstHour = firstHourStr, firstHourInt = Int(uFirstHour) {
                firstHour = firstHourInt
            }
            let parity = slot["parity"].element?.text
            let room = slot["room"].element?.text
            Database.addSlotTo(context: SavedVariables.cdh.backgroundContext!, type: type, subject: subject, subjectName: subject, teacher: teacher, day: day, duration: duration, firstHour: firstHour, parity: parity, room: room, person: person)            
        }
    }
    
    private class func currentSemesterParser(xml: XMLIndexer) {
        SavedVariables.currentSemester = xml["atom:entry"]["atom:content"]["code"].element?.text
        print("Current semester: \(SavedVariables.currentSemester)")
        if let currentSemester = SavedVariables.currentSemester, accessToken = LoginHelper.getAuthToken() {
            Database.setSavedVariables(SavedVariables.cdh.backgroundContext!, username: SavedVariables.username!, currentSemester: currentSemester, accessToken: accessToken, refreshToken: LoginHelper.refreshToken, expires: LoginHelper.expires)
        }
    }
    
    private class func teachersParser(xml: XMLIndexer) {
        guard let teacherNumber = getNumberFrom(xml) else {
            return
        }
        for index in 0...teacherNumber-1 {
            let title = xml["atom:feed"]["atom:entry"][index]["atom:title"].element?.text
            let person = personInfoParser(xml, index: index)
            Database.addPersonTo(context: SavedVariables.cdh.backgroundContext!, firstName: person.firstName, lastName: person.lastName, username: person.username, email: person.email, personalNumber: person.personalNumber, title: title)
        }
    }
    
    private class func userParser(xml: XMLIndexer) {
        let person = personInfoParser(xml, index: -1)
        Database.addPersonTo(context: SavedVariables.cdh.backgroundContext!, firstName: person.firstName, lastName: person.lastName, username: person.username, email: person.email, personalNumber: person.personalNumber, title: nil)

    }
    
    private class func personInfoParser(xml: XMLIndexer, index: Int) -> (firstName: String?, lastName: String?, username: String?, email: String?, personalNumber: String?) {
        var content: XMLIndexer
        if index != -1 {
            content = xml["atom:feed"]["atom:entry"][index]["atom:content"]
        } else {
            content = xml["atom:entry"]["atom:content"]
        }
        let firstName = content["firstName"].element?.text
        let lastName = content["lastName"].element?.text
        let username = content["username"].element?.text
        let email = content["email"].element?.text
        let personalNumber = content["personalNumber"].element?.text
        return (firstName: firstName, lastName: lastName, username: username, email: email, personalNumber: personalNumber)
    }

    private class func semesterParser(xml: XMLIndexer) {
        let subjectNumberStr = xml["atom:feed"]["osearch:totalResults"].element?.text
        guard let uSubjectNumberStr = subjectNumberStr, subjectNumber = Int(uSubjectNumberStr) else {
            return
        }
        for index in 0...subjectNumber-1 {
            let content = xml["atom:feed"]["atom:entry"][index]["atom:content"]
            let semesterID = content["semester"].element?.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString("semesters/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
            if let semID = semesterID {
                if SavedVariables.semesterIDNameDict[semID] == nil {
                    let semesterName = content["semester"].element?.text
                    SavedVariables.semesterIDNameDict[semID] = semesterName
                    Database.addSemesterTo(context: SavedVariables.cdh.backgroundContext!, name: semesterName, id: semID)
                }
            }
            
            let completedStr = content["completed"].element?.text
            let subjectName = content["course"].element?.text
            let code = content["course"].element?.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString("courses/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
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
            Database.addSubjectTo(context: SavedVariables.cdh.backgroundContext!, code: code, name: subjectName, completed: completed, credits: nil, semester: semesterID)
        }
    }

    private class func subjectsDetailsParser(xml: XMLIndexer) {
        guard let number = getNumberFrom(xml) else {
            return
        }
        for index in 0...number-1 {
            let content = xml["atom:feed"]["atom:entry"][index]["atom:content"]
            let code = content["code"].element?.text
            let credits = content["credits"].element?.text
            Database.changeSubjectBy(code: code, name: nil, completed: nil, credits: credits, semester: nil, context: SavedVariables.cdh.backgroundContext!)
        }
    }
    
    private class func getNumberFrom(xml: XMLIndexer) -> Int? {
        let numberStr = xml["atom:feed"]["osearch:totalResults"].element?.text
        guard let uNumberStr = numberStr, number = Int(uNumberStr) else {
            return nil
        }
        if number < 1 {
            return nil
        }
        return number
    }
    
    private class func download(name: String, extensionURL: String, parser: (XMLIndexer) -> Void) {
        dispatch_async(dispatch_get_main_queue(), {
            SavedVariables.waitingViewController?.counter += 5
            return
        })
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + extensionURL)!)
        request.HTTPMethod = "GET"
        request.addValue("application/xml", forHTTPHeaderField: "accept")
        //print("That value: \(request.valueForHTTPHeaderField("Accept"))")
        print("Request = \(request)")
        var failed = false
        var running = false
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, _, error in
            if error != nil {
                print("error=\(error)")
                failed = true
                return
            }
            print("Downloading \(name)...")
            //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("Response string = [ \(responseString) ]")

            if let uData = data {
                let xml = SWXMLHash.parse(uData)
                parser(xml)
            }
            running = false
            dispatch_async(dispatch_get_main_queue(), {
                SavedVariables.waitingViewController?.counter += 5
                return
            })
        }
        running = true
        task.resume()
        var count = 0
        while running && !failed && count < MaxWaitForResponse {
            print("waiting for response...")
            sleep(1)
            count++
        }
        if failed || errorOcurredIn(task.response) || count >= MaxWaitForResponse{
            print("Unable to download \(name)")
        }
    }
    
    private class func downloadExams(name: String, extensionURL: String) -> [Exam]? {
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + extensionURL)!)
        request.HTTPMethod = "GET"
        //request.addValue("application/atom+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        print("Request = \(request)")
        var failed = false
        var running = false
        var exams: [Exam]? = nil
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, _, error in
            if error != nil {
                print("error=\(error)")
                failed = true
                return
            }
            if let uData = data {
                let xml = SWXMLHash.parse(uData)
                exams = examsParser(xml)
            }
            running = false
        }
        running = true
        task.resume()
        var count = 0
        while running && !failed && count < MaxWaitForResponse {
            print("waiting for response...")
            sleep(1)
            count++
        }
        if failed || errorOcurredIn(task.response) || count >= MaxWaitForResponse{
            print("Unable to download \(name)")
        }
        return exams
    }

}


