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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        let endpoint1 = Endpoint(name: "Instance 0", url: NSURL(string: "https://google.com.au"))
        let endpoint2 = Endpoint(name: "Instance 1", url: NSURL(string: "https://instance1.com"))
        let endpoint3 = Endpoint(name: "Instance 2", url: NSURL(string: "https://instance2.com"))

        EndpointManager.populate([endpoint1, endpoint2, endpoint3])
        EndpointLogger.monitor([endpoint1, endpoint2, endpoint3], forSession: NSURLSession.sharedSession())
        EndpointLogger.logToConsole = true
        EndpointLogger.interceptAndDisplayRequest = true
        EndpointLogger.keyWindow = window

        NSURLProtocol.registerClass(EndpointLogger.endpointProtocol)

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        vc!.view.frame = window!.bounds
        window?.rootViewController = vc

        window?.makeKeyAndVisible()

        return true
    }
}

