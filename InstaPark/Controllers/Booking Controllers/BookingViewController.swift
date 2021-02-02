//
//  BookingViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 11/6/20.
//

import UIKit
import MapKit
import Braintree
import BraintreeDropIn

protocol isAbleToReceiveData {
    func pass(start: Date, end: Date, date: Date, cancel: Bool)
}

class BookingViewController: UIViewController, isAbleToReceiveData {
    var transationDate: String! // only not nil when view came from transactions view
    
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet var popupView: UIView!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UIButton!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var timeFrameTitleLabel: UILabel!
    @IBOutlet weak var paymentCardLabel: UILabel!
    @IBOutlet weak var paymentStack: UIStackView!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var totalTitleLabel: UILabel!
    var bookmarkFlag = false
 
    @IBOutlet var blackScreen: UIView!
    //  @IBOutlet var listingPopup: UIView!

    
    
    @IBOutlet weak var tag1: UIButton!
    @IBOutlet weak var tag2: UIButton!
    @IBOutlet weak var tag3: UIButton!
    @IBOutlet weak var tag4: UIButton!
    
    
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var reserveButton: UIButton!
    var totalPrice: Double?
    var paymentResult: BTDropInResult?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    //variables that are passed in from mapView
    var info = ParkingSpaceMapAnnotation(id: "0XsChhfAoV33XFCOZKUK", name: "address", coordinate: CLLocationCoordinate2DMake(34.0703, -118.4441), price: 10.0, address: "test", tags: ["test"], comments: "test", startTime: Date(), endTime: Date(), date: Date(), startDate: Date(), endDate: Date())
    var ShortTermParking: ShortTermParkingSpot!
    //var LongTermParking : LongTermParkingSpot!
    var total = 0.0
    var startDate: Date? = nil
    var startTime: Date? = nil
    var endTime: Date? = nil
    var parkingType: ParkingType = .short //update this later
    var listing = false // only true if this is listing model
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        
        bookmarkButton.isHidden = true
        nameLabel.text = info.name
        addressLabel.text = info.address
        commentsLabel.text = info.comments
        commentsLabel.sizeToFit()
        
