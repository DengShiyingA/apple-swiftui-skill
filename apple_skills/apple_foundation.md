# Apple FOUNDATION Skill


## About Apple File System
> https://developer.apple.com/documentation/foundation/about-apple-file-system

### 
#### 
A clone is a copy of a file or directory that occupies no additional space on disk. Clones let you make fast, power-efficient file copies on the same volume. The  and  methods of  automatically create a clone for Apple File System volumes, as shown in the listing below.
```swift
let origin = URL(fileURLWithPath: "/path/to/origin")
let destination = URL(fileURLWithPath: "/path/to/destination")
do {
    // Creates a clone for Apple File System volumes, or makes
    // a copy immediately for other file systems.
    try FileManager.default.copyItem(at: origin, to: destination)
} catch {
    // ... Handle the error ...
}
```

#### 
Each volume in the container can use the shared free space, so they all include that amount when reporting the available free space. For example, when you call  method of , the amount that’s reported includes all of the shared free space.
```swift
if let attributes = try? FileManager.default.attributesOfFileSystem(forPath: "/") {
    let availableFreeSpace = attributes[.systemFreeSize] 
}
```

#### 

## Accessing cached data
> https://developer.apple.com/documentation/foundation/accessing-cached-data

### 
#### 
#### 
You can get or set the cache object used by a `URLSession` object by using the  property of the session’s  object.
#### 
You can write to the cache programmatically, with the  method, passing in a new `CachedURLResponse` object and a `URLRequest` object.
- The provided `CachedURLResponse` object, to cache the proposed response as-is
- `nil`, to prevent caching
- A newly created `CachedURLResponse` object, typically based on the provided object, but with a modified  and  dictionary, as you see fit
The following example shows an implementation of `urlSession(_:dataTask:willCacheResponse:completionHandler:)`, which intercepts responses to HTTPS requests and allows the responses to be stored in the in-memory cache only.
Handling the urlSession(_:dataTask:willCacheResponse:completionHandler:) callback
```swift
func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                willCacheResponse proposedResponse: CachedURLResponse,
                completionHandler: @escaping (CachedURLResponse?) -> Void) {
    if proposedResponse.response.url?.scheme == "https" {
        let updatedResponse = CachedURLResponse(response: proposedResponse.response,
                                                data: proposedResponse.data,
                                                userInfo: proposedResponse.userInfo,
                                                storagePolicy: .allowedInMemoryOnly)
        completionHandler(updatedResponse)
    } else {
        completionHandler(proposedResponse)
    }
}
```


## Accessing settings from your code
> https://developer.apple.com/documentation/foundation/accessing-settings-from-your-code

### 
#### 
#### 
If you use settings to configure your SwiftUI interface, wrap the variables you use to store those values with the  property wrapper. Although you can fetch values from  programmatically, the property wrapper automates the process of getting and setting the values.
The following example shows a view with a variable that retrieves its value from the app’s settings. The `"ShowLineNumbers"` value in the declaration is the setting key SwiftUI uses to get and set the value. The initial value in the declaration becomes the default value, which SwiftUI adds to the registration domain of the defaults database.
```swift
struct EditingPrefs: View {
    @AppStorage("ShowLineNumbers") var showLineNumbers = false

    var body: some View {
        Toggle("Show line numbers", isOn: $showLineNumbers) 
    }
}
```

#### 
Each  object provides methods to get and set settings. Choose the method for the type of value you want and provide a key string with the name of the setting. The following code shows examples of how to use these methods to get and set assorted values:
```swift
let defaults = UserDefaults()
        
// Change settings.
let showLineNumbers = true
let title = "Hello, World!"
defaults.set(showLineNumbers, forKey: "ShowLineNumbers")
defaults.set(title, forKey: "TitleString")
defaults.set(true, forKey: "CacheDataAggressively")
        
// Retrieve settings.
let boolValue = defaults.bool(forKey: "ShowLineNumbers")
let stringValue = defaults.string(forKey: "TitleString")
```

#### 
- To detect changes that occur inside your app, register for a  or  with your `UserDefaults` object.
- To detect changes that occur outside your app, use key-value observing to monitor specific settings in your  object. For example, use this approach to detect changes people make to your app-specific settings from the system Settings app. In macOS, external changes can also come from the `defaults` command-line tool.
The following example shows a type that uses key-value observing to monitor changes to a setting. After creating the object, a call to the `configureObserver` function registers the object as an observer of the `ShowLineNumbers` setting in the standard defaults database. When the value of that setting changes, the defaults system calls the object’s  method to report the change. The system calls this method only when the actual value of the setting changes. If your code assigns a value to a setting, but the new value is the same as the old value, the defaults system doesn’t notify observers.
```swift
@objc class MyObserver: NSObject {
    let defaults = UserDefaults()
    
    func configureObserver() {
        defaults.addObserver(self, forKeyPath: "ShowLineNumbers", options: [.new, .old], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, 
                                                change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(“Setting changed: \(keyPath ?? "nil")")
    }
}
```


## Adding a settings interface to your app
> https://developer.apple.com/documentation/foundation/adding-a-settings-interface-to-your-app

### 
#### 
In macOS, apps display settings in a separate window that’s accessible from the app’s menus. The standard App menu includes space for a Settings menu item, which displays your settings window when selected.
To define the settings interface of your macOS app using SwiftUI, add a  scene to the body of your app. When this scene type is present in your app, SwiftUI updates your app’s menus to include an item to display your settings interface. When someone selects that menu item, SwiftUI displays a new window with the contents of the scene you provide. The following code shows a settings scene in the body of a SwiftUI app:
```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
```

#### 
#### 

## Analyzing HTTP traffic with Instruments
> https://developer.apple.com/documentation/foundation/analyzing-http-traffic-with-instruments

### 
#### 
#### 
The HTTP Traffic track and the process tracks show an aggregated view that displays how many tasks or transactions are active at any point. Session tracks display individual intervals for each task and transaction.
A session track corresponds to a  that you create in code. The session name comes from the  property. Naming your session allows you to reference it when viewing HTTP traffic for your app. Here’s an example showing how to name a session:
```swift
let session = URLSession(configuration:.default)
session.sessionDescription = "Main Session"
```

#### 

## Building a Localized Food-Ordering App
> https://developer.apple.com/documentation/foundation/building-a-localized-food-ordering-app

### 
- `FormatStyle`-based formatting customizes the display of currency values, dates and times, and lists of strings.
#### 
When the app launches, the user can choose one of several foods to add to their order. When the user chooses a food item, a new view shows the item’s ingredients and the available sizes with corresponding prices.
The ingredient list shows an example of formatting a list of items, using the  method defined on the Swift  type. It starts with the an array of `ingredients` defined by the `Food` type. In `FoodHeaderView`, the `ingredientText` variable takes the ingredient strings, maps each to a localized string, and then uses the `formatted(_:)` method to create a comma-separated list. By adding the  list type  as a format style parameter, the formatter places an “and” (or its localized equivalent) before last member of the list.
```swift
private var ingredientText: String {
    food.ingredients.map(\.localizedDescription).formatted(.list(type: .and))
}
```

In English, the ingredient text reads “Our pizza is made from: prosciutto, cheese, flour, and tomatoes.” In Spanish, the list reads “Nuestro pizza está hecho de: prosciutto, queso, harina y tomates.”
The app also uses string formatters to present the price of each item, as seen here:
```swift
func localizedPrice(_ size: FoodSize) -> String {
    price[size]!.formatted(.currency(code: "USD"))
}
```

As with the list of ingredients earlier, the  method applies directly to the type it formats. In this case, the formatted type is a ; this type conforms to Swift’s , which defines the `formatted(_:)` method. A  parameter indicates that the formatting should format the price as a currency, using U.S. dollars.
For more sophisticated formatting needs, some format styles support chaining modifier methods to customize a default style. The Caffé app includes a companion app for Apple Watch that shows the next date when the user is eligible to receive a free coffee. The  presented in this view customizes the default  format style to show only the weekday, hour, and minute:
```swift
var str = date.formatted(.dateTime
                            .locale(locale)
                            .minute()
                            .hour()
                            .weekday()
                            .attributed)
```

