//
//  SettingsViewController.swift
//  Yelp
//
//  Created by Andrew Wilkes on 9/7/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func settingsViewController(settingsViewController: SettingsViewController, didUpdateFilters preferences: Preferences?)
}

enum SettingSections: Int {
    case Length = 0, LongBreak, Alarm, Lock
}

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, PickerCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var switchStates = [Int:Bool]()
    
    var delegate: SettingsViewControllerDelegate?
    
    let sectionHeaders = [
        "Timer Length",
        "Long Break",
        "Alarm",
        "Screen Lock"
    ]
    
    var sectionRowCounts = [
        2,
        2,
        2,
        1 // show a few first, then potentially expand
    ]
    
    var preferences = Preferences()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80 // only used for scroll height dimension
        
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        navigationController!.navigationBar.barTintColor = UIColor(red:0.753, green:0.063, blue:0.004, alpha:1.00)

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == SettingSections.Length.rawValue {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! PickerCell
            if(indexPath.row==0) {
                preferences.worklength = cell.topNameLabel.text!  }
            else
            {  preferences.breaklength = cell.topNameLabel.text!  }
            sectionRowCounts[SettingSections.Length.rawValue] = 1
            tableView.reloadData()
   
        } else if indexPath.section == SettingSections.LongBreak.rawValue {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! PickerCell
            preferences.longbreakLength = cell.topNameLabel.text!
            sectionRowCounts[SettingSections.LongBreak.rawValue] = 1
            tableView.reloadData()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionHeaders.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SettingSections.Lock.rawValue  {
                return 1
        } else {
            return sectionRowCounts[section]
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case SettingSections.Lock.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            
            cell.delegate = self
            cell.switchLabel.text = "Screen Lock"
            cell.onSwitch.on = preferences.screenlock
            
            return cell

        case SettingSections.Length.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("PickerCell", forIndexPath: indexPath) as! PickerCell

            
            if indexPath.row != 0 || sectionRowCounts[indexPath.section] != 1 {
                cell.dropDownButton.hidden = true
                cell.topNameLabel.text = preferences.minutesValues[indexPath.row]
            } else {
                cell.dropDownButton.hidden = false
                cell.topNameLabel.text = "Best Match"   //preferences.lock ??
            }
            
            cell.delegate = self
            
            return cell
        case SettingSections.LongBreak.rawValue:
            if(indexPath.row==0) {
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
                
                cell.delegate = self
                cell.switchLabel.text = "Enable Long Break"
                cell.onSwitch.on = switchStates[indexPath.row] ?? false
                
                return cell

            }else
            {
  
            let cell = tableView.dequeueReusableCellWithIdentifier("PickerCell", forIndexPath: indexPath) as! PickerCell
            
            cell.topNameLabel.text = preferences.worklength ?? "25 minutes"
            
            if indexPath.row != 0  || sectionRowCounts[indexPath.section] != 1 {
                cell.dropDownButton.hidden = true
                cell.topNameLabel.text = "hello"   //preferences.sortByValues[indexPath.row]
            } else {
                cell.dropDownButton.hidden = false
                cell.topNameLabel.text = "hello2"    //preferences.sortName ?? "25 minutes"
            }
        
            cell.delegate = self
            
            return cell
            }
            
        default:
            let rowCount = sectionRowCounts[SettingSections.Lock.rawValue]
            
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
                
                cell.delegate = self
                cell.switchLabel.text = "Screen Lock"
                cell.onSwitch.on = switchStates[indexPath.row] ?? false
                
                return cell
            
        }
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let index = tableView.indexPathForCell(switchCell)!
        
        let section = index.section
        
        switch(section) {
        case SettingSections.Alarm.rawValue:
            preferences.alarm = value
        default:
            switchStates[index.row] = value
        }
    }
    
    func pickerCell(pickerCell: PickerCell, didClickExpand value: Bool) {
        let section = tableView.indexPathForCell(pickerCell)!.section as Int
        
        if section == SettingSections.Length.rawValue {
            sectionRowCounts[section] = sectionRowCounts[section] == 1 ? 5 : 1
        } else if section == SettingSections.LongBreak.rawValue {
            sectionRowCounts[section] = sectionRowCounts[section] == 1 ? 3 : 1
        }
        tableView.reloadData()
    }
    
 
    
  
}
