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

class EndpointLoggerDataViewController: UIViewController {

    fileprivate let sectionArray = ["Method", "Header", "Body"]
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)

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
        tableView.tableFooterView = UIView()

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
        tableView.sectionHeaderHeight = 40
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

    fileprivate func genRequest() -> String {
        var string = ""

        string += "\((request?.url?.absoluteString)!)\n\n"
        string += "\((request?.allHTTPHeaderFields)!)\n\n"

        if let body = request?.httpBody {
            if let dataString = String(data: body, encoding: String.Encoding.utf8) {
                string += dataString
            }
        }

        return string
    }

    fileprivate func genResponse() -> String {

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
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textView") as! BoringTextViewTableViewCell
            cell.selectionStyle = .none
            cell.textView.delegate = self
            cell.textView.text = type == .request ? String(describing: request?.url!) : String(describing: response?.response?.url!)
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "segmented")!
            cell.selectionStyle = .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textView") as! BoringTextViewTableViewCell
            cell.selectionStyle = .none
            cell.textView.delegate = self
            cell.textView.text = type == .request ? String(describing: request?.allHTTPHeaderFields) : String(describing: response?.response)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textView") as! BoringTextViewTableViewCell
            cell.selectionStyle = .none
            cell.textView.delegate = self
            cell.textView.text = type == .request ? genRequest() : genResponse()
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

