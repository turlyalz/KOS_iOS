//
//  KOSAPI.swift
//  KOSeek
//
//  Created by Alzhan on 11.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import Foundation
import UIKit


class KOSAPI {
    
    static var onComplete: (() -> Void)!
    private static let baseURL = "https://kosapi.fit.cvut.cz/api/3"
    
    private init(){ }
    
    class func downloadAllData() {
        downloadPersonInfo()
        onComplete()
    }
    
    class func downloadPersonInfo() {
        let extensionURL = "/students/" + SavedVariables.username! + "?access_token=" + LoginHelper.accessToken + "&lang=cs"
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + extensionURL)!)
        request.HTTPMethod = "GET"
        print("Request = \(request)")
       
        var failed = false
        var running = false
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, _, error in
            
            if error != nil {
                print("error=\(error)")
                failed = true
                return
            }
            
            if let uData = data {
                let xml = SWXMLHash.parse(uData)
                print(xml["atom:entry"]["atom:content"]["firstName"].element?.text)
            }
            
            
            running = false
        }
        running = true
        task.resume()
        
        while running && !failed {
            //print("waiting for response...")
        }
        
        if failed || LoginHelper.errorOcurredIn(task.response) {
            print("Unable to download")
        }
    }
    
}