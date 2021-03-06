//
//  ParkingSpots.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/1/20.
//

import Foundation
import Firebase
//Don't directly instantiate this class, use either Short Term Parking or Long Term Parking
class ParkingSpot: Codable {

    init(id: String, address: Address, coordinates: Coordinate, pricePerHour: Double, pricePerDay: Double, dailyPriceEnabled: Bool, provider: String, comments: String, tags: [String], reservations: [String], images: [String], startDate: Int, endDate: Int, directions: String, selfParking: SelfParking, approvedReservations: [String]) {
        self.id = id
        self.address = address
        self.coordinates = coordinates
        self.pricePerHour = pricePerHour
        self.provider = provider
        self.comments = comments
        self.tags = tags
        self.startDate = startDate
        self.endDate = endDate
        self.reservations = reservations
        self.images = images
        self.directions = directions
        self.selfParking = selfParking
        self.approvedReservations = approvedReservations
        self.deactivated = false
        self.pricePerDay = pricePerDay
        self.dailyPriceEnabled = dailyPriceEnabled
    }
    
    var id: String
    var address: Address
    var coordinates: Coordinate
    var pricePerHour: Double
    var pricePerDay: Double
    var dailyPriceEnabled: Bool
    var provider: String
    var comments: String
    var tags: [String]
    var images: [String]
    var directions: String
    
    var startDate: Int
    var endDate: Int
    
    // NOTE: no longer needed since we requery provider data every time
    //Fields below are properties of provider but stored here to minimize data costs
//    var displayName: String
//    var email: String
//    var phoneNumber: String
//    var photo: String
//
    //List of IDs for all transactions
    var reservations: [String]
    var approvedReservations: [String]?
    func validateTimeSlot(start: Int, end: Int, completion: @escaping(Bool)->Void) {
        completion(true);
    }
    var selfParking: SelfParking
    var deactivated: Bool
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
struct SelfParking: Codable {
    var hasSelfParking: Bool
    var selfParkingMethod: String
    var specificDirections: String
}
extension SelfParking {
    static func blank() -> SelfParking {
        return SelfParking(hasSelfParking: false, selfParkingMethod: "", specificDirections:"")
    }
}
extension Address {
    func toString() -> String {
        return street + ", " + city + ", " + state + " " + zip
    }
    static func blankAddress() -> Address {
        return Address(city: "Test City", state: "TS", street: "Test Street", zip: "12345")
    }
}
