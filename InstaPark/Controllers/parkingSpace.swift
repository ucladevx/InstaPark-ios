//
//  parkingSpace.swift
//  InstaPark
//
//  Created by Yili Liu on 10/30/20.
//

import MapKit
import UIKit

class parkingSpace: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var name: String?
    var coordinate: CLLocationCoordinate2D
    var price: Double
    var time: String
    
    init(name: String, coordinate: CLLocationCoordinate2D, price: Double, time: String) {
        self.coordinate = coordinate
        self.price = price
        self.time = time
        self.name = name
        
        //temporary variables
        self.subtitle = "Available " + time
        self.title = name + "   $" + String(price) + "/hr"
    }
}

