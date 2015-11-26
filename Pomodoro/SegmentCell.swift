//
//  SegmentCell.swift
//  Yelp
//
//  Created by Holly French on 4/26/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

protocol SegmentCellDelegate : class {
    func didUpdateSegmentValue(segmentCell: SegmentCell, value: Int)
}

class SegmentCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    
    @IBOutlet weak var segmentCell: UISegmentedControl!
    
    var type: FilterTypes?
    
    weak var delegate: SegmentCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        delegate!.didUpdateSegmentValue(self, value: segmentCell.selectedSegmentIndex)
    }
 
    func setSegmentValue(index: Int) {
        segmentCell.selectedSegmentIndex = index
    }
    
}