#### 
The previous listing also uses the  modifier to return an . Attributed strings contain text and metadata that applies to ranges of that text. In this case, the attributed string returned by the formatter uses the  attribute to mark which ranges of text correspond to which parts of the formatted date. This allows the app to find the weekday attribute in the attribute container and change it to an orange foreground color attribute. The SwiftUI view can then use this attribute when styling the watch display.
```swift
let weekday = AttributeContainer
    .dateField(.weekday)

let color = AttributeContainer
    .foregroundColor(.orange)

str.replaceAttributes(weekday, with: color)
```

```
 is strongly-typed, meaning that all attributes must have defined names and value types. `AttributedString` defines attributes for Foundation, SwiftUI, AppKit, and UIKit in its  type. For common inline attributes like emphasis and links, attributed strings support initialization from with Markdown syntax, either in source or in `.strings` files. The following entry from the Spanish localization’s `Localizable.strings` file shows Markdown formatting for strong emphasis (`**`), regular emphasis (`_`), and links (`[]` for link text, followed by a URL in parentheses):
```None
"**Thank you!**" = "**¡Gracias!**";
"_Please visit our [website](https://www.example.com)._" = "_Visita nuestro [sitio web](https://www.example.com)._";
```

1. Defining the `RainbowAttribute` as an extension of , and providing the name and value type of the attribute.
2. Extending  to define a new  called `CaffeAppAttributes`, whose one member is `rainbow`, of type `RainbowAttribute`. The app also extends `AttributeScopes` with `caffeApp`, a variable of the `CaffeAppAttributes` type, that allows access to the Caffé app’s custom attributes with dynamic member lookup syntax.
3. Extending  to provide a subscript method that takes key paths of type `CaffeAppAttributes`. This allows code to use dot syntax when looking up the members of `CaffeAppAttributes`.
```swift
enum RainbowAttribute: CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
    enum Value: String, Codable, Hashable {
        case plain
        case fun
        case extreme
    }
    
    static var name: String = "rainbow"
}

extension AttributeScopes {
    struct CaffeAppAttributes: AttributeScope {
        let rainbow: RainbowAttribute
    }
    
    var caffeApp: CaffeAppAttributes.Type { CaffeAppAttributes.self }
}

extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.CaffeAppAttributes, T>) -> T {
        self[T.self]
    }
}
```

```
The implementation of `RainbowText` uses these attributes by creating an  and calling a private `annotateRainbowColors(from:)` method to apply its color attributes. To create an `AttributedString` that uses custom attribute scopes, Caffé uses the  initializer, passing the key path to the custom attribute name as the `including:` parameter:
```swift
init(_ localizedKey: String.LocalizationValue) {
    attributedString = RainbowText.annotateRainbowColors(
        from: AttributedString(localized: localizedKey, including: \.caffeApp))
}
```

```
To apply a custom attribute in a string, a caller uses the Markdown extension syntax, as seen in the following example, which applies two different values of the rainbow attribute:
```swift
RainbowText("^[Fast](rainbow: 'fun') & ^[Delicious](rainbow: 'extreme') Food")
    .font(.slogan)
    .frame(maxWidth: 260, alignment: .leading)
```

#### 
Some languages’ grammar require that nouns, adjectives, articles, and other parts of speech agree in number or gender with other parts of a sentence. Localized attributed strings can perform this agreement by using a template string to format the values at runtime.
In Caffé, each food’s detail view has a button indicating how many of each item the user has selected to add to their order. The app fills in this button text with the number, size, and food item to add to the order:
```swift
Button(
    "Add ^[\(quantity) \(foodSizeSelection.localizedName) \(food.localizedName)](inflect: true) to your order",
    action: orderButtonTapped
)
```

The syntax `^[text](inflect:true)` tells the generated attributed string to  the string, meaning to perform automatic grammar agreement on the range of text within the square braces. This process takes into account the value of any numeric substitutions and grammatical gender of string substitutions. In English, this causes the food name to pluralize when `quantity` is not equal to `1`.
In Spanish, the localized string in the `.strings` file uses the parameter reordering syntax to place the noun before the adjective, like the following:
```None
"Añadir ^[%1$lld %3$@ %2$@](inflect: true) a tu pedido";
```

When the automatic grammar engine inflects the generated string for Spanish, it pluralizes the food name, as it does in English. In Spanish, it also adjusts the adjective (`foodSizeSelection.localizedName`) to match the number of `quantity` and the grammatical gender of `food.localizedName`. For example, one small salad becomes “1 ensalada pequeña” in Spanish, while two small salads is “2 ensaladas pequeñas”. In both cases, the grammar engine changes the adjective “pequeño” to match the feminine gender of “ensalada”.
In some languages, an app may need to provide part-of-speech information to the inflection engine. This happens in English, where the words “sandwich” and “juice” are both a noun and a verb. In Spanish, the food size terms “grande” and “enorme” can be used as both adjectives and nouns. The inflection engine logs a warning when it encounters this type of ambiguity. To clarify intent, the inflection engine accepts a grammar markup that wraps the substitution with the syntax `^[…](morphology: {…})` and provides part-of-speech information. The following entry from the English strings file shows an example of this disambiguation:
```None
"Add ^[%lld %@ %@](inflect: true) to your order" = "Add ^[%lld %@ ^[%@](morphology: { partOfSpeech: \"noun\" })](inflect: true) to your order";
```


## Building a Settings bundle for your app
> https://developer.apple.com/documentation/foundation/building-a-settings-bundle-for-your-app

### 
#### 
6. Save the bundle with the name `Settings.bundle`.
#### 
When you build your settings interface, specify the text for interface elements in your development language. To localize that text, add strings files to your Settings bundle for each language you support. When building your settings interface, the Settings app loads the strings file for the appropriate language and makes the relevant substitutions. The following listing shows the structure of a bundle that includes localized strings for English and German.
```None
Settings.bundle/
    Root.plist
    en.lproj/
        root.strings
    de.lproj/
        root.strings 
```

Each property list file in your Settings bundle can have its own dedicated strings file. When building a page of settings, add the Strings Filename key to the page and set its value to the name of the relevant strings file. Omit the filename extension from the name of the strings file. For example, when specifying the strings file for the `Root.plist` file in the previous listing, set the value of the key to `root`.
Inside each strings file, place a pair of translation strings on its own line and separate the strings with an equal sign (=). Place the original value on the left side of the equal sign, and have your translator place the translated value on the right side. The following listing shows the contents of a strings file that translates a set of strings from English to German.
```None
"Group" = "Gruppe";
"Name" = "Name";
"Enabled" = "Aktiviert";
```

#### 
| Settings Page Title | String | The name of the page, which the Settings app doesn’t use. The raw name of this key is `Title`. |
#### 
| Title (required, localizable) | String | The title string that the system displays next to the text field. The raw name of this key is `Title`. |
#### 
| Type (required) | String | The value of this key is always `Group`.  The raw name of this key is `Type` and the raw value is `PSGroupSpecifier`. |
#### 
#### 
| `Type` (required) | String | The raw name of this key is `Type` and the value is always `PSRadioGroupSpecifier`. |
| `FooterText` (localizable) | String | Additional text to display below the group box. The raw name of this key is `FooterText`. |
#### 
#### 
#### 
#### 
| `Type` (required) | String | The value of this key must be `PSConfirmationPrompt`. |
| `Title` (required) | String | A string with the title of the prompt. This title might not appear on some devices. |

## Continuing User Activities with Handoff
> https://developer.apple.com/documentation/foundation/continuing-user-activities-with-handoff

### 
#### 
`HandoffMapViewer` must be run on actual devices; the iOS version cannot run in Simulator.
To configure the sample code project so that it can run on your devices, open the `HandoffMapViewer.xcodeproj` project in Xcode and do the following:
4. To run the iOS version, build the `HandoffMapViewerIOS` target and run it on one of your connected iOS devices.
#### 
You use the app’s `Info.plist` to tell Handoff which activities your app can continue, by providing an entry with the key name `NSUserActivityTypes`. The type of this entry is `Array`, and each member is a `String` representing a supported Handoff activity. In the sample app, the macOS and iOS targets include the `map-viewing` and `store-editing` activities in their `Info.plist` files.
```None
<key>NSUserActivityTypes</key>
<array>
  <string>com.example.apple-samplecode.HandoffMapViewer.map-viewing</string>
  <string>com.example.apple-samplecode.HandoffMapViewer.store-editing</string>
