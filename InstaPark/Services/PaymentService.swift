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
    static func postNonceToServer(paymentMethodNonce: String, transactionAmount: Double, completion: @escaping(PaymentError?)->Void) {
        let paymentURL = URL(string: "http://localhost:3000/checkout")!
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
}

