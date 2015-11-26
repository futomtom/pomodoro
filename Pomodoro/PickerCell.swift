//
//  PickerCell.swift
//  Yelp
//
//  Created by Andrew Wilkes on 9/7/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol PickerCellDelegate {
    optional func pickerCell(pickerCell: PickerCell, didClickExpand
        value: Bool)
}

class PickerCell: UITableViewCell {

    @IBOutlet weak var topNameLabel: UILabel!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var dropDownView: UIView!
    
    weak var delegate: PickerCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func dropDownClicked(sender: AnyObject) {
        delegate?.pickerCell?(self, didClickExpand: true)
    }
}
