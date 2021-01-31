//
//  PictureUploadViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 1/21/21.
//

import UIKit

class PictureUploadViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parkingType: ParkingType = .short
    var ShortTermParking: ShortTermParkingSpot!
    //var LongTermParking : LongTermParkingSpot!
    
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        //UNCOMMENT this when all the listing controllers are connected
        if imageIDs.count != 0 {
            if parkingType == .short {
                ShortTermParking.images = imageIDs
                print(ShortTermParking.images)
            } else { //longterm parking when finished
                
            }
            
        }
        if let vc = segue.destination as? CommentsViewController {
            vc.parkingType = parkingType
            if(parkingType == .short) {
                vc.ShortTermParking = ShortTermParking
            } else {
                // pass in long term parking when ready
            }
        }*/
    }
}
