//
//  SettingsModel.swift
//  Pomodoro
//
//  Created by Shannon Coyne on 8/1/15.
//  Copyright (c) 2015 Shannon Coyne. All rights reserved.
//

import Foundation
import CoreData // Core Data persistent implementation to come! pList also a possibility

struct SettingsModelKeys {
    static let vibrate = "vibrate"
    static let notifications = "notifications"
}

protocol SettingsDelegate: class {
    var vibrate: Bool { get }
    var notifications: Bool { get }
    func flipSwitch(switchName: String)
}

class SettingsModel: SettingsDelegate {
    var vibrate = true
    var notifications = true
    
    func flipSwitch(switchName: String) {
        switch switchName {
        case SettingsModelKeys.vibrate:
            vibrate = !vibrate
        default:
            notifications = !notifications
        }
    }
}