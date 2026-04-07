# Apple SWIFTDATA Skill


## Adding and editing persistent data in your app
> https://developer.apple.com/documentation/swiftdata/adding-and-editing-persistent-data-in-your-app

### 
#### 
Before SwiftData can store data from your app, the app must define the data model that represents the data. SwiftData uses model classes to construct the schema of the data model. For example, the sample app stores data about animals, and groups those animals into categories. To define the schema for this data model, the sample defines two model classes: `Animal` and `AnimalCategory`.
The `Animal` model class stores information about an animal, like its name and diet. To persist instances of `Animal`, the class definition applies the  macro. This macro generates code at compile time that ensures the class conforms to the  protocol and makes it possible for SwiftData to save animal data to a model container.
```swift
import SwiftData

@Model
final class Animal {
    var name: String
    var diet: Diet
    var category: AnimalCategory?
    
    init(name: String, diet: Diet) {
        self.name = name
        self.diet = diet
    }
}
```

```
The `AnimalCategory` model class stores information about an animal category, such as mammal or reptile. As with `Animal`, the `AnimalCategory` definition applies the  macro to ensure the class conforms to  and to save the animal category data to a model container.
```swift
import SwiftData

@Model
final class AnimalCategory {
    @Attribute(.unique) var name: String
    // `.cascade` tells SwiftData to delete all animals contained in the 
    // category when deleting it.
    @Relationship(deleteRule: .cascade, inverse: \Animal.category)
    var animals = [Animal]()
    
    init(name: String) {
        self.name = name
    }
}
```

#### 
When deciding how people add and edit data in your app, consider the user experience. The sample app, for instance, lets someone add and edit information about animals using a custom data entry view, named `AnimalEditor`.
The design of `AnimalEditor` allows the app to use the same view for both adding new animals and editing existing ones. To provide this behavior, the editor declares the `animal` property as an optional `Animal` type. If `animal` is `nil`, a person using the editor is adding an animal; otherwise, the person is editing an existing animal. The editor makes the intention obvious by determining the title of the editor based on the value of `animal` in a computed property.
```swift
struct AnimalEditor: View {
    let animal: Animal?
    
    private var editorTitle: String {
        animal == nil ? "Add Animal" : "Edit Animal"
    }
    // ...
}
```

```
To enable editing the values of a new or existing animal, the editor defines state variables for each editable value. These state variables store the data that a person enters into the editor, separating what they enter from the data stored in `animal`. This separation ensures that SwiftData doesn’t save changes that a person makes until they’re ready to save those changes. This also gives them an opportunity to discard any changes they may have made to the data in the editor.
```swift
@State private var name = ""
@State private var selectedDiet = Animal.Diet.herbivorous
@State private var selectedCategory: AnimalCategory?

var body: some View {
    NavigationStack {
        Form {
            TextField("Name", text: $name)
            
            Picker("Category", selection: $selectedCategory) {
                Text("Select a category").tag(nil as AnimalCategory?)
                ForEach(categories) { category in
                    Text(category.name).tag(category as AnimalCategory?)
                }
            }
            
            Picker("Diet", selection: $selectedDiet) {
                ForEach(Animal.Diet.allCases, id: \.self) { diet in
                    Text(diet.rawValue).tag(diet)
                }
            }
        }
    }
}
```

The sample app takes this approach because it uses the autosave feature from SwiftData. The autosave feature automatically saves data changes made to model class instances, such as `animal`, instead of relying on the app to make explicit calls to the model context  method. For more information about autosave, see .
Finally, to make the purpose of the editor clear to the person using it, `AnimalEditor` uses the `editorTitle` computed property to displays the title in the  item section of the toolbar:
```swift
.toolbar {
    ToolbarItem(placement: .principal) {
        Text(editorTitle)
    }
}
```

#### 
The `AnimalEditor` view declares its state variables with default values for a new animal, setting `name` to an empty string, `selectedDiet` to `herbivorous`, and leaving `selectedCategory` as `nil`. But the editor also supports editing an existing animal.
If someone edits an animal, the editor needs to show the values of the animal to edit, not the default values for the new animal. The view stores the animal to edit in the `animal` property. To show the current values of that animal, the editor applies the  modifier and copies the editable values from `animal` to the state variables:
```swift
.onAppear {
    if let animal {
        // Edit the incoming animal.
        name = animal.name
        selectedDiet = animal.diet
        selectedCategory = animal.category
    }
}
```

#### 
To allow a person to save the changes they made in the editor, the editor provides a Save button in the toolbar:
```swift
ToolbarItem(placement: .confirmationAction) {
    Button("Save") {
        withAnimation {
            save()
            dismiss()
        }
    }
}
```

```
When a person clicks the Save button, it calls the editor’s `save` method. If the person is editing an existing animal, `save` copies the values from the state variables to the instance of `Animal`. This directly updates the data that SwiftData manages, and because the app uses the autosave feature, SwiftData automatically saves the changes without calling the model context  method.
```swift
private func save() {
    if let animal {
        // Edit the animal.
        animal.name = name
        animal.diet = selectedDiet
        animal.category = selectedCategory
    } else {
        // Add an animal.
        // ...
    }
}
```

```
When adding a new animal, the `save` function creates a new `Animal` instance, initializing it with the name and diet from the state variables. Then it sets the category and inserts the animal into the model context by calling the model context  method:
```swift
private func save() {
    if let animal {
        // Edit the animal.
        // ...
    } else {
        // Add an animal.
        let newAnimal = Animal(name: name, diet: selectedDiet)
        newAnimal.category = selectedCategory
        modelContext.insert(newAnimal)
    }
}
```

