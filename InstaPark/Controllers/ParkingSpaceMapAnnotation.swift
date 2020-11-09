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
    var name: String?
    var coordinate: CLLocationCoordinate2D
    var price: Double
    var startTime: NSDate
    var endTime: NSDate
    var time: String

    init(name: String, coordinate: CLLocationCoordinate2D, price: Double, startTime: NSDate, endTime: NSDate) {
        self.coordinate = coordinate
        self.price = price
        self.startTime = startTime
        self.endTime = endTime
        self.name = name
        
        //convert NSDate to String
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "h:00"
        let startString = formatter1.string(from: startTime as Date)
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "h:00 a"
        let endString = formatter2.string(from: endTime as Date)
    
        self.time = startString + "-" + endString

    }
}

