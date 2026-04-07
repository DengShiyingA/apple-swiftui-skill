# Apple EVENTKIT Skill


## Accessing Calendar using EventKit and EventKitUI
> https://developer.apple.com/documentation/eventkit/accessing-calendar-using-eventkit-and-eventkitui

### 
#### 
#### 
- If your app requests permission using  or `requestAccess(to:)`, remove these instance methods from your source code.
- If your app requests permission using  or `requestAccess(to:)`, remove these instance methods from your source code.
The `DropInLessons` app writes data to Calendar without performing any other operations on the user’s events. Because its workflow doesn’t interact with the user’s calendar data, the app isn’t required to include any calendar usage strings or prompt the user for access.  allows apps to request permission from the user, and read and write data to Calendar. `DropInLessons` creates an instance of the event store, `store`.
```swift
@State private var store = EKEventStore()
```

When the user schedules a lesson, `DropInLessons` creates a `selectedEvent`, then presents an event edit view controller.
```
When the user schedules a lesson, `DropInLessons` creates a `selectedEvent`, then presents an event edit view controller.
```swift
    .sheet(isPresented: $showEventEditViewController,
           onDismiss: didDismissEventEditController, content: {
       EventEditViewController(event: $selectedEvent, eventStore: store)
})
```

```
The app creates `selectedEvent` in the event store, adds it to the default calendar for the store, then configures `selectedEvent` with the selected lesson’s details. The view controller takes `selectedEvent` and `store` as parameters.
```swift
let controller = EKEventEditViewController()
controller.eventStore = eventStore
controller.event = event
controller.editViewDelegate = context.coordinator
```

```
`DropInLessons` relinquishes control once the editor is presented. Because the event edit view controller renders its content out of process, it has full access to all the user’s calendars on the device, regardless of the access granted to the app. This allows the user to get a full-featured editing experience, such as choosing another calendar to save the selected lesson or changing presented information in the editor. However, the app isn’t aware of any of these changes. When the user taps the Add button in the UI, the system saves the lesson to the user’s selected or default calendar, then dismisses the editor.
```swift
func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
    parent.presentationMode.wrappedValue.dismiss()
}
```

#### 
- Add the `NSCalendarsWriteOnlyAccessUsageDescription` key to the `Info.plist` file of the target building your app.
- To request write-only access to events, use `requestWriteOnlyAccessToEvents(completion:)` or `requestWriteOnlyAccessToEvents()`.
`RepeatingLessons` displays a list of recurring lessons and a “Select calendar” button in the toolbar. The app offers the lessons on specific dates and times and doesn’t fetch any events from the user’s calendars. `RepeatingLessons` can’t let the user or the system make any changes to these events. Because of these reasons, the app requires write-only access so it can control the date and time of every event added to Calendar. When the user selects a lesson, then taps the booking button, the app first checks whether it has authorization to access the user’s calendar data. If the authorization status is , the app uses an instance of , `eventStore`, to prompt the user for write-only access.
```swift
return try await eventStore.requestWriteOnlyAccessToEvents()
```

```
`RepeatingLessons` includes `NSCalendarsWriteOnlyAccessUsageDescription` in its `Info.plist` file and uses its value when showing an alert. The alert prompts the user for write-only acess to save repeating lessons to a calendar that the user chooses. If the user grants the request, the app receives a `.writeOnly` authorization status, creates a recurring event using the selected lesson’s details, then saves it to Calendar without the user making any changes to this event.
```swift
try self.eventStore.save(newEvent, span: .futureEvents)
```

```
The “Select calendar” button in the toolbar allows the user to choose another calendar to save the recurring events using `EKCalendarChooser`. The app turns off the button by default. The app turns it on when the user grants write-only or full access to the app. When the user taps the button, `RepeatingLessons` presents a calendar chooser with an instance of , `calendar`, which keeps track of calendars the user chooses in the view controller.
```swift
.sheet(isPresented: $showCalendarChooser) {
    CalendarChooser(calendar: $calendar)
}
```

```
The  property of `EKCalendarChooser` specifies whether to display writable calendars only or all calendars. In write-only access apps, the calendar chooser ignores the value of the `displayStyle` setting and this setting always behaves as if it’s set to . As a result, the app only allows the user to select a single writable calendar from the list presented in the calendar chooser.
```swift
// Initializes a calendar chooser that allows the user to select a single calendar from a list of writable calendars only.
let calendarChooser = EKCalendarChooser(selectionStyle: .single,
                                        displayStyle: .writableCalendarsOnly,
                                        entityType: .event,
                                        eventStore: storeManager.store)
```

