//
//  ProfilePhotoUploadViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 2/24/21.
//

import UIKit
import Firebase

class ProfilePhotoUploadViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    var image: UIImage!
    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        profileImage.layer.cornerRadius = 60
        print(Auth.auth().currentUser!.uid)
        print(user.displayName)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func UploadPhotoBtn(_ sender: Any) {
        let img = UIImagePickerController()
        img.delegate = self
        img.sourceType = UIImagePickerController.SourceType.photoLibrary
        img.allowsEditing = true
        self.present(img, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                image = self.resizeImage(image: selectedImage, targetSize: CGSize(width: 100, height: 100))
                profileImage.image = selectedImage
            }
           self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ContinueBtn(_ sender: Any){
        if image == nil {
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to proceed without choosing a profile photo?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
                return
            }))
            alert.addAction(UIAlertAction(title: "Proceed", style: UIAlertAction.Style.destructive, handler: {(_: UIAlertAction!) in
                self.performSegue(withIdentifier: "signupSuccess", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        ImageService.uploadProfilePhoto(image: image, uid: currentUser.uid)
        self.performSegue(withIdentifier: "signupSuccess", sender: self)
    }
    @IBAction func SkipForNowBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "signupSuccess", sender: self)
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
}
