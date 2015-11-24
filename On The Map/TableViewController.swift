//
//  TableViewController.swift
//  On The Map
//
//  Created by Vince Chan on 10/20/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import UIKit

class TableViewController:  TabItemViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        createNavigationButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    func refresh() {
        ParseClient.sharedInstance().getRecentStudentLocations() {
            (students, error) in
            
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showError("Unable to download data.")
                    return
                }
            }
            
            if let students = students {
                StudentInformation.allStudents = students
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showError("No students found")
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformation.allStudents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentTableViewCell", forIndexPath: indexPath)
        
        let student = StudentInformation.allStudents[indexPath.row]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = "\(student.mediaURL)"
        cell.imageView!.image = UIImage(named: "pin")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        // fetch image for the student
        UdacityClient.sharedInstance().getStudentImage(student.uniqueKey) {
            (imageData, error) in
            if (imageData != nil) {
                if let image = UIImage(data: imageData!) {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.imageView!.image = image
                    }
                } else {
                    // a default image would be shown if we are not able to load the student image
                    // ignore any error related to loading student image
                    print(error)
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        openUrl(StudentInformation.allStudents[indexPath.row].mediaURL)
    }
    
}
