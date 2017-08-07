//
//  Endpoint.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 3/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

/// An Endpoint object containing a name and url
@objc open class Endpoint: NSObject, NSCoding {

    /// The name of the Endpoint
    open var name: String?

    // The url of the endpoint
    open var url: URL?

    /**
     Initialize the endpoint object

     - parameter name: the name of the endpoint
     - parameter url:  the url of the endpoint

     - returns: initialized endpoint
     */
    public init(name: String?, url: URL?) {
        self.name = name
        self.url = url
    }

    public required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String
        url = aDecoder.decodeObject(forKey: "url") as? URL
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(url, forKey: "url")
    }
}
