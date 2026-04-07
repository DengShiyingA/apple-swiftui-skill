# Apple CLOUDKIT Skill


## Changing Access Controls on User Data
> https://developer.apple.com/documentation/cloudkit/changing-access-controls-on-user-data

### 
#### 
To be sure that you restrict changes and access to all of a user’s data that your app stores, cross-reference the list of containers your app has access to in Xcode and assemble a list of those containers’ identifiers.  describes this process.
The example below stores containers in constants to use later:
```swift
let defaultContainer = CKContainer.default()
let documents = CKContainer(identifier: "iCloud.com.example.myexampleapp.documents")
let settings = CKContainer(identifier: "iCloud.com.example.myexampleapp.settings")
```

#### 
Generate a token in the CloudKit Dashboard by visiting the page for each container, then selecting API Access > New Token > Create Token. Tokens are specific to a deployment environment, so you need separate tokens for the production and development environments.
The example below stores tokens in a dictionary for each container to use later:
```swift
let containerAPITokens: [CKContainer: String] = [
    defaultContainer: "<# Token for the default container #>",
    documents: "<# Token for a custom container #>",
    settings: "<# Token for another custom container #>"
]

let containers = Array(containerAPITokens.keys)
```

#### 
The `restrict` API call requires a new authentication token each time you call the API, in addition to the reusable API token. The example below shows how to create that token using an instance of :
```swift
for container in containers {
    guard let apiToken = containerAPITokens[container] else {
        continue
    }
    
    let fetchAuthorization = CKFetchWebAuthTokenOperation(apiToken: apiToken)
    
    fetchAuthorization.fetchWebAuthTokenCompletionBlock = { webToken, error in
        guard let webToken = webToken, error == nil else { return }
        
        restrict(container: container, apiToken: apiToken, webToken: webToken) { error in
            guard error == nil else {
                 print("Restriction failed. Reason: ", error!)
                 return
            }
            print("Restriction succeeded.")
        }
    }
    
    container.privateCloudDatabase.add(fetchAuthorization)
}
```

After you receive the authentication token, you can immediately call the `restrict` API once for each container.
#### 
The example below defines the `restrict(container:apiToken:webToken:completionHandler:)` and `requestRestriction(url:completionHandler:)` methods for the example above to build the network request for the `restrict` API:
```swift
func requestRestriction(url: URL, completionHandler: @escaping (Error?) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completionHandler(error)
            return
        }
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                completionHandler(RestrictError.failure)
                return
        }
        
        print("Restrict result", httpResponse)
        
        // Other than indicating success or failure, the `restrict` API doesn't return actionable data in its response.
        if data != nil {
            completionHandler(nil)
        } else {
            completionHandler(RestrictError.failure)
        }
    }
    task.resume()
}

/// A utility function that percent encodes a token for URL requests.
func encodeToken(_ token: String) -> String {
    return token.addingPercentEncoding(
        withAllowedCharacters: CharacterSet(charactersIn: "+/=").inverted
    ) ?? token
}

/// An error type that represents a failure in the `restrict` API call.
enum RestrictError: Error {
    case failure
}

func restrict(container: CKContainer, apiToken: String, webToken: String, completionHandler: @escaping (Error?) -> Void) {
    let webToken = encodeToken(webToken)
    
    let identifier = container.containerIdentifier!
    let env = "production" // Use "development" during development.
    let baseURL = "https://api.apple-cloudkit.com/database/1/"
    let apiPath = "\(identifier)/\(env)/private/users/restrict"
    let query = "?ckAPIToken=\(apiToken)&ckWebAuthToken=\(webToken)"
    
    let url = URL(string: "\(baseURL)\(apiPath)\(query)")!
    
    requestRestriction(url: url, completionHandler: completionHandler)
}
```

#### 
When a user requests that you remove restrictions, you use the `unrestrict` API, which performs the opposite operation that the `restrict` API performs.
The example below shows a modified version of the `restrict(container:apiToken:webToken:completionHandler:)` method from the previous example that removes restrictions instead of enabling them:
```swift
func unrestrict(container: CKContainer, apiToken: String, webToken: String, completionHandler: @escaping (Error?) -> Void) {
    let webToken = encodeToken(webToken)
    
    let identifier = container.containerIdentifier!
    let env = "production" // Use "development" during development.
    let baseURL = "https://api.apple-cloudkit.com/database/1/"
    let apiPath = "\(identifier)/\(env)/private/users/unrestrict"
    let query = "?ckAPIToken=\(apiToken)&ckWebAuthToken=\(webToken)"
    
    let url = URL(string: "\(baseURL)\(apiPath)\(query)")!
    
    requestRestriction(url: url, completionHandler: completionHandler)
}
```


