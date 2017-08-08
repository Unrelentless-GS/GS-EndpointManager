//
//  FancyTextField.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 7/8/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

class FancyTextField: UITextField, UITextFieldDelegate {

    private var shouldToggle = false
    private var isShowing = false

    private lazy var underline: UIView = {
        let line = UIView()
        line.frame = CGRect(x: 20, y: self.bounds.size.height-2, width: self.bounds.size.width - 36, height: 1)
        line.backgroundColor = myOutline

        return line
    }()

    private lazy var placeholderText: UILabel = {
        let label = UILabel()
        label.text = self.placeholder
        label.frame = CGRect(x: 20, y: self.bounds.origin.y + 50, width: self.bounds.size.width - 36, height: 40)
        label.textColor = myOutline
        label.font = UIFont.systemFont(ofSize: 14)
        label.alpha = 0

        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if underline != nil {
            addSubview(underline)
            addSubview(placeholderText)
        }
    }

    private func toggleLine(editing: Bool) {
        underline.backgroundColor = editing == true ? myGreen : myOutline
        underline.frame = CGRect(origin: underline.frame.origin,
                                 size: CGSize(width: underline.frame.size.width,
                                              height: editing == true ? 2 : 1))
    }

    private func toggleText(show: Bool) {
        guard isShowing != show else { return }

        let newFrame = self.placeholderText.frame.offsetBy(dx: 0, dy: show == true ? -30 : 30)
        let newColour = show == true ? myGreen : myOutline

        UIView.animate(withDuration: 0.2) {
            self.placeholderText.alpha = show ? 1 : 0
            self.placeholderText.frame = newFrame
            self.placeholderText.textColor = newColour
        }

        isShowing = show
    }

    internal func toggleError() {
        underline.backgroundColor = myRed
        underline.frame = CGRect(origin: underline.frame.origin,
                                 size: CGSize(width: underline.frame.size.width,
                                              height: 2))

    }

    //MARK: OTHER

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let shouldShow = textField.text?.characters.count == 1 && string.isEmpty == true
        toggleText(show: !shouldShow)

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleLine(editing: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        toggleLine(editing: false)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.offsetBy(dx: 20, dy: 20)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.offsetBy(dx: 20, dy: 20)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.offsetBy(dx: 20, dy: 20)
    }

}
