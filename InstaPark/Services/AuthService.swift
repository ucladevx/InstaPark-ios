//
//  AuthService.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/27/20.
//

import Foundation
import FirebaseAuth
class AuthService {
    enum AuthenticationError: Error {
        case invalidEmail
        case emailInUse
        case passwordMatch
        case error
    }
    static func validateInput(email: String, password1: String, password2: String) -> AuthenticationError?{
        if(password1 != password2){
            return .passwordMatch
        }
        return nil;
    }
    static func signup(email: String, password1: String, password2: String, completion: @escaping (AuthDataResult?, AuthenticationError?) -> Void){
        if let error = validateInput(email: email, password1: password1, password2: password2) {
            completion(nil, error)
        }
        Auth.auth().createUser(withEmail: email, password: password1) { authResult, error in
            if let error = error as NSError?{
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    var firebaseError: AuthenticationError
                    switch errorCode {
                    case .invalidEmail:
                        firebaseError = .invalidEmail
                    case .emailAlreadyInUse:
                        firebaseError = .emailInUse
                    default:
                        firebaseError = .error
                    }
                    completion(nil, firebaseError)
                }
                //No specific firebase error
                completion(nil, .error)
                return;
            } else {
                completion(authResult, nil)
            }
        }
    }
    static func login() {
        
    }
}
