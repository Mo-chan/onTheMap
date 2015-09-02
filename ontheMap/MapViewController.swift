//
//  MapViewController.swift
//  ontheMap
//
//  Created by Mohammad Awwad on 8/30/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController :  UIViewController, MKMapViewDelegate {
    
    var studentInformation :[StudentInformation]!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstButton = UIBarButtonItem(image: UIImage(named: "Pin"), style: UIBarButtonItemStyle.Plain,target: self, action: "pinButtonTouchUp")
        let secondButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshButtonTouchUp")
        self.navigationItem.rightBarButtonItems = [secondButton,firstButton]
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        studentInformation = appDelegate.studentInformation
        annotationsAdd()    
    }
    
    func annotationsAdd(){
        var annotations = [MKPointAnnotation]()
        
        for dictionary in studentInformation {
            
            let lat = CLLocationDegrees(dictionary.latitude as! Double)
            let long = CLLocationDegrees(dictionary.longitude as! Double)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary.firstName as! String
            let last = dictionary.lastName as! String
            let mediaURL = dictionary.mediaURL as! String
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            println(annotationView.annotation.subtitle!)
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        let urlstring = OTMClient.Constants.BaseURLSecure + OTMClient.Methods.Session
        OTMClient.sharedInstance().logoutUser(urlstring) { (result, errorString) in
            if result {
               self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let alertController = UIAlertController(title: nil, message: "Network Error.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in}
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {}
            }
        }
    }
    
    func refreshButtonTouchUp (){
        let urlstring = OTMClient.Constants.ParseURLSecure
        OTMClient.sharedInstance().getStudentLocations(urlstring) { (success, locations , errorString) in
            if success {
                let object = UIApplication.sharedApplication().delegate
                let appDelegate = object as! AppDelegate
                appDelegate.studentInformation.removeAll(keepCapacity: false)
                self.studentInformation.removeAll(keepCapacity: false)
                if let locations = locations {
                    for location in locations {
                        var student = StudentInformation (dictionary: location)
                        appDelegate.studentInformation.append(student)
                    }
                    self.studentInformation = appDelegate.studentInformation
                    self.annotationsAdd()
                }
            } else {
                let alertController = UIAlertController(title: nil, message: "Faild to get data.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {}
            }
        }
    
    }
    func pinButtonTouchUp (){
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingView") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
}