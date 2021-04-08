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
    var paymentCompleted = false
    @IBAction func venmoPayment(_ sender: Any) {
//        let url = URL(string: "venmo://users/60573933")
        orderCode = generateOrderCode()
        let url = URL(string: "venmo://paycharge?txn=pay&recipients=claireez&amount=10&note=Sparke: Parking for Westwood #"+orderCode!)
        UIApplication.shared.open(url!, options: [:], completionHandler: doVerificationProcess)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func doVerificationProcess(success: Bool) {
        if(success) {
            while(!paymentCompleted) {
                let seconds = 4.0
                DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + seconds) {
                    self.sendVerificationRequest()
                }
            }
        }
    }
    func sendVerificationRequest() {
        if let transaction = transaction {
            let requestURL = URL(string: "http://localhost:3000/validatePayment")
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
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: request) {(data, response, error) in
                if let data = data {
                    print(data)
                }
            }
        }
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
