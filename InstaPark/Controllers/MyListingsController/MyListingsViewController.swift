//
//  MyListingsViewController.swift
//  InstaPark
//
//  Created by Daniel Hu on 4/5/21.
//

import UIKit
import FirebaseAuth
import MapKit

class MyListingsViewController: UIViewController, CustomSegmentedControlDelegate {
    
    var nextTab = true
    func change(to index: Int) {
        if index == 1 {
            nextTab = false
        } else {
            nextTab = true
        }
        DispathQueue.main.async {
            self.tableView.reloadData()
        }
    }
    

    @IBOutlet var transactionsList: UITableView!
    
    var upcomingTransactions = [Transaction](){
        didSet{
        }
    }
    
    var tabs: CustomSegmentedContro!
    var upcomingConsumerNames = [String]()
    
    
    
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
        
        getTransactions()
        
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left]
           for direction in directions {
                let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(sender:)))
                gesture.direction = direction
                self.view.addGestureRecognizer(gesture)
           }
        
    }
    
    

}