#### 
To discard changes that someone made, the editor provides a Cancel button in the toolbar:
```swift
ToolbarItem(placement: .cancellationAction) {
    Button("Cancel", role: .cancel) {
        dismiss()
    }
}
```


## Adopting inheritance in SwiftData
> https://developer.apple.com/documentation/swiftdata/adopting-inheritance-in-swiftdata

### 
Like other Swift subclasses, SwiftData models can inherit the properties and capabilities of a parent or superclass. In SwiftData this allows you to add new properties and behaviors that extend the capabilities of your models by creating a hierarchical relationship between them that you can operating on using query, predicate, and history operations. This enables you to build in more flexibility into your app as your models become more specialized and able to serve more diverse use cases.
An example of such an app might one that tracks trips: both personal trips, such as family vacations, and business trips.  At a high level, a trip might be captured in a very concise model, like the one shown here.
```swift
@Model LivingAccommodation { ... }

@Model class Trip {
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
    
    var isBusinessTrip: Boolean = false
}

```

### 
Subclasses that build upon the base `Trip` model make use of its properties and any common behavior, but keep these new behaviors isolated. For example, a `PersonalTrip` doesn’t have to have a state or behavior for calculating the cumulative miles traveled in a reimbursement calculation: that’s more relevant to a `BusinessTrip`.
Given the outline of personal and business trip specialization above, you’d create model subclasses for SwiftData subclasses as you would in Swift, but with the addition of the `@Model` macro, to indicate the new class is a model to SwiftData. A refactoring of our trip classes into a parent (base) class and two subclasses could resemble these classes:
```swift
import SwiftData

@Model BucketListActivity { ... }

@Model class Trip {
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
}
```

```
Here, an expanded `Trip` base class no longer uses the Boolean value that previously indicated the kind of trip. The following `BusinessTrip` and `PersonalTrip` subclasses describe additional properties and behaviors that could define these specialized trip types and create a hierarchical relationship between the parent and the subclasses.
```swift

@available(iOS 26, *)
@Model class BusinessTrip: Trip {
    var purpose: String
    var itinerary: MeetingItinerary
    var expenseCode: String
    var perDiemRate: Double
    var mileageRate: Double
    
    @Relationship(deleteRule: .cascade, inverse: \DailyMilageRecord.trip)
    var milesDriven: [DailyMilageRecord]
    
    @Relationship(deleteRule: .cascade, inverse: \BusinessMeal.trip)
    var businessMeals: [BusinessMeal]
    
    @Relationship(deleteRule: .cascade, inverse: \ConferenceSession.trip)
    var sessionsAttended: [ConferenceSession]
}
```

```
The `PersonalTrip` subclass may have  a very different set of properties, its design and use case shares very little with a business trip, beside the name, place, optional transportation, and duration, as shown here.
```swift

@Model Attraction { ... }
@Model FamilyMember { ... }

@available(iOS 26, *)
@Model class PersonalTrip: Trip {
    enum Reason: String, CaseIterable, Codable, Identifiable {
        case family
        case reunion
        case wellness
        case unknown
        
        var id: Self { self }
    }

    var reason: Reason
    @Relationship(deleteRule: .cascade, inverse: \BucketListActivities.trip)
    var bucketList: [BucketListActivity]
    var attractionsToVisit: [Attraction]
    var familyMembers: [FamilyMember]
}
```

### 
Avoid using inheritance in scenarios where the specialized subclass would center on common properties, such as a trip’s name, or starting or ending dates; subclassing at this level of granularity, the class hierarchy would contain many subdomains that only share a single property. In these cases if common properties need some kind of specialized behavior, protocol conformance is a better tool.
Avoid using inheritance if your querying model would depend on fetching all of the model data all the time and then filtering the results, — this is known as a . It’s possible the specialization (here the difference between personal and business trips) is something that a Boolean type could represent as it did in the initial `Trip` model where a Boolean value differentiated the type of trip. Another method to keep models “flatter,” reduce the number of properties, and avoid inheritance is to add an enumeration type that has a value which captures the type of trip and it’s value, here the personal trip’s reason or the business trip’s per diem value instead of an `isBusinessTrip` Boolean property, as shown here:
```swift
    enum Category: Codable {
        case personal(Reason)​​​​​​​​​​​​
        case business(perdiem: Double)​​​​​​​​​​​​
    }
```

### 
Combining inheritance and customized predicates it’s possible to create any number of customized searching and filtering mechanisms that can select from any of the properties available in your parent or subclasses.
For example, to search for text in both `BusinessTrip` and `PersonalTrip` types, perform a deep search on properties using the base class `Trip`, as this the outline demonstrates:
```swift
struct TripListView: View {
    @Environment(\.modelContext) private var modelContext
    // All trips, in ascending order, by start date.
    @Query(sort: \Trip.startDate, order: .forward)
    var trips: [Trip]
    
    init(searchText: String) {
        let searchPredicate = #Predicate<Trip> {
            searchText.isEmpty ? true : $0.name.localizedStandardContains(searchText) || $0.destination.localizedStandardContains(searchText)
        }
        // Filter the trips array using predicate, which searches the trip name and destination for the provided `searchText`.
        _trips = Query(filter: searchPredicate, sort: \.startDate, order: .forward) 
    }
    
    var body: some View {
        /* View body contents */
    }
}
```

