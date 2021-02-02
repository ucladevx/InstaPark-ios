//
//  ParkingSpots.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/1/20.
//

import Foundation
//Don't directly instantiate this class, use either Short Term Parking or Long Term Parking
class ParkingSpot: Codable {
    init(id: String, address: Address, coordinates: Coordinate, pricePerHour: Double, provider: String, comments: String, tags: [String], firstName: String, lastName: String, reservations: [String], images: [String]) {
        self.id = id
        self.address = address
        self.coordinates = coordinates
        self.pricePerHour = pricePerHour
        self.provider = provider
        self.comments = comments
        self.tags = tags
        self.firstName = firstName
        self.lastName = lastName
        self.reservations = reservations
        self.images = images
    }
    
    var id: String
    var address: Address
    var coordinates: Coordinate
    var pricePerHour: Double
    var provider: String
    var comments: String
    var tags: [String]
    var images: [String]
    
    //Fields below are properties of provider but stored here to minimize data costs
    var firstName: String
    var lastName: String
    
    //List of IDs for all transactions
    var reservations: [String]
    func validateTimeSlot(startTime: Int, endTime: Int, completion: @escaping(Bool)->Void) {
        completion(true);
    }
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
