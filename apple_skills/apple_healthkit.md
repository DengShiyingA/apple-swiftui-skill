# Apple HEALTHKIT Skill


## Accessing Health Records
> https://developer.apple.com/documentation/healthkit/accessing-health-records

### 
#### 
You request authorization to read clinical records using the  enumeration. This enumeration specifies the types of FHIR data supported by HealthKit. You must request permission to read all the types that your app intends to use. Additionally, clinical records are read-only, so you can’t request authorization to share clinical record types. You can’t create or save new  objects.
```swift
guard let allergiesType = HKObjectType.clinicalType(forIdentifier: .allergyRecord),
let medicationsType = HKObjectType.clinicalType(forIdentifier: .medicationRecord) else {
    fatalError("*** Unable to create the requested types ***")
}

// Clinical types are read-only.
store.requestAuthorization(toShare: nil, read: [allergiesType, medicationsType]) { (success, error) in
    
    guard success else {
        // Handle errors here.
        fatalError("*** An error occurred while requesting authorization: \(error!.localizedDescription) ***")
    }

    // You can start accessing clinical record data.
}
```

#### 
You can use HealthKit’s regular queries to look up clinical records.
```swift
// Get all the allergy records.
guard let allergyType = HKObjectType.clinicalType(forIdentifier: .allergyRecord) else {
    fatalError("*** Unable to create the allergy type ***")
}

let allergyQuery = HKSampleQuery(sampleType: allergyType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
    
    guard let actualSamples = samples else {
        // Handle the error here.
        print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
        return
    }
    
    let allergySamples = actualSamples as? [HKClinicalRecord]
    // Do something with the allergy samples here...
}

store.execute(allergyQuery)
```

#### 
Once you have an  sample, you can access the FHIR data through its  property. The  object represents the underlying data from the user’s health care institution. While the resource object provides properties to access a few, useful attributes (, , and ), use the  property to access the underlying JSON, which contains the complete clinical data.
```swift
guard let fhirRecord = clinicalRecord.fhirResource else {
    print("No FHIR record found!")
    return
}

do {
    let jsonDictionary = try JSONSerialization.jsonObject(with: fhirRecord.data, options: [])
    
    // Do something with the JSON data here.
}
catch let error {
    print("*** An error occurred while parsing the FHIR data: \(error.localizedDescription) ***")
    // Handle JSON parse errors here.
}
```

Similarly, a  identifier matches , , , and  types. Therefore—unless you use the  predicate—when you query for medication, you can get a mixture of statement, order, request, and dispense records.
The following sample shows JSON data for an FHIR Condition resource:
```other
{
    "asserter": {
        "display": "Juan Chavez",
        "reference": "Practitioner/20"
    },
    "category": {
        "coding": [
            {
                "code": "diagnosis",
                "system": "http://hl7.org/fhir/condition-category"
            }
        ]
    },
    "clinicalStatus": "active",
    "code": {
        "coding": [
            {
                "code": "367498001",
                "display": "Seasonal allergic rhinitis",
                "system": "http://snomed.info/sct"
            }
        ],
        "text": "Seasonal Allergic Rhinitis"
    },
    "dateRecorded": "2012-01-02",
    "id": "2",
    "notes": "Worse when visiting family in NC during the spring",
    "onsetDateTime": "1994-05-12",
    "resourceType": "Condition",
    "verificationStatus": "confirmed"
}
```


## Accessing a User’s Clinical Records
> https://developer.apple.com/documentation/healthkit/accessing-a-user-s-clinical-records

### 
#### 
#### 
The app defines the clinical record sample types using the  enumeration. The app must request permission to read all the types that it intends to use. Note that the app may define both clinical records and standard HealthKit sample types at the same time.
```swift
/// An enumeration that defines two categories of data types: Health Records and Fitness Data.
/// Health Records enumerates the clinical records the app would like to access and Fitness Data contains the
/// fitness data types.
enum Section {
    case healthRecords
    case fitnessData
    
    var displayName: String {
        switch self {
        case .healthRecords:
            return "Health Records"
        case .fitnessData:
            return "Fitness Data"
        }
    }
    
    var types: [HKSampleType] {
        switch self {
        case .healthRecords:
            return [
                HKObjectType.clinicalType(forIdentifier: .allergyRecord)!,
                HKObjectType.clinicalType(forIdentifier: .vitalSignRecord)!,
                HKObjectType.clinicalType(forIdentifier: .conditionRecord)!,
                HKObjectType.clinicalType(forIdentifier: .immunizationRecord)!,
                HKObjectType.clinicalType(forIdentifier: .labResultRecord)!,
                HKObjectType.clinicalType(forIdentifier: .medicationRecord)!,
                HKObjectType.clinicalType(forIdentifier: .procedureRecord)!
            ]
        
        case .fitnessData:
            return [
                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
            ]
        }
    }
}
```

