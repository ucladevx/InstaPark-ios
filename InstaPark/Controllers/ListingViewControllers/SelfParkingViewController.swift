//
//  SelfParkingViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 2/22/21.
//

import UIKit

class SelfParkingViewController: UIViewController {
    var parkingType = ParkingType.short
    var ShortTermParking: ShortTermParkingSpot!
    @IBOutlet var hidden: [UIView]!
    @IBOutlet weak var selfParkingAvailableButton: UIButton!
    
    @IBOutlet weak var selfParkingUnavailableButton: UIButton!
    @IBOutlet weak var selectionDetailsText: UILabel!
    var selectedSelfParking = false
    @IBAction func selfParkingSelect(_ sender: UIButton) {
        if(!selectedSelfParking) {
            for view in hidden {
                view.isHidden = false
            }
        }
        selectedSelfParking = true
        for btn in selfParkingRadioButtons! {
            btn.setImage(UIImage(), for: .normal)
            btn.tintColor = UIColor.darkGray
        }
        sender.tintColor = UIColor(red: 183/255, green: 91/255, blue: 1, alpha: 1)
        sender.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        if sender == selfParkingAvailableButton {
            ShortTermParking.selfParking.hasSelfParking = true
            selectionDetailsText.text = "Any details to access your parking spot will be sent automatically after a reservation request."
        } else {
            ShortTermParking.selfParking.hasSelfParking = false
            selectionDetailsText.text = "Booking transactions will be held until you accept and confirm booking reservation requests."
        }
    }
    @IBOutlet weak var remoteAccessButton: UIButton!
    @IBOutlet weak var codeAccessButton: UIButton!
    @IBOutlet weak var keyAccessButton: UIButton!
    @IBOutlet weak var otherAccessButton: UIButton!
    var selectedAccess = false
    @IBAction func accessSelect(_ sender: UIButton) {
        selectedAccess = true
        for btn in accessRadioButtons! {
            btn.setImage(UIImage(), for: .normal)
            btn.tintColor = UIColor.darkGray
        }
        sender.tintColor = UIColor(red: 183/255, green: 91/255, blue: 1, alpha: 1)
        sender.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        ShortTermParking.selfParking.selfParkingMethod = sender.value(forKey: "tag") as? String ?? ""
    }
    @IBOutlet weak var specificDirectionsInput: UITextView!
    var selfParkingRadioButtons:[UIButton]?
    var accessRadioButtons:[UIButton]?
    override func viewDidLoad() {
        for view in hidden {
            view.isHidden = true
        }
        selfParkingRadioButtons = [selfParkingAvailableButton, selfParkingUnavailableButton]
        accessRadioButtons = [remoteAccessButton, codeAccessButton, keyAccessButton, otherAccessButton]
        super.viewDidLoad()
        for btn in selfParkingRadioButtons! {
            btn.layer.cornerRadius = 8
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor(red: 0.429, green: 0.429, blue: 0.429, alpha: 1).cgColor
        }
        for btn in accessRadioButtons! {
            btn.layer.cornerRadius = 8
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor(red: 0.429, green: 0.429, blue: 0.429, alpha: 1).cgColor
        }
        // Do any additional setup after loading the view.
    }
    func checkBeforeMovingPages() -> Bool {
        ShortTermParking.selfParking.specificDirections = specificDirectionsInput.text
        return selectedSelfParking && selectedAccess
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