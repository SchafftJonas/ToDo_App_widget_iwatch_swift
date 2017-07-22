//
//  SettingsViewController.swift
//
//  Created by Jonas Schafft on 1/12/2015.
//  Copyright (c) 2015 Jonas Schafft. All rights reserved.
//

import UIKit
import CoreData

extension UIColor {
    
    func red() -> CGFloat? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
           
            return fRed
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    
    func green() -> CGFloat? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
         
            return fGreen
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    
    func blue() -> CGFloat? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
          
            return fBlue
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

class SettingsViewController: UIViewController,SwiftHUEColorPickerDelegate {

    @IBOutlet weak var showAddButtonSwitch: UISwitch?
    @IBOutlet weak var autoCorrectEnabledSwitch: UISwitch?
    @IBOutlet weak var notificationsEnabledSwitch: UISwitch?
    @IBOutlet weak var dailyUpdateSwitch: UISwitch?
    @IBOutlet weak var currentColorView: UIView?
    
    @IBOutlet weak var horizontalColorPicker: SwiftHUEColorPicker!
    
    var settings = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadSwitchSettings()
        loadColorPicker()
        
        currentColorView?.backgroundColor = horizontalColorPicker.currentColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadColorPicker(){
      
        horizontalColorPicker.delegate = self
        horizontalColorPicker.direction = SwiftHUEColorPicker.PickerDirection.horizontal
        
        
    }
    
    func valuePicked(_ color: UIColor, type: SwiftHUEColorPicker.PickerType) {
       
        currentColorView?.backgroundColor = horizontalColorPicker.currentColor
        
        notificationsEnabledSwitch?.isOn = true
        
    }
    
    func loadSwitchSettings(){
        
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
        
        for setting in settings{
            
            if(setting.value(forKey: "autoCorrectEnabledSwitch") as? Bool == true)
            {
                autoCorrectEnabledSwitch?.isOn = true
            }else{
                autoCorrectEnabledSwitch?.isOn = false
            }
            
            if(setting.value(forKey: "dailyUpdateSwitch") as? Bool == true)
            {
                dailyUpdateSwitch?.isOn = true
            }else{
                dailyUpdateSwitch?.isOn = false
            }
            
            if(setting.value(forKey: "notificationsEnabledSwitch") as? Bool == true)
            {
                notificationsEnabledSwitch?.isOn = true
            }else{
                notificationsEnabledSwitch?.isOn = false
            }
            
            if(setting.value(forKey: "showAddButton") as? Bool == true)
            {
                showAddButtonSwitch?.isOn = true
            }else{
                showAddButtonSwitch?.isOn = false
            }
            
            let colorR = setting.value(forKey: "pickedColorR") as! Float
            let colorG = setting.value(forKey: "pickedColorG") as! Float
            let colorB = setting.value(forKey: "pickedColorB") as! Float
            
           horizontalColorPicker.currentColor = UIColor(red: CGFloat(colorR), green: CGFloat(colorG), blue: CGFloat(colorB), alpha: 1.0)
            currentColorView?.backgroundColor = UIColor(red: CGFloat(colorR), green: CGFloat(colorG), blue: CGFloat(colorB), alpha: 1.0) 
            
            
        }
        
    }
    
    func saveSwitchSettings(){
        
        //1
        let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        
        do {
            let results =
            try managedContext.fetch(request)
            settings = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        for bas: AnyObject in settings
        {
            managedContext.delete(bas as! NSManagedObject)
        }
        
        settings.removeAll(keepingCapacity: false)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        let entity =  NSEntityDescription.entity(forEntityName: "Settings",
            in:managedContext)
        
        let toDo = NSManagedObject(entity: entity!,
            insertInto: managedContext)
        
        //3
        toDo.setValue(showAddButtonSwitch?.isOn, forKey: "showAddButton")
        toDo.setValue(dailyUpdateSwitch?.isOn, forKey: "dailyUpdateSwitch")
        toDo.setValue(notificationsEnabledSwitch?.isOn, forKey: "notificationsEnabledSwitch")
        toDo.setValue(autoCorrectEnabledSwitch?.isOn, forKey: "autoCorrectEnabledSwitch")
        
        toDo.setValue(horizontalColorPicker.currentColor.red(), forKey: "pickedColorR")
        toDo.setValue(horizontalColorPicker.currentColor.green(), forKey: "pickedColorG")
        toDo.setValue(horizontalColorPicker.currentColor.blue(), forKey: "pickedColorB")
        
        //4
        do {
            try managedContext.save()
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBAction func backButtonPressed(_ sender:AnyObject) {
    
        
        saveSwitchSettings()
        
        self.dismiss(animated: true, completion: nil)
       
    }
    
    @IBAction func showAddButtonSwitchChanged(_ switchState: UISwitch) {
        if switchState.isOn {
            
        } else {
           
        }
    }
    
    @IBAction func autoCorrectEnabledSwitch(_ switchState: UISwitch) {
        if switchState.isOn {
            
        } else {
            
        }
    }
    
    @IBAction func notificationsEnabledSwitch(_ switchState: UISwitch) {
        if switchState.isOn {
            
        } else {
            
        }
    }
    
    @IBAction func dailyUpdateSwitch(_ switchState: UISwitch) {
        if switchState.isOn {
            
        } else {
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
