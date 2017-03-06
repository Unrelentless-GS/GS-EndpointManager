//
//  EndpointManager.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 2/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

@objc public class EndpointManager: NSObject {

    /// The array of endpoints
    public static var endpoints: [Endpoint]? {
        get {
            return defaultManager.endpoints
        }

        set {
            defaultManager.endpoints = newValue
            if selectedEndpointIndex == nil {
                selectedEndpoint = nil
            }
        }
    }

    /// The selected endpoint
    internal(set) public static var selectedEndpoint: Endpoint? {
        get {
            return defaultManager.selectedEndpoint
        }
        set {
            defaultManager.selectedEndpoint = newValue
        }
    }

    internal static func dismissVC() {
        defaultManager.dimiss()
    }

    internal static var selectedEndpointIndex: Int? {
        get {
            return defaultManager.selectedEndpointIndex
        }
    }

    internal static var defaultManager = EndpointManager()

    internal var endpoints = [Endpoint]?()
    internal var window = UIWindow()
    internal var selectedEndpoint: Endpoint?
    internal var selectedEndpointIndex: Int? {
        return self.endpoints?.indexOf{$0.name == self.selectedEndpoint?.name}
    }

    private weak var privateWindow: UIWindow?

    private override init() {} //This prevents others from using the default '()' initializer for this class.

    public static func presentEndpointManagerFrom(window: UIWindow) {
        defaultManager.privateWindow = window

        defaultManager.window.frame = window.bounds
        let vc = EndpointManagerViewController()

        let nc = UINavigationController(rootViewController: vc)
        defaultManager.window.rootViewController = nc
        defaultManager.window.makeKeyAndVisible()
    }

    internal func dimiss() {
        privateWindow?.makeKeyAndVisible()
    }
}
