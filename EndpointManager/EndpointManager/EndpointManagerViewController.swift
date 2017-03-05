//
//  EndpointManagerViewController.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 2/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

internal class EndpointManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let endpointTableView = UITableView()

    private var selectedIndex: Int?

    override internal func viewDidLoad() {
        super.viewDidLoad()

        title = "Endpoint Manager"

        endpointTableView.dataSource = self
        endpointTableView.delegate = self

        endpointTableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(endpointTableView)

        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[tableView]|",
            options: [],
            metrics: nil,
            views: ["tableView": endpointTableView]))

        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[tableView]|",
            options: [],
            metrics: nil,
            views: ["tableView": endpointTableView]))

        view.backgroundColor = .whiteColor()

        genNavButtons()
    }

    override internal func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateSelections(EndpointManager.selectedEndpointIndex)
    }

    @objc private func doneHandler() {
        EndpointManager.dismissVC()

        guard let index = selectedIndex, let endpoints = EndpointManager.endpoints else { return }
        EndpointManager.selectedEndpoint = endpoints[index]
    }

    @objc private func newHandler(item: UIBarButtonItem) {
        let newVC = EndpointNewViewController()
        newVC.modalPresentationStyle = .Popover
        newVC.preferredContentSize = CGSizeMake(200, 400)
        newVC.completion = { [unowned self] endpoint in
            self.updateEndpointWith(endpoint)

            let index = EndpointManager.endpoints?.indexOf{$0.name == endpoint.name}
            self.endpointTableView.reloadData()
            self.updateSelections(index)
        }

        let popover = newVC.popoverPresentationController
        popover?.barButtonItem = item
        popover?.sourceRect = CGRectMake(100, 100, 0, 0)
        popover?.delegate = newVC

        self.showDetailViewController(newVC, sender: self)
    }

    private func genNavButtons() {
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(doneHandler))
        let newButton = UIBarButtonItem(title: "New", style: .Plain, target: self, action: #selector(newHandler))

        self.navigationItem.leftBarButtonItem = doneButton
        self.navigationItem.rightBarButtonItem = newButton
    }

    private func updateEndpointWith(endpoint: Endpoint?) {
        guard let endpoint = endpoint else { return }
        guard let endpoints = EndpointManager.endpoints else { return }
        if !endpoints.contains({$0.name == endpoint.name}) {
            EndpointManager.endpoints?.append(endpoint)
        }
        EndpointManager.selectedEndpoint = endpoint
    }

    private func updateSelections(row: Int?) {
        for i in 0..<endpointTableView.numberOfRowsInSection(0) {
            let cell = endpointTableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
            cell?.highlight(i == row)
        }
    }
}

//MARK: datasource
extension EndpointManagerViewController {

    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EndpointManager.endpoints?.count ?? 0
    }

    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")

        defer {
            cell?.textLabel!.text = EndpointManager.endpoints?[indexPath.row].name
            cell?.detailTextLabel!.text = EndpointManager.endpoints?[indexPath.row].url
        }

        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        }

        return cell!
    }
}

//MARK: delegate
extension EndpointManagerViewController {
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        updateEndpointWith(EndpointManager.endpoints?[indexPath.row])
        updateSelections(indexPath.row)
    }

    internal func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }

    internal func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        EndpointManager.endpoints?.removeAtIndex(indexPath.row)
        tableView.reloadData()
        updateSelections(EndpointManager.selectedEndpointIndex)
    }
}
