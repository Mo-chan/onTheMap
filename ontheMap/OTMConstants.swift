//
//  OTMConstants.swift
//  ontheMap
//
//  Created by Mohammad Awwad on 8/28/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation

extension OTMClient{

    struct Constants {
        
        // Parse
        static let ParseID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseApi : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseURLSecure : String = "https://api.parse.com/1/classes/StudentLocation"
        
        static let FacebookID: String = "365362206864879"
        static let FacebookSuffix : String = "onthemap"
        
        static let BaseURLSecure : String = "https://www.udacity.com/api/"
        static let Signin : String = "https://www.udacity.com/account/auth#!/signin"
        
    }
    
    struct Methods {

        static let Session = "session"
        static let User = "users/"
        
    }

    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"

        
        static let Username = "username"
        static let Password = "password"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let longitude = "longitude"
    }
    
    struct JSONBodyKeys {
        
        static let SessionID = "id"
        static let UserID = "key"
        static let Account = "account"
        static let Session = "session"
        static let LastName = "last_name"
        static let FirstName = "first_name"
        static let User = "user"
        static let Status = "status"
    }
    
    struct JSONResponseKeys {
        
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"

        
    }
    
}