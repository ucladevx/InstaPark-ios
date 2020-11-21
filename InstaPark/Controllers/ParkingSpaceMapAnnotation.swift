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
    var times: [Int: [ParkingTimeInterval]]
    var tags: [String]
    var comments: String
    var bookedTimes: [Int: [ParkingTimeInterval]]
    
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
            0: [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605348000), end: Date.init(timeIntervalSince1970: 1605380010))],
            1: [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605347900), end: Date.init(timeIntervalSince1970: 1605380500))],
            2: [], 
            3: [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605348000), end: Date.init(timeIntervalSince1970: 1605390500))],
            4: [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605348200), end: Date.init(timeIntervalSince1970: 1605380700))],
            5: [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605346900), end: Date.init(timeIntervalSince1970: 1605390200))],
            6: [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605348000), end: Date.init(timeIntervalSince1970: 1605373200))]]
        self.bookedTimes = [
            0: [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605367900), end: Date.init(timeIntervalSince1970: 1605370200))],
            1: [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605369900), end: Date.init(timeIntervalSince1970: 1605370200))],
            2: [],
            3: [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605362900), end: Date.init(timeIntervalSince1970: 1605370200))],
            4: [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605363900), end: Date.init(timeIntervalSince1970: 1605370200))],
            5: [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605366900), end: Date.init(timeIntervalSince1970: 1605379200)),
                ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605356900), end: Date.init(timeIntervalSince1970: 1605360200))],
            6: [ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605366900), end: Date.init(timeIntervalSince1970: 1605370200))]]
    }
    
    /*[ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605348000), end: Date.init(timeIntervalSince1970: 1605390500))],*/
}

