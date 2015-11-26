//
//  PomodoroViewController.swift
//  Pomodoro
//
//  Created by Shannon Coyne on 8/1/15.
//  Copyright (c) 2015 Shannon Coyne. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox // vibrate
import LiquidFloatingActionButton
import RFAboutView_Swift
import JSQCoreDataKit
import WatchConnectivity //WCSession
import PermissionScope
import Instructions

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}


class PomodoroViewController: UIViewController,LiquidFloatingActionButtonDataSource,LiquidFloatingActionButtonDelegate,WCSessionDelegate,CoachMarksControllerDataSource,CoachMarksControllerDelegate {
    
    var coachMarksController: CoachMarksController?
    
    let avatarText = "1"
    let PlayPauseText = "You can tap to start/pause Pomodoro."
    let BottomLeftText = "Setting and statistics chart"
    let closeText = "You can tap to cancel Pomodoro"
    let postsText = "4"
    let reputationText = "5"
    
    let nextButtonText = "Ok!"
    
  

    var coreDataStack:CoreDataStack?
    var bottomLeftButton:LiquidFloatingActionButton!
    var NotfirstLaunch:Bool=false

    var cells: [LiquidFloatingCell] = []
       var observer: NSObjectProtocol?
    var timerView: TimerView?
    var session: WCSession?
    private var localNotification: UILocalNotification?

    var pomodoro: Pomodoro! { // Singular Pomodoro attributes are passed in from the TableViewController and are fixed in this view (no editing functionality, no selecting a different pomodoro once you're here). Hence, I've just a passed in a struct (value type) and not the whole model ref typically stored in a delegate variable.
        didSet {
          
            timerModel = TimerModel(sLength: pomodoro.intervalLength.integerValue, bLength: pomodoro.breakLength.integerValue, numberIntervals: pomodoro.numIntervals.integerValue)
            
        }
    }
    var todayRecord:Record!
    private var endDate: NSDate?
    private var remaintime:NSTimeInterval?
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBAction func CancelTimer(sender: AnyObject) {
        let alertview = JSSAlertView().show(self, title: "Stop", text: "Arer you sure you want to skip current pomodoro ", buttonText: "Yep", cancelButtonText: "Nope")
        alertview.addAction(closeCallback)
        alertview.addCancelAction(cancelCallback)
    }
    
    func closeCallback() {
        
        timerModel.closetap()
        closeButton.hidden=true
        timerModel.isBreak=false
        setDuration(timerModel.intervalLength,seconds: 0, maxValue: 1)
        resetTimer()
    }
    
    func cancelCallback() {
        
    }

    
   
    override func viewDidLoad() {
        super.viewDidLoad()
            
            let model = CoreDataModel(name: "PomodoroModel")
            let factory = CoreDataStackFactory(model: model)
            let result = factory.createStack()
            coreDataStack = result.stack()!
            
            self.view.backgroundColor=UIColor(rgb: 0x34485e)
            
            //get setting value
            // WHEN: we execute a fetch request
            let request = FetchRequest<Pomodoro>(entity: entity(name: Pomodoro.entityName, context: coreDataStack!.mainContext))
            let results = try! fetch(request: request, inContext: coreDataStack!.mainContext)
            
            if (results.count<1)     //not setting default
            {   pomodoro = Pomodoro.newPomodoroInContext((coreDataStack?.mainContext)!)
                saveContext((coreDataStack?.mainContext)!)
            }
            else
            {
               // pomodoro = Pomodoro()
                pomodoro = results[0]
              print("Load setting")
            }
            
            closeButton.hidden=true
        
            if(todayRecord==nil)
            {
                todayRecord = Record.newRecordInContext((coreDataStack?.mainContext)!)
                saveContext((coreDataStack?.mainContext)!)
                
            }
     //   testChart()
        
        setupTimeView()
        setupCoach()
        session = WCSession.defaultSession()
        WCSession.defaultSession().delegate = self
        WCSession.defaultSession().activateSession()
            
    }
    
    func testChart()
    {
        for i in 0...10
        {
        let now=NSDate()
        var tempRecord = Record.newRecordInContext((coreDataStack?.mainContext)!)
        tempRecord.date=now-i.days
        tempRecord.number=Int(arc4random_uniform(6) + 1)
        saveContext((coreDataStack?.mainContext)!)
        }
        
        let request = FetchRequest<Record>(entity: entity(name: "Record", context: coreDataStack!.mainContext))
        let results = try! fetch(request: request, inContext: coreDataStack!.mainContext)
        
        if (results.count<1)     //not setting default
        {
            print("Error")
        }

        
    }
    
    
    func setupCoach()
    {
        
        NotfirstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
        if (NotfirstLaunch)  {
            // print("Not first launch.")
            return
        }
        else {
            //First launch
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
            coachMarksController = CoachMarksController()
            coachMarksController?.allowOverlayTap = true
            coachMarksController?.delegate = self
            coachMarksController?.datasource = self
          
            
        
        }
        
        
        
    /*
        let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle("Skip", forState: .Normal)
        
        coachMarksController?.skipView = skipView
    */
    }
    
