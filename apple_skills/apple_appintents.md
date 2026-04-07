# Apple APPINTENTS Skill


## Accelerating app interactions with App Intents
> https://developer.apple.com/documentation/appintents/acceleratingappinteractionswithappintents

### 
#### 
The sample app includes two key features that people are likely to use frequently: looking up information on a trail, and recording activity on a trail. To make it easy for people to use these features without even opening the app, the sample code creates intents for them to use with Siri, Spotlight search, and Shortcuts. For example, if someone saves their favorite trails in the app and wants to get the current conditions for those trails, the app implements the `OpenFavorites` structure, which conforms to . When someone runs this intent, the app opens and navigates to the Favorites view.
```swift
/// Each intent needs to include metadata, such as a localized title. The title of the intent displays throughout the system.
static let title: LocalizedStringResource = "Open Favorite Trails"

/// An intent can optionally provide a localized description that the Shortcuts app displays.
static let description = IntentDescription("Opens the app and goes to your favorite trails.")

/// Tell the system to bring the app to the foreground when the intent runs.
static let openAppWhenRun: Bool = true

/**
 When the system runs the intent, it calls `perform()`.
 
 Intents run on an arbitrary queue. Intents that manipulate UI need to annotate `perform()` with `@MainActor`
 so that the UI operations run on the main actor.
 */
@MainActor
func perform() async throws -> some IntentResult {
    navigationModel.selectedCollection = trailManager.favoritesCollection
    
    /// Return an empty result, indicating that the intent is complete.
    return .result()
}
```

#### 
People may ask Siri to show their favorite trails, or they may find this suggested action through a Spotlight search. To support both of these options, the app implements an  using `OpenFavorites`. An App Shortcut combines an intent with phrases people may use with Siri to perform the action, and additional metadata, such as an icon, and then uses this information in a Spotlight search. People can invoke the App Shortcut with a suggested phrase, or other similiar words, because the system uses a semantic similarity index to help identify people’s requests — automatically matching phrases that are similar, but not identical.
```swift
AppShortcut(intent: OpenFavorites(), phrases: [
    "Open Favorites in \(.applicationName)",
    "Show my favorite \(.applicationName)"
],
shortTitle: "Open Favorites",
systemImageName: "star.circle")
```

To aid the system’s presentation of the App Shortcut, the sample app includes a short title and an SF Symbols name that represent the App Shortcut. Further, the sample app’s `Info.plist` file declares `NSAppIconActionTintColorName` with the app’s primary color and two contrasting colors in an array for the `NSAppIconComplementingColorNames` key. The system uses these colors when displaying the App Shortcuts, such as in Spotlight or the Shortcuts app. The specified values of the color names for these keys come from the app’s asset catalog.
After registering an App Shortcut with the system, people can begin using the intent through Siri without any further configuration. To teach people a phrase to use the intent, the app provides a  in the associated view.
```swift
SiriTipView(intent: OpenFavorites(), isVisible: $displaySiriTip)
```

The `SiriTipView` takes a binding to a visibility Boolean so that the app hides the view if an individual chooses to dismiss it.
#### 
Even though the app doesn’t provide `GetTrailInfo` as an App Shortcut, people may still interact with it through Siri, such as including the intent in a shortcut they create in the Shortcuts app. For a good user experience, this intent provides its result with a visual response using a custom UI snippet, and as a dialog for Siri to communicate the same information. It does so by conforming the return type of the intent’s  function to both  and .
```swift
func perform() async throws -> some IntentResult & ReturnsValue<TrailEntity> & ProvidesDialog & ShowsSnippetView {
```

```
The app provides both visual experiences and voice-only experiences because people may be in a context where they can’t see information in a custom UI (such as when the intent runs on HomePod), or when displaying the custom UI may be inappropriate (such as when the intent runs through CarPlay). This implementation provides a custom UI with a shorter supporting dialog to use when the custom UI is visible, and a different dialog containing additional information if the system can’t show the snippet. The sample uses a transparent background for the custom UI because the system displays it over a translucent background material. Avoiding opaque backgrounds provides the best results.
```swift
let snippet = TrailInfoView(trail: trailData, includeConditions: true)

/**
 This intent displays a custom view that includes the trail conditions as part of the view. The dialog includes the trail conditions when
 the system can only read the response, but not display it. When the system can display the response, the dialog omits the trail
 conditions.
 */
let dialog = IntentDialog(full: "The latest reported conditions for \(trail.name) indicate: \(trail.currentConditions).",
                          supporting: "Here's the latest information on trail conditions.")

return .result(value: trail, dialog: dialog, view: snippet)
```

```
This sample app provides custom dialog throughout its intents. `SuggestTrails` validates the parameters that people provide and uses the custom dialog to prompt them for additional information. For example, if the provided location parameter isn’t specific enough, the intent prompts the individual to choose from a list of locations related to their input. The app does this by throwing  with a value for the dialog parameter.
```swift
let dialog = IntentDialog("Multiple locations match \(location). Did you mean one of these locations?")
let disambiguationList = suggestedMatches.sorted(using: KeyPathComparator(\.self, comparator: .localizedStandard))
throw $location.needsDisambiguationError(among: disambiguationList, dialog: dialog)
```

#### 
An app intent can optionally require certain parameters to complete its action. For example, the `GetTrailInfo` intent declares a `trail` parameter by decorating the property with the  property wrapper.
```swift
@Parameter(title: "Trail", description: "The trail to get information for.")
var trail: TrailEntity
```

The system supports parameters using common Foundation types, such as , and those for custom data types in an app. The app makes its trail data available in an app intent through the `TrailEntity` type, which is a structure conforming to the  protocol.
To allow the system to query the app for `TrailEntity` data, the entity implements the  protocol with values that are stable and persistent. `TrailEntity` declares , which the system uses to perform queries to receive `TrailEntity` structures.
```swift
static let defaultQuery = TrailEntityQuery()
```

An `AppEntity` makes its properties available to the system by decorating it with the  property wrapper.
```
An `AppEntity` makes its properties available to the system by decorating it with the  property wrapper.
```swift
/**
 The trail's name. The `EntityProperty` property wrapper makes this property's data available to the system as part of the intent,
 such as when an intent returns a trail in a shortcut.
 
 The system automatically generates the title for this property from the variable name when it displays it in a system UI, like Shortcuts.
 Generated titles are available for both `EntityProperty` and `IntentIntentParameter` property wrappers.
 */
@Property var name: String

/**
 A description of the trail's location, such as a nearby city name, or the national park encompassing it.
 
 If you want the displayed title for the property to be different from the variable name, use a `title` parameter with the
 `EntityProperty` property wrapper.
 */
@Property(title: "Region")
var regionDescription: String

```

#### 
The system queries the app for its trail data through `TrailEntityQuery`, a type conforming to . For example, if someone saves a specific value as the `trail` parameter for `GetTrailInfo`, the system locates the `TrailEntity` by using the `defaultQuery` and requesting the entity by its ID from the `Identifable` protocol. All types conforming to `EntityQuery` need to implement this method.
```swift
func entities(for identifiers: [TrailEntity.ID]) async throws -> [TrailEntity] {
    Logger.entityQueryLogging.debug("[TrailEntityQuery] Query for IDs \(identifiers)")
    
    return trailManager.trails(with: identifiers)
            .map { TrailEntity(trail: $0) }
}
```

```
The app also provides a list of common trail suggestions by implementing the optional  function.
```swift
func suggestedEntities() async throws -> [TrailEntity] {
    Logger.entityQueryLogging.debug("[TrailEntityQuery] Request for suggested entities")
    
    return trailManager.trails(with: trailManager.favoritesCollection.members)
            .map { TrailEntity(trail: $0) }
}
```

There are several subprotocols to `EntityQuery`, each of which enables different types of functionality. The sample app implements all of them for demonstration purposes, but a real app can use only the ones that meet its needs.
The app implements  to help people configure `GetTrailInfo`. When people configure this intent in the Shortcuts app, they first see the list of trails from `suggestedEntities`. The Shortcuts app provides a search field, enabling people to search for results that appear in the list of suggested trails. The app provides results for the search term by implementing .
```swift
func entities(matching string: String) async throws -> [TrailEntity] {
    Logger.entityQueryLogging.debug("[TrailEntityQuery] String query for term \(string)")
    
    return trailManager.trails { trail in
        trail.name.localizedCaseInsensitiveContains(string)
    }.map { TrailEntity(trail: $0) }
}
```

#### 
Apps implementing either the  or the  protocol automatically add a Find intent in the Shortcuts app. These intents enable people to build powerful new features for themselves in Shortcuts, powered by the app’s data — without requiring the app to implement that feature itself. For example, the sample app focuses its UI on providing trail information, but people can also use its data to plan activities for a vacation. The app doesn’t need to build vacation-planning features because it implements these entity query protocols to provide an interface to the data through a Shortcut.
The sample app groups trails into collections based on geographic region, and implements the collections as a type called `TrailCollection` that conforms to `AppEntity`. The list of geographic regions is small, and a `TrailCollection` is a simple structure with the collection name and a list of trail IDs that require little memory. To make this information available through a Find intent, the app implements `FeaturedCollectionEntityQuery` with conformance to `EnumerableEntityQuery`. The app uses `EnumerableEntityQuery` here because the data for the featured trail collections is a small and fixed set of values, and doesn’t require a large amount of memory. The app implements  to return all of the values, which people can filter by name in the Shortcuts app.
```swift
func allEntities() async throws -> [TrailCollection] {
    Logger.entityQueryLogging.debug("[FeaturedCollectionEntityQuery] Request for all entities")
    return trailManager.featuredTrailCollections
}
```

- `SuggestTrails` can use the output of the Find intent for trail collections as input.
- The Find intent for trails can use the output of `SuggestTrails` to further refine the results.
#### 
The sample app provides its trail data to Spotlight when the app first runs. The app declares a `Trail` structure for this data, containing the app’s internal representation of that data. The app maps its data from the structure to searchable attributes in a .
```swift
var searchableAttributes: CSSearchableItemAttributeSet {
    let attributes = CSSearchableItemAttributeSet()
    
    attributes.title = name
    attributes.namedLocation = regionDescription
    attributes.keywords = activities.localizedElements
    
    attributes.latitude = NSNumber(value: coordinate.latitude)
    attributes.longitude = NSNumber(value: coordinate.longitude)
    attributes.supportsNavigation = true
    
    return attributes
}
```

```
The app also declares a `TrailEntity` structure to make the trail data available to the rest of the system as part of its App Intents integration. To integrate `TrailEntity` with Spotlight, `TrailEntity` conforms to . The app associates the searchable attributes from the `Trail` structure with the `TrailEntity` by calling  before contributing the data to the Spotlight index.
```swift
// Create an array of the searchable information for each `Trail`.
let searchableItems = trails.map { trail in
    let item = CSSearchableItem(uniqueIdentifier: String(trail.id),
                                domainIdentifier: nil,
                                attributeSet: trail.searchableAttributes)
    
    let isFavorite = favoritesCollection.members.contains(trail.id)
    let weight = isFavorite ? 10 : 1
    let intent = TrailEntity(trail: trail)
    
    /**
     Associate `TrailEntity` with the data that the `Trail` structure provides so the system recognizes that
     both types represent the same data. You need to create this association before adding the `CSSearchableItem`
     to a `CSSearchableIndex`.
     */
    item.associateAppEntity(intent, priority: weight)
    return item
}