## Designing and Creating a CloudKit Database
> https://developer.apple.com/documentation/cloudkit/designing-and-creating-a-cloudkit-database

### 
#### 
#### 
Create a  object with a string representing the type of record you want to store, using . Every record type must have a unique string name.
```swift
let record = CKRecord(recordType: "ToDoItem")
```

```
Then set the record’s fields. Because  is key-value coding compliant, you can use . The values you set could be from a details sheet that the user fills out.
```swift
record.setValuesForKeys([
    "title": "Get apples",
    "dueDate": DateComponents(
        calendar: Calendar.current,
        year: 2019,
        month: 10,
        day: 28).date!,
    "isCompleted": false // Stored as Int(64)
])
```

#### 
To save a record to your container, you must pick a database to save the record to. Each container has a single  database accessible to all app users, and  databases for each user of your app. Also, a user may have a  database if that user is accessing another user’s shared private data. Note that every database within your app’s container shares the same schema.
Although an app can have multiple containers or can share a container, each app has one default container. You access the default container using  on . The following example uses the current user’s private database within the app’s default container and exists in an action handler for a Save button.
```swift
let container = CKContainer.default()
let database = container.privateCloudDatabase
```

```
Save the record to the user’s private database in the app’s container.
```swift
database.save(record) { record, error in
    if let error = error {
        // Handle error.
        return
    }
    // Record saved successfully.
}
```

