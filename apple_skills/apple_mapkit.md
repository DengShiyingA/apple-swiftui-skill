# Apple MAPKIT Skill


## Annotating a Map with Custom Data
> https://developer.apple.com/documentation/mapkit/annotating-a-map-with-custom-data

### 
#### 
To display an annotation on a map, your app must provide two distinct objects: an annotation object and an annotation view.
An annotation object conforms to the `MKAnnotation` protocol and manages the data for the annotation, such as the , , and  properties as shown in this section of the sample code.
```swift
class SanFranciscoAnnotation: NSObject, MKAnnotation {
    
    // This property must be key-value observable, which the `@objc dynamic` attributes provide.
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 37.779_379, longitude: -122.418_433)
    
    // Required if you set the annotation view's `canShowCallout` property to `true`
    var title: String? = NSLocalizedString("SAN_FRANCISCO_TITLE", comment: "SF annotation")
    
    // This property defined by `MKAnnotation` is not required.
    var subtitle: String? = NSLocalizedString("SAN_FRANCISCO_SUBTITLE", comment: "SF annotation")
}
```

```
Derived from the `MKAnnotationView` class, an annotation view draws the visual representation of the annotation on the map surface. Register annotation views with the `MKMapView` so the map view can create and efficiently reuse them. Use a default annotation view if you need to customize the content with  a callout, or change the default marker. Use a custom annotation view if you want to have a completely custom view appear for the annotation.
```swift
private func registerMapAnnotationViews() {
    mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(BridgeAnnotation.self))
    mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomAnnotation.self))
    mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(SanFranciscoAnnotation.self))
    mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(FerryBuildingAnnotation.self))
}
```

```
When an annotation comes into view, the map view asks the  to provide the appropriate annotation view.
```swift
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    guard !annotation.isKind(of: MKUserLocation.self) else {
        // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
        return nil
    }
    
    var annotationView: MKAnnotationView?
    
    if let annotation = annotation as? BridgeAnnotation {
        annotationView = setupBridgeAnnotationView(for: annotation, on: mapView)
    } else if let annotation = annotation as? CustomAnnotation {
        annotationView = setupCustomAnnotationView(for: annotation, on: mapView)
    } else if let annotation = annotation as? SanFranciscoAnnotation {
        annotationView = setupSanFranciscoAnnotationView(for: annotation, on: mapView)
    } else if let annotation = annotation as? FerryBuildingAnnotation {
        annotationView = setupFerryBuildingAnnotationView(for: annotation, on: mapView)
    }
    
    return annotationView
}
```

