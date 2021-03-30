//
//  HelpViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 3/18/21.
//

import UIKit
import MessageUI

class HelpViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var sparkeLogo: UILabel!
    @IBOutlet weak var emailView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //sparke logo
        func gradientColor(bounds: CGRect, gradientLayer :CAGradientLayer) -> UIColor? {
              UIGraphicsBeginImageContext(gradientLayer.bounds.size)
              gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
              let image = UIGraphicsGetImageFromCurrentImageContext()
              UIGraphicsEndImageContext()
              return UIColor(patternImage: image!)
        }
        func getGradientLayer(bounds : CGRect) -> CAGradientLayer{
            let gradient = CAGradientLayer()
            gradient.frame = bounds
            gradient.colors = [UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0).cgColor, UIColor.init(red: 0.561, green: 0.0, blue: 1.0, alpha: 1.0).cgColor]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            return gradient
        }
        let gradient = getGradientLayer(bounds: sparkeLogo.bounds)
        sparkeLogo.textColor = gradientColor(bounds: sparkeLogo.bounds, gradientLayer: gradient)
        sparkeLogo.font = UIFont(name: "ProximaNova-Bold", size: 36)
        
        //emailView
        emailView.layer.shadowRadius = 5.0
        emailView.layer.shadowOpacity = 0.25
        emailView.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        emailView.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let emailTap = UITapGestureRecognizer(target:self, action: #selector(self.email(_:)))
        self.emailView.isUserInteractionEnabled = true
        self.emailView.addGestureRecognizer(emailTap)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc func email(_ send: UITapGestureRecognizer) {
        print("email")
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            vc.setSubject("User Feedback")
            vc.setToRecipients(["sparkeapp@gmail.com"])
            present(vc, animated: true)
        } else {
            print("fail")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
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
