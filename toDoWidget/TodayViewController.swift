//
//  TodayViewController.swift
//  toDoWidget
//
//  Created by Jonas Schafft on 1/12/2015.
//  Copyright (c) 2015 Jonas Schafft. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource,UITableViewDelegate {
    
    var toDos = [NSManagedObject]()
    var todayList = [ToDoItem]()
    var errr = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        loadCoreData()
        tableView.reloadData()
        
        self.preferredContentSize = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height+44)

    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
     
        
        let url =  URL(string:"ClearStyle://")
        
        self.extensionContext?.open(url!, completionHandler:{(success: Bool) -> Void in
          
        })
    }
    
    @IBAction func completedPressed(_ sender: UIButton) {
        
        todayList.remove(at: sender.tag)
        tableView.reloadData()
        
        self.preferredContentSize = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height+44)
        
        saveCompletionInCoreDataForIndex(sender.tag)
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
 
        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WidgetTableViewCell", for: indexPath) as! WidgetTableViewCell
            cell.selectionStyle = .none
            
            cell.cell_title.text = todayList[indexPath.row].text
            cell.textLabel?.textColor = UIColor.white
         
            cell.cell_button.tag = indexPath.row
           
            return cell
    }
    
    func saveCompletionInCoreDataForIndex(_ index: Int){
        
        let managedContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        do {
            let results =
            try managedContext.fetch(fetchRequest)
            toDos = results as! [NSManagedObject]
        } catch let error as NSError {
              print("Could not fetch \(error), \(error.userInfo)")
            
        }
        
        var counter = 0
        
        for toDo in toDos{
           
            if let section = toDo.value(forKey: "section") as? Int {
                if section == 0 {
                    
                    if let isCompleted = toDo.value(forKey: "isCompleted") as? Bool {
                        
                        if(counter == index && !isCompleted){
                            toDo.setValue(true, forKey: "isCompleted")
                           counter += 1
                        }
                        
                        if(!isCompleted){
                            
                            counter += 1
                        }else{
                            
                        }
                        
                    }
                     
                }
            }
            
        }
        
     
        do {
            try managedContext.save()
            
        } catch let error as NSError  {
              print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    
    func loadCoreData(){
        
        todayList.removeAll()
   
        let managedContext = self.managedObjectContext
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        
        
        do {
            let results =
            try managedContext.fetch(fetchRequest)
            toDos = results as! [NSManagedObject]
        } catch let error as NSError {
             print("Could not fetch \(error), \(error.userInfo)")
           
        }
        
       
        for toDo in toDos{
            let item = ToDoItem(text: toDo.value(forKey: "text") as! String)
            if let section = toDo.value(forKey: "section") as? Int {
                if section == 0 {
                    
                    if let isCompleted = toDo.value(forKey: "isCompleted") as? Bool {
                    
                        if(!isCompleted){
                    
                    todayList.append(item)
                        }
                        
                    }
                
                
                }
            }
            
        }
        
       
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL? = {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.de.jonasschafft.ClearStyleGroup") ?? nil
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory!.appendingPathComponent("ClearStyle.sqlite")
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
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }


    
}