```
Before returning from the delegate call providing the annotation view, you configure the annotation view with any customizations required for the annotation. For example, use a flag icon for an annotation view representing San Francisco.
```swift
private func setupSanFranciscoAnnotationView(for annotation: SanFranciscoAnnotation, on mapView: MKMapView) -> MKAnnotationView {
    let reuseIdentifier = NSStringFromClass(SanFranciscoAnnotation.self)
    let flagAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
    
    flagAnnotationView.canShowCallout = true
    
    // Provide the annotation view's image.
    let image = #imageLiteral(resourceName: "flag")
    flagAnnotationView.image = image
    
    // Provide the left image icon for the annotation.
    flagAnnotationView.leftCalloutAccessoryView = UIImageView(image: #imageLiteral(resourceName: "sf_icon"))
    
    // Offset the flag annotation so that the flag pole rests on the map coordinate.
    let offset = CGPoint(x: image.size.width / 2, y: -(image.size.height / 2) )
    flagAnnotationView.centerOffset = offset
    
    return flagAnnotationView
}
```

#### 
A callout is a standard or custom view that can appear with an annotation view. A standard callout displays the annotation’s title, and it can display additional content such as a subtitle, images, and a control.
A callout can be customized in multiple ways. To place a disclosure button inside a callout:
```swift
let rightButton = UIButton(type: .detailDisclosure)
markerAnnotationView.rightCalloutAccessoryView = rightButton
```

When the disclosure button is tapped, MapKit calls  for the app to handle the tap event.
Callouts can also include images, such as the :
```swift
// Provide an image view to use as the accessory view's detail view.
markerAnnotationView.detailCalloutAccessoryView = UIImageView(image: #imageLiteral(resourceName: "ferry_building"))
```


## Converting a user’s location to a descriptive placemark
> https://developer.apple.com/documentation/mapkit/converting-a-user-s-location-to-a-descriptive-placemark

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


## Decluttering a Map with MapKit Annotation Clustering
> https://developer.apple.com/documentation/mapkit/decluttering-a-map-with-mapkit-annotation-clustering

### 
#### 
To group annotations into a cluster, set the  property to the same value on each annotation view in the group. For example, to show overlapping unicycle annotations in a clustering annotation view, TANDm sets `clusteringIdentifier` on each instance of `UnicycleAnnotationView` to `"unicycle"`.
```swift
override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    clusteringIdentifier = "unicycle"
}
```

#### 
To determine how an annotation view behaves when it overlaps another annotation view, set its  property. In the sample app, the map view is likely to hide the unicycle annotation if it overlaps with another annotation because the unicycle annotation view has a display priority of , while the display priorities for bicycle and tricycle are set to . Here’s an example of setting the display priority while preparing an instance of `BicycleAnnotationView` for reuse:
```swift
override func prepareForDisplay() {
    super.prepareForDisplay()
    displayPriority = .defaultHigh
    markerTintColor = UIColor.bicycleColor
    glyphImage = #imageLiteral(resourceName: "bicycle")
}
```

#### 
Customize the behavior and appearance of a clustering annotation view by subclassing ; for instance, to display hints about the annotations within the cluster. TANDm, for example, uses the custom clustering annotation view `ClusterAnnotationView` to show the ratio between bicycles and tricycles at a location.
```swift
override func prepareForDisplay() {
    super.prepareForDisplay()
    
    if let cluster = annotation as? MKClusterAnnotation {
        let totalBikes = cluster.memberAnnotations.count
        
        if count(cycleType: .unicycle) > 0 {
            image = drawUnicycleCount(count: totalBikes)
        } else {
            let tricycleCount = count(cycleType: .tricycle)
            image = drawRatioBicycleToTricycle(tricycleCount, to: totalBikes)
        }
        
        if count(cycleType: .unicycle) > 0 {
            displayPriority = .defaultLow
        } else {
            displayPriority = .defaultHigh
        }
    }
}
```


## Displaying an updating path of a user’s location history
> https://developer.apple.com/documentation/mapkit/displaying-an-updating-path-of-a-user-s-location-history

### 
#### 
Before recording the user’s path, the app asks the user for permission to access location data while the app is running. After the user grants location authorization, a `CLLocationManager` receives a stream of location updates as the user travels. The app also receives location updates while in the background by setting the  property of  to `true`. This combination of when-in-use authorization and background updates allows the app to receive location updates while in the background, and the system displays a location service indicator when the app isn’t in the foreground.
```swift
locationManager.requestWhenInUseAuthorization()

/// Enable the app to collect location updates while it's in the background.
locationManager.allowsBackgroundLocationUpdates = true
```

The app sets a default value for the  property on the location manager. This value is customizable in a menu to demonstrate how the value of this property affects the accuracy of the recorded data. Lower accuracy values allow the device to conserve power and have less impact on the device’s battery life. For example, if this app is for hiking, it needs high-accuracy data to capture a detailed path for the user’s hiking route, requiring  to facilitate the required detail. In contrast, if the app tracks overall progress between a start and end point without needing the exact path taken, using a lower accuracy value, such as  or , is a better choice because it conserves power.
The app also sets a default value for the  property, and is configurable in a menu. This property provides a hint to Core Location about the type of travel the device encounters while monitoring location. For example, if someone uses this app often while running, it sets `activityType` to . If they use it for providing driving directions, it sets `activityType` to  so that Core Location makes small adjustments to the reported location to match known roads.
```swift
locationManager.requestWhenInUseAuthorization()

/// Enable the app to collect location updates while it's in the background.
locationManager.allowsBackgroundLocationUpdates = true
```

```
After the app calls  on the location manager, Core Location provides location updates to the location manager’s delegate. Then the app forwards the location updates to other functions in the app responsible for maintaining the user’s location history.
```swift
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    // Play a sound so it's easy to tell when a location update occurs while the app is in the background.
    if chimeOnLocationUpdate && !locations.isEmpty {
        setSessionActiveWithMixing(true) // Ducks the audio of other apps when playing the chime.
        playSound()
    }
    
    // Always process all of the provided locations. Don't assume the array only contains a single location.
    for location in locations {
        displayNewBreadcrumbOnMap(location)
    }
}
```

#### 
When drawing an overlay on the map, MapKit uses the overlay’s  to determine when the overlay is visible. Because this app can’t determine the extent of the path the user might track on the map, `BreadcrumbPath` declares its `boundingMapRect` as . In an app that has well-defined usage patterns, such as a hiking app for use within a national park, the `boundingMapRect` might consist of a large area the path is likely to remain within, such as the bounds of the national park.
When the app adds a new location, `BreadcrumbPath` validates that the information in  is usable for its purposes. Each app that maintains a location history needs to define criteria for ensuring a location update is usable based on the app’s specific needs.
```swift
private func isNewLocationUsable(_ newLocation: CLLocation, breadcrumbData: BreadcrumbData) -> Bool {
    /**
     Always check the timestamp of a location value to ensure the location is recent, such as within the last 60 seconds. When starting
     location updates, the values that return may reflect cached values while the device works to acquire updated locations according to
     the accuracy level of the location manager. For some apps, the cached values may be sufficient, but in an app that draws a map of
     a user's travel path, values that are too old may deviate too far from the user's actual path.
     */
    let now = Date()
    let locationAge = now.timeIntervalSince(newLocation.timestamp)
    guard locationAge < 60 else { return false }
    
    /**
     An app might keep the first few updates before applying any further filtering, such as to ensure there is an intial set of
     locations while waiting for the location accuracy to increase to the requested level.
     */
    guard breadcrumbData.locations.count > 10 else { return true }
    
    /**
     Identify locations that shouldn't be part of the breadcrumb data, such as locations that are too close together.
     Get the distance between this new location and the previous location, and use a minimum threshold
     to determine if keeping the location is useful. For example, a location update that is just a few meters from the
     prior location might represent a user that hasn't moved.
     
     Your app may apply other criteria. For example, an app tracking a user at walking speed may discard updates that show the user
     moving at car speeds because that might indicate the user forgot to stop recording their location after completing the walk.
     Consider comparing an average value over the last several location updates, such as the user's average speed.
     
     If using the location accuracy properties as criteria for determining a usable location, expect the values to vary, and don't
     throw away low-accuracy values by expecting only high-accuracy values. Discarding locations due to lower than expected accuracy
     can cause the user's location to appear to jump if the user is moving.
     */
    let minimumDistanceBetweenLocationsInMeters = 10.0
    let previousLocation = breadcrumbData.locations.last!
    let metersApart = newLocation.distance(from: previousLocation)
    return metersApart > minimumDistanceBetweenLocationsInMeters
}
```

```
After `BreadcrumbPath` validates that a location is usable, it updates its data structures to include the new location. One of the properties of `BreadcrumbPath` is `pathBounds`, the bounding rectangle containing all of the locations for the overlay. Unlike `boundingMapRect`, `pathBounds` changes its value as the app adds locations to the overlay. A custom overlay renderer reads the value of `pathBounds` from multiple threads concurrently, so `BreadcrumbPath` uses  to protect reading of this property from data races.
```swift
/// This is a lock protecting the `locations` and `bounds` properties that define the breadcrumb path from data races.
private let protectedBreadcrumbData = OSAllocatedUnfairLock(initialState: BreadcrumbData())

/**
 This is a rectangle encompassing the breadcrumb path, including a reasonable amount of padding. The value of this property changes
 when adding a new location to the breadcrumb path that’s outside of the existing `pathBounds`.
 */
var pathBounds: MKMapRect {
    /**
     The app accesses this property from the main thread in `BreadcrumbViewController`, and multiple
     background threads running in parallel, through the `canDraw(_:zoomScale)` method.
     Using a lock for access avoids data races.
     */
    return protectedBreadcrumbData.withLock { breadcrumbData in
        return breadcrumbData.bounds
    }
}
```

#### 
To implement a custom overlay renderer object that complements the custom overlay data object, the app subclasses . To determine whether an overlay has content to draw, MapKit queries the  method of an overlay renderer. The `BreadcrumbPathRenderer` class in this sample overrides this method to check whether the provided  intersects the `pathBounds` property of the `BreadcrumbPath` object.
```swift
override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
    return crumbs.pathBounds.intersects(mapRect)
}
```

```
A custom overlay renderer also needs to implement the  method to draw the requested section of the overlay. The app draws only the portion of the overlay within the bounds of the provided `MKMapRect` into the provided .
```swift
override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
    /// Scale the width of the line to match the width of a road.
    let lineWidth = MKRoadWidthAtZoomScale(zoomScale)
    
    /// Outset `mapRect` by the line width to include points just outside of the current rectangle in the generated path.
    let clipRect = mapRect.insetBy(dx: -lineWidth, dy: -lineWidth)
    
    /**
     Because the system might call this function on multiple background threads simultaneously,
     and the `locations` property of the `BreadcrumbPath` updates frequently,
     `locations` needs to guard against data races. See the comments in `BreadcrumbPath` for details.
     */
    let points = crumbs.locations.map { MKMapPoint($0.coordinate) }
    if let path = pathForPoints(points, mapRect: clipRect, zoomScale: zoomScale) {
        context.addPath(path)
        context.setStrokeColor(UIColor.systemBlue.withAlphaComponent(0.5).cgColor)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setLineWidth(lineWidth)
        context.strokePath()
    }
}
```

