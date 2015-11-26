//
//  Record.swift
//  Pomodoro
//
//  Created by alex on 11/4/15.
//  Copyright © 2015 Shannon Coyne. All rights reserved.
//

import Foundation
import CoreData


class Record: NSManagedObject {

    class func newRecordInContext(context: NSManagedObjectContext) -> Record {
        let tempRecord=NSEntityDescription.insertNewObjectForEntityForName("Record", inManagedObjectContext: context) as! Record
        
        tempRecord.resetFieldsToDefaults()
        return tempRecord
    }
    
    
    class func lastweekResult(context: NSManagedObjectContext) throws -> [Record] {
        let fetchRequest = NSFetchRequest(entityName: "Record")
        
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        
        let startDate = calendar.startOfDayForDate(now)
        let endDate = calendar.dateByAddingUnit(.Day, value: -7, toDate: startDate, options: NSCalendarOptions())
     
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date<= %@",endDate!,startDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return try! context.executeFetchRequest(fetchRequest) as! [Record]
    }
    
    class func allRecordInContext(context: NSManagedObjectContext) throws -> [Record] {
        let fr = NSFetchRequest(entityName: "Record")
        return try! context.executeFetchRequest(fr) as! [Record]
    }

    
    
    
    func resetFieldsToDefaults() {
        date = NSDate()
        number = 0
        duration = 0
       
    }
    


}
