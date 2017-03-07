//
//  EndpointLogger.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 7/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

@objc public class EndpointLogger: NSObject {


    public static var monitoredEndpoints: [Endpoint]? {
        get {
            return defaultManager.monitoredEndpoints
        }
    }

    internal var monitoredEndpoints = [Endpoint]?()


    internal static var defaultManager = EndpointLogger()
    private override init() { }

    
    public class var endpointProtocol: AnyClass {
        return EndpointProtocol.self
    }

    public static func monitor(endpoints: [Endpoint]) {
        defaultManager.monitoredEndpoints = endpoints
    }
}