The app sets the  property of `EKCalendarChooser` to `calendar`, which is empty when the user hasn’t selected a calendar.
```
The app sets the  property of `EKCalendarChooser` to `calendar`, which is empty when the user hasn’t selected a calendar.
```swift
/*
    Set up the selected calendars property. If the user previously selected a calendar from the view controller, update the property with it.
    Otherwise, update selected calendars with an empty set.
*/
if let calendar = calendar {
    let selectedCalendar: Set<EKCalendar> = [calendar]
    calendarChooser.selectedCalendars = selectedCalendar
} else {
    calendarChooser.selectedCalendars = []
}
```

`RepeatingLessons` configures the chooser to show the Done and Cancel buttons.
```
`RepeatingLessons` configures the chooser to show the Done and Cancel buttons.
```swift
calendarChooser.delegate = context.coordinator
// Configure the chooser to display Done and Cancel buttons.
calendarChooser.showsDoneButton = true
calendarChooser.showsCancelButton = true
return UINavigationController(rootViewController: calendarChooser)
```

#### 
- Add the `NSCalendarsFullAccessUsageDescription` key to the `Info.plist` file of the target building your app.
- To request full access to events, use `requestFullAccessToEvents(completion:)` or `requestFullAccessToEvents()`.
Upon its first launch, the `MonthlyEvents` app registers for  notifications to listen for any changes to the event store.
- To request full access to events, use `requestFullAccessToEvents(completion:)` or `requestFullAccessToEvents()`.
Upon its first launch, the `MonthlyEvents` app registers for  notifications to listen for any changes to the event store.
```swift
let center = NotificationCenter.default
let notifications = center.notifications(named: .EKEventStoreChanged).map({ (notification: Notification) in notification.name })
for await _ in notifications {
    guard await dataStore.isFullAccessAuthorized else { return }
    await self.fetchLatestEvents()
}
```

```
Then, the app checks whether it’s authorized to access the user’s calendar data.
```swift
let status = EKEventStore.authorizationStatus(for: .event)
```

If the authorization status is , the app uses an instance of , `eventStore`, to prompt the user for full access.
```
If the authorization status is , the app uses an instance of , `eventStore`, to prompt the user for full access.
```swift
return try await eventStore.requestFullAccessToEvents()
```

```
`MonthlyEvents` includes `NSCalendarsFullAccessUsageDescription` in its `Info.plist` file and uses its value when showing an alert. The alert  prompts the user for  full access to fetch events in all the user’s calendars and delete the ones the user selects in the app. If the user grants the request, the app receives a `.fullAccess` authorization status.
```swift
EKEventStore.authorizationStatus(for: .event) == .fullAccess
```

```
Then, the app fetches and displays all events occuring within a month in all the user’s calendars sorted by start date in ascending order.
```swift
let start = Date.now
let end = start.oneMonthOut
let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
return eventStore.events(matching: predicate).sortedEventByAscendingDate()
```

If the user denies the request, the app does nothing. In subsequent launches, the app displays a message prompting the user to grant the app full access in Settings on their device.
Because the user authorized the app for full access, the user can additionally select and delete one or more events in `MonthlyEvents`. The app iterates through an array of events that the user chose to delete. It calls and sets the `commit` parameter of the  function to `false` to batch the deletion of each event in the array.
```swift
try self.eventStore.remove(event, span: .thisEvent, commit: false)
```

```
Then, the app commits the changes once it’s done iterating through the array.
```swift
try eventStore.commit()
```

```
When you assign `true` to `commit` to immediately save or remove the event in your app, the event store automatically rolls back any changes if the commit operation fails. However, if you set `commit` to `false` and your app successfully removes some events and fails removing others, this can result in a later commit failing. Every subsequent commit fails until you roll back the changes. Call  to manually roll back the changes.
```swift
eventStore.reset()
```

#### 
- To request access to events, use  or `requestAccess(to: .event)`.
The `DropInLessons`, `MonthlyEvents`, and `RepeatingLessons` targets in the sample project have a deployment target of iOS 16.4, meaning their apps can run on devices running iOS 16.4 and later. These apps include `NSCalendarsUsageDescription` in their `Info.plist` and use `requestAccess(to: .event`) when requesting permission from the user.
```swift
// Fall back on earlier versions.
return try await eventStore.requestAccess(to: .event)
```

