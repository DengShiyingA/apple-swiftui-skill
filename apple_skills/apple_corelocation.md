# Apple CORELOCATION Skill


## Configuring your app to use location services
> https://developer.apple.com/documentation/corelocation/configuring-your-app-to-use-location-services

### 
#### 
If a service isn’t available, disable any app-specific features that rely on that service. Disabling features in advance is a more reliable approach than using a service and responding to errors.
The  class provides methods to determine the availability of each service. Call the appropriate method for a given service immediately before you try to use that service. For example, an app that offers compass heading information might call the  method before starting the service. If your app uses multiple services, call the appropriate method for each service.
```swift
// Check if heading data is available.
if CLLocationManager.headingAvailable() {
    locationManager.startUpdatingHeading()
} else {
    // Disable compass features.
}
```

#### 
Location updates and authorization status changes arrive in an asynchronous fashion. Check for both the presence of a location update and authorization status changes within the loop. The loop doesn’t terminate unless you explicitly use `return`, `break`, or throw an exception.
```swift
// Obtain an asynchronous stream of updates.
let stream = CLLocationUpdate.liveUpdates()

// Iterate over the stream and handle incoming updates.
for try await update in stream {
     if update.location != nil {
          // Process the location.
     } else if update.authorizationDenied {
          // Process the authorization denied state change.
     } else {
          // Process other state changes.
     }
}
```

#### 
#### 

## Converting a user’s location to a descriptive placemark
> https://developer.apple.com/documentation/corelocation/converting-a-user-s-location-to-a-descriptive-placemark

### 
#### 
#### 
> **important:**  Geocoding requests are rate-limited for each app. Issue new geocoding requests only when the user has moved a significant distance and after a reasonable amount of time has passed.
```swift
func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let newLocation = userLocation.location else { return }
        
        let currentTime = Date()
        let lastLocation = self.currentLocation
        self.currentLocation = newLocation
        
        // Only get new placemark information if you don't have a previous location,
        // if the user has moved a meaningful distance from the previous location, such as 1000 meters,
        // and if it's been 60 seconds since the last geocode request.
        if let lastLocation = lastLocation,
            newLocation.distance(from: lastLocation) <= 1000,
            let lastTime = lastGeocodeTime,
            currentTime.timeIntervalSince(lastTime) < 60 {
            return
        }
        
        // Convert the user's location to a user-friendly place name by reverse geocoding the location.
        lastGeocodeTime = currentTime
        geocoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
            guard error == nil else {
                self.handleError(error)
                return
            }
            
            // Most geocoding requests contain only one result.
            if let firstPlacemark = placemarks?.first {
                self.mostRecentPlacemark = firstPlacemark
                self.currentCity = firstPlacemark.locality
            }
        }
    }
```

### 
#### 

## Converting between coordinates and user-friendly place names
> https://developer.apple.com/documentation/corelocation/converting-between-coordinates-and-user-friendly-place-names

### 
#### 
Listing 1 shows how to obtain placemark information for the last location reported by the  object. Because calls to the geocoder object are asynchronous, the caller of this method passes in a completion handler, which is executed with the results.
Listing 1. Reverse geocoding a coordinate
```swift
func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                -> Void ) {
    // Use the last reported location.
    if let lastLocation = self.locationManager.location {
        let geocoder = CLGeocoder()
            
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(lastLocation, 
                    completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else {
	         // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
    }
    else {
        // No location was available.
        completionHandler(nil)
    }
}
```

#### 
Listing 2 shows how you might obtain a coordinate value from a user-provided string. The example calls the provided completion handler with only the first result. If the string does not correspond to any location, the method calls the completion handler with an error and an invalid coordinate.
Listing 2. Getting a coordinate from an address string
```swift
func getCoordinate( addressString : String, 
        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(addressString) { (placemarks, error) in
        if error == nil {
            if let placemark = placemarks?[0] {
                let location = placemark.location!
                    
                completionHandler(location.coordinate, nil)
                return
            }
        }
            
        completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
    }
}
```


## Determining the proximity to an iBeacon device
> https://developer.apple.com/documentation/corelocation/determining-the-proximity-to-an-ibeacon-device

