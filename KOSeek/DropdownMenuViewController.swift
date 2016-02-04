//
//  DropdownMenuViewController.swift
//  KOSeek
//
//  Created by Alzhan on 04.02.16.
//  Copyright © 2016 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class DropdownMenuViewController: TableContentViewController {

    private var dropdownMenuView: BTNavigationDropdownMenu?
    var dropdownData: [String] = []
    var didSelectItemHandler: (indexPath: Int) -> () = {_ in}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.childFuncBeforeShowSideMenu =  {
            if self.dropdownMenuView?.getShown() == true {
                self.dropdownMenuView?.hideMenu()
                self.dropdownMenuView?.setShown(false)
            }
        }
    }
    
    func setupDropdownMenu() {
        if dropdownData.count == 0 {
            return
        }
        dropdownMenuView = BTNavigationDropdownMenu(title: dropdownData.first!, items: dropdownData, navController: self.navigationController)
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
            self.didSelectItemHandler(indexPath: indexPath)
        }
        self.navigationItem.titleView = dropdownMenuView
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        dropdownMenuView?.cellHeight = DropdownMenuViewCellHeight
        if dropdownMenuView?.getShown() == true {
            dropdownMenuView?.hideMenu()
            dropdownMenuView?.setShown(false)
        }
    }
}
