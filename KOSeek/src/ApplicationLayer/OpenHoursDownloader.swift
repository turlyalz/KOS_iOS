//
//  OpenHoursDownloader.swift
//  KOSeek
//
//  Created by Alzhan on 02.02.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//

import Foundation
import SWXMLHash

class OpenHoursDownloader {
    
    static private let URL = "https://fit.cvut.cz/student/studijni/kontakt"
    static var data: NSData? = nil
    static var table: [[String]]? = nil
    
    private init() {}
    
    class func download() {
        let url = NSURL(string: URL)
        var running = false
        var failed = false
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, _, error) in
            if error != nil {
                print("error=\(error)")
                failed = true
                return
            }
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            self.data = data
            if let data = data {
                Database.setOpenHoursData(SavedVariables.cdh.backgroundContext!, data: data)
            }
            running = false
        }
        running = true
        task.resume()
        var count = 0
        while running && !failed && count < MaxWaitForResponse {
            print("waiting for response...")
            sleep(1)
            count++
        }
        parse()
    }
    
    class func parse() {
        guard let data = data else {
            return
        }
        let xml = SWXMLHash.parse(data)
        parser(xml)
    }
    
    class func parser(xml: XMLIndexer) {
        do {
            let content = try xml["html"]["body"]["div"].withAttr("class", "center")["div"].withAttr("id", "wrapper")["div"]
            let tbody = try content["div"].withAttr("class", "webcontent")["div"].withAttr("class", "content-text hasleft")["div"]["table"][1]["tbody"]
            table = []
            for row in 2...6 {
                if let day = daysHeader[row-2] {
                    var columns: [String] = [day]
                    for column in 1...4 {
                        var trimmedText: String = ""
                        if row == 2 {
                            if let text = tbody["tr"][row]["td"][column+1].element?.text {
                                trimmedText = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                            }
                        } else {
                            if let text = tbody["tr"][row]["td"][column].element?.text {
                                trimmedText = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                            }
                        }
                        columns.append(trimmedText)
                    }
                    table?.append(columns)
                    }
            }
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}
