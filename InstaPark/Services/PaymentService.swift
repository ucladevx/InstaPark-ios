//
//  PaymentService.swift
//  InstaPark
//
//  Created by Tony Jiang on 1/11/21.
//

import Foundation
class PaymentService {
    enum PaymentError {
        case error(String)
        func errorMessage() -> String {
            switch(self) {
            case .error(let str):
                return str;
            }
            
        }
    }
    struct PaymentResponse : Decodable {
        let success: Bool
        let error_message: String
    }
    struct VenmoResponse: Decodable {
        let success: Bool
    }
    static func savePaymentToDatabase(providerId: String, customerId: String, transactionId: String) {
        let url = URL(string: "https://salty-river-57707.herokuapp.com/savePayment")!
        var request = URLRequest(url: url)
        let body: [String:Any] = ["providerId": providerId, "customerId": customerId, transactionId: transactionId]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData;
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    static func postNonceToServer(paymentMethodNonce: String, transactionAmount: Double, completion: @escaping(PaymentError?)->Void) {
        let paymentURL = URL(string: "https://salty-river-57707.herokuapp.com/checkout")!
        var request = URLRequest(url: paymentURL)
        let body: [String: Any] = ["payment_method_nonce": paymentMethodNonce, "amount": transactionAmount]
//        let body = "payment_method_nonce=\(paymentMethodNonce)&amount=\(transactionAmount)"
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            var paymentResponse: PaymentResponse?
            if let data = data {
                paymentResponse = try? JSONDecoder().decode(PaymentResponse.self, from: data)
                if let paymentResponse = paymentResponse {
                    if paymentResponse.success {
                        completion(nil)
                    } else {
                        completion(.error(paymentResponse.error_message))
                    }
                    return;
                }
            }
            completion(.error("Error"))
            // TODO: Handle success or failure
        }.resume()
    }
    static func testGet() {
        print("Test Get")
        let requestURL = URL(string: "https://salty-river-57707.herokuapp.com/test")!
        var request = URLRequest(url:requestURL)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            print(data)
            print(response)
            print(error)
        }.resume()
    }
    static func validatePayment(transaction: Transaction, orderCode: String, completion: @escaping(Bool)->Void) {
//        let requestURL = URL(string: "https://salty-river-57707.herokuapp.com/validatePayment")!
        let requestURL = URL(string: "https://salty-river-57707.herokuapp.com/validatePayment")!
        var request = URLRequest(url: requestURL)
        let body: [String: Any] = ["orderCode": orderCode,
                                   "amount": transaction.total,
                                   "providerId": transaction.provider,
                                   "customerId": transaction.customer,
                                   "parkingSpotId": transaction.parkingSpot]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("Do post request")
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let data = data {
                print("VERIFACATION BACK!")
                let decoder = JSONDecoder()
                let res = try! decoder.decode(VenmoResponse.self, from: data)
                completion(res.success)
            } else {
                print(error);
                completion(false);
            }
        }.resume()
    }
}

