//
//  ParkingSpotService.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/2/20.
//

import Foundation
import Firebase
class ParkingSpotService {
    static func createParkingSpotIn(lat: Double, long: Double) {
        print("Creating parking spot")
        let db = Firestore.firestore()
        let spot = ParkingSpot(id: "1", address: Address(city: "LA", state: "CA", street: "Street1", zip: "90024"), startTime: 0, endTime: 0, coordinates: Coordinate(lat: lat, long: long), isAvailable: true, pricePerHour: 1.0, provider: "provider")
        db.collection("ParkingSpot").document("1").setData(spot.dictionary)
    }
}
