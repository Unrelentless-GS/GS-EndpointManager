//
//  EndpointSaveManager.swift
//  EndpointManager
//
//  Created by Pavel Boryseiko on 6/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

private let EndpointManagerSaveKey = "GSEndpointManagerSaveKey"
private let EndpointManagerSaveSelectedKey = "GSEndpointManagerSaveSelectedKey"

/// Used to manage all the saving/loading
internal class EndpointDataManager {

    static func saveEndpoints() {
        if let endpoints = EndpointManager.endpoints {
            let encodedEndpoints = NSKeyedArchiver.archivedDataWithRootObject(endpoints)
            NSUserDefaults.standardUserDefaults().setObject(encodedEndpoints, forKey: EndpointManagerSaveKey)
        }

        if let selectedEndpoint = EndpointManager.selectedEndpoint {
            let encodedSelectedEndpoint = NSKeyedArchiver.archivedDataWithRootObject(selectedEndpoint)
            NSUserDefaults.standardUserDefaults().setObject(encodedSelectedEndpoint, forKey: EndpointManagerSaveSelectedKey)
        }
    }

    static func loadEndpoints() -> [Endpoint]? {
        guard let endpointsData = NSUserDefaults.standardUserDefaults().objectForKey(EndpointManagerSaveKey) as? NSData else { return nil }
        let endpoints = NSKeyedUnarchiver.unarchiveObjectWithData(endpointsData) as? [Endpoint]
        return endpoints
    }

    static func loadSelectedEndpoint() -> Endpoint? {
        guard let selectedEndpointData = NSUserDefaults.standardUserDefaults().objectForKey(EndpointManagerSaveSelectedKey) as? NSData else { return nil }
        let endpoint = NSKeyedUnarchiver.unarchiveObjectWithData(selectedEndpointData) as? Endpoint
        return endpoint
    }
}
