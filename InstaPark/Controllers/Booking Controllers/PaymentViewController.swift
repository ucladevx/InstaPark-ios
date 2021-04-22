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
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var paymentLoadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var processingPaymentLabel: UILabel!
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated:true)
    }
    @IBAction func venmoPayment(_ sender: Any) {
        orderCode = generateOrderCode()
        print("Order Code: \(orderCode!)")
//        let urlString = "venmo://paycharge?txn=pay&recipients=Tony-Jiang-16&amount=\(transaction!.total)&note=Sparke:Parking%20for%20Westwood%20%23\(orderCode!)"
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
        paymentLoadingSpinner.hidesWhenStopped = true
        paymentLoadingSpinner.stopAnimating()
        processingPaymentLabel.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    @objc func viewDidBecomeActive() {
        if(paymentOngoing) {
            paymentLoadingSpinner.startAnimating()
            processingPaymentLabel.isHidden = false
            print("Return to app while payment ongoing")
            sendVerificationRequest();
        }
    }
    func sendVerificationRequest() {
        if let transaction = transaction {
            PaymentService.validatePayment(transaction: transaction, orderCode: orderCode ?? "") { success in
                DispatchQueue.main.async {
                    self.paymentLoadingSpinner.stopAnimating()
                    self.processingPaymentLabel.isHidden = true
                }
                
                if(success) {
                    self.paymentOngoing = false
                    print("Payment Successful")
                    
                    //DO PAYMENT GOOD POPUP
                    TransactionService.saveTransactionObject(transaction: transaction)
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Payment Approved!", message: "You will be redirected to your parking confirmation page", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title:"Continue", style: .default, handler: self.confirmAction))
                        alert.addAction(UIAlertAction(title:"Report a Problem", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    }
                    
                } else {
                    print("Payment Failed, please try again")
                    //DO PAYMENT FAILED POPUP
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Payment Failed", message: "If did pay and this is an error, press Report a Problem. Otherwise, press continue and pay using venmo or cancel your order.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title:"Continue", style: .default, handler: nil))
                        alert.addAction(UIAlertAction(title:"Report a Problem", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
        } else {
            print("Transaction is nil")
        }
    }
    func confirmAction(action: UIAlertAction) {
        weak var pvc = self.presentingViewController
        self.dismiss(animated: true) {
            pvc?.performSegue(withIdentifier: "showReservationConfirmation", sender: pvc)
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
