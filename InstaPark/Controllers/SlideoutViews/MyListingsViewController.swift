//
//  MyListingsViewController.swift
//  InstaPark
//
//  Created by Daniel Hu on 4/5/21.
//

import UIKit
import FirebaseAuth
import MapKit

//DOES NOT SAVE BC THIS DOESNT ACCESS DATABASE
//ALSO CAN STILL SWIPE ON APPROVED REQUESTS WHEN U SHOULD NOT BE ABLE TO
//ADD CUSTOMER IMG AND ORGANIZE CELL CONTENT
//CONFIRMING/DENYING TAKES LONG TIME
//CONFIRMING/DENYING A REQUEST ALSO REPLICATES ACTION ON FOLLOWING REQUESTS
//CANT IMPLEMENT CELL REMOVAL WITHOUT CRASHING
//SECTION HEADER TEXT CAN'T BE CUSTOMIZED


//MARK: - designers want us to hold off on confirming/denying reservations

/*Object used to differentiate between pending and approved requests*/
struct Requests {
    var item: Transaction
    var status: NSMutableAttributedString
}

/*Adapted object for Dictionary groupping/mapping functions*/
struct r {
    var arr: [Requests]
    var s: NSMutableAttributedString
}

class MyListingsViewController: UITableViewController, CustomSegmentedControlDelegate {
    
    var requestsTab = true

    @IBOutlet weak var transactionsList: UITableView!
    
    var requests = [Transaction](){
        didSet{
        }
    }
    
    var reservations = [Transaction](){
        didSet{
        }
    }
    
    var pending = [Requests]() {
        didSet{
        }
    }
    
    var approved = [Requests]() {
        didSet{
        }
    }
    
    var tabs: CustomSegmentedControl!
    var requestsNames = [String]()
    var requestProfilePics = [UIImage]()
    var hasProfilePics = [Bool]()
    var sections = [r]()
    var dummy: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Loading transaction table view controller")
        tabs = CustomSegmentedControl(frame: CGRect(x: 0, y: 58, width: self.view.frame.width, height: 35), buttonTitle: ["LISTINGS","RESERVATION REQUESTS"])
        tabs.backgroundColor = .clear
        tabs.delegate = self
        self.view.addSubview(tabs)
        
        self.tableView.rowHeight = 100
        self.refreshControl = UIRefreshControl()
        
        refreshControl!.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        
        getTransactions()
        
//        //DUMMY 1
//        let addy = Address(city: "Los Angeles", state: "CA", street: "330 De Neve Dr", zip: "90024")
//
//        let sp = SelfParking(hasSelfParking: false, selfParkingMethod: "", specificDirections: "")
//
//        let co = Coordinate(lat: 0.0, long: 0.0)
//
//        let park = ParkingSpot(id: "", address: addy, coordinates: co, pricePerHour: 0.0, provider: "", comments: "", tags: dummy, reservations: dummy, images: dummy, startDate: 0, endDate: 0, directions: "", selfParking: sp, approvedReservations: [])
//
//        let tr = Transaction(id: "1", customer: "Joe Bruin", startTime: 0, endTime: 0, address: addy, fromParkingSpot: park)
//        requests.append(tr)
//        requestsNames.append(tr.customer)
//
//        let s = NSMutableAttributedString(string: "PENDING APPROVAL", attributes: [NSAttributedString.Key.font: UIFont(name: "OpenSans-Regular", size: 10)!])
//        s.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 97/256, green: 0/256, blue: 255/256, alpha: 1.0)], range: NSRange(location: 0, length: s.length))
//        let req = Requests(item: tr, status: s)
//        self.pending.append(req)
//
//        //DUMMY 2
//        let addy1 = Address(city: "Los Angeles", state: "CA", street: "330 De Neve Dr", zip: "90024")
//
//        let sp1 = SelfParking(hasSelfParking: false, selfParkingMethod: "", specificDirections: "")
//
//        let co1 = Coordinate(lat: 0.0, long: 0.0)
//
//        let park1 = ParkingSpot(id: "", address: addy1, coordinates: co1, pricePerHour: 0.0, provider: "", comments: "", tags: dummy, reservations: dummy, images: dummy, startDate: 0, endDate: 0, directions: "", selfParking: sp1, approvedReservations: [])
//
//        let tr1 = Transaction(id: "1", customer: "Bob Bruin", startTime: 0, endTime: 0, address: addy, fromParkingSpot: park1)
//        requests.append(tr1)
//        requestsNames.append(tr1.customer)
//
//        let s1 = NSMutableAttributedString(string: "PENDING APPROVAL", attributes: [NSAttributedString.Key.font: UIFont(name: "OpenSans-Regular", size: 10)!])
//        s1.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 97/256, green: 0/256, blue: 255/256, alpha: 1.0)], range: NSRange(location: 0, length: s1.length))
//        let req1 = Requests(item: tr1, status: s1)
//        self.pending.append(req1)
//
//        splitRequests()
        
