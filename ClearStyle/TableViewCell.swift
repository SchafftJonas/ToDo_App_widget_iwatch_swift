//
//  TableViewCell.swift
//  ClearStyle
//
//  Created by Jonas Schafft on 1/12/2015.
//  Copyright (c) 2015 Jonas Schafft. All rights reserved.
//

import UIKit
import QuartzCore

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol TableViewCellDelegate {
    // indicates that the given item has been deleted
    func toDoItemDeleted(_ todoItem: ToDoItem, section:Int)
    // Indicates that the edit process has begun for the given cell
    func cellDidBeginEditing(_ editingCell: TableViewCell)
    // Indicates that the edit process has committed for the given cell
    func cellDidEndEditing(_ editingCell: TableViewCell)
    
    func moveItemToBottomOfSection(_ toDoItem: ToDoItem, section: Int)
    
    func moveItemToTopOfSection(_ toDoItem: ToDoItem, section: Int)
    
}


class TableViewCell: UITableViewCell, UITextFieldDelegate{
    
    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false, completeOnDragRelease = false
   // var tickLabel: UILabel, crossLabel: UILabel
    let label: StrikeThroughText
    var itemCompleteLayer = CALayer()
    // The object that acts as delegate for this cell.
    var delegate: TableViewCellDelegate?
    
    
    var deleteButton: UIButton?
    
