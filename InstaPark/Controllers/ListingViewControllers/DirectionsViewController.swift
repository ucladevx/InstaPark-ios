//
//  DirectionsViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 2/2/21.
//

import UIKit

class DirectionsViewController: UIViewController, UITextViewDelegate {
    
    var parkingType: ParkingType = .short
    var ShortTermParking: ShortTermParkingSpot!
    //var LongTermParking : LongTermParkingSpot!
    var images = [UIImage]()
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let count = textView.text.count + (text.count - range.length)
        guard count <= 140 else {return false}
        charCount.text = "\(count)/140"
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if directionsText.textColor == UIColor.lightGray {
            directionsText.text = nil
            directionsText.textColor = UIColor.label
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        directionsText.resignFirstResponder()
    }
    
    @IBOutlet var charCount: UILabel!
    @IBOutlet var directionsText: UITextView!
    
    var directions = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Runtime attributes must be done here b/c borderColor doesn't work on Storyboard
        //directionsText border radius was able to done in Storyboard however
        directionsText.delegate = self
        directionsText.text = "Start typing here..."
        directionsText.textColor = UIColor.lightGray
        directionsText.textContainerInset.left = 10
        directionsText.textContainerInset.right = 10
        
    }
    
    func checkBeforeMovingPages() -> Bool {
        //directions are also optional
        if directionsText.text != "" && directionsText.text != "Start typing here..."{
            ShortTermParking.directions = directionsText.text
            print("in check before moving: \(ShortTermParking.directions)")
        }
        return true
    }
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if directions == "" {
            let alert = UIAlertController(title: "Error", message: "Please enter directions to your parking spot.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }*/
}
