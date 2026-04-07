# Apple WIDGETKIT Skill


## Adding interactivity to widgets and Live Activities
> https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities

### 
#### 
#### 
#### 
#### 
4. In the protocol’s required  function, add code for the action you want to make available to the widget.
For example, the  sample code project includes a button in its large widget that people click or touch to give the hero a healing boost. The following code snippet shows its app intent implementation:
```swift
struct SuperCharge: AppIntent {
    
    static var title: LocalizedStringResource = "Emoji Ranger SuperCharger"
    static var description = IntentDescription("All heroes get instant 100% health.")
    
    func perform() async throws -> some IntentResult {
        EmojiRanger.superchargeHeros()
        return .result()
    }
}
```

#### 
#### 
The following example shows how the large  widget includes a button to give the heroes a healing boost. Note how the sample checks for the presence of iOS 17 before adding the button.
```swift

struct EmojiRangerWidgetEntryView: View {
    var entry: SimpleEntry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {

        case .systemLarge:
            VStack {
                HStack(alignment: .top) {
                    AvatarView(entry.hero)
                        .foregroundStyle(.white)
                    Text(entry.hero.bio)
                        .foregroundStyle(.white)
                }
                .padding()
                if #available(iOS 17.0, *) {
                    HStack(alignment: .top) {
                        Button(intent: SuperCharge()) {
                            Image(systemName: "bolt.fill")
                        }
                    }
                    .tint(.white)
                    .padding()
                }
            }
            .containerBackground(for: .widget) {
                Color.gameBackgroundColor
            }
            .widgetURL(entry.hero.url)
            
        // Code for other widget sizes.
    }
}   
```

#### 
Add a  to your view using one of the initializers that take an app intent, for example, .
The following example shows how a view of a task manager widget could add a toggle. Note that the initializer’s `isOn` parameter receives a Boolean value instead of a `Binding<Bool>` value.
```swift
struct TodoItemView: View {
    var todo: Todo

    var body: some View {
        Toggle(isOn: todo.complete, intent: ToggleTodoIntent(todo.id)) {
            Text(todo.body)
        }
        .toggleStyle(TodoToggleStyle())
    }
}
```

#### 

## Adding refinements and configuration to controls
> https://developer.apple.com/documentation/widgetkit/adding-refinements-and-configuration-to-controls

### 
#### 
The control’s configuration view displays a localizable description for a control. Add a description, using the  modifier, to give additional information about what the control does.
The following code adds a name and description to the control that gives people more insight about what it does:
```swift
struct TimerToggle: ControlWidget {
	static let kind: String = "com.example.MyApp.TimerToggle"

	var body: some ControlWidgetConfiguration {
		StaticControlConfiguration(
			...
		) {
			ControlWidgetToggle(
				...
			)
		}
		.displayName("Productivity Timer")
		.description("Start and stop a productivity timer.")
	}
}
```

#### 
Controls can require a device to be authenticated to allow the control to perform its action or to display its current state and information. Set the `authenticationPolicy` in the control’s app intent to refine what level of authentication is necessary to perform the action.
The following code sets the  to  to require device authentication to unlock a door:
```swift
struct UnlockDoor: AppIntent {
	static let title: LocalizedStringResource = "Unlock the door"
	static let authenticationPolicy = .requiresAuthentication
	...
}
```

Use the  modifier on a  type to redact the active or inactive state of a control while the device isn’t authenticated.
The following code adds the `privacySensitive()` modifier to a control toggle. The modifier redacts the state and information in the control that displays whether a door is open or closed:
```swift
struct DoorOpener: ControlWidget {
	var body: some ControlWidgetConfiguration {
		StaticControlConfiguration(...) {
			ControlWidgetToggle(...) {
				Label(
					isOpen ? "Open" : "Closed",
					systemImage: isOpen ? "door.open" : "door.closed"
				)
			}
			.privacySensitive()
		}
	}
}
```

#### 
The Action button gives quick and easy access to controls and system functionality. Provide hint text to people to help give context to the action the control performs. The text set with the `displayName` modifier on the  or  provides text to the system to display a hint. The default hint text is different for buttons, toggles, and buttons that have an  action to launch an app.
The following code shows the default hint text for a button:
```swift
// Hint Text: "Hold for 'Perform Action'"
struct PerformActionButton: ControlWidget {
	var body: some ControlWidgetConfiguration {
		StaticControlConfiguration(...) {
			...
		}
		.displayName("Perform Action")
	}
}
```

The following code shows the default hint text for a button with an `OpenIntent` action:
```
The following code shows the default hint text for a button with an `OpenIntent` action:
```swift
// Hint Text: "Hold to Open MyApp"
struct MyAppLauncher: ControlWidget {
	var body: some ControlWidgetConfiguration {
		StaticControlConfiguration(...) {
			ControlWidgetButton(
				action: OpenMyAppIntent(),
				...
			)
		}
		.displayName("MyApp")    
	}
}
```

```
Hint text for a toggle prepends with “Hold to Turn On…” and “Hold to Turn Off…” The following code shows the default hint text for a toggle:
```swift
// Hint Text: "Hold to Turn On 'Lightswitch'" / "Hold to Turn Off 'Lightswitch'"
struct LightswitchToggle: ControlWidget {
	var body: some ControlWidgetConfiguration {
		StaticControlConfiguration(...) {
			...
		}
		.displayName("Lightswitch")
	}
}
```

Use  and the  modifier in your control content to create fully custom hint text. Begin the  `controlWidgetActionHint` with a verb, similar to .
Use  and the  modifier in your control content to create fully custom hint text. Begin the  `controlWidgetActionHint` with a verb, similar to .
When you customize hint text for button controls, the hint text prepends with “Hold to…” The following code shows custom hint text for a button:
```swift
// Hint Text: "Hold to Perform the Action"
ControlWidgetButton(...) {
	Label("Perform Action", systemName: "checkmark.circle")
		.controlWidgetActionHint("Perform the Action")
}
```

```
The following code shows custom hint text for a button with an `OpenIntent` action. The hint text is the same as a button, but when executed, this action launches the app:
```swift
// Hint Text: "Hold to Perform the Action"
ControlWidgetButton(...) {
	Image(systemName: "checkmark.circle")
		.controlWidgetActionHint("Perform the Action")
}
```

Customize toggles using custom value text or a custom action hint. Custom hint text using custom value text prepends with “Hold for…” Custom hint text using a custom action hint prepends with “Hold to…”
The following code shows custom hint text for a toggle using custom value text:
```swift
// Hint Text: "Hold for Lights On" / "Hold for Lights Off"
ControlWidgetToggle(...) { isOn in
	Label(
		isOn ? "Lights On" : "Lights Off",
		systemImage: isOn ? "lightbulb.max" : "lightbulb"
	)
}
```

The following code uses the `controlWidgetActionHint` modifier to display custom hint text:
```
The following code uses the `controlWidgetActionHint` modifier to display custom hint text:
```swift
// Hint Text: "Hold to Turn on Lights" / "Hold to Turn off Lights"
ControlWidgetToggle(...) { isOn in
	Label(
		isOn ? "On" : "Off",
		systemImage: isOn ? "lightbulb.max" : "lightbulb"
	)
	.controlWidgetActionHint(isOn ? "Turn on Lights" : "Turn off Lights")
}
```

