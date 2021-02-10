//
//  ListingViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 2/3/21.
//

import UIKit
import CoreLocation


class ListingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
   
    var coordinates: CLLocationCoordinate2D! // stores user's coordinates
    var address: String! // stores address entered in the search bar
    var parkingType: ParkingType = .short
    var ShortTermParking: ShortTermParkingSpot!
    var images = [UIImage]()
    var currentViewIndex: Int = 0
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else{
            return nil
        }
        print("view controller index from func: \(viewControllerIndex)\nview controller from current index variable: \(currentViewIndex)")
        let nextIndex = viewControllerIndex + 1
        
        //MARK: Moving from ListingAddress
        if viewControllerIndex == currentViewIndex {
            if let addressController = viewController as? ListingAddressViewController {
                 print("address to times")
                 if let next = orderedViewControllers[nextIndex] as? ListingTimesViewController {
                     if !addressController.checkBeforeMovingPages() {
                         //not configured yet
                     }
                     next.parkingType = addressController.parkingType
                     if(addressController.parkingType == .short) {
                         next.ShortTermParking = addressController.ShortTermParking
                     } else {
                         // pass in long term parking when ready
                     }
                     return next;
                 }
             }
        }
        
        if(nextIndex != 7) {
            return orderedViewControllers[nextIndex]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print("will transition to")
        
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: pendingViewControllers.first!) else {
            return
        }
        let nextIndex = viewControllerIndex
       // print("next view controller: \(nextIndex)")
        let viewController = orderedViewControllers[currentViewIndex]
        
        if let addressController = viewController as? ListingAddressViewController {
             print("address to times")
             if let next = orderedViewControllers[nextIndex] as? ListingTimesViewController {
                 if !addressController.checkBeforeMovingPages() {
                     //not configured yet
                 }
                 next.parkingType = addressController.parkingType
                 if(addressController.parkingType == .short) {
                     next.ShortTermParking = addressController.ShortTermParking
                 } else {
                     // pass in long term parking when ready
                 }
             }
         }
         //MARK: Moving from ListingTimes
         if let timesController = viewController as? ListingTimesViewController {
             print("time to price")
                 if let next = orderedViewControllers[nextIndex] as? PriceViewController {
                     if !timesController.checkBeforeMovingPages() {
                         //not configured yet
                     }
                     next.parkingType = timesController.parkingType
                     if(timesController.parkingType == .short) {
                         next.ShortTermParking = timesController.ShortTermParking
                     } else {
                         // pass in long term parking when ready
                     }
                 }
         }
         //MARK: Moving from Price
         if let priceController = viewController as? PriceViewController {
             print("price to tag")
             if let next = orderedViewControllers[nextIndex] as? ParkingTypeViewController {
                 if !priceController.checkBeforeMovingPages() {
                     //not configured yet
                 }
                 next.parkingType = priceController.parkingType
                 if(priceController.parkingType == .short) {
                     next.ShortTermParking = priceController.ShortTermParking
                 } else {
                     // pass in long term parking when ready
                 }
             }
             
         }
         //MARK: Moving from ParkingType/Tags view
         if let tagController = viewController as? ParkingTypeViewController {
             print("tag to picture")
             if let next = orderedViewControllers[nextIndex] as? PictureUploadViewController {
                 if !tagController.checkBeforeMovingPages() {
                     //not configured yet
                 }
                 next.parkingType = tagController.parkingType
                 if(tagController.parkingType == .short) {
                     next.ShortTermParking = tagController.ShortTermParking
                 } else {
                     // pass in long term parking when ready
                 }
            }
             
         }
         //MARK: Moving from Picture
         if let picController = viewController as? PictureUploadViewController {
             print("picture to direction")
             if let next = orderedViewControllers[nextIndex] as? DirectionsViewController {
                 if !picController.checkBeforeMovingPages() {
                     //not configured yet
                 }
                 next.parkingType = picController.parkingType
                 next.images = picController.images
                 if(picController.parkingType == .short) {
                     next.ShortTermParking = picController.ShortTermParking
                 } else {
                     // pass in long term parking when ready
                 }
                next.view.layoutIfNeeded()
             }
             
         }
         //MARK: Moving from Directions
         if let directionsController = viewController as? DirectionsViewController {
             print("direction to comments")
             if let next = orderedViewControllers[nextIndex] as? CommentsViewController {
                 if !directionsController.checkBeforeMovingPages() {
                     //not configured yet
                 }
                 next.parkingType = directionsController.parkingType
                 next.images = directionsController.images
                 if(directionsController.parkingType == .short) {
                     next.ShortTermParking = directionsController.ShortTermParking
                    if parkingType == .short { //check pass
                        print("checking successful passing of data so far...")
                        print(next.ShortTermParking.times)
                        print("Parking price is: \(next.ShortTermParking.pricePerHour)")
                        print(next.ShortTermParking.coordinates)
                        print(next.ShortTermParking.address)
                        print("Tags: \(next.ShortTermParking.tags)")
                        print("Directions: \(next.ShortTermParking.directions)")
                        print("Number of images: \(next.images.count)")
                    }
                 } else {
                     // pass in long term parking when ready
                 }
                next.view.layoutIfNeeded()
            }
         }
         //MARK: Moving from Comments
         if let commentsController = viewController as? CommentsViewController {
             print("comments to booking")
             parkingType = commentsController.parkingType
             if(commentsController.parkingType == .short) {
                 ShortTermParking = commentsController.ShortTermParking
                 images = commentsController.images
             } else {
                 // pass in long term parking when ready
             }
         }
    }

    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: previousViewControllers.last!) else {
            return
        }
        currentViewIndex = viewControllerIndex + 1
        print("page changed to: \(currentViewIndex)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BookingViewController {
            vc.parkingType = parkingType
            if(parkingType == .short) {
                vc.ShortTermParking = ShortTermParking
                var startTime: Date = Date()
                var endTime: Date = Date()
                for i in 0...6 {
                    let day = ShortTermParking.times[i]
                    if day?.isEmpty == false {
                        startTime = Date.init(timeIntervalSince1970: TimeInterval(day![0].start))
                        print(startTime)
                        endTime = Date.init(timeIntervalSince1970: TimeInterval(day![0].end))
                        break
                    }
                }
                vc.images = images
                vc.ShortTermParking = ShortTermParking
                var address = ShortTermParking.address.street
                address += ", " + ShortTermParking.address.city
                address += ", " + ShortTermParking.address.state + " " + ShortTermParking.address.zip
                vc.listing = true
                vc.info = ParkingSpaceMapAnnotation.init(id: "", name: "", coordinate: CLLocationCoordinate2DMake(ShortTermParking.coordinates.lat, ShortTermParking.coordinates.long), price: ShortTermParking.pricePerHour, address: ShortTermParking.address, tags: ShortTermParking.tags, comments: ShortTermParking.comments, startTime: startTime, endTime: endTime, date: Date(), startDate: Date(), endDate: nil)
                if ShortTermParking.tags.isEmpty {
                    vc.info.tags = ["no", "tags", "passed"]
                }
            } else {
                // pass in long term parking when ready
            }
        }
    }
    
    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(controller: "Listing1"),
                self.newViewController(controller: "Listing2"),
                self.newViewController(controller: "Listing3"),
                self.newViewController(controller: "Listing4"),
                self.newViewController(controller: "Listing5"),
                self.newViewController(controller: "Listing6"),
                self.newViewController(controller: "Listing7"),]
    }()

    private func newViewController(controller: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: controller)
    }

    var pageControl = UIPageControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let viewController = orderedViewControllers.first {
            if let firstViewController = orderedViewControllers.first as? ListingAddressViewController {
            firstViewController.parkingType = parkingType
            if(parkingType == .short) {
                firstViewController.ShortTermParking = ShortTermParking
            } else {
                // pass in long term parking when ready
            }
                setViewControllers([firstViewController],direction: .forward,animated: true,completion: nil)
                return
            }
            setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
        }
        
    }
    
    
    
    override func viewDidLayoutSubviews() {
        //corrects scrollview frame to allow for full-screen view controller pages
        for subView in self.view.subviews {
            if subView is UIScrollView {
                subView.frame = self.view.bounds
            }
        }
        super.viewDidLayoutSubviews()
    }
    
}
