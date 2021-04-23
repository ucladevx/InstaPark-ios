//
//  AuthService.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/27/20.
//

import Foundation
import FirebaseAuth
import Firebase

class AuthService {
    enum AuthenticationError: Error {
        case invalidEmail
        case emailInUse
        case passwordMatch
        case userDisabled
        case incorrectPassword
        case custom(String)
        case error
        func errorString() -> String {
            switch self {
            case .invalidEmail:
                return "The email you entered was invalid."
            case .emailInUse:
                return "The email you entered is already in use."
            case .passwordMatch:
                return "The two passwords do not match."
            case .userDisabled:
                return "Your account has been disabled."
            case .incorrectPassword:
                return "The password you entered is not correct."
            case .custom(let msg):
                return msg
            default:
                return "Error."
            }
        }
    }
    private static func validateInput(email: String, password1: String, password2: String) -> AuthenticationError?{
        if(password1 != password2){
            return .passwordMatch
        }
        return nil;
    }
    
    //signup user with completion
    static func signup(user: User, password1: String, password2: String, completion: @escaping (AuthDataResult?, AuthenticationError?) -> Void){
        if let error = validateInput(email: user.email, password1: password1, password2: password2) {
            completion(nil, error)
        }
        Auth.auth().createUser(withEmail: user.email, password: password1) { authResult, error in
            if let error = error as NSError?{
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    var firebaseError: AuthenticationError
                    switch errorCode {
                    case .invalidEmail:
                        firebaseError = .invalidEmail
                    case .emailAlreadyInUse:
                        firebaseError = .emailInUse
                    default:
                        firebaseError = .custom(error.localizedDescription)
                    }
                    completion(nil, firebaseError)
                }
                //No specific firebase error
                completion(nil, .error)
                return;
            } else if let authResult = authResult{
                createUserDocument(authResult: authResult, user: user)
                completion(authResult, nil)
            }
        }
    }
    
    //login user with completion
    static func login(email: String, password: String, completion: @escaping (AuthDataResult?, AuthenticationError?) -> Void) {
        print("Logging in with firebase.")
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    var firebaseError: AuthenticationError
                    switch errorCode {
                    case .userDisabled:
                        firebaseError = .userDisabled
                    case .wrongPassword:
                        firebaseError = .incorrectPassword
                    case .invalidEmail:
                        firebaseError = .invalidEmail
                    default:
                        firebaseError = .custom(error.localizedDescription)
                    }
                    completion(nil, firebaseError)
                    return;
                }
                completion(nil, .error)
            } else {
                completion(authResult, nil)
            }
        }
    }
    
    //creates user document
    static func createUserDocument(authResult: AuthDataResult, user: User) {
        print("Creating user document")
        if let usr = Auth.auth().currentUser {
            let id = usr.uid
            print(id)
            let usr = authResult.user
            let data = usr.providerData[0]
            let db = Firestore.firestore()
            var cust = user
            cust.uid = id
            if(user.displayName == "" ){
                cust.displayName = data.phoneNumber ?? ""
            }
            if(user.phoneNumber == "" ) {
                cust.phoneNumber = data.phoneNumber ?? ""
            }
            db.collection("User").document(id).setData(user.dictionary)
        } else {
            print("Cannot create user document without signed in user")
        }
       
    }
    
    static func updateEmail(email: String) {
        Auth.auth().currentUser?.updateEmail(to: email) { (error) in
            if error != nil {
                print("email successfully updated")
            } else {
                print("cannot update email")
            }
        }
    }
}
