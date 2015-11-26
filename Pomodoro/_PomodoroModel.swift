//
//  PomodoroModel.swift
//  Pomodoro
//
//  Created by Shannon Coyne on 8/1/15.
//  Copyright (c) 2015 Shannon Coyne. All rights reserved.
//

import UIKit
import CoreData

struct Pomodoro {
    var name: String
    var intervalLength: Int
    var numIntervals: Int
    var breakLength: Int
}

struct PomodoroModelKeys {
    static let pomodoro = "Pomodoro"
    static let name = "name"
    static let intervalLength = "intervalLength"
    static let numIntervals = "numIntervals"
    static let breakLength = "breakLength"
}

struct PomodoroModelMessages {
    static let notificationName = "PomodoroModel"
    static let notificationEventKey = "message"
    static let modelChangeDidFail = "failed"
    static let modelChangeDidSucceed = "succeeded"
}

protocol PomodoroDelegate: class {
    var name: String! { get }
    var numIntervals: Int! { get }
    var intervalLength: Int! { get }
    var breakLength: Int! { get }
    
    func userInputIsValid(input: String, field: String)
    func getPomodoroFromIndexPathRow(row: Int) -> Pomodoro?
    func savePomodoro(name: String, numIntervals: Int, intervalLength: Int, breakLength: Int)
}

class PomodoroModel: PomodoroDelegate {
    struct DefaultValuesAndLimits {
        static let minLength = 1
        static let maxLength = 60
        
        static let defaultName = "New Pomodoro"
        static let defaultnumIntervals = 3
        static let defaultintervalLength = 25
        static let defaultBreakLength = 5
    }
    
    var pomodori = [NSManagedObject]()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext: NSManagedObjectContext
    let entity: NSEntityDescription
    
    // build up and store values of a new pomodoro before saving it
    var name: String!
    var numIntervals: Int!
    var intervalLength: Int!
    var breakLength: Int!
    
    required init() {
        managedContext = appDelegate.managedObjectContext!
        entity = NSEntityDescription.entityForName(PomodoroModelKeys.pomodoro, inManagedObjectContext: managedContext)!
        loadPomodori() // load persisted data from core data
        resetFieldsToDefaults()
    }
    
    private func resetFieldsToDefaults() {
        name = DefaultValuesAndLimits.defaultName
        numIntervals = DefaultValuesAndLimits.defaultnumIntervals
        intervalLength = DefaultValuesAndLimits.defaultintervalLength
        breakLength = DefaultValuesAndLimits.defaultBreakLength
    }
    
    func userInputIsValid(input: String, field: String) {
        var success = false
        
        switch field {
        case PomodoroModelKeys.name: // validate string value
            if !input.isEmpty {
                name = input // store the name and report modelChangeDidSucceed.
                success = true
            } else {
                // modelChangeDidFail -- input is empty.
            }
        default: // intervalLength and breakLength. validate int values.
            let val = Int(input) // returns optional int
            
            if let v = val {
                var assignedVal = v
                
                if v < DefaultValuesAndLimits.minLength {
                    assignedVal = DefaultValuesAndLimits.minLength
                } else if v > DefaultValuesAndLimits.maxLength {
                    assignedVal = DefaultValuesAndLimits.maxLength
                }
                
                // user's input is valid, so store it in the correct field:
                if field == PomodoroModelKeys.breakLength {
                    breakLength = assignedVal
                } else {
                    intervalLength = assignedVal
                }
                success = true
                
            } else {
                // modelChangeDidFail -- we got back nil for val.
            }
        }
        notifyObservers(success: success)
    }
    
    func getPomodoroFromIndexPathRow(row: Int) -> Pomodoro? {
        var error: NSError?
        do {
            let p = try managedContext.existingObjectWithID(pomodori[row].objectID)
            let pName = p.valueForKey(PomodoroModelKeys.name) as! String
            let pNumIntervals = p.valueForKey(PomodoroModelKeys.numIntervals) as! Int
            let pIntervalLength = p.valueForKey(PomodoroModelKeys.intervalLength) as! Int
            let pBreakLength = p.valueForKey(PomodoroModelKeys.breakLength) as! Int
            
            let pomodoro = Pomodoro(name: pName, intervalLength: pIntervalLength, numIntervals: pNumIntervals, breakLength: pBreakLength)
            return pomodoro
        } catch let error1 as NSError {
            error = error1
            return nil
        }
    }
    
    private func save() {
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save changes \(error), \(error?.userInfo)")
        }
    }
    
    private func loadPomodori() {
        print("Loading pomodori")
        let request = NSFetchRequest()
        request.entity = entity
        
        var error: NSError?
   
        do{
            let objects = try managedContext.executeFetchRequest(request) as? [NSManagedObject]
            if let obs = objects {
                pomodori = obs
            } else {
                print("No pomodoro objects found to load")
            }
        }
        catch  {
            print("error")
        }
        
        
       
    }
    
    func savePomodoro(name: String, numIntervals: Int, intervalLength: Int, breakLength: Int) {
        let pomodoro = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedContext)
        
        pomodoro.setValue(name, forKey: PomodoroModelKeys.name)
        pomodoro.setValue(numIntervals, forKey: PomodoroModelKeys.numIntervals)
        pomodoro.setValue(intervalLength, forKey: PomodoroModelKeys.intervalLength)
        pomodoro.setValue(breakLength, forKey: PomodoroModelKeys.breakLength)
        
        save()
        
        pomodori.append(pomodoro)
        
        resetFieldsToDefaults()
    }
    
    func deletePomodoro(row row: Int) {
        // delete from core data persistent data
        managedContext.deleteObject(pomodori[row])
        
        save()
        
        // delete from in memory array
        pomodori.removeAtIndex(row)
    }
    
    // not currently in use by any controller....but good for scalability.
    private func notifyObservers(success success: Bool) {
        let message = success ? PomodoroModelMessages.modelChangeDidSucceed : PomodoroModelMessages.modelChangeDidFail
        let notification = NSNotification(
            name: PomodoroModelMessages.notificationName, object: self,
            userInfo: [ PomodoroModelMessages.notificationEventKey : message ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
}