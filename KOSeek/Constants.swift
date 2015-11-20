//
//  Constants.swift
//  KOSeek
//
//  Created by Alzhan on 15.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import Foundation

let MAX_WAIT_FOR_RESPONSE = 10

typealias ProfileContent = (names: [String], values: [String])
typealias SemesterContent = (name: String?, subjectNumber: NSNumber?, subjects: NSSet?)
typealias SavedVariablesContent = (username: String?, currentSemester: String?)

var screenSize: CGRect = UIScreen.mainScreen().bounds

var SubjectCell: (subjectNameWidth: CGFloat, subjectCodeWidth: CGFloat, subjectCreditWidth: CGFloat, height: CGFloat) =
(subjectNameWidth: screenSize.width*19/30, subjectCodeWidth: screenSize.width/5, subjectCreditWidth: screenSize.width/6, height: 50)

var SemesterNumber: CGFloat = 8

var DropdownMenuView: (cellHeight: CGFloat, cellBackgroundColor: UIColor, cellSelectionColor: UIColor, cellTextLabelColor: UIColor, arrowPadding: CGFloat, animationDuration: NSTimeInterval, maskBackgroundColor: UIColor, maskBackgroundOpacity: CGFloat) =
    (cellHeight: screenSize.height/(SemesterNumber+2), cellBackgroundColor: UIColor(red: 120/255, green: 162/255, blue: 182/255, alpha: 1.0),
    cellSelectionColor: UIColor(red: 110/255, green: 115/255, blue: 120/255, alpha: 1.0), cellTextLabelColor: .whiteColor(),
    arrowPadding: 15, animationDuration: 0.4, maskBackgroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.0), maskBackgroundOpacity: 0.3)


func updateValues() {
    screenSize = UIScreen.mainScreen().bounds
    SubjectCell = (subjectNameWidth: screenSize.width*19/30, subjectCodeWidth: screenSize.width/5, subjectCreditWidth: screenSize.width/6, height: 50)
    DropdownMenuView.cellHeight = screenSize.height/SemesterNumber
}

func updateSemesterNumber(number: Int) {
    SemesterNumber = CGFloat(number+2)
    updateValues()
}

func errorOcurredIn(response: NSURLResponse?) -> Bool {
    if let httpResponse = response as? NSHTTPURLResponse {
        if let resp = httpResponse.URL {
            let respStr = String(resp)
            if respStr.rangeOfString("authentication_error=true") != nil {
                return true
            }
        }
        if httpResponse.statusCode != 200 {
            print("Unexpected status code: \(httpResponse.statusCode)")
            return true
        }
    }
    return false
}
