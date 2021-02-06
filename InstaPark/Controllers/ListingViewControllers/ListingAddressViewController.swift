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
    @IBOutlet weak var cardViewController: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var currentSearchAnnotation: MKPointAnnotation?
    var matchingItems = [MKMapItem]()
    
    //variables to save
    var coordinates: CLLocationCoordinate2D! // stores user's coordinates
    var address: String! // stores address entered in the search bar
    var parkingType: ParkingType = .short
    var ShortTermParking: ShortTermParkingSpot!
    //var LongTermParking : LongTermParkingSpot!
   
    enum CardState {
        case collapsed
        case expanded
    }
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    var endCardHeight:CGFloat = 0
    var startCardHeight:CGFloat = 0
    var cardVisible = false
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(parkingType == .short){
            print("shortterm parking")
        } else {
            print("longterm parking")
        }
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        setupCard()
        searchBar.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        //
        // Do any additional setup after loading the view.
    }
    
    func setupCard() {
        endCardHeight = self.view.frame.height * 0.8
        startCardHeight = self.view.frame.height * 0.25
        
        cardViewController.frame = CGRect(x: 0, y: self.view.frame.height - startCardHeight, width: self.view.bounds.width, height: endCardHeight)
        cardViewController.clipsToBounds = true
        self.cardViewController.layer.cornerRadius = 30
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ListingAddressViewController.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ListingAddressViewController.handleCardPan(recognizer:)))
        self.tableView.frame = CGRect(x: 0, y: self.tableView.frame.origin.y, width: self.tableView.frame.width, height: self.view.bounds.height/1.7)
        
        handleArea.addGestureRecognizer(tapGestureRecognizer)
        handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc
    func handleCardTap(recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    @objc
    func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
            
        case .changed:
            let translation = recognizer.translation(in: self.handleArea)
            var fractionComplete = translation.y / endCardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.cardViewController.frame.origin.y = self.view.frame.height - self.endCardHeight
                    self.tableView.isHidden = false
                case .collapsed:
                    self.cardViewController.frame.origin.y = self.view.frame.height - self.startCardHeight
                    self.tableView.isHidden = true
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
        }
    }
    
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }

    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    
    func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double){
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let lat: Double = pdblLatitude
            let lon: Double = pdblLongitude
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lon

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)

            var addressString : String = ""
            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    let pm = placemarks! as [CLPlacemark]
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        //var addressString : String = ""
                        if pm.subThoroughfare != nil {
                            addressString = addressString + pm.subThoroughfare! + " "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }
                        //self.address = addressString
                        //self.searchBar.text = addressString
                  }
            })
        }
    

    // MARK: - Navigation

    func checkBeforeMovingPages() -> Bool {
        if coordinates == nil {
            let alert = UIAlertController(title: "Error", message: "Please choose a valid location on the map. You can drag the annotation or use the search bar.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if address == nil || address.count == 0 {
            let alert = UIAlertController(title: "Error", message: "Please enter a valid address in the search bar to continue.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if parkingType == .short  {
            ShortTermParking.coordinates = Coordinate(lat: coordinates.latitude, long: coordinates.longitude)
            let addressArray = address.components(separatedBy: ", ")
            var stateAndZip = [String]()
            //if there is an extra street addresss line
            if addressArray.count == 5 {
                stateAndZip = addressArray[3].components(separatedBy: " ")
                ShortTermParking.address = Address(city: addressArray[2], state: stateAndZip[0], street: addressArray[0] + ", " +  addressArray[1], zip: stateAndZip[1])
                print(ShortTermParking.address)
                return true
            }
            else if addressArray.count == 4 {
                stateAndZip = addressArray[2].components(separatedBy: "  ")
                ShortTermParking.address = Address(city: addressArray[1], state: stateAndZip[0], street: addressArray[0], zip: stateAndZip[1])
                print(ShortTermParking.address)
                return true
            }
            else {
                let alert = UIAlertController(title: "Error", message: "The address you entered is invalid. Please enter a valid address in form 'Street Address, City, State, Zip' to continue.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
        } else { // LONGTERM -- do same thing as shortterm
           return true
        }

    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if coordinates == nil {
//            let alert = UIAlertController(title: "Error", message: "Please choose a valid location on the map. You can drag the annotation or use the search bar.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            return
//        }
//        if address == nil || address.count == 0 {
//            let alert = UIAlertController(title: "Error", message: "Please enter a valid address in the search bar to continue.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            return
//        }
//        if parkingType == .short  {
//            ShortTermParking.coordinates = Coordinate(lat: coordinates.latitude, long: coordinates.longitude)
//            let addressArray = address.components(separatedBy: ", ")
//            var stateAndZip = [String]()
//            //if there is an extra street addresss line
//            if addressArray.count == 5 {
//                stateAndZip = addressArray[3].components(separatedBy: " ")
//                ShortTermParking.address = Address(city: addressArray[2], state: stateAndZip[0], street: addressArray[0] + ", " +  addressArray[1], zip: stateAndZip[1])
//                print(ShortTermParking.address)
//            }
//            else if addressArray.count == 4 {
//                stateAndZip = addressArray[2].components(separatedBy: "  ")
//                ShortTermParking.address = Address(city: addressArray[1], state: stateAndZip[0], street: addressArray[0], zip: stateAndZip[1])
//                print(ShortTermParking.address)
//            }
//            else {
//                let alert = UIAlertController(title: "Error", message: "The address you entered is invalid. Please enter a valid address in form 'Street Address, City, State, Zip' to continue.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                return
//            }
//        } else { // LONGTERM -- do same thing as shortterm
//
//        }
//
//
//        if let vc = segue.destination as? ListingTimesViewController {
//            vc.parkingType = parkingType
//            if(parkingType == .short) {
//                vc.ShortTermParking = ShortTermParking
//            } else {
//                // pass in long term parking when ready
//            }
//        }
//    }

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
            currentSearchAnnotation = annotation
            self.getAddressFromLatLon(pdblLatitude: annotation.coordinate.latitude, withLongitude: annotation.coordinate.longitude)
            coordinates = location.coordinate
            
            mapView.addAnnotation(currentSearchAnnotation!)
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

extension ListingAddressViewController: UITableViewDataSource, UITableViewDelegate {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        dropPinZoomIn(placemark: selectedItem)
        searchBar.text = selectedItem.title
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        address = searchBar.text
        animateTransitionIfNeeded(state: nextState, duration: 0.9)
    }
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.title
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        if(self.mapView.annotations.count >= 1) {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
//        if let currentSearchAnnotation = currentSearchAnnotation {
//            mapView.removeAnnotation(currentSearchAnnotation)
//        }
        coordinates = placemark.coordinate
        currentSearchAnnotation = annotation
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
extension ListingAddressViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Change")
        if(nextState == .expanded) {
            animateTransitionIfNeeded(state: .expanded, duration: 0.9)
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(center: mapView.centerCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        let search = MKLocalSearch(request: request)
        search.start() { response, error in
            if let response = response {
                print(response.mapItems)
                self.matchingItems = response.mapItems
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        //animateTransitionIfNeeded(state: .collapsed, duration: 0.9)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        animateTransitionIfNeeded(state: .expanded, duration: 0.9)
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let overlay = self.view.viewWithTag(100) {
            overlay.removeFromSuperview()
        }
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        animateTransitionIfNeeded(state: .collapsed, duration: 0.9)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        animateTransitionIfNeeded(state: .collapsed, duration: 0.9)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
}


