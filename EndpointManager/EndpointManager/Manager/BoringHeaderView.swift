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

        backgroundColor = #colorLiteral(red: 0.9531012177, green: 0.9531235099, blue: 0.9531114697, alpha: 1)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please select an endpoint that you would like to hit"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)

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
