// MIT license. Copyright (c) 2015 SwiftyFORM. All rights reserved.
import UIKit
import SwiftyFORM
import JSQCoreDataKit








class SettingsViewController: FormViewController {
    var coreDataStack:CoreDataStack?
    var settings: Pomodoro!
    var parentVC: PomodoroViewController!
    
   
	override func populate(builder: FormBuilder) {
		builder.navigationTitle = "Settings"
		builder.toolbarMode = .Simple
		builder += SectionHeaderTitleFormItem().title("Length")
        builder += PomodoroLength
        builder += ShortBreak
        builder += LongBreak
        builder += LongBreakAfter
        builder += SectionFormItem()
        builder += SectionHeaderTitleFormItem().title("Alarm")
        builder += sound
        
	}
	
    
    //選項
 /*   lazy var PomodoroLength: ViewControllerFormItem = {
        let instance = ViewControllerFormItem()
        let value=self.settings.intervalLength
        instance.title("Pomodoro Duration").placeholder("\(value) minutes")

        instance.createViewController = { (dismissCommand: CommandProtocol) in
            let vc = LengthViewController(dismissCommand: dismissCommand)
            return vc
        }
        instance.willPopViewController = { (context: ViewControllerFormItemPopContext) in
            if let x = context.returnedObject as? SwiftyFORM.OptionRowFormItem {
                context.cell.detailTextLabel?.text = x.title
            } else {
                context.cell.detailTextLabel?.text = nil
            }
        }
        return instance
        }()
*/
    
    lazy var PomodoroLength: OptionPickerFormItem = {
        let instance = OptionPickerFormItem()
        instance.title("Pomodoro Duration")
        instance.append("10 minutes").append("15 minutes").append("20 minutes").append("25 minutes").append("30 minutes").append("35 minutes ").append("40 minutes").append("1 minutes")
        let value=self.settings.intervalLength
        instance.selectOptionWithTitle("\(value) minutes")
        return instance
        }()
    
    lazy var ShortBreak: OptionPickerFormItem = {
        let instance = OptionPickerFormItem()
        instance.title("Short Break")
        instance.append("5 minutes").append("10 minutes").append("15 minutes").append("20 minutes").append("25 minutes").append("30 minutes").append("35 minutes").append("40 minutes").append("45 minutes").append("50 minutes").append("55 minutes").append("60 minutes").append("1 minutes")
        let value=self.settings.breakLength
        instance.selectOptionWithTitle("\(value) minutes")
        return instance
        }()
    
    
    lazy var LongBreak: OptionPickerFormItem = {
        let instance = OptionPickerFormItem()
        instance.title("Long Break")
        instance.append("5 minutes").append("10 minutes").append("15 minutes").append("20 minutes").append("25 minutes").append("30 minutes").append("1 minutes")
        let value=self.settings.longbreak
        instance.selectOptionWithTitle("\(value) minutes")
        return instance
        }()
    
    lazy var LongBreakAfter: OptionPickerFormItem = {
        let instance = OptionPickerFormItem()
        instance.title("Long Break After")
        instance.append("2 pomodoros").append("3 pomodoros").append("4 pomodoros").append("5 pomodoros")
        let value=self.settings.numIntervals
        instance.selectOptionWithTitle("\(value) pomodoros")
        return instance
        }()
    

    
    lazy var sound: SwitchFormItem = {
        let instance = SwitchFormItem()
        instance.title("Sound")
         let onoff=self.settings.sound
        instance.value = onoff
        return instance
        }()
    
    
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            
            let aMap  = [
                "1 minutes": 1,
                "5 minutes": 5,
                "10 minutes": 10,
                "15 minutes": 15,
                "20 minutes": 20,
                "25 minutes": 25,
                "30 minutes": 30,
                "35 minutes": 35,
                "40 minutes": 40,
                "45 minutes": 45,
                "50 minutes": 50,
                "55 minutes": 55,
                "60 minutes": 60,
                "2 pomodoros": 2,
                "3 pomodoros": 3,
                "4 pomodoros": 4,
                "5 pomodoros": 5,
                "6 pomodoros": 6,
                "7 pomodoros": 7,
                "8 pomodoros": 8,
                
            ]
            print("result \(sound.value) \(LongBreakAfter.selected?.identifier) \(ShortBreak.selected?.identifier)\(PomodoroLength.selected?.identifier) \(LongBreak.selected?.identifier)")
        
            settings.intervalLength=aMap[PomodoroLength.selected!.identifier]!
            settings.breakLength=aMap[ShortBreak.selected!.identifier]!
        //    settings.longbreak=aMap[LongBreak.selected!.identifier]!
               settings.longbreak=aMap["1 minutes"]!
            settings.numIntervals=aMap[LongBreakAfter.selected!.identifier]!
            settings.sound=sound.value
            
           saveContext((coreDataStack?.mainContext)!)
            
           
                parentVC.pomodoro = settings

            
            
                                     
           
            
           // let numIntervals=Int(temp)
           // LongBreakAfter.placeholder[[greeting.startIndex]
            //settings.numIntervals=
        }
    }

    override func viewWillAppear(animated: Bool) {
       
            self.navigationController!.navigationBar.hidden = false
        
        
    }
    



	
	

}
