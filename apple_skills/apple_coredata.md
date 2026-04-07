# Apple COREDATA Skill


## Accessing data when the store changes
> https://developer.apple.com/documentation/coredata/accessing-data-when-the-store-changes

### 
#### 
Query generations leverage WAL mode to let you query against the historical state of the database. Core Data appends transactions to a `.sqlite-wal` file, or journal, in the same directory as the main store file. When your context reads from the journal, it starts at the transaction associated with a specific generation, instead of at the most recent transaction.
To confirm whether a custom store has WAL mode enabled, turn on SQL logging. Choose Product > Scheme > Edit Scheme, then choose the Run action, and add the following line under Arguments Passed on Launch:
```swift
-com.apple.CoreData.SQLDebug 1
```

```
Run your app, and look for the following output in the console:
```swift
CoreData: sql: pragma journal_mode=wal
```

#### 
To pin a context, call  and pass an opaque . The context updates to the specified generation lazily on the next read (fetching or faulting) operation.
Use the  generation token to pin the context to the generation corresponding to the most recent store transaction. For example, pass the  generation token when setting up your stack to pin the view context to the first generation that it fetches.
```swift
// Pin the context to the generation that corresponds with the most recent
// store transaction.
do {
    try persistentContainer.viewContext.setQueryGenerationFrom(.current)
} catch {
    // Handle the error appropriately.
    print("Failed to pin the context:", error.localizedDescription)
}
```

To unpin a context, call , passing `nil`.
Alternatively, use the  from another pinned context to align both contexts to the same generation.
To unpin a context, call , passing `nil`.
```swift
// Unpin the context.
do {
    try persistentContainer.viewContext.setQueryGenerationFrom(nil)
} catch {
    // Handle the error appropriately.
    print("Failed to unpin the context:", error.localizedDescription)
}
```

#### 
Advance a context to the generation of the most recent transaction, and pin it there, by calling  and passing the  token. The context updates to the specified generation lazily on the next read (fetching or faulting) operation.
```swift
// Advance the context to the generation of the most recent store transaction.
do {
    try persistentContainer.viewContext.setQueryGenerationFrom(.current)
} catch {
    // Handle the error appropriately.
    print("Failed to set the query generation:", error.localizedDescription)
}
```

#### 
Refresh any managed objects registered to the context after you change the context’s query generation or unpin the context. Managed objects don’t automatically refresh, as this behavior may not be desirable and is difficult to revert.
Call  on the context to refresh its existing managed objects.
```swift
// Refresh existing managed objects.
persistentContainer.viewContext.refreshAllObjects()
```

```
You can also refresh your objects by fetching them again. Call  on the context to retrieve a fresh set of managed objects matching your request criteria.
```swift
// Alternatively, refresh objects by fetching them again.
let request = NSFetchRequest<ShoppingItem>(entityName: "ShoppingItem")
request.fetchBatchSize = 10

// Execute the fetch.
let results = await persistentContainer.viewContext.perform {
    do {
        return try self.persistentContainer.viewContext.fetch(request)
    } catch {
        // Handle the error appropriately. It's useful to use
        // `fatalError(_:file:line:)` during development.
        fatalError("Failed to refresh the objects: \(error.localizedDescription)")
    }
}
```


## Adopting SwiftData for a Core Data app
> https://developer.apple.com/documentation/coredata/adopting-swiftdata-for-a-core-data-app

### 
#### 
#### 
Each model file in this sample uses the  macro to add necessary conformances for the `PersistentModel` and  protocols:
The SwiftData sample sets up the schema with Swift types that conform to the  protocol, which captures information about the app’s types, including properties and relationships. Each model file corresponds to an individual entity, with identical entity names, properties, and relationships as its Core Data counterpart.
Each model file in this sample uses the  macro to add necessary conformances for the `PersistentModel` and  protocols:
```swift
@Model class Trip {
    #Index<Trip>([\.name], [\.startDate], [\.endDate], [\.name, \.startDate, \.endDate])
    #Unique<Trip>([\.name, \.startDate, \.endDate])
    
    @Attribute(.preserveValueOnDeletion)
    var name: String
    var destination: String
    
    @Attribute(.preserveValueOnDeletion)
    var startDate: Date
    
    @Attribute(.preserveValueOnDeletion)
    var endDate: Date

    @Relationship(deleteRule: .cascade, inverse: \BucketListItem.trip)
    var bucketList: [BucketListItem] = [BucketListItem]()
    
    @Relationship(deleteRule: .cascade, inverse: \LivingAccommodation.trip)
    var livingAccommodation: LivingAccommodation?
    ...
```

Additionally, the app sets up the container using  to ensure that all views access the same `ModelContainer`.
```
Additionally, the app sets up the container using  to ensure that all views access the same `ModelContainer`.
```swift
.modelContainer(modelContainer)
```

```
Setting up the `ModelContainer` also creates and sets a default  in the environment. The app can access the `ModelContext` from any scene or view using an environment property.
```swift
@Environment(\.modelContext) private var modelContext
```

#### 
This app creates a new instance of a trip and inserts it into the  for persistence:
```swift
if newTripSegment == .personal {
    newTrip = PersonalTrip(name: name, destination: destination, startDate: startDate, endDate: endDate, reason: reason)
} else if newTripSegment == .business {
    newTrip = BusinessTrip(name: name, destination: destination, startDate: startDate, endDate: endDate, perdiem: perdiem)
} else {
    newTrip = Trip(name: name, destination: destination, startDate: startDate, endDate: endDate)
}
modelContext.insert(newTrip)
```

#### 
The app uses the SwiftData implicit save feature to persist data. This implicit save occurs on UI life cycle events and on a timer after the context changes. For more information about enabling autosave, see the  property.
The app calls  on the  with the instance to delete.
```swift
modelContext.delete(trip)
```

