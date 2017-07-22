//
//  WidgetTableViewCell.swift
//  ClearStyle
//
//  Created by Jonas Schafft on 1/12/2015.
//  Copyright (c) 2015 Jonas Schafft. All rights reserved.
//

import UIKit

class WidgetTableViewCell: UITableViewCell {

    @IBOutlet var cell_title: UILabel!
    @IBOutlet var cell_button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
