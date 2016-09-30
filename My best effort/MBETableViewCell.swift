//
//  MBETableViewCell.swift
//  My best effort
//
//  Created by iMac on 29.09.16.
//  Copyright © 2016 vasayCo. All rights reserved.
//

import UIKit

class MBETableViewCell: UITableViewCell {

    @IBOutlet var labelPlace: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var labelDate: UILabel!
    @IBOutlet var labelName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
