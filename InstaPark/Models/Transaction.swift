//
//  Transaction.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/1/20.
//

import Foundation
struct Transaction: Codable {
    var id: String
    var customer: String
    var provider: String
    var parkingSpot: String
    var startTime: Int
    var endTime: Int
    var priceRatePerHour: Double
    var total: Double
    var address: Address
    init(id: String, customer: String, startTime: Int, endTime: Int, address: Address, fromParkingSpot parkingSpot: ParkingSpot) {
        self.id = id
        self.customer = customer
        self.startTime = startTime
        self.endTime = endTime
        self.parkingSpot = parkingSpot.id
        self.provider = parkingSpot.provider
        self.priceRatePerHour = parkingSpot.pricePerHour
        self.total = parkingSpot.pricePerHour * Double((endTime - startTime))/3600
        self.address = address
    }
}