#### 
This sample app fetches the complete list of upcoming trips by wrapping an array of trips in a  macro, which fetches `Trip` objects from the container.
```swift
@Query(sort: \Trip.startDate, order: .forward)
var trips: [Trip]
```

```
This sample also fetches data by calling  on the  and passing in a  that specifies both the entity to retrieve data from as well as a corresponding  that specifies the conditions for the object to fetch.
```swift
var descriptor = FetchDescriptor<BucketListItem>()
let tripName = trip.name
descriptor.predicate = #Predicate { item in
    item.title.contains(searchText) && tripName == item.trip?.name
}
let filteredList = try? modelContext.fetch(descriptor)
```

#### 
The SwiftData-Inheritance version of the app extends the `Trip` class into two distinct kinds of Trips, `PersonalTrip` and `BusinessTrip`, building on the basic `Trip` model to include more specialized properties for different kinds of Trips.
```swift
class PersonalTrip: Trip {...}
```

```
Both `PersonalTrip` and `BusinessTrip` inherit basic properties from their superclass, `Trip`, while defining their own specialized properties, as shown in the following code. For instance, `PersonalTrip`, has an additional property that describes the reason for the trip.
```swift
init(name: String, destination: String, startDate: Date = .now, endDate: Date = .distantFuture, reason: Reason) {
    self.reason = reason
    super.init(name: name, destination: destination, startDate: startDate, endDate: endDate)
}
```

#### 
#### 
The namespaces in the coexistence sample use the pre-existing -based entity subclasses so that they don’t conflict with the SwiftData classes. Note that this refers to the class name, not the entity name.
```swift
class CDTrip: NSManagedObject {...}
```

The sample then refers to the entity as `CDTrip` when accessing it in the Core Data host app. For instance, when adding a new `Trip`:
```
The sample then refers to the entity as `CDTrip` when accessing it in the Core Data host app. For instance, when adding a new `Trip`:
```swift
let newTrip = CDTrip(context: viewContext)
```

#### 
This sample ensures that both the Core Data and SwiftData persistent stacks write to the same store file by setting the persistent store URL for the container description:
```swift
if let description = container.persistentStoreDescriptions.first {
    description.url = url
    ...
}
```

```
Additionally, the coexistence sample must set the . Although SwiftData enables persistent history tracking automatically, Core Data does not, so the app enables persistent history manually.
```swift
description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
```

