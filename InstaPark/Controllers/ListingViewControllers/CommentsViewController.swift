//
//  CommentsViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 1/21/21.
//

import UIKit
import MapKit
import Firebase

class CommentsViewController: UIViewController, UITextViewDelegate{
    
    @IBOutlet var comments: UITextView!
    //Comment can be retrieved using comments.text
    @IBOutlet var wordCount: UILabel!
    var images = [UIImage]()
    var parkingType: ParkingType = .short
    var ShortTermParking: ShortTermParkingSpot!
    //var LongTermParking : LongTermParkingSpot!
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let count = textView.text.count + (text.count - range.length)
        guard count <= 140 else {return false}
        wordCount.text = "\(count)/140"
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if comments.textColor == UIColor.lightGray {
            comments.text = ""
            comments.textColor = UIColor.black
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        comments.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        comments.delegate = self
        comments.text = "Start typing here..."
        comments.textColor = UIColor.lightGray
        comments.textContainerInset.left = 10
        comments.textContainerInset.right = 10
    }
    
    func checkBeforeMovingPages() -> Bool {
        if comments.text.count != 0 {
            if parkingType == .short {
                ShortTermParking.comments = comments.text
            } else { //longterm parking once it's done
                
            }
        }
        return true
    }
    
    // MARK: - Navigation

    //pass all info into booking view controller
    func moveToNext() {
        print("next")
        if comments.text == "" || comments.text == "Start typing here..." {
            let alert = UIAlertController(title: "Error", message: "Please enter a comment", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if comments.text.count != 0 {
            if parkingType == .short {
                ShortTermParking.comments = comments.text
            } else { //longterm parking once it's done
                
            }
        }
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "bookingView") as! BookingViewController
        nextViewController.modalPresentationStyle = .fullScreen
        nextViewController.modalTransitionStyle = .coverVertical
        
        nextViewController.parkingType = parkingType
        nextViewController.images = images
        if(parkingType == .short) {
            var startTime: Date = Date()
            var endTime: Date = Date()
            for i in 0...6 {
                let day = self.ShortTermParking.times[i]
                if day?.isEmpty == false {
                    startTime = Date.init(timeIntervalSince1970: TimeInterval(day![0].start))
                    print(startTime)
                    endTime = Date.init(timeIntervalSince1970: TimeInterval(day![0].end))
                    break
                }
            }
            nextViewController.ShortTermParking = self.ShortTermParking
            var address = self.ShortTermParking.address.street
            address += ", " + self.ShortTermParking.address.city
            address += ", " + self.ShortTermParking.address.state + " " + self.ShortTermParking.address.zip
            nextViewController.listing = true
            let start = Date.init(timeIntervalSince1970: TimeInterval(self.ShortTermParking.startDate))
            var end:Date? = Date.init(timeIntervalSince1970: TimeInterval(self.ShortTermParking.endDate))
            if start == end {
                end = nil
            }
            nextViewController.info = ParkingSpaceMapAnnotation.init(id: ShortTermParking.provider, name: "",email:"", phoneNumber: "", photo: "", coordinate: CLLocationCoordinate2DMake(self.ShortTermParking.coordinates.lat, self.ShortTermParking.coordinates.long), price: self.ShortTermParking.pricePerHour, address: self.ShortTermParking.address, tags: self.ShortTermParking.tags, comments: self.ShortTermParking.comments, startTime: startTime, endTime: endTime, date: Date(), startDate: start, endDate: end, images: [String]())
            
        } else {
            // pass in long term parking when ready
        }
        self.present(nextViewController, animated:true)
    }
    

}
