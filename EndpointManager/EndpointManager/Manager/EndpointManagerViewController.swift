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

    private var selectedIndex: Int? {
        guard let endpoints = EndpointManager.endpoints, let selectedEndpoint = selectedEndpoint else { return nil }
        return endpoints.indexOf{($0.name == selectedEndpoint.name) && ($0.url == selectedEndpoint.url)}
    }

    private var selectedEndpoint: Endpoint?

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

        selectedEndpoint = EndpointManager.selectedEndpoint
        updateSelections(selectedIndex)
    }

    @objc private func doneHandler() {
        EndpointManager.dismissVC()

        guard let index = selectedIndex, let endpoints = EndpointManager.endpoints else { return }
        EndpointManager.selectedEndpoint = endpoints[index]
        EndpointDataManager.saveEndpoints()
    }

    @objc private func newHandler(item: UIBarButtonItem) {
        let newVC = EndpointNewViewController()
        newVC.modalPresentationStyle = .Popover
        newVC.preferredContentSize = CGSizeMake(200, 400)
        newVC.completion = { [unowned self] endpoint, error in
            guard error == nil else { return }
            guard let validEndpoint = endpoint else { return }
            EndpointManager.defaultManager.endpoints?.append(validEndpoint)

            self.selectedEndpoint = validEndpoint
            self.endpointTableView.reloadData()
            self.updateSelections(self.selectedIndex)
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

        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        }

        cell?.textLabel!.text = EndpointManager.endpoints?[indexPath.row].name
        cell?.detailTextLabel!.text = EndpointManager.endpoints?[indexPath.row].url?.absoluteString

        return cell!
    }
}

//MARK: delegate
extension EndpointManagerViewController {

    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        guard let endpoints = EndpointManager.endpoints else { return }
        selectedEndpoint = endpoints[indexPath.row]
        updateSelections(selectedIndex)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return selectedIndex != indexPath.row
    }

    internal func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }

    internal func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        EndpointManager.defaultManager.endpoints?.removeAtIndex(indexPath.row)
        tableView.reloadData()
        updateSelections(selectedIndex)
    }
}
