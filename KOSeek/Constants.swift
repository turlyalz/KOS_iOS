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


func updateValues() {
    screenSize = UIScreen.mainScreen().bounds
    SubjectCell = (subjectNameWidth: screenSize.width*19/30, subjectCodeWidth: screenSize.width/5, subjectCreditWidth: screenSize.width/6, height: 50)
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
