# GS-EndpointManager
Managing endpoints since 2017.


- [Description](#-description)
- [Installation](#-installation)
- [Usage](#-usage)

##📃 Description
Endpoint Manager is used to change any endpoints or constants during runtime.
Helpful with network managers where you have multiple environments.

##💾 Installation

### Carthage

To integrate GS-EndpointManager into your Xcode project using Carthage, specify it in your `Cartfile`:

```
github "Unrelentless-GS/GS-EndpointManager"
```

Run `carthage update` to build the framework and drag the built `EndpointManager.framework` into your Xcode project.

##🦄 Usage
Create endpoints using:
```
let endpoint1 = Endpoint(name: "Instance 0", url: NSURL(string: "https://instance0"))
let endpoint2 = Endpoint(name: "Instance 1", url: NSURL(string: "https://instance1"))
let endpoint3 = Endpoint(name: "Instance 2", url: NSURL(string: "https://instance2"))
```

Add them to the Endpoint Manager using:
```
 EndpointManager.endpoints = [endpoint1, endpoint2, endpoint3]
```

To present the endpoint manager, call:
```
EndpointManager.presentEndpointManagerFrom(UIApplication.sharedApplication().keyWindow!)
```
_note:_ make sure to pass in your current working window to overlay the Endpoint Manager on top of.


You can also observe the `EndpointManager.EndpointChangedNotification` notification to check for changes to the selected endpoint.
