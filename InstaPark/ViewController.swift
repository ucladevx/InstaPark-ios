//
//  ViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/27/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // AuthService.signup(email: "tonyjiang02@gmail.com", password: "test123$")
        // AuthService.signup(email: "tonyjiang02@gmail.com", password1: "test123$", password2: "test123$")
        // Do any additional setup after loading the view.
    }
    
    func hideNavBar(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func showNavBar(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
