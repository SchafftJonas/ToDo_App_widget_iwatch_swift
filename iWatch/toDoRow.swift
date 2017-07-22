//
//  toDoRow.swift
//  ClearStyle
//
//  Created by Jonas Schafft on 1/12/2015.
//  Copyright (c) 2015 Jonas Schafft. All rights reserved.
//

import WatchKit

class toDoRow: NSObject {
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var textLabel: WKInterfaceLabel!
  
    // 1
    var toDo: ToDoItem? {
        // 2
        didSet {
            // 3
            if let toDo = toDo {
                // 4
                textLabel.setText(toDo.value(forKey: "text") as? String)
               
            }
        }
    }
  
    
}
