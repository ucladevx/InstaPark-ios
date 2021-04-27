//
//  PriceViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 1/28/21.
//

import UIKit

class PriceViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var input2: UITextField!
    @IBOutlet var input1: UITextField!
    @IBOutlet var PriceDescrip: UILabel!
    @IBOutlet weak var dailyPricingCheckbox: UIButton!
    @IBOutlet weak var dailyPricingStackView: UIStackView!
    
    @IBOutlet weak var input3: UITextField!
    @IBOutlet weak var input4: UITextField!
    var price:Double = 0;
    var dailyPrice: Double = 0;
    var parkingType: ParkingType = .short
    var ShortTermParking: ShortTermParkingSpot!
    var dailyPriceEnabled: Bool = false
    //var LongTermParking : LongTermParkingSpot!
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= 2
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "XX" {
            textField.text = nil
            textField.font = UIFont(name: "Roboto", size: 36)
            textField.textColor = UIColor(red: 0.56, green: 0, blue: 1, alpha: 1)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var newsum:Double = 0;
        newsum += Double(input1.text ?? "0") ?? 0
        newsum += (Double(input2.text ?? "0") ?? 0.0) / 100
        price = newsum
        print(price)
        var dailySum = 0.0;
        dailySum += Double(input3.text ?? "0") ?? 0
        dailySum += (Double(input4.text ?? "0") ?? 0.0) / 100
        dailyPrice = dailySum == 0.0 ? -1 : dailySum
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        input1.resignFirstResponder()
        input2.resignFirstResponder()
    }
    
    @IBAction func checkedDailyPricingBox(_ sender: UIButton) {
        if sender.backgroundColor != .clear {
            sender.backgroundColor = .clear
            sender.layer.borderWidth = 0.5
            sender.setImage(nil, for: .normal)
            dailyPricingStackView.isHidden = true
            dailyPriceEnabled = false
        } else {
            sender.backgroundColor = UIColor(red: 183/255, green: 91/255, blue: 1, alpha: 1)
            sender.layer.borderWidth = 0
            sender.setImage(UIImage(named: "check"), for: .normal)
            dailyPricingStackView.isHidden = false
            dailyPriceEnabled = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dailyPricingStackView.isHidden = true
        input1.delegate = self
        input2.delegate = self
        input3.delegate = self
        input4.delegate = self
        //Must declare info text here because bolding partial text in storyboard doesn't work
        let attrs_b = [NSAttributedString.Key.font : UIFont(name: "Roboto Bold", size: 12)]
        let attrs = [NSAttributedString.Key.font : UIFont(name: "Roboto", size: 12)]
        
        let h_text = "Enter your price. This will be charged on an "
        let h_bold = "hourly "
        let h_text2 = "basis to buyers."
        
        let h_attributed = NSMutableAttributedString(string:h_text, attributes:attrs as [NSAttributedString.Key : Any])
        let h_attributed_b = NSMutableAttributedString(string: h_bold, attributes: attrs_b as [NSAttributedString.Key : Any])
        let h_attributed2 = NSMutableAttributedString(string:h_text2, attributes:attrs as [NSAttributedString.Key : Any])
        h_attributed.append(h_attributed_b)
        h_attributed.append(h_attributed2)
        PriceDescrip.attributedText = h_attributed
        dailyPricingCheckbox.layer.cornerRadius = 3
        dailyPricingCheckbox.layer.borderWidth = 0.5
        dailyPricingCheckbox.layer.borderColor = UIColor(red: 0.429, green: 0.429, blue: 0.429, alpha: 1).cgColor
    }
    
    func checkBeforeMovingPages() -> Bool {
        if price == 0 {
            let alert = UIAlertController(title: "Error", message: "Please input a price above $0.00.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        ShortTermParking.pricePerHour = abs(price)
        ShortTermParking.pricePerDay = abs(dailyPrice)
        ShortTermParking.dailyPriceEnabled = dailyPriceEnabled
        return true
    }

}
