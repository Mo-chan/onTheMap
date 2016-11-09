//
//  OTMClinet.swift
//  ontheMap
//
//  Created by Mohammad Awwad on 8/28/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation

class OTMClient : NSObject {
 
    var session: URLSession
    var sessionID : String? = nil
    var userID : String? = nil
    var lastName : String? = nil
    var firstName : String? = nil
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    func taskForGETMethod(_ urlstring: String, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let urlString = urlstring
        let url = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        
        if urlstring == Constants.ParseURLSecure {
            request.addValue(Constants.ParseID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.ParseApi, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        
        
        
        let task = session.dataTask(with: url, completionHandler: {
            data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, downloadError as NSError?)
                return
            }
            if urlstring == Constants.ParseURLSecure {
                OTMClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
            let newData = data!.subdata(in: 5..<data!.count - 5)
            //let newData = data!.subdata(in: NSMakeRange(5, data!.count - 5))
            OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }) 
        task.resume()
        
        return task
    }
    
    func taskForPOSTMethod(_ urlstring: String, jsonBody: [String:AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let url = URL(string: urlstring)!
        let request = NSMutableURLRequest(url: URL(string: urlstring)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if urlstring == Constants.ParseURLSecure {
            request.addValue(Constants.ParseID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.ParseApi, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch { }
        let task = session.dataTask(with: url, completionHandler: {data, response, downloadError in
            if downloadError != nil {
                completionHandler(nil, downloadError as NSError?)
                return
            }
            if urlstring == Constants.ParseURLSecure {
                OTMClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
            let newData = data!.subdata(in: 5..<data!.count - 5)
            //let newData = data!.subdata(with: NSMakeRange(5, data!.count - 5))
            OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }) 
        task.resume()
        
        return task
    }
    
    func taskForDELETEMethod(_ urlstring: String, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let url = URL(string: urlstring)!
        let request = NSMutableURLRequest(url: URL(string: urlstring)!)
        
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let task = session.dataTask(with: url, completionHandler: {
            data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, downloadError as NSError?)
                return
            }
            let newData = data!.subdata(in: 5..<data!.count - 5)
            //let newData = data!.subdata(with: NSMakeRange(5, data!.count - 5))
            //println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }) 
        task.resume()
        
        return task
    }
    
    func taskForPUTMethod(_ urlstring: String, jsonBody: [String:AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let url = URL(string: urlstring)!
        let request = NSMutableURLRequest(url: URL(string: urlstring)!)
        request.httpMethod = "PUT"
        request.addValue(Constants.ParseID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseApi, forHTTPHeaderField: "X-Parse-REST-API-Key")
        do {
        request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch { }
        let task = session.dataTask(with: url, completionHandler: {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, downloadError as NSError?)
                return
            }
        OTMClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)

        })
        task.resume()
        
        return task
    }
    
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        let parsingError: NSError? = nil
        do {
            
            let parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            
            if let error = parsingError {
                completionHandler(nil, error)
            } else {
                completionHandler(parsedResult as AnyObject?, nil)
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
