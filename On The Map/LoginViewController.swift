//
//  LoginViewController.swift
//  On The Map
//
//  Created by Vince Chan on 10/1/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController  {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    @IBAction func facebookLoginButtonTouch(sender: AnyObject) {
        
        let manager = FBSDKLoginManager()
        manager.logInWithReadPermissions(["public_profile"], fromViewController: self) {
            (result, error) in
            
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showError(self.view, error: "Error login with facebook \(error)")
                }
                return
            }
            else if (result.isCancelled) {
                // user cancelled the login
            }
            else {
                UdacityClient.sharedInstance().loginWithFacebook(result.token.tokenString) {
                    (success, error) in
                    
                    if error != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.showError(self.view, error: "Error login with facebook \(error)")
                        }
                        return
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabViewController")
                            self.presentViewController(controller, animated: true, completion: nil)
                        }
                    }
                }
                
            }
        }
    }
    
    @IBAction func loginButtonTouch(sender: UIButton) {
        guard emailTextField.text != nil &&
            emailTextField.text != "" else {
                showError(emailTextField, error: "Email is required")
                return
        }
        
        guard passwordTextField.text != nil &&
            passwordTextField.text != "" else {
                showError(passwordTextField, error: "Password is required")
                return
        }
        
        UdacityClient.sharedInstance().login(emailTextField.text!, password: passwordTextField.text!) {
            (success, error) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showError(self.view, error: "\(error!)")
                }
                return
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabViewController")
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    // redirect the user to the signup url
    @IBAction func signUpButtonTouch(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
    }
    
    // Show an error by displaying an alert and shaking the screen
    func showError(control: UIView, error: String) {
        shake(control)
        
        let alert = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // shake the screen to draw user attention
    // This function is from: http://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift
    func shake(control: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(control.center.x - 10, control.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(control.center.x + 10, control.center.y))
        control.layer.addAnimation(animation, forKey: "position")
    }
}