do {
    // Add the trails to the search index so people can find them through Spotlight.
    // You need to do this as part of the app's initial setup on launch.
    let index = CSSearchableIndex.default()
    try await index.indexSearchableItems(searchableItems)
    Logger.spotlightLogging.info("[Spotlight] Trails indexed by Spotlight")
} catch let error {
    Logger.spotlightLogging.error("[Spotlight] Trails were not indexed by Spotlight. Reason: \(error.localizedDescription)")
}
```

#### 
The sample app offers an `OpenTrail` intent so that people can open the app to a specific trail’s information from a shortcut. Rather than adding code to configure the app’s UI for displaying a trail’s information just for this intent, the app uses the same URL scheme it uses to implement universal links. The app declares the URL for a trail’s details through conformance to .
```swift
extension TrailEntity: URLRepresentableEntity {
    static var urlRepresentation: URLRepresentation {
        // Use string interpolation to fill values from your entity necessary for constructing the universal link URL.
        // This example URL uses the unique and persistant identifier for the `TrailEntity` in the URL.
        "https://example.com/trail/\(.id)/details"
    }
}
```


## Adding parameters to an app intent
> https://developer.apple.com/documentation/appintents/adding-parameters-to-an-app-intent

### 
Many of your app’s actions likely require input data to perform their work. To help people provide the input that an  needs to perform its functionality, add parameters to the intent to tell the system about that data and whether it’s required or optional. When you expose these parameters, people can configure your intents with values unique to their requirements and enable the App Intents framework to mediate with system experiences to write those values at runtime.
For example, the  sample code project’s `GetTrailInfo` intent lets people choose which hiking trail information to view when they invoke the app intent. It declares a `trail` parameter by decorating the `trail` property with the  property wrapper and provides a title and a description to identify the parameter in the Shortcuts app.
```swift
@Parameter(title: "Trail", description: "The trail to get information on.")
var trail: TrailEntity
```

#### 
How you define your parameter variables determines whether the system treats that parameter as required or optional. If you define a variable as a non-optional type, the system knows the parameter is required and, when necessary, requests a value. Conversely, if you define a variable as an optional type, the system assumes the parameter is optional and doesn’t request a value. In this scenario, use the property wrapper’s  method to pause execution and request a value if the intent can’t proceed otherwise.
```swift
guard let date = date else {
    throw $date.requestValue("What date would you like to use?")
}
```

#### 
You can use the `@Parameter` property wrapper with common Swift and Foundation types:
#### 
#### 
- At runtime, specify an options provider as part of the property wrapper’s declaration. An  is a type you implement that conforms to the  protocol and provides a set of permitted values at runtime.
For example, the  sample code project uses a dynamic options provider to display a sorted list of location parameters in the Shortcuts app.
```swift
struct LocationOptionsProvider: DynamicOptionsProvider {
    
    @Dependency
    private var trailManager: TrailDataManager
    
    func results() async throws -> [String] {
        Logger.intentLogging.debug("Getting locations from LocationOptionsProvider")
        
        // Get a list of locations and return it sorted for display, such as in the Shortcuts app.
        return trailManager.uniqueLocations
                .sorted(using: KeyPathComparator(\.self, comparator: .localizedStandard))
    }
}
```

#### 
A parameter summary is a visual, textual outline of your app intent that the Shortcuts app displays in the shortcut editor. The summary can include placeholders that people interact with to choose the values for the intent’s parameters. Even if your intent doesn’t expose any parameters, providing a summary is an opportunity to present more information about your intent in addition to its title.
To add a parameter summary to your intent, implement the protocol’s  requirement and use the provided  result builder to build the summary. Write the content using localized natural language and, where applicable, substitute words that represent parameters with the key paths to those parameters.
```swift
static var parameterSummary: some ParameterSummary {
        Summary("Get information on \(\.$trail)")
    }
```

For example, the  sample code project uses  in its `SuggestedTrails` app intent:
Parameter summaries can include conditional statements such as  and  that let the summary update itself in response to already chosen values.
For example, the  sample code project uses  in its `SuggestedTrails` app intent:
```swift
    static var parameterSummary: some ParameterSummary {
        Switch(\.$activity) {
            Case(.biking) {
                When(\.$location, .hasAnyValue) {
                    Summary("Ride a bike within \(\.$searchRadius) of \(\.$location)")
                } otherwise: {
                    When(\.$trailCollection, .hasAnyValue) {
                        Summary("Pick a bike ride from \(\.$trailCollection)")
                    } otherwise: {
                        Summary("Suggest bike rides from \(\.$trailCollection) or near \(\.$location)")
                    }
                }
            }
            DefaultCase() {
                When(\.$location, .hasAnyValue) {
                    Summary("Suggest \(\.$activity) trails within \(\.$searchRadius) of \(\.$location)")
                } otherwise: {
                    When(\.$trailCollection, .hasAnyValue) {
                        Summary("Suggest \(\.$activity) trails from \(\.$trailCollection)")
                    } otherwise: {
                        Summary("Suggest \(\.$activity) trails from \(\.$trailCollection) or near \(\.$location)")
                    }
                }
            }
        }
    }
```

#### 

## Adopting App Intents to support system experiences
> https://developer.apple.com/documentation/appintents/adopting-app-intents-to-support-system-experiences

### 
#### 
The app contains many actions and makes them available to the system as app intents, so people can use them to create custom shortcuts and invoke across system experiences. For example, the app offers key actions like finding the closest landmark or opening a landmark in the app. This app intent opens a landmark in the app:
```swift
import AppIntents

struct OpenLandmarkIntent: OpenIntent {
    static let title: LocalizedStringResource = "Open Landmark"

    @Parameter(title: "Landmark", requestValueDialog: "Which landmark?")
    var target: LandmarkEntity

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
```

```
To use your data as input and output of app intents and make the data available to the system, you use app entities. App entities often limit the information a model object you persist to storage to what the system needs. They also add required information to understand the data or to use it in system experiences. For example, the `LandmarkEntity` of the sample app provides required `typeDisplayRepresentation` and `displayRepresentation` properties but doesn’t include every property of the `Landmark` model object:
```swift
struct LandmarkEntity: IndexedEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        return TypeDisplayRepresentation(
            name: LocalizedStringResource("Landmark", table: "AppIntents", comment: "The type name for the landmark entity"),
            numericFormat: "\(placeholder: .int) landmarks"
        )
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(continent)",
            image: .init(data: try! self.thumbnailRepresentationData)
        )
    }

    static let defaultQuery = LandmarkEntityQuery()

    var id: Int { landmark.id }

    @ComputedProperty(indexingKey: \.displayName)
    var name: String { landmark.name }

    // Maps the description variable to the Spotlight indexing key `contentDescription`.
    @ComputedProperty(indexingKey: \.contentDescription)
    var description: String { landmark.description }

    @ComputedProperty
    var continent: String { landmark.continent }

    @DeferredProperty
    var crowdStatus: Int {
        get async throws { // swiftlint:disable:this implicit_getter
            await modelData.getCrowdStatus(self)
        }
    }

    var landmark: Landmark
    var modelData: ModelData

    init(landmark: Landmark, modelData: ModelData) {
        self.modelData = modelData
        self.landmark = landmark
    }
}
```

#### 
The app’s “Find Closest” App Shortcut performs an app intent that finds the closest nearby landmark without opening the app, and allows people to find tickets to visit it. Instead of taking them to the app, the app intent displays interactive snippets that appear as overlays at the top of the screen. To display the interactive snippet, the app’s `ClosestLandmarkIntent` returns a  that presents the interactive snippet in its `perform()` method:
```swift
import AppIntents
import SwiftUI

struct ClosestLandmarkIntent: AppIntent {
    static let title: LocalizedStringResource = "Find Closest Landmark"

    @Dependency var modelData: ModelData

    func perform() async throws -> some ReturnsValue<LandmarkEntity> & ShowsSnippetIntent & ProvidesDialog {
        let landmark = await self.findClosestLandmark()

        return .result(
            value: landmark,
            dialog: IntentDialog(
                full: "The closest landmark is \(landmark.name).",
                supporting: "\(landmark.name) is located in \(landmark.continent)."
            ),
            snippetIntent: LandmarkSnippetIntent(landmark: landmark)
        )
    }
}
```

#### 
To allow Siri to access the landmark information that’s visible onscreen in the app, its `LandmarkEntity` implements the  protocol and provides plain-text, image, and PDF representations that Siri can understand and forward to other services, including third-party services:
```swift
extension LandmarkEntity: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .pdf) { @MainActor landmark in
            let url = URL.documentsDirectory.appending(path: "\(landmark.name).pdf")

            let renderer = ImageRenderer(content: VStack {
                Image(landmark.landmark.backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text(landmark.name)
                Text("Continent: \(landmark.continent)")
                Text(landmark.description)
            }.frame(width: 600))

            renderer.render { size, renderer in
                var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)

                guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                    return
                }
                pdf.beginPDFPage(nil)
                renderer(pdf)
                pdf.endPDFPage()
                pdf.closePDF()
            }

            return .init(url)
        }

        DataRepresentation(exportedContentType: .image) {
            try $0.imageRepresentationData
        }

        DataRepresentation(exportedContentType: .plainText) {
            """
            Landmark: \($0.name)
            Description: \($0.description)
            """.data(using: .utf8)!
        }
    }
}
```

```
When the landmark becomes visible onscreen, the app uses the user activity annotation API to give the system access to the data:
```swift
HStack(alignment: .bottom) {
    Text(landmark.name)
        .font(.title)
        .fontWeight(.bold)
        .userActivity(
            "com.landmarks.ViewingLandmark"
        ) {
            $0.title = "Viewing \(landmark.name)"
            $0.appEntityIdentifier = EntityIdentifier(for: try! modelData.landmarkEntity(id: landmark.id))
        }
}
```

#### 
The app describes its data as app entities, so the system can use it when it performs app intents. Additionally, the app donates the entities into the semantic search index, making it possible to find the app entities in Spotlight. The following example shows how the app’s `LandmarkEntity` conforms to  and uses Swift macros to add the indexing keys that Spotlight needs.
```swift
struct LandmarkEntity: IndexedEntity {
    // ...

    // Maps the description to the Spotlight indexing key `contentDescription`.
    @ComputedProperty(indexingKey: \.contentDescription)
    var description: String { landmark.description }

    @ComputedProperty
    var continent: String { landmark.continent }

