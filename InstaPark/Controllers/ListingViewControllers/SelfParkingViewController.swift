//
//  SelfParkingViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 2/22/21.
//

import UIKit

class SelfParkingViewController: UIViewController, UITextViewDelegate {
    var parkingType = ParkingType.short
    var ShortTermParking: ShortTermParkingSpot!
    @IBOutlet var hidden: [UIView]!

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
        switch sender.tag {
        case 0:
            ShortTermParking.selfParking.selfParkingMethod = "remote"
        case 1:
            ShortTermParking.selfParking.selfParkingMethod = "code"
        case 2:
            ShortTermParking.selfParking.selfParkingMethod = "key"
        default:
            ShortTermParking.selfParking.selfParkingMethod = "open"
        }
    }
    @IBOutlet weak var specificDirectionsInput: UITextView!
    @IBOutlet weak var wordCount: UILabel!
    var accessRadioButtons:[UIButton]?
    override func viewDidLoad() {
        accessRadioButtons = [remoteAccessButton, codeAccessButton, keyAccessButton, otherAccessButton]
        super.viewDidLoad()
        for btn in accessRadioButtons! {
            btn.layer.cornerRadius = btn.frame.width/2
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor(red: 0.429, green: 0.429, blue: 0.429, alpha: 1).cgColor
            btn.imageEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        }
        specificDirectionsInput.text = "Start typing here..."
        specificDirectionsInput.textColor = UIColor.lightGray
        specificDirectionsInput.font = UIFont(name: "OpenSans-Italic", size: 14)
        specificDirectionsInput.delegate = self
        specificDirectionsInput.textContainerInset.left = 15
        specificDirectionsInput.textContainerInset.top = 10
        specificDirectionsInput.textContainerInset.right = 15
        // Do any additional setup after loading the view.
    }
    func checkBeforeMovingPages() -> Bool {
        ShortTermParking.selfParking.specificDirections = specificDirectionsInput.text
        if(selectedAccess) {
            return true;
        } else {
            let alert = UIAlertController(title: "Error", message: "Please fill out parking spot access options.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return false;
        }
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

extension SelfParkingViewController {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let count = textView.text.count + (text.count - range.length)
        guard count <= 140 else {return false}
        wordCount.text = "\(count)/140"
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if specificDirectionsInput.textColor == UIColor.lightGray {
            specificDirectionsInput.text = ""
            specificDirectionsInput.textColor = UIColor.label
            specificDirectionsInput.font = UIFont(name: "OpenSans-Regular", size: 14)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        specificDirectionsInput.resignFirstResponder()
    }
    
}
