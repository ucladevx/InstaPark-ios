//
//  ContactInfoViewController.swift
//  InstaPark
//
//  Created by Daniel Hu on 2/6/21.
//

import UIKit
import CoreData


class ContactInfoViewController: UIViewController, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var textField: [UITextField]!
    
    @IBAction func save(_ sender: Any) {
        defaults.set(textField[0].text, forKey: "firstName")
        defaults.set(textField[1].text, forKey: "lastName")
        defaults.set(textField[2].text, forKey: "phone")
        defaults.set(textField[3].text, forKey: "email")
        defaults.synchronize()
        dismiss(animated: true)
    }
    
    var savedText: String!
    
    @IBAction func enterInfo(_ sender: UITextField) {
        print("Success")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        savedText = textField.text
        textField.resignFirstResponder()
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField[0].text = defaults.object(forKey: "firstName") as? String
        textField[1].text = defaults.object(forKey: "lastName") as? String
        textField[2].text = defaults.object(forKey: "phone") as? String
        textField[3].text = defaults.object(forKey: "email") as? String
    }

}

