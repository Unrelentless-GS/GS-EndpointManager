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
@objc open class EndpointLogger: NSObject {

    /// Whether you want the logger to print to console
    open static var logToConsole: Bool = false

    /// Whether you want to intercept and display all requests
    open static var interceptAndDisplayRequest: Bool = false

    /// Whether you want to intercept and display all responses
    open static var interceptAndDisplayResponse: Bool = false

    /// A reference to the keyWindow. Pass in your working keyWindow otherwise, intercepting and presenting **will not work**
    open static weak var keyWindow: UIWindow?

    internal static var defaultManager = EndpointLogger()
    internal var monitoredEndpoints = [Endpoint]()

    internal static var monitoredEndpoints: [Endpoint]? {
        get {
            return defaultManager.monitoredEndpoints
        }
    }

    fileprivate lazy var loggerWindow: UIWindow = {
        let frame = UIApplication.shared.keyWindow?.frame
        return UIWindow(frame: frame!)
    }()

    fileprivate var queuedRequests = [QueuedRequest]() // { didSet { print("Request: \(queuedRequests.count)") } }
    fileprivate var queuedResponses = [QueuedResponse]() // { didSet { print("Response: \(queuedResponses.count)") } }

    fileprivate override init() {
        URLProtocol.registerClass(EndpointProtocol.self)
        URLSession.endpointManagerNSURLSessionSwizzle()
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
    open static func monitor(_ endpoints: [Endpoint]) {
        defaultManager.monitoredEndpoints = endpoints
    }

    internal static func log(title: String, message: Any?) {
        guard var message = message else { return }
        guard logToConsole == true else { return }
        if let data = message as? Data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if json is [AnyObject] {
                    message = "\(json as! [AnyObject])\n\n" as AnyObject
                } else {
                    message = "\(json as! [String: AnyObject])\n\n" as AnyObject
                }
            } catch {
                if let dataString = String(data: data, encoding: String.Encoding.utf8) {
                    message = dataString as AnyObject
                }
            }
        }

        print("****************************")
        print("ENDPOINT LOGGER")
        print(title)
        print(message)
        print("****************************")
    }

    internal static func presentWindow(forRequest request: URLRequest, completion: @escaping InterceptRequestCompletion) {
        if EndpointLogger.interceptAndDisplayRequest == true {
            let queuedRequest = QueuedRequest(request: request, completion: completion)
            defaultManager.queuedRequests.append(queuedRequest)
            let _ = defaultManager.tryPresentingSomething()
        } else {
            completion(nil)
        }
    }

    internal static func presentWindow(forResponse response: EndpointResponse, completion: @escaping InterceptResponseCompletion) {
        if EndpointLogger.interceptAndDisplayResponse == true {
            let queuedResponse = QueuedResponse(reponse: response, completion: completion)
            defaultManager.queuedResponses.append(queuedResponse)
            let _ = defaultManager.tryPresentingSomething()
        } else {
            completion()
        }
    }

    fileprivate func tryPresentingSomething() -> Bool {
        if self.queuedResponses.count == 0 && self.queuedRequests.count == 0 { return false }

        DispatchQueue.main.async {
            let `self` = self

            let viewController = EndpointLoggerDataViewController()
//            let viewController = EndpointLoggerInterceptedViewController()
//
//            if self.queuedRequests.count > 0 {
//                viewController.request = self.queuedRequests.first!.request
//                viewController.requestCompletion = self.queuedRequests.first!.completion
//                viewController.type = .request
//            } else if self.queuedResponses.count > 0 {
//                viewController.response = self.queuedResponses.first!.reponse
//                viewController.responseCompletion = self.queuedResponses.first!.completion
//                viewController.type = .response
//            }

            let navController = UINavigationController(rootViewController: viewController)
            self.loggerWindow.rootViewController = navController
            self.loggerWindow.makeKeyAndVisible()
        }

        return true
    }

    internal static func dismiss(fromType type: NetworkMethodType) {
        if type == .request {
            defaultManager.queuedRequests.removeFirst()
        } else {
            defaultManager.queuedResponses.removeFirst()
        }

        if defaultManager.tryPresentingSomething() == false {
            EndpointLogger.keyWindow?.makeKeyAndVisible()
        }
    }
}