`MonthlyEvents` and `RepeatingLessons` confirm that they have an  authorization status.
`MonthlyEvents` and `RepeatingLessons` confirm that they have an  authorization status.
```swift
// Fall back on earlier versions.
EKEventStore.authorizationStatus(for: .event) == .authorized
```


## Implementing a virtual conference extension
> https://developer.apple.com/documentation/eventkit/implementing-a-virtual-conference-extension

### 
#### 
#### 
#### 
The Virtual Conference template creates an `Info.plist` file and the `VirtualConferenceProvider` class. The `Info.plist` file includes an `NSExtensionPointIdentifier` key and an `NSExtensionPrincipalClass` key under the `NSExtension` key:
```None
<plist>
    <dict>
        <key>NSExtension</key>
        <dict>
            <key>NSExtensionPointIdentifier</key>
            <string>com.apple.calendar.virtualconference</string>
            <key>NSExtensionPrincipalClass</key>
            <string>$(PRODUCT_MODULE_NAME).VirtualConferenceProvider</string>
        </dict>
    </dict>
</plist>
```

#### 
The sample project extension provides a personal room and a one-time room that people can select in the calendar event to schedule a virtual conference. It creates an  object for each room. Each descriptor specifies a title and a unique identifier for the room:
```swift
let personalRoom = EKVirtualConferenceRoomTypeDescriptor(title: "Personal Room", identifier: "personal-room")
let oneTimeRoom = EKVirtualConferenceRoomTypeDescriptor(title: "One-Time Room", identifier: "onetime-room")
```

```
Then the sample project extension modifies the  method to return a list that contains these rooms:
```swift
override func fetchAvailableRoomTypes() async throws -> [EKVirtualConferenceRoomTypeDescriptor] {
   // Create the different room types the app supports.
   let personalRoom = EKVirtualConferenceRoomTypeDescriptor(title: "Personal Room", identifier: "personal-room")
   let oneTimeRoom = EKVirtualConferenceRoomTypeDescriptor(title: "One-Time Room", identifier: "onetime-room")
    
   // A list of virtual rooms people can select in the calendar event.
   return [personalRoom, oneTimeRoom]
}
```

#### 
The sample project extension calls a custom method to set up a virtual conference descriptor for each of the rooms it provides. It creates a list of URL descriptors, including an HTTP URL universal link for joining the conference and an optional secondary URL for dialing in to the conference:
```swift
/*
     The sample project extension provides a primary URL to join this conference and an optional alternate URL
     to let people dial in to the conference.
 */
 var urlDescriptors = [EKVirtualConferenceURLDescriptor(title: "Join Meeting", url: url)]
        
if let alternateURL {
   urlDescriptors.append(EKVirtualConferenceURLDescriptor(title: "Audio Only", url: alternateURL))
}
```

```
Then the sample project extension creates an  object that takes a specified name, the list of URL descriptors, and conference details:
```swift
// A descriptor that includes a title, a list of URL descriptors, and information about the conference.
 let virtualConferenceDescriptor = EKVirtualConferenceDescriptor(title: title, urlDescriptors: urlDescriptors, conferenceDetails: details)
```

#### 
After a person selects the personal room or one-time room from the list in the calendar event, the system calls the  method to fetch details about the room using its unique identifier.
The sample project extension uses this identifier to determine which virtual conference descriptor to create and provide. For example, if the identifier identifies the personal room, the sample project extension creates and configures a virtual conference descriptor that includes a name, a URL for joining the conference, and a generic message about the conference. If the identifier identifies the one-time room, the sample project extension creates and configures a virtual conference descriptor that includes a name, a URL for joining the conference, a phone number for dialing in to the conference, and reading material for the conference.
```swift
override func fetchVirtualConference(identifier: EKVirtualConferenceRoomTypeIdentifier) async throws -> EKVirtualConferenceDescriptor {
    let meetingID = UUID().uuidString.prefix(8).lowercased()
         
    // The identifier determines which conference the sample project extension sets up and returns.
    switch identifier {
    case "personal-room":
        let personalRoomDescriptor = createVirtualConferenceDescriptor(with: "Personal Room",
                                                                       url: URL(string: "https://www.personal.example.com/\(meetingID)")!,
                                                                       details: "Please join the meeting in my personal room.")
        return personalRoomDescriptor
    case "onetime-room":
        let details = "For the topic, see the documentation at https://developer.apple.com/documentation/eventkit/ekvirtualconferenceprovider"
        let oneTimeRoomDescriptor = createVirtualConferenceDescriptor(with: "One-Time Room",
                                                                      url: URL(string: "https://www.team.example.com/\(meetingID)")!,
                                                                      alternateURL: URL(string: "tel:1-408-555-0100"),
                                                                      details: details)
            
        return oneTimeRoomDescriptor
    // If the identifier is unknown, the sample project extension throws an error to indicate an invalid room.
    default:
        throw VirtualConferenceSampleError.invalidRoom(identifier)
    }
}
```


