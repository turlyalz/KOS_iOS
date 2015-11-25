//
//  ResultsViewController.swift
//  KOSeek
//
//  Created by Alzhan on 28.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class ExamsViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var subjects: [String] = []
    var dropdownMenuView: BTNavigationDropdownMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self
            menuButton.action = "menuButtonPressed"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        guard let semester = SavedVariables.currentSemester, subjects = Database.getSubjectsBy(semester: semester, context: SavedVariables.cdh!.managedObjectContext) else {
            return
        }
        
        for subject in subjects {
            if let code = subject.code {
                self.subjects.append(code)
            }
        }
        
        setupDropdownMenu()
    }
    
    func menuButtonPressed() {
        if dropdownMenuView?.getShown() == true {
            dropdownMenuView?.hideMenu()
            dropdownMenuView?.setShown(false)
        }
        UIApplication.sharedApplication().sendAction("revealToggle:", to: self.revealViewController(), from: self, forEvent: nil)
    }
    
    func setupDropdownMenu() {
        if let _ = subjects.first {
            dropdownMenuView = BTNavigationDropdownMenu(title: subjects.first!, items: subjects, navController: self.navigationController)
            dropdownMenuView?.cellHeight = DropdownMenuViewCellHeight
            dropdownMenuView?.cellBackgroundColor =  DropdownMenuView.cellBackgroundColor
            dropdownMenuView?.cellSelectionColor = DropdownMenuView.cellSelectionColor
            dropdownMenuView?.cellTextLabelColor = DropdownMenuView.cellTextLabelColor
            dropdownMenuView?.cellSeparatorColor = DropdownMenuView.cellSeparatorColor
            dropdownMenuView?.arrowPadding = DropdownMenuView.arrowPadding
            dropdownMenuView?.animationDuration = DropdownMenuView.animationDuration
            dropdownMenuView?.maskBackgroundColor = DropdownMenuView.maskBackgroundColor
            dropdownMenuView?.maskBackgroundOpacity = DropdownMenuView.maskBackgroundOpacity
            dropdownMenuView?.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
                //let semester = self.semesterIDNameDict[indexPath].0
                //self.updateSubjects(semester)
            }
            self.navigationItem.titleView = dropdownMenuView
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        SavedVariables.sideMenuViewController?.view.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateValues()
        dropdownMenuView?.cellHeight = DropdownMenuViewCellHeight
        if dropdownMenuView?.getShown() == true {
            dropdownMenuView?.hideMenu()
            dropdownMenuView?.setShown(false)
        }
    }
    
}

