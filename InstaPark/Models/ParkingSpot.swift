//
//  ParkingSpots.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/1/20.
//

import Foundation

struct ParkingSpot: Codable {
    var id: String
    var address: Address
    var startTime: Int
    var endTime: Int
    var coordinates: Coordinate
    var isAvailable: Bool
    var pricePerHour: Double
    var provider: String
}
struct Address: Codable {
    var city: String
    var state: String
    var street: String
    var zip: String
}
struct Coordinate: Codable {
    var lat: Double
    var long: Double
}