## Managing location-based reminders
> https://developer.apple.com/documentation/eventkit/managing-location-based-reminders

### 
#### 
#### 
#### 
#### 
The sample app verifies its authorization status upon launching. The authorization status of the app is  until the person authorizes or denies access. The person can grant or deny the app access to their reminder data, then change the authorization status later in the Settings app. To determine its status, the app calls the  class method of  with an entity type :
```swift
authorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
```

#### 
If the authorization status is , the sample app initializes a single instance of , `eventStore`, then calls its  method to prompt the person for full access:
```swift
return try await withCheckedThrowingContinuation { continuation in
    eventStore.requestFullAccessToReminders { granted, error in
        if let error {
            continuation.resume(throwing: error)
        }
        continuation.resume(returning: granted)
    }
}
```

#### 
Creating a reminder requires a list, which is a calendar for these items. The app calls  on `eventStore` to check whether the person has specified a default list for reminders.
```swift
eventStore.defaultCalendarForNewReminders() != nil
```

#### 
5. Save the reminder.
First, the sample app creates an  object using , then it sets the  and  properties, and other properties, such as priority and time zone:
```swift
let reminder = EKReminder(eventStore: eventStore)
reminder.calendar = calendar
reminder.title = entry.title
reminder.priority = entry.priority

/*
    The app creates reminders with a specific date and time. To create an
    all-day reminder, set `dueDateComponents` to a date component without
    hour, minute, and second components.
*/
reminder.dueDateComponents = Date.next7DaysComponents

/*
    A floating reminder is one that isn't associated with a specific time
    zone. Set `timeZone` to `nil` if you wish to have a floating reminder.
*/
reminder.timeZone = TimeZone.current
```

> **important:** The `calendar` and `title` properties are required and must be set before saving the reminder.
Next, the sample creates a structured location by using either ’s  or  methods. When the location object has latitude and longitude coordinates, the app uses `init(title:)` to create the structured location. The sample initializes an  object with the specified latitude and longitude, then assigns it to the created structured location’s  property:
```swift
let structuredLocation = EKStructuredLocation(title: annotation.name)
structuredLocation.geoLocation = CLLocation(latitude: annotation.coordinates.latitude, longitude: annotation.coordinates.longitude)
```

When the location object is an  object, the sample uses `init(mapItem:)` to create the structured location:
```
When the location object is an  object, the sample uses `init(mapItem:)` to create the structured location:
```swift
let structuredLocation = EKStructuredLocation(mapItem: mapItem)
```

```
EventKit defines the structured location’s  property in meters. When someone enters a value for the radius, the app checks the person’s preferences for unit of length measurement. If the person’s preferred unit of length is a unit other than meters, the sample converts the radius value to meters, then assigns the converted value to the structured location’s `radius` property:
```swift
// Get the person's preferred unit of length measurement.
let preferredUnit = UnitLength(forLocale: .current, usage: .asProvided)
structuredLocation.radius = (preferredUnit == .meters) ? entry.radius : entry.radius.convert(from: preferredUnit, to: .meters)
```

```
Next, the sample creates an  object, then sets its  property to the created structured location object. The sample then sets the  property to a value to finish configuring the alarm’s geofence:
```swift
let alarm = EKAlarm(relativeOffset: 0)
alarm.structuredLocation = structuredLocation
alarm.proximity = entry.proximity
```

```
The app adds the created alarm to the reminder. For more information on adding alarms, see .
```swift
reminder.addAlarm(alarm)
```