#### 
When the sample app receives a location update, it adds the location to the custom overlay by calling a method that `BreadcrumbPath` defines. This method returns information indicating the result of adding the location to the overlay. When successful, the app calls  on the custom overlay renderer to trigger a redraw of the overlay within the region of the map where the user traveled.
```swift
/**
 If the `BreadcrumbPath` model object determines that the current location moves far enough from the previous location,
 use the returned updateRect to redraw just the changed area.
*/
let result = breadcrumbs.addLocation(newLocation)

/**
 If the `BreadcrumbPath` model object successfully adds the location to the path,
 update the rendering of the path to include the new location.
 */
 if result.locationAdded {
    // Compute the currently visible map zoom scale.
    let currentZoomScale = mapView.bounds.size.width / mapView.visibleMapRect.size.width
    
    /**
     Find out the line width at this zoom scale and outset the `pathBounds` by that amount to ensure the full line width draws.
     This covers situations where the new location is right on the edge of the provided `pathBounds`, and only part of the line width
     is within the bounds.
    */
    let lineWidth = MKRoadWidthAtZoomScale(currentZoomScale)
    var areaToRedisplay = breadcrumbs.pathBounds
    areaToRedisplay = areaToRedisplay.insetBy(dx: -lineWidth, dy: -lineWidth)
    
    /**
     Tell the overlay view to update just the changed area, including the area that the line width covers.
     Use `setNeedsDisplay(_:)` to only redraw the changed area of a breadcrumb overlay. For this sample,
     the changed area includes the entire overlay because if the app was recently in the background, the breadcrumb path
     that's visible when the app returns to the foreground might change significantly.

     In general, avoid calling `setNeedsDisplay()` on the overlay renderer without a map rectangle, as that may cause a render
     pass for the entire visible map, only some of which may contain updated data in the overlay.
     
     To avoid an expensive operation, call `setNeedsDisplay(_:)` instead of removing the overlay from the map and then immediately
     adding it back to trigger a render pass when the data is changing often. The rendering of an overlay after adding it to the
     map is not instantaneous, so removing and adding an overlay may cause a visual flicker as the system updates the map view
     without the overlay, and then updates it again with the overlay. This is especially true if the map is displaying more than
     one overlay or updating the overlay data often, such as on each location update.
    */
    breadcrumbPathRenderer?.setNeedsDisplay(areaToRedisplay)
}
```


