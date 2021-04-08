//
//  UserService.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/5/20.
//

import Foundation
import Firebase
class UserService {
    static let db = Firestore.firestore()
    static func getUserById(_ id: String, completion: @escaping(User?,Error?)->Void) {
        let docRef = db.collection("User").document(id)
        print(id)
        docRef.getDocument() { document, error in
            if let error = error {
                completion(nil, error)
                return
            }else {
                if let document = document {
                    if let user = try? User.init(from: document.data()!) {
                        completion(user, nil)
                    }
                }
            }
        }
    }
    static func updateUserInfo(id: String, changedData: [String:String]) {
        let docRef = db.collection("User").document(id)
        for (key, data) in changedData {
            docRef.updateData([key: data])
            print("updated key: \(key) to \(data)")
        }
    }
    static func saveListingToUser(uid: String, spotID: String) {
        db.collection("User").document(uid).updateData(["parkingSpots": FieldValue.arrayUnion([spotID])])
    }
}
