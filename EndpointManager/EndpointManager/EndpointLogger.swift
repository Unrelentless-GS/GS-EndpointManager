//
//  EndpointLogger.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 7/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

@objc public class EndpointLogger: NSObject {

    public static var logToConsole: Bool = false

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

    internal static func log(title title: String, message: AnyObject?) {
        guard var message = message else { return }
        guard logToConsole == true else { return }
        if let data = message as? NSData {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                message = json as! [String: AnyObject]
            } catch {
                if let dataString = String(data: data, encoding: NSUTF8StringEncoding) {
                    message = dataString
                }
            }
        }

        print("****************************")
        print("ENDPOINT LOGGER")
        print(title)
        print("****************************")
        print(message)
    }
}
