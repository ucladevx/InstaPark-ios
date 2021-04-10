//
//  ReservationConfirmationViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 11/20/20.
//

import UIKit

class ReservationConfirmationViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var parkLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    var listing = false // only true if new listing is created
    
    @IBOutlet weak var segueToMyReservations: UIButton!
    @IBAction func segueToMyReservations(_ sender: Any) {
        weak var pvc = self.presentingViewController
        weak var pvcpvc = pvc?.presentingViewController
        if listing {
            self.dismiss(animated: false) {
                pvc?.dismiss(animated: false) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "MyListingsVC") as MyListingsTableViewController
                    (pvcpvc as? UINavigationController)?.pushViewController(vc, animated: true)
                }
            };
        } else {
            self.view.window?.rootViewController?.dismiss(animated: true) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "MyReservationsVC") as TransactionTableViewController
                self.present(vc, animated: true)
            }
            
        }
    }
    @IBAction func returnToHome(_ sender: Any) {
        weak var pvc = self.presentingViewController
        weak var pvcpvc = pvc?.presentingViewController
        print(String(describing: pvc.self))
        print(String(describing: pvcpvc.self))
        if listing {
            self.dismiss(animated: true) {
                pvc?.dismiss(animated: true) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "MapViewVC") as MapViewViewController
                    (pvcpvc as? UINavigationController)?.pushViewController(vc, animated: true)
                }
//                pvcpvc?.performSegue(withIdentifier: "segueToMapView", sender: nil)
            };
            
        } else {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    var time = ""
    var date = ""
    var address = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if listing {
            parkLabel.text = "Your listing is up!"
            instructionsLabel.text = "Your listing is live for buyers to view!\nYou'll get a notification if anyone purchases your spot."
            segueToMyReservations.setTitle("My Listings", for: .normal)
        } else {
            let instructions = attributedInfoRegular(string: "Your reservation has been processed and a confirmation has been sent to your email. Check the ", fontSize: 14)
            instructions.append(attributedInfoBold(string: "My Reservations", fontSize: 14))
            instructions.append(attributedInfoRegular(string: " tab for additional details regarding your reservation.", fontSize: 14))
            instructionsLabel.attributedText = instructions
            segueToMyReservations.setTitle("My Reservations", for: .normal)
        }
        infoLabel.font = UIFont(name: "OpenSans-Regular", size: 14)
//        timeLabel.text = time
//        addressLabel.text = address
        infoLabel.font = UIFont(name: "OpenSans-Regular", size: 16)
        
        let info = attributedInfoBold(string: "Date: ", fontSize: 16)
        info.append(attributedInfoRegular(string: date + "\n", fontSize: 16))
        info.append(attributedInfoBold(string: "Time: ", fontSize: 16))
        info.append(attributedInfoRegular(string: time + "\n", fontSize: 16))
        info.append(attributedInfoBold(string: "Address: ", fontSize: 16))
        info.append(attributedInfoRegular(string: address, fontSize: 16))
        
        infoLabel.attributedText = info
        
        infoView.layer.shadowRadius = 10
        infoView.layer.shadowColor = CGColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        infoView.layer.shadowOpacity = 0.2
        infoView.layer.shadowOffset = .init(width: 5, height: 5)
        parkLabel?.font = UIFont(name: "OpenSans-Bold", size: 26)
        parkLabel?.textColor = .black
        infoView.layer.cornerRadius = 32
        
        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
