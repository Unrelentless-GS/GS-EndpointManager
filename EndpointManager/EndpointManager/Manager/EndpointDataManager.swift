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
            let encodedEndpoints = NSKeyedArchiver.archivedData(withRootObject: endpoints)
            UserDefaults.standard.set(encodedEndpoints, forKey: EndpointManagerSaveKey)
        }

        if let selectedEndpoint = EndpointManager.selectedEndpoint {
            let encodedSelectedEndpoint = NSKeyedArchiver.archivedData(withRootObject: selectedEndpoint)
            UserDefaults.standard.set(encodedSelectedEndpoint, forKey: EndpointManagerSaveSelectedKey)
        }
    }

    static func loadEndpoints() -> [Endpoint]? {
        guard let endpointsData = UserDefaults.standard.object(forKey: EndpointManagerSaveKey) as? Data else { return nil }
        let endpoints = NSKeyedUnarchiver.unarchiveObject(with: endpointsData) as? [Endpoint]
        return endpoints
    }

    static func loadSelectedEndpoint() -> Endpoint? {
        guard let selectedEndpointData = UserDefaults.standard.object(forKey: EndpointManagerSaveSelectedKey) as? Data else { return nil }
        let endpoint = NSKeyedUnarchiver.unarchiveObject(with: selectedEndpointData) as? Endpoint
        return endpoint
    }
}
