//
//  TransactionService.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/5/20.
//

import Foundation
import Firebase
class TransactionService {
    static let db = Firestore.firestore()
    static func getTransactionById(_ id: String, completion: @escaping(Transaction?,Error?)->Void) {
        let docRef = db.collection("Transaction").document(id)
        print(id)
        docRef.getDocument() { document, error in
            if let error = error {
                completion(nil, error)
                return
            }else {
                if let document = document {
                    if let transaction = try? Transaction.init(from: document.data()!) {
                        completion(transaction, nil)
                    }
                }
            }
        }
    }
    static func getTransactionsByIds(_ ids: [String], completion: @escaping([Transaction]?, Error?)->Void) {
        print("Getting transactions by ids")
        var transactions = [Transaction]()
        print(ids)
        for s in ids {
            let docRef = db.collection("Transaction").document(s)
            docRef.getDocument() {document, error in
                if let error = error {
                    completion(nil, error)
                    return
                } else {
                    if let document = document {
                        if let transaction = try? Transaction.init(from: document.data()!) {
                            print("Found transaction")
                            transactions.append(transaction)
                        }
                    }
                }
            }
        }
        completion(transactions, nil)
        return
    }
    
    //TODO - saveTransaction
    static func saveTransaction(customer: String, provider: String, startTime: Int, endTime: Int, address: Address, spot: ParkingSpot) {
        if let user = Auth.auth().currentUser {
            print(user.uid)
            let docRef = db.collection("Transaction").document()
            let transaction = Transaction(id: docRef.documentID, customer: customer, startTime: startTime, endTime: endTime, address: address, fromParkingSpot: spot)
            docRef.setData(transaction.dictionary)
            db.collection("User").document(user.uid).updateData(["transactions": FieldValue.arrayUnion([transaction.id])])
        }
        
    }
    
}
