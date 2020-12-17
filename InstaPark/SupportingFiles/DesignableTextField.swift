//
//  DesignableTextField.swift
//  InstaPark
//
//  Created by Amy Seo on 11/14/20.
//

import Foundation
import UIKit

@IBDesignable
class DesignableTextField: UITextField, UITextFieldDelegate {
    
    @IBInspectable var padding: CGFloat = 0
    @IBInspectable var leadingImage: UIImage? { didSet { updateView() }}
    @IBInspectable var rtl: Bool = false { didSet { updateView() }}
    @IBInspectable var linesWidth: CGFloat = 1.0 { didSet{ drawLines() } }
    @IBInspectable var linesColor: UIColor = UIColor.black { didSet{ drawLines() } }
    @IBInspectable var bottomLine: Bool = false { didSet{ drawLines() } }

    //Padding images on left
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += padding
        return textRect
    }

    //Padding images on Right
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x -= padding
        return textRect
    }

    func drawLines() {
        if bottomLine {
            let border = CALayer()
            border.frame = CGRect(x: 0.0, y: frame.size.height - linesWidth + 8, width: frame.size.width, height: linesWidth)
            border.backgroundColor = linesColor.cgColor
            layer.addSublayer(border)
        }
    }

    func updateView() {
        drawLines()

        rightViewMode = UITextField.ViewMode.never
        rightView = nil
        leftViewMode = UITextField.ViewMode.never
        leftView = nil

        if let image = leadingImage {
            leftViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: 0, y: -3, width: 20, height: 20))
            imageView.image = image
            
//            let button = UIButton(type: .custom)
//            button.frame = CGRect(x: 0, y: 0, width: 20, height: 10)
//            button.setImage(image, for: .normal)
//
//            if rtl {
//                rightViewMode = UITextField.ViewMode.always
//                rightView = imageView
//            } else {
//                leftViewMode = UITextField.ViewMode.always
//                leftView = imageView
//            }
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 27, height: 10)) // has 5 point higher in width in imageView
            view.addSubview(imageView)
            leftView = view
        }
    }
}
