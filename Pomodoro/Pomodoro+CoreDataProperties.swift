//
//  Pomodoro+CoreDataProperties.swift
//  Pomodoro
//
//  Created by alex on 10/24/15.
//  Copyright © 2015 Shannon Coyne. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pomodoro {

    @NSManaged var breakLength: NSNumber
    @NSManaged var intervalLength: NSNumber
    @NSManaged var name: String?
    @NSManaged var numIntervals: NSNumber
    @NSManaged var longbreak: NSNumber
    @NSManaged var sound: Bool
}
