//
//  EndpointLogger.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 7/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

internal typealias InterceptRequestCompletion = (NSMutableURLRequest?) -> ()
internal typealias InterceptResponseCompletion = () -> ()

@objc public class EndpointLogger: NSObject {

    public static var logToConsole: Bool = false
    public static var interceptAndDisplayRequest: Bool = false
    public static var monitoredEndpoints: [Endpoint]? {
        get {
            return defaultManager.monitoredEndpoints
        }
    }

    public static weak var keyWindow: UIWindow?
    public static var endpointProtocol: AnyClass {
        return EndpointProtocol.self
    }

    internal static var defaultManager = EndpointLogger()
    internal var monitoredEndpoints = [Endpoint]?()

    private lazy var loggerWindow: UIWindow = {
        let frame = UIApplication.sharedApplication().keyWindow?.frame
        return UIWindow(frame: frame!)
    }()


    private override init() { /* NSMutableURLRequest.endpointManagerHTTPBodySwizzle() */ }

    public static func monitor(endpoints: [Endpoint], forSession session: NSURLSession) {
        var classes = session.configuration.protocolClasses
        classes?.insert(EndpointProtocol.self, atIndex: 0)
        session.configuration.protocolClasses = classes

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
        print(message)
        print("****************************")
    }

    internal static func presentWindow(forRequest request: NSURLRequest, completion: InterceptRequestCompletion) {
        if EndpointLogger.interceptAndDisplayRequest == true {
            dispatch_async(dispatch_get_main_queue()) {
                let viewController = EndpointLoggerInterceptedViewController()
                viewController.request = request
                viewController.requestCompletion = completion
                let navController = UINavigationController(rootViewController: viewController)
                defaultManager.loggerWindow.rootViewController = navController
                defaultManager.loggerWindow.makeKeyAndVisible()
            }
        }
    }


    internal static func presentWindow(forResponse response: NSURLResponse, completion: InterceptResponseCompletion) {
        if EndpointLogger.interceptAndDisplayRequest == true {
            dispatch_async(dispatch_get_main_queue()) {
                let viewController = EndpointLoggerInterceptedViewController()
                viewController.response = response
                viewController.responseCompletion = completion
                let navController = UINavigationController(rootViewController: viewController)
                defaultManager.loggerWindow.rootViewController = navController
                defaultManager.loggerWindow.makeKeyAndVisible()
            }
        }
    }

    internal static func dismiss() {
        EndpointLogger.keyWindow?.makeKeyAndVisible()
    }
}
