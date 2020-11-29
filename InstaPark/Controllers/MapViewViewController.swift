//
//  MapViewViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/28/20.
//

import UIKit
import MapKit
import GeoFire

class MapViewViewController: ViewController{
    
    let locationManager = CLLocationManager()
    
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
    
    var selectedAnnotation: ParkingSpaceMapAnnotation?
    let blackView = UIView()
    let animationTime = SlideViewConstant.animationTime
    var originalCenterOfslideUpView = CGFloat()
    var totalDistance = CGFloat()
    var currentSearchAnnotation: MKPointAnnotation?
    
    private var geoFire = GeoFire(firebaseRef: Database.database().reference())
    private var regionQuery: GFRegionQuery?
    
    private var annotations = [ParkingSpaceMapAnnotation]()
    
    @IBOutlet var overlay: UITableView!
    private var matchingItems = [MKMapItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.hideNavBar(false)
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
        //set up of map
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(34.0703, -118.4441)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        
        self.mapView.setRegion(region, animated: false)
        regionQuery = geoFire.query(with: region)
        ParkingSpotService.getAllParkingSpots() { parkingSpots, error in
            print("Rendering parking spots on map")
            if let parkingSpots = parkingSpots {
                for parking in parkingSpots {
                    if parking.isAvailable {
                        self.annotations.append(ParkingSpaceMapAnnotation(id: parking.id, name: "Test Name", coordinate: CLLocationCoordinate2DMake(parking.coordinates.lat, parking.coordinates.long), price: parking.pricePerHour, address: "125 Glenrock Ave, Los Angeles, CA 90024", tags: ["Tandem", "Hourly", "Covered"], comments: "Parking space with room for a large vehicle! \nMessage me for more details." ))
                    }
                }
                print("Adding annotations")
                self.mapView.addAnnotations(self.annotations)
            }
         }
    
        
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
    
    @IBAction func reserveBtn(_ sender: UIButton) {
        let parkingSpace = mapView.selectedAnnotations as! [ParkingSpaceMapAnnotation]
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "bookingView") as! BookingViewController
        nextViewController.modalPresentationStyle = .fullScreen
        nextViewController.modalTransitionStyle = .coverVertical
        nextViewController.info = parkingSpace[0]
        self.present(nextViewController, animated:true, completion:nil)
    }
    
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
            regionQuery.observe(.keyEntered, with: { key, location in
                DispatchQueue.global(qos: .userInteractive).async {
                    ParkingSpotService.getParkingSpotById(key) { parkingSpot, error in
                        if let parkingSpot = parkingSpot, parkingSpot.isAvailable{
                            self.annotations.append(ParkingSpaceMapAnnotation(id: parkingSpot.id, name: "Test Name", coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, address: "125 Glenrock Ave, Los Angeles, CA 90024", tags: ["Tandem", "Hourly", "Covered"], comments: "Parking space with room for a large vehicle! \nMessage me for more details."))
                        }
                    }
                }
            })
            //currently no behavior when parking spot leaves the view
//            regionQuery.observe(.keyExited, with: { key, location in
//                DispatchQueue.global(qos: .userInteractive).async {
//
//                }
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
        //self.isHidden = false
    }
    func slideDownHide(_ duration: CGFloat){
        
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [.curveEaseOut],
                       animations: {
                        self.center.y += self.bounds.height
                        self.layoutIfNeeded()
                        
        },  completion: {(_ completed: Bool) -> Void in
            //self.isHidden = true
        })
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
            let dollar_attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 9)]
            let cost = NSMutableAttributedString(string:dollar, attributes:dollar_attrs)

            let price = String(format: "%.2f", parkingSpace.price)
            let price_attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13)]
            let price_string = NSMutableAttributedString(string:price, attributes:price_attrs)
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
    
    
    
    

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let parkingSpace = view.annotation as? ParkingSpaceMapAnnotation {
            let region: MKCoordinateRegion =  MKCoordinateRegion(center: parkingSpace.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            mapView.setRegion(region, animated: true)
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
            
            //set up price label
            let dollar = "$"
            let dollar_attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
            let cost = NSMutableAttributedString(string:dollar, attributes:dollar_attrs)
            
            let price = String(format: "%.2f", parkingSpace.price)
            let price_attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 19)]
            let price_string = NSMutableAttributedString(string:price, attributes:price_attrs)
            cost.append(price_string)
            
            let perHour = " per hour"
            let hour_attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .medium)]
            let hour_string = NSMutableAttributedString(string:perHour, attributes:hour_attrs)
            cost.append(hour_string)
            
            priceLabel.attributedText = cost
            
            //set up tags
            let tags: [UIButton] = [tag1, tag2, tag3, tag4]
            
            for tag in tags {
                tag.layer.borderWidth = 1.5
                tag.layer.cornerRadius = 11
                tag.layer.borderColor = CGColor.init(red: 0.796, green: 0.651, blue: 0.821, alpha: 1.0)
                tag.isHidden = true
            }
            for n in 0...(parkingSpace.tags.count-1) {
                tags[n].setTitle(parkingSpace.tags[n], for: .normal)
                tags[n].isHidden = false
            }
            
            //set up availability -- not done yet
            let avail = "Available "
            let avail_attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]
            let timeAvail = NSMutableAttributedString(string:avail, attributes:avail_attrs)
            
            var now = "NOW"
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
            }
            
            let now_attrs =  [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)]
            let nowLabel = NSMutableAttributedString(string:now, attributes:now_attrs)
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
private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

