//
//  InterceptedEndpointViewController.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 31/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

internal enum NetworkMethodType {
    case request
    case response
}

internal class EndpointLoggerInterceptedViewController: UIViewController {

    internal var type: NetworkMethodType = .request
    
    internal var request: URLRequest?
    internal var response: EndpointResponse?

    internal var requestCompletion: InterceptRequestCompletion?
    internal var responseCompletion: InterceptResponseCompletion?

    fileprivate var textView = UITextView()

    override internal func viewDidLoad() {
        super.viewDidLoad()

        title = request != nil ? "REQUEST" : response != nil ? "RESPONSE" : "LOGGER"

        textView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(textView)

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[textView]|",
            options: [],
            metrics: nil,
            views: ["textView": textView]))

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[textView]|",
            options: [],
            metrics: nil,
            views: ["textView": textView]))

        view.backgroundColor = .white

        genNavButtons()

        if type == .request {
            genRequest()
        } else if type == .response {
            genResponse()
        }
    }

    fileprivate func genRequest() {
        var string = ""

        string += "\((request?.url?.absoluteString)!)\n\n"
        string += "\((request?.allHTTPHeaderFields)!)\n\n"

        if let body = request?.httpBody {
            if let dataString = String(data: body, encoding: String.Encoding.utf8) {
                string += dataString
            }
        }

        textView.text = string
    }

    fileprivate func genResponse() {

        var string = ""

        if let absoluteString = response?.response?.url?.absoluteString {
            string += "\(absoluteString)\n\n"
        }

        if let response = response?.response as? HTTPURLResponse {
            string += "\((response.allHeaderFields))\n\n"
        }

        if let data = response?.data {
            do {
                let json = try JSONSerialization.jsonObject(with: data as Data, options: [])
                if json is [AnyObject] {
                    string += "\(json as! [AnyObject])\n\n"
                } else {
                    string += "\(json as! [String: AnyObject])\n\n"
                }
            } catch {
                if let dataString = String(data: data as Data, encoding: String.Encoding.utf8) {
                    string += dataString
                }
            }
        }

        if let error = response?.error {
            string += "\(error.localizedDescription)\n\n"
        }

        textView.text = string
    }

    @objc fileprivate func doneHandler() {
        EndpointLogger.dismiss(fromType: type)
        responseCompletion?()
        requestCompletion?(nil)
    }

    fileprivate func genNavButtons() {
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneHandler))
        self.navigationItem.leftBarButtonItem = doneButton
    }
    
}
