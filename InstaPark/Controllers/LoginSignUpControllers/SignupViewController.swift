//
//  SignupViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/28/20.
//

import UIKit
import Foundation
class SignupViewController: ViewController {
    
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var startedLabel: UILabel!
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password1: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var phone: DesignableTextField!
    @IBOutlet weak var signupStack: UIStackView!
    @IBOutlet weak var venmo_username: DesignableTextField!
    var clickedVenmoBefore = false
    var password1Value = ""
    var password2Value = ""
    var user: User!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBAction func didTouchVenmoUsernameTextField(_ sender: Any) {
//        if(!clickedVenmoBefore) {
//            let alert = UIAlertController(title: "Important!", message: "Your venmo username will be used to receive payments. Please make sure it is correct!", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Okay", style: .default))
//            self.present(alert, animated: true)
//            clickedVenmoBefore = true
//        }
    }
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
//    @objc func keyboardWasShown(notification: NSNotification) {
//        let info = notification.userInfo!
//        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//
//        UIView.animate(withDuration: 0.3, animations: { () -> Void in
//            self.bottomConstraint.constant = keyboardFrame.size.height + 20
//        })
//    }
//    @objc func keyboardWasHidden(notification: NSNotification) {
//        UIView.animate(withDuration: 0.3, animations: { () -> Void in
//            self.bottomConstraint.constant = 150
//        })
//    }
    var activeField: UITextField?
    func registerForKeyboardNotifications()
   {
       //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
   }
   func deregisterFromKeyboardNotifications()
   {
    
       //Removing notifies on keyboard appearing
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
   }

   @objc func keyboardWasShown(notification: NSNotification)
   {
       //Need to calculate keyboard exact size due to Apple suggestions
       var info = notification.userInfo!
       var keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
//       var aRect : CGRect = self.view.frame
//       aRect.size.height -= keyboardSize!.height
//       if let activeFieldPresent = activeField
//       {
//        if (!aRect.contains(activeField!.frame.origin))
//           {
//            bottomConstraint.constant = keyboardSize!.height + 20
//           }
//       }
    if(activeField == password2 || activeField == venmo_username) {
        bottomConstraint.constant = keyboardSize!.height + 20
    }

   }
    @objc func keyboardWillBeHidden(notifcation: NSNotification) {
        bottomConstraint.constant = 150
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        print(activeField?.placeholder)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    @IBAction func signupAction(_ sender: Any) {
        if let email = email.text, let name = firstname.text, let phoneNumber = phone.text, let password1 = password1.text, let password2 = password2.text, let venmouser = venmo_username.text{
            var fullNameArr = name.components(separatedBy: " ")
            var firstName: String = fullNameArr[0]
            var lastName: String? = fullNameArr.count > 1 ? fullNameArr[1] : nil
            user = User(uid: "", displayName: name, phoneNumber: phoneNumber ?? "", firstName: firstName, lastName: lastName ?? "" , photoURL: "", email: email, venmo_username: venmouser, transactions: [], parkingSpots: [])

            AuthService.signup(user: user, password1: password1, password2: password2) { (success, error) in
               if success != nil{
                 self.performSegue(withIdentifier: "signupInfoSuccess", sender: self)
               } else {
                if let messageError = error {
                    let alertController = UIAlertController(title: "Error", message: messageError.errorString(), preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
               }
            }
        }
    }
    
    override func viewDidLoad() {
        super.showNavBar(true)
        super.viewDidLoad()
        
        welcomeLabel.font = UIFont(name: "OpenSans-Bold", size: 43)
        startedLabel.font = UIFont(name: "OpenSans-Bold", size: 41)
        
        //passwords
        /*
        if #available(iOS 10.0, *) {
            password1.textContentType = UITextContentType(rawValue: "")
            password2.textContentType = UITextContentType(rawValue: "")
        }
        password1.addTarget(self, action: #selector(password1(_:)), for: .editingChanged)
        password2.addTarget(self, action: #selector(password2(_:)), for: .editingChanged)
        password1.autocorrectionType = .no
        password2.autocorrectionType = .no*/
        

        password1.isSecureTextEntry = true
        password2.isSecureTextEntry = true

        // Do any additional setup after loading the view.
        signupButton.addTarget(self, action: #selector(signupAction), for: .touchUpInside)
        signupButton.layer.shadowRadius = 3.0
        signupButton.layer.shadowOpacity = 0.3
        signupButton.layer.shadowOffset = CGSize.init(width: 2, height: 2)
        signupButton.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        email.delegate = self
        firstname.delegate = self
        password1.delegate = self
        password2.delegate = self
        venmo_username.delegate = self
        registerForKeyboardNotifications()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        email.resignFirstResponder()
        firstname.resignFirstResponder()
        password1.resignFirstResponder()
        password2.resignFirstResponder()
    }
    

    @IBAction func password1(_ textField: UITextField){
        /*
        if textField.text!.count > 1 {
                // User did copy & paste
                if password1Value.count == 0 { // Pasted into an empty textField
                    password1Value = String(textField.text!)
                }
            } else {
                // User did input by keypad
                if textField.text!.count > password1Value.count { // Added chars
                    password1Value += String(textField.text!.last!)
                } else if textField.text!.count < password1Value.count { // Removed chars
                    password1Value = String(password1Value.dropLast())
                }
        }
        self.password1.text = String(repeating: "•", count: self.password1.text!.count)*/
    }
    
    @IBAction func password2(_ textField: UITextField) {
        /*
        if textField.text!.count > 1 {
                // User did copy & paste
                if password2Value.count == 0 { // Pasted into an empty textField
                    password2Value = String(textField.text!)
                }
            } else {
                // User did input by keypad
                if textField.text!.count > password2Value.count { // Added chars
                    password2Value += String(textField.text!.last!)
                } else if textField.text!.count < password2Value.count { // Removed chars
                    password2Value = String(password2Value.dropLast())
                }
        }
        self.password2.text = String(repeating: "•", count: self.password2.text!.count)*/
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProfilePhotoUploadViewController {
            vc.user = self.user
        }
    }
    

}

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
