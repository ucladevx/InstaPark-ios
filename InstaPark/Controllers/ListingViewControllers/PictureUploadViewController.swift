//
//  PictureUploadViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 1/21/21.
//

import UIKit



class PictureUploadViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!
    var parkingType: ParkingType = .short
    var ShortTermParking: ShortTermParkingSpot!
    //var LongTermParking : LongTermParkingSpot!
    let scrollWidth = 300
    let scrollHeight = 200
    var page = 0
    //Must also change width and height of UploadSlideView if changing scrollWidth/Height
    var images = [UIImage]()
    let uploadSlide = Bundle.main.loadNibNamed("UploadSlideView", owner: self, options: nil)?.first as! UploadSlideView

    
    @objc func buttonAct(_ sender: UIButton!) {
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
        self.dismiss(animated: true, completion: {() in self.setUpSlides()})
    }
    

   //var images = [UIImage]()
    var imageIDs = [String]()
    @IBOutlet var upload: UIButton!
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
         pageControl.currentPage = page
        
    }

    func setUpSlides() {
        var array = [UIView]()
        for i in images {
            let slide = UIImageView()
            slide.image = i
            slide.contentMode = .scaleAspectFit
            array.append(slide)
        }
        array.append(uploadSlide)

        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: scrollWidth * array.count, height: scrollHeight)
        for i in 0 ..< array.count {
            array[i].frame = CGRect(x: scrollWidth * i, y: 0, width: scrollWidth, height: scrollHeight)
            scrollView.addSubview(array[i])
        }
        pageControl.numberOfPages = array.count
        pageControl.currentPage = 0
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setUpSlides()
        pageControl.numberOfPages = 1
        pageControl.currentPage = 0
        
        uploadSlide.buttonOut.layer.shadowRadius = 3.0
        uploadSlide.buttonOut.layer.shadowOpacity = 0.3
        uploadSlide.buttonOut.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        uploadSlide.buttonOut.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        uploadSlide.buttonOut.addTarget(self, action: #selector(self.buttonAct), for: .touchUpInside)
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
        if images.count == 0 {
            let alert = UIAlertController(title: "Error", message: "Please upload at least one photo of your parking spot.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
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