        /*let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left]
           for direction in directions {
                let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(sender:)))
                gesture.direction = direction
                self.view.addGestureRecognizer(gesture)
           }*/
    }
    
    func splitRequests(){ //split requests based on which 2 statuses they are: PENDING APPROVAL or APPROVED
        let groups = Dictionary(grouping: self.pending) { (request) -> NSMutableAttributedString in
            return request.status
        }
        self.sections = groups.map { (key, values) in
            return r(arr: values, s: key)
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        requests.removeAll()
        requestsNames.removeAll()
        getTransactions()
        
        self.refreshControl!.endRefreshing()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /*@objc func handleSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.right:
            if !requestsTab {
                tabs.setIndex(index: 0)
                change(to: 0)
            }
            print("right")
        case UISwipeGestureRecognizer.Direction.left:
            if requestsTab {
                tabs.setIndex(index: 1)
                change(to: 1)
            }
            print("left")
        default:
            break
        }
    }*/
    
    func load(transaction: Transaction){
        self.requests.append(transaction)
        self.requestsNames.append(transaction.customer)
        let s = NSMutableAttributedString(string: "PENDING APPROVAL")
        addToArray(transaction: transaction, status: s)
    }
    
    func addToArray(transaction: Transaction, status: NSMutableAttributedString){
        self.pending.append(Requests(item: transaction, status: status))
    }
    
    func getTransactions() {
        let segControl = CustomSegmentedControl()
        segControl.delegate = self
        UserService.getUserById(Auth.auth().currentUser!.uid) { user, error in
            DispatchQueue.global(qos: .userInteractive).async {
                if let user = user {
                    print(user.uid)
                    ParkingSpotService.getAllReservationsForParkingSpot(ids: user.parkingSpots) { (transactions, error) in
                        if let transactions = transactions, error == nil {
                            self.reservations = transactions
                            print(self.reservations.count)
                            DispatchQueue.main.async {
                                for _ in self.reservations {
                                    self.requestsNames.append("")
                                    self.requestProfilePics.append(UIImage())
                                    self.hasProfilePics.append(false)
                                }
                                self.tableView.reloadData()
                            }
                        } else {
                            print("error")
                        }
                    }
                }
            }
        }
    }
    
    func change(to index: Int) {
        if index == 1 {
            requestsTab = false
        } else {
            requestsTab = true
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1//self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if requestsTab {
        print("requests")
//        print(requests.count)
        //let section = self.sections[section]
        //return section.arr.count
        return reservations.count
        //}
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let section = self.sections[section]
//        let header = section.s.string
//        return header
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Preparing cell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyListingsViewCell", for: indexPath) as? MyListingsViewCell else {
            fatalError("Dequeued cell not an instance of MyListingsViewCell")
        }
        var transaction: Transaction
        var customerName = ""
        //if requestsTab {
        transaction = reservations[indexPath.row]
        customerName = requestsNames[indexPath.row]
        var customerImage = requestProfilePics[indexPath.row]
        
        //} else {

        //}
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MMMM d"
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "h:mm a"
        var secondDate = ""
        if transaction.startTime - transaction.endTime > 86400 { //transaction for more than a day
            secondDate = " — " + dateFormatter1.string(from: Date.init(timeIntervalSince1970: TimeInterval(transaction.endTime))) + "\n"
        }
        let date = attributedInfoBold(string: "Date: ", fontSize: 12)
        date.append(attributedInfoRegular(string: dateFormatter1.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.startTime))) + secondDate, fontSize: 12))
        cell.Date.attributedText = date
        
        let time = attributedInfoBold(string: "Time: ", fontSize: 12)
        time.append(attributedInfoRegular(string: dateFormatter2.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.startTime))) + " - " + dateFormatter2.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.endTime))), fontSize: 12))
        cell.Time.attributedText = time
        
        let addr = attributedInfoBold(string: "Address: ", fontSize: 12)
        addr.append(attributedInfoRegular(string: transaction.address.street + " " + transaction.address.city + " " + transaction.address.state + " " + transaction.address.zip, fontSize: 12))
        cell.address.attributedText = addr
        
        cell.price.text = "$" + String(format: "%.2f", transaction.total)
        
        cell.profilePicture.isUserInteractionEnabled = true
        let tapRecognizer = MyTapGesture(target: self, action: #selector(profileTapped))
        tapRecognizer.uid = transaction.customer
        cell.profilePicture.addGestureRecognizer(tapRecognizer)
        
        
//        cell.Date.text = "Date: " + dateFormatter1.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.startTime))) + secondDate
//        cell.Time.text = "Time: " + dateFormatter2.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.startTime))) + " - " + dateFormatter2.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.endTime)))
//        cell.address.text = "Address: " + transaction.address.street + " " + transaction.address.city + " " + transaction.address.state + " " + transaction.address.zip
        if customerName.isEmpty {
            DispatchQueue.global(qos: .userInteractive).async {
                UserService.getUserById(transaction.customer ) { (user, error) in
                    if let user = user {
                        cell.customerRequest.attributedText = self.attributedInfoBold(string: user.displayName, fontSize: 14)
                        if user.photoURL != "" {
                            guard let url = URL(string: user.photoURL) else {
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
                                    cell.profilePicture.setImage(UIimage, for: .normal)
                                    self.requestProfilePics[indexPath.row] = UIimage
                                    self.hasProfilePics[indexPath.row] = true
                                }
                            }
                            task.resume()
                        }
                        DispatchQueue.main.async {
                            //if self.requestsTab {
                            if indexPath.row < self.requestsNames.count {
                                self.requestsNames[indexPath.row] = user.displayName
                            }
                                
                            //} else {
                            //}
                        }
                    }
                }
            }
        } else {
            print("customer name already loaded once")
            cell.customerRequest.attributedText = attributedInfoBold(string: customerName, fontSize: 14)
            if hasProfilePics[indexPath.row] {
                cell.profilePicture.setImage(requestProfilePics[indexPath.row], for: .normal)
            }
        }
        
        //print(cell.priceLabel.text ?? "")
        return cell
    }
    
    @objc func profileTapped(sender : MyTapGesture){
        let uid = sender.uid
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "userProfileVC") as! UserProfileViewController
        nextViewController.modalPresentationStyle = .fullScreen
        nextViewController.modalTransitionStyle = .coverVertical
        nextViewController.uid = uid
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    func attributedInfoBold(string: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs = [NSAttributedString.Key.font :  UIFont.init(name: "OpenSans-SemiBold", size: fontSize)]
        let attr = NSMutableAttributedString(string: string, attributes:attrs as [NSAttributedString.Key : Any])
        return attr
    }
    
    func attributedInfoRegular(string: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs = [NSAttributedString.Key.font :  UIFont.init(name: "OpenSans-Regular", size: fontSize)]
        let attr = NSMutableAttributedString(string: string, attributes:attrs as [NSAttributedString.Key : Any])
        return attr
    }
    