### 
#### 
#### 
Listing 1 shows an example of how to set up region monitoring for a company’s beacons. Because you typically define a UUID for your company once and do not change it later, the example includes a hard-coded version of that value. Prior to calling this method, you must have created a  object and assigned a delegate to it.
Listing 1. Setting up region monitoring for beacons
```swift
func monitorBeacons() {
    if CLLocationManager.isMonitoringAvailable(for: 
                  CLBeaconRegion.self) {
        // Match all beacons with the specified UUID
        let proximityUUID = UUID(uuidString: 
               "39ED98FF-2900-441A-802F-9C398FC199D2")
        let beaconID = "com.example.myBeaconRegion"
            
        // Create the region and begin monitoring it.
        let region = CLBeaconRegion(proximityUUID: proximityUUID!,
               identifier: beaconID)
        self.locationManager.startMonitoring(for: region)
    }
}
```

#### 
Listing 2 shows an implementation of this delegate method that turns on ranging for a detected beacon. The method also adds the beacon to an internal array so that the app can stop and restart ranging at any time. For example, you might stop ranging when your app is in the background to save power.
Listing 2. Ranging for beacons
```swift
func locationManager(_ manager: CLLocationManager, 
            didEnterRegion region: CLRegion) {
    if region is CLBeaconRegion {
        // Start ranging only if the devices supports this service.
        if CLLocationManager.isRangingAvailable() {
            manager.startRangingBeacons(in: region as! CLBeaconRegion)

            // Store the beacon so that ranging can be stopped on demand.
            beaconsToRange.append(region as! CLBeaconRegion)        
        }
    }
}
```

When ranging is active, the location manager object calls the  method of its delegate whenever there is a change to report. Use this method to take action based on the proximity of nearby beacons. Listing 3 shows how a museum app might use the proximity value to display information about the closest exhibit. In this example, the museum uses the major and minor values to identify each exhibit.
Listing 3. Acting on the nearest beacon
```swift
func locationManager(_ manager: CLLocationManager, 
            didRangeBeacons beacons: [CLBeacon], 
            in region: CLBeaconRegion) {
    if beacons.count > 0 {
        let nearestBeacon = beacons.first!
        let major = CLBeaconMajorValue(nearestBeacon.major)
        let minor = CLBeaconMinorValue(nearestBeacon.minor)
            
        switch nearestBeacon.proximity {
        case .near, .immediate:
            // Display information about the relevant exhibit.
            displayInformationAboutExhibit(major: major, minor: minor)
            break
                
        default:
           // Dismiss exhibit information, if it is displayed.
           dismissExhibit(major: major, minor: minor)
           break
           }
        }
    }
```


## Monitoring the user’s proximity to geographic regions
> https://developer.apple.com/documentation/corelocation/monitoring-the-user-s-proximity-to-geographic-regions

### 
#### 
Listing 1 shows how to configure and register a condition centered around a point provided by the caller of the method. The task uses a radius of 200 meters to define the boundaries of the condition, then awaits as  events arrive asynchronously from Core Location.
Listing 1. Monitoring a region around the specified coordinate
```swift
Task {    
     // Create a custom monitor.
     let monitor = await CLMonitor("my_custom_monitor")
     // Register the condition for 200 meters.
     let center = myFirstLocation;
     let condition = CLCircularGeographicCondition(center: center1, radius: 200)
     // Add the condition to the monitor.
     monitor.add(condition, identifier: "stay_within_200_meters")
     // Start monitoring.
     for try await event in monitor.events {
         // Respond to events.
         if event.state == .satisfied {
             // Process the 200 meter condition.
         }
     }
}
```

#### 

## Ranging for Beacons
> https://developer.apple.com/documentation/corelocation/ranging-for-beacons

### 
#### 
Run the sample app on the first iOS device. Select the option to Configure a Beacon. The project hardcodes a default value for the UUID that can be changed in `ConfigureBeaconViewController.swift`.
```swift
let beaconUUID = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")
```

Optionally modify the major and minor value for the beacon, then select the Enabled switch on the configuration screen to start advertising.
`ConfigureBeaconViewController.swift` contains a view controller object that configures the iOS device running this app to act as a beacon.  The `configureBeaconRegion()` method sets up the region and starts advertising itself.
```swift
if peripheralManager.state == .poweredOn {
    peripheralManager.stopAdvertising()
    if enabled {
        let bundleURL = Bundle.main.bundleIdentifier!
        
        // Defines the beacon identity characteristics the device broadcasts.
        let constraint = CLBeaconIdentityConstraint(uuid: beaconUUID!, major: major, minor: minor)
        region = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: bundleURL)
        
        let peripheralData = region.peripheralData(withMeasuredPower: nil) as? [String: Any]
        
        // Start broadcasting the beacon identity characteristics.
        peripheralManager.startAdvertising(peripheralData)
    }
```

