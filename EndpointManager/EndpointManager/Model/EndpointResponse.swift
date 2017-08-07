//
//  EndpointResponse.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 31/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

internal struct EndpointResponse {
    var response: URLResponse?
    var data: Data?
    var error: Error?
}

internal struct QueuedResponse {
    var reponse: EndpointResponse
    var completion: InterceptResponseCompletion
}

internal struct QueuedRequest {
    var request: URLRequest
    var completion: InterceptRequestCompletion
}
