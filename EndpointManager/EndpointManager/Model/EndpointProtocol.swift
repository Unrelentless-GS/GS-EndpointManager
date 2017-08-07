//
//  EndpointProtocol.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 7/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import Foundation
import ObjectiveC.runtime

internal extension URLSession {

    @objc class func swizzledInit(_ configuration: URLSessionConfiguration) -> URLSession {
        let swizzledConfig = configuration
        var classes = swizzledConfig.protocolClasses
        classes?.insert(EndpointProtocol.self, at: 0)
        swizzledConfig.protocolClasses = classes

        return URLSession.swizzledInit(swizzledConfig)
    }

    @objc class func endpointManagerNSURLSessionSwizzle() {
        let selector = #selector(URLSession.init(configuration:))

        let originalInit = class_getClassMethod(self, selector)
        let swizzledInit = class_getClassMethod(self, #selector(swizzledInit(_:)))

        method_exchangeImplementations(originalInit, swizzledInit)
    }
}


//private var bodyValues = [ String : NSData]()

@objc internal class EndpointProtocol: URLProtocol, URLSessionDataDelegate, URLSessionTaskDelegate {

    fileprivate static let magicFunUniqueKey = UUID().uuidString

    fileprivate var dataTask: URLSessionTask?
    fileprivate var urlResponse: URLResponse?
    fileprivate var newRequest: NSMutableURLRequest?

    fileprivate var fullResponse = EndpointResponse()

    fileprivate lazy var defaultSession: Foundation.URLSession = {
        let defaultConfigObj = URLSessionConfiguration.default
        return Foundation.URLSession(configuration: defaultConfigObj, delegate: self, delegateQueue: nil)
    }()

    override internal class func canInit(with request: URLRequest) -> Bool {
        guard URLProtocol.property(forKey: magicFunUniqueKey, in: request) == nil else { return false }
        guard let endpoints = EndpointLogger.monitoredEndpoints else { return false }
        guard let urlString = request.url?.absoluteString else { return false }

        let monitoredURLs = endpoints.flatMap{$0.url?.absoluteString}
        let shouldMonitor = monitoredURLs.contains{urlString.contains($0)}

        if let method = request.httpMethod, shouldMonitor == true {
            EndpointLogger.log(title: "Can init with: \(method)", message: request.url?.absoluteString as AnyObject)
        }

        return shouldMonitor
    }

    override internal class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override internal func startLoading() {

        let semaphore = DispatchSemaphore(value: 0)

        EndpointLogger.presentWindow(forRequest: self.request) { [weak self] updatedRequest in

            let newRequest = updatedRequest ?? (self?.request as! NSMutableURLRequest)

            URLProtocol.setProperty("true?", forKey: EndpointProtocol.magicFunUniqueKey, in: newRequest)

            self?.newRequest = newRequest

            if let stream = self?.request.httpBodyStream {
                stream.open()
                if stream.hasBytesAvailable == true {
                    let data: NSMutableData = NSMutableData()

                    var buffer = [UInt8](repeating: 0, count: 8)
                    var result: Int = stream.read(&buffer, maxLength: buffer.count)
                    repeat {
                        data.append(buffer, length: 8)
                        result = stream.read(&buffer, maxLength: buffer.count)
                    } while result != 0

                    EndpointLogger.log(title: "Started loading with body stream: ", message: data)
                }
            }

            /* Workaround might not be required anymore, disabling workaround
             let keyRequest = "\(newRequest.hashValue ?? 0)"
             var bodyData: NSData? = nil
             if let body = bodyValues["\(keyRequest)"] {
             bodyData = body
             } else {
             bodyData = request.HTTPBody
             }
             */

            let bodyData = self?.request.httpBody

            EndpointLogger.log(title: "Started loading with body: ", message: bodyData)

            self?.dataTask = self?.defaultSession.dataTask(with: (newRequest as URLRequest))
            self?.dataTask?.resume()

            semaphore.signal()
        }

        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }

    override internal func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask = nil
        self.urlResponse = nil

        /*
         if let newRequest = newRequest {
         let keyRequest = "\(newRequest.hashValue ?? 0)"
         bodyValues.removeValueForKey(keyRequest)
         }
         */
    }

    // MARK: NSURLSessionDataDelegate

    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                             didReceive response: URLResponse,
                                                completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {

        self.fullResponse.response = response

        EndpointLogger.log(title: "Did receieve response: ", message: response)

        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        self.urlResponse = response

        completionHandler(.allow)
    }

    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.fullResponse.data = data

        EndpointLogger.log(title: "Did receieve data: ", message: data as AnyObject)
        EndpointLogger.presentWindow(forResponse: self.fullResponse) {
            self.client?.urlProtocol(self, didLoad: data)
        }
    }

    internal func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential,credential);
        }
        completionHandler(.performDefaultHandling, nil)
    }

    internal func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, nil)
    }

    // MARK: NSURLSessionTaskDelegate

    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error else { return }

        let nsError = error as NSError

        self.fullResponse.error = nsError

        EndpointLogger.log(title: "Did complete with error: ", message: error.localizedDescription as AnyObject)
        EndpointLogger.presentWindow(forResponse: self.fullResponse) {
            if nsError.code != NSURLErrorCancelled {
                self.client?.urlProtocol(self, didFailWithError: nsError)
            } else {
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }
    }
}

/*
 /* This is a workaround to http://openradar.appspot.com/15993891
 * Swizzle the setHTTPBody: to store the http body in the internal dictionary to be retrieved later.
 */
 import ObjectiveC.runtime
 public extension NSMutableURLRequest {

 private var endpointManagerShouldStoreBody: Bool {
 get {
 guard let value = objc_getAssociatedObject(self, "endpointManagerShouldStoreBody") as? Bool else {
 return false
 }
 return value
 }
 set {
 objc_setAssociatedObject(self, "endpointManagerShouldStoreBody", endpointManagerShouldStoreBody, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
 }
 }

 @objc func endpointManagerHackBody(body: NSData?) {
 defer {
 endpointManagerHackBody(body)
 }
 guard endpointManagerShouldStoreBody == true else {
 return
 }
 let keyRequest = "\(hashValue)"
 guard let body = body where bodyValues[keyRequest] == nil else {
 return
 }
 bodyValues[keyRequest] = body as NSData
 }
 
 @objc class func endpointManagerHTTPBodySwizzle() {
 
 let originalSelector = Selector("setHTTPBody:")
 
 let setHttpBody = class_getInstanceMethod(self, originalSelector)
 let httpBodyHackSetHttpBody = class_getInstanceMethod(self, #selector(self.endpointManagerHackBody(_:)))
 method_exchangeImplementations(setHttpBody, httpBodyHackSetHttpBody)
 }
 }
 */
