//
//  ParkingTypeViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 1/28/21.
//

import UIKit

class ParkingTypeViewController: UIViewController {

    var parkingType: ParkingType = .short
    var ShortTermParking: ShortTermParkingSpot!
    //var LongTermParking : LongTermParkingSpot!
    
    @IBAction func featureAction(_ sender: UIButton) {
        if sender.backgroundColor != .clear {
            sender.backgroundColor = .clear
            sender.layer.borderWidth = 0.5
            sender.setImage(nil, for: .normal)
            chosenFeatures.remove(at: chosenFeatures.lastIndex(of:features[sender.tag])!)
        } else {
            sender.backgroundColor = UIColor(red: 183/255, green: 91/255, blue: 1, alpha: 1)
            sender.layer.borderWidth = 0
            sender.setImage(UIImage(named: "check"), for: .normal)
            chosenFeatures.append(features[sender.tag])
        }
        print(chosenFeatures)
    }
    @IBAction func typeAction(_ sender: UIButton) {
        if sender.backgroundColor != .clear {
            sender.backgroundColor = .clear
            sender.setTitleColor(UIColor(red: 0.429, green: 0.429, blue: 0.429, alpha: 1), for: .normal)
            sender.layer.borderWidth = 2
            chosenTypes.remove(at: chosenTypes.lastIndex(of:types[sender.tag])!)
        } else {
            sender.backgroundColor = UIColor(red: 183/255, green: 91/255, blue: 1, alpha: 1)
            sender.setTitleColor(.white, for: .normal)
            sender.layer.borderWidth = 0
            chosenTypes.append(types[sender.tag])
        }
        print(chosenTypes)
    }
    
    @IBAction func infoButton(_ sender: Any) {
        ParkingType.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {self.content.alpha = 0.5
            self.ParkingType.alpha = 1
        })
    }
    @IBAction func closeButton(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.content.alpha = 1
            self.ParkingType.alpha = 0
        }, completion: {_ in self.ParkingType.isHidden = true})
    }
    
    @IBOutlet var drivewayInfo: UILabel!
    @IBOutlet var GarageInfo: UILabel!
    @IBOutlet var StreetInfo: UILabel!
    @IBOutlet var LotInfo: UILabel!
    @IBOutlet var ParkingType: ParkingTypeView!
    @IBOutlet var content: UIView!
    
    @IBOutlet var typeButtons: [UIButton]!
    @IBOutlet var featureButtons: [UIButton]!
    
    //Selected types/features will be in chosenFeatures/Types, a string array
    
    let types = ["Driveway","Garage", "Street", "Lot"] //index and button tags are related
    var chosenTypes = [String]()
    
    let features = ["Tandem","Well-lit","Gated","Covered", "Security on-site",
    "Wheelchair accessible", "Cellular service available", "Underground"] //index and button tags are related
    var chosenFeatures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(ShortTermParking.pricePerHour)
        //Runtime attributes must be done here b/c borderColor doesn't work on Storyboard
        for i in typeButtons {
        i.layer.cornerRadius = 10
        i.layer.borderWidth = 1
            i.layer.borderColor = UIColor(red: 0.77, green: 0.77, blue: 0.77, alpha: 1).cgColor
        }
        for i in featureButtons {
        i.layer.cornerRadius = 3
            i.layer.borderWidth = 0.5
        i.layer.borderColor = UIColor(red: 0.429, green: 0.429, blue: 0.429, alpha: 1).cgColor
        }
        
        self.view.addSubview(ParkingType)
        ParkingType.isHidden = true
        ParkingType.alpha = 0
        ParkingType.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ParkingType.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        //Must declare info text here because bolding partial text in storyboard doesn't work
        let attrs_b = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 12)]
        let attrs = [NSAttributedString.Key.font : UIFont(name: "OpenSans-Regular", size: 12)]
        
        var bold = "Driveway parking"
        var text = " is parking within a driveway, usually close to the sidewalk and uncovered."
        var attributed = NSMutableAttributedString(string:text, attributes:attrs as [NSAttributedString.Key : Any])
        var attributed_b = NSMutableAttributedString(string:bold, attributes: attrs_b as [NSAttributedString.Key : Any])
        attributed_b.append(attributed)
        drivewayInfo.attributedText = attributed_b
        
        bold = "Garage parking"
        text = " is a structure or building dedicated to parking vehicles, usually with multiple levels."
        attributed = NSMutableAttributedString(string:text, attributes:attrs as [NSAttributedString.Key : Any])
        attributed_b = NSMutableAttributedString(string:bold, attributes: attrs_b as [NSAttributedString.Key : Any])
        attributed_b.append(attributed)
        GarageInfo.attributedText = attributed_b
        
        bold = "Street parking"
        text = " is areas close to the curb of the streets reserved for parking."
        attributed = NSMutableAttributedString(string:text, attributes:attrs as [NSAttributedString.Key : Any])
        attributed_b = NSMutableAttributedString(string:bold, attributes: attrs_b as [NSAttributedString.Key : Any])
        attributed_b.append(attributed)
        StreetInfo.attributedText = attributed_b
        
        bold = "Lot parking"
        text = " is usually flat, uncovered areas on the ground level."
        attributed = NSMutableAttributedString(string:text, attributes:attrs as [NSAttributedString.Key : Any])
        attributed_b = NSMutableAttributedString(string:bold, attributes: attrs_b as [NSAttributedString.Key : Any])
        attributed_b.append(attributed)
        LotInfo.attributedText = attributed_b
    }
    
    func checkBeforeMovingPages() -> Bool {
        if chosenTypes.count == 0 && chosenFeatures.count == 0 {
            let alert = UIAlertController(title: "Error", message: "Please select at least one parking tag for your spot.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        var tags = [String]()
        tags.append(contentsOf: chosenTypes)
        tags.append(contentsOf: chosenFeatures)
        ShortTermParking.tags = tags
        return true
    }
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if chosenTypes.count == 0 && chosenFeatures.count == 0 {
            let alert = UIAlertController(title: "Error", message: "Please select at least one parking type or feature for your spot.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }*/
}
