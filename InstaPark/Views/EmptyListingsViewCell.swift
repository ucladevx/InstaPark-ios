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
    @IBAction func createListing(_ sender: Any){
        
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "EmptyListingsViewCell", bundle: nil)
    }
    
    public func configure(){
        contentView.addSubview(emptyText)
        emptyText.text = "Oops! You do not have any active listings."
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
