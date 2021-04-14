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
        if(ids.count == 0) {
            completion(transactions, nil)
            return
        }
        let query = db.collection("Transaction").whereField("id", in: ids).getDocuments() { querySnapshot, err in
            if let err = err {
                completion(nil, err)
            } else {
                for document in querySnapshot!.documents {
                    print(document.data())
                    let transaction = try? Transaction.init(from: document.data());
                    if let transaction = transaction {
                        transactions.append(transaction)
                    }
                }
                completion(transactions,nil)
            }
            
        }
    }
    
    //TODO - saveTransaction
    static func saveTransaction(customer: String, provider: String, startTime: Int, endTime: Int, address: Address, spot: ParkingSpot) {
        if let user = Auth.auth().currentUser {
            print(user.uid)
            let docRef = db.collection("Transaction").document()
            let transaction = Transaction(id: docRef.documentID, customer: customer, startTime: startTime, endTime: endTime, fromParkingSpot: spot)
            docRef.setData(transaction.dictionary)
            db.collection("User").document(user.uid).updateData(["transactions": FieldValue.arrayUnion([transaction.id])])
            print("Transaction information: ")
            print("Parking Spot ID " + spot.id)
            print("Transaction ID " + transaction.id)
            db.collection(ParkingSpotService.parkingDBName).document(spot.id).updateData(["super.reservations": FieldValue.arrayUnion([docRef.documentID])])
        }
        
    }
    static func saveTransactionObject(transaction: Transaction) {
        var newTransaction = transaction;
        if let user = Auth.auth().currentUser {
            newTransaction.customer = user.uid;
            let docRef = db.collection("Transaction").document()
            newTransaction.id = docRef.documentID
            docRef.setData(newTransaction.dictionary)
            db.collection("User").document(user.uid).updateData(["transactions": FieldValue.arrayUnion([newTransaction.id])])
            print("Transaction information: ")
            print("Transaction ID " + newTransaction.id)
            db.collection(ParkingSpotService.parkingDBName).document(newTransaction.parkingSpot).updateData(["super.reservations": FieldValue.arrayUnion([docRef.documentID])])
        }
    }
}