#### 
The app may request authorization to access both clinical data and HealthKit data simultaneously.
```swift
/// Create an instance of the health store. Use the health store to request authorization to access
/// HealthKit records and to query for the records.
let healthStore = HKHealthStore()

var sampleTypes: Set<HKSampleType> {
    return Set(Section.healthRecords.types + Section.fitnessData.types)
}

/// Before accessing clinical records and other health data from HealthKit, the app must ask the user for
/// authorization. The health store's getRequestStatusForAuthorization method allows the app to check
/// if user has already granted authorization. If the user hasn't granted authorization, the app
/// requests authorization from the person using the app.
@objc
func requestAuthorizationIfNeeded(_ sender: AnyObject? = nil) {
    healthStore.getRequestStatusForAuthorization(toShare: Set(), read: sampleTypes) { (status, error) in
        if status == .shouldRequest {
            self.requestAuthorization(sender)
        } else {
            DispatchQueue.main.async {
                let message = "Authorization status has been determined, no need to request authorization at this time"
                self.present(message: message, titled: "Already Requested")
            }
        }
    }
}

/// The health store's requestAuthorization method presents a permissions sheet to the user, allowing the user to
/// choose what data they allow the app to access.
@objc
func requestAuthorization(_ sender: AnyObject? = nil) {
    healthStore.requestAuthorization(toShare: nil, read: sampleTypes) { (success, error) in
        guard success else {
            DispatchQueue.main.async {
                self.handleError(error)
            }
            return
        }
    }
}
```

#### 
To query for clinical records, the app uses an  as shown below.
```swift
/// Use HKSampleQuery to query the HealthKit store for samples by type.
func queryForSamples() {
    let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
    let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 100, sortDescriptors: sortDescriptors) {(_, samplesOrNil, error) in
        DispatchQueue.main.async {
            guard let samples = samplesOrNil else {
                self.handleError(error)
                return
            }
            
            self.samples = samples
            self.tableView.reloadData()
        }
    }
    
    healthStore.execute(query)
}
```

#### 
It uses a `JSONDecoder` to convert the resource’s JSON data:
The app uses the  library to parse the JSON data into Swift classes. For more details on FHIRModels, see .
It uses a `JSONDecoder` to convert the resource’s JSON data:
```swift
/// Each clincal record retrieved from HealthKit is associated with a FHIR Resource. Decode it using the FHIRModels.
func decode(resource: HKFHIRResource) throws -> DisplayItemSubtitleConvertible {
    if #available(iOS 14.0, *) {
        switch resource.fhirVersion.fhirRelease {
        case .dstu2:
            return try decodeDSTU2(resource: resource)
        case .r4:
            return try decodeR4(resource: resource)
        default:
            throw FHIRResourceDecodingError.versionNotSupported(resource.fhirVersion.stringRepresentation)
        }
    } else {
        return try decodeDSTU2(resource: resource) // On iOS 12 and 13, HealthKit always uses DSTU2 encoding for FHIR resources.
    }
}
```

This provides direct access to the `status` element, so that the app can display it. It appears as the subtitle of the Medication list view.
```
This provides direct access to the `status` element, so that the app can display it. It appears as the subtitle of the Medication list view.
```swift
extension ModelsDSTU2.MedicationStatement: DisplayItemSubtitleConvertible {
    var displayItemSubtitle: String {
        return self.status.value?.rawValue ?? "unknown"
    }
}
```


## Accessing condensed workout samples
> https://developer.apple.com/documentation/healthkit/accessing-condensed-workout-samples

### 
#### 
Because HealthKit condenses and coalesces older workout data, any samples associated with a workout may actually represent a series of higher-frequency data. In many cases, you don’t need to operate on the `HKSamples` or the backing quantity series data. Instead, you should use  and  to transparently compute statistics for the underlying data.
However, if your app needs to access the underlying data directly, start by querying for all the samples associated with a workout:
```swift
// Create the workout predicate.
let forWorkout = HKQuery.predicateForObjects(from: workout)

// Create the heart-rate descriptor.
let heartRateDescriptor = HKQueryDescriptor(sampleType: myHeartRateType,
                                            predicate: forWorkout)

// Create the query.
let heartRateQuery = HKSampleQuery(queryDescriptors: [heartRateDescriptor],
                                   limit: HKObjectQueryNoLimit)
{ query, samples, error in
    // Process the samples.
}

// Run  the query.
myStore.execute(heartRateQuery)
```

```
Then, in the query’s results handler, if a sample has a  greater than 1, it contains series data.
```swift
// Create the query.
let heartRateQuery = HKSampleQuery(queryDescriptors: [heartRateDescriptor],
                                   limit: HKObjectQueryNoLimit)
{ query, samples, error in

    // Start by checking for errors.
    guard let samples = samples else {
        // Handle the error.
        fatalError("*** An error occurred: \(error!.localizedDescription) ***")
    }
    
    // Iterate over all the samples.
    for sample in samples {
        
        guard let sample = sample as? HKDiscreteQuantitySample else {
            fatalError("*** Unexpected Sample Type ***")
        }
        
        // Check to see if the sample is a series.
        if sample.count == 1 {
            // This is a single sample.
            // Use the sample.
            myOutput.append("\(sample)\n")
        }
        else {
            // This is a series.
            // Get the detailed items for the series.
            myGetDetailedItems(for: sample)
        }
    }
}

```

```
Use an  to access the detailed data from the series.
```swift
// Create the predicate.
let inSeriesSample = HKQuery.predicateForObject(with: series.uuid)

