//
//  SignupViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/28/20.
//

import UIKit

class SignupViewController: ViewController {
    
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var startedLabel: UILabel!
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password1: UITextField!
    @IBOutlet weak var password2: UITextField!
    
    var password1Value = ""
    var password2Value = ""
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBAction func signupAction(_ sender: Any) {
        if let email = email.text, let password1 = password1.text, let password2 = password2.text{
            AuthService.signup(email: email, password1: password1, password2: password2) { (success, error) in
               if success != nil{
                 self.performSegue(withIdentifier: "signupSuccess", sender: self)
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
        
        welcomeLabel.font = UIFont(name: "BebasNeue", size: 48)
        startedLabel.font = UIFont(name: "BebasNeue", size: 47)
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
