//
//  CustomHeader.swift
//  custom_uitablewview


import UIKit

class CustomHeader: UITableViewCell {

    @IBOutlet var section_title: UILabel!
    @IBOutlet var section_addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