</array>
```

#### 
At runtime, you represent a user activity with the `NSUserActivity`  type. You initialize a user activity object with a string identifier, the same one used earlier in the `Info.plist`.  This object also has an `isEligibleForHandoff` property that exposes the activity to Handoff, and a `userInfo`  dictionary containing data needed to recreate the app’s state on the receiving device.
In the sample app, the `MapViewController` manages two `NSUserActivity` instances: one each for the `map-viewing` and `store-editing` activities. When the map region changes, it sets the `userActivity` property (defined in `NSViewController` for macOS and `UIViewController` for iOS) to the `map-viewing` activity. It makes this the current activity, replacing any other activity that may have previously been sent to Handoff, and sets `needsSave` to `true`, indicating that the activity has new data to send to remote devices.
```swift
userActivity = mapViewingActivity
mapViewingActivity.needsSave = true
mapViewingActivity.becomeCurrent()
```

```
Calling `needsSave`  on the view controller’s `userActivity` eventually results in a callback to the method `updateUserActivityState(_:)`, declared in `UIResponder` on iOS and `NSResponder` on macOS. This is the app’s opportunity to refresh the activity object’s `userInfo` before Handoff receives the activity. The implementation in the sample app calls a convenience function `updateViewingRegion(_:)`,  defined in an extension on `NSUserActivity`, to encode the map view’s `MKCoordinateRegion` into key-value entries in the `userInfo` dictionary.
```swift
func updateViewingRegion(_ region: MKCoordinateRegion) {
    let updateDict = [
        NSUserActivity.regionCenterLatitudeKeyString: region.center.latitude,
        NSUserActivity.regionCenterLongitudeKeyString: region.center.longitude,
        NSUserActivity.regionSpanLatitudeKeyString: region.span.latitudeDelta,
        NSUserActivity.regionSpanLongitudeKeyString: region.span.longitudeDelta]
    addUserInfoEntries(from: updateDict)
}
```

#### 
When you move to another device, macOS or iOS indicates that a Handoff activity is available. macOS displays a Handoff icon at the beginning of the Dock, with a badge indicating the type of source device. On iOS, the Handoff banner appears at the bottom of the screen in the app switcher, showing the app and source device name.
When you launch the app using the Handoff prompts, the system calls methods in `UIApplicationDelegate` (iOS) or `NSApplicationDelegate` (macOS) to provide the Handoff activity. The `application(_:continue:restorationHandler:)` method provides the activity, along with a completion handler that you call with an array of view controllers that can handle the activity.  The implementation in the iOS app delegate just finds and passes the first view controller, an instance of `MapViewController`.
```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    guard let topNav = application.keyWindow?.rootViewController as? UINavigationController,
        let mapVC = topNav.viewControllers.first as? MapViewController else {
        return false
    }
    
    mapVC.loadView()
    restorationHandler([mapVC])
    return true
}
```

```
The implementation in the macOS app delegate is similar, except that it traverses the key window’s hierarchy, rather than the iOS navigation controller stack:
```swift
func application(_ application: NSApplication, continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
    guard let mapVC = application.keyWindow?.windowController?.contentViewController as? MapViewController else {
        return false
    }
    
    mapVC.loadView()
    restorationHandler([mapVC])
    return true
}
```

#### 
The view controllers receive the `NSUserActivity` in the `restoreUserActivityState(_:)` method. `MapViewController` inspects the activity to determine whether it is the map-viewing or the store-editing activity, and then updates the UI as needed. The map-viewing activity case resets the map region, by creating a new `MKCoordinateRegion` from the values in the `userInfo`.
```swift
func viewingRegion() -> MKCoordinateRegion? {
    guard let centerLatitude = userInfo?[NSUserActivity.regionCenterLatitudeKeyString] as? CLLocationDegrees,
        let centerLongitude = userInfo?[NSUserActivity.regionCenterLongitudeKeyString] as? CLLocationDegrees,
        let spanLatitude = userInfo?[NSUserActivity.regionSpanLatitudeKeyString] as? CLLocationDegrees,
        let spanLongitude = userInfo?[NSUserActivity.regionSpanLongitudeKeyString] as? CLLocationDegrees else {
            return nil
    }
    return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLatitude,
                                                             longitude: centerLongitude),
                              span: MKCoordinateSpan(latitudeDelta: spanLatitude,
                                                     longitudeDelta: spanLongitude))
}
```

#### 
The `NSUserActivity` class has a `delegate` property of type `NSUserActivityDelegate`. This notifies the originating device when you continue an activity on another device. The originating device can use this to clean up its own UI state.
In the sample app, tapping a pin for an Apple Store shows a popover with details about the store and a switch (iOS) or checkbox (macOS) to mark the store as a favorite. The `MapViewContoller` represents this activity as the `storeEditingActivity` property, and sets itself as the activity’s delegate. When you continue editing on a second device, the delegate on the originating device receives a notification that this activity has been continued, and dismisses its own popover.
```swift
func userActivityWasContinued(_ userActivity: NSUserActivity) {
    DispatchQueue.main.async {[weak self] in
        if let detailVC = self?.presentedViewController as? StoreDetailViewController,
           userActivity.activityType == NSUserActivity.storeEditingActivityType {
            detailVC.dismiss(animated: true)
        }
    }
}
```


## Downloading files from websites
> https://developer.apple.com/documentation/foundation/downloading-files-from-websites

### 
#### 
The following example shows a simple example of creating a download task with a completion handler. If no errors are indicated, the completion handler moves the downloaded file to the app’s `Documents` directory. Start the task by calling .
Creating a download task with a completion handler
```swift
let downloadTask = URLSession.shared.downloadTask(with: url) {
    urlOrNil, responseOrNil, errorOrNil in
    // check for and handle errors:
    // * errorOrNil should be nil
    // * responseOrNil should be an HTTPURLResponse with statusCode in 200..<299
    
    guard let fileURL = urlOrNil else { return }
    do {
        let documentsURL = try
            FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        let savedURL = documentsURL.appendingPathComponent(fileURL.lastPathComponent)
        try FileManager.default.moveItem(at: fileURL, to: savedURL)
    } catch {
        print ("file error: \(error)")
    }
}
downloadTask.resume()

```

#### 
Create your own  instance, and set its `delegate` property. The following example shows a lazily instantiated `urlSession` property that sets `self` as its delegate.
Creating a URL session with a delegate
```swift
private lazy var urlSession = URLSession(configuration: .default,
                                         delegate: self,
                                         delegateQueue: nil)

```

To start downloading, use this  to create a , and then start the task by calling , as shown in in the following example.
Creating and starting a download task that uses a delegate
```swift
private func startDownload(url: URL) {
    let downloadTask = urlSession.downloadTask(with: url)
    downloadTask.resume()
    self.downloadTask = downloadTask
}

```

#### 
The following example shows an implementation of this callback method. This implementation calculates the fractional progress of the download, and uses it to update a label that shows progress as a percentage. Because the callback is performed on an unknown Grand Central Dispatch queue, you  explicitly perform the UI update on the main queue.
Using a delegate method to update download progress in a UI
```swift
func urlSession(_ session: URLSession,
                downloadTask: URLSessionDownloadTask,
                didWriteData bytesWritten: Int64,
                totalBytesWritten: Int64,
                totalBytesExpectedToWrite: Int64) {
     if downloadTask == self.downloadTask {
        let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progressLabel.text = self.percentFormatter.string(from:
                NSNumber(value: calculatedProgress))
        }
    }
}
```

#### 
When you use a delegate instead of a completion handler, you handle the completion of the download by implementing . Check the `downloadTask`‘s  property to ensure that the server response indicates success. If so, the `location` parameter provides a local URL where the file has been stored. This location is valid only until the end of the callback. This means you  either read the file immediately, or move it to another location such as the app’s `Documents` directory before you return from the callback method. The following example shows how to preserve the downloaded file.
Saving the downloaded file in the delegate callback
```swift
func urlSession(_ session: URLSession,
                downloadTask: URLSessionDownloadTask,
                didFinishDownloadingTo location: URL) {
    // check for and handle errors:
    // * downloadTask.response should be an HTTPURLResponse with statusCode in 200..<299

    do {
        let documentsURL = try
            FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        let savedURL = documentsURL.appendingPathComponent(
            location.lastPathComponent)
        try FileManager.default.moveItem(at: location, to: savedURL)
    } catch {
        // handle filesystem error
    }
}

