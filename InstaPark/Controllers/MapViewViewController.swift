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
import Firebase

class MapViewViewController: ViewController{
    
    let locationManager = CLLocationManager()
    let defaults = UserDefaults.standard
    
    @IBOutlet var timeSelectionPopup: UIView!
    @IBOutlet weak var slideOutMenuUserName: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet var blackScreen: UIView!
    //passed variable from hourlyTimeViewController
    var shortTermStartTime: Date!
    var shortTermEndTime: Date!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    var shortTermDate: Date!
    @IBOutlet weak var timeFrameButton: UIButton!
    
    @IBOutlet weak var SlideUpView: SlideView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var reserveBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
   // @IBOutlet weak var availableLabel: UILabel!
    
//    @IBOutlet weak var tag1: UIButton!
//    @IBOutlet weak var tag2: UIButton!
//    @IBOutlet weak var tag3: UIButton!
//    @IBOutlet weak var tag4: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBAction func didTapMenuButton(_ sender: UIButton) {
        toggleMenu()
    }

    @IBAction func didTapSlideoutBlackView(_ sender: Any) {
        toggleMenu()
    }
    
    @IBOutlet weak var slideoutBlackView: UIView!
    var selectedAnnotationTags = [String]()
    var selectedImages = [String]()
    var images = [UIImage]()
    
    
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("Show navigation bar")
//        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MapKit did load")
        if shortTermStartTime == nil || shortTermEndTime == nil {
            setUpTimePopup()
        }
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
        
        // make user name & image a user default so it doesn't have to be queried every time
        
        
        UserService.getUserById(Auth.auth().currentUser!.uid) { (user, error) in
            if let user = user {
                self.slideOutMenuUserName.text = user.displayName
                let photoURL = user.photoURL
                if photoURL != "" {
                    // set profile photo image for slide out menu when users have them
                }
            }
        }
        
        //time frame button
        timeFrameButton.layer.shadowRadius = 4.0
        timeFrameButton.layer.shadowOpacity = 0.4
        timeFrameButton.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        timeFrameButton.layer.shadowColor = CGColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
        
        //tag collection view
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.allowsSelection = false
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.allowsSelection = false
        tagCollectionView.tag = 2
        imageCollectionView.tag = 0
        imageCollectionView.roundTopCorners(cornerRadius: Double(SlideViewConstant.cornerRadiusOfSlideView))
        
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
//        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
//        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(34.0703, -118.4441)
//        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
//
//        self.mapView.setRegion(region, animated: false)
//        regionQuery = geoFire.query(with: region) // for some reason geoFire isn't working with regionQuery???
//        circleQuery = geoFire.query(at: CLLocation.init(latitude: location.latitude, longitude: location.longitude), withRadius: 20)
//        queryInRegion(region: region, location: location)
//        // if user has chosen a time frame & date query only to that time frame/date
//        if shortTermStartTime != nil && shortTermEndTime != nil {
//            // get all parking spaces within a 20000 km radius from the db
//            _ = circleQuery?.observe(.keyEntered, with: { (key:String!, location:CLLocation!) in
//                print("FOUND KEY: ",key!,"WITH LOCATION: ",location!)
//                ParkingSpotService.getParkingSpotById(key!) { parkingSpot, error in
//                    DispatchQueue.global(qos: .userInteractive).async {
//                        ParkingSpotService.getParkingSpotById(key) { [self] parkingSpot, error in
//                            if let parkingSpot = parkingSpot{
//                                parkingSpot.validateTimeSlot(start: Int(shortTermStartTime.timeIntervalSince1970), end: Int(shortTermEndTime.timeIntervalSince1970)) { success in
//                                    if (success) {
//                                        if let parkingSpot = parkingSpot as? ShortTermParkingSpot {
//                                            parkingSpot.validateTimeSlot(start: Int(shortTermStartTime.timeIntervalSince1970), end: Int(shortTermEndTime.timeIntervalSince1970)) { success in
//                                                if(success){
//                                                    //IF PARKING SPOT IS AVAILABLE
//                                                    print("Parking Spot is available")
//                                                    print("Query by location")
//                                                    let annotation = ParkingSpaceMapAnnotation(id: parkingSpot.id, name: "", coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, address: parkingSpot.address, tags: parkingSpot.tags, comments: parkingSpot.comments,startTime: nil, endTime: nil, date: nil, startDate: nil, endDate: nil, images: parkingSpot.images)
//                                                    // short-term parking
//                                                    if(self.shortTermStartTime != nil && self.shortTermEndTime != nil && self.shortTermDate != nil) {
//                                                        annotation.startTime = self.shortTermStartTime
//                                                        annotation.endTime = self.shortTermEndTime
//                                                        annotation.date = self.shortTermDate
//                                                    }
//                                                    self.annotations.append(annotation)
//                                                    mapView.addAnnotation(annotation)
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            })
//        }
//        // no time is selected - query all parking spots in user location so map is not empty??
//        else {
//            _ = circleQuery?.observe(.keyEntered, with: { (key:String!, location:CLLocation!) in
//                print("FOUND KEY: ",key!,"WITH LOCATION: ",location!)
//                ParkingSpotService.getParkingSpotById(key!) { parkingSpot, error in
//                    DispatchQueue.global(qos: .userInteractive).async {
//                        ParkingSpotService.getParkingSpotById(key) { [self] parkingSpot, error in
//                            if let parkingSpot = parkingSpot{
//                                if let parkingSpot = parkingSpot as? ShortTermParkingSpot {
//                                    print("Query by location")
//                                    let annotation = ParkingSpaceMapAnnotation(id: parkingSpot.id, name: "", coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, address: parkingSpot.address, tags: parkingSpot.tags, comments: parkingSpot.comments,startTime: nil, endTime: nil, date: nil, startDate: nil, endDate: nil, images: parkingSpot.images)
//                                    // short-term parking
//                                    if(self.shortTermStartTime != nil && self.shortTermEndTime != nil && self.shortTermDate != nil) {
//                                        annotation.startTime = self.shortTermStartTime
//                                        annotation.endTime = self.shortTermEndTime
//                                        annotation.date = self.shortTermDate
//                                    }
//                                    self.annotations.append(annotation)
//                                    mapView.addAnnotation(annotation)
//                                }
//                            }
//                        }
//                    }
//                }
//            })
//        }
//
        
        
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
        setUpTimePopup()
    }
    @IBAction func reserveBtn(_ sender: UIButton) {
        let parkingSpace = mapView.selectedAnnotations as! [ParkingSpaceMapAnnotation]
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "bookingView") as! BookingViewController
//        self.navigationController?.pushViewController(nextViewController, animated: true)
        nextViewController.modalPresentationStyle = .fullScreen
        nextViewController.modalTransitionStyle = .coverVertical
        nextViewController.info = parkingSpace[0]
        nextViewController.images = images
        
        self.present(nextViewController, animated:true)
    }
    
    func queryInRegion(region: MKCoordinateRegion, location: CLLocationCoordinate2D) {
        regionQuery = geoFire.query(with: region) // for some reason geoFire isn't working with regionQuery???
        circleQuery = geoFire.query(at: CLLocation.init(latitude: location.latitude, longitude: location.longitude), withRadius: 20)
        // if user has chosen a time frame & date query only to that time frame/date
        if shortTermStartTime != nil && shortTermEndTime != nil {
            // get all parking spaces within a 20000 km radius from the db
            _ = circleQuery?.observe(.keyEntered, with: { (key:String!, location:CLLocation!) in
                print("FOUND KEY: ",key!,"WITH LOCATION: ",location!)
                ParkingSpotService.getParkingSpotById(key) { parkingSpot, error in
                    DispatchQueue.global(qos: .userInteractive).async {
                        ParkingSpotService.getParkingSpotById(key) { [self] parkingSpot, error in
                            if let parkingSpot = parkingSpot{
                                parkingSpot.validateTimeSlot(start: Int(shortTermStartTime.timeIntervalSince1970), end: Int(shortTermEndTime.timeIntervalSince1970)) { success in
                                    if (success) {
                                        if let parkingSpot = parkingSpot as? ShortTermParkingSpot {
                                            parkingSpot.validateTimeSlot(start: Int(shortTermStartTime.timeIntervalSince1970), end: Int(shortTermEndTime.timeIntervalSince1970)) { success in
                                                if(success && parkingSpot.provider != ""){
                                                    UserService.getUserById(parkingSpot.provider) { (user, error) in
                                                        if let user = user {
                                                            //IF PARKING SPOT IS AVAILABLE
                                                            print("Parking Spot is available")
                                                            print("Query by location")
                                                            
                                                            let annotation = ParkingSpaceMapAnnotation(id: parkingSpot.id, name: user.displayName, email: user.email, phoneNumber: user.phoneNumber, photo: user.photoURL, coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, address: parkingSpot.address, tags: parkingSpot.tags, comments: parkingSpot.comments,startTime: nil, endTime: nil, date: nil, startDate: nil, endDate: nil, images: parkingSpot.images)
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
                    }
                }
            })
        }
        // no time is selected - query all parking spots in user location so map is not empty??
        else {
            _ = circleQuery?.observe(.keyEntered, with: { (key:String!, location:CLLocation!) in
                print("FOUND KEY: ",key!,"WITH LOCATION: ",location!)
                ParkingSpotService.getParkingSpotById(key!) { parkingSpot, error in
                    DispatchQueue.global(qos: .userInteractive).async {
                        ParkingSpotService.getParkingSpotById(key) { [self] parkingSpot, error in
                            if let parkingSpot = parkingSpot{
                                if let parkingSpot = parkingSpot as? ShortTermParkingSpot {
                                    if parkingSpot.provider != "" {
                                        UserService.getUserById(parkingSpot.provider) { (user, error) in
                                            if let user = user {
                                                print("Query by location")
                                                let annotation = ParkingSpaceMapAnnotation(id: parkingSpot.id, name: user.displayName, email: user.email, phoneNumber: user.phoneNumber, photo: user.photoURL, coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, address: parkingSpot.address, tags: parkingSpot.tags, comments: parkingSpot.comments,startTime: nil, endTime: nil, date: nil, startDate: nil, endDate: nil, images: parkingSpot.images)
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
            })
        }
    }
    
    func existingAnnotation(location: CLLocationCoordinate2D) -> Bool{
        for annotation in mapView.annotations {
            if location.longitude == annotation.coordinate.longitude && location.latitude == annotation.coordinate.latitude {
                return true
            }
        }
        return false
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
                            let annotation = ParkingSpaceMapAnnotation(id: parkingSpot.id, name: "", email: "", phoneNumber: "", photo: "", coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, address: parkingSpot.address, tags: parkingSpot.tags, comments: parkingSpot.comments,startTime: nil, endTime: nil, date: nil, startDate: nil, endDate: nil, images: parkingSpot.images)
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
    
    //MARK: time selection popup view setup
    func setUpTimePopup() {
        blackScreen.alpha = 0.35
        blackScreen.backgroundColor = .black
        blackScreen.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(blackScreen)
        self.view.addSubview(timeSelectionPopup)
        timeSelectionPopup.isHidden = false
        timeSelectionPopup.center.x = self.view.center.x
        timeSelectionPopup.center.y = self.view.frame.height * 3 / 4
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut],
                       animations: {
                        self.timeSelectionPopup.center = self.view.center
        }, completion: nil)
    }
    func dismissTimePopup() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseIn],
                       animations: {
                        self.timeSelectionPopup.center.y = self.view.frame.height * 3 / 4
                       }, completion: {_ in
                        self.timeSelectionPopup.removeFromSuperview()
                        self.timeSelectionPopup.isHidden = true
                        self.blackScreen.removeFromSuperview()
                       })
    }
    @IBAction func timePopupDismiss(_ sender: Any) {
        dismissTimePopup()
    }
    @IBAction func timePopupSkipToMap(_ sender: Any) {
        dismissTimePopup()
    }
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
            print("price is: \(price) at location (\(annotation.coordinate.longitude), \(annotation.coordinate.latitude))")
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
            selectedAnnotationTags = [String]()
            selectedImages = [String]()
            images = [UIImage]()
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
            //slide up view without images size: 280
            if parkingSpace.images.isEmpty {
                self.imageCollectionView.isHidden = true
                self.imageCollectionView.frame.size.height = 0
                self.SlideUpView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: SlideViewConstant.slideViewSmallHeight)
                self.SlideUpView.frame.size.height = SlideViewConstant.slideViewSmallHeight
            } else {
                self.imageCollectionView.isHidden = false
                self.imageCollectionView.frame.size.height = 144
                self.SlideUpView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: SlideViewConstant.slideViewHeight)
            }
            self.SlideUpView.layoutIfNeeded()
            
            UIView.animate(withDuration: TimeInterval(animationTime), animations: {
                self.blackView.alpha = 1
                self.SlideUpView.backgroundColor = UIColor.white
                self.SlideUpView.layer.cornerRadius = SlideViewConstant.cornerRadiusOfSlideView
                self.SlideUpView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }, completion: nil)
            SlideUpView.slideUpShow(animationTime)
            originalCenterOfslideUpView = SlideUpView.center.y
          
            nameLabel.text = parkingSpace.name
            addressLabel.text = parkingSpace.address.toString()
            
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
            self.selectedAnnotationTags = parkingSpace.tags
            self.selectedImages = parkingSpace.images
            tagCollectionView.reloadData()
            if !selectedImages.isEmpty {
//                if selectedImages.count == 1 {
//                    imageCollectionView.roundCorners(corners: [.topLeft, .topRight], radius: SlideViewConstant.cornerRadiusOfSlideView)
//                } else {
//
//                }
                print("reloading images")
                imageCollectionView.reloadData()
            }
            
//            let tags: [UIButton] = [tag1, tag2, tag3, tag4]
//
//            for tag in tags {
//                tag.layer.borderWidth = 1.5
//                tag.layer.cornerRadius = 8
//                tag.layer.borderColor = CGColor.init(red: 0.502, green: 0.455, blue: 0.576, alpha: 1.0)
//                tag.isHidden = true
//            }
//            for n in 0...(parkingSpace.tags.count-1) {
//                tags[n].setTitle(parkingSpace.tags[n], for: .normal)
//                tags[n].isHidden = false
//            }
            
            
//            let avail = "Available  "
//            let avail_attrs = [NSAttributedString.Key.font : UIFont.init(name: "Roboto-Regular", size: 14)]
//            let timeAvail = NSMutableAttributedString(string:avail, attributes:avail_attrs as [NSAttributedString.Key : Any])
//
//            var now = "NOW"
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
            
//            let now_attrs =  [NSAttributedString.Key.font :  UIFont.init(name: "Roboto-MediumItalic", size: 16), NSAttributedString.Key.foregroundColor : UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)]
//            let nowLabel = NSMutableAttributedString(string:now, attributes:now_attrs as [NSAttributedString.Key : Any])
//            timeAvail.append(nowLabel)
//            availableLabel.attributedText = timeAvail
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
            self.queryInRegion(region: region, location: location.coordinate)
            mapView.setRegion(region, animated: true)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(34.0703, -118.4441)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: false)
        self.queryInRegion(region: region, location: location)
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
        let annotations = self.mapView.annotations
        self.mapView.removeAnnotations(annotations)
        self.annotations = [ParkingSpaceMapAnnotation]()
        self.queryInRegion(region: region, location: annotation.coordinate)
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

extension MapViewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0 {
            if selectedImages.count == 1 {
                return CGSize(width: self.view.frame.width, height: 144)
            }
            else if !selectedImages.isEmpty {
                return CGSize(width: 250, height: 144)
            }
            return CGSize(width: 0, height: 0)
        } else {
            let index = indexPath.row
            var width = 63 + 10
            if self.selectedAnnotationTags[index].count > 8 {
                width = (self.selectedAnnotationTags[index].count * 6) + 30
            }
            return CGSize(width: CGFloat(width), height: 30)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 2 {
            return self.selectedAnnotationTags.count
        } else {
            return self.selectedImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 2 {
            print("refreshing tags")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! BookingTagCollectionViewCell
            let index = indexPath.row
            var width = 63
            if self.selectedAnnotationTags[index].count > 8 {
                width = (self.selectedAnnotationTags[index].count * 6) + 20
            }
            cell.frame.size.width = CGFloat(width)
            cell.frame.size.height = 30
            cell.contentView.frame.size.width = CGFloat(width) + 5
            cell.contentView.frame.size.height = 30
            let tag = cell.tagLabel ?? UILabel()
            tag.layer.borderWidth = 1.5
            tag.frame.size.width = CGFloat(width)
            tag.frame.size.height = 20
            tag.layer.cornerRadius = 8
            tag.layer.borderColor = CGColor(red: 0.502, green: 0.455, blue: 0.576, alpha: 1.0)
            tag.text = self.selectedAnnotationTags[index]
            tag.textColor = UIColor.init(red: 0.502, green: 0.455, blue: 0.576, alpha: 1.0)
            tag.font = .systemFont(ofSize: 10)
            tag.textAlignment = .center
            return cell
        }
        else {
            print("refreshing pictures")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCells", for: indexPath) as! BookingImageCollectionViewCell
            
            cell.frame.size.width = 250
            cell.frame.size.height = 144
            let index = indexPath.row
            if selectedImages.count != 0 {
//                if index == 0 {
//                    cell.roundCorners(corners: [.topLeft], radius: SlideViewConstant.cornerRadiusOfSlideView)
//                }
//                else if index == selectedImages.count-1 {
//                    cell.roundCorners(corners: [.topRight], radius: SlideViewConstant.cornerRadiusOfSlideView)
//                }
                if selectedImages.count == 1 {
                    cell.sizeToFit()
                    cell.frame.size.width = collectionView.fs_width
                    cell.image.setNeedsLayout()
                    cell.image.layoutIfNeeded()
                    cell.image.frame.size.width = self.view.frame.width
                }
                let image = self.selectedImages[index]
                guard let url = URL(string: image) else {
                    print("can't convert string to URL")
                    return cell
                }
                let activityIndicator = UIActivityIndicatorView()
                activityIndicator.style = .medium
                activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                activityIndicator.hidesWhenStopped = true
                cell.addSubview(activityIndicator)
                activityIndicator.center = cell.center
                activityIndicator.startAnimating()
                let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                    guard let data = data, error == nil else {
                        print("failed to convert image from url")
                        return
                    }
                    DispatchQueue.main.async {
                        guard let UIimage = UIImage(data: data) else {
                            print("failed to make image into UIimage")
                            return
                        }
                        print("image converted")
                        activityIndicator.stopAnimating()
                        cell.image.image = UIimage
                        self.images.append(UIimage)
                    }
                }
                task.resume()
            }
            return cell
        }
    }
    
}

extension UICollectionView {
    func roundTopCorners(cornerRadius: Double) {
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}
