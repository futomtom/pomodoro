//
//  TimerModel.swift
//  Pomodoro
//
//  Created by Shannon Coyne on 8/2/15.
//  Copyright (c) 2015 Shannon Coyne. All rights reserved.
//

import Foundation

struct TimerModelMessages {
    static let notificationName = "TimerModel"
    static let notificationEventKey = "message"
    static let timerDidStart = "started"
    static let timerDidPause = "paused"
    static let intervalDidEnd = "intervalEnded"
    static let breakDidEnd = "breakEnded"
    static let countdownDecrement = "countdown"
    static let pomodoroDidFinish = "finished"
}

class TimerModel: NSObject {
    private var timer: NSTimer?
    var intervalLength: Int
    var breakLength: Int
    var numIntervals: Int
    var isActive = false
    var isStart = false
    var isBreak = false
    
    var currentInterval = 1
    var currentBreak = 1
    
    var secondsElapsed = 0
    
    lazy var secondsLeft = Int()
    lazy var minutes = Int()
    lazy var seconds = Int()
    lazy var progress = Float()

     init(sLength: Int, bLength: Int, numberIntervals: Int) {
        intervalLength = sLength
        breakLength = bLength
        numIntervals = numberIntervals
        super.init()
        getIntervalSecondsLeft()
    }
    
    func getIntervalSecondsLeft() {
        secondsLeft = intervalLength * 60
        isBreak = false
    }
    
    func getBreakSecondsLeft() {
        secondsLeft = breakLength * 60
        isBreak = true
    }

    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "progressTimeAndDecrementCountdown", userInfo: nil, repeats: true)
        isActive = true
        isStart = true
        notifyObservers(TimerModelMessages.timerDidStart)
    }
    
    func pauseTimer() {
        if let t = timer {
            t.invalidate()
            isActive = false
            notifyObservers(TimerModelMessages.timerDidPause)
        }
    }
    
    func progressTimeAndDecrementCountdown() {
        secondsLeft--
        minutes = (secondsLeft % 3600) / 60
        seconds = (secondsLeft % 3600) % 60
        
        secondsElapsed++
        progress = Float(secondsElapsed) / Float(intervalLength * 60)
        
        notifyObservers(TimerModelMessages.countdownDecrement)
        
        decrementCountdown()
    }
    
    func closetap () {
        if let t = timer {
            t.invalidate()
            isActive = false
           
        }
        if(isBreak){
            notifyObservers(TimerModelMessages.breakDidEnd)
        }else
        {
            notifyObservers(TimerModelMessages.pomodoroDidFinish)
        }
    }
    func decrementCountdown() {
        if secondsLeft == 0 {
            secondsElapsed = 0
            if !isBreak {
                getBreakSecondsLeft()
                notifyObservers(TimerModelMessages.intervalDidEnd)
                currentInterval++
                if currentBreak == numIntervals {
                    pauseTimer() // done!
                    notifyObservers(TimerModelMessages.pomodoroDidFinish)
                }
            } else {
                getIntervalSecondsLeft()
                notifyObservers(TimerModelMessages.breakDidEnd)
                currentBreak++
            }
        }
    }
    
    func notifyObservers(message: String) {
        let notification = NSNotification(name: TimerModelMessages.notificationName, object: self, userInfo: [ TimerModelMessages.notificationEventKey : message ])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
}