```


## Downloading files in the background
> https://developer.apple.com/documentation/foundation/downloading-files-in-the-background

### 
#### 
4. Use the  instance to create a  instance. Provide a delegate, to receive events from the background transfer.
Creating a background URL session
```swift
private lazy var urlSession: URLSession = {
    let config = URLSessionConfiguration.background(withIdentifier: "MySession")
    config.isDiscretionary = true
    config.sessionSendsLaunchEvents = true
    return URLSession(configuration: config, delegate: self, delegateQueue: nil)
}()
```

#### 
In the following example, the task is set to begin at least one hour in the future and is configured to send around 200 bytes of data and receive around 500 KB.
Creating a download task from a URL session
```swift
let backgroundTask = urlSession.downloadTask(with: url)
backgroundTask.earliestBeginDate = Date().addingTimeInterval(60 * 60)
backgroundTask.countOfBytesClientExpectsToSend = 200
backgroundTask.countOfBytesClientExpectsToReceive = 500 * 1024
backgroundTask.resume()
```

#### 
This delegate method also receives a completion handler as its final parameter. Immediately store this handler wherever it makes sense for your app, perhaps as a property of your app delegate, or of your class that implements . In the following example, this completion handler is stored in an app delegate property called `backgroundCompletionHandler`.
Storing the background download completion handler sent to the application delegate
```swift
func application(_ application: UIApplication,
                 handleEventsForBackgroundURLSession identifier: String,
                 completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
}
```

Note that because  may be called on a secondary queue, it needs to explicitly execute the handler (which was received from a UIKit method) on the main queue.
Executing the background URL session completion handler on the main queue
```swift
func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    DispatchQueue.main.async {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let backgroundCompletionHandler =
            appDelegate.backgroundCompletionHandler else {
                return
        }
        backgroundCompletionHandler()
    }
}
```

#### 
#### 
#### 
#### 

## Encoding and Decoding Custom Types
> https://developer.apple.com/documentation/foundation/encoding-and-decoding-custom-types

### 
#### 
Consider a `Landmark` structure that stores the name and founding year of a landmark:
The simplest way to make a type codable is to declare its properties using types that are already . These types include standard library types like , , and ; and Foundation types like , , and . Any type whose properties are codable automatically conforms to  just by declaring that conformance.
Consider a `Landmark` structure that stores the name and founding year of a landmark:
```swift
struct Landmark {
    var name: String
    var foundingYear: Int
}
```

Adding  to the inheritance list for `Landmark` triggers an automatic conformance that satisfies all of the protocol requirements from  and :
```
Adding  to the inheritance list for `Landmark` triggers an automatic conformance that satisfies all of the protocol requirements from  and :
```swift
struct Landmark: Codable {
    var name: String
    var foundingYear: Int
    
    // Landmark now supports the Codable methods init(from:) and encode(to:), 
    // even though they aren't written as part of its declaration.
}
```

The example below shows how automatic  conformance applies when a `location` property is added to the `Landmark` structure:
The same principle applies to custom types made up of other custom types that are codable. As long as all of its properties are , any custom type can also be .
The example below shows how automatic  conformance applies when a `location` property is added to the `Landmark` structure:
```swift
struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
}

struct Landmark: Codable {
    // Double, String, and Int all conform to Codable.
    var name: String
    var foundingYear: Int
    
    // Adding a property of a custom Codable type maintains overall Codable conformance.
    var location: Coordinate
}
```

The example below shows how automatic conformance still applies when adding multiple properties using built-in codable types within `Landmark`:
Built-in types such as ,  , and  also conform to  whenever they contain codable types. You can add an array of `Coordinate` instances to `Landmark`, and the entire structure will still satisfy .
The example below shows how automatic conformance still applies when adding multiple properties using built-in codable types within `Landmark`:
```swift
struct Landmark: Codable {
    var name: String
    var foundingYear: Int
    var location: Coordinate
    
    // Landmark is still codable after adding these properties.
    var vantagePoints: [Coordinate]
    var metadata: [String: String]
    var website: URL?
}
```

#### 
The examples below show alternative declarations of the `Landmark` structure that only encode or decode data:
In some cases, you may not need ’s support for bidirectional encoding and decoding.  For example, some apps only need to make calls to a remote network API and do not need to decode a response containing the same type. Declare conformance to  if you only need to support the encoding of data. Conversely, declare conformance to  if you only need to read data of a given type.
The examples below show alternative declarations of the `Landmark` structure that only encode or decode data:
```swift
struct Landmark: Encodable {
    var name: String
    var foundingYear: Int
}
```

}
```
```swift
struct Landmark: Decodable {
    var name: String
    var foundingYear: Int
}
```

#### 
The example below uses alternative keys for the `name` and `foundingYear` properties of the `Landmark` structure when encoding and decoding:
If the keys used in your serialized data format don’t match the property names from your data type, provide alternative keys by specifying  as the raw-value type for the `CodingKeys` enumeration.  The string you use as a raw value for each enumeration case is the key name used during encoding and decoding. The association between the case name and its raw value lets you name your data structures according to the Swift  rather than having to match the names, punctuation, and capitalization of the serialization format you’re modeling.
The example below uses alternative keys for the `name` and `foundingYear` properties of the `Landmark` structure when encoding and decoding:
```swift
struct Landmark: Codable {
    var name: String
    var foundingYear: Int
    var location: Coordinate
    var vantagePoints: [Coordinate]
    
    enum CodingKeys: String, CodingKey {
        case name = "title"
        case foundingYear = "founding_date"
        
        case location
        case vantagePoints
    }
}
```

#### 
If the structure of your Swift type differs from the structure of its encoded form, you can provide a custom implementation of  and  to define your own encoding and decoding logic.
In the examples below, the `Coordinate` structure is expanded to support an `elevation` property that’s nested inside of an `additionalInfo` container:
```swift
struct Coordinate {
    var latitude: Double
    var longitude: Double
    var elevation: Double

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case additionalInfo
    }
    
    enum AdditionalInfoKeys: String, CodingKey {
        case elevation
    }
}
```

In the example below, the `Coordinate` structure is extended to conform to the  protocol by implementing its required initializer, :
Because the encoded form of the `Coordinate` type contains a second level of nested information, the type’s adoption of the  and  protocols uses two enumerations that each list the complete set of coding keys used on a particular level.
In the example below, the `Coordinate` structure is extended to conform to the  protocol by implementing its required initializer, :
```swift
extension Coordinate: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
        
        let additionalInfo = try values.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
        elevation = try additionalInfo.decode(Double.self, forKey: .elevation)
    }
}
```

The example below shows how the `Coordinate` structure can be extended to conform to the  protocol by implementing its required method, :
The initializer populates a `Coordinate` instance by using methods on the  instance it receives as a parameter. The `Coordinate` instance’s two properties are initialized using the keyed container APIs provided by the Swift standard library.
The example below shows how the `Coordinate` structure can be extended to conform to the  protocol by implementing its required method, :
```swift
extension Coordinate: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        
        var additionalInfo = container.nestedContainer(keyedBy: AdditionalInfoKeys.self, forKey: .additionalInfo)
        try additionalInfo.encode(elevation, forKey: .elevation)
    }
}
```


## Fetching website data into memory
> https://developer.apple.com/documentation/foundation/fetching-website-data-into-memory

### 
#### 
To create a data task that uses a completion handler, call the  method of `URLSession`. Your completion handler needs to do three things:
1. Verify that the `error` parameter is `nil`. If not, a transport error has occurred; handle the error and exit.
3. Use the `data` instance as needed.
The following example shows a `startLoad()` method for fetching a URL’s contents. It starts by using the  class’s shared instance to create a data task that delivers its results to a completion handler. After checking for local and server errors, this handler converts the data to a string, and uses it to populate a `WKWebView` outlet. Of course, your app might have other uses for fetched data, like parsing it into a data model.
Creating a completion handler to receive data-loading results
```swift
func startLoad() {
    let url = URL(string: "https://www.example.com/")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            self.handleClientError(error)
            return
        }
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
            self.handleServerError(response)
            return
        }
        if let mimeType = httpResponse.mimeType, mimeType == "text/html",
            let data = data,
            let string = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.webView.loadHTMLString(string, baseURL: url)
            }
        }
    }
    task.resume()
}

```

#### 
Declare that your class implements one or more of the delegate protocols (, , , and ). Then create the URL session instance with the initializer . You can customize the configuration instance used with this initializer. For example, it’s a good idea to set  to . That way, the session waits for suitable connectivity, rather than failing immediately if the required connectivity is unavailable.
Creating a URLSession that uses a delegate
```swift
private lazy var session: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.waitsForConnectivity = true
    return URLSession(configuration: configuration,
                      delegate: self, delegateQueue: nil)
}()
```

-  takes each `Data` instance received by the task and appends it to a buffer called `receivedData`.
-  first looks to see if a transport-level error has occurred. If there is no error, it attempts to convert the `receivedData` buffer to a string and set it as the contents of `webView`.
Using a delegate with a URL session data task
```swift
var receivedData: Data?

