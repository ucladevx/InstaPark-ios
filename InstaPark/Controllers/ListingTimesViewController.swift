//
//  ListingTimesViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 1/20/21.
//

import UIKit
import FSCalendar

class ListingTimesViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    @IBOutlet var infoPopup: UIView!
    @IBOutlet var blackScreen: UIView!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var weekdaysBtn: UIButton!
    @IBOutlet weak var weekendsBtn: UIButton!
    @IBOutlet weak var startScroller: UIPickerView!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var endScroller: UIPickerView!
    @IBOutlet weak var startEndLabels: UIStackView!
    @IBOutlet weak var arrow: UIImageView!
    
    var twentyFourHourAccess = false
    var weekdaysOnly = false
    var weekendsOnly = false
    fileprivate weak var calendar: FSCalendar!
    var timeRange = [String]()
    
    // saved variables
    var startTime = Date() //daily start time
    var endTime = Date.init(timeIntervalSinceNow: 60*60) //daily end time
    var selectedDate = Date() //selected date
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 340, height: 240))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.placeholderType = .none
        calendar.select(Date() as Date)
        calendar.appearance.titleFont = .boldSystemFont(ofSize: 16)
        calendar.appearance.headerTitleFont = .boldSystemFont(ofSize: 16)
        calendar.appearance.todayColor = .clear
        calendar.appearance.headerTitleColor = UIColor.init(red: 143.0/255, green: 0.0, blue: 1.0, alpha: 1.0)
        calendar.appearance.titleSelectionColor = .black
        calendar.firstWeekday = 1
        calendar.weekdayHeight = 0
        
        
        calendarView.addSubview(calendar)
        self.calendar = calendar
        
       // calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "CELL")
        
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
    
    // MARK: call this before passing - this saves all the variables needed
    func getAllValues() {
        if(twentyFourHourAccess) {
            startTime = timeFormatter1.date(from: "12:00 AM")!
            endTime = timeFormatter1.date(from: "11:45 PM")!
        } else {
            startTime = timeFormatter1.date(from: timeRange[startScroller.selectedRow(inComponent: 0)])!
            endTime = timeFormatter1.date(from: timeRange[endScroller.selectedRow(inComponent: 0)])!
        }
        selectedDate = calendar.selectedDate!
    }
    
    @IBAction func infoBtn(_ sender: Any) {
        blackScreen.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(blackScreen)
        self.view.addSubview(infoPopup)
        infoPopup.center = self.view.center
    }
    
    @IBAction func removeInfoPopup(_ sender: Any) {
        blackScreen.removeFromSuperview()
        infoPopup.removeFromSuperview()
    }
    
    @IBAction func weekdaysBtn(_ sender: Any) {
        if weekdaysOnly {
            weekdaysBtn.setBackgroundImage(UIImage.init(systemName: "square"), for: .normal)
            weekdaysBtn.tintColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
            weekdaysOnly = false
        } else {
            weekdaysBtn.setBackgroundImage(UIImage.init(systemName: "checkmark.square.fill"), for: .normal)
            weekdaysBtn.tintColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            weekdaysOnly = true
        }
        calendar.reloadData()
    }
    
    @IBAction func weekendsBtn(_ sender: Any) {
        if weekendsOnly {
            weekendsBtn.setBackgroundImage(UIImage.init(systemName: "square"), for: .normal)
            weekendsBtn.tintColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
            weekendsOnly = false
        } else {
            weekendsBtn.setBackgroundImage(UIImage.init(systemName: "checkmark.square.fill"), for: .normal)
            weekendsBtn.tintColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            weekendsOnly = true
        }
        calendar.reloadData()
    }
    
    @IBAction func accessSwitch(_ sender: Any) {
        twentyFourHourAccess = !twentyFourHourAccess
        if(!twentyFourHourAccess) {
            startEndLabels.isHidden = false
            startScroller.isHidden = false
            endScroller.isHidden = false
            arrow.isHidden = false
        } else {
            startEndLabels.isHidden = true
            startScroller.isHidden = true
            endScroller.isHidden = true
            arrow.isHidden = true
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
        formatter1.dateFormat = "h:mm a"
        return formatter1
    }()
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //selectedDate = date
    }
    
    // MARK: FScalendar
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let weekday = Calendar.current.component(.weekday, from: date)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        if weekdaysOnly && (weekday == 1 || weekday == 7){
            return UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        }
        else if weekendsOnly && (weekday == 2 || weekday == 3 || weekday == 4 || weekday == 5 || weekday == 6){
            return UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        } else if date < yesterday{
            return UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        }
        else {
            return .black
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        //0.76    1.00    0.81
        return UIColor.init(red: 213.0/255, green: 159.0/255, blue: 1.0, alpha: 1.0)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        if date < yesterday{
            return false
        }
        else if weekdaysOnly && (weekday == 1 || weekday == 7){
            return false
        }
        else if weekendsOnly && (weekday == 2 || weekday == 3 || weekday == 4 || weekday == 5 || weekday == 6){
            return  false
        }
        return true
    }
}

//extension ListingTimesViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//
//    }
//}

extension ListingTimesViewController: UIPickerViewDelegate {
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
               // self.searchButton.isEnabled = false
              //  self.searchButton.backgroundColor = UIColor.init(red: 0.819, green: 0.788, blue: 0.847, alpha: 1.0)
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
                    //self.searchButton.isEnabled = false
                    //self.searchButton.backgroundColor = UIColor.init(red: 0.819, green: 0.788, blue: 0.847, alpha: 1.0)
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
        //searchButton.isEnabled = true
        //self.searchButton.backgroundColor = UIColor.init(red: 0.561, green: 0.1, blue: 0.941, alpha: 1.0)
       
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

extension ListingTimesViewController: UIPickerViewDataSource {
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

