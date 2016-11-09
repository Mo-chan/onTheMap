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
    
    func LoginWithViewController(_ hostViewController: UIViewController, completionHandler: (_ success: Bool, _ errorString: String?) -> Void) {

    }
    
    func LoginWithUser(_ parameters : [String],completionHandler: @escaping (_ result: Bool, _ error: String?) -> Void) {
        
        let Body : [String:AnyObject] = [
            
            OTMClient.ParameterKeys.Username: parameters[0] as AnyObject,
            OTMClient.ParameterKeys.Password: parameters[1] as AnyObject
            
        ]
        let jsonBody = ["udacity": Body]
        var urlstring = OTMClient.Constants.BaseURLSecure + OTMClient.Methods.Session
        
        getSession(urlstring, jsonBody: jsonBody as [String : AnyObject]) { (success, sessionID, userID, errorString) in
            
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
                                
                                let object = UIApplication.shared.delegate
                                let appDelegate = object as! AppDelegate
                                appDelegate.studentInformation = [StudentInformation] ()
                                if let locations = locations {
                                    for location in locations {
                                        let student = StudentInformation (dictionary: location)
                                        appDelegate.studentInformation.append(student)
                                    }
                                }
                                completionHandler(success, errorString)
                            }
                            else{
                                completionHandler(success, errorString)
                            }
                        }
                    } else {
                        completionHandler(success, errorString)
                    }
                }
            } else {
                completionHandler(success, errorString)
            }
        }
        
    }
    
    func getSession(_ urlstring: String, jsonBody:[String:AnyObject], completionHandler: @escaping (_ success: Bool, _ sessionID: String?,_ userID : String? ,_ errorString: String?) -> Void) {
        
        _ = taskForPOSTMethod(urlstring, jsonBody: jsonBody) { JSONResult, error in
            
            if let _ = error {
                completionHandler(false, nil, nil , "Network Error")
            } else {

                if let _ = JSONResult?.value(forKey: OTMClient.JSONBodyKeys.Status) as? Int  {
                   completionHandler(false, nil, nil , "Wrong")
                } else {
                    let account = JSONResult?.value(forKey: OTMClient.JSONBodyKeys.Account) as! [String : AnyObject]
                    let session = JSONResult?.value(forKey: OTMClient.JSONBodyKeys.Session) as! [String : AnyObject]
                    
                     completionHandler(true, session[OTMClient.JSONBodyKeys.SessionID] as? String, account[OTMClient.JSONBodyKeys.UserID] as? String, nil)
                }
            }
        }
    }
    
    func getUserData(_ urlstring: String, completionHandler: @escaping (_ success: Bool, _ lastName: String?, _ firstName : String? ,_ errorString: String?) -> Void) {
        
        _ = taskForGETMethod(urlstring) { JSONResult, error in

            if let _ = error {
                completionHandler(false, nil, nil , "Network Error")
            } else {
                
                if let _ = JSONResult?.value(forKey: OTMClient.JSONBodyKeys.Status) as? Int  {
                     completionHandler(false, nil, nil , "Faild to get user data")
                } else {
                    let user = JSONResult?.value(forKey: OTMClient.JSONBodyKeys.User) as! [String : AnyObject]
                    completionHandler(true, user[OTMClient.JSONBodyKeys.LastName] as? String, user[OTMClient.JSONBodyKeys.FirstName] as? String, nil)
                   
                }
            }
        }
    }
    
    func getStudentLocations(_ urlstring: String, completionHandler: @escaping (_ success: Bool, _ locations: [[String: AnyObject]]?, _ errorString: String?) -> Void) {
        
        _ = taskForGETMethod(urlstring) { JSONResult, error in
            
            if let _ = error {
                completionHandler(false, nil, "Network Error")
            } else {
                if let arrayOfResults = JSONResult?.value(forKey: "results") as? [[String:AnyObject]] {
                    completionHandler(true, arrayOfResults, "Done")
                }
                else {
                    completionHandler(false, nil, "Faild to download")
                }
            }
        }
    }
    
    func postStudentLocation(_ urlstring: String, parameters:[AnyObject], completionHandler: @escaping (_ success: Bool ,_ errorString: String?) -> Void) {
        
        let Body : [String:AnyObject] = [
            
            OTMClient.ParameterKeys.UniqueKey: self.userID as AnyObject,
            OTMClient.ParameterKeys.FirstName: self.firstName as AnyObject,
            OTMClient.ParameterKeys.LastName : self.lastName as AnyObject,
            OTMClient.ParameterKeys.MapString : parameters[0],
            OTMClient.ParameterKeys.MediaURL : parameters[1],
            OTMClient.ParameterKeys.Latitude : parameters[2],
            OTMClient.ParameterKeys.longitude : parameters[3]
            
        ]
        _ = taskForPOSTMethod(urlstring, jsonBody: Body) { JSONResult, error in
            if let _ = error {
                completionHandler(false, "Network Error")
            } else {
                completionHandler(true, "Done")
            }
        }
    }
    
    
    func logoutUser(_ completionHandler: @escaping (_ result: Bool, _ error: String?) -> Void) {
        let urlstring = OTMClient.Constants.BaseURLSecure + OTMClient.Methods.Session
        _ = taskForDELETEMethod(urlstring) { JSONResult, error in
            
            if let _ = error {
                completionHandler(false, "Network Error")
            } else {
                completionHandler(true, "Done")
            }
        }
    }
}
