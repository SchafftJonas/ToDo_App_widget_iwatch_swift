//
//  StrikeThroughText.swift
//  ClearStyle
//
//  Created by Jonas Schafft on 1/12/2015.
//  Copyright (c) 2015 Jonas Schafft. All rights reserved.
//

import UIKit
import QuartzCore

// A UILabel subclass that can optionally have a strikethrough.
class StrikeThroughText: UITextField {
    let strikeThroughLayer: CALayer
    // A Boolean value that determines whether the label should have a strikethrough.
    var strikeThrough : Bool {
        didSet {
            strikeThroughLayer.isHidden = !strikeThrough
            if strikeThrough {
                resizeStrikeThrough()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        strikeThroughLayer = CALayer()
        strikeThroughLayer.backgroundColor = UIColor.black.cgColor
        strikeThroughLayer.isHidden = true
        strikeThrough = false
     
        super.init(frame: frame)
        layer.addSublayer(strikeThroughLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeStrikeThrough()
    }
    
    let kStrikeOutThickness: CGFloat = 1.0
    func resizeStrikeThrough() {
        strikeThroughLayer.frame = CGRect(x: 0, y: bounds.size.height/2,
            width: bounds.size.width - 20, height: kStrikeOutThickness)
    }
}
