//
//  MapViewViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/28/20.
//

import UIKit
import MapKit
import GeoFire
import CoreLocation

class MapViewViewController: ViewController{
    
    let locationManager = CLLocationManager()
    
    //passed variable from hourlyTimeViewController
    var shortTermStartTime: Date!
    var shortTermEndTime: Date!
    var shortTermDate: Date!
    @IBOutlet weak var timeFrameButton: UIButton!
    
    @IBOutlet weak var SlideUpView: SlideView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var reserveBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    
    @IBOutlet weak var tag1: UIButton!
    @IBOutlet weak var tag2: UIButton!
    @IBOutlet weak var tag3: UIButton!
    @IBOutlet weak var tag4: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBAction func didTapMenuButton(_ sender: UIButton) {
        toggleMenu()
    }

    @IBAction func didTapSlideoutBlackView(_ sender: Any) {
        toggleMenu()
    }
    
    @IBOutlet weak var slideoutBlackView: UIView!
    
    
    @IBOutlet var slideOutBar: SlideOutView!
    var slideOutBarCollapsed = true
    var selectedAnnotation: ParkingSpaceMapAnnotation?
    let blackView = UIView()
    let animationTime = SlideViewConstant.animationTime
    var originalCenterOfslideUpView = CGFloat()
    var totalDistance = CGFloat()
    var currentSearchAnnotation: MKPointAnnotation?
    
    private var geoFire = GeoFire(firebaseRef: Database.database().reference())
    private var regionQuery: GFRegionQuery?
    private var circleQuery: GFCircleQuery? // test variable
    
    private var annotations = [ParkingSpaceMapAnnotation]()
    
    @IBOutlet var overlay: UITableView!
    private var matchingItems = [MKMapItem]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MapKit did load")
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        overlay.frame = CGRect(x: 0, y: 100, width: self.view.bounds.width, height: self.view.bounds.height-50)
        overlay.tag = 100
        overlay.dataSource = self
        overlay.delegate = self
        menuButton.setBackgroundImage(UIImage.init(named: "purple-circle"), for: .normal)
        menuButton.isHidden = false
        menuButton.layer.shadowRadius = 3.0
        menuButton.layer.shadowOpacity = 0.3
        menuButton.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        menuButton.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        self.view.addSubview(slideoutBlackView)
        self.view.addSubview(slideOutBar)
        slideOutBar.frame = CGRect(x: -self.view.bounds.width/2, y:0, width: self.view.bounds.width/2, height: self.view.bounds.height)
        
        //time frame button
        timeFrameButton.layer.shadowRadius = 4.0
        timeFrameButton.layer.shadowOpacity = 0.4
        timeFrameButton.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        timeFrameButton.layer.shadowColor = CGColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
        
        // if segued from hourlyTimeViewController, search/setup in here
        if(shortTermStartTime != nil && shortTermEndTime != nil && shortTermDate != nil) {
            print("ID:2")
            print(shortTermStartTime!)
            print(shortTermEndTime!)
            print("ID:3")
            print(shortTermDate!)
            print("ID:4")
            //time frame button
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "MMMM dth"
            let day = formatter1.string(from: shortTermDate ?? Date())
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "h:mm a"
            let startString = formatter2.string(from: shortTermStartTime! as Date)
            let endString = formatter2.string(from: shortTermEndTime! as Date)
            timeFrameButton.setTitle(day + "th, " + startString + " to " + endString, for: .normal)
        }
        else {
            timeFrameButton.setTitle("Select a specific time frame", for: . normal)
        }
        
        //set up of map
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(34.0703, -118.4441)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        
        self.mapView.setRegion(region, animated: false)
        regionQuery = geoFire.query(with: region) // for some reason geoFire isn't working with regionQuery???
        
        // get all parking spaces within a 20000 km radius from the db
        circleQuery = geoFire.query(at: CLLocation.init(latitude: location.latitude, longitude: location.longitude), withRadius: 20)
        
