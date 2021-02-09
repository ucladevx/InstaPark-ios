//
//  CommentsViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 1/21/21.
//

import UIKit
import MapKit

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
    @IBAction func nextBtn(_ sender: Any) {
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
            //nextViewController.listing = true
            //nextViewController.info = ParkingSpaceMapAnnotation.init(id: "", name: "First Last", coordinate: CLLocationCoordinate2DMake(34.0703, -118.4441), price: 6.0, address: "address goes here", tags: ["tag1", "tag2", "tag3"], comments: comments.text, startTime: Date(), endTime: Date(), date: Date(), startDate: Date(), endDate: nil)
            var startTime: Date = Date()
            var endTime: Date = Date()
            for i in 0...6 {
                let day = ShortTermParking.times[i]
                if day?.isEmpty == false {
                    startTime = Date.init(timeIntervalSince1970: TimeInterval(day![0].start))
                    print(startTime)
                    endTime = Date.init(timeIntervalSince1970: TimeInterval(day![0].end))
                    break
                }
            }
            nextViewController.ShortTermParking = ShortTermParking
            var address = ShortTermParking.address.street
                address += ", " + ShortTermParking.address.city
                address += ", " + ShortTermParking.address.state + " " + ShortTermParking.address.zip
            nextViewController.listing = true
            nextViewController.info = ParkingSpaceMapAnnotation.init(id: "", name: ShortTermParking.firstName + " " + ShortTermParking.lastName, coordinate: CLLocationCoordinate2DMake(ShortTermParking.coordinates.lat, ShortTermParking.coordinates.long), price: ShortTermParking.pricePerHour, address: address, tags: ShortTermParking.tags, comments: ShortTermParking.comments, startTime: startTime, endTime: endTime, date: Date(), startDate: Date(), endDate: nil)
        } else {
            // pass in long term parking when ready
        }
        self.present(nextViewController, animated:true)
    }
    

}
