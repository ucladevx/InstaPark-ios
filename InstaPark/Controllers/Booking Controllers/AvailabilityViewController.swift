//
//  AvailabilityViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 11/8/20.
//

import UIKit
import FSCalendar

class AvailabilityViewController: UIViewController {
    var delegate: isAbleToReceiveData?

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var endPicker: UIDatePicker!
    
    var startTime:Date? = nil
    var endTime:Date? = nil
//    var invalidDates:[String] = ["2020-11-17",
//                                 "2020-11-15",
//                                 "2020-11-16",
//                                 "2020-11-21"]
    var invalid = [Int]()
    var selectedDate = Date.init()
    var times = [Int: [ParkingSpaceMapAnnotation.ParkingTimeInterval]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //calendar setup
        calendar.delegate = self
        calendar.placeholderType = .none
        calendar.select(selectedDate as Date)
        calendar.reloadData()
        calendar.appearance.titleFont = .boldSystemFont(ofSize: 16)
        calendar.appearance.headerTitleFont = .boldSystemFont(ofSize: 16)
        calendar.dataSource = self
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "CELL")
        
        //picker setup
        if (startTime == nil || endTime == nil) {
            let weekDay = Calendar.current.component(.weekday, from: selectedDate)
            if(times[weekDay-1]!.isEmpty) {
                invalid.append(weekDay)
            }
            else
            {
                startTime = times[weekDay-1]![0].start
                let length = times[weekDay-1]!.count
                endTime = times[weekDay-1]![length-1].end
            }
        }
        startPicker.setDate(startTime!, animated: false)
        endPicker.setDate(endTime!, animated: false)
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        if (startPicker.date >= endPicker.date){
            return
        }
        dismiss(animated: true)
    }
    
    @IBAction func startPicker(_ sender: Any) {
        
    }
    
    @IBAction func endPicker(_ sender: Any) {
        
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }*/
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.pass(start: startPicker.date, end: endPicker.date, date: selectedDate)
    }

}

extension AvailabilityViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        let weekDay = Calendar.current.component(.weekday, from: selectedDate)
        //print(weekDay-1)
        startTime = times[weekDay-1]![0].start
        let length = times[weekDay-1]!.count
        endTime = times[weekDay-1]![length-1].end
        self.startPicker.setDate(startTime!, animated: true)
        self.endPicker.setDate(endTime!, animated: true)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        //let dateString : String = dateFormatter1.string(from:date)
        let weekDay = Calendar.current.component(.weekday, from: date)
        
        if date < Date() || self.times[weekDay-1]!.isEmpty {
            return false
        }
        return true
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //let dateString = self.dateFormatter1.string(from: date)
        let weekDay = Calendar.current.component(.weekday, from: date)
        if date < Date() || self.times[weekDay-1]!.isEmpty{
            return UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        } else {
            return .black
        }
    }
    
    /*
    //fill background of unavailible dates too if needed
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let dateString = self.dateFormatter1.string(from: date)
        if self.invalidDates.contains(dateString) {
            return .systemGray2
        }
        return nil
    }
    */
}