    // ...
}
```

```
In a utility function, the app donates the landmark entities to the Spotlight index:
```swift
static func donateLandmarks(modelData: ModelData) async throws {
    let landmarkEntities = await modelData.landmarkEntities
    try await CSSearchableIndex.default().indexAppEntities(landmarkEntities)
}
```

#### 
With visual intelligence, people circle items onscreen or in visual intelligence camera to search for matching results across apps that support visual intelligence. To support visual intelligence search, the sample app implements an  to find matching landmarks:
```swift
@UnionValue
enum VisualSearchResult {
    case landmark(LandmarkEntity)
    case collection(CollectionEntity)
}

struct LandmarkIntentValueQuery: IntentValueQuery {

    @Dependency var modelData: ModelData

    func values(for input: SemanticContentDescriptor) async throws -> [VisualSearchResult] {

        guard let pixelBuffer: CVReadOnlyPixelBuffer = input.pixelBuffer else {
            return []
        }

        let landmarks = try await modelData.search(matching: pixelBuffer)

        return landmarks
    }
}

extension ModelData {
    /**
     This method contains the search functionality that takes the pixel buffer that visual intelligence provides
     and uses it to find matching app entities. To keep this example app easy to understand, this function always
     returns the same landmark entity.
    */
    func search(matching pixels: CVReadOnlyPixelBuffer) throws -> [VisualSearchResult] {
        let landmarks = landmarkEntities.filter {
            $0.id != 1005
        }.map {
            VisualSearchResult.landmark($0)
        }.shuffled()

        let collections = userCollections
            .filter {
                $0.landmarks.contains(where: { $0.id == 1005 })
            }
            .map {
                CollectionEntity(collection: $0, modelData: self)
            }
            .map {
                VisualSearchResult.collection($0)
            }

        return [try! .landmark(landmarkEntity(id: 1005))]
            + collections
            + landmarks
    }
}
```


## Creating your first app intent
> https://developer.apple.com/documentation/appintents/creating-your-first-app-intent

### 
#### 
#### 
#### 
To define an action, create a type that adopts the  protocol, or a related protocol that provides the specific behavior you need. If possible, start with a simple action that doesn’t require parameters. Alternatively, if your action requires a parameter, consider initially hard-coding the parameter to get your first app intent implementation to work. Then make changes to add parameters to your first app intent as described in .
For example, the  sample code project provides an app intent that opens the app and displays a person’s favorite hiking trails:
```swift
struct OpenFavorites: AppIntent {
    
    static var title: LocalizedStringResource = "Open Favorite Trails"

    static var description = IntentDescription("Opens the app and goes to your favorite trails.")
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        navigationModel.selectedCollection = trailManager.favoritesCollection
        
        return .result()
    }
    
    @Dependency
    private var navigationModel: NavigationModel
    
    @Dependency
    private var trailManager: TrailDataManager
}
```

#### 
For example, the  sample code project returns a dialog for the `GetTrailInfo` app intent:
Your implementation must complete the necessary work and return a result to the system. A result may include, among other things, a value that a shortcut can use in subsequent connected actions, dialogue to display or announce, and a  snippet view.
For example, the  sample code project returns a dialog for the `GetTrailInfo` app intent:
```swift
func perform() async throws -> some IntentResult & ReturnsValue<TrailEntity> & ProvidesDialog & ShowsSnippetView {
    guard let trailData = trailManager.trail(with: trail.id) else {
        throw TrailIntentError.trailNotFound
    }
            
    /**
     You provide a custom view by conforming the return type of the `perform()` function to the `ShowsSnippetView` protocol.
     */
    let snippet = TrailInfoView(trail: trailData, includeConditions: true)
    
    /**
     This intent displays a custom view that includes the trail conditions as part of the view. The dialog includes the trail conditions when
     the system can only read the response, but not display it. When the system can display the response, the dialog omits the trail
     conditions.
     */
    let dialog = IntentDialog(full: "The latest conditions reported for \(trail.name) indicate: \(trail.currentConditions).",
                              supporting: "Here's the latest information on trail conditions.")
    
    return .result(value: trail, dialog: dialog, view: snippet)
}
```

If it doesn’t make sense for your intent to return a concrete result, return `.result()` to tell the system the intent is complete.
#### 
#### 
#### 
#### 
#### 

## Defining your app’s Focus filter
> https://developer.apple.com/documentation/appintents/defining-your-app-s-focus-filter

### 
#### 
#### 
- `alwaysUseDarkMode: false`
- `status: nil`
- `account: nil`
#### 
To define Focus filter parameters for an object that conforms to the `SetFocusFilterIntent` parameter, the sample project annotates the relevant variables with the `@Parameter` property wrapper. It provides a default value for nonoptional parameters unless the filter requires the system to prompt for this value each time it enables it.
```swift
struct ExampleFocusFilter: SetFocusFilterIntent {
    /// Providing a default value ensures setting this required Boolean value.
    @Parameter(title: "Use Dark Mode", default: false)
    var alwaysUseDarkMode: Bool

    @Parameter(title: "Status Message")
    var status: String?

    /// A representation of a chat account this app uses for notification filtering and suppression.
    /// The user receives suggestions from the suggestedEntities() function that AccountEntityQuery declares.
    @Parameter(title: "Selected Account")
    var account: AccountEntity?
}
```

#### 
To use a custom object as a `SetFocusFilterIntent` parameter, the sample project adds `AppEntity` conformance to the object. In the example below, `AppEntity` conformance allows the system to use the `AccountEntity` object as a `SetFocusFilterIntent @Parameter`:
```swift
struct AccountEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "A chat account")
    }

    static var defaultQuery = AccountEntityQuery()

    let id: String
    let displayName: String
    let displaySubtitle: String
    let image: DisplayRepresentation.Image

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayName) account",
                              subtitle: "\(displaySubtitle)",
                              image: image)
    }
}
```

#### 
The sample project adds a default entity query to suggest values when configuring the Focus filter in Settings. In the example below, the `AccountEntityQuery` that `AccountEntity` uses suggests chat accounts that are currently logged in:
```swift
struct AccountEntityQuery: EntityQuery {
    func entities(for identifiers: [AccountEntity.ID]) async throws -> [AccountEntity] {
        Repository.shared.accountsLoggedIn.filter {
            identifiers.contains($0.id)
        }
    }

    func suggestedEntities() async throws -> [AccountEntity] {
        Repository.shared.accountsLoggedIn
    }
}
```

#### 
To filter notifications with Focus filters, the sample project sets the `filterCriteria` parameter for the notifications, and then lets the system know whether to suppress them by providing a predicate that evaluates against `filterCriteria`. In the example below, the `FocusFilterAppContext appContext` variable returns a predicate that states: If there’s an account `@Parameter` for this filter, suppress the notification unless the `filterCriteria` matches the `account.id` value:
```swift
struct ExampleFocusFilter: SetFocusFilterIntent {
    var appContext: FocusFilterAppContext {
        logger.debug("App Context Called")
        let predicate: NSPredicate
        if let account = account {
            predicate = NSPredicate(format: "SELF IN %@", [account.id])
        } else {
            predicate = NSPredicate(value: true)
        }
        return FocusFilterAppContext(notificationFilterPredicate: predicate)
    }
}
```

#### 

## Displaying static and interactive snippets
> https://developer.apple.com/documentation/appintents/displaying-static-and-interactive-snippets

### 
#### 
If your app intent doesn’t require a follow-up action, return a static snippet that enables someone to view the outcome of the app intent. To show a static snippet as a result from an app intent, return a view from your app intent’s `perform()` method:
```swift
func perform() async throws -> some IntentResult {
    // ...
    
    return .result(view: Text("Some example text.").font(.title))
}
```

#### 
To display an interactive snippet as a result of an app intent, create an app intent for your action - or use an existing app intent. For example, the  sample app provides landmark information might already have an app intent that finds a nearby landmark and returns information about it:
```swift
struct ClosestLandmarkIntent: AppIntent {
    static let title: LocalizedStringResource = "Find Closest Landmark"

    func perform() async throws -> some ReturnsValue<LandmarkEntity> & ShowsSnippetIntent {
        let landmark = await self.findClosestLandmark()

        return .result(
            value: landmarkEntity // Return information about the landmark.
        )
    }
}
```

```
To display a snippet instead of just returning the app entity, change your intent’s `perform()` function to return a  in addition to the existing return value by adding `& ShowsSnippetIntent`. When you return a   result from the intent, you let the system know that the action displays an interactive snippet. In the  example app, the previous example’s updated `perform()` method might look like this:
```swift
struct ClosestLandmarkIntent: AppIntent {
    static let title: LocalizedStringResource = "Find Closest Landmark"

    @Dependency var modelData: ModelData

    func perform() async throws -> some ReturnsValue<LandmarkEntity> & ShowsSnippetIntent {
        let landmark = await self.findClosestLandmark()

        return .result(
            value: landmark,
            snippetIntent: LandmarkSnippetIntent(landmark: landmark)
        )
    }
}
```

#### 
2. Make sure the intent’s `perform()` method returns a .
The following code continues the previous example and shows how the `AppIntentsTravelTracking` app might return a `LandmarkView` from the :
2. Make sure the intent’s `perform()` method returns a .
The following code continues the previous example and shows how the `AppIntentsTravelTracking` app might return a `LandmarkView` from the :
```swift
import AppIntents
import SwiftUI

struct LandmarkSnippetIntent: SnippetIntent {
    static let title: LocalizedStringResource = "Landmark Snippet"

    @Parameter var landmark: LandmarkEntity
    @Dependency var modelData: ModelData

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        let isFavorite = await modelData.isFavorite(landmark)

        return .result(
            view: LandmarkView(landmark: landmark, isFavorite: isFavorite)
        )
    }
}

extension LandmarkSnippetIntent {
    init(landmark: LandmarkEntity) {
        self.landmark = landmark
    }
}
```

#### 
Because the system creates and performs your  repeatedly, make sure calling its `perform()` method doesn’t produce side effects:
#### 
To create this sequence of snippets, the  app uses a combination of regular app intents, a request for confirmation, and snippet intents.
First, the app defines the `FindTicketsIntent`, a regular app intent to perform the search. In its `perform()` method, the  API displays the interactive snippet for people to enter the tickets, using the  `TicketRequestSnippetIntent`.
```swift
import AppIntents

struct FindTicketsIntent: AppIntent {

    // ...

    func perform() async throws -> some IntentResult & ShowsSnippetIntent {
        let searchRequest = await searchEngine.createRequest(landmarkEntity: landmark)

        // Present a snippet that allows people to change
        // the number of tickets.
        try await requestConfirmation(
            actionName: .search,
            snippetIntent: TicketRequestSnippetIntent(searchRequest: searchRequest)
        )
        
        // ...
    }
}

// ...
```

```
When the person has entered the number of tickets in the snippet that `TicketRequestSnippetIntent` presents, they confirm the number of tickets and the search starts. The search results appear in a third snippet that the  `TicketResultSnippetIntent` presents:
```swift
// ...

func perform() async throws -> some IntentResult & ShowsSnippetIntent {
    let searchRequest = await searchEngine.createRequest(landmarkEntity: landmark)

    // Present a snippet that allows people to change
    // the number of tickets.
    try await requestConfirmation(
        actionName: .search,
        snippetIntent: TicketRequestSnippetIntent(searchRequest: searchRequest)
    )
    
    // If the person has confirmed the action, perform the ticket search.
    try await searchEngine.performRequest(request: searchRequest)

    // Show the result of the ticket search.
    return .result(
        snippetIntent: TicketResultSnippetIntent(
            searchRequest: searchRequest
        )
    )
}

// ...
```

#### 
In the above example, three snippets appear in a sequence, each snippet replacing the previous snippet. If a snippet remains onscreen for some time; for example, if you perform a search like the in the example; reload the snippet to let people know that the search is ongoing. Similarly, reload the snippet if its underlying data changes.
To reload a snippet, use the  function defined by  . The following example adds it to the trailing closure of the search method:
```swift
// ...

func perform() async throws -> some IntentResult & ShowsSnippetIntent {
    // ...
        
    // If the person has confirmed the action, perform the ticket search.
    try await searchEngine.performRequest(request: searchRequest) {
        // Creates and reloads the TicketResultSnippetIntent.
        TicketResultSnippetIntent.reload()
    }

    // Show the result of the ticket search.
    return .result(
        snippetIntent: TicketResultSnippetIntent(
            searchRequest: searchRequest
        )
    )
}

// ...
```


## Integrating actions with Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/integrating-actions-with-siri-and-apple-intelligence

