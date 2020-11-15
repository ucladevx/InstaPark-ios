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
    var times: [[ParkingTimeInterval]]
    var tags: [String]
    var comments: String
    
    struct ParkingTimeInterval {
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
        self.times = [
            [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605348000), end: Date.init(timeIntervalSince1970: 16053800100)),
             ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605380400), end: Date.init(timeIntervalSince1970: 1605405570))],
            [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605347900), end: Date.init(timeIntervalSince1970: 1605380500))],
            [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605337200), end: Date.init(timeIntervalSince1970: 1605380900))],
            [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605337500), end: Date.init(timeIntervalSince1970: 1605390400))],
            [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605348200), end: Date.init(timeIntervalSince1970: 1605380700))],
            [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605346900), end: Date.init(timeIntervalSince1970: 1605390200))],
            [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605348000), end: Date.init(timeIntervalSince1970: 1605373200))]]
    }
}