#### 
1. Adding a key value pair to the shared `UserDefaults` ( for the widget and the main app to share the changes.
2. Adding a new attribute in `Trip` so the widget can mark the trip as “unread” when changing the living accommodation status.
The first option introduces a new storage, and hence needs to maintain the consistency between SwiftData and the shared `UserDefaults`. The second option is easier to implement, but introduces and maintains a new attribute, which is redundant and consumes extra storage space; for real-world apps that manage more complicated changes and have larger data set, that may not be the favorite approach.
This sample chooses to detect the changes with the third option. To do so, it sets up a `HistoryDescriptor<DefaultHistoryTransaction>` with a history token (`DefaultHistoryToken`) and calls `fetchHistory(_:)` to retrieve the history transactions (`DefaultHistoryTransaction`) after the token, as shown in the following code:
```swift
private func findTransactions(after historyToken: DefaultHistoryToken?, author: String) -> [DefaultHistoryTransaction] {...}
```

```
After getting the transactions, it uses the following code to find the trips that have living accommodation changes:
```swift
private func findTrips(in transactions: [DefaultHistoryTransaction]) -> (Set<Trip>, DefaultHistoryToken?) {...}
```


## Consuming relevant store changes
> https://developer.apple.com/documentation/coredata/consuming-relevant-store-changes

### 
#### 
When you create a persistent container, set the  option on the store description to  to enable history tracking.
```swift
// Pass the data model filename to the container’s initializer.
let container = PersistentContainer(name: "DataModel")

// Get the persistent store description.
let description = container.persistentStoreDescriptions.first

// Set the persistent history tracking key option.
description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
```

#### 
In the persistent container, set the  option to  to enable listening for remote change notifications.
```swift
description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
```

```
In your view, add an observer to listen for remote change notifications.
```swift
.onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
    .receive(on: DispatchQueue.main)) { _ in
        fetchRemoteChanges()
        
        viewContext.perform {
            do {
                try viewContext.save()
            } catch {
                print("Failed to save changes: \(error.localizedDescription)")
            }
        }
    }
```

#### 
Each history transaction automatically includes the originating ,  and . You can supply additional information about the source of a change by setting each managed object context’s  and .
Provide a unique  for each context to identify it in the persistent history. The context’s  becomes the persistent history transaction’s . You only need to set this once per context.
```swift
class PersistentContainer: NSPersistentContainer {
    override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
        
        // Set the context's name.
        viewContext.name = "viewContext"
    }
}
```

```
You can also set a  before each context save to differentiate among multiple call sites that modify the same context. The context’s  becomes the  of subsequent persistent history transactions.
```swift
let newItem = ShoppingItem(context: viewContext)

// Set newItem properties.

// Set the transaction author.
viewContext.transactionAuthor = "addItem"

// Perform a save.
viewContext.perform {
    do {
        try viewContext.save()
        
        // Reset the transaction author to prevent misattribution of
        // future transactions.
        viewContext.transactionAuthor = nil
    } catch {
        print("Failed to save changes:", error.localizedDescription)
    }
}
```

Reset the context’s  to `nil` after saving the context to prevent misattribution of future transactions.
#### 
Create an instance of  to keep track of the most recent history.
```swift
var lastToken: NSPersistentHistoryToken?
```

```
Save the token to disk so you can track history across app launches and fetch history based on the token.
```swift
var lastToken: NSPersistentHistoryToken? = nil {
    didSet {
        // Encode the token.
        guard let lastToken,
              let data = try? NSKeyedArchiver.archivedData(withRootObject: lastToken,
                                                           requiringSecureCoding: true) else {
            return
        }
        
        do {
            // Write the token to disk.
            try data.write(to: tokenFileURL)
        } catch {
            print("Failed to write token data:", error.localizedDescription)
        }
    }
}

lazy var tokenFileURL: URL = {
    // Get the URL to the persistent store directory.
    let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("ShoppingList",
                                                                                 isDirectory: true)
    
    // Create the directory if it doesn't already exist.
    if FileManager.default.fileExists(atPath: url.path) == false {
        do {
            try FileManager.default.createDirectory(at: url,
                                                    withIntermediateDirectories: true)
        } catch {
            print("Failed to create persistent container URL:", error.localizedDescription)
        }
    }
    
    // Append the name of the token data file and return the URL.
    return url.appendingPathComponent("token.data", isDirectory: false)
}()
```

#### 
The following example shows a request to fetch new history since the last time you fetched history and convert the  to an array of :
```swift
// Create a fetch history request with the last token.
let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastToken)

// Get a background context.
let backgroundContext = persistentContainer.newBackgroundContext()

// Perform the fetch.
guard let historyResult = await backgroundContext.perform({
    let historyResult = try? backgroundContext.execute(fetchHistoryRequest) as? NSPersistentHistoryResult
    return historyResult?.result
}) else {
    fatalError("Failed to fetch history")
}

// Cast the result as an array of history transactions.
guard let historyTransactions = historyResult as? [NSPersistentHistoryTransaction] else {
    fatalError("Failed to convert history result to history transactions")
}
```

#### 
Each transaction represents a set of changes. Iterate through the array of transactions to learn their details. The following code loops through the results of the `fetchHistoryRequest` to inspect the properties of each transaction.
```swift
for transaction in history.reversed() {
    // Token, date, and transaction number.
    let token = transaction.token
    let timestamp = transaction.timestamp
    let transactionNumber = transaction.transactionNumber
    
    // Transaction source details.
    let store = transaction.storeID
    let bundle = transaction.bundleID
    let process = transaction.processID
    let context = transaction.contextName ?? "Unknown context"
    let author = transaction.author ?? "Unknown author"
    
    // Get the transaction's changes.
    guard let changes = transaction.changes else { continue }
}
```

Iterate through a transaction’s changes to identify each object that changed, the type of change that occurred, and any details about the change.
In the case of an update, the  set includes any updated attributes and relationships. In the case of a deletion, the  dictionary includes key-value pairs for any attributes marked for preservation after deletion.
```swift
for change in changes {
    let objectID = change.changedObjectID
    let changeID = change.changeID
    let transaction = change.transaction
    let changeType = change.changeType
    var changedAttributes = [String]()
    
    // Iterate over the change type to get updated or deleted attributes.
    switch changeType {
    case .update:
        guard let updatedProperties = change.updatedProperties else { break }
        for property in updatedProperties {
            changedAttributes.append(property.name)
        }
    case .delete:
        guard let tombstone = change.tombstone else { break }
        changedAttributes.append(tombstone["name"] as? String ?? "Unknown name")
    default:
        break
    }
}
```

#### 
Filter the history to narrow it to changes that affect the current view. The following code filters for changes to `ShoppingItem` instances, and it updates the last transaction token as it goes.
```swift
var filteredTransactions = [NSPersistentHistoryTransaction]()
for transaction in transactions {
    guard let changes = transaction.changes else { continue }
    
    let filteredChanges = changes.filter { change -> Bool in
        ShoppingItem.entity().name == change.changedObjectID.entity.name
    }
    
    if filteredChanges.isEmpty == false {
        filteredTransactions.append(transaction)
    }
    
    lastToken = transaction.token
}
```

#### 
To merge the relevant changes into your view context, first obtain a notification by calling  on the transaction. Then, pass the notification to .
```swift
if filteredTransactions.isEmpty == false {
    // Iterate over filtered transactions and merge the changes in the
    // object ID notification that you specify.
    for transaction in filteredTransactions {
        await persistentContainer.viewContext.perform {
            self.persistentContainer.viewContext.mergeChanges(
                fromContextDidSave: transaction.objectIDNotification()
            )
        }
    }
}
```

#### 
In the persistent history,  changes include a  dictionary with key-value pairs for any attributes marked for preservation after deletion.
```swift
var deletedAttributes = [String]()

for transaction in history.reversed() {
    guard let changes = transaction.changes else { continue }
    
    for change in changes where change.changeType == .delete {
        if let tombstone = change.tombstone {
            deletedAttributes.append(tombstone["name"] as? String ?? "Unknown attribute")
        }
    }
}
```

#### 
Because persistent history tracking transactions take up space on disk, determine a clean-up strategy to remove them when you no longer need them. Before you purge history, ensure that your app and its clients have consumed the history they need.
Similar to fetching history, you can use  to delete history older than a token, a transaction, or a date. For example, you can delete all transactions older than seven days:
```swift
// Get the point in time seven days ago.
let sevenDaysAgo = Calendar.current.date(byAdding: .day,
                                         value: -7,
                                         to: Date())!

// Create a purge history request to delete history before seven days ago.
let purgeHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: sevenDaysAgo)

// Get a background context.
let backgroundContext = persistentContainer.newBackgroundContext()

// Execute the request.
await backgroundContext.perform {
    do {
        try backgroundContext.execute(purgeHistoryRequest)
    } catch {
        print("Failed to purge history:", error.localizedDescription)
    }
}
```


## Creating a Core Data Model for CloudKit
> https://developer.apple.com/documentation/coredata/creating-a-core-data-model-for-cloudkit

### 
#### 
|  | `Undefined` and  attribute types aren’t supported. |
#### 
After creating your Core Data model, inform CloudKit about the types of records it contains by initializing a development schema. This is a draft schema that you can rewrite as often as necessary during development. You can’t delete a record type or modify any existing attributes after you promote a development schema to production.
Use the persistent container to initialize the development schema, which you can do during app launch or from within one or more integration tests. To exclude schema initialization from your production builds, use the following:
```swift
let container = NSPersistentCloudKitContainer(name: "Earthquakes")

// Only initialize the schema when building the app with the 
// Debug build configuration.        
#if DEBUG
do {
    // Use the container to initialize the development schema.
    try container.initializeCloudKitSchema(options: [])
} catch {
    // Handle any errors.
}
#endif
```

```
After initializing the schema, the console contains an entry similar to the following:
```None
<NSCloudKitMirroringDelegate: 0x7f9699d29a90>: Successfully set up CloudKit 
    integration for store
```

#### 
#### 
#### 
- Version your entities by including a `version` attribute from the outset, and use a fetch request to select only those records that are compatible with the current version of the app. If you adopt this approach, older versions of your app won’t fetch records that a user creates with a more recent version, effectively hiding them on that device.
For example, consider a `Post` entity with a `version` attribute that stores the version of the app that creates the record. You can use a predicate to fetch only the records that are compatible with the current version of the app.
```swift
// The current version of the app's data model.
let maxCompatibleVersion = 3

let context = NSManagedObjectContext(
    concurrencyType: .privateQueueConcurrencyType
)

context.performAndWait {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Post")
    
    // Create a predicate that matches against the version attribute.
    fetchRequest.predicate = NSPredicate(
        format: "version <= %d",
        argumentArray: [maxCompatibleVersion]
    )
    
    // Fetch all posts with a version less than or equal to maxCompatibleVersion.
    let results = context.fetch(fetchRequest)
}
```


## Generating code
> https://developer.apple.com/documentation/coredata/generating-code

### 
After you define your entities, their attributes, and relationships as described in Configuring a Core Data Model, specify the classes that you’ll use to create instances of your entities. Core Data optionally generates two files to support your class: a class file and a properties file.
The class file declares the class as a subclass of :
```swift
//
//  Store+CoreDataClass.swift
//  
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(Store)
public class Store: NSManagedObject {

}
```

```
The properties file declares an extension to hold the `@NSManaged` properties that represent attributes and relationships, their accessors, and helper functionality for fetching instances of this type:
```swift
//
//  Store+CoreDataProperties.swift
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension Store {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Store> {
        return NSFetchRequest<Store>(entityName: "Store")
    }

    @NSManaged public var name: String?
    @NSManaged public var shoppingItems: NSSet?

}

// MARK: Generated accessors for shoppingItems
extension Store {

    @objc(addShoppingItemsObject:)
    @NSManaged public func addToShoppingItems(_ value: ShoppingItem)

    @objc(removeShoppingItemsObject:)
    @NSManaged public func removeFromShoppingItems(_ value: ShoppingItem)

    @objc(addShoppingItems:)
    @NSManaged public func addToShoppingItems(_ values: NSSet)

    @objc(removeShoppingItems:)
    @NSManaged public func removeFromShoppingItems(_ values: NSSet)

}

extension Store : Identifiable {

}
```

#### 

## Handling Different Data Types in Core Data
> https://developer.apple.com/documentation/coredata/handling-different-data-types-in-core-data

### 
#### 
To make an attribute `Transient`, select the Core Data model in Xcode Project Navigator, navigate to the Core Data entity, select the attribute in the attributes list, and check the `Transient` box in the Data Model Inspector.
In this sample, `publishMonthID` is a `Transient` attribute derived from `publishDate`. To implement the derivation, this sample provides a custom accessor for `publishDate` and `publishMonthID`. The `setter` method of `publishDate` nullifies `primitivePublishMonthID`, which allows the `getter` method of `publishMonthID` to recalculate the value based on the current `publishDate`.
```swift
@objc public var publishDate: Date? {
    get {
        willAccessValue(forKey: Name.publishDate)
        defer { didAccessValue(forKey: Name.publishDate) }
        return primitivePublishDate
    }
    set {
        willChangeValue(forKey: Name.publishDate)
        defer { didChangeValue(forKey: Name.publishDate) }
        primitivePublishDate = newValue
        primitivePublishMonthID = nil
    }
}
```

The `getter` method of `publishMonthID` recalculates the value if `primitivePublishMonthID` is nil.
```
The `getter` method of `publishMonthID` recalculates the value if `primitivePublishMonthID` is nil.
```swift
@objc public var publishMonthID: String? {
    willAccessValue(forKey: Name.publishMonthID)
    defer { didAccessValue(forKey: Name.publishMonthID) }
    
    guard primitivePublishMonthID == nil, let date = primitivePublishDate else {
        return primitivePublishMonthID
    }
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents([.year, .month], from: date)
    if let year = components.year, let month = components.month {
        primitivePublishMonthID = "\(year * 1000 + month)"
    }
    return primitivePublishMonthID
}
```

With these two methods, `publishMonthID` is associated with `publishDate` and always stays current.
In the case where `publishMonthID` is , the following code ensures that the observations are triggered when `publishDate` changes.
With these two methods, `publishMonthID` is associated with `publishDate` and always stays current.
In the case where `publishMonthID` is , the following code ensures that the observations are triggered when `publishDate` changes.
```swift
class func keyPathsForValuesAffectingPublishMonthID() -> Set<String> {
    return [Name.publishDate]
}
```

#### 
This sample uses a `Derived` attribute, `canonicalTitle`, to support searching the canonical form of book titles. `canonicalTitle` is configured as the canonical form of  `title` by setting the following expression as the value of the `Derivation` field shown Xcode’s Data Model Inspector.
```None
canonical:(title)
```

#### 
`Transformable` attributes store objects with a non-standard type, or a type that isn’t in the attribute type list in Xcode’s Data Model Inspector. To implement a `Transformable` attribute, configure it by setting its type to `Transformable` and specifying the transformer and custom class name in Data Model Inspector, then register a transformer with code before an app loads its Core Data stack.
```swift
// Register the transformer at the very beginning.
// .colorToDataTransformer is a name defined with an NSValueTransformerName extension.
ValueTransformer.setValueTransformer(ColorToDataTransformer(), forName: .colorToDataTransformer)
```

#### 
#### 
This sample uses a `Decimal` attribute to represent the book price, which is then mapped to a variable of `NSDecimalNumber` type. `NSDecimalNumber` has a convenient method to process a currency value.
```swift
newBook.price = NSDecimalNumber(mantissa: value, exponent: -2, isNegative: false)
```

`NSDecimalNumber` also provides a convenient way to present a value with locale in mind.
```
`NSDecimalNumber` also provides a convenient way to present a value with locale in mind.
```swift
cell.price.text = book.price?.description(withLocale: Locale.current)
```


## Linking Data Between Two Core Data Stores
> https://developer.apple.com/documentation/coredata/linking-data-between-two-core-data-stores

### 
#### 
#### 
The sample app creates one `NSPersistentStoreDescription` object for each store with the store’s URL and model configuration, then uses `NSPersistentContainer` to load the stores.
```swift
let container = NSPersistentContainer(name: "CoreDataFetchedProperty")
let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()

let bookStoreURL = defaultDirectoryURL.appendingPathComponent("Books.sqlite")
let bookStoreDescription = NSPersistentStoreDescription(url: bookStoreURL)
bookStoreDescription.configuration = "Book"

let feedbackStoreURL = defaultDirectoryURL.appendingPathComponent("Feedback.sqlite")
let feedbackStoreDescription = NSPersistentStoreDescription(url: feedbackStoreURL)
feedbackStoreDescription.configuration = "Feedback"

container.persistentStoreDescriptions = [bookStoreDescription, feedbackStoreDescription]
container.loadPersistentStores(completionHandler: { (_, error) in
    guard let error = error as NSError? else { return }
    fatalError("###\(#function): Failed to load persistent stores:\(error)")
})
```

#### 
Xcode currently doesn’t generate code for fetched properties, so the sample app adds the following extension to provide the accessor for `feedbackList`.
```swift
extension Book {
    var feedbackList: [Feedback]? { // The accessor of the feedbackList property.
        return value(forKey: "feedbackList") as? [Feedback]
    }
}
```

With the `feedbackList` accessor, the app can access the fetched property directly.
```
With the `feedbackList` accessor, the app can access the fetched property directly.
```swift
guard let feedback = book.feedbackList?[indexPath.row] else { return cell }
let rating = Int(feedback.rating)
let comment = feedback.comment ?? ""
```

```
Unlike a relationship, a fetched property can’t be used in a predicate for `NSFetchRequest`. It isn’t automatically updated when the managed context is saved either. When the sample app saves changes on the `Feedback` entity, the app must refresh the `book` object to update the `book.feedbackList` property.
```swift
context.refresh(book, mergeChanges: true)
```


## Migrating your data model automatically
> https://developer.apple.com/documentation/coredata/migrating-your-data-model-automatically

### 
#### 
#### 
#### 
#### 
#### 
#### 
You request automatic lightweight migration using the options dictionary that you pass into . Set values corresponding to both the  and the  keys to :
```swift
// Create a persistent store coordinator with a managed object model.
let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

// Create a URL to the data store.

do {
    // Set the options to enable lightweight data migrations.
    let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                         NSInferMappingModelAutomaticallyOption: true]
    
    // Set the options when you add the store to the coordinator.
    _ = try coordinator.addPersistentStore(type: .sqlite,
                                           at: storeURL,
                                           options: options)
} catch {
    // Handle the error appropriately. It's useful to use
    // `fatalError(_:file:line:)` during development.
    fatalError("Failed to add persistent store: \(error.localizedDescription)")
}
```


## Reading CloudKit Records for Core Data
> https://developer.apple.com/documentation/coredata/reading-cloudkit-records-for-core-data

### 
#### 
When you initialize a schema, Core Data adds a custom field to the record type, `CD_entityName`, to store the name of the .
For example, an entity named `Post` generates the following structure (before adding its attributes), with its `CD_entityName` set to `Post`, and its `recordType` set to `CD_Post`.
```swift
<CKRecord: 0x7fbae9e19510; recordID=CD_Post_UUID:
(com.apple.coredata.cloudkit.zone:__defaultOwner__), values={
    "CD_entityName" = Post;
}, recordType=CD_Post>
```

Consider a second entity, `ImagePost`, that inherits from Post.
`ImagePost` generates the following structure (before adding its attributes), with its `CD_entityName` set to `ImagePost`, and its `recordType` set to `CD_Post`.
```swift
<CKRecord: 0x7f9c9fe17780; recordID=CD_ImagePost_UUID:
(com.apple.coredata.cloudkit.zone:__defaultOwner__), values={
    "CD_entityName" = ImagePost;
}, recordType=CD_Post>
```

#### 
| Core Data attribute type | `NSManagedObject` attribute type | `CKRecord` attribute type |
| `Integer 16` |  |  |
| `Integer 32` |  |  |
| `Integer 64` |  |  |
| `Double` |  |  |
| `Float` |  |  |
| `Boolean` |  |  |
| `Date` |  |  |
| `Decimal` |  |  |
| `UUID` |  |  |
| `URI` |  |  |
| `String` |  | or |
| `Binary Data` |  | or |
| `Transformable` |  | or |
| `Undefined` | — | not supported |
| `Object ID` | — | not supported |
For example, an entity named `Post` with String `content` and `title` attributes would generate the following fully materialized record, with pairs of fields for `CD_content and` `CD_content_ckAsset`, and for `CD_title` and `CD_title_ckAsset`.
```swift
<CKRecord: 0x7f9c9fd0f870; recordID=CD_Post_UUID:
(com.apple.coredata.cloudkit.zone:__defaultOwner__), values={
    "CD_content" = "An example core data string";
    "CD_content_ckAsset" = "<CKAsset: 0x7f9c9fe1db50; 
path=/var/folders/*/C9EDC901-385B-4778-9D78-03E9C740AD89.fxd, 
UUID=C37985B7-F959-4174-AA93-C404F9DCC6A5>";
    "CD_entityName" = Post;
    "CD_title" = "An example core data string";
    "CD_title_ckAsset" = "<CKAsset: 0x7f9c9fd10140; 
path=/var/folders/*/C7977A3A-623E-441E-9086-66F2F5B7B746.fxd, 
UUID=81800071-ECBD-46E1-B4F9-2F7168269497>";
}, recordType=CD_Post
```

#### 
This one-to-one relationship between `ImageData` and `Attachment` would generate the following CloudKit records.
This one-to-one relationship between `ImageData` and `Attachment` would generate the following CloudKit records.
```swift
<CKRecord: 0x7f9ca1300f50; recordID=CD_Attachment_UUID:
(com.apple.coredata.cloudkit.zone:__defaultOwner__), values={
    "CD_entityName" = Attachment;
    "CD_imageData" = "CD_ImageData_UUID";
}, recordType=CD_Attachment>
<CKRecord: 0x7f9c9fc18610; recordID=CD_ImageData_UUID:
(com.apple.coredata.cloudkit.zone:__defaultOwner__), values={
    "CD_attachment" = "CD_Attachment_UUID";
    "CD_entityName" = ImageData;
}, recordType=CD_ImageData>
```

#### 
For example, a one-to-many relationship between a single `Post` and multiple `Attachment` instances would generate multiple `CD_Attachment` records. Each record contains the foreign key of the `Post` it belongs to in their `CD_post` field.
```swift
<CKRecord: 0x7f9ca1300f50; recordID=CD_Attachment_UUID:
(com.apple.coredata.cloudkit.zone:__defaultOwner__), values={
    "CD_entityName" = Attachment;
    "CD_post" = "CD_VideoPost_UUID";
}, recordType=CD_Attachment>
```

Generated `Post` records don’t contain a reference to their attachments.
#### 
| `CD_relationships` | The relationship names, for example, `“tags:posts”`, sorted according to the CD_entityNames order. |
For example, consider a many-to-many relationship between `Tag` and `Post` entities.
The individual `Tag` and `Post` records don’t contain fields for the relationship.
The individual `Tag` and `Post` records don’t contain fields for the relationship.
```swift
<CKRecord: 0x7f9c9fd0f870; recordID=CD_Post_UUID:
(com.apple.coredata.cloudkit.zone:__defaultOwner__), values={
    "CD_content" = "An example core data string";
    "CD_content_ckAsset" = "<CKAsset: 0x7f9c9fe1db50; 
path=/var/folders/*/C9EDC901-385B-4778-9D78-03E9C740AD89.fxd, 
UUID=C37985B7-F959-4174-AA93-C404F9DCC6A5>";
    "CD_entityName" = Post;
    "CD_title" = "An example core data string";
    "CD_title_ckAsset" = "<CKAsset: 0x7f9c9fd10140; 
path=/var/folders/*/C7977A3A-623E-441E-9086-66F2F5B7B746.fxd, 
UUID=81800071-ECBD-46E1-B4F9-2F7168269497>";
}, recordType=CD_Post>
<CKRecord: 0x7f9ca10188d0; recordID=CD_Tag_UUID:
(com.apple.coredata.cloudkit.zone:__defaultOwner__), values={
    "CD_color" = {length = 17, bytes = 0x536f6d65206578616d706c652064617461};
    "CD_color_ckAsset" = "<CKAsset: 0x7f9c9fd07790; 
path=/var/folders/*/5D5DF5B2-DB27-4F01-B311-52A274374F59.fxd, 
UUID=787F4868-1F4D-4BF7-86D4-3867BEA65172>";
    "CD_entityName" = Tag;
    "CD_name" = "An example core data string";
    "CD_name_ckAsset" = "<CKAsset: 0x7f9ca1300af0; 
path=/var/folders/*/C40A1E1F-C2F5-4BA1-A6ED-F5977301A1F7.fxd, 
UUID=A4C4B698-55FC-4C87-BA8A-D6DD0011DD90>";
    "CD_uuid" = "51BAFD98-D1F7-472F-95D6-BBF40D7CBD75";
}, recordType=CD_Tag>
```

```
The relationship between any two `Tag` and `Post` records exists in a third CDMR record. The CDMR record describes the entity type, record name, and Core Data relationship between the `Tag` and `Post`.
```swift
<CKRecord: 0x7f9ca1301780; recordID=EE64F478-A761-4049-B559-853457ABA997:
(com.apple.coredata.cloudkit.zone:__defaultOwner__), values={
    "CD_entityNames" = "Post:Tag";
    "CD_recordNames" = "CD_Post_UUID:CD_Tag_UUID";
    "CD_relationships" = "tags:posts";
}, recordType=CDMR>
```

#### 
Alternatively, use the class functions , , , and `recordIDs(for:)` on .

## Setting Up Core Data with CloudKit
> https://developer.apple.com/documentation/coredata/setting-up-core-data-with-cloudkit

### 
#### 
#### 
#### 
#### 
#### 
First, enable iCloud, CloudKit, Push notifications, and Remote notifications in the background as described in the preceding sections. Then, replace your persistent container with an instance of .
For example, if you created a project from the Multiplatform App template, with the Use Core Data checkbox selected, the following code appeared in the `PersistenceController`:
```swift
init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "Earthquakes")
    if inMemory {
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    })
    container.viewContext.automaticallyMergesChangesFromParent = true
}
```

```
 supports only local persistent stores. To add the ability to sync a local store to a CloudKit database, replace  with the subclass .
