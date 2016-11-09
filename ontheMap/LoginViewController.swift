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
    var session: URLSession!
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        session = URLSession.shared
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailField.text = ""
        PasswordField.text = ""
        addKeyboardDismissRecognizer()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    // End
    
    @IBAction func loginButtonTouch(_ sender: AnyObject) {
        
        if emailField.text!.isEmpty {
            debugText.text = "Username Empty."
        }
        else if PasswordField.text!.isEmpty{
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
        DispatchQueue.main.async(execute: {
            self.debugText.text = ""
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapNavigationController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        })
    }
    
    func displayError(_ errorString: String?) {
        DispatchQueue.main.async(execute: {
            
            switch errorString! {
            
            case "Wrong":
                let alertController = UIAlertController(title: nil, message: "Incorrect Username or Password.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true) {}
            case "Faild to get user data":
                let alertController = UIAlertController(title: nil, message: "Faild to download user data.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true) {}
            case "Network Error" :
                let alertController = UIAlertController(title: nil, message: "No Internet Connection.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true) {}
            case "Faild to download" :
                let alertController = UIAlertController(title: nil, message: "Faild to get data.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true) {}
            default:
                print("Unknown error")
                
            }
        })
    }
    
    @IBAction func signupButtonTouch(_ sender: AnyObject) {
        
        let app = UIApplication.shared
        app.openURL(URL(string: OTMClient.Constants.Signin)!)
    }

    @IBAction func facebookButtonTouch(_ sender: AnyObject) {
        
        let webAuthViewController = self.storyboard!.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webAuthViewController.urlRequest = URLRequest(url: URL(string: OTMClient.Constants.Signin)!)
        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
        
        DispatchQueue.main.async(execute: {
            self.present(webAuthNavigationController, animated: true, completion: nil)
        })
    }
    
    // Start: Keyboard Adjustments Functions
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        if keyboardAdjusted == true {
            view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    // End
}

