//
//  TransactionsBookingViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 2/24/21.
//

import UIKit
import MapKit
import Braintree
import BraintreeDropIn

// MARK: booking view controller but for TRANSACTIONS
class TransactionsBookingViewController: UIViewController, isAbleToReceiveData {
    var transationDate: String!
    var provider: String!
    var directions: String!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UIButton!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var timeFrameTitleLabel: UILabel!
    @IBOutlet weak var paymentCardLabel: UILabel!
    @IBOutlet weak var paymentIcon: UIImageView!
    @IBOutlet weak var paymentStack: UIStackView!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var totalTitleLabel: UILabel!
   
    var bookmarkFlag = false
    var transaction = false

    var images = [UIImage]()
    
    
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
    var info = ParkingSpaceMapAnnotation(id: "0XsChhfAoV33XFCOZKUK", name: "temp", email: "", phoneNumber: "", photo: "", coordinate: CLLocationCoordinate2DMake(34.0703, -118.4441), price: 10.0, address: Address.blankAddress(), tags: ["test"], comments: "test", startTime: Date(), endTime: Date(), date: Date(), startDate: Date(), endDate: Date(), images: [String](), selfParking: false)
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
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.allowsSelection = false
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.allowsSelection = false
        imageCollectionView.tag = 0
        tagCollectionView.tag = 2
        //imageCollectionView.hide
        backBtn.layer.shadowRadius = 4.0
        backBtn.layer.shadowOpacity = 0.98
        backBtn.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        backBtn.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        bookmarkButton.isHidden = true
        nameLabel.text = info.name
        phoneNumberLabel.text = info.phoneNumber
        emailLabel.text = info.email
        addressLabel.text = info.address.toString()
        commentsLabel.text = info.comments
        commentsLabel.sizeToFit()
        
        if directions != nil {
            directionsLabel.text = directions
        }
        
        //shadow for user info view
        userInfoView.layer.shadowRadius = 5.0
        userInfoView.layer.shadowOpacity = 0.25
        userInfoView.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        userInfoView.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        //let paymentTap = UITapGestureRecognizer(target:self, action: #selector(self.paymentTapped(_:)))
        //self.paymentStack.isUserInteractionEnabled = true
        //self.paymentStack.addGestureRecognizer(paymentTap)
        
        UserService.getUserById(provider) { (user, error) in
            if let user = user {
                self.nameLabel.text = user.displayName
                self.phoneNumberLabel.text = user.phoneNumber
                self.emailLabel.text = user.email
                self.info.photo = user.photoURL
            }
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        imageCollectionView.collectionViewLayout = layout
        
        //set up price Attributed String
        let dollar = "$"
        let dollar_attrs = [NSAttributedString.Key.font :  UIFont.init(name: "Roboto-Bold", size: 13)]
        let cost = NSMutableAttributedString(string:dollar, attributes:dollar_attrs as [NSAttributedString.Key : Any])
        print(info.price)
        let price = String(format: "%.2f", info.price)
        let price_attrs = [NSAttributedString.Key.font :  UIFont.init(name: "Roboto-Medium", size: 23)]
        let price_string = NSMutableAttributedString(string:price, attributes:price_attrs as [NSAttributedString.Key : Any])
        cost.append(price_string)
        
        var perHour = "/hour"
        if price_string.length > 4 {
            perHour = "/hr"
        }
        let hour_attrs = [NSAttributedString.Key.font :  UIFont.init(name: "Roboto-Medium", size: 16)]
        let hour_string = NSMutableAttributedString(string:perHour, attributes:hour_attrs as [NSAttributedString.Key : Any])
        cost.append(hour_string)
        
        priceLabel.attributedText = cost

//        if listing {
//          //  setupPopup()
//            //var name = "", photo = "", email = "", phone = ""
//            UserService.getUserById(ShortTermParking.provider) { (user, error) in
//                if let user = user {
//                    self.nameLabel.text = user.displayName
//                    self.phoneNumberLabel.text = user.phoneNumber
//                    self.emailLabel.text = user.email
//                    self.info.photo = user.photoURL
//                }
//            }
//            paymentMethodLabel.isHidden = true
//            totalTitleLabel.isHidden = true
//            totalLabel.isHidden = true
//            startTime = info.startTime
//            endTime = info.endTime
//            startDate = info.date
//            let formatter1 = DateFormatter()
//            formatter1.dateFormat = "MMMM d"
//            let startday = formatter1.string(from: info.startDate ?? Date())
//            var endday = ""
//            if info.endDate != nil {
//                let formatter1b = DateFormatter()
//                formatter1b.dateFormat = "d yyyy"
//                endday = formatter1b.string(from: info.endDate ?? Date())
//                endday = "-" + endday
//            }
//            let formatter2 = DateFormatter()
//            formatter2.dateFormat = "h:mm a"
//            let startString = formatter2.string(from: startTime! as Date)
//            let endString = formatter2.string(from: endTime! as Date)
//            availabilityLabel.setTitle(startday + endday + ", " + startString + " to " + endString, for: .normal)
//            availabilityLabel.titleLabel?.font = UIFont.init(name: "Roboto-Medium", size: 14)
//            availabilityLabel.isEnabled = false
//
//            reserveButton.isEnabled = true
//            reserveButton.setTitle("Create Listing", for: .normal)
//            reserveButton.backgroundColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
//            reserveButton.setTitleColor(.white, for: .normal)
//            reserveButton.titleLabel?.font = UIFont.init(name: "Roboto-Medium", size: 16)
//        }
        // short term
        if(info.startTime != nil && info.endTime != nil && info.date != nil) {
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
        
        
        if info.photo != "" {
            photoImage.layer.cornerRadius = 18
            guard let url = URL(string: info.photo) else {
                print("can't convert string to URL")
                return
            }
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard let data = data, error == nil else {
                    print("failed to convert image from url")
                    return
                }
                DispatchQueue.main.async { [self] in
                    guard let UIimage = UIImage(data: data) else {
                        print("failed to make image into UIimage")
                        return
                    }
                    print("image converted")
                    self.photoImage.image = UIimage
                }
            }
            task.resume()
        }
        
    }
    
