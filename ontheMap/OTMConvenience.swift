//
//  OTMConvenience.swift
//  ontheMap
//
//  Created by Mohammad Awwad on 8/28/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
import Foundation

extension OTMClient {
    
    func LoginWithViewController(hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {

    }
    
    func LoginWithUser(parameters : [String],completionHandler: (result: Bool, error: String?) -> Void) {
        
        let Body : [String:AnyObject] = [
            
            OTMClient.ParameterKeys.Username: parameters[0],
            OTMClient.ParameterKeys.Password: parameters[1]
            
        ]
        let jsonBody = ["udacity": Body]
        var urlstring = OTMClient.Constants.BaseURLSecure + OTMClient.Methods.Session
        
        getSession(urlstring, jsonBody: jsonBody) { (success, sessionID, userID, errorString) in
            
            if success {
                self.sessionID = sessionID
                self.userID = userID
                urlstring = OTMClient.Constants.BaseURLSecure + OTMClient.Methods.User + self.userID!
                
                self.getUserData(urlstring) { (success, lastName, firstName, errorString) in
                
                    if success {
                        
                        self.lastName = lastName
                        self.firstName = firstName
                        
                        urlstring = OTMClient.Constants.ParseURLSecure
                        
                        self.getStudentLocations(urlstring){  (success, locations , errorString) in
                            if success {
                                
                                let object = UIApplication.sharedApplication().delegate
                                let appDelegate = object as! AppDelegate
                                appDelegate.studentInformation = [StudentInformation] ()
                                if let locations = locations {
                                    for location in locations {
                                        let student = StudentInformation (dictionary: location)
                                        appDelegate.studentInformation.append(student)
                                    }
                                }
                                completionHandler(result: success, error: errorString)
                            }
                            else{
                                completionHandler(result: success, error: errorString)
                            }
                        }
                    } else {
                        completionHandler(result: success, error: errorString)
                    }
                }
            } else {
                completionHandler(result: success, error: errorString)
            }
        }
        
    }
    
    func getSession(urlstring: String, jsonBody:[String:AnyObject], completionHandler: (success: Bool, sessionID: String?,userID : String? ,errorString: String?) -> Void) {
        
        _ = taskForPOSTMethod(urlstring, jsonBody: jsonBody) { JSONResult, error in
            
            if let _ = error {
                completionHandler(success: false, sessionID: nil, userID : nil , errorString: "Network Error")
            } else {

                if let _ = JSONResult.valueForKey(OTMClient.JSONBodyKeys.Status) as? Int  {
                   completionHandler(success: false, sessionID: nil, userID : nil , errorString: "Wrong")
                } else {
                    let account = JSONResult.valueForKey(OTMClient.JSONBodyKeys.Account) as! [String : AnyObject]
                    let session = JSONResult.valueForKey(OTMClient.JSONBodyKeys.Session) as! [String : AnyObject]
                    
                     completionHandler(success: true, sessionID : session[OTMClient.JSONBodyKeys.SessionID] as? String, userID: account[OTMClient.JSONBodyKeys.UserID] as? String, errorString: nil)
                }
            }
        }
    }
    
    func getUserData(urlstring: String, completionHandler: (success: Bool, lastName: String?, firstName : String? ,errorString: String?) -> Void) {
        
        _ = taskForGETMethod(urlstring) { JSONResult, error in

            if let _ = error {
                completionHandler(success: false, lastName: nil, firstName : nil , errorString: "Network Error")
            } else {
                
                if let _ = JSONResult.valueForKey(OTMClient.JSONBodyKeys.Status) as? Int  {
                     completionHandler(success: false, lastName: nil, firstName : nil , errorString: "Faild to get user data")
                } else {
                    let user = JSONResult.valueForKey(OTMClient.JSONBodyKeys.User) as! [String : AnyObject]
                    completionHandler(success: true, lastName : user[OTMClient.JSONBodyKeys.LastName] as? String, firstName: user[OTMClient.JSONBodyKeys.FirstName] as? String, errorString: nil)
                   
                }
            }
        }
    }
    
    func getStudentLocations(urlstring: String, completionHandler: (success: Bool, locations: [[String: AnyObject]]?, errorString: String?) -> Void) {
        
        _ = taskForGETMethod(urlstring) { JSONResult, error in
            
            if let _ = error {
                completionHandler(success: false, locations: nil, errorString: "Network Error")
            } else {
                if let arrayOfResults = JSONResult.valueForKey("results") as? [[String:AnyObject]] {
                    completionHandler(success: true, locations: arrayOfResults, errorString: "Done")
                }
                else {
                    completionHandler(success: false, locations: nil, errorString: "Faild to download")
                }
            }
        }
    }
    
    func postStudentLocation(urlstring: String, parameters:[AnyObject], completionHandler: (success: Bool ,errorString: String?) -> Void) {
        
        let Body : [String:AnyObject] = [
            
            OTMClient.ParameterKeys.UniqueKey: self.userID as! AnyObject,
            OTMClient.ParameterKeys.FirstName: self.firstName as! AnyObject,
            OTMClient.ParameterKeys.LastName : self.lastName as! AnyObject,
            OTMClient.ParameterKeys.MapString : parameters[0],
            OTMClient.ParameterKeys.MediaURL : parameters[1],
            OTMClient.ParameterKeys.Latitude : parameters[2],
            OTMClient.ParameterKeys.longitude : parameters[3]
            
        ]
        _ = taskForPOSTMethod(urlstring, jsonBody: Body) { JSONResult, error in
            if let _ = error {
                completionHandler(success: false, errorString: "Network Error")
            } else {
                completionHandler(success: true, errorString: "Done")
            }
        }
    }
    
    
    func logoutUser(completionHandler: (result: Bool, error: String?) -> Void) {
        let urlstring = OTMClient.Constants.BaseURLSecure + OTMClient.Methods.Session
        _ = taskForDELETEMethod(urlstring) { JSONResult, error in
            
            if let _ = error {
                completionHandler(result: false, error: "Network Error")
            } else {
                completionHandler(result: true, error: "Done")
            }
        }
    }
}