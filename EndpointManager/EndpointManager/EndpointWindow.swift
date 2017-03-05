//
//  EndpointWindow.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 2/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit

/// An endpoint window to handle shake events
@objc public class EndpointWindow: UIWindow {

    private var subWindow = UIWindow()

    public override func canBecomeFirstResponder() -> Bool {
        return true
    }

    public override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        self.subWindow.frame = self.bounds
        let vc = EndpointManagerViewController()

        let nc = UINavigationController(rootViewController: vc)
        subWindow.rootViewController = nc
        subWindow.makeKeyAndVisible()

        super.motionEnded(motion, withEvent: event)
    }

    internal func dismissSub() {
        self.makeKeyAndVisible()
    }
}