        _ = circleQuery?.observe(.keyEntered, with: { (key:String!, location:CLLocation!) in
            print("FOUND KEY: ",key!,"WITH LOCATION: ",location!)
            ParkingSpotService.getParkingSpotById(key!) { parkingSpot, error in
                DispatchQueue.global(qos: .userInteractive).async {
                    ParkingSpotService.getParkingSpotById(key) { [self] parkingSpot, error in
                        if let parkingSpot = parkingSpot{
                            parkingSpot.validateTimeSlot(startTime: Int(shortTermStartTime.timeIntervalSince1970), endTime: Int(shortTermEndTime.timeIntervalSince1970)) { success in
                                if (success) {
                                    if let parkingSpot = parkingSpot as? ShortTermParkingSpot {
                                        parkingSpot.validateTimeSlot(start: Int(shortTermStartTime.timeIntervalSince1970), end: Int(shortTermEndTime.timeIntervalSince1970)) { success in
                                            if(success){
                                                //IF PARKING SPOT IS AVAILABLE
                                                print("Parking Spot is available")
                                                print("Query by location")
                                                let address = parkingSpot.address.street + ", " + parkingSpot.address.city + ", " + parkingSpot.address.state + " " + parkingSpot.address.zip
                                                let annotation = ParkingSpaceMapAnnotation(id: parkingSpot.id, name: parkingSpot.firstName + " " + parkingSpot.lastName, coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, address: address, tags: parkingSpot.tags, comments: parkingSpot.comments,startTime: nil, endTime: nil, date: nil, startDate: nil, endDate: nil)
                                                // short-term parking
                                                if(self.shortTermStartTime != nil && self.shortTermEndTime != nil && self.shortTermDate != nil) {
                                                    annotation.startTime = self.shortTermStartTime
                                                    annotation.endTime = self.shortTermEndTime
                                                    annotation.date = self.shortTermDate
                                                }
                                                self.annotations.append(annotation)
                                                mapView.addAnnotation(annotation)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
        
        
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//          guard let self = self else {
//            return
//          }
//            ParkingSpotService.getAllParkingSpots() { parkingSpots, error in
//                print("Rendering parking spots on map")
//                if let parkingSpots = parkingSpots {
//                    for parking in parkingSpots {
//                        if parking.isAvailable {
//                            let address = parking.address.street + ", " + parking.address.city + ", " + parking.address.state + " " + parking.address.zip
//
//                            self.annotations.append(ParkingSpaceMapAnnotation(id: parking.id, name: parking.firstName + " " + parking.lastName, coordinate: CLLocationCoordinate2DMake(parking.coordinates.lat, parking.coordinates.long), price: parking.pricePerHour, address: address , tags: parking.tags, comments: parking.comments))
//                        }
//                    }
//                    print("Adding annotations")
//                    DispatchQueue.main.async {
//                        self.mapView.addAnnotations(self.annotations)
//                    }
//                }
//             }
//        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateView), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        //test annotations until set up with firebase
//        let annotation1 = ParkingSpaceMapAnnotation(name: "Joe Bruin", coordinate: CLLocationCoordinate2DMake(34.0703, -118.4441), price: 4.00, time: "3:00-4:00")
//        let annotation2 = ParkingSpaceMapAnnotation(name: "FIRST LAST ", coordinate: CLLocationCoordinate2DMake(34.072, -118.43), price: 7.0, time: "5:00-8:00")
//        let annotation3 = ParkingSpaceMapAnnotation(name: "First Last ", coordinate: CLLocationCoordinate2DMake(34.071, -118.439), price: 8.0, time: "7:00-9:00")
//        let annotation4 = ParkingSpaceMapAnnotation(name: "First Last ", coordinate: CLLocationCoordinate2DMake(34.073, -118.449), price: 5.0, time: "2:30-4:00")
//        let annotation5 = ParkingSpaceMapAnnotation(name: "First Last ", coordinate: CLLocationCoordinate2DMake(34.08, -118.4381), price: 6.0, time: "11:00-12:00")
        
//        annotations.append(contentsOf: [annotation1, annotation2, annotation3, annotation4, annotation5])
//
//        self.mapView.addAnnotations(annotations)
        setupView()
        SlideUpView.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func updateView() {
        self.SlideUpView.isHidden = true
        print("update View")
    }
    
    @IBAction func timeFrameBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func reserveBtn(_ sender: UIButton) {
        let parkingSpace = mapView.selectedAnnotations as! [ParkingSpaceMapAnnotation]
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "bookingView") as! BookingViewController
//        self.navigationController?.pushViewController(nextViewController, animated: true)
        nextViewController.modalPresentationStyle = .fullScreen
        nextViewController.modalTransitionStyle = .coverVertical
        nextViewController.info = parkingSpace[0]
        
        self.present(nextViewController, animated:true)
    }
    
//    @IBAction func transactionsPressed(_ sender: UIButton) {
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "transactionsTableView") as! TransactionTableViewController
//        nextViewController.modalPresentationStyle = .fullScreen
//        nextViewController.modalTransitionStyle = .crossDissolve
//        self.present(nextViewController, animated: true, completion: nil)
//    }
    private func setupView(){
        SlideUpView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: SlideViewConstant.slideViewHeight)
        SlideUpView.layoutIfNeeded()
        SlideUpView.addDropShadow(cornerRadius: SlideViewConstant.cornerRadiusOfSlideView)
        
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.0)
        blackView.frame = self.view.frame
        blackView.frame.size.height = self.view.frame.height
        blackView.alpha = 0
        self.view.insertSubview(blackView, belowSubview: SlideUpView)
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
//
        let downPan = UIPanGestureRecognizer(target: self, action: #selector(dismissslideUpView(_:)))
        SlideUpView.addGestureRecognizer(downPan)
    }
    
    //Animation when user interacts with the slide view
    @objc func dismissslideUpView(_ gestureRecognizer:UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.SlideUpView)
        
        switch gestureRecognizer.state{
        case .began, .changed:
            //Pan gesture began and continued

            gestureRecognizer.view!.center = CGPoint(x: self.SlideUpView.center.x, y: max(gestureRecognizer.view!.center.y + translation.y, originalCenterOfslideUpView))
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.SlideUpView)
            totalDistance += translation.y
            break
        case .ended:
            //Pan gesture ended
            // Set a constant : self.slideUpView.center.y > self.view.bounds.height - 40
            // OR set the following if statement
            if gestureRecognizer.velocity(in: SlideUpView).y > 300 {
                handleDismiss()
            } else if totalDistance >= 0{
                UIView.animate(withDuration: TimeInterval(animationTime), delay: 0, options: [.curveEaseOut],
                               animations: {
                                self.SlideUpView.center.y -= self.totalDistance
                                self.SlideUpView.layoutIfNeeded()
                }, completion: nil)
            } else {
                
            }
            
            totalDistance = 0
            break
        case .failed:
            print("Failed to do UIPanGestureRecognizer with slideUpView")
            break
        default:
            //default
            print("default: UIPanGestureRecognizer")
            break
        }
        mapView.selectedAnnotations.forEach({ mapView.deselectAnnotation($0, animated: false) })
        
    }
    
    @objc func handleDismiss() {
        
        UIView.animate(withDuration: TimeInterval(animationTime)) {
            self.blackView.alpha = 0
            self.SlideUpView.layer.cornerRadius = 0
            self.SlideUpView.backgroundColor = .clear
        }
        SlideUpView.slideDownHide(animationTime)
        //SlideUpBtn.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        mapView.selectedAnnotations.forEach({ mapView.deselectAnnotation($0, animated: false) })
    }
    func initializeQueryObservers() {
        if let regionQuery = regionQuery {
            regionQuery.observe(.keyMoved, with: { key, location in
                
                    print("Key: " + key + "entered the search radius.")
                DispatchQueue.global(qos: .userInteractive).async {
                    ParkingSpotService.getParkingSpotById(key) { parkingSpot, error in
                        if let parkingSpot = parkingSpot{
                            //IF PARKING SPOT IS AVAILABLEx
                            print("Query by location")
                            let address = parkingSpot.address.street + ", " + parkingSpot.address.city + ", " + parkingSpot.address.state + " " + parkingSpot.address.zip
                            let annotation = ParkingSpaceMapAnnotation(id: parkingSpot.id, name: parkingSpot.firstName + " " + parkingSpot.lastName, coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, address: address, tags: parkingSpot.tags, comments: parkingSpot.comments,startTime: nil, endTime: nil, date: nil, startDate: nil, endDate: nil)
                            // short-term parking
                            if(self.shortTermStartTime != nil && self.shortTermEndTime != nil && self.shortTermDate != nil) {
                                annotation.startTime = self.shortTermStartTime
                                annotation.endTime = self.shortTermEndTime
                                annotation.date = self.shortTermDate
                            }
                        }
                    }
                }
            })
            //currently no behavior when parking spot leaves the view
//            regionQuery.observe(.keyExited, with: { key, location in
//                self.mapView.addAnnotations(self.annotations)
//            })
        }
    }
    func updateMapView() {
    }
    //transaction button, for later use
    @IBAction func transactionButton(_ sender: UIButton){}
}

extension UIView {
    func addDropShadow(scale: Bool = true, cornerRadius: CGFloat ) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        //layer.shadowColor = UIColor.black.cgColor
        //layer.shadowOpacity = 0.5
        //layer.shadowOffset = .zero
        //layer.shadowRadius = 4.5
        
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func slideUpShow(_ duration: CGFloat){
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [.curveEaseOut],
                       animations: {
                        self.center.y -= self.bounds.height
                        self.layoutIfNeeded()
        }, completion: nil)
        self.isHidden = false
    }
    func slideDownHide(_ duration: CGFloat){
        
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [.curveEaseOut],
                       animations: {
                        self.center.y += self.bounds.height
                        self.layoutIfNeeded()
                        
        },  completion: {(_ completed: Bool) -> Void in
            self.isHidden = true
        })
    }
    
    func dismiss() {
        self.center.y += self.bounds.height
        self.layoutIfNeeded()
        self.isHidden = true
    }
    
}


extension MapViewViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        if let parkingSpace = annotation as? ParkingSpaceMapAnnotation {
            print("Parking Space Map Annotation")
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

            let dollar = "$"
            let dollar_attrs = [NSAttributedString.Key.font : UIFont.init(name: "Roboto-Bold", size: 9)]
            let cost = NSMutableAttributedString(string:dollar, attributes:dollar_attrs as [NSAttributedString.Key : Any])

            let price = String(format: "%.2f", parkingSpace.price)
            let price_attrs = [NSAttributedString.Key.font : UIFont.init(name: "Roboto-Bold", size: 13)]
            let price_string = NSMutableAttributedString(string:price, attributes:price_attrs as [NSAttributedString.Key : Any])
            cost.append(price_string)
            label.attributedText = cost

            annotationView?.addSubview(label)
            return annotationView
        } else {
            return nil
        }
//        let parkingSpace = annotation as! ParkingSpaceMapAnnotation
//        print("Parking Space Map Annotation")
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
//
//         if annotationView == nil {
//             annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
//             annotationView?.canShowCallout = false
//
//         } else {
//             annotationView?.annotation = annotation
//         }
//        annotationView?.image = UIImage(named: "mapAnnotation")
//        let label = UILabel(frame: CGRect(x: 7, y: -4, width: 40, height: 30))
//        label.textColor = .white
//
//        let dollar = "$"
//        let dollar_attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 9)]
//        let cost = NSMutableAttributedString(string:dollar, attributes:dollar_attrs)
//
//        let price = String(format: "%.2f", parkingSpace.price)
//        let price_attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13)]
//        let price_string = NSMutableAttributedString(string:price, attributes:price_attrs)
//        cost.append(price_string)
//        label.attributedText = cost
//
//        annotationView?.addSubview(label)
//        return annotationView
    }
    /*
    //not the optimal solution yet
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //calculate meters in latitude of current map span
        let span = mapView.region.span
        let center = mapView.region.center
        let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        let queryRadius = loc1.distance(from: loc2)
        print(queryRadius)
        
        if (circleQuery?.radius) ?? 0 < queryRadius {
            circleQuery = geoFire.query(at: CLLocation.init(latitude: center.latitude, longitude: center.longitude), withRadius: queryRadius/1000)
            
            _ = circleQuery?.observe(.keyEntered, with: { (key:String!, location:CLLocation!) in
                print("FOUND KEY: ",key!,"WITH LOCATION: ",location!)
                ParkingSpotService.getParkingSpotById(key!) { parkingSpot, error in
                    DispatchQueue.global(qos: .userInteractive).async {
                        ParkingSpotService.getParkingSpotById(key) { [self] parkingSpot, error in
                            if let parkingSpot = parkingSpot, parkingSpot.isAvailable{
                                print("Query with change")
                                let address = parkingSpot.address.street + ", " + parkingSpot.address.city + ", " + parkingSpot.address.state + " " + parkingSpot.address.zip
                                let annotation = ParkingSpaceMapAnnotation(id: parkingSpot.id, name: parkingSpot.firstName + " " + parkingSpot.lastName, coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, address: address, tags: parkingSpot.tags, comments: parkingSpot.comments)
                                annotations.append(annotation)
                                mapView.addAnnotation(annotation)
                            }
                        }
                    }
                }
            })
        }
    }*/
    

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let parkingSpace = view.annotation as? ParkingSpaceMapAnnotation {
            let region: MKCoordinateRegion =  MKCoordinateRegion(center: parkingSpace.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            mapView.setRegion(region, animated: true)
            menuButton.isHidden = false
            //view.image = UIImage(named: "mapAnnotation")
        } else {
            return
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let userLocation = mapView.view(for: mapView.userLocation)
            userLocation?.isEnabled = false
    }
   
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Annotation selected")
        if let parkingSpace = view.annotation as? ParkingSpaceMapAnnotation {
            // view.image = UIImage(named: "mapAnnotationSelected")
             let region: MKCoordinateRegion =  MKCoordinateRegion(center: parkingSpace.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
             
             mapView.setRegion(region, animated: true)
            menuButton.isHidden = true
            SlideUpView.isHidden = false
            totalDistance = 0
            SlideUpView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: SlideViewConstant.slideViewHeight)
            UIView.animate(withDuration: TimeInterval(animationTime), animations: {
                self.blackView.alpha = 1
                self.SlideUpView.backgroundColor = UIColor.white
                self.SlideUpView.layer.cornerRadius = SlideViewConstant.cornerRadiusOfSlideView
                self.SlideUpView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }, completion: nil)
            SlideUpView.slideUpShow(animationTime)
            originalCenterOfslideUpView = SlideUpView.center.y
          
            nameLabel.text = parkingSpace.name
            addressLabel.text = parkingSpace.address
            
            //set up price label
            let dollar = "$"
            let dollar_attrs = [NSAttributedString.Key.font : UIFont.init(name: "Roboto-Bold", size: 12)]
            let cost = NSMutableAttributedString(string:dollar, attributes:dollar_attrs as [NSAttributedString.Key : Any])
            
            let price = String(format: "%.2f", parkingSpace.price)
            let price_attrs = [NSAttributedString.Key.font : UIFont.init(name: "Roboto-Medium", size: 22)]
            let price_string = NSMutableAttributedString(string:price, attributes:price_attrs as [NSAttributedString.Key : Any])
            cost.append(price_string)
            
            let perHour = " per hour"
            let hour_attrs = [NSAttributedString.Key.font : UIFont.init(name: "Roboto-Medium", size: 16)]
            let hour_string = NSMutableAttributedString(string:perHour, attributes:hour_attrs as [NSAttributedString.Key : Any])
            cost.append(hour_string)
            
            priceLabel.attributedText = cost
            
            //set up tags
            let tags: [UIButton] = [tag1, tag2, tag3, tag4]
            
            for tag in tags {
                tag.layer.borderWidth = 1.5
                tag.layer.cornerRadius = 8
                tag.layer.borderColor = CGColor.init(red: 0.502, green: 0.455, blue: 0.576, alpha: 1.0)
                tag.isHidden = true
            }
            for n in 0...(parkingSpace.tags.count-1) {
                tags[n].setTitle(parkingSpace.tags[n], for: .normal)
                tags[n].isHidden = false
            }
            
            //set up availability -- not done yet
            let avail = "Available  "
            let avail_attrs = [NSAttributedString.Key.font : UIFont.init(name: "Roboto-Regular", size: 14)]
            let timeAvail = NSMutableAttributedString(string:avail, attributes:avail_attrs as [NSAttributedString.Key : Any])
            
            var now = "NOW"
            /*
            let weekDay = Calendar.current.component(.weekday, from: Date())
            
            func hourAsInt(date: Date) -> Int {
                return Calendar.current.component(.hour, from: date)
            }
            func minAsInt(date: Date) -> Int {
                return Calendar.current.component(.minute, from: date)
            }
            func compareTimes(h1: Int, h2: Int, m1: Int, m2: Int) -> Bool {
                if h1 < h2 || (h1 == h2 && m1 < m2) {
                    return true
                }
                return false
            }
            var i = -1
            while parkingSpace.times[weekDay+i]!.isEmpty { //find most close unbooked day
                i += 1
            }
            let booked = parkingSpace.bookedTimes[weekDay+i]
            let timeRange = parkingSpace.times[weekDay+i]![0]
            let endTime = timeRange.end
            
            if compareTimes(h1: hourAsInt(date: endTime), h2: hourAsInt(date: Date()), m1: minAsInt(date: endTime), m2: minAsInt(date: Date())) {
                switch weekDay+1 {
                    case 1:
                        now = "SUNDAY"
                    case 2:
                        now = "MONDAY"
                    case 3:
                        now = "TUESDAY"
                    case 4:
                        now = "WEDNESDAY"
                    case 5:
                        now = "THURSDAY"
                    case 6:
                        now = "FRIDAY"
                    case 7:
                        now = "SATURDAY"
                default:
                    break
                }
            }
            else {
                for interval in booked ?? [] {
                    if compareTimes(h1: hourAsInt(date: Date()), h2: hourAsInt(date: interval.end), m1: minAsInt(date: Date()), m2: minAsInt(date: interval.end)) && compareTimes(h1: hourAsInt(date: interval.start), h2: hourAsInt(date: Date()), m1: minAsInt(date: interval.start), m2: minAsInt(date: Date()))
                    {
                        now = "LATER TODAY"
                    }
                }
            }*/
            
            let now_attrs =  [NSAttributedString.Key.font :  UIFont.init(name: "Roboto-MediumItalic", size: 16), NSAttributedString.Key.foregroundColor : UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)]
            let nowLabel = NSMutableAttributedString(string:now, attributes:now_attrs as [NSAttributedString.Key : Any])
            timeAvail.append(nowLabel)
            availableLabel.attributedText = timeAvail
        } else {
            return
        }
        
    }

    
}


//for the "Book" button in the callouts, pass data and segue in here 
extension MapViewViewController: ParkingCalloutViewDelegate {
    func mapView(_ mapView: MKMapView, didTapDetailsButton button: UIButton, for annotation: MKAnnotation) {
        let parkingSpace = annotation as! ParkingSpaceMapAnnotation
        let name = parkingSpace.name
        let coordinates = String(parkingSpace.coordinate.latitude) + ", " + String(parkingSpace.coordinate.longitude)
        let price = parkingSpace.price
        print(name)
        print(coordinates)
        print(price)
        print(time)
    }
}
extension MapViewViewController: CLLocationManagerDelegate {
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
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
extension MapViewViewController: UITableViewDataSource, UITableViewDelegate {
    func parseAddress(selectedItem: MKPlacemark) -> String{
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        dropPinZoomIn(placemark: selectedItem)
        if let overlay = self.view.viewWithTag(100) {
            overlay.removeFromSuperview()
        }
        searchBar.text = selectedItem.title
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
    func dropPinZoomIn(placemark: MKPlacemark) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.title
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        if let currentSearchAnnotation = currentSearchAnnotation {
            mapView.removeAnnotation(currentSearchAnnotation)
        }
        currentSearchAnnotation = annotation
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
extension MapViewViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.SlideUpView.isHidden = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(center: mapView.centerCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        let search = MKLocalSearch(request: request)
        search.start() { response, error in
            if let response = response {
                print(response.mapItems)
                self.matchingItems = response.mapItems
                self.overlay.reloadData()
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        self.SlideUpView.isHidden = true
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view.addSubview(overlay)
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let overlay = self.view.viewWithTag(100) {
            overlay.removeFromSuperview()
        }
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        self.SlideUpView.isHidden = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let overlay = self.view.viewWithTag(100) {
            overlay.removeFromSuperview()
        }
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        self.SlideUpView.isHidden = true
    }
}
extension MapViewViewController {
    func toggleMenu() {
        print("Toggle Menu")
        if(slideOutBarCollapsed) {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.slideOutBar.frame.origin.x = 0
                self.slideoutBlackView.isHidden = false
                self.slideoutBlackView.alpha = 0.3
                self.menuButton.frame.origin.x = self.view.bounds.width/2 + 30
            }, completion: { completed in
                self.slideOutBarCollapsed = false
            })
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.slideOutBar.frame.origin.x = -self.view.bounds.width/2
                self.slideoutBlackView.isHidden = true
                self.slideoutBlackView.alpha = 0
                self.menuButton.frame.origin.x = 30
            }, completion: { completed in
                self.slideOutBarCollapsed = true
            })
        }
        
//        slideOutBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width/2, height: self.view.bounds.height)
        
        
    }
}
private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

