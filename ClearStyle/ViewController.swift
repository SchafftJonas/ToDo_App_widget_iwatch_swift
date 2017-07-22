//
//  ViewController.swift
//  ClearStyle
//
//  Created by Jonas Schafft on 1/12/2015.
//  Copyright (c) 2015 Jonas Schafft. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate, UIGestureRecognizerDelegate, WCSessionDelegate {
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        
    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

                            
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var constraint: NSLayoutConstraint!
    @IBOutlet weak var constraint2: NSLayoutConstraint!
    
    @IBOutlet weak var addButton: UIButton!
    
    var docController:UIDocumentInteractionController!
    
    var toDos = [NSManagedObject]()
    var settings = [NSManagedObject]()
    
    var autoCorrectEnabled:Bool?
    var dailyUpdateSwitchEnabled:Bool?
    var showAddButton:Bool?
    var notificationsEnabled:Bool?
    
    var swipestart:CGFloat = 0.0
    var fromFull:Bool = true
    
    
    var sections: [String] = ["TODAY", "TOMORROW", "UPCOMING", "SOMEDAY"]
    var todayList = [ToDoItem]()
    var tomorrowList = [ToDoItem]()
    var upcomingList = [ToDoItem]()
    var somedayList = [ToDoItem]()
    let pinchRecognizer = UIPinchGestureRecognizer()
    
    var isEditingMode = false
    
    var slideWidth = 0.0 as CGFloat
    
    var todayHeader: CustomHeader = CustomHeader()
    var tomorrowHeader: CustomHeader = CustomHeader()
    var upcomingHeader: CustomHeader = CustomHeader()
    var somedayHeader: CustomHeader = CustomHeader()
    
    var color: UIColor = UIColor(red: CGFloat(82.0/255.0), green: CGFloat(211.0/255), blue: CGFloat(247.0/255.0), alpha: 1.0)
    
  
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.viewDidBecomeActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    
        loadCoreData()
        
        updatePriorities()
        
        sortCompleted()
        
        saveCoreData()
        
        tableView.reloadData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
            loadCoreDataSettings()
    }
    
    func updatePriorities(){
        
        if(dailyUpdateSwitchEnabled != nil && dailyUpdateSwitchEnabled == false){
     
            return
        }
        
      
        let userCalendar = Calendar.current
        let dayCalendarUnit: NSCalendar.Unit = [.day]
        let today = Date()
       
        
        
        for toDoObj in tomorrowList{
            if(toDoObj.created != nil){
                
                let days = (userCalendar as NSCalendar).components(
                    dayCalendarUnit,
                    from: toDoObj.created! as Date,
                    to: today,
                    options: [])
                
                if(days.day! >= 1){
                    tomorrowList.remove(at: tomorrowList.index(of: toDoObj)!)
                   todayList.append(toDoObj)
                
                }else{
                  
                }
              
                
            }else{
              
            }
        }
        
    }
    
    func viewDidBecomeActive(){
     
        loadCoreData()
        loadCoreDataSettings()
       
        updatePriorities()
        
        sortCompleted()
        
        saveCoreData()
        
        tableView.reloadData()
    }
    
    func sortCompleted(){
        for toDo in todayList{
            if(toDo.completed == true){
                // print("Move item to Bottom")
                moveItemToLowestBottomOfSection(toDo, section: 0)
            }
        }
    }
    
    func loadCoreDataSettings(){
        
    
        
        //1
        let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        
        do {
            let results =
            try managedContext.fetch(fetchRequest)
            settings = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        let app = UIApplication.shared.delegate as! AppDelegate
        
        if(settings.count == 0){
            // add default settings
            
            loadDefaultSettings()
            loadCoreDataSettings()
            loadDefaultToDos()
            loadCoreData()
            saveCoreData()
            return
            
        }
        
        for setting in settings{
            
            
            if(setting.value(forKey: "autoCorrectEnabledSwitch") as? Bool == true)
            {
                autoCorrectEnabled = true
                app.isAutocorrectMode = true
                
            }else{
                autoCorrectEnabled = false
                app.isAutocorrectMode = false
            }
            
            if(setting.value(forKey: "dailyUpdateSwitch") as? Bool == true)
            {
                dailyUpdateSwitchEnabled = true
            }else{
                dailyUpdateSwitchEnabled = false
            }
            
            if(setting.value(forKey: "notificationsEnabledSwitch") as? Bool == true)
            {
                notificationsEnabled = true
                
                let colorR = setting.value(forKey: "pickedColorR") as! Float
                let colorG = setting.value(forKey: "pickedColorG") as! Float
                let colorB = setting.value(forKey: "pickedColorB") as! Float
                
                color = UIColor(red: CGFloat(colorR), green: CGFloat(colorG), blue: CGFloat(colorB), alpha: 1.0)
             
                if(addButton != nil){
                addButton.backgroundColor = UIColor(red: CGFloat(colorR), green: CGFloat(colorG), blue: CGFloat(colorB), alpha: 1.0)
                }
                if(todayHeader.section_title != nil){
                todayHeader.section_title.textColor = UIColor(red: CGFloat(colorR), green: CGFloat(colorG), blue: CGFloat(colorB), alpha: 1.0)
                }
                if(tomorrowHeader.section_title != nil){
                tomorrowHeader.section_title.textColor = UIColor(red: CGFloat(colorR), green: CGFloat(colorG), blue: CGFloat(colorB), alpha: 1.0)
                }
                if(upcomingHeader.section_title != nil){
                upcomingHeader.section_title.textColor = UIColor(red: CGFloat(colorR), green: CGFloat(colorG), blue: CGFloat(colorB), alpha: 1.0)
                }
                if(somedayHeader.section_title != nil){
                somedayHeader.section_title.textColor = UIColor(red: CGFloat(colorR), green: CGFloat(colorG), blue: CGFloat(colorB), alpha: 1.0)
                }
                
                if(todayHeader.section_addButton != nil){
                todayHeader.section_addButton.titleLabel?.textColor = UIColor(red: CGFloat(colorR), green: CGFloat(colorG), blue: CGFloat(colorB), alpha: 1.0)
                    todayHeader.section_addButton.setTitleColor(color, for: UIControlState())
                }
                if(tomorrowHeader.section_addButton != nil){
                tomorrowHeader.section_addButton.titleLabel?.textColor = UIColor(red: CGFloat(colorR), green: CGFloat(colorG), blue: CGFloat(colorB), alpha: 1.0)
                    tomorrowHeader.section_addButton.setTitleColor(color, for: UIControlState())
                }
                if(upcomingHeader.section_addButton != nil){
                upcomingHeader.section_addButton.titleLabel?.textColor = UIColor(red: CGFloat(colorR), green: CGFloat(colorG), blue: CGFloat(colorB), alpha: 1.0)
                    upcomingHeader.section_addButton.setTitleColor(color, for: UIControlState())
                }
                if(somedayHeader.section_addButton != nil){
                somedayHeader.section_addButton.titleLabel?.textColor = UIColor(red: CGFloat(colorR), green: CGFloat(colorG), blue: CGFloat(colorB), alpha: 1.0)
                    somedayHeader.section_addButton.setTitleColor(color, for: UIControlState())
                }
                
            }else{
                notificationsEnabled = false
                
                 addButton.backgroundColor = UIColor(red: CGFloat(82.0/255.0), green: CGFloat(211.0/255), blue: CGFloat(247.0/255.0), alpha: 1.0)
                
            }
            
            if(setting.value(forKey: "showAddButton") as? Bool == true)
            {
                showAddButton = true
                
                addButton.isHidden = false
                
                addButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2/2))
                
            }else{
                showAddButton = false
                
                addButton.isHidden = true
                
                
            }
            
            
        }
        
    }
    
    func loadDefaultToDos(){
     
        let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entity(forEntityName: "ToDo",
            in:managedContext)
        
        let toDo1 = NSManagedObject(entity: entity!,
            insertInto: managedContext)
        
        let toDo2 = NSManagedObject(entity: entity!,
            insertInto: managedContext)
        
        let toDo3 = NSManagedObject(entity: entity!,
            insertInto: managedContext)
        
        let toDo4 = NSManagedObject(entity: entity!,
            insertInto: managedContext)
        
        let toDo5 = NSManagedObject(entity: entity!,
            insertInto: managedContext)
      
        //3
        toDo1.setValue("Swipe right with two fingers to see all options.", forKey: "text")
        toDo1.setValue(0, forKey: "section")
        toDo1.setValue(0, forKey: "row")
        toDo1.setValue(false, forKey: "isCompleted")
      
        
        toDo2.setValue("Rate this App 5 little stars. Thank you!", forKey: "text")
        toDo2.setValue(3, forKey: "section")
        toDo2.setValue(0, forKey: "row")
        toDo2.setValue(false, forKey: "isCompleted")
        
        
        toDo3.setValue("Have a nice day :)", forKey: "text")
        toDo3.setValue(0, forKey: "section")
        toDo3.setValue(2, forKey: "row")
        toDo3.setValue(false, forKey: "isCompleted")
        
        
        toDo4.setValue("Come back and use this App again!", forKey: "text")
        toDo4.setValue(1, forKey: "section")
        toDo4.setValue(0, forKey: "row")
        toDo4.setValue(false, forKey: "isCompleted")
        toDo1.setValue(Date(), forKey: "created")
        
        toDo5.setValue("Swipe a task with one finger to complete it.", forKey: "text")
        toDo5.setValue(0, forKey: "section")
        toDo5.setValue(1, forKey: "row")
        toDo5.setValue(false, forKey: "isCompleted")
    
        //4
        do {
            try managedContext.save()
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    func loadDefaultSettings(){
        
        print("Load Default Settings")
        
        let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entity(forEntityName: "Settings",
            in:managedContext)
        
        let toDo = NSManagedObject(entity: entity!,
            insertInto: managedContext)
        
        //3
        toDo.setValue(true, forKey: "showAddButton")
        toDo.setValue(true, forKey: "dailyUpdateSwitch")
        toDo.setValue(false, forKey: "notificationsEnabledSwitch")
        toDo.setValue(false, forKey: "autoCorrectEnabledSwitch")
        
        toDo.setValue(82.0/255.0, forKey: "pickedColorR")
        toDo.setValue(211.0/255.0, forKey: "pickedColorG")
        toDo.setValue(247.0/255.0, forKey: "pickedColorB")
        
        //4
        do {
            try managedContext.save()
            
        } catch let error as NSError  {
             print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func loadCoreData(){
        
        //1
        let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        
    
        do {
            let results =
            try managedContext.fetch(fetchRequest)
            toDos = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        clearAllData()
        
        
        for toDo in toDos{
      
       
            if let section = toDo.value(forKey: "section") as? Int {
            
            switch section{
            case 0:
                
                let item = ToDoItem(text: "")
                todayList.append(item)
                
                break
            case 1:
                
                let item = ToDoItem(text: "")
                tomorrowList.append(item)
                
                break
            case 2:
                
                let item = ToDoItem(text: "")
                upcomingList.append(item)
                
                break
            case 3:
                
                let item = ToDoItem(text: "")
                somedayList.append(item)
                
                break
            default:
                break
            }
                
                }
          
        }
        
        
        for toDo in toDos{
        
            if let section = toDo.value(forKey: "section") as? Int {
                
                if let index = toDo.value(forKey: "row") as? Int {
                    
                    if let completed = toDo.value(forKey: "isCompleted") as? Bool {
         
        
            switch section{
            case 0:
                
                let item = ToDoItem(text: toDo.value(forKey: "text") as! String)
                item.completed = completed
                if let created = toDo.value(forKey: "created") as? Date {
                    item.created = created
                }
                todayList.remove(at: index)
                todayList.insert(item, at: index)
            
                break
            case 1:
                
                let item = ToDoItem(text: toDo.value(forKey: "text") as! String)
                item.completed = completed
          
                if let created = toDo.value(forKey: "created") as? Date {
                    print(created)
                item.created = created
                }
                tomorrowList.remove(at: index)
                tomorrowList.insert(item, at: index)
             
                
                break
            case 2:
                
                let item = ToDoItem(text: toDo.value(forKey: "text") as! String)
                item.completed = completed
                if let created = toDo.value(forKey: "created") as? Date {
                    item.created = created
                }
                upcomingList.remove(at: index)
                upcomingList.insert(item, at: index)
                
                
                break
            case 3:
                
                let item = ToDoItem(text: toDo.value(forKey: "text") as! String)
                item.completed = completed
                if let created = toDo.value(forKey: "created") as? Date {
                    item.created = created
                }
                somedayList.remove(at: index)
                somedayList.insert(item, at: index)
                
                
                break
            default:
                break
            }
                }
            }
            }
        }
        
      self.tableView.reloadData()
        
    }
    
    @IBAction func sendFile(_ sender:AnyObject) {
        
        var text = "to-Do List: \n \n"
        
        if(todayList.count>0){
        text += "Today: \n"
        for toDo in todayList {
            text += "- " + toDo.text + "\n"
        }
        text += "\n"
        }
        
        if(tomorrowList.count>0){
        text += "Tomorrow: \n"
        for toDo in tomorrowList {
            text += "- " + toDo.text + "\n"
        }
        text += "\n"
        }
        
        if(upcomingList.count>0){
        text += "Upcoming: \n"
        for toDo in upcomingList {
            text += "- " + toDo.text + "\n"
        }
        text += "\n"
        }
        
        if(somedayList.count>0){
        text += "Someday: \n"
        for toDo in somedayList {
            text += "- " + toDo.text + "\n"
        }
        }
        
       
        let textToShare = text
      
            let objectsToShare = [textToShare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.present(activityVC, animated: true, completion: nil)

}
    
    @IBAction func clearEverything(_ sender:AnyObject) {
        
        let refreshAlert = UIAlertController(title: "Clear", message: "All data will be lost. Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
         
            self.clearAllData()
            self.saveCoreData()
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
         
        }))
        
        present(refreshAlert, animated: true, completion: nil)
   
    }
    
    func clearAllData(){
        
      
        todayList.removeAll()
        tomorrowList.removeAll()
        upcomingList.removeAll()
        somedayList.removeAll()
        
        tableView.reloadData()
        
    }
    
    @IBAction func rateApp(_ sender:AnyObject) {
      
         UIApplication.shared.openURL(URL(string : "itms-apps://itunes.apple.com/us/app/get-it-done-fast-easy-to-do/id1070337852?l=de&ls=1&mt=8")!)
        
    }
    
    @IBAction func settings(_ sender:AnyObject) {
      
        let vc = SettingsViewController()
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func sendCoreDateToWatchOS(){
    
        do {
            if #available(iOS 9.0, *) {
              
                var applicationDict = [String:Any]()
                
                for index in 0 ..< todayList.count {
                    applicationDict["index-\(index)"] = ["text":todayList[index].text, "isCompleted":todayList[index].completed]
                }
               
                
                try WCSession.default().updateApplicationContext(applicationDict)
            } else {
              
            }
        } catch {
         
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.view.isMultipleTouchEnabled = true
        self.tableView.isMultipleTouchEnabled = true
        
        if #available(iOS 9.0, *) {
            if (WCSession.isSupported()) {
                let session = WCSession.default()
                session.delegate = self
                session.activate()
              
            }
        } else {
        }
        

        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressGestureRecognized(_:)))
        tableView.addGestureRecognizer(longpress)
 
        let doubleTapGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.doubleswipe(_:)))
        doubleTapGesture.minimumNumberOfTouches = 2
        doubleTapGesture.delegate = self
        view.addGestureRecognizer(doubleTapGesture)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.rowHeight = 50
   
        self.tableView.layer.masksToBounds = false;
        self.tableView.layer.shadowOffset = CGSize(width: 0, height: 0);
        self.tableView.layer.shadowRadius = 6;
        self.tableView.layer.shadowOpacity = 0.5;
        
       
    }
    
    func doubleswipe(_ recognizer: UIPanGestureRecognizer) {

        if(isEditingMode){
            return
        }
        
        let app = UIApplication.shared.delegate as! AppDelegate
  
        if recognizer.state == .began {
            
            app.exclusiveMultitouchInProgress = true
            if(self.tableView.frame.origin.x >= 37){
            
                fromFull = false
                
            }else{
            
                fromFull = true
                
            }
            
            swipestart = recognizer.location(in: self.view).x
        }
        
        if recognizer.state == .changed {
            
            var location:CGFloat = 0
            
            app.exclusiveMultitouchInProgress = true
            if(fromFull){
                location = recognizer.location(in: self.view).x - swipestart
            }else{
                location = 76 - (swipestart - recognizer.location(in: self.view).x)
            }
                if(location < 76 && location >= 0){
                    self.tableView.frame.origin.x = location
                }else if (location >= 76){
                    self.tableView.frame.origin.x = 76
                }else{
                    self.tableView.frame.origin.x = 0
                   
                }
            
         
                 self.tableView.frame.size.width = self.view.frame.size.width
        
        }
        
        if recognizer.state == .ended {
      
            if(self.tableView.frame.origin.x >= 37){
             
                UIView.animate(withDuration: 0.3, animations: {
                
                    
                    self.tableView.frame.origin.x = 76
                    }, completion: {
                        (value: Bool) in
                        self.constraint.constant = 60
                        self.constraint2.constant = -80
                })
            
            }else{
                UIView.animate(withDuration: 0.3, animations: {
                  
                self.tableView.frame.origin.x = 0
                    
                    self.constraint.constant = -20
                    self.constraint2.constant = -20
                }) 
            }
            
            app.exclusiveMultitouchInProgress = false
            
        }
        
        
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
   
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
      
        var item = ToDoItem(text: "")
        
        switch sourceIndexPath.section{
        case 0:
            item = todayList[sourceIndexPath.row]
            todayList.remove(at: sourceIndexPath.row)
            break
        case 1:
            item = tomorrowList[sourceIndexPath.row]
            tomorrowList.remove(at: sourceIndexPath.row)
            break
        case 2:
            item = upcomingList[sourceIndexPath.row]
            upcomingList.remove(at: sourceIndexPath.row)
            break
        case 3:
            item = somedayList[sourceIndexPath.row]
            somedayList.remove(at: sourceIndexPath.row)
            break
        default:
            break
        }
        
        switch destinationIndexPath.section{
        case 0:
            todayList.insert(item, at: destinationIndexPath.row)
            break
        case 1:
            tomorrowList.insert(item, at: destinationIndexPath.row)
            break
        case 2:
            upcomingList.insert(item, at: destinationIndexPath.row)
            break
        case 3:
            somedayList.insert(item, at: destinationIndexPath.row)
            break
        default:
            break
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
     
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "customheader") as! CustomHeader
        
        headerCell.section_title.textColor = color
        headerCell.section_addButton.titleLabel?.textColor = color
        
        headerCell.section_title.text = sections[section]
        //headerCell.backgroundColor =  UIColor(red:72/255,green:141/255,blue:200/255,alpha:0.9)
        
        
        
        switch section{
        case 0:
            todayHeader = headerCell
            headerCell.tag = 0
            for view in todayHeader.contentView.subviews{
                view.tag = 0
            }
            break
            
        case 1:
            tomorrowHeader = headerCell
            headerCell.tag = 1
            for view in tomorrowHeader.contentView.subviews{
                view.tag = 1
            }
            break
            
        case 2:
            upcomingHeader = headerCell
            headerCell.tag = 2
            for view in upcomingHeader.contentView.subviews{
                view.tag = 2
            }
            break
            
        case 3:
            somedayHeader = headerCell
            headerCell.tag = 3
            for view in somedayHeader.contentView.subviews{
                view.tag = 3
            }
            break
            
        default:
            break;
            
            
        }
        
        headerCell.section_title.textColor = color
        headerCell.section_addButton.titleLabel?.textColor = color
        headerCell.section_addButton.tintColor = color
        headerCell.section_addButton.setTitleColor(color, for: UIControlState())
        
        
        
        
        return headerCell.contentView
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
            case 0:
                return todayList.count
            
            case 1:
                return tomorrowList.count
        
            case 2:
                return upcomingList.count
           
            case 3:
                return somedayList.count
           
            default:
            return 0
            
            
            }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
            cell.selectionStyle = .none
            cell.textLabel?.backgroundColor = UIColor.clear
            
            var item = ToDoItem(text: "")
            
            switch indexPath.section{
            case 0:
                item = todayList[indexPath.row]
                break
            case 1:
                 item = tomorrowList[indexPath.row]
                break
            case 2:
                item = upcomingList[indexPath.row]
                break
            case 3:
                item = somedayList[indexPath.row]
                break
            default:
                break
            }
            cell.delegate = self
            cell.tag = indexPath.section
            cell.toDoItem = item
            cell.showsReorderControl = false
            if(cell.toDoItem?.completed == true){
                cell.deleteButton?.isHidden = false
                cell.label.alpha = 0.5
            }else{
                cell.label.alpha = 1
                cell.deleteButton?.isHidden = true
            }
            
            
         
            return cell
    }
   
  
    func cellDidBeginEditing(_ editingCell: TableViewCell) {
     
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        tableView.isScrollEnabled = false
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.isEditingMode = true
        isEditingMode = true
     
        let editingOffset = 44 + tableView.contentOffset.y - editingCell.frame.origin.y as CGFloat
        let visibleCells = tableView.visibleCells as! [TableViewCell]
      
        UIView.animate(withDuration: 0.3, animations: {() in
            
            if(editingCell.tag != 0){
                self.todayHeader.contentView.alpha = 0.3
                self.todayHeader.contentView.transform = CGAffineTransform(translationX: 0, y: editingOffset)
            }else{
                self.todayHeader.contentView.transform = CGAffineTransform(translationX: 0, y: -self.todayHeader.contentView.frame.origin.y + self.tableView.contentOffset.y)
                
            }
        })
        UIView.animate(withDuration: 0.3, animations: {() in
            
            if(editingCell.tag != 1){
                self.tomorrowHeader.contentView.alpha = 0.3
                self.tomorrowHeader.contentView.transform = CGAffineTransform(translationX: 0, y: editingOffset)
            }else{
                self.tomorrowHeader.contentView.transform = CGAffineTransform(translationX: 0, y: -self.tomorrowHeader.contentView.frame.origin.y + self.tableView.contentOffset.y)
            }
        })
        UIView.animate(withDuration: 0.3, animations: {() in
            
            if(editingCell.tag != 2){
                self.upcomingHeader.contentView.alpha = 0.3
                self.upcomingHeader.contentView.transform = CGAffineTransform(translationX: 0, y: editingOffset)
            }else{
                self.upcomingHeader.contentView.transform = CGAffineTransform(translationX: 0, y: -self.upcomingHeader.contentView.frame.origin.y + self.tableView.contentOffset.y)
            }
        })
        UIView.animate(withDuration: 0.3, animations: {() in
            
            if(editingCell.tag != 3){
                self.somedayHeader.contentView.alpha = 0.3
                self.somedayHeader.contentView.transform = CGAffineTransform(translationX: 0, y: editingOffset)
            }else{
                self.somedayHeader.contentView.transform = CGAffineTransform(translationX: 0, y: -self.somedayHeader.contentView.frame.origin.y + self.tableView.contentOffset.y)
            }
        })
        
       
        for cell in visibleCells {
            UIView.animate(withDuration: 0.3, animations: {() in
                cell.transform = CGAffineTransform(translationX: 0, y: editingOffset)
                if cell !== editingCell {
                    cell.alpha = 0.3
                }
            })
        }
       
        
        tableView.isScrollEnabled = false
        
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
       // // print(sender.tag)
        
       toDoItemAdded(sender.tag)
      
    }
    
    func cellDidEndEditing(_ editingCell: TableViewCell) {
        let app = UIApplication.shared.delegate as! AppDelegate
        app.isEditingMode = false
        isEditingMode = false
        
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for cell: TableViewCell in visibleCells {
            UIView.animate(withDuration: 0.3, animations: {() in
                cell.transform = CGAffineTransform.identity
                if cell !== editingCell {
                    cell.alpha = 1.0
                }
                }, completion: { (finished) -> Void in
                    
                    if finished {
                        
                        
                         self.tableView.reloadData()
                        
                    }
                    
            })

        }
        
        UIView.animate(withDuration: 0.3, animations: {() in
            self.todayHeader.contentView.transform = CGAffineTransform.identity
            self.todayHeader.contentView.alpha = 1.0
        })
        UIView.animate(withDuration: 0.3, animations: {() in
            self.tomorrowHeader.contentView.transform = CGAffineTransform.identity
            self.tomorrowHeader.contentView.alpha = 1.0
        })
        UIView.animate(withDuration: 0.3, animations: {() in
            self.upcomingHeader.contentView.transform = CGAffineTransform.identity
            self.upcomingHeader.contentView.alpha = 1.0
        })
        UIView.animate(withDuration: 0.3, animations: {() in
            self.somedayHeader.contentView.transform = CGAffineTransform.identity
            self.somedayHeader.contentView.alpha = 1.0
        })
        
        
        if editingCell.toDoItem!.text == "" {
            toDoItemDeleted(editingCell.toDoItem!, section: editingCell.tag)
        }
        
        tableView.isScrollEnabled = true
        
        
        saveCoreData()
        
    }
    
    func saveCoreData(){
    
        let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        
        do {
            let results =
            try managedContext.fetch(request)
            toDos = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
       
            for bas: AnyObject in toDos
            {
                managedContext.delete(bas as! NSManagedObject)
            }
            
            toDos.removeAll(keepingCapacity: false)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
      
        for toDoObject in todayList {
        
            let entity =  NSEntityDescription.entity(forEntityName: "ToDo",
                in:managedContext)
            
            let toDo = NSManagedObject(entity: entity!,
                insertInto: managedContext)
           
            toDo.setValue(toDoObject.text, forKey: "text")
            toDo.setValue(0, forKey: "section")
            toDo.setValue(todayList.index(of: toDoObject), forKey: "row")
            toDo.setValue(toDoObject.completed, forKey: "isCompleted")
            
            if(toDoObject.created != nil){
            toDo.setValue(toDoObject.created, forKey: "created")
            }else{
            toDo.setValue(Date(), forKey: "created")
            }
            
        }
        
        for toDoObject in tomorrowList {
            
            let entity =  NSEntityDescription.entity(forEntityName: "ToDo",
                in:managedContext)
            
            let toDo = NSManagedObject(entity: entity!,
                insertInto: managedContext)
            
            //3
            toDo.setValue(toDoObject.text, forKey: "text")
            toDo.setValue(1, forKey: "section")
            toDo.setValue(tomorrowList.index(of: toDoObject), forKey: "row")
            toDo.setValue(toDoObject.completed, forKey: "isCompleted")
            
            if(toDoObject.created != nil){
                toDo.setValue(toDoObject.created, forKey: "created")
            }else{
                toDo.setValue(Date(), forKey: "created")
            }
            
        }
        
        for toDoObject in upcomingList {
            
            
            //2
            let entity =  NSEntityDescription.entity(forEntityName: "ToDo",
                in:managedContext)
            
            let toDo = NSManagedObject(entity: entity!,
                insertInto: managedContext)
            
            //3
            toDo.setValue(toDoObject.text, forKey: "text")
            toDo.setValue(2, forKey: "section")
            toDo.setValue(upcomingList.index(of: toDoObject), forKey: "row")
            toDo.setValue(toDoObject.completed, forKey: "isCompleted")
            
            if(toDoObject.created != nil){
                toDo.setValue(toDoObject.created, forKey: "created")
            }else{
                toDo.setValue(Date(), forKey: "created")
            }
            
        }
        
        for toDoObject in somedayList {
            
            let entity =  NSEntityDescription.entity(forEntityName: "ToDo",
                in:managedContext)
            
            let toDo = NSManagedObject(entity: entity!,
                insertInto: managedContext)
           
            toDo.setValue(toDoObject.text, forKey: "text")
            toDo.setValue(3, forKey: "section")
            toDo.setValue(somedayList.index(of: toDoObject), forKey: "row")
            toDo.setValue(toDoObject.completed, forKey: "isCompleted")
            
            if(toDoObject.created != nil){
                toDo.setValue(toDoObject.created, forKey: "created")
            }else{
                toDo.setValue(Date(), forKey: "created")
            }
            
        }
      
        do {
            try managedContext.save()
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        
        var counter = 0
        
        for obj in todayList{
            if (obj.completed == false){
                counter += 1
            }
        }
        
        UIApplication.shared.applicationIconBadgeNumber = counter
       
        sendCoreDateToWatchOS()
        
    }
    
    @available(iOS 9.0, *)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
         print("Got message from Watch")
        DispatchQueue.main.async(execute: {
        self.loadCoreData()
      
        for (id, obj) in applicationContext {
             if((obj as AnyObject).value(forKey: "isCompleted") as! Bool == true){
                
            for toDo in self.todayList{
           
                if (toDo.text == (obj as AnyObject).value(forKey: "text") as! String){
                    if(toDo.completed == false){
                      
                        toDo.completed = true
                       
                    }else{
                        
                    }
                }else{
                 
                }
            }
             }else{
              
            }
     
        }
      
            self.sortCompleted()
            self.tableView.reloadData()
            self.saveCoreData()
        
            })
        
   
    }
    
    
    func moveItemToTopOfSection(_ toDoItem: ToDoItem, section: Int){
    
       
        var index = 0
        
        switch section{
        case 0:
            for i in 0..<todayList.count {
                if todayList[i] === toDoItem {  // note: === not ==
                    index = i
                    break
                }
            }
            
            if(index == 0){
                saveCoreData()
                return
            }
            
            tableView.moveRow(at: IndexPath(row: index, section: section), to: IndexPath(row: 0, section: section))
            break
        case 1:
            for i in 0..<tomorrowList.count {
                if tomorrowList[i] === toDoItem {  // note: === not ==
                    index = i
                    break
                }
            }
            
            if(index == 0){
                saveCoreData()
                return
            }
            
            tableView.moveRow(at: IndexPath(row: index, section: section), to: IndexPath(row: 0, section: section))
            break
        case 2:
            for i in 0..<upcomingList.count {
                if upcomingList[i] === toDoItem {  // note: === not ==
                    index = i
                    break
                }
            }
            
            if(index == 0){
                saveCoreData()
                return
            }
            
            tableView.moveRow(at: IndexPath(row: index, section: section), to: IndexPath(row: 0, section: section))
            break
        case 3:
            for i in 0..<somedayList.count {
                if somedayList[i] === toDoItem {  // note: === not ==
                    index = i
                    break
                }
            }
            
            if(index == 0){
                saveCoreData()
                return
            }
            
            tableView.moveRow(at: IndexPath(row: index, section: section), to: IndexPath(row: 0, section: section))
            break
        default:
            break
        }
        
        switch section{
        case 0:
            
            todayList.remove(at: index)
            break
        case 1:
            tomorrowList.remove(at: index)
            break
        case 2:
            upcomingList.remove(at: index)
            break
        case 3:
            somedayList.remove(at: index)
            break
        default:
            break
        }
        
        switch section{
        case 0:
            todayList.insert(toDoItem, at: 0)
            break
        case 1:
            tomorrowList.insert(toDoItem, at: 0)
            break
        case 2:
            upcomingList.insert(toDoItem, at: 0)
            break
        case 3:
            somedayList.insert(toDoItem, at: 0)
            break
        default:
            break
        }
        
    saveCoreData()
    }
    
    func moveItemToLowestBottomOfSection(_ toDoItem: ToDoItem, section: Int){
        
        var index = 0
        var max = 0
        
        switch section{
        case 0:
            for i in 0..<todayList.count {
                if todayList[i] === toDoItem {  // note: === not ==
                    index = i
                }
                max = todayList.count
            }
         
            if(index == max+1){
                saveCoreData()
                return
            }
            
            tableView.moveRow(at: IndexPath(row: index, section: section), to: IndexPath(row: max-1, section: section))
            break
        case 1:
            for i in 0..<tomorrowList.count {
                if tomorrowList[i] === toDoItem {  // note: === not ==
                    index = i
                }
               max = tomorrowList.count
            }
            
            if(index == max+1){
                saveCoreData()
                return
            }
            
            tableView.moveRow(at: IndexPath(row: index, section: section), to: IndexPath(row: max-1, section: section))
            break
        case 2:
            for i in 0..<upcomingList.count {
                if upcomingList[i] === toDoItem {  // note: === not ==
                    index = i
                }
               max = upcomingList.count
            }
            
            if(index == max+1){
                saveCoreData()
                return
            }
            
            tableView.moveRow(at: IndexPath(row: index, section: section), to: IndexPath(row: max-1, section: section))
            break
        case 3:
            for i in 0..<somedayList.count {
                if somedayList[i] === toDoItem {  // note: === not ==
                    index = i
                }
               max = somedayList.count
            }
            
            if(index == max+1){
                saveCoreData()
                return
            }
            
            tableView.moveRow(at: IndexPath(row: index, section: section), to: IndexPath(row: max-1, section: section))
            break
        default:
            break
        }
        
        
        
        switch section{
        case 0:
            
            todayList.remove(at: index)
            break
        case 1:
            tomorrowList.remove(at: index)
            break
        case 2:
            upcomingList.remove(at: index)
            break
        case 3:
            somedayList.remove(at: index)
            break
        default:
            break
        }
     
        switch section{
        case 0:
            todayList.insert(toDoItem, at: max-1)
            
            break
        case 1:
            tomorrowList.insert(toDoItem, at: max-1)
            break
        case 2:
            upcomingList.insert(toDoItem, at: max-1)
            break
        case 3:
            somedayList.insert(toDoItem, at: max-1)
            break
        default:
            break
        }
      
        saveCoreData()
    }
    
    func moveItemToBottomOfSection(_ toDoItem: ToDoItem, section: Int){
    
        var index = 0
        var max = 0
       
        switch section{
        case 0:
            for i in 0..<todayList.count {
                if todayList[i] === toDoItem {  // note: === not ==
                    index = i
                }
                if(!todayList[i].completed){
                    max = i
                }
            }
            
         
            
            if(index == max+1){
                saveCoreData()
                return
            }
            
            tableView.moveRow(at: IndexPath(row: index, section: section), to: IndexPath(row: max, section: section))
            break
        case 1:
            for i in 0..<tomorrowList.count {
                if tomorrowList[i] === toDoItem {  // note: === not ==
                    index = i
                }
                if(!tomorrowList[i].completed){
                    max = i
                }
            }
            
            if(index == max+1){
                saveCoreData()
                return
            }
            
            tableView.moveRow(at: IndexPath(row: index, section: section), to: IndexPath(row: max, section: section))
            break
        case 2:
            for i in 0..<upcomingList.count {
                if upcomingList[i] === toDoItem {  // note: === not ==
                    index = i
                }
                if(!upcomingList[i].completed){
                    max = i
                }
            }
            
            if(index == max+1){
                saveCoreData()
                return
            }
            
            tableView.moveRow(at: IndexPath(row: index, section: section), to: IndexPath(row: max, section: section))
            break
        case 3:
            for i in 0..<somedayList.count {
                if somedayList[i] === toDoItem {  // note: === not ==
                    index = i
                }
                if(!somedayList[i].completed){
                    max = i
                }
            }
            
            if(index == max+1){
                saveCoreData()
                return
            }
            
            tableView.moveRow(at: IndexPath(row: index, section: section), to: IndexPath(row: max, section: section))
            break
        default:
            break
        }
        
        
        
        switch section{
        case 0:
           
            todayList.remove(at: index)
            break
        case 1:
            tomorrowList.remove(at: index)
            break
        case 2:
            upcomingList.remove(at: index)
            break
        case 3:
            somedayList.remove(at: index)
            break
        default:
            break
        }
        
        switch section{
        case 0:
            todayList.insert(toDoItem, at: max)
           
            break
        case 1:
            tomorrowList.insert(toDoItem, at: max)
            break
        case 2:
            upcomingList.insert(toDoItem, at: max)
            break
        case 3:
            somedayList.insert(toDoItem, at: max)
            break
        default:
            break
        }
        saveCoreData()
    }
    
    
    func toDoItemDeleted(_ toDoItem: ToDoItem, section: Int) {
       
        // could use this to get index when Swift Array indexOfObject works
        // let index = toDoItems.indexOfObject(toDoItem)
        // in the meantime, scan the array to find index of item to delete
        var index = 0
        
        // could removeAtIndex in the loop but keep it here for when indexOfObject works
        
        switch section{
        case 0:
            for i in 0..<todayList.count {
                if todayList[i] === toDoItem {  // note: === not ==
                    index = i
                    break
                }
            }
            todayList.remove(at: index)
            break
        case 1:
            for i in 0..<tomorrowList.count {
                if tomorrowList[i] === toDoItem {  // note: === not ==
                    index = i
                    break
                }
            }
            tomorrowList.remove(at: index)
            break
        case 2:
            for i in 0..<upcomingList.count {
                if upcomingList[i] === toDoItem {  // note: === not ==
                    index = i
                    break
                }
            }
            upcomingList.remove(at: index)
            break
        case 3:
            for i in 0..<somedayList.count {
                if somedayList[i] === toDoItem {  // note: === not ==
                    index = i
                    break
                }
            }
            somedayList.remove(at: index)
            break
        default:
            break
        }
        
        
        // loop over the visible cells to animate delete
        var sectionIndex = 0
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        let lastView = visibleCells[visibleCells.count - 1] as TableViewCell
        var delay = 0.0
        var startAnimating = false
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            if startAnimating {
                UIView.animate(withDuration: 0.3, delay: delay, options: UIViewAnimationOptions(),
                    animations: {() in
                        cell.frame = cell.frame.offsetBy(dx: 0.0, dy: -cell.frame.size.height)},
                    completion: {(finished: Bool) in if (cell == lastView) {
                        self.tableView.reloadData()
                        }
                    }
                )
                delay += 0.03
            }
            if cell.toDoItem === toDoItem {
                startAnimating = true
                cell.isHidden = true
                sectionIndex = cell.tag
            }
        }
        
        tableView.beginUpdates()
        let indexPathForRow = IndexPath(row: index, section: sectionIndex)
        tableView.deleteRows(at: [indexPathForRow], with: .fade)
        tableView.endUpdates()
        
        
        saveCoreData()
    }
    // MARK: - Table view delegate
    
    func colorForIndex(_ index: Int) -> UIColor {
    
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    let kRowHeight: CGFloat = 50.0
    func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
            return kRowHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
            cell.backgroundColor = colorForIndex(indexPath.row)
            cell.textLabel?.textColor = UIColor.black
    }

    // MARK: - pinch-to-add methods
    
    struct TouchPoints {
        var upper: CGPoint
        var lower: CGPoint
    }
    // the indices of the upper and lower cells that are being pinched
    var upperCellIndex = -100
    var lowerCellIndex = -100
    var middleCellSection = -100
    // the location of the touch points when the pinch began
    var initialTouchPoints: TouchPoints!
    // indicates that the pinch was big enough to cause a new item to be added
    var pinchExceededRequiredDistance = false

    // indicates that the pinch is in progress
    var pinchInProgress = false
    
    func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began {
            pinchStarted(recognizer)
        }
        if recognizer.state == .changed
            && pinchInProgress
            && recognizer.numberOfTouches == 2 {
                pinchChanged(recognizer)
        }
        if recognizer.state == .ended {
            pinchEnded(recognizer)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func snapshopOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
    
        if(isEditingMode == true){
            return
        }
        
        
        
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        struct My {
            
            static var cellSnapshot : UIView? = nil
            
        }
        struct Path {
            
            static var initialIndexPath : IndexPath? = nil
            
        }
        
        switch state {
        case UIGestureRecognizerState.began:
            
            let app = UIApplication.shared.delegate as! AppDelegate
            app.isLongPressMode = true
            
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshopOfCell(cell!)
                var center = cell?.center
                
                My.cellSnapshot!.center = center!
                
                My.cellSnapshot!.alpha = 0.0
                
                tableView.addSubview(My.cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    
                    My.cellSnapshot!.center = center!
                    
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    
                    My.cellSnapshot!.alpha = 0.98
                    
                    cell?.alpha = 0.0
                    
                    }, completion: { (finished) -> Void in
                        
                        if finished {
                            
                            cell?.isHidden = true
                           // self.tableView.reloadData()
                            
                        }
                        
                })
                
            }
            
            break
        case UIGestureRecognizerState.changed:
            
            let app = UIApplication.shared.delegate as! AppDelegate
            app.isLongPressMode = true
            
            var center = My.cellSnapshot!.center
            center.y = locationInView.y
            My.cellSnapshot!.center = center
            if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
          
                var item = ToDoItem(text: "")
                
                switch Path.initialIndexPath!.section{
                case 0:
                    item = todayList[Path.initialIndexPath!.row]
                    todayList.remove(at: Path.initialIndexPath!.row)
                    break
                case 1:
                    item = tomorrowList[Path.initialIndexPath!.row]
                    tomorrowList.remove(at: Path.initialIndexPath!.row)
                    break
                case 2:
                    item = upcomingList[Path.initialIndexPath!.row]
                    upcomingList.remove(at: Path.initialIndexPath!.row)
                    break
                case 3:
                    item = somedayList[Path.initialIndexPath!.row]
                    somedayList.remove(at: Path.initialIndexPath!.row)
                    break
                default:
                    break
                }
                
                switch indexPath!.section{
                case 0:
                    todayList.insert(item, at: indexPath!.row)
                    break
                case 1:
                    tomorrowList.insert(item, at: indexPath!.row)
                    break
                case 2:
                    upcomingList.insert(item, at: indexPath!.row)
                    break
                case 3:
                    somedayList.insert(item, at: indexPath!.row)
                    break
                default:
                    break
                }
           
                tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                
                Path.initialIndexPath = indexPath
                
                
            }else if (indexPath == nil){
                
                // check nach headers
                
               
                if(locationInView.y >= somedayHeader.contentView.frame.origin.y){
                    
                    var item = ToDoItem(text: "")
                    
                    switch Path.initialIndexPath!.section{
                    case 0:
                        item = todayList[Path.initialIndexPath!.row]
                        todayList.remove(at: Path.initialIndexPath!.row)
                        break
                    case 1:
                        item = tomorrowList[Path.initialIndexPath!.row]
                        tomorrowList.remove(at: Path.initialIndexPath!.row)
                        break
                    case 2:
                        item = upcomingList[Path.initialIndexPath!.row]
                        upcomingList.remove(at: Path.initialIndexPath!.row)
                        break
                    case 3:
                        item = somedayList[Path.initialIndexPath!.row]
                        somedayList.remove(at: Path.initialIndexPath!.row)
                        break
                    default:
                        break
                    }
                    
                    somedayList.insert(item, at: 0)
                    tableView.moveRow(at: Path.initialIndexPath!, to: IndexPath(row: 0, section: 3))
                    Path.initialIndexPath = IndexPath(row: 0, section: 3)
                    
                }else if(locationInView.y >= upcomingHeader.contentView.frame.origin.y){
                    
                    var item = ToDoItem(text: "")
                    
                    switch Path.initialIndexPath!.section{
                    case 0:
                        item = todayList[Path.initialIndexPath!.row]
                        todayList.remove(at: Path.initialIndexPath!.row)
                        break
                    case 1:
                        item = tomorrowList[Path.initialIndexPath!.row]
                        tomorrowList.remove(at: Path.initialIndexPath!.row)
                        break
                    case 2:
                        item = upcomingList[Path.initialIndexPath!.row]
                        upcomingList.remove(at: Path.initialIndexPath!.row)
                        break
                    case 3:
                        item = somedayList[Path.initialIndexPath!.row]
                        somedayList.remove(at: Path.initialIndexPath!.row)
                        break
                    default:
                        break
                    }
                    
                    upcomingList.insert(item, at: 0)
                    tableView.moveRow(at: Path.initialIndexPath!, to: IndexPath(row: 0, section: 2))
                    Path.initialIndexPath = IndexPath(row: 0, section: 2)
                    
                }else if(locationInView.y >= tomorrowHeader.contentView.frame.origin.y){
                    
                    var item = ToDoItem(text: "")
                    
                    switch Path.initialIndexPath!.section{
                    case 0:
                        item = todayList[Path.initialIndexPath!.row]
                        todayList.remove(at: Path.initialIndexPath!.row)
                        break
                    case 1:
                        item = tomorrowList[Path.initialIndexPath!.row]
                        tomorrowList.remove(at: Path.initialIndexPath!.row)
                        break
                    case 2:
                        item = upcomingList[Path.initialIndexPath!.row]
                        upcomingList.remove(at: Path.initialIndexPath!.row)
                        break
                    case 3:
                        item = somedayList[Path.initialIndexPath!.row]
                        somedayList.remove(at: Path.initialIndexPath!.row)
                        break
                    default:
                        break
                    }
                    
                    tomorrowList.insert(item, at: 0)
                    tableView.moveRow(at: Path.initialIndexPath!, to: IndexPath(row: 0, section: 1))
                    Path.initialIndexPath = IndexPath(row: 0, section: 1)
                    
                }else if(locationInView.y >= todayHeader.contentView.frame.origin.y){
                    
                    var item = ToDoItem(text: "")
                    
                    switch Path.initialIndexPath!.section{
                    case 0:
                        item = todayList[Path.initialIndexPath!.row]
                        todayList.remove(at: Path.initialIndexPath!.row)
                        break
                    case 1:
                        item = tomorrowList[Path.initialIndexPath!.row]
                        tomorrowList.remove(at: Path.initialIndexPath!.row)
                        break
                    case 2:
                        item = upcomingList[Path.initialIndexPath!.row]
                        upcomingList.remove(at: Path.initialIndexPath!.row)
                        break
                    case 3:
                        item = somedayList[Path.initialIndexPath!.row]
                        somedayList.remove(at: Path.initialIndexPath!.row)
                        break
                    default:
                        break
                    }
                    
                    todayList.insert(item, at: 0)
                    tableView.moveRow(at: Path.initialIndexPath!, to: IndexPath(row: 0, section: 0))
                    Path.initialIndexPath = IndexPath(row: 0, section: 0)
                    
                }
                
                
            }
            
            break
        default:
            
            let app = UIApplication.shared.delegate as! AppDelegate
            app.isLongPressMode = false
            
            let cell = tableView.cellForRow(at: Path.initialIndexPath!) as UITableViewCell!
            cell?.isHidden = false
            cell?.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                My.cellSnapshot!.center = (cell?.center)!
                My.cellSnapshot!.transform = CGAffineTransform.identity
                My.cellSnapshot!.alpha = 0.0
                cell?.alpha = 1.0
                }, completion: { (finished) -> Void in
                    if finished {
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                        self.tableView.reloadData()
                        
                        
                    }
            })
            
            saveCoreData()
            break
        }
       
        
    }
    func pinchStarted(_ recognizer: UIPinchGestureRecognizer) {
        if(isEditingMode == true){
            return
        }
        
        // find the touch-points
        initialTouchPoints = getNormalizedTouchPoints(recognizer)
        
        // locate the cells that these points touch
        upperCellIndex = -100
        lowerCellIndex = -100
        let visibleCells = tableView.visibleCells  as! [TableViewCell]
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            if viewContainsPoint(cell, point: initialTouchPoints.upper) {
                upperCellIndex = i
            }
            if viewContainsPoint(cell, point: initialTouchPoints.lower) {
                lowerCellIndex = i
                
                middleCellSection = cell.tag
                
            }
        }
        // check whether they are neighbors
        if abs(upperCellIndex - lowerCellIndex) == 1 {
            // initiate the pinch
            pinchInProgress = true
            // show placeholder cell
            let precedingCell = visibleCells[upperCellIndex]
            placeHolderCell.frame = precedingCell.frame.offsetBy(dx: 0.0, dy: kRowHeight / 2.0)
            placeHolderCell.backgroundColor = precedingCell.backgroundColor
            tableView.insertSubview(placeHolderCell, at: 0)
        }
    }
    
    func pinchChanged(_ recognizer: UIPinchGestureRecognizer) {
        
        if(isEditingMode == true){
            return
        }
        
        // find the touch points
        let currentTouchPoints = getNormalizedTouchPoints(recognizer)
        
        // determine by how much each touch point has changed, and take the minimum delta
        let upperDelta = currentTouchPoints.upper.y - initialTouchPoints.upper.y
        let lowerDelta = initialTouchPoints.lower.y - currentTouchPoints.lower.y
        let delta = -min(0, min(upperDelta, lowerDelta))
        
        // offset the cells, negative for the cells above, positive for those below
        let visibleCells = tableView.visibleCells as! [TableViewCell]
        for i in 0..<visibleCells.count {
            let cell = visibleCells[i]
            if i <= upperCellIndex {
                cell.transform = CGAffineTransform(translationX: 0, y: -delta)
            }
            if i >= lowerCellIndex {
                cell.transform = CGAffineTransform(translationX: 0, y: delta)
            }
        }
        
        // scale the placeholder cell
        let gapSize = delta * 2
        let cappedGapSize = min(gapSize, tableView.rowHeight)
        placeHolderCell.transform = CGAffineTransform(scaleX: 1.0, y: cappedGapSize / tableView.rowHeight)
        placeHolderCell.label.text = gapSize > tableView.rowHeight ? "Release to add item" : "Pull apart to add item"
        placeHolderCell.alpha = min(1.0, gapSize / tableView.rowHeight)
        
        // has the user pinched far enough?
        pinchExceededRequiredDistance = gapSize > tableView.rowHeight
    }
    
    func pinchEnded(_ recognizer: UIPinchGestureRecognizer) {
        
        if(isEditingMode == true){
            return
        }
        
        pinchInProgress = false
        
        // remove the placeholder cell
        placeHolderCell.transform = CGAffineTransform.identity
        placeHolderCell.removeFromSuperview()
        
        if pinchExceededRequiredDistance {
            pinchExceededRequiredDistance = false

            // Set all the cells back to the transform identity
            let visibleCells = self.tableView.visibleCells as! [TableViewCell]
            for cell in visibleCells {
                cell.transform = CGAffineTransform.identity
            }
            
            // add a new item
            let indexOffset = Int(floor(tableView.contentOffset.y / tableView.rowHeight))
           
          //  // // print(lowerCellIndex + indexOffset)
            
            toDoItemAddedAtIndex(lowerCellIndex + indexOffset, section: middleCellSection)
        } else {
            // otherwise, animate back to position
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: {() in
                let visibleCells = self.tableView.visibleCells as! [TableViewCell]
                for cell in visibleCells {
                    cell.transform = CGAffineTransform.identity
                }
                }, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // returns the two touch points, ordering them to ensure that
    // upper and lower are correctly identified.
    func getNormalizedTouchPoints(_ recognizer: UIGestureRecognizer) -> TouchPoints {
        var pointOne = recognizer.location(ofTouch: 0, in: tableView)
        var pointTwo = recognizer.location(ofTouch: 1, in: tableView)
        // ensure pointOne is the top-most
        if pointOne.y > pointTwo.y {
            let temp = pointOne
            pointOne = pointTwo
            pointTwo = temp
        }
        return TouchPoints(upper: pointOne, lower: pointTwo)
    }
    
    func viewContainsPoint(_ view: UIView, point: CGPoint) -> Bool {
        let frame = view.frame
        return (frame.origin.y < point.y) && (frame.origin.y + (frame.size.height) > point.y)
    }
    
    // MARK: - UIScrollViewDelegate methods
    // contains scrollViewDidScroll, and you'll add two more, to keep track of dragging the scrollView

    // a cell that is rendered as a placeholder to indicate where a new item is added
    let placeHolderCell = TableViewCell(style: .default, reuseIdentifier: "cell")
    // indicates the state of this behavior
    var pullDownInProgress = false

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
   
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView)  {
     
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        tableView.reloadData()
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
      
    }
    
    // MARK: - add, delete, edit methods
    
    func toDoItemAdded(_ section: Int) {
        toDoItemAddedAtIndex(0, section: section)
    }
    

    
    func toDoItemAddedAtIndex(_ index: Int, section: Int) {
        let toDoItem = ToDoItem(text: "")
        
        toDoItem.created = Date()
        
        switch section{
        case 0:
            todayList.insert(toDoItem, at: index)
            break
        case 1:
            tomorrowList.insert(toDoItem, at: index)
            break
        case 2:
            upcomingList.insert(toDoItem, at: index)
            break
        case 3:
            somedayList.insert(toDoItem, at: index)
            break
        default:
            break
        }
        
        tableView.reloadData()
       
        
        
        tableView.selectRow(at: IndexPath(row: index, section: section), animated: false, scrollPosition: UITableViewScrollPosition.top)
        
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: section)) as! TableViewCell
        
        cell.label.isEnabled = true
        cell.label.becomeFirstResponder()
         
     
    }
}

