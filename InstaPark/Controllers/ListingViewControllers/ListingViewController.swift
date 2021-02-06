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
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        
        //MARK: Moving from ListingAddress
        if let addressController = viewController as? ListingAddressViewController {
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
        //MARK: Moving from Comments
        if let commentsController = viewController as? CommentsViewController {
            parkingType = commentsController.parkingType
            if(commentsController.parkingType == .short) {
                ShortTermParking = commentsController.ShortTermParking
            } else {
                // pass in long term parking when ready
            }
            performSegue(withIdentifier: "toBooking", sender: nil)
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BookingViewController {
            vc.parkingType = parkingType
            if(parkingType == .short) {
                vc.ShortTermParking = ShortTermParking
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
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: controller)
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
            }
            setViewControllers([viewController],direction: .forward,animated: true,completion: nil)
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
