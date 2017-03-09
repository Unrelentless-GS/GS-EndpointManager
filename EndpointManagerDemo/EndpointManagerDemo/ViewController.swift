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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func testNetwork(sender: AnyObject) {
        guard let url = EndpointManager.selectedEndpoint?.url else { return }
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue()) { [weak self] in
            self?.webView.stopLoading()
        }

        let request2 = NSMutableURLRequest(URL: url)
        request2.HTTPMethod = "POST"

        let request3 = NSMutableURLRequest(URL: url)
        request2.HTTPMethod = "PUT"

        let data = "asdasjdasdasd".dataUsingEncoding(NSUTF8StringEncoding)

        NSURLSession.sharedSession().dataTaskWithRequest(request2).resume()
        NSURLSession.sharedSession().uploadTaskWithStreamedRequest(request3).resume()
        NSURLSession.sharedSession().uploadTaskWithRequest(request2, fromData: data!).resume()
    }

    @IBAction func touchMe(sender: UIButton) {
        EndpointManager.presentEndpointManagerFrom(UIApplication.sharedApplication().keyWindow!)
    }

    @objc private func endpointDidChange() {
        urlLabel.text = EndpointManager.selectedEndpoint?.name
    }
}

