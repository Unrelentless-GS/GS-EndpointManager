//
//  EndpointLogger.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 7/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

internal typealias InterceptRequestCompletion = (NSMutableURLRequest?) -> ()
internal typealias InterceptResponseCompletion = () -> ()


/// Your one point of contact with the logger
@objc public class EndpointLogger: NSObject {

    /// Whether you want the logger to print to console
    public static var logToConsole: Bool = false

    /// Whether you want to intercept and display all requests
    public static var interceptAndDisplayRequest: Bool = false

    /// Whether you want to intercept and display all responses
    public static var interceptAndDisplayResponse: Bool = false

    /// A reference to the keyWindow. Pass in your working keyWindow otherwise, intercepting and presenting **will not work**
    public static weak var keyWindow: UIWindow?

    internal static var defaultManager = EndpointLogger()
    internal var monitoredEndpoints = [Endpoint]?()

    internal static var monitoredEndpoints: [Endpoint]? {
        get {
            return defaultManager.monitoredEndpoints
        }
    }

    private lazy var loggerWindow: UIWindow = {
        let frame = UIApplication.sharedApplication().keyWindow?.frame
        return UIWindow(frame: frame!)
    }()

    private override init() {
        NSURLProtocol.registerClass(EndpointProtocol.self)
        NSURLSession.endpointManagerNSURLSessionSwizzle()
        /* NSMutableURLRequest.endpointManagerHTTPBodySwizzle() */
    }

    /**
     Monitor endpoints on a specific url session
     - parameter endpoints: an array of endpoints to monitor.
     Set these to the endpoint you want monitored.
     Technically, only the url is used.

     The url to be monitored will be matched exactly:
     ie. if you want to monitor for example:
     ```
     https://someURL.io/first
     https://someURL.io/second
     ```
     passing in:
     **`https://someURL.io`** will match everything with the base URL of **`https://someURL.io`**
     including both:
     ```
     https://someURL.io/first
     https://someURL.io/second
     ```
     but **`https://someURL.io/first`** will only match the first as well as any other path under the first:
     ```
     https://someURL.io/first
     https://someURL.io/first/third
     ```
     and will not match
     ```
     https://someURL.io/second
     ```
     */
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
        } else {
            completion(nil)
        }
    }


    internal static func presentWindow(forResponse response: EndpointResponse, completion: InterceptResponseCompletion) {
        if EndpointLogger.interceptAndDisplayResponse == true {
            dispatch_async(dispatch_get_main_queue()) {
                let viewController = EndpointLoggerInterceptedViewController()
                viewController.response = response
                viewController.responseCompletion = completion
                let navController = UINavigationController(rootViewController: viewController)
                defaultManager.loggerWindow.rootViewController = navController
                defaultManager.loggerWindow.makeKeyAndVisible()
            }
        } else {
            completion()
        }
    }

    internal static func dismiss() {
        EndpointLogger.keyWindow?.makeKeyAndVisible()
    }
}
