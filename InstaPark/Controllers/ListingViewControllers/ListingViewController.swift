//
//  ListingViewController.swift
//  InstaPark
//
//  Created by Nathan Endow on 2/3/21.
//

import UIKit
import CoreLocation


class ListingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
   
    @IBOutlet var dot1: UIImageView!
    @IBOutlet var dot2: UIImageView!
    @IBOutlet var dot3: UIImageView!
    @IBOutlet var dot4: UIImageView!
    @IBOutlet var dot5: UIImageView!
    @IBOutlet var dot6: UIImageView!
    @IBOutlet var dot7: UIImageView!
    var dots = [UIImageView]()
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var pageControl: UIView!
    
    var coordinates: CLLocationCoordinate2D! // stores user's coordinates
    var address: String! // stores address entered in the search bar
    var parkingType: ParkingType = .short
    var ShortTermParking: ShortTermParkingSpot!
    var images = [UIImage]()
    var currentViewIndex: Int = 0
    
    @IBAction func leftButtonAction(_ sender: UIButton) {
        if currentViewIndex == 0 {
            performSegue(withIdentifier: "unwind", sender: nil)
        } else {
            setViewControllers([orderedViewControllers[currentViewIndex-1]], direction: .reverse, animated: true, completion:{(true) in
                        self.currentViewIndex -= 1
                        self.updatePageControl()
            })
        }
    }
    
    @IBAction func rightButtonAction(_ sender: UIButton) {
        if currentViewIndex == 6 {
            if let controller = orderedViewControllers[6] as? CommentsViewController {
                controller.moveToNext()
            }
        }else{
            guard transition(next:orderedViewControllers[currentViewIndex+1]) else {return}
            setViewControllers([orderedViewControllers[currentViewIndex+1]], direction: .forward, animated: true, completion:{(true) in
                        self.currentViewIndex += 1
                        self.updatePageControl()
            })
        }
    }
    
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
        if(viewControllerIndex != 6) {
            return orderedViewControllers[viewControllerIndex+1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let next = pendingViewControllers.first {
            transition(next:next)
        }
    }
    
    func transition(next:UIViewController) -> Bool {
        print("will transition to")
        let viewController = orderedViewControllers[currentViewIndex]
        //MARK: Moving from ListingAddress
        if let addressController = viewController as? ListingAddressViewController {
             if let next = next as? ListingTimesViewController {
                print("address to times")
                 guard addressController.checkBeforeMovingPages() else {
                    dataSource = nil
                    dataSource = self
                    return false}
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
                 if let next = next as? PriceViewController {
                    print("time to price")
                    guard timesController.checkBeforeMovingPages() else {
                       dataSource = nil
                       dataSource = self
                       return false}
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
             if let next = next as? ParkingTypeViewController {
                print("price to tag")
                guard priceController.checkBeforeMovingPages() else {
                   dataSource = nil
                   dataSource = self
                   return false}
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
             if let next = next as? PictureUploadViewController {
                print("tag to picture")
                guard tagController.checkBeforeMovingPages() else {
                   dataSource = nil
                   dataSource = self
                   return false}
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
             if let next = next as? DirectionsViewController {
                 print("picture to direction")
                guard picController.checkBeforeMovingPages() else {
                   dataSource = nil
                   dataSource = self
                   return false}
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
             if let next = next as? CommentsViewController {
                 print("direction to comments")
                guard directionsController.checkBeforeMovingPages() else {
                   dataSource = nil
                   dataSource = self
                   return false}
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
        return true
    }

    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        currentViewIndex = pageViewController.viewControllers!.first!.view.tag
        updatePageControl()
    }
    
    func updatePageControl() {
        if currentViewIndex == 6 {
            rightButton.setImage(UIImage(named: "listingDone"), for: .normal)
        }else {
            rightButton.setImage(UIImage(named: "rightPage"), for: .normal)
        }
        for i in 0..<currentViewIndex+1 {
            dots[i].image = UIImage(named: "pastPage")
        }
        for i in currentViewIndex+1..<7 {
            dots[i].image = UIImage(named: "futurePage")
        }
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
                vc.info = ParkingSpaceMapAnnotation.init(id: "", name: ShortTermParking.displayName, email: ShortTermParking.email, phoneNumber: ShortTermParking.phoneNumber, photo: ShortTermParking.photo, coordinate: CLLocationCoordinate2DMake(ShortTermParking.coordinates.lat, ShortTermParking.coordinates.long), price: ShortTermParking.pricePerHour, address: ShortTermParking.address, tags: ShortTermParking.tags, comments: ShortTermParking.comments, startTime: startTime, endTime: endTime, date: Date(), startDate: Date(), endDate: nil, images: [String]())
                if ShortTermParking.tags.isEmpty {
                    vc.info.tags = ["no", "tags", "passed"]
                }
            } else {
                // pass in long term parking when ready
            }
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        self.view.addSubview(pageControl)
        dots = [dot1,dot2,dot3,dot4,dot5,dot6,dot7]
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
//        view.addConstraint(NSLayoutConstraint(item: pageControl!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 5))
        
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