### 
#### 
- The  that describes a collection of APIs for specific functionality; for example, the `.photos` domain if an app has photos or video functionality.
#### 
#### 
The following code snippet shows how the  sample declares an app intent that opens a video from a device’s media library:
```swift
@AppIntent(schema: .photos.openAsset)
struct OpenAssetIntent: OpenIntent {
    var target: AssetEntity

    @Dependency
    var library: MediaLibrary

    @Dependency
    var navigation: NavigationManager

    @MainActor
    func perform() async throws -> some IntentResult {
        let assets = library.assets(for: [target.id])
        guard let asset = assets.first else {
            throw IntentError.noEntity
        }

        navigation.openAsset(asset)
        return .result()
    }
}
```

#### 
For example, the  `AssetEntity` implementation from the  sample looks like this:
3. Update your code to meet the requirements of the schema.
For example, the  `AssetEntity` implementation from the  sample looks like this:
```swift
@AppEntity(schema: .photos.asset)
struct AssetEntity: IndexedEntity {

    static let defaultQuery = AssetQuery()

    let id: String
    let asset: Asset

    @Property(title: "Title")
    var title: String?

    var creationDate: Date?
    var location: CLPlacemark?
    var assetType: AssetType?
    var isFavorite: Bool
    var isHidden: Bool
    var hasSuggestedEdits: Bool

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: title.map { "\($0)" } ?? "Unknown",
            subtitle: assetType?.localizedStringResource ?? "Photo"
        )
    }
}
```

#### 
Your existing app intents might overlap with functionality that assistant schemas provide. If you can make an existing app intent conform to a schema without making changes to parameters that the intent uses, proceed with adding schema conformance. However, changing existing app intent implementations or removing app intents can directly impact people because their custom shortcuts may no longer work.
To not break people’s existing workflows, create a new app intent in addition to an existing app intent. As a result, both intents appear in the Shortcuts app as actions. To avoid them appearing as duplicates, mark your new app intent as available to Apple Intelligence only by setting  to `true`. For example, an app intent implementation could look like this:
```swift
@AppIntent(schema: .photos.createAssets)
struct CreateAssetsIntent: AppIntent {
    
    // ...

    static let isAssistantOnly: Bool = true
    
    // ...

    @MainActor
    func perform() async throws -> some ReturnsValue<[AssetEntity]> {
        // ... 
    }
}
```

Similarly, you can set `isAssistantOnly` to `true` for any applicable app entities and app enums that conform to an assistant schema.

## Integrating custom data types into your intents
> https://developer.apple.com/documentation/appintents/integrating-custom-types-into-your-intents

### 
#### 
To let an intent use one of your app’s custom data types as a parameter, define a new structure in your app’s target to represent that type. Then update the structure’s definition to adopt the  protocol. Although custom types can directly conform to the protocol, prefer using distinct entity types that are lightweight and provide only the information the system requires. Distinct types let you separate your entities from the rest of your app’s model and domain code. For example, the  sample code project uses a `Trail` type and defines a corresponding `TrailEntity` type.
```swift
struct TrailEntity: AppEntity {
    // ...
}
```

#### 
Every entity must have a stable, unique identifier. The framework uses that identifier as a concrete reference to your entity while mediating between your app and other parts of the system. For example, when someone selects the value for an entity-based parameter in the shortcut editor, the system asks your app to resolve that parameter using the entity’s identifier. The  protocol inherits the  protocol to enforce this prerequisite.
To add a unique identifier to your entity type, implement the protocol’s  requirement and set its type to one of the three data types optimized for the framework: , , or .
```swift
var id: UUID
```

#### 
An entity represents a type and the data for that type. In your entity, describe how to display both elements onscreen. For example, the Shortcuts app uses this information to show type details in the Actions Library and to present entity data in the shortcut editor.
Add the  variable to your entity’s structure and return a human-readable, localized string that describes the entity. For example, the hiking app from the previous example displays the number of trails. The system displays this string whenever it needs to present your entity’s type onscreen.
```swift
static var typeDisplayRepresentation: TypeDisplayRepresentation {
    TypeDisplayRepresentation(
        name: LocalizedStringResource("Trail", table: "AppIntents"),
        numericFormat: LocalizedStringResource("\(placeholder: .int) trails", table: "AppIntents")
    )
}
```

The required  variable describes how to display an entity’s represented data at runtime. Update your structure to include this variable and return an instance of . Specify a localized  that lets people recognize the data.
Create a visually rich display of your entity by setting the representation’s  and  variables. For example, the  sample code project displays the name of the trail, a region description, and an image.
```swift
var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(name)",
                          subtitle: "\(regionDescription)",
                          image: DisplayRepresentation.Image(named: imageName))
}
```

#### 
The framework requires entity types to be searchable so the system can resolve identifiers at runtime and request a list of suggested entities to display onscreen. For example, when a person sets a parameter to a specific entity in the shortcut editor, the system retains that entity’s identifier. Later, when the intent runs, the framework asks your type to materialize the entity from its identifier. The framework then updates the relevant parameter with the materialized entity before invoking the intent’s  function.
To make your entity searchable, define a new structure that adopts the  protocol. Place this structure in the app’s target alongside your entity. Add the  function, and update the declaration so the element type of the `identifiers` array matches your entity’s `id` variable. Use the provided identifiers to materialize and return the relevant entities.
```swift
struct TrailEntityQuery: EntityQuery {
    
    @Dependency
    var trailManager: TrailDataManager

    func entities(for identifiers: [TrailEntity.ID]) async throws -> [TrailEntity] {
        Logger.entityQueryLogging.debug("[TrailEntityQuery] Query for IDs \(identifiers)")
        
        return trailManager.trails(with: identifiers)
                .map { TrailEntity(trail: $0) }
    }
}
```

```
To offer a better user experience, provide a list of suggested entities that the system displays, at appropriate times, to let people quickly make a selection. To provide those entities, add the  method to your query structure. If your data generates a small number of entities, return them all; otherwise, return a subset of those entities relevant to the current context. For example, the  sample code project suggests a person’s favorite hiking trails.
```swift
func suggestedEntities() async throws -> [TrailEntity] {
    Logger.entityQueryLogging.debug("[TrailEntityQuery] Request for suggested entities")
    
    return trailManager.trails(with: trailManager.favoritesCollection.members)
            .map { TrailEntity(trail: $0) }
}
```

```
To let people use arbitrary text to find specific entities, adopt the  protocol instead. Queries that adopt this protocol cause the system to display a search field above the list of suggested entities. Implement the required  function, and use the provided string to match against your data. For example, the  sample code project allows people to search for a specific trail. The following code snippet from the sample code project matches a person’s search input to the app’s trail information using the `name` property:
```swift
func entities(matching string: String) async throws -> [TrailEntity] {
    return trailManager.trails { trail in
        trail.name.localizedCaseInsensitiveContains(string)
    }.map { TrailEntity(trail: $0) }
}
```

```
After you implement your query, update the related entity’s definition to include the  variable, and specify an instance of your query type as the value. The system uses this variable at runtime to determine which type it can query on behalf of the related entity.
```swift
static var defaultQuery = TrailEntityQuery()
```

#### 
#### 
If a type has known fixed values at build time, such as a Swift enumeration, expose those types to the system by converting them to , the static equivalent of entities. Because app enum values are constant, the compiler introspects them at build time and optimizes their use. The framework provides both an identity and a query by default, and the system can get type information at runtime without launching the app. For example, a music app might use an app enum to associate an album with an album type such as studio, live, or compilation.
To convert a common type to an app enum, update its declaration to adopt the  protocol. There’s no need to create a separate type because the existing type is inherently lightweight and doesn’t store additional data. The framework requires that app enums also conform to  and use  as their storage type, so modify your type to satisfy those requirements. Like with entities, specify a localized description of the type that the system can display onscreen.
```swift
enum ActivityStyle: String, Codable, Sendable {
    case biking
    case equestrian
    case hiking
    case jogging
    case crossCountrySkiing
    case snowshoeing

    // ...
}

extension ActivityStyle: AppEnum {

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("Activity", table: "AppIntents"),
            numericFormat: LocalizedStringResource("\(placeholder: .int) activities", table: "AppIntents")
        )
    }
```

To provide descriptions for each of your app enum’s values, add the protocol’s required  variable. Return a dictionary that maps the values to their display representations.
```swift
static var caseDisplayRepresentations: [ActivityStyle: DisplayRepresentation] = [
    .biking: DisplayRepresentation(title: "Biking",
                                   subtitle: "Mountain bike ride",
                                   image: imageRepresentation[.biking]),
    
    .equestrian: DisplayRepresentation(title: "Equestrian",
                                       subtitle: "Equestrian sports",
                                       image: imageRepresentation[.equestrian]),
    
    .hiking: DisplayRepresentation(title: "Hiking",
                                   subtitle: "A lengthy outdoor walk",
                                   image: imageRepresentation[.hiking]),
    
    .jogging: DisplayRepresentation(title: "Jogging",
                                    subtitle: "A gentle run",
                                    image: imageRepresentation[.jogging]),
    
    .crossCountrySkiing: DisplayRepresentation(title: "Skiing",
                                               subtitle: "Cross-country skiing",
                                               image: imageRepresentation[.crossCountrySkiing]),
    
    .snowshoeing: DisplayRepresentation(title: "Snowshoeing",
                                        subtitle: "Walking in the snow",
                                        image: imageRepresentation[.snowshoeing])
]
```


## Launching your voice-based conversational app from the side button of iPhone
> https://developer.apple.com/documentation/appintents/launching-your-voice-based-conversational-app-from-the-side-button-of-iphone

### 
3. In the app intent’s  implementation, navigate to the scene that provides voice-based conversational functionality and start an audio session.
The following example shows how an app that provides voice-based conversational functionality might implement an app intent that people in Japan can place on the side button of iPhone:
```swift
@AppIntent(schema: .assistant.activate)
struct ActivateVoiceBasedConversationSceneIntent {
    static let supportedModes: IntentModes = .foreground

    func perform() async throws -> some IntentResult {

        // Add code here to navigate to the scene in your app that provides
        // voice-based conversational functionality.
        // If applicable, pass information to your app that allows it to update
        // its data or UI in response to the invocation from
        // the side button and start voice-based conversational functionality.

        return .result()
    }
}
```


## Making app entities available in Spotlight
> https://developer.apple.com/documentation/appintents/making-app-entities-available-in-spotlight

### 
#### 
To index your app’s entities, each  type you define needs to conform to the  protocol. The following example shows the `LandmarkEntity` type from , which includes this protocol in its declaration:
```swift
struct LandmarkEntity: IndexedEntity {

    // ...

}
```

#### 
If you adorn properties with the  or  property wrappers, you can use those same wrappers to tell Spotlight what content to index. When you include an indexing key with those property wrappers, Spotlight automatically adds the data in that property to your app’s index. Specify an indexing key using Swift key paths and one of the property names in the  type. To create this path, specify a slash and period (`\.`) followed by the property name. You can also use this approach to specify key paths for your app’s custom indexing keys.
The following code from the  sample shows the `LandmarkEntity` type, which makes the app’s landmark data available to the system. The property wrapper for `description` tells Spotlight to index the property using the Spotlight-provided  key. The property wrapper for `continent` tells Spotlight to index the property using the provided custom key.
```swift
struct LandmarkEntity: IndexedEntity {
    // ...

    // Maps the description variable to the Spotlight indexing key `contentDescription`.
    @ComputedProperty(indexingKey: \.contentDescription)
    var description: String { landmark.description }