```swift
    let container = NSPersistentCloudKitContainer(name: "Earthquakes")
```

#### 
1. Open your project’s `.xcdatamodeld` file.
4. Add the store description to the persistent container before loading the store.
The following example code creates two store descriptions: one for the “Local” configuration, and one for the “Cloud” configuration. It then sets the cloud store description’s  to match the store with its CloudKit container. Finally, it updates the container’s list of persistent store descriptions to include all local and cloud-backed store descriptions, and loads both stores.
```swift
lazy var persistentContainer: NSPersistentCloudKitContainer = {
    let container = NSPersistentCloudKitContainer(name: "Earthquakes")
    
    // Create a store description for a local store.
    let localStoreLocation = URL(fileURLWithPath: "/path/to/local.store")
    let localStoreDescription =
        NSPersistentStoreDescription(url: localStoreLocation)
    localStoreDescription.configuration = "Local"
    
    // Create a store description for a CloudKit-backed local store.
    let cloudStoreLocation = URL(fileURLWithPath: "/path/to/cloud.store")
    let cloudStoreDescription =
        NSPersistentStoreDescription(url: cloudStoreLocation)
    cloudStoreDescription.configuration = "Cloud"

    // Set the container options on the cloud store.
    cloudStoreDescription.cloudKitContainerOptions = 
        NSPersistentCloudKitContainerOptions(
            containerIdentifier: "com.my.container")
    
    // Update the container's list of store descriptions.
    container.persistentStoreDescriptions = [
        cloudStoreDescription,
        localStoreDescription
    ]
    
    // Load both stores.
    container.loadPersistentStores { storeDescription, error in
        guard error == nil else {
            fatalError("Could not load persistent stores. \(error!)")
        }
    }
    
    return container
}()
```


