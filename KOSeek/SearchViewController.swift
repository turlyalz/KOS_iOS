//
//  SearchViewController.swift
//  KOSeek
//
//  Created by Alzhan on 28.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var teachers: [Person]?
    var filtered: [Person]?
    var searchBar: UISearchBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self
            menuButton.action = "menuButtonPressed"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        teachers = Database.getPersons(SavedVariables.cdh!.managedObjectContext)
        createSearchBar()
        if let searchText = SavedVariables.searchText, _ = searchBar {
            searchBar(searchBar!, textDidChange: searchText)
            searchBar!.text = searchText
        }
    }
      
    func createSearchBar() {
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
        searchBar?.barTintColor = DropdownMenuView.cellBackgroundColor
        searchBar?.placeholder = "type to start"
        searchBar?.showsCancelButton = true
        searchBar?.tintColor = BGHeaderColor
        searchBar?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        SavedVariables.sideMenuViewController?.view.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func menuButtonPressed() {
        self.view.endEditing(true)
        UIApplication.sharedApplication().sendAction("revealToggle:", to: self.revealViewController(), from: self, forEvent: nil)
    }
    
    // MARK: - Search bar delegate
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = teachers?.filter({ (person) -> Bool in
            if person.username == SavedVariables.username {
                return false
            }
            guard let firstName = person.firstName, lastName = person.lastName else {
                return false
            }
            var tmp: NSString = firstName
            var range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            if range.location == NSNotFound {
                tmp = lastName
                range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            }
            return range.location != NSNotFound
        })
        SavedVariables.searchText = searchText
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let uFiltered = filtered else {
            return 0
        }
        return uFiltered.count
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        updateValues()
        searchBar?.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 44)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
        view.addSubview(searchBar!)
        return view
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let title = filtered?[indexPath.row].title {
            cell.textLabel?.text = title
        } else {
            if let firstName = filtered?[indexPath.row].firstName, lastName = filtered?[indexPath.row].lastName {
                cell.textLabel?.text = firstName + " " + lastName
            }
        }
        return cell
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
    }
}
