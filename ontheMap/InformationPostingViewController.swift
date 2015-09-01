//
//  InformationPostingViewController.swift
//  ontheMap
//
//  Created by Mohammad Awwad on 8/31/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class InformationPostingViewController: UIViewController, MKMapViewDelegate,UITextFieldDelegate {
    
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var linkText: UITextField!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var topSecond: UIView!
    @IBOutlet weak var bottomSecond: UIView!
    @IBOutlet weak var topFirst: UIView!
    @IBOutlet weak var bottomFirst: UIView!
    
    var latitude : AnyObject? = nil
    var longitude : AnyObject? = nil
    var link: AnyObject? = nil
    var address: AnyObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topSecond.hidden = true
        bottomSecond.hidden = true
        topFirst.hidden = false
        bottomFirst.hidden = false
        
        linkText.text = "Enter a Link to Share Here"
        linkText.textAlignment = NSTextAlignment.Center
        linkText.delegate = self
        
        locationText.text = "Enter Your Location Here"
        locationText.textAlignment = NSTextAlignment.Center
        locationText.delegate = self
        
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "Enter a Link to Share Here" || textField.text == "Enter Your Location Here" {
            textField.text = ""
        }
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
    
    @IBAction func cancelFirst(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancelSecond(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func findOnMap(sender: AnyObject) {
        
        if !locationText.text.isEmpty {
            var geocoder = CLGeocoder()
            address = locationText.text
            let addressString = locationText.text
            geocoder.geocodeAddressString(addressString, completionHandler:  {(placemarks: [AnyObject]!, error: NSError!) -> Void in
               //alert
                println(error)
                if let placemark = placemarks?[0] as? CLPlacemark {
                    
                    self.latitude = placemark.location.coordinate.latitude
                    self.longitude = placemark.location.coordinate.longitude
                    self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                    self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
                    
                    
                    self.topSecond.hidden = false
                    self.bottomSecond.hidden = false
                    self.topFirst.hidden = true
                    self.bottomFirst.hidden = true
                    
                    println(placemark.location.coordinate.latitude)
                    println(placemark.location.coordinate.longitude)
                    
                }
            })
        }
    }
    @IBAction func submitButton(sender: AnyObject) {
        
        if !linkText.text.isEmpty {
            
            link = linkText.text
            var arrayBody = [address!,link!,latitude!,longitude!]
            let urlstring = OTMClient.Constants.ParseURLSecure
            OTMClient.sharedInstance().postStudentLocation(urlstring, parameters: arrayBody) { (success, errorString) in
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: nil, message: "Network Faild.", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alertController.addAction(OKAction)
                    
                    self.presentViewController(alertController, animated: true) {}
                }
            }
        }
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