## Displaying overlays on a map
> https://developer.apple.com/documentation/mapkit/displaying-overlays-on-a-map

### 
#### 
Overlays are data objects that represent geographic information. Most overlays use geographic coordinates to create contiguous or noncontiguous sets of lines, rectangles, circles, and other shapes. For example, this sample app defines a rectangular area enclosing San Francisco as an array of  coordinates.
```swift
/// A rectangular area containing San Francisco.
static let sanFranciscoRectangle = [
    CLLocationCoordinate2D(latitude: 37.816_41, longitude: -122.522_62),
    CLLocationCoordinate2D(latitude: 37.816_41, longitude: -122.355_54),
    CLLocationCoordinate2D(latitude: 37.702_08, longitude: -122.355_54),
    CLLocationCoordinate2D(latitude: 37.702_08, longitude: -122.522_62)
]
```

```
The app creates the overlay objects by providing the coordinate data to an object that conforms to the  protocol. This data object is responsible for managing the data that defines the overlay. MapKit defines several concrete overlay objects for specifying different types of standard shapes, such as circles and polygons. The app uses the coordinate array above to create one of these provided overlay objects — a polygon.
```swift
/// Creates a rectangle polygon.
var rectangleOverlay: MKPolygon {
    return MKPolygon(coordinates: LocationData.sanFranciscoRectangle, count: LocationData.sanFranciscoRectangle.count)
}
```

#### 
 is a standards-based data format for representing geographic data, and apps often receive overlay data from a server in GeoJSON format. Rather than connect to a server, this app uses a local GeoJSON file containing `MultiPolygon` features into an `MKMultiPolygon` by using .
```swift
init() {
    /// In a real app, the event data probably downloads from a server. This sample loads GeoJSON data from a local file instead.
    if let jsonUrl = Bundle.main.url(forResource: "event", withExtension: "json") {
        do {
            let eventData = try Data(contentsOf: jsonUrl)

            // Use the `MKGeoJSONDecoder` to convert the JSON data into MapKit objects, such as `MKGeoJSONFeature`.
            let decoder = MKGeoJSONDecoder()
            let jsonObjects = try decoder.decode(eventData)

            parse(jsonObjects)
        } catch {
            print("Error decoding GeoJSON: \(error).")
        }
    }
}