    // Maps the continent variable to a custom Spotlight indexing key. 
    @ComputedProperty(
        customIndexingKey: CSCustomAttributeKey(
            keyName: "com_AppIntentsTravelTracking_LandmarkEntity_continent"
        )!
    )
    var continent: String { landmark.continent }

    // ...
}
```

```
If your entity doesn’t have a declared property for data you want to index, specify that data in your entity’s  property. The  protocol provides the default implementation of this property, but you can implement it yourself and return a custom  with additional data to index. The following example shows how you might use this property to return additional information related to a landmark that the entity doesn’t expose directly:
```swift
extension LandmarkEntity {
    var attributeSet: CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet()
                
        attributes.latitude = NSNumber(value: landmark.latitude)
        attributes.longitude = NSNumber(value: landmark.longitude)
        attributes.supportsNavigation = true
        
        return attributes
    }
}
```

#### 
When your app runs, you must deliver instances of your  types to Spotlight so it can index them. If your app doesn’t yet support Spotlight, index your entities directly by calling the  method of a named  object. This method passes the entities to Spotlight, which processes them and adds them to your app’s index. The following example donates entities containing landmark data to an app-specific index:
```swift
static func donateLandmarks(modelData: ModelData) async throws {
    let landmarkEntities = await modelData.landmarkEntities
    try await CSSearchableIndex(name: "AppIntentsTravelTracking_Landmarks").indexAppEntities(landmarkEntities)
}
```

#### 
5. Index the item with the rest of your content.
The following example creates an array of searchable items for an app that manages hiking trails. For each trail, the code creates an app entity for the trail and associates it with the trail’s search attributes. When calling the  method, the code also specifies a priority value to indicate the importance of that trail to the person. Spotlight elevates items with higher priority values in suggestions and search results to make them more visible.
```swift
let searchableItems = trails.map { trail in
    let attributes = trail.searchableAttributes
            
    let isFavorite = favoritesCollection.members.contains(trail.id)
    let weight = isFavorite ? 10 : 1
    let entity = TrailEntity(trail: trail)
    attributes.associateAppEntity(entity, priority: weight)

    let item = CSSearchableItem(uniqueIdentifier: String(trail.id),
                                        domainIdentifier: nil,
                                        attributeSet: attributes)
                        
    return item
}
```

#### 
For each  type that you define and donate to Spotlight, create an  type that opens that entity in your app. When Spotlight returns one of your app’s entities in a search result, you want people to be able to tap that result and navigate to the associated content in your app. When an open intent is present, Spotlight can use it to provide that behavior. The following example from  shows the open intent for the app’s `LandmarkEntity` type. When someone taps a landmark in search results, Spotlight uses the intent to open the app and display the chosen landmark.
```swift
struct OpenLandmarkIntent: OpenIntent {
    static let title: LocalizedStringResource = "Open Landmark"

    @Parameter(title: "Landmark", requestValueDialog: "Which landmark?")
    var target: LandmarkEntity
}
```


## Making browser actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-browser-actions-available-to-siri-and-apple-intelligence

### 
For example, if your app allows a person to open a website in a new tab, use the  macro and provide the assistant schema that consists of the `.browser` domain and the  schema:
```swift
@AppIntent(schema: .browser.createTab)
struct CreateTabIntent: AppIntent {
    var url: URL?
    var isPrivate: Bool

    // Return a TabEntity instance.
    func perform() async throws -> some ReturnsValue<TabEntity> {
       .result(value: TabEntity())
    }
}
```

To learn more about assistant schemas, see . For a list of available app intents in the `.browser` domain, see .
#### 
If you use app entities to describe custom data types, annotate the app entity implementation with the  macro. This makes sure Siri and Apple Intelligence can understand your data. For example, the intent in the previous section uses `TabEntity`. The following code snippet shows how the `TabEntity` implementation uses the  macro:
```swift
@AppEntity(schema: .browser.tab)
struct TabEntity {
    struct Query: EntityStringQuery {
        func entities(for identifiers: [TabEntity.ID]) async throws -> [TabEntity] { [] }
        func entities(matching string: String) async throws -> [TabEntity] { [] }
    }
    static var defaultQuery = Query()
    
    var displayRepresentation: AppIntents.DisplayRepresentation { "TabEntity" }

    let id = UUID()

    var url: URL?
    var name: String
    var isPrivate: Bool
}
```

The assistant schema for the `TabEntity` consists of the `.browser` domain and the  schema.
For a list of available app entity schemas in the `.browser` domain, see .
#### 
To make sure Siri and Apple Intelligence understand custom static types for your intent parameters, annotate app enumerations with the  macro. Then, pass the `.browser` domain and a schema to it. The following example uses the  schema:
```swift
@AppEnum(schema: .browser.clearHistoryTimeFrame)
struct ClearHistoryTimeFrameEnum: String, AppEnum {
    case today
    case lastFourHours
    case todayAndYesterday
    case allTime

static var caseDisplayRepresentations: [ClearHistoryTimeFrame: DisplayRepresentation] = [:]
}
```

For a list of available app enumeration schemas in the `.browser` domain, see .

## Making camera actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-camera-actions-available-to-siri-and-apple-intelligence

### 
For example, if your app allows a person to take a photo or video, use the  macro and provide the assistant schema that consists of the `.camera` domain and the  schema:
```swift
@AppIntent(schema: .camera.startCapture)
struct StartCaptureIntent {
    var captureMode: CaptureMode
    var timerDuration: CaptureDuration?
    var device: CaptureDevice?

    func perform() async throws -> some IntentResult {
        .result()
    }
}
```

To learn more about assistant schemas, see . For a list of available app intents in the `.camera` domain, see .
#### 
To make sure Siri and Apple Intelligence understand custom static types for your intent parameters, annotate app enumerations with the  macro. Then, pass the `.camera` domain and a schema to it. The following example uses the  schema:
```swift
@AppEnum(schema: .camera.captureMode)
struct CameraCaptureMode: String, AppEnum {
    // Your app's camera capture modes.
    case portrait
    case landscape
    case catFace
    case awesomeFilter

    static var caseDisplayRepresentations: [ClearHistoryTimeFrame: DisplayRepresentation] = [:]

}
```

For a list of available app enumeration schemas in the `.camera` domain, see .

## Making document reader actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-document-reader-actions-available-to-siri-and-apple-intelligence

### 
For example, if your app allows people to view and rotate a document, use the  macro and provide the assistant schema that consists of the `.reader` domain and the  schema:
```swift
@AppIntent(schema: .reader.rotatePages)
struct ReaderRotatePagesIntent {
    var pages: [ReaderPageEntity]
    var isClockwise: Bool

    func perform() async throws -> some IntentResult & ReturnsValue<[ReaderPageEntity]> {
        return .result(value: [ReaderPageEntity]())
    }
}
```

To learn more about assistant schemas, see . For a list of available app intents in the `.reader` domain, see .
#### 
If you use app entities to describe custom data types, annotate the app entity implementation with the  macro. This makes sure Siri and Apple Intelligence can understand your data. For example, the intent in the previous section uses `ReaderPageEntity`. The following code snippet shows how the `ReaderPageEntity` implementation uses the  macro:
```swift
@AppEntity(schema: .reader.document)
struct ReaderDocumentEntity {
    struct Query: EntityStringQuery {
        func entities(for identifiers: [ReaderDocumentEntity.ID]) async throws -> [ReaderDocumentEntity] { [] }
        func entities(matching string: String) async throws -> [ReaderDocumentEntity] { [] }
    }
    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation { "A display representation." }

    let id = UUID()

    var title: String
    var kind: ReaderDocumentKind
    var width: Int?
    var height: Int?
}
```

The assistant schema for the `ReaderPageEntity` consists of the `.reader` domain and the  schema.
For a list of available app entity schemas in the `.reader` domain, see .
#### 
To make sure Siri and Apple Intelligence understand custom static types for your intent parameters, annotate app enumerations with the  macro. Then, pass the `.reader` domain and a schema to it. The following example uses the  schema:
```swift
import Foundation
import AppIntents

@AppEnum(schema: .reader.documentKind)
enum ReaderDocumentKind: String, AppEnum, Codable {
    case image
    case pdf

    static var caseDisplayRepresentations: [ReaderDocumentKind: DisplayRepresentation] = [:]
}

```

For a list of available app enumeration schemas in the `.reader` domain, see .

## Making ebook actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-ebook-actions-available-to-siri-and-apple-intelligence

### 
For example, if your app allows a person to open an ebook, use the  macro and provide the assistant schema that consists of the `.books` domain and the  schema:
```swift
@AppIntent(schema: .books.openBook)
struct OpenBookIntent: OpenIntent {
    var target: BookEntity
    
    func perform() async throws -> some IntentResult {
        .result()
    }
}
```

To learn more about assistant schemas, see . For a list of available app intents in the `.books` domain, see .
#### 
If you use app entities to describe custom data types, annotate the app entity implementation with the  macro. This makes sure Siri and Apple Intelligence can understand your data. For example, the intent in the previous section uses `BookEntity`. The following code snippet shows how the `BookEntity` implementation uses the  macro:
```swift
@AppEntity(schema: .books.book)
struct BookEntity {
    struct Query: EntityStringQuery {
        func entities(for identifiers: [BookEntity.ID]) async throws -> [BookEntity] { [] }
        func entities(matching string: String) async throws -> [BookEntity] { [] }
    }

    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation { "Provide a display representation." }
    
    let id = UUID()
    
    var title: String?
    var seriesTitle: String?
    var author: String?
    var genre: String?
    var purchaseDate: Date?
    var contentType: BookContentType?
    var url: URL?
}
```

The assistant schema for the `BookEntity` consists of the `.books` domain and the  schema.
For a list of available app entity schemas in the `.books` domain, see .
#### 
To make sure Siri and Apple Intelligence understand custom static types for your intent parameters, annotate app enumerations with the  macro. Then, pass the `.books` domain and a schema to it. The following example uses the  schema:
```swift
@AppEnum(schema: .books.contentType)
enum BookContentType: String, AppEnum {
    case book
    case pdf

    static var caseDisplayRepresentations: [BookContentType: AppIntents.DisplayRepresentation] = [:]

}
```

For a list of available app enumeration schemas in the `.books` domain, see .

## Making email actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-email-actions-available-to-siri-and-apple-intelligence

### 
For example, if your app allows someone to draft an email and send that at a later date and time, use the  macro and provide the assistant schema that consists of the `.mail` domain and the  schema:
```swift
@AppIntent(schema: .mail.sendDraft)
struct SendDraftIntent: AppIntent {
    var target: MailDraftEntity
    var sendLaterDate: Date?

    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
```

To learn more about assistant schemas, see . For a list of available app intent schemas in the `.mail` domain, see .
#### 
If you use app entities to describe custom data types, annotate the app entity implementation with the  macro. This makes sure Siri and Apple Intelligence can understand your data. For example, the intent in the previous section uses `MailDraftEntity`. The following code snippet shows how the `MailDraftEntity` implementation uses the  macro:
```swift
@AppEntity(schema: .mail.draft)
struct MailDraftEntity {

    static var defaultQuery = Query()
    
    struct Query: EntityStringQuery {
        init() {}
        func entities(for identifiers: [MailDraftEntity.ID]) async throws -> [MailDraftEntity] { [] }
        func entities(matching string: String) async throws -> [MailDraftEntity] { [] }
    }

    var displayRepresentation: DisplayRepresentation { "Provide a display representation." }

    let id = UUID()

    var to: [IntentPerson]
    var cc: [IntentPerson]
    var bcc: [IntentPerson]
    var subject: String?
    var body: AttributedString?
    var attachments: [IntentFile]
    var account: MailAccountEntity
}
```

