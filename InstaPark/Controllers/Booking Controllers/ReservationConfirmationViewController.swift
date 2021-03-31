//
//  ReservationConfirmationViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 11/20/20.
//

import UIKit

class ReservationConfirmationViewController: UIViewController {

    @IBOutlet weak var parkLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    var listing = false // only true if new listing is created
    
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
    var address = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if listing {
            parkLabel.text = "Your listing is up!"
            instructionsLabel.text = "Your listing is live for buyers to view!\nYou'll get a notification if anyone purchases your spot."
        }
        timeLabel.text = time
        addressLabel.text = address
        infoView.layer.shadowRadius = 10
        infoView.layer.shadowColor = CGColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        infoView.layer.shadowOpacity = 0.2
        infoView.layer.shadowOffset = .init(width: 5, height: 5)
        parkLabel?.font = UIFont(name: "OpenSans-Bold", size: 34)
        
        // Do any additional setup after loading the view.
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
