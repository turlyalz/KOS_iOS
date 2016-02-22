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

/// Static class provides functions for downloading all data using KOSAPI
class KOSAPI {
    
    /// Function that called when all downloads are completed
    static var onComplete: (() -> Void)!
    /// Function that called when need to increase progress bar
    static var increaseProgressBar: ((Int) -> Void)?
    
    /// Variable defines download language
    static var downloadLanguage = "cs"
    
    private static let baseURL = "https://kosapi.fit.cvut.cz/api/3"
    private static var semesterID = "none"
    private static var subjectCode = "none"
    private static var courseEvent = false
    
    private init() {}
    
    /// Download all data
    class func downloadAllData(context: NSManagedObjectContext) {
        if (!Reachability.isConnectedToNetwork()) {
            return
        }
        downloadUserInfo(context)
        downloadEnrolledCourses(context, semesterID: "none")
        downloadTimeTableSlots(context)
        downloadCurrentSemester(context)
        downloadTeachers(context)
        downloadSubjectsInfo(context)
        downloadAllCourseEvents(context)
        dispatch_async(dispatch_get_main_queue(), {
            increaseProgressBar?(100)
            onComplete()
            return
        })
    }
    
    class func downloadUserInfo(context: NSManagedObjectContext) {
        guard let accessToken = LoginHelper.getAuthToken() else {
            return
        }
        download("User person Info", extensionURL: "/students/" + SavedVariables.username! + "?access_token=" + accessToken + "&lang=cs", context: context, parser: userParser)
    }
    
    class func downloadEnrolledCourses(context: NSManagedObjectContext, semesterID: String) {
        guard let accessToken = LoginHelper.getAuthToken() else {
            return
        }
        self.semesterID = semesterID
        if (semesterID != "none") {
            download("Enrolled Courses", extensionURL: "/students/" + SavedVariables.username! + "/enrolledCourses?access_token=" + accessToken + "&sem=" + semesterID + "&limit=1000&lang=" + downloadLanguage, context: context, parser: subjectsParser)
        } else {
            download("Enrolled Courses", extensionURL: "/students/" + SavedVariables.username! + "/enrolledCourses?access_token=" + accessToken + "&sem=" + semesterID + "&limit=1000&lang=" + downloadLanguage, context: context, parser: semesterParser)
        }
    }
    
    class func downloadTimeTableSlots(context: NSManagedObjectContext) {
        guard let accessToken = LoginHelper.getAuthToken() else {
            return
        }
        download("Timetable slots", extensionURL: "/students/" + SavedVariables.username! + "/parallels?access_token=" + accessToken + "&limit=1000&lang=" + downloadLanguage, context: context, parser: timetableSlotParser)
    }
    
    class func downloadCurrentSemester(context: NSManagedObjectContext) {
        guard let accessToken = LoginHelper.getAuthToken() else {
            return
        }
        download("Current Semester", extensionURL: "/semesters/current?access_token=" + accessToken + "&lang=" + downloadLanguage, context: context, parser: currentSemesterParser)
    }
    
    class func downloadTeachers(context: NSManagedObjectContext) {
        guard let accessToken = LoginHelper.getAuthToken() else {
            return
        }
        download("Teachers", extensionURL: "/divisions/18000/teachers/?access_token=" + accessToken + "&limit=1000&lang=" + downloadLanguage, context: context, parser: teachersParser)
    }
    
    class func downloadSubjectsInfo(context: NSManagedObjectContext) {
        guard let accessToken = LoginHelper.getAuthToken() else {
            return
        }
        var subjectExtensionURL = "/courses?access_token=" + accessToken + "&limit=1000&lang=" + downloadLanguage + "&query="
        guard let subjects = Database.getSubjects(context) else {
            return
        }
        for subject in subjects {
            if let code = subject.code {
                subjectExtensionURL += "code=" + code + ","
            }
        }
        let url = String(subjectExtensionURL.characters.dropLast())
        download("Subjects Info", extensionURL: url, context: context, parser: subjectsDetailsParser)
    }
    
