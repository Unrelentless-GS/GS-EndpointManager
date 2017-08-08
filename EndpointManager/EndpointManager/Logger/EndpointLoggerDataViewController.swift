//
//  EndpointLoggerDataViewController.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 8/8/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

class EndpointLoggerDataViewController: UIViewController {

    fileprivate let sectionArray = ["Method", "Header", "Body"]

    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = myGreen
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        title = "Logger"

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

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(BoringSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.register(UINib(nibName: String(describing: BoringSegmentedTableViewCell.self),
                                 bundle: Bundle(for: BoringSegmentedTableViewCell.self)),
                           forCellReuseIdentifier: "segmented")

        genNavButtons()
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
        dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func doneHandler(_ item: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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

        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")!

        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "segmented")!
        default:
            break
        }

        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! BoringSectionHeaderView
        header.label.text = sectionArray[section]
        return header
    }
}
