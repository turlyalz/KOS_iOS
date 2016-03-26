//
//  KOSAPITests.swift
//  KOSeek
//
//  Created by Alzhan on 21.02.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//

import XCTest
import CoreData
import SWXMLHash
@testable import KOSeek

class KOSAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        KOSAPI.downloadCurrentSemester(SavedVariables.cdh.managedObjectContext)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDownload() {
        XCTAssert(Database.getSavedVariablesFrom(context: SavedVariables.cdh.managedObjectContext).currentSemester != nil, "")
    }
    
    func testKOSAPIdata() {
        XCTAssert(LoginHelper.getAuthToken() != nil, "Access token is nil!")
        KOSAPI.download("Timetable slots", extensionURL: "/students/" + SavedVariables.username! + "/parallels?access_token=" +  LoginHelper.getAuthToken()! + "&limit=1000&lang=cs", context: SavedVariables.cdh.managedObjectContext, parser: parser)
    }
    
    func parser(xml: XMLIndexer, context: NSManagedObjectContext) {
        if let slotNumber = KOSAPI.getNumberFrom(xml) {
            for index in 0...slotNumber-1 {
                let content = xml["atom:feed"]["atom:entry"][index]["atom:content"]
                let subject = content["course"].element?.attributes["xlink:href"]?.stringByReplacingOccurrencesOfString("courses/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
                XCTAssert(subject != nil, "No subject!")
                let subjectName = content["course"].element?.text
                XCTAssert(subjectName != nil, "No subject name!")
                let type = content["parallelType"].element?.text
                XCTAssert(type != nil, "No type!")
                let teacher = content["teacher"].element?.text
                XCTAssert(teacher != nil, "No teacher!")
                let slot = content["timetableSlot"]
                let dayStr = slot["day"].element?.text
                XCTAssert(dayStr != nil, "No day!")
            }
        } else {
            XCTAssert(true, "No timetable slots")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
