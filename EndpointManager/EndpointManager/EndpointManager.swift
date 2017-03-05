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

    /// Set this to your main Window if you want the Endpoint Manager to handle all presentation of the endpoint manager screen
    /// by shaking the device.
    /// You can also call `presentEndpointManager` to manually present it from your own action.
    public static var window: EndpointWindow? {
        get {
            return defaultManager.window
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
    internal var selectedEndpoint: Endpoint?
    internal lazy var window: EndpointWindow = {
        UIApplication.sharedApplication().applicationSupportsShakeToEdit = true
        let window = EndpointWindow()
        window.frame = UIScreen.mainScreen().bounds
        return window
    }()
    internal var selectedEndpointIndex: Int? {
        return self.endpoints?.indexOf{$0.name == self.selectedEndpoint?.name}
    }

    internal func dimiss() {
        window.dismissSub()
    }

    private override init() {} //This prevents others from using the default '()' initializer for this class.

    public func presentEndpointManager() {
        
    }
}
