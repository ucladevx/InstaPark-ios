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
    
    //Fields below are properties of provider but stored here to minimize data costs
    var firstName: String
    var lastName: String
    
//    init?(data: [String: Any]) {
//        guard let id = data["id"] as? String,
//              let addressObj = data["address"] as? [String: Any],
//              let address = Address(data: addressObj),
//              let startTime = data["startTime"] as? Int,
//
//
//    }
}
struct Address: Codable {
    var city: String
    var state: String
    var street: String
    var zip: String
//    init?(data: [String: Any]) {
//        guard let city = data["city"] as? String,
//              let state = data["state"] as? String,
//              let street = data["street"] as? String,
//              let zip = data["zip"] as? String
//        else {
//            print("Failed init of Address")
//            return nil
//        }
//        self.city = city
//        self.state = state
//        self.street = street
//        self.zip = zip
//    }
}
struct Coordinate: Codable {
    var lat: Double
    var long: Double
}
