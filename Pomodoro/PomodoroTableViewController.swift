//
//  PomodoroTableViewController.swift
//  Pomodoro
//
//  Created by Shannon Coyne on 8/1/15.
//  Copyright (c) 2015 Shannon Coyne. All rights reserved.
//

import UIKit

struct Identifiers {
    static let addNewSegue = "add new"
    static let showPomodoroSegue = "show pomodoro"
    static let showSettingsSegue = "show settings"
}

struct ErrorMsgs {
    static let couldntLoadPomodoro = "couldn't load pomodoro"
}

class PomodoroTableViewController: UITableViewController {
    let model = PomodoroModel()
    let settingsModel = SettingsModel()
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.pomodori.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pomodoro cell", forIndexPath: indexPath) 
        
        if let pomodoro = model.getPomodoroFromIndexPathRow(indexPath.row) {
            cell.textLabel!.text = pomodoro.name
            let numIntervals = pomodoro.numIntervals
            let intervalLength = pomodoro.intervalLength
            let breakLength = pomodoro.breakLength
            
            cell.detailTextLabel!.text = "\(numIntervals) Intervals / \(intervalLength) minute intervals / \(breakLength) minute breaks"
            
            return cell
        }
        // error catch:
        cell.textLabel!.text = ErrorMsgs.couldntLoadPomodoro
        cell.detailTextLabel!.text = ErrorMsgs.couldntLoadPomodoro
        
        return cell
    }

   

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            model.deletePomodoro(row: indexPath.row)

            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier ?? "MISSING" {
        case Identifiers.addNewSegue:
            if let navController = segue.destinationViewController as? UINavigationController {
                if let addNewVC = navController.viewControllers.first as? AddNewViewController {
                    addNewVC.model = model
                }
            }
            else {
                assertionFailure("destination of segue was not an AddNewViewController")
            }
        case Identifiers.showPomodoroSegue:
            if let indexPath = tableView.indexPathForSelectedRow {
                if let pomodoroVC = segue.destinationViewController as? PomodoroViewController {
                    if let pomodoro = model.getPomodoroFromIndexPathRow(indexPath.row) {
                        pomodoroVC.title = "\(pomodoro.name)"
                        pomodoroVC.settingsModel = settingsModel
                        pomodoroVC.pomodoro = model.getPomodoroFromIndexPathRow(indexPath.row)
                    } else {
                        assertionFailure("pomodoro does not exist on disk")
                    }
                }
                else {
                    assertionFailure("destination of segue was not a PomodoroViewController")
                }
            }
            else {
                assertionFailure("prepareForSegue called when no row selected")
            }
        case Identifiers.showSettingsSegue:
            
                //do nothing
            print("hello")
        
        default:
            assertionFailure("unknown segue ID \(segue.identifier)")
        }
    }
    
    @IBAction func unwindToPomodoroList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? AddNewViewController {
            let newIndexPath = NSIndexPath(forRow: model.pomodori.count, inSection: 0)
            
            tableView.reloadData()
        }
    }
}