// Create the query.
let detailQuery = HKQuantitySeriesSampleQuery(quantityType: myHeartRateType,
                                              predicate: inSeriesSample)
{ query, quantity, dateInterval, HKSample, done, error in
    
    guard let quantity = quantity, let dateInterval = dateInterval else {
        fatalError("*** An error occurred: \(error!.localizedDescription) ***")
    }
    
    // Use the data.
    myOutput.append("\(quantity.doubleValue(for: HKUnit(from: "count/min"))): \(dateInterval)")
}

// Run the query.
myStore.execute(detailQuery)
```


## Adding Digital Signatures
> https://developer.apple.com/documentation/healthkit/adding-digital-signatures

### 
The format used for the digital signature is the Cryptographic Message Syntax (CMS) specified in IETF RFC 5652. The signature is encoded using ASN.1 with Distinguished Encoding Rules (DER). The message digest used should be SHA256, and the signature cipher should be FIPS PUB 186-4 Digital Signature Standard Elliptic Curve P-256.  This will ensure both strength and efficiency.  In addition, the entire signature should be base64 encoded so that it can be stored in the HealthKit  metadata object.
The signature should be of the ASN.1 Signed-data Content Type:
```objc
SignedData ::= SEQUENCE {
  version CMSVersion,
  digestAlgorithms DigestAlgorithmIdentifiers,
  encapContentInfo EncasulatedContentInfo,
  signerInfos SignerInfo }
```

where `SignerInfo` type is:
```
where `SignerInfo` type is:
```objc
SignerInfo ::= SEQUENCE {
  version CMSVersion,
  sid SignerIdentifier,
  digestAlgorithm DigestAlgorithmIdentifier,
  signatureAlgorithem SignatureAlgorithmIdentifier,
  signatureSignatureValue }
```


## Adding samples to a workout
> https://developer.apple.com/documentation/healthkit/adding-samples-to-a-workout

### 
#### 
#### 
Start by creating quantity objects for the total energy burned, and total distance traveled.
```swift
let energyBurned = HKQuantity(unit: HKUnit.largeCalorie(), doubleValue: 425.0)
let distance = HKQuantity(unit: HKUnit.mile(), doubleValue: 3.2)
```

```
Next create the workout sample.
```swift
let run = HKWorkout(activityType: HKWorkoutActivityType.running,
                    start: start,
                    end: end,
                    duration: 0,
                    totalEnergyBurned: energyBurned,
                    totalDistance: distance,
                    metadata: nil)
```

```
And save the sample to the HealthKit store.
```swift
store.save(run) { (success, error) -> Void in
    guard success else {
        // Perform proper error handling here.
        return
    }
    
    // Add detail samples here.
}
```

#### 
In the completion handler, you check to ensure that the save succeeded, and then add detailed samples to the workout. For example, you could split the workout into intervals and then calculate detailed information for each interval. The following code listing creates a sample for the distance covered in the first interval.
```swift
guard let distanceType =
    HKObjectType.quantityType(forIdentifier:
        HKQuantityTypeIdentifier.distanceWalkingRunning) else {
    fatalError("*** Unable to create a distance type ***")
}

let distancePerInterval = HKQuantity(unit: HKUnit.foot(),
                                     doubleValue: 165.0)

let distancePerIntervalSample = HKQuantitySample(type: distanceType,
                                                 quantity: distancePerInterval,
                                                 start: myIntervals[0],
                                                 end: myIntervals[1])

myDetailSamples.append(distancePerIntervalSample)
```

```
Then you create an energy-burned sample for that interval.
```swift
guard let energyBurnedType =
    HKObjectType.quantityType(forIdentifier:
        HKQuantityTypeIdentifier.activeEnergyBurned) else {
    fatalError("*** Unable to create an energy burned type ***")
}

let energyBurnedPerInterval = HKQuantity(unit: HKUnit.largeCalorie(),
                                         doubleValue: 15.5)

let energyBurnedPerIntervalSample =
    HKQuantitySample(type: energyBurnedType,
                     quantity: energyBurnedPerInterval,
                     start: myIntervals[0],
                     end: myIntervals[1])

myDetailSamples.append(energyBurnedPerIntervalSample)
```

```
However, you’re not limited to just energy burned and distance. The following code creates a heart rate sample.
```swift
guard let heartRateType =
    HKObjectType.quantityType(forIdentifier:
        HKQuantityTypeIdentifier.heartRate) else {
    fatalError("*** Unable to create a heart rate type ***")
}

let heartRateForInterval = HKQuantity(unit: HKUnit(from: "count/min"),
                                      doubleValue: 95.0)

let heartRateForIntervalSample =
    HKQuantitySample(type: heartRateType,
                     quantity: heartRateForInterval,
                     start: myIntervals[0],
                     end: myIntervals[1])

myDetailSamples.append(heartRateForIntervalSample)
```

```
Continue to create all the samples you need for all of your intervals. Then use the HealthKit store to add these samples to the workout.
```swift
store.add(myDetailSamples, to: run) { (success, error) -> Void in
    guard success else {
        // Perform proper error handling here.
        return
    }
}
```

#### 
To read a workout’s fine-grain details, you need to create a query that returns only the samples associated with the workout. Use the  method to create a predicate object that matches only samples associated with the  workout. You can then use that predicate to filter one or more queries. For example, the following sample code returns all the distance samples associated with the workout.
```swift
guard let distanceType =
    HKObjectType.quantityType(forIdentifier:
        HKQuantityTypeIdentifier.distanceWalkingRunning) else {
            fatalError("*** Unable to create a distance type ***")
}

