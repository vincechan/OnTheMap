//
//  MapViewController.swift
//  On The Map
//
//  Created by Vince Chan on 10/14/15.
//  Copyright © 2015 Vince Chan. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: TabItemViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        createNavigationButtons()
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
                
                // Create an MKPointAnnotation for each dictionary in students
                // The point annotations will be stored in this array, and then provided to the map view.
                var annotations = [MKPointAnnotation]()
                
                for student in students {
                    let lat = CLLocationDegrees(student.latitude)
                    let long = CLLocationDegrees(student.longitude)
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    // Create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(student.firstName) \(student.lastName)"
                    annotation.subtitle = student.mediaURL
                    
                    // Place he annotation in an array of annotations.
                    annotations.append(annotation)
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    // When the array is complete, we add the annotations to the map.
                    self.mapView.addAnnotations(annotations)
                }
                
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showError("No students found")
                }
            }
        }
    }
    
    // Create a view with a "right callout accessory view".
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            openUrl(view.annotation!.subtitle!!)
        }
    }
}
