//
//  StudentInformation.swift
//  ontheMap
//
//  Created by Mohammad Awwad on 8/30/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit

struct StudentInformation {

    var firstName : AnyObject?
    var lastName : AnyObject?
    var latitude : AnyObject?
    var longitude : AnyObject?
    var mapString : AnyObject?
    var mediaURL : AnyObject?
    var objectID : AnyObject?
    var uniqueKey : AnyObject?
    
    init(dictionary : [String: AnyObject]){
 
            self.firstName = dictionary["firstName"]
            self.lastName = dictionary["lastName"]
            self.latitude = dictionary["latitude"]
            self.longitude = dictionary["longitude"]
            self.mapString = dictionary["mapString"]
            self.mediaURL = dictionary["mediaURL"]
            self.objectID = dictionary["objectID"]
            self.uniqueKey = dictionary["uniqueKey"]
    }
}