private func parse(_ jsonObjects: [MKGeoJSONObject]) {
    for object in jsonObjects {

        /**
         In this sample's GeoJSON data, there are only GeoJSON features at the top level, so this parse method only checks for those. An
         implementation that parses arbitrary GeoJSON files needs to check for GeoJSON geometry objects too.
        */
        if let feature = object as? MKGeoJSONFeature {
            for geometry in feature.geometry {

                /**
                 Separate annotation objects from overlay objects because you add them to the map view in different ways. This sample
                 GeoJSON only contains `Point` and `MultiPolygon` geometry. In a generic parser, check for all possible geometry types.
                */
                if let multiPolygon = geometry as? MKMultiPolygon {
                    overlays.append(multiPolygon)
                } else if let point = geometry as? MKPointAnnotation {
                     // The name of the annotation passes in the feature properties.
                     // Parse the name and apply it to the annotation.
                    configure(annotation: point, using: feature.properties)
                    annotations.append(point)
                }
            }
        }
    }
}
```

#### 
The app adds the overlay data objects to the map in a specific order to ensure that certain overlays display on top of others. To specify whether an overlay is above or below content that the map provides, such as roads and labels, the app calls  with the `level` parameter as a value that  provides.
```swift
mapView.addOverlay(reliefTileOverlay, level: .aboveLabels)
```

```
The overlay data object doesn’t draw the overlay on the map. A second object, called an , handles the drawing responsibilities for displaying the overlay on the map view. After adding an overlay, the map view calls  on its delegate to create an appropriate renderer object. Because this app demonstrates many different overlays, its implementation of `mapView(_:rendererFor:)` creates many different types of overlay renderers. Most apps only use a small number of overlay types, so this function only needs to create the small number of corresponding overlay renderer types.
```swift
func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    switch overlay {
    case let overlay as MKCircle:
        return createCircleRenderer(for: overlay)
    case let overlay as MKGeodesicPolyline:
        return createGeodesicPolylineRenderer(for: overlay)
    case let overlay as MKPolyline where currentExample == .gradientPolyline:
        return createGradientPolylineRenderer(for: overlay)
    case let overlay as MKPolyline:
        return createPolylineRenderer(for: overlay)
    case let overlay as MKPolygon where currentExample == .blendModes:
        return createBlendModesPolygonRenderer(for: overlay)
    case let overlay as MKPolygon:
        return createPolygonRenderer(for: overlay)
    case let overlay as MKMultiPolygon:
        return createMultiPolylineRenderer(for: overlay)
    case let overlay as PeakGroundAccelerationGrid:
        return createCustomRenderer(for: overlay)
    case let overlay as MKTileOverlay:
        return createTileRenderer(for: overlay)
    default:
        return MKOverlayRenderer(overlay: overlay)
    }
}
```

#### 
The app highlights specific map regions with basic shapes by using the standard overlay classes, including , , and . For example, it creates a circle overlay using `MKCircle` with a center coordinate and a radius specified in meters to highlight San Francisco.
```swift
/// Create a circle overlay that centers on San Francisco.
let circleOverlay = MKCircle(center: LocationData.sanFranciscoGeographicCenter, radius: 9000)
mapView.addOverlay(circleOverlay, level: overlayLevel)
```

```
The standard overlay classes define the basic shape of the overlay, and the app uses them in conjunction with the , , or  classes to handle the rendering of that shape on the map. The app creates a renderer for the circle described above with the following code:
```swift
func createCircleRenderer(for circle: MKCircle) -> MKCircleRenderer {
    /**
     Some of the most common customizations for an `MKOverlayRenderer` include customizing drawing settings, such as the
     fill color of an enclosed shape, or the stroke color for the edge of the shape.
     */
    let renderer = MKCircleRenderer(circle: circle)
    renderer.lineWidth = 2
    renderer.strokeColor = .systemBlue
    renderer.fillColor = .systemTeal
    renderer.alpha = 0.5
    
    return renderer
}
```

#### 
The standard overlay renderers allow customization of common drawing properties for the fill and edges. For example, the app displays an `MKPolyline` overlay using dashes instead of a solid line, and sets a customized dash pattern using the  property of an .
```swift
/**
 Apply a custom pattern to the line, alternating dash length with space length in drawing points.
 The pattern repeats for the length of the polyline.
 */
renderer.lineDashPattern = [20 as NSNumber,   // Long dash
                            10 as NSNumber,   // Space
                             5 as NSNumber,   // Shorter dash
                            10 as NSNumber,   // Space
                             1 as NSNumber,   // Dot
                            10 as NSNumber]   // Space
