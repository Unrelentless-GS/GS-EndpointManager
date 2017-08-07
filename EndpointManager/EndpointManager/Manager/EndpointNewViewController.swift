//
//  NewEndpointViewController.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 3/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

internal enum URLError: Error {
    case malformedURL
}

internal typealias EndpointCompletion = (Endpoint?, URLError?) -> ()

internal class EndpointNewViewController: UIViewController {

    var completion: EndpointCompletion?

    let nameLabel = UILabel()
    let nameTextField = UITextField()

    let urlLabel = UILabel()
    let urlTextField = UITextField()

    let button = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = "Name"
        urlLabel.text = "Base URL"

        nameTextField.borderStyle = .roundedRect
        nameTextField.adjustsFontSizeToFitWidth = true
        nameTextField.minimumFontSize = 1.0
        urlTextField.borderStyle = .roundedRect
        urlTextField.adjustsFontSizeToFitWidth = true
        urlTextField.minimumFontSize = 1.0

        button.setTitle("Done", for: UIControlState())
        button.backgroundColor = UIColor(red: 56.0/255, green: 142.0/255, blue: 241.0/255, alpha: 1.0)
        button.tintColor = .white
        button.addTarget(self, action: #selector(doneHandler), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        let viewArray: [UIView] = [nameLabel, nameTextField, urlLabel, urlTextField]
        var constraints = [NSLayoutConstraint]()

        for view in viewArray {
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false

            constraints += NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-16-[name]-16-|",
                options: [],
                metrics: nil,
                views: ["name": view])
        }

        constraints += NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-20-[name(30)]-2-[nameText(==name)]-10-[url(==name)]-2-[urlText(==name)]->=20@200-[button(60)]|",
            options: [],
            metrics: nil,
            views: ["name": nameLabel, "nameText": nameTextField, "url": urlLabel, "urlText": urlTextField, "button": button])

        constraints += NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[name]|",
            options: [],
            metrics: nil,
            views: ["name": button])

        NSLayoutConstraint.activate(constraints)
    }

    @objc fileprivate func doneHandler() {
        guard let text = urlTextField.text else { return }
        guard let url = URL(string: text), UIApplication.shared.canOpenURL(url) else {
            completion?(nil, .malformedURL)

            let animation = CABasicAnimation(keyPath: "backgroundColor")
            animation.toValue = UIColor.red.cgColor
            animation.duration = 0.5
            animation.autoreverses = true

            urlTextField.layer.add(animation, forKey: "animation")
            return
        }
        let endpoint = Endpoint(name: nameTextField.text, url: url)
        completion?(endpoint, nil)
        self.dismiss(animated: true, completion: nil)
    }
}

extension EndpointNewViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
