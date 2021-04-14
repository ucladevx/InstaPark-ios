//
//  ListingTimesViewController.swift
//  InstaPark
//
//  Created by Yili Liu on 1/20/21.
//

import UIKit
import FSCalendar

class ListingTimesViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UIScrollViewDelegate, CustomSegmentedControlDelegate{
    @IBOutlet var infoPopup: UIView!
    @IBOutlet var blackScreen: UIView!
    @IBOutlet var scrollView: UIScrollView!
    
    var blackInfoView: UIView!
    
//    @IBOutlet weak var timeSegmentedControl: UIView!
//    @IBOutlet weak var timeSegmentDescription: UILabel!
    var tabs: CustomSegmentedControl!
    @IBOutlet weak var segmentedView: UIView!
    @IBOutlet var standardTimeView: UIView!
    @IBOutlet var customTimePopip: UIView!
    @IBOutlet weak var customStartScroller: UIPickerView!
    @IBOutlet weak var customEndScroller: UIPickerView!
    var standardTime = true
    let animationTime = SlideViewConstant.animationTime
    var originalCenterOfslideUpView = CGFloat()
    var totalDistance = CGFloat()
    
    //custom time view
    @IBOutlet var customTimeView: UIView!
    @IBOutlet weak var sundayStart: UIButton!
    @IBOutlet weak var sundayEnd: UIButton!
    @IBOutlet weak var mondayStart: UIButton!
    @IBOutlet weak var mondayEnd: UIButton!
    @IBOutlet weak var tuesdayStart: UIButton!
    @IBOutlet weak var tuesdayEnd: UIButton!
    @IBOutlet weak var wednesdayStart: UIButton!
    @IBOutlet weak var wednesdayEnd: UIButton!
    @IBOutlet weak var thursdayStart: UIButton!
    @IBOutlet weak var thursdayEnd: UIButton!
    @IBOutlet weak var fridayStart: UIButton!
    @IBOutlet weak var fridayEnd: UIButton!
    @IBOutlet weak var saturdayStart: UIButton!
    @IBOutlet weak var saturdayEnd: UIButton!
    var currentStartTimeView: UIButton!
    var currentEndTimeView: UIButton!
    var selectedDayOfWeek: Int!
    
    @IBOutlet weak var advancedOptionsBtn: UIButton!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var calendarBackground: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var weekdaysBtn: UIButton!
    @IBOutlet weak var weekendsBtn: UIButton!
    @IBOutlet weak var startScroller: UIPickerView!
    //@IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var endScroller: UIPickerView!
//    @IBOutlet weak var startEndLabels: UIStackView!
//    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var calendar: FSCalendar!
    
    //advanced options
    @IBOutlet weak var advancedOptionsCheckStack: UIStackView!
    @IBOutlet weak var sunday: UIButton!
    @IBOutlet weak var monday: UIButton!
    @IBOutlet weak var tuesday: UIButton!
    @IBOutlet weak var wednesday: UIButton!
    @IBOutlet weak var thursday: UIButton!
    @IBOutlet weak var friday: UIButton!
    @IBOutlet weak var saturday: UIButton!
    @IBOutlet weak var advancedOptionsDayStack: UIStackView!
    var twentyFourHourAccess = false
    var weekdaysOnly = false
    var weekendsOnly = false
  //  fileprivate weak var calendar: FSCalendar!
    var timeRange = [String]()
    var daysOfWeek = [0: true, 1: true, 2: true, 3: true, 4: true, 5: true, 6:true]
    
    // saved variables
    var startTime:Int = 0 //daily start time
    var endTime:Int = 60*60*24-1 //daily end time
    var selectedStartDate: Date!
    var selectedEndDate: Date!
    var datesRange: [Date]?
    var parkingType: ParkingType = .short
    var ShortTermParking: ShortTermParkingSpot!
    //var LongTermParking : LongTermParkingSpot!
    