let workoutPredicate = HKQuery.predicateForObjects(from: workout)

let startDateSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

let query = HKSampleQuery(sampleType: distanceType,
                          predicate: workoutPredicate,
                          limit: 0,
                          sortDescriptors: [startDateSort]) { (sampleQuery, results, error) -> Void in
                            guard let distanceSamples = results as? [HKQuantitySample] else {
                                // Perform proper error handling here.
                                return
                            }
                            
                            // Use the workout's distance samples here.
}

store.execute(query)
```


## Authorizing access to health data
> https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data

### 
#### 
#### 
To request permission to read or write data, start by creating the HealthKit data types that you want to read or write. The following example creates data types for active energy burned, distance cycling, distance walking or running, distance in a wheelchair, and heart rate.
```swift
// Create the HealthKit data types your app
// needs to read and write.
let allTypes: Set = [
    HKQuantityType.workoutType(),
    HKQuantityType(.activeEnergyBurned),
    HKQuantityType(.distanceCycling),
    HKQuantityType(.distanceWalkingRunning),
    HKQuantityType(.distanceWheelchair),
    HKQuantityType(.heartRate)
]
```

```
Next, you can request read or write access to that data. To request access from the HealthKit store, call .
```swift
do {
    // Check that Health data is available on the device.
    if HKHealthStore.isHealthDataAvailable() {
        
        // Asynchronously request authorization to the data.
        try await healthStore.requestAuthorization(toShare: allTypes, read: allTypes)
    }
} catch {
    
    // Typically, authorization requests only fail if you haven't set the
    // usage and share descriptions in your app's Info.plist, or if
    // Health data isn't available on the current device.
    fatalError("*** An unexpected error occurred while requesting authorization: \(error.localizedDescription) ***")
}
```

To request access from SwiftUI, use the  `modifier.`
> **important:**  The ` `modifier is only available if you import both SwiftUI and HealthKitUI.
> **important:**  The ` `modifier is only available if you import both SwiftUI and HealthKitUI.
```swift
import SwiftUI
import HealthKitUI

struct MyView: View {
    @State var accessRequested = false
    @State var trigger = false

    var body: some View {
        Button("Access health data") {
            // OK to read or write HealthKit data here.
        }
        .disabled(!accessRequested)
        
        // If HealthKit data is available, request authorization
        // when this view appears.
        .onAppear() {
            
            // Check that Health data is available on the device.
            if HKHealthStore.isHealthDataAvailable() {
                // Modifying the trigger initiates the health data
                // access request.
                trigger.toggle()
            }
        }
        
        // Requests access to share and read HealthKit data types
        // when the trigger changes.
        .healthDataAccessRequest(store: healthStore,
                                 shareTypes: allTypes,
                                 readTypes: allTypes,
                                 trigger: trigger) { result in
            switch result {
                
            case .success(_):
                accessRequested = true
            case .failure(let error):
                // Handle the error here.
                fatalError("*** An error occurred while requesting authentication: \(error) ***")
            }
        }
    }
}
```

#### 
#### 
#### 

## Creating a workout route
> https://developer.apple.com/documentation/healthkit/creating-a-workout-route

### 
#### 
#### 
When the user starts a new workout, begin tracking the user’s location using a  object from the Core Location framework. After you call the location manager’s  method, the location manager’s delegate begins receiving updates containing the user’s current location.
```swift
// Start tracking the user.
locationManager.desiredAccuracy = kCLLocationAccuracyBest
locationManager.startUpdatingLocation()
```

```
Next, use  to create and store a route builder for the workout. During the workout, you incrementally add locations from the Core Location updates to the route builder, which then creates the route from the accumulated data.
```swift
// Create the route builder using a HKWorkoutBuilder
guard let routeBuilder = workoutBuilder.seriesBuilder(for: HKSeriesType.workoutRoute()) as? HKWorkoutRouteBuilder else {
    fatalError("*** Unexpected HKSeriesBuilder Type ***")
}
```

#### 
As your app receives location updates from Core Location, filter and smooth the locations, and then call  to add the locations to the route builder.
```swift
// MARK: - CLLocationManagerDelegate Methods.
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    // Filter the raw data.
    let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
        location.horizontalAccuracy <= 50.0
    }
    
    guard !filteredLocations.isEmpty else { return }
    
    // Add the filtered data to the route.
    routeBuilder.insertRouteData(filteredLocations) { (success, error) in
        if !success {
            // Handle any errors here.
        }
    }
}
```

#### 
#### 
After saving the workout, add any remaining locations to the route builder and call .
```swift
// Create, save, and associate the route with the provided workout.
routeBuilder.finishRoute(with: myWorkout, metadata: myMetadata) { (newRoute, error) in
    
    guard newRoute != nil else {
        // Handle any errors here.
        return
    }
    
    // Optional: Do something with the route here.
}
```


## Data types
> https://developer.apple.com/documentation/healthkit/data-types

### 
HealthKit uses  subclasses to identify the different types of data stored in HealthKit, from inherent data that doesn’t typically change over time to complex data types that combine multiple samples or compute values over sets of samples.
To create a type object, call the appropriate  class method, and pass in the desired type identifier.
```swift
let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType)

let caloriesConsumed = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)

