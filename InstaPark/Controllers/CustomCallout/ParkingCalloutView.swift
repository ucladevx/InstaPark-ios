//
//  ParkingCallout.swift
//  InstaPark
//
//  Created by Yili Liu on 10/31/20.
//  This code is adapted from Robert Ryan under the Creative Commons Attribution-ShareAlike 4.0 International License.
//

import UIKit
import MapKit

protocol ParkingCalloutViewDelegate: class {
    func mapView(_ mapView: MKMapView, didTapDetailsButton button: UIButton, for annotation: MKAnnotation)
}

class ParkingCalloutView: CalloutView {

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.font = .boldSystemFont(ofSize: 16)
        return label
    }()

    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.font = .preferredFont(forTextStyle: .caption1)
        return label
    }()

    private var detailsButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Book", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 13)
        button.backgroundColor = UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)
        button.layer.cornerRadius = 15

        return button
    }()

    override init(annotation: MKAnnotation) {
        super.init(annotation: annotation)

        configure()

        updateContents(for: annotation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Should not call init(coder:)")
    }


    private func updateContents(for annotation: MKAnnotation) {
        let parkingSpace = annotation as! ParkingSpaceMapAnnotation
        
        //title customization
        let name = parkingSpace.name
        let name_attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 19), NSAttributedString.Key.foregroundColor : UIColor.black]
        let title = NSMutableAttributedString(string:name, attributes:name_attrs)
        
        let price = "   $" + String(parkingSpace.price)
        let price_attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 19), NSAttributedString.Key.foregroundColor : UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)]
        let price_string = NSMutableAttributedString(string:price, attributes:price_attrs)
        title.append(price_string)
        
        let hour = "/hr"
        let hour_attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.init(red: 0.380, green: 0.0, blue: 1.0, alpha: 1.0)]
        let hour_string = NSMutableAttributedString(string:hour, attributes:hour_attrs)
        title.append(hour_string)
        
        self.titleLabel.attributedText = title
        
        //subtitle customization
        let available = "Available "
        let available_attrs = [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.gray]
        let subtitle = NSMutableAttributedString(string:available, attributes:available_attrs)
        /*
        let time = parkingSpace.time
        let time_attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.black]
        let time_string = NSMutableAttributedString(string:time, attributes:time_attrs)
        subtitle.append(time_string)
        
        self.subtitleLabel.attributedText = subtitle */
    }

    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(detailsButton)
        detailsButton.addTarget(self, action: #selector(didTapDetailsButton(_:)), for: .touchUpInside)

        let views: [String: UIView] = [
            "titleLabel": titleLabel,
            "subtitleLabel": subtitleLabel,
            "detailsButton": detailsButton
        ]

        let vflStrings = [
            "V:|-[titleLabel]-[subtitleLabel]-[detailsButton]-|",
            "H:|-[titleLabel]-|",
            "H:|-[subtitleLabel]-|",
            "H:|-[detailsButton]-|"
        ]

        for vfl in vflStrings {
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vfl, metrics: nil, views: views))
        }
    }

    override func didTouchUpInCallout(_ sender: Any) {
        print("didTouchUpInCallout")
    }

    @objc func didTapDetailsButton(_ sender: UIButton) {
        if let mapView = mapView, let delegate = mapView.delegate as? ParkingCalloutViewDelegate {
            delegate.mapView(mapView, didTapDetailsButton: sender, for: annotation!)
        }
    }

    var mapView: MKMapView? {
        var view = superview
        while view != nil {
            if let mapView = view as? MKMapView { return mapView }
            view = view?.superview
        }
        return nil
    }
}
