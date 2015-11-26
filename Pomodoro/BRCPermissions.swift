//
//  BRCPermissions.swift
//  iBurn
//
//  Created by Christopher Ballinger on 8/14/15.
//  Copyright (c) 2015 Burning Man Earth. All rights reserved.
//

import UIKit
import PermissionScope



/** Wrapper around swift-only PermissionScope */
public class BRCPermissions: NSObject {
    
    /** Show location permissions prompt */

    
    /** Show notification permissions prompt */
    public static func promptForPush(completion: dispatch_block_t) {
        let pscope = PermissionScope()
        pscope.headerLabel.text = "Reminders"
        pscope.bodyLabel.text = "Don't you want reminders?"
        pscope.addPermission(NotificationsPermission(notificationCategories: nil),
            message: "Pmodoro is best with nofification!")
        
        pscope.show(
            { finished, results in
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "Push Enable")
                print("push enable")
            },
            cancelled: { results in
                 NSUserDefaults.standardUserDefaults().setBool(false, forKey: "Push Enable")
                print("push disable")
            }
        )    }
}
