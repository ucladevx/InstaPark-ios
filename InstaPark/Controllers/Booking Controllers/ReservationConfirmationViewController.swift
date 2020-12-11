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
    
    var time = ""
    var address = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.text = time
        addressLabel.text = address
        infoView.layer.shadowRadius = 10
        infoView.layer.shadowColor = CGColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        infoView.layer.shadowOpacity = 0.2
        infoView.layer.shadowOffset = .init(width: 5, height: 5)
        parkLabel?.font = UIFont(name: "BebasNeue", size: 40)
        
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
