//
//  PaymentViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 4/6/21.
//

import UIKit

class PaymentViewController: UIViewController {
    @IBOutlet weak var venmoButton: UIButton!
    var orderCode: String?
    var transaction: Transaction?
    var paymentOngoing = false
    @IBAction func venmoPayment(_ sender: Any) {
        orderCode = generateOrderCode()
        print("Order Code: \(orderCode!)")
        let urlString = "venmo://paycharge?txn=pay&recipients=Tony-Jiang-16&amount=0.01&note=Sparke:Parking%20for%20Westwood%20%23\(orderCode!)"
        let url = URL(string: urlString)
        UIApplication.shared.open(url!, options: [:]) { success in
            if(success) {
                self.paymentOngoing = true;
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    @objc func viewDidBecomeActive() {
        if(paymentOngoing) {
            print("Return to app while payment ongoing")
            sendVerificationRequest();
        }
    }
    func sendVerificationRequest() {
        if let transaction = transaction {
            let requestURL = URL(string: "https://salty-river-57707.herokuapp.com:3000/validatePayment")
            print(requestURL)
            var request = URLRequest(url: requestURL!)
            let body: [String:Any] = [
                "orderCode": orderCode,
                "amount": transaction.total,
                "providerId": transaction.provider,
                "customerId": transaction.customer
            ]
            let jsonData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: request) {(data, response, error) in
                self.paymentOngoing = false
                if let data = data {
                    print("VERIFACATION BACK!")
                    print(data)
                } else {
                    print(error);
                }
            }
        } else {
            print("Transaction is nil")
        }
    }
    func generateOrderCode() -> String {
        let allowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = 36
        var code = ""
        for _ in 0 ..< 8 {
            let randomNum = Int(arc4random_uniform(UInt32(allowedCharsCount)))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            code += String(newCharacter)
        }
        return code
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
