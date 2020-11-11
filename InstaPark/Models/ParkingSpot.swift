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
    //Epoch time of when parking becomes available (set by provider)
    var startTime: Int
    //Epoch time of when parking no longer is available (set by provider)
    var endTime: Int
    var coordinates: Coordinate
    var pricePerHour: Double
    var provider: String
    
    //Fields below are properties of provider but stored here to minimize data costs
    var firstName: String
    var lastName: String
    
    //Epoch time when last order ended
    var lastEndTime: Int
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
extension ParkingSpot {
    var isAvailable: Bool {
        return lastEndTime < Int(NSDate.now.timeIntervalSince1970)
    }
}