## Setting up a Core Data stack
> https://developer.apple.com/documentation/coredata/setting-up-a-core-data-stack

### 
#### 
Typically, you initialize a Core Data stack as a singleton:
```swift
// Define an observable class to encapsulate all Core Data-related functionality.
class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    // Create a persistent container as a lazy variable to defer instantiation until its first use.
    lazy var persistentContainer: NSPersistentContainer = {
        
        // Pass the data model filename to the container’s initializer.
        let container = NSPersistentContainer(name: "DataModel")
        
        // Load any persistent stores, which creates a store if none exists.
        container.loadPersistentStores { _, error in
            if let error {
                // Handle the error appropriately. However, it's useful to use
                // `fatalError(_:file:line:)` during development.
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
        
    private init() { }
}
```

#### 
Create an instance of the Core Data stack and inject its managed object context into your app environment:
```swift
@main
struct ShoppingListApp: App {
    // Create an observable instance of the Core Data stack.
    @StateObject private var coreDataStack = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            // Inject the persistent container's managed object context
            // into the environment.
                .environment(\.managedObjectContext,
                              coreDataStack.persistentContainer.viewContext)
        }
    }
}
```

```
Use an environment property wrapper to access the managed object context in your views:
```swift
//#-code-listing(AccessManagedObjectContext) [Access the managed object context]
struct ContentView: View {
    // Get a reference to the managed object context from the environment.
    @Environment(\.managedObjectContext) private var viewContext

