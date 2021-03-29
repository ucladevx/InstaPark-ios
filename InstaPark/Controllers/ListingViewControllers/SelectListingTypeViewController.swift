//
//  SelectListingTypeViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 1/20/21.
//

import UIKit
import Firebase

class SelectListingTypeViewController: UIViewController {
    var parkingType: ParkingType = .long
    let ShortTermParking = ShortTermParkingSpot.init(id: "", address: Address.blankAddress(), coordinates: Coordinate(lat: 0.0, long: 0.0), pricePerHour: 0.0, provider: "", comments: "", tags: [String](),reservations: [String](), fromFullDays: [Int](), images: [String](), startDate: 0, endDate: 0, directions: "", selfParking: SelfParking.blank())
   
    @IBAction func monthlyAction(_ sender: Any) {
        //do the same as short term parking here but with long term parking if clicked
        parkingType = .long
        performSegue(withIdentifier: "toListing1", sender: nil)
    }
    @IBAction func hourlyAction(_ sender: Any) {
        isHourly = true
        parkingType = .short
        performSegue(withIdentifier: "toListing1", sender: nil)
    }
    @IBAction func CloseButton(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.content.alpha = 1
            self.ParkingInfo.alpha = 0
        }, completion: {_ in self.ParkingInfo.isHidden = true})
    }
    @IBAction func InfoButton(_ sender: Any) {
        ParkingInfo.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {self.content.alpha = 0.5
            self.ParkingInfo.alpha = 1
        })
        
    }
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
    }
    
    var isHourly = false
    
    @IBOutlet var monthlyButton: UIButton!
    @IBOutlet var hourlyButton: UIButton!
    @IBOutlet var content: UIView!
    @IBOutlet var ParkingInfo: ParkingInfoView!
    @IBOutlet var hourlyParking: UILabel!
    @IBOutlet var monthlyParking: UILabel!
    @IBAction func backButton(_ sender: Any) {
        print("pressed back button")
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(ParkingInfo)
        navigationController?.setNavigationBarHidden(true, animated: false)
        ParkingInfo.isHidden = true
        ParkingInfo.alpha = 0
        ParkingInfo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ParkingInfo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        monthlyButton.layer.shadowRadius = 3.0
        monthlyButton.backgroundColor = .white
        hourlyButton.backgroundColor = .white
        monthlyButton.layer.shadowOpacity = 0.3
        monthlyButton.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        monthlyButton.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        hourlyButton.layer.shadowRadius = 3.0
        hourlyButton.layer.shadowOpacity = 0.3
        hourlyButton.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        hourlyButton.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let buttons = [monthlyButton, hourlyButton]
        for button in buttons {
            let gradient = CAGradientLayer()
            gradient.frame =  CGRect(origin: CGPoint.zero, size: button!.frame.size)
            gradient.colors = [UIColor.init(red: 143.0/255, green: 0.0, blue: 1.0, alpha: 1.0).cgColor, UIColor.init(red: 183/255, green: 91/255, blue: 1.0, alpha: 1.0).cgColor, UIColor.init(red: 97/255, green: 0.0, blue: 1.0, alpha: 1.0).cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            
            let shape = CAShapeLayer()
            shape.lineWidth = 2
            shape.path = UIBezierPath(roundedRect: button!.bounds, cornerRadius: button!.layer.cornerRadius).cgPath
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = UIColor.clear.cgColor
            gradient.mask = shape
            
            button!.layer.addSublayer(gradient)
        }
        
        //self.monthlyButton.layer.borderColor.insertSublayer
        //Must declare info text here because bolding partial text in storyboard doesn't work
        let attrs_b = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 12)]
        let attrs = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Regular", size: 12)]
        
        let h_bold = "Hourly Parking"
        let h_text = " means other buyers will rent your parking spot for hours at a time."
        let h_attributed = NSMutableAttributedString(string:h_text, attributes:attrs as [NSAttributedString.Key : Any])
        let h_attributed_b = NSMutableAttributedString(string: h_bold, attributes: attrs_b as [NSAttributedString.Key : Any])
        h_attributed_b.append(h_attributed)
        hourlyParking.attributedText = h_attributed_b
        
        let m_bold = "Monthly Parking"
        let m_text = " means other buyers will rent your parking spot for months at a time."
        let m_attributed = NSMutableAttributedString(string:m_text, attributes:attrs as [NSAttributedString.Key : Any])
        let m_attributed_b = NSMutableAttributedString(string: m_bold, attributes: attrs_b as [NSAttributedString.Key : Any])
        m_attributed_b.append(m_attributed)
        monthlyParking.attributedText = m_attributed_b
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ListingViewController {
            vc.parkingType = parkingType
            if(parkingType == .short) {
                self.ShortTermParking.provider = Auth.auth().currentUser!.uid
                vc.ShortTermParking = ShortTermParking
            } else {
                // pass in long term parking when ready 
            }
        }
    }
    
}
