//
//  ListingAddressViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 1/20/21.
//

import UIKit
import MapKit
import CoreLocation

class ListingAddressViewController: UIViewController {
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    
    var coordinates: CLLocationCoordinate2D! // stores user's coordinates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ListingAddressViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin1"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

         if annotationView == nil {
             annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
             annotationView?.canShowCallout = false
            annotationView?.isDraggable = true
            
         } else {
             annotationView?.annotation = annotation
         }
        
        annotationView?.image = UIImage(named: "mapAnnotationPark")
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        if(newState == MKAnnotationView.DragState.ending) {
            if let coordinate = view.annotation?.coordinate {
                view.dragState  = MKAnnotationView.DragState.none
                coordinates = coordinate
                print(coordinates)
            }
        }
    }
}

extension ListingAddressViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            //print(location.coordinate)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.title = "User-Location"
            annotation.coordinate = location.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
