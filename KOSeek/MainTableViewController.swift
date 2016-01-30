//
//  MainTableViewController.swift
//  KOSeek
//
//  Created by Alzhan on 30.01.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//

import UIKit

// Base class for all ViewControllers
class MainTableViewController: UITableViewController {
    
    var menuButton: UIBarButtonItem!
    var childFuncBeforeShowSideMenu: () -> () = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = TableViewBackgroundColor
        menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        menuButton.tintColor = MenuButtonTintColor
        if self.revealViewController() != nil {
            menuButton.target = self
            menuButton.action = "menuButtonPressed"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    func menuButtonPressed() {
        childFuncBeforeShowSideMenu()
        UIApplication.sharedApplication().sendAction("revealToggle:", to: self.revealViewController(), from: self, forEvent: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        SavedVariables.sideMenuViewController?.view.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateValues()
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.7
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView.numberOfRowsInSection(section) == 0 {
            tableView.scrollEnabled = false
            return nil
        }
        let line = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 0.7))
        line.backgroundColor = .grayColor()
        line.alpha = 0.5
        let view = UIView()
        view.backgroundColor = TableViewBackgroundColor
        view.addSubview(line)
        return view
    }
    
}
