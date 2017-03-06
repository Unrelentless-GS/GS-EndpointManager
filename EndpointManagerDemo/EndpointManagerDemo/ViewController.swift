//
//  ViewController.swift
//  EndpointManagerDemo
//
//  Created by Pavel Boryseiko on 2/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit
import EndpointManager

class ViewController: UIViewController {

    @IBOutlet weak var urlLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .cyanColor()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(endpointDidChange), name: EndpointManager.EndpointChangedNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: EndpointManager.EndpointChangedNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func touchMe(sender: UIButton) {
        EndpointManager.presentEndpointManagerFrom(UIApplication.sharedApplication().keyWindow!)
    }

    @objc private func endpointDidChange() {
        urlLabel.text = EndpointManager.selectedEndpoint?.name
    }
}