```
Selecting trips based on type, or all trips is a similar predicate: this example uses a simple enumeration and a switch to indicate which kind of trips to select.
```swift
enum TripKind: String, CaseIterable {
    case all = "All"
    case personal = "Personal"
    case business = "Business"
}

struct TripListView: View {
        @Environment(\.modelContext) private var modelContext
        /// All trips, in ascending order, by start date.
        @Query(sort: \Trip.startDate, order: .forward)
        var trips: [Trip]
    
        init(tripKind: Binding<ContentView.TripKind>) {            
            // Create a predicate, selected by the provided enumeration 
            // case, that examines the object's class to determine if it's 
            // a `BusinessTrip`, `PersonalTrip`, or `Trip`.
            let classPredicate: Predicate<Trip>? = {
                switch tripKind.wrappedValue {
                // Returns a `nil` predicate representing all trips.
                case .all:
                    return nil 
                // Returns a predicate that matches on `PersonalTrip` objects.
                case .personal:
                    return #Predicate { $0 is PersonalTrip }
                // Returns a predicate that matches on `BusinessTrip` objects.
                case .business:
                    return #Predicate { $0 is BusinessTrip }
                }
            }()
            
           // Filter the trips array using predicate, which matches on trips of a specific class.
           _trips = Query(filter: classPredicate, sort: \.startDate, order: .forward) 
        }
    
        var body: some View {
            // View body contents that displays the matching trips. 
        }
 }
 
```

```
The following example demonstrates how to combine both of these predicates to search for text in the trip’s’ `name` and `destination` properties, as well as by trips or by type of trip, if specified:
```swift

enum TripKind: String, CaseIterable {
    case all = "All"
    case personal = "Personal"
    case business = "Business"
}

struct TripListView: View {
    @Environment(\.modelContext) private var modelContext
    /// All trips, ordered by start date.
    @Query(sort: \Trip.startDate, order: .forward)
    var trips: [Trip]

    init(searchString: String, tripKind: Binding<ContentView.TripKind>) {     
        // Create a predicate that examines the object's class to determine
        // if it's a `BusinessType`, `Personal`, or `Trip` ("all trips").
        let classPredicate: Predicate<Trip>? = {
            switch tripKind.wrappedValue {
            // Returns a `nil` predicate representing all trips.
            case .all:
                return nil 
            // Returns a predicate that matches on `PersonalTrip` objects.
            case .personal:
                return #Predicate { $0 is PersonalTrip }
            // Returns a predicate that matches on `BusinessTrip` objects.
            case .business:
                return #Predicate { $0 is BusinessTrip }
            }
        }()
        
        // If there's search text, create a predicate than can search the trip's name and destination.        
        let searchPredicate = #Predicate<Trip> {
            searchText.isEmpty ? true : $0.name.localizedStandardContains(searchText) || $0.destination.localizedStandardContains(searchText)
        }   
    
        let fullPredicate: Predicate<Trip>
        if let classPredicate {
            fullPredicate = #Predicate { classPredicate.evaluate($0) && searchPredicate.evaluate($0) }
        } else {
            fullPredicate = searchPredicate
        }                                                          
        // Filter trips on other `searchText` or trip type, or both.
        _trips = Query(filter: fullPredicate, sort: \.startDate, order: .forward) 
    }

    var body: some View {
        // View body contents that displays the matching trips. 
    }
}
```


## Defining data relationships with enumerations and model classes
> https://developer.apple.com/documentation/swiftdata/defining-data-relationships-with-enumerations-and-model-classes

### 
#### 
Enumerations are a convenient way to form relationships between a model class and static data — data that the app defines and doesn’t change. To define the static data, create an enumeration and ensure it conforms to the  protocol. SwiftData requires this conformance to persist any data that is of the enumeration type. The following code, for example, declares a `Codable` conforming enumeration that specify the animal type based on their diets:
```swift
extension Animal {
    enum Diet: String, CaseIterable, Codable {
        case herbivorous = "Herbivore"
        case carnivorous = "Carnivore"
        case omnivorous = "Omnivore"
    }
}
```

```
The `Animal` model class declares the property `diet` as a type of `Diet`. Because this property is non-optional, its value must be set to one of the `Diet` cases: `herbivore`, `carnivore`, and `ominvore`.
```swift
@Model
final class Animal {
    var name: String
    var diet: Diet
    var category: AnimalCategory?
    
    init(name: String, diet: Diet) {
        self.name = name
        self.diet = diet
    }
}
```

A person using the sample app can set the diet of an animal by choosing one of the available `Diet` cases from a ; for example:
```
A person using the sample app can set the diet of an animal by choosing one of the available `Diet` cases from a ; for example:
```swift
Picker("Diet", selection: $selectedDiet) {
    ForEach(Animal.Diet.allCases, id: \.self) { diet in
        Text(diet.rawValue).tag(diet)
    }
}
```

