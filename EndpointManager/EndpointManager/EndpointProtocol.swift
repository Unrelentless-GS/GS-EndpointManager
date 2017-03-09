//
//  EndpointProtocol.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 7/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

@objc internal class EndpointProtocol: NSURLProtocol, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {

    private static let magicFunUniqueKey = NSUUID().UUIDString

    private var dataTask: NSURLSessionTask?
    private var urlResponse: NSURLResponse?
    private var receivedData: NSMutableData?
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
            EndpointLogger.log(title: "Can init with: \(request.HTTPMethod)", message: request.URL?.absoluteString)
        }

        return shouldMonitor
    }

    override internal class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }

    override internal func startLoading() {

        let newRequest = self.request.mutableCopy() as! NSMutableURLRequest

        NSURLProtocol.setProperty("true?", forKey: EndpointProtocol.magicFunUniqueKey, inRequest: newRequest)

        EndpointLogger.log(title: "Started loading with body: ", message: request.HTTPBody)

        self.dataTask = defaultSession.dataTaskWithRequest(newRequest)
        self.dataTask?.resume()
    }

    override internal func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask = nil
        self.receivedData = nil
        self.urlResponse = nil
    }

    // MARK: NSURLSessionDataDelegate

    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask,
                             didReceiveResponse response: NSURLResponse,
                                                completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        EndpointLogger.log(title: "Did receieve response: ", message: response)

        self.client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)

        self.urlResponse = response
        self.receivedData = NSMutableData()

        completionHandler(.Allow)
    }

    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        EndpointLogger.log(title: "Did receieve data: ", message: data)

        self.client?.URLProtocol(self, didLoadData: data)
        self.receivedData?.appendData(data)
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

        EndpointLogger.log(title: "Did complete with error: ", message: error?.localizedDescription)

        if error != nil && error!.code != NSURLErrorCancelled {
            self.client?.URLProtocol(self, didFailWithError: error!)
        } else {
            doStuff()
            self.client?.URLProtocolDidFinishLoading(self)
        }
    }

    // MARK: Private
    private func doStuff () {
        let timeStamp = NSDate()
        let urlString = self.request.URL?.absoluteString
        //        let dataString = NSString(data: self.receivedData!, encoding: NSUTF8StringEncoding) as NSString?
        print("TimeStamp:\(timeStamp)\nURL: \(urlString)\n\n")
    }
}