```

```
MapKit also provides  to draw a polyline with a color gradient. The app configures a gradient renderer in the following way:
```swift
func createGradientPolylineRenderer(for line: MKPolyline) -> MKGradientPolylineRenderer {
    let renderer = MKGradientPolylineRenderer(polyline: line)
    
    let colorPalette: [UIColor] = [.systemPurple, .systemMint, .systemOrange, .systemTeal, .systemRed]
    
    /**
     Gradient polylines take an array of colors and an array of locations to place each color within the gradient.
     The system describes the location values as a fractional distance along the polyline between 0.0 (representing the first point) and
     1.0 (representing the last point).
     
     For apps that add a color to the gradient per point in the polyline, `MKPolyline` offers the `location(atPointIndex:)` function to
     compute the location value for use with the gradient polyline.
     */
    var unitDistances = [CGFloat]()
    var colors = [UIColor]()
    var index = 0
    while index < line.pointCount {
        // Figure out the location of a point in the polyline as a fraction of unit distance between 0 and 1.
        unitDistances.append(line.location(atPointIndex: index))
        
        // Pick a color to add to the gradient.
        colors.append(colorPalette[index % colorPalette.count])
        
        index += 1
    }
    
    renderer.setColors(colors, locations: unitDistances)
    renderer.lineWidth = 2
    
    return renderer
}
```

#### 
It’s common to have multiple related overlays appear on the map with an identical visual style. For example, the app displays a map of an outdoor event that uses multiple overlays to show where the stage is located in relation to different event booths. Because the app shows each of these overlays using the same color scheme, it groups the individual overlay objects together using an  object.
The app then adds the grouped overlay to the map view, rather than adding the individual overlays, to avoid requesting a separate renderer for each overlay from its delegate. Instead, the app returns an  from the delegate. This returned renderer applies the same drawing properties to all overlays within the  `MKMultiPolygon`. This is more efficient than creating a renderer for each overlay.
```swift
func createMultiPolylineRenderer(for multiPolygon: MKMultiPolygon) -> MKMultiPolygonRenderer {
    let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
    renderer.fillColor = UIColor(named: "MultiPolygonOverlayFill")
    renderer.strokeColor = UIColor(named: "MultiPolygonOverlayStroke")
    renderer.lineWidth = 2.0

    return renderer
}
```

#### 
 relate the content that draws in an overlay to the content that draws behind the overlay. This enables creating visual effects on the map by adding overlays with a specific Z-order and applying a blend mode on the different overlays. For example, the app highlights a park hosting an outdoor event by using blend modes to lighten the map areas outside the park and to amplify the colors within the park.
To create such an effect, the app uses two overlays. The first overlay covers the entire map except for an inner polygon for the park, and the second overlay is a polygon outlining only the park.
```swift
/// Turn an array of points into a polygon. You can also load the polygon from a GeoJSON file by using `MKGeoJSONDecoder`.
let parkPolygon = MKPolygon(coordinates: LocationData.plazaDeCesarChavezParkOutline,
                                 count: LocationData.plazaDeCesarChavezParkOutline.count)

/// Create an overlay polygon that covers the entire world, except for a cutout of the highlighted park.
let worldPoints = [MKMapRect.world.origin,
                   MKMapPoint(x: MKMapRect.world.origin.x, y: MKMapRect.world.origin.y + MKMapRect.world.size.height),
                   MKMapPoint(x: MKMapRect.world.origin.x + MKMapRect.world.size.width, y: MKMapRect.world.origin.y),
                   MKMapPoint(x: MKMapRect.world.origin.x + MKMapRect.world.size.width,
                              y: MKMapRect.world.origin.y + MKMapRect.world.size.height)]
let desaturatedBase = MKPolygon(points: worldPoints, count: worldPoints.count, interiorPolygons: [parkPolygon])
```