#### 
If the related data is dynamic and unknown to the app — data that comes from an external source such as someone using the app or a remote server — then form a relationship between two model classes instead of a class and enumeration. For instance, the dynamic data in the sample app includes animals and animal categories. An animal can belong to no more than one animal category, and a category can contain zero, one, or more animals.
To declare this relationship, the `AnimalCategory` class defines the property `animals`, which represents the animals contained in the category. The class also applies the  macro to the `animals` property. This macro defines the relationship between the `AnimalCategory` and `Animal` model classes.
```swift
@Model
final class AnimalCategory {
    @Attribute(.unique) var name: String
    // `.cascade` tells SwiftData to delete all animals contained in the 
    // category when deleting it.
    @Relationship(deleteRule: .cascade, inverse: \Animal.category)
    var animals = [Animal]()
    
    init(name: String) {
        self.name = name
    }
}
```

#### 
The `deleteRule` parameter specifies how SwiftData handles delete operations with regards to the related data. The  delete rule tells SwiftData to delete all related data when deleting the primary object. For example, deleting an `AnimalCategory` in the sample app causes SwiftData to also delete all animals contained in that category.
```swift
@Relationship(deleteRule: .cascade, inverse: \Animal.category)
var animals = [Animal]()
```

```
If you don’t want to delete the animals within a category, you can use the  delete rule. This rule tells SwiftData to set the animal’s `category` property to `nil` for each animal contained in the animal category when deleting the category. Because the default value for the `deleteRule` parameter is `nullify`, you can create the relationship without explicitly specifying the delete rule, like so:
```swift
@Relationship(inverse: \Animal.category)
var animals = [Animal]()
```

#### 
Whether your data model includes relationships, you must always create a model container for your app when using SwiftData. The sample app creates a model container using the  modifier, passing in the model type `AnimalCategory.self`:
```swift
@main
struct SwiftDataAnimalsApp: App {
    var body: some Scene {
        WindowGroup() {
            ContentView()
        }
        .modelContainer(for: AnimalCategory.self)
    }
}
```


## Deleting persistent data from your app
> https://developer.apple.com/documentation/swiftdata/deleting-persistent-data-from-your-app

### 
### 
The sample app shows a list of animals. A person using the app can delete an animal using a swipe gesture. For example, the following code adds the swipe-to-delete option to the `AnimalList` view by applying the  modifier to :
```swift
private struct AnimalList: View {
    @Environment(NavigationContext.self) private var navigationContext
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Animal.name) private var animals: [Animal]

    var body: some View {
        @Bindable var navigationContext = navigationContext
        List(selection: $navigationContext.selectedAnimal) {
            ForEach(animals) { animal in
                NavigationLink(animal.name, value: animal)
            }
            .onDelete(perform: removeAnimals)
        }
    }
}
```

```
The  modifier in the previous code calls the custom method `removeAnimals` to remove one or more animals from the list. This method receives an  which identifies the animals to delete. The method then iterates through the index set, deleting each animal using the  method .
```swift
private func removeAnimals(at indexSet: IndexSet) {
    for index in indexSet {
        modelContext.delete(animals[index])
    }
}
```

```
However, it’s possible for a person using this sample to delete the selected animal, so the `removeAnimals` method needs to unselect the animal before deleting it. The updated version of `removeAnimals` uses the  to determine whether the animal to delete is also the selected animal. If it is, the method sets the selected animal to `nil`.
```swift
private func removeAnimals(at indexSet: IndexSet) {
    for index in indexSet {
        let animalToDelete = animals[index]
        if navigationContext.selectedAnimal?.persistentModelID == animalToDelete.persistentModelID {
            navigationContext.selectedAnimal = nil
        }
        modelContext.delete(animalToDelete)
    }
}
```

```
The sample uses the SwiftData autosave feature, which is enabled by default when creating a  using the  modifier. If this feature is disabled, the `removeAnimals` method needs to explicitly save the change by calling the  method ; for example:
```swift
private func removeAnimals(at indexSet: IndexSet) {
    do {
	    for index in indexSet {
	        let animalToDelete = animals[index]
	        if navigationContext.selectedAnimal?.persistentModelID == animalToDelete.persistentModelID {
	            navigationContext.selectedAnimal = nil
	        }
	        modelContext.delete(animalToDelete)
	    }
        try modelContext.save()
    } catch {
        // Handle error.
    }
}
```

### 
The sample app also lets a person delete the selected animal by clicking the Trash button that `AnimalDetailView` displays in its toolbar.
The sample app also lets a person delete the selected animal by clicking the Trash button that `AnimalDetailView` displays in its toolbar.
```swift
struct AnimalDetailView: View {
    var animal: Animal?
    @State private var isDeleting = false
    @Environment(\.modelContext) private var modelContext
    @Environment(NavigationContext.self) private var navigationContext

    var body: some View {
        if let animal {
            AnimalDetailContentView(animal: animal)
                .navigationTitle("\(animal.name)")
                .toolbar {
                    Button { isDeleting = true } label: {
                        Label("Delete \(animal.name)", systemImage: "trash")
                            .help("Delete the animal")
                    }
                }
        } else {
            ContentUnavailableView("Select an animal", systemImage: "pawprint")
        }
    }
}
```

```
The action for the button set the state variable `isDeleting` to `true`, which displays the delete confirmation alert described in the following code:
```swift
.alert("Delete \(animal.name)?", isPresented: $isDeleting) {
    Button("Yes, delete \(animal.name)", role: .destructive) {
        delete(animal)
    }
}
```

```
After confirming the delete request, the action for the confirmation button calls the custom `delete` method. This method sets the selected animal to `nil`, then deletes the animal from the model context by calling the  method.
```swift
private func delete(_ animal: Animal) {
    navigationContext.selectedAnimal = nil
    modelContext.delete(animal)
}
```

