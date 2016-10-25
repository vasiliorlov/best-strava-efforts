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
        let color1 = UIColor(red: 240/255, green: 120/255, blue: 35/255, alpha: 1).CGColor
        let color2 = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).CGColor
        let gradLayer = CAGradientLayer()
        gradLayer.frame = self.contentView.bounds
        gradLayer.startPoint = CGPoint(x: 0, y: 0)
        gradLayer.endPoint = CGPoint(x: 1, y: 1)
        gradLayer.colors = [color1,color2]
        
        self.layer.insertSublayer(gradLayer, atIndex: 0)
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
