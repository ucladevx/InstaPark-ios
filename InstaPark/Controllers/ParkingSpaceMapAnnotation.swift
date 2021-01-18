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
    var address: String
    var times: [Int: [ParkingTimeInterval]]
    var tags: [String]
    var comments: String
    var bookedTimes: [Int: [ParkingTimeInterval]]
    
    // MARK: Optional Args
    
    // for short term parking
    var startTime: Date?
    var endTime: Date?
    var date: Date?
    
    // for long term parking
    var startDate: Date?
    var endDate: Date?
    
    struct ParkingTimeInterval {
        //epoch time
        var start: Date
        var end: Date
    }
    
    init(id: String, name: String, coordinate: CLLocationCoordinate2D, price: Double, address: String, tags: [String], comments: String, startTime: Date?, endTime: Date?, date: Date?, startDate: Date?, endDate: Date?) {
        self.id = id
        self.coordinate = coordinate
        self.price = price
        self.name = name
        self.address = address
        self.tags = tags
        self.comments = comments
        
        self.startTime = startTime
        self.endTime = endTime
        self.date = date
        
        self.startDate = startDate
        self.endDate = endDate
        
        
        //MARK: Dummy data for testing purposes 
        func setTime(hour: Int, minute: Int) -> Date {
            return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
        }

        self.times = [
            0: [ParkingTimeInterval(start: setTime(hour: 7, minute: 30), end: setTime(hour: 21, minute: 00))],
            1: [ParkingTimeInterval(start: setTime(hour: 8, minute: 15), end: setTime(hour: 20, minute: 30))],
            2: [],
            3: [ParkingTimeInterval(start: setTime(hour: 7, minute: 00), end: setTime(hour: 21, minute: 24))],
            4: [ParkingTimeInterval(start: setTime(hour: 9, minute: 45), end: setTime(hour: 22, minute: 15))],
            5: [ParkingTimeInterval(start: setTime(hour: 10, minute: 00), end: setTime(hour: 23, minute: 30))],
            6: [ParkingTimeInterval(start: setTime(hour: 8, minute: 00), end: setTime(hour: 23, minute: 00))]]
        self.bookedTimes = [
            0: [ParkingTimeInterval(start: setTime(hour: 9, minute: 00), end: setTime(hour: 12, minute: 00)),
                ParkingTimeInterval(start: setTime(hour: 15, minute: 30), end: setTime(hour: 19, minute: 15))],
            1: [ParkingTimeInterval(start: setTime(hour: 10, minute: 15), end: setTime(hour: 13, minute: 45))],
            2: [],
            3: [ParkingTimeInterval(start: setTime(hour: 8, minute: 30), end: setTime(hour: 11, minute: 30)),
                ParkingTimeInterval(start: setTime(hour: 14, minute: 15), end: setTime(hour: 16, minute: 30)),
                ParkingTimeInterval(start: setTime(hour: 18, minute: 45), end: setTime(hour: 19, minute: 45))],
            4: [ParkingTimeInterval(start: setTime(hour: 16, minute: 00), end: setTime(hour: 22, minute: 15))],
            5: [ParkingTimeInterval(start: setTime(hour: 12, minute: 30), end: setTime(hour: 16, minute: 30))],
            6: [ParkingTimeInterval(start: setTime(hour: 8, minute: 00), end: setTime(hour: 11, minute: 15))]]
    }
    
   
    
    /*self.times = [
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
}*/
    
    /*[ParkingTimeInterval(start: Date.init(timeIntervalSince1970: 1605348000), end: Date.init(timeIntervalSince1970: 1605390500))],*/
}

