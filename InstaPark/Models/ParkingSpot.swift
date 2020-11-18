//
//  ParkingSpots.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/1/20.
//

import Foundation
//Don't directly instantiate this class, use either Short Term Parking or Long Term Parking
class ParkingSpot: Codable {
    init(id: String, address: Address, coordinates: Coordinate, pricePerHour: Double, provider: String, comments: String, tags: [String], firstName: String, lastName: String, lastEndTime: Int) {
        self.id = id
        self.address = address
        self.coordinates = coordinates
        self.pricePerHour = pricePerHour
        self.provider = provider
        self.comments = comments
        self.tags = tags
        self.firstName = firstName
        self.lastName = lastName
        self.lastEndTime = lastEndTime
    }
    
    var id: String
    var address: Address
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

extension ParkingSpot {
    var isAvailable: Bool {
        return lastEndTime < Int(NSDate.now.timeIntervalSince1970)
    }
}