The assistant schema for the `MailDraftEntity` consists of the `.mail` domain and the  schema.
For a list of available app entity schemas in the `.mail` domain, see .

## Making file management actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-file-management-actions-available-to-siri-and-apple-intelligence

### 
For example, if your app allows a person to open a file, use the  macro and provide the assistant schema that consists of the `.files` domain and the  schema:
```swift
@AppIntent(schema: .files.openFile)
struct OpenFileIntent: OpenIntent {
    var target: FileEntity

   func perform() async throws -> some IntentResult {
        return .result()
    }
}
```

To learn more about assistant schemas, see . For a list of available app intents in the `.files` domain, see .
#### 
If you use app entities to describe custom data types, annotate the app entity implementation with the  macro. This makes sure Siri and Apple Intelligence can understand your data. For example, the intent in the previous section uses `FileEntity`. The following code snippet shows how the `FileEntity` implementation uses the  macro:
```swift
@AppEntity(schema: .files.file)
struct FilesEntity: FileEntity {
    struct Query: EntityStringQuery {
        func entities(for identifiers: [FilesEntity.ID]) async throws -> [FilesEntity] { [] }
        func entities(matching string: String) async throws -> [FilesEntity] { [] }
    }
    static var defaultQuery = Query()

    static var supportedContentTypes = [UTType.image]
    var displayRepresentation: AppIntents.DisplayRepresentation { "Provide a display representation." }

    var id: FileEntityIdentifier

    var creationDate: Date?
    var fileModificationDate: Date?
}
```

The assistant schema for the `FileEntity` consists of the `.files` domain and the  schema.
For a list of available app entity schemas in the `.files` domain, see .

## Making in-app search actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-in-app-search-actions-available-to-siri-and-apple-intelligence

### 
Use the  macro and provide the assistant schema that consists of the `.system` domain and the  schema:
Use the  macro and provide the assistant schema that consists of the `.system` domain and the  schema:
```swift
import AppIntents
import Foundation

@AppIntent(schema: .system.search)
struct ExampleSearchIntent: ShowInAppSearchResultsIntent {
    static var searchScopes: [StringSearchScope] = [.general]
    var criteria: StringSearchCriteria
    
    func perform() async throws -> some IntentResult {
        let searchString = criteria.term
        print("Searching for \(searchString)")
        // ...
        // Code that navigates to your app's search and enters the search string into a search field.
        // ...
        return .result()
    }
}
```


## Making journaling actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-journaling-actions-available-to-siri-and-apple-intelligence

### 
For example, if your app allows someone to create a new journal entry, use the  macro and provide the assistant schema that consists of the `.journal` domain and the  schema:
```swift
@AppIntent(schema: .journal.createEntry)
struct CreateJournalEntryIntent {
    var message: AttributedString
    var title: String?
    var entryDate: Date?
    var location: CLPlacemark?

    @Parameter(default: [])
    var mediaItems: [IntentFile]

    func perform() async throws -> some ReturnsValue<JournalEntryEntity> {
        .result(value: JournalEntryEntity)
    }
}

```

To learn more about assistant schemas, see . For a list of available app intents in the `.journal` domain, see .
#### 
If you use app entities to describe custom data types, annotate the app entity implementation with the  macro. This makes sure Siri and Apple Intelligence can understand your data. For example, the intent in the previous section uses `JournalEntity`. The following code snippet shows how the `JournalEntity` implementation uses the  macro:
```swift
@AppEntity(schema: .journal.entry)
struct JournalEntryEntity {
    struct Query: EntityStringQuery {
        func entities(for identifiers: [JournalEntryEntity.ID]) async throws -> [JournalEntryEntity] { [] }
        func entities(matching string: String) async throws -> [JournalEntryEntity] { [] }
    }

    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation { "Provide a display representation." }

    let id = UUID()
    
    var title: String?
    var message: AttributedString?
    var mediaItems: [IntentFile]
    var entryDate: Date?
    var location: CLPlacemark?
}
```

The assistant schema for the `JournalEntity` consists of the `.journal` domain and the  schema.
For a list of available app entity schemas in the `.journal` domain, see .

## Making onscreen content available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-onscreen-content-available-to-siri-and-apple-intelligence

### 
#### 
To remove the association between the user activity and your app entity, set the user activity’s `appEntityIdentifier` property to `nil`.
To remove the association between the user activity and your app entity, set the user activity’s `appEntityIdentifier` property to `nil`.
The following code snippet from the  sample code project shows how a photo-viewing app might provide a photo to Siri and Apple Intelligence by creating an app entity identifier for the `asset` app entity that represents a photo, and associating it with the user activity:
```swift
 MediaView(
    image: image,
    duration: asset.duration,
    isFavorite: asset.isFavorite,
    proxy: proxy
)
.userActivity(
    "com.example.apple-samplecode.AssistantSchemasExample.ViewingPhoto",
    element: asset.entity
) { asset, activity in
    activity.title = "Viewing a photo"
    activity.appEntityIdentifier = EntityIdentifier(for: asset)
}
```

#### 
#### 
| Browser |  | `@AppEntity(schema: .browser.tab)` | A person might ask Siri questions about the web page. |
| Document reader |  | `@AppEntity(schema: .reader.document)` | A person might ask Siri to explain the conclusion of a document. |
| File management |  | `@AppEntity(schema: .files.file)` | A person might ask Siri to summarize file content. |
| Mail |  | `@AppEntity(schema: .mail.message) ` | A person might ask Siri to provide a summary. |
| Photos |  | `@AppEntity(schema: .photos.asset)` | A person might ask Siri about things to do with an object in a photo. |
| Presentations |  | `@AppEntity(schema: .presentation.document)` | A person might ask Siri to suggest a creative title for a presentation. |
| Spreadsheets |  | `@AppEntity(schema: .spreadsheet.document)` | A person might ask Siri to give an overview of the spreadsheet’s data. |
| Word processor |  | `@AppEntity(schema: .wordProcessor.document)` | A person might ask Siri to suggest additional content for a text document. |

## Making photo and video actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-photo-and-video-actions-available-to-siri-and-apple-intelligence

### 
For example, if your app allows someone to open a photo, use the  macro and provide the assistant schema that consists of the `.photos` domain and the  schema:
```swift
@AppIntent(schema: .photos.openAsset)
struct OpenAssetIntent: OpenIntent {
    var target: AssetEntity

    @Dependency
    var library: MediaLibrary

    @Dependency
    var navigation: NavigationManager

    @MainActor
    func perform() async throws -> some IntentResult {
        let assets = library.assets(for: [target.id])
        guard let asset = assets.first else {
            throw IntentError.noEntity
        }

        navigation.openAsset(asset)
        return .result()
    }
}
```

To learn more about assistant schemas, see . For a list of available app intents in the `.photos` domain, see .
#### 
If you use app entities to describe custom data types, annotate the app entity implementation with the  macro. This makes sure Siri and Apple Intelligence can understand your data. For example, the intent in the previous section uses `AssetEntity`. The following code snippet shows how the `AssetEntity` implementation uses the  macro:
```swift
@AppEntity(schema: .photos.asset)
struct AssetEntity: IndexedEntity {

    static let defaultQuery = AssetQuery()

    let id: String
    let asset: Asset

    @Property()
    var title: String?

    var creationDate: Date?
    var location: CLPlacemark?
    var assetType: AssetType?
    var isFavorite: Bool
    var isHidden: Bool
    var hasSuggestedEdits: Bool

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: title.map { "\($0)" } ?? "Unknown",
            subtitle: assetType?.localizedStringResource ?? "Photo"
        )
    }
}
```

The assistant schema for the `AssetEntity` consists of the `.photos` domain and the  schema.
For a list of available app entity schemas in the `.photos` domain, see .
#### 
To make sure Siri and Apple Intelligence understand custom static types for your intent parameters, annotate app enumerations with the  macro. Then, pass the `.photos` domain and a schema to it. The following example uses the  schema:
```swift
@AppEnum(schema: .photos.assetType)
enum AssetType: String, AppEnum {
    case photo
    case video

    static let caseDisplayRepresentations: [AssetType: DisplayRepresentation] = [
        .photo: "Photo",
        .video: "Video"
    ]
}
```

For a list of available app enumeration schemas in the `.photos` domain, see .

## Making presentation actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-presentation-actions-available-to-siri-and-apple-intelligence

### 
For example, if your app allows someone to open a presentation, use the  macro and provide the assistant schema that consists of the `.presentation` domain and the  schema:
```swift
@AppIntent(schema: .presentation.open)
struct OpenPresentationIntent: OpenIntent {
    var target: PresentationEntity

    func perform() async throws -> some IntentResult {
        .result()
    }
}
```

To learn more about assistant schemas, see . For a list of available app intents in the `.presentation` domain, see .
#### 
If you use app entities to describe custom data types, annotate the app entity implementation with the  macro. This makes sure Siri and Apple Intelligence can understand your data. For example, the intent in the previous section uses `PresentationEntity`. The following code snippet shows how the `PresentationEntity` implementation uses the  macro:
```swift
@AppEntity(schema: .presentation.document)
struct PresentationEntity {
    struct Query: EntityStringQuery {
        func entities(for identifiers: [PresentationEntity.ID]) async throws -> [PresentationEntity] { [] }
        func entities(matching string: String) async throws -> [PresentationEntity] { [] }
    }

    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation { "Provide a display representation." }

    let id = UUID()

    var name: String
}
```

The assistant schema for the `PresentationEntity` consists of the `.presentation` domain and the  schema.
For a list of available app entity schemas in the `.presentation` domain, see .

## Making spreadsheet actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-spreadsheet-actions-available-to-siri-and-apple-intelligence

### 
For example, if your app allows someone to open a spreadsheet, use the  macro and provide the assistant schema that consists of the `.spreadsheet` domain and the  schema:
```swift
@AppIntent(schema: .spreadsheet.open)
struct OpenSpreadsheetIntent: OpenIntent {
    var target: SpreadsheetDocumentEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
```

To learn more about assistant schemas, see . For a list of available app intents in the `.spreadsheet` domain, see .
#### 
If you use app entities to describe custom data types, annotate the app entity implementation with the  macro. This makes sure Siri and Apple Intelligence can understand your data. For example, the intent in the previous section uses `SpreadsheetEntity`. The following code snippet shows how the `SpreadsheetEntity` implementation uses the  macro:
```swift
@AppEntity(schema: .spreadsheet.document)
struct SpreadsheetDocumentEntity {
    struct Query: EntityStringQuery {
        func entities(for identifiers: [SpreadsheetDocumentEntity.ID]) async throws -> [SpreadsheetDocumentEntity] { [] }
        func entities(matching string: String) async throws -> [SpreadsheetDocumentEntity] { [] }
    }

    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation { "Provide a display representation." }

    let id = UUID()

    var name: String
}
```

The assistant schema for the `PresentationEntity` consists of the `.spreadsheet` domain and the  schema.
For a list of available app entity schemas in the `.spreadsheet` domain, see .

## Making whiteboard actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-whiteboard-actions-available-to-siri-and-apple-intelligence

### 
For example, if your app allows someone to open a whiteboard, use the  macro and provide the assistant schema that consists of the `.whiteboard` domain and the  schema:
```swift
@AppIntent(schema: .whiteboard.createBoard)
struct CreateWhiteboardIntent: AppIntent {
    public var title: String?

    func perform() async throws -> some ReturnsValue<WhiteboardBoardEntity> {
        .result(value: WhiteboardBoardEntity())
    }
}
```

