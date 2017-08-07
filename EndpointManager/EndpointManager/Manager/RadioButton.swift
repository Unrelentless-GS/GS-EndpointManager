//
//  RadioButton.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 7/8/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

let radioFill = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
let radioOutline = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
let radioClear = UIColor.clear

class RadioButton: UIView {

    var circleLayer: CAShapeLayer?
    var borderLayer: CAShapeLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.drawBorder()
        self.drawCircle()
    }

    private func drawBorder() {

        self.borderLayer?.removeFromSuperlayer()
        self.borderLayer = nil

        let centre = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)

        let circlePath = UIBezierPath(arcCenter: centre,
                                      radius: CGFloat(10),
                                      startAngle: CGFloat(0),
                                      endAngle:CGFloat(Double.pi * 2),
                                      clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath

        shapeLayer.strokeColor = radioOutline.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1.0

        self.borderLayer = shapeLayer

        self.layer.addSublayer(shapeLayer)
    }

    private func drawCircle() {

        self.circleLayer?.removeFromSuperlayer()
        self.circleLayer = nil

        let centre = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)

        let circlePath = UIBezierPath(arcCenter: centre,
                                      radius: CGFloat(8),
                                      startAngle: CGFloat(0),
                                      endAngle:CGFloat(Double.pi * 2),
                                      clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor

        self.circleLayer = shapeLayer
        circleLayer?.bounds = self.bounds
        circleLayer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer?.position = centre

        self.layer.addSublayer(shapeLayer)
    }

    func animateFill(inverse: Bool) {
        let centre = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)

        circleLayer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer?.position = centre

        let animcolor = CABasicAnimation(keyPath: "fillColor")
        animcolor.fromValue = inverse ? radioClear.cgColor : radioFill.cgColor
        animcolor.toValue = inverse ? radioFill.cgColor : radioClear.cgColor
        animcolor.duration = 1.0

        let transform = CABasicAnimation(keyPath: "transform")
        transform.fromValue = inverse ? CATransform3DMakeScale(1, 1, 1) : CATransform3DMakeScale(1, 1, 1)
        transform.toValue = inverse ? CATransform3DMakeScale(0, 0, 1) : CATransform3DMakeScale(1, 1, 1)
        transform.duration = 1.0

        circleLayer?.add(animcolor, forKey: "animcolor")
        circleLayer?.add(transform, forKey: "transform")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //        drawCircle()
    }
}
