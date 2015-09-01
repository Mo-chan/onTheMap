//
//  LoginViewController.swift
//  ontheMap
//
//  Created by Mohammad Awwad on 8/28/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var debugText: UILabel!
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        session = NSURLSession.sharedSession()
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardDismissRecognizer()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardDismissRecognizer()
        unsubscribeToKeyboardNotifications()
    }
    
    //Start: Add and Remove keyboard on tap Functions
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    // End
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        
        if emailField.text.isEmpty {
            debugText.text = "Username Empty."
        }
        else if PasswordField.text.isEmpty{
            debugText.text = "Password Empty."
        }
        else {
            let param = [emailField.text!, PasswordField.text!]
            OTMClient.sharedInstance().LoginWithUser(param) { (result, errorString) in
                if result {
                    self.completeLogin()
                } else {
                    self.displayError(errorString)
                }
            }
        }
        
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugText.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapNavigationController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if errorString == "Wrong" {
                let alertController = UIAlertController(title: nil, message: "Incorrect Username or Password.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                alertController.addAction(OKAction)

                self.presentViewController(alertController, animated: true) {}
            }
            else if errorString == "Faild to get user data" {
                let alertController = UIAlertController(title: nil, message: "Faild to download user data.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {}
            
            }
            else if errorString == "Network Error" {
                let alertController = UIAlertController(title: nil, message: "Network Error.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {}
            
            }
            else if errorString == "Faild to download" {
                let alertController = UIAlertController(title: nil, message: "Faild to get data.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {}
            
            }
        })
    }
    
    @IBAction func signupButtonTouch(sender: AnyObject) {
        
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: OTMClient.Constants.Signin)!)
    }

    @IBAction func facebookButtonTouch(sender: AnyObject) {
        
        let webAuthViewController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        webAuthViewController.urlRequest = NSURLRequest(URL: NSURL(string: OTMClient.Constants.Signin)!)
        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(webAuthNavigationController, animated: true, completion: nil)
        })
    }
    
    // Start: Keyboard Adjustments Functions
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    // End
}

