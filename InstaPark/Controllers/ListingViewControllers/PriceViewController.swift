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
    var price:Double = 0;
    
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        input1.resignFirstResponder()
        input2.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        input1.delegate = self
        input2.delegate = self
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if price == 0 {
            let alert = UIAlertController(title: "Error", message: "Please input a price above $0.00.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }


}
