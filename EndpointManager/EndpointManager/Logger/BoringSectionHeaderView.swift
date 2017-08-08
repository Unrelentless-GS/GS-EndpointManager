//
//  BoringSectionHeaderView.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 8/8/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

class BoringSectionHeaderView: UITableViewHeaderFooterView {

    var label = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        label.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(label)

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[label]|",
            options: [],
            metrics: nil,
            views: ["label": label]))

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-16-[label]-16-|",
            options: [],
            metrics: nil,
            views: ["label": label]))

        label.textColor = .black
        label.text = "Test"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
