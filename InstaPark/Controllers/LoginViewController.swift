//
//  LoginViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/28/20.
//

import UIKit

class LoginViewController: ViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!
    
    @IBAction func loginAction(_ sender: Any) {
        if let email = email.text, let password = password.text {
            AuthService.login(email: email, password: password) { (success, error) in
               if success != nil{
                 self.performSegue(withIdentifier: "loginSuccess", sender: self)
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
        //G Login Button
        googleLoginButton.setImage(UIImage(named: "google-icon.ico"), for: .normal)
        googleLoginButton.imageView?.contentMode = .scaleAspectFit
        googleLoginButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        
        googleLoginButton.contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 10,
            bottom: 0,
            right: 0
        )
        
        //Apple Login Button
//        appleLoginButton.setImage(UIImage(named: "applelogo"), for: .normal)
        appleLoginButton.imageView?.contentMode = .scaleAspectFit
        appleLoginButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        appleLoginButton.contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 10,
            bottom: 0,
            right: 0
        )
        super.hideNavBar(true)
        super.viewDidLoad()
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
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
