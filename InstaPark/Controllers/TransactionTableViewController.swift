//
//  TransactionTableViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 12/2/20.
//

import UIKit
import FirebaseAuth
class TransactionTableViewController: UITableViewController {
    @IBOutlet var transactionTable: UITableView!
    var transactions = [Transaction]() {
        didSet {
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loading transaction table view controller")
        self.tableView.rowHeight = 100
        UserService.getUserById(Auth.auth().currentUser!.uid) { user, error in
            if let user = user {
                TransactionService.getTransactionById(user.transactions[0]) { transaction, error in
                    if let transaction = transaction {
                        self.transactions.append(transaction)
                        print("Reloading data")
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                }
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return transactions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Preparing cell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as? TransactionTableViewCell else {
            fatalError("Dequeued cell not an instance of TransactionTableViewCell")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let transaction = transactions[indexPath.row]
        cell.dateTimeLabel.text = dateFormatter.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.startTime))) + " - " + dateFormatter.string(from:Date.init(timeIntervalSince1970: TimeInterval(transaction.endTime)))
        cell.providerName.text = "Provider"
        cell.addressLabel.text = "Address"
        cell.priceLabel.text = "$"+String(transaction.priceRatePerHour)
        print(cell.priceLabel.text)
        return cell
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
