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
    
    var startTime:NSDate = NSDate.init()
    var endTime:NSDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())! as NSDate
    var invalidDates:[String] = ["2020-11-14",
                                 "2020-11-15",
                                 "2020-11-16",
                                 "2020-11-21"]
    var selectedDate = Date.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        calendar.placeholderType = .none
        calendar.select(selectedDate as Date)
        
        startPicker.setDate(startTime as Date, animated: false)
        
        endPicker.setDate(endTime as Date, animated: false)
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
        delegate?.pass(start: startPicker.date as NSDate, end: endPicker.date as NSDate, date: selectedDate)
    }

}

extension AvailabilityViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let dateString : String = dateFormatter1.string(from:date)
        if self.invalidDates.contains(dateString) {
            return false
        }
        return true
    }

    //for blocked off dates
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarDelegateAppearance, titleDefaultColorFor date: Date) -> UIColor {
        let dateString : String = dateFormatter1.string(from: date)
        if self.invalidDates.contains(dateString){
            return .purple
        } else {
            return .black
        }
    }
}
