//
//  ParkingSpotService.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/2/20.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import GeoFire
class ParkingSpotService {
    static let db = Firestore.firestore()
    static let geoFire = GeoFire(firebaseRef: Database.database().reference())
    static var parkingType: ParkingType = .short
    static func setParkingType(_ parkingType: ParkingType) {
        self.parkingType = parkingType
    }
    //Temporary function for creating dummy parking spots
    static func createParkingSpotIn(lat: Double, long: Double) {
        print("Creating parking spot")
        let spot = ShortTermParkingSpot(id: "", address: Address(city: "LA", state: "CA", street: "Street1", zip: "90024"), coordinates: Coordinate(lat: lat, long: long), pricePerHour: 1.0, provider: "provider", comments: "Comment", tags: ["Tag"], firstName: "Bob", lastName: "Steve", lastEndTime: 0, fromFullDays: [0,1,2,3,4,5,6])
        let docRef = db.collection("ShortTermParkingSpot").document()
        spot.id = docRef.documentID
        do {
            try docRef.setData(from: spot)
        } catch {
            print("ERROR")
        }
    }
    static func saveShortTermParkingSpot(_ shortTerm: ShortTermParkingSpot) {
        let docRef = db.collection("ShortTermParkingSpot").document()
        var newShortTerm = shortTerm
        newShortTerm.id = docRef.documentID
        docRef.setData(newShortTerm.dictionary)
        geoFire.setLocation(CLLocation(latitude: newShortTerm.coordinates.lat, longitude: newShortTerm.coordinates.long), forKey: newShortTerm.id)
    }
    //Gets parking spots near you, takes in region as an argument
    static func getParkingSpotQuery(region: MKCoordinateRegion) -> GFRegionQuery{
        let regionQuery = geoFire.query(with: region)
        return regionQuery
    }
    //Gets all parking spots from the ParkingSpot collection
    static func getAllParkingSpots(completion: @escaping ([ParkingSpot]?, Error?) -> Void){
        print("Getting all parking spaces")
        var collection: CollectionReference
        switch parkingType {
        case .long:
            collection = db.collection("LongTermParkingSpot")
        case .short:
            collection = db.collection("ShortTermParkingSpot")
        }
        collection.getDocuments() { querySnapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                var parkingSpots = [ParkingSpot]()
                print(querySnapshot!.documents.count)
                for document in querySnapshot!.documents {
                    switch parkingType {
                    case .long:
                        if let parkingSpot = try? ShortTermParkingSpot.init(from: document.data()) {
                            parkingSpots.append(parkingSpot)
                        }
                    case .short:
                        if let parkingSpot = try? ShortTermParkingSpot.init(from: document.data()) {
                            parkingSpots.append(parkingSpot)
                            print("Parking Spot appended")
                        }
                    }
//                    if let parkingSpot = try? ParkingSpot.init(from: document.data()) {
//                        parkingSpots.append(parkingSpot)
//                    }
                }
                completion(parkingSpots, nil)
            }
        }
    }
    //Gets parking spot by id(The id is a string that is stored in User's parkingSpots array)
    static func getParkingSpotById(_ id: String, completion: @escaping(ParkingSpot?, Error?)->Void) {
        let docRef: DocumentReference
        switch parkingType {
        case .short:
            docRef = db.collection("ShortTermParkingSpot").document(id)
        case .long:
            docRef = db.collection("ShortTermParkingSpot").document(id)
        }
        docRef.getDocument() {document, error in
            if let error = error {
                completion(nil, error)
                return
            }else {
                if let document = document {
                    switch parkingType {
                    case .short:
                        if let parkingSpot = try? ShortTermParkingSpot.init(from: document.data()!) {
                            completion(parkingSpot, nil)
                        }
                    case .long:
                        if let parkingSpot = try? ShortTermParkingSpot.init(from: document.data()!) {
                            completion(parkingSpot, nil)
                        }
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
enum ParkingType {
    case short
    case long
}