        //shadow for user info view
        userInfoView.layer.shadowRadius = 5.0
        userInfoView.layer.shadowOpacity = 0.25
        userInfoView.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        userInfoView.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let paymentTap = UITapGestureRecognizer(target:self, action: #selector(self.paymentTapped(_:)))
        self.paymentStack.isUserInteractionEnabled = true
        self.paymentStack.addGestureRecognizer(paymentTap)
        
        //set up price Attributed String
        let dollar = "$"
        let dollar_attrs = [NSAttributedString.Key.font :  UIFont.init(name: "Roboto-Bold", size: 13)]
        let cost = NSMutableAttributedString(string:dollar, attributes:dollar_attrs as [NSAttributedString.Key : Any])
        
        let price = String(format: "%.2f", info.price)
        let price_attrs = [NSAttributedString.Key.font :  UIFont.init(name: "Roboto-Medium", size: 23)]
        let price_string = NSMutableAttributedString(string:price, attributes:price_attrs as [NSAttributedString.Key : Any])
        cost.append(price_string)
        
        let perHour = "/hour"
        let hour_attrs = [NSAttributedString.Key.font :  UIFont.init(name: "Roboto-Medium", size: 16)]
        let hour_string = NSMutableAttributedString(string:perHour, attributes:hour_attrs as [NSAttributedString.Key : Any])
        cost.append(hour_string)
        
        priceLabel.attributedText = cost
        
        //set up tags
        let tags: [UIButton] = [tag1, tag2, tag3, tag4]
        
        for tag in tags {
            tag.layer.borderWidth = 1.5
            tag.layer.cornerRadius = 8
            tag.layer.borderColor = CGColor.init(red: 0.427, green: 0.427, blue: 0.427, alpha: 1.0)
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
//        let mask = UIView.init(frame: mapView.frame)
//        mask.backgroundColor = UIColor.init(white: 0.0, alpha: 0.5)
//        self.mapView.addSubview(mask)
        
        if listing {
            setupPopup()
            paymentMethodLabel.isHidden = true
            totalTitleLabel.isHidden = true
            priceLabel.isHidden = true
            startTime = info.startTime
            endTime = info.endTime
            startDate = info.date
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "MMMM dth"
            let day = formatter1.string(from: startDate ?? Date())
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "h:mm a"
            let startString = formatter2.string(from: startTime! as Date)
            let endString = formatter2.string(from: endTime! as Date)
            availabilityLabel.setTitle(day + "th, " + startString + " to " + endString, for: .normal)
            availabilityLabel.titleLabel?.font = UIFont.init(name: "Roboto-Medium", size: 14)
            availabilityLabel.isEnabled = false
            
            reserveButton.isEnabled = true
            reserveButton.setTitle("Create Listing", for: .normal)
            reserveButton.backgroundColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            reserveButton.setTitleColor(.white, for: .normal)
            reserveButton.titleLabel?.font = UIFont.init(name: "Roboto-Medium", size: 16)
        }
        // short term
        else if(info.startTime != nil && info.endTime != nil && info.date != nil) {
            //time frame
            startTime = info.startTime
            endTime = info.endTime
            startDate = info.date
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "MMMM dth"
            let day = formatter1.string(from: startDate ?? Date())
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "h:mm a"
            let startString = formatter2.string(from: startTime! as Date)
            let endString = formatter2.string(from: endTime! as Date)
            availabilityLabel.setTitle(day + "th, " + startString + " to " + endString, for: .normal)
            availabilityLabel.titleLabel?.font = UIFont.init(name: "Roboto-Medium", size: 14)
            availabilityLabel.isEnabled = false
            
            //calculate total cost (for now without tax/extra fees)
            let startHour = Calendar.current.component(.hour, from: startTime! as Date)
            let startMin = Calendar.current.component(.minute, from: startTime! as Date)
            let endHour = Calendar.current.component(.hour, from: endTime! as Date)
            let endMin = Calendar.current.component(.minute, from: endTime! as Date)
            //let totalTime:Double = Double(startEpoch - endEpoch)/3600
            var totalTime: Double = abs(Double(endHour-startHour) + (Double(endMin - startMin)/60))
            if(startTime == endTime){
                totalTime = 24.0
            }else if startHour > endHour {
                totalTime += 12.0
            }
            print(totalTime)
            total = totalTime * info.price
            self.totalPrice = total
            totalLabel.text = "$" + String(format: "%.2f", total)
            totalLabel.textColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            totalLabel.font =  UIFont.init(name: "Roboto-Medium", size: 20)
            reserveButton.backgroundColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            reserveButton.setTitleColor(.white, for: .normal)
            reserveButton.titleLabel?.font = UIFont.init(name: "Roboto-Medium", size: 16)
            

            reserveButton.isEnabled = true
        }
        // long term
        else if (info.startDate != nil && info.endDate != nil) {
            availabilityLabel.isEnabled = false
            reserveButton.isEnabled = true
            
        }
        // transaction reciept
        else if (transationDate != nil) {
            availabilityLabel.setTitle(transationDate, for: .normal)
            availabilityLabel.titleLabel?.font = UIFont.init(name: "Roboto-Medium", size: 14)
            availabilityLabel.isEnabled = false
            
            timeFrameTitleLabel.text = "LAST BOOKED"
            bookmarkButton.isHidden = false
            bookmarkButton.layer.shadowRadius = 2.0
            bookmarkButton.layer.shadowOpacity = 0.3
            bookmarkButton.layer.shadowOffset = CGSize.init(width: 1, height: 2)
            bookmarkButton.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            
            totalLabel.text = "$" + String(format: "%.2f", total)
            totalLabel.textColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            totalLabel.font =  UIFont.init(name: "Roboto-Medium", size: 20)
            
            reserveButton.isEnabled = false
            reserveButton.setTitle("Book Again", for: .normal)
            reserveButton.backgroundColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            reserveButton.setTitleColor(.white, for: .normal)
            reserveButton.titleLabel?.font = UIFont.init(name: "Roboto-Medium", size: 16)
        }
        // just browsing
        else {
            availabilityLabel.setTitle("To book, go back to select a specific time frame!", for: .normal)
            reserveButton.isEnabled = false
            availabilityLabel.isEnabled = false
        }
        
        /*
        var time =  [Int: [ParkingSpaceMapAnnotation.ParkingTimeInterval]]()
        time = [
            0: [],
            1: [],
            2: [],
            3: [],
            4: [],
            5: [],
            6: []
        ]
        switch parkingType {
        case .long:
            print("long")
        case .short:
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else {
                    return
                }
                ParkingSpotService.getShortTermParkingSpotById(self.info.id) { (parkingSpot, error) in
                    if let spot = parkingSpot {
                        for i in 0...6 {
                            for times in spot.times[i] ?? [] {
                                time[i]!.append(ParkingSpaceMapAnnotation.ParkingTimeInterval(start: Date.init(timeIntervalSince1970: Double(times.start)), end: Date.init(timeIntervalSince1970: Double(times.end))))
                            }
                        }
                        DispatchQueue.main.async {
                            self.info.times = time
                        }
                    }
                }
            }
        }*/
        
    }
    
    func setupPopup() {
        blackScreen.alpha = 0.35
        blackScreen.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(blackScreen)
        popupTitle.font =  UIFont(name: "BebasNeue", size: 30)
        popupView.frame = CGRect(x: self.view.frame.midX , y: self.view.frame.midY , width: 325, height: 300)
        self.view.addSubview(popupView)
        popupView.center = self.view.center
        popupView.isHidden = false
    }
    
    @IBAction func dismissPopup(_ sender: Any) {
        popupView.removeFromSuperview()
        blackScreen.removeFromSuperview()
    }
    
    @IBAction func bookmarkButton(_ sender: Any) {
        if bookmarkFlag {
            bookmarkButton.backgroundColor = UIColor.init(red: 0.820, green: 0.788, blue: 0.847, alpha: 1.0)
            bookmarkButton.tintColor = UIColor.init(red: 0.577, green: 0.531, blue: 0.643, alpha: 1.0)
            bookmarkFlag = false
        } else {
            bookmarkButton.backgroundColor = UIColor.init(red: 0.565, green: 0.0, blue: 1.0, alpha: 1.0)
            bookmarkButton.tintColor = .white
            bookmarkFlag = true
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func availabilityButton(_ sender: Any) {
        performSegue(withIdentifier: "availabilityVC", sender: self)
    }
    
    @IBAction func reserveButton(_ sender: Any) {
        if listing {
            //UNCOMMENT when entire listing process is finished
            /*
            if parkingType == .short {
                ParkingSpotService.saveShortTermParkingSpot(ShortTermParking)
            } else {
                // set up saving of long term parking spot here
            }*/
        }
        else if let paymentResult = paymentResult{
            if let paymentMethod = paymentResult.paymentMethod, let total = self.totalPrice {
                print("Sending payment to server");
                PaymentService.postNonceToServer(paymentMethodNonce: paymentMethod.nonce, transactionAmount: total) { error in
                    if error == nil {
                        print("Payment Success!")
                        ParkingSpotService.getParkingSpotById(self.info.id) { [self] (parkingSpot, error) in
                            if let spot = parkingSpot {
                                print(spot)
                                //REPLACE WITH IF PARKING SPOT IS AVAILABLE
                                if true {
                                    print("Saving spot")
                                    let weekDay = Calendar.current.component(.weekday, from: self.startDate!)
                                    //need to switch from info.bookTimes to ShortTermParkingSpot later
                                    switch parkingType {
                                    case .long:
                                        print("long")
                                    case .short:
                                        if let parkingSpot = spot as? ShortTermParkingSpot{
                                            TransactionService.saveTransaction(customer: "", provider:self.info.name, startTime: Int(self.startTime!.timeIntervalSince1970), endTime: Int(self.endTime!.timeIntervalSince1970), address: spot.address, spot: spot)
//                                            parkingSpot.occupied[weekDay-1]?.append(ParkingTimeInterval(start: Int((self.startTime!.timeIntervalSince1970)), end: Int(self.endTime!.timeIntervalSince1970)))
                                           // ParkingSpotService.reserveParkingSpot(parkingSpot: parkingSpot as ParkingSpot, time: Int(self.endTime!.timeIntervalSince1970))
                                        }
                                    }
//                                    self.info.bookedTimes[weekDay-1]?.append(ParkingSpaceMapAnnotation.ParkingTimeInterval(start: self.startTime!, end: self.endTime!))
//
//                                    TransactionService.saveTransaction(customer: "", provider: self.info.name, startTime: Int(self.startTime!.timeIntervalSince1970), endTime: Int(self.endTime!.timeIntervalSince1970), address: spot.address, spot: spot)
                                    
                                }
                            }
                        }
                    } else {
                        print(error!.errorMessage())
                    }
                }
            }
        }else {
            print("Payment has not been selected yet.")
            //payment has not been selected
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let vc = segue.destination as? AvailabilityViewController {
            vc.delegate = self
            if (startTime != nil && endTime != nil && startDate != nil)
            {
                vc.selectedDate = startDate!
                vc.selectedStart = startTime!
                vc.selectedEnd = endTime!
                vc.times = info.times
                vc.bookedTimes = info.bookedTimes
            }
            else
            {
                //vc.startTime = NSDate.init(timeInterval: 1000, since: Date.init())
                //vc.endTime = NSDate.init(timeInterval: 5000, since: Date.init())
                vc.times = info.times
                vc.bookedTimes = info.bookedTimes
            }
        }
        
        if let vc = segue.destination as? ReservationConfirmationViewController {
            vc.address = addressLabel.text!
            vc.time = availabilityLabel.titleLabel!.text!
            vc.listing = listing
        }
    }
    
    func pass(start: Date, end: Date, date: Date, cancel: Bool) {
        if (cancel != true) {
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
            //let totalTime:Double = Double(startEpoch - endEpoch)/3600
            var totalTime: Double = abs(Double(endHour-startHour) + (Double(endMin - startMin)/60))
            if(startTime == endTime){
                totalTime = 24.0
            }else if startHour > endHour {
                totalTime += 12.0
            }
            print(totalTime)
            total = totalTime * info.price
            self.totalPrice = total
            totalLabel.text = "$" + String(format: "%.2f", total)
            totalLabel.textColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            totalLabel.font =  UIFont.init(name: "Roboto-Medium", size: 20)
            reserveButton.backgroundColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            reserveButton.setTitleColor(.white, for: .normal)
            reserveButton.titleLabel?.font = UIFont.init(name: "Roboto-Medium", size: 16)
            
            reserveButton.isEnabled = true
        }
    }
}
extension BookingViewController {
    @objc func paymentTapped(_ send: UITapGestureRecognizer) {
        print("Payment Tapped");
        var key = "sandbox_ndnbmg78_77yb2gxcsdwv5spd"
        showDropIn(clientTokenOrTokenizationKey: key)
    }
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                self.paymentResult = result
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    //function not currently being used
    func processPayment() {
        //payment has been selected
        if let paymentResult = paymentResult{
            if let paymentMethod = paymentResult.paymentMethod, let total = self.totalPrice {
                print("Sending payment to server");
                PaymentService.postNonceToServer(paymentMethodNonce: paymentMethod.nonce, transactionAmount: total) { error in
                    if error == nil {
                        print("Payment Success!")
                    } else {
                        print(error!.errorMessage())
                    }
                }
            }
        }else {
            //payment has not been selected
        }
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

