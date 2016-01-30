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

// Colors
let BGHeaderColor = UIColor(red: 80/255.0, green: 85/255.0, blue: 90/255.0, alpha: 1)
let SlotTutorialColor = UIColor(red: 219/255.0, green: 242/255.0, blue: 219/255.0, alpha: 1)
let SlotLectureColor = UIColor(red: 255/255.0, green: 245/255.0, blue: 207/255.0, alpha: 1)
let SlotLaboratoryColor = UIColor(red: 189/255.0, green: 196/255.0, blue: 231/255.0, alpha: 1)
let MenuButtonTintColor = UIColor(red: 57/255.0, green: 61/255.0, blue: 67/255.0, alpha: 1)
let TableViewBackgroundColor = UIColor(white: 1, alpha: 0.95)

typealias SavedVariablesContent = (username: String?, currentSemester: String?, accessToken: String?, refreshToken: String?, expires: NSDate?)

var screenSize: CGRect = UIScreen.mainScreen().bounds

// Dropdown menu constants
var SemesterNumber: CGFloat = 10
var DropdownMenuViewCellHeight: CGFloat = screenSize.height/SemesterNumber

let DropdownMenuView: (cellBackgroundColor: UIColor, cellSelectionColor: UIColor, cellSeparatorColor: UIColor, cellTextLabelFont: UIFont?, cellTextLabelColor: UIColor, arrowPadding: CGFloat, animationDuration: NSTimeInterval, maskBackgroundColor: UIColor, maskBackgroundOpacity: CGFloat) =
    (cellBackgroundColor: UIColor(red: 120/255, green: 162/255, blue: 182/255, alpha: 1),
        cellSelectionColor: UIColor(red: 110/255, green: 115/255, blue: 120/255, alpha: 1), cellSeparatorColor: UIColor(red: 110/255, green: 110/255, blue: 120/255, alpha: 1), cellTextLabelFont: UIFont(name: "HelveticaNeue", size: 17), cellTextLabelColor: .whiteColor(),
    arrowPadding: 15, animationDuration: 0.4, maskBackgroundColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0), maskBackgroundOpacity: 0.3)


// Updates values if orientation was changed
func updateValues() {
    screenSize = UIScreen.mainScreen().bounds
    DropdownMenuViewCellHeight = screenSize.height/SemesterNumber
}

func updateSemesterNumber(number: Int) {
    SemesterNumber = CGFloat(number+2)
    updateValues()
}

// Check if comunication error
func errorOcurredIn(response: NSURLResponse?) -> Bool {
    guard let httpResponse = response as? NSHTTPURLResponse, resp = httpResponse.URL else  {
        return false
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

func createAlertView(title: String, text: String, viewController: UIViewController, handlers: [String: (UIAlertAction) -> ()]) {
    let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.Alert)
    for (title, handler) in handlers {
        alert.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: handler))
    }
    viewController.presentViewController(alert, animated: true, completion: nil)
}

