//
//  PaymentViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 4/6/21.
//

import UIKit

class PaymentViewController: UIViewController {
    
    @IBOutlet weak var venmoButton: UIButton!
    @IBAction func venmoPayment(_ sender: Any) {
//        let url = URL(string: "venmo://users/60573933")
        let orderCode = generateOrderCode()
        let url = URL(string: "venmo://paycharge?txn=pay&recipients=claireez&amount=10&note=Sparke: Parking for Westwood #"+orderCode)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func generateOrderCode() -> String{
        let allowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = 36
        var orderCode = ""
        for _ in 0 ..< 5 {
            let randomNum = Int(arc4random_uniform(UInt32(allowedCharsCount)))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            orderCode += String(newCharacter)
        }
        return orderCode
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
