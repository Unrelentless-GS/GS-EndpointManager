//
//  BoringSegmentedTableViewCell.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 8/8/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

class BoringSegmentedTableViewCell: UITableViewCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControl.tintColor = myGreen
        segmentedControl.backgroundColor = .white
    }
}
