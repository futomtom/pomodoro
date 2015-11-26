//
//  Pomodoro.swift
//  Pomodoro
//
//  Created by alex on 10/21/15.
//  Copyright © 2015 Shannon Coyne. All rights reserved.
//

import Foundation
import CoreData

class Pomodoro: NSManagedObject {
    static public let entityName = "Pomodoro"

    struct DefaultValuesAndLimits {
        static let minLength = 1
        static let maxLength = 60
        
        static let defaultName = "New Pomodoro"
        static let defaultnumIntervals = 3
        static let defaultintervalLength = 25
        static let defaultBreakLength = 5
    }
    
    class func newPomodoroInContext(context: NSManagedObjectContext) -> Pomodoro {
         let tempPomo=NSEntityDescription.insertNewObjectForEntityForName("Pomodoro", inManagedObjectContext: context) as! Pomodoro
        
        tempPomo.resetFieldsToDefaults()
        return tempPomo
    }
    
    class func allPomodoroInContext(context: NSManagedObjectContext) throws -> [Pomodoro] {
        let fr = NSFetchRequest(entityName: "Pomodoro")
        return try! context.executeFetchRequest(fr) as! [Pomodoro]
    }

    

     func resetFieldsToDefaults() {
        name = DefaultValuesAndLimits.defaultName
        numIntervals = DefaultValuesAndLimits.defaultnumIntervals
        intervalLength = DefaultValuesAndLimits.defaultintervalLength
        breakLength = DefaultValuesAndLimits.defaultBreakLength
    }

}



struct PomodoroModelMessages {
    static let notificationName = "PomodoroModel"
    static let notificationEventKey = "message"
    static let modelChangeDidFail = "failed"
    static let modelChangeDidSucceed = "succeeded"
}