```
If the SwiftData autosave feature was disabled, the `delete` method would need to explicitly save the change by calling the `ModelContext` method ; for example:
```swift
private func delete(_ animal: Animal) {
    do {
        navigationContext.selectedAnimal = nil
        modelContext.delete(animal)
        try modelContext.save()
    } catch {
        // Handle error.
    }
}
```

### 
Deleting all items of a particular model type is less common in data driven apps, but there may be times when having this option is helpful. For example, the sample apps lets a person reload sample data that comes with the app. Reloading the sample data deletes all animal categories and animals from persistent storage.
To delete all items of a particular model type, use the  method . For example, the following code deletes all animal categories before reloading the sample data:
```swift
static func reloadSampleData(modelContext: ModelContext) {
    do {
        try modelContext.delete(model: AnimalCategory.self)
        insertSampleData(modelContext: modelContext)
    } catch {
        fatalError(error.localizedDescription)
    }
}
```

```
When deleting all animal categories, SwiftData also deletes all animals within those categories. SwiftData knows to perform this cascading delete because the relationship between `AnimalCategory` and `Animal` uses the  delete rule. (For a complete list of delete rules, see .)
```swift
import SwiftData

@Model
final class AnimalCategory {
    @Attribute(.unique) var name: String
    // `.cascade` tells SwiftData to delete all animals contained in the 
    // category when deleting it.
    @Relationship(deleteRule: .cascade, inverse: \Animal.category)
    var animals = [Animal]()
    
    init(name: String) {
        self.name = name
    }
}
```


## Fetching and filtering time-based model changes
> https://developer.apple.com/documentation/swiftdata/fetching-and-filtering-time-based-model-changes

### 
### 
Using a model context, you can fetch all transactions from the persistent store, or just a subset by specifying a history token, an author, or both. Tokens are opaque objects that conform to the  and  protocols, enabling you to store the most recent token on-disk and use it in the next fetch to receive only newer changes. An author is a short string that your app uses to identify the origin of a transaction, which you specify on the model context that writes those changes to the store.
For example, you may want to fetch all new transactions that originate from your app’s widget.
```swift
func fetchWidgetTransactions(after tokenData: Data) -> Result<[DefaultHistoryTransaction], Error> {
    do {
        // Decode the given token data.
        let token = try JSONDecoder().decode(History.DefaultToken.self, from: tokenData)
        // Create a history descriptor and specify the predicate.
        var descriptor = History.HistoryDescriptor<History.DefaultTransaction>()
        descriptor.predicate = #Predicate {
            ($0.token > token) && ($0.author == "widget")
        }
        // Fetch the matching history transactions.
        let context = ModelContext(modelContainer)
        let txns = try context.fetchHistory(descriptor)
        return .success(txns)
    } catch {
        return .failure(error)
    }
}
```

### 
As transactions represent points in time, they’re heterogenous — a single transaction can (and often will) contain changes for several different model types. Because of this, transactions aren’t bound to a specific model type. When you fetch them from a data store, the results will likely contain transactions, and changes within those transactions, that are unrelated to the current view or task. Filter each transaction’s changes and identify only those that are relevant.
The following example shows how you might identify trips with updated flight times:
```swift
let context = ModelContext(modelContainer)
var updatedTrips = Set<Trip>()

for txn in transactions {
    // Filter out any change that isn't an update.
    for change in txn.changes where change is History.DefaultUpdateChange<Trip> {
        // Proceed only when there's a single change, and that change 
        // is to the `flightTime` attribute.
        guard change.updatedAttributes.count == 1, 
              change.updatedAttributes.contains(\.flightTime)
        else { continue }
        // Use the model ID from the change to fetch the actual model.
        let changedModelID = change.changedModelID
        var fetchDescriptor = FetchDescriptor<Trip>(predicate: #Predicate { 
            $0.persistentModelID == changedModelID
        })
        if let trip = try? taskContext.fetch(fetchDescriptor).first {
            updatedTrips.insert(trip)
        }
    }
}
```

### 
After deleting a model from the data store, its values are gone with no way to recover them. In most situations, this is the preferred behavior. However, there may be occasions where your app needs to retain one or more attribute values from a deleted model. For example, using a model’s  as a means of identifying that model is only relevant within the scope of the local data store, and a different attribute may provide a stable identity across different devices and services. By retaining that attribute’s value, you’re able to reliably identify the deleted model after it’s gone.
To retain a value, use the  macro and specify the  option:
```swift
@Model
final class Trip {
    @Attribute(.preserveValueOnDeletion)
    var airlineBookingRef: String
    // ...
}
```

