//
//  InterceptedEndpointViewController.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 31/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

internal enum NetworkMethodType {
    case Request
    case Response
}

internal class EndpointLoggerInterceptedViewController: UIViewController {

    internal var type: NetworkMethodType = .Request
    
    internal weak var request: NSURLRequest?
    internal var response: EndpointResponse?

    internal var requestCompletion: InterceptRequestCompletion?
    internal var responseCompletion: InterceptResponseCompletion?

    private var textView = UITextView()

    override internal func viewDidLoad() {
        super.viewDidLoad()

        title = request != nil ? "REQUEST" : response != nil ? "RESPONSE" : "LOGGER"

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

        if type == .Request {
            genRequest()
        } else if type == .Response {
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

        if let absoluteString = response?.response?.URL?.absoluteString {
            string += "\(absoluteString)\n\n"
        }

        if let response = response?.response as? NSHTTPURLResponse {
            string += "\((response.allHeaderFields))\n\n"
        }

        if let data = response?.data {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                if json is [AnyObject] {
                    string += "\(json as! [AnyObject])\n\n"
                } else {
                    string += "\(json as! [String: AnyObject])\n\n"
                }
            } catch {
                if let dataString = String(data: data, encoding: NSUTF8StringEncoding) {
                    string += dataString
                }
            }
        }

        if let error = response?.error {
            string += "\(error.localizedDescription)\n\n"
        }

        textView.text = string
    }

    @objc private func doneHandler() {
        EndpointLogger.dismiss(fromType: type)
        responseCompletion?()
        requestCompletion?(nil)
    }

    private func genNavButtons() {
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(doneHandler))
        self.navigationItem.leftBarButtonItem = doneButton
    }
    
}