let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
```


## Dividing a HealthKit workout into activities
> https://developer.apple.com/documentation/healthkit/dividing-a-healthkit-workout-into-activities

### 
#### 
#### 
To add workout activities to a workout session, start by creating the session and start collecting data using the workout builder.
```swift
// Create the workout configuration for a multisport workout.
let configuration = HKWorkoutConfiguration()
configuration.activityType = .swimBikeRun
configuration.locationType = .outdoor

// Create the workout session.
session = try HKWorkoutSession(healthStore: store,
                               configuration: configuration)

// Start the session and the workout builder.
let startDate = Date()
session.startActivity(with: startDate)
workoutBuilder = session.associatedWorkoutBuilder()

// Set the workout builder's data source.
workoutBuilder.dataSource =
HKLiveWorkoutDataSource(healthStore: store,
                        workoutConfiguration: configuration)

// Start collecting data.
try await workoutBuilder.beginCollection(at: startDate)
```

```
Next, when an activity begins, create a new configuration for the activity, and start the activity using the session’s  method. The data source automatically begins collecting the default data types for the activity.
```swift
// Start the swimming activity.
let swimmingConfiguration = HKWorkoutConfiguration()
swimmingConfiguration.activityType = .swimming
swimmingConfiguration.locationType = .outdoor
swimmingConfiguration.swimmingLocationType = .openWater

session.beginNewActivity(configuration: swimmingConfiguration,
                         date: Date(),
                         metadata: nil)
```

```
When the activity ends, call the session’s  method. HealthKit also ends the current activity when you begin a new activity.
```swift
// End the activity.
session.endCurrentActivity(on: Date())
```

```
To explicitly track the intervals between activities, start a new activity using . End this transition when the next activity begins.
```swift
// Explicitly track the transition between activities.
let transitionConfiguration = HKWorkoutConfiguration()
transitionConfiguration.activityType = .transition
transitionConfiguration.locationType = .outdoor

session.beginNewActivity(configuration: transitionConfiguration,
                         date: Date(),
                         metadata: nil)
```

```
Finally, when the entire workout session ends, call the session’s  method. This also ends the current activity. Then call the workout builder’s  method to save the workout to the HealthKit store. This method also returns an  object, which you can use to display summary information about the workout.
```swift
// Ending the session also ends the current activity.
session.end()

// Finishing the workout saves the workout
// and returns an HKWorkout object that you can use to display summary data.
let workout = try await workoutBuilder.finishWorkout()

// Do something with the workout here.
print(workout as Any)
```

#### 
Most of the time, you can use the default collected data types. However, if your app calculates and saves its own  objects during the workout, you may want to manually enable and disable the collection of that data type, letting the data source automatically associate your samples with the workout.
To start collecting a data type, call the data source’s  method.
```swift
// Enable the collection of respiratory rate.
guard let dataSource = session.associatedWorkoutBuilder().dataSource else {
    print("*** No data source found! ***")
    return }

let respiratoryRate = HKQuantityType(.respiratoryRate)
dataSource.enableCollection(for: respiratoryRate, predicate: nil)
```

```
HealthKit then associates any matching samples from your app with the workout activity. You can also disable the collection of a data type by calling .
```swift
// Disable the collection of respiratory rate.
guard let dataSource = session.associatedWorkoutBuilder().dataSource else {
    print("*** No data source found! ***")
    return }

let respiratoryRate = HKQuantityType(.respiratoryRate)
dataSource.disableCollection(for: respiratoryRate)
```

#### 
To query for workouts with activities that match a specific predicate, start by creating a workout activity predicate using one of the  class’s `predicateForWorkoutActivities` methods. Next, use  to wrap the activity predicate inside a workout predicate. You can then use the workout predicate in your query.
```swift
// Create a predicate for an average heart rate of greater than 150 bpm.
let highHeartRate = HKQuantity(unit: .count(), doubleValue: 150.0)
let heartRateType = HKQuantityType(.heartRate)

let heartRatePredicate =
HKQuery.predicateForWorkoutActivities(operatorType: .greaterThan,
                                      quantityType: heartRateType,
                                      averageQuantity: highHeartRate)

// Wrap the workout activity predicate inside a workout predicate.
let workoutPredicate = HKQuery.predicateForWorkouts(activityPredicate: heartRatePredicate)

let query = HKSampleQueryDescriptor(predicates: [.workout(workoutPredicate)],
                                    sortDescriptors: [])

let matchingWorkouts = try await query.result(for: store)

// Do something with the samples here.
print(matchingWorkouts)
```


## Executing Statistical Queries
> https://developer.apple.com/documentation/healthkit/executing-statistical-queries

### 
#### 
Start by creating the type object for the desired samples. The following example creates a type object for energy consumed.
```swift
guard let energyConsumed = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed) else {
    // This should never fail when using a defined constant.
    fatalError("*** Unable to get the dietary energy consumed type ***")
}
```

```
Next, create a predicate for samples created between midnight last night and midnight tonight.
```swift
let calendar = NSCalendar.current
let now = Date()
let components = calendar.dateComponents([.year, .month, .day], from: now)

guard let startDate = calendar.date(from: components) else {
    fatalError("*** Unable to create the start date ***")
}
 
guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
    fatalError("*** Unable to create the end date ***")
}

