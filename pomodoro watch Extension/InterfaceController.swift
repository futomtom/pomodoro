//
//  InterfaceController.swift
//  Fojusi Watch Extension
//
//  Created by dasdom on 04.07.15.
//  Copyright © 2015 Dominik Hauser. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import ClockKit

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var timerInterface: WKInterfaceTimer!
    @IBOutlet var backgroundGroup: WKInterfaceGroup!
    
    var timer: NSTimer?
    var currentBackgroundImageNumber = 0
    var maxValue = 60
    var active=false
    
    @IBOutlet var StartPauseButton: WKInterfaceButton!
    var session: WCSession?
    
    var endDate: NSDate? {
        didSet {
            if let date = endDate where endDate?.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                timerInterface.setDate(date)
                timerInterface.start()
                timer?.invalidate()
                timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "updateUserInterface", userInfo: nil, repeats: true)
            } else {
                timerInterface.stop()
                timer?.invalidate()
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        session = WCSession.defaultSession()
        session?.delegate = self
        session?.activateSession()
    }
/*
    override func willActivate() {
        let timeStamp = NSUserDefaults.standardUserDefaults().doubleForKey("timeStamp")
        endDate = NSDate(timeIntervalSince1970: timeStamp)
        maxValue = NSUserDefaults.standardUserDefaults().integerForKey("maxValue")
        
        currentBackgroundImageNumber = 0
        
        super.willActivate()
    }
  */  
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateUserInterface() {
        //  print("watch max=\(maxValue)")
        if let endDate = endDate {
            //      let remainingTenSecondSteps = Int(endDate.timeIntervalSinceNow/10.0) + 1
            let promillValue = Int(endDate.timeIntervalSinceNow*100.0/Double(maxValue))+1
            //      if remainingTenSecondSteps == 0 {
            if promillValue == 0 {
                backgroundGroup.setBackgroundImageNamed(nil)
                return
                //      } else if remainingTenSecondSteps < 0 {
            } else if promillValue < 0 {
                timer?.invalidate()
                timerInterface.stop()
                return
            }
            //      if currentBackgroundImageNumber != remainingTenSecondSteps {
            //        currentBackgroundImageNumber = remainingTenSecondSteps
            //        let imageName = "fiveMin\(remainingTenSecondSteps)"
            //        backgroundGroup.setBackgroundImageNamed(imageName)
            //      }
            //      if currentBackgroundImageNumber != promillValue {
            currentBackgroundImageNumber = promillValue
            let formatString = "03"
           // print("promillValue=\(promillValue.format(formatString))")
            let imageName = "fiveMin\(promillValue.format(formatString))"
            backgroundGroup.setBackgroundImageNamed(imageName)
            //      }
        }
    }
    
}

extension InterfaceController: WCSessionDelegate {

    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let timeStamp = applicationContext["date"]! as! Double
            guard timeStamp > 0 else {
                print("<0")
                self.timer?.invalidate()
                self.timerInterface.stop()
                self.timerInterface.setDate(NSDate())
                self.backgroundGroup.setBackgroundImageNamed(nil)
                NSUserDefaults.standardUserDefaults().removeObjectForKey("timeStamp")
                NSUserDefaults.standardUserDefaults().removeObjectForKey("maxValue")
                return
            }
           print(">0")
            self.maxValue = applicationContext["maxValue"] as! Int
            self.endDate = NSDate(timeIntervalSince1970: timeStamp)
            self.currentBackgroundImageNumber = 0
            
            NSUserDefaults.standardUserDefaults().setDouble(timeStamp, forKey: "timeStamp")
            NSUserDefaults.standardUserDefaults().setInteger(self.maxValue, forKey: "maxValue")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        print(message)
        guard let actionString = message["action"] as? String else { return }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            switch actionString {
            case "start":
                print("wget stop")
                self.StartStop(true,notifPeer:false)
            case "stop":
                print("wget stop")
                self.StartStop(false,notifPeer:false)
            default:
                break
            }
        })
    }

}

extension InterfaceController {

    @IBAction func startCurrent() {
     
        StartStop(!self.active,notifPeer:true)
    }
    
    func StartStop(start:Bool,notifPeer:Bool)
        {
     
        if(!start){
        active=false
        print("set Start")
        StartPauseButton.setTitle("Start")
        timer?.invalidate()
        timerInterface.stop()
        if(notifPeer) {
                sendAction("stop")
            }
        } else
        {
        active=true
        StartPauseButton.setTitle("Pause")
            print("set Pause")
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "updateUserInterface", userInfo: nil, repeats: true)
        timerInterface.start()
        if(notifPeer) {
                sendAction("start")
            }
        }
    }


    
    func sendAction(actionSting: String) {
        //    do {
        //      try session.updateApplicationContext(["action": actionSting])
        //    } catch {
        //      print("Error")
        //    }
        if let session = session where session.reachable {
            session.sendMessage(["action": actionSting], replyHandler: nil, errorHandler: nil)
        }
    }
}

extension Int {
    func format(f: String) -> String {
        return NSString(format: "%\(f)d", self) as String
    }
}

