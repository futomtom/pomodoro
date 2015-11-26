//
//  Record+CoreDataProperties.swift
//  Pomodoro
//
//  Created by alex on 11/5/15.
//  Copyright © 2015 Shannon Coyne. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Record {

    @NSManaged var date: NSDate
    @NSManaged var duration: NSNumber
    @NSManaged var number: NSNumber

}
