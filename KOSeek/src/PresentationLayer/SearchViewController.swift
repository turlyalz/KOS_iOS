//
//  SearchViewController.swift
//  KOSeek
//
//  Created by Alzhan on 28.10.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class SearchViewController: MainTableViewController, UISearchBarDelegate {
   
    private var teachers: [Person]?
    private var filtered: [Person]?
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teachers = Database.getPersons(SavedVariables.cdh.managedObjectContext)
        initSearchBar()
        if let searchText = SavedVariables.searchText {
            searchBar(searchBar, textDidChange: searchText)
            searchBar.text = searchText
        }
        SavedVariables.searchViewController = self
    }
      
    func initSearchBar() {
        searchBar.barTintColor = DropdownMenuView.cellBackgroundColor
        searchBar.placeholder = typeToStartString
        searchBar.showsCancelButton = true
        searchBar.tintColor = BGHeaderColor
        searchBar.delegate = self
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
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
        searchBar.becomeFirstResponder()
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let uFiltered = filtered else {
            return 0
        }
        return uFiltered.count
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        searchBar.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 64)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 64))
        view.addSubview(searchBar)
        return view
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        if let email = filtered?[indexPath.row].email {
            let pasteBoard = UIPasteboard.generalPasteboard()
            pasteBoard.string = email
        }
        createAlertView("", text: pasteBoardMessage, viewController: self, handlers: [ "OK": {_ in} ])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let title = filtered?[indexPath.row].title, email = filtered?[indexPath.row].email {
            cell.textLabel?.numberOfLines = 2
            cell.textLabel?.text = title + "\n" + email
        } else {
            if let firstName = filtered?[indexPath.row].firstName, lastName = filtered?[indexPath.row].lastName, email = filtered?[indexPath.row].email {
                cell.textLabel?.text = firstName + " " + lastName + "\n" + email
            }
        }
        return cell
    }
}
