//
//  TabItemViewController.swift
//  On The Map
//
//  Created by Vince Chan on 11/24/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import UIKit

/*
 Base class for the map view and table view
 The map view and table view has the same navigation bar buttons that peform the same functions, this base
 class enables the two to share code
 */
class TabItemViewController: UIViewController {
    
    // Log user out
    func logout() {
        UdacityClient.sharedInstance().logout()
        
        let manager = FBSDKLoginManager()
        manager.logOut()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Present the PostLocationViewController to let use share location
    func upload() {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("PostLocationViewController")
        let navigation = UINavigationController(rootViewController: controller!)
        navigationController?.presentViewController(navigation, animated: true, completion: nil)
    }
    
    // Create the navigation bar buttons
    func createNavigationButtons() {
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh")
        let uploadButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "upload")
        navigationItem.rightBarButtonItems = [refreshButton, uploadButton]
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        navigationItem.leftBarButtonItem = logoutButton
    }
    
    // Display error with alert
    func showError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func openUrl(urlString : String) {
        if let url = NSURL(string: urlString) {
            let app = UIApplication.sharedApplication()
            app.openURL(url)
        }
    }
}