> **note:** `controlWidgetActionHint` takes precedence over custom value text `Label` provides.
#### 
#### 
To make a control configurable, use an  and conform your value provider to . This step tells the system you provide the ability for someone to configure the control when they long press the control, in edit mode, in Control Center, on the Lock Screen, and when they configure the control for the Action button.
The following code creates a control toggle that starts and stops a timer. Someone can configure the control and select their desired type of timer. The control uses `AppIntentControlConfiguration` and sets the name of the control to the name of the configured timer. `ToggleTimerIntent` acts on the selected timer. The control has a provider that uses `AppIntentControlValueProvider` and has a custom app intent, `SelectTimerIntent`, that provides the type of timer choices:
```swift
struct TimerToggle: ControlWidget {
	static let kind: String = "com.example.MyApp.TimerToggle"

	var body: some ControlWidgetConfiguration {
		AppIntentControlConfiguration(
			kind: Self.kind,
			provider: ConfigurableProvider()
		) { timerState in
			ControlWidgetToggle(
				timerState.timer.name,
				isOn: timerState.isRunning,
				action: ToggleTimerIntent(timer: timerState.timer),
				valueLabel: { isOn in
					Label(isOn ? "Running" : "Stopped", systemImage: "timer")
				}
			)
		}
		.displayName("Productivity Timer")
		.description("Start and stop a productivity timer.")
	}
}

extension TimerToggle {
	struct ConfigurableProvider: AppIntentControlValueProvider {
		func previewValue(configuration: SelectTimerIntent) -> TimerState {
			return TimerState(timer: configuration.timer, isRunning: false)
		}

		func currentValue(configuration: SelectTimerIntent) async throws -> TimerState {
			let timer = configuration.timer
			let isRunning = try await TimerManager.shared.fetchTimerRunning(timer: timer)
			
			return TimerState(timer: timer, isRunning: isRunning)
		}
	}
}

struct ToggleTimerIntent: SetValueIntent {
    
    static var title: LocalizedStringResource = "Start and stop timer"
    
    init() {}
    
    init(timer: Timer) {
        self.timer = timer
    }
    
    @Parameter(title: “Timer”)
    var timer: Timer
    
    @Parameter(title: “Timer is running”)
    var value: Bool
    
    func perform() async throws -> some IntentResult {
        // ...
        // Code to toggle between starting and stopping the timer.
        return .result()
    }
}
```

The following code uses the  modifier on the `AppIntentControlConfiguration` to prompt someone to configure the control when they choose it:
A control that requires configuration to be functional can use the `promptsForUserConfiguration` modifier to have the system automatically prompt someone for configuration when they add it to Control Center or the Lock Screen, or configure it for the Action button.
The following code uses the  modifier on the `AppIntentControlConfiguration` to prompt someone to configure the control when they choose it:
```swift
struct TimerToggle: ControlWidget {
	static let kind: String = "com.example.MyApp.TimerToggle"

	var body: some ControlWidgetConfiguration {
		AppIntentControlConfiguration(
			...
		) { timerState in
			ControlWidgetToggle(
				...
			)
		}
		.promptsForUserConfiguration()
	}
}
```


## Animating data updates in widgets and Live Activities
> https://developer.apple.com/documentation/widgetkit/animating-data-updates-in-widgets-and-live-activities

### 
#### 
In addition to the default transitions and animations that the system performs when views update their data, you can choose other built-in SwiftUI transitions and animations. Widgets and Live Activities support all built-in SwiftUI transitions and animations. For example, you could configure a content transition for numeric text as shown in this example:
```swift
Text(totalCaffeine.formatCaffeine())
    .font(.title)
    .minimumScaleFactor (0.8)
    .contentTransition(.numericText())
```

```
Additionally, you could add a spring animation to the transition:
```swift
Text (totalCaffeine.formatCaffeine())
    .font(.title)
    .minimumScaleFactor (0.8)
    .contentTransition(.numericText())
    .animation(.spring(duration: 0.2), value: totalCaffeine)
```

```
To use custom text animations, use  as shown in the example above. To use the default text animation, use , and customize its speed and delay as shown in the following example:
```swift
Text("Some text with \(entry.value) that changes.")
    .animation(.default.speed(0.25).delay(0.5), value: entry.value)
```

#### 
The following example shows how the `LastDrinkView` adds a push transition when the associated `log` changes.
In addition to adding transitions or animations to a view that changes its data, you can animate a view when other widget information changes. To animate a view when a certain value changes, first associate the view you want to animate with that value’s data model object. This is easiest when your data model conforms to the  protocol. If your data model doesn’t conform to `Hashable`, change its code accordingly. Then, associate the view with the data model using the  view modifier. Finally, add a transition or animation.
The following example shows how the `LastDrinkView` adds a push transition when the associated `log` changes.
```swift
struct LastDrinkView: View {
    let log: CaffeineLog
    var dateFormatStyle: Date.FormatStyle {
        Date.FormatStyle(date: .omitted, time: .shortened)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(log.drink.name)
                .bold()
            Text ("\(log.date, format: .dateFormatStyle) • \(log.drink.caffeine.formatCaffeine())")
        }
        .font (.caption)
        .id(log) // Associate the view with the data model.
        .transition(.push(from: .bottom))
    }
}
```

#### 

## Creating a widget extension
> https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension

### 
#### 
#### 
To configure a static widget, provide the following information:
Use modifiers to provide additional configuration details, including a display name, a description, and the families the widget supports. The following code shows a widget that provides general status for a game:
```swift
@main
struct GameStatusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "com.mygame.game-status",
            provider: GameStatusProvider(),
        ) { entry in
            GameStatusView(entry.gameStatus)
        }
        .configurationDisplayName("Game Status")
        .description("Shows an overview of your game status")
        .supportedFamilies([.systemSmall])
    }
}
```

#### 
The timeline provider you define generates a sequence of timeline entries. Each specifies the date and time to update the widget’s content, and includes the data your widget needs to render its view. The game-status widget might define its timeline entry to include a string that represents the status of the game, as follows:
```swift
struct GameStatusEntry: TimelineEntry {
    var date: Date
    var gameStatus: String
}
```

The following example shows how the game-status widget’s provider generates a timeline that consists of a single entry with the current game status from the server, and a reload policy to request a new timeline in 15 minutes:
```swift
struct GameStatusProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<GameStatusEntry>) -> Void) {
        // Create a timeline entry for "now."
        let date = Date()
        let entry = GameStatusEntry(
            date: date,
            gameStatus: gameStatusFromServer
        )

        // Create a date that's 15 minutes in the future.
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!

        // Create the timeline with the entry and a reload policy with the date
        // for the next update.
        let timeline = Timeline(
            entries:[entry],
            policy: .after(nextUpdateDate)
        )

        // Call the completion to pass the timeline to WidgetKit.
        completion(timeline)
    }
}
```

#### 
In response, you need to create the preview snapshot quickly. If your widget would normally need assets or information that takes time to generate or fetch from a server, use sample data instead.
In the following code, the game-status widget’s provider implements the snapshot method by showing the game status if it’s available, falling back to an empty status if it doesn’t have the status from its server:
```swift
struct GameStatusProvider: TimelineProvider {
    var hasFetchedGameStatus: Bool
    var gameStatusFromServer: String

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let date = Date()
        let entry: GameStatusEntry

        if context.isPreview && !hasFetchedGameStatus {
            entry = GameStatusEntry(date: date, gameStatus: "—")
        } else {
            entry = GameStatusEntry(date: date, gameStatus: gameStatusFromServer)
        }
        completion(entry)
    }
```

