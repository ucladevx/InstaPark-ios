//
//  MyListingsViewCell.swift
//  InstaPark
//
//  Created by Daniel Hu on 4/6/21.
//

import UIKit

class MyListingsViewCell: UITableViewCell {
    
    
    @IBOutlet weak var customerRequest: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Time: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
