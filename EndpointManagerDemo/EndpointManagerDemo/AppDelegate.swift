//
//  AppDelegate.swift
//  EndpointManagerDemo
//
//  Created by Pavel Boryseiko on 2/3/17.
//  Copyright © 2017 Pavel Boryseiko. All rights reserved.
//

import UIKit
import EndpointManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        let endpoint1 = Endpoint(name: "Instance 0", url: URL(string: "https://google.com.au"))
        let endpoint2 = Endpoint(name: "Instance 1", url: URL(string: "https://instance1.com"))
        let endpoint3 = Endpoint(name: "Instance 2", url: URL(string: "https://instance2.com"))

        EndpointManager.populate([endpoint1, endpoint2, endpoint3])
        EndpointLogger.monitor([endpoint1, endpoint2, endpoint3])
        EndpointLogger.logToConsole = false
        EndpointLogger.interceptAndDisplayRequest = true
        EndpointLogger.interceptAndDisplayResponse = true
        EndpointLogger.keyWindow = window

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        vc!.view.frame = window!.bounds
        window?.rootViewController = vc

        window?.makeKeyAndVisible()

        return true
    }
}

