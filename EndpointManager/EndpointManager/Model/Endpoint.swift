//
//  Endpoint.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 3/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

/// An Endpoint object containing a name and url
@objc public class Endpoint: NSObject, NSCoding {

    /// The name of the Endpoint
    public var name: String?

    // The url of the endpoint
    public var url: NSURL?

    /**
     Initialize the endpoint object

     - parameter name: the name of the endpoint
     - parameter url:  the url of the endpoint

     - returns: initialized endpoint
     */
    public init(name: String?, url: NSURL?) {
        self.name = name
        self.url = url
    }

    public required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as? String
        url = aDecoder.decodeObjectForKey("url") as? NSURL
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(url, forKey: "url")
    }
}