    func presentNotificationWithDelay(time: NSDate, category: String) {
        
        let notification = UILocalNotification()
        notification.alertTitle = "Pomodoro"
        notification.alertBody = "Time Up"
        notification.category = category
      //  notification.soundName = UILocalNotificationDefaultSoundName
        notification.fireDate = time
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
  
    
    
    
    
    func setupTimeView()
    {
        timerView = TimerView(frame: CGRectZero)
        timerView!.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(timerView!, belowSubview: pauseStartButton)
        
        
        
        
        //  timerView!.backgroundColor = UIColor.redColor()
        let horizontalConstraint = timerView!.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
        let vertivalConstraint = timerView!.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
        let widthConstraint = timerView!.widthAnchor.constraintEqualToAnchor(nil, constant: 300)
        let heightConstraint = timerView!.heightAnchor.constraintEqualToAnchor(nil, constant: 300)
        NSLayoutConstraint.activateConstraints([horizontalConstraint, vertivalConstraint, widthConstraint, heightConstraint])
        
        
        let createButton: (CGRect, LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton = { (frame, style) in
            let floatingActionButton = LiquidFloatingActionButton(frame: frame)
            floatingActionButton.animateStyle = style
            floatingActionButton.dataSource = self
            floatingActionButton.delegate = self
            return floatingActionButton
        }
        
        let cellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            return LiquidFloatingCell(icon: UIImage(named: iconName)!)
        }
        cells.append(cellFactory("settings"))
        cells.append(cellFactory("progress"))
        cells.append(cellFactory("info2"))
        
        let floatingFrame = CGRect(x: 40, y: self.view.frame.height - 56 - 16, width: 56, height: 56)
         bottomLeftButton = createButton(floatingFrame, .Up)
        self.view.addSubview(bottomLeftButton)
        setDuration(timerModel.intervalLength,seconds: 0, maxValue: CGFloat(timerModel.intervalLength*60))
        
  
    
    }
    
    
   override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
        if(!timerModel.isStart)
        {
            timerModel.intervalLength=pomodoro.intervalLength.integerValue
            setDuration(timerModel.intervalLength,seconds: 0, maxValue: CGFloat(timerModel.intervalLength*60))
        }
        
        
    }
    
    //watch part
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(!NotfirstLaunch)
        {   closeButton.hidden=false
            coachMarksController?.startOn(self)
        }
        