let today = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
```

#### 
To create the statistical query, call the  initializer. The following code creates a statistical query that calculates the total energy consumed during the specified time period.
```swift
let query = HKStatisticsQuery(quantityType: energyConsumed, quantitySamplePredicate: today, options: .cumulativeSum) { (query, statisticsOrNil, errorOrNil) in
    
    guard let statistics = statisticsOrNil else {
        // Handle any errors here.
        return
    }
    
    let sum = statistics.sumQuantity()
    let totalCaloriesConsumed = sum?.doubleValue(for: HKUnit.largeCalorie())
    
    // Update your app here.
    
    // The results come back on an anonymous background queue.
    // Dispatch to the main queue before modifying the UI.
    
    DispatchQueue.main.async {
        // Update the UI here.
    }
}
```

#### 
After the query is instantiated, you run it by calling the HealthKit store’s  method on the HealthKit store.
```swift
store.execute(query)
```


## Executing Statistics Collection Queries
> https://developer.apple.com/documentation/healthkit/executing-statistics-collection-queries

### 
#### 
Start by creating your anchor date and time interval. The following sample starts by creating a 1-week time interval. Next, it sets the anchor date to Monday morning at 3:00 a.m. Because the interval is 1 week long, the anchor’s exact date doesn’t matter. Each set of statistics represents exactly 1 week, starting on Monday at 3:00 a.m.
```swift
let calendar = Calendar.current

// Create a 1-week interval.
let interval = DateComponents(day: 7)

// Set the anchor for 3 a.m. on Monday.
var components = DateComponents(calendar: calendar,
                                timeZone: calendar.timeZone,
                                hour: 3,
                                minute: 0,
                                second: 0,
                                weekday: 2)

guard let anchorDate = calendar.nextDate(after: Date(),
                                         matching: components,
                                         matchingPolicy: .nextTime,
                                         repeatedTimePolicy: .first,
                                         direction: .backward) else {
    fatalError("*** unable to find the previous Monday. ***")
}
```

```
Next, create the quantity type and the statistics collection query. The following code creates the quantity type for step counts and then creates the query itself.
```swift
guard let quantityType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
    fatalError("*** Unable to create a step count type ***")
}

// Create the query.
let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                        quantitySamplePredicate: nil,
                                        options: .cumulativeSum,
                                        anchorDate: anchorDate,
                                        intervalComponents: interval)
```

#### 
In your results handler, first check for and handle errors. Many  values indicate that you haven’t properly set up HealthKit. Always check HealthKit’s availability and request permission to read the specified data type before creating a query. For more information, see  and .
However, your app may need to explicitly check for some errors, depending on its needs. For example, if your app can run a query in the background, you need to check for and handle the  error.
```swift
// Set the results handler.
query.initialResultsHandler = {
    query, results, error in
    
    // Handle errors here.
    if let error = error as? HKError {
        switch (error.code) {
        case .errorDatabaseInaccessible:
            // HealthKit couldn't access the database because the device is locked.
            return
        default:
            // Handle other HealthKit errors here.
            return
        }
    }
    
    guard let statsCollection = results else {
        // You should only hit this case if you have an unhandled error. Check for bugs 
        // in your code that creates the query, or explicitly handle the error.
        assertionFailure("")
        return
    }

...
```

After you handle any errors, process the incoming statistics data, and then update your app. Be sure to dispatch code that updates the user interface to the  queue.
The following code calculates the start and end times for a 3-month window and then iterates over all the time intervals in that window. The statistics collection passes the enumeration block a statistics object for each time interval between the start and end dates. However, if the time interval doesn’t contain any samples, the provided statistics’s  method returns `nil`. Therefore, the sample must check to see whether it has a valid quantity. If it does, it adds the data; otherwise, it skips the time interval.
```swift
...
    
    let endDate = Date()
    let threeMonthsAgo = DateComponents(month: -3)
    
    guard let startDate = calendar.date(byAdding: threeMonthsAgo, to: endDate) else {
        fatalError("*** Unable to calculate the start date ***")
    }
    
    // Plot the weekly step counts over the past 3 months.
    var weeklyData = MyWeeklyData()
    
    // Enumerate over all the statistics objects between the start and end dates.
    statsCollection.enumerateStatistics(from: startDate, to: endDate)
    { (statistics, stop) in
        if let quantity = statistics.sumQuantity() {
            let date = statistics.startDate
            let value = quantity.doubleValue(for: .count())
            
            // Extract each week's data.
            weeklyData.addWeek(date: date, stepCount: Int(value))
        }
    }
    
    // Dispatch to the main queue to update the UI.
    DispatchQueue.main.async {
        myUpdateGraph(weeklyData: weeklyData)
    }
}
```

```
Finally, execute the query using the HealthKit store.
```swift
healthStore.execute(query)
```


## Logging symptoms associated with a medication
> https://developer.apple.com/documentation/healthkit/logging-symptoms-associated-with-a-medication

### 
#### 
4. Build and run the sample app on the iPhone to see the medication list after providing authorization. Tap a medication to see the most-recent dose event and associated symptoms. When tapping a medication, an additional authorization sheet prompts for authorization to access symptoms data.
5. To add more medications in the Health app and view them in the sample app, add their RxNorm codes to the `SideEffects` dictionary, along with their associated symptoms. For instance, for piroxicam, the RxNorm code is 105929, and the symptoms can be headache, loss of appetite, and nausea. To view the symptoms, modify `SideEffects` by adding the following code:
```None
"105929": [SymptomModel(name: "Headache", categoryID: .headache),
			SymptomModel(name: "Diarrhea", categoryID: .diarrhea),
			SymptomModel(name: "Nausea", categoryID: .nausea)]