```
Then, when processing a transaction’s changes, use the `tombstone` property to retrieve the preserved value. `History/Tombstone` is a generic sequence type that lets you iterate over the preserved values, or access a specific value directly using the corresponding model key path.
```swift
if let deletion = change as? History.DefaultDeleteChange<Trip> {
   bookingRef = deletion.tombstone[\.airlineBookingRef]
}
```

### 
Similar to fetching, use a model context to delete transactions and provide a predicate to narrow the scope. For example, you may want to delete all transactions that occur before a given token:
```swift
func deleteTransactions(before token: History.DefaultToken) -> Result<Void, Error> {
    do {
        // Create a history descriptor and specify the predicate.
        var descriptor = History.HistoryDescriptor<History.DefaultTransaction>()
        descriptor.predicate = #Predicate {
            $0.token < token
        }
        // Delete the matching history transactions.
        let context = ModelContext(modelContainer)
        try context.deleteHistory(descriptor)
        return .success
    } catch {
        return .failure(error)
    }
}
```


## Filtering and sorting persistent data
> https://developer.apple.com/documentation/swiftdata/filtering-and-sorting-persistent-data

### 
#### 
The app’s `ContentView` fetches a complete list of earthquakes by applying the  macro to its `quakes` property:
The app’s `ContentView` fetches a complete list of earthquakes by applying the  macro to its `quakes` property:
```swift
@Query private var quakes: [Quake]
```

```
The query macro injects code that keeps the array of earthquake instances synchronized with items in the data store. The view uses this list of earthquakes to configure the navigation bar based on the selected earthquake. For example, it sets the title and subtitle in macOS:
```swift
.navigationTitle(quakes[selectedId]?.location.name ?? "Earthquakes")
.navigationSubtitle(quakes[selectedId]?.fullDate ?? "")
```

```
The above code relies on a subscript method that the app defines in an extension of :
```swift
extension Array where Element: Quake {
    subscript(id: Quake.ID?) -> Quake? {
        first { $0.id == id }
    }
}
```

#### 
It introduces the sorting by adding parameters to the query macro:
```swift
@Query(sort: \Quake.magnitude, order: .reverse)
private var quakes: [Quake]
```

The output of this query drives the generation of the map content builder’s `QuakeMarker` instances, and always appears in the desired order:
```
The output of this query drives the generation of the map content builder’s `QuakeMarker` instances, and always appears in the desired order:
```swift
Map(selection: $selectedIdMap) {
    ForEach(quakes) { quake in
        QuakeMarker(
            quake: quake,
            selected: quake.id == selectedId)
    }
}
```

#### 
-  — To enable people to focus on specific earthquakes, people can enter text in a search field that the app matches against earthquake location names.
To implement this filtering, the app defines a static method that returns a  that takes into account both a search date and search text:
```swift
static func predicate(
    searchText: String,
    searchDate: Date
) -> Predicate<Quake> {
    let calendar = Calendar.autoupdatingCurrent
    let start = calendar.startOfDay(for: searchDate)
    let end = calendar.date(byAdding: .init(day: 1), to: start) ?? start

    return #Predicate<Quake> { quake in
        (searchText.isEmpty || quake.location.name.contains(searchText))
        &&
        (quake.time > start && quake.time < end)
    }
}
```

#### 
When someone selects a new date or changes the search text, the app needs to update the query to match. The map view achieves this by providing an initializer with `searchDate` and `searchText` inputs, and rebuilding the stored query using those values:
```swift
init(
    selectedId: Binding<Quake.ID?>,
    selectedIdMap: Binding<Quake.ID?>,
    searchDate: Date = .now,
    searchText: String = ""
) {
    _selectedId = selectedId
    _selectedIdMap = selectedIdMap

    _quakes = Query(
        filter: Quake.predicate(
            searchText: searchText,
            searchDate: searchDate),
        sort: \.magnitude,
        order: .reverse
    )
}
```

Because these values are inputs to the view’s initializer, SwiftUI reevaluates the initializer to produce a new query whenever either value changes. This in turn updates the appearance of the view.
The earthquake list view does something similar, although in this case it takes sort configuration inputs as well:
```swift
init(
    selectedId: Binding<Quake.ID?>,
    selectedIdMap: Binding<Quake.ID?>,
    
    searchText: String = "",
    searchDate: Date = .now,
    sortParameter: SortParameter = .time,
    sortOrder: SortOrder = .reverse
) {
    _selectedId = selectedId
    _selectedIdMap = selectedIdMap

    let predicate = Quake.predicate(searchText: searchText, searchDate: searchDate)
    switch sortParameter {
    case .time: _quakes = Query(filter: predicate, sort: \.time, order: sortOrder)
    case .magnitude: _quakes = Query(filter: predicate, sort: \.magnitude, order: sortOrder)
    }
}
```


## Maintaining a local copy of server data
> https://developer.apple.com/documentation/swiftdata/maintaining-a-local-copy-of-server-data

### 
#### 
The app represents the information it needs for its interface by defining a `Quake` class. The class definition includes the  macro to tell the system to store the data persistently using SwiftData:
```swift
import SwiftData

@Model
class Quake {
    @Attribute(.unique) var code: String
    var magnitude: Double
    var time: Date
    var location: Location
}
```

-  — A custom `Location` instance that contains a location name and map coordinates:
-  — The moment in time when the earthquake happened, stored as a  instance.
-  — A custom `Location` instance that contains a location name and map coordinates:
```swift
struct Location: Codable {
    var name: String
    var longitude: Double
    var latitude: Double
}
```