//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        return decline(cellForRowAt: indexPath)
//    }
//
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        return confirm(cellForRowAt: indexPath)
//
//    }
//
//    private func decline(cellForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let c = UIContextualAction(style: .destructive, title: "Decline Request") { (action, swipeButtonView, completion) in
//            //self.tableView.deleteRows(at: [indexPath], with: .fade)
//            self.pending.remove(at: indexPath.item)
//            self.splitRequests()
//            print("DELETE HERE")
//            completion(true)
//        }
//        c.backgroundColor = UIColor(red: 128/256, green: 116/256, blue: 147/256, alpha: 1.0)
//
//        let action = UISwipeActionsConfiguration(actions: [c])
//
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//
//        return action
//    }
//
//    private func confirm(cellForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let c = UIContextualAction(style: .normal, title: "Approve Request") { (action, swipeButtonView, completion) in
//            self.pending[indexPath.item].status = NSMutableAttributedString(string: "REQUESTS", attributes: [NSAttributedString.Key.font: UIFont(name: "OpenSans-Regular", size: 10)!]) //change status so second section can be created
//            self.pending[indexPath.item].status.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 97/256, green: 0/256, blue: 255/256, alpha: 1.0)], range: NSRange(location: 0, length: self.pending[indexPath.row].status.length))
//            self.approved.append(self.pending[indexPath.item])
//            print(indexPath.item)
//            self.splitRequests() //should re-split based on changed statuses
//            //let req = self.pending[indexPath.row]
//            //self.pending.remove(at: indexPath.row)
//            //self.tableView.deleteRows(at: [indexPath], with: .fade)
//            //self.pending.insert(req, at: indexPath.row)
//            print("COMPLETE HERE")
//            print(self.pending[indexPath.item].status)
//            completion(true)
//        }
//        c.backgroundColor = UIColor(red: 143/256, green: 0/256, blue: 255/256, alpha: 1.0)
//
//        let action = UISwipeActionsConfiguration(actions: [c])
//
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//
//        return action
//    }
    
    
    /*override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var transaction: Transaction
        //if requestsTab {
            transaction = requests[indexPath.row]
        //} else {

        //}
        ParkingSpotService.getParkingSpotById(transaction.parkingSpot) { [self] parkingSpot, error in
            if let parkingSpot = parkingSpot{
                //IF PARKING SPOT IS AVAILABLE
                let parkingSpace = ParkingSpaceMapAnnotation(id: parkingSpot.id,name: "", email: "", phoneNumber: "", photo:"", coordinate: CLLocationCoordinate2DMake(parkingSpot.coordinates.lat, parkingSpot.coordinates.long), price: parkingSpot.pricePerHour, address: parkingSpot.address, tags: parkingSpot.tags, comments: parkingSpot.comments,startTime: nil, endTime: nil, date: nil, startDate: nil, endDate: nil, images: parkingSpot.images, selfParking: parkingSpot.selfParking.hasSelfParking)
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "transactionsBookingView") as! TransactionsBookingViewController
                nextViewController.modalPresentationStyle = .fullScreen
                nextViewController.modalTransitionStyle = .coverVertical
                nextViewController.info = parkingSpace
                nextViewController.total = transaction.total
                nextViewController.provider = parkingSpot.provider
                nextViewController.directions = parkingSpot.selfParking.specificDirections
                
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
                
                self.present(nextViewController, animated:true)
            }
        }
        
    }*/

}

class MyTapGesture: UITapGestureRecognizer {
    var uid = String()
}
