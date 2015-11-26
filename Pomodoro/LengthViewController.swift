// MIT license. Copyright (c) 2014 SwiftyFORM. All rights reserved.
import UIKit
import SwiftyFORM

struct OptionRow {
	let title: String
	let identifier: String
	
	init(_ title: String, _ identifier: String) {
		self.title = title
		self.identifier = identifier
	}
}

class MyOptionForm {
	let optionRows: [OptionRow]
	let vc0 = ViewControllerFormItem()
	
	init(optionRows: [OptionRow]) {
		self.optionRows = optionRows
	}
	
	func populate(builder: FormBuilder) {
		builder.navigationTitle = "Picker"
		
		for optionRow: OptionRow in optionRows {
			let option = OptionRowFormItem()
			option.title(optionRow.title)
			builder.append(option)
		}
	}

	
	
}

class LengthViewController: FormViewController, SelectOptionDelegate {
	var xmyform: MyOptionForm?
	
	let dismissCommand: CommandProtocol
	
	init(dismissCommand: CommandProtocol) {
		self.dismissCommand = dismissCommand
		super.init()
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func populate(builder: FormBuilder) {
		let optionRows: [OptionRow] = [
            OptionRow("5 minutes", "5"),
			OptionRow("10 minutes", "10"),
			OptionRow("15 minutes", "15"),
			OptionRow("20 minutes", "20"),
            OptionRow("25 minutes", "25"),
            OptionRow("30 minutes", "30"),
            OptionRow("35 minutes", "35"),
            OptionRow("40 minutes", "40"),
		]
		
		let myform = MyOptionForm(optionRows: optionRows)

		myform.populate(builder)
		xmyform = myform
	}
	
	func form_willSelectOption(option: OptionRowFormItem) {
		print("select option \(option)")
		dismissCommand.execute(self, returnObject: option)
	}

}

class LongBreakViewController: FormViewController, SelectOptionDelegate {
    var xmyform: MyOptionForm?
    
    let dismissCommand: CommandProtocol
    
    init(dismissCommand: CommandProtocol) {
        self.dismissCommand = dismissCommand
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func populate(builder: FormBuilder) {
        let optionRows: [OptionRow] = [
            OptionRow("2 pomodoros", "2"),
            OptionRow("3 pomodoros", "3"),
            OptionRow("4 pomodoros", "4"),
            OptionRow("5 pomodoros", "5"),
            OptionRow("6 pomodoros", "6"),
            OptionRow("7 pomodoros", "7"),
            OptionRow("8 pomodoros", "8"),
        ]
        
        let myform = MyOptionForm(optionRows: optionRows)
        
        myform.populate(builder)
        xmyform = myform
    }
    
    func form_willSelectOption(option: OptionRowFormItem) {
        print("select option \(option)")
        dismissCommand.execute(self, returnObject: option)
    }
    
}


class EmptyViewController: UIViewController {
	
	override func loadView() {
		self.view = UIView()
		self.view.backgroundColor = UIColor.redColor()
	}
	
}

