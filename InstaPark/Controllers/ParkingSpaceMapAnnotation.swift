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
    var time: String
    
    init(name: String, coordinate: CLLocationCoordinate2D, price: Double, time: String) {
        self.coordinate = coordinate
        self.price = price
        self.time = time
        self.name = name
    }
}

