//
//  MyListingsTableViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 4/2/21.
//

import UIKit
import FirebaseAuth
import MapKit

class MyListingsTableViewController: UITableViewController,CustomSegmentedControlDelegate {

        @IBOutlet var listingTable: UITableView!
    
    @IBOutlet var deactivatePopup: UIView!
    var blackScreen: UIView!
    
    var myListings = [ShortTermParkingSpot]() {
            didSet {
            }
        }
    
        var listingsTab = true
        var tabs: CustomSegmentedControl!
    
    var currentSelectedID: String!
    var currentIndex: Int!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            listingTable.allowsSelection = false;
            print("Loading my listings table view controller")
            tabs = CustomSegmentedControl(frame: CGRect(x: 0, y: 58, width: self.view.frame.width, height: 35), buttonTitle: ["LISTINGS","BOOKING REQUESTS"])
            tabs.backgroundColor = .clear
            tabs.delegate = self
            self.view.addSubview(tabs)
            
            self.tableView.rowHeight = 100
            self.refreshControl = UIRefreshControl()
            
            refreshControl!.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
            tableView.addSubview(refreshControl!)
            
            getData()
            
            let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left]
               for direction in directions {
                    let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(sender:)))
                    gesture.direction = direction
                    self.view.addGestureRecognizer(gesture)
               }
            
            blackScreen = UIView()
            blackScreen.backgroundColor = .black
            // Uncomment the following line to preserve selection between presentations
            // self.clearsSelectionOnViewWillAppear = false

            // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
            // self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
        @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
            switch sender.direction {
            case UISwipeGestureRecognizer.Direction.right:
                if !listingsTab {
                    tabs.setIndex(index: 0)
                    change(to: 0)
                }
                print("right")
            case UISwipeGestureRecognizer.Direction.left:
                if listingsTab {
                    tabs.setIndex(index: 1)
                    change(to: 1)
                }
                print("left")
            default:
                break
            }
        }
        
        func getData() {
            let segControl = CustomSegmentedControl()
            segControl.delegate = self
            DispatchQueue.global(qos: .userInteractive).async {
                UserService.getUserById(Auth.auth().currentUser!.uid) { user, error in
                    if let user = user {
                        ParkingSpotService.getParkingSpotByIds(user.parkingSpots) { (parkingSpots, error) in
                            if let parkingSpots = parkingSpots, error == nil {
                                for spot in parkingSpots {
                                    if let parkingSpot = spot as? ShortTermParkingSpot {
                                        self.myListings.append(parkingSpot)
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    if self.refreshControl != nil {
                                        self.refreshControl!.endRefreshing()
                                    }
                                    return
                                }
                            }
                        }
                    }
                    
                }
//                    ParkingSpotService.getAllParkingSpots(completion: {(a:[ParkingSpot]?,b:Error?) in
//                    if (b == nil && a != nil) {
//                        let spots = a!;
//                        for spot in spots {
//                            if let parkingSpot = spot as? ShortTermParkingSpot {
//                                self.myListings.append(parkingSpot)
//                            }
//                        }
//                        print("Reloading listings")
//
//                        //MARK: Add booking request retrieval code here
//
//                        DispatchQueue.main.async {
//                            self.tableView.reloadData()
//                            if self.refreshControl != nil {
//                                self.refreshControl!.endRefreshing()
//                            }
//                            return
//                        }
//                    }
//                })
            }
        }
        

        func change(to index: Int) {
            if index == 1 {
                listingsTab = false
            } else {
                listingsTab = true
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        @objc func refresh(_ sender: AnyObject) {
            myListings.removeAll()
            //MARK: Clear all booking request data here
            getData()
        }
    
        @objc func options(sender: UIButton) {
           let optionMenu = UIAlertController(title: nil, message: "Select Action", preferredStyle: .actionSheet)
            let editAction = UIAlertAction(title: "View Listing", style: .default, handler: {action -> Void in
                let parkingSpot = self.myListings[sender.tag]
                let parkingSpace = ParkingSpaceMapAnnotation(id: parkingSpot.id,name: "", email: "", phoneNumber: "", photo:"", coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, pricePerDay: parkingSpot.pricePerDay, dailyPriceEnabled: parkingSpot.dailyPriceEnabled, address: parkingSpot.address, tags: parkingSpot.tags, comments: parkingSpot.comments,startTime: nil, endTime: nil, date: nil, startDate: nil, endDate: nil, images: parkingSpot.images, selfParking: parkingSpot.selfParking)
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "transactionsBookingView") as! TransactionsBookingViewController
                nextViewController.modalPresentationStyle = .fullScreen
                nextViewController.modalTransitionStyle = .coverVertical
                nextViewController.info = parkingSpace
                nextViewController.total = parkingSpot.pricePerHour
                nextViewController.provider = parkingSpot.provider
                nextViewController.directions = parkingSpot.selfParking.specificDirections
                
                self.present(nextViewController, animated:true)
            })
            let parkingSpot = self.myListings[sender.tag]
            var action2Title = "Temporarily Deactivate Listing"
            if parkingSpot.deactivated {
                print("reactivating")
                action2Title = "Reactivate Listing"
            }
            let viewAction = UIAlertAction(title: action2Title, style: .default, handler: {action -> Void in
                if parkingSpot.deactivated {
                    ParkingSpotService.deactivateParkingSpot(id: parkingSpot.id, deactivate: false)
                    self.myListings[sender.tag].deactivated = false
                    let alert = UIAlertController(title: "Success", message: "Your listing has been reactivated.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.currentSelectedID = parkingSpot.id
                    self.blackScreen.alpha = 0.0
                    self.blackScreen.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIScreen.main.bounds.height)
                    self.view.addSubview(self.blackScreen)
                    
                    self.deactivatePopup.frame = CGRect(x: 0 , y: 0 , width: 325, height: 300)
                    self.deactivatePopup.center.x = self.view.center.x
                    self.deactivatePopup.center.y = self.view.frame.height * 3 / 4
                    self.view.addSubview(self.deactivatePopup)
                    self.deactivatePopup.isHidden = false
                    self.currentIndex = sender.tag
                    
                    
                    UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut],
                                   animations: {
                                    self.deactivatePopup.center.y = self.view.center.y * 0.8
                                   }, completion: {_ in })
                }
            })
            let deleteAction = UIAlertAction(title: "Delete Listing", style: .destructive, handler: {action -> Void in
                let alert = UIAlertController(title: "Delete Your Lisiting?", message: "This action cannot be undone.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    let parkingSpot = self.myListings[sender.tag]
                    ParkingSpotService.deleteParkingSpotById(parkingSpot.id)
                    self.myListings.remove(at: sender.tag)
                    self.tableView.reloadData()
                }))
                self.present(alert, animated: true, completion: nil)
            })
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
           optionMenu.addAction(editAction)
           optionMenu.addAction(viewAction)
           optionMenu.addAction(deleteAction)
           optionMenu.addAction(cancelAction)
           self.present(optionMenu, animated: true, completion: nil)
        }
    
    @IBAction func deactivate(_ sender: Any) {
        ParkingSpotService.deactivateParkingSpot(id: currentSelectedID, deactivate: true)
        myListings[currentIndex].deactivated = true
        dismissPopup()
    }
    
    @IBAction func canelDeactivation(_ sender: Any) {
        dismissPopup()
    }
    
    func dismissPopup() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseIn],
                       animations: {
                        self.deactivatePopup.center.y = self.view.frame.height * 3 / 4
                       }, completion: {_ in
                        self.deactivatePopup.removeFromSuperview()
                        self.deactivatePopup.isHidden = true
                        self.blackScreen.removeFromSuperview()
                       })
    }
    

        @IBAction func backBtn(_ sender: Any) {
            dismiss(animated: true)
        }
        
        // MARK: - Table view data source

        override func numberOfSections(in tableView: UITableView) -> Int {
            
            return 1
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if listingsTab {
                print("listing \(myListings.count)")
                return myListings.count
            }
            print("requests")
            //MARK: Return amount of booking requests here
            return 0
        }
    
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            print("Preparing cell")
            if listingsTab && myListings.count > 0{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyListingTableViewCell", for: indexPath) as? MyListingsTableViewCell else {fatalError("Dequeued cell not an instance of MyListingTableViewCell")}
                let listing = myListings[indexPath.row]
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "MMMM d"
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "h:mm a"
                if listing.startDate == listing.endDate {
                    cell.dateLabel.text = dateFormatter1.string(from:Date.init(timeIntervalSince1970: TimeInterval(listing.startDate)))
                } else {
                    cell.dateLabel.text = dateFormatter1.string(from:Date.init(timeIntervalSince1970: TimeInterval(listing.startDate))) + " - " + dateFormatter1.string(from:Date.init(timeIntervalSince1970: TimeInterval(listing.endDate)))
                }
                var time:ParkingTimeInterval!
                for i in 0..<7 {
                    if listing.times[i] != nil && !listing.times[i]!.isEmpty {
                        time = listing.times[i]![0]
                        break
                    }
                }
                cell.timeLabel.text =  dateFormatter2.string(from:Date.init(timeIntervalSince1970: TimeInterval(time.start)))
                    + " - " +  dateFormatter2.string(from:Date.init(timeIntervalSince1970: TimeInterval(time.end)))
                cell.addressLabel.text = listing.address.street + " " + listing.address.city + " " + listing.address.state + " " + listing.address.zip
                cell.priceLabel.text = "$"+String(format: "%.2f", listing.pricePerHour) + "/hr"
                cell.optionsButton.addTarget(self, action: #selector(options), for: .touchUpInside)
                cell.optionsButton.tag = indexPath.row
                return cell
            } else {
                
                //MARK: Add requests cell setup logic here
                return UITableViewCell()
            }
        }
        
}
