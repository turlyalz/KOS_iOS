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
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        app.navigationBars[""].buttons["menu"].tap()
        app.tables.cells.staticTexts["Alzhan Turlybekov"].tap()
        let cells = app.tables.cells
        XCTAssertEqual(cells.count, 3, "Found instead: \(cells.debugDescription)")
        
        app.navigationBars["Time"].buttons["menu"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Timetable"].tap()
        tablesQuery.cells.containingType(.StaticText, identifier:"9:15").staticTexts["BI-EPD.2"].tap()
        app.alerts["BI-EPD.2"].collectionViews.buttons["OK"].tap()
      
        
        // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
