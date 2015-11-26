//
//  AddNewViewController.swift
//  Pomodoro
//
//  Created by Shannon Coyne on 8/1/15.
//  Copyright (c) 2015 Shannon Coyne. All rights reserved.
//

import UIKit

class AddNewViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
  
    var observer: NSObjectProtocol?
    var textFieldToString = [UITextField : String]()
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet { textFieldToString[nameTextField] = PomodoroModelKeys.name }
    }
    @IBOutlet weak var sprintsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sprintLengthTextField: UITextField! {
        didSet { textFieldToString[sprintLengthTextField] = PomodoroModelKeys.intervalLength }
    }
    @IBOutlet weak var breakLengthTextField: UITextField! {
        didSet { textFieldToString[breakLengthTextField] = PomodoroModelKeys.breakLength }
    }
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        sprintLengthTextField.delegate = self
        breakLengthTextField.delegate = self
        
        nameTextField.becomeFirstResponder()
    }
    
    // MARK: - TextFieldDelegate methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
      //  saveButton.enabled = false // do not allow saving before the model can validate input
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // check values against the limits in the model
        if let fieldStringName = textFieldToString[textField] {
            model.userInputIsValid(textField.text!, field: fieldStringName)
        } else {
            assertionFailure("Unrecognized UITextField passed to model")
        }
        saveButton.enabled = true
    }
    
    func startModelListener() {
        let center = NSNotificationCenter.defaultCenter()
        let uiQueue = NSOperationQueue.mainQueue()
        
        observer = center.addObserverForName(PomodoroModelMessages.notificationName, object: model, queue: uiQueue) {
            [weak self]
            (notification) in
            if let message = notification.userInfo?[PomodoroModelMessages.notificationEventKey] as? String {
                self?.handleNotification(message)
            }
            else {
                assertionFailure("No message found in notification")
            }
        }
    }
    
    func handleNotification(message: String) {
        switch message {
        case PomodoroModelMessages.modelChangeDidFail:
            updateTextualView()
        case PomodoroModelMessages.modelChangeDidSucceed:
            saveButton.enabled = true
            updateTextualView()
        default:
            assertionFailure("Unexpected message: \(message)")
        }
        
    }
    
    func updateTextualView() {
        nameTextField.text = model.name
        sprintLengthTextField.text = "\(model.intervalLength)"
        breakLengthTextField.text = "\(model.breakLength)"
    }

    // MARK: - Navigation

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let numFormatter = NSNumberFormatter()
            
            let name = nameTextField.text ?? ""
            let numIntervals = sprintsSegmentedControl.selectedSegmentIndex + 2
            let intervalLength = numFormatter.numberFromString(sprintLengthTextField.text!)
            let breakLength = numFormatter.numberFromString(breakLengthTextField.text!)
            
            if let iLength = intervalLength, bLength = breakLength {
                model.savePomodoro(name, numIntervals: numIntervals, intervalLength: iLength.integerValue, breakLength: bLength.integerValue)
                print("Added new pomodoro")
            }
        } else {
            assertionFailure("sender and saveButton not the same object instance")
        }
        
    }
    
}
