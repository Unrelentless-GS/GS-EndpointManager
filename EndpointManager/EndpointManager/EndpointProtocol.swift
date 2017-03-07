//
//  EndpointProtocol.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 7/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

@objc internal class EndpointProtocol: NSURLProtocol, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {

    private var dataTask: NSURLSessionDataTask?
    private var urlResponse: NSURLResponse?
    private var receivedData: NSMutableData?

    override public class func canInitWithRequest(request: NSURLRequest) -> Bool {
        guard let endpoints = EndpointLogger.monitoredEndpoints else { return false }
        guard let urlString = request.URL?.absoluteString else { return false }

        let monitoredURLs = endpoints.flatMap{$0.url?.absoluteString}
        let shouldMonitor = monitoredURLs.contains{urlString.containsString($0)}

        return shouldMonitor
    }

    override public class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }

    override public func startLoading() {

        let newRequest = self.request.mutableCopy() as! NSMutableURLRequest

        let defaultConfigObj = NSURLSessionConfiguration.defaultSessionConfiguration()
        let defaultSession = NSURLSession(configuration: defaultConfigObj, delegate: self, delegateQueue: nil)

        self.dataTask = defaultSession.dataTaskWithRequest(newRequest)
        self.dataTask!.resume()
    }

    override public func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask = nil
        self.receivedData = nil
        self.urlResponse = nil
    }


    // MARK: NSURLSessionDataDelegate

    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask,
                           didReceiveResponse response: NSURLResponse,
                                              completionHandler: (NSURLSessionResponseDisposition) -> Void) {

        self.client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)

        self.urlResponse = response
        self.receivedData = NSMutableData()

        completionHandler(.Allow)
    }

    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.client?.URLProtocol(self, didLoadData: data)
        self.receivedData?.appendData(data)
    }

    // MARK: NSURLSessionTaskDelegate

    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil && error!.code != NSURLErrorCancelled {
            self.client?.URLProtocol(self, didFailWithError: error!)
        } else {
            doStuff()
            self.client?.URLProtocolDidFinishLoading(self)
        }
    }

    // MARK: Private
    func doStuff () {
        let timeStamp = NSDate()
        let urlString = self.request.URL?.absoluteString
//        let dataString = NSString(data: self.receivedData!, encoding: NSUTF8StringEncoding) as NSString?
        print("TimeStamp:\(timeStamp)\nURL: \(urlString)\n\n")
    }
}