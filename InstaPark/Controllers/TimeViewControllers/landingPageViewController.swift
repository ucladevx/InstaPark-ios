//
//  landingPageViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 1/12/21.
//

import UIKit

class landingPageViewController: UIViewController {

    @IBOutlet weak var hourlyButton: UIButton!
    @IBOutlet weak var monthlyButton: UIButton!
    @IBOutlet weak var hourlyView: UIView!
    @IBOutlet weak var montlyView: UIView!
    @IBOutlet weak var showAllButton: UIButton!
    @IBOutlet var backgroundView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        // add shadows
        hourlyView.layer.shadowRadius = 3.0
        hourlyView.layer.shadowOpacity = 0.3
        hourlyView.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        hourlyView.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        montlyView.layer.shadowRadius = 3.0
        montlyView.layer.shadowOpacity = 0.3
        montlyView.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        montlyView.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        showAllButton.layer.shadowRadius = 3.0
        showAllButton.layer.shadowOpacity = 0.3
        showAllButton.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        showAllButton.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

        //gradient
        let layer = CAGradientLayer()
        layer.frame = self.backgroundView.frame
        layer.colors = [UIColor.init(red: 0.561, green: 0.0, blue: 1.0, alpha: 1.0).cgColor, UIColor.init(red: 0.129, green: 0.588, blue: 0.953, alpha: 1.0).cgColor, UIColor.init(red: 0.718, green: 0.357, blue: 1.0, alpha: 1.0).cgColor]
        layer.startPoint = CGPoint(x: 1, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.cornerRadius = 15
        self.backgroundView.layer.insertSublayer(layer, at: 0)
        
        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showAllAvailableSpotsSegue") {
            if let destination = segue.destination as? MapViewViewController {
                var now = Date()
                destination.shortTermStartTime = now
                destination.shortTermEndTime = Date(timeInterval: TimeInterval(3600), since: now)
                destination.shortTermDate = Date()
            }
        }
    }
    @IBAction func hourlyButton(_ sender: Any) {
    }
    
    @IBAction func monthlyButton(_ sender: Any) {
    }
    @IBAction func showAllButton(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