#### 
Using a second iOS device, run the sample app and tap Range for Beacons to scan for beacons. Add a UUID to range for by tapping the Add button in the upper corner of the screen. The hardcoded UUID appears by default.
`RangeBeaconViewController.swift` contains a view controller object that ranges a set of beacon regions that the user adds. As in any location-based service, first request authorization. Use a `CLLocationManager` instance to request that authorization, set up the constraint based on the hardcoded UUID, then tell the instance to start monitoring.
```swift
self.locationManager.requestWhenInUseAuthorization()

// Create a new constraint and add it to the dictionary.
let constraint = CLBeaconIdentityConstraint(uuid: uuid)
self.beaconConstraints[constraint] = []

/*
By monitoring for the beacon before ranging, the app is more
energy efficient if the beacon is not immediately observable.
*/
let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuid.uuidString)
self.locationManager.startMonitoring(for: beaconRegion)
```


## Requesting authorization to use location services
> https://developer.apple.com/documentation/corelocation/requesting-authorization-to-use-location-services

### 
#### 
#### 
#### 
Before you start any location services, check your app’s current authorization status and place an authorization request if needed. You can get your app’s current authorization from the  property of your location-manager object. However, a newly configured  object also reports your app’s current authorization status to its delegate’s  method automatically. You might use that method to place an authorization request when the current status is . In the following example, the delegate method enables or disables location features when the status is known and requests authorization when the status is undetermined.
```swift
func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { 
    switch manager.authorizationStatus {
    case .authorizedWhenInUse:  // Location services are available.
        enableLocationFeatures()
        break
        
    case .restricted, .denied:  // Location services currently unavailable.
        disableLocationFeatures()
        break
        
    case .notDetermined:        // Authorization not determined yet.
       manager.requestWhenInUseAuthorization()
        break
        
    default:
        break
    }
}

```


## Supporting live updates in SwiftUI and Mac Catalyst apps
> https://developer.apple.com/documentation/corelocation/supporting-live-updates-in-swiftui-and-mac-catalyst-apps

### 
#### 
2. An `AppDelegate` object that provides the  method that handles resuming background activities on return from background or an app relaunch
3. An `AppDelegate` object in the SwiftUI or Mac Catalyst app’s `@main` structure
3. An `AppDelegate` object in the SwiftUI or Mac Catalyst app’s `@main` structure
In your SwiftUI or Mac Catalyst App, add support for the `AppDelegate` by adding a shared state through an , and a  as an object the app’s `@main` structure maintains, as shown in the following example:
```swift
    import SwiftUI

    // Shared state that manages the `CLLocationManager` and `CLBackgroundActivitySession`.
    @MainActor class LocationsHandler: ObservableObject {
    
        static let shared = LocationsHandler()  // Create a single, shared instance of the object.
        private let manager: CLLocationManager
        private var background: CLBackgroundActivitySession?

        @Published var lastLocation = CLLocation()
        @Published var isStationary = false
        @Published var count = 0
    
        @Published
        var updatesStarted: Bool = UserDefaults.standard.bool(forKey: "liveUpdatesStarted") {
            didSet { UserDefaults.standard.set(updatesStarted, forKey: "liveUpdatesStarted") }
        }
    
        @Published
        var backgroundActivity: Bool = UserDefaults.standard.bool(forKey: "BGActivitySessionStarted") {
            didSet {
                backgroundActivity ? self.background = CLBackgroundActivitySession() : self.background?.invalidate()
                UserDefaults.standard.set(backgroundActivity, forKey: "BGActivitySessionStarted")
            }
        }
    
        private init() {
            self.manager = CLLocationManager()  // Creating a location manager instance is safe to call here in `MainActor`.
        }
    
        func startLocationUpdates() {
            if self.manager.authorizationStatus == .notDetermined {
                self.manager.requestWhenInUseAuthorization()
            }
            self.logger.info("Starting location updates")
            Task() {
                do {
                    self.updatesStarted = true
                    let updates = CLLocationUpdate.liveUpdates()
                    for try await update in updates {
                        if !self.updatesStarted { break }  // End location updates by breaking out of the loop.
                        if let loc = update.location {
                            self.lastLocation = loc
                            self.isStationary = update.isStationary
                            self.count += 1
                            print("Location \(self.count): \(self.lastLocation)")
                        }
                    }
                } catch {
                    print("Could not start location updates")
                }
                return
            }
        }
    
        func stopLocationUpdates() {
            print("Stopping location updates")
            self.updatesStarted = false
            self.updatesStarted = false
        } 
    }
```

