//
//  PostLocationViewController.swift
//  On The Map
//
//  Created by Vince Chan on 10/27/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: UIViewController, UITextFieldDelegate {
    
    let topViewHeight = CGFloat(100)
    let bottomViewHeight = CGFloat(60)
    let darkColor = UIColor(red: 81/255, green: 137/255, blue: 180/255, alpha: 1)
    let lightColor = UIColor(red: 217/255, green: 217/255, blue: 213/255, alpha: 1)
    
    var originalNavbarShadowImage : UIImage?
    var originalNavbarBackgroundImage : UIImage?
    
    var topView : UIView!
    var middleView : UIView!
    var bottomView: UIView!
    var locationTextField : UITextField!
    var findButton : UIButton!
    let geoCoder = CLGeocoder()
    
    var mapView : MKMapView!
    var locationPlacemark : MKPlacemark!
    var urlTextField : UITextField!
    var submitButton: UIButton!
    
    var progressIndicatorView : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure navigation bar
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")
        navigationItem.rightBarButtonItem = cancelButton
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        makeNavigationBarTransparent()
        
        // create the controls programmatically
        createContainerViews()
        createPromptLocationViews()
        createSubmitLocationViews()
    }
    
    // Make NavigationBar transparent by removing the shawdow image and background image
    func makeNavigationBarTransparent() {
        originalNavbarShadowImage = UINavigationBar.appearance().shadowImage
        originalNavbarBackgroundImage = UINavigationBar.appearance().backgroundImageForBarPosition(
            UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(
            UIImage(),
            forBarPosition: UIBarPosition.Any,
            barMetrics: UIBarMetrics.Default)
    }
    
    // Restore the NavigationBar appearance by restoring the original shadow image and background image
    func undoMakeNavigationBarTransparent() {
        UINavigationBar.appearance().shadowImage = originalNavbarShadowImage
        UINavigationBar.appearance().setBackgroundImage(
            originalNavbarBackgroundImage,
            forBarPosition: UIBarPosition.Any,
            barMetrics: UIBarMetrics.Default)
    }
    
    override func viewWillDisappear(animated: Bool) {
        undoMakeNavigationBarTransparent()
    }
    
    override func viewWillAppear(animated: Bool) {
        configureViewsForPromptLocation()
    }
    
    // Create the top, middle and bottom container views
    func createContainerViews() {
        let navigationBarHeight = navigationController?.navigationBar.frame.size.height ?? 0
        let appHeight = view.frame.height - navigationBarHeight
        let appWidth = view.frame.width
        
        // create top view
        topView = UIView(frame: CGRect(x: 0, y: navigationBarHeight, width: appWidth, height: topViewHeight))
        view.addSubview(topView)
        
        // create bottom view
        bottomView = UIView(frame: CGRect(x: 0, y: topView.frame.minY + (appHeight  - bottomViewHeight),
            width: appWidth, height: bottomViewHeight))
        view.addSubview(bottomView)
        
        // create middle view
        middleView = UIView(frame: CGRect(x: 0, y: topView.frame.minY + topViewHeight,
            width: appWidth, height: appHeight - topViewHeight - bottomViewHeight))
        view.addSubview(middleView)
    }
    
    // Create the controls for prompting location
    func createPromptLocationViews() {
        var currentY =  CGFloat(5)
        let label1 = UILabel(frame: CGRect(x: 0, y: currentY, width: topView.frame.width, height: 30))
        label1.text = "Where are you"
        label1.textAlignment = NSTextAlignment.Center
        label1.textColor = UIColor(red: 118/255, green: 139/255, blue: 161/255, alpha: 1)
        topView.addSubview(label1)
        currentY += 30
        
        let label2 = UILabel(frame: CGRect(x: 0.0, y: currentY, width: topView.frame.width, height: 30))
        label2.text = "studying"
        label2.textAlignment = NSTextAlignment.Center
        label2.textColor = UIColor.purpleColor()
        topView.addSubview(label2)
        currentY += 30
        
        let label3 = UILabel(frame: CGRect(x: 0.0, y: currentY, width: topView.frame.width, height: 30))
        label3.text = "today?"
        label3.textAlignment = NSTextAlignment.Center
        label3.textColor = UIColor(red: 118/255, green: 139/255, blue: 161/255, alpha: 1)
        topView.addSubview(label3)
        
        locationTextField = UITextField(frame: CGRect(x: 0, y: 0,
            width: middleView.frame.width, height: middleView.frame.height))
        locationTextField.autocapitalizationType = UITextAutocapitalizationType.Words
        locationTextField.textColor = UIColor.whiteColor()
        locationTextField.textAlignment = NSTextAlignment.Center
        locationTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
        locationTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter Your Location Here",
            attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        locationTextField.clearsOnBeginEditing = true
        locationTextField.delegate = self
        middleView.addSubview(locationTextField)
        
        findButton = UIButton(frame: CGRect(x: 0, y: 0, width: 220, height: 30))
        findButton.center = CGPoint(x: bottomView.frame.width / 2, y: bottomView.frame.height / 2)
        findButton.setTitle("Find on the Map", forState: UIControlState.Normal)
        findButton.layer.cornerRadius = 6
        findButton.backgroundColor = UIColor.lightGrayColor()
        findButton.addTarget(self, action: "find", forControlEvents: UIControlEvents.TouchUpInside)
        bottomView.addSubview(findButton)
    }
    
    // Create the controls for submitting location
    func createSubmitLocationViews() {
        urlTextField = UITextField(frame: CGRect(x: 0, y: topView.frame.minY + 30,
            width: topView.frame.width, height: topView.frame.height - 30))
        urlTextField.textColor = UIColor.whiteColor()
        urlTextField.textAlignment = NSTextAlignment.Center
        urlTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
        urlTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter a Link to Share Here",
            attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        urlTextField.keyboardType  = UIKeyboardType.URL
        urlTextField.clearsOnBeginEditing = true
        urlTextField.delegate = self
        urlTextField.autocorrectionType = UITextAutocorrectionType.No
        urlTextField.autocapitalizationType = UITextAutocapitalizationType.None
        view.addSubview(urlTextField)
        
        mapView = MKMapView(frame: CGRect(x: 0, y: topView.frame.minY + topView.frame.height,
            width: middleView.frame.width,
            height: middleView.frame.height + bottomView.frame.height))
        // disable user interaction with the map
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        view.addSubview(mapView)
        
        submitButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 25))
        submitButton.center = CGPoint(x: bottomView.frame.width / 2, y: bottomView.frame.height / 2)
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.layer.cornerRadius = 6
        submitButton.backgroundColor = UIColor.whiteColor()
        submitButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        submitButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Highlighted)
        submitButton.addTarget(self, action: "submit", forControlEvents: UIControlEvents.TouchUpInside)
        bottomView.addSubview(submitButton)
    }
    
    // Configure the views to let user enter location
    func configureViewsForPromptLocation() {
        view.backgroundColor = lightColor
        
        middleView.backgroundColor = darkColor
        
        urlTextField.hidden = true
        mapView.hidden = true
        submitButton.hidden = true
    }
    
    // Configure the views to let user submit location
    func configureViewsForSubmitLocation() {
        view.backgroundColor = darkColor
        
        topView.hidden = true
        middleView.hidden = true
        findButton.hidden = true
        bottomView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        view.bringSubviewToFront(bottomView)
        
        urlTextField.hidden = false
        view.bringSubviewToFront(urlTextField)
        
        submitButton.hidden = false
        
        mapView.hidden = false
        mapView.addAnnotation(locationPlacemark!)
        let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        let region = MKCoordinateRegionMake((locationPlacemark!.location?.coordinate)!, span)
        mapView.setRegion(region, animated: true)
    }
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func find() {
        if (locationTextField.text == nil || locationTextField.text == "") {
            showError("Must enter a location")
            return
        }
        
        showProgressIndicator()
        geoCoder.geocodeAddressString(locationTextField.text!) {
            (placemarks, error) in
            
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.hideProgressIndicator()
                    self.showError("Error geocoding location: \(self.locationTextField.text!)")
                }
            }
            else if let placemark = placemarks?[0] {
                self.locationPlacemark = MKPlacemark(placemark: placemark)
                dispatch_async(dispatch_get_main_queue()) {
                    self.hideProgressIndicator()
                    self.configureViewsForSubmitLocation()
                }
            }
        }
    }
    
    func showProgressIndicator() {
        progressIndicatorView = UIView(frame: view.frame)
        progressIndicatorView.center = view.center
        progressIndicatorView.alpha = 0.5
        progressIndicatorView.backgroundColor = UIColor.blackColor()
        view.addSubview(progressIndicatorView)
        view.bringSubviewToFront(progressIndicatorView)
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        indicator.center = progressIndicatorView.center
        indicator.startAnimating()
        progressIndicatorView.addSubview(indicator)
    }
    
    func hideProgressIndicator() {
        progressIndicatorView.removeFromSuperview()
    }
    
    func submit() {
        if (urlTextField.text == nil || urlTextField.text == "") {
            showError("Must enter a Url")
            return
        }
        
        UdacityClient.sharedInstance().getStudentName(UdacityClient.sharedInstance().UserId!) {
            (first, last, error) in
            if (error == nil) {
                ParseClient.sharedInstance().addOrUpdateLocation(UdacityClient.sharedInstance().UserId!, firstName: first!, lastName: last!,longitude: self.locationPlacemark.coordinate.longitude, latitude: self.locationPlacemark.coordinate.latitude, location: self.locationTextField.text!, url: self.urlTextField.text!) {
                    (success, addError) in
                    
                    if (addError != nil) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.showError("Error posting location: \(addError!)")
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showError("Error posting location: \(error!)")
                }
            }
        }
    }
    
    // Show an error message with alert
    func showError(error: String) {
        let alert = UIAlertController(title: "", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
