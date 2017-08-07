//
//  EndpointManagerViewController.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 2/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

internal class EndpointManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    fileprivate let endpointTableView = UITableView()

    fileprivate var selectedIndex: Int? {
        guard let endpoints = EndpointManager.endpoints, let selectedEndpoint = selectedEndpoint else { return nil }
        return endpoints.index{($0.name == selectedEndpoint.name) && ($0.url == selectedEndpoint.url)}
    }

    fileprivate var selectedEndpoint: Endpoint?

    override internal func viewDidLoad() {
        super.viewDidLoad()

        title = "Endpoint Manager"

        endpointTableView.dataSource = self
        endpointTableView.delegate = self

        endpointTableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(endpointTableView)

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[tableView]|",
            options: [],
            metrics: nil,
            views: ["tableView": endpointTableView]))

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[tableView]|",
            options: [],
            metrics: nil,
            views: ["tableView": endpointTableView]))

        view.backgroundColor = .white

        endpointTableView.register(UINib(nibName: String(describing: FancyTableViewCell.self), bundle: Bundle(for: FancyTableViewCell.self)), forCellReuseIdentifier: "cell")
        endpointTableView.estimatedRowHeight = 100

        genNavButtons()
    }

    override internal func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        selectedEndpoint = EndpointManager.selectedEndpoint
        updateSelections(selectedIndex)
    }

    @objc fileprivate func doneHandler() {
        EndpointManager.dismissVC()

        guard let index = selectedIndex, let endpoints = EndpointManager.endpoints else { return }
        EndpointManager.selectedEndpoint = endpoints[index]
        EndpointDataManager.saveEndpoints()
    }

    @objc fileprivate func newHandler(_ item: UIBarButtonItem) {
        let newVC = EndpointNewViewController()
        newVC.modalPresentationStyle = .popover
        newVC.preferredContentSize = CGSize(width: 200, height: 400)
        newVC.completion = { [unowned self] endpoint, error in
            guard error == nil else { return }
            guard let validEndpoint = endpoint else { return }
            EndpointManager.defaultManager.endpoints.append(validEndpoint)

            self.selectedEndpoint = validEndpoint
            self.endpointTableView.reloadData()
            self.updateSelections(self.selectedIndex)
        }

        let popover = newVC.popoverPresentationController
        popover?.barButtonItem = item
        popover?.sourceRect = CGRect(x: 100, y: 100, width: 0, height: 0)
        popover?.delegate = newVC

        self.showDetailViewController(newVC, sender: self)
    }

    fileprivate func genNavButtons() {
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneHandler))
        let newButton = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(newHandler))

        self.navigationItem.leftBarButtonItem = doneButton
        self.navigationItem.rightBarButtonItem = newButton
    }

    fileprivate func updateSelections(_ row: Int?) {
        for i in 0..<endpointTableView.numberOfRows(inSection: 0) {
            let cell = endpointTableView.cellForRow(at: IndexPath(row: i, section: 0))
            cell?.highlight(i == row)
        }
    }
}

//MARK: datasource
extension EndpointManagerViewController {

    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EndpointManager.endpoints?.count ?? 0
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FancyTableViewCell

//        if cell == nil {
//            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
//        }

//        cell?.textLabel!.text = EndpointManager.endpoints?[indexPath.row].name
//        cell?.detailTextLabel!.text = EndpointManager.endpoints?[indexPath.row].url?.absoluteString

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

//MARK: delegate
extension EndpointManagerViewController {

    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let endpoints = EndpointManager.endpoints else { return }
        selectedEndpoint = endpoints[indexPath.row]
        updateSelections(selectedIndex)

        let cell = endpointTableView.cellForRow(at: indexPath) as! FancyTableViewCell
        cell.fill()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return selectedIndex != indexPath.row
    }

    internal func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        EndpointManager.defaultManager.endpoints.remove(at: indexPath.row)
        tableView.reloadData()
        updateSelections(selectedIndex)
    }
}
