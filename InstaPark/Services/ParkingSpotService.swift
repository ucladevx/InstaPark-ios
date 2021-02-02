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
    static let parkingDBName = "TestParkingSpotDB";
    static let db = Firestore.firestore()
    static let geoFire = GeoFire(firebaseRef: Database.database().reference())
    static var parkingType: ParkingType = .short
    static func setParkingType(_ parkingType: ParkingType) {
        self.parkingType = parkingType
    }
    //Temporary function for creating dummy parking spots
    static func createParkingSpotIn(lat: Double, long: Double) {
        let spot = ShortTermParkingSpot(id: "", address: Address(city: "Los Angeles", state: "CA", street: generateRandomStreet(), zip: String(Int.random(in: 10000..<99999))), coordinates: Coordinate(lat: lat, long: long), pricePerHour: 1.0, provider: "provider", comments: "Comment", tags: ["Tag"], firstName: "Bob", lastName: "Steve", reservations: [String](), fromFullDays: [0,1,2,3,4,5,6], images: [String]())
        let docRef = db.collection(parkingDBName).document()
        spot.id = docRef.documentID
        print("DOCUMENT ID:")
        print(docRef.documentID)
        do {
            try docRef.setData(from: spot)
            geoFire.setLocation(CLLocation(latitude: spot.coordinates.lat, longitude: spot.coordinates.long), forKey: spot.id) { error in
                if error == nil {
                    print("SUCCESSFULLY SAVED")
                }
            }
        } catch {
            print("ERROR")
        }
    }
    static func saveShortTermParkingSpot(_ shortTerm: ShortTermParkingSpot) {
        let docRef = db.collection(parkingDBName).document()
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
            collection = db.collection(parkingDBName)
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
            docRef = db.collection(parkingDBName).document(id)
        case .long:
            docRef = db.collection(parkingDBName).document(id)
        }
        docRef.getDocument() {document, error in
            if let error = error {
                completion(nil, error)
                return
            }else {
                if let document = document {
                    if let data = document.data() {
                        switch parkingType {
                        case .short:
                            if let parkingSpot = try? ShortTermParkingSpot.init(from: data) {
                                completion(parkingSpot, nil)
                            }
                        case .long:
                            if let parkingSpot = try? ShortTermParkingSpot.init(from: data) {
                                completion(parkingSpot, nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func getShortTermParkingSpotById(_ id: String, completion: @escaping(ShortTermParkingSpot?, Error?)->Void) {
        let docRef: DocumentReference
        docRef = db.collection(parkingDBName).document(id)
        docRef.getDocument() {document, error in
            if let error = error {
                completion(nil, error)
                return
            }else {
                if let document = document {
                    if let parkingSpot = try? ShortTermParkingSpot.init(from: document.data()!) {
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
    //currently not in use
    static func reserveParkingSpot(parkingSpot: ParkingSpot, startTime:Int, endTime: Int) {
        // save parking spot information as transaction
        let docRef = db.collection("Transaction").document()
        if let user = Auth.auth().currentUser {
            let transaction = Transaction.init(id: docRef.documentID, customer: user.uid, startTime: startTime, endTime: endTime, address: parkingSpot.address, fromParkingSpot: parkingSpot)
            docRef.setData(transaction.dictionary)
            db.collection("ParkingSpot").document(parkingSpot.id).updateData(["reservations": FieldValue.arrayUnion([docRef.documentID])])
        }
    }
    
}
enum ParkingType {
    case short
    case long
}
extension ParkingSpotService {
    static func generateRandomStreet() -> String{
        var randStreet = ["Glenwood Drive", "Canterbury Court", "8th Avenue", "East Street", "Marshall Street", "Cypress Court", "Wall Street", "Hilltop Road", "Buttonwood Drive", "Grove Street", "Willow Lane", "Oxford Court", "Bridle Lane"]
        var streetNumbers = ["10443", "10399", "10322", "10244", "15443", "15355", "12553", "12443", "11953"]
        let n1 = Int.random(in: 0..<randStreet.count)
        let n2 = Int.random(in: 0..<streetNumbers.count)
        return streetNumbers[n2] + " " + randStreet[n1]
    }
    
}
