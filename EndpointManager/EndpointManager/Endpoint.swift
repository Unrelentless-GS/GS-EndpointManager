//
//  Endpoint.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 3/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

/// An Endpoint object containing a name and url
@objc public class Endpoint: NSObject {

    /// The name of the Endpoint
    public var name: String?

    // The url of the endpoint
    public var url: NSURL?

    public init(name: String?, url: NSURL?) {
        self.name = name
        self.url = url
    }
}
