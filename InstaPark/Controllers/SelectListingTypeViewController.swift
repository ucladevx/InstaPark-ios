//
//  SelectListingTypeViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 1/20/21.
//

import UIKit

class SelectListingTypeViewController: UIViewController {

    
    @IBAction func monthlyAction(_ sender: Any) {
        performSegue(withIdentifier: "toPage2", sender: nil)
    }
    @IBAction func hourlyAction(_ sender: Any) {
        isHourly = true
        performSegue(withIdentifier: "toPage2", sender: nil)
    }
    @IBAction func CloseButton(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.layer.alpha = 0
            self.InfoView.alpha = 0
        }, completion: {_ in self.InfoView.isHidden = true})
    }
    @IBAction func InfoButton(_ sender: Any) {
        InfoView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {self.layer.alpha = 0.5
            self.InfoView.alpha = 1
        })
        
    }
    
    var isHourly = false
    
    @IBOutlet var monthlyButton: UIButton!
    @IBOutlet var hourlyButton: UIButton!
    @IBOutlet var InfoView: UIView!
    @IBOutlet var layer: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthlyButton.layer.shadowRadius = 3.0
        monthlyButton.layer.shadowOpacity = 0.3
        monthlyButton.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        monthlyButton.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        hourlyButton.layer.shadowRadius = 3.0
        hourlyButton.layer.shadowOpacity = 0.3
        hourlyButton.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        hourlyButton.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

    }
    


}
