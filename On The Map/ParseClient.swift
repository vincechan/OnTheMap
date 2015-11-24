//
//  PulseClient.swift
//  On The Map
//
//  Created by Vince Chan on 10/15/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
    
    // Retrieve student location given the unique key
    func getStudentLocation(uniqueKey: String, completionHandler: (result: [StudentInformation]?, error: String?) -> Void) {
        
        let headerParams = [
            HeaderParameterKeys.ApplicationId : Constants.ApplicationId,
            HeaderParameterKeys.RestApiKey : Constants.ApiKey
        ]
        
        let urlParams = [
            UrlParameterKeys.Where: "{ \"uniqueKey\":\"\(uniqueKey)\"}"
        ]
        
        HttpClient.sharedInstance().httpGet(Constants.BaseUrl, method: Methods.StudentLocation, urlParams: urlParams, headerParams: headerParams) {
            (result, code, error) in
            
            if error != nil {
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let result = result else {
                completionHandler(result: nil, error: "no results found")
                return
            }
            
            HttpClient.parseJSONWithCompletionHandler(result) {
                (jsonResult, parseError) in
                
                if parseError != nil {
                    completionHandler(result: nil, error: parseError)
                    return
                }
                
                guard let jsonResult = jsonResult else {
                    completionHandler(result: nil, error: "Server error. Empty json result")
                    return
                }
                
                if let results = jsonResult[JsonResponseKey.Results] as? [[String:AnyObject]] {
                    let students = StudentInformation.studentsFromResult(results)
                    completionHandler(result: students, error: nil)
                }
                else {
                    completionHandler(result: nil, error: "Could not parse result")
                }
            }
        }
    }
    
    // Retrieve the last 100 posted student locations
    func getRecentStudentLocations(completionHandler: (result: [StudentInformation]?, error: String?) -> Void) {
        
        let headerParams = [
            HeaderParameterKeys.ApplicationId : Constants.ApplicationId,
            HeaderParameterKeys.RestApiKey : Constants.ApiKey
        ]
        
        let urlParams = [
            UrlParameterKeys.Limit: 100,
            UrlParameterKeys.Order: "-updatedAt"
        ]
        
        HttpClient.sharedInstance().httpGet(Constants.BaseUrl, method: Methods.StudentLocation, urlParams: urlParams, headerParams: headerParams) {
            (result, code, error) in
            
            if error != nil {
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let result = result else {
                completionHandler(result: nil, error: "No results found")
                return
            }
            
            HttpClient.parseJSONWithCompletionHandler(result) {
                (jsonResult, parseError) in
                
                if parseError != nil {
                    completionHandler(result: nil, error: parseError)
                    return
                }
                
                guard let jsonResult = jsonResult else {
                    completionHandler(result: nil, error: "Server error. Empty json result.")
                    return
                }
                
                if let results = jsonResult[JsonResponseKey.Results] as? [[String:AnyObject]] {
                    let students = StudentInformation.studentsFromResult(results)
                    completionHandler(result: students, error: nil)
                }
                else {
                    completionHandler(result: nil, error: "Could not parse result")
                }
            }
        }
    }
    
    // add or update the location for a student
    // if a location does not already exist for the student, add a new location, otherwise update the location
    func addOrUpdateLocation(uniqueKey: String, firstName: String, lastName: String, longitude: Double, latitude: Double, location: String, url: String, completionHandler: (success: Bool, error: String?) -> Void) {
        
        getStudentLocation(uniqueKey) {
            (students, error) in
            
            if (error != nil) {
                completionHandler(success: false, error: "Unable to verify status")
                return
            }
            
            let headerParams = [
                HeaderParameterKeys.ApplicationId : Constants.ApplicationId,
                HeaderParameterKeys.RestApiKey : Constants.ApiKey
            ]
            
            let jsonBody : [String: AnyObject] = [
                JsonResponseKey.UniqueKey : uniqueKey,
                JsonResponseKey.FirstName : firstName,
                JsonResponseKey.LastName : lastName,
                JsonResponseKey.Longitude : longitude,
                JsonResponseKey.Latitude : latitude,
                JsonResponseKey.MapString : location,
                JsonResponseKey.MediaURL : url
            ]
            
            if (students?.count > 0) {
                // update
                HttpClient.sharedInstance().httpPut(Constants.BaseUrl, method: Methods.StudentLocation + "/" + students![0].objectId, urlParams: nil, headerParams: headerParams, jsonBody: jsonBody) {
                    (data, code, error) in
                    
                    if error != nil {
                        completionHandler(success: false, error: error!)
                    }
                    else {
                        completionHandler(success: true, error: nil)
                    }
                }
            }
            else {
                // add
                HttpClient.sharedInstance().httpPost(Constants.BaseUrl, method: Methods.StudentLocation, urlParams: nil, headerParams: headerParams, jsonBody: jsonBody) {
                    (data, code, error) in
                    
                    if error != nil {
                        completionHandler(success: false, error: error!)
                    }
                    else {
                        completionHandler(success: true, error: nil)
                    }
                }
            }
        }
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstace = ParseClient()
        }
        return Singleton.sharedInstace
    }
}


extension ParseClient {
    struct Constants {
        static let BaseUrl : String = "https://api.parse.com/1/classes/"
        static let ApplicationId: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct Methods {
        static let StudentLocation = "StudentLocation"
    }
    
    struct UrlParameterKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
    }
    
    struct HeaderParameterKeys {
        static let ApplicationId = "X-Parse-Application-Id"
        static let RestApiKey = "X-Parse-REST-API-Key"
    }
    
    struct JsonResponseKey {
        static let Results = "results"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
}