```


## Reading route data
> https://developer.apple.com/documentation/healthkit/reading-route-data

### 
#### 
To guarantee that your app receives the most up-to-date route information, use an anchored object query to access the route and track any updates.
```swift
let runningObjectQuery = HKQuery.predicateForObjects(from: myWorkout)

let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
    
    guard error == nil else {
        // Handle any errors here.
        fatalError("The initial query failed.")
    }
    
    // Process the initial route data here.
}

routeQuery.updateHandler = { (query, samples, deleted, anchor, error) in
    
    guard error == nil else {
        // Handle any errors here.
        fatalError("The update failed.")
    }
    
    // Process updates or additions here.
}

store.execute(routeQuery)
```

#### 
3.  Your block receives one or more batches of location data. When the block’s done parameter is , you have received all the data.
4.  Call the HealthKit store’s  method to stop the query from receiving additional data.
```swift
// Create the route query.
let query = HKWorkoutRouteQuery(route: myRoute) { (query, locationsOrNil, done, errorOrNil) in
    
    // This block may be called multiple times.
    
    if let error = errorOrNil {
        // Handle any errors here.
        return
    }
    
    guard let locations = locationsOrNil else {
        fatalError("*** Invalid State: This can only fail if there was an error. ***")
    }
    
    // Do something with this batch of location data.
        
    if done {
        // The query returned all the location data associated with the route.
        // Do something with the complete data set.
    }
    
    // You can stop the query by calling:
    // store.stop(query)
    
}
store.execute(query)
```


## Running Queries with Swift Concurrency
> https://developer.apple.com/documentation/healthkit/running-queries-with-swift-concurrency

### 
#### 
For all queries, start by constructing the type and predicates that describe the desired data. The following code creates a type for workout samples, and a predicate that matches samples that started within the last week.
```swift
let workoutType = HKWorkoutType.workoutType()

// Get the date one week ago.
let calendar = Calendar.current
var components = calendar.dateComponents([.year, .month, .day], from: Date())
components.day = components.day! - 7
let oneWeekAgo = calendar.date(from: components)

// Create a predicate for all samples within the last week.
let inLastWeek = HKQuery.predicateForSamples(withStart: oneWeekAgo,
                                             end: nil,
                                             options: [.strictStartDate])
```

Next, create a descriptor that represents the query itself. The following descriptor uses the previous type and predicate to search for all workouts added to the HealthKit store after the provided anchor that are less than one week old.
```swift
// Create the query descriptor.
let anchorDescriptor =
HKAnchoredObjectQueryDescriptor(
    predicates: [.workout(inLastWeek)],
        anchor: myAnchor)
```

#### 
Descriptors that adopt the  protocol can perform one-shot queries. Call the descriptor’s  method to start the query. The query then gathers a snapshot of all the matching data currently in the HealthKit store.
Note that the type that the  method returns varies based on the descriptor. For example,  returns an array of properly typed samples, while the  returns a structure that contains arrays of added samples and deleted objects.
```swift
// Wait for the current results.
let results = try await anchorDescriptor.result(for: store)

// Process the results.
let addedSamples = results.addedSamples
let deletedSamples = results.deletedObjects

// Do something with the results here.

// Update the anchor.
myAnchor = results.newAnchor
```

#### 
Descriptors that adopt the  protocol can create long-running queries that monitor the HealthKit store and return periodic updates. Here, the  method returns an instance that adopts the  protocol. Note that the call to  is synchronous, but accessing data from the sequence is asynchronous.
The following code uses a `for` loop to read updates from the sequence as they arrive. The first instance contains all matching samples currently in the HealthKit store. This is the same as the results that the  method returns. However, the system continues to monitor the HealthKit store, and returns new results as they appear.
```swift
// Start a long-running query to monitor the HealthKit store.
let updateQueue = anchorDescriptor.results(for: store)

// Wait for the initial results and each update.
myUpdateTask = Task {
    for try await results in updateQueue {
        
        // Process the results.
        let addedSamples = results.addedSamples
        let deletedSamples = results.deletedObjects
        myAnchor = results.newAnchor
        
        log.append("- \(addedSamples.count) new workouts found.\n")
        log.append("- \(deletedSamples.count) deleted workouts found.\n")
    }
}
```

By wrapping the `for` loop in a , you can cancel the task to stop the long-running query.
```
By wrapping the `for` loop in a , you can cancel the task to stop the long-running query.
```swift
func stopUpdates() {
    myUpdateTask?.cancel()
    myUpdateTask = nil
}
```

#### 
> **tip:**  Most descriptors only adopt one of the two protocols; however, , , and  adopt both. Be sure to select  or  based on your app’s needs.
```swift
// Returns all matching samples currently in the HealthKit Store.
let results = try await anchorDescriptor.result(for: store)

// Sets up a long-running query that returns both the current matching samples
// as well as any changes.
let updateQueue = anchorDescriptor.results(for: store)
```


## Running workout sessions
> https://developer.apple.com/documentation/healthkit/running-workout-sessions