    class func downloadExamBy(subjectCode: String, context: NSManagedObjectContext) {
        guard let currentSemester = SavedVariables.currentSemester, accessToken = LoginHelper.getAuthToken() else {
            return
        }
        var extensionURL =  "/exams/?access_token=" + accessToken + "&query=semester='" + currentSemester
        extensionURL += "';course='" + subjectCode + "'&limit=1000"
        courseEvent = false
        download("Exams for subject: " + subjectCode, extensionURL: extensionURL, context: context, parser: examsOrCourseEventsParser)
    }
    
    class func downloadAllCourseEvents(context: NSManagedObjectContext) {
        guard let currentSemester = SavedVariables.currentSemester, accessToken = LoginHelper.getAuthToken() else {
            return
        }
        let extensionURL =  "/courseEvents/?access_token=" + accessToken + "&query=semester='" + currentSemester + "'&limit=1000"
        courseEvent = true
        download("Course events", extensionURL: extensionURL, context: context, parser: examsOrCourseEventsParser)
    }
    
    class func downloadSubjectDetails(code: String, context: NSManagedObjectContext) {
        guard let accessToken = LoginHelper.getAuthToken() else {
            return
        }
        let extensionURL =  "/courses?access_token=" + accessToken + "&limit=1000&query=code=" + code + "&detail=1&lang=" + downloadLanguage + "&multilang=0"
        subjectCode = code
        download("Subject details", extensionURL: extensionURL, context: context, parser: subjectDetailsParser)
    }
    
    private class func subjectDetailsParser(xml: XMLIndexer, context: NSManagedObjectContext) {
        let content = xml["atom:feed"]["atom:entry"]["atom:content"]
        let completion = content["completion"].element?.text
        let season = content["season"].element?.text
        let range = content["range"].element?.text
        let description = content["description"].element?.text
        let lecturesContents = content["lecturesContents"].element?.text
        let tutorialsContents = content["tutorialsContents"].element?.text
        Database.addSubjectDetails(code: subjectCode, completion: completion, range: range, season: season, description: description, lecturesContents: lecturesContents, tutorialsContents: tutorialsContents, context: context)
    }
    
    private class func examsOrCourseEventsParser(xml: XMLIndexer, context: NSManagedObjectContext) {
        guard let examNumber = getNumberFrom(xml) else {
            return
        }
        for index in 0...examNumber-1 {
            let content = xml["atom:feed"]["atom:entry"][index]["atom:content"]
            let subject = content["course"].element?.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString("courses/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
            let name = content["name"].element?.text
            let startDate = content["startDate"].element?.text
            let room = content["room"].element?.text
            let capacity = content["capacity"].element?.text
            let occupied = content["occupied"].element?.text
            let signinDeadline = content["signinDeadline"].element?.text
            let cancelDeadline = content["cancelDeadline"].element?.text
            var termType: String?
            if courseEvent {
                termType = "COURSE_EVENT"
            } else {
                termType = content["termType"].element?.text
            }
            guard let uStartDate = startDate else {
                continue
            }
            if isLateDate(uStartDate) {
                continue
            }
            Database.addExamTo(context: context, name: name, capacity: capacity, occupied: occupied, startDate: startDate, room: room, cancelDeadline: cancelDeadline, signinDeadline: signinDeadline, termType: termType, subject: subject)
        }
    }
    
    private class func timetableSlotParser(xml: XMLIndexer, context: NSManagedObjectContext) {
        guard let slotNumber = getNumberFrom(xml) else {
            return
        }
        let person = Database.getPersonBy(username: SavedVariables.username!, context: context)
        for index in 0...slotNumber-1 {
            let content = xml["atom:feed"]["atom:entry"][index]["atom:content"]
            let subject = content["course"].element?.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString("courses/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
            let subjectName = content["course"].element?.text
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
            Database.addSlotTo(context: context, type: type, subject: subject, subjectName: subjectName, teacher: teacher, day: day, duration: duration, firstHour: firstHour, parity: parity, room: room, person: person)
        }
    }
    
    private class func currentSemesterParser(xml: XMLIndexer, context: NSManagedObjectContext) {
        SavedVariables.currentSemester = xml["atom:entry"]["atom:content"]["code"].element?.text
        print("Current semester: \(SavedVariables.currentSemester)")
        if let currentSemester = SavedVariables.currentSemester, accessToken = LoginHelper.getAuthToken() {
            Database.setSavedVariables(context, username: SavedVariables.username!, currentSemester: currentSemester, accessToken: accessToken, refreshToken: LoginHelper.refreshToken, expires: LoginHelper.expires, downloadLanguage: downloadLanguage)
        }
    }
    
