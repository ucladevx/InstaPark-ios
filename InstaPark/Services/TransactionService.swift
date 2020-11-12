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
        var transactions = [Transaction]()
        for s in ids {
            let docRef = db.collection("Transaction").document(s)
            docRef.getDocument() {document, error in
                if let error = error {
                    completion(nil, error)
                    return
                } else {
                    if let document = document {
                        if let transaction = try? Transaction.init(from: document.data()!) {
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
}
