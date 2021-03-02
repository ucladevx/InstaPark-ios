//
//  PictureUploadViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 1/21/21.
//

import UIKit
import AVFoundation

class PictureUploadViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var scrollView: UIScrollView!
    var parkingType: ParkingType = .short
    var ShortTermParking: ShortTermParkingSpot!
    //var LongTermParking : LongTermParkingSpot!
    //Must change width and height in PictureSlide xib too if want to change scrollWidth/Height
    let scrollWidth = 300
    let scrollHeight = 200
    var page = 0
    //Must also change width and height of UploadSlideView if changing scrollWidth/Height
    var images = [UIImage]()
    var lowerQualityImages = [UIImage]()
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
            //shrink image
            let shrinkWidth = 400
            let shrinkHeight = Int(Double(shrinkWidth)/Double(selectedImage.size.width) * Double(selectedImage.size.height))
            print(shrinkHeight)
            lowerQualityImages.append(self.resizeImage(image: selectedImage, targetSize: CGSize(width: shrinkWidth, height: shrinkHeight)))
            print(images.count)
        }
        self.dismiss(animated: true, completion: {() in self.setUpSlides()})
    }
    

   //var images = [UIImage]()
    var imageIDs = [String]()
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
         pageControl.currentPage = page
        
    }
    
    @objc func deleteAction(sender:UIButton) {
        images.remove(at: sender.tag)
        lowerQualityImages.remove(at: sender.tag)
        setUpSlides()
    }

    func setUpSlides() {
        var arraySlides = [UIView]()
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        for i in images {
            let slide:PictureSlide = Bundle.main.loadNibNamed("PictureSlide", owner: self, options: nil)?.first as! PictureSlide
            let frame = AVMakeRect(aspectRatio: i.size, insideRect: slide.image.frame)
            slide.image.image = i
            slide.buttonTop.constant = (CGFloat(scrollHeight) - frame.height)/2 + 10
            slide.buttonRight.constant = (CGFloat(scrollWidth) - frame.width)/2 + 10
            slide.button.tag = arraySlides.count
            slide.button.addTarget(self, action: #selector(deleteAction), for: .touchDown)
            arraySlides.append(slide)
        }
        arraySlides.append(uploadSlide)

        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: scrollWidth * arraySlides.count, height: scrollHeight)
        for i in 0 ..< arraySlides.count {
            arraySlides[i].frame = CGRect(x: scrollWidth * i, y: 0, width: scrollWidth, height: scrollHeight)
            scrollView.addSubview(arraySlides[i])
        }
        pageControl.numberOfPages = arraySlides.count
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
//    func uploadAllPhotosToDB() {
//        for image in images {
//            ImageService.uploadImage(image: image) { (imageID, error) in
//                if let imageID = imageID, error == nil {
//                    print(imageID)
//                    self.imageIDs.append(imageID)
//                }
//            }
//        }
//    }
    
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
    
    func checkBeforeMovingPages() -> Bool {
        //should be fine to not check this view since it is fine to upload no pictures
        print("check before moving, image size: \(images.count)")
        return true
    }
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if images.count == 0 {
            let alert = UIAlertController(title: "Error", message: "Please upload at least one photo of your parking spot.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }*/
}
