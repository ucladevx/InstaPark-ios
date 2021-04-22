//
//  TransactionTableViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 12/2/20.
//

import UIKit
import FirebaseAuth
import MapKit

//MARK: now called 'My Reservations' View Controller
class TransactionTableViewController: UITableViewController, CustomSegmentedControlDelegate {
    @IBOutlet var transactionTable: UITableView!
//    var transactions = [Transaction]() {
//        didSet {
//        }
//    }
    var upcomingTransactions = [Transaction]() {
        didSet {
        }
    }
    var upcomingProviderNames = [String]() // to refrain from having to recall DB for provider name after one call
    var pastTransactions = [Transaction]() {
        didSet {
        }
    }
    var pastProviderNames = [String]()
    var upcomingTab = true
    var tabs: CustomSegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loading transaction table view controller")
        tabs = CustomSegmentedControl(frame: CGRect(x: 0, y: 58, width: self.view.frame.width, height: 35), buttonTitle: ["UPCOMING","PAST"])
        tabs.backgroundColor = .clear
        tabs.delegate = self
        self.view.addSubview(tabs)
        
        self.tableView.rowHeight = 100
        self.refreshControl = UIRefreshControl()
        
        refreshControl!.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        tableView.allowsSelection = true
        getTransactions()
        
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
            if !upcomingTab {
                tabs.setIndex(index: 0)
                change(to: 0)
            }
            print("right")
        case UISwipeGestureRecognizer.Direction.left:
            if upcomingTab {
                tabs.setIndex(index: 1)
                change(to: 1)
            }
            print("left")
        default:
            break
        }
    }
    
    func splitBetweenUpcomingAndPast(transaction: Transaction) {
        let endTime = Date(timeIntervalSince1970: TimeInterval(transaction.endTime))
        let currentTime = Date()
        if endTime > currentTime {
            self.upcomingTransactions.append(transaction)
            self.upcomingProviderNames.append("")
        } else {
            self.pastTransactions.append(transaction)
            self.pastProviderNames.append("")
        }
    }
    
    func getTransactions() {
        let segControl = CustomSegmentedControl()
        segControl.delegate = self
        UserService.getUserById(Auth.auth().currentUser!.uid) { user, error in
            DispatchQueue.global(qos: .userInteractive).async {
                if let user = user {
                    print(user.uid)
                    for id in user.transactions {
                        TransactionService.getTransactionById(id) { transaction, error in
                            if let transaction = transaction {
                                //                            self.transactions.append(transaction)
                                self.splitBetweenUpcomingAndPast(transaction: transaction)
                                print("Reloading data")
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    

    func change(to index: Int) {
        if index == 1 {
            upcomingTab = false
        } else {
            upcomingTab = true
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        upcomingTransactions.removeAll()
        upcomingProviderNames.removeAll()
        pastTransactions.removeAll()
        pastProviderNames.removeAll()
        getTransactions()
//        UserService.getUserById(Auth.auth().currentUser!.uid) { user, error in
//            if let user = user {
//                print(user.uid)
//                for id in user.transactions {
//                    TransactionService.getTransactionById(id) { transaction, error in
//                        if let transaction = transaction {
//                            //self.transactions.append(transaction)
//                            print("Reloading data")
//                            DispatchQueue.main.async {
//                                self.tableView.reloadData()
//                            }
//                        }
//
//                    }
//                }
//            }
//        }
        
        self.refreshControl!.endRefreshing()
    }
    

    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if upcomingTab {
            print("upcoming")
            return upcomingTransactions.count
        }
        print("past")
        return pastTransactions.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Preparing cell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as? TransactionTableViewCell else {
            fatalError("Dequeued cell not an instance of TransactionTableViewCell")
        }
        var transaction: Transaction
        var providerName = ""
        if upcomingTab {
            transaction = upcomingTransactions[indexPath.row]
            providerName = upcomingProviderNames[indexPath.row]
        } else {
            transaction = pastTransactions[indexPath.row]
            providerName = pastProviderNames[indexPath.row]
        }
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MMMM d"
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "h:mm a"
        var secondDate = ""
        if transaction.startTime - transaction.endTime > 86400 { //transaction for more than a day
            secondDate = " — " + dateFormatter1.string(from: Date.init(timeIntervalSince1970: TimeInterval(transaction.endTime))) + "\n"
        }
        cell.dateTimeLabel.text = dateFormatter1.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.startTime))) + secondDate
            + ", " +  dateFormatter2.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.startTime)))
            + " to " +  dateFormatter2.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.endTime)))
        cell.addressLabel.text = transaction.address.street + " " + transaction.address.city + " " + transaction.address.state + " " + transaction.address.zip
//        cell.addressLabel.text = "Addressss"
        if providerName.isEmpty {
            DispatchQueue.global(qos: .userInteractive).async {
                UserService.getUserById(transaction.provider) { (user, error) in
                    if let user = user {
                        cell.providerName.text = user.displayName
                        DispatchQueue.main.async {
                            if self.upcomingTab {
                                self.upcomingProviderNames[indexPath.row] = user.displayName
                            } else {
                                self.pastProviderNames[indexPath.row] = user.displayName
                            }
                        }
                    }
                }
            }
        } else {
            print("provider name already loaded once")
            cell.providerName.text = providerName
        }
        
        cell.priceLabel.text = "$"+String(format: "%.2f", transaction.total)
        //print(cell.priceLabel.text ?? "")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var transaction: Transaction
        if upcomingTab {
            transaction = upcomingTransactions[indexPath.row]
        } else {
            transaction = pastTransactions[indexPath.row]
        }
        print("did select")
        ParkingSpotService.getParkingSpotById(transaction.parkingSpot) { [weak self] parkingSpot, error in
            if let parkingSpot = parkingSpot{
                //IF PARKING SPOT IS AVAILABLE
                print("did select")
                let parkingSpace = ParkingSpaceMapAnnotation(id: parkingSpot.id,name: "", email: "", phoneNumber: "", photo:"", coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, pricePerDay: parkingSpot.pricePerDay, dailyPriceEnabled: parkingSpot.dailyPriceEnabled, address: parkingSpot.address, tags: parkingSpot.tags, comments: parkingSpot.comments,startTime: nil, endTime: nil, date: nil, startDate: nil, endDate: nil, images: parkingSpot.images, selfParking: parkingSpot.selfParking)
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "transactionsBookingView") as! TransactionsBookingViewController
                nextViewController.modalPresentationStyle = .fullScreen
                nextViewController.modalTransitionStyle = .coverVertical
                nextViewController.info = parkingSpace
                nextViewController.total = transaction.total
                nextViewController.provider = parkingSpot.provider
                nextViewController.directions = parkingSpot.selfParking.specificDirections
                if self?.upcomingTab == true {
                    nextViewController.upcomingSpot = true
                }
                
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "MMMM d"
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "h:mm a"
                var secondDate = ""
                if transaction.startTime - transaction.endTime > 86400 { //transaction for more than a day
                    secondDate = " — " + dateFormatter1.string(from: Date.init(timeIntervalSince1970: TimeInterval(transaction.endTime)))
                }
                nextViewController.transationDate = dateFormatter1.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.startTime))) + secondDate
                    + ", " +  dateFormatter2.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.startTime)))
                    + " to " +  dateFormatter2.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.endTime)))
                nextViewController.transaction = true
                
                self?.present(nextViewController, animated:true)
            } else {
                print("error")
            }
        }
        
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
