//
//  Constants.swift
//  KOSeek
//
//  Created by Alzhan on 15.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import Foundation

let MaxWaitForResponse = 10
let Parity = (Even: "EVEN", Odd: "ODD", Both: "BOTH")

let BGHeaderColor = UIColor(red: 80/255.0, green: 85/255.0, blue: 90/255.0, alpha: 1)


typealias SavedVariablesContent = (username: String?, currentSemester: String?)

var screenSize: CGRect = UIScreen.mainScreen().bounds

var SubjectCell: (subjectNameWidth: CGFloat, subjectCodeWidth: CGFloat, subjectCreditWidth: CGFloat, height: CGFloat) =
(subjectNameWidth: screenSize.width*19/30, subjectCodeWidth: screenSize.width/5, subjectCreditWidth: screenSize.width/6, height: 50)

var ProfileCell: ()

// Dropdown menu constants
var SemesterNumber: CGFloat = 8
var DropdownMenuViewCellHeight: CGFloat = screenSize.height/(SemesterNumber+2)

let DropdownMenuView: (cellBackgroundColor: UIColor, cellSelectionColor: UIColor, cellSeparatorColor: UIColor, cellTextLabelFont: UIFont?, cellTextLabelColor: UIColor, arrowPadding: CGFloat, animationDuration: NSTimeInterval, maskBackgroundColor: UIColor, maskBackgroundOpacity: CGFloat) =
    (cellBackgroundColor: UIColor(red: 120/255, green: 162/255, blue: 182/255, alpha: 1),
        cellSelectionColor: UIColor(red: 110/255, green: 115/255, blue: 120/255, alpha: 1), cellSeparatorColor: UIColor(red: 110/255, green: 110/255, blue: 120/255, alpha: 1), cellTextLabelFont: UIFont(name: "HelveticaNeue", size: 17), cellTextLabelColor: .whiteColor(),
    arrowPadding: 15, animationDuration: 0.4, maskBackgroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0), maskBackgroundOpacity: 0.3)


// Updates values if orientation did changed
func updateValues() {
    screenSize = UIScreen.mainScreen().bounds
    SubjectCell = (subjectNameWidth: screenSize.width*19/30, subjectCodeWidth: screenSize.width/5, subjectCreditWidth: screenSize.width/6, height: 50)
    DropdownMenuViewCellHeight = screenSize.height/SemesterNumber
}

func updateSemesterNumber(number: Int) {
    SemesterNumber = CGFloat(number+2)
    updateValues()
}

// Check if comunication error
func errorOcurredIn(response: NSURLResponse?) -> Bool {
    guard let httpResponse = response as? NSHTTPURLResponse, resp = httpResponse.URL else  {
        return true
    }
    let respStr = String(resp)
    if respStr.rangeOfString("authentication_error=true") != nil {
        return true
    }
    
    if httpResponse.statusCode != 200 {
        print("Unexpected status code: \(httpResponse.statusCode)")
        return true
    }
    return false
}
