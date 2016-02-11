//
//  WaitingViewController.swift
//  KOSeek
//
//  Created by Alzhan on 11.11.15.
//  Copyright © 2015 Alzhan Turlybekov. All rights reserved.
//

import UIKit

class WaitingViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    var counter:Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            progressView.setProgress(fractionalProgress, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = "Logging In, please wait."
        progressView.setProgress(0, animated: true)
        progressView.hidden = true
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
            self.activityIndicator.startAnimating()
        })
    }
      
    override func viewDidAppear(animated: Bool) {
        KOSAPI.onComplete = {
            self.performSegueWithIdentifier("downloadCompleteSegue", sender: nil)
        }
        KOSAPI.increaseProgressBar = { value in
            self.counter += value
        }
        let response = LoginHelper.getAuthToken(username: SavedVariables.username!, password: SavedVariables.password!)
        SavedVariables.password = nil
        if response.success {
            progressView.hidden = false
            statusLabel.text = "Downloading data, please wait."
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                KOSAPI.downloadAllData(SavedVariables.cdh.backgroundContext!)
                OpenHoursDownloader.download()
            })
        } else {
            createAlertView("", text: response.error, viewController: self, handlers: ["OK": { action in
                self.performSegueWithIdentifier("failedLoginSegue", sender: nil)
                }])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
