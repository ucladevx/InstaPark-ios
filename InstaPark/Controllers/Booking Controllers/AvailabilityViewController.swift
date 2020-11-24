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
    @IBOutlet weak var startScroller: UIPickerView!
    @IBOutlet weak var endScroller: UIPickerView!
    
    var startTime:Date? = nil
    var endTime:Date? = nil
    var selectedStart:Date? = nil
    var selectedEnd:Date? = nil
    var selectedDate = Date.init()
    var invalidDates = [String]()
    var times = [Int: [ParkingSpaceMapAnnotation.ParkingTimeInterval]]()
    var bookedTimes = [Int: [ParkingSpaceMapAnnotation.ParkingTimeInterval]]()
    var weekDay = Calendar.current.component(.weekday, from: Date())
    
    var timeData = [String]()
    var bookedData = [String]()
    
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
        weekDay = Calendar.current.component(.weekday, from: selectedDate)
        var i = -1
        while times[weekDay+i]!.isEmpty {
            i += 1
        }
        startTime = times[weekDay+i]![0].start
        let length = times[weekDay+i]!.count
        endTime = times[weekDay+i]![length-1].end
        selectedDate = Calendar.current.date(byAdding: .day, value: i+1, to: selectedDate)!
        calendar.select(selectedDate as Date)
        updateBookedData()
        updatePickerData()
        
        if (selectedStart != nil || selectedEnd != nil) {
            startScroller.selectRow(timeData.firstIndex(of: timeFormatter1.string(from: selectedStart!))!, inComponent: 0, animated: false)
            endScroller.selectRow(timeData.firstIndex(of: timeFormatter1.string(from: selectedEnd!))!, inComponent: 0, animated: false)
        }
        else {
            updateSelectedDates()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func doneButton(_ sender: Any) {
       
        dismiss(animated: true)
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
    }
    
    func updateSelectedDates() {
        var start = 0
        let calendarString = dateFormatter1.string(from: calendar.selectedDate!)
        let todayString = dateFormatter1.string(from: Date())
        if todayString == calendarString {
            if !timeData.contains(todayString) {
                calendar.select(Calendar.current.date(byAdding: .day, value: 1, to: Date()))
                start = 0
                invalidDates.append(todayString)
            }
            else {
                let nextDiff = 15 - Calendar.current.component(.minute, from: Date()) % 15
                let todayDate = Calendar.current.date(byAdding: .minute, value: nextDiff, to: startTime!) ?? Date()
                start = timeData.firstIndex(of: timeFormatter1.string(from: todayDate))!
            }
        }
        
        for i in start...timeData.count-1 {
            if !bookedData.contains(timeData[i]) {
                startScroller.selectRow(i, inComponent: 0, animated: true)
                break
            }
        }
        for i in 1...timeData.count-1 {
            if bookedData.contains(timeData[i]) {
                endScroller.selectRow(i-1, inComponent: 0, animated: true)
                return
            }
        }
    }
    
    func updateBookedData() {
        bookedData = []
        
        for interval in bookedTimes[weekDay-1]! {
            var row = 0
            let nextDiff = 15 - Calendar.current.component(.minute, from: interval.start) % 15
            let rounded = Calendar.current.date(byAdding: .minute, value: nextDiff, to: interval.start) ?? Date()
            var newDate = rounded
            while newDate < interval.end {
                newDate = rounded.addingTimeInterval(TimeInterval(900*row))
                let timeString = timeFormatter1.string(from: newDate)
                bookedData.append(timeString)
                row += 1
            }
        }
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    fileprivate lazy var timeFormatter1: DateFormatter = {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "h : mm  a"
        return formatter1
    }()
    
    
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }*/
    
    override func viewWillDisappear(_ animated: Bool) {
        let startInt: Date = timeFormatter1.date(from: timeData[startScroller.selectedRow(inComponent: 0)])!
        let endInt : Date = timeFormatter1.date(from: timeData[endScroller.selectedRow(inComponent: 0)])!
        
        delegate?.pass(start: startInt, end: endInt, date: selectedDate)
    }

}