```
When the map view requests renderer objects from the map delegate for these overlay objects, the app configures the  property with the  blend mode to lighten the map area outside the park, and the  blend mode to darken the colors within the park.
```swift
func createBlendModesPolygonRenderer(for overlay: MKPolygon) -> MKPolygonRenderer {
    let renderer = MKPolygonRenderer(polygon: overlay)
    
    if overlay.interiorPolygons == nil {
        /// An overlay without `interiorPolygons` is the overlay highlighting the park.
        renderer.fillColor = traitCollection.userInterfaceStyle == .light ? .darkGray : .white
        renderer.blendMode = .colorBurn
    } else {
        /// An overlay with `interiorPolygons` is the background overlay to desaturate.
        renderer.fillColor = .gray
        renderer.blendMode = .screen
    }
    return renderer
}
```

#### 
To draw complex overlays that go beyond drawing boundaries and filling standard overlay shapes, this sample code project creates a custom overlay renderer. The app contains data related to earthquake hazards, and defines a custom `MKOverlay` to represent that hazard data. It also defines a custom overlay renderer to draw a color-coded, shaded map of hazards based on the data.
To create a custom overlay renderer, the app subclasses `MKOverlayRenderer` and implements `draw(_:zoomScale:in:)` to draw the earthquake data into the provided . MapKit calls this method concurrently on multiple background queues for the app to draw the overlay, with each call rendering a specific section of the overlay within the bounds of the `mapRect` parameter.
```swift
override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
    // Don't draw anything that doesn't intersect the data set.
    guard mapRect.intersects(data.boundingMapRect) else { return }
    
    /**
     Determine the section of the overlay to render. MapKit breaks overlays into multiple rectangles for rendering on multiple threads.
     Each call to `draw(_:zoomScale:in:)` should only render within bounds of the provided `mapRect`.
     If your drawing implementation needs to draw content outside of the provided `mapRect` as part of its drawing algorithm, apply a clipping
     rectangle by calling `clip(to:)` on the `CGContext`.
     */
    let intersection = mapRect.intersection(data.boundingMapRect)
```

```
When the app draws the custom overlay, it uses  data associated with the overlay to define shapes. When it needs to convert data between MapKit geometry and Core Graphics geometry, it uses .
```swift
let point1Conversion = point(for: coord1.mapPoint)
```

#### 
To use a custom bitmap map tile overlay, the app uses  to manage loading the tile data and  to render the map tiles. When creating the tile overlay, the app provides a URL template with placeholder values for the tile position, zoom level, and scale factor to the `MKTileOverlay`. When the tile overlay loads the data, MapKit replaces the placeholder values with the required values to load tiles for a specific map region according to the EPSG:3857 spherical Mercator projection coordinate system.
The URL template can be either an HTTP URL or a file URL, and this app uses both. For example, it loads some map tiles bundled with the app and specifies a file URL template that locates the map tiles within the app’s bundle.
```swift
let tileDirectoryName = "tileData"
guard let resourcePath = Bundle.main.resourcePath else { return }
let localPath = "file://\(resourcePath)/\(tileDirectoryName)/{z}/{x}/{y}.jpg"
let tileOverlay = MKTileOverlay(urlTemplate: localPath)
```

#### 
The `MKOverlay` protocol conforms to the  protocol. As a result, all overlay objects are also annotation objects. When adding an overlay as an annotation to the map, `MKMapView` displays it at the overlay’s `coordinate` property. For example, the app uses a polygon outlining the park for an outdoor concert as an annotation to label the concert location.
```swift
/**
 Types that derive from `MKOverlay`, such as `MKPolygon`, also conform to `MKAnnotation`, enabling you to add them to the map as an overlay,
 as well as place an annotation on the overlay to label it.
 */
parkPolygon.title = "Concert Location"
mapView.addAnnotation(parkPolygon)
```


## Interacting with nearby points of interest
> https://developer.apple.com/documentation/mapkit/interacting-with-nearby-points-of-interest

### 
#### 
 retrieves autocomplete suggestions for a partial search query within a map region. A person can type “cof”, and a search completion suggests “coffee” as the query string. As the person types a query into a search bar, the sample app updates the query. In SwiftUI, the sample creates the search field using the  modifier.
```swift
.searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: searchPrompt)
```

