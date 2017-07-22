
//
//  Created by Jonas Schafft on 1/12/2015.
//  Copyright (c) 2015 Jonas Schafft. All rights reserved.
//

import WatchKit
import Foundation


class toDoDetails:WKInterfaceController {
    
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
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let toDo = context as? ToDoItem { self.toDo = toDo }
    }
    
    @IBAction func deleteButtonPressed(_ sender:WKInterfaceButton!)
    {
      
        toDo?.completed = true
   
        dismiss()
        
    }
    
}
