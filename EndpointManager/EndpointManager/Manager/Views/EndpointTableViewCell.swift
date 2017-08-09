//
//  EndpointTableViewCell.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 3/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

internal extension UITableViewCell {
    internal func highlight(_ highlight: Bool) {
        self.contentView.layer.borderColor = UIColor(red: 0, green: 153.0/255.0, blue: 0, alpha: 1.0).cgColor
        self.contentView.layer.borderWidth = highlight ? 2 : 0
    }
}
