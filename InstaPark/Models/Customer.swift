//
//  Customer.swift
//  InstaPark
//
//  Created by Tony Jiang on 10/31/20.
//

import Foundation

struct Customer: Codable {
    var uid: String
    var displayName: String = ""
    var phoneNumber: String = ""
    var transactions: [String] = [String]()
}
