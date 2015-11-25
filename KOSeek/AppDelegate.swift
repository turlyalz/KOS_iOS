//
//  AppDelegate.swift
//  KOSeek
//
//  Created by Alzhan on 11.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    //lazy var coreDataStack = CoreDataStack()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        SavedVariables.cdh = self.cdh
        setSavedVariables()
        return true
    }
    
    func setSavedVariables() {
        let response = Database.getSavedVariablesFrom(context: self.cdh.managedObjectContext)
        if let username = response.username, currentSemester = response.currentSemester {
            SavedVariables.username = username
            SavedVariables.currentSemester = currentSemester
            if let semesters = Database.getSemestersFrom(context: self.cdh.managedObjectContext) {
                for semester in semesters {
                    if let id = semester.id, name = semester.name {
                        SavedVariables.semesterIDNameDict[id] = name
                    }
                }
            }
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let exampleViewController: SWRevealViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
            
            self.window?.rootViewController = exampleViewController
            self.window?.makeKeyAndVisible()
        }

    }
    
    // #pragma mark - Core Data Helper
    
    lazy var cdstore: CoreDataStore = {
        let cdstore = CoreDataStore()
        return cdstore
    }()
    
    lazy var cdh: CoreDataHelper = {
        let cdh = CoreDataHelper()
        return cdh
    }()
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        self.cdh.saveContext()
    }
    
}