        WCSession.defaultSession().delegate = self
        WCSession.defaultSession().activateSession()
    }
    
    func setDuration(minutes: Int,seconds: Int, maxValue: CGFloat) {
      
     //   timerView!.durationInSeconds = duration
        timerView!.seconds = seconds
        timerView!.minutes = minutes
        timerView!.maxValue = maxValue
        timerView!.setNeedsDisplay()
    }
    
    var timerModel: TimerModel! {
        didSet { startTimerModelListener() }
    }
    
    var settingsModel: SettingsDelegate!
    
    @IBOutlet weak var sprintLabel: UILabel!
       
    @IBOutlet weak var pauseStartButton: UIButton!
  
   
    
    @IBAction func startPauseButtonPressed(sender: UIButton) {
            startstop(!timerModel.isActive,notiPeer: true)
    }
    
    func sendAction(actionSting: String) {
        if let session = session where session.reachable {
            session.sendMessage(["action": actionSting], replyHandler: nil, errorHandler: nil)
        }
    }
   
    func startstop(start:Bool,notiPeer:Bool)
    {
        closeButton.hidden=false
        if timerModel.isActive { // user wishes to pause
            timerModel.pauseTimer()
            remaintime = endDate!-NSDate()
            
            
            if(notiPeer){
                sendAction("stop")
            }
        } else { // user wishes to (re)start
            print("starting timer, from pomodoroviewcontroller")
            timerModel.startTimer()
            var time:Int
            if timerModel.isBreak
            {
                time = pomodoro.breakLength.integerValue
            }
            else
            {
               time = pomodoro.intervalLength.integerValue
            }
            if(remaintime==nil)
            {
                endDate = NSDate()+time.minutes
            
            }
            else
            {
            endDate = NSDate()+remaintime!
            }
           // endDate = NSDate()+10.seconds
            
             UIApplication.sharedApplication().cancelAllLocalNotifications()
            
            presentNotificationWithDelay(endDate!,category: "Pomodoro")
            let endTimeStamp = floor(endDate!.timeIntervalSince1970)
            
            if let sharedDefaults = NSUserDefaults(suiteName: "group.sidc.time") {
                sharedDefaults.setDouble(endTimeStamp, forKey: "date")
                sharedDefaults.setInteger(time*60, forKey: "maxValue")
                sharedDefaults.synchronize()
            }
            
            
            if let session = session where session.paired && session.watchAppInstalled {
                do {
                     print("Paired")
                    try session.updateApplicationContext(["date": endTimeStamp, "maxValue": time*60])
                } catch {
                    print("Error!")
                }
                //      if session.complicationEnabled {
                session.transferCurrentComplicationUserInfo(["date": endTimeStamp, "maxValue": time*60])
                //      }
            }
            if(notiPeer){
                sendAction("start")
            }

        }
    }
 
    func disableStartPauseButtonAndUpdateIntervalLabel() {
      //  sprintLabel.text = "Completed \(pomodoro.numIntervals) Intervals"
        updatePauseStartButtonImage("play")
    }
    
    func updateTimerLabel() {
        // countdown label text
       
        setDuration(timerModel.minutes,seconds: timerModel.seconds, maxValue: CGFloat(timerModel.intervalLength*60))
        
        
    
    }
    
    func updatePauseStartButtonImage(imageName: String) {
  
        pauseStartButton.setImage(UIImage(named: imageName), forState: .Normal)
    }
    
    func startTimerModelListener() {
        let center = NSNotificationCenter.defaultCenter()
        let uiQueue = NSOperationQueue.mainQueue()
        
        observer = center.addObserverForName(TimerModelMessages.notificationName, object: timerModel, queue: uiQueue) {
            [unowned self]
            (notification) in
            if let message = notification.userInfo?[TimerModelMessages.notificationEventKey] as? String {
                self.handleNotification(message) //
            }
            else {
                assertionFailure("No message found in notification")
            }
        }
    }
    
    func updateSprintLabel() {
        if timerModel.isBreak {
            sprintLabel.text = "Break \(timerModel.currentBreak) of \(timerModel.numIntervals - 1)"
        } else {
            sprintLabel.text = "Interval \(timerModel.currentInterval) of \(timerModel.numIntervals)"
        }
    }
    
    func vibrate() {
        /*
        if settingsModel.vibrate {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
*/
    }
    
    func handleNotification(message: String) {
        switch message {
        case TimerModelMessages.countdownDecrement:
            updateTimerLabel()
        case TimerModelMessages.timerDidStart:
            updatePauseStartButtonImage("pause")
        case TimerModelMessages.timerDidPause:
            updatePauseStartButtonImage("play")
        case TimerModelMessages.breakDidEnd, TimerModelMessages.intervalDidEnd:
            updateSprintLabel()
            updatePauseStartButtonImage("play")
            setDuration(timerModel.intervalLength,seconds: 0, maxValue: CGFloat(timerModel.intervalLength*60))
            vibrate()
        case TimerModelMessages.pomodoroDidFinish:
            disableStartPauseButtonAndUpdateIntervalLabel()
            updatePauseStartButtonImage("play")
            todayRecord.number=todayRecord.number.integerValue+1
            if((timerModel.currentInterval % pomodoro.numIntervals.integerValue)==0){
                setDuration(timerModel.breakLength ,seconds: 0, maxValue: CGFloat(timerModel.breakLength*60))
            }
            else    {
                setDuration(timerModel.breakLength ,seconds: 0, maxValue: CGFloat(timerModel.breakLength*60))
            }
            
        default:
            assertionFailure("Unexpected message: \(message)")
        }
    }
    
    func numberOfCells(liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return cells.count
    }
    
    func cellForIndex(index: Int) -> LiquidFloatingCell {
        return cells[index]
    }
    
    func liquidFloatingActionButton(liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        liquidFloatingActionButton.close()
        
        switch(index){
        case 0:
            self.performSegueWithIdentifier("setting", sender: self)
        case 1:
            self.performSegueWithIdentifier("chart", sender: self)
        case 2:
            showAbout()
        default:
            print("Error");
        }
        
        
       
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "setting" {
            let settingVC = segue.destinationViewController as! SettingsViewController
            settingVC.coreDataStack=coreDataStack
            settingVC.settings=pomodoro
            settingVC.parentVC=self
        }
        if segue.identifier == "chart" {
            do {
                let result = try Record.lastweekResult(coreDataStack!.mainContext)
               // let result = try Record.allRecordInContext(coreDataStack!.mainContext)
                var max:Int=0
                var TotalPomodoro:Int=0
                for record in result
                {
                    if(record.number.integerValue > max)
                    {
                        max=record.number.integerValue
                    }
                    
                    
                }
                TotalPomodoro=result[0].number.integerValue+result[1].number.integerValue+result[2].number.integerValue+result[3].number.integerValue+result[4].number.integerValue+result[5].number.integerValue+result[6].number.integerValue
                let chartVC = segue.destinationViewController as! BarsExample
                chartVC.tuplesXY=[(1, result[0].number.integerValue), (2, result[1].number.integerValue), (3, result[2].number.integerValue), (4, result[3].number.integerValue), (5, result[4].number.integerValue),(6, result[5].number.integerValue),(7, result[6].number.integerValue)]
                chartVC.max=max
                chartVC.numofPomodoro=TotalPomodoro
             } catch {
                print(error)
            }
            
            
            
        }
    }
    func showAbout() {
        // First create a UINavigationController (or use your existing one).
        // The RFAboutView needs to be wrapped in a UINavigationController.
        
        let aboutNav = UINavigationController()
        
        // Initialise the RFAboutView:
        
        let aboutView = RFAboutViewController(appName: nil, appVersion: nil, appBuild: nil, copyrightHolderName: "AlexFu, Inc.", contactEmail: "fualex@hotmail.com", contactEmailTitle: "Contact us", websiteURL: NSURL(string: ""), websiteURLTitle: "Our Website", pubYear: nil)
        
        // Set some additional options:
        
        aboutView.headerBackgroundColor = .blackColor()
        aboutView.headerTextColor = .whiteColor()
        aboutView.blurStyle = .Dark
        aboutView.headerBackgroundImage = UIImage(named: "about_header_bg.jpg")
        
        // Add an additional button:
        aboutView.addAdditionalButton("Privacy Policy", content: "Here's the privacy policy")
        
        // Add the aboutView to the NavigationController:
        aboutNav.setViewControllers([aboutView], animated: false)
        
        // Present the navigation controller:
        self.presentViewController(aboutNav, animated: true, completion: nil)
    }

 
    
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        print(message)
        guard let actionString = message["action"] as? String else { return }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            switch actionString {
            case "start":
                print("pget start")
               self.startstop(true,notiPeer: false)
            case "stop":
                 print("pget stop")
                self.startstop(false,notiPeer:false)
            default:
                break
            }
        })
    }
    
    private func resetTimer() {

        
        if let session = session where session.paired && session.watchAppInstalled {
            do {
                try session.updateApplicationContext(["date": -1.0, "maxValue": -1.0])
            } catch {
                print("Error!")
            }
            session.transferCurrentComplicationUserInfo(["date": -1.0, "maxValue": -1.0])
        }
        
        if let sharedDefaults = NSUserDefaults(suiteName: "group.sidc.time") {
            sharedDefaults.removeObjectForKey("date")
            sharedDefaults.synchronize()
        }
    }
    
    
    //MARK: - Protocol Conformance | CoachMarksControllerDataSource
    func numberOfCoachMarksForCoachMarksController(coachMarksController: CoachMarksController) -> Int {
        return 3
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarksForIndex index: Int) -> CoachMark {
        switch(index) {
     /*   case 0:
            return coachMarksController.coachMarkForView(self.navigationController?.navigationBar) { (frame: CGRect) -> UIBezierPath in
                // This will make a cutoutPath matching the shape of
                // the component (no padding, no rounded corners).
                return UIBezierPath(rect: frame)
            }
            */
        case 0:
            return coachMarksController.coachMarkForView(pauseStartButton)
        case 1:
            return coachMarksController.coachMarkForView(bottomLeftButton)
        case 2:
            return coachMarksController.coachMarkForView(closeButton)
        default:
            return coachMarksController.coachMarkForView()
        }
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarkViewsForIndex index: Int, coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let coachViews = coachMarksController.defaultCoachViewsWithArrow(true, arrowOrientation: coachMark.arrowOrientation)
        
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = self.PlayPauseText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 1:
            coachViews.bodyView.hintLabel.text = self.BottomLeftText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 2:
            coachViews.bodyView.hintLabel.text = self.closeText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
   
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }

    func didFinishShowingFromCoachMarksController(coachMarksController: CoachMarksController) {
        closeButton.hidden=true
    }


}
