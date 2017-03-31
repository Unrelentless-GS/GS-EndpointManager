//
//  InterceptedEndpointViewController.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 31/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

internal class EndpointLoggerInterceptedViewController: UIViewController {

    internal weak var request: NSURLRequest?
    internal weak var response: NSURLResponse?

    internal var requestCompletion: InterceptRequestCompletion?
    internal var responseCompletion: InterceptResponseCompletion?

    private var textView = UITextView()

    override internal func viewDidLoad() {
        super.viewDidLoad()

        title = "Endpoint Logger"

        textView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(textView)

        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[textView]|",
            options: [],
            metrics: nil,
            views: ["textView": textView]))

        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[textView]|",
            options: [],
            metrics: nil,
            views: ["textView": textView]))

        view.backgroundColor = .whiteColor()

        genNavButtons()

        if request != nil {
            genRequest()
        } else if response != nil {
            genResponse()
        }
    }

    private func genRequest() {
        var string = ""

        string += "\((request?.URL?.absoluteString)!)\n\n"
        string += "\((request?.allHTTPHeaderFields)!)\n\n"

        if let body = request?.HTTPBody {
            if let dataString = String(data: body, encoding: NSUTF8StringEncoding) {
                string += dataString
            }
        }

        textView.text = string
    }

    private func genResponse() {

        var string = ""

        string += "\((response?.URL?.absoluteString)!)\n\n"
        if let response = response as? NSHTTPURLResponse {
            string += "\((response.allHeaderFields))\n\n"
        }

        if let message = response {
            if let data = message as? NSData {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    string += "\(json as! [String: AnyObject])"
                } catch {
                    if let dataString = String(data: data, encoding: NSUTF8StringEncoding) {
                        string += dataString
                    }
                }
            }
        }

        textView.text = string
    }

    @objc private func doneHandler() {
        EndpointLogger.dismiss()
        responseCompletion?()
        requestCompletion?(nil)
    }

    private func genNavButtons() {
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(doneHandler))
        self.navigationItem.leftBarButtonItem = doneButton
    }

}