    var customTimes = [0: [ParkingTimeInterval](), 1: [ParkingTimeInterval](), 2: [ParkingTimeInterval](), 3:[ParkingTimeInterval](), 4:[ParkingTimeInterval](), 5:[ParkingTimeInterval](), 6:[ParkingTimeInterval]()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: calendarBackground.frame.width, height: 240))
        scrollView.delegate = self
        calendar.dataSource = self
        calendar.delegate = self
        calendar.placeholderType = .none
        //calendar.select(Date() as Date)
        calendar.backgroundColor = UIColor.init(red: 248.0/255.0, green: 240/255.0, blue: 1.0, alpha: 1.0)
        calendar.appearance.titleFont = .boldSystemFont(ofSize: 16)
        calendar.appearance.headerTitleFont = .boldSystemFont(ofSize: 16)
        calendar.appearance.todayColor = .clear
        calendar.appearance.headerTitleColor = UIColor.init(red: 143.0/255, green: 0.0, blue: 1.0, alpha: 1.0)
        calendar.appearance.borderRadius = 0.6
        calendar.appearance.titleSelectionColor = .black
        calendar.allowsMultipleSelection = true
        calendar.firstWeekday = 1
        calendar.weekdayHeight = 0
        calendar.rowHeight = 15
        calendar.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.swipeToChooseGesture.isEnabled = true
        let scopeGesture = UIPanGestureRecognizer(target: calendar, action: #selector(calendar.handleScopeGesture(_:)));
                calendar.addGestureRecognizer(scopeGesture)
        //calendarView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 18)
        calendar.roundBottomCorners(cornerRadius: 18)
        if calendar.selectedDates.count == 0 {
            startDateLabel.text = ""
            endDateLabel.text = ""
        }
        
        blackInfoView = UIView()
        
        
//        tabs = CustomSegmentedControl(frame: CGRect(x: 0, y: 0, width: self.timeSegmentedControl.frame.width, height: 35), buttonTitle: ["STANDARD","CUSTOM"])
//        tabs.backgroundColor = .clear
//        tabs.delegate = self
//        self.timeSegmentedControl.addSubview(tabs)
//        timeSegmentDescription.textColor = .darkGray
        
        advancedOptionsDayStack.isHidden = true
        advancedOptionsCheckStack.isHidden = true
        let days = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
        for day in days {
            day!.setBackgroundImage(UIImage.init(systemName: "checkmark.square.fill"), for: .normal)
            day!.tintColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            
        }
     
 //       calendarView.addSubview(calendar)
//        NSLayoutConstraint(item: calendar, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: calendarView, attribute: NSLayoutConstraint.Attribute.leadingMargin, multiplier: 1.0, constant: 0.0).isActive = true
//        NSLayoutConstraint(item: calendar, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: calendarView, attribute: NSLayoutConstraint.Attribute.trailingMargin, multiplier: 1.0, constant: 0.0).isActive = true
//        NSLayoutConstraint(item: calendar, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: calendarView, attribute: NSLayoutConstraint.Attribute.bottomMargin, multiplier: 1.0, constant: 0.0).isActive = true
//        self.calendar = calendar
        
        calendarBackground.layer.cornerRadius = 20
        calendarBackground.layer.shadowRadius = 5.0
        calendarBackground.layer.shadowOpacity = 0.35
        calendarBackground.layer.shadowOffset = CGSize.init(width: 1, height: 2)
        calendarBackground.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
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
        
        customStartScroller.delegate = self
        customStartScroller.dataSource = self
        customStartScroller.tag = 11
        customEndScroller.delegate = self
        customEndScroller.dataSource = self
        customEndScroller.tag = 12
        
        
        // round user's current time to ceiling in 15 min ranges
        let nextDiff = 15 - Calendar.current.component(.minute, from: Date()) % 15
        let todayDate = Calendar.current.date(byAdding: .minute, value: nextDiff, to: Date())
        let hourAfterNow = Calendar.current.date(byAdding: .hour, value: 1, to: todayDate!)
        let start = timeRange.firstIndex(of: timeFormatter1.string(from: todayDate!))!
        
        startScroller.selectRow(start, inComponent: 0, animated: false)
        endScroller.selectRow(start+4, inComponent: 0, animated: false)
        customStartScroller.selectRow(start, inComponent: 0, animated: false)
        customEndScroller.selectRow(start+4, inComponent: 0, animated: false)
        let customStartTime = getEpochTime(row: customStartScroller.selectedRow(inComponent: 0))//customStartScroller.selectedRow(inComponent: 0) * (15*60)
        let customEndTime = getEpochTime(row: customEndScroller.selectedRow(inComponent: 0))//customEndScroller.selectedRow(inComponent: 0) * (15*60)
        
//        self.segmentedView.addSubview(standardTimeView)
//        standardTimeView.frame =  CGRect(x: 0, y: 0, width: self.segmentedView.frame.width, height: 210)
        self.segmentedView.addSubview(customTimeView)
        customTimeView.frame =  CGRect(x: 0, y: 0, width: self.customTimeView.frame.width, height: 300)
        customTimeView.center.x = view.center.x
        standardTime = false
        let timeBtns = [sundayStart, sundayEnd, mondayStart, mondayEnd, tuesdayStart, tuesdayEnd, wednesdayStart, wednesdayEnd, thursdayStart, thursdayEnd, fridayStart, fridayEnd, saturdayStart, saturdayEnd]
        var count = 0
        for btn in timeBtns {
            btn?.setTitleColor(.black, for: .normal)
            btn?.layer.cornerRadius = 6
            btn?.layer.borderWidth = 1
            btn?.layer.borderColor = .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
            if count % 2 == 0 {
                btn?.setTitle(timeFormatter1.string(from: todayDate!), for: .normal)
                customTimes[count/2] = [ParkingTimeInterval(start: customStartTime, end: customEndTime)]
            } else {
                btn?.setTitle(timeFormatter1.string(from: hourAfterNow!), for: .normal)
            }
            count += 1
        }
        
        
        // set up custom popup
        customTimePopip.roundTopCorners(cornerRadius: 25.0)
        
        customTimePopip.frame = CGRect(x: 0, y: self.view.frame.height-238, width: self.view.frame.width, height: 270)
        customTimePopip.layer.shadowRadius = 7.0
        customTimePopip.layer.shadowOpacity = 0.3
        customTimePopip.layer.shadowOffset = CGSize.init(width: 1, height: -2)
        customTimePopip.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        customTimePopip.clipsToBounds = false
        customTimePopip.layoutIfNeeded()
        
        blackScreen.backgroundColor = UIColor(white: 0, alpha: 0.0)
        blackScreen.frame = self.view.frame
        blackScreen.frame.size.height = self.view.frame.height
        blackScreen.alpha = 0
        self.view.insertSubview(blackScreen, belowSubview:customTimePopip)
        blackScreen.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
       
        let downPan = UIPanGestureRecognizer(target: self, action: #selector(dismissslideUpView(_:)))
        customTimePopip.addGestureRecognizer(downPan)
    }
    
    // MARK: call this before passing - this saves all the variables needed
    func getAllValues() {
        if(twentyFourHourAccess) {
            startTime = 0
            endTime = 60*60*24-1;
        } else {
            //CHANGE TO seconds SINCE start of day
            startTime = startScroller.selectedRow(inComponent: 0) * (15*60);
            endTime = endScroller.selectedRow(inComponent: 0) * (15*60);
// =======
//             let startRow = startScroller.selectedRow(inComponent: 0)
//             let endRow = endScroller.selectedRow(inComponent: 0)
//             print("start time: \(startRow/4): \((startRow % 4) * 15)")
//             print("end time: \(endRow/4): \((endRow % 4) * 15)")
//             startTime = setTime(hour: startRow/4, minute: (startRow % 4) * 15)
//             endTime = setTime(hour: endRow/4, minute: (endRow % 4) * 15)
// >>>>>>> main
        }
        //selectedStartDate = calendar.selectedDate!
    }
    
    @IBAction func infoBtn(_ sender: Any) {
        blackInfoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        blackInfoView.backgroundColor = .black
        blackInfoView.alpha = 0.25
        self.view.addSubview(blackInfoView)
        self.view.addSubview(infoPopup)
        infoPopup.center = self.view.center
    }
    
    @IBAction func removeInfoPopup(_ sender: Any) {
        blackInfoView.removeFromSuperview()
        infoPopup.removeFromSuperview()
    }
    
    func setToChecked(for btn: UIButton) {
        btn.setBackgroundImage(UIImage.init(systemName: "checkmark.square.fill"), for: .normal)
        btn.tintColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
    }
    
    func setToUnchecked(for btn: UIButton) {
        btn.setBackgroundImage(UIImage.init(systemName: "square"), for: .normal)
        btn.tintColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
    }
    
    @IBAction func weekdaysBtn(_ sender: Any) {
        let timeBtns : [UIButton] = [sundayStart, sundayEnd, saturdayStart, saturdayEnd]
        if weekdaysOnly {
//            weekdaysBtn.setBackgroundImage(UIImage.init(systemName: "square"), for: .normal)
//            weekdaysBtn.tintColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
            setToUnchecked(for: weekdaysBtn)
            daysOfWeek[0] = true
            daysOfWeek[6] = true
            for btn in timeBtns {
                btn.isEnabled = true
                btn.backgroundColor = .clear
            }
            weekdaysOnly = false
            if advancedOptionsDayStack.isHidden == false {
                let days: [UIButton] = [sunday, saturday]
                for day in days {
                    setToChecked(for: day)
                }
            }
        } else {
//            weekdaysBtn.setBackgroundImage(UIImage.init(systemName: "checkmark.square.fill"), for: .normal)
//            weekdaysBtn.tintColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            setToChecked(for: weekdaysBtn)
            daysOfWeek[0] = false
            daysOfWeek[6] = false
            for btn in timeBtns {
                btn.isEnabled = false
                btn.backgroundColor =  UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
            }
            weekdaysOnly = true
            if advancedOptionsDayStack.isHidden == false {
                let days: [UIButton] = [sunday, saturday]
                for day in days {
                    setToUnchecked(for: day)
                }
            }
        }
        refreshCalendar()
        calendar.reloadData()
    }
    
    @IBAction func weekendsBtn(_ sender: Any) {
        let timeBtns : [UIButton] = [mondayStart, mondayEnd, tuesdayStart, tuesdayEnd, wednesdayStart, wednesdayEnd, thursdayStart, thursdayEnd, fridayStart, fridayEnd]
        if weekendsOnly {
//            weekendsBtn.setBackgroundImage(UIImage.init(systemName: "square"), for: .normal)
//            weekendsBtn.tintColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
            setToUnchecked(for:weekendsBtn)
            for i in 1...5 {
                daysOfWeek[i] = true
            }
            for btn in timeBtns {
                btn.isEnabled = true
                btn.backgroundColor = .clear
            }
            weekendsOnly = false
            if advancedOptionsDayStack.isHidden == false {
                let days: [UIButton] = [monday, tuesday, wednesday, thursday, friday]
                for day in days {
                    setToChecked(for: day)
                }
            }
        } else {
//            weekendsBtn.setBackgroundImage(UIImage.init(systemName: "checkmark.square.fill"), for: .normal)
//            weekendsBtn.tintColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            setToChecked(for: weekendsBtn)
            for i in 1...5 {
                daysOfWeek[i] = false
            }
            for btn in timeBtns {
                btn.isEnabled = false
                btn.backgroundColor =  UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
            }
            weekendsOnly = true
            if advancedOptionsDayStack.isHidden == false {
                let days: [UIButton] = [monday, tuesday, wednesday, thursday, friday]
                for day in days {
                    setToUnchecked(for: day)
                }
            }
        }
        refreshCalendar()
        calendar.reloadData()
    }
    
    func refreshCalendar(){
        for date in calendar.selectedDates {
            if !shouldSelectDate(for: date) {
                calendar.deselect(date)
            }
        }
    }
    
    @IBAction func accessSwitch(_ sender: Any) {
        twentyFourHourAccess = !twentyFourHourAccess
        if(!twentyFourHourAccess) {
//            timeSegmentDescription.isHidden = false
//            timeSegmentedControl.isHidden = false
            segmentedView.isHidden = false
//            startEndLabels.isHidden = false
//            startScroller.isHidden = false
//            endScroller.isHidden = false
//            arrow.isHidden = false
        } else {
//            startEndLabels.isHidden = true
//            startScroller.isHidden = true
//            endScroller.isHidden = true
//            arrow.isHidden = true
//            timeSegmentDescription.isHidden = true
//            timeSegmentedControl.isHidden = true
            segmentedView.isHidden = true
        }
    }
    
    @IBAction func advancedOptionsBtn(_ sender: Any) {
        if advancedOptionsDayStack.isHidden == true {
            let days: [UIButton] = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
            for i in 0...6 {
                if daysOfWeek[i] == true {
//                    days[i].setBackgroundImage(UIImage.init(systemName: "checkmark.square.fill"), for: .normal)
//                    days[i].tintColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
                    setToChecked(for: days[i])
                }
                else {
//                    days[i].setBackgroundImage(UIImage.init(systemName: "square"), for: .normal)
//                    days[i].tintColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
                    setToUnchecked(for: days[i])
                }
            }
            advancedOptionsDayStack.isHidden = false
            advancedOptionsCheckStack.isHidden = false
            return
        }
        else {
            advancedOptionsDayStack.isHidden = true
            advancedOptionsCheckStack.isHidden = true
        }
    }
    
    func changeState(day: Int, button: UIButton, customStartBtn: UIButton, customEndBtn: UIButton){
        if daysOfWeek[day] == false {
//            button.setBackgroundImage(UIImage.init(systemName: "checkmark.square.fill"), for: .normal)
//            button.tintColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
            setToChecked(for: button)
            daysOfWeek[day] = true
            customStartBtn.isEnabled = true
            customEndBtn.isEnabled = true
            customStartBtn.backgroundColor = .clear
            customEndBtn.backgroundColor = .clear
        } else {
//            button.setBackgroundImage(UIImage.init(systemName: "square"), for: .normal)
//            button.tintColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
            setToUnchecked(for: button)
            daysOfWeek[day] = false
            customStartBtn.isEnabled = false
            customEndBtn.isEnabled = false
            customStartBtn.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
            customEndBtn.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        }
        print(daysOfWeek)
        refreshCalendar()
        calendar.reloadData()
    }
    @IBAction func sunday(_ sender: Any) {
        changeState(day: 0, button: sunday, customStartBtn: sundayStart, customEndBtn: sundayEnd)
    }
    @IBAction func monday(_ sender: Any) {
        changeState(day: 1, button: monday, customStartBtn: mondayStart, customEndBtn: mondayEnd)
    }
    @IBAction func tuesday(_ sender: Any) {
        changeState(day: 2, button: tuesday, customStartBtn: tuesdayStart, customEndBtn: tuesdayEnd)
    }
    @IBAction func wednesday(_ sender: Any) {
        changeState(day: 3, button: wednesday, customStartBtn: wednesdayStart, customEndBtn: wednesdayEnd)
    }
    @IBAction func thursday(_ sender: Any) {
        changeState(day: 4, button: thursday, customStartBtn: thursdayStart, customEndBtn: thursdayEnd)
    }
    @IBAction func friday(_ sender: Any) {
        changeState(day: 5, button: friday, customStartBtn: fridayStart, customEndBtn: fridayEnd)
    }
    @IBAction func saturday(_ sender: Any) {
        changeState(day: 6, button: saturday, customStartBtn: saturdayStart, customEndBtn: saturdayEnd)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
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
    
    func setTime(hour: Int, minute: Int) -> Int {
        return hour*3600+minute*60
//        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
    }
    
    
    //MARK: custom time selection
    @IBAction func sunStart(_ sender: Any) {
        currentStartTimeView = sundayStart
        currentEndTimeView = sundayEnd
        selectedDayOfWeek = 0
        setUpCustomScrollers()
    }
    @IBAction func sunEnd(_ sender: Any) {
        currentStartTimeView = sundayStart
        currentEndTimeView = sundayEnd
        selectedDayOfWeek = 0
        setUpCustomScrollers()
    }
    @IBAction func monStart(_ sender: Any) {
        currentStartTimeView = mondayStart
        currentEndTimeView = mondayEnd
        selectedDayOfWeek = 1
        setUpCustomScrollers()
    }
    @IBAction func monEnd(_ sender: Any) {
        currentStartTimeView = mondayStart
        currentEndTimeView = mondayEnd
        selectedDayOfWeek = 1
        setUpCustomScrollers()
    }
    @IBAction func tuesStart(_ sender: Any) {
        currentStartTimeView = tuesdayStart
        currentEndTimeView = tuesdayEnd
        selectedDayOfWeek = 2
        setUpCustomScrollers()
    }
    @IBAction func tuesEnd(_ sender: Any) {
        currentStartTimeView = tuesdayStart
        currentEndTimeView = tuesdayEnd
        selectedDayOfWeek = 2
        setUpCustomScrollers()
    }
    @IBAction func wedStart(_ sender: Any) {
        currentStartTimeView = wednesdayStart
        currentEndTimeView = wednesdayEnd
        selectedDayOfWeek = 3
        setUpCustomScrollers()
    }
    @IBAction func wedEnd(_ sender: Any) {
        currentStartTimeView = wednesdayStart
        currentEndTimeView = wednesdayEnd
        selectedDayOfWeek = 3
        setUpCustomScrollers()
    }
    @IBAction func thurStart(_ sender: Any) {
        currentStartTimeView = thursdayStart
        currentEndTimeView = thursdayEnd
        selectedDayOfWeek = 4
        setUpCustomScrollers()
    }
    @IBAction func thurEnd(_ sender: Any) {
        currentStartTimeView = thursdayStart
        currentEndTimeView = thursdayEnd
        selectedDayOfWeek = 4
        setUpCustomScrollers()
    }
    @IBAction func friStart(_ sender: Any) {
        currentStartTimeView = fridayStart
        currentEndTimeView = fridayEnd
        selectedDayOfWeek = 5
        setUpCustomScrollers()
    }
    @IBAction func friEnd(_ sender: Any) {
        currentStartTimeView = fridayStart
        currentEndTimeView = fridayEnd
        selectedDayOfWeek = 5
        setUpCustomScrollers()
    }
    @IBAction func satStart(_ sender: Any) {
        currentStartTimeView = saturdayStart
        currentEndTimeView = saturdayEnd
        selectedDayOfWeek = 6
        setUpCustomScrollers()
    }
    @IBAction func satEnd(_ sender: Any) {
        currentStartTimeView = saturdayStart
        currentEndTimeView = saturdayEnd
        selectedDayOfWeek = 6
        setUpCustomScrollers()
    }
    
    func setUpCustomScrollers(){
        let start = timeRange.firstIndex(of: currentStartTimeView.titleLabel?.text ?? "12:00 AM")!
        let end = timeRange.firstIndex(of: currentEndTimeView.titleLabel?.text ?? "1:00 AM")!
        customStartScroller.selectRow(start, inComponent: 0, animated: false)
        customEndScroller.selectRow(end, inComponent: 0, animated: false)
        
        customTimePopip.layoutIfNeeded()
        totalDistance = 0
        self.customTimePopip.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height:300)
        
        UIView.animate(withDuration: TimeInterval(animationTime), animations: {
            self.blackScreen.alpha = 1
            self.view.addSubview(self.customTimePopip)
            self.customTimePopip.backgroundColor = UIColor.white
        }, completion: nil)
        customTimePopip.slideUpShow(animationTime)
        originalCenterOfslideUpView = customTimePopip.center.y
    }
    
    @objc func dismissslideUpView(_ gestureRecognizer:UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.customTimePopip)
        switch gestureRecognizer.state{
        case .began, .changed:
            gestureRecognizer.view!.center = CGPoint(x: self.customTimePopip.center.x, y: max(gestureRecognizer.view!.center.y + translation.y, originalCenterOfslideUpView))
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.customTimePopip)
            totalDistance += translation.y
            break
        case .ended:
            if gestureRecognizer.velocity(in: customTimePopip).y > 300 {
                handleDismiss()
            } else if totalDistance >= 0{
                UIView.animate(withDuration: TimeInterval(animationTime), delay: 0, options: [.curveEaseOut],
                               animations: {
                                self.customTimePopip.center.y -= self.totalDistance
                                self.customTimePopip.layoutIfNeeded()
                }, completion: nil)
                currentStartTimeView.setTitle(timeRange[self.customStartScroller.selectedRow(inComponent: 0)], for: .normal)
                currentEndTimeView.setTitle(timeRange[self.customEndScroller.selectedRow(inComponent: 0)], for: .normal)
            }
            totalDistance = 0
            break
        case .failed:
            print("Failed to do UIPanGestureRecognizer with slideUpView")
            break
        default:
            print("default: UIPanGestureRecognizer")
            break
        }
    }
    
    @objc func handleDismiss() {
        customTimePopip.slideDownHide(animationTime)
        UIView.animate(withDuration: TimeInterval(animationTime)) {
            self.blackScreen.alpha = 0
//            self.customTimePopip.removeFromSuperview()
        }

        currentStartTimeView.setTitle(timeRange[self.customStartScroller.selectedRow(inComponent: 0)], for: .normal)
        currentEndTimeView.setTitle(timeRange[self.customEndScroller.selectedRow(inComponent: 0)], for: .normal)
        
        let customStartTime = getEpochTime(row: customStartScroller.selectedRow(inComponent: 0))//customStartScroller.selectedRow(inComponent: 0) * (15*60)
        let customEndTime = getEpochTime(row: customEndScroller.selectedRow(inComponent: 0))//customEndScroller.selectedRow(inComponent: 0) * (15*60)
        customTimes[selectedDayOfWeek!] = [ParkingTimeInterval(start: customStartTime, end: customEndTime)]
                
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setUserTimeZoneTime(hour: Int, minute: Int) -> Date {
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
    }
    
    func getEpochTime(row: Int) -> Int {
        let userTimeZoneTime = setUserTimeZoneTime(hour: row/4, minute: (row%4) * 15)
        let delta = TimeInterval(-1 * TimeZone.current.secondsFromGMT())
        let UTCTime = userTimeZoneTime.addingTimeInterval(delta)
  
        let hour = Calendar.current.component(.hour, from: UTCTime)
        let minutes = Calendar.current.component(.minute, from: UTCTime)
        print("\(hour): \(minutes)")
        return (hour * 3600) + (minutes * 60)
    }
    
    func change(to index: Int) {
        if index == 0 {
            customTimeView.removeFromSuperview()
//            timeSegmentDescription.text = "Standard means the daily time frame does not change between different days."
//            timeSegmentDescription.textAlignment = .left
            self.segmentedView.addSubview(standardTimeView)
            standardTimeView.frame =  CGRect(x: 0, y: 0, width: self.segmentedView.frame.width, height: 210)
            standardTime = true
        } else {
            standardTimeView.removeFromSuperview()
//            timeSegmentDescription.text = "Custom allows for different time frames for each day."
//            timeSegmentDescription.textAlignment = .center
            self.segmentedView.addSubview(customTimeView)
            customTimeView.frame =  CGRect(x: 0, y: 0, width: self.customTimeView.frame.width, height: 300)
            customTimeView.center.x = segmentedView.center.x
            standardTime = false
        }
    }
    
    // MARK: - Navigation
    
    func checkBeforeMovingPages() -> Bool {
        getAllValues()
        if calendar.selectedDates.count == 0 {
            let alert = UIAlertController(title: "Error", message: "Please select at least one day on the calendar.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        if weekdaysOnly && weekendsOnly {
            let alert = UIAlertController(title: "Error", message: "Please select at least one valid date.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        var times = [0: [ParkingTimeInterval](), 1: [ParkingTimeInterval](), 2: [ParkingTimeInterval](), 3:[ParkingTimeInterval](), 4:[ParkingTimeInterval](), 5:[ParkingTimeInterval](), 6:[ParkingTimeInterval]()]
        if parkingType == .short {
            if twentyFourHourAccess {
                startTime = setTime(hour: 0, minute: 00)
                endTime = setTime(hour: 23, minute: 59)
            }
            else if standardTime {
                for i in 0...6 {
                    if daysOfWeek[i] == true {
                        times[i] = [ParkingTimeInterval(start: startTime, end: endTime)]
                    }
                }
            } else { // custom time
                times = customTimes
                for i in 0...6 {
                    if daysOfWeek[i] == false {
                        times[i] = [ParkingTimeInterval]()
                    }
                }
            }
            
//            if weekendsOnly {
//                times[5] = [ParkingTimeInterval(start: startTime, end: endTime)]
//                times[6] = [ParkingTimeInterval(start: startTime, end: endTime)]
//            }
//            else if weekdaysOnly {
//                for i in 0...4 {
//                    times[i] = [ParkingTimeInterval(start: startTime, end: endTime)]
//                }
//            }
//            else {
//                for i in 0...6 {
//                    times[i] = [ParkingTimeInterval(start: startTime, end: endTime)]
//                }
//            }
            ShortTermParking.times = times
            if selectedStartDate != nil {
                ShortTermParking.startDate = Int(selectedStartDate.timeIntervalSince1970)
            }
            if selectedEndDate != nil {
                ShortTermParking.endDate = Int(selectedEndDate.timeIntervalSince1970)
            } else {
                ShortTermParking.endDate = Int(selectedStartDate.timeIntervalSince1970)
            }
            
            print(ShortTermParking.times)
            return true
            
        }
        else { //LONGTERM parking
            return true
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
    
    // MARK: FScalendar
    func shouldSelectDate(for date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        if date < yesterday{
            return false
        }
        for i in 0...6 {
            if daysOfWeek[i] == false && weekday == i+1 {
                return false
            }
        }
        return true
    }
    
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
    
//    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
//        let weekday = Calendar.current.component(.weekday, from: date)
//        if weekdaysOnly && (weekday == 1 || weekday == 7){
//            return true
//        }
//        else if weekendsOnly && (weekday == 2 || weekday == 3 || weekday == 4 || weekday == 5 || weekday == 6){
//            return true
//        }
//        return true
//    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
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
                if shouldSelectDate(for: d) {
                    calendar.select(d)
                }
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
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
//        let weekday = Calendar.current.component(.weekday, from: date)
//        if weekdaysOnly && (weekday == 1 || weekday == 7){
//            self.calendar.deselect(date)
//        }
//        else if weekendsOnly && (weekday == 2 || weekday == 3 || weekday == 4 || weekday == 5 || weekday == 6){
//            self.calendar.deselect(date)
//        }
        return .black
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
//        let weekday = Calendar.current.component(.weekday, from: date)
//        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
//        if date < yesterday{
//            return UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
//        }
//        for i in 0...6 {
//            if daysOfWeek[i] == false && weekday == i+1 {
//                return UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
//            }
//        }
//        return .black
        if shouldSelectDate(for: date) {
            return .black
        }
        return UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        //0.76    1.00    0.81
        return UIColor.init(red: 213.0/255, green: 159.0/255, blue: 1.0, alpha: 1.0)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
//        let weekday = Calendar.current.component(.weekday, from: date)
//        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
//        if date < yesterday{
//            return false
//        }
//        for i in 0...6 {
//            if daysOfWeek[i] == false && weekday == i+1 {
//                return false
//            }
//        }
//        return true
        return shouldSelectDate(for: date)
    }

    private func configureVisibleCells() {
            calendar.visibleCells().forEach { (cell) in
                let date = calendar.date(for: cell)
                if !shouldSelectDate(for: date!) {
                    return
                }
                let position = calendar.monthPosition(for: cell)
                self.configure(cell: cell, for: date!, at: position)
            }
        }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        
        func formatDate(date: Date) -> String{
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            return formatter.string(from: date)
        }
        if selectedStartDate != nil {
            startDateLabel.text = formatDate(date: selectedStartDate)
        }
        else {
            startDateLabel.text = ""
        }
        if selectedEndDate != nil {
            endDateLabel.text = formatDate(date: selectedEndDate)
        }
        else {
            endDateLabel.text = ""
        }
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
        
        let customStartRow = self.customStartScroller.selectedRow(inComponent: 0)
        let customEndRow = self.customEndScroller.selectedRow(inComponent: 0)
        print("custom time scrollers - rows \(customStartRow) to \(customEndRow)")
        
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
        }
        else if pickerView.tag == 2 { // end picker
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
        else if pickerView.tag == 11 { // custom start picker
            if customStartRow == 95 {
                self.customEndScroller.selectRow(95, inComponent: 0, animated: true)
                return
            }
            else if customStartRow > 91 {
                self.customEndScroller.selectRow(95, inComponent: 0, animated: true)
            }
            else if(customStartRow >= customEndRow) {
                self.customEndScroller.selectRow(customStartRow+4, inComponent: 0, animated: true)
            }
        }
        else if pickerView.tag == 12 { //custom end picker
            if(customStartRow >= customEndRow) {
                if endRow == 0 {
                    self.customStartScroller.selectRow(0, inComponent: 0, animated: true)
                    return
                }
                else if(customEndRow < 4) {
                    self.customStartScroller.selectRow(0, inComponent: 0, animated: true)
                }
                else if(customStartRow >= customEndRow) {
                    self.customStartScroller.selectRow(customEndRow-4, inComponent: 0, animated: true)
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

extension UIView {
    func roundBottomCorners(cornerRadius: Double) {
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    func roundTopCorners(cornerRadius: Double) {
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
