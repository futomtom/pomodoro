//
//  TimerViewController.swift
//  Lecture3Demo
//
//  Created by Daniel Bromberg on 6/27/15.
//  Copyright (c) 2015 S65. All rights reserved.
//

import UIKit

struct Timer {
    static let NotificationName = "Timer"
    static let MessageKey = "message"
    static let ResignedMessage = "resigned"
    static let ActivatedMessage = "activated"
}

class TimerViewController: UIViewController {
    private var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObservers()
    }
    
    func handleAppActivated() {
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "handleTimer:", userInfo: nil, repeats: true)
    }
    
    func handleAppResigned() {
        if let t = timer {
            t.invalidate()
        }
        else {
            // no timer to cancel
        }
    }
    
    func handleTimer(timer: NSTimer) {
        // deliberately crash if this is not occurring on the UI thread
        assert(NSThread.isMainThread())
    }
    
    func startObservers() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserverForName(Timer.NotificationName, object: nil, queue: NSOperationQueue.mainQueue()) {
            [unowned self]
            (notification: NSNotification!) -> Void in
            if let message = notification.userInfo?[Timer.MessageKey] as? String {
                switch message {
                case Timer.ActivatedMessage: self.handleAppActivated()
                case Timer.ResignedMessage: self.handleAppResigned()
                default: assertionFailure("Unknown message: \(message)")
                }
            }
            else {
                assertionFailure("Missing message")
            }
        }
    }
}