func startLoad() {
    loadButton.isEnabled = false
    let url = URL(string: "https://www.example.com/")!
    receivedData = Data()
    let task = session.dataTask(with: url)
    task.resume()
}

// delegate methods

func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    guard let response = response as? HTTPURLResponse,
        (200...299).contains(response.statusCode),
        let mimeType = response.mimeType,
        mimeType == "text/html" else {
        completionHandler(.cancel)
        return
    }
    completionHandler(.allow)
}

func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    self.receivedData?.append(data)
}

func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    DispatchQueue.main.async {
        self.loadButton.isEnabled = true
        if let error = error {
            handleClientError(error)
        } else if let receivedData = self.receivedData,
            let string = String(data: receivedData, encoding: .utf8) {
            self.webView.loadHTMLString(string, baseURL: task.currentRequest?.url)
        }
    }
}
```


## Handling an authentication challenge
> https://developer.apple.com/documentation/foundation/handling-an-authentication-challenge

### 
#### 
#### 
The following example tests the authentication method to see if it is the expected type, HTTP Basic. If the `authenticationMethod` property indicates some other kind of challenge, it calls the completion handler with the  disposition. Telling the task to use its default handling may satisfy the challenge; otherwise, the task will move on to the next challenge in the response and call this delegate again. This process continues until the task reaches the HTTP Basic challenge that you expect to handle.
Checking the authentication method of an authentication challenge
```swift
let authMethod = challenge.protectionSpace.authenticationMethod
guard authMethod == NSURLAuthenticationMethodHTTPBasic else {
    completionHandler(.performDefaultHandling, nil)
    return
}
```

#### 
To successfully answer the challenge, you need to submit a credential appropriate to type of challenge you have received. For HTTP Basic and HTTP Digest challenges, you provide a username and password. The following example shows a helper method that attempts to create a  instance from user-interface fields, if they are filled in.
Creating a URLCredential from user interface values
```swift
func credentialsFromUI() -> URLCredential? {
    guard let username = usernameField.text, !username.isEmpty,
        let password = passwordField.text, !password.isEmpty else {
            return nil
    }
    return URLCredential(user: username, password: password,
                         persistence: .forSession)
}
```

#### 
The following example shows both these options.
Invoking the authentication challenge completion Handler
```swift
guard let credential = credentialOrNil else {
    completionHandler(.cancelAuthenticationChallenge, nil)
    return
}
completionHandler(.useCredential, credential)
```

#### 

## Implementing Handoff in Your App
> https://developer.apple.com/documentation/foundation/implementing-handoff-in-your-app

### 
#### 
Start by identifying which activities make sense to use with Handoff. Choose activities that represent what the user is doing at some point in time, like creating a shape or editing document properties. Choose a universally-unique identifier string for each of your activities, using a reverse-DNS pattern, like `com.example.app.activity-name`.
You use your app’s `Info.plist` file to declare that your app can receive an activity from Handoff. Create a new top-level entry in this file with the key  and with the type `Array`. Each member of the array should be a `String` whose value is one of your activity identifiers. The following example shows the `Info.plist` XML source of a `NSUserActivityTypes` entry that declares three activities that the app can continue:
```other
<key>NSUserActivityTypes</key>
<array>
    <string>com.example.myapp.create-shape</string>
    <string>com.example.myapp.edit-shape</string>
    <string>com.example.myapp.edit-document-properties</string>
</array>
```

#### 
At runtime, create instances of  for each of your app’s activities. Use the same identifier strings that you used in the `Info.plist` to indicate which activities your app can continue.
The  class contains a  dictionary that you use to recreate the activity on other devices. The activity type also has a  property that you populate with the minimal set of dictionary keys to make the activity restorable. The activity also contains a user-readable  property that you should set. If the activity also supports search, the system displays this title in the search results.
```swift
let activity = NSUserActivity(activityType: "com.example.myapp.create-shape")
activity?.isEligibleForHandoff = true
activity?.requiredUserInfoKeys = ["shape-type"]
activity.title = NSLocalizedString("Creating shape", comment: "Creating shape activity")
```

#### 
As your user interacts with your app, update the user activity to save the state of their interaction. If you have set the  property of a responder, the system automatically calls its  (iOS) or  (macOS) method. Override this method to write new values to the activity’s  dictionary.
The keys and values you use in  must be of the types , , , , , , , , or  (or their Swift-bridged equivalents). Create a dictionary with any data needed to recreate the activity on the other device, then call  to update the activity. It’s also a good idea to provide a key-value pair that versions the dictionary itself. That way, you can change the activity’s dictionary representation later and be able to detect incompatible versions.
```swift
override func updateUserActivityState(_ activity: NSUserActivity) {
    if activity.activityType == "com.example.myapp.create-shape" {
        let updateDict:  [AnyHashable : Any] = [
            "shape-type" : currentShapeType(),
            "activity-version" : 1
        ]
        activity.addUserInfoEntries(from: updateDict)
    }
}
```

#### 
Handoff provides the activity to your app in the  (iOS), or  (macOS) delegate method. Implement the method by creating an array of view controllers that need to update for the activity, and provide this array to the completion handler. Return  if your implementation successfully handled the activity, or  if it did not. The following example shows an iOS app delegate finding its top view controller and providing it to the completion handler.
```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    guard let topNav = application.keyWindow?.rootViewController as? UINavigationController,
        let shapesVC = topNav.viewControllers.first as? MyShapesViewController else {
            return false
    }
    restorationHandler([shapesVC])
    return true
}

```

#### 
Each view controller provided to the completion handler in the previous step receives a call to its  (iOS), or  (macOS) method. Use this method to update the view controller’s state to match the state of the originating device. If you have several activity types, use the  to determine which activity you are handling. Then, get the values from the activity’s  dictionary to update the view controller’s state.
```swift
override func restoreUserActivityState(_ userActivity: NSUserActivity) {    super.restoreUserActivityState(userActivity)
    guard userActivity.activityType == "com.example.myapp.create-shape",
        let type = userActivity.userInfo?["shape-type"] as? String,
        let version = userActivity.userInfo?["activity-version"] as? Int,
        version >= 1 else {
            return
    }
    
    createShape(type: type)
}
```


## Improving performance and stability when accessing the file system
> https://developer.apple.com/documentation/foundation/improving-performance-and-stability-when-accessing-the-file-system

### 
#### 
#### 
#### 
When taking some action on a list of files, an app may iterate over that list and process each file sequentially, such as in a `for` or `while` loop. However, accessing files that are external to the device, such as those in iCloud Drive, may result in expensive, blocking network requests as the system must download the files before it can make them available for your app to use.
To minimize the impact, don’t perform any file I/O in the loop. Instead, use each iteration of the loop to create an instance of  and specify a background queue for the system to use when it invokes that coordinator’s `accessor` closure. By adopting this approach, you enable the system to download any remote files in a concurrent, nonblocking way, as the following example shows:
```swift
// Create a background queue for the system to use
// when invoking each file coordinator's accessor 
// closure.
let queue = OperationQueue()
queue.underlyingQueue = .global(qos: .utility)

// Iterate over the file URLs.
for url in fileURLs {
    // Create a file coordinator and specify the appropriate
    // file access intent and queue.
    let intent = NSFileAccessIntent.readingIntent(with: url)
    let coordinator = NSFileCoordinator()
    coordinator.coordinate(with: [intent],
                           queue: queue) { error in
        if let error {
            // If there's an error, handle it here.
        } else {
            // Otherwise, process the file.
        }
    }
}
```

#### 

## Increasing App Usage with Suggestions Based on User Activities
> https://developer.apple.com/documentation/foundation/increasing-app-usage-with-suggestions-based-on-user-activities

### 
#### 
You implement proactive suggestions by determining specific activities that a user can perform in your app, and whose state you can recreate at a later time. The sample app has one user activity, `view-location`, which represents the user viewing details of a specific restaurant location.
In the sample app, the target includes the `view-location` activity in its  file, as an entry with the key name . The type of this entry is `Array`, and each member is a `String` representing a supported user activity in reverse DNS notation.
```None
<key>NSUserActivityTypes</key>
<array>
<string>com.example.apple-samplecode.ProactiveToolbox.view-location</string>
</array>
```

#### 
The view controller also sets  to `true`, indicating that the activity will be updated with new data in the future, which eventually results in a callback to the  method. This is the app’s opportunity to refresh the activity object’s  property, with the minimal amount of information needed to restore the state of the app, before Siri or the system receives the activity.
```swift
/*
 Provide just enough information in the `userInfo` dictionary to be able to restore state.
 The larger the dictionary, the longer it takes to deliver that payload and resume the activity.
 */