As someone types a query into a search bar, the sample app updates the  for the search completion through the `searchQuery` binding.
```
As someone types a query into a search bar, the sample app updates the  for the search completion through the `searchQuery` binding.
```swift
/// Ask for completion suggestions based on the query text.
func provideCompletionSuggestions(for query: String) {
    /**
     Configure the search to return completion results based only on the options in the app. For example,
     someone can configure the app to exclude specific point-of-interest categories, or to only return results for addresses.
     */
    searchCompleter?.resultTypes = mapConfiguration.resultType.completionResultType
    searchCompleter?.regionPriority = mapConfiguration.regionPriority.localSearchRegionPriority
    if mapConfiguration.resultType == .pointsOfInterest {
        searchCompleter?.pointOfInterestFilter = mapConfiguration.pointOfInterestOptions.filter
    } else if mapConfiguration.resultType == .addresses {
        searchCompleter?.addressFilter = mapConfiguration.addressOptions.filter
    }
    
    searchCompleter?.region = mapConfiguration.region
    searchCompleter?.queryFragment = query
}
```

#### 
Completion results represent fully formed query strings based on the query fragment someone types. The sample app uses completion results to populate UI elements to quickly fill in a search query. The app receives the latest completion results as an array of  objects by adopting the  protocol.
```swift
nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    Task { @MainActor in
        /**
         As a person types, new completion suggestions continuously return to this method. Update the property storing the current
         results, so that the app UI can observe the change and display the updated suggestions.
         */
        let suggestedCompletions = completer.results
        resultStreamContinuation?.yield(suggestedCompletions)
    }
}
```

```
The app uses an  to deliver the completion results to the UI, which the `SidebarView`  stores in its `searchCompletions` property. The app displays the search suggestions with the  modifier, which takes a binding to the `searchCompletions` property.
```swift
.searchSuggestions {
    // Treat each `MKMapItem` object as unique, using `\.self` for the identity. The `identifier` property of `MKMapItem`
    // is an optional value, and the meaning of the identifier for `MKMapItem` doesn't have the same semantics as
    // the `Identifable` protocol that `ForEach` requires.
    ForEach($searchCompletions, id: \.self) { completion in
        SearchCompletionItemView(completion: completion.wrappedValue)
        .onTapGesture {
            convertSearchCompletionToSearchResults(completion.wrappedValue)
        }
    }
}
```

#### 
Within the UI elements that represent each query result, the sample code uses the  on an `MKLocalSearchCompletion` to show how the query someone enters relates to the suggested result. For example, the following code applies a highlight with :
```swift
private func createHighlightedString(text: String, rangeValues: [NSValue]) -> NSAttributedString {
    let attributes = [NSAttributedString.Key.backgroundColor: UIColor(named: "suggestionHighlight")!]
    let highlightedString = NSMutableAttributedString(string: text)

    // Each `NSValue` wraps an `NSRange` that functions as a style attribute's range with `NSAttributedString`.
    let ranges = rangeValues.map { $0.rangeValue }
    for range in ranges {
        highlightedString.addAttributes(attributes, range: range)
    }

    return highlightedString
}
```

#### 
An `MKLocalSearch.Request` takes either an `MKLocalSearchCompletion` or a natural language query string, and returns an array of  objects. Each `MKMapItem` represents a geographic location, like a specific address, that matches the search query. The sample code asynchronously retrieves the array of `MKMapItem` objects by calling  on .
```swift
let search = MKLocalSearch(request: request)
currentSearch = search
defer {
    // After the search completes, the reference is no longer needed.
    currentSearch = nil
}

var results: [MKMapItem]

do {
    let response = try await search.start()
    results = response.mapItems
} catch let error {
    searchLogging.error("Search error: \(error.localizedDescription)")
    results = []
}
```

#### 
If a person is exploring the map, they can get information for a point of interest by tapping it. To provide these interactions, the sample code enables selectable map features as follows:
```swift
// Use the standard map style, with an option to display specific point-of-interest categories.
.mapStyle(.standard(pointsOfInterest: mapModel.searchConfiguration.pointOfInterestOptions.categories))

// Only allow selection for points of interest, and disable selection of other labels, like city names.
.mapFeatureSelectionDisabled { feature in
    feature.kind != MapFeature.FeatureKind.pointOfInterest
}

/*
 The selection accessory allows people to tap on map features and get more detailed information, which displays
 as either a sheet or a callout according to the `style` parameter. Along with the `selection` binding, this determines
 which feature to display additional information for.
 
 This modifier differs from the `mapItemDetailSelectionAccessory(:_) modifier, which enables the same selection
 behaviors on annotations that the app adds to `Map` for search results.
 */
.mapFeatureSelectionAccessory(.automatic)
```

#### 
If someone is exploring the map, they may want the app to store places they looked at so that they can come back to them later, including across app launches. `MKMapItem` has an  property, which the app stores in its `VisitedPlace` model using `SwiftData`.
```swift
guard let identifier = mapItem.identifier else { return }
let visit = VisitedPlace(id: identifier.rawValue)
```

```
When the app launches, it retrieves the history of visited locations from SwiftData. To get the `MKMapItem` from the previously stored identifier, the app creates an  with the stored identifier and calls .
```swift
@MainActor
func convertToMapItem() async -> MKMapItem? {
    guard let identifier = MKMapItem.Identifier(rawValue: id) else { return nil }
    let request = MKMapItemRequest(mapItemIdentifier: identifier)
    var mapItem: MKMapItem? = nil
    do {
        mapItem = try await request.mapItem
    } catch let error {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Map Item Requests")
        logger.error("Getting map item from identifier failed. Error: \(error.localizedDescription)")
    }
    return mapItem
}
```


