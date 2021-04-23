//
//  EmptyListingsViewCell.swift
//  InstaPark
//
//  Created by Daniel Hu on 4/13/21.
//

import UIKit

class EmptyListingsViewCell: UITableViewCell {
    
    static let identifier = "EmptyListingsViewCell"
    
    @IBOutlet weak var emptyText: UILabel!
    @IBOutlet weak var toListingBtn: UIButton!
    
    static func nib() -> UINib {
        return UINib(nibName: "EmptyListingsViewCell", bundle: nil)
    }
    
    public func configure(){
        contentView.addSubview(emptyText)
        emptyText.text = "Oops! You do not have any active listings."
        toListingBtn.layer.shadowRadius = 3.0
        toListingBtn.layer.shadowOpacity = 0.25
        toListingBtn.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        toListingBtn.layer.shadowColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