    // The item that this cell renders.
    var toDoItem: ToDoItem? {
        didSet {
            label.text = toDoItem!.text
            label.strikeThrough = toDoItem!.completed
            itemCompleteLayer.isHidden = !label.strikeThrough
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle,
        reuseIdentifier: String?) {
       
        // create a label that renders the to-do item text
        label = StrikeThroughText(frame: CGRect.null)
  
        label.textColor = UIColor.black
      
            label.font = UIFont.systemFont(ofSize: 14)
           
        label.backgroundColor = UIColor.clear
        
        // utility method for creating the contextual cues
        func createCueLabel() -> UILabel {
            let label = UILabel(frame: CGRect.null)
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 32.0)
            label.backgroundColor = UIColor.clear
            return label
        }
 
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
             self.showsReorderControl = false
            
          //  label.gestureRecognizers
            
        label.delegate = self
        label.contentVerticalAlignment = .center
            label.isEnabled = false
           
      
        addSubview(label)
        selectionStyle = .none
    
        // add a layer that renders a green background when an item is complete
        itemCompleteLayer = CALayer(layer: layer)
        itemCompleteLayer.backgroundColor = UIColor.clear.cgColor
        itemCompleteLayer.isHidden = true
        layer.insertSublayer(itemCompleteLayer, at: 0) 
      
            // add a pan recognizer
            let recognizer2 = UITapGestureRecognizer(target: self, action: #selector(TableViewCell.handleTouch(_:)))
            recognizer2.delegate = self
            addGestureRecognizer(recognizer2)
            
        // add a pan recognizer
       let recognizer = UIPanGestureRecognizer(target: self, action: #selector(TableViewCell.handlePan(_:)))
       recognizer.delegate = self
            recognizer.maximumNumberOfTouches = 1
       addGestureRecognizer(recognizer)
            
            let deleteImage = UIImage(named: "delete")
            deleteButton   = UIButton(type: UIButtonType.custom) as UIButton
            deleteButton!.setImage(deleteImage, for: UIControlState())
            deleteButton!.setTitle("", for: UIControlState())
            deleteButton!.addTarget(self, action: #selector(TableViewCell.deleteButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            
            self.addSubview(deleteButton!)
            deleteButton!.isHidden = true
            
            
            
            addSubview(deleteButton!)
            
    }
    
    
    
    func deleteButtonPressed(_ sender:UIButton!)
    {
    
       delegate!.toDoItemDeleted(toDoItem!, section: self.tag)
    }
    
    let kLabelLeftMargin: CGFloat = 15.0
    let kUICuesMargin: CGFloat = 10.0, kUICuesWidth: CGFloat = 50.0
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin, y: 0,
            width: bounds.size.width - kLabelLeftMargin - 60, height: bounds.size.height)
        label.frame.origin.x += 14
    
        deleteButton!.frame = CGRect(x: bounds.size.width-43 , y: bounds.size.height/2-7, width: 14, height: 14)
    }
    
  
    func handleTouch(_ recognizer: UITapGestureRecognizer) {
        
        if toDoItem != nil {
            if(!toDoItem!.completed){
                self.label.isEnabled = true
                self.label.becomeFirstResponder()
            }
        }
        
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - horizontal pan gesture methods
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        let app = UIApplication.shared.delegate as! AppDelegate
        
        if(app.exclusiveMultitouchInProgress! == true){
            return
        }
        
        if(app.isEditingMode! == true){
            return
        }
        
        if(recognizer.numberOfTouches > 1){
            return
        }
     
        
        // 1
        if recognizer.state == .began {
            // when the gesture begins, record the current center location
            originalCenter = center
        }
        // 2
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
         
            deleteOnDragRelease = translation.x < -frame.size.width / 6.0
            completeOnDragRelease = translation.x > frame.size.width / 6.0
                  }
        // 3
        if recognizer.state == .ended {
            _ = CGRect(x: 0, y: frame.origin.y,
                width: bounds.size.width, height: bounds.size.height)
            if deleteOnDragRelease {
     

                if toDoItem != nil {
                    if(toDoItem!.completed == true){
                        toDoItem!.completed = false
                        label.strikeThrough = false
                        itemCompleteLayer.isHidden = true
                        deleteButton!.isHidden = true
                        moveItemToTopOfSection()
                    }else{
                        toDoItem!.completed = true
                        label.strikeThrough = true
                        itemCompleteLayer.isHidden = false
                        deleteButton!.isHidden = false
                        moveCellToBottomOfSection()
                    }
                }
                
            } else if completeOnDragRelease {
                if toDoItem != nil {
                    if(toDoItem!.completed == true){
                        toDoItem!.completed = false
                        label.strikeThrough = false
                        itemCompleteLayer.isHidden = true
                        deleteButton!.isHidden = true
                        moveItemToTopOfSection()
                    }else{
                        toDoItem!.completed = true
                        label.strikeThrough = true
                        itemCompleteLayer.isHidden = false
                        deleteButton!.isHidden = false
                        moveCellToBottomOfSection()
                    }
                }
               // UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
            } else {
              //  UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
            }
        }
    }
    
    func moveCellToBottomOfSection(){
        
        self.label.alpha = 0.5
      
      delegate!.moveItemToBottomOfSection(self.toDoItem!, section: self.tag)
    }
    
    func moveItemToTopOfSection(){
        
        self.label.alpha = 1
        
        delegate!.moveItemToTopOfSection(self.toDoItem!, section: self.tag)
    }
    
   
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return true

    }
    
    // MARK: - UITextFieldDelegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // close the keyboard on Enter
        textField.resignFirstResponder()
        textField.isEnabled = false
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // disable editing of completed to-do items

        let app = UIApplication.shared.delegate as! AppDelegate
        if (app.isLongPressMode == true){
            return false
        }
        
        if toDoItem != nil {
            return !toDoItem!.completed
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
      
        if toDoItem != nil {
            toDoItem!.text = textField.text!
        }
        if delegate != nil {
            delegate!.cellDidEndEditing(self)
        }
        textField.isEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let app = UIApplication.shared.delegate as! AppDelegate
        
        if(app.isAutocorrectMode == true){
            textField.autocorrectionType = UITextAutocorrectionType.yes
        }else{
            textField.autocorrectionType = UITextAutocorrectionType.no
        }
        
        
        if delegate != nil {
           
            delegate!.cellDidBeginEditing(self)
        }
    }

}
