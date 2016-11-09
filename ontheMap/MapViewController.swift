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
        
        let firstButton = UIBarButtonItem(image: UIImage(named: "Pin"), style: UIBarButtonItemStyle.plain,target: self, action: #selector(MapViewController.pinButtonTouchUp))
        let secondButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(MapViewController.refreshButtonTouchUp))
        self.navigationItem.rightBarButtonItems = [secondButton,firstButton]
        
        let object = UIApplication.shared.delegate
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
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.shared
            app.openURL(URL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
    @IBAction func logoutButton(_ sender: AnyObject) {
        
        OTMClient.sharedInstance().logoutUser() { (result, errorString) in
            if result {
               self.dismiss(animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: nil, message: "Network Error.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in}
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true) {}
            }
        }
    }
    
    func refreshButtonTouchUp (){
        let urlstring = OTMClient.Constants.ParseURLSecure
        OTMClient.sharedInstance().getStudentLocations(urlstring) { (success, locations , errorString) in
            if success {
                let object = UIApplication.shared.delegate
                let appDelegate = object as! AppDelegate
                appDelegate.studentInformation.removeAll(keepingCapacity: false)
                self.studentInformation.removeAll(keepingCapacity: false)
                if let locations = locations {
                    for location in locations {
                        let student = StudentInformation (dictionary: location)
                        appDelegate.studentInformation.append(student)
                    }
                    self.studentInformation = appDelegate.studentInformation
                    self.annotationsAdd()
                }
            } else {
                let alertController = UIAlertController(title: nil, message: "Faild to get data.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in}
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true) {}
            }
        }
    
    }
    func pinButtonTouchUp (){
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "InformationPostingView")
        self.present(controller, animated: true, completion: nil)
    }
}
