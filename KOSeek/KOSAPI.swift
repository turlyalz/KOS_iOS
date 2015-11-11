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
    
    private init(){ }
    
    class func downloadAllData() {
        downloadPersonInfo()
        onComplete()
    }
    
    class func downloadPersonInfo() {
       //let xml = SWXMLHash.parse(xmlToParse)
    }
    
}