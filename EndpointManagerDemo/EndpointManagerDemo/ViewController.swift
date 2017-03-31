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
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .cyanColor()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(endpointDidChange), name: EndpointManager.EndpointChangedNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: EndpointManager.EndpointChangedNotification, object: nil)
    }

    @IBAction func testNetwork(sender: AnyObject) {
        guard let url = EndpointManager.selectedEndpoint?.url else { return }
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_SEC)), dispatch_get_main_queue()) { [weak self] in
            self?.webView.stopLoading()
        }
    }

    @IBAction func touchMe(sender: UIButton) {
        EndpointManager.presentEndpointManagerFrom(UIApplication.sharedApplication().keyWindow!)
    }

    @objc private func endpointDidChange() {
        urlLabel.text = EndpointManager.selectedEndpoint?.name
    }
}

