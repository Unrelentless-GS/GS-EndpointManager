//
//  BoringHeaderView.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 7/8/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

class BoringHeaderView: UIView {

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please select an endpoint that you would like to hit"
        label.textAlignment = .center
        label.numberOfLines = 0

        self.addSubview(label)

        var constraints = [NSLayoutConstraint]()

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: [], metrics: nil, views: ["label": label])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: ["label": label])

        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
