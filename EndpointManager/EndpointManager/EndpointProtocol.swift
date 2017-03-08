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

    override internal class func canInitWithRequest(request: NSURLRequest) -> Bool {
        guard let endpoints = EndpointLogger.monitoredEndpoints else { return false }
        guard let urlString = request.URL?.absoluteString else { return false }

        EndpointLogger.log(title: "Can init with:", message: request)

        let monitoredURLs = endpoints.flatMap{$0.url?.absoluteString}
        let shouldMonitor = monitoredURLs.contains{urlString.containsString($0)}

        return shouldMonitor
    }

    override internal class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }

    override internal func startLoading() {

        let newRequest = self.request.mutableCopy() as! NSMutableURLRequest

        let defaultConfigObj = NSURLSessionConfiguration.defaultSessionConfiguration()
        let defaultSession = NSURLSession(configuration: defaultConfigObj, delegate: self, delegateQueue: nil)

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
        EndpointLogger.log(title: "Received response: ", message: response)

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

    // MARK: NSURLSessionTaskDelegate

    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {

        EndpointLogger.log(title: "Completed with error: ", message: error?.localizedDescription)

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
