//
//  ListingMapViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 4/3/21.
//

import UIKit
import MapKit

class ListingMapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var button: UIButton!
    @IBAction func buttonAct(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    var coord: CLLocationCoordinate2D!
    var price: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.shadowRadius = 4.0
        button.layer.shadowOpacity = 0.98
        button.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        button.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        mapView.delegate = self
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let viewLocation = MKCoordinateRegion(center: coord, span: span)
        mapView.setRegion(viewLocation, animated: true)
        
        let annotation = ParkingSpaceMapAnnotation(id: "", name: "", email: "", phoneNumber: "", photo: "", coordinate: coord, price: price, pricePerDay: 0.0, dailyPriceEnabled: false, address: Address(city: "", state: "", street: "", zip: ""), tags: [""], comments: "",startTime: nil, endTime: nil, date: nil, startDate: nil, endDate: nil, images: [""], selfParking: SelfParking(hasSelfParking: false, selfParkingMethod: "", specificDirections: ""))
        mapView.addAnnotation(annotation)
    }

}

extension ListingMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let parkingSpace = annotation as? ParkingSpaceMapAnnotation {
            print("Parking Space Map Annotation")
            let reuseIdentifier = "Annotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = annotation
            }
            
            annotationView?.image = UIImage(named: "mapAnnotation")
            let label = UILabel(frame: CGRect(x: 10, y: 0, width: 40, height: 30))
            label.textColor = .white
            
            var priceString = String(format: "%.2f", price)
            if parkingSpace.price > 99 {
                priceString = String(format: "%g", price)
            }
            
            let font:UIFont? = UIFont.init(name: "Roboto-Bold", size: 13)
            let fontSuper:UIFont? = UIFont.init(name: "Roboto-Bold", size: 8)
            let attString:NSMutableAttributedString = NSMutableAttributedString(string: "$"+priceString, attributes: [.font:font!])
            attString.setAttributes([.font:fontSuper!,.baselineOffset:2.5], range: NSRange(location:0,length:1))
            label.attributedText = attString
            annotationView?.addSubview(label)
            return annotationView
        } else {
            return nil
        }

    }
}