### 
#### 
Before creating a workout session, you must set up HealthKit and request permission to read and share any health data your app intends to use. For step-by-step instructions, see .
For workout sessions, you must request permission to share workout types. You may also want to read any data types automatically recorded by Apple Watch as part of the session.
```swift
// The quantity type to write to the health store.
let typesToShare: Set = [
    HKQuantityType.workoutType()
]

// The quantity types to read from the health store.
let typesToRead: Set = [
    HKQuantityType.quantityType(forIdentifier: .heartRate)!,
    HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
    HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    HKObjectType.activitySummaryType(),
    HKCharacteristicType(.activityMoveMode)
]

// Request authorization for those quantity types.
healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
    // Handle errors here.
}
```

#### 
To start a workout session, begin by creating a configuration object for the workout.
```swift
let configuration = HKWorkoutConfiguration()
configuration.activityType = .running
configuration.locationType = .outdoor
```

For example, while the session runs, Apple Watch automatically saves active energy-burned samples to the HealthKit store. HealthKit provides optimized calorie calculations for some activities. These include, but are not limited to, run, walk, cycle, stair-climbing, elliptical, and rowing activities. Furthermore, the calculations for activities may differ between indoor and outdoor locations. For all other activities, the system estimates calories based on the data from Apple Watch’s sensors. Depending on the activity, this rate is either never lower than the brisk walk burn rate or never lower than the brisk walk burn rate when moving.
Next, use the configuration to create your workout session and get a reference to the session’s  object.
```swift
do {
    session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
    builder = session.associatedWorkoutBuilder()
} catch {
    // Handle failure here.
    return
}
```

The  class’s initializer can throw an exception if the configuration is invalid, so you need to wrap the initializer in a `do-catch` block.
The  class’s initializer can throw an exception if the configuration is invalid, so you need to wrap the initializer in a `do-catch` block.
Then, create an  object and assign it to the workout builder.
```swift
builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                             workoutConfiguration: configuration)
```

Use the same configuration object for the workout session and the live data source. While the session runs, Apple Watch automatically collects data about the workout, and saves samples to the HealthKit store. For example, an outdoor running session collects and saves , , , and  samples.
You can assign delegates to monitor both the workout session and the workout builder.
```swift
session.delegate = self
builder.delegate = self
```

By default, the workout session automatically forwards all events to the builder, so both delegates should receive the same set of events. However, you can set the builder’s  property to  if you want to control the events set to the builder.
Finally, start the session and the builder.
```swift
session.startActivity(with: Date())
builder.beginCollection(withStart: Date()) { (success, error) in
    
    guard success else {
        // Handle errors.
    }
    
    // Indicate that the session has started.
}
```

#### 
While the session runs, Apple Watch automatically collects and adds samples and events based on the workout configuration. You can record additional information by adding your own events and samples to the workout. To add samples, call the builder’s  method. To add events, call the  method.
Typically, you should update your app’s user interface whenever the builder receives a new sample or event. To respond to new samples, implement your  delegate’s  method.
```swift
func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
    for type in collectedTypes {
        guard let quantityType = type as? HKQuantityType else {
            return // Nothing to do.
        }
        
        // Calculate statistics for the type.
        let statistics = workoutBuilder.statistics(for: quantityType)
        let label = labelForQuantityType(quantityType)
        
        DispatchQueue.main.async() {
            // Update the user interface.
        }   
    }
}
```

HealthKit calls this method whenever the builder receives a new sample. Your implementation should examine the samples and update your app’s user interface—for example, by updating the current distance traveled, calories burned, and pace during a run. Use the workout builder’s  method to calculate statistics, such as the total, average, minimum, or maximum, for any types that have new data.
To respond to new events, implement your  delegate’s  method.
```swift
func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    
    let lastEvent = workoutBuilder.workoutEvents.last
    
    DispatchQueue.main.async() {
        // Update the user interface here.
    }    
}
```

#### 
#### 
#### 
After the user finishes the workout, stop the session by calling .
```swift
session.stopActivity(with: Date())
```

After the session has transitioned to the `.stopped` state, call the builder’s  and  methods. Finally, call  to end the session.
```
After the session has transitioned to the `.stopped` state, call the builder’s  and  methods. Finally, call  to end the session.
```swift
func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                    from fromState: HKWorkoutSessionState, date: Date) {

    // Wait for the session to transition states before ending the builder.
    if toState == .stopped {

        builder.endCollection(withEnd: date) { (success, error) in

            guard success else {
                // Handle errors.
            }

            builder.finishWorkout { (workout, error) in
                
                guard workout != nil else {
                    // Handle errors.
                }

                session.end()
                
                DispatchQueue.main.async() {
                    // Update the user interface.
                }
            }
        }
    }
}
```

#### 

## Setting up HealthKit
> https://developer.apple.com/documentation/healthkit/setting-up-healthkit

### 
#### 
> **note:**  The `healthkit` entry isn’t used by watchOS apps.
#### 
Call the  method to confirm that HealthKit is available on the user’s device.
```swift
if HKHealthStore.isHealthDataAvailable() {
    // Add code to use HealthKit here.
}
```

#### 
If HealthKit is both enabled and available, instantiate an  object for your app as shown:
```swift
let healthStore = HKHealthStore()
```


