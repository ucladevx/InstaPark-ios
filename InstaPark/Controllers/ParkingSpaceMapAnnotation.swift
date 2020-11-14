//
//  parkingSpace.swift
//  InstaPark
//
//  Created by Yili Liu on 10/30/20.
//

import MapKit
import UIKit

//class for MapView to pass data into annotations 
class ParkingSpaceMapAnnotation: NSObject, MKAnnotation {
    var id: String
    var name: String
    var coordinate: CLLocationCoordinate2D
    var price: Double
    var startTime: NSDate
    var endTime: NSDate
    var address: String
    var times: [ParkingTimeInterval]
    var tags: [String]
    var comments: String
    
    struct ParkingTimeInterval :Codable{
        //epoch time
        var start: Date
        var end: Date
    }

    init(id: String, name: String, coordinate: CLLocationCoordinate2D, price: Double, startTime: NSDate, endTime: NSDate, address: String, tags: [String], comments: String) {
        self.id = id
        self.coordinate = coordinate
        self.price = price
        self.startTime = startTime
        self.endTime = endTime
        self.name = name
        self.address = address
        self.tags = tags
        self.comments = comments
        let end = Date.init(timeIntervalSinceNow: 5000)
        self.times = [ParkingTimeInterval(start: Date.init(), end: end)]
    }
}

