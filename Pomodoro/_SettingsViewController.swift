//
//  SettingsViewController.swift
//  Pomodoro
//
//  Created by Shannon Coyne on 8/1/15.
//  Copyright (c) 2015 Shannon Coyne. All rights reserved.
//

import UIKit



class SettingsViewController: UITableViewController , SwitchCellDelegate ,PickerCellDelegate {
    var model: SettingsDelegate!

    @IBOutlet weak var BreakTimerLength: PickerCell!
    @IBOutlet weak var vibrateUISwitch: UISwitch! {
        didSet {
            if !model.vibrate {
                vibrateUISwitch.on = false
            }
        }
    }
    @IBOutlet weak var notificationsUISwitch: UISwitch! {
        didSet {
            if !model.notifications {
                notificationsUISwitch.on = false
            }
        }
    }
  
    // MARK: - Navigation
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            switch(indexPath.section) {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("PickerCell", forIndexPath: indexPath) as! PickerCell

                if indexPath.row != 0  {
                    cell.dropDownButton.hidden = true
                    cell.topNameLabel.text = "Best Match"
                } else {
                    cell.dropDownButton.hidden = false
                    cell.topNameLabel.text = "Best Match2"
                }
                
                cell.delegate = self
                
                return cell
        

            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
                
                cell.delegate = self
                cell.switchLabel.text = "Offering a deal?"
                cell.onSwitch.on = preferences.deals!
                
                return cell
                
          }
    }
    
            //PickerCell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                if indexPath.section == 0 {
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! PickerCell
                    
                    sectionRowCounts[FilterSections.Distance.rawValue] = 1
                    tableView.reloadData()
                }
        }


    override func viewDidLoad() {
        
        
    }
        
  /*  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            // good stuff!
        } else {
            assertionFailure("sender and saveButton not the same object instance")
        }
    }
*/

}