#### 
When people add your widget from the widget gallery, they choose the specific family — for example, small or medium — from the ones your widget supports. The widget’s content closure has to be capable of rendering each family the widget supports. WidgetKit sets the corresponding family and additional properties, such as the color scheme (light or dark), in the SwiftUI environment.
In the game-status widget’s configuration shown above, the content closure uses a `GameStatusView` to display the status. Because this widget only supports the `.systemSmall` family, it uses a composed `GameTurnSummary` SwiftUI view to display a summary of the game’s current status. For any other family size, it shows the default view, which indicates that game status is unavailable.
```swift
struct GameStatusView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var gameStatus: GameStatus
    var selectedCharacter: CharacterDetail

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall: GameTurnSummary(gameStatus)
        default: GameDetailsNotAvailable()
        }
    }
}
```

> **note:** The view declares its body with `@ViewBuilder` because the type of view it uses varies.
#### 
#### 
If you choose the `NSFileProtectionCompleteUntilFirstUserAuthentication` or `NSFileProtectionNone` protection level for your widget extension:
#### 
#### 
#### 
Xcode allows you to look at previews of your widgets without running your app in Simulator or on a test device. The following example shows the preview code from the Emoji Rangers widget of the  sample code project.
```swift
#Preview(as: .systemMedium, widget: {
    EmojiRangerWidget()
}, timeline: {
    SimpleEntry(date: Date(), relevance: nil, hero: .spouty)
})
```

#### 
#### 

## Creating controls to perform actions across the system
> https://developer.apple.com/documentation/widgetkit/creating-controls-to-perform-actions-across-the-system

### 
#### 
#### 
The widget extension template provides an initial implementation of a `ControlWidgetToggle`, a  type that starts and stops a timer. The body property determines if a control is static or configurable. Controls use a  for the body property by default. Provide people with the ability to configure a control by using .
The following code creates a nonconfigurable control toggle that starts and stops a timer. The `kind` is the control’s unique identifier and the action of the `ControlWidgetToggle` executes the app intent specified:
```swift
struct TimerToggle: ControlWidget {
	static let kind: String = "com.example.MyApp.TimerToggle"

	var body: some ControlWidgetConfiguration {
		StaticControlConfiguration(
			kind: Self.kind,
			provider: Provider()
		) { value in
			ControlWidgetToggle(
				"Productivity Timer",
				isOn: value,
				action: ToggleTimerIntent(),
				valueLabel: { isOn in
					Label(isOn ? "Running" : "Stopped", systemImage: "timer")
				}
			)
		}
		.displayName("Productivity Timer")
		.description("Start and stop a productivity timer.")
	}
}

extension TimerToggle {
	struct Provider: ControlValueProvider {
		var previewValue: Bool {
			false
		}

		func currentValue() async throws -> Bool {
			let isRunning = true // Check if the timer is running
			return isRunning
		}
	}
}

struct ToggleTimerIntent: SetValueIntent {
	static var title: LocalizedStringResource = "Productivity Timer"

	@Parameter(title: "Timer is running")
	var value: Bool

	func perform() async throws -> some IntentResult {
		// Start / stop the timer based on `value`.
		return .result()
	}
}
```

#### 
A control button performs an action from your app. For example, the button can launch a locked camera capture extension, start a live activity, or take someone to a specific area of your app.
The following code creates a nonconfigurable  that uses an app intent to perform an action:
```swift
struct PerformActionButton: ControlWidget {
	var body: some ControlWidgetConfiguration {
		StaticControlConfiguration(
			kind: "com.example.myApp.performActionButton"
		) {
			ControlWidgetButton(action: PerformAction()) {
                Label("Perform Action", systemImage: "checkmark.circle")
			}
		}
		.displayName("Perform Action")
		.description("An example control that performs an action.")
	}
}

struct PerformAction: AppIntent {
	static let title: LocalizedStringResource = "Perform action"

	func perform() async throws -> some IntentResult {
		// Code that performs the action...
		return .result()
	}
}
```

#### 
The following code uses an app intent to launch the app to a specific screen when a `ControlWidgetButton` performs its action:
The system requires the Target Membership of the app intent to be set to both the app and the widget extension to open the app.
The following code uses an app intent to launch the app to a specific screen when a `ControlWidgetButton` performs its action:
```swift
import AppIntents

struct LaunchAppIntent: OpenIntent {
    static var title: LocalizedStringResource = "Launch App"
    @Parameter(title: "Target")
    var target: LaunchAppEnum
}

enum LaunchAppEnum: String, AppEnum {
    case timer
    case history

    static var typeDisplayRepresentation = TypeDisplayRepresentation("Productivity Timer's app screens")
    static var caseDisplayRepresentations = [
        LaunchAppEnum.timer : DisplayRepresentation("Timer"),
        LaunchAppEnum.history : DisplayRepresentation("History")
    ]
}
```

#### 
The  in the Widget extension provides controls and widgets to the system from your app. List all controls and widgets inside the `WidgetBundle`. The order of controls and widgets in the `WidgetBundle` defines their order in the controls gallery and the widgets gallery.
```swift
@main
struct MyControlsAndWidgetsBundle: WidgetBundle {
	var body: some Widget {
		PerformActionButton()
		MyAppWidget()
		MyAppControlToggle()
	}
}
```


## Displaying dynamic dates in widgets
> https://developer.apple.com/documentation/widgetkit/displaying-dynamic-dates

### 
Using a  view in your widget, you can display dates and times that stay up to date onscreen. The following examples show the combinations available.
To display a relative time that updates automatically:
```swift
let components = DateComponents(minute: 11, second: 14)
let futureDate = Calendar.current.date(byAdding: components, to: Date())!

Text(futureDate, style: .relative)
// Displays:
// 11 min, 14 sec

Text(futureDate, style: .offset)
// Displays:
// -11 minutes
```

Using the  style shows the absolute difference between the current date and time and the date specified, regardless of whether the date is in the future or the past. The  style shows the difference between the current date and time and the date specified, indicating dates in the future with a minus sign (`-`) prefix and dates in the past with a plus sign (`+`) prefix.
To display a timer that continues updating automatically:
```swift
let components = DateComponents(minute: 15)
let futureDate = Calendar.current.date(byAdding: components, to: Date())!

Text(futureDate, style: .timer)
// Displays:
// 15:00
```

For dates in the future, the  style counts down until the current time reaches the specified date and time, and counts up when the date passes.
To display an absolute date or time:
```swift
// Absolute Date or Time
let components = DateComponents(year: 2020, month: 4, day: 1, hour: 9, minute: 41)
let aprilFirstDate = Calendar.current(components)!

Text(aprilFirstDate, style: .date)
Text("Date: \(aprilFirstDate, style: .date)")
Text("Time: \(aprilFirstDate, style: .time)")

// Displays:
// April 1, 2020
// Date: April 1, 2020
// Time: 9:41AM
```

