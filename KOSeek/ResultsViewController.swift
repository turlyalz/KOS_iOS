//
//  ResultsViewController.swift
//  KOSeek
//
//  Created by Alzhan on 28.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class ResultsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var subjectsTableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var pickerData: [(String, String)] = []
    var subjectsTableViewDelegate: SubjectsTableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        subjectsTableViewDelegate = subjectsTableView as? SubjectsTableViewDelegate
        subjectsTableView.dataSource = subjectsTableViewDelegate
        subjectsTableView.delegate = subjectsTableViewDelegate
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerData = SavedVariables.semesterIDNameDict.sort({$0.0 < $1.0})
        subjectsTableViewDelegate?.updateActualSubjects(pickerData[0].0)
    }
    
    override func viewDidAppear(animated: Bool) {
        SavedVariables.sideMenuViewController?.view.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Delegates and data sources for picker view
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Montserrat", size: 18)
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        pickerLabel?.text = pickerData[row].1
        return pickerLabel!
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        subjectsTableViewDelegate?.updateActualSubjects(pickerData[row].0)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateValues()
        self.subjectsTableViewDelegate?.reloadData()
    }
}

