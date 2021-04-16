//
//  UserProfileViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 4/14/21.
//

import UIKit

//MARK: profile view for others to see
class UserProfileViewController: UIViewController {

    @IBOutlet weak var userNameTitle: UILabel!
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var contactInfoView: UIView!
    
    var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactInfoView.layer.shadowRadius = 3.0
        contactInfoView.layer.shadowOpacity = 0.20
        contactInfoView.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        contactInfoView.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        // Do any additional setup after loading the view.
        
        UserService.getUserById(uid ?? "") { (user, error) in
            if let user = user {
                self.name.text = user.displayName
                self.userNameTitle.text = user.displayName
                self.email.text = user.email
                self.phone.text = user.phoneNumber
                if user.photoURL != "" {
                    guard let url = URL(string: user.photoURL) else {
                            print("can't convert string to URL")
                            return
                        }
                        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                            guard let data = data, error == nil else {
                                print("failed to convert image from url")
                                return
                            }
                            DispatchQueue.main.async { [self] in
                                guard let UIimage = UIImage(data: data) else {
                                    print("failed to make image into UIimage")
                                    return
                                }
                                print("image converted")
                                self.userProfilePic.image = UIimage
                            }
                        }
                        task.resume()
                }
            }
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
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
