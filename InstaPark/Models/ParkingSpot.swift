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
    
    var times: [ParkingTimeInterval] // Stores list of time intervals
                                     // Query date
//    var times: [String: [ParkingTimeInterval]] // Key - "11-16-20"
    var coordinates: Coordinate
    var pricePerHour: Double
    var provider: String
    var comments: String
    var tags: [String]
    
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
struct ParkingTimeInterval: Codable {
    //epoch time
    var start: Int
    var end: Int
}
extension ParkingSpot {
    var isAvailable: Bool {
        return lastEndTime < Int(NSDate.now.timeIntervalSince1970)
    }
}
