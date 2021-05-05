//
//  ReservationConfirmationViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 11/20/20.
//

import UIKit

class ReservationConfirmationViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var parkLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    var listing = false // only true if new listing is created
    
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var segueToMyReservations: UIButton!
    @IBAction func segueToMyReservations(_ sender: Any) {
        weak var pvc = self.presentingViewController
        weak var pvcpvc = pvc?.presentingViewController
        if listing {
            self.dismiss(animated: false) {
                pvc?.dismiss(animated: false) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "MyListingsVC") as MyListingsTableViewController
                    (pvcpvc as? UINavigationController)?.pushViewController(vc, animated: true)
                }
            };
        } else {
            self.view.window?.rootViewController?.dismiss(animated: true) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "MyReservationsVC") as TransactionTableViewController
                self.present(vc, animated: true)
            }
            
        }
    }
    @IBAction func returnToHome(_ sender: Any) {
        weak var pvc = self.presentingViewController
        weak var pvcpvc = pvc?.presentingViewController
        weak var pvcpvcpvc = pvcpvc?.presentingViewController
        print(String(describing: pvc.self))
        print(String(describing: pvcpvc.self))
        if listing {
            self.dismiss(animated: true) {
                pvc?.dismiss(animated: true) {
//                    pvcpvc?.dismiss(animated: true) {
//                        pvcpvcpvc?.dismiss(animated: true) {
//
//                        }
//                    }
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "MapViewVC") as MapViewViewController
                    (pvcpvc as? UINavigationController)?.pushViewController(vc, animated: true)
                }
//                pvcpvc?.performSegue(withIdentifier: "segueToMapView", sender: nil)
            };
            
        } else {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    var time = ""
    var date = ""
    var address = ""
    var phoneNumber = ""
    var fullName = ""
    @objc
    func tapContactLabel(sender: UITapGestureRecognizer) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if listing {
            contactLabel.text=""
            parkLabel.text = "Your listing is up!"
            instructionsLabel.text = "Your listing is live for buyers to view!\nYou'll get a notification if anyone purchases your spot."
            segueToMyReservations.setTitle("My Listings", for: .normal)
        } else {
            let contact = attributedInfoRegular(string: "Please contact ", fontSize: 14)
            contact.append(attributedInfoBold(string: "\(fullName) at \(format(phoneNumber: phoneNumber) ?? phoneNumber)", fontSize: 14))
            contact.append(attributedInfoRegular(string: " for parking instructions/payment", fontSize: 14))
            contactLabel.attributedText = contact
            let contactTap = UITapGestureRecognizer(target: self, action: #selector(tapContactLabel))
            contactLabel.isUserInteractionEnabled = true
            contactLabel.addGestureRecognizer(contactTap)
            let instructions = attributedInfoRegular(string: "Your reservation has been saved. Check the ", fontSize: 14)
            instructions.append(attributedInfoBold(string: "My Reservations", fontSize: 14))
            instructions.append(attributedInfoRegular(string: " tab for additional details regarding your reservation.", fontSize: 14))
            instructionsLabel.attributedText = instructions
            segueToMyReservations.setTitle("My Reservations", for: .normal)
        }
        infoLabel.font = UIFont(name: "OpenSans-Regular", size: 14)
//        timeLabel.text = time
//        addressLabel.text = address
        infoLabel.font = UIFont(name: "OpenSans-Regular", size: 16)
        
        let info = attributedInfoBold(string: "Date: ", fontSize: 16)
        info.append(attributedInfoRegular(string: date + "\n", fontSize: 16))
        info.append(attributedInfoBold(string: "Time: ", fontSize: 16))
        info.append(attributedInfoRegular(string: time + "\n", fontSize: 16))
        info.append(attributedInfoBold(string: "Address: ", fontSize: 16))
        info.append(attributedInfoRegular(string: address, fontSize: 16))
        
        infoLabel.attributedText = info
        
        infoView.layer.shadowRadius = 10
        infoView.layer.shadowColor = CGColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        infoView.layer.shadowOpacity = 0.2
        infoView.layer.shadowOffset = .init(width: 5, height: 5)
        parkLabel?.font = UIFont(name: "OpenSans-Bold", size: 26)
        parkLabel?.textColor = .black
        infoView.layer.cornerRadius = 32
        
        // Do any additional setup after loading the view.
    }
    
    func attributedInfoBold(string: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs = [NSAttributedString.Key.font :  UIFont.init(name: "OpenSans-SemiBold", size: fontSize)]
        let attr = NSMutableAttributedString(string: string, attributes:attrs as [NSAttributedString.Key : Any])
        return attr
    }
    
    func attributedInfoRegular(string: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs = [NSAttributedString.Key.font :  UIFont.init(name: "OpenSans-Regular", size: fontSize)]
        let attr = NSMutableAttributedString(string: string, attributes:attrs as [NSAttributedString.Key : Any])
        return attr
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func format(phoneNumber sourcePhoneNumber: String) -> String? {
        // Remove any character that is not a number
        let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = numbersOnly.count
        let hasLeadingOne = numbersOnly.hasPrefix("1")

        // Check for supported phone number length
        guard length == 7 || (length == 10 && !hasLeadingOne) || (length == 11 && hasLeadingOne) else {
            return nil
        }

        let hasAreaCode = (length >= 10)
        var sourceIndex = 0

        // Leading 1
        var leadingOne = ""
        if hasLeadingOne {
            leadingOne = "1 "
            sourceIndex += 1
        }

        // Area code
        var areaCode = ""
        if hasAreaCode {
            let areaCodeLength = 3
            guard let areaCodeSubstring = numbersOnly.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
                return nil
            }
            areaCode = String(format: "(%@) ", areaCodeSubstring)
            sourceIndex += areaCodeLength
        }

        // Prefix, 3 characters
        let prefixLength = 3
        guard let prefix = numbersOnly.substring(start: sourceIndex, offsetBy: prefixLength) else {
            return nil
        }
        sourceIndex += prefixLength

        // Suffix, 4 characters
        let suffixLength = 4
        guard let suffix = numbersOnly.substring(start: sourceIndex, offsetBy: suffixLength) else {
            return nil
        }

        return leadingOne + areaCode + prefix + "-" + suffix
    }
}
extension String {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }

        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }

        return String(self[substringStartIndex ..< substringEndIndex])
    }
}
