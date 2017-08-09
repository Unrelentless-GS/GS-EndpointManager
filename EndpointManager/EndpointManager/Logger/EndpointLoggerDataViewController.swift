//
//  EndpointLoggerDataViewController.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 8/8/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

internal enum NetworkMethodType {
    case request
    case response
}

internal enum NetworkMethod: String {
    case get
    case post
    case put
    case patch

    var segmentIndex: Int {
        switch self {
        case .get:
            return 0
        case .post:
            return 2
        case .patch:
            return 3
        case .put:
            return 1
        }
    }
}

class EndpointLoggerDataViewController: UIViewController {

    fileprivate let sectionArray = ["URL", "Method", "Header", "Body"]
    fileprivate let tableView = UITableView(frame: .zero, style: .plain)

    internal var type: NetworkMethodType = .request

    internal var request: URLRequest?
    internal var response: EndpointResponse?

    internal var requestCompletion: InterceptRequestCompletion?
    internal var responseCompletion: InterceptResponseCompletion?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = myGreen
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        title = request != nil ? "REQUEST" : response != nil ? "RESPONSE" : "LOGGER"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableHeaderView = UIView(frame: .zero)

        view.addSubview(tableView)

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[tableView]|",
            options: [],
            metrics: nil,
            views: ["tableView": tableView]))

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[tableView]|",
            options: [],
            metrics: nil,
            views: ["tableView": tableView]))

        view.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)

        tableView.estimatedRowHeight = 100
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(BoringSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.register(UINib(nibName: String(describing: BoringSegmentedTableViewCell.self),
                                 bundle: Bundle(for: BoringSegmentedTableViewCell.self)),
                           forCellReuseIdentifier: "segmented")
        tableView.register(UINib(nibName: String(describing: BoringTextViewTableViewCell.self),
                                 bundle: Bundle(for: BoringTextViewTableViewCell.self)),
                           forCellReuseIdentifier: "textView")

        genNavButtons()
    }

    func method() -> Int {
        guard let method = request?.httpMethod else { return 0 }
        return NetworkMethod(rawValue: method.lowercased())!.segmentIndex
    }

    func headers() -> String {
        var string = ""

        switch type {
        case .request:
            if let headers = request?.allHTTPHeaderFields {
                string += "\(headers)"
            }
        case .response:
            if let response = response?.response as? HTTPURLResponse {
                let keys = Array(response.allHeaderFields.keys).flatMap{$0.base}
                let values = Array(response.allHeaderFields.values)
                let test = zip(keys, values)

                test.forEach { (key, value) in
                    string += "\(key): \(value)\n"
                }
            }
        }
        return string
    }

    func body() -> String {
        var string = ""

        switch type {
        case .request:
            if let body = request?.httpBody {
                if let dataString = String(data: body, encoding: String.Encoding.utf8) {
                    string += dataString
                }
            }
        case .response:
            if let data = response?.data {
                if let dataString = String(data: data as Data, encoding: String.Encoding.utf8) {
                    string += dataString
                }
            }

            if let error = response?.error {
                string += "\(error.localizedDescription)"
            }
        }
        return string
    }


    func url() -> String {
        var string = ""

        switch type {
        case .request:
            string += request?.url?.absoluteString ?? ""
        case .response:
            if let response = response?.response as? HTTPURLResponse {
                string += response.url?.absoluteString ?? ""
            }
        }
        return string
    }

    fileprivate func genNavButtons() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelHandler))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneHandler))

        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton

        doneButton.tintColor = UIColor.white
        cancelButton.tintColor = UIColor.white
    }

    @objc fileprivate func cancelHandler() {
        EndpointLogger.dismiss(fromType: type)
        responseCompletion?()
        requestCompletion?(nil)
    }

    @objc fileprivate func doneHandler(_ item: UIBarButtonItem) {
        EndpointLogger.dismiss(fromType: type)
        responseCompletion?()
        requestCompletion?(nil)
    }
}

extension EndpointLoggerDataViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textView") as! BoringTextViewTableViewCell
            cell.selectionStyle = .none
            cell.textView.delegate = self
            cell.textView.text = url()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "segmented") as! BoringSegmentedTableViewCell
            cell.selectionStyle = .none
            cell.segmentedControl.selectedSegmentIndex = method()
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textView") as! BoringTextViewTableViewCell
            cell.selectionStyle = .none
            cell.textView.delegate = self
            cell.textView.text = headers()
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textView") as! BoringTextViewTableViewCell
            cell.selectionStyle = .none
            cell.textView.delegate = self
            cell.textView.text = body()
            return cell
        default:
            break
        }

        return tableView.dequeueReusableCell(withIdentifier: "cell")!
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! BoringSectionHeaderView
        header.label.text = sectionArray[section]
        return header
    }
}

extension EndpointLoggerDataViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
}

