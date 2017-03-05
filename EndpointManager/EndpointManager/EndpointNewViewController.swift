//
//  NewEndpointViewController.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 3/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

internal typealias EndpointCompletion = (Endpoint) -> ()

internal class EndpointNewViewController: UIViewController {

    var completion: EndpointCompletion?

    let nameLabel = UILabel()
    let nameTextField = UITextField()

    let urlLabel = UILabel()
    let urlTextField = UITextField()

    let button = UIButton(type: .System)

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = "Name"
        urlLabel.text = "Base URL"

        nameTextField.borderStyle = .RoundedRect
        nameTextField.adjustsFontSizeToFitWidth = true
        nameTextField.minimumFontSize = 1.0
        urlTextField.borderStyle = .RoundedRect
        urlTextField.adjustsFontSizeToFitWidth = true
        urlTextField.minimumFontSize = 1.0

        button.setTitle("Done", forState: .Normal)
        button.backgroundColor = UIColor(red: 56.0/255, green: 142.0/255, blue: 241.0/255, alpha: 1.0)
        button.tintColor = .whiteColor()
        button.addTarget(self, action: #selector(doneHandler), forControlEvents: .TouchUpInside)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(urlLabel)
        view.addSubview(urlTextField)
        view.addSubview(button)

        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-20-[name(30)]-2-[nameText(==name)]-10-[url(==name)]-2-[urlText(==name)]->=20@200-[button(60)]|",
            options: [],
            metrics: nil,
            views: ["name": nameLabel, "nameText": nameTextField, "url": urlLabel, "urlText": urlTextField, "button": button]))

        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-16-[name]-16-|",
            options: [],
            metrics: nil,
            views: ["name": nameLabel]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-16-[name]-16-|",
            options: [],
            metrics: nil,
            views: ["name": nameTextField]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-16-[name]-16-|",
            options: [],
            metrics: nil,
            views: ["name": urlLabel]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-16-[name]-16-|",
            options: [],
            metrics: nil,
            views: ["name": urlTextField]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[name]|",
            options: [],
            metrics: nil,
            views: ["name": button]))

    }

    @objc private func doneHandler() {
        let endpoint = Endpoint(name: nameTextField.text, url: urlTextField.text)
        completion?(endpoint)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension EndpointNewViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }
}
