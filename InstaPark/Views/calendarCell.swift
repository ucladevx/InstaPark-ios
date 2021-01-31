//
//  calendarCell.swift
//  InstaPark
//
//  Created by Yili Liu on 1/30/21.
//


import Foundation
import FSCalendar
import UIKit

enum SelectionType : Int {
    case none
    case single
    case leftBorder
    case middle
    case rightBorder
}


class DIYCalendarCell: FSCalendarCell {
    
    weak var circleImageView: UIImageView!
    weak var selectionLayer: CAShapeLayer!
    
    var selectionType: SelectionType = .none {
        didSet {
            setNeedsLayout()
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let circleImageView = UIImageView(image: UIImage(systemName: "circle")!)
        self.contentView.insertSubview(circleImageView, at: 0)
        self.circleImageView = circleImageView
        
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor.init(red: 213.0/255, green: 159.0/255, blue: 1.0, alpha: 1.0).cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
        
        self.shapeLayer.isHidden = true
        
        let view = UIView(frame: self.bounds)
       // view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.12)
        self.backgroundView = view;
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.circleImageView.frame = self.contentView.bounds
        self.backgroundView?.frame = self.bounds.insetBy(dx: 1, dy: 1)
        self.selectionLayer.frame = self.contentView.bounds
        
        if selectionType == .middle {
            self.selectionLayer.path = UIBezierPath(rect: self.selectionLayer.bounds).cgPath
            self.selectionLayer.fillColor = UIColor.init(red: 213.0/255, green: 159.0/255, blue: 1.0, alpha: 0.5).cgColor
        }
        else if selectionType == .leftBorder {
            self.selectionLayer.path = UIBezierPath(roundedRect: self.selectionLayer.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: self.selectionLayer.frame.width / 1.5, height: self.selectionLayer.frame.width / 1.5)).cgPath
            selectionLayer.fillColor = UIColor.init(red: 213.0/255, green: 159.0/255, blue: 1.0, alpha: 1.0).cgColor
        }
        else if selectionType == .rightBorder {
            self.selectionLayer.path = UIBezierPath(roundedRect: self.selectionLayer.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: self.selectionLayer.frame.width / 1.5, height: self.selectionLayer.frame.width / 1.5)).cgPath
            selectionLayer.fillColor = UIColor.init(red: 213.0/255, green: 159.0/255, blue: 1.0, alpha: 1.0).cgColor
        }
        else if selectionType == .single {
            let diameter: CGFloat = min(self.selectionLayer.frame.height, self.selectionLayer.frame.width)
            self.selectionLayer.path = UIBezierPath(ovalIn: CGRect(x: self.contentView.frame.width / 2 - diameter / 2, y: self.contentView.frame.height / 2 - diameter / 2, width: diameter, height: diameter)).cgPath
            selectionLayer.fillColor = UIColor.init(red: 213.0/255, green: 159.0/255, blue: 1.0, alpha: 1.0).cgColor
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        // Override the build-in appearance configuration
        if self.isPlaceholder {
            self.eventIndicator.isHidden = true
            self.titleLabel.textColor = UIColor.lightGray
        }
    }
    
}
