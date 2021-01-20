//
//  ShortTermParking.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/12/20.
//

import Foundation
class ShortTermParkingSpot: ParkingSpot {
    //protocol for setting times : let user set time interval for each day of the week. 0 is monday, 6 is sunday. Each day has a list of time intervals (in unix time) for the start and end time of the interval.
    var times: [Int: [ParkingTimeInterval]]
    var occupied = [Int: [ParkingTimeInterval]]()
    init(id: String, address: Address, coordinates: Coordinate, pricePerHour: Double, provider: String, comments: String, tags: [String], firstName: String, lastName: String, reservations: [String], times: [Int: [ParkingTimeInterval]]) {
        self.times = times
        super.init(id: id, address: address, coordinates: coordinates, pricePerHour: pricePerHour, provider: provider, comments: comments, tags: tags, firstName: firstName, lastName: lastName, reservations: reservations)
        
    }
    // init from Full Days means that the parking spot is open for the full days in the array ( 0 -> Monday, 6 -> Sunday)
    init(id: String, address: Address, coordinates: Coordinate, pricePerHour: Double, provider: String, comments: String, tags: [String], firstName: String, lastName: String, reservations: [String], fromFullDays: [Int]) {
        //since we only care about the day of the week, 345600 represents Jan 4th 1970 in unix or Monday there are 86400 seconds in a day
        self.times = [Int: [ParkingTimeInterval]]()
        for i in fromFullDays {
            times[i] = [ParkingTimeInterval(start: 345600+i*86400, end: 345600+(i+1)*86400-1)]
        }
        super.init(id: id, address: address, coordinates: coordinates, pricePerHour: pricePerHour, provider: provider, comments: comments, tags: tags, firstName: firstName, lastName: lastName, reservations: reservations)
    }
    enum CodingKeys: String, CodingKey {
        case times
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.times = try container.decode([Int: [ParkingTimeInterval]].self, forKey: .times)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let superdecoder = try container.superDecoder()
        try super.init(from: superdecoder)
//        self.times = try values.decode([[ParkingTimeInterval]].self, forKey: .times)
    }
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.times, forKey:.times)
        let superencoder = container.superEncoder()
        try super.encode(to: superencoder)
    }
    //Adds time slot for a certain day ( 0 -> Monday, 6 -> Sunday )
    func addTimeSlot(forDay: Int, start: Int, end: Int) {
        self.times[forDay]!.append(ParkingTimeInterval(start: start, end: end))
    }
    //checks if time slot is available for reservation, including if they span across night (takes into account provider time-ranges. All times are in epoch
    func validateTimeSlotWithProvider(start: Int, end: Int) -> Bool {
        //first, make sure valid with provider time intervals
        let startParking = Date.init(timeIntervalSince1970: Double(start))
        var startWeekday = Calendar.current.component(.weekday, from: startParking)
        let endParking = Date.init(timeIntervalSince1970: Double(end))
        var endWeekday = Calendar.current.component(.weekday, from: endParking)
        // default 1-7, week starts on Sunday. Change to 0-6, week starts on Monday;
        startWeekday = (7+(startWeekday-2))%7
        endWeekday = (7+(endWeekday-2))%7
        //if the parking begins and ends on the same day
        if startWeekday == endWeekday && end-start < 864000 /*seconds in a day*/ {
            for interval in times[startWeekday]! {
                let startInterval = Date.init(timeIntervalSince1970: Double(interval.start))
                let endInterval = Date.init(timeIntervalSince1970: Double(interval.end))
                if(compareHourMinutes(startParking,startInterval) >= 0 && compareHourMinutes(endParking, endInterval)<=0) {
                    return true;
                    //Succeeded in provider time slot check
                }
            }
        } else {
            
        }
    }
    //checks if time slot is available for reservation taking into account current reservations for the spot. MUST DO validateTimeSlotWithProvider first
    func validateTimeSlotWithReserved(start: Int, end: Int, completion: @escaping (Bool) -> Void) {
        
    }
    //checks if these two time slots are available for reservation, including if they span across night
    func validateTimeSlot(start: Int, end: Int) -> Bool {
        let startParking = Date.init(timeIntervalSince1970: Double(start))
        var startWeekday = Calendar.current.component(.weekday, from: startParking)
        let endParking = Date.init(timeIntervalSince1970: Double(end))
        var endWeekday = Calendar.current.component(.weekday, from: endParking)
        startWeekday = (7+(startWeekday-2))%7
        endWeekday = (7+(endWeekday-2))%7
        if startWeekday == endWeekday &&  end - start < 86400 /*seconds in a day*/{
            for interval in times[startWeekday]! {
                let startInterval = Date.init(timeIntervalSince1970: Double(interval.start))
                let endInterval = Date.init(timeIntervalSince1970: Double(interval.end))
                if(compareHourMinutes(startParking,startInterval) >= 0 && compareHourMinutes(endParking, endInterval)<=0) {
                    return true
                }
            }
        } else {
            for interval in times[startWeekday]! {
                let startInterval = Date.init(timeIntervalSince1970: Double(interval.start))
                let endInterval = Date.init(timeIntervalSince1970: Double(interval.end))
                if(compareHourMinutes(startParking, startInterval) >= 0 && isEndOfDay(endInterval)) {
                    for i in 1...7 {
                        let k = (startWeekday + i)%7
                        if (k == endWeekday){
                            let finalEndInterval = Date.init(timeIntervalSince1970: Double(times[k]![0].end))
                            if(compareHourMinutes(endParking, finalEndInterval)<=0) {
                                return true
                            }
                        } else {
                            if Calendar.current.component(.hour, from: Date(timeIntervalSince1970: Double(times[k]![0].start))) == 0 && isEndOfDay(Date(timeIntervalSince1970: Double(times[k]![0].end))){
                            }else {
                                break
                            }
                        }
                    }
                }
            }
        }
        return false
    }
}
extension ShortTermParkingSpot {
    //checks if the end time is 11:59
    func isEndOfDay(_ date: Date) -> Bool {
        return (Calendar.current.component(.hour, from: date) == 11 && Calendar.current.component(.minute, from: date) >= 50)
    }
    func compareHourMinutes(_ date1: Date, _ date2: Date) -> Int{
        if(Calendar.current.component(.hour, from: date1) == Calendar.current.component(.hour, from:date2)) {
            return Calendar.current.component(.minute, from: date1) - Calendar.current.component(.minute, from:date2)
        }
        return Calendar.current.component(.hour, from: date1)-Calendar.current.component(.hour, from:date2)
    }
//    var dictionary: [String: Any] {
//        var dict: [String: Any]?
//        try? JSON.encoder.encode(self) as? [String: Any]
//        dict = try? JSONSerialization.jsonObject(with: JSON.encoder.encode(self)) as? [String: Any] ?? [:]
//        if var dict = dict {
//            return dict
//        }
//        return [:]
//    }
}

struct ParkingTimeInterval : Codable{
    //epoch time
    var start: Int
    var end: Int
}