If saving the record to iCloud succeeds, `error` is `nil`. (If `error` is non-`nil`, see  for possible values of `error.)`
#### 
When designing your app, consider how to handle or prevent error conditions. For example, an error occurs if your app attempts to save a record to a user’s private database and the user hasn’t yet signed in to iCloud. You might handle this scenario by checking whether the user has signed in before the app saves the record. If the user hasn’t signed in, present an alert. If they’re signed in, save the record.
The following example demonstrates preventing the error condition in this manner.
```swift
CKContainer.default().accountStatus { accountStatus, error in
    if accountStatus == .noAccount {
        DispatchQueue.main.async {
            let message = 
                """
                Sign in to your iCloud account to write records.
                On the Home screen, launch Settings, tap Sign in to your
                iPhone/iPad, and enter your Apple ID. Turn iCloud Drive on.
                """
            let alert = UIAlertController(
                title: "Sign in to iCloud",
                message: message,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true)
        }
    }
    else {
        // Save your record here.
    }
}
```

#### 

## Encrypting User Data
> https://developer.apple.com/documentation/cloudkit/encrypting-user-data

### 
#### 
#### 
#### 
Use the  property to set a field on a `CKRecord` that instructs CloudKit to automatically encrypt data while writing, and decrypt it while reading. This method of encryption and decryption applies to most of the `Record` value types, including , , , , , and . However, there’s no encryption support for  objects because they need to be visible to the server. CloudKit encrypts  by default so you can’t set it as a value for the  property.
Below is an example of the encrypted values property setting and getting :
```swift
// Create a record.
let record = CKRecord(recordType: "MyRecordType")
        
// Define the encrypted field keys.
let dataKey = "dataKey"
let listKey = "listKey"
        
// Encrypt and decrypt arbitrary bytes of data.
record.encryptedValues[dataKey] = NSData()
let _ = record.encryptedValues[dataKey] as? NSData
        
// Encrypt a list of data bytes.
record.encryptedValues[listKey] = [
    NSData(),
    NSData()
]
        
// Retrieve the keys of all encrypted fields.
print(record.encryptedValues.allKeys())
```

#### 
#### 
#### 
- Pass an `isEncrypted` flag along with the payload in a  records request
The web services handle the encryption and decryption for you. The rules regarding CloudKit database schema promotion remain the same for web services as they are for native CloudKit.
The following shows an example request for creating records with the encrypted fields:
```json
{
  "operations" : [ {
    "operationType" : "create",
    "record" : {
      "recordType" : "myRecordType",
      "fields" : {
        "myDoubleField" : {
          "value" : 0.55,
          "type" : "DOUBLE",
          "isEncrypted" : true
        },
        "myIntListField" : {
          "value" : [ 123, 456, 789 ],
          "type" : "INT64_LIST",
          "isEncrypted" : true
        }
      "recordName" : "recordWithEncryptedFields",
    }
  } ],
  "zoneID" : {
    "zoneName" : "myZone"
  }
}
```


## Identifying an App’s Containers
> https://developer.apple.com/documentation/cloudkit/identifying-an-app-s-containers

### 
#### 
After you identify the containers that your app uses, you can create instances of  in your app and interact with CloudKit data.
```swift
// These constants correspond to the containers you configure for your
// target in your project's Signing & Capabilities tab.
let app = CKContainer(identifier: "iCloud.com.example.MyCloudKitApp.app")
let docs = CKContainer(identifier: "iCloud.com.example.MyCloudKitApp.docs")
let settings = CKContainer(identifier: "iCloud.com.example.MyCloudKitApp.settings")
```


## Integrating a Text-Based Schema into Your Workflow
> https://developer.apple.com/documentation/cloudkit/integrating-a-text-based-schema-into-your-workflow

### 
#### 
The grammar for the CloudKit Schema Language contains all the elements to define your schema. Use the grammar to create roles, declare record types and their permissions, as well as specify data types and options for each field in the record.
```other
create-schema:
    DEFINE SCHEMA 
        [ { create-role | record-type } ";" ] ...

create-role:
    CREATE ROLE %role-name% 
    
record-type:
    RECORD TYPE %type-name% ( 
        {
            [ %field-name% data-type [ field-options [..] ] ]
            |
            [ GRANT { READ | CREATE | WRITE } [, ... ] TO %role-name% ]
        } ["," ... ]
    )    

field-options:
    | QUERYABLE
    | SORTABLE
    | SEARCHABLE

data-type:
   primitive-type | list-type

primitive-type:
   | ASSET
   | BYTES
   | DOUBLE
   | [ ENCRYPTED ] { BYTES | STRING | DOUBLE | INT64 | LOCATION | TIMESTAMP }
   | INT64
   | LOCATION 
   | NUMBER [ PREFERRED AS { INT64 | DOUBLE } ]
   | REFERENCE
   | STRING
   | TIMESTAMP
   
list-type:
   | LIST "<" primitive-type ">"

```

`QUERYABLE` - Maintains an index to optimize equality lookups on the field.
`SORTABLE` - Maintains an index optimizing for range searches on the field.
`SEARCHABLE` - Maintains a text search index on the field.
- The first character must be one of `a-z` or `A-Z`.
- Subsequent characters must be one of `a-z`, `A-Z`, `0-9`, or `_` (underscore).
Also, CloudKit reserves identifiers starting with a leading underscore as system-defined identifiers. For example, all record types have an implicitly defined `___recordID` field. Use double quotes when referring to such system fields as well.
The language allows comments in these forms:
```other
// Single-line comment
-- Single-line comment
/* 
Multi-line comment
*/
```

#### 
- `“___createTime” TIMESTAMP`
- `”___createdBy” REFERENCE`
- `”___etag” STRING`
- `”___modTime” TIMESTAMP`
- `”___modifiedBy” REFERENCE`
- `”___recordID” REFERENCE`
These field names are always present within the record time so it’s not necessary to explicitly provide them. If you wish to make any of these fields queryable, sortable, or searchable, then your type must explicitly specify the field and the attribute. You can’t change the type of these system fields.
Though CloudKit won’t remove the system field names, it doesn’t maintain the field options if the field isn’t mentioned in later schema updates. For example, if the following is in your schema:
```other
RECORD TYPE ApplicationType  (
        "___createTime" TIMESTAMP QUERYABLE,
        name STRING,
        ...
)
```

```
Then CloudKit builds an index for efficient searches on the record creation time field. Later, if you modify the schema to no longer mention the creation time field:
```other
RECORD TYPE ApplicationType  (
        name STRING,
        ...
)
```

For types that you wish to use in a `PUBLIC` database, include the following grants:
Additionally, all record types have these implicitly defined roles:
For types that you wish to use in a `PUBLIC` database, include the following grants:
```other
GRANT WRITE TO "_creator"
GRANT CREATE TO "_icloud"
GRANT READ TO "_world"
```

#### 
This sample schema defines a simple company department and employee information. It demonstrates extending the attributes of system fields and the double quotes necessary for referring to system identifiers.
```other
DEFINE SCHEMA
    CREATE ROLE DeptManager;

    RECORD TYPE Department (
        "___createTime" TIMESTAMP QUERYABLE SORTABLE,
        "___recordID" REFERENCE QUERYABLE,
        name STRING,
        address STRING,
        phone LIST<STRING>,
        employees LIST<REFERENCE>,
        GRANT WRITE TO "_creator", 
        GRANT CREATE TO "_icloud",
        GRANT READ TO "_world",
        GRANT WRITE, CREATE, READ TO DeptManager
    );

    RECORD TYPE Employee (
        "___createTime" TIMESTAMP QUERYABLE SORTABLE,
        "___recordID" REFERENCE QUERYABLE,
        name STRING,
        address STRING,
        hiredate TIMESTAMP,
        salary INT64,
        GRANT WRITE TO "_creator", 
        GRANT CREATE TO "_icloud",
        GRANT READ TO "_world"
    );
```


## Local Records
> https://developer.apple.com/documentation/cloudkit/local-records

### 
It’s important to consider the cost of a record when fetching it, especially when the record contains one or more assets. Both  and  provide a `desiredKeys` property, which allows you to specify the fields the operation retrieves from iCloud. If you don’t immediately need any associated assets, use `desiredKeys` to exclude the corresponding fields. You can then download individual assets as you need them.
The following example shows how to construct a query operation. It searches a specific record zone for properties in Cupertino, and uses a sort descriptor to request that iCloud returns the results in chronological order. The operation excludes a field that contains an asset using . For brevity, the example omits configuring the operation’s callbacks and executing it.
```swift
// Create a predicate that performs a case-insensitive search 
// of the record's address field for the value 'Cupertino'.
let predicate = NSPredicate(format: "address CONTAINS[c] 'Cupertino'")

// Use the predicate to create a query. Limit the query to 
// only retrieve records of the 'Property' record type.
let query = CKQuery(recordType: "Property", predicate: predicate)

// Set the query's sort descriptors so that iCloud returns 
// the records in chronological order.
query.sortDescriptors = [
    NSSortDescriptor(key: "creationDate", ascending: true)
]

// Use the query to create a query operation. Scope the 
// operation to the record zone that contains property
// records.
let operation = CKQueryOperation(query: query)
operation.zoneID = propertiesRecordZone.zoneID

// Each property has an address, a brochure, an owner, and
// a sale price. Don't include the 'brochure' field in the 
// query results. It contains a PDF asset, which can be 
// several megabytes in size.
operation.desiredKeys = [
    "address",
    "ownerName",
    "salePrice"
]
```


## Providing User Access to CloudKit Data
> https://developer.apple.com/documentation/cloudkit/providing-user-access-to-cloudkit-data

### 
#### 
#### 
Associate the record types with the container they appear in. The example below uses a dictionary to represent the relationship between containers and the record types they contain:
```swift
let defaultContainer = CKContainer.default()
let documents = CKContainer(identifier: "iCloud.com.example.myexampleapp.documents")
let settings = CKContainer(identifier: "iCloud.com.example.myexampleapp.settings")

let containerRecordTypes: [CKContainer: [String]] = [
    defaultContainer: ["log", "verboseLog"],
    documents: ["textDocument", "spreadsheet"],
    settings: ["preference", "profile"]
]

let containers = Array(containerRecordTypes.keys)
```

#### 
Store user data in a container’s private database. Use the containers in the example above to find all record zones in the private database for each container that your app uses.
The example below shows how to iterate over the containers, record zones, and records. It also shows how to list the fields for each record, which you use to show the data in those records:
```swift
// Utility function to display records.
// Customize it to display records appropriately
// according to your app's unique record types.
func printRecords(_ records: [CKRecord]) {
    for record in records {
        for key in record.allKeys() {
            let value = record[key]
            print(key + " = " + (value?.description ?? "") + ")")
        }
    }
}

for container in containers {
    // User data should be stored in the private database.
    let database = container.privateCloudDatabase
    
    database.fetchAllRecordZones { zones, error in
        guard let zones = zones, error == nil else {
            print(error!)
            return
        }
        
        // The true predicate represents a query for all records.
        let alwaysTrue = NSPredicate(value: true)
        for zone in zones {
            for recordType in containerRecordTypes[container] ?? [] {
                let query = CKQuery(recordType: recordType, predicate: alwaysTrue)
                database.perform(query, inZoneWith: zone.zoneID) { records, error in
                    guard let records = records, error == nil else {
                        print("An error occurred fetching these records.")
                        return
                    }
                    
                    printRecords(records)
                }
            }
        }
    }
}
```


## Remote Records
> https://developer.apple.com/documentation/cloudkit/remote-records

### 
#### 
When you fetch a record from iCloud, update the local model object using the record’s fields. Then encode the record’s metadata, attach it to the model, and save the model to the cache. To update a record in iCloud, decode the model’s metadata and use it to create an instance of . Set the record’s fields to the model’s values and save it to iCloud.
The following example shows how to encode a record’s metadata and store it on a custom `Product` model. It also shows how to decode the metadata and use it to create an instance of .
```swift
func storeCloudRecord(_ record: CKRecord, on product: Product) {
    
    // Encode the record's metadata.
    let coder = NSKeyedArchiver(requiringSecureCoding: true)
    record.encodeSystemFields(with: coder)
    
    // Attach the encoded metadata to the 
    // model object so you can store it in
    // your local cache.
    product.recordMetadata = coder.encodedData
}
    
func extractCloudRecord(from product: Product) throws -> CKRecord? {
    guard let metadata = product.recordMetadata else { return nil }
    
    // Create an unarchiver from the record's stored metadata
    // and use it to create an instance of CKRecord.
    let coder = try NSKeyedUnarchiver(forReadingFrom: metadata)
    let record = CKRecord(coder: coder)
    coder.finishDecoding()

    // Return the record to the caller, which can update its 
    // fields using the product's properties before saving
    // it to iCloud.
    return record
}
```


## Responding to Requests to Delete Data
> https://developer.apple.com/documentation/cloudkit/responding-to-requests-to-delete-data

### 
#### 
To be sure that you delete all of a user’s data that your app stores in CloudKit, cross-reference the list of containers your app has access to in Xcode and assemble a list of those containers’ identifiers.  describes this process.
The example below stores containers in an array to use later for enumeration:
```swift
let containers: [CKContainer] = [
    CKContainer.default(),
    .init(identifier: "iCloud.com.example.myexampleapp.documents"),
    .init(identifier: "iCloud.com.example.myexampleapp.settings")
]
```

#### 
The example below uses an instance of  to delete all records in each container’s private database:
```swift
for container in containers {
    container.privateCloudDatabase.fetchAllRecordZones { zones, error in
        guard let zones = zones, error == nil else {
            print("Error fetching zones.")
            return
        }
        
        let zoneIDs = zones.map { $0.zoneID }
        let deletionOperation = CKModifyRecordZonesOperation(recordZonesToSave: nil, recordZoneIDsToDelete: zoneIDs)
        
        deletionOperation.modifyRecordZonesCompletionBlock = { _, deletedZones, error in
            guard error == nil else {
                let error = error!
                
                print("Error deleting records.", error)
                return
            }

            print("Records successfully deleted in this zone.")
        }
        
        container.privateCloudDatabase.add(deletionOperation)
    }
}
```


## Sharing CloudKit Data with Other iCloud Users
> https://developer.apple.com/documentation/cloudkit/sharing-cloudkit-data-with-other-icloud-users

### 
#### 
1. In the General pane of the `CloudKitShare` target, update the Bundle Identifier field with a new identifier.
#### 
CloudKit apps need to create a schema to define the record types and fields, and  is the tool for doing that. For more information, see .
The sample uses the following record types and fields:
```None
Topic
    name (String)
Note
    title (String)
    topic (Reference, pointing to the parent topic)
```

#### 
- On device B, navigate to the shared database’s topic view, then tap the Edit button and add a note under the shared topic. The new note synchronizes within seconds to the private database on device A. (This assumes the topic’s “Anyone with this link can make changes” option is in an enabled state. If the topic’s “Anyone with this link can view” option is in an enabled state, participants have read-only permissions, and can’t add a note under the topic.)
- On device A, add a note under the shared topic. The note synchronizes within seconds to device B. When creating a note, the sample sets its `parent` property to the topic, so the system automatically shares the note with its parent topic.
```swift
newNoteRecord.parent = CKRecord.Reference(record: topicRecord, action: .none)
```

#### 
The sample uses  to implement the sharing flow. Depending on whether the root record is in a shared state, there are different ways to create a sharing controller.
```swift
if rootRecord.share != nil {
    newSharingController(sharedRootRecord: rootRecord, database: database,
                         completionHandler: completionHandler)
} else {
    newSharingController(unsharedRootRecord: rootRecord, database: database, zone: zone,
                         completionHandler: completionHandler)
}
```

```
If the root record is in a shared state, the sample grabs the `recordID` from the  property of the root record, uses it to fetch the share, which is the associated  object, from the server, and calls  to create a sharing controller.
```swift
let sharingController = UICloudSharingController(share: share, container: self)
```

```
If the root record isn’t in a shared state, the sample uses  to create the sharing controller.
```swift
let sharingController = UICloudSharingController { (_, prepareCompletionHandler) in
```

In the preparation handler, the sample sets up a new `CKShare` object using the root record.
```
In the preparation handler, the sample sets up a new `CKShare` object using the root record.
```swift
let shareID = CKRecord.ID(recordName: UUID().uuidString, zoneID: zone.zoneID)
var share = CKShare(rootRecord: unsharedRootRecord, shareID: shareID)
share[CKShare.SystemFieldKey.title] = "A cool topic to share!" as CKRecordValue
share.publicPermission = .readWrite
```

```
The sample then saves the share and its root record together using .
```swift
let modifyRecordsOp = CKModifyRecordsOperation(recordsToSave: [share, unsharedRootRecord], recordIDsToDelete: nil)
```

```
After creating the sharing controller, the sample uses the following code to present it:
```swift
sharingController.popoverPresentationController?.sourceView = sender as? UIView
self.rootRecord = topicRecord
sharingController.delegate = self
sharingController.availablePermissions = [.allowPublic, .allowReadOnly, .allowReadWrite]
self.present(sharingController, animated: true) { self.spinner.stopAnimating() }
```

#### 
To avoid fetching data from the server each time the zone view and topic view are about to appear, the sample caches the zones in the container, and the topics and notes in the current zone. The caches are both in-memory because the sample doesn’t tend to add more complexity by introducing a persistence layer. Real-world apps can persist their cache to avoid doing an initial fetch on each launch.
The sample establishes the local caches with two steps: initial fetch and incremental update. In , the sample checks the account status, and then starts the initial fetch if there isn’t a cache for the current account.
```swift
let building = appDelegate.buildZoneCacheIfNeed(for: newUserRecordID)
```

```
CloudKit notifications trigger the incremental updates. The sample uses  to subscribe to CloudKit database changes.
```swift
let subscription = CKDatabaseSubscription(subscriptionID: subscriptionID)
let notificationInfo = CKSubscription.NotificationInfo()
notificationInfo.shouldBadge = true
notificationInfo.alertBody = "Database (\(subscriptionID)) was changed!"
subscription.notificationInfo = notificationInfo

let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
operation.modifySubscriptionsCompletionBlock = { _, _, error in
    completionHandler(error as NSError?)
}

add(operation, to: operationQueue)
```

```
With the subscriptions, the sample gets push notifications when the database changes, and starts the incremental update from the following  method:
```swift
func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("\(#function)")
    updateWithNotificationUserInfo(notification.request.content.userInfo)
    completionHandler([])
}
```

```
The sample uses  to fetch the deleted or changed zones. When doing the fetch, CloudKit provides a `serverChangeToken` () by calling the operation’s . Apps keep the token and use it as `previousServerChangeToken` for the next fetch.
```swift
operation.changeTokenUpdatedBlock = { serverChangeToken in
    self.setServerChangeToken(newToken: serverChangeToken, cloudKitDB: cloudKitDB)
}
```

```
When apps use the token to create and run a CloudKit operation, the token tells the server which portions of the zones to return. If the token is `nil`, the server returns all zones.
```swift
let serverChangeToken = getServerChangeToken(for: cloudKitDB)
let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: serverChangeToken)
```

After gathering the deleted and changed zones, the sample updates the zone cache and makes it consistent with the server truth.
Similarly, the sample uses  to gather the deleted and changed topic and notes, and uses them to maintain the topic cache.
```swift
let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
configuration.previousServerChangeToken = getServerChangeToken()

let operation = CKFetchRecordZoneChangesOperation(
    recordZoneIDs: [zone.zoneID], configurationsByRecordZoneID: [zone.zoneID: configuration]
)
```


