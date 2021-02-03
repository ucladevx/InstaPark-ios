//
//  hourlyTimeViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 1/12/21.
//

import UIKit
import FSCalendar
//NOTE - CURRENT IMPLEMENTATION ONLY WORKS FOR NON-OVERNIGHT PARKING
class hourlyTimeViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var startScroller: UIPickerView!
    @IBOutlet weak var endScroller: UIPickerView!
    @IBOutlet weak var searchButton: UIButton!
    
    var startTime = Date()
    var endTime = Date.init(timeIntervalSinceNow: 60*60)
    var selectedDate = Date()
    
    var timeRange = [String]()
    var selectedStartDate: Date! //holds selected start date -- use this if you need it to be passed to next view
    var selectedEndDate: Date! //holds selected end date
    var datesRange: [Date]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set up calendar
        calendar.delegate = self
        calendar.allowsMultipleSelection = true
        calendar.placeholderType = .none
        //calendar.select(Date())
        calendar.reloadData()
        calendar.appearance.titleFont = UIFont.init(name: "Roboto-Medium", size: 16)
        calendar.appearance.headerTitleFont = UIFont.init(name: "Roboto-Medium", size: 16)
        calendar.dataSource = self
        calendar.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.swipeToChooseGesture.isEnabled = true
        let scopeGesture = UIPanGestureRecognizer(target: calendar, action: #selector(calendar.handleScopeGesture(_:)));
                calendar.addGestureRecognizer(scopeGesture)
            
        //create time range from picker from 12:00 am -> 11:45 pm
        for row in 0...95 {
            if(row < 4) {
                timeRange.append("12:" + String(format: "%02d", ((row % 4)*15)) + " AM")
            }
            else if(row < 48) {
                timeRange.append(String((row/4)) + String(format: ":%02d", ((row % 4)*15)) + " AM")
            }
            else if(row > 47 && row < 52) {
                timeRange.append("12:" + String(format: "%02d", ((row % 4)*15)) + " PM")
            }
            else {
                timeRange.append(String(((row-48)/4)) + String(format: ":%02d", ((row % 4)*15)) + " PM")
            }
        }
        
        //set up scrollers
        startScroller.delegate = self
        startScroller.dataSource = self
        startScroller.tag = 1
        endScroller.delegate = self
        endScroller.dataSource = self
        endScroller.tag = 2
        
        // round user's current time to ceiling in 15 min ranges
        let nextDiff = 15 - Calendar.current.component(.minute, from: Date()) % 15
        let todayDate = Calendar.current.date(byAdding: .minute, value: nextDiff, to: Date())
        let start = timeRange.firstIndex(of: timeFormatter1.string(from: todayDate!))!
        
        startScroller.selectRow(start, inComponent: 0, animated: false)
        endScroller.selectRow(start+4, inComponent: 0, animated: false)
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func searchButton(_ sender: Any) {
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
        formatter1.dateFormat = "h:mm a"
        return formatter1
    }()
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
          
          let diyCell = (cell as! DIYCalendarCell)
          // Custom today circle
          diyCell.circleImageView.isHidden = true//!self.gregorian.isDateInToday(date)
          // Configure selection layer
          if position == .current {
              
              var selectionType = SelectionType.none
              
              if calendar.selectedDates.contains(date) {
                  let previousDate = self.gregorian.date(byAdding: .day, value: -1, to: date)!
                  let nextDate = self.gregorian.date(byAdding: .day, value: 1, to: date)!
                  if calendar.selectedDates.contains(date) {
                      if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(nextDate) {
                          selectionType = .middle
                      }
                      else if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(date) {
                          selectionType = .rightBorder
                      }
                      else if calendar.selectedDates.contains(nextDate) {
                          selectionType = .leftBorder
                      }
                      else {
                          selectionType = .single
                      }
                  }
              }
              else {
                  selectionType = .none
              }
              if selectionType == .none {
                  diyCell.selectionLayer.isHidden = true
                  return
              }
              diyCell.selectionLayer.isHidden = false
              diyCell.selectionType = selectionType
              
          } else {
              diyCell.circleImageView.isHidden = true
              diyCell.selectionLayer.isHidden = true
          }
      }
    
    
    func datesRange(from: Date, to: Date) -> [Date] {
        // in case of the "from" date is more than "to" date,
        // it should returns an empty array:
        if from > to { return [Date]() }

        var tempDate = from
        var array = [tempDate]

        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }

        return array
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //CURRENT IMPLEMENTATION ONLY WORKS FOR NON-OVERNIGHT PARKING
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //converts string Hour:Minutes into a date;
        startTime = timeFormatter1.date(from: timeRange[startScroller.selectedRow(inComponent: 0)])!
        endTime = timeFormatter1.date(from: timeRange[endScroller.selectedRow(inComponent: 0)])!
        var actualStartDate = Calendar.current.startOfDay(for: selectedDate); // beginning of day
        var actualStartTime = Date(timeIntervalSince1970: actualStartDate.timeIntervalSince1970 + startTime.timeIntervalSince1970 - Calendar.current.startOfDay(for:startTime).timeIntervalSince1970) // calculates actual start time from beginning of day from actualStartDate plus hours+minutes from startTime (previously from year 2000)
        var actualEndTime = Date(timeIntervalSince1970: actualStartDate.timeIntervalSince1970+endTime.timeIntervalSince1970-Calendar.current.startOfDay(for: endTime).timeIntervalSince1970) // calculates actual start end from beginning of day from actualStartDate plus hours+minutes from endTime (previously from year 2000)
        print("ID:1 - " + String(startTime.timeIntervalSince1970))
        print("ID:1 - " + String(endTime.timeIntervalSince1970))
        if let vc = segue.destination as? MapViewViewController {
            vc.shortTermStartTime = actualStartTime
            vc.shortTermEndTime = actualEndTime
            vc.shortTermDate = actualStartDate
        }
    }
    

}

