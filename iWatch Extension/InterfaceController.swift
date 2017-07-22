//
//  InterfaceController.swift
//  iWatch Extension
//
//  Created by Jonas Schafft on 1/12/2015.
//  Copyright (c) 2015 Jonas Schafft. All rights reserved.
//

import WatchKit
import Foundation
import CoreData
import WatchConnectivity


class InterfaceController: WKInterfaceController,WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    @IBOutlet var table: WKInterfaceTable!
    
    var toDos = [ToDoItem]()
    var toDosData = [NSManagedObject]()
    var emptyList = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
      
        
        if (WCSession.isSupported()) {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }
    
        loadCoreData()
    
    }
    
    func sendCoreDateToAppOS(){
 
        do {
            if #available(iOS 9.0, *) {
                
                var applicationDict = [String:Any]()
                
                for index in 0..<toDos.count {
                    applicationDict["index-\(index)"] = ["text":toDos[index].text, "isCompleted":toDos[index].completed]
                }
                
                
                try WCSession.default().updateApplicationContext(applicationDict)
            } else {
              
            }
        } catch {
           
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    
        toDos.removeAll()
   
        for (id, obj) in applicationContext {
     
             print("id: \(id) obj: \(obj)")
            
            if((obj as AnyObject).value(forKey: "isCompleted") as! Bool == false){
                 toDos.append(ToDoItem(text: (obj as AnyObject).value(forKey: "text") as! String))
           
                
            }else{
            
            }
         
        }
        DispatchQueue.main.async(execute: {
      self.activateWithoutSending()
        
        self.saveCoreData()
            
        })
     
    }
    
    func activateWithoutSending(){
        var test = 0
        
        var counter = 0
        for toDo in toDos{
            test += 1
            if(toDo.completed == false){
                counter += 1
            }
        }
        
        if(counter == 0){
            table.setNumberOfRows(1, withRowType: "toDoRow")
            if let controller = table.rowController(at: 0) as? toDoRow {
                
                let toDo = ToDoItem(text: "No Tasks for Today")
                controller.toDo = toDo
                
            }
            emptyList = true
            return
        }else{
            emptyList = false
        }
        
        
        table.setNumberOfRows(counter, withRowType: "toDoRow")
     
        var next = 0
        for index in 0..<toDos.count {
            
            if(toDos[index].completed == true){
                next += 1
                continue
            }
            
            if let controller = table.rowController(at: index-next) as? toDoRow {
                
                controller.toDo = toDos[index]
                
            }
        }
    
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if(emptyList == true){
            return
        }
        
        
         if let controller = table.rowController(at: rowIndex) as? toDoRow {
        let toDo = controller.toDo
        presentController(withName: "toDoDetails", context: toDo)
        }
        
    }

    override func willActivate() {
        
        super.willActivate()
 
        var test = 0
        
        var counter = 0
        for toDo in toDos{
            test += 1
            if(toDo.completed == false){
               counter += 1
            }
        }
        
        if(counter == 0){
            table.setNumberOfRows(1, withRowType: "toDoRow")
            if let controller = table.rowController(at: 0) as? toDoRow {
                
                let toDo = ToDoItem(text: "No Tasks for Today")
                controller.toDo = toDo
                
            }
            emptyList = true
            sendCoreDateToAppOS()
            return
        }else{
            emptyList = false
        }
        
        
        table.setNumberOfRows(counter, withRowType: "toDoRow")
      
        var next = 0
        for index in 0..<toDos.count {
            
            if(toDos[index].completed == true){
                next += 1
                continue
            }
            
            if let controller = table.rowController(at: index-next) as? toDoRow {
               
                     controller.toDo = toDos[index]
              
            }
        }
   
        saveCoreData()

        sendCoreDateToAppOS()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func saveCoreData(){
  
        let managedContext = self.managedObjectContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        
        do {
            let results =
            try managedContext.fetch(request)
            toDosData = results as! [NSManagedObject]
        } catch let error as NSError {
              print("Could not fetch \(error), \(error.userInfo)")
        }
        
        for bas: AnyObject in toDosData
        {
            managedContext.delete(bas as! NSManagedObject)
        }
        
        toDosData.removeAll(keepingCapacity: false)
        
       
        for obj in toDos{
            
            let entity =  NSEntityDescription.entity(forEntityName: "ToDo",
                in:managedContext)
            
            let toDo = NSManagedObject(entity: entity!,
                insertInto: managedContext)
            
            toDo.setValue(obj.text, forKey: "text")
            toDo.setValue(0, forKey: "section")
            toDo.setValue(-1, forKey: "row")
            toDo.setValue(obj.completed, forKey: "isCompleted")
           
            do {
                try managedContext.save()
                
            } catch let error as NSError  {
                 print("Could not save \(error), \(error.userInfo)")
            }
            
        }
        
        
        
    }
    
    func insertObjInCoreData(){
        
        let managedContext = self.managedObjectContext
        
        let entity =  NSEntityDescription.entity(forEntityName: "ToDo",
            in:managedContext)
        
        let toDo = NSManagedObject(entity: entity!,
            insertInto: managedContext)
        
        toDo.setValue("test x x", forKey: "text")
        toDo.setValue(0, forKey: "section")
        toDo.setValue(-1, forKey: "row")
        toDo.setValue(false, forKey: "isCompleted")
     
        do {
            try managedContext.save()
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    func loadCoreData(){
        
        
        let managedContext = self.managedObjectContext
      
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        
        
        do {
            let results =
            try managedContext.fetch(fetchRequest)
            toDosData = results as! [NSManagedObject]
        } catch let error as NSError {
              print("Could not fetch \(error), \(error.userInfo)")
            
        }
     
        for toDo in toDosData{
            let item = ToDoItem(text: (toDo.value(forKey: "text") as? String)!)
            
            if let isCompleted = toDo.value(forKey: "isCompleted") as? Bool {
                
                if(!isCompleted){
                    
            
            toDos.append(item)
                }
            }
            
        }
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "WatchKitCoreData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("ClearStyle.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
 /*   func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    } */

    

}
