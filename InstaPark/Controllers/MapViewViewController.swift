//
//  MapViewViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/28/20.
//

import UIKit
import MapKit

class MapViewViewController: UIViewController {
    
    let locationManager = CLLocationManager()
   
    @IBOutlet weak var SlideUpView: SlideView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        //set up of map
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(34.0703, -118.4441)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        
        self.mapView.setRegion(region, animated: false)
        
        ParkingSpotService.getAllParkingSpots() { parkingSpots, error in
            print("Rendering parking spots on map")
            if let parkingSpots = parkingSpots {
                var annotations = [ParkingSpaceMapAnnotation]()
                for parking in parkingSpots {
                    
                    annotations.append(ParkingSpaceMapAnnotation(name: "Test Name", coordinate: CLLocationCoordinate2DMake(parking.coordinates.lat, parking.coordinates.long), price: parking.pricePerHour, startTime: NSDate.init(), endTime: NSDate.init()))
                }
                print("Adding annotations")
                self.mapView.addAnnotations(annotations)
            }
        }
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
        let parkingSpace = annotation as! ParkingSpaceMapAnnotation
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

         if annotationView == nil {
             annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
             annotationView?.canShowCallout = false
            
         } else {
             annotationView?.annotation = annotation
         }
        annotationView?.image = UIImage(named: "mapAnnotation")
        let label = UILabel(frame: CGRect(x: 7, y: -4, width: 40, height: 30))
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
    }
   
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let parkingSpace = view.annotation as! ParkingSpaceMapAnnotation
        
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
        
        let now = "NOW"
        let now_attrs =  [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)]
        let nowLabel = NSMutableAttributedString(string:now, attributes:now_attrs)
        timeAvail.append(nowLabel)
        availableLabel.attributedText = timeAvail
    }

    
}


//for the "Book" button in the callouts, pass data and segue in here 
extension MapViewViewController: ParkingCalloutViewDelegate {
    func mapView(_ mapView: MKMapView, didTapDetailsButton button: UIButton, for annotation: MKAnnotation) {
        let parkingSpace = annotation as! ParkingSpaceMapAnnotation
        let name = parkingSpace.name ?? "Unknown"
        let coordinates = String(parkingSpace.coordinate.latitude) + ", " + String(parkingSpace.coordinate.longitude)
        let price = parkingSpace.price
        print(name)
        print(coordinates)
        print(price)
        print(time)
    }
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