The `Quake` model can embed a location instance because the `Location` structure conforms to the  protocol.
#### 
The app loads data from a U.S. Geological Survey (USGS) server, which provides earthquake data in  format. To interpret this data, the app defines a `GeoFeatureCollection` structure with property names that match the names of relevant JSON properties:
```swift
struct GeoFeatureCollection: Decodable {
    let features: [Feature]

    struct Feature: Decodable {
        let properties: Properties
        let geometry: Geometry
        
        struct Properties: Decodable {
            let mag: Double
            let place: String
            let time: Date
            let code: String
        }

        struct Geometry: Decodable {
            let coordinates: [Double]
        }
    }
}
```

#### 
To retrieve data, the app defines a `fetchFeatures()` method that uses a  to store the earthquake JSON in a `data` property:
To retrieve data, the app defines a `fetchFeatures()` method that uses a  to store the earthquake JSON in a `data` property:
```swift
let session = URLSession.shared
guard let (data, response) = try? await session.data(from: url),
      let httpResponse = response as? HTTPURLResponse,
      httpResponse.statusCode == 200
else {
    throw DownloadError.missingData
}
```

The method then parses the data with a  instance, according to the definition provided by the decodable `GeoFeatureCollection` structure:
```
The method then parses the data with a  instance, according to the definition provided by the decodable `GeoFeatureCollection` structure:
```swift
do {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
    return try jsonDecoder.decode(GeoFeatureCollection.self, from: data)
} catch {
    throw DownloadError.wrongDataFormat(error: error)
}
```

#### 
After retrieving a collection of features, the app interprets each feature as an earthquake. The `Quake` class defines a convenience initializer that creates a new earthquake from a feature instance:
```swift
convenience init(from feature: GeoFeatureCollection.Feature) {
    self.init(
        code: feature.properties.code,
        magnitude: feature.properties.mag,
        time: feature.properties.time,
        name: feature.properties.place,
        longitude: feature.geometry.coordinates[0],
        latitude: feature.geometry.coordinates[1]
    )
}
```

#### 
As the app creates new earthquake instances, it persistently stores any that have a magnitude greater than zero by calling the model context’s  method for each one:
```swift
for feature in featureCollection.features {
    let quake = Quake(from: feature)

    if quake.magnitude > 0 {
        modelContext.insert(quake)
    }
}
```


## Preserving your app’s model data across launches
> https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches

### 
#### 
To let SwiftData save instances of a model class, import the framework and annotate that class with the  macro. The macro updates the class with conformance to the  protocol, which SwiftData uses to examine the class and generate an internal schema. Additionally, the macro enables change tracking for the class by adding conformance to the  protocol.
```swift
import SwiftData

// Annotate new or existing model classes with the @Model macro.
@Model
class Trip {
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var accommodation: Accommodation?
}
```

#### 
An  is a property of a model class that SwiftData manages. In most cases, the framework’s default behavior for attributes is sufficient. However, if you need to alter how SwiftData handles the persistence of a particular attribute, use one of the provided schema macros. For example, you may want to avoid conflicts in your model data by specifying that an attribute’s value is unique across all instances of that model.
To customize an attribute’s behavior, annotate the property with the  macro and specify values for the options that drive the desired behavior:
```swift
@Attribute(.unique) var name: String
```

Aside from enforcing unique constraints, `@Attribute` supports, among others, preserving deleted values, Spotlight indexing, and encryption. You can also use the `@Attribute` macro to correctly handle renamed attributes if you want to preserve the original name in the underlying model data.
When a model contains an attribute whose type is also a model (or a collection of models), SwiftData implicitly manages the relationship between those models for you. By default, the framework sets relationship attributes to `nil` after you delete a related model instance. To specify a different deletion rule, annotate the property with the  macro. For example, you may want to delete any related accommodations when deleting a trip. For more information about delete rules, see .
```swift
@Relationship(.cascade) var accommodation: Accommodation?
```

```
SwiftData persists all noncomputed attributes of a model by default, but you may not always want this to happen. For example, one or more properties on a class may only ever contain temporary data that doesn’t need saving, such as the current weather at an upcoming trip’s destination. In such scenarios, annotate those properties with the  macro and SwiftData won’t write their values to disk.
```swift
@Transient var destinationWeather = Weather.current()
```

#### 
Before SwiftData can examine your models and generate the required schema, you need to tell it — at runtime — which models to persist, and optionally, the configuration to use for the underlying storage. For example, you may want the storage to exist only in memory when running tests, or to use a specific CloudKit container when syncing model data across devices.
To set up the default storage, use the  view modifier (or the scene equivalent) and specify the array of model types to persist. If you use the view modifier, add it at the very top of the view hierarchy so all nested views inherit the properly configured environment:
```swift
import SwiftUI
import SwiftData

@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
                    Trip.self,
                    Accommodation.self
                ])
        }
    }
}
```

```
If you’re not using SwiftUI, create a model container manually using the appropriate initializer:
```swift
import SwiftData

let container = try ModelContainer([
    Trip.self, 
    Accommodation.self
])
```

- the storage is read-only.
- the app uses a specific App Group to store its model data.
```swift
let configuration = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: false)

let container = try ModelContainer(
    for: Trip.self, Accommodation.self, 
    configurations: configuration
)
```

#### 
To manage instances of your model classes at runtime, use a  — the object responsible for the in-memory model data and coordination with the model container to successfully persist that data. To get a context for your model container that’s bound to the main actor, use the  environment variable:
```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
}
```

```
Outside of a view, or if you’re not using SwiftUI, access the same actor-bound context directly using the model container:
```swift
let context = container.mainContext
```