    func getAllImages() {
        for image in info.images {
            print("starting image conversion...")
            guard let url = URL(string: image) else {
                print("can't convert string to URL")
                return
            }
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
                    self.images.append(UIimage)
                    let imageView = UIImageView.init(image: UIimage)
                    //imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 60)
                    self.view.addSubview(imageView)
                    imageView.center = self.view.center
                }
            }
            task.resume()
        }
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
    
//    @IBAction func availabilityButton(_ sender: Any) {
//        performSegue(withIdentifier: "availabilityVC", sender: self)
//    }
    
    @IBAction func reserveButton(_ sender: Any) {
        
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
//extension TransactionsBookingViewController {
//    @objc func paymentTapped(_ send: UITapGestureRecognizer) {
//        print("Payment Tapped");
//        let key = "sandbox_ndnbmg78_77yb2gxcsdwv5spd"
//        showDropIn(clientTokenOrTokenizationKey: key)
//    }
//    func showDropIn(clientTokenOrTokenizationKey: String) {
//        let request =  BTDropInRequest()
//        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
//        { (controller, result, error) in
//            if (error != nil) {
//                print("ERROR")
//            } else if (result?.isCancelled == true) {
//                print("CANCELLED")
//            } else if let result = result {
//                self.paymentResult = result
//                self.paymentCardLabel.text = result.paymentDescription
//                let size = CGSize(width: 32, height: 17)
//                self.paymentIcon.image = BTUIKViewUtil.vectorArtView(for: result.paymentOptionType).image(of: size)
//            }
//            controller.dismiss(animated: true, completion: nil)
//        }
//        self.present(dropIn!, animated: true, completion: nil)
//    }
//    //function not currently being used
//    func processPayment() {
//        //payment has been selected
//        if let paymentResult = paymentResult{
//            if let paymentMethod = paymentResult.paymentMethod, let total = self.totalPrice {
//                print("Sending payment to server");
//                PaymentService.postNonceToServer(paymentMethodNonce: paymentMethod.nonce, transactionAmount: total) { error in
//                    if error == nil {
//                        print("Payment Success!")
//                    } else {
//                        print(error!.errorMessage())
//                    }
//                }
//            }
//        }else {
//            //payment has not been selected
//        }
//    }
//}
extension TransactionsBookingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let index = indexPath.row
        if collectionView.tag == 0 { //image collection
            if images.isEmpty && info.images.isEmpty {
                return CGSize(width: self.view.frame.width+4, height: 256)
            } else if (index == info.images.count && !info.images.isEmpty) || (index == images.count && !images.isEmpty){
                return CGSize(width: self.view.frame.width, height: 256)
            }
            return CGSize(width: 327, height: 256)
        } else { //tag view
            var width = 63.0 + 10.0
            if index == 0 {
                if self.info.selfParking {
                    width = (20 * 6) + 30
                } else {
                    width = (23 * 6) + 30
                }
            }
            else {
                if self.info.tags[index-1].count > 8 {
                    width = (Double(self.info.tags[index-1].count) * 5.5) + 30
                }
            }
            return CGSize(width: CGFloat(width), height: 33)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 2 {
            return info.tags.count + 1
        } else {
            if transaction {
                return info.images.count + 1
            }
            return images.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! BookingTagCollectionViewCell
            var selfParkingText = "Self-Parking Not Available"
            if self.info.selfParking {
                selfParkingText = "Self-Parking Available"
            }
            let index = indexPath.row
            var width = 63.0
            if index == 0 {
                if self.info.selfParking {
                    width = (20 * 6) + 20
                } else {
                    width = (23 * 6) + 20
                }
            }
            else if self.info.tags[index-1].count > 8 {
                width = (Double(self.info.tags[index-1].count) * 5.5) + 20.0
            }
            cell.frame.size.width = CGFloat(width)
            cell.frame.size.height = 33
            cell.contentView.frame.size.width = CGFloat(width) + 5
            cell.contentView.frame.size.height = 30
            let tag = cell.tagLabel ?? UILabel()
            tag.layer.borderWidth = 1.5
            tag.frame.size.width = CGFloat(width)
            tag.frame.size.height = 20
            tag.layer.cornerRadius = 9
//            tag.layer.borderColor = CGColor.init(red: 0.427, green: 0.427, blue: 0.427, alpha: 1.0)
            tag.layer.borderColor = CGColor.init(red: 196.0/255.0, green: 196.0/255.0, blue: 0196.0/255.0, alpha: 1.0)
            if index == 0 {
                tag.text = selfParkingText
            } else {
                tag.text = self.info.tags[index-1]
            }
            tag.textColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            tag.font = .systemFont(ofSize: 10)
            tag.textAlignment = .center
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCells", for: indexPath) as! BookingImageCollectionViewCell
            cell.frame.size.width = 327
            cell.frame.size.height = 256
            let index = indexPath.row
            var mapFlag = false
            var mapOnly = false
            if images.isEmpty && info.images.isEmpty {
                mapOnly = true
            }
            if !mapOnly && !transaction{
                if index != images.count {
                    cell.image.image = self.images[index]
                } else {
                    mapFlag = true
                }
            } else if !mapOnly && transaction{
                if index != info.images.count {
                    let image = info.images[index]
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
                            cell.image.adjustsImageSizeForAccessibilityContentSizeCategory = true
                            self.images.append(UIimage)
                        }
                    }
                    task.resume()
                } else {
                    mapFlag = true
                }
            }
            if mapFlag || mapOnly {
                if mapOnly || mapFlag {
                    print("map only")
                    cell.sizeToFit()
                    cell.frame.size.width = collectionView.fs_width
                    cell.image.setNeedsLayout()
                    cell.image.layoutIfNeeded()
                    cell.image.frame.size.width = self.view.frame.width
                }
                if mapOnly {
                    self.backBtn.tintColor = .black
                }
                let rect = cell.image.bounds
                let options = MKMapSnapshotter.Options()
                let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
                let location: CLLocationCoordinate2D = info.coordinate
                let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
                options.size = CGSize(width: cell.fs_width, height: cell.fs_height)
//                if mapOnly {
//                    options.size = CGSize(width: self.view.frame.width, height: cell.image.fs_height)
//                }
                options.region = region
                let snapshot = MKMapSnapshotter(options: options)
                snapshot.start { snapshot, error in
                    guard let snapshot = snapshot, error == nil else {
                        print(error ?? "Unknown error")
                        return
                    }
                    let image = UIGraphicsImageRenderer(size: options.size).image { _ in
                        snapshot.image.draw(at: .zero)
                        
                        let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                        //pinView.frame = CGRect(x: 0, y: 0, width: 12, height: 10)
                        let pinImage = UIImage(named: "mapAnnotationPark")
                        
                        //CGSize(width: 15, height: 10)
                        var point = snapshot.point(for: self.info.coordinate)

                        if rect.contains(point) {
                            point.x -= pinView.bounds.width / 2
                            point.y -= pinView.bounds.height / 2
                            point.x += pinView.centerOffset.x
                            point.y += pinView.centerOffset.y
                            pinImage?.draw(at: point)
                        }
                    }
                    UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
                    DispatchQueue.main.async {
                        cell.image.image = image
                    }
                }

            }
            
            return cell
        }
    }
    
    
}
//extension TransactionsBookingViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let reuseIdentifier = "pin1"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
//
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
//            annotationView?.canShowCallout = false
//
//        } else {
//            annotationView?.annotation = annotation
//        }
//
//        annotationView?.image = UIImage(named: "mapAnnotationPark")
//        return annotationView
//    }
//}
