//
//  SignupViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/28/20.
//

import UIKit

class SignupViewController: ViewController {
    
    
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password1: UITextField!
    @IBOutlet weak var password2: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBAction func signupAction(_ sender: Any) {
        if let email = email.text, let password1 = password1.text, let password2 = password2.text {
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

        // Do any additional setup after loading the view.
        signupButton.addTarget(self, action: #selector(signupAction), for: .touchUpInside)

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
