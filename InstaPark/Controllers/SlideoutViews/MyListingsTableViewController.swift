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
    
        var myListings = [ShortTermParkingSpot]() {
            didSet {
            }
        }
    
        var listingsTab = true
        var tabs: CustomSegmentedControl!
    
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
                let parkingSpace = ParkingSpaceMapAnnotation(id: parkingSpot.id,name: "", email: "", phoneNumber: "", photo:"", coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, address: parkingSpot.address, tags: parkingSpot.tags, comments: parkingSpot.comments,startTime: nil, endTime: nil, date: nil, startDate: nil, endDate: nil, images: parkingSpot.images, selfParking: parkingSpot.selfParking)
                
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
            let viewAction = UIAlertAction(title: "View on Map", style: .default, handler: {action -> Void in
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ListingMapViewController") as! ListingMapViewController
                nextViewController.modalPresentationStyle = .fullScreen
                nextViewController.modalTransitionStyle = .coverVertical
                nextViewController.coord = CLLocationCoordinate2D(latitude: self.myListings[sender.tag].coordinates.lat, longitude: self.myListings[sender.tag].coordinates.long)
                nextViewController.price = self.myListings[sender.tag].pricePerHour
                self.present(nextViewController, animated: true)
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
