//
//  AvailabilityViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 11/8/20.
//

import UIKit
import FSCalendar

class AvailabilityViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
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
    var todayTime = Date.init()
    var times = [Int: [ParkingSpaceMapAnnotation.ParkingTimeInterval]]()
    var bookedTimes = [Int: [ParkingSpaceMapAnnotation.ParkingTimeInterval]]()
    var weekDay = Calendar.current.component(.weekday, from: Date())
    var cancel = false
    
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
        while times[weekDay+i]!.isEmpty { //find most close unbooked day
            i += 1
        }
        startTime = times[weekDay+i]![0].start
        let length = times[weekDay+i]!.count
        endTime = times[weekDay+i]![length-1].end
        selectedDate = Calendar.current.date(byAdding: .day, value: i+1, to: selectedDate)!
        calendar.select(selectedDate as Date)
        updateBookedData(dayOfWeek: weekDay+i+1)
        updatePickerData()
        
        //if the user is revisiting the controller, select their last chosen times on picker
        if (selectedStart != nil || selectedEnd != nil) {
            startScroller.selectRow(timeData.firstIndex(of: timeFormatter1.string(from: selectedStart!))!, inComponent: 0, animated: false)
            endScroller.selectRow(timeData.firstIndex(of: timeFormatter1.string(from: selectedEnd!))!, inComponent: 0, animated: false)
        }
        else {
            updateSelectedDates()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        cancel = true
        dismiss(animated: true)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func updatePickerData() {
        timeData = []
        //rounding to +-15 shouldn't be needed later since dates should all be exatly in intervals of 15
        //let nextDiff = 15 - Calendar.current.component(.minute, from: startTime!) % 15
        //startTime = Calendar.current.date(byAdding: .minute, value: nextDiff, to: startTime!) ?? Date()
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
            //check if user's current time is beyond the time of the ending time
            let length = times[weekDay-1]!.count
            endTime = times[weekDay-1]![length-1].end
            let endHour = Calendar.current.component(.hour, from: endTime!)
            let endMin = Calendar.current.component(.minute, from: endTime!)
            let curHour = Calendar.current.component(.hour, from: Date())
            let curMin = Calendar.current.component(.minute, from: Date())
            if endHour < curHour || (endHour == curHour && endMin < curMin) {
                let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                calendar.select(nextDay)
                start = 0
                invalidDates.append(todayString)
                weekDay = Calendar.current.component(.weekday, from: nextDay!)
                updateBookedData(dayOfWeek: weekDay)
                startScroller.reloadAllComponents()
                endScroller.reloadAllComponents()
            }
            //if not, put earliest start time as the first available index starting at user's current time (rounded up to the nearst 15 mins)
            else {
                let nextDiff = 15 - Calendar.current.component(.minute, from: Date()) % 15
                let todayDate = Calendar.current.date(byAdding: .minute, value: nextDiff, to: Date()) 
                start = timeData.firstIndex(of: timeFormatter1.string(from: todayDate!))!
                var startDataTime = times[weekDay-1]![0].start
                var row = 0
                while startDataTime < todayDate! {
                    startDataTime = times[weekDay-1]![0].start.addingTimeInterval(TimeInterval(900*row))
                    let timeString = timeFormatter1.string(from: startDataTime)
                    bookedData.append(timeString)
                    row += 1
                }
            }
        }
        var end = 0
        for i in start...timeData.count-1 {
            if !bookedData.contains(timeData[i]) {
                startScroller.selectRow(i, inComponent: 0, animated: true)
                end = i
                break
            }
        }
        for i in end+1...timeData.count-1 {
            if bookedData.contains(timeData[i]) {
                endScroller.selectRow(i-1, inComponent: 0, animated: true)
                return
            }
            if i == timeData.count-1 {
                endScroller.selectRow(i, inComponent: 0, animated: true)
                return
            }
        }
    }
    
    func updateBookedData(dayOfWeek: Int) {
        bookedData = []
    
        for interval in bookedTimes[dayOfWeek-1]! {
            var row = 0
            //let nextDiff = 15 - Calendar.current.component(.minute, from: interval.start) % 15
            //let rounded = Calendar.current.date(byAdding: .minute, value: nextDiff, to: interval.start) ?? Date()
            var curr = interval.start
            while curr < interval.end {
                curr = interval.start.addingTimeInterval(TimeInterval(900*row))
                let timeString = timeFormatter1.string(from: curr)
                bookedData.append(timeString)
                row += 1
            }
        }
    }
    
    //for cleaner time conversion from date -> string 
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
        
        delegate?.pass(start: startInt, end: endInt, date: selectedDate, cancel: cancel)
    }

}

extension AvailabilityViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        self.weekDay = Calendar.current.component(.weekday, from: selectedDate)
        self.startTime = times[weekDay-1]![0].start
        let length = times[weekDay-1]!.count
        self.endTime = times[weekDay-1]![length-1].end
        self.updateBookedData(dayOfWeek: weekDay)
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
       
        //if the user selects an invalid date
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
        
        //if the user chose the same time for both
        if startRow == endRow {
            self.doneButton.isEnabled = false
            self.doneButton.backgroundColor = UIColor.init(red: 0.819, green: 0.788, blue: 0.847, alpha: 1.0)
            return
        }
        //if not, check if an interval between is invalid
        if pickerView.tag == 1 { //start picker
            //if start row is the last available time slot, disable button
            if startRow == (self.timeData.count-1) {
                self.endScroller.selectRow((self.timeData.count-1), inComponent: 0, animated: true)
                self.doneButton.isEnabled = false
                self.doneButton.backgroundColor = UIColor.init(red: 0.819, green: 0.788, blue: 0.847, alpha: 1.0)
                return
            }
            //if start is greater than end, move end picker to largest interval between start and last interval if needed
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
            } else { //if invalid time in between, move end picker to the last time before invalid interval
                for i in startRow...endRow{
                    if self.bookedData.contains(self.timeData[i]) {
                        self.endScroller.selectRow(i-1, inComponent: 0, animated: true)
                        return
                    }
                }
            }
        }
        else { //end picker
            if endRow == 0 { //if end time is the first time, disable done button
                self.startScroller.selectRow(0, inComponent: 0, animated: true)
                self.doneButton.isEnabled = false
                self.doneButton.backgroundColor = UIColor.init(red: 0.819, green: 0.788, blue: 0.847, alpha: 1.0)
                return
            }
            else if startRow > endRow { //if start is greater than end, move start picker to earliest time frame between 0 and end that does not contain invalid times
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
            } else { //if invalid time between, move start picker to time right after the last invalid block between the two times
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
        var newDate: Date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: date)! */
 
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