```
Next, create an instance of a UIKit `AppDelegate` class that conforms to SwiftUI’s  protocol; this enables the `AppDelegate` to participate in the SwiftUI’s app-level shared state and manages the resumption of Core Location activities when needed.
```swift
    import Foundation
    import UIKit

    class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {   
    
        func application(_ application: UIApplication, didFinishLaunchingWithOptions
                         launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
            let locationsHandler = LocationsHandler.shared
        
            // If location updates were previously active, restart them after the background launch.
            if locationsHandler.updatesStarted {
                locationsHandler.startLocationUpdates()
            }
            // If a background activity session was previously active, reinstantiate it after the background launch.
            if locationsHandler.backgroundActivity {
                locationsHandler.backgroundActivity = true
            }
            return true
        }
    }
```

Finally, include the `AppDelegate` functionality in your app’s `@main` structure using a :
```
Finally, include the `AppDelegate` functionality in your app’s `@main` structure using a :
```swift
    @main
    struct MyApp: App {
        @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
    }
```


## Suspending authorization requests
> https://developer.apple.com/documentation/corelocation/suspending-authorization-requests

### 
If your app has an onboarding flow that includes obtaining location updates, you may want to defer the Core Location’s request for authorization from the user. You can inhibit the auto-prompting in your app by creating a  at a convenient time in your app, then iterating over its diagnostics property to determine the level of authorization the person using your app selects. The following code snippet demonstrates how to defer the prompting.
```swift
func doPromptingFlow() async {
    await showHelloPrompt()

    // Obtain a session. This causes Core Location to display the authorization prompt.
    let session = CLServiceSession.session(authorization: .whenInUse)

    // Wait for interaction with the prompot to complete (successfully or with denial).
    for try await diagnostic in session.diagnostics {
        if !diagnostic.authorizationRequestInProgress {
            // A denial occurred.
            break
        }
    }

    await doFurtherWork()
}
```

Add the `CLRequireExplicitServiceSession` property to your app’s Info.plist file to opt into this control behavior.

## Turning an iOS device into an iBeacon device
> https://developer.apple.com/documentation/corelocation/turning-an-ios-device-into-an-ibeacon-device

### 
#### 
To create a new UUID for your iBeacon deployment, use the `uuidgen` command-line tool. Open Terminal and type `uuidgen` on the command line and press Return. This tool generates a unique 128-bit value and formats it as an ASCII string that is punctuated by hyphens, as shown in Listing 1.
Listing 1. Generating a UUID from the command line
```shell
$ uuidgen
39ED98FF-2900-441A-802F-9C398FC199D2 
```

#### 
Use a  object to configure your beacon’s identity. You use the beacon region to generate a dictionary of information that you can advertise later over Bluetooth. Listing 2 shows how to create a beacon region object and fill it with information.
Listing 2. Configuring your beacon’s identity
```swift
func createBeaconRegion() -> CLBeaconRegion? {
    let proximityUUID = UUID(uuidString:
                "39ED98FF-2900-441A-802F-9C398FC199D2")
    let major : CLBeaconMajorValue = 100
    let minor : CLBeaconMinorValue = 1
    let beaconID = "com.example.myDeviceRegion"
        
    return CLBeaconRegion(proximityUUID: proximityUUID!, 
                major: major, minor: minor, identifier: beaconID)
}
```

#### 
Add the Core Bluetooth framework to your Xcode project. In your code, create a  object and call its  method to begin broadcasting your beacon data. The  method takes a dictionary parameter that contains your beacon information. Call the  method of the  that you created previously to get a dictionary containing the data associated with your beacon.
Listing 3. Advertising your device over Bluetooth
```swift
func advertiseDevice(region : CLBeaconRegion) {
    let peripheral = CBPeripheralManager(delegate: self, queue: nil)
    let peripheralData = region.peripheralData(withMeasuredPower: nil)
        
    peripheral.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
}
```


