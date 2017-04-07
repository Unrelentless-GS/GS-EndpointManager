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
        EndpointLogger.monitor([Endpoint(name: nil, url: NSURL(string: "jsonplaceholder.typicode.com"))])

        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let request1 = NSMutableURLRequest(URL: NSURL(string: "https://jsonplaceholder.typicode.com/posts")!)
        let request2 = NSMutableURLRequest(URL: NSURL(string: "https://jsonplaceholder.typicode.com/posts")!)

        request2.HTTPMethod = "POST"
        request2.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(["title": "Hello", "body": "Something", "userId": "Bleh"], options: .PrettyPrinted)

        session.dataTaskWithRequest(request1).resume()
        session.dataTaskWithRequest(request2).resume()
    }

    @IBAction func touchMe(sender: UIButton) {
        EndpointManager.presentEndpointManagerFrom(UIApplication.sharedApplication().keyWindow!)
    }

    @objc private func endpointDidChange() {
        urlLabel.text = EndpointManager.selectedEndpoint?.name
    }
}