extension AvailabilityViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        self.weekDay = Calendar.current.component(.weekday, from: selectedDate)
        self.startTime = times[weekDay-1]![0].start
        let length = times[weekDay-1]!.count
        self.endTime = times[weekDay-1]![length-1].end
        self.updateBookedData()
        self.updatePickerData()
        self.updateSelectedDates()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        //let dateString : String = dateFormatter1.string(from:date)
        weekDay = Calendar.current.component(.weekday, from: date)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        if date < yesterday || self.times[weekDay-1]!.isEmpty || self.invalidDates.contains(dateFormatter1.string(from: date)){
            return false
        }
        return true
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //let dateString = self.dateFormatter1.string(from: date)
        weekDay = Calendar.current.component(.weekday, from: date)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        if date < yesterday || self.times[weekDay-1]!.isEmpty || self.invalidDates.contains(dateFormatter1.string(from: date)){
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("selected row \(row)")
       
        
        if self.bookedData.contains(self.timeData[row]) {
            self.doneButton.isEnabled = false
            self.doneButton.backgroundColor = UIColor.init(red: 0.819, green: 0.788, blue: 0.847, alpha: 1.0)
            return
        }
        else if self.doneButton.isEnabled == false{
            self.doneButton.isEnabled = true
            self.doneButton.backgroundColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            self.doneButton.titleLabel?.font = .italicSystemFont(ofSize: 16)
        }
        
        let startRow = self.startScroller.selectedRow(inComponent: 0)
        let endRow = self.endScroller.selectedRow(inComponent: 0)
        
        //check if an interval between is invalid
        if startRow == endRow {
            self.doneButton.isEnabled = false
            self.doneButton.backgroundColor = UIColor.init(red: 0.819, green: 0.788, blue: 0.847, alpha: 1.0)
            return
        }
        
        if pickerView.tag == 1 {
            if startRow == (self.timeData.count-1) {
                self.endScroller.selectRow((self.timeData.count-1), inComponent: 0, animated: true)
                self.doneButton.isEnabled = false
                self.doneButton.backgroundColor = UIColor.init(red: 0.819, green: 0.788, blue: 0.847, alpha: 1.0)
                return
            }
            else if startRow > endRow {
                for i in startRow...(self.timeData.count-1){
                    if self.bookedData.contains(self.timeData[i]) {
                        self.endScroller.selectRow(i-1, inComponent: 0, animated: true)
                        return
                    }
                    if i ==  (self.timeData.count-1){
                        self.endScroller.selectRow((self.timeData.count-1), inComponent: 0, animated: true)
                        return
                    }
                }
            } else {
                for i in startRow...endRow{
                    if self.bookedData.contains(self.timeData[i]) {
                        self.endScroller.selectRow(i-1, inComponent: 0, animated: true)
                        return
                    }
                }
            }
        }
        else {
            if endRow == 0 {
                self.startScroller.selectRow(0, inComponent: 0, animated: true)
                self.doneButton.isEnabled = false
                self.doneButton.backgroundColor = UIColor.init(red: 0.819, green: 0.788, blue: 0.847, alpha: 1.0)
                return
            }
            else if startRow > endRow {
                for i in (0...endRow).reversed(){
                    if self.bookedData.contains(self.timeData[i]) {
                        self.startScroller.selectRow(i+1, inComponent: 0, animated: true)
                        return
                    }
                    if i == 0 {
                        self.startScroller.selectRow(0, inComponent: 0, animated: true)
                        return
                    }
                }
            } else {
                for i in (startRow...endRow).reversed(){
                    if self.bookedData.contains(self.timeData[i]) {
                        self.startScroller.selectRow(i+1, inComponent: 0, animated: true)
                        return
                    }
                }
            }
        }
        
    }
}

extension AvailabilityViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
 
        if self.bookedData.contains(self.timeData[row]) {
            return NSAttributedString(string: self.timeData[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        else {
            return NSAttributedString(string: self.timeData[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)])
            
        }
        
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let w = pickerView.frame.size.height
        return 0.25 * w;
    }
    
    
}


