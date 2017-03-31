//
//  EndpointProtocol.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 7/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import Foundation

//private var bodyValues = [ String : NSData]()

@objc internal class EndpointProtocol: NSURLProtocol, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {

    private static let magicFunUniqueKey = NSUUID().UUIDString

    private var dataTask: NSURLSessionTask?
    private var urlResponse: NSURLResponse?
    private var receivedData: NSMutableData?
    private var newRequest: NSMutableURLRequest?

    private var fullResponse = EndpointResponse()

    private lazy var defaultSession: NSURLSession = {
        let defaultConfigObj = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: defaultConfigObj, delegate: self, delegateQueue: nil)
    }()

    override internal class func canInitWithRequest(request: NSURLRequest) -> Bool {
        guard NSURLProtocol.propertyForKey(magicFunUniqueKey, inRequest: request) == nil else { return false }
        guard let endpoints = EndpointLogger.monitoredEndpoints else { return false }
        guard let urlString = request.URL?.absoluteString else { return false }

        let monitoredURLs = endpoints.flatMap{$0.url?.absoluteString}
        let shouldMonitor = monitoredURLs.contains{urlString.containsString($0)}

        if let method = request.HTTPMethod where shouldMonitor == true {
            EndpointLogger.log(title: "Can init with: \(method)", message: request.URL?.absoluteString)
        }

        return shouldMonitor
    }

    override internal class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }

    override internal func startLoading() {

        EndpointLogger.presentWindow(forRequest: self.request) { [weak self] updatedRequest in

            let newRequest = updatedRequest ?? self?.request.mutableCopy() as! NSMutableURLRequest

            NSURLProtocol.setProperty("true?", forKey: EndpointProtocol.magicFunUniqueKey, inRequest: newRequest)

            self?.newRequest = newRequest

            if let stream = self?.request.HTTPBodyStream {
                stream.open()
                if stream.hasBytesAvailable == true {
                    let data: NSMutableData = NSMutableData()

                    var buffer = [UInt8](count: 8, repeatedValue: 0)
                    var result: Int = stream.read(&buffer, maxLength: buffer.count)
                    repeat {
                        data.appendBytes(buffer, length: 8)
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

            let bodyData = self?.request.HTTPBody

            EndpointLogger.log(title: "Started loading with body: ", message: bodyData)

            self?.dataTask = self?.defaultSession.dataTaskWithRequest(newRequest)
            self?.dataTask?.resume()
        }
    }

    override internal func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask = nil
        self.receivedData = nil
        self.urlResponse = nil

        /*
         if let newRequest = newRequest {
         let keyRequest = "\(newRequest.hashValue ?? 0)"
         bodyValues.removeValueForKey(keyRequest)
         }
         */
    }

    // MARK: NSURLSessionDataDelegate

    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask,
                             didReceiveResponse response: NSURLResponse,
                                                completionHandler: (NSURLSessionResponseDisposition) -> Void) {

        self.fullResponse.response = response

        EndpointLogger.log(title: "Did receieve response: ", message: response)

        self.client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)

        self.urlResponse = response
        self.receivedData = NSMutableData()

        completionHandler(.Allow)
    }

    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.fullResponse.data = data

        EndpointLogger.log(title: "Did receieve data: ", message: data)
        EndpointLogger.presentWindow(forResponse: self.fullResponse) {
            self.client?.URLProtocol(self, didLoadData: data)
            self.receivedData?.appendData(data)
        }
    }

    internal func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
            completionHandler(.UseCredential,credential);
        }
        completionHandler(.PerformDefaultHandling, nil)
    }

    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(.UseCredential, nil)
    }

    // MARK: NSURLSessionTaskDelegate

    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        self.fullResponse.error = error

        EndpointLogger.log(title: "Did complete with error: ", message: error?.localizedDescription)
        EndpointLogger.presentWindow(forResponse: self.fullResponse) {
            if error != nil && error!.code != NSURLErrorCancelled {
                self.client?.URLProtocol(self, didFailWithError: error!)
            } else {
                self.client?.URLProtocolDidFinishLoading(self)
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
