//
//  DirectionsViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 2/2/21.
//

import UIKit

class DirectionsViewController: UIViewController, UITextViewDelegate {

    @IBAction func recentDirectButtonAct(_ sender: UIButton) {
        if useRecent {
            recentDirectButton.backgroundColor = .clear
            recentDirectButton.layer.borderWidth = 2
            useRecent = false
            directions = directionsText.text ?? ""
        } else {
            useRecent = true
            directions = userRecentText
            recentDirectButton.backgroundColor = UIColor(red: 183/255, green: 91/255, blue: 1, alpha: 1)
            recentDirectButton.layer.borderWidth = 0
        }
        print(directions)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let count = textView.text.count + (text.count - range.length)
        guard count <= 140 else {return false}
        charCount.text = "\(count)/140"
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if directionsText.textColor == UIColor.lightGray {
            directionsText.text = nil
            directionsText.textColor = UIColor.black
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        directionsText.resignFirstResponder()
    }
    
    @IBOutlet var directionsToTop: NSLayoutConstraint!
    @IBOutlet var recentDirectionsHeading: UILabel!
    @IBOutlet var recentDirectContainer: UIStackView!
    @IBOutlet var recentDirectButton: UIButton!
    @IBOutlet var recentDirectText: UILabel!
    @IBOutlet var charCount: UILabel!
    @IBOutlet var directionsText: UITextView!
    
    var useRecent = false
    var userRecentText = ""
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
        
        userRecentText = "Not sure where recent text would be saved so saving implementation for later"
        if userRecentText == "" {
            recentDirectionsHeading.isHidden = true
            recentDirectContainer.isHidden = true
            directionsToTop.constant = 75
        } else {
            recentDirectText.text = userRecentText
            recentDirectContainer.layer.cornerRadius = 20
            recentDirectContainer.layer.borderWidth = 2
            recentDirectContainer.layer.borderColor =  UIColor(red: 0.429, green: 0.429, blue: 0.429, alpha: 1).cgColor
            recentDirectButton.layer.cornerRadius = 5
            recentDirectButton.layer.borderWidth = 1
            recentDirectButton.layer.borderColor = UIColor(red: 0.429, green: 0.429, blue: 0.429, alpha: 1).cgColor
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if directions == "" {
            let alert = UIAlertController(title: "Error", message: "Please enter directions to your parking spot.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
}