var userInfo = [String: Any]()
do {
    let data = try NSKeyedArchiver.archivedData(withRootObject: mapItem.placemark, requiringSecureCoding: true)
    userInfo["placemark"] = data
} catch {
    os_log("Could not encode placemark data", type: .error)
}

if let phoneNumber = mapItem.phoneNumber {
    userInfo["phoneNumber"] = phoneNumber
}

activity.addUserInfoEntries(from: userInfo)
```

#### 
If your user activity objects contain information that the user might want to search for later, you can have Search index those objects and consider them during subsequent on-device searches.
To enable support for Search on a user activity object, set the  property to `true`. Additionally, you can make an activity object publicly accessible to all iOS users by setting the  property to `true`.
```swift
// The following properties enable the activity to be indexed in Search.
activity.isEligibleForPublicIndexing = true
activity.isEligibleForSearch = true
activity.title = mapItem?.name
activity.keywords = ["pizza"]
```

```
Provide the activity object with as much rich information about the activity as possible, by configuring the , , or  properties so that the system can index the object. The app must also maintain a strong reference to any activity objects that the system uses for search results.
```swift
// Provide additional searchable attributes.
activity.contentAttributeSet?.supportsNavigation = true
activity.contentAttributeSet?.supportsPhoneCall = true
activity.contentAttributeSet?.thumbnailData = #imageLiteral(resourceName: "pizza").pngData()
```

#### 
Siri learns about the shortcuts available to your app through donations that your app makes to Siri. You can make donations from a user activity when the action involves a view within your app, such as the sample app, which displays a list of nearby restaurants.
The sample app enables support for Siri Shortcuts on a user activity object by setting the  property to `true`. The app suggests an invocation phrase, which is displayed to the user when they create a shortcut, by setting a short, memorable phrase to the  property.
```swift
// The following properties enable the activity to be used as a shortcut with Siri.
activity.isEligibleForPrediction = true
activity.suggestedInvocationPhrase = "Show my favorite pizzeria"
```

#### 
If your user-activity object contains information about a webpage, your users can share that webpage with others through Siri. For example, the user can share the pizza restaurant they’re viewing by asking Siri to “share this”, to send a message that contains the webpage URL to another user. Siri uses the URL stored by the app in the  on the user activity.
```swift
// Enable sharing this location by telling Siri to "share this".
activity.webpageURL = mapItem?.url
```

#### 
When a user interacts with a proactive suggestion for your app, such as through Siri Shortcuts, the system restores your app to the foreground, receives data associated with its user activity, and calls .
To give `SearchViewController` a chance to perform its state restoration operation through , the sample app verifies the activity type of the user activity object, and passes the first tab’s view controller hierarchy to the `restorationHandler` block parameter.
```swift
func application(_ application: UIApplication,
                 continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    
    guard userActivity.activityType == "com.example.apple-samplecode.ProactiveToolbox.view-location",
        let tabBarController = window?.rootViewController as? UITabBarController,
        let navigationController = tabBarController.viewControllers?.first as? UINavigationController
        else { return false }
    
    tabBarController.selectedIndex = 0
    
    /*
     Calling the restoration handler is optional and is only needed
     when specific objects are capable of continuing the activity.
     */
    restorationHandler(navigationController.viewControllers)
    
    return true
}
```

```
The sample app validates the user activity, consumes any necessary information from the `userInfo` dictionary, and updates its UI to continue the requested activity from where the user left off.
```swift
override func restoreUserActivityState(_ activity: NSUserActivity) {
    super.restoreUserActivityState(activity)
    
    do {
        guard let userInfo = activity.userInfo,
            let url = activity.webpageURL,
            let phoneNumber = userInfo["phoneNumber"] as? String,
            let placemarkData = userInfo["placemark"] as? Data,
            let placemark = try NSKeyedUnarchiver.unarchivedObject(ofClass: MKPlacemark.self, from: placemarkData)
            else { return }
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = activity.title
        
        if navigationController?.visibleViewController == self {
            restoreMapItem(mapItem, url: url, phoneNumber: phoneNumber)
        } else if let modalController = navigationController?.visibleViewController as? LocationViewController {
            modalController.restoreMapItem(mapItem, url: url, phoneNumber: phoneNumber)
        }
    } catch {
        os_log("Could not convert user activity placemark data to placemark object", type: .error)
    }
}
```

#### 
Text fields describe the intended purpose of input data, like a region’s name or postal code, via the  property. If any app on the device recently donated information matching the expected text content type, that information is suggested in the QuickType keyboard as the user types in the text field.
For example, in the sample app, a user selects a pizza restaurant, and its address is suggested in Messages or a search field in Apple Maps.
```swift
// These properties can also be set on the field in Interface Builder.
nameTextField.textContentType = .organizationName
streetAddressLine1TextField.textContentType = .streetAddressLine1
streetAddressLine2TextField.textContentType = .streetAddressLine2
cityTextField.textContentType = .addressCity
stateTextField.textContentType = .addressState
postalCodeTextField.textContentType = .postalCode
countryOrRegionTextField.textContentType = .countryName
```


## NSComparisonMethods
> https://developer.apple.com/documentation/foundation/nscomparisonmethods

### 
If you have scriptable objects that need to perform comparisons for scripting purposes, you may need to implement some of the methods declared in NSScriptingComparisonMethods. The default implementation provided for many of these methods by `NSObject` is appropriate for objects that implement a single comparison method whose selector, signature, and description match the following:
```objc
- (NSComparisonResult)compare:(id)object;
```


## Optimizing Your App’s Data for iCloud Backup
> https://developer.apple.com/documentation/foundation/optimizing-your-app-s-data-for-icloud-backup

### 
#### 
- `/tmp`
- `/Library/Caches`
The system periodically purges these directories, so iCloud Backup excludes them by default. If your app creates purgeable data, store it in one of these directories; otherwise, iCloud Backup may include that data, needlessly increasing the physical size of the backup with no benefit to the user. Don’t use these directories to exclude nonpurgeable data from iCloud Backup.
To retrieve the location of these system-provided directories, use the  class, as the following example shows.
```swift
let manager = FileManager.default

// Get the URL to the app container's 'tmp' directory.
let tmpDirectoryURL = manager.temporaryDirectory

// Get the URL to the app container's 'Caches' directory.
let cachesDirectoryURL = try manager.url(for: .cachesDirectory,
                                         in: .userDomainMask,
                                         appropriateFor: nil,
                                         create: false)
```

#### 
For example, if your app downloads high-definition movies for offline viewing, exclude those files because they’re typically large in size and the user can download them again on a restored device, if necessary. Conversely, if your app allows the user to import arbitrary files such as PDFs, ebooks, and digital comics, don’t exclude those files because it might be difficult, even impossible, for the user to re-create them on a restored device.
If your app creates nonpurgeable data that isn’t appropriate for backup, you can indicate which files and directories the system can exclude by setting their  resource value to , as the following example shows.
```swift
func excludeItem(at url: URL) throws {
    // Create the resource values for the specified URL.
    var values = URLResourceValues()
    values.isExcludedFromBackup = true

    // Apply those values to the URL.
    var url = url
    try url.setResourceValues(values)
}
```

The  resource value exists only to provide guidance to the system about which files and directories it can exclude; it’s not a mechanism to guarantee those items never appear in a backup or on a restored device.
To indicate the system can exclude a group of related files from iCloud Backup, move those files into a directory and update the directory’s  resource value. If you create an excludable directory inside the app container’s `Library` directory, consider naming the directory with the app’s bundle identifier to avoid potential conflicts with directories the system may create there in the future.
```swift
let manager = FileManager.default

