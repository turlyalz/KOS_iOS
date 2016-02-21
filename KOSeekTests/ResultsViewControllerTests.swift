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
        let semesterIDNameDict = [("1","Letni 152"), ("4", "Zimni 141"), ("2", "Zimni 131")].sort({$0.0 < $1.0})
        var array: [String] = []
        for idName in semesterIDNameDict {
            array.append(idName.1)
        }
        let rightArray = ["Letni 152", "Zimni 131", "Zimni 141"]
        XCTAssertEqual(array, rightArray)
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