    // Remaining implementation of the user interface.
}
```

#### 
Your Core Data stack is a convenient place to put related code, such as methods to save changes and delete managed objects in the persistent store:
```swift
extension CoreDataStack {
    // Add a convenience method to commit changes to the store.
    func save() {
        // Verify that the context has uncommitted changes.
        guard persistentContainer.viewContext.hasChanges else { return }
        
        do {
            // Attempt to save changes.
            try persistentContainer.viewContext.save()
        } catch {
            // Handle the error appropriately.
            print("Failed to save the context:", error.localizedDescription)
        }
    }
    
    func delete(item: ShoppingItem) {
        persistentContainer.viewContext.delete(item)
        save()
    }
}
```

The `save` method improves performance by saving the context only when there are changes.

## Setting up a Core Data stack manually
> https://developer.apple.com/documentation/coredata/setting-up-a-core-data-stack-manually

### 
#### 
To instantiate an , pass in a URL that points to the compiled version of the `.xcdatamodeld` file. This `.momd` file is typically part of your app bundle.
```swift
// Get a URL to the compiled model in the app bundle.
guard let modelURL = Bundle.main.url(forResource: "DataModel",
                                     withExtension: "momd") else {
    fatalError("Failed to find data model")
}

// Use the URL to create a managed object model.
guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
    fatalError("Failed to create model from file: \(modelURL)")
}
```

#### 
Next, pass the managed object model to the  initializer to create a store coordinator with that model.
```swift
// Use the managed object model to create a persistent store coordinator.
let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
```

If you want Core Data to persist your data model to disk, tell the store coordinator where the file exists and what format to use.
```swift
// Get the URL to the Document directory.
let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).last
// Create a URL to the data store.
guard let storeURL = URL(string: "DataModel.sqlite",
                         relativeTo: documentDirectoryURL) else {
    fatalError("Failed to create store URL")
}