In both instances, the returned context periodically checks whether it contains unsaved changes, and if so, implicitly saves those changes on your behalf. For contexts you create manually, set the  property to `true` to get the same behavior.
To enable SwiftData to persist a model instance and begin tracking changes to it, insert the instance into the context:
```swift
var trip = Trip(name: name, 
                destination: destination, 
                startDate: startDate, 
                endDate: endDate)

context.insert(trip)
```

#### 
After you begin persisting model data, you’ll likely want to retrieve that data, materialized as model instances, and display those instances in a view or take some other action on them. SwiftData provides the  property wrapper and the  type for performing fetches.
To fetch model instances, and optionally apply search criteria and a preferred sort order, use `@Query` in your SwiftUI view. The `@Model` macro adds `Observable` conformance to your model classes, enabling SwiftUI to refresh the containing view whenever changes occur to any of the fetched instances.
```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \.startDate, order: .reverse) var allTrips: [Trip]
    
    var body: some View {
        List {
            ForEach(allTrips) {
                TripView(for: $0)
            }
        }
    }
}
```

```
Outside of a view, or if you’re not using SwiftUI, use one of the two fetch methods on . Each method expects an instance of  containing a predicate and a sort order. The fetch descriptor allows for additional configuration that influences batching, offsets, and prefetching, among others.
```swift
let context = container.mainContext

let upcomingTrips = FetchDescriptor<Trip>(
    predicate: #Predicate { $0.startDate > Date.now },
    sortBy: [
        .init(\.startDate)
    ]
)
upcomingTrips.fetchLimit = 50
upcomingTrips.includePendingChanges = true

let results = context.fetch(upcomingTrips)
```


## Reverting data changes using the undo manager
> https://developer.apple.com/documentation/swiftdata/reverting-data-changes-using-the-undo-manager

### 
#### 
Using SwiftData to store data, you can enable undo support for data changes by setting the `isUndoEnabled` parameter to `true` when applying the  modifier to a scene or view in your SwiftUI app:
```swift
@main
struct SwiftDataAnimalsApp: App {
    var body: some Scene {
        WindowGroup() {
            ContentView()
        }
        .modelContainer(for: AnimalCategory.self, isUndoEnabled: true)
    }
}
```

> **note:** To retrieve the  in a SwiftUI view, use the  environment value; for example, `@Environment(\.modelContext) private var modelContext`.

## Syncing model data across a person’s devices
> https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices

### 
#### 
#### 
#### 
5. Create a managed object model that contains the same model types as the `ModelConfiguration` instance.
6. Use  to load the store from the description and to initialize the CloudKit schema.
7. Unload the persistent store before creating an instance of  to avoid both frameworks attempting to sync data to CloudKit.
```swift
let config = ModelConfiguration()

do {
#if DEBUG
    // Use an autorelease pool to make sure Swift deallocates the persistent 
    // container before setting up the SwiftData stack.
    try autoreleasepool {
        let desc = NSPersistentStoreDescription(url: config.url)
        let opts = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.example.Trips")
        desc.cloudKitContainerOptions = opts
        // Load the store synchronously so it completes before initializing the 
        // CloudKit schema.
        desc.shouldAddStoreAsynchronously = false
        if let mom = NSManagedObjectModel.makeManagedObjectModel(for: [Trip.self, Accommodation.self]) {
            let container = NSPersistentCloudKitContainer(name: "Trips", managedObjectModel: mom)
            container.persistentStoreDescriptions = [desc]
            container.loadPersistentStores {_, err in
                if let err {
                    fatalError(err.localizedDescription)
                }
            }
            // Initialize the CloudKit schema after the store finishes loading.
            try container.initializeCloudKitSchema()
            // Remove and unload the store from the persistent container.
            if let store = container.persistentStoreCoordinator.persistentStores.first {
                try container.persistentStoreCoordinator.remove(store)
            }
        }
    }
#endif
    modelContainer = try ModelContainer(for: Trip.self, Accommodation.self,
                                        configurations: config)
} catch {
    fatalError(error.localizedDescription)
}
```

#### 
To opt out of automatic container discovery in SwiftData, create an instance of  and use the initializer’s `cloudKitDatabase` parameter to specify your preferred identifier:
```swift
let config = ModelConfiguration(cloudKitDatabase: .private("iCloud.com.example.Trips"))
let modelContainer = try ModelContainer(for: Trip.self, Accommodation.self,
                                        configurations: config)
```

#### 
In such scenarios, opt out of automatic iCloud sync by creating an instance of  and explicitly pass  for the `cloudKitDatabase` parameter:
SwiftData uses CloudKit to provide automatic iCloud sync and therefore requires the same Xcode-managed capabilities as those found in traditional CloudKit apps. This sharing of capabilities may lead to issues in apps already using CloudKit, because SwiftData assumes the presence of those capabilities as an indication that it handles sync. For example, automatic sync isn’t possible if there are incompatibilities between a SwiftData schema and an existing CloudKit schema.
In such scenarios, opt out of automatic iCloud sync by creating an instance of  and explicitly pass  for the `cloudKitDatabase` parameter:
```swift
let config = ModelConfiguration(cloudKitDatabase: .none)
let modelContainer = try ModelContainer(for: Trip.self, Accommodation.self,
                                        configurations: config)
```

Specifying `none` overrides any automatically discovered identifiers and disables SwiftData’s automatic iCloud sync.

