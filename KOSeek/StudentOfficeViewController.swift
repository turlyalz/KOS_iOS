//
//  StudentOfficeViewController.swift
//  KOSeek
//
//  Created by Alzhan on 01.02.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//

import Foundation

class StudentOfficeViewController: TableContentViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let table = OpenHoursDownloader.table {
            super.data = table
            super.header = ["Day", "From", "Till", "From", "Till"]
        }
    }
}
