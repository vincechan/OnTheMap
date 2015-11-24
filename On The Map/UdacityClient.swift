//
//  UdacityClient.swift
//  On The Map
//
//  Created by Vince Chan on 10/6/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import UIKit

class UdacityClient: NSObject {
    
    var SessionId : String?
    var UserId: String?
    
    // Retrieve student name given the id
    func getStudentName(userid: String, completionHandler: (firstName: String?, lastName: String?, error: String?)->Void) {
        
        let method = HttpClient.subtituteKeyInMethod(Methods.Users, key: UrlKeys.UserId, value: userid)!
        HttpClient.sharedInstance().httpGet(Constants.BaseUrl, method: method, urlParams: nil, headerParams: nil) {
            (data, code, error) in
            
            if (error != nil) {
                completionHandler(firstName: nil, lastName: nil, error: error)
                return
            }
            
            // first five 5 bytes of data returned from udacity api needs to be skipped
            let udacityData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            HttpClient.parseJSONWithCompletionHandler(udacityData) {
                (jsonResult, parseError) in
                
                if parseError != nil {
                    completionHandler(firstName: nil, lastName: nil, error: "Failed to parse response \(parseError)")
                    return
                }
                
                var first : String? = nil
                var last : String? = nil
                if let user = jsonResult![UdacityClient.JsonResponseKey.User] as? [String:AnyObject] {
                    first = user[UdacityClient.JsonResponseKey.FirstName] as? String
                    last = user[UdacityClient.JsonResponseKey.LastName] as? String
                }
                
                if (first != nil || last != nil) {
                    completionHandler(firstName: first, lastName: last, error: nil)
                }
                else {
                    completionHandler(firstName: nil, lastName: nil, error: "no user found in response")
                }
            }
        }
    }
    
    // Retrieve student image given the id
    func getStudentImage(userid: String, completionHandler: (imageData: NSData?, error: String?)->Void) {
        
        let method : String = HttpClient.subtituteKeyInMethod(Methods.Users, key: UrlKeys.UserId, value: userid)!
        
        HttpClient.sharedInstance().httpGet(Constants.BaseUrl, method: method, urlParams: nil, headerParams: nil) {
            (data, code, error) in
            
            if (error != nil) {
                completionHandler(imageData: nil, error: error)
                return
            }
            
            // first five 5 bytes of data returned from udacity api needs to be skipped
            let udacityData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            HttpClient.parseJSONWithCompletionHandler(udacityData) {
                (jsonResult, parseError) in
                
                if parseError != nil {
                    completionHandler(imageData: nil, error: "Failed to parse response \(parseError)")
                    return
                }
                
                var image : NSData? = nil
                if let user = jsonResult![UdacityClient.JsonResponseKey.User] as? [String:AnyObject] {
                    if let url = user[UdacityClient.JsonResponseKey.ImageUrl] as? String {
                        image = NSData(contentsOfURL: NSURL(string: "https:\(url)")!)
                    }
                }
                
                if (image != nil) {
                    completionHandler(imageData: image, error: nil)
                }
                else {
                    completionHandler(imageData: nil, error: "no image found in response")
                }
            }
        }
    }
    
    // Logout of current session
    func logout() {
        let urlString = Constants.BaseUrl + Methods.Session
        let request = NSMutableURLRequest(URL: NSURL(string:urlString)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print(error)
                return
            }
            if let data = data {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            }
        }
        task.resume()
    }
    
    // Login using Facebook
    func loginWithFacebook(token: String, completionHandler: (success: Bool, errorString: String?)->Void) {
        
        let accessToken = [
            JsonBodyKeys.AccessToken : token
        ]
        let jsonBody = [ JsonBodyKeys.FacebookMobile: accessToken]
        
        HttpClient.sharedInstance().httpPost(Constants.BaseUrl, method: Methods.Session, urlParams: nil, headerParams: nil, jsonBody: jsonBody) {
            (data, code, error) in
            if error != nil {
                completionHandler(success: false, errorString: error)
                return
            }
            
            // first five 5 bytes of data returned from udacity api needs to be skipped
            let udacityData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            print(NSString(data: udacityData, encoding: NSUTF8StringEncoding))
            
            HttpClient.parseJSONWithCompletionHandler(udacityData) {
                (jsonResult, parseError) in
                if parseError != nil {
                    completionHandler(success: false, errorString: "Failed to parse response")
                }
                
                // retrieve user id and session id
                if let jsonResult = jsonResult {
                    if let account = jsonResult[JsonResponseKey.Account] as? [String:AnyObject] {
                        if let key = account[JsonResponseKey.Key] as? String {
                            self.UserId  = key
                        }
                    }
                    if let session = jsonResult[JsonResponseKey.Session] as? [String:AnyObject] {
                        if let id = session[JsonResponseKey.Id] as? String {
                            self.SessionId = id
                        }
                    }
                }
                
                if (self.SessionId != nil && self.UserId != nil) {
                    completionHandler(success: true, errorString: nil)
                }
                else {
                    completionHandler(success: false, errorString: "Login Failed (no id found in response")
                }
            }
        }
        
    }
    
    // Login using udacity user name and password
    func login(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let credentials = [
            JsonBodyKeys.UserName : username,
            JsonBodyKeys.Password : password
        ]
        let jsonBody = [ JsonBodyKeys.Udacity: credentials]
        
        HttpClient.sharedInstance().httpPost(Constants.BaseUrl, method: Methods.Session, urlParams: nil, headerParams: nil, jsonBody: jsonBody) {
            (data, code, error) in
            if error != nil {
                print(error)
                
                if let code = code where code == 403 {
                    completionHandler(success: false, errorString: "Invalid email or password")
                } else {
                    completionHandler(success: false, errorString: error)
                }
                return
            }
            
            // first five 5 bytes of data returned from udacity api needs to be skipped
            let udacityData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            print(NSString(data: udacityData, encoding: NSUTF8StringEncoding))
            
            HttpClient.parseJSONWithCompletionHandler(udacityData) {
                (jsonResult, parseError) in
                if parseError != nil {
                    completionHandler(success: false, errorString: "Failed to parse response")
                }
                
                // retrieve user id and session id
                if let jsonResult = jsonResult {
                    if let account = jsonResult[JsonResponseKey.Account] as? [String:AnyObject] {
                        if let key = account[JsonResponseKey.Key] as? String {
                            self.UserId  = key
                        }
                    }
                    if let session = jsonResult[JsonResponseKey.Session] as? [String:AnyObject] {
                        if let id = session[JsonResponseKey.Id] as? String {
                            self.SessionId = id
                        }
                    }
                }
                
                if (self.SessionId != nil && self.UserId != nil) {
                    completionHandler(success: true, errorString: nil)
                }
                else {
                    completionHandler(success: false, errorString: "Login Failed (no id found in response")
                }
            }
        }
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}

extension UdacityClient {
    struct Constants {
        static let BaseUrl : String = "https://www.udacity.com/api/"
    }
    
    struct Methods {
        static let Session = "session"
        static let Users = "users/{user_id}"
    }
    
    struct UrlKeys {
        static let UserId = "user_id"
    }
    
    struct JsonBodyKeys {
        static let Udacity = "udacity"
        static let UserName = "username"
        static let Password = "password"
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken = "access_token"
    }
    
    struct JsonResponseKey {
        static let Account = "account"
        static let Session = "session"
        static let Id = "id"
        static let User = "user"
        static let ImageUrl = "_image_url"
        static let Key = "key"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
}
