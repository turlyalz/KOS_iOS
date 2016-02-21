//
//  ResultsViewControllerTests.swift
//  KOSeek
//
//  Created by Alzhan on 16.02.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//

import XCTest
@testable import KOSeek
import UIKit

/// Class for testing ResultsViewController
class ResultsViewControllerTests: XCTestCase {
    
    var viewController: ResultsViewController!
    
    override func setUp() {
        super.setUp()
        viewController = ResultsViewController()
        viewController.viewDidLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testSemesterDictionary() {
        XCTAssertTrue(viewController.semesterIDNameDict.count != 0, "No semesters")
    }
    
    func testPerformanceLoadingView() {
        // This is a performance test case.
        self.measureBlock {
            self.viewController.viewDidLoad()
        }
    }
    
}
