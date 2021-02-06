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
    
    
    // MARK: - Navigation

    //pass all info into booking view controller
    @IBAction func nextBtn(_ sender: Any) {
        print("next")
        //UNCOMMENT all comment parts when all the listing controllers are connected
        /*
        if comments.text.count != 0 {
            if parkingType == .short {
                ShortTermParking.comments = comments.text
            } else { //longterm parking once it's done
                
            }
        }*/
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "bookingView") as! BookingViewController
        nextViewController.modalPresentationStyle = .fullScreen
        nextViewController.modalTransitionStyle = .coverVertical
        
        nextViewController.parkingType = parkingType
        if(parkingType == .short) {
            //temp for now until all views are connected
            nextViewController.listing = true
            nextViewController.info = ParkingSpaceMapAnnotation.init(id: "", name: "First Last", coordinate: CLLocationCoordinate2DMake(34.0703, -118.4441), price: 6.0, address: "address goes here", tags: ["tag1", "tag2", "tag3"], comments: comments.text, startTime: Date(), endTime: Date(), date: Date(), startDate: Date(), endDate: nil)
            /*
            nextViewController.ShortTermParking = ShortTermParking
            var address = ShortTermParking.address.street
                address += ", " + ShortTermParking.address.city
                address += ", " + ShortTermParking.address.state + " " + ShortTermParking.address.zip
            nextViewController.listing = true
            nextViewController.info = ParkingSpaceMapAnnotation.init(id: "", name: ShortTermParking.firstName + " " + ShortTermParking.lastName, coordinate: CLLocationCoordinate2DMake(ShortTermParking.coordinates.lat, ShortTermParking.coordinates.long), price: ShortTermParking.pricePerHour, address: address, tags: ShortTermParking.tags, comments: ShortTermParking.comments, startTime: Date(), endTime: Date(), date: Date(), startDate: Date(), endDate: nil)*/
        } else {
            // pass in long term parking when ready
        }
        self.present(nextViewController, animated:true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if comments.text == "" || comments.text == "Start typing here..." {
            let alert = UIAlertController(title: "Error", message: "Please enter a comment", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }

}