extension hourlyTimeViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
            return cell
    }
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
            self.configure(cell: cell, for: date, at: position)
    }
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
           self.calendar.frame.size.height = bounds.height
          
    }
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
           return monthPosition == .current
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        // nothing selected:
        if selectedStartDate == nil {
            selectedStartDate = date
            datesRange = [selectedStartDate]
            self.configureVisibleCells()
            return
        }
        if selectedStartDate != nil && selectedEndDate == nil {
            if date <= selectedStartDate! {
                calendar.deselect(selectedStartDate!)
                selectedStartDate = date
                datesRange = [selectedStartDate!]
                self.configureVisibleCells()
                return
            }
            let range = datesRange(from: selectedStartDate!, to: date)
            selectedEndDate = range.last
            for d in range {
                calendar.select(d)
            }
            datesRange = range
            self.configureVisibleCells()
            return
        }
        // both are selected:
        if selectedStartDate != nil && selectedEndDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }
            selectedEndDate = nil
            selectedStartDate = nil
            datesRange = []
            self.configureVisibleCells()
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if selectedStartDate != nil && selectedEndDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }
            selectedEndDate = nil
            selectedStartDate = nil
            datesRange = []
        }
        self.configureVisibleCells()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        if date < yesterday{
            return UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        }
        else {
            return .black
        }
    }
    
//    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
//        monthPosition == .current
//        return true
//    }
    
    private func configureVisibleCells() {
            calendar.visibleCells().forEach { (cell) in
                let date = calendar.date(for: cell)
                let position = calendar.monthPosition(for: cell)
                self.configure(cell: cell, for: date!, at: position)
            }
        
        
        }
    
    /*
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
    }*/
    
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


extension hourlyTimeViewController: UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 96 // 4 * 24 hours
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let startRow = self.startScroller.selectedRow(inComponent: 0)
        let endRow = self.endScroller.selectedRow(inComponent: 0)
        if pickerView.tag == 1 { // start picker
            if startRow == 95 {
                self.endScroller.selectRow(95, inComponent: 0, animated: true)
                self.searchButton.isEnabled = false
                self.searchButton.backgroundColor = UIColor.init(red: 0.819, green: 0.788, blue: 0.847, alpha: 1.0)
                return
            }
            else if startRow > 91 {
                self.endScroller.selectRow(95, inComponent: 0, animated: true)
            }
            else if(startRow >= endRow) {
                self.endScroller.selectRow(startRow+4, inComponent: 0, animated: true)
            }
        } else { // end picker
            if(startRow >= endRow) {
                if endRow == 0 {
                    self.startScroller.selectRow(0, inComponent: 0, animated: true)
                    self.searchButton.isEnabled = false
                    self.searchButton.backgroundColor = UIColor.init(red: 0.819, green: 0.788, blue: 0.847, alpha: 1.0)
                    return
                }
                else if(endRow < 4) {
                    self.startScroller.selectRow(0, inComponent: 0, animated: true)
                }
                else if(startRow >= endRow) {
                    self.startScroller.selectRow(endRow-4, inComponent: 0, animated: true)
                }
            }
        }
        searchButton.isEnabled = true
        self.searchButton.backgroundColor = UIColor.init(red: 0.561, green: 0.1, blue: 0.941, alpha: 1.0)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.init(name: "Roboto-Medium", size: 18)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = self.timeRange[row]

        return pickerLabel!
    }
    
}

extension hourlyTimeViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.timeRange[row]
    }
    /*
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
    }*/
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let w = pickerView.frame.size.height
        return 0.25 * w;
    }
    
    
}



