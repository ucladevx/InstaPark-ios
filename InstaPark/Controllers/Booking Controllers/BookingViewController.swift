//
//  BookingViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 11/6/20.
//

import UIKit
import MapKit

protocol isAbleToReceiveData {
    func pass(start: Date, end: Date, date: Date)
}

class BookingViewController: UIViewController, isAbleToReceiveData {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UIButton!
    
    @IBOutlet weak var tag1: UIButton!
    @IBOutlet weak var tag2: UIButton!
    @IBOutlet weak var tag3: UIButton!
    @IBOutlet weak var tag4: UIButton!
    
    
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var reserveButton: UIButton!
    
    //variables that are passed in from mapView
    var info = ParkingSpaceMapAnnotation(id: "id", name: "address", coordinate: CLLocationCoordinate2DMake(34.0703, -118.4441), price: 10.0, startTime: NSDate.init(), endTime: NSDate.init(), address: "test", tags: ["test"], comments: "test")
    var total = 0.0
    var startDate: Date? = nil
    var startTime: Date? = nil
    var endTime: Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        nameLabel.text = info.name
        addressLabel.text = info.address
        commentsLabel.text = info.comments
        cardLabel.text = "ending in \(5678)" ///need to get this from user data structure
        
        //set up price Attributed String
        let dollar = "$"
        let dollar_attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13)]
        let cost = NSMutableAttributedString(string:dollar, attributes:dollar_attrs)
        
        let price = String(format: "%.2f", info.price)
        let price_attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 23)]
        let price_string = NSMutableAttributedString(string:price, attributes:price_attrs)
        cost.append(price_string)
        
        let perHour = " per hour"
        let hour_attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium)]
        let hour_string = NSMutableAttributedString(string:perHour, attributes:hour_attrs)
        cost.append(hour_string)
        
        priceLabel.attributedText = cost
        
        //set up tags
        let tags: [UIButton] = [tag1, tag2, tag3, tag4]
        
        for tag in tags {
            tag.layer.borderWidth = 1.5
            tag.layer.borderColor = CGColor.init(red: 0.796, green: 0.651, blue: 0.821, alpha: 1.0)
            tag.isHidden = true
        }
        for n in 0...(info.tags.count-1) {
            tags[n].setTitle(info.tags[n], for: .normal)
            tags[n].isHidden = false
        }
        
        //initialize map
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let location: CLLocationCoordinate2D = info.coordinate
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: false)
        self.mapView.addAnnotation(info)
        
        reserveButton.isEnabled = false
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func availabilityButton(_ sender: Any) {
        performSegue(withIdentifier: "availabilityVC", sender: self)
    }
    
    @IBAction func reserveButton(_ sender: Any) {
        ParkingSpotService.getParkingSpotById(info.id) { (parkingSpot, error) in
            if let spot = parkingSpot {
                if spot.isAvailable {
                    TransactionService.saveTransaction(id: self.info.id, customer: "", provider: self.info.name, startTime: Int(self.startTime!.timeIntervalSince1970), endTime: Int(self.endTime!.timeIntervalSince1970), priceRatePerHour: self.info.price, spot: spot)
                }
            }
        }
        dismiss(animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let vc = segue.destination as? AvailabilityViewController {
            vc.delegate = self
            if (startTime != nil && endTime != nil && startDate != nil)
            {
                vc.selectedDate = startDate!
                vc.startTime = startTime!
                vc.endTime = endTime!
                vc.times = info.times
            }
            else
            {
                //vc.startTime = NSDate.init(timeInterval: 1000, since: Date.init())
                //vc.endTime = NSDate.init(timeInterval: 5000, since: Date.init())
                vc.times = info.times
            }
        }
    }
    
    func pass(start: Date, end: Date, date: Date) {
        startTime = start
        endTime = end
        startDate = date
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MMMM dth"
        let day = formatter1.string(from: startDate ?? Date())
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "h:mm a"
        let startString = formatter2.string(from: startTime! as Date)
        let endString = formatter2.string(from: endTime! as Date)
        availabilityLabel.setTitle(day + "th, " + startString + " to " + endString, for: .normal)
        availabilityLabel.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        //calculate total cost (for now without tax/extra fees)
        let startHour = Calendar.current.component(.hour, from: startTime! as Date)
        let startMin = Calendar.current.component(.minute, from: startTime! as Date)
        let endHour = Calendar.current.component(.hour, from: endTime! as Date)
        let endMin = Calendar.current.component(.minute, from: endTime! as Date)
        let totalTime: Double = Double(endHour-startHour) + (Double(endMin - startMin)/60) ///should we round up the price by hour or charge to the exact minute?
        print(totalTime)
        total = totalTime * info.price
        totalLabel.text = "$" + String(format: "%.2f", total)
        totalLabel.textColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
        totalLabel.font = .systemFont(ofSize: 20, weight: .medium)
        
        reserveButton.backgroundColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
        reserveButton.setTitleColor(.white, for: .normal)
        reserveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        reserveButton.isEnabled = true
    }
}

extension BookingViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin1"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

         if annotationView == nil {
             annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
             annotationView?.canShowCallout = false
            
         } else {
             annotationView?.annotation = annotation
         }
        
        annotationView?.image = UIImage(named: "mapAnnotationPark")
        return annotationView
    }
}
