//
//  ContactInfoViewController.swift
//  InstaPark
//
//  Created by Daniel Hu on 2/6/21.
//

import UIKit
//import CoreData
import Firebase

class ContactInfoViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    var image: UIImage!
    var imageChanged = false
    var uid: String!
    var delegate: passFromProfile?
    //let defaults = UserDefaults.standard
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var userInfoView: UIView!
    
    var originalUserInfo: User!
    
    //    @IBOutlet var textField: [UITextField]!
//
//    @IBAction func save(_ sender: Any) {
//        defaults.set(textField[0].text, forKey: "firstName")
//        defaults.set(textField[1].text, forKey: "lastName")
//        defaults.set(textField[2].text, forKey: "phone")
//        defaults.set(textField[3].text, forKey: "email")
//        defaults.synchronize()
//        dismiss(animated: true)
//    }
//
//    var savedText: String!
//
//    @IBAction func enterInfo(_ sender: UITextField) {
//        print("Success")
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        savedText = textField.text
//        textField.resignFirstResponder()
//        return false
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textFields = [nameTextField, emailTextField, phoneTextField]
        for field in textFields {
            field!.delegate = self
        }
        
        userInfoView.layer.shadowRadius = 3.0
        userInfoView.layer.shadowOpacity = 0.20
        userInfoView.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        userInfoView.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        uid = Auth.auth().currentUser!.uid
        UserService.getUserById(uid) { (user, error) in
            if let user = user {
                self.originalUserInfo = user
                self.nameTextField.text = user.displayName
                self.emailTextField.text = user.email
                self.phoneTextField.text = user.phoneNumber
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
                                self.profilePhoto.image = UIimage
                            }
                        }
                        task.resume()
                }
            }
        }
        
//        textField[0].text = defaults.object(forKey: "firstName") as? String
//        textField[1].text = defaults.object(forKey: "lastName") as? String
//        textField[2].text = defaults.object(forKey: "phone") as? String
//        textField[3].text = defaults.object(forKey: "email") as? String
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let textFields = [nameTextField, emailTextField, phoneTextField]
        for field in textFields {
            field!.resignFirstResponder()
        }
    }

    @IBAction func NameTextField(_ sender: Any) {
    }
    @IBAction func EmailTextField(_ sender: Any) {
    }
    @IBAction func PhoneTextField(_ sender: Any) {
    }
    @IBAction func uploadProfilePhotoBtn(_ sender: Any) {
        let img = UIImagePickerController()
        img.delegate = self
        img.sourceType = UIImagePickerController.SourceType.photoLibrary
        img.allowsEditing = true
        self.present(img, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = self.resizeImage(image: editedImage, targetSize: CGSize(width: 100, height: 100))
            profilePhoto.image = editedImage
            imageChanged = true
        }
        else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = self.resizeImage(image: originalImage, targetSize: CGSize(width: 100, height: 100))
            profilePhoto.image = originalImage
            imageChanged = true
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        //MARK: save info to database here???
        //MARK: also did not implement saving of email since that might mess up authentication
        var changedData = [String:String]()
        if imageChanged {
            ImageService.uploadProfilePhoto(image: image, uid: uid)
        }
        if let email = emailTextField.text, let name = nameTextField.text, let phoneNumber = phoneTextField.text {
            print(email)
            if name == "" {
                displayAlert("Name field cannot be empty")
                return
            }
            if email == "" {
                displayAlert("Email field cannot be empty")
                return
            }
            
            if name != originalUserInfo.displayName {
                let fullNameArr = name.components(separatedBy: " ")
                let firstName: String = fullNameArr[0]
                let lastName: String? = fullNameArr.count > 1 ? fullNameArr[1] : nil
                changedData["displayName"] = name
                changedData["firstName"] = firstName
                changedData["lastName"] = lastName ?? ""
            }
            if phoneNumber != originalUserInfo.phoneNumber {
                changedData["phoneNumber"] = phoneNumber
            }
            
            if changedData.count != 0 {
                print(changedData)
                UserService.updateUserInfo(id: uid, changedData: changedData)
            }
        }
        dismiss(animated: true)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MapViewViewController{
            vc.signupPhoto = profilePhoto.image
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        if let name = nameTextField.text{
            let fullNameArr = name.components(separatedBy: " ")
            let firstName: String = fullNameArr[0]
            let lastName: String? = fullNameArr.count > 1 ? fullNameArr[1] : nil
            delegate?.reload(firstName: firstName, lastName: lastName ?? "", image: profilePhoto.image!)
        }
    }
}