do {
    // Set the options to enable lightweight data migrations.
    let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                         NSInferMappingModelAutomaticallyOption: true]
    // Add the store to the coordinator.
    _ = try coordinator.addPersistentStore(type: .sqlite, at: storeURL,
                                       options: options)
} catch {
    fatalError("Failed to add persistent store: \(error.localizedDescription)")
}
```

#### 
Create an , and set its store coordinator property.
```swift
// Create a context to interact with managed objects.
let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
// Assign the coordinator to the context.
context.persistentStoreCoordinator = persistentStoreCoordinator
```


## Sharing Core Data objects between iCloud users
> https://developer.apple.com/documentation/coredata/sharing-core-data-objects-between-icloud-users

### 
#### 
4. Specify the same iCloud container for the `gCloudKitContainerIdentifier` variable in `PersistenceController.swift`.
#### 
#### 
#### 
Every CloudKit container has a  and a . To mirror both of them, the sample app sets up a Core Data stack with two stores, sets one store’s  to `.private` and the other to `.shared`, and then uses  or  to specify the target store for data fetching or saving.
When setting up the store description, the sample app enables  tracking and turns on remote change notifications by setting the `NSPersistentHistoryTrackingKey` and `NSPersistentStoreRemoteChangeNotificationPostOptionKey` options to `true`. Core Data relies on the persistent history to track the store changes, and the sample app updates its UI when remote changes occur.
```swift
privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
```

```
To synchronize data through CloudKit, apps need to use the same CloudKit container. The sample app explicitly specifies the same container for its iOS, macOS, and watchOS apps when setting up the CloudKit container options.
```swift
let cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: gCloudKitContainerIdentifier)
```

