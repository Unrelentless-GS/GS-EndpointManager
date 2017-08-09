//
//  FancyTableViewCell.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 7/8/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

class FancyTableViewCell: UITableViewCell {

    @IBOutlet weak var radioButton: RadioButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    func toggle(disabled: Bool) {
        self.titleLabel.textColor = disabled ? UIColor.lightGray : UIColor.black
        self.subtitleLabel.textColor = disabled ? UIColor.lightGray : UIColor.black
    }

    func fill(inverse: Bool) {
        radioButton.animateFill(inverse: inverse)
    }
}
