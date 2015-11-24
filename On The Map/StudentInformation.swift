//
//  StudentInformation.swift
//  On The Map
//
//  Created by Vince Chan on 10/14/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    var objectId: String = ""
    var uniqueKey: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var mapString: String = ""
    var mediaURL: String = ""
    var latitude: Float = 0
    var longitude: Float = 0
    
    // Construct StudentInformation from a dictionary
    init(dictionary: [String: AnyObject]) {
        objectId = dictionary[ParseClient.JsonResponseKey.ObjectId] as! String
        uniqueKey = dictionary[ParseClient.JsonResponseKey.UniqueKey] as! String
        firstName = dictionary[ParseClient.JsonResponseKey.FirstName] as! String
        lastName = dictionary[ParseClient.JsonResponseKey.LastName] as! String
        mapString = dictionary[ParseClient.JsonResponseKey.MapString] as! String
        mediaURL = dictionary[ParseClient.JsonResponseKey.MediaURL] as! String
        latitude = dictionary[ParseClient.JsonResponseKey.Latitude] as! Float
        longitude = dictionary[ParseClient.JsonResponseKey.Longitude] as! Float
    }
    
    // Given an array of dictionaries, convert them to an array of StudentInformation objects
    static func studentsFromResult(results: [[String: AnyObject]]) -> [StudentInformation] {
        var students = [StudentInformation]()
        
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        
        return students
    }
    
    static var allStudents = [StudentInformation]()
}
