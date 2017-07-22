//
//  ToDoItem.swift
//  ClearStyle
//
//  Created by Jonas Schafft on 1/12/2015.
//  Copyright (c) 2015 Jonas Schafft. All rights reserved.
//

import UIKit

class ToDoItem: NSObject {
    // A text description of this item.
    var text: String
    
    // A Boolean value that determines the completed state of this item.
    var completed: Bool
    
    // Creation Date
    var created:Date?
    
    // Returns a ToDoItem initialized with the given text and default completed value.
    init(text: String) {
        self.text = text
        self.completed = false
    }   
}
