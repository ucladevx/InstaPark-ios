//
//  LoginViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/28/20.
//

import UIKit

import Firebase
import GoogleSignIn

class LoginViewController: ViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var instaparkLogo: UILabel!
    
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBAction func googleLoginAction(_ sender: Any) {
        print("google button pressed")
        GIDSignIn.sharedInstance()?.presentingViewController = self
//        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
    }
    
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
        navigationController?.isNavigationBarHidden = false
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
        
        googleLoginButton.layer.shadowRadius = 3.0
        googleLoginButton.layer.shadowOpacity = 0.3
        googleLoginButton.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        googleLoginButton.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        //Apple Login Button
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
        email.delegate = self
        password.delegate = self
        
        //login button
        loginButton.layer.shadowRadius = 3.0
        loginButton.layer.shadowOpacity = 0.3
        loginButton.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        loginButton.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        //instapark logo
        func gradientColor(bounds: CGRect, gradientLayer :CAGradientLayer) -> UIColor? {
              UIGraphicsBeginImageContext(gradientLayer.bounds.size)
              gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
              let image = UIGraphicsGetImageFromCurrentImageContext()
              UIGraphicsEndImageContext()
              return UIColor(patternImage: image!)
        }
        func getGradientLayer(bounds : CGRect) -> CAGradientLayer{
            let gradient = CAGradientLayer()
            gradient.frame = bounds
            gradient.colors = [UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0).cgColor, UIColor.init(red: 0.561, green: 0.0, blue: 1.0, alpha: 1.0).cgColor]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            return gradient
        }

        
        let gradient = getGradientLayer(bounds: instaparkLogo.bounds)
        instaparkLogo.textColor = gradientColor(bounds: instaparkLogo.bounds, gradientLayer: gradient)
        instaparkLogo?.font = UIFont(name: "BebasNeue", size: 48)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        email.resignFirstResponder()
        password.resignFirstResponder()
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