To learn more about assistant schemas, see . For a list of available app intents in the `.whiteboard` domain, see .
#### 
If you use app entities to describe custom data types, annotate the app entity implementation with the  macro. This makes sure Siri and Apple Intelligence can understand your data. For example, the intent in the previous section uses `WhiteboardEntity`. The following code snippet shows how the `WhiteboardEntity` implementation uses the  macro:
```swift
@AppEntity(schema: .whiteboard.board)
struct WhiteboardBoardEntity {
    struct Query: EntityStringQuery {
        func entities(for identifiers: [WhiteboardBoardEntity.ID]) async throws -> [WhiteboardBoardEntity] { [] }
        func entities(matching string: String) async throws -> [WhiteboardBoardEntity] { [] }
    }

    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation { "Provide a display representation." }

    let id = UUID()

    var title: String
    var creationDate: Date
    var lastModificationDate: Date
}
```

The assistant schema for the `WhiteboardBoardEntity` consists of the `.whiteboard` domain and the  schema.
For a list of available app entity schemas in the `.whiteboard` domain, see .
#### 
To make sure Siri and Apple Intelligence understand custom static types for your intent parameters, annotate app enumerations with the  macro. Then, pass the `.whiteboard` domain and a schema to it. The following example uses the  schema:
```swift
@AppEnum(schema: .whiteboard.color)
enum WhiteboardColor: String, AppEnum {
    case white
    case black
    case grey
    case green
    case red
    case blue
    case yourCustomAppColor

    static var caseDisplayRepresentations: [WhiteboardColor: AppIntents.DisplayRepresentation] = [:]

}
```

For a list of available app enums in the `.whiteboard` domain, refer to .

## Making word processor actions available to Siri and Apple Intelligence
> https://developer.apple.com/documentation/appintents/making-word-processor-actions-available-to-siri-and-apple-intelligence

### 
For example, if your app allows someone to open a text document, use the  macro and provide the assistant schema that consists of the `.wordProcessor` domain and the  schema:
```swift
@AppIntent(schema: .wordProcessor.open)
struct OpenWordProcessorDocumentIntent: OpenIntent {
    var target: WordProcessorDocumentEntity

    func perform() async throws -> some IntentResult {
        .result()
    }
}
```

To learn more about assistant schemas, see . For a list of available app intents in the `.wordProcessor` domain, see .
#### 
If you use app entities to describe custom data types, annotate the app entity implementation with the  macro. This makes sure Siri and Apple Intelligence can understand your data. For example, the intent in the previous section uses `DocumentEntity`. The following code snippet shows how the `DocumentEntity` implementation uses the  macro:
```swift
@AppEntity(schema: .wordProcessor.document)
struct WordProcessorDocumentEntity {
    struct Query: EntityStringQuery {
        func entities(for identifiers: [WordProcessorDocumentEntity.ID]) async throws -> [WordProcessorDocumentEntity] { [] }
        func entities(matching string: String) async throws -> [WordProcessorDocumentEntity] { [] }
    }

    static var defaultQuery = Query()
    var displayRepresentation: DisplayRepresentation { "Provide a display representation." }

    let id = UUID()

    var name: String
    var creationDate: Date?
    var modificationDate: Date?
}
```

The assistant schema for the `DocumentEntity` consists of the `.wordProcessor` domain and the  schema.
For a list of available app entity schemas in the `.wordProcessor` domain, see .

## Making your app’s functionality available to Siri
> https://developer.apple.com/documentation/appintents/making-your-app-s-functionality-available-to-siri

### 
#### 
This sample uses  to make the , , and  implementations available to Siri as shown in the following example:
```swift
@AppEnum(schema: .photos.assetType)
enum AssetType: String, AppEnum {
    case photo
    case video

    static let caseDisplayRepresentations: [AssetType : DisplayRepresentation]  = [
        .photo: "Photo",
        .video: "Video"
    ]
}
```

#### 
People can use Spotlight to search for data the sample contains. To enable this functionality, the sample defines an app entity that conforms to :
```swift
@AppEntity(schema: .photos.asset)
struct AssetEntity: IndexedEntity {

    // MARK: Static

    static let defaultQuery = AssetQuery()

    // MARK: Properties

    let id: String
    let asset: Asset

    @Property(title: "Title")
    var title: String?

    var creationDate: Date?
    var location: CLPlacemark?
    var assetType: AssetType?
    var isFavorite: Bool
    var isHidden: Bool
    var hasSuggestedEdits: Bool

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: title.map { "\($0)" } ?? "Unknown",
            subtitle: assetType?.localizedStringResource ?? "Photo"
        )
    }
}
```

#### 
By adopting the  protocol, this sample makes the data it describes as app entities more shareable and allows other apps to understand its data formats. For example, the sample’s `AssetEntity` implements `Transferable` to make it easy to share a photo as a PNG image with Siri or the share sheet:
```swift
extension AssetEntity: Transferable {

    struct AssetQuery: EntityQuery {
        @Dependency
        var library: MediaLibrary

        @MainActor
        func entities(for identifiers: [AssetEntity.ID]) async throws -> [AssetEntity] {
            library.assets(for: identifiers).map(\.entity)
        }

        @MainActor
        func suggestedEntities() async throws -> [AssetEntity] {
            // Suggest the first three assets in the photo library.
            library.assets.prefix(3).map(\.entity)
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { entity in
            try await entity.asset.pngData()
        }
    }
}
```

#### 
When the user asks a question about onscreen content or wants to perform an action on it, Siri and Apple Intelligence can retrieve the content to respond to the question and perform the action. If the user explicitly requests it, Siri and Apple Intelligence can send content to supported third-party services. For example, someone could view a photo and use Siri to describe things a person can do with an identified object in the photo by saying or typing a phrase like “Hey Siri, what can I do with the object in this photo?” To integrate onscreen content with current and upcoming personal intelligence features of Siri and Apple Intelligence, the sample’s `AssetEntity` conforms to the  protocol and the `.photos.asset` schema. When a person views a photo, the app associates the asset entity with an  to make the photo available to Siri and Apple Intelligence:
```swift
var body: some View {
    // ...
    MediaView(
        image: image,
        duration: asset.duration,
        isFavorite: asset.isFavorite,
        proxy: proxy
    )
    .userActivity(
        "com.example.apple-samplecode.AssistantSchemasExample.ViewingPhoto",
        element: asset.entity
    ) { asset, activity in
        activity.title = "Viewing a photo"
        activity.appEntityIdentifier = EntityIdentifier(for: asset)
    }
    // ...
```


## Parameter resolution
> https://developer.apple.com/documentation/appintents/parameter-resolution

### 
Parameters represent input arguments to your app intents and offer additional metadata to the system. When you define an app intent, add the `@Parameter` property wrapper to any properties you use as input. For example, an app intent that sends a message might include a parameter for the recipient and message string. The system collects and resolves the relevant parameter information before it performs your app intent.
The following partial example shows how to declare parameters for a custom app intent that enables someone to order soup from your app. Configure the parameter property wrapper with any additional details that help the system infer extra information about your parameter.
```swift
struct OrderSoupIntent: AppIntent {
    @Parameter(title: "Soup")
    var soup: Soup
    
    @Parameter(title: "Quantity", inclusiveRange: (1, 10))
    var quantity: Int

    // Other properties
}
```


## Responding to the Action button on Apple Watch Ultra
> https://developer.apple.com/documentation/appintents/actionbuttonarticle

### 
#### 
Start by creating either an  or an  that defines the types of workouts that your app supports. If your app supports only a single workout, you can create an enumeration with a single case. Also define the display representation for each type of workout that your app supports. Apple Watch Ultra shows the case description’s title and subtitle below the First Press settings when someone sets your app as the workout app in Settings > Action Button.
```swift
enum WorkoutEnum: String, AppEnum {
    
    // List the types of workout your app supports.
    case running

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Workout"

    // Define the display representation for each of the workouts your app supports.
    static var caseDisplayRepresentations: [WorkoutEnum: DisplayRepresentation] =
        [.running: DisplayRepresentation(title: "Running", subtitle: "outside run")]
}
```

```
Next, create a structure that adopts the  protocol. Your implementation needs to define the intent’s , a list of , and a parameter that contains the .
```swift
struct MyStartWorkoutIntent: StartWorkoutIntent {

    // Define the intent's title.
    static var title: LocalizedStringResource = "Start Workout"
    
    // Define a list of start workout intents that appear below the First Press settings when someone sets your app as the workout app in Settings > Action Button.

    static var suggestedWorkouts: [MyStartWorkoutIntent] = [MyStartWorkoutIntent()]

    // Define a parameter that specifies the type of workout that this intent starts.
    @Parameter(title: "Type of Workout")
    var workoutStyle: WorkoutEnum

    // Define an init method that sets the default workout type.
    init() {
        workoutStyle = .running
    }

    // Add the display representation, and the perform method here.
}
```

> **important:** Define your implementation’s `workoutStyle` property using the  property wrapper.
Next, set the display strings for the intent by defining the `displayRepresentation` just after the intent’s initializer.
You can dynamically change the list of suggested workouts by changing the value of the  property and then calling , which tells the system to reread the suggested workouts.
Next, set the display strings for the intent by defining the `displayRepresentation` just after the intent’s initializer.
```swift
var displayRepresentation: DisplayRepresentation {
    WorkoutEnum.caseDisplayRepresentations[workoutStyle] ??
    DisplayRepresentation(title: "Unknown")
}
```

```
Then, implement your intent’s  method. The system calls this method when anything starts the intent. In your implementation, you have 30 seconds to start a workout session and return a successful value. If you don’t start a workout session in that time, the system displays an error message, but the app remains in the foreground. People can start a workout session directly from the app, but without a session, the app goes to the background the next time they drop their wrist.
```swift
// Define the method that the system calls when it performs the intent.
func perform() async throws -> some IntentResult {
    logger.debug("*** Performing a Start Intent. ***")
    
    // Start a workout session inside the perform method.
    let workoutManager = MyWorkoutManager.shared
    try await workoutManager.startWorkout(type: workoutStyle)
    
    // Schedule a task to request authorization and then set up the data source and start collecting data from the workout.
    Task {
        await workoutManager.requestAuthorization()
        
        do {
            try await workoutManager.startCollectingData()
        } catch {
            fatalError("*** An error occurred while setting up the data source: \(error.localizedDescription) ***")
        }
    }
    
    // Return a successful result.
    return .result()
}
```

Before authorizing the HealthKit data, create and start your workout session.
```swift
func startWorkout(type: WorkoutEnum) throws {
    logger.debug("*** Start a workout of type \(type.rawValue) ***")
    
    logger.debug("==> Creating the workout configuration.")
    let configuration = HKWorkoutConfiguration()
    configuration.activityType = .running
    configuration.locationType = .outdoor
    
    self.configuration = configuration
    
    logger.debug("==> Creating the workout session.")
    let session = try HKWorkoutSession(healthStore: store, configuration: configuration)
    
    session.delegate = self
    self.session = session
    workoutType = type
    
    logger.debug("==> Starting the session.")
    session.startActivity(with: Date())
}
```