    private class func teachersParser(xml: XMLIndexer, context: NSManagedObjectContext) {
        guard let teacherNumber = getNumberFrom(xml) else {
            return
        }
        for index in 0...teacherNumber-1 {
            let title = xml["atom:feed"]["atom:entry"][index]["atom:title"].element?.text
            let person = personInfoParser(xml, index: index)
            Database.addPersonTo(context: context, firstName: person.firstName, lastName: person.lastName, username: person.username, email: person.email, personalNumber: person.personalNumber, title: title)
        }
    }
    
    private class func userParser(xml: XMLIndexer, context: NSManagedObjectContext) {
        let person = personInfoParser(xml, index: -1)
        Database.addPersonTo(context: context, firstName: person.firstName, lastName: person.lastName, username: person.username, email: person.email, personalNumber: person.personalNumber, title: nil)

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

    private class func semesterParser(xml: XMLIndexer, context: NSManagedObjectContext) {
        guard let number = getNumberFrom(xml) else {
            return
        }
        for index in 0...number-1 {
            let content = xml["atom:feed"]["atom:entry"][index]["atom:content"]
            let semesterID = content["semester"].element?.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString("semesters/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
            guard let semID = semesterID else {
                return
            }
            var semester: Semester?
            if SavedVariables.semesterIDNameDict[semID] == nil {
                let semesterName = content["semester"].element?.text
                SavedVariables.semesterIDNameDict[semID] = semesterName
                semester = Database.addSemesterTo(context: context, name: semesterName, id: semID)
            } else {
                semester = Database.getSemesterBy(semID, context: context)
            }
            subjectParser(xml, semester: semester, index: index, context: context)
        }
    }
    
    private class func subjectsParser(xml: XMLIndexer, context: NSManagedObjectContext) {
        guard let number = getNumberFrom(xml) else {
            return
        }
        let semester = Database.getSemesterBy(semesterID, context: context)
        for index in 0...number-1 {
            subjectParser(xml, semester: semester, index: index, context: context)
        }
    }
    
    private class func subjectParser(xml: XMLIndexer, semester: Semester?, index: Int, context: NSManagedObjectContext) {
        let content = xml["atom:feed"]["atom:entry"][index]["atom:content"]
        let completedStr = content["completed"].element?.text
        let subjectName = content["course"].element?.text
        let code = content["course"].element?.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString("courses/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
        var completed = 0
        if completedStr == "true" {
            completed = 1
        } else {
            completed = 0
        }
        Database.addSubjectTo(context: context, code: code, name: subjectName, completed: completed, credits: nil, semester: semester)
    }

    private class func subjectsDetailsParser(xml: XMLIndexer, context: NSManagedObjectContext) {
        guard let number = getNumberFrom(xml) else {
            return
        }
        for index in 0...number-1 {
            let content = xml["atom:feed"]["atom:entry"][index]["atom:content"]
            let code = content["code"].element?.text
            let credits = content["credits"].element?.text
            Database.changeSubjectBy(code: code, name: nil, completed: nil, credits: credits, semester: nil, context: context)
        }
    }
    
    class func getNumberFrom(xml: XMLIndexer) -> Int? {
        let numberStr = xml["atom:feed"]["osearch:totalResults"].element?.text
        guard let uNumberStr = numberStr, number = Int(uNumberStr) else {
            return nil
        }
        if number < 1 {
            return nil
        }
        return number
    }
    
    class func download(name: String, extensionURL: String, context: NSManagedObjectContext, parser: (XMLIndexer, NSManagedObjectContext) -> Void) {
        dispatch_async(dispatch_get_main_queue(), {
            increaseProgressBar?(9)
            return
        })
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + extensionURL)!)
        request.HTTPMethod = "GET"
        request.addValue("application/xml", forHTTPHeaderField: "accept")
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

            if let uData = data {
                let xml = SWXMLHash.parse(uData)
                parser(xml, context)
            }
            running = false
            dispatch_async(dispatch_get_main_queue(), {
                increaseProgressBar?(8)
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
}


