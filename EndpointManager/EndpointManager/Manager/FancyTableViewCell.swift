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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func fill() {
        radioButton.animateFill(inverse: false)
    }
}
