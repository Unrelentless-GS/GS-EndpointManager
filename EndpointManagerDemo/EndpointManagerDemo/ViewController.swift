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
        view.backgroundColor = .cyan

        NotificationCenter.default.addObserver(self, selector: #selector(endpointDidChange), name: NSNotification.Name(rawValue: EndpointManager.EndpointChangedNotification), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: EndpointManager.EndpointChangedNotification), object: nil)
    }

    @IBAction func testNetwork(sender: AnyObject) {
        EndpointLogger.monitor([Endpoint(name: nil, url: URL(string: "jsonplaceholder.typicode.com"))])

        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let request1 = NSMutableURLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/comments?postId=1")!)
        let request2 = NSMutableURLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)

        request2.httpMethod = "POST"
        request2.httpBody = try? JSONSerialization.data(withJSONObject: ["title": "Hello", "body": "Something", "userId": "Bleh"], options: .prettyPrinted)

        session.dataTask(with: request1 as URLRequest).resume()
        session.dataTask(with: request2 as URLRequest).resume()
    }

    @IBAction func touchMe(sender: UIButton) {
        EndpointManager.presentEndpointManagerFrom(UIApplication.shared.keyWindow!)
    }

    @objc private func endpointDidChange() {
        urlLabel.text = EndpointManager.selectedEndpoint?.name
    }
}

