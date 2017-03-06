//
//  EndpointManager.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 2/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

/** 
 The Endpoint Manager
 
 Your one point of contact with endpoints
 
 Subscribe to the **`EndpointChangedNotification`** notification for changes to selected endpoint
*/
@objc public class EndpointManager: NSObject {
    
    public static let EndpointChangedNotification = "GSEndpointChangedNotification"

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
            NSNotificationCenter.defaultCenter().postNotificationName(EndpointChangedNotification, object: nil)
        }
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

    /**
     Present the endpoint manager screen

     - parameter window: a reference to your current working window. If in doubt, pass in **`UIApplication.sharedApplication().keyWindow`**
     */
    public static func presentEndpointManagerFrom(window: UIWindow) {
        defaultManager.privateWindow = window

        defaultManager.window.frame = window.bounds
        let vc = EndpointManagerViewController()

        let nc = UINavigationController(rootViewController: vc)
        defaultManager.window.rootViewController = nc
        defaultManager.window.makeKeyAndVisible()
    }

    internal static func dismissVC() {
        defaultManager.dimiss()
    }

    internal func dimiss() {
        privateWindow?.makeKeyAndVisible()
    }
}
