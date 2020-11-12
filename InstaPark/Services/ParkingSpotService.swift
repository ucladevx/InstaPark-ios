//
//  ParkingSpotService.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/2/20.
//

import Foundation
import Firebase
import FirebaseAuth
import GeoFire
class ParkingSpotService {
    static let db = Firestore.firestore()
    static let geoFire = GeoFire(firebaseRef: Database.database().reference())
    //Temporary function for creating dummy parking spots
    static func createParkingSpotIn(lat: Double, long: Double) {
        print("Creating parking spot")
        let docRef = db.collection("ParkingSpot").document()
        let spot = ParkingSpot(id: docRef.documentID, address: Address(city: "LA", state: "CA", street: "Street1", zip: "90024"), times: [ParkingTimeInterval(start: 0, end: 0)], coordinates: Coordinate(lat: lat, long: long), pricePerHour: 1.0, provider: "provider", comments: "Comment", tags: ["Tag"], firstName: "Bob", lastName: "Steve", lastEndTime: 0)
        docRef.setData(spot.dictionary)
    }
    
    // saves new parking spot
    static func saveParkingSpot(_ parkingSpot: ParkingSpot) {
        let docRef = db.collection("ParkingSpot").document()
        var spot = parkingSpot
        spot.id = docRef.documentID
        docRef.setData(spot.dictionary)
        geoFire.setLocation(CLLocation(latitude: spot.coordinates.lat, longitude: spot.coordinates.long), forKey: spot.id)
        
    }
    //Gets parking spots near you, takes in region as an argument
    static func getParkingSpotQuery(region: MKCoordinateRegion) -> GFRegionQuery{
        let regionQuery = geoFire.query(with: region)
        return regionQuery
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
    //Gets parking spot by id(The id is a string that is stored in User's parkingSpots array)
    static func getParkingSpotById(_ id: String, completion: @escaping(ParkingSpot?, Error?)->Void) {
        let docRef = db.collection("ParkingSpot").document(id)
        docRef.getDocument() {document, error in
            if let error = error {
                completion(nil, error)
                return
            }else {
                if let document = document {
                    if let parkingSpot = try? ParkingSpot.init(from: document.data()!) {
                        completion(parkingSpot, nil)
                    }
                }
            }
        }
    }
    static func getParkingSpotsByIds(_ ids: [String], completion: @escaping([ParkingSpot]?, Error?)->Void) {
        var transactions = [ParkingSpot]()
        for s in ids {
            let docRef = db.collection("ParkingSpot").document(s)
            docRef.getDocument() {document, error in
                if let error = error {
                    completion(nil, error)
                    return
                } else {
                    if let document = document {
                        if let parkingSpot = try? ParkingSpot.init(from: document.data()!) {
                            transactions.append(parkingSpot)
                        }
                    }
                }
            }
        }
        completion(transactions, nil)
        return
    }
    //Time is seconds since epoch when reservation will end
    static func reserveParkingSpot(parkingSpot: ParkingSpot, time: Int) {
        // update parking spot to set ended parking time
        db.collection("ParkingSpot").document(parkingSpot.id).updateData(["lastEndTime": time])
        // save parking spot information as transaction
        let docRef = db.collection("Transaction").document()
        if let user = Auth.auth().currentUser {
            let transaction = Transaction.init(id: docRef.documentID, customer: user.uid, startTime: Int(NSDate.now.timeIntervalSince1970), endTime: time, fromParkingSpot: parkingSpot)
            docRef.setData(transaction.dictionary)
        }
    }
}
