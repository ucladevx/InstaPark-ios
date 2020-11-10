//
//  Customer.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/31/20.
//

import Foundation

struct User: Codable {
    var uid: String
    var displayName: String = ""
    var phoneNumber: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var photoURL: String = ""
    var email: String = ""
    var transactions: [String] = [String]()
    var parkingSpots: [String] = [String]()
}
