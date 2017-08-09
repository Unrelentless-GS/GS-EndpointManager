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

internal class EndpointNewViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: FancyTextField!
    @IBOutlet weak var urlTextField: FancyTextField!

    var completion: EndpointCompletion?

    private var currentTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Endpoint"

        navigationController?.navigationBar.barTintColor = myGreen
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        genNavButtons()
    }

    @objc fileprivate func cancelHandler() {
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func doneHandler(_ item: UIBarButtonItem) {

        guard let text = urlTextField.text else { return }
        guard let url = URL(string: text), UIApplication.shared.canOpenURL(url) else {
            completion?(nil, .malformedURL)
            urlTextField.toggleError()
            return
        }
        let endpoint = Endpoint(name: nameTextField.text, url: url)
        completion?(endpoint, nil)
        self.dismiss(animated: true, completion: nil)
    }

    fileprivate func genNavButtons() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelHandler))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneHandler))

        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton

        doneButton.tintColor = UIColor.white
        cancelButton.tintColor = UIColor.white
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
}