```
And finally, to display a time interval between two dates:
```swift
let startComponents = DateComponents(hour: 9, minute: 30)
let startDate = Calendar.current.date(from: startComponents)!

let endComponents = DateComponents(hour: 14, minute: 45)
let endDate = Calendar.current.date(from: endComponents)!

Text(startDate ... endDate)
Text("The meeting will take place: \(startDate ... endDate)")

// Displays:
// 9:30AM-2:45PM
// The meeting will take place: 9:30AM-2:45PM
```


## Displaying the right widget background
> https://developer.apple.com/documentation/widgetkit/displaying-the-right-widget-background

### 
2. Move code that declares any background color or views inside the `containerBackground(for:)` view modifier and pass  to it. This makes sure WidgetKit automatically removes the background as needed.
The following code snippet from the  sample code project defines a `gameBackground` color for the widget’s container background to make sure WidgetKit renders it with or without the background color as applicable.
```swift
var body: some View {
    switch family {
    // Logic for additional widget sizes.
    case .accessoryRectangular:
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading) {
                Text(entry.hero.name)
                    .font(.headline)
                    .widgetAccentable()
                Text("Level \(entry.hero.level)")
                Text(entry.hero.fullHealthDate, style: .timer)
            }.frame(maxWidth: .infinity, alignment: .leading)
            Avatar(hero: entry.hero, includeBackground: false)
        }
        .containerBackground(for: .widget) {
            Color.gameBackground
        }
		// Logic for additional widget sizes.
}
```

#### 
#### 
Depending on your accessory widget or complication, you may need to set a consistent background for your accessory widget. Use  to draw a consistent background for your widget, as shown in the following example. It creates a view that’s similar to the circular Lock Screen widget that the Calendar app offers:
```swift
ZStack {
     AccessoryWidgetBackground()
     VStack {
        Text(“MON”)
        Text(“6”)
         .font(.title)
    }
}
```


## Increasing the visibility of widgets in Smart Stacks
> https://developer.apple.com/documentation/widgetkit/widget-suggestions-in-smart-stacks

### 
#### 
#### 
On iPhone and iPad, one of the different clues on-device intelligence uses to determine the widget’s position in the Smart Stack is the  property of the entries your  or  generates. The property’s  type contains a  and a . The score is a value you choose that indicates the relevance of the widget, relative to entries across timelines that the provider creates. When the date of an entry arrives, and for the duration you specify, WidgetKit may rotate your widget to the top of the Smart Stack, making it visible.
For example, the  sample code project sets an increased relevance if a configured hero hasn’t recovered its full health:
```swift
    func timeline(for configuration: EmojiRangerSelection, in context: Context) async -> Timeline<SimpleEntry> {
        let selectedCharacter = hero(for: configuration)
        let endDate = selectedCharacter.fullHealthDate
        let oneMinute: TimeInterval = 60
        var currentDate = Date()
        var entries: [SimpleEntry] = []
        
        while currentDate < endDate {
            let relevance = TimelineEntryRelevance(score: Float(selectedCharacter.healthLevel))
            let entry = SimpleEntry(date: currentDate, relevance: relevance, hero: selectedCharacter)
            currentDate += oneMinute
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
```

A score of zero (`0`) or lower indicates that a widget isn’t relevant, and WidgetKit won’t consider rotating it to the top of the stack.
#### 
#### 
#### 
2. Return the relevant intents in the  `relevance()` callback of your widget’s  or   implementation.
4. Call  to update relevance information every time it changes for your app; for example, when you receive updated data.
The following example shows how a gaming app might allow people to track the health of their hero and provide contextual clues to the system:
```swift
import SwiftUI
import WidgetKit
import AppIntents

struct AppIntentProvider: AppIntentTimelineProvider {
    
    typealias Entry = SimpleEntry
    
    typealias Intent = EmojiRangerSelection
    
    func placeholder(in context: Context) -> SimpleEntry {
        // Code that returns a placeholder entry.
    }
    
    func snapshot(for configuration: EmojiRangerSelection, in context: Context) async -> SimpleEntry {
        // Code that returns a snapshot entry.
    }
    
    func timeline(for configuration: EmojiRangerSelection, in context: Context) async -> Timeline<SimpleEntry> {
        // Code that creates timeline entries.
        // ...
        
        // Update relevant intents with each timeline refresh.
        await updateRangerRelevantIntents()
        
        // Code that returns a timeline.
    }
    
    func recommendations() -> [AppIntentRecommendation<EmojiRangerSelection>] {
        [] // Returns an empty array that makes the widget configurable.       
    }
    
    // Provide contextual clues that inform the system about contexts in which
    // your widget is especially important to a person. 
    func relevance() async -> WidgetRelevance<Self.Intent> {
        let relevances = EmojiRanger.allHeros.map { hero in
            let rangerIntent = EmojiRangerSelection()
            rangerIntent.hero = hero
            let relevantRangerContext = RelevantContext.date(from: hero.injuryDate, to: hero.fullHealthDate)
            return WidgetRelevanceAttribute(configuration: rangerIntent, context: relevantRangerContext)
        }
        return WidgetRelevance(relevances)
    }
    
    // A function that updates your relevant intents.
    func updateRangerRelevantIntents() async {
        var relevantIntents: [RelevantIntent] = []
        
        // Create relevant intents.
        // The code below is intentionally simple to make it easy to understand.
        for hero in EmojiRanger.allHeros {
            let configuredRangerIntent = EmojiRangerSelection()
            configuredRangerIntent.hero = hero
            let relevantRangerContext = RelevantContext.date(from: hero.injuryDate, to: hero.fullHealthDate)
        
            let relevantIntent = RelevantIntent(
                configuredRangerIntent,
                widgetKind: EmojiRanger.EmojiRangerWidgetKind,
                relevance: relevantRangerContext
            )
            relevantIntents.append(relevantIntent)
        }

        do {
            try await RelevantIntentManager.shared.updateRelevantIntents(relevantIntents)
        } catch {
            // Handle error cases.
        }
    }
}
```

#### 
3. Make sure you return each . If you don’t provide entries, the widget won’t appear in the Smart Stack.
The following code snippet shows how a gaming app that allows people to track the health level of their heroes initializes a watchOS widget with a `RelevanceConfiguration` and provides relevance information with a `RelevanceEntriesProvider`:
```swift
// Create the widget with a relevance configuration.
@available(watchOS 12, *)
struct EmojiRangerWidget: Widget {    
    var body: some WidgetConfiguration {
        RelevanceConfiguration(
            kind: EmojiRanger.EmojiRangerWidgetKind,
            provider: EmojiRangerRelevanceProvider()
        ) { entry in
            EmojiRangerWidgetView(entry: entry)
        }
        .configurationDisplayName("Emoji Ranger")
        .description("Healing status")
    }
}

// Implement the relevance provider and its requirements.
@available(watchOS 12, *)
struct EmojiRangerRelevanceProvider: RelevanceEntriesProvider {
    // Provide all contextual clues.
    func relevance() async -> WidgetRelevance<EmojiRangerConfigurationIntent> {
        let healingUpdates = ... // Code to retrieve healing update information
        let attributes = healingUpdates.map { update in
            // Create relevant contexts objects.
            let context = RelevantContext.date(
                interval: update.date,
                kind: .scheduled
            )
            WidgetRelevanceAttribute(
                configuration: EmojiRangerConfigurationIntent(update: update),
                context: context
            )
        }
        return WidgetRelevance(attributes)
    }

    // Provide all data entries for the widget.
    func entry(
        configuration: Configuration,
        context: Context
    ) async throws -> EmojiRangersRelevanceEntry {
        if context.isPreview {
            return EmojiRangersRelevanceEntry.previewEntry
        }
        return EmojiRangersRelevanceEntry(
            hero: configuration.update?.hero,
            update: configuration.update
        )
    }

    func placeholder(context: Context) -> EmojiRangersRelevanceEntry {
        EmojiRangersRelevanceEntry.placeholderEntry
    }
}
```

#### 
#### 

## Keeping a widget up to date
> https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date

### 
#### 
#### 
#### 
Your app can tell WidgetKit to request a new timeline when something affects a widget’s current timeline. In the game widget example above, if the app receives a push notification indicating a teammate has given the character a healing potion, the app can tell WidgetKit to reload the timeline and update the widget’s content. To reload a specific type of widget, your app uses , as shown here:
```swift
WidgetCenter.shared.reloadTimelines(ofKind: "com.mygame.character-detail")
```

The `kind` parameter contains the same string as the value used to create the widget’s .
If your widgets have user-configurable properties, avoid unnecessary reloads by using WidgetCenter to verify that a widget with the appropriate settings exists. For example, when the game receives a push notification about a character receiving a healing potion, it verifies that a widget is showing that character before reloading the timeline.
In the following code, the app calls  to retrieve the list of user-configured widgets. It then iterates through the resulting  objects to find one with an `intent` configured with the character that received the healing potion. If it finds one, the app calls  for that widget’s `kind`.
```swift
WidgetCenter.shared.getCurrentConfigurations { result in
    guard case .success(let widgets) = result else { return }

    // Iterate over the WidgetInfo elements to find one that matches
    // the character from the push notification.
    if let widget = widgets.first(
        where: { widget in
            let intent = widget.configuration as? SelectCharacterIntent
            return intent?.character == characterThatReceivedHealingPotion
        }
    ) {
        WidgetCenter.shared.reloadTimelines(ofKind: widget.kind)
    }
}
```

```
If your app uses  to support multiple widgets, you can use `WidgetCenter` to reload the timelines for all your widgets. For example, if your widgets require the user to sign in to an account but they have signed out, you can reload all the widgets by calling:
```swift
WidgetCenter.shared.reloadAllTimelines()
```

#### 
#### 
#### 

## Linking to specific app scenes from your widget or Live Activity
> https://developer.apple.com/documentation/widgetkit/linking-to-specific-app-scenes-from-your-widget-or-live-activity

### 
#### 
> **important:** If the view hierarchy includes more than one `widgetURL` modifier, the behavior is undefined.
For example, the following code snippet from the  sample code project shows how the small widget uses `widgetURL(_:)` to allow people to open the app and show a character’s detail information:
```swift
struct EmojiRangerWidgetEntryView: View {
    var entry: SimpleEntry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            AvatarView(entry.hero)
                .foregroundStyle(.white)
                .widgetBackground()
                .widgetURL(entry.hero.url)

        // Code for other widget sizes.
    }
}
```

#### 
#### 

## Making a configurable widget
> https://developer.apple.com/documentation/widgetkit/making-a-configurable-widget

### 
#### 
To show the character’s information, the person needs a way to select the character. The following code shows how to define a custom app intent to represent the choice the person makes:
```swift
struct SelectCharacterIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Character"
    static var description = IntentDescription("Selects the character to display information for.")

    @Parameter(title: "Character")
    var character: CharacterDetail

    init(character: CharacterDetail) {
        self.character = character
    }

    init() {
    }
}
```

In the example above, the parameter uses a custom `CharacterDetail` type the app defines to represent a character in the game. To use a custom type as an app intent parameter, it must conform to . To implement the `CharacterDetail` parameter type, the game-status widget uses a structure that exists in the game’s project. This structure defines a list of available characters and their details, as follows:
```swift
struct CharacterDetail: AppEntity {
    let id: String
    let avatar: String
    let healthLevel: Double
    let heroType: String
    let isAvailable = true
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Character"
    static var defaultQuery = CharacterQuery()
            
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(avatar) \(id)")
    }

    static let allCharacters: [CharacterDetail] = [
        CharacterDetail(id: "Power Panda", avatar: "🐼", healthLevel: 0.14, heroType: "Forest Dweller"),
        CharacterDetail(id: "Unipony", avatar: "🦄", healthLevel: 0.67, heroType: "Free Rangers"),
        CharacterDetail(id: "Spouty", avatar: "🐳", healthLevel: 0.83, heroType: "Deep Sea Goer")
    ]
}
```

Because characters might vary from game to game, the intent generates the list dynamically at runtime. WidgetKit uses the app entity’s `defaultQuery` property to access the dynamic values, as described below.
If your widget includes nonoptional parameters, you must supply a default value. For types such as `String`, `Int`, or enumerations that use `AppEnum`, one option is to supply a default value as follows:
```swift
@Parameter(title: "Title", default: "A Default Title")
var title: String
```

A second option is to use a query type that implements `defaultResult()`, as shown in the next section.
#### 
- Mapping `AppEntity` identifiers to the corresponding entity instances.
In the entity query, the result is an array of all the `CharacterDetail` types available.
When a person edits a widget with a custom intent that provides dynamic values, the system invokes the query object’s  method to get the list of possible choices.
In the entity query, the result is an array of all the `CharacterDetail` types available.
```swift
struct CharacterQuery: EntityQuery {
    func entities(for identifiers: [CharacterDetail.ID]) async throws -> [CharacterDetail] {
        CharacterDetail.allCharacters.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [CharacterDetail] {
        CharacterDetail.allCharacters.filter { $0.isAvailable }
    }
    
    func defaultResult() async -> CharacterDetail? {
        try? await suggestedEntities().first
    }
}
```

#### 
To support configurable properties, a widget uses the  configuration. For example, the character-details widget defines its configuration as follows:
```swift
struct CharacterDetailWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectCharacterIntent.self,
            provider: CharacterDetailProvider()) { entry in
            CharacterDetailView(entry: entry)
        }
        .configurationDisplayName("Character Details")
        .description("Displays a character's health and other details")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
```

The `SelectCharacterIntent` parameter determines the customizable properties for the widget. The configuration uses `CharacterDetailProvider` to manage the timeline events for the widget. For more information about timeline providers, see .
After a person edits the widget, WidgetKit passes the customized values to the provider when requesting timeline entries. You typically include relevant details from the intent in the timeline entries the provider generates. In the following example, the provider uses the `defaultQuery` to look up the `CharacterDetail` using the character’s `id` in the intent, and then creates a timeline with an entry containing the character’s detail:
```swift
struct CharacterDetailProvider: AppIntentTimelineProvider {
    func timeline(for configuration: SelectCharacterIntent, in context: Context) async -> Timeline<CharacterDetailEntry> {
        // Create the timeline and return it. The .never reload policy indicates
        // that the containing app uses WidgetCenter methods to reload the
        // widget's timeline when the details change.
        let entry = CharacterDetailEntry(date: Date(), detail: configuration.character)
        let timeline = Timeline(entries: [entry], policy: .never)
        return timeline
    }
}
```

#### 
To access the intent of any widget that the user has installed, use  to fetch the  objects. Iterate over the `WidgetInfo` objects and call .
#### 
- An empty array (`return []`) to let people configure the complication or widget

## Migrating ClockKit complications to WidgetKit
> https://developer.apple.com/documentation/widgetkit/converting-a-clockkit-app

### 
#### 
#### 
In each of the protocol methods, your app needs to create and return one or more  instances:
The template provides a timeline entry that contains the date when the system should display it. Add any extra properties that you need for your complications.
```swift
struct CoffeeTrackerEntry: TimelineEntry {
    let date: Date
    let mgCaffeine: Double
    let totalCups: Double
}
```

```
Then, begin updating the timeline provider’s methods. For the placeholder, the system automatically redacts all of the widget’s content, unless you explicitly mark items with the  view modifier in your complication’s SwiftUI view. As a result, you may want to provide generic data that fills out the redacted version.
```swift
func placeholder(in context: Context) -> SimpleEntry {
    
    // Show a complication with generic data.
    CoffeeTrackerEntry(date: Date(),
                       mgCaffeine: 250.0,
                       totalCups: 2.0)
}
```

The system can display the placeholder when the watch is locked, when it’s in Always On mode, and when it can’t otherwise display a live version of your complication.
For the snapshot, return a single entry. In general, you want to return the current state of your app. However, the system also uses the snapshot when displaying your complication in the complication picker. When returning your snapshot entry, be sure to check the `context` parameter  property. This property indicates whether the snapshot will be used in the complication picker. If this is `true`, provide generic data that shows your app’s typical appearance.
```swift
func getSnapshot(in context: Context, completion: @escaping (CoffeeTrackerEntry) -> Void) {
    
    if context.isPreview {
        // Show a complication with generic data.
        let entry = CoffeeTrackerEntry(date: Date(),
                    mgCaffeine: 250.0,
                    totalCups: 2.0)
        
        completion(entry)
        return
    }
    
    Task {
        
        let date = Date()
        
        // Get the current data from the model.
        let mgCaffeine = await data.mgCaffeine(atDate: date)
        let totalCups = await data.totalCupsToday
        
        // Create the entry.
        let entry = CoffeeTrackerEntry(date: date,
                                mgCaffeine: mgCaffeine,
                                totalCups: totalCups)
        
        // Pass the entry to the completion handler.
        completion(entry)
    }
}
```

```
For the timeline, create an array of entries, and then create a  instance from that array. You can also select a reload policy for the timeline. By default, the system reloads the timeline when you reach its end. However, in the example below, the system only reloads the timeline when you explicitly request it.
```swift
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    Task {

        // Create an array to hold the events.
        var entries: [CoffeeTrackerEntry] = []
        
        // The total number of cups consumed only changes when the user actively adds a drink,
        // so it remains constant in this timeline.
        let totalCups = await data.totalCupsToday

        // Generate a timeline covering every 5 minutes for the next 24 hours.
        let currentDate = Date()
        for minuteOffset in stride(from: 0, to: 60 * 24, by: 5) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            
            // Get the projected data for the specified date.
            let mgCaffeine = await data.mgCaffeine(atDate: entryDate)
            
            // Create the entry.
            let entry = CoffeeTrackerEntry(date: entryDate,
                                           mgCaffeine: mgCaffeine,
                                           totalCups: totalCups)
            
            // Add the event to the array.
            entries.append(entry)
        }

        // Create the timeline and pass it to the completion handler.
        // Because the caffeine dose drops to 0.0 mg after 24 hours,
        // there's no need to reload this timeline unless the user adds
        // a new drink. Setting the reload policy to .never.
        let timeline = Timeline(entries: entries, policy: .never)
        
        // Pass the timeline to the completion handler.
        completion(timeline)
    }
}
```

#### 
If your app provides a static set of widgets, you can define multiple widgets using a  protocol. For example, the code listing below provides three complications: one that displays the user’s current caffeine dose, one that provides the total number of cups of coffee for the day, and one that provides both. Each widget can then support a different subset of the available families.
```swift
@main
struct CoffeeTrackerWidgets: WidgetBundle {
   var body: some Widget {
       CaffeineComplication()
       CupsComplication()
       CaffeineAndCupsComplication()
   }
}
```

WidgetKit uses app intents for customizable properties, the same method that Siri Suggestions and Siri Shortcuts use to customize those interactions. In iOS, the app intents describe elements that the user can customize. For WidgetKit complications in watchOS, these intents aren’t user configurable. Instead, they represent items that your app can dynamically configure.
To customize the widgets, implement your  structure’s  method to return an array of  instances.
```swift
func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
    var recommendations = [AppIntentRecommendation<ConfigurationAppIntent>]()
    
    for cityID in favoriteCityIDs {
        let intent = ConfigurationAppIntent()
        intent.cityID = cityID
        recommendations.append(AppIntentRecommendation(intent: intent, description: cityName(id: cityID)))
    }

    return recommendations
}
```

#### 
Because complications show a snapshot of the app’s data at a particular point in time, they don’t support features like animation. Additionally, if the user touches your complication, the system launches your app instead of passing the touch event to the SwiftUI views, so a complication can’t use interactive elements like buttons or switches.
Start by updating your  structure.
```swift
struct CaffeineComplication: Widget {
    
    // Create a unique string to identify the complication.
    let kind: String = "com.example.caffeine-complication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CoffeeTrackerComplicationsEntryView(entry: entry)
        }
        .configurationDisplayName("Coffee Tracker")
        .description("Shows the current caffeine dose in your system.")
        .supportedFamilies([.accessoryCorner, .accessoryCircular, .accessoryInline])
    }
}
```

Use the  environment value to determine the complication’s family. You can provide a different SwiftUI view for each family. You can also get the family from the context passed to your timeline provider’s , , and  methods.
```swift
struct CaffeineComplicationView: View {
    
    // Get the widget's family.
    @Environment(\.widgetFamily) private var family
    
    var entry: Provider.Entry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            MyCircularComplication(mgCaffeine: entry.mgCaffeine,
                                   totalCups: entry.totalCups)
            
        case .accessoryCorner:
            MyCornerComplication(mgCaffeine: entry.mgCaffeine,
                                 totalCups: entry.totalCups)
            
        case .accessoryInline:
            MyInlineComplication(mgCaffeine: entry.mgCaffeine,
                                 totalCups: entry.totalCups)
            
        default:
            Image("AppIcon")
        }
    }
}
```

```
Then, check the  environmental value to determine whether your complication is rendered in full color or using accent colors. Modify your design to best suit the current rendering mode.
```swift
struct MyCircularComplication: View {
    // Get the rendering mode.
    @Environment(\.widgetRenderingMode) var renderingMode
    
    var mgCaffeine: Double
    var totalCups: Double
    let maxMG = 500.0
    
    var body: some View {
        Gauge( value: min(mgCaffeine, maxMG), in: 0.0...maxMG ) {
            Text("mg")
        } currentValueLabel: {
            if renderingMode == .fullColor {
                // Add a foreground color to the label.
                Text(mgCaffeine.formatted(myFloatFormatter))
                    .foregroundStyle(.doseColor(for: mgCaffeine))
            }
            else {
                // Otherwise, use the default text color.
                Text(mgCaffeine.formatted(myFloatFormatter))
            }
        }
        .gaugeStyle(
            // Add a gradient to the gauge.
            CircularGaugeStyle(tint: Gradient(stops: myStops)))
    }
}
```

### 
When users upgrade your app, you need to transition them from the old ClockKit complications to your new WidgetKit complications. Start by implementing your  type’s  method. Use your implementation to return an instance that conforms to the  protocol.
For example, update your data source so that it conforms to the  protocol.
```swift
class ComplicationController: NSObject, CLKComplicationDataSource, CLKComplicationWidgetMigrator {
   // ...
}
```

Then, have the  property return `self`.
```
Then, have the  property return `self`.
```swift
var widgetMigrator: CLKComplicationWidgetMigrator {
    self
}
```

```
Finally, implement the  method. This method determines the best WidgetKit configuration for the given complication descriptor. This example uses the Swift async version of the method:
```swift
func widgetConfiguration(from complicationDescriptor: CLKComplicationDescriptor) async -> CLKComplicationWidgetMigrationConfiguration? {
    
    switch complicationDescriptor.identifier {
    case caffeineDoseIdentifier:
        return CLKComplicationStaticWidgetMigrationConfiguration(
            kind: "com.example.Caffeine-Complication",
            extensionBundleIdentifier: "com.example.apple-samplecode.Coffee-Tracker.watchkitapp.watchkitextension.CoffeeTracker-Complications")

    case cupTotalIdentifier:
        return CLKComplicationStaticWidgetMigrationConfiguration(
            kind: "com.example.CupTotal-Complication",
            extensionBundleIdentifier: "com.example.apple-samplecode.Coffee-Tracker.watchkitapp.watchkitextension.CoffeeTracker-Complications")

    case cupAndCaffeineIdentifier:
        return CLKComplicationStaticWidgetMigrationConfiguration(
            kind: "com.example.CupAndCaffeine-Complication",
            extensionBundleIdentifier: "com.example.apple-samplecode.Coffee-Tracker.watchkitapp.watchkitextension.CoffeeTracker-Complications")

    default:
        return nil
    }
}
```


## Migrating widgets from SiriKit Intents to App Intents
> https://developer.apple.com/documentation/widgetkit/migrating-from-sirikit-intents-to-app-intents

### 
#### 
Xcode generates source files for new types that conform to the  protocol, and sets the `intentClassName` property to the name of the SiriKit Intent.
#### 
In the widget’s `body` method, add code that does the following:
- Instead of using an `IntentConfiguration`, create an .
- Instead of passing an `IntentTimelineProvider`, pass a type that conforms to .
- Instead of passing an `IntentTimelineProvider`, pass a type that conforms to .
To continue supporting versions earlier than iOS 17, macOS 14, and watchOS 10, factor the creation of the widget’s configuration to a type-erased method that the `body` method calls, as shown below.
```swift
struct MyWidget: Widget {

    // Helper method to create the appropriate configuration depending
    // on the operating system version.
    func makeWidgetConfiguration() -> some WidgetConfiguration {
        if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
            return AppIntentConfiguration(kind: kind, intent: MyAppIntent.self, provider: MyAppIntentProvider()) { entry in
                MyAppIntentWidgetEntryView(entry: entry)
            }
        } else {
            return IntentConfiguration(kind: kind, intent: MyIntent.self, provider: MyIntentProvider()) { entry in
                MyIntentWidgetEntryView(entry: entry)
            }
        }
    }

    var body: some WidgetConfiguration {
        makeWidgetConfiguration()
            .configurationDisplayName("My Widget")
            .description("This is an example widget.")
    }
}
```

- Identifies the name of the custom `INIntent` in the widget’s stored configuration.
- Maps the parameters from the `INIntent` configuration to the `CustomIntentMigratedAppIntent`, matching the parameter name and type.
- Uses the new app intent for the widget’s configuration instead of the `INIntent`.
#### 
#### 

## Preparing widgets for additional platforms, contexts, and appearances
> https://developer.apple.com/documentation/widgetkit/preparing-widgets-for-additional-contexts-and-appearances

### 
In your code, read the  environment variable to create SwiftUI views for each applicable rendering mode, as shown in the following example:
```swift
// ...

@Environment(\.widgetRenderingMode) var renderingMode

var body: some View {
   ZStack {
       switch renderingMode {
       case .fullColor:
           // Create views for full-color widgets and watch complications.
       case .accented:
           // Create views and group applicable views in the accented group.
           VStack {
               // ...
           }
           .widgetAccentable()
           // Additional views that you don't group in the accented group.
       case .vibrant:
           // Create views for Lock Screen widgets on iPhone and iPad.
   }
}
```

#### 
#### 
#### 
#### 
#### 

## Previewing widgets and Live Activities in Xcode
> https://developer.apple.com/documentation/widgetkit/previewing-widgets-and-live-activities-in-xcode

### 
#### 
Using one of the `#Preview` macros, provide Xcode with the widget and its widget families:
In some cases, you might need to fix an animation that occurs later in the timeline. Creating a specific timeline is especially useful because it can help you fix the issue faster by focusing on a specific transition between two timeline entries. For example, you might supply the preview with a timeline provider that has 10 entries and identify an optimization for the transition from entry 9 to 10. To focus on optimizing this specific transition without going through entries 1 to 8, you create a preview with a `timeline` specific to this case that only contains entries 9 and 10.
The following example shows a preview for the medium system family widget of the  sample code project that uses a timeline with two entries.
```swift

#Preview(as: .systemMedium, widget: {
    EmojiRangerWidget()
}, timeline: {
    let date = Date()
    SimpleEntry(date: date, relevance: nil, hero: .spouty)
    SimpleEntry(date: date.addingTimeInterval(60), relevance: nil, hero: .spook)
})
```

#### 

## Supporting additional widget sizes
> https://developer.apple.com/documentation/widgetkit/supporting-additional-widget-sizes

### 
After you add a widget extension to your app and create your first widget, add code to declare additional widgets your app supports using the  property modifier. The sizes you use depend on the devices your app supports. If your app supports more than one platform, make sure to conditionally declare supported widget families.
The following example from the  sample code project shows how you declare several widgets sizes in your  implementation. The app supports accessory widgets in both watchOS and iOS and  and  widgets in iOS. Note the usage of the `#if os(watchOS)` macro to make sure you declare the correct supported widget families for each platform.
```swift
public var body: some WidgetConfiguration {
    makeWidgetConfiguration()
        .configurationDisplayName("Ranger Detail")
        .description("See your favorite ranger.")
#if os(watchOS)
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline])
#else
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline,
                            .systemSmall, .systemMedium, .systemLarge])
#endif
}
```

#### 
2. Construct the view for each size and include code to handle appearances like vibrant and Dark Mode, as applicable. To learn more, see .
The following example shows an abbreviated code snippet from the  sample code project. It conditionally returns the right SwiftUI view for each widget family.
```swift
struct EmojiRangerWidgetEntryView: View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryCircular:
            // Code to construct the view for the circular accessory widget or watch complication.
        case .accessoryRectangular:
            // Code to construct the view for the rectangular accessory widget or watch complication.
        case .accessoryInline:
            // Code to construct the view for the inline accessory widget or watch complication.
        case .systemSmall:
            // Code to construct the view for the small widget.
        case .systemLarge:
            // Code to construct the view for the large widget.
        case .systemMedium
            // Code to construct the view for the medium widget.
        default:
            // Code to construct the view for other widgets, for example, the extra large widget.
        }
    }
}
```


## Updating controls locally and remotely
> https://developer.apple.com/documentation/widgetkit/updating-controls-locally-and-remotely

### 
#### 
Reload controls when their state changes after someone interacts with them, such as turning a light on or off from within your app. Use the  method on the shared `ControlCenter` to ask the system to reload a control from your app that matches a specific `kind` unique identifier.
The following code shows reloading a garage door control toggle from within the app:
```swift
func toggleGarageDoor() {
	//Open or close a garage door.
	
	ControlCenter.shared.reloadControls(ofKind: "com.example.myApp.garageDoorToggle")
}
```

#### 
- The  containing the unique push token that’s used to deliver updates for this control, if a push handler is registered.
The following code registers a push handler on a control that opens and closes a garage door:
```swift
struct GarageDoorOpener: ControlWidget {
	var body: some ControlWidgetConfiguration {
		StaticControlConfiguration(
			kind: "com.apple.GarageDoorOpener"
		) {
			ControlWidgetToggle(...)
		}
		.pushHandler(MyPushHandler.self)
	}
}

struct MyPushHandler: ControlPushHandler {
	func pushTokensDidChange(controls: [ControlInfo]) {
		// Send push tokens and subscription info to your server.
		// ...
	}
}
```

Query for the current set of your controls someone placed across their system in your app by calling  on the shared `ControlCenter`. Introspect the push tokens, if any, from the set of controls to sync state with your app and server.
The following code queries for the current set of controls and gets any push tokens associated with them:
```swift
let controls = await ControlCenter.shared.currentControls()
let pushTokens = controls.compactMap { $0.pushInfo?.token }

// Sync push tokens with your server.
```

Use APNs when your server has a state change to communicate to controls on someone’s devices. The POST request indicates that state changed for the single control representing that given push token, and the system reloads the control.
The code snippet below shows a sample POST request created with an authentication token:
```swift
HEADERS
  - END_STREAM
  + END_HEADERS
  :method = POST
  :scheme = https
  :path = /3/device/00fc13adff785122b4ad28809a3420982341241421348097878e577c991de8f0
  host = api.sandbox.push.apple.com
  authorization = bearer eyAia2lkIjogIjhZTDNHM1JSWDciIH0.eyAiaXNzIjogIkM4Nk5WOUpYM0QiLCAiaWF0I
		 jogIjE0NTkxNDM1ODA2NTAiIH0.MEYCIQDzqyahmH1rz1s-LFNkylXEa2lZ_aOCX4daxxTZkVEGzwIhALvkClnx5m5eAT6
		 Lxw7LZtEQcH6JENhJTMArwLf3sXwi
  apns-id = eabeae54-14a8-11e5-b60b-1697f925ec7b
  apns-push-type = controls
  apns-expiration = 0
  apns-priority = 10
  apns-topic = com.example.MyApp.push-type.controls
DATA
  + END_STREAM
  { "aps" : { "content-changed" : true } }
```


## Updating widgets with WidgetKit push notifications
> https://developer.apple.com/documentation/widgetkit/updating-widgets-with-widgetkit-push-notifications

### 
#### 
#### 
> **note:** The system calls `pushTokenDidChange(_:widgets:)` for all push token updates and for the first push token you receive from WidgetKit.
The following example shows a template for the `pushTokenDidChange(_:widgets:)` requirement:
The following example shows a template for the `pushTokenDidChange(_:widgets:)` requirement:
```swift
// Handle push token and widget configuration changes.
struct CaffeineTrackerPushHandler: WidgetPushHandler {
    func pushTokenDidChange(_ pushInfo: WidgetPushInfo, widgets: [WidgetInfo]) {
        // Send the push token and subscription info
        // to your remote notification server.
        // ...
    }
}
```

#### 
When you implement the push handler, tell WidgetKit which widget you want to update with remote push notifications by adding the handler to your  using the  API:
```swift
// Add the pushHandler to the WidgetConfiguration.
struct CaffeineTrackerWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: Constants.widgetKind,
            provider: Provider()
        ) { entry in
            CaffeineTrackerWidgetView(entry: entry)
        }
        .configurationDisplayName("Caffeine Tracker")
        .pushHandler(CaffeineTrackerPushHandler.self)
    }
}
```

#### 
- Set the value for the `apns-push-type` header field to `widgets`.
- Set the value for the `apns-topic` header field to `<your bundleID>.push-type.widgets`.
- In your request’s `apn` dictionary, set the `content-changed` property to `true`.
- In your request’s `apn` dictionary, set the `content-changed` property to `true`.
The following sample shows what a POST request for a widget update might look like:
```swift
:method = POST
:scheme = https
:path = /3/device/<DEVICE_TOKEN>

// Request headers
host = api.sandbox.push.apple.com
apns-push-type = widgets
apns-topic = com.example.CaffeineTracker.push-type.widgets

// Request body
{
    "aps": {
        "content-changed": true,     
    }
}
```


## Updating your widgets for visionOS
> https://developer.apple.com/documentation/widgetkit/updating-your-widgets-for-visionos

### 
#### 
- If your widget only supports the  mounting style, people can’t place it on horizontal surfaces.
For example, a widget might use a photo to create the illusion of a window into another part of the world. This widget would rely on a sense of depth and alignment that doesn’t make sense on a horizontal surface, and does not support the `elevated` mounting style as shown in the following example:
```swift
struct WeatherWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            // ...
        ) { entry in
            WeatherWidgetView(entry: entry)
        }
        .configurationDisplayName("Weather widget")
        .supportedMountingStyles([.recessed])
    }
}
```

#### 
By default, widgets in visionOS appear under a glass texture. For widgets that your visionOS app offers, choose between the default glass texture or an alternative paper texture that gives the widget a poster-like look. To specify your widget’s texture, use the  view modifier and choose between  and .
Especially if your widgets uses a poster-like look, consider offering a  or  widget by including it in the array of  as shown in the following example:
```swift
struct CaffeineTrackerWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            // ...
        ) { entry in
            CaffeineTrackerWidgetView(entry: entry)
        }
        .configurationDisplayName("Caffeine Tracker")
        .supportedMountingStyles([.elevated])
        .widgetTexture(.paper)
        .supportedFamilies([.systemExtraLarge])
    }
}
```

#### 
#### 
When a person’s distance to a widget changes to above or below the threshold for a simplified layout, the system animates the layout changes, similar to how it animates data changes between timeline entries.
This example shows how a view might respond to the level of detail environment variable by adjusting the text size:
```swift
struct TotalCaffeineView: View {
    @Environment(\.levelOfDetail) var levelOfDetail
    
    // ...

    var body: some View {
        VStack {
            Text("Total Caffeine")
                .font(.caption)
            Text(totalCaffeine.formatted())
                .font(caffeineFont)
       }
    }

    var caffeineFont: Font {
        if levelOfDetail == .simplified {
            .largeTitle
        } else {
            .title
        }
    }
}
```


