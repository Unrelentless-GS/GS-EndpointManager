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
@objc final public class EndpointManager: NSObject {
    
    public static let EndpointChangedNotification = "GSEndpointChangedNotification"

    internal static var defaultManager = EndpointManager()

    /// The array of endpoints
    public static var endpoints: [Endpoint]? {
        get {
            return defaultManager.endpoints
        }
    }

    /// The selected endpoint
    internal(set) public static var selectedEndpoint: Endpoint? {
        get {
            return defaultManager.selectedEndpoint
        }
        set {
            defaultManager.selectedEndpoint = newValue
            NotificationCenter.default.post(name: Notification.Name(rawValue: EndpointChangedNotification), object: nil)
        }
    }

    internal static var selectedEndpointIndex: Int? {
        get {
            return defaultManager.selectedEndpointIndex
        }
    }

    internal var endpoints = [Endpoint]() {
        didSet {
            if selectedEndpointIndex == nil {
                selectedEndpoint = nil
            }
        }
    }

    internal var window = UIWindow()
    internal var selectedEndpoint: Endpoint?
    internal var selectedEndpointIndex: Int? {
        return self.endpoints.index{$0.name == self.selectedEndpoint?.name}
    }

    fileprivate weak var keyWindow: UIWindow?

    //This prevents others from using the default '()' initializer for this class.
    fileprivate override init() {
        super.init()
        self.endpoints = [Endpoint]()
    }

    /**
     Populate the endpoints

     - parameter endpoints: an array of endpoints
     */
    public static func populate(_ endpoints: [Endpoint]) {
        if let existingEndpoints = EndpointDataManager.loadEndpoints() {
            defaultManager.endpoints = existingEndpoints
            defaultManager.selectedEndpoint = EndpointDataManager.loadSelectedEndpoint()
        } else {
            defaultManager.endpoints = endpoints
        }
    }

    /**
     Present the endpoint manager screen

     - parameter window: a reference to your current working window. if in doubt, pass in **`UIApplication.sharedApplication().keyWindow`**
     */
    public static func presentEndpointManagerFrom(_ window: UIWindow) {
        defaultManager.keyWindow = window

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
        keyWindow?.isHidden = false
        keyWindow?.makeKeyAndVisible()
    }
}
