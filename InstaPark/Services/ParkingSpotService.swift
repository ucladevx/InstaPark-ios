//
//  ParkingSpotService.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/2/20.
//

import Foundation
import Firebase
class ParkingSpotService {
    static let db = Firestore.firestore()
    //Temporary function for creating dummy parking spots
    static func createParkingSpotIn(lat: Double, long: Double) {
        print("Creating parking spot")
        let docRef = db.collection("ParkingSpot").document()
        let spot = ParkingSpot(id: docRef.documentID, address: Address(city: "LA", state: "CA", street: "Street1", zip: "90024"), startTime: 0, endTime: 0, coordinates: Coordinate(lat: lat, long: long), isAvailable: true, pricePerHour: 1.0, provider: "provider")
        docRef.setData(spot.dictionary)
    }
    //Gets all parking spots from the ParkingSpot collection
    static func getAllParkingSpots(completion: @escaping ([ParkingSpot]?, Error?) -> Void){
        print("Getting all parking spaces")
        db.collection("ParkingSpot").getDocuments() { querySnapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                var parkingSpots = [ParkingSpot]()
                for document in querySnapshot!.documents {
                    if let parkingSpot = try? ParkingSpot.init(from: document.data()) {
                        parkingSpots.append(parkingSpot)
                    }
                }
                completion(parkingSpots, nil)
            }
        }
    }
}