// Retrieve the app's bundle identifier.
if let bundleIdentifier = Bundle.main.bundleIdentifier {
    
    // Get the URL to the app container's 'Library' directory.
    var url = try manager.url(for: .libraryDirectory,
                              in: .userDomainMask,
                              appropriateFor: nil,
                              create: false)
    
    // Append the bundle identifier to the retrieved URL.
    url.appendPathComponent(bundleIdentifier, isDirectory: true)
    
    // Use the URL to create the new directory.
    try manager.createDirectory(at: url,
                                withIntermediateDirectories: true,
                                attributes: nil)
}
```


## Pausing and resuming downloads
> https://developer.apple.com/documentation/foundation/pausing-and-resuming-downloads

### 
#### 
You cancel a  by calling . This method takes a completion handler which is called once the cancellation is complete. The completion handler receives a `resumeData` parameter. If it it not `nil`, this is the token you use later to resume the download. The following example shows how to cancel a download task and store `resumeData`, if it exists, in a property.
Storing the resume data when canceling a download
```swift
downloadTask.cancel { resumeDataOrNil in
    guard let resumeData = resumeDataOrNil else { 
      // download can't be resumed; remove from UI if necessary
      return
    }
    self.resumeData = resumeData
}

```

#### 
The following example shows an implementation of  that retrieves and saves the `resumeData` object, if any, from the error.
When the download fails, the session calls your  delegate method. If `error` is not `nil`, look in its `userInfo` dictionary for the key . If the key exists, save the value associated with it to use later when you try to resume the download. If the key does not exist, the download can’t be resumed.
The following example shows an implementation of  that retrieves and saves the `resumeData` object, if any, from the error.
```swift
func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let error = error else {
        // Handle success case.
        return
    }
    let userInfo = (error as NSError).userInfo
    if let resumeData = userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
        self.resumeData = resumeData
    } 
    // Perform any other error handling.
}

```

#### 
When it’s appropriate to resume the download, create a new  by using the  or  method of , passing in the `resumeData` object you stored earlier. Then call  on the task to resume the download.
Creating and starting a download task from resume data
```swift
guard let resumeData = resumeData else {
    // inform the user the download can't be resumed
    return
}
let downloadTask = urlSession.downloadTask(withResumeData: resumeData)
downloadTask.resume()
self.downloadTask = downloadTask

```


## Pausing and resuming uploads
> https://developer.apple.com/documentation/foundation/pausing-and-resuming-uploads

### 
#### 
You can effectively pause a  by calling . This method cancels the task and passes a `resumeData` parameter to its completion handler. If `resumeData` is not `nil`, you can use this token later to resume the upload. The listing below shows how to cancel an upload task and store `resumeData`, if it exists, in a property:
```swift
uploadTask.cancel { resumeData in
    guard let resumeData else { 
      // The upload can't be resumed; remove the upload from the UI if necessary.
      return
    }
    self.resumeData = resumeData
}
```

#### 
You can conveniently access resume data using the  property of .
You can also catch the error from asynchronous  upload methods such as . The listing below shows an implementation of this error handling that checks the error for resume data:
```swift
do {
    let (data, response) = try await session.upload(for: request, fromFile: fileURL)
} catch let error as URLError {
    guard let resumeData = error.uploadTaskResumeData else {
        // The upload can't be resumed.
        return
    }
    self.resumeData = resumeData
}
```

#### 
When it’s appropriate to resume the upload, create a new  by using the  method of , passing in the `resumeData` object you stored earlier. Then, call  on the task to resume the upload:
```swift
guard let resumeData = self.resumeData else {
    // Inform the user that the upload can't be resumed.
    return
}

let uploadTask = session.uploadTask(withResumeData: resumeData)
uploadTask.resume()
self.uploadTask = uploadTask
```


## Performing manual server trust authentication
> https://developer.apple.com/documentation/foundation/performing-manual-server-trust-authentication

### 
#### 
#### 
The following example shows how to test these conditions, given the `challenge` parameter passed to the  callback. It gets the challenge’s  and uses it to perform the two checks listed above. First, it gets the  from the protection space and checks that the type of authentication is . Then it makes sure the protection space’s  matches the expected name `example.com`. If either of these conditions are not met, it calls the `completionHandler` with the  disposition to allow the system to handle the challenge.
Testing the challenge type and host name of a server trust authentication challenge.
```swift
let protectionSpace = challenge.protectionSpace
guard protectionSpace.authenticationMethod ==
    NSURLAuthenticationMethodServerTrust,
    protectionSpace.host.contains("example.com") else {
        completionHandler(.performDefaultHandling, nil)
        return
}
```

#### 
To access the server’s credential, get the  property (an instance of the  class) from the protection space. The following example shows how to access the server trust and accept or reject it. The listing starts by attempting to get the  property from the protection space, and falls back to default handling if the property is `nil`. Next, it passes the server trust to a private helper method `checkValidity(of:)` that compares the certificate or public key in the server trust to known-good values stored in the app bundle.
Evaluating credentials in a server trust instance.
```swift
guard let serverTrust = protectionSpace.serverTrust else {
    completionHandler(.performDefaultHandling, nil)
    return
}
if checkValidity(of: serverTrust) {
    let credential = URLCredential(trust: serverTrust)
    completionHandler(.useCredential, credential)
} else {
    // Show a UI here warning the user the server credentials are
    // invalid, and cancel the load.
    completionHandler(.cancelAuthenticationChallenge, nil)
}
```

#### 

## Supporting suggestions in your app’s share extension
> https://developer.apple.com/documentation/foundation/supporting-suggestions-in-your-app-s-share-extension

### 
#### 
#### 
#### 
Donate an  only when a person sends or receives a message in your app and its share extension. Donate a  along with  for  and  by adding values to the contact  field when initializing an .
As you initialize the  object, provide metadata that’s available later when a person choses your app’s share extension from the list of suggestions. The following code snippet donates an  with a , a , and an .
```swift
// Create an INSendMessageIntent to donate an intent for a conversation with Juan Chavez.
let groupName = INSpeakableString(spokenPhrase: "Juan Chavez")
let sendMessageIntent = INSendMessageIntent(recipients: nil,
                                            content: nil,
                                            speakableGroupName: groupName,
                                            conversationIdentifier: "sampleConversationIdentifier",
                                            serviceName: nil,
                                            sender: nil)

// Add the person's avatar to the intent.
let image = INImage(named: "Juan Chavez")
sendMessageIntent.setImage(image, forParameterNamed: \.speakableGroupName)

// Donate the intent.
let interaction = INInteraction(intent: sendMessageIntent, response: nil)
interaction.donate(completion: { error in
    if error != nil {
        // Add error handling here.
    } else {
        // Do something, for example, send the content to a contact.
    }
})
```

#### 
When a person selects your app from the list of suggestions, you can access the metadata that you created when your app donated the . Use it to populate your share extension’s interface.
The following code listing shows a template implementation for an  subclass. It accesses the  property, makes sure it’s an , and uses the intent’s  to create a new `Recipient` object. It then uses the `Recipient` object to populate the share extension’s interface in the  method.
```swift
import Intents
import Social
import UIKit

class ShareViewController: SLComposeServiceViewController {

    var recipient: Recipient = Recipient(withName: "Placeholder")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the recipient property with the metadata in case the person taps a suggestion from the share sheet.
        let intent = self.extensionContext?.intent as? INSendMessageIntent
        if intent != nil {
            let conversationIdentifier = intent!.conversationIdentifier
            self.recipient = recipient(identifier: conversationIdentifier!)
        }
    }

    func recipient(identifier: String) -> Recipient {
        // Create a recipient object, for example, by loading it from a data base.
        return Recipient(withName: identifier)
    }

    override func isContentValid() -> Bool {
        // Validate contentText and NSExtensionContext attachments here.
        return true
    }

    override func didSelectPost() {
        // This is called after the person selects Post. Upload contentText and NSExtensionContext attachments.
        
        // Inform the host that the selection is done, so it unblocks its UI.
        // Note: Alternatively, you could call super's -didSelectPost, which similarly completes the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        
        // Use the Recipient object to populate the share sheet.
        let item = SLComposeSheetConfigurationItem()
        item?.title = NSLocalizedString("To:", comment: "The To: label when sharing content.")
        item?.value = self.recipient.name
        item?.tapHandler = {
            self.validateContent()
            item!.value = self.recipient.name
        }
        
        return [item!]
    }
}
```


## Synchronizing App Preferences with iCloud
> https://developer.apple.com/documentation/foundation/synchronizing-app-preferences-with-icloud

### 
### 
1. In the Xcode project, open the target’s `PrefsInCloud.entitlements` file.
### 
The sample uses  to register as an observer to the notification . The following example installs the app as the observer to respond to the key-value store changes:
```swift
NotificationCenter.default.addObserver(self,
    selector: #selector(ubiquitousKeyValueStoreDidChange(_:)),
    name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
    object: NSUbiquitousKeyValueStore.default)
