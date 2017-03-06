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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .cyanColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func touchMe(sender: UIButton) {
        EndpointManager.presentEndpointManagerFrom(UIApplication.sharedApplication().keyWindow!)
    }
}

