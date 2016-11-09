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

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
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
        topSecond.isHidden = true
        bottomSecond.isHidden = true
        topFirst.isHidden = false
        bottomFirst.isHidden = false
        
        linkText.text = "Enter a Link to Share Here"
        linkText.textAlignment = NSTextAlignment.center
        linkText.delegate = self
        
        locationText.text = "Enter Your Location Here"
        locationText.textAlignment = NSTextAlignment.center
        locationText.delegate = self
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(InformationPostingViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardDismissRecognizer()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardDismissRecognizer()
        unsubscribeToKeyboardNotifications()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
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
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    // End
    
    @IBAction func cancelFirst(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelSecond(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func findOnMap(_ sender: AnyObject) {
        
        if !locationText.text!.isEmpty {
            let geocoder = CLGeocoder()
            address = locationText.text as AnyObject?
            let addressString = locationText.text
            activityIndicatorView.startAnimating()
            self.bottomFirst.alpha = 0.5
            geocoder.geocodeAddressString(addressString!, completionHandler:  {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if let _ = error {
                    OperationQueue.main.addOperation {
                        let alertController = UIAlertController(title: nil, message: "Can't Find Place.", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                            self.activityIndicatorView.stopAnimating()
                            self.bottomFirst.alpha = 1
                            self.locationText.text = "Enter Your Location Here"
                        }
                        alertController.addAction(OKAction)
                        
                        self.present(alertController, animated: true) {}
                    }
                }
                
                if let placemark = placemarks?[0] {
                    
                    self.latitude = placemark.location!.coordinate.latitude as AnyObject?
                    self.longitude = placemark.location!.coordinate.longitude as AnyObject?
                    self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                    self.mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
                    self.activityIndicatorView.stopAnimating()
                    
                    self.topSecond.isHidden = false
                    self.bottomSecond.isHidden = false
                    self.topFirst.isHidden = true
                    self.bottomFirst.isHidden = true
                    
                    print(placemark.location!.coordinate.latitude)
                    print(placemark.location!.coordinate.longitude)
                    
                }
            } as! CLGeocodeCompletionHandler)
        }
    }
    @IBAction func submitButton(_ sender: AnyObject) {
        
        if !linkText.text!.isEmpty {
            
            link = linkText.text as AnyObject?
            let arrayBody = [address!,link!,latitude!,longitude!]
            let urlstring = OTMClient.Constants.ParseURLSecure
            OTMClient.sharedInstance().postStudentLocation(urlstring, parameters: arrayBody) { (success, errorString) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    OperationQueue.main.addOperation {
                        let alertController = UIAlertController(title: nil, message: "Network Faild.", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(OKAction)
                        
                       self.present(alertController, animated: true) {}
                    }
                }
            }
        }
    }
    
    // Start: Keyboard Adjustments Functions
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(InformationPostingViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InformationPostingViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