#### 
`ShareLink` requires the sharing object be . The `Photo` class in this sample conforms to the protocol by implementing  to provide a  instance, which is based on a new share it creates by calling .
`NSPersistentCloudKitContainer` uses CloudKit zone sharing to share objects. Each share has its own record zone on the CloudKit server. CloudKit has a limit on how many record zones a database can have. To avoid reaching the limit over time, the sample app provides an option for users to share an object by adding it to an existing share, as the following example shows:
```swift
func shareObject(_ unsharedObject: NSManagedObject, to existingShare: CKShare?,
                 completionHandler: ((_ share: CKShare?, _ error: Error?) -> Void)? = nil)
```

#### 
- Maintains a transaction author, and uses it to filter the transactions irrelevant to `NSPersistentCloudKitContainer`.
The following code sets up the history fetch request (`NSPersistentHistoryChangeRequest`):
- Only fetches and consumes the history of the relevant persistent store.
The following code sets up the history fetch request (`NSPersistentHistoryChangeRequest`):
```swift
let lastHistoryToken = historyToken(with: storeUUID)
let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
let historyFetchRequest = NSPersistentHistoryTransaction.fetchRequest!
historyFetchRequest.predicate = NSPredicate(format: "author != %@", TransactionAuthor.app)
request.fetchRequest = historyFetchRequest

if privatePersistentStore.identifier == storeUUID {
    request.affectedStores = [privatePersistentStore]
} else if sharedPersistentStore.identifier == storeUUID {
    request.affectedStores = [sharedPersistentStore]
}
```

#### 
When detecting duplicate tags, the sample app doesn’t delete them immediately. It waits until the next `eventChangedNotification` occurs, and only removes the tags with a `deduplicatedDate` that’s sometime before the last successful export and import event. This allows enough time for `NSPersistentCloudKitContainer` to synchronize the relationships of the deduplicated tags, and the app to establish the relationships for the tag it reserves.
The following code implements the deduplication process:
```swift
func deduplicateAndWait(tagObjectIDs: [NSManagedObjectID])
```

```
The following code shows how the app determines the deduplicated tags it can safely remove:
```swift
@objc
func containerEventChanged(_ notification: Notification)
```

#### 
1. It creates a share using `share(_:to:completion:)` when an owner shares a photo.
3. It allows users to deliver the share URL () to a participant using `ShareLink`.
In this process, the sample app calls  when it changes the share using CloudKit APIs for `NSPersistentCloudKitContainer` to update the store. The following code shows how the app adds a participant:
```swift
participant.permission = permission
participant.role = .privateUser
share.addParticipant(participant)

self.persistentContainer.persistUpdatedShare(share, in: persistentStore) { (share, error) in
    if let error = error {
        print("\(#function): Failed to persist updated share: \(error)")
    }
    completionHandler?(share, error)
}
```


## Syncing a Core Data Store with CloudKit
> https://developer.apple.com/documentation/coredata/syncing-a-core-data-store-with-cloudkit

### 
#### 
#### 
#### 
#### 
For this reason, you need to isolate the current view from changes to the store by ensuring that the records the view expects continue to exist. Using query generations, you pin the persistent container’s  to a specific generation of store data. This allows the context to fulfill faults — placeholder objects whose values haven’t yet been fetched — that existed at the time the view loaded, even if the store changes underneath.
Pin a context to a query generation before its first read from the store.
```swift
try? persistentContainer.viewContext.setQueryGenerationFrom(.current)
```

#### 
#### 
Higher argument values produce more information; start at `1` and increase if you need more detail. For more information about handling errors, see .
#### 
Filter CloudKit logs to see operations on the `cloudd` process for your container.
Push notifications may get dropped or deferred, so don’t rely on them for testing. Watch system logs to observe the status and result of expected activity. Run the `log stream` command from the terminal, filtering by process and container ID. If the logs don’t include the operation, your push may have been dropped. Check the originating device for export activity.
Filter CloudKit logs to see operations on the `cloudd` process for your container.
```swift
$ log stream --info --debug --predicate 'process = "cloudd" and message
contains[cd] "containerID=com.mycontainer"'
```

```
Filter Core Data logs to see information about the mirroring delegate’s setup, exports, and imports for your process.
```swift
$ log stream --info --debug --predicate 'process = "myprocess" and 
(subsystem = "com.apple.coredata" or subsystem = "com.apple.cloudkit")'
```

```
Or monitor both CloudKit and Core Data logs at the same time.
```swift
$ log stream --info --debug --predicate '(process = "myprocess" and
(subsystem = "com.apple.coredata" or subsystem = "com.apple.cloudkit")) or
(process = "cloudd" and message contains[cd] "container=com.mycontainer")'
```


## Using Core Data in the background
> https://developer.apple.com/documentation/coredata/using-core-data-in-the-background

### 
#### 
#### 
Use  to create a new context. For example, to create a private queue context:
```swift
// Create a private queue context.
let context = NSManagedObjectContext(.privateQueue)
```

#### 
You retrieve the managed object ID of a managed object by calling the `objectID` accessor on the  instance.

