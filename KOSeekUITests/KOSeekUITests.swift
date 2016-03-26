//
//  KOSeekUITests.swift
//  KOSeekUITests
//
//  Created by Alzhan on 20.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import XCTest
@testable import KOSeek

class KOSeekUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launch()

        app.navigationBars[""].buttons["menu"].tap()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// Additional method that waits until a required screen will be loaded
    func waitFor(object object: AnyObject, predicate: NSPredicate, time: Double) {
        _ = self.expectationForPredicate(predicate, evaluatedWithObject: object, handler: nil)
        self.waitForExpectationsWithTimeout(time, handler: nil)
    }
    
    func testProfile() {
        let app = XCUIApplication()
        app.tables.staticTexts["Alzhan Turlybekov"].tap()
        waitFor(object: app.tables, predicate: NSPredicate(format: "count == 1"), time: 2)
        XCTAssertEqual(app.tables.cells.count, 3, "Found instead: \(app.tables.cells.debugDescription)")
        let languageSwitch = app.childrenMatchingType(.Switch).elementBoundByIndex(0)
        XCTAssertNotNil(languageSwitch.exists, "Switch doesn't exist!")
    }
    
    func testTimetable() {
        let app = XCUIApplication()
        app.tables.cells.staticTexts["Timetable"].tap()
        waitFor(object: app.tables, predicate: NSPredicate(format: "count == 1"), time: 2)
        app.tables.cells.containingType(.StaticText, identifier: "9:15").staticTexts["BI-EPD.2"].tap()
        XCTAssertEqual(app.alerts["BI-EPD.2"].label, "BI-EPD.2")
        app.alerts["BI-EPD.2"].collectionViews.buttons["OK"].tap()
        
        // Test pull to refresh
        let firstCell = app.staticTexts["7:30"]
        let start = firstCell.coordinateWithNormalizedOffset(CGVector(dx: 0, dy: 0))
        let finish = firstCell.coordinateWithNormalizedOffset(CGVector(dx: 0, dy: 20))
        start.pressForDuration(0, thenDragToCoordinate: finish)
        XCTAssertTrue(app.tables.cells.containingType(.StaticText, identifier: "14:30").staticTexts["BI-EPD.2"].exists)
        app.tables.cells.containingType(.StaticText, identifier:"14:30").staticTexts["BI-EPD.2"].tap()
        app.alerts["BI-EPD.2"].collectionViews.buttons["OK"].tap()
    }
    
    func testSearch() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["People Search"].tap()
        waitFor(object: app.tables, predicate: NSPredicate(format: "count == 1"), time: 2)
        let typeToStartSearchField = tablesQuery.searchFields["type to start"]
        typeToStartSearchField.tap()
        typeToStartSearchField.typeText("vag")
        XCTAssertEqual(app.tables.cells.elementBoundByIndex(0).staticTexts.elementBoundByIndex(0).label, "Ing. Ladislav Vagner Ph.D.")
        tablesQuery.buttons["Cancel"].tap()
        typeToStartSearchField.tap()
        typeToStartSearchField.typeText("Nonvalid name")
        XCTAssertTrue(app.tables.cells.count == 0)
    }
    
    func testResults() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Results"].tap()
        let button = app.navigationBars["Results"].childrenMatchingType(.Other).element.childrenMatchingType(.Button).element
        waitFor(object: button, predicate: NSPredicate(format: "exists == true"), time: 2)
        button.tap()
        tablesQuery.staticTexts["Zimní 2014/2015"].tap()
        XCTAssertEqual(tablesQuery.cells.elementBoundByIndex(0).staticTexts.elementBoundByIndex(0).label, "BI-AAG")
        tablesQuery.staticTexts["Objektové modelování"].tap()
        let cancelButton = app.navigationBars["BI-OMO"].buttons["cancel"]
        waitFor(object: cancelButton, predicate: NSPredicate(format: "exists == true"), time: 5)
        XCTAssertEqual(tablesQuery.cells.elementBoundByIndex(0).staticTexts.elementBoundByIndex(0).label, "Completion: Z, ZK Season: Z")
        app.navigationBars["BI-OMO"].buttons["cancel"].tap()
    }
    
}