```

### 
This sample examines the reason for the change through the use the  from the notification’s `userInfo`.
The sample implements the function `ubiquitousKeyValueStoreDidChange` for listening for key-value notification changes. This function is called when the key-value store in the cloud has changed externally. It replaces the old key-value color with the new one. Additionally, this function updates the  key-value.
This sample examines the reason for the change through the use the  from the notification’s `userInfo`.
```swift
guard let userInfo = notification.userInfo else { return }

// Get the reason for the notification (initial download, external change or quota violation change).
guard let reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else { return }
```

To obtain key-values that have changed, use the key  from the notification’s  `userInfo`.
- : The user has changed the primary iCloud account.
To obtain key-values that have changed, use the key  from the notification’s  `userInfo`.
```swift
guard let keys =
          userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
```

          userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
```
```swift
let possibleColorIndexFromiCloud =
          NSUbiquitousKeyValueStore.default.longLong(forKey: gBackgroundColorKey)
```


## Uploading data to a website
> https://developer.apple.com/documentation/foundation/uploading-data-to-a-website

### 
#### 
Many web service endpoints take JSON-formatted data, which you create by using the   class on  types like arrays and dictionaries. As shown in the following example, you can declare a structure that conforms to , create an instance of this type, and use  to encode the instance to JSON data for upload.
Preparing JSON data for upload
```swift
struct Order: Codable {
    let customerId: String
    let items: [String]
}

// ...

let order = Order(customerId: "12345",
                  items: ["Cheese pizza", "Diet soda"])
guard let uploadData = try? JSONEncoder().encode(order) else {
    return
}
```

#### 
An upload task requires a  instance. As shown in the following example, set the  property of the request to `"``POST``"` or `"PUT"`, depending on what the server supports and expects. Use the  method to set the values of any HTTP headers that you want to provide, except the `Content-Length` header. The session figures out content length automatically from the size of your data.
Configuring a URL request
```swift
let url = URL(string: "https://example.com/post")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
```

#### 
To begin an upload, call  on a  instance to create an uploading  instance, passing in the request and the data instances you’ve previously set up. Because tasks start in a suspended state, you begin the network loading process by calling  on the task. The following example uses the shared `URLSession` instance, and receives its results in a completion handler. The handler checks for transport and server errors before using any returned data.
Starting an upload task
```swift
let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
    if let error = error {
        print ("error: \(error)")
        return
    }
    guard let response = response as? HTTPURLResponse,
        (200...299).contains(response.statusCode) else {
        print ("server error")
        return
    }
    if let mimeType = response.mimeType,
        mimeType == "application/json",
        let data = data,
        let dataString = String(data: data, encoding: .utf8) {
        print ("got data: \(dataString)")
    }
}
task.resume()
```

#### 

## Uploading streams of data
> https://developer.apple.com/documentation/foundation/uploading-streams-of-data

### 
#### 
Begin by creating a URLSession and providing it with a delegate. The following example creates a URL session with the default  and sets `self` as the delegate. You’ll implement  later, in .
Creating a URLSession with a delegate
```swift
lazy var session: URLSession = URLSession(configuration: .default,
                                          delegate: self,
                                          delegateQueue: .main)

```

#### 
Create the upload task with the  method . This takes a  specifying the URL you want to upload to, along with other parameters. You start the task by calling . The following example shows how to create and start an upload task, connecting to a server on the local machine (`127.0.0.1`) listening on port `12345`.
Creating an upload task
```swift
let url = URL(string: "http://127.0.0.1:12345")!
var request = URLRequest(url: url,
                         cachePolicy: .reloadIgnoringLocalCacheData,
                         timeoutInterval: 10)
request.httpMethod = "POST"
let uploadTask = session.uploadTask(withStreamedRequest: request)
uploadTask.resume()
```

#### 
The following example shows a structure called `Streams` that consists of an  and an . The listing creates a property of this type, called `boundStreams`, by calling the  method of the  class, passing in in-out references for the input and output streams.
Creating a bound pair of input and output streams
```swift
struct Streams {
    let input: InputStream
    let output: OutputStream
}
lazy var boundStreams: Streams = {
    var inputOrNil: InputStream? = nil
    var outputOrNil: OutputStream? = nil
    Stream.getBoundStreams(withBufferSize: 4096,
                           inputStream: &inputOrNil,
                           outputStream: &outputOrNil)
    guard let input = inputOrNil, let output = outputOrNil else {
        fatalError("On return of `getBoundStreams`, both `inputStream` and `outputStream` will contain non-nil streams.")
    }
    // configure and open output stream
    output.delegate = self
    output.schedule(in: .current, forMode: .default)
    output.open()
    return Streams(input: input, output: output)
}()

```

#### 
You provide the input stream to the upload task in your implementation of the  method , which is called after you start the upload task by calling . The callback passes in a completion handler, which you call directly, passing in the `boundStreams.input` stream you created earlier. The following example shows an implementation of this method.
Providing the input stream to the upload task in the delegate callback
```swift
func urlSession(_ session: URLSession, task: URLSessionTask,
                needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
    completionHandler(boundStreams.input)
}
```

#### 
While handling stream events, also check whether `eventCode` is . This means that the stream has failed. When this happens, close the streams and abandon the upload.
Handling StreamDelegate events
```swift
func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    guard aStream == boundStreams.output else {
        return
    }
    if eventCode.contains(.hasSpaceAvailable) {
        canWrite = true
    }
    if eventCode.contains(.errorOccurred) {
        // Close the streams and alert the user that the upload failed.
    }
}

```

The following example uses a timer to wait for the private `canWrite` property to become true. Once this is the case, the code creates a string representing the current date and converts it to raw bytes. The listing then calls  to send these bytes to the output stream. Because this output stream is bound to an input stream, the upload task can then automatically read these bytes from the input stream and send them to the destination URL.
Creating a timer to write to the output stream when the stream has space available
```swift
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
    [weak self] timer in
    guard let self = self else { return }

    if self.canWrite {
        let message = "*** \(Date())\r\n"
        guard let messageData = message.data(using: .utf8) else { return }
        let messageCount = messageData.count
        let bytesWritten: Int = messageData.withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) in
            self.canWrite = false
            return self.boundStreams.output.write(buffer, maxLength: messageCount)
        }
        if bytesWritten < messageCount {
            // Handle writing less data than expected.
        }
    }
}

```


## Using JSON with custom types
> https://developer.apple.com/documentation/foundation/using-json-with-custom-types

### 
This sample defines a simple data type, `GroceryProduct`, and demonstrates how to construct instances of that type from several different JSON formats.
```swift
struct GroceryProduct: Codable {
    var name: String
    var points: Int
    var description: String?
}
```

#### 
Use Swift’s expressive type system to avoid manually looping over collections of identically structured objects. This playground uses array types as values to see how to work with JSON that’s structured like this:
```swift
[
    {
        "name": "Banana",
        "points": 200,
        "description": "A banana grown in Ecuador."
    }
]
```

#### 
Learn how to map data from JSON keys into properties on your custom types, regardless of their names. For example, this playground shows how to map the `"product_name"` key in the JSON below to the `name` property on `GroceryProduct`:
```swift
{
    "product_name": "Banana",
    "product_cost": 200,
    "description": "A banana grown in Ecuador."
}
```

#### 
Learn how to ignore structure and data in JSON that you don’t need in your code. This playground uses an intermediate type to see how to extract grocery products from JSON that looks like this to skip over unwanted data and structure:
```swift
[
    {
        "name": "Home Town Market",
        "aisles": [
            {
                "name": "Produce",
                "shelves": [
                    {
                        "name": "Discount Produce",
                        "product": {
                            "name": "Banana",
                            "points": 200,
                            "description": "A banana that's perfectly ripe."
                        }
                    }
                ]
            }
        ]
    }
]
```

#### 
Combine or separate data from different depths of a JSON structure by writing custom implementations of protocol requirements from `Encodable` and `Decodable`. This playground shows how to construct a `GroceryProduct` instance from JSON that looks like this:
```None
{
    "Banana": {
        "points": 200,
        "description": "A banana grown in Ecuador."
    }
}
```