```
Finally, it saves the reminder to the person’s Calendar database:
```swift
try eventStore.save(reminder, commit: true)
```

#### 
The  method asynchronously fetches all reminders matching a given predicate. The app calls this method with  to fetch complete and incomplete reminders. The predicate takes `nil` or an array of  objects in its `calendars` parameters. Pass `nil` to fetch from all of the person’s calendars, and an array to fetch reminders from a subset of the person’s calendars. The app passes `nil` to `predicateForReminders(in:)`:
```swift
let predicate = eventStore.predicateForReminders(in: nil)
```

```
Then, the app executes the fetch request. If the request succeeds, `fetchReminders(matching:completion:)` returns an array that contains both time-based and location-based reminders:
```swift
return await withCheckedContinuation { continuation in
    eventStore.fetchReminders(matching: predicate) { reminders in
        var result: [LocationReminder] = []
        
        if let reminders {
            result = reminders
                .filter(\.isLocation)
                .map { LocationReminder(reminder: $0) }
        }
        continuation.resume(returning: result)
    }
}
```

```
To retrieve location-based reminders, the app parses the returned array for reminders defined with an existing alarm that has a `structuredlocation` and `proximity` value:
```swift
/// Specifies whether the reminder is location-based.
var isLocation: Bool {
    guard let alarms else { return false }
    
    let proximityAlarms = alarms.filter {
        $0.structuredLocation != nil && ($0.proximity == .enter || $0.proximity == .leave)
    }
    
    return !proximityAlarms.isEmpty
}
```

#### 
After fetching the location-based reminders, the app displays a segmented control that organizes the fetched reminders by priority: None, Low, Medium, and High. Fetching reminders from the Calendar database returns reminders sorted by creation date. The app offers a menu that lets people choose how to sort the reminders by creation date, due date, or title in ascending order. When someone selects a priority in the control, the sample inspects the fetch result. If the result contains location reminders with the priority the person selected, the app uses the person’s sorting preferences to sort the reminders, then it displays them. The sample uses key paths to sort the fetched location-based reminders.
```swift
/// Sorts reminders by creation date, due date, or title in ascending order.
func reminders(sortedBy sort: ReminderSortValue) -> [LocationReminder] {
    switch sort {
    case .creationDate: return self.sorted(by: \.creationDate)
    case .dueDate: return self.sorted(by: \.dueDate)
    case .title: return self.sorted(by: \.title)
    }
}
```


## Retrieving events and reminders
> https://developer.apple.com/documentation/eventkit/retrieving-events-and-reminders

### 
#### 
> **note:**  Although the  method accepts a parameter of type , you must supply a predicate created with the  method .
```swift
// Get the appropriate calendar.
let calendar = Calendar.current

// Create the start date components
var oneDayAgoComponents = DateComponents()
oneDayAgoComponents.day = -1
let oneDayAgo = calendar.date(byAdding: oneDayAgoComponents, to: Date(), wrappingComponents: false)

// Create the end date components.
var oneYearFromNowComponents = DateComponents()
oneYearFromNowComponents.year = 1
let oneYearFromNow = calendar.date(byAdding: oneYearFromNowComponents, to: Date(), wrappingComponents: false)

// Create the predicate from the event store's instance method.
var predicate: NSPredicate? = nil
if let anAgo = oneDayAgo, let aNow = oneYearFromNow {
    predicate = store.predicateForEvents(withStart: anAgo, end: aNow, calendars: nil)
}

// Fetch all events that match the predicate.
var events: [EKEvent]? = nil
if let aPredicate = predicate {
    events = store.events(matching: aPredicate) 
}
```

-  finds all reminders.
You can iterate across matched reminders by passing a block to the completion argument, as shown in the code below.
```swift
var predicate: NSPredicate? = store.predicateForReminders(in: nil)
if let aPredicate = predicate {
    store.fetchReminders(matching: aPredicate, completion: {(_ reminders: [Any]?) -> Void in
        for reminder: EKReminder? in reminders as? [EKReminder?] ?? [EKReminder?]() {
            // Do something for each reminder.
        }
    })
}
```

#### 

## Updating with notifications
> https://developer.apple.com/documentation/eventkit/updating-with-notifications

### 
#### 
An  object posts an  notification whenever it detects changes to the Calendar database. Register for this notification if your app handles event or reminder data.
The code listing below registers for the  notification.
```swift
NotificationCenter.default.addObserver(self, selector: Selector("storeChanged:"), name: .EKEventStoreChanged, object: eventStore)
```

#### 

