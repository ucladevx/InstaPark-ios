//
//  PictureUploadViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 1/21/21.
//

import UIKit

class PictureUploadViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func uploadAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerController.SourceType.photoLibrary;
            imag.allowsEditing = false
            self.present(imag, animated: true, completion: nil)
            }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            images.append(selectedImage)
        }
       self.dismiss(animated: true, completion: nil)
    }
    
    var images = [UIImage]()
    var imageIDs = [String]()
    @IBOutlet var upload: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upload.layer.shadowRadius = 3.0
        upload.layer.shadowOpacity = 0.3
        upload.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        upload.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    // call right before going to next view or maybe when the user confirms the entire listing to avoid uploading unwanted photos?
    func uploadAllPhotosToDB() {
        for image in images {
            ImageService.uploadImage(image: image) { (imageID, error) in
                if let imageID = imageID, error == nil {
                    print(imageID)
                    self.imageIDs.append(imageID)
                }
            }
        }
    }
}
