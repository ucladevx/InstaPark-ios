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
    @IBOutlet weak var startScroller: UIPickerView!
    @IBOutlet weak var endScroller: UIPickerView!
    
    var startTime:Date? = nil
    var endTime:Date? = nil
//    var invalidDates:[String] = ["2020-11-17",
//                                 "2020-11-15",
//                                 "2020-11-16",
//                                 "2020-11-21"]
    var invalid = [Int]()
    var selectedDate = Date.init()
    var times = [Int: [ParkingSpaceMapAnnotation.ParkingTimeInterval]]()
    var weekDay = Calendar.current.component(.weekday, from: Date())
    
    var timeData = [String]()
    
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
        
        startScroller.delegate = self
        startScroller.dataSource = self
        endScroller.delegate = self
        endScroller.dataSource = self
        
        //picker setup
        if (startTime == nil || endTime == nil) {
            weekDay = Calendar.current.component(.weekday, from: selectedDate)
            var i = -1
            while times[weekDay+i]!.isEmpty {
                invalid.append(weekDay)
                i += 1
            }
            startTime = times[weekDay+i]![0].start
            let length = times[weekDay+i]!.count
            endTime = times[weekDay+i]![length-1].end
            selectedDate = Calendar.current.date(byAdding: .day, value: i+1, to: selectedDate)!
            calendar.select(selectedDate as Date)
            updatePickerData()
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
    
    func updatePickerData() {
        timeData = []
        //rounding to +-15 shouldn't be needed later?
        let nextDiff = 15 - Calendar.current.component(.minute, from: startTime!) % 15
        startTime = Calendar.current.date(byAdding: .minute, value: nextDiff, to: startTime!) ?? Date()
        var row = 0
        var newDate = startTime!
        while newDate < endTime! {
            newDate = startTime!.addingTimeInterval(TimeInterval(900*row))
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "h : mm  a"
            let timeString = formatter1.string(from: newDate)
            timeData.append(timeString)
            row += 1
        }
        startScroller.reloadAllComponents()
        endScroller.reloadAllComponents()
        startScroller.selectRow(0, inComponent: 0, animated: true)
        endScroller.selectRow(timeData.count-1, inComponent: 0, animated: true)
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
        self.weekDay = Calendar.current.component(.weekday, from: selectedDate)
        self.startTime = times[weekDay-1]![0].start
        let length = times[weekDay-1]!.count
        self.endTime = times[weekDay-1]![length-1].end
        self.updatePickerData()
        self.startPicker.setDate(startTime!, animated: true)
        self.endPicker.setDate(endTime!, animated: true)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        //let dateString : String = dateFormatter1.string(from:date)
        weekDay = Calendar.current.component(.weekday, from: date)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        if date < yesterday || self.times[weekDay-1]!.isEmpty {
            return false
        }
        return true
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //let dateString = self.dateFormatter1.string(from: date)
        weekDay = Calendar.current.component(.weekday, from: date)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        if date < yesterday || self.times[weekDay-1]!.isEmpty{
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


extension AvailabilityViewController: UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.timeData.count
    }
}

extension AvailabilityViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        /*
        let date: Date = Date()
        let cal: Calendar = Calendar(identifier: .gregorian)
        var newDate: Date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        newDate = newDate.addingTimeInterval(TimeInterval(900*row))
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "h:mm a"
        let startString = formatter1.string(from: newDate)  */
        
        return self.timeData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        /*
        let date: Date = Date()
        let cal: Calendar = Calendar(identifier: .gregorian)
        var newDate: Date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        newDate = newDate.addingTimeInterval(TimeInterval(900*row))
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "h : mm  a"
        let startString = formatter1.string(from: newDate) */
        if pickerView.tag == 1 {
            if row % 4 == 0 {
                return NSAttributedString(string: self.timeData[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            }
            else {
                return NSAttributedString(string: self.timeData[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)])
                
            }
        }
        else {
            if row % 4 == 1 {
                return NSAttributedString(string: self.timeData[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            }
            else {
                return NSAttributedString(string: self.timeData[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)])
            }
        }
        
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let w = pickerView.frame.size.height
        return 0.25 * w;
    }
    
    
}


