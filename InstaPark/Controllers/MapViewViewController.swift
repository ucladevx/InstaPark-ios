//
//  MapViewViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/28/20.
//

import UIKit
import MapKit

class MapViewViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var transactionsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        transactionsButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        transactionsButton.layer.shadowOffset = CGSize(width: 4.0, height: 3.0)
        transactionsButton.layer.shadowOpacity = 0.5
        transactionsButton.layer.shadowRadius = 3.0
        transactionsButton.layer.masksToBounds = false
        
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(34.0703, -118.4441)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        
        self.mapView.setRegion(region, animated: false)
        
        var annotations: [parkingSpace] = []
        
        //test annotations until set up with firebase
        let annotation1 = parkingSpace(name: "Joe Bruin", coordinate: CLLocationCoordinate2DMake(34.0703, -118.4441), price: 4.00, time: "3:00-4:00")
        let annotation2 = parkingSpace(name: "FIRST LAST ", coordinate: CLLocationCoordinate2DMake(34.072, -118.43), price: 7.0, time: "5:00-8:00")
        let annotation3 = parkingSpace(name: "First Last ", coordinate: CLLocationCoordinate2DMake(34.071, -118.439), price: 8.0, time: "7:00-9:00")
        let annotation4 = parkingSpace(name: "First Last ", coordinate: CLLocationCoordinate2DMake(34.073, -118.449), price: 5.0, time: "2:30-4:00")
        let annotation5 = parkingSpace(name: "First Last ", coordinate: CLLocationCoordinate2DMake(34.08, -118.4381), price: 6.0, time: "11:00-12:00")
        
        annotations.append(contentsOf: [annotation1, annotation2, annotation3, annotation4, annotation5])
        
        self.mapView.addAnnotations(annotations)
    }
    


    @IBAction func transactionButton(_ sender: UIButton) {
        
    }
}


extension MapViewViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        if #available(iOS 11.0, *) {
            if annotation is MKClusterAnnotation { return nil }
        }
        
        let customAnnotationViewIdentifier = "MyAnnotation"

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: customAnnotationViewIdentifier)
        if annotationView == nil {
            
            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: customAnnotationViewIdentifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        //unsure what the three colors of annotations are so for now, they are all random
        let color = Int.random(in: 1..<4)
        if color == 1 {
            annotationView?.image = UIImage(named: "mapAnnotation1")
        }
        else if color == 2 {
            annotationView?.image = UIImage(named: "mapAnnotation2")
        }
        else {
            annotationView?.image = UIImage(named: "mapAnnotation3")
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("mapView(_:annotationView:calloutAccessoryControlTapped)")
    }
    
}

extension MapViewViewController: ParkingCalloutViewDelegate {
    func mapView(_ mapView: MKMapView, didTapDetailsButton button: UIButton, for annotation: MKAnnotation) {
        let parkingSpace = annotation as! parkingSpace
        let name = parkingSpace.name ?? "Unknown"
        let coordinates = String(parkingSpace.coordinate.latitude) + ", " + String(parkingSpace.coordinate.longitude)
        let price = parkingSpace.price
        let time = parkingSpace.time
        print(name)
        print(coordinates)
        print(price)
        print(time)
    }
}

