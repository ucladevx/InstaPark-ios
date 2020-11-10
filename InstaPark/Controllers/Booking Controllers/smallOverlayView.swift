//
//  smallOverlayView.swift
//  InstaPark
//
//  Created by Yili Liu on 11/6/20.
//

import Foundation
import UIKit

struct SlideViewConstant {
    static let slideViewHeight: CGFloat = 280
    static let cornerRadiusOfSlideView: CGFloat = 20
    static let animationTime: CGFloat = 0.3
    
}

class SlideView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

}
