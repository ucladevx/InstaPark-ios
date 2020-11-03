//
//  Transactions.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/1/20.
//

import Foundation
struct Transactions: Codable {
    var id: String
    var customer: String
    var provider: String
    var startTime: Int
    var endTime: Int
    var priceRatePerHour: Double
    var total: Double
}
