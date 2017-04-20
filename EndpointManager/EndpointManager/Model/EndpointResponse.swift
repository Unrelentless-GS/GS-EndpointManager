//
//  EndpointResponse.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 31/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

internal struct EndpointResponse {
    var response: NSURLResponse?
    var data: NSData?
    var error: NSError?
}

internal struct QueuedResponse {
    var reponse: EndpointResponse
    var completion: InterceptResponseCompletion
}

internal struct QueuedRequest {
    var request: NSURLRequest
    var completion: InterceptRequestCompletion
}