Because the app hasn’t created a data source for the workout session, the session doesn’t generate any data.
Next, request authorization for all the HealthKit data types that your workout sessions use.
```swift
func requestAuthorization() async {
    logger.debug("*** Requesting Authorization ***")
    
    // The quantity type to write to the health store.
    let typesToShare: Set = [
        HKQuantityType.workoutType()
    ]

    // The quantity types to read from the health store.
    let typesToRead: Set = [
        HKQuantityType(.heartRate),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.distanceWalkingRunning)
    ]
    
    guard HKHealthStore.isHealthDataAvailable() else {
        logger.debug("*** HealthKit is not supported on this device. ***")
        return
    }
    
    do {
        try await store.requestAuthorization(toShare: typesToShare, read: typesToRead)
    } catch {
        fatalError("*** An error occurred while requesting authorization to read and save data: \(error.localizedDescription) ***")
    }

    enabled = true
}
```

This authorization request can take an arbitrarily long amount of time. Any time you request authorization for new data, the system displays an authorization sheet, and waits until someone either authorizes the data or dismisses the sheet. However, if someone has already authorized the requested data types, the system returns immediately.
After the authorization request finishes, set up the data source, assign a delegate to receive data from the workout builder, and begin collecting data from the workout.
```swift
func startCollectingData() async throws {
    precondition(enabled == true)
    guard let configuration else { fatalError("*** You need to create a workout configuration before calling this method. ***") }
    guard let session else { fatalError("*** You need to create a session before calling this method. ***") }
    
    logger.debug("==> Setting the session's data source.")
    let builder = session.associatedWorkoutBuilder()
    builder.dataSource = HKLiveWorkoutDataSource(healthStore: store,
                                                 workoutConfiguration: configuration)
    
    builder.delegate = self
    
    logger.debug("==> Begin collecting data.")
    try await builder.beginCollection(at: Date())
    
    self.builder = builder

    logger.debug("==> Donate the mark lap intent as the Action button's next action.")
    try await MyStartWorkoutIntent().donate(result: .result(actionButtonIntent: MyMarkLapIntent()))
}
```

#### 
Your app can provide a list of suggested workout types, letting people associate a particular workout type with the Action button.
To suggest multiple workout types, start by defining the different types of workouts that your app supports in your  implementation.
```swift
enum WorkoutEnum: String, AppEnum {

    // List the types of workout your app supports.
    case walking
    case running
    case swimming
    case cycling

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Workout"

    // Set the display representation here.
}
```

```
Then set a display representation for each case.
```swift
static var caseDisplayRepresentations: [WorkoutEnum: DisplayRepresentation] =
[.walking: DisplayRepresentation(title: "Walking", subtitle: "outside walk"),
 .running: DisplayRepresentation(title: "Running", subtitle: "outside run"),
 .swimming: DisplayRepresentation(title: "Swimming", subtitle: "lap swim"),
 .cycling: DisplayRepresentation(title: "Cycling", subtitle: "outside cycling")
]
```

```
Next, in your  implementation, define the set of suggested workouts.
```swift
static var suggestedWorkouts: [MyStartWorkoutIntent] =
[MyStartWorkoutIntent(style: .walking),
 MyStartWorkoutIntent(style: .running),
 MyStartWorkoutIntent(style: .swimming),
 MyStartWorkoutIntent(style: .cycling)]
```

```
Then, in the  method, check the intent’s  and create the corresponding workout session.
```swift
func perform() async throws -> some IntentResult {

    let workoutManager = MyWorkoutManager.shared
    await workoutManager.requestAuthorization()
    await workoutManager.startWorkout(type: workoutStyle)
    return .result()
}
```

```
Create a configuration for the specified type of workout.
```swift
func startWorkout(type: WorkoutEnum) throws {
    logger.debug("*** Should be starting a workout of type \(type.rawValue) ***")
    
    logger.debug("==> Creating the workout configuration.")
    let configuration = HKWorkoutConfiguration()
    
    switch type {
    case .walking:
        configuration.activityType = .walking
    case .running:
        configuration.activityType = .running
    case .swimming:
        configuration.activityType = .swimming
    case .cycling:
        configuration.activityType = .cycling
    }
    configuration.activityType = type.activityType()
    
    if type == .swimming {
        configuration.locationType = .indoor
        configuration.swimmingLocationType = .pool
        configuration.lapLength = HKQuantity(unit: HKUnit.yard(), doubleValue: 25.0)
    } else {
        configuration.locationType = .outdoor
    }
    
    self.configuration = configuration
    
    logger.debug("==> Creating the workout session.")
    let session = try HKWorkoutSession(healthStore: store, configuration: configuration)
    
    session.delegate = self
    self.session = session
    workoutType = type
    
    logger.debug("==> Starting the session.")
    session.startActivity(with: Date())
}
```

```
And, finally, request authorization for all the data types that your workout sessions use.
```swift
// The quantity types to read from the health store.
let typesToRead: Set = [
    HKQuantityType(.heartRate),
    HKQuantityType(.activeEnergyBurned),
    HKQuantityType(.distanceCycling),
    HKQuantityType(.distanceSwimming),
    HKQuantityType(.distanceWalkingRunning)
]
```

#### 
Apple Watch Ultra runs the next action when someone presses the Action button while a workout or dive session is already running. This means the first time someone presses the Action button, the system starts your session. If they press the Action button any other time during the session, it performs the next action.
To set the next action, implement a structure that adopts the  protocol.
```swift
struct MarkLapIntent: AppIntent {
    static var title: LocalizedStringResource = "Mark Lap"

    func perform() async throws -> some IntentResult {
        logger.debug("*** Perform a mark lap intent. ***")
        await MyWorkoutManager.shared.markLap(at: Date())
        return .result()
    }
}
```

However, in most cases you want to donate a next action regardless of whether the user presses the Action button or launches the session from within your app. To ensure that your app donates the correct intent, simply return `.result()` from your start intent, and then donate the next intent as soon as the session starts.
Previous code examples show how to donate the `MyMarkLapIntent` in its `startCollectingData()` method. The app then calls this method when starting a workout from the Action button or from the app’s user interface.
```swift
logger.debug("==> Donate the mark lap intent as the Action button's next action.")
try await MyStartWorkoutIntent().donate(result: .result(actionButtonIntent: MyMarkLapIntent()))
```

#### 
Apple Watch Ultra supports pausing and resuming a current workout session by simultaneously pressing both the Action button and the side button.
To implement the pause action, create a structure that adopts the  protocol.
```swift
struct MyPauseWorkoutIntent: PauseWorkoutIntent {
    static var title: LocalizedStringResource = "Pause Workout"

    func perform() async throws -> some IntentResult {
        logger.debug("*** Performing a pause intent. ***")
        await MyWorkoutManager.shared.pauseWorkout()
        return .result()
    }
}
```

This intent needs a  property that provides a localized description of the action, and a  method, which the system calls when it performs the intent.
Similarly, to implement the resume action, create a structure that adopts the  protocol.
```swift
struct MyResumeWorkoutIntent: ResumeWorkoutIntent {
    static var title: LocalizedStringResource = "Resume Workout"

    func perform() async throws -> some IntentResult {
        logger.debug("*** Performing a resume intent. ***")
        await MyWorkoutManager.shared.resumeWorkout()
        return .result()
    }
}
```

#### 
Dive sessions work similarly to workout sessions. To start a dive session, implement a structure that adopts the  protocol. Typically, people start the dive session just before entering the water. Your app can then donate App Intents that help them use your app while in the water. For example, while in the water they can’t use the touch screen, but the Action button and Digital Crown function normally.
```swift
struct MyStartDiveSessionIntent: StartDiveIntent {

    static var title: LocalizedStringResource = "Starting a dive session."

    func perform() async throws -> some IntentResult {
        logger.debug("*** Starting a dive session. ***")

        await DiveManager.shared.start()
        return .result(actionButtonIntent: MyCollectSubmergedDataIntent())
    }
}
```

#### 
The previous examples use singleton objects to share data between the different parts of your app; however, App Intents support dependency injection, letting you define the data in your main app, and access it in your intents.
In your intents, create a property that uses the  property wrapper.
```swift
struct MyStartWorkoutIntent: StartWorkoutIntent {
  @Dependency var workoutManager: MyWorkoutManager

  // Add remaining code here.
}
```

```
Then, as early as possible when your app launches, use the  to define the dependency.
```swift
AppDependencyManager.shared.add { MyWorkoutManager() }
```

#### 

## Static parameter types
> https://developer.apple.com/documentation/appintents/app-enums

### 
App enums represent a fixed set of possible values that you use as intent parameters that appear in interfaces like the Shortcuts app or Siri responses. In contrast to app entities that provide you with a way to describe dynamic content to the system, app enums describe static, predefined values you know at compile time, such as a set of categories. For example, the  sample app uses an app enum to describe different types of activities it supports. The following code snippet uses an extension to add conformance with the  protocol to the `ActivityStyle` enumeration and provides localized display representations:
```swift
enum ActivityStyle: String, Codable, Sendable {
    case biking
    case equestrian
    case hiking
    case jogging
    case crossCountrySkiing
    case snowshoeing
    
    /// The string name for an SF Symbols symbol representing the value.
    var symbol: String {
        switch self {
        case .biking:
            return "figure.outdoor.cycle"
        case .equestrian:
            return "figure.equestrian.sports"
        case .hiking:
            return "figure.hiking"
        case .jogging:
            return "figure.run"
        case .crossCountrySkiing:
            return "figure.skiing.crosscountry"
        case .snowshoeing:
            return "snowflake"
        }
    }

    /// The HealthKit workout type that corresponds to the activity type.
    var workoutStyle: HKWorkoutActivityType {
        switch self {
        case .biking:
            return .cycling
        case .equestrian:
            return .equestrianSports
        case .hiking:
            return .hiking
        case .jogging:
            return .running
        case .crossCountrySkiing:
            return .crossCountrySkiing
        case .snowshoeing:
            return .snowSports
        }
    }
}

/// Conforming `ActivityStyle` to `AppEnum` makes it available for use as a parameter in an `AppIntent`.
extension ActivityStyle: AppEnum {
    
    /**
     A localized name representing this entity as a concept people are familiar with in the app, including localized variations based on the plural
     rules the app defines in `AppIntents.stringsdict`, which the app references through the `table` parameter. The system may show
     this value to people when they configure an intent.
     */
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("Activity", table: "AppIntents"),
            numericFormat: LocalizedStringResource("\(placeholder: .int) activities", table: "AppIntents")
        )
    }
    
    /// Localized names for each case that the enumeration defines. The system shows these values to people when they configure or use an intent.
    static let caseDisplayRepresentations: [ActivityStyle: DisplayRepresentation] = [
        .biking: DisplayRepresentation(title: "Biking",
                                       subtitle: "Mountain bike ride",
                                       image: .init(systemName: "figure.outdoor.cycle")),
        
        .equestrian: DisplayRepresentation(title: "Equestrian",
                                           subtitle: "Equestrian sports",
                                           image: .init(systemName: "figure.equestrian.sports")),
        
        .hiking: DisplayRepresentation(title: "Hiking",
                                       subtitle: "A lengthy outdoor walk",
                                       image: .init(systemName: "figure.hiking")),
        
        .jogging: DisplayRepresentation(title: "Jogging",
                                        subtitle: "A gentle run",
                                        image: .init(systemName: "figure.run")),
        
        .crossCountrySkiing: DisplayRepresentation(title: "Skiing",
                                                   subtitle: "Cross-country skiing",
                                                   image: .init(systemName: "figure.skiing.crosscountry")),
        
        .snowshoeing: DisplayRepresentation(title: "Snowshoeing",
                                            subtitle: "Walking in the snow",
                                            image: .init(systemName: "snowflake"))
    ]
}
```


