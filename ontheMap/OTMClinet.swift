//
//  OTMClinet.swift
//  ontheMap
//
//  Created by Mohammad Awwad on 8/28/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation

class OTMClient : NSObject {
 
    var session: NSURLSession
    var sessionID : String? = nil
    var userID : String? = nil
    var lastName : String? = nil
    var firstName : String? = nil
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func taskForGETMethod(urlstring: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = urlstring
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        if urlstring == Constants.ParseURLSecure {
            request.addValue(Constants.ParseID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.ParseApi, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(result: nil, error: downloadError)
                return
            }
            if urlstring == Constants.ParseURLSecure {
                OTMClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        task.resume()
        
        return task
    }
    
    func taskForPOSTMethod(urlstring: String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        

        let request = NSMutableURLRequest(URL: NSURL(string: urlstring)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if urlstring == Constants.ParseURLSecure {
            request.addValue(Constants.ParseID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.ParseApi, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions.PrettyPrinted)
        } catch { }
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if downloadError != nil {
                completionHandler(result: nil, error: downloadError)
                return
            }
            if urlstring == Constants.ParseURLSecure {
                OTMClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        task.resume()
        
        return task
    }
    
    func taskForDELETEMethod(urlstring: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlstring)!)
        
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(result: nil, error: downloadError)
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            //println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        task.resume()
        
        return task
    }
    
    func taskForPUTMethod(urlstring: String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlstring)!)
        request.HTTPMethod = "PUT"
        request.addValue(Constants.ParseID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseApi, forHTTPHeaderField: "X-Parse-REST-API-Key")
        do {
        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions.PrettyPrinted)
        } catch { }
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(result: nil, error: downloadError)
                return
            }
        OTMClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)

        }
        task.resume()
        
        return task
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let parsingError: NSError? = nil
        do {
            let parsedResult: AnyObject? =  try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            
            
            if let error = parsingError {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: parsedResult, error: nil)
            }
        } catch {}
    }
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
}