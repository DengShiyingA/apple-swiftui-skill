# Apple SWIFTUI Skill


## Adding a background to your view
> https://developer.apple.com/documentation/swiftui/adding-a-background-to-your-view

### 
#### 
If your design calls for a background, you can use the  modifier to add it underneath an existing view. The following example adds a gradient to the vertical stack using the  view modifier:
```swift
let backgroundGradient = LinearGradient(
    colors: [Color.red, Color.blue],
    startPoint: .top, endPoint: .bottom)

struct SignInView: View {
    @State private var name: String = ""

    var body: some View {
        VStack {
            Text("Welcome")
                .font(.title)
            HStack {
                TextField("Your name?", text: $name)
                    .textFieldStyle(.roundedBorder)
                Button(action: {}, label: {
                    Image(systemName: "arrow.right.square")
                        .font(.title)
                })
            }
            .padding()
        }
        .background {
            backgroundGradient
        }
    }
}
```

#### 
To create a background that’s larger than the vertical stack, use a different technique. You could add  views above and below the content in the  to expand it, but that would also expand the size of the stack, possibly changing it’s layout. To add in a larger background without changing the size of the stack, nest the views within a  to layer the  over the background view:
```swift
struct SignInView: View {
    @State private var name: String = ""

    var body: some View {
        ZStack {
            backgroundGradient
            VStack {
                Text("Welcome")
                    .font(.title)
                HStack {
                    TextField("Your name?", text: $name)
                        .textFieldStyle(.roundedBorder)
                    Button(action: {}, label: {
                        Image(systemName: "arrow.right.square")
                            .font(.title)
                    })
                }
                .padding()
            }
        }
    }
}
```

#### 
By default, SwiftUI sizes and positions views to avoid system defined safe areas to ensure that system content or the edges of the device won’t obstruct your views. If your design calls for the background to extend to the screen edges, use the  modifier to override the default.
```swift
struct SignInView: View {
    @State private var name: String = ""
    var body: some View {
        ZStack {
            backgroundGradient
            VStack {
                Text("Welcome")
                    .font(.title)
                HStack {
                    TextField("Your name?", text: $name)
                        .textFieldStyle(.roundedBorder)
                    Button(action: {}, label: {
                        Image(systemName: "arrow.right.square")
                            .font(.title)
                    })
                }
                .padding()
            }
        }
        .ignoresSafeArea()
    }
}
```

#### 
To get the contents of the vertical stack to respect the safe areas and adjust to the keyboard, move the modifier to only apply to the background view.
```swift
struct SignInView: View {
    @State private var name: String = ""
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            VStack {
                Text("Welcome")
                    .font(.title)
                HStack {
                    TextField("Your name?", text: $name)
                        .textFieldStyle(.roundedBorder)
                    Button(action: {}, label: {
                        Image(systemName: "arrow.right.square")
                            .font(.title)
                    })
                }
                .padding()
            }
        }
    }
}
```


## Adding a search interface to your app
> https://developer.apple.com/documentation/swiftui/adding-a-search-interface-to-your-app

### 
#### 
You can automatically place the search field by adding the  modifier to a navigation element like a navigation split view:
```swift
struct ContentView: View {
    @State private var departmentId: Department.ID?
    @State private var productId: Product.ID?
    @State private var searchText: String = ""

    var body: some View {
        NavigationSplitView {
            DepartmentList(departmentId: $departmentId)
        } content: {
            ProductList(departmentId: departmentId, productId: $productId)
        } detail: {
            ProductDetails(productId: productId)
        }
        .searchable(text: $searchText) // Adds a search field.
    }
}
```

#### 
To add a search field to a specific column in iOS and iPadOS, add the searchable modifier to a view in that column. For example, to indicate that the search covers departments in the previous example, you could place the search field in the first column by adding the modifier to that column’s `DepartmentList` view instead of to the navigation split view:
```swift
NavigationSplitView {
    DepartmentList(departmentId: $departmentId)
        .searchable(text: $searchText)
} content: {
    ProductList(departmentId: departmentId, productId: $productId)
} detail: {
    ProductDetails(productId: productId)
}
```

#### 
You can alternatively use the `placement` input parameter to suggest a  value for the search interface. For example, you can achieve the same results as the previous example in macOS using the  placement:
```swift
NavigationSplitView {
    DepartmentList(departmentId: $departmentId)
} content: {
    ProductList(departmentId: departmentId, productId: $productId)
} detail: {
    ProductDetails(productId: productId)
}
.searchable(text: $searchText, placement: .sidebar)
```

#### 
By default, the search field contains Search as the placeholder text, to prompt people on how to use the field. You can customize the prompt by setting either a string, a  view, or a  for the searchable modifier’s `prompt` input parameter. For example, you might use this to clarify that the search field in the Department column searches among both departments and the products in each department:
```swift
DepartmentList(departmentId: $departmentId)
    .searchable(text: $searchText, prompt: "Departments and products")
```


## Adding interactivity with gestures
> https://developer.apple.com/documentation/swiftui/adding-interactivity-with-gestures

### 
#### 
Each gesture you add applies to a specific view in the view hierarchy. To recognize a gesture event on a particular view, create and configure the gesture, and then use the  modifier:
```swift
struct ShapeTapView: View {
    var body: some View {
        let tap = TapGesture()
            .onEnded { _ in
                print("View tapped!")
            }
        
        return Circle()
            .fill(Color.blue)
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(tap)
    }
}
```

#### 
To update a view as a gesture changes, add a  property to your view and update it in the  callback. SwiftUI invokes the updating callback as soon as it recognizes the gesture and whenever the value of the gesture changes. For example, SwiftUI invokes the updating callback as soon as a magnification gesture begins and then again whenever the magnification value changes. SwiftUI doesn’t invoke the updating callback when the user ends or cancels a gesture. Instead, the gesture state property automatically resets its state back to its initial value.
For example, to make a view that changes color while the user performs a long press, add a gesture state property and update it in the updating callback.
```swift
struct CounterView: View {
    @GestureState private var isDetectingLongPress = false
    
    var body: some View {
        let press = LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }
        
        return Circle()
            .fill(isDetectingLongPress ? Color.yellow : Color.green)
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(press)
    }
}
```

To track changes to a gesture that shouldn’t reset once the gesture ends, use the  callback. For example, to count the number of times your app recognizes a long press, add an  callback and increment a counter.
```swift
struct CounterView: View {
    @GestureState private var isDetectingLongPress = false
    @State private var totalNumberOfTaps = 0
    
    var body: some View {
        let press = LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }.onChanged { _ in
                self.totalNumberOfTaps += 1
            }
        
        return VStack {
            Text("\(totalNumberOfTaps)")
                .font(.largeTitle)
            
            Circle()
                .fill(isDetectingLongPress ? Color.yellow : Color.green)
                .frame(width: 100, height: 100, alignment: .center)
                .gesture(press)
        }
    }
}
```

To recognize when a gesture successfully completes and to retrieve the gesture’s final value, use the  function to update your app’s state in the callback. SwiftUI only invokes the  callback when the gesture succeeds. For example, during a  if the user stops touching the view before  seconds have elapsed or moves their finger more than  points SwiftUI does not invoke the  callback.
For example, to stop counting long press attempts after the user completes a long press, add an  callback and conditionally apply the gesture modifier.
```swift
struct CounterView: View {
    @GestureState private var isDetectingLongPress = false
    @State private var totalNumberOfTaps = 0
    @State private var doneCounting = false
    
    var body: some View {
        let press = LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }.onChanged { _ in
                self.totalNumberOfTaps += 1
            }
            .onEnded { _ in
                self.doneCounting = true
            }
        
        return VStack {
            Text("\(totalNumberOfTaps)")
                .font(.largeTitle)
            
            Circle()
                .fill(doneCounting ? Color.red : isDetectingLongPress ? Color.yellow : Color.green)
                .frame(width: 100, height: 100, alignment: .center)
                .gesture(doneCounting ? nil : press)
        }
    }
}
```


## Adopting drag and drop using SwiftUI
> https://developer.apple.com/documentation/swiftui/adopting-drag-and-drop-using-swiftui

### 
#### 
To enable dragging, add the `draggable(_:)` modifier to a view to send items that conform to `Transferable` protocol.
To enable dragging, add the `draggable(_:)` modifier to a view to send items that conform to `Transferable` protocol.
```swift
List {
    ForEach(dataModel.contacts) { contact in
        NavigationLink {
            ContactDetailView(contact: contact)
        } label: {
            CompactContactView(contact: contact)
                .draggable(contact) {
                    ThumbnailView(contact: contact)
                }
        }
    }
}
```

#### 
Use the `dropDestination(for:action:isTargeted:)` modifier to receive dragged items and define the destination that handles the dropped content.
Use the `dropDestination(for:action:isTargeted:)` modifier to receive dragged items and define the destination that handles the dropped content.
```swift
.dropDestination(for: Contact.self) { droppedContacts, index in
    dataModel.handleDroppedContacts(droppedContacts: droppedContacts, index: index)
}
```

The modifier expects a type `Contact` which conforms to the `Transferable` protocol. The implementation of the `dropDestination(for:action:isTargeted:)` modifier uses the  to receive a dragged item representing the dropped contact information.
The app defines the transfer representations in order of preference. The app uses the most suitable representation to create and initialize a `Contact` object.
```swift
static var transferRepresentation: some TransferRepresentation {
    // Allows a Contact to be transferred with a custom content type.
    CodableRepresentation(contentType: .exampleContact)
    // Allows importing and exporting Contact data as a vCard.
    DataRepresentation(contentType: .vCard) { contact in
        try contact.toVCardData()
    } importing: { data in
        try await parseVCardData(data)
    }
    .suggestedFileName { $0.fullName }
    // Enables exporting the `phoneNumber` string as a proxy for the entire `Contact`.
    ProxyRepresentation { contact in
        contact.phoneNumber
    } importing: { value in
        Contact(id: UUID().uuidString, givenName: value, familyName: "", phoneNumber: "")
    }
}
```

If the app receives an item with a custom , for example `com.example.contact`, it uses the  to represent the `Contact` data structure.
Finally,  creates a binary representation of the `Contact` object and constructs the value for the receiver that supports the `vCard` content type.
Finally,  creates a binary representation of the `Contact` object and constructs the value for the receiver that supports the `vCard` content type.
When someone drops the contact on the `Table` or `List`, the completion handler inserts the dropped contact into the collection of contacts at the drop location. If the drop doesn’t specify an index, the completion handler adds the dropped contact to the end of the collection.
```swift
func handleDroppedContacts(droppedContacts: [Contact], index: Int? = nil) {
    guard let firstContact = droppedContacts.first else {
        return
    }
    // If the ID of the first contact exists in the contacts list,
    // move the contact from its current position to the new index.
    // If no index is specified, insert the contact at the end of the list.
    if let existingIndex = contacts.firstIndex(where: { $0.id == firstContact.id }) {
        let indexSet = IndexSet(integer: existingIndex)
        contacts.move(fromOffsets: indexSet, toOffset: index ?? contacts.endIndex)
    } else {
        contacts.insert(firstContact, at: index ?? contacts.endIndex)
    }
}
```

Finally, the `dropDestination(for:action:isTargeted:)` modifier can receive drag interactions that start in any other view or app.

## Aligning views across stacks
> https://developer.apple.com/documentation/swiftui/aligning-views-across-stacks

### 
#### 
To illustrate aligning items across stacks, the following view shows a horizontal stack wrapping around two nested vertical stacks that have a different number of child views. The enclosing  doesn’t define an alignment, so it defaults to .
```swift
struct ImageRow: View {
    var body: some View {
        HStack {
            VStack {
                Image("bell_peppers")
                    .resizable()
                    .scaledToFit()
                Text("Bell Peppers")
                    .font(.title)
            }
            VStack {
                Image("chili_peppers")
                    .resizable()
                    .scaledToFit()
                Text("Chili Peppers")
                    .font(.title)
                Text("Higher levels of capsicum")
                    .font(.caption)
            }
        }
    }
}
```

#### 
To create a new vertical alignment guide, extend  with a new static property for your guide. Name the guide according to what it aligns to make it easier to use. The following example uses bottom positioning as the default value for this guide:
```swift
extension VerticalAlignment {
    /// A custom alignment for image titles.
    private struct ImageTitleAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            // Default to bottom alignment if no guides are set.
            context[VerticalAlignment.bottom]
        }
    }

    /// A guide for aligning titles.
    static let imageTitleAlignmentGuide = VerticalAlignment(
        ImageTitleAlignment.self
    )
}
```

#### 
To use the alignment guide, assign it to a parent view that encloses the views you want to align. The following example specifies `imageTitleAlignmentGuide` as the alignment for the horizontal stack:
```swift
struct RowOfAlignedImages: View {
    var body: some View {
        HStack(alignment: .imageTitleAlignmentGuide) {
            VStack {
                Image("bell_peppers")
                    .resizable()
                    .scaledToFit()

                Text("Bell Peppers")
                    .font(.title)
            }
            VStack {
                Image("chili_peppers")
                    .resizable()
                    .scaledToFit()

                Text("Chili Peppers")
                    .font(.title)

                Text("Higher levels of capsicum")
                    .font(.caption)
            }
        }
    }
}
```

When you define an alignment on a stack, it projects through enclosed child views. Within the nested  instances, apply  to the views to align, using your custom guide for the .
```swift
struct RowOfAlignedImages: View {
    var body: some View {
        HStack(alignment: .imageTitleAlignmentGuide) {
            VStack {
                Image("bell_peppers")
                    .resizable()
                    .scaledToFit()

                Text("Bell Peppers")
                    .font(.title)
                    .alignmentGuide(.imageTitleAlignmentGuide) { context in
                        context[.firstTextBaseline]
                    }
            }
            VStack {
                Image("chili_peppers")
                    .resizable()
                    .scaledToFit()

                Text("Chili Peppers")
                    .font(.title)
                    .alignmentGuide(.imageTitleAlignmentGuide) { context in
                        context[.firstTextBaseline]
                    }

                Text("Higher levels of capsicum")
                    .font(.caption)
            }
        }
    }
}
```

The closure from the alignment guide modifier returns , which aligns the baselines of the titles with the alignment guide `imageTitleAlignmentGuide`.

## Aligning views within a stack
> https://developer.apple.com/documentation/swiftui/aligning-views-within-a-stack

### 
#### 
For an example of how SwiftUI applies default alignment to the views in an , examine the following code used to provide a status view for a recording app. The `HStack` contains an image view for the icon and two text views with labels that use the  modifier to adjust the font size of the text.
```swift
HStack {
    Image("microphone")
    Text("Connecting")
        .font(.caption)
    Text("Bryan")
        .font(.title)
}
.padding()
.border(Color.blue, width: 1)
```

#### 
-  uses the guides defined in , and a combination of `HorizontalAlignment` and `VerticalAlignment`.
-  uses the guides defined in , and a combination of `HorizontalAlignment` and `VerticalAlignment`.
Use the `alignment` parameter when initializing a stack to define the alignment guide for the stack. The following example sets the alignment of the `HStack` to , which aligns its child views to the baseline of the first text view (which contains the string “Connecting”):
```swift
HStack(alignment: .firstTextBaseline) {
    Image("microphone")
    Text("Connecting")
        .font(.caption)
    Text("Bryan")
        .font(.title)
}
.padding()
.border(Color.blue, width: 1)
```

#### 
Custom images don’t provide a text baseline guide, so the bottom of the image aligns to the text view’s baseline. Adjust the alignment of the image using  to get the visual alignment you desire. The alignment guide’s closure provides an instance of , the parameter `context` in this example — which you can use to return an offset value. The value looked up from `context` with , provides an offset that aligns the bottom of the image adjusted by an offset to the baseline guide defined on the stack:
```swift
HStack(alignment: .firstTextBaseline) {
    Image("microphone")
        .alignmentGuide(.firstTextBaseline) { context in
            context[.bottom] - 0.12 * context.height
        }
    Text("Connecting")
        .font(.caption)
    Text("Bryan")
        .font(.title)
}
.padding()
.border(Color.blue, width: 1)
```

#### 
You can replace the microphone image with a similar icon from  to simplify the view. The icons from SF Symbols use text baseline guides, which means they support whatever font styling you apply to the view.
```swift
HStack(alignment: .firstTextBaseline) {
    Image(systemName: "mic.circle")
        .font(.title)
    Text("Connecting")
        .font(.caption)
    Text("Bryan")
        .font(.title)
}
.padding()
.border(Color.blue, width: 1)
```


## Applying Liquid Glass to custom views
> https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views

### 
### 
- Add  to custom components to make them react to touch and pointer interactions. This applies the same responsive and fluid reactions that  provides to standard buttons.
In the examples below, observe how to apply Liquid Glass effects to a view, use an alternate shape with a specific corner radius, and create a tinted view that responds to interactivity:
```swift
Text("Hello, World!")
    .font(.title)
    .padding()
    .glassEffect()

Text("Hello, World!")
    .font(.title)
    .padding()
    .glassEffect(in: .rect(cornerRadius: 16.0))

Text("Hello, World!")
    .font(.title)
    .padding()
    .glassEffect(.regular.tint(.orange).interactive())
```

### 
In the example below, two images are placed close to each other and the Liquid Glass effects begin to blend their shapes together. This creates a fluid animation as components move around each other within a container:
```swift
GlassEffectContainer(spacing: 40.0) {
    HStack(spacing: 40.0) {
        Image(systemName: "scribble.variable")
            .frame(width: 80.0, height: 80.0)
            .font(.system(size: 36))
            .glassEffect()

        Image(systemName: "eraser.fill")
            .frame(width: 80.0, height: 80.0)
            .font(.system(size: 36))
            .glassEffect()

            // An `offset` shows how Liquid Glass effects react to each other in a container.
            // Use animations and components appearing and disappearing to obtain effects that look purposeful.
            .offset(x: -40.0, y: 0.0)
    }
}
```

In some cases, you want the geometries of multiple views to contribute to a single Liquid Glass effect capsule, even when your content is at rest. Use the  modifier to specify that a view contributes to a unified effect with a particular ID. This combines all effects with a similar shape, Liquid Glass effect, and ID into a single shape with the applied Liquid Glass material. This is especially useful when creating views dynamically, or with views that live outside of a layout container, like an `HStack` or `VStack`.
```swift
let symbolSet: [String] = ["cloud.bolt.rain.fill", "sun.rain.fill", "moon.stars.fill", "moon.fill"]

GlassEffectContainer(spacing: 20.0) {
    HStack(spacing: 20.0) {
        ForEach(symbolSet.indices, id: \.self) { item in
            Image(systemName: symbolSet[item])
                .frame(width: 80.0, height: 80.0)
                .font(.system(size: 36))
                .glassEffect()
                .glassEffectUnion(id: item < 2 ? "1" : "2", namespace: namespace)
        }
    }
}
```

### 
The `glassEffectID(_:in:)` and `glassEffectTransition(_:)` modifiers only affect their content during view hierarchy transitions or animations.
The `glassEffectID(_:in:)` and `glassEffectTransition(_:)` modifiers only affect their content during view hierarchy transitions or animations.
In the example below, the eraser image transitions into and out of the pencil image when the `isExpanded` variable changes. The `GlassEffectContainer` has a spacing value of `40.0`, and the `HStack` within it has a spacing of `40.0`. This morphs the eraser image into the pencil image when the eraser’s nearest edge is less than or equal to the container’s spacing.
```swift
@State private var isExpanded: Bool = false
@Namespace private var namespace

var body: some View {
    GlassEffectContainer(spacing: 40.0) {
        HStack(spacing: 40.0) {
            Image(systemName: "scribble.variable")
                .frame(width: 80.0, height: 80.0)
                .font(.system(size: 36))
                .glassEffect()
                .glassEffectID("pencil", in: namespace)

            if isExpanded {
                Image(systemName: "eraser.fill")
                    .frame(width: 80.0, height: 80.0)
                    .font(.system(size: 36))
                    .glassEffect()
                    .glassEffectID("eraser", in: namespace)
            }
        }
    }

    Button("Toggle") {
        withAnimation {
            isExpanded.toggle()
        }
    }
    .buttonStyle(.glass)
}
```

### 

## Applying custom fonts to text
> https://developer.apple.com/documentation/swiftui/applying-custom-fonts-to-text

### 
#### 
#### 
#### 
The following example applies the font `MyFont` to a text view:
Use the  method to retrieve an instance of your font and apply it to a text view with the  modifier. When retrieving the font with , match the name of the font with the font’s PostScript name. You can find the postscript name of a font by opening it with the Font Book app and selecting the Font Info tab. If SwiftUI can’t retrieve and apply your font, it renders the text view with the default system font instead.
The following example applies the font `MyFont` to a text view:
```swift
Text("Hello, world!")
    .font(Font.custom("MyFont", size: 18))
```

```
The font scales adaptively from the size provided to align with the default text style of . Use the `relativeTo` parameter to specify a text style to scale with other than the default of `body`. For example, to set the font size to `32` points and adaptively scale relative to the text style of :
```swift
Text("Hello, world!")
    .font(Font.custom("MyFont", size: 32, relativeTo: .title))
```

#### 
The  property wrapper on a view property provides a scaled value that changes automatically with accessibility settings. When working with adaptively sized fonts, you can scale the spacing between or around the text to improve the visual design with this property wrapper.
The following example uses `@ScaledMetric` to scale the padding value surrounding a text view relative to the `body` text style, with a blue border added to identify the spacing that padding adds:
```swift
struct ContentView: View {
    @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10

    var body: some View {
        Text("The quick brown fox jumps over the lazy dog.")
            .font(Font.custom("MyFont", size: 18))
            .padding(scaledPadding)
            .border(Color.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

Use the  modifier to set the accessibility size category on the preview to :
```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.sizeCategory, .accessibilityLarge)
    }
}
```


## Backyard Birds: Building an app with SwiftData and widgets
> https://developer.apple.com/documentation/swiftui/backyard-birds-sample

### 
#### 
2. Edit the multiplatform target’s scheme, and on the Options tab, choose the `Store.storekit` file for StoreKit configuration.
#### 
The app defines its data model by conforming the model objects to  using the  macro. Using the  macro with the  option ensures that the `id` property is unique.
```swift
@Model public class BirdSpecies {
    @Attribute(.unique) public var id: String
    public var naturalScale: Double
    public var isEarlyAccess: Bool
    public var parts: [BirdPart]
    
    @Relationship(deleteRule: .cascade, inverse: \Bird.species)
    public var birds: [Bird] = []
    
    public var info: BirdSpeciesInfo { BirdSpeciesInfo(rawValue: id) }
    
    public init(info: BirdSpeciesInfo, naturalScale: Double = 1, isEarlyAccess: Bool = false, parts: [BirdPart]) {
        self.id = info.rawValue
        self.naturalScale = naturalScale
        self.isEarlyAccess = isEarlyAccess
        self.parts = parts
    }
}
```

#### 
Backyard Birds displays interactive widgets by presenting a  to refill a backyard’s supplies when the water and food are running low. The app does this by placing a `Button` in the widget’s view, and passing a `ResupplyBackyardIntent` instance to the  initializer:
```swift
Button(intent: ResupplyBackyardIntent(backyard: BackyardEntity(from: snapshot.backyard))) {
    Label("Refill Water", systemImage: "arrow.clockwise")
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.quaternary, in: .containerRelative)
}
```

```
The app allows for configuration of the widget by implementing the  protocol:
```swift
struct BackyardWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Backyard"
    static let description = IntentDescription("Keep track of your backyards.")
    
    @Parameter(title: "Backyards", default: BackyardWidgetContent.all)
    var backyards: BackyardWidgetContent
    
    @Parameter(title: "Backyard")
    var specificBackyard: BackyardEntity?
    
    init(backyards: BackyardWidgetContent = .all, specificBackyard: BackyardEntity? = nil) {
        self.backyards = backyards
        self.specificBackyard = specificBackyard
    }
    
    init() {
    }
    
    static var parameterSummary: some ParameterSummary {
        When(\.$backyards, .equalTo, BackyardWidgetContent.specific) {
            Summary {
                \.$backyards
                \.$specificBackyard
            }
        } otherwise: {
            Summary {
                \.$backyards
            }
        }
    }
}
```

#### 
The sample app uses  to display several different bird food upgrades available for purchase on a store shelf. To prominently feature an in-app purchase item, the app uses the  modifier:
```swift
ProductView(id: product.id) {
    BirdFoodProductIcon(birdFood: birdFood, quantity: product.quantity)
        .bestBirdFoodValueBadge()
}
.padding(.vertical)
.background(.background.secondary, in: .rect(cornerRadius: 20))
.productViewStyle(.large)
```

```
The Backyard Birds Pass page displays renewable subscriptions using the  view. The app uses the `PassMarketingContent` view as the content of the `SubscriptionStoreView`:
```swift
SubscriptionStoreView(
    groupID: passGroupID,
    visibleRelationships: showPremiumUpgrade ? .upgrade : .all
) {
    PassMarketingContent(showPremiumUpgrade: showPremiumUpgrade)
        #if !os(watchOS)
        .containerBackground(for: .subscriptionStoreFullHeight) {
            SkyBackground()
        }
        #endif
}
```


## Building a document-based app with SwiftUI
> https://developer.apple.com/documentation/swiftui/building-a-document-based-app-with-swiftui

### 
### 
### 
A document-based SwiftUI app returns a `DocumentGroup` scene from its `body` property. The `newDocument` parameter that an app supplies to the document group’s  initializer conforms to either  or . In this sample, the document type conforms to `FileDocument`. The trailing closure of the initializer returns a view that renders the document’s contents:
```swift
@main
struct WritingApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: WritingAppDocument()) { file in
            StoryView(document: file.$document)
        }
    }
}
```

### 
You can update the default launch experience on iOS and iPadOS with a custom title, action buttons, and screen background. To add an action button with a custom label, use  to replace the default label. You can customize the background in many ways such as adding a view or a `backgroundStyle` with an initializer, for example . This sample customizes the background of the title view, using the  initializer:
```swift
DocumentGroupLaunchScene("Writing App") {
    NewDocumentButton("Start Writing")
} background: {
    Image(.pinkJungle)
    .resizable()
    .scaledToFill()
    .ignoresSafeArea()
} 
```

```
You can also add accessories to the scene using initializers such as  and  depending on the positioning.
```swift
overlayAccessoryView: { _ in
    AccessoryView()
}
```

```
This sample contains two accessories in the overlay position that it defines in `AccessoryView`. It customizes the accessories by applying modifiers, including  and .
```swift
ZStack {
    Image(.robot)
        .resizable()
        .offset(x: size.width / 2 - 450, y: size.height / 2 - 300)
        .scaledToFit()
        .frame(width: 200)
        .opacity(horizontal == .compact ? 0 : 1)
    Image(.plant)
        .resizable()
        .offset(x: size.width / 2 + 250, y: size.height / 2 - 225)
        .scaledToFit()
        .frame(width: 200)
        .opacity(horizontal == .compact ? 0 : 1)
}
```

### 
This sample has a data model that defines a story as a `String`, it initializes `story` with an empty string:
This sample has a data model that defines a story as a `String`, it initializes `story` with an empty string:
```swift
var story: String

init(text: String = "") {
    self.story = text
}
```

### 
The `WritingAppDocument` structure adopts the `FileDocument` protocol to serialize documents to and from files. The  property defines the types that the sample can read and write, specifically, the `.writingAppDocument` type:
```swift
static var readableContentTypes: [UTType] { [.writingAppDocument] }
```

```
The  initializer loads documents from a file. After reading the file’s data using the  property of the `configuration` input, it deserializes the data and stores it in the document’s data model:
```swift
init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents,
          let string = String(data: data, encoding: .utf8)
    else {
        throw CocoaError(.fileReadCorruptFile)
    }
    story = string
}
```

```
When a person writes a document, SwiftUI calls the  function to serialize the data model into a `FileWrapper` value that represents the data in the file system:
```swift
func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    let data = Data(story.utf8)
    return .init(regularFileWithContents: data)
}
```

Because the document type conforms to `FileDocument`, this sample handles undo actions automatically.
### 
The app defines and exports a custom content type for the documents it creates. It declares this custom type in the project’s  file under the  key. This sample uses `com.example.writingAppDocument` as the identifier in the `Info.plist` file:
```swift
<key>CFBundleDocumentTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>LSHandlerRank</key>
        <string>Default</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>com.example.writingAppDocument</string>
        </array>
        <key>NSUbiquitousDocumentUserActivityType</key>
        <string>$(PRODUCT_BUNDLE_IDENTIFIER).exampledocument</string>
    </dict>
</array>
<key>UTExportedTypeDeclarations</key>
<array>
    <dict>
        <key>UTTypeConformsTo</key>
        <array>
            <string>public.utf8-plain-text</string>
        </array>
        <key>UTTypeDescription</key>
        <string>Writing App Document</string>
        <key>UTTypeIconFiles</key>
        <array/>
        <key>UTTypeIdentifier</key>
        <string>com.example.writingAppDocument</string>
        <key>UTTypeTagSpecification</key>
        <dict>
            <key>public.filename-extension</key>
            <array>
                <string>story</string>
            </array>
        </dict>
    </dict>
</array>
```

```
For convenience, you can also define the content type in code. For example:
```swift
extension UTType {
    static var writingapp: UTType {
        UTType(exportedAs: "com.example.writingAppDocument")
    }
}
```


## Building and customizing the menu bar with SwiftUI
> https://developer.apple.com/documentation/swiftui/building-and-customizing-the-menu-bar-with-swiftui

### 
### 
Each scene includes a set of default menus and menu items, which you can supplement with your own app-specific needs using the  modifier.
A scene’s default menus and menu items are dependent on the functionality the scene type supports. For example,  includes commands for quitting and hiding the app, as well as Copy and Paste support and window management.
```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

```
On macOS, the  scene includes the same actions as `Window`, but adds an action for presenting the app’s Settings window that people get when they choose App menu > Settings. On iPadOS, this menu bar item doesn’t require an additional scene and when performed; it switches to the app’s settings in the Settings app.
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

The  scene includes actions that `WindowGroup` includes, as well as a number of actions that support document management capabilities, like Save and Duplicate.
Using scenes together creates a menu bar that includes menu items for all of the core functionality of an app that creates and edits documents, manages multiple windows, and exposes user-configurable settings.
```swift
@main
struct MyApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MyAppDocument()) { file in
            // ...
        }

        #if os(macOS)
        Settings {
            // ...
        }
        #endif
    }
}
```

### 
Some common menu items are optional, but are helpful if the app contains certain capabilities. For example, not every scene includes a navigation sidebar, but for those that do, people expect to find a menu item that controls the navigation sidebar’s visibility. If your scene includes a navigation sidebar, include this menu item using the  modifier and implementing :
```swift
@main
struct MyApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MyAppDocument()) { file in
            ContentView(document: file.$document)
        }
        .commands {
            SidebarCommands()
        }
    }
}
```

### 
Custom menu items are created with standard SwiftUI views, for example  and .  creates a submenu. For more information about menu item creation, see .
The menu bar also displays information about keyboard shortcuts next to menu items and which keys someone needs to press on the keyboard to perform an action without using the menu bar. The  modifier allows you to define which key combination will perform the action. Be aware that the system provides many keyboard shortcuts that your app can’t override. For design guidance, see Human Interface Guidelines > .
```swift
WindowGroup {
    ContentView()
}
.commands {
    CommandMenu("Actions") {
        Button("Run", systemImage: "play.fill") { ... }
            .keyboardShortcut("R")

        Button("Stop", systemImage: "stop.fill") { ... }
            .keyboardShortcut(".")
    }
}
```

### 
Modify system-provided menus using . These groups either extend menus with additional menu items or they replace existing menu items in the indicated command group. When you add menu items in this way, you can specify the location of the menu item based on system-provided menu items.
```swift
WindowGroup {
    ContentView()
}
.commands {
    CommandGroup(before: .systemServices) {
        Button("Check for Updates") { ... }
    }
    
    CommandGroup(after: .newItem) {
        Button("New from Clipboard") { ... }
    }
    
    CommandGroup(replacing: .help) {
        Button("User Manual") { ... }
    }
}

```

### 
Use  to create contextual dependencies with your menus and menu items. For example, a menu item’s title can change if the current focus is on a photo or a photo album. A focused value is state data that requires an active scene with its view hierarchy in focus. Use a dynamic property to react to changes in the views of the scene.
In the following, an app with a `WindowGroup` scene has an  data model for each window that supplies that window’s contents. The active window’s data model is made available as a focused value using the  modifier in the window view hierarchy.
```swift
@Observable
final class DataModel {
    var messages: [Message]
    ...
}

struct ContentView: View {
    @State private var model = DataModel()

    var body: some View {
        VStack {
            ForEach(model.messages) { ... }
        }
        .focusedSceneValue(model)
    }
}
```

```
Use the  property wrapper to represent the active scene’s data model in the menu bar. The data model changes whether the “New Message” button is active or inactive:
```swift
struct MessageCommands: Commands {
    @FocusedValue(DataModel.self) private var dataModel: DataModel?

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Message") {
                dataModel?.messages.append(...)
            }
            .disabled(dataModel == nil)
        }
    }
}

@main struct MessagesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            MessageCommands()
        }
    }
}
```

Similar to the  dynamic property, `FocusedValue` uses a key you provide to find the current value. When the focused value is an `Observable` object, that key can simply be the object’s type.
To share value-typed values, extend `FocusedValues` with a custom entry using the  macro, and pass the resulting key path when declaring the `FocusedValue` property. Custom entry values must always be optional.
```swift
struct ContentView: View {
    @State private var items: [Item] = ...
    @State private var selection: UUID?
    
    var body: some View {
        List(items, selection: $selection) { item in
            ...
        }
        // When active, views in the same scene or in the menu bar
        // can read the selected item ID.
        .focusedSceneValue(\.selectedItemID, selection)
    }
}

struct ItemCommands: Commands {
    @FocusedValue(\.selectedItemID) var selectedItemID: UUID?
    
    var body: some Commands {
        ...
    }
}

extension FocusedValues {
    @Entry var selectedItemID: UUID?
}
```

```
Use  when a menu item depends on the current placement of focus within the active scene’s view hierarchy. This creates a focused value that’s’ only visible to other views when focus is on the modified view or one of its subviews. When focus is elsewhere, the value of corresponding `FocusedValue` property is `nil`.
```swift
struct ContentView: View {
    @State private var items: [Item] = ...
    @State private var selection: UUID?

    var body: some View {
        NavigationSplitView {
            SidebarContent()
        } detail: {
            List(items, selection: $selection) { item in
                ...
            }

            // The selected item ID is visible when focus is on the 
            // navigation detail list. If focus is on the sidebar, the value of 
            // `@FocusedValue(\.selectedItemID)` is `nil`.
            .focusedValue(\.selectedItemID, selection)
        }
    }
}
```


## Building layouts with stack views
> https://developer.apple.com/documentation/swiftui/building-layouts-with-stack-views

### 
#### 
A  contains an  view that displays a profile picture with a semi-transparent  overlaid on top. The  contains a  with a pair of  views inside it, and a  view pushes the  to the leading side.
To create this stack view:
```swift
struct ProfileView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("ProfilePicture")
                .resizable()
                .aspectRatio(contentMode: .fit)
            HStack {
                VStack(alignment: .leading) {
                    Text("Rachael Chiseck")
                        .font(.headline)
                    Text("Chief Executive Officer")
                        .font(.subheadline)
                }
                Spacer()
            }
            .padding()
            .foregroundColor(.primary)
            .background(Color.primary
                            .colorInvert()
                            .opacity(0.75))
        }
    }
}
```

#### 
Align any contained views inside a stack view by using a combination of the `alignment` property, , and  views.
The `alignment` property doesn’t position the  inside its container; instead, it positions the views inside the .
#### 
#### 
For example, this code overlays a `ProfileDetail` view on top of the  view:
Choose between a stack-based approach and the view modifier approach based on how you want to determine the size of the final layout. If your layout has one dominant view that defines the size of the layout, use the  or  view modifier on that view. If you want the final view size to come from an aggregation of all the contained views, use a .
For example, this code overlays a `ProfileDetail` view on top of the  view:
```swift
struct ProfileViewWithOverlay: View {
    var body: some View {
        VStack {
            Image("ProfilePicture")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(ProfileDetail(), alignment: .bottom)
        }
    }
}

struct ProfileDetail: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Rachael Chiseck")
                    .font(.headline)
                Text("Chief Executive Officer")
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
        .foregroundColor(.primary)
        .background(Color.primary
                        .colorInvert()
                        .opacity(0.75))
    }
}
```


## Composing SwiftUI gestures
> https://developer.apple.com/documentation/swiftui/composing-swiftui-gestures

### 
#### 
To make it easier to track complicated states, use an enumeration that captures all of the states you need to configure your views. In the following example, there are three important states: no interaction (`inactive`), long press in progress (`pressing`), and dragging (`dragging`).
```swift
struct DraggableCircle: View {

    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }
    
    @GestureState private var dragState = DragState.inactive
    @State private var viewState = CGSize.zero
```

When you sequence two gestures, the callbacks capture the state of both gestures. In the update callback, the new `value` uses an enumeration to represent the combination of the possible gesture states. The code below converts the underlying gesture states into the high-level `DragState` enumeration defined above.
```swift
var body: some View {
        let minimumLongPressDuration = 0.5
        let longPressDrag = LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture())
            .updating($dragState) { value, state, transaction in
                switch value {
                // Long press begins.
                case .first(true):
                    state = .pressing
                // Long press confirmed, dragging may begin.
                case .second(true, let drag):
                    state = .dragging(translation: drag?.translation ?? .zero)
                // Dragging ended or the long press cancelled.
                default:
                    state = .inactive
                }
            }
            .onEnded { value in
                guard case .second(true, let drag?) = value else { return }
                self.viewState.width += drag.translation.width
                self.viewState.height += drag.translation.height
            }
```

```
When the user begins pressing the view, the drag state changes to `pressing` and a shadow animates under the shape. After the user finishes the long press and the drag state changes to `dragging`, a border appears around the shape to indicate that the user may begin moving the view.
```swift
        return Circle()
            .fill(Color.blue)
            .overlay(dragState.isDragging ? Circle().stroke(Color.white, lineWidth: 2) : nil)
            .frame(width: 100, height: 100, alignment: .center)
            .offset(
                x: viewState.width + dragState.translation.width,
                y: viewState.height + dragState.translation.height
            )
            .animation(nil)
            .shadow(radius: dragState.isActive ? 8 : 0)
            .animation(.linear(duration: minimumLongPressDuration))
            .gesture(longPressDrag)
    }
}
```


## Composing custom layouts with SwiftUI
> https://developer.apple.com/documentation/swiftui/composing-custom-layouts-with-swiftui

### 
#### 
The grid contains a  inside a , where each view in the row creates a column cell. So the first view appears in the first column, the second in the second column, and so on. Because the  appears outside of a grid row instance, it creates a row that spans the width of the grid.
```swift
Grid(alignment: .leading) {
    ForEach(model.pets) { pet in
        GridRow {
            Text(pet.type)
            ProgressView(
                value: Double(pet.votes),
                total: Double(max(1, model.totalVotes))) // Avoid dividing by zero.
            Text("\(pet.votes)")
                .gridColumnAlignment(.trailing)
        }

        Divider()
    }
}
```

#### 
To ensure the buttons all have the same width, but are no wider than the widest button text, the app creates a custom layout container type that conforms to the  protocol. The equal-width horizontal stack (`MyEqualWidthHStack`) measures the ideal sizes of all its subviews, and offers the widest ideal size to each subview.
The custom stack implements the protocol’s two required methods. First,  reports the container’s size, given a set of subviews.
```swift
func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Void
) -> CGSize {
    guard !subviews.isEmpty else { return .zero }

    let maxSize = maxSize(subviews: subviews)
    let spacing = spacing(subviews: subviews)
    let totalSpacing = spacing.reduce(0) { $0 + $1 }

    return CGSize(
        width: maxSize.width * CGFloat(subviews.count) + totalSpacing,
        height: maxSize.height)
}
```

```
This method combines the largest size in each dimension with the horizontal spacing between subviews to find the container’s total size. Then,  tells each of the subviews where to appear within the layout’s bounds.
```swift
func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Void
) {
    guard !subviews.isEmpty else { return }

    let maxSize = maxSize(subviews: subviews)
    let spacing = spacing(subviews: subviews)

    let placementProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
    var nextX = bounds.minX + maxSize.width / 2

    for index in subviews.indices {
        subviews[index].place(
            at: CGPoint(x: nextX, y: bounds.midY),
            anchor: .center,
            proposal: placementProposal)
        nextX += maxSize.width + spacing[index]
    }
}
```

#### 
The size of the voting buttons depends on the width of the text they contain. For people that speak another language or that use a larger text size, the horizontally arranged buttons might not fit in the display. So the app uses  to let SwiftUI choose between a horizontal and a vertical arrangement of the buttons for the one that fits in the available space.
```swift
ViewThatFits { // Choose the first view that fits.
    MyEqualWidthHStack { // Arrange horizontally if it fits...
        Buttons()
    }
    MyEqualWidthVStack { // ...or vertically, otherwise.
        Buttons()
    }
}
```

#### 
First, the layout defines a `CacheData` type for the storage.
The methods of the  protocol take a bidirectional `cache` parameter. The cache provides access to optional storage that’s shared among all the methods of a particular layout instance. To demonstrate the use of a cache, the sample app’s equal-width vertical layout creates storage to share size and spacing calculations between its  and  implementations.
First, the layout defines a `CacheData` type for the storage.
```swift
struct CacheData {
    let maxSize: CGSize
    let spacing: [CGFloat]
    let totalSpacing: CGFloat
}
```

```
It then implements the protocol’s optional  method to do the calculations for a set of subviews, returning a value of the type defined above.
```swift
func makeCache(subviews: Subviews) -> CacheData {
    let maxSize = maxSize(subviews: subviews)
    let spacing = spacing(subviews: subviews)
    let totalSpacing = spacing.reduce(0) { $0 + $1 }

    return CacheData(
        maxSize: maxSize,
        spacing: spacing,
        totalSpacing: totalSpacing)
}
```

```
If the subviews change, SwiftUI calls the layout’s  method. The default implementation of that method calls  again, which recalculates the data. Then the `sizeThatFits(proposal:subviews:cache:)` and `placeSubviews(in:proposal:subviews:cache:)` methods make use of their `cache` parameter to retrieve the data. For example, `placeSubviews(in:proposal:subviews:cache:)` reads the size and the spacing array from the cache.
```swift
let maxSize = cache.maxSize
let spacing = cache.spacing
```

#### 
To display the pet avatars in a circle, the app defines a radial layout (`MyRadialLayout`).
Like other custom layouts, this layout needs the two required methods. For , the layout fills the available space by returning whatever size its container proposes.
```swift
proposal.replacingUnspecifiedDimensions()
```

```
The app uses the proposal’s  method to convert the proposal into a concrete size. Then, to place subviews, the layout rotates a vector, translates the vector to the middle of the placement region, and uses that as the anchor for the subview.
```swift
for (index, subview) in subviews.enumerated() {
    // Find a vector with an appropriate size and rotation.
    var point = CGPoint(x: 0, y: -radius)
        .applying(CGAffineTransform(
            rotationAngle: angle * Double(index) + offset))

    // Shift the vector to the middle of the region.
    point.x += bounds.midX
    point.y += bounds.midY

    // Place the subview.
    subview.place(at: point, anchor: .center, proposal: .unspecified)
}
```

#### 
The radial layout can calculate an offset that creates an appropriate arrangement for all but one set of rankings: there’s no way to show a three-way tie with the avatars in a circle. To resolve this, the app detects this condition, and uses it to put the avatars in a line instead, using a the  type, which is a version of the built-in  that conforms to the  protocol. To transition between these layout types, the app uses the  type.
```swift
let layout = model.isAllWayTie ? AnyLayout(HStackLayout()) : AnyLayout(MyRadialLayout())

Podium()
    .overlay(alignment: .top) {
        layout {
            ForEach(model.pets) { pet in
                Avatar(pet: pet)
                    .rank(model.rank(pet))
            }
        }
        .animation(.default, value: model.pets)
    }
```

#### 

## Configuring views
> https://developer.apple.com/documentation/swiftui/configuring-views

### 
#### 
Like other Swift methods, a modifier operates on an instance — a view of some kind in this case — and can optionally take input parameters. For example, you can apply the  modifier to set the color of a  view:
```swift
Text("Hello, World!")
    .foregroundStyle(.red) // Display red text.
```

#### 
You commonly chain modifiers, each wrapping the result of the previous one, by calling them one after the other. For example, you can wrap a text view in an invisible box with a given width using the  modifier to influence its layout, and then use the  modifier to draw an outline around that:
```swift
Text("Title")
    .frame(width: 100)
    .border(Color.gray)
```

By specifying the frame modifier after the border modifier, SwiftUI applies the border only to the text view, which never takes more space than it needs to render its contents.
```swift
Text("Title")
    .border(Color.gray) // Apply the border first this time.
    .frame(width: 100)
```

#### 
You can apply any view modifier defined by the  protocol to any concrete view, even when the modifier doesn’t have an immediate effect on its target view. The effects of a modifier propagate to child views that don’t explicitly override the modifier.
For example, a  instance on its own acts only to vertically stack other views — it doesn’t have any text to display. Therefore, applying a  modifier to the stack has no effect on the stack. Yet the font modifier does apply to any of the stack’s child views, some of which might display text. You can, however, locally override the stack’s modifier by adding another to a specific child view:
```swift
VStack {
    Text("Title")
        .font(.title) // Override the font of this view.
    Text("First body line.")
    Text("Second body line.")
}
.font(.body) // Set a default font for text in the stack.
```

#### 
While many view types rely on standard view modifiers for customization and control, some views do define modifiers that are specific to that view type. You can’t use such a modifier on anything but the appropriate kind of view. For example,  defines the  modifier as a convenience for adding a bold effect to the view’s text. While you can use  on any view because it’s part of the  protocol, you can use  only on  views. As a result, you can’t use it on a container view:
```swift
VStack {
    Text("Hello, world!")
}
.bold() // Fails because 'VStack' doesn't have a 'bold' modifier.
```

```
You also can’t use it on a  view after applying another general modifier because general modifiers return an . For example, the return value from the padding modifier isn’t , but rather an opaque result type that can’t take a bold modifier:
```swift
Text("Hello, world!")
    .padding()
    .bold() // Fails because 'some View' doesn't have a 'bold' modifier.
```

```
Instead, apply the bold modifier directly to the  view and then add the padding:
```swift
Text("Hello, world!")
    .bold() // Succeeds.
    .padding()
```


## Controlling the timing and movements of your animations
> https://developer.apple.com/documentation/swiftui/controlling-the-timing-and-movements-of-your-animations

### 
### 
To better understand how to create animations using a  or , start with a simple example that uses standard SwiftUI animations. The following code moves an emoji upwards by setting its offset to `-40.0`. To provide a smooth transition of the movement, the code uses the  function to apply a  animation after someone taps the emoji.
```swift
struct SimpleAnimationView: View {
    var emoji: String
    @State private var offset = 0.0

    var body: some View {
        EmojiView(emoji: emoji)
            .offset(y: offset)
            .onTapGesture {
                withAnimation(.bouncy) {
                    offset = -40.0
                }
            }
    }
}
```

```
This animation has a single, discrete step: move the emoji upward. However, an animation can have multiple steps, such as moving an emoji upwards then back to its original position. For example, the following code sets the offset to `-40.0` to move the emoji upward, and then sets the offset (`0.0`) to return the emoji back to its original position:
```swift
struct SimpleAnimationView: View {
    var emoji: String
    @State private var offset = 0.0

    var body: some View {
        EmojiView(emoji: emoji)
            .offset(y: offset)
            .onTapGesture {
                withAnimation(.bouncy) {
                    offset = -40.0
                } completion: {
                    withAnimation {
                        offset = 0.0
                    }
                }
            }
    }
}
```

### 
A  automatically advances through a set of given phases to create an animated transition. Use the  modifier to provide the animator the phases for changing the animation value. For example, the emoji bounce animation shown earlier has two phases: move up and move back. You can represent these phases using the Boolean values, `true` and `false`. When the phase is `true`, the emoji moves up to `-40.0`. When the phase is `false`, the emoji moves back to the original position by setting the offset to `0.0`.
```swift
struct TwoPhaseAnimationView: View {
    var emoji: String
    
    var body: some View {
        EmojiView(emoji: emoji)
            .phaseAnimator([false, true]) { content, phase in
                content.offset(y: phase ? -40.0 : 0.0)
            }
    }
}
```

This means that in the previous code, the phase animator calls `content` with the phase value of `false` when the view first appears. This sets the emoji’s offset to `0.0`. The phase animator then calls `content` with the `true` phase. This phase sets the offset to `-40.0`, causing the emoji to move upwards. After reaching that offset position, the animator calls `content` with the phase of `false`. This causes the emoji to move back to its original position by setting its offset to `0.0`.
This animation starts when the view appears. To start the animation based on an event, use the  modifier and provide a `trigger` value that animator observes for changes. The animator starts the animation when the value changes. For example, the following code increments the state variable `likeCount` each time a person taps the emoji. The code uses `likeCount` as the value that the phase animator observes for changes. Now whenever someone taps the emoji, it moves up and returns to its original position.
```swift
struct TwoPhaseAnimationView: View {
    var emoji: String
    @State private var likeCount = 1
    
    var body: some View {
        EmojiView(emoji: emoji)
            .phaseAnimator([false, true], trigger: likeCount) { content, phase in
                content.offset(y: phase ? -40.0 : 0.0)
            }
            .onTapGesture {
                likeCount += 1
            }
    }
}
```

```
So far, the phase animator uses the  animation to move the emoji. You can change that behavior by providing the `phaseAnimator` modifier an animation closure. In this closure, specify the type of animation to apply for each phase. For instance, the following code applies a  animation when the phase is `true`; otherwise, it applies the  animation:
```swift
struct TwoPhaseAnimationView: View {
    var emoji: String
    @State private var likeCount = 1
    
    var body: some View {
        EmojiView(emoji: emoji)
            .phaseAnimator([false, true], trigger: likeCount) { content, phase in
                content.offset(y: phase ? -40.0 : 0.0)
            } animation: { phase in
                phase ? .bouncy : .default
            }
            .onTapGesture {
                likeCount += 1
            }
    }
}
```

### 
While this bounce effect is nice, you can add more pizzazz to it. For instance, you could make the emoji increase in size as it moves upward, and then shrink back to normal size. To do this, you’ll add a third phase to the animation: scale.
To define the phases, create a custom type that lists the possible phases; for example:
```swift
private enum AnimationPhase: CaseIterable {
    case initial
    case move
    case scale
}
```

```
Next, to help simplify logic and reduce complexity, define computed properties that return the values to animate. For instance, to set the vertical offset to move the emoji, create a computed property that returns the offset based on the current phase:
```swift
private enum AnimationPhase: CaseIterable {
    case initial
    case move
    case scale
    
    var verticalOffset: Double {
        switch self {
        case .initial: 0
        case .move, .scale: -64
        }
    }
}
```

When at the initial phase, the offset is `0`, which is the original screen location for the emoji. But when the phase is `move` or `scale`, the offset is `-64`.
You can use the same approach (creating a computed property) for the scale effect to change the size of the emoji. Initially, the emoji appears at its original size, but increases in size during the move and scale phase, as shown here:
```swift
private enum AnimationPhase: CaseIterable {
    case initial
    case move
    case scale
    
    var verticalOffset: Double {
        switch self {
        case .initial: 0
        case .move, .scale: -64
        }
    }
    
    var scaleEffect: Double {
        switch self {
        case .initial: 1
        case .move, .scale: 1.5
        }
    }
}
```

```
To animate an emoji, apply the  modifier to the `EmojiView`. Provide the animator all cases from the custom `AnimationPhase` type. Then change the content based on the phase by applying the  and  modifiers. The values passed into these modifiers come from the computed properties, which helps keep the view code more readable.
```swift
struct ThreePhaseAnimationView: View {
    var emoji: String
    @State private var likeCount = 1
    
    var body: some View {
        EmojiView(emoji: emoji)
            .phaseAnimator(AnimationPhase.allCases, trigger: likeCount) { content, phase in
                content
                    .scaleEffect(phase.scaleEffect)
                    .offset(y: phase.verticalOffset)
            } animation: { phase in
                switch phase {
                case .initial: .smooth
                case .move: .easeInOut(duration: 0.3)
                case .scale: .spring(duration: 0.3, bounce: 0.7)
                }
            }
            .onTapGesture {
                likeCount += 1
            }
    }
}
```

### 
Unlike a phase animator, in which you model separate, discrete states, a keyframe animator generates interpolated values of the type that you specify. While an animation is in progress, the animator provides you with a value of this type on every frame so you can update the animating view by applying modifiers to it.
You define the type as a structure that contains the properties that you want to independently animate. For example, the following code defines four properties that determine the scale, stretch, position, and angle of an emoji:
```swift
private struct AnimationValues {
    var scale = 1.0
    var verticalStretch = 1.0
    var verticalOffset = 0.0
    var angle = Angle.zero
}
```

To create a animation using a keyframe animator, apply either the  or  modifier to the view that you want to animate. For instance, the following code applies the second modifier to `EmojiView`. The initial value for the animation is a new instance of `AnimationValues`, and the state variable `likeCount` is the value that the animator observes for changes as it did in the previous phase animation example.
```swift
struct KeyframeAnimationView: View {
    var emoji: String
    @State private var likeCount = 1
    
    var body: some View {
        EmojiView(emoji: emoji)
            .keyframeAnimator(
                initialValue: AnimationValues(),
                trigger: likeCount
            ) { content, value in
                // ...
            } keyframes: { _ in
                // ...
            }
            .onTapGesture {
                likeCount += 1
            }
    }
}
```

To apply modifiers to a view during the animation, provide a `content` closure to the keyframe animator. This closure includes two parameters:
To apply modifiers to a view during the animation, provide a `content` closure to the keyframe animator. This closure includes two parameters:
Use these parameters to apply modifiers to the view that SwiftUI is animating. For example, the following code uses these parameters to rotate, scale, stretch, and move an emoji:
```swift
struct KeyframeAnimationView: View {
    var emoji: String
    @State private var likeCount = 1
    
    var body: some View {
        EmojiView(emoji: emoji)
            .keyframeAnimator(
                initialValue: AnimationValues(),
                trigger: likeCount
            ) { content, value in
                content
                    .rotationEffect(value.angle)
                    .scaleEffect(value.scale)
                    .scaleEffect(y: value.verticalStretch)
                    .offset(y: value.verticalOffset)
            } keyframes: { _ in
                // ...
            }
            .onTapGesture {
                likeCount += 1
            }
    }
}
```

Next, define the keyframes. Keyframes let you build sophisticated animations with different keyframe for different properties. To make this possible, you organize the keyframes into tracks. Each track controls a different property of the type that you are animating. You associate a property to a track by providing the key path to the property when creating the track. For example, the following code adds a  for the `scale` property:
```swift
struct KeyframeAnimationView: View {
    var emoji: String
    @State private var likeCount = 1
    
    var body: some View {
        EmojiView(emoji: emoji)
            .keyframeAnimator(
                initialValue: AnimationValues(),
                trigger: likeCount
            ) { content, value in
                content
                    .rotationEffect(value.angle)
                    .scaleEffect(value.scale)
                    .scaleEffect(y: value.verticalStretch)
                    .offset(y: value.verticalOffset)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    // ...
                }
            }
            .onTapGesture {
                likeCount += 1
            }
    }
}
```

```
When creating a track, you use the declarative syntax in SwiftUI to add keyframes to the track. There are different kinds of keyframes, such as , , and . You can mix and match the different kinds of keyframes within a track. For example, the following code adds a track for the `scale` property that performs a combination of linear and spring animations:
```swift
struct KeyframeAnimationView: View {
    var emoji: String
    @State private var likeCount = 1
    
    var body: some View {
        EmojiView(emoji: emoji)
            .keyframeAnimator(
                initialValue: AnimationValues(),
                trigger: likeCount
            ) { content, value in
                content
                    .rotationEffect(value.angle)
                    .scaleEffect(value.scale)
                    .scaleEffect(y: value.verticalStretch)
                    .offset(y: value.verticalOffset)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    LinearKeyframe(1.0, duration: 0.36)
                    SpringKeyframe(1.5, duration: 0.8,
                        spring: .bouncy)
                    SpringKeyframe(1.0, spring: .bouncy)
                }
            }
            .onTapGesture {
                likeCount += 1
            }
    }
}
```

- `scale`
- `verticalStretch`
- `verticalOffset`
- `angle`
- `angle`
To animate all four, the animator needs four keyframe tracks as shown in the following code:
```swift
struct KeyframeAnimationView: View {
    var emoji: String
    @State private var likeCount = 1
    
    var body: some View {
        EmojiView(emoji: emoji)
            .keyframeAnimator(
                initialValue: AnimationValues(),
                trigger: likeCount
            ) { content, value in
                content
                    .rotationEffect(value.angle)
                    .scaleEffect(value.scale)
                    .scaleEffect(y: value.verticalStretch)
                    .offset(y: value.verticalOffset)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    LinearKeyframe(1.0, duration: 0.36)
                    SpringKeyframe(1.5, duration: 0.8, spring: .bouncy)
                    SpringKeyframe(1.0, spring: .bouncy)
                }
                
                KeyframeTrack(\.verticalOffset) {
                    LinearKeyframe(0.0, duration: 0.1)
                    SpringKeyframe(20.0, duration: 0.15, spring: .bouncy)
                    SpringKeyframe(-60.0, duration: 1.0, spring: .bouncy)
                    SpringKeyframe(0.0, spring: .bouncy)
                }

                KeyframeTrack(\.verticalStretch) {
                    CubicKeyframe(1.0, duration: 0.1)
                    CubicKeyframe(0.6, duration: 0.15)
                    CubicKeyframe(1.5, duration: 0.1)
                    CubicKeyframe(1.05, duration: 0.15)
                    CubicKeyframe(1.0, duration: 0.88)
                    CubicKeyframe(0.8, duration: 0.1)
                    CubicKeyframe(1.04, duration: 0.4)
                    CubicKeyframe(1.0, duration: 0.22)
                }

                KeyframeTrack(\.angle) {
                    CubicKeyframe(.zero, duration: 0.58)
                    CubicKeyframe(.degrees(16), duration: 0.125)
                    CubicKeyframe(.degrees(-16), duration: 0.125)
                    CubicKeyframe(.degrees(16), duration: 0.125)
                    CubicKeyframe(.zero, duration: 0.125)
                }
            }
            .onTapGesture {
                likeCount += 1
            }
    }
}
```


## Creating a tvOS media catalog app in SwiftUI
> https://developer.apple.com/documentation/swiftui/creating-a-tvos-media-catalog-app-in-swiftui

### 
- `ButtonsView` provides a showcase of the various button styles available in tvOS.
- `DescriptionView` provides an example of how to build a product page similar to those you see on the Apple TV app, with a custom material blur.
- `SearchView` shows an example of a simple search page using the  and  modifiers.
- `SidebarContentView` shows how to make a sectioned sidebar using the new tab bar APIs in tvOS 18.
- `HeroHeaderView` gives an example of creating a material gradient to blur content in a certain area, fading it into unblurred content.
#### 
Provide a separate  and  view in the button’s label closure to ensure the correct vertical appearance. Using a  usually results in a horizontal layout, and, depending on the current label style, may not give you the appearance you expect.
```swift
Button { /* action */ } label: {
    Image("discovery_portrait")
        .resizable()
        .frame(width: 250, height: 375)
    Text("Borderless Portrait")
}
```

By default, the button style locates the first `Image` within the button’s label and attaches a  hover effect to it, providing lift, a specular highlight, and gimbal motion effects.
To ensure the hover effect applies to exactly the right view, you can manually attach it to a particular subview of the button’s label using the  modifier. For instance, to ensure an SF Symbols image hovers along with its background, do the following:
```swift
Button { /* action */ } label: {
    Image(systemName: "person.circle")
        .font(.title)
        .background(Color.blue.grayscale(0.7))
        .hoverEffect(.highlight)
    Text("Shaped")
}
.buttonBorderShape(.circle)
```

```
You can also attach the hover effect to a custom view.
```swift
Button { /* action */ } label: {
    CodeSampleArtwork(size: .appIconSize)
        .frame(width: 400, height: 240)
        .hoverEffect(.highlight)
    Text("Custom Icon View")
}
```

#### 
For lockups with more dense information, consider using the  button style, which provides a platter and a more subtle motion effect on focus. Providing containers with padding as the button’s label gives you something similar to the search result lockups on the Apple TV app.
```swift
Button { /* action */ } label: {
    HStack(alignment: .top, spacing: 10) {
        Image( . . . )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))

        VStack(alignment: .leading) {
            Text(asset.title)
                .font(.body)
            Text("Subtitle text goes here, limited to two lines.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                ForEach(1..<4) { _ in
                    Image(systemName: "ellipsis.rectangle.fill")
                }
            }
            .foregroundStyle(.secondary)
        }
    }
    .padding(12)
}
```

```
You can also use a custom  to create a standard card-based lockup appearance while keeping your button’s declarations clean at the point of use.
```swift
struct CardOverlayLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .bottomLeading) {
            configuration.icon
                .resizable()
                .aspectRatio(400/240, contentMode: .fit)
                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: .black.opacity(0.6), location: 0.1),
                            .init(color: .black.opacity(0.2), location: 0.25),
                            .init(color: .black.opacity(0), location: 0.4)
                        ],
                        startPoint: .bottom, endPoint: .top
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.quaternary)
                }

            configuration.title
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .padding(6)
        }
        .frame(maxWidth: 400)
    }
}

Button { /* action */ } label: {
    Label("Title at the bottom", image: "discovery_landscape")
}
```

#### 
Disabling scroll clipping is necessary to allow the focus effects to scale up and lift each lockup. Shelves typically contain only a single style of lockup, so assign your button style on the outside of the shelf container.
```swift
ScrollView(.horizontal) {
    LazyHStack(spacing: 40) {
        ForEach(Asset.allCases) { asset in
            // . . .
        }
    }
}
.scrollClipDisabled()
.buttonStyle(.borderless)
```

To arrange your lockups nicely, use the  modifier to let SwiftUI determine the best size for each. You can specify how many lockups you want on the screen, and the amount of spacing your stack view provides. Then SwiftUI arranges the content so that the edges of the leading and trailing items align with the leading and trailing safe area insets of its container.
For borderless buttons, you can attach the modifier to the `Image` instance within the button’s label closure to make the image the source of the frame calculations and alignments.
```swift
asset.portraitImage
    .resizable()
    .aspectRatio(250 / 375, contentMode: .fit)
    .containerRelativeFrame(.horizontal, count: 6, spacing: 40)
Text(asset.title)
```

#### 
Define your showcase or header section as a stack with a container relative frame to make it take up a particular percentage of the available space. Attach a  modifier to the stack as well, so that its full width can act as a target for focus movement, which it then diverts to its content. Otherwise, moving focus up from the right side of the shelves below might fail, or might jump all the way to the tab bar because the focus engine searches for the nearest focusable view along a straight line from the currently focused item.
```swift
VStack(alignment: .leading) {
    // Header content.
}
.frame(maxWidth: .infinity, alignment: .leading)
.focusSection()
.containerRelativeFrame(.vertical, alignment: .topLeading) {
    length, _ in length * 0.8
}
```

```
The code above is the above-the-fold section. To detect when focus moves below the fold, use  to detect when the header view moves more than halfway off the screen.
```swift
.onScrollVisibilityChange { visible in
    // When the header scrolls more than 50% offscreen, toggle
    // to the below-the-fold state.
    withAnimation {
        belowFold = !visible
    }
}
```

```
You can define the background of your landing page using a full-screen image with a material in an overlay. Then you can turn the material into a gradient by masking it with a , and you can adjust the opacity of that gradient’s stops according to the view’s above- or below-the-fold status.
```swift
Image("beach_landscape")
    .resizable()
    .aspectRatio(contentMode: .fill)
    .overlay {
        // Build the gradient material by filling an area with a material, and
        // then masking that area using a linear gradient.
        Rectangle()
            .fill(.regularMaterial)
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .black, location: 0.25),
                        .init(color: .black.opacity(belowFold ? 1 : 0.3), location: 0.375),
                        .init(color: .black.opacity(belowFold ? 1 : 0), location: 0.5)
                    ],
                    startPoint: .bottom, endPoint: .top
                )
            }
    }
    .ignoresSafeArea()
```

#### 
You can implement a custom  to create a fold-snapping effect. Then add a check to determine whether the target of a scroll event is crossing a fold threshold, and update that target to either the top of the page (if moving upward) or to the top of your first content shelf (if moving downward). With your view already tracking the above/below fold state, it can pass that information into the behavior to indicate which operation to check for.
```swift
ScrollView {
    // . . .
}
.scrollTargetBehavior(
    FoldSnappingScrollTargetBehavior(
        aboveFold: !belowFold, showcaseHeight: showcaseHeight))

struct FoldSnappingScrollTargetBehavior: ScrollTargetBehavior {
    var aboveFold: Bool
    var showcaseHeight: CGFloat

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        // The view is above the fold and not moving far enough down, so make no
        // change.
        if aboveFold && target.rect.minY < showcaseHeight * 0.3 {
            return
        }

        // The view is below the fold, and the header isn't coming onscreen, so
        // make no change.
        if !aboveFold && target.rect.minY > showcaseHeight {
            return
        }

        // Upward movement: Require revealing over 30% of the header, or don't let
        // the scroll go upward.
        let showcaseRevealThreshold = showcaseHeight * 0.7
        let snapToHideRange = showcaseRevealThreshold...showcaseHeight

        if aboveFold || snapToHideRange.contains(target.rect.origin.y) {
            // Snap to align the first content shelf at the top of the screen.
            target.rect.origin.y = showcaseHeight
        }
        else {
            // Snap upward to reveal the header.
            target.rect.origin.y = 0
        }
    }
}
```

#### 
This makes each product’s page unique, with its defining artwork tinting the content. This is the same effect that root screen on the Apple TV uses — the system blurs the most recently displayed top-shelf image and uses it as the background of the tvOS home screen.
In your description view, you may want to display a stack of bordered buttons, and stretch each to the same width. SwiftUI implements bordered buttons by attaching a background to their labels, so increasing the size of the button view isn’t necessarily going to cause the background platter to grow. Instead, you need to specify that the  is able to expand, and its background then expands as well. Attaching a  modifier to the button’s label content achieves this for you.
```swift
VStack(spacing: 12) {
    Button { /* action */ } label: {
        Text("Sign Up")
            .font(.body.bold())
            .frame(maxWidth: .infinity)
    }

    Button { /* action */ } label: {
        Text("Buy or Rent")
            .font(.body.bold())
            .frame(maxWidth: .infinity)
    }

    Button { /* action */ } label: {
        Label("Add to Up Next", systemImage: "plus")
            .font(.body.bold())
            .frame(maxWidth: .infinity)
    }
}
```

```
When displaying your content’s description, allow it to truncate on the page, and place it within a  using the `.plain` style. People can then select it, and you can present the full description using an overlay view that you attach with the  modifier.
```swift
.fullScreenCover(isPresented: $showDescription) {
    VStack(alignment: .center) {
        Text(loremIpsum)
            .frame(maxWidth: 600)
    }
}
```

#### 
The search implementation consists of simple view modifiers that function identically on each Apple platform. The  modifier provides the entire search UI for you, binding the search field to the provided text. By attaching a  modifier, you can present a list of potential search keyword completions. These are commonly `Text` instances, but `Button` and  also work.
Be sure to sort your search results so that the content of your grid is stable and predictable.
```swift
ScrollView(.vertical) {
    LazyVGrid(
        columns: Array(repeating: .init(.flexible(), spacing: 40), count: 4), 
        spacing: 40
    ) {
        ForEach(/* matching assets, sorted */) { asset in
            Button { /* action */ } label: {
                asset.landscapeImage
                    .resizable()
                    .aspectRatio(16 / 9, contentMode: .fit)
                Text(asset.title)
            }
        }
    }
    .buttonStyle(.borderless)
}
.scrollClipDisabled()
.searchable(text: $searchTerm)
.searchSuggestions {
    ForEach(/* keywords matching search term */, id: \.self) { suggestion in
        Text(suggestion)
    }
}
```


## Creating performant scrollable stacks
> https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks

### 
#### 
Implementing repeating views or groups of views can be as simple as wrapping them in an  or  inside a .
```swift
ScrollView(.horizontal) {
    HStack {
        ProfileView()
        ProfileView()
        ProfileView()
        ProfileView()
        ProfileView()
    }
}
.frame(maxWidth: 500)
```

#### 
Use  to repeat views for the data in your app. From a list of profile data in a `profiles` array, use  to create one `ProfileView` per element in the array inside an .
```swift
ScrollView(.horizontal) {
    HStack {
        ForEach(profiles) { profile in
            ProfileView(profile: profile)
        }
    }
}
.frame(maxWidth: 500)
```

#### 
#### 
When profiling the above code, the View Body instrument shows that 1,000 `ProfileView` instances load into memory at the same time as the . You can also see the same number of  views load as the system loads each profile.
In this case, the solution is to replace the  with a  as the following code shows:
```swift
ScrollView(.horizontal) {
    LazyHStack {
        ForEach(profiles) { profile in
            ProfileView(profile: profile)
        }
    }
}
.frame(maxWidth: 500)
```


## Customizing window styles and state-restoration behavior in macOS
> https://developer.apple.com/documentation/swiftui/customizing-window-styles-and-state-restoration-behavior-in-macos

### 
### 
To remove the toolbar’s background, `ContentView` calls the  view method:
Destination Video uses a tab view as its main user interface component, and in macOS, this appears similar to a two-column navigation split view. In this configuration, each tab appears as an entry in the sidebar and participates in the app’s navigation. Because the sidebar provides a visual indication of where you are in that navigation hierarchy, and the app’s content doesn’t require any additional toolbar items, a toolbar isn’t necessary. Removing the toolbar can elevate the underlying content by letting it extend right up to the window’s edge.
To remove the toolbar’s background, `ContentView` calls the  view method:
```swift
.toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
```

```
And then removes the toolbar’s title:
```swift
.toolbar(removing: .title)
```

### 
To move a window in macOS, you typically drag that window’s toolbar. However, if you choose to remove the background from a toolbar, or hide the toolbar completely, use  to extend that window’s drag region and make sure the window is still draggable.
Destination Video’s `PlayerView` adds this gesture to a transparent overlay and inserts the overlay between the video content and the playback controls. This enables you to safely drag the window and not interfere with the system playback UI that AVKit provides.
```swift
.gesture(WindowDragGesture())
```

```
The player also uses the  view method to enable the installed window drag gesture to receive events that activate the window — for example, if the window is in the background and you click it and immediately drag.
```swift
.allowsWindowActivationEvents(true)
```

### 
Typically, a window zooms to either its defined maximum size, or as large as the display permits. However, you can use the  scene method to override this behavior and provide a size and position that’s more appropriate for the window’s contents. The app uses this method to provide a maximum size for the video player that maintains the video’s aspect ratio to prevent black bars appearing above and below it.
```swift
.windowIdealPlacement { proxy, context in
    let displayBounds = context.defaultDisplay.visibleRect
    let idealSize = proxy.sizeThatFits(.unspecified)
    
    // Calculate the content's aspect ratio.
    let aspectRatio = aspectRatio(of: idealSize)
    // Determine the deltas between the display's size and the content's size.
    let deltas = deltas(of: displayBounds.size, idealSize)
    
    // Calculate the window's zoomed size while maintaining the aspect ratio
    // of the content.
    let size = calculateZoomedSize(
        of: idealSize,
        inBounds: displayBounds,
        withAspectRatio: aspectRatio,
        andDeltas: deltas
    )
    
    // Position the window in the center of the display and return the
    // corresponding window placement.
    let position = position(of: size, centeredIn: displayBounds)
    return WindowPlacement(position, size: size)
}
```

### 
In macOS, state restoration is optional and a person enables (or disables) it systemwide in System Settings. By default, your SwiftUI app respects this setting, but you can choose to override it and specify the preferred restoration behavior for each of your app’s windows. For example, you may want to opt out of state restoration for a window that represents a transient activity, or where it’s difficult or expensive to restore the underlying state from a previous session.
When running in macOS, Destination Video uses the  view modifier to disable state restoration for the video player view.
```swift
.restorationBehavior(.disabled)
```


## Declaring a custom view
> https://developer.apple.com/documentation/swiftui/declaring-a-custom-view

### 
#### 
Declare a custom view type by defining a structure that conforms to the  protocol:
```swift
struct MyView: View {
}
```

#### 
The  protocol’s main requirement is that conforming types must define a  :
```swift
struct MyView: View {
    var body: some View {
    }
}
```

#### 
Describe your view’s appearance by adding content to the view’s body property. You can compose the body from built-in views that SwiftUI provides, as well as custom views that you’ve defined elsewhere. For example, you can create a body that draws the string “Hello, World!” using a built-in  view:
```swift
struct MyView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
```

In addition to views for specific kinds of content, controls, and indicators, like , , and , SwiftUI also provides built-in views that you can use to arrange other views. For example, you can vertically stack two  views using a :
```swift
struct MyView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
            Text("Glad to meet you.")
        }
    }
}
```

#### 
To configure the views in your view’s body, you apply view modifiers. A modifier is nothing more than a method called on a particular view. The method returns a new, altered view that effectively takes the place of the original in the view hierarchy.
SwiftUI extends the  protocol with a large set of methods for this purpose. All  protocol conformers — both built-in and custom views — have access to these methods that alter the behavior of a view in some way. For example, you can change the font of a text view by applying the  modifier:
```swift
struct MyView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .font(.title)
            Text("Glad to meet you.")
        }
    }
}
```

#### 
To supply inputs to your views, add properties. For example, you can make the font of the “Hello, World!” string configurable:
```swift
struct MyView: View {
    let helloFont: Font
    
    var body: some View {
        VStack {
            Text("Hello, World!")
                .font(helloFont)
            Text("Glad to meet you.")
        }
    }
}
```

#### 
After you define a view, you can incorporate it in other views, just like you do with built-in views. You add your view by declaring it at the point in the hierarchy at which you want it to appear. For example, you could put `MyView` in your app’s `ContentView`, which Xcode creates automatically as the root view of a new app:
```swift
struct ContentView: View {
    var body: some View {
        MyView(helloFont: .title)
    }
}
```


## Displaying data in lists
> https://developer.apple.com/documentation/swiftui/displaying-data-in-lists

### 
#### 
The most common use of  is for representing collections of information in your data model. The following example defines a `Person` as an  type with the properties `name` and `phoneNumber`. An array called `staff` contains two instances of this type.
```swift
struct Person: Identifiable {
     let id = UUID()
     var name: String
     var phoneNumber: String
 }

var staff = [
    Person(name: "Juan Chavez", phoneNumber: "(408) 555-4301"),
    Person(name: "Mei Chen", phoneNumber: "(919) 555-2481")
]
```

```
To present the contents of the array as a list, the example creates a `List` instance. The list’s content builder uses a  to iterate over the `staff` array. For each member of the array, the listing creates a row view by instantiating a new  that contains the name of the `Person`.
```swift
struct StaffList: View {
    var body: some View {
        List {
            ForEach(staff) { person in
                Text(person.name)
            }
        }
    }
}
```

#### 
Each row inside a  must be a SwiftUI . You may be able to represent your data with a single view such as an  or  view, or you may need to define a custom view to compose several views into something more complex.
As your row views get more sophisticated, refactor the views into separate view structures, passing in the data that the row needs to render. The following example defines a `PersonRowView` to create a two-line view for a `Person`, using fonts, colors, and the system “phone” icon image to visually style the data.
```swift
struct PersonRowView: View {
    var person: Person

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(person.name)
                .foregroundColor(.primary)
                .font(.headline)
            HStack(spacing: 3) {
                Label(person.phoneNumber, systemImage: "phone")
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
        }
    }
}

struct StaffList: View {
    var body: some View {
        List {
            ForEach(staff) { person in
                PersonRowView(person: person)
            }
        }
    }
}
```

#### 
 views can also display data with a level of hierarchy, grouping associated data into sections.
Consider an expanded data model that represents an entire company, including multiple departments. Each `Department` has a name and an array of `Person` instances, and the company has an array of the `Department` type.
```swift
struct Department: Identifiable {
    let id = UUID()
    var name: String
    var staff: [Person]
}

struct Company {
    var departments: [Department]
}

var company = Company(departments: [
    Department(name: "Sales", staff: [
        Person(name: "Juan Chavez", phoneNumber: "(408) 555-4301"),
        Person(name: "Mei Chen", phoneNumber: "(919) 555-2481"),
        // ...
    ]),
    Department(name: "Engineering", staff: [
        Person(name: "Bill James", phoneNumber: "(408) 555-4450"),
        Person(name: "Anne Johnson", phoneNumber: "(417) 555-9311"),
        // ...
    ]),
    // ...
])
```

```
Use  views to give the data inside a `List` a level of hierarchy. Start by creating the `List`, using a  to iterate over the `company.departments` array, and then create `Section` views for each department. Within the section’s view builder, use a `ForEach` to iterate over the department’s `staff`, and return a customized view for each `Person`.
```swift
List {
    ForEach(company.departments) { department in
        Section {
            ForEach(department.staff) { person in
                PersonRowView(person: person)
            }
        } header: {
            Text(department.name)
        }
    }
 }
```

#### 
Using a  within a  contained inside a  adds platform-appropriate visual styling for navigation. SwiftUI navigates to a destination view you provide when a person chooses a list item.
The following example sets up a navigation-based UI by wrapping the list with a navigation stack. Instances of `NavigationLink` wrap the list’s rows to provide a `destination` view to navigate to when a person taps the row.
```swift
NavigationStack {
    List {
        ForEach(company.departments) { department in
            Section {
                ForEach(department.staff) { person in
                    NavigationLink {
                        PersonDetailView(person: person)
                    } label: {
                        PersonRowView(person: person)
                    }
                }
            } header: {
                Text(department.name)
            }
        }
    }
    .navigationTitle("Staff Directory")
}
```

```
In this example, the view passed in as the `destination` is a `PersonDetailView`, which repeats the information from the list. In a more complex app, this detail view could show more information about a `Person` than would fit inside the list row.
```swift
struct PersonDetailView: View {
    var person: Person

    var body: some View {
        VStack {
            Text(person.name)
                .foregroundColor(.primary)
                .font(.title)
                .padding()
            HStack {
                Label(person.phoneNumber, systemImage: "phone")
            }
            .foregroundColor(.secondary)
        }
    }
}
```


## Enhancing your app’s content with tab navigation
> https://developer.apple.com/documentation/swiftui/enhancing-your-app-content-with-tab-navigation

### 
#### 
You can create a  with an explicit selection binding using the  initializer. To add a tab within a `TabView` initialize a . Destination Video uses the  initializer to create each tab:
```swift
@State private var selectedTab: Tabs = .watchNow

var body: some View {
    TabView(selection: $selectedTab) {
        Tab("Watch Now", systemImage: "play", value: .watchNow) {
            WatchNowView()
        }
        // More tabs...
    }
}
```

```
The selection value type of the `TabView` matches the value type of the tabs it contains. In this case, the value of each `Tab` is of type `Tabs`, which this sample defines the following enumeration:
```swift
enum Tabs: Equatable, Hashable, Identifiable {
    case watchNow
    case library
    case new
    case favorites
    case search
}
```

- The default system symbol for search, a magnifying glass
- The default pinned behavior for search, the system automatically pins it in the tab bar
```swift
Tab(value: .search, role: .search) {
    // ...
}
```

#### 
You can use a  to declare a secondary tab hierarchy within a `TabView`. For example Destination Video uses the  initializer to create tab sections.
You can use a  to declare a secondary tab hierarchy within a `TabView`. For example Destination Video uses the  initializer to create tab sections.
```swift
TabView(selection: $selectedTab) {
    Tab("Watch Now", systemImage: "play", value: .watchNow) {
        WatchNowView()
    }

    // More tabs...
    
    TabSection {
        Tab("Cinematic Shots", systemImage: "list.and.film", value: .collections(.cinematic)) {
            // ...
        }
    } header: {
        Label("Collections", systemImage: "folder")
    }
}
```

Then it extends the `Tabs` enumeration to account for secondary tabs:
```
Then it extends the `Tabs` enumeration to account for secondary tabs:
```swift
enum Tabs: Equatable, Hashable, Identifiable {
    case watchNow
    // ..
    case search
    case collections(Category)
    case animations(Category)
}

enum Category: Equatable, Hashable, Identifiable, CaseIterable {
    case cinematic
    case forest
    case sea
    // ...
}
```

This sample uses a  loop to iterate and initialize a new `Tab` for each tab value.
```
This sample uses a  loop to iterate and initialize a new `Tab` for each tab value.
```swift
TabSection {
    ForEach(Category.collectionsList) { collection in
        Tab(collection.name, systemImage: collection.icon, value: Tabs.collections(collection)) {
            // ..
        }
    }
} header: {
    Label("Collections", systemImage: "folder")
}
```

#### 
To create an adaptable tab bar, Destination Video adds the  modifier to its `TabView` and passes in the value .
Tab bars with the  style allow people to toggle between the sidebar and tab bar. This lets your app leverage the convenience of being able to quickly navigate to top-level destinations within a compact tab bar while providing rich navigation hierarchy and destination options in the sidebar.
To create an adaptable tab bar, Destination Video adds the  modifier to its `TabView` and passes in the value .
```swift
TabView(selection: $selectedTab) {
    // Tabs
    // ..
}
.tabViewStyle(.sidebarAdaptable)

```

A `TabView` with the `sidebarAdaptable` style appears differently depending on the platform, as shown in the following images.
#### 
- Reorder tabs in the tab bar
To enable customizations, this sample defines a  and attaches it to the `TabView` using the  modifier. To persist the customization, this sample adds  with an identifier for a  `TabViewCustomization` variable. Finally, it adds the  modifier to each tab.
```swift
@AppStorage("sidebarCustomizations") var tabViewCustomization: TabViewCustomization
@State private var selectedTab: Tabs = .watchNow

var body: some View {
    TabView(selection: $selectedTab) {
        Tab("Watch Now", systemImage: "play", value: .watchNow) {
            WatchNowView()
        }
        .customizationID(Tabs.watchNow.customizationID)

        // More tabs...

    }
    .tabViewCustomization($tabViewCustomization)
}
```

```
To keep the most important tabs visible and in a fixed position, turn off customization behavior for those tabs using the  modifier.
```swift
Tab("Watch Now", systemImage: "play", value: .watchNow) {
    WatchNowView()
}
.customizationBehavior(.disabled, for: .sidebar, .tabBar)
```

#### 
In iPadOS, if there are too many tabs to fit in the screen, the system collapses the tabs that don’t fit and enables scrolling. However, having too many tabs can make it harder for people to locate the tab they’re looking for and navigate your app. Consider limiting the number of tabs so they all fit in the tab bar. The  modifier sets the default visibility of a `Tab` or `TabSection`.
Destination Video contains five tabs and two tab sections, each tab section contains multiple secondary tabs, but only seven tabs appear in the tab bar. In order to limit the tab bar to the most important tabs, all tabs within a `TabSection` are hidden from the tab bar by default.
```swift
TabSection {
    // Tabs
} header {
    // Section header
}
.defaultVisibility(.hidden, for: .tabBar)
```


## Fitting images into available space
> https://developer.apple.com/documentation/swiftui/fitting-images-into-available-space

### 
#### 
The following example loads the image directly into an  view, and then places it in a 300 x 400 point frame, with a blue border:
```swift
    Image("Landscape_4")
        .frame(width: 300, height: 400, alignment: .topLeading)
        .border(.blue)
```

To fix this, you need to apply two modifiers to the `Image`:
-  tells the image view to adjust the image representation to match the size of the view. By default, this modifier scales the image by reducing the size of larger images and enlarges images smaller than the view. By itself, this modifier scales each axis of the image independently.
-  corrects the behavior where the image scaling is different for each axis. This preserves the image’s original aspect ratio, using one of two strategies defined by the  enumeration.  scales the image to fit the view size along one axis, possibly leaving empty space along the other axis.  scales the image to fill the entire view.
```swift
  Image("Landscape_4")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 300, height: 400, alignment: .topLeading)
      .border(.blue)
```

#### 
If you use  when scaling an image, a portion of an image may extend beyond the view’s bounds, unless the view matches the image’s aspect ratio exactly. The following example illustrates this problem:
```swift
    Image("Landscape_4")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 300, height: 400, alignment: .topLeading)
        .border(.blue)
```

To prevent this problem, add the  modifier. This modifier simply cuts off excess image rendering at the bounding frame of the view. Optionally, you can add an antialiasing behavior to apply smoothing to the edges of the clipping rectangle; this parameter defaults to `false`. The following example shows the effect of adding clipping to the previous fill-mode example:
```swift
    Image("Landscape_4")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 300, height: 400, alignment: .topLeading)
        .border(.blue)
        .clipped()
```

#### 
Rendering an image at anything other than its original size requires : using the existing image data to approximate a representation at a different size. Different approaches to performing interpolation have different trade-offs between computational complexity and visual quality of the rendered image. You can use the  modifier to provide a hint for SwiftUI rendering behavior.
It’s easier to see the effect of interpolation when scaling a smaller image into a larger space, because the rendered image requires more image data than is available. Consider the following example, which renders a 34 x 34 image named `dot_green` into the same 300 x 400 container frame as before:
```swift
    Image("dot_green")
        .resizable()
        .interpolation(.none)
        .aspectRatio(contentMode: .fit)
        .frame(width: 300, height: 400, alignment: .topLeading)
        .border(.blue)
```

#### 
When you have an image that’s much smaller than the space you want to render it into, another option  to fill the space is : repeating the same image over and over again. To tile an image, pass the  parameter to the  modifier:
```swift
    Image("dot_green")
        .resizable(resizingMode: .tile)
        .frame(width: 300, height: 400, alignment: .topLeading)
        .border(.blue)
```


## Food Truck: Building a SwiftUI multiplatform app
> https://developer.apple.com/documentation/swiftui/food-truck-building-a-swiftui-multiplatform-app

### 
#### 
6. In the `AccountManager.swift` file, replace all occurrences of `example.com` with the name of your domain.
#### 
#### 
The sample’s navigation interface consists of a  with a `Sidebar` view, and a :
The sample’s navigation interface consists of a  with a `Sidebar` view, and a :
```swift
NavigationSplitView {
    Sidebar(selection: $selection)
} detail: {
    NavigationStack(path: $path) {
        DetailColumn(selection: $selection, model: model)
    }
}
```

```
At app launch, the sample presents the `TruckView` as the default view. The `Panel` enum encodes the views the user can select in the sidebar, and hence appear in the detail view. The value corresponding to `TruckView` is `.truck`, and the app sets this to be the default selection.
```swift
@State private var selection: Panel? = Panel.truck
```

#### 
In the Truck view, the New Orders panel shows the five most-recent orders, and each order shows a `DonutStackView`, which is a diagonal stack of donut thumbnails. The  protocol allows the app to define a `DiagonalDonutStackLayout` that arranges the donut thumbnails into the diagonal layout. The layout’s  implementation calculates the donuts’ positions.
```swift
for index in subviews.indices {
    switch (index, subviews.count) {
    case (_, 1):
        subviews[index].place(
            at: center,
            anchor: .center,
            proposal: ProposedViewSize(size)
        )
        
    case (_, 2):
        let direction = index == 0 ? -1.0 : 1.0
        let offsetX = minBound * direction * 0.15
        let offsetY = minBound * direction * 0.20
        subviews[index].place(
            at: CGPoint(x: center.x + offsetX, y: center.y + offsetY),
            anchor: .center,
            proposal: ProposedViewSize(CGSize(width: size.width * 0.7, height: size.height * 0.7))
        )
    case (1, 3):
        subviews[index].place(
            at: center,
            anchor: .center,
            proposal: ProposedViewSize(CGSize(width: size.width * 0.65, height: size.height * 0.65))
        )
        
    case (_, 3):
        let direction = index == 0 ? -1.0 : 1.0
        let offsetX = minBound * direction * 0.15
        let offsetY = minBound * direction * 0.23
        subviews[index].place(
            at: CGPoint(x: center.x + offsetX, y: center.y + offsetY),
            anchor: .center,
            proposal: ProposedViewSize(CGSize(width: size.width * 0.7, height: size.height * 0.65))
        )
```

#### 
The sample contains several charts. The most popular items are shown on the `TopFiveDonutsView`. This chart is implemented in `TopDonutSalesChart`, which uses a  to construct a bar chart.
```swift
Chart {
    ForEach(sortedSales) { sale in
        BarMark(
            x: .value("Donut", sale.donut.name),
            y: .value("Sales", sale.sales)
        )
        .cornerRadius(6, style: .continuous)
        .foregroundStyle(.linearGradient(colors: [Color("BarBottomColor"), .accentColor], startPoint: .bottom, endPoint: .top))
        .annotation(position: .top, alignment: .top) {
            Text(sale.sales.formatted())
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(.quaternary.opacity(0.5), in: Capsule())
                .background(in: Capsule())
                .font(.caption)
        }
    }
}
```

```
The  axis of the chart shows labels with the names and thumbnails of the items that correspond to each data point.
```swift
.chartXAxis {
    AxisMarks { value in
        AxisValueLabel {
            let donut = donutFromAxisValue(for: value)
            VStack {
                DonutView(donut: donut)
                    .frame(height: 35)
                    
                Text(donut.name)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.center)
            }
            .frame(idealWidth: 80)
            .padding(.horizontal, 4)
            
        }
    }
}
```

#### 
The app shows a forecasted temperature graph in the Forecast panel in the Truck view. The app obtains this data from the  framework.
```swift
.task(id: city.id) {
    for parkingSpot in city.parkingSpots {
        do {
            let weather = try await WeatherService.shared.weather(for: parkingSpot.location)
            condition = weather.currentWeather.condition
            willRainSoon = weather.minuteForecast?.contains(where: { $0.precipitationChance >= 0.3 })
            cloudCover = weather.currentWeather.cloudCover
            temperature = weather.currentWeather.temperature
            symbolName = weather.currentWeather.symbolName
            
            let attribution = try await WeatherService.shared.attribution
            attributionLink = attribution.legalPageURL
            attributionLogo = colorScheme == .light ? attribution.combinedMarkLightURL : attribution.combinedMarkDarkURL
            
            if willRainSoon == false {
                spot = parkingSpot
                break
            }
        } catch {
            print("Could not gather weather information...", error.localizedDescription)
            condition = .clear
            willRainSoon = false
            cloudCover = 0.15
        }
    }
}
```

#### 
#### 
The app allows the food truck operator to keep track of order preparation time, which is guaranteed to be 60 seconds or less. To facilitate this, the app implements a toolbar button on the order details screen for orders with `placed` status. Tapping this button changes the order status to `preparing`, and creates an  instance to start a Live Activity, which shows the countdown timer and order details on an iPhone lock screen.
```swift
let timerSeconds = 60
let activityAttributes = TruckActivityAttributes(
    orderID: String(order.id.dropFirst(6)),
    order: order.donuts.map(\.id),
    sales: order.sales,
    activityName: "Order preparation activity."
)

let future = Date(timeIntervalSinceNow: Double(timerSeconds))

let initialContentState = TruckActivityAttributes.ContentState(timerRange: Date.now...future)

let activityContent = ActivityContent(state: initialContentState, staleDate: Calendar.current.date(byAdding: .minute, value: 2, to: Date())!)

do {
    let myActivity = try Activity<TruckActivityAttributes>.request(attributes: activityAttributes, content: activityContent,
        pushType: nil)
    print(" Requested MyActivity live activity. ID: \(myActivity.id)")
    postNotification()
} catch let error {
    print("Error requesting live activity: \(error.localizedDescription)")
}
```

```
The app also implements  to show the same information as on the lock screen in the Dynamic Island on iPhone 14 Pro devices.
```swift
DynamicIsland {
    DynamicIslandExpandedRegion(.leading) {
        ExpandedLeadingView()
    }

    DynamicIslandExpandedRegion(.trailing, priority: 1) {
        ExpandedTrailingView(orderNumber: context.attributes.orderID, timerInterval: context.state.timerRange)
            .dynamicIsland(verticalPlacement: .belowIfTooWide)
    }
} compactLeading: {
    Image("IslandCompactIcon")
        .padding(4)
        .background(.indigo.gradient, in: ContainerRelativeShape())
       
} compactTrailing: {
    Text(timerInterval: context.state.timerRange, countsDown: true)
        .monospacedDigit()
        .foregroundColor(Color("LightIndigo"))
        .frame(width: 40)
} minimal: {
    Image("IslandCompactIcon")
        .padding(4)
        .background(.indigo.gradient, in: ContainerRelativeShape())
}
.contentMargins(.trailing, 32, for: .expanded)
.contentMargins([.leading, .top, .bottom], 6, for: .compactLeading)
.contentMargins(.all, 6, for: .minimal)
.widgetURL(URL(string: "foodtruck://order/\(context.attributes.orderID)"))
```

```
Tapping the same button again changes the status to `complete`, and ends the Live Activity. This removes the Live Activity from the lock screen and from the Dynamic Island.
```swift
Task {
    for activity in Activity<TruckActivityAttributes>.activities {
        // Check if this is the activity associated with this order.
        if activity.attributes.orderID == String(order.id.dropFirst(6)) {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
```


## Grouping data with lazy stack views
> https://developer.apple.com/documentation/swiftui/grouping-data-with-lazy-stack-views

### 
#### 
As with views contained within a stack, each  must be uniquely identifiable when iterated by . In this example, `ColorData` instances represent the sections, and `ShadeData` instances represent the shades of each color inside a section. Both `ColorData` and `ShadeData` conform to the  protocol.
```swift
struct ColorData: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let variations: [ShadeData]

    struct ShadeData: Identifiable {
        let id = UUID()
        var brightness: Double
    }

    init(color: Color, name: String) {
        self.name = name
        self.color = color
        self.variations = stride(from: 0.0, to: 0.5, by: 0.1)
            .map { ShadeData(brightness: $0) }
    }
}
```

#### 
The `ColorSelectionView` below sets up an array containing `ColorData` instances for each primary color. The  iterates over the array of color data to create sections, then iterates over the `variations` to create views from the shades.
```swift
struct ColorSelectionView: View {
    let sections = [
        ColorData(color: .red, name: "Reds"),
        ColorData(color: .green, name: "Greens"),
        ColorData(color: .blue, name: "Blues")
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(sections) { section in
                    Section(header: SectionHeaderView(colorData: section)) {
                        ForEach(section.variations) { variation in
                            section.color
                                .brightness(variation.brightness)
                                .frame(height: 20)
                        }
                    }
                }
            }
        }
    }
}
```

```
Group data with  views and pass in a header or footer view with the `header` and `footer` properties. This example implements a `SectionHeaderView` as a header view, containing a semi-transparent stack view and the name of the section’s color in a  label.
```swift
struct SectionHeaderView: View {
    var colorData: ColorData

    var body: some View {
        HStack {
            Text(colorData.name)
                .font(.headline)
                .foregroundColor(colorData.color)
            Spacer()
        }
        .padding()
        .background(Color.primary
                        .colorInvert()
                        .opacity(0.75))
    }
}
```

#### 
By default, section header and footer views will scroll in sync with section content. If you want header and footer views to always remain visible, regardless of whether the top or bottom of the section is visible, then specify a set of  for the `pinnedViews` property of the lazy stack view.
```swift
LazyVStack(spacing: 1, pinnedViews: [.sectionHeaders]) {
    // ...
}
```


## Inspecting view layout
> https://developer.apple.com/documentation/swiftui/inspecting-view-layout

### 
#### 
Using Xcode previews, you can quickly see the size of a specific view element by selecting the view or child view in the editor. To illustrate this, the following example uses a  to vertically group an image, provided by , above a name:
```swift
struct StatusRow: View {
    let name: String

    var body: some View {
        VStack {
            Image(systemName: "person.circle")
            Text(name)
        }            
    }
}

struct StatusRow_Previews: PreviewProvider {
    static var previews: some View {
        StatusRow(name: "Maria")
    }
}
```

#### 
To see the border of more than one view, or to see a border when the view isn’t selected, temporarily add a border with the view modifier . Set the border’s color to something other than  to easily distinguish it from a border added by Xcode:
```swift
struct StatusRow: View {
    let name: String

    var body: some View {
        VStack {
            Image(systemName: "person.circle")
            Text(name)
                .border(Color.red)
        }
        .padding()
        .border(Color.gray)
    }
}
```


## Landmarks: Applying a background extension effect
> https://developer.apple.com/documentation/swiftui/landmarks-applying-a-background-extension-effect

### 
#### 
To apply the  to a view, align the leading edge of the view next to the sidebar, and align the trailing edge of the view to the trailing edge of the containing view.
In `LandmarksView`, the `LandmarkFeaturedItemView` and the containing  and  don’t have padding. This allows the `LandmarkFeaturedItemView` to align with the leading edge of the view next to the sidebar.
```swift
ScrollView(showsIndicators: false) {
    LazyVStack(alignment: .leading, spacing: Constants.standardPadding) {
        LandmarkFeaturedItemView(landmark: modelData.featuredLandmark!)
            .flexibleHeaderContent()
        //...
    }
}
```

#### 
In `LandmarkDetailView`, the sample applies the background extension effect to the main image by adding the  modifier:
In `LandmarkDetailView`, the sample applies the background extension effect to the main image by adding the  modifier:
```swift
Image(landmark.backgroundImageName)
    //...
    .backgroundExtensionEffect()
```

#### 
In `LandmarksView`, the `LandmarkFeaturedItemView` has an image from the featured landmark, and includes a title for the landmark and a button you can click or tap to learn more about that location.
To avoid having the landmark’s title and button appear under the sidebar in macOS, the sample applies the  modifier to the image before adding the overlay that includes the title and button:
```swift
Image(decorative: landmark.backgroundImageName)
    //...
    .backgroundExtensionEffect()
    .overlay(alignment: .bottom) {
        VStack {
            Text("Featured Landmark", comment: "Big headline in the main image of featured landmarks.")
                //...
            Text(landmark.name)
                //...
            Button("Learn More") {
                modelData.path.append(landmark)
            }
            //...
        }
        .padding([.bottom], Constants.learnMoreBottomPadding)
    }

```


## Landmarks: Displaying custom activity badges
> https://developer.apple.com/documentation/swiftui/landmarks-displaying-custom-activity-badges

### 
### 
To make the badges available in other views, like `CollectionsView`, the sample uses a custom modifier, `ShowBadgesViewModifier`, as a . The sample layers the badges over another view using a , and positions the badge view in the lower trailing corner:
```swift
private struct ShowsBadgesViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    BadgesView()
                        .padding()
                }
            }
        }
    }
}
```

The sample extends  by adding the `showBadges` modifier:
```
The sample extends  by adding the `showBadges` modifier:
```swift
extension View {
    func showsBadges() -> some View {
        modifier(ShowsBadgesViewModifier())
    }
}
```

### 
To create the toggle button, the sample configures a  using `ToggleBadgesLabel` which has different system images for the Show and Hide toggle states. To apply Liquid Glass, style the button with the  modifier:
```swift
Button {
    //...
} label: {
    //...
}
.buttonStyle(.glass)

```

### 
To add Liquid Glass to each badge, the sample uses the  modifier. To make a custom glass view appearance, the sample specifies a rectangular option with a corner radius:
```swift
BadgeLabel(badge: $0)
    .glassEffect(.regular, in: .rect(cornerRadius: Constants.badgeCornerRadius))
```

### 
- wraps the command that toggles the `isExpanded` property in 
- adds  to the toggle button
- wraps the command that toggles the `isExpanded` property in 
```swift
// Organizes the badges and toggle button to animate together.
GlassEffectContainer(spacing: Constants.badgeGlassSpacing) {
    VStack(alignment: .center, spacing: Constants.badgeButtonTopSpacing) {
        if isExpanded {
            VStack(spacing: Constants.badgeSpacing) {
                ForEach(modelData.earnedBadges) {
                    BadgeLabel(badge: $0)
                        // Adds Liquid Glass to the badge.
                        .glassEffect(.regular, in: .rect(cornerRadius: Constants.badgeCornerRadius))
                        // Adds an identifier to the badge for animation.
                        .glassEffectID($0.id, in: namespace)
                }
            }
        }

        Button {
            // Animates this button and badges when `isExpanded` changes values.
            withAnimation {
                isExpanded.toggle()
            }
        } label: {
            ToggleBadgesLabel(isExpanded: isExpanded)
                .frame(width: Constants.badgeShowHideButtonWidth,
                       height: Constants.badgeShowHideButtonHeight)
        }
        // Adds Liquid Glass to the button.
        .buttonStyle(.glass)
        #if os(macOS)
        .tint(.clear)
        #endif
        // Adds an identifier to the button for animation.
        .glassEffectID("togglebutton", in: namespace)
    }
    .frame(width: Constants.badgeFrameWidth)
}
```


## Landmarks: Extending horizontal scrolling under a sidebar or inspector
> https://developer.apple.com/documentation/swiftui/landmarks-extending-horizontal-scrolling-under-a-sidebar-or-inspector

### 
### 
To achieve this effect, the sample configures the `LandmarkHorizontalListView` so it touches the leading and trailing edges. When a scroll view touches the sidebar or inspector, the system automatically adjusts it to scroll under the sidebar or inspector and then off the edge of the screen.
The sample adds a  at the beginning of the  to inset the content so it aligns with the title padding:
```swift
ScrollView(.horizontal, showsIndicators: false) {
    LazyHStack(spacing: Constants.standardPadding) {
        Spacer()
            .frame(width: Constants.standardPadding)
        ForEach(landmarkList) { landmark in
            //...
        }
    }
}
```


## Landmarks: Refining the system provided Liquid Glass effect in toolbars
> https://developer.apple.com/documentation/swiftui/landmarks-refining-the-system-provided-glass-effect-in-toolbars

### 
This sample demonstrates how to refine the system provided glass effect in toolbars. In `LandmarkDetailView`, the sample adds toolbar items for:
### 
To organize the toolbar items into logical groupings, the sample adds  items and passes  as the `sizing` parameter to divide the toolbar into sections:
```swift
.toolbar {
    ToolbarSpacer(.flexible)

    ToolbarItem {
        ShareLink(item: landmark, preview: landmark.sharePreview)
    }

    ToolbarSpacer(.fixed)
    
    ToolbarItemGroup {
        LandmarkFavoriteButton(landmark: landmark)
        LandmarkCollectionsMenu(landmark: landmark)
    }
    
    ToolbarSpacer(.fixed)

    ToolbarItem {
        Button("Info", systemImage: "info") {
            modelData.selectedLandmark = landmark
            modelData.isLandmarkInspectorPresented.toggle()
        }
    }
}
```


## Laying out a simple view
> https://developer.apple.com/documentation/swiftui/laying-out-a-simple-view

### 
#### 
The following example creates a view to display an incoming message from a messaging service. The view uses an  to collect a view that identifies the sender and another that provides the content of the message:
```swift
struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.yellow)
                Text(message.initials)
            }

            Text(message.content)
        }
    }
}
```

#### 
You can constrain a view to a fixed size by adding a frame modifier. For example, use the  modifier to limit the width the circle to `40` points:
- Have an ideal size that never varies, like  or .
You can constrain a view to a fixed size by adding a frame modifier. For example, use the  modifier to limit the width the circle to `40` points:
```swift
struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.yellow)
                Text(message.initials)
            }
            .frame(width: 40)

            Text(message.content)
        }
    }
}
```

#### 
If you want the top of the circle aligned with the top of the message content text, you can refine the view by applying an alignment to the . To position the content vertically within the stack, specify the `alignment` parameter to :
```swift
struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack(alignment: .top) {
            ZStack {
                Circle()
                    .fill(Color.yellow)
                Text(message.initials)
            }
            .frame(width: 40)

            Text(message.content)
        }
    }
}
```

In the previous section, you applied a frame with only a width constraint. SwiftUI drew a circle limited by that width. But because the height was left unspecified, the circle’s frame separately expanded to fill the available height, even though that extra space had no visible impact on the rendered circle. You can resolve this problem by adding an explicit `height` parameter:
```swift
struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack(alignment: .top) {
            ZStack {
                Circle()
                    .fill(Color.yellow)
                Text(message.initials)
            }
            .frame(width: 40, height: 40)

            Text(message.content)
        }
    }
}
```

#### 
To avoid visually crowding the outer edges of a view, add padding. This introduces a fixed amount of space along the specified edges, reducing the space available for the contents of the view by a corresponding amount. For example, you can use  to add extra space along the  edges of the :
```swift
struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack(alignment: .top) {
            ZStack {
                Circle()
                    .fill(Color.yellow)
                Text(message.initials)
            }
            .frame(width: 40, height: 40)

            Text(message.content)
        }
        .padding([.horizontal])
    }
}
```


## Loading and displaying a large data feed
> https://developer.apple.com/documentation/swiftui/loading-and-displaying-a-large-data-feed

### 
#### 
Both contexts are connected to the same . This configuration is more efficient than using a nested context.
The sample creates a main queue context by setting up a Core Data stack using , which initializes a main queue context in its  property.
```swift
let container = NSPersistentContainer(name: "Earthquakes")
```

```
Create a private queue context by calling the persistent container’s  method.
```swift
let taskContext = container.newBackgroundContext()
```

```
When the feed download finishes, the sample uses the task context to consume the feed in the background. In Core Data, every queue-based context has its own serial queue, and apps must serialize the tasks that manipulate the context with the queue by wrapping the code with a  — with or without the `await` keyword — or  closure.
```swift
try await taskContext.perform {
```

For more information about working with concurrency, see .
To efficiently handle large data sets, the sample uses  which accesses the store directly — without interacting with the context, triggering any key value observation, or allocating managed objects. The closure-style initializer of  allows apps to provide one record at a time when Core Data calls the `dictionaryHandler` closure, which helps apps keep their memory footprint low because they do not need to prepare a buffer for all records.
```swift
let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
if let fetchResult = try? taskContext.execute(batchInsertRequest),
   let batchInsertResult = fetchResult as? NSBatchInsertResult,
   let success = batchInsertResult.result as? Bool, success {
    return
}
```

#### 
- The data model contains a single entity, so all changes are relevant to the `List` and do not require parsing specific changes within the history.
-  fetches and retrieves results directly from the store, and the `List` refreshes its contents automatically.
Enable remote change notifications for a persistent store by setting the  option on the store description to `true`.
- SwiftUI is only concerned about the view context, so `QuakesProvider` observes the  notification to merge changes from the background context, performing the batch operations, into the view context.
Enable remote change notifications for a persistent store by setting the  option on the store description to `true`.
```swift
description.setOption(true as NSNumber,
                      forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
```

Enable persistent history tracking for a persistent store by setting the  option to `true` as well.
```
Enable persistent history tracking for a persistent store by setting the  option to `true` as well.
```swift
description.setOption(true as NSNumber,
                      forKey: NSPersistentHistoryTrackingKey)
```

```
Whenever changes occur within a persistent store, including writes by other processes, the store posts a remote change notification. When the sample receives the notification, it fetches the persistent history transactions and changes occurring after a given token. After the persistent history change request retrieves the history, the sample merges each transaction’s  into the view context via .
```swift
let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastToken)
let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
if let history = historyResult?.result as? [NSPersistentHistoryTransaction] {
    return history
}
```

```
After executing each  or , the sample dispatches any UI updates back to the main queue, to render them in SwiftUI.
```swift
let viewContext = container.viewContext
let tokens = await viewContext.perform {
    history.map { (transaction: NSPersistentHistoryTransaction) -> NSPersistentHistoryToken in
        viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
        return transaction.token
    }
}
```

#### 
The sample sets the `viewContext`’s  property to `false` to prevent Core Data from automatically merging changes every time the background context is saved.
```swift
container.viewContext.automaticallyMergesChangesFromParent = false
```

#### 
The `code` attribute uniquely identifies an earthquake record, so constraining the `Quake` entity on `code` ensures that no two stored records have the same `code` value.
Select the `Quake` entity in the data model editor. In the data model inspector, add a new constraint by clicking the + button under the Constraints list. A constraint placeholder appears.
```swift
comma, separated, properties
```

```
Double-click the placeholder to edit it. Enter the name of the attribute, or comma-separated list of attributes, to serve as unique constraints on the entity.
```swift
code
```

```
When saving a new record, the store now checks whether any record already exists with the same value for the constrained attribute. In the case of a conflict, an  policy comes into play, and the new record overwrites all fields in the existing record.
```swift
container.viewContext.automaticallyMergesChangesFromParent = false
```


## Making a view into a drag source
> https://developer.apple.com/documentation/swiftui/making-a-view-into-a-drag-source

### 
#### 
Use the `draggable(_:)` modifier to send or receive `Transferable` items within an app, among a collection of your own apps, or between your apps and other apps that support the import or export of a specified data format.
```swift
struct MyView: View {
    let name = "Mei Chen"
    
    var body: some View {
        Text(name)
            .draggable(name)
    }
}
```

```
Use the  modifier to define a custom preview for the dragged item.
```swift
    Text(name)
        .draggable(name) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 300, height: 300)
                    .foregroundStyle(.yellow.gradient)
                Text("Drop \(name)")
                    .font(.title)
                    .foregroundStyle(.red)
            }
        }
```

```
To customize the lift preview that the system shows as it transitions to displaying your custom `preview`, apply a  modifier with a  kind. For example, you can change the preview’s corner radius, as in the following code example:
```swift
    Text(name)
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 7))
        .draggable(name) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 300, height: 300)
                    .foregroundStyle(.yellow.gradient)
                Text("Drop \(name)")
                    .font(.title)
                    .foregroundStyle(.red)
            }
        }
```

#### 
Define a data model, representing a user profile, that is a type conforming to  with the properties `name` and `phoneNumber`.
To support drag operations of model objects, conform a model to the `Transferable` protocol to create a transferable item, and implement the  static property. Types like , , , and  already conform to `Transferable`, making them easy to use in drag-and-drop operations.
Define a data model, representing a user profile, that is a type conforming to  with the properties `name` and `phoneNumber`.
```swift
struct Profile: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var phoneNumber: String
}
```

```
Extend `Profile` to conform to the `Transferable` protocol to compose a transfer representation, and add  with the custom uniform type identifier `com.example.profile` to represent the `Profile` data structure.
```swift
extension Profile: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .profile)
        ProxyRepresentation(exporting: \.name)
    }
}
```

Make sure to include the custom uniform type identifier in the app’s `Info.plist` file. For more information, see .
Make sure to include the custom uniform type identifier in the app’s `Info.plist` file. For more information, see .
Declare new uniform type identifiers as convenience variables on . For an exported declaration, use the following code:
```swift
extension UTType {
    static var profile = UTType(exportedAs: "com.example.profile")
}
```

To use the `com.example.profile` content type for drag operations, pass in the profiles to the `draggable(_:)` modifier.
To add more transfer representations to a draggable item, specify one or more additional representations in order of preference. This ensures that the system uses the most suitable representation, depending on the content type that the receiver can accept for drag-and-drop operations. For more information, see .
To use the `com.example.profile` content type for drag operations, pass in the profiles to the `draggable(_:)` modifier.
```swift
struct ContentView: View {
    @State private var profiles = [
        Profile(name: "Juan Chavez", phoneNumber: "(408) 555-4301"),
        Profile(name: "Mei Chen", phoneNumber: "(919) 555-2481")
    ]
    
    var body: some View {
        List {
            ForEach(profiles) { profile in
                Text(profile.name)
                    .draggable(profile)
            }
        }
    }
}
```

#### 
Within a , you can use the  modifier to enable reordering. The modifier allows you to reorder list items by using a long press on a row, and then dragging it to a new location. Add the `onMove(perform:)` modifier to a `List` to enable the interaction.
```swift
    List {
        ForEach(profiles) { profile in
            Text(profile.name)
        }
        .onMove { indices, newOffset in
            // Update the items array based on source and destination indices.
            profiles.move(fromOffsets: indices, toOffset: newOffset)
        }
    }
```

To conditionally disable item reordering on a specific row, set  to `true`.

## Making fine adjustments to a view’s position
> https://developer.apple.com/documentation/swiftui/making-fine-adjustments-to-a-view-s-position

### 
#### 
The following example provides a view to illustrate how to position views, providing a rough layout of views composed within a . The stack contains a quadrant with an overlaid circle image:
```swift
struct Crosshairs: View { ... } // Draws crosshairs.

struct Quadrant: View {
    var body: some View {
        ZStack {
            Crosshairs()
            Rectangle()
                .stroke(Color.primary)
            Image(systemName: "circle")
        }
        .frame(width: 160, height: 160)
    }
}
```

#### 
The following example shifts the circle `40` points from the center, up and toward the trailing edge:
The following example shifts the circle `40` points from the center, up and toward the trailing edge:
```swift
struct Quadrant: View {
    var body: some View {
        ZStack {
            Crosshairs()
            Rectangle()
                .stroke(Color.primary)
            Image(systemName: "circle")
                .offset(x: 40.0, y: -40.0)
        }
        .frame(width: 160, height: 160)
    }
}
```

#### 
To explicitly position elements within a view, use the  view modifier. A position modifier overrides where the parent view places its content. The modifier renders the view at a location offset from the origin of the parent view, unlike an offset modifier that shifts the view from the location chosen by the parent view. The position modifier uses the same `x`, `y` coordinate system as the offset modifier, and similarly doesn’t influence the size of the view. In this example, the position of the circle is set halfway down on the right side of the quadrant with explicit values:
```swift
struct Quadrant: View {
    var body: some View {
        ZStack {
            Crosshairs()
            Rectangle()
                .stroke(Color.primary)
            Image(systemName: "circle")
                .position(x: 144, y: 80)
        }
        .frame(width: 160, height: 160)
    }
}
```


## Managing model data in your app
> https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app

### 
#### 
To make data changes visible to SwiftUI, apply the  macro to your data model. This macro generates code that adds observation support to your data model at compile time, keeping your data model code focused on the properties that store data. For example, the following code defines a data model for books:
```swift
@Observable class Book: Identifiable {
    var title = "Sample Book Title"
    var author = Author()
    var isAvailable = true
}
```

#### 
In SwiftUI, a view forms a dependency on an observable data model object, such as an instance of `Book`, when the view’s  property reads a property of the object. If `body` doesn’t read any properties of an observable data model object, the view doesn’t track any dependencies.
When a tracked property changes, SwiftUI updates the view. If other properties change that  doesn’t read, the view is unaffected and avoids unnecessary updates. For example, the view in the following code updates only when a book’s `title` changes but not when `author` or `isAvailable` changes:
```swift
struct BookView: View {
    var book: Book
    
    var body: some View {
        Text(book.title)
    }
}
```

```
SwiftUI establishes this dependency tracking even if the view doesn’t store the observable type, such as when using a global property or singleton:
```swift
var globalBook: Book = Book()

struct BookView: View {
    var body: some View {
        Text(globalBook.title)
    }
}
```

```
Observation also supports tracking of computed properties when the computed property makes use of an observable property. For instance, the view in the following code updates when the number of available books changes:
```swift
@Observable class Library {
    var books: [Book] = [Book(), Book(), Book()]
    
    var availableBooksCount: Int {
        books.filter(\.isAvailable).count
    }
}

struct LibraryView: View {
    @Environment(Library.self) private var library
    
    var body: some View {
        NavigationStack {
            List(library.books) { book in
                // ...
            }
            .navigationTitle("Books available: \(library.availableBooksCount)")
        }
    }
}
```

```
When a view forms a dependency on a collection of objects, of any collection type, the view tracks changes made to the collection itself. For instance, the view in the following code forms a dependency on `books` because `body` reads it. As changes occur to `books`, such as inserting, deleting, moving, or replacing items in the collection, SwiftUI updates the view.
```swift
struct LibraryView: View {
    @State private var books = [Book(), Book(), Book()]

    var body: some View {
        List(books) { book in 
            Text(book.title)
        }
    }
}
```

You can also share an observable model data object with another view. The receiving view forms a dependency if it reads any properties of the object in its . For example, in the following code `LibraryView` shares an instance of `Book` with `BookView`, and `BookView` displays the book’s `title`. If the book’s `title` changes, SwiftUI updates only `BookView`, and not `LibraryView`, because only `BookView` reads the `title` property.
```swift
struct LibraryView: View {
    @State private var books = [Book(), Book(), Book()]

    var body: some View {
        List(books) { book in 
            BookView(book: book)
        }
    }
}

struct BookView: View {
    var book: Book
    
    var body: some View {
        Text(book.title)
    }
}
```

```
If a view doesn’t have any dependencies, SwiftUI doesn’t update the view when data changes. This approach allows an observable model data object to pass through multiple layers of a view hierarchy without each intermediate view forming a dependency.
```swift
// Will not update when any property of `book` changes.
struct LibraryView: View {
    @State private var books = [Book(), Book(), Book()]
    
    var body: some View {
        List(books) { book in 
            LibraryItemView(book: book)
        }
    }
}

// Will not update when any property of `book` changes.
struct LibraryItemView: View {
    var book: Book
    
    var body: some View {
        BookView(book: book)
    }
}

// Will update when `book.title` changes.
struct BookView: View {
    var book: Book
    
    var body: some View {
        Text(book.title)
    }
}
```

```
However, a view that stores a reference to the observable object updates if the reference changes. This happens because the stored reference is part of the view’s value and not because the object is observable. For example, if the reference to book in the following code changes, SwiftUI updates the view:
```swift
struct BookView: View {
    var book: Book
    
    var body: some View {
        // ...
    }
}
```

```
A view can also form a dependency on an observable data model object accessed through another object. For example, the view in the following code updates when the author’s `name` changes:
```swift
struct LibraryItemView: View {
    var book: Book
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(book.title)
            Text("Written by: \(book.author.name)")
                .font(.caption)
        }
    }
}
```

#### 
To create and store the source of truth for model data, declare a private variable and initialize it with a instance of an observable data model type. Then wrap it with a  property wrapper. For example, the following code stores an instance of the data model type `Book` in the state variable `book`:
```swift
struct BookView: View {
    @State private var book = Book()
    
    var body: some View {
        Text(book.title)
    }
}
```

By wrapping the book with , you’re telling SwiftUI to manage the storage of the instance. Each time SwiftUI re-creates `BookView`, it connects the `book` variable to the managed instance, providing the view a single source of truth for the model data.
You can also create a state object in your top-level  instance or in one of your app’s  instances. For example, the following code creates an instance of `Library` in the app’s top-level structure:
```swift
@main
struct BookReaderApp: App {
    @State private var library = Library()
    
    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environment(library)
        }
    }
}
```

#### 
If you have a data model object, like `Library`, that you want to share throughout your app, you can either:
To share model data throughout a view hierarchy without needing to pass it to each view, add the model data to the view’s environment. You can add the data to the environment using either  or the  modifier, passing in the model data.
Before you can use the  modifier, you need to create a custom . Then extend  to include a custom environment property that gets and sets the value for the custom key. For instance, the following code creates an environment key and property for `library`:
```swift
extension EnvironmentValues {
    var library: Library {
        get { self[LibraryKey.self] }
        set { self[LibraryKey.self] = newValue }
    }
}

private struct LibraryKey: EnvironmentKey {
    static let defaultValue: Library = Library()
}
```

```
With the custom environment key and property in place, a view can add model data to its environment. For example, `LibraryView` adds the source of truth for a `Library` instance to its environment using the  modifier:
```swift
@main
struct BookReaderApp: App {
    @State private var library = Library()
    
    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environment(\.library, library)
        }
    }
}
```

```
To retrieve the `Library` instance from the environment, a view defines a local variable that stores a reference to the instance, and then wraps the variable with the  property wrapper, passing in the key path to the custom environment value.
```swift
struct LibraryView: View {
    @Environment(\.library) private var library

    var body: some View {
        // ...
    }
}
```

```
You can also store model data directly in the environment without defining a custom environment value by using the  modifier. For instance, the following code adds a `Library` instance to the environment using this modifier:
```swift
@main
struct BookReaderApp: App {
    @State private var library = Library()
    
    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environment(library)
        }
    }
}
```

```
To retrieve the instance from the environment, another view defines a local variable to store the instance and wraps it with the  property wrapper. But instead of providing a key path to the environment value, you can provide the model data type, as shown in the following code:
```swift
struct LibraryView: View {
    @Environment(Library.self) private var library
    
    var body: some View {
        // ...
    }
}
```

By default, reading an object from the environment returns a non-optional object when using the object type as the key. This default behavior assumes that a view in the current hierarchy previously stored a non-optional instance of the type using the  modifier. If a view attempts to retrieve an object using its type and that object isn’t in the environment, SwiftUI throws exception.
In cases where there is no guarantee that an object is in the environment, retrieve an optional version of the object as shown in the following code. If the object isn’t available in the environment, SwiftUI returns `nil` instead of throwing an exception.
```swift
@Environment(Library.self) private var library: Library?
```

#### 
In most apps, people can change data that the app presents. When data changes, any views that display the data should update to reflect the changed data. With Observation in SwiftUI, a view can support data changes without using property wrappers or bindings. For example, the following toggles the `isAvailable` property of a book in the action closure of a button:
```swift
struct BookView: View {
    var book: Book
    
    var body: some View {
        List {
            Text(book.title)
            HStack {
                Text(book.isAvailable ? "Available for checkout" : "Waiting for return")
                Spacer()
                Button(book.isAvailable ? "Check out" : "Return") {
                    book.isAvailable.toggle()
                }
            }
        }
    }
}
```

```
However, there may be times when a view expects a binding before it can change the value of a mutable property. To provide a binding, wrap the model data with the  property wrapper. For example, the following code wraps the `book` variable with `@Bindable`. Then it uses a  to change the `title` property of a book, and a  to change the `isAvailable` property, using the `$` syntax to pass a binding to each property.
```swift
struct BookEditView: View {
    @Bindable var book: Book
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack() {
            HStack {
                Text("Title")
                TextField("Title", text: $book.title)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        dismiss()
                    }
            }
            
            Toggle(isOn: $book.isAvailable) {
                Text("Book is available")
            }
            
            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

```
You can use the  property wrapper on properties and variables to an  object. This includes global variables, properties that exist outside of SwiftUI types, or even local variables. For example, you can create a `@Bindable` variable within a view’s :
```swift
struct LibraryView: View {
    @State private var books = [Book(), Book(), Book()]

    var body: some View {
        List(books) { book in 
            @Bindable var book = book
            TextField("Title", text: $book.title)
        }
    }
}
```


## Managing search interface activation
> https://developer.apple.com/documentation/swiftui/managing-search-interface-activation

### 
#### 
You can control search interface activation programmatically by providing the searchable modifier’s `isPresented` parameter with a  to a Boolean value. For example, to present a sheet that appears with the search interface already active, create a binding that starts as true:
```swift
struct SheetView: View {
    @State private var isPresented = true
    @State private var text = ""
  
    var body: some View {
        NavigationStack {
            SheetContent()
                .searchable(text: $text, isPresented: $isPresented)
        }
    }
}   
```

#### 
If you need to know when the search interface is active, you can query the environment’s  property using the  property wrapper. The following example shows a view that updates the text it displays based on the state of the property:
```swift
struct SearchingExample: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            SearchedView()
                .searchable(text: $searchText)
        }
    }
}

struct SearchedView: View {
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        Text(isSearching ? "Searching" : "Not searching")
    }
}
```

#### 
You can programmatically deactivate the interface using the environment’s  action. For example, consider a view with a  that presents more information about the first matching item from a collection:
```swift
struct ContentView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            SearchedView(searchText: searchText)
                .searchable(text: $searchText)
        }
    }
}

private struct SearchedView: View {
    var searchText: String

    let items = ["a", "b", "c"]
    var filteredItems: [String] { items.filter { $0 == searchText.lowercased() } }

    @State private var isPresented = false
    @Environment(\.dismissSearch) private var dismissSearch

    var body: some View {
        if let item = filteredItems.first {
            Button("Details about \(item)") {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    DetailView(item: item, dismissSearch: dismissSearch)
                }
            }
        }
    }
}
```

```
The button becomes visible only after someone enters search text that produces a match. The button’s action shows a sheet that provides more information about the item, including an Add button for adding the item to a stored list of items:
```swift
private struct DetailView: View {
    var item: String
    var dismissSearch: DismissSearchAction

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Text("Information about \(item).")
            .toolbar {
                Button("Add") {
                    // Store the item here...

                    dismiss()
                    dismissSearch()
                }
            }
    }
}
```

#### 
To specify an action that SwiftUI invokes when someone submits the search query (by pressing the Return key), add the  modifier:
```swift
SearchedView()
    .searchable(text: $searchText)
    .onSubmit(of: .search) {
        submitCurrentSearchQuery()
    }
```


## Managing user interface state
> https://developer.apple.com/documentation/swiftui/managing-user-interface-state

### 
#### 
If a view needs to store data that it can modify, declare a variable with the  property wrapper. For example, you can create an `isPlaying` Boolean inside a podcast player view to keep track of when a podcast is running:
```swift
struct PlayerView: View {
    @State private var isPlaying: Bool = false
    
    var body: some View {
        // ...
    }
}
```

```
Marking the property as state tells the framework to manage the underlying storage. Your view reads and writes the data, found in the state’s  property, by using the property name. When you change the value, SwiftUI updates the affected parts of the view. For example, you can add a button to the `PlayerView` that toggles the stored value when tapped, and that displays a different image depending on the stored value:
```swift
Button(action: {
    self.isPlaying.toggle()
}) {
    Image(systemName: isPlaying ? "pause.circle" : "play.circle")
}
```

#### 
To provide a view with data that the view doesn’t modify, declare a standard Swift property. For example, you can extend the podcast player to have an input structure that contains strings for the episode title and the show name:
```swift
struct PlayerView: View {
    let episode: Episode // The queued episode.
    @State private var isPlaying: Bool = false
    
    var body: some View {
        VStack {
            // Display information about the episode.
            Text(episode.title)
            Text(episode.showTitle)

            Button(action: {
                self.isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle" : "play.circle")
            }
        }
    }
}
```

#### 
If a view needs to share control of state with a child view, declare a property in the child with the  property wrapper. A binding represents a reference to existing storage, preserving a single source of truth for the underlying data. For example, if you refactor the podcast player view’s button into a child view called `PlayButton`, you can give it a binding to the `isPlaying` property:
```swift
struct PlayButton: View {
    @Binding var isPlaying: Bool
    
    var body: some View {
        Button(action: {
            self.isPlaying.toggle()
        }) {
            Image(systemName: isPlaying ? "pause.circle" : "play.circle")
        }
    }
}
```

As shown above, you read and write the binding’s wrapped value by referring directly to the property, just like state. But unlike a state property, the binding doesn’t have its own storage. Instead, it references a state property stored somewhere else, and provides a two-way connection to that storage.
When you instantiate `PlayButton`, provide a binding to the corresponding state variable declared in the parent view by prefixing it with the dollar sign (`$`):
```swift
struct PlayerView: View {
    var episode: Episode
    @State private var isPlaying: Bool = false
    
    var body: some View {
        VStack {
            Text(episode.title)
            Text(episode.showTitle)
            PlayButton(isPlaying: $isPlaying) // Pass a binding.
        }
    }
}
```

The `$` prefix asks a wrapped property for its , which for state is a binding to the underlying storage. Similarly, you can get a binding from a binding using the `$` prefix, allowing you to pass a binding through an arbitrary number of levels of view hierarchy.
You can also get a binding to a scoped value within a state variable. For example, if you declare `episode` as a state variable in the player’s parent view, and the episode structure also contains an `isFavorite` Boolean that you want to control with a toggle, then you can refer to `$episode.isFavorite` to get a binding to the episode’s favorite status:
```swift
struct Podcaster: View {
    @State private var episode = Episode(title: "Some Episode",
                                         showTitle: "Great Show",
                                         isFavorite: false)
    var body: some View {
        VStack {
            Toggle("Favorite", isOn: $episode.isFavorite) // Bind to the Boolean.
            PlayerView(episode: episode)
        }
    }
}
```

#### 
When the view state changes, SwiftUI updates affected views right away. If you want to smooth visual transitions, you can tell SwiftUI to animate them by wrapping the state change that triggers them in a call to the  function. For example, you can animate changes controlled by the `isPlaying` Boolean:
```swift
withAnimation(.easeInOut(duration: 1)) {
    self.isPlaying.toggle()
}
```

```
By changing `isPlaying` inside the animation function’s trailing closure, you tell SwiftUI to animate anything that depends on the wrapped value, like a scale effect on the button’s image:
```swift
Image(systemName: isPlaying ? "pause.circle" : "play.circle")
    .scaleEffect(isPlaying ? 1 : 1.5)
```

SwiftUI transitions the scale effect input over time between the given values of `1` and `1.5`, using the curve and duration that you specify, or reasonable default values if you provide none. On the other hand, the image content isn’t affected by the animation, even though the same Boolean dictates which system image to display. That’s because SwiftUI can’t incrementally transition in a meaningful way between the two strings `pause.circle` and `play.circle`.
You can add animation to a state property, or as in the above example, to a binding. Either way, SwiftUI animates any view changes that happen when the underlying stored value changes. For example, if you add a background color to the `PlayerView` — at a level of view hierarchy above the location of the animation block — SwiftUI animates that as well:
```swift
VStack {
    Text(episode.title)
    Text(episode.showTitle)
    PlayButton(isPlaying: $isPlaying)
}
.background(isPlaying ? Color.green : Color.red) // Transitions with animation.
```


## Migrating from the Observable Object protocol to the Observable macro
> https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro

### 
#### 
#### 
#### 
The only change made to the sample app so far is to apply the  macro to `Library` and remove support for the  protocol. The app still uses the  data flow primitive like  to manage an instance of `Library`. If you were to build and run the app, SwiftUI still updates the views as expected. That’s because data flow property wrappers such as  and  support types that use the  macro. SwiftUI provides this support so apps can make source code changes incrementally.
However, to fully adopt , replace the use of  with  after updating your data model type. For example, in the following code the main app structure creates an instance of `Library` and stores it as a `StateObject`. It also adds the `Library` instance to the environment using the  modifier.
```swift
// BEFORE
@main
struct BookReaderApp: App {
    @StateObject private var library = Library()

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environmentObject(library)
        }
    }
}
```

Now that `Library` no longer conforms to , the code can change to use  instead of  and to add `library` to the environment using the  modifier.
```
Now that `Library` no longer conforms to , the code can change to use  instead of  and to add `library` to the environment using the  modifier.
```swift
// AFTER
@main
struct BookReaderApp: App {
    @State private var library = Library()

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environment(library)
        }
    }
}
```

#### 

## Migrating to new navigation types
> https://developer.apple.com/documentation/swiftui/migrating-to-new-navigation-types

### 
#### 
If your app uses a  that you style using the  navigation view style, where people navigate by pushing a new view onto a stack, switch to .
In particular, stop doing this:
```swift
NavigationView { // This is deprecated.
    /* content */
}
.navigationViewStyle(.stack)
```

```
Instead, create a navigation stack:
```swift
NavigationStack {
    /* content */
}
```

#### 
If your app uses a two- or three-column , or for apps that have multiple columns in some cases and a single column in others — which is typical for apps that run on iPhone and iPad — switch to .
Instead of using a two-column navigation view:
```swift
NavigationView { // This is deprecated.
    /* column 1 */
    /* column 2 */
}
```

```
Create a navigation split view that has explicit sidebar and detail content using the  initializer:
```swift
NavigationSplitView {
    /* column 1 */
} detail: {
    /* column 2 */
}
```

```
Similarly, instead of using a three-column navigation view:
```swift
NavigationView { // This is deprecated.
    /* column 1 */
    /* column 2 */
    /* column 3 */
}
```

```
Create a navigation split view that has explicit sidebar, content, and detail components using the  initializer:
```swift
NavigationSplitView {
    /* column 1 */
} content: {
    /* column 2 */
} detail: {
    /* column 3 */
}
```

#### 
If you perform programmatic navigation using one of the  initializers that has an `isActive` input parameter, move the automation to the enclosing stack. Do this by changing your navigation links to use the  initializer, then use one of the navigation stack initializers that takes a path input, like .
For example, if you have a navigation view with links that activate in response to individual state variables:
```swift
@State private var isShowingPurple = false
@State private var isShowingPink = false
@State private var isShowingOrange = false

var body: some View {
    NavigationView { // This is deprecated.
        List {
            NavigationLink("Purple", isActive: $isShowingPurple) {
                ColorDetail(color: .purple)
            }
            NavigationLink("Pink", isActive: $isShowingPink) {
                ColorDetail(color: .pink)
            }
            NavigationLink("Orange", isActive: $isShowingOrange) {
                ColorDetail(color: .orange)
            }
        }
    }
    .navigationViewStyle(.stack) 
}
```

When some other part of your code sets one of the state variables to true, the navigation link that has the matching tag activates in response.
Rewrite this as a navigation stack that takes a path input:
```swift
@State private var path: [Color] = [] // Nothing on the stack by default.

var body: some View {
    NavigationStack(path: $path) {
        List {
            NavigationLink("Purple", value: .purple)
            NavigationLink("Pink", value: .pink)
            NavigationLink("Orange", value: .orange)
        }
        .navigationDestination(for: Color.self) { color in
            ColorDetail(color: color)
        }
    }
}
```

#### 
If you perform programmatic navigation on  elements that use one of the  initializers with a `selection` input parameter, you can move the selection to the list. For example, suppose you have a navigation view with links that activate in response to a `selection` state variable:
```swift
let colors: [Color] = [.purple, .pink, .orange]
@State private var selection: Color? = nil // Nothing selected by default.

var body: some View {
    NavigationView { // This is deprecated.
        List {
            ForEach(colors, id: \.self) { color in
                NavigationLink(color.description, tag: color, selection: $selection) {
                    ColorDetail(color: color)
                }
            }
        }
        Text("Pick a color")
    }
}
```

```
Using the same properties, you can rewrite the body as:
```swift
var body: some View {
    NavigationSplitView {
        List(colors, id: \.self, selection: $selection) { color in
            NavigationLink(color.description, value: color)
        }
    } detail: {
        if let color = selection {
            ColorDetail(color: color)
        } else {
            Text("Pick a color")
        }
    }
}
```

#### 
If your app needs to run on platform versions earlier than iOS 16, iPadOS 16, macOS 13, tvOS 16, watchOS 9, or visionOS 1, you can start migration while continuing to support older clients by using an . For example, you can create a custom wrapper view that conditionally uses either  or :
```swift
struct NavigationSplitViewWrapper<Sidebar, Content, Detail>: View
    where Sidebar: View, Content: View, Detail: View
{
    private var sidebar: Sidebar
    private var content: Content
    private var detail: Detail
    
    init(
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder content: () -> Content,
        @ViewBuilder detail:  () -> Detail
    ) {
        self.sidebar = sidebar()
        self.content = content()
        self.detail = detail()
    }
    
    var body: some View {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1, *) {
            // Use the latest API.
            NavigationSplitView {
                sidebar
            } content: {
                content
            } detail: {
                detail
            }
        } else {
            // Support previous platform versions.
            NavigationView {
                sidebar
                content
                detail
            }
            .navigationViewStyle(.columns)
        }
    }
}
```


## Migrating to the SwiftUI life cycle
> https://developer.apple.com/documentation/swiftui/migrating-to-the-swiftui-life-cycle

### 
#### 
3. Name the file `<YourAppName>App.swift`.
4. Add `import SwiftUI` at the top of the file.
5. Annotate the app structure with the `@main` attribute to indicate the entry point of the SwiftUI app, as shown in the code snippet below.
> **important:** Remove the `@main` or `@UIApplicationMain` attribute in your app delegate.
Use following code to create the SwiftUI app structure. To learn more about this structure, see .
```swift
import SwiftUI

@main
struct MyExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

#### 
To continue using methods in your app delegate, use the  property wrapper. To tell SwiftUI about a delegate that conforms to the  protocol, place this property wrapper inside your  declaration:
```swift
@main
struct MyExampleApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
    var body: some Scene { ... }
}
```

#### 
2. Remove `Main.storyboard` from the project navigator.
4. Open the `Info.plist` file.
6. Remove the  key in the  >  >  > `Item 0 (Default Configuration)` dictionary.
This figure shows the structure of the `Info.plist` file before removing these keys.
#### 
You will no longer be able to monitor life-cycle changes in your app delegate due to the scene-based nature of SwiftUI (see ). Prefer to handle these changes in , the life cycle enumeration that SwiftUI provides to monitor the phases of a scene. Observe the  value to initiate actions when the phase changes.
```swift
@Environment(\.scenePhase) private var scenePhase
```


## Model data
> https://developer.apple.com/documentation/swiftui/model-data

### 
#### 
SwiftUI implements many data management types, like  and , as Swift property wrappers. Apply a property wrapper by adding an attribute with the wrapper’s name to a property’s declaration.
```swift
@State private var isVisible = true // Declares isVisible as a state variable.
```

```
The property gains the behavior that the wrapper specifies. The state and data flow property wrappers in SwiftUI watch for changes in your data, and automatically update affected views as necessary. When you refer directly to the property in your code, you access the wrapped value, which for the `isVisible` state property in the example above is the stored Boolean.
```swift
if isVisible == true {
    Text("Hello") // Only renders when isVisible is true.
}
```

```
Alternatively, you can access a property wrapper’s projected value by prefixing the property name with the dollar sign (`$`). SwiftUI state and data flow property wrappers project a , which is a two-way connection to the wrapped value, allowing another view to access and mutate a single source of truth.
```swift
Toggle("Visible", isOn: $isVisible) // The toggle can update the stored value.
```


## Monitoring data changes in your app
> https://developer.apple.com/documentation/swiftui/monitoring-model-data-changes-in-your-app

### 
#### 
To make the data changes in your model visible to SwiftUI, adopt the  protocol for model classes. For example, you can create a `Book` class that’s an observable object:
```swift
class Book: ObservableObject {
}
```

```
The system automatically infers the  associated type for the class and synthesizes the required  method that emits the changed values of published properties. To publish a property, add the  property wrapper to the property’s declaration:
```swift
class Book: ObservableObject {
    @Published var title = "Sample Book Title"
}
```

```
Avoid the overhead of a published property when you don’t need it. Only publish properties that both can change and that matter to the UI. For example, the `Book` class might have an `identifier` property that never changes after initialization:
```swift
class Book: ObservableObject {
    @Published var title = "Sample Book Title"

    let identifier = UUID() // A unique identifier that never changes.
}
```

#### 
To tell SwiftUI to monitor an observable object, add the  property wrapper to the property’s declaration:
```swift
struct BookView: View {
    @ObservedObject var book: Book
    
    var body: some View {
        Text(book.title)
    }
}
```

```
You can pass individual properties of an observed object to child views, as shown above. When the data changes, like when you load new data from disk, SwiftUI updates all the affected views. You can also pass an entire observable object to a child view and share model objects across levels of a view hierarchy:
```swift
struct BookView: View {
    @ObservedObject var book: Book
    
    var body: some View {
        BookEditView(book: book)
    }
}

struct BookEditView: View {
    @ObservedObject var book: Book

    // ...
}
```

#### 
SwiftUI might create or recreate a view at any time, so it’s important that initializing a view with a given set of inputs always results in the same view. As a result, it’s unsafe to create an observed object inside a view. Instead, SwiftUI provides the  property wrapper, which creates a single source of truth for a reference type that you store in a view hierarchy. You can safely create a `Book` instance inside a view this way:
```swift
struct LibraryView: View {
    @StateObject private var book = Book()
    
    var body: some View {
        BookView(book: book)
    }
}
```

A state object behaves like an observed object, except that SwiftUI creates and manages a single object instance for a given view instance, regardless of how many times it recreates the view. You can use the object locally, or pass the state object into another view’s observed object property, as shown in the above example.
While SwiftUI doesn’t recreate the state object within a view, it does create a distinct object instance for each view instance. For example, each `LibraryView` in the following code gets a unique `Book` instance:
```swift
VStack {
    LibraryView()
    LibraryView()
}
```

```
You can also create a state object in your top level  instance, or in one of your app’s  instances. For example, if you define an observable object called `Library` to hold a collection of books for a book reader app, you could create a single library instance in the app’s top level structure:
```swift
@main
struct BookReader: App {
    @StateObject private var library = Library()

    // ...
}
```

#### 
If you have a data model object that you want to use throughout your app, but don’t want to pass it through many layers of hierarchy, you can use the  view modifier to put the object into the environment instead:
```swift
@main
struct BookReader: App {
    @StateObject private var library = Library()
    
    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environmentObject(library)
        }
    }
}
```

```
Any descendant view of the view to which you apply the modifier can then access the data model instance by declaring a property with the  property wrapper:
```swift
struct LibraryView: View {
    @EnvironmentObject var library: Library
    
    // ...
}
```

```
If you use an environment object, you might add it to the view at the top of your app’s hierarchy, as shown above. Alternatively, you might add it to the root view of a subtree in your view hierarchy. Either way, remember to also add it to the preview provider of any view that uses the object, or that has a descendant that uses the object:
```swift
struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
            .environmentObject(Library())
    }
}
```

#### 
When you allow a person to change the data in the UI, use a binding to the corresponding property. This ensures that updates flow back into the data model automatically. You can get a binding to an observed object, state object, or environment object property by prefixing the name of the object with the dollar sign (`$`). For example, if you let someone edit the title of a book by adding a  to the `BookEditView`, give the text field a binding to the book’s `title` property:
```swift
struct BookEditView: View {
    @ObservedObject var book: Book
    
    var body: some View {
        TextField("Title", text: $book.title)
    }
}
```


## Performing a search operation
> https://developer.apple.com/documentation/swiftui/performing-a-search-operation

### 
#### 
The searchable modifiers take a  to a string value for the `text` input. The string serves as the storage for the search query field that SwiftUI displays. You can create this storage inside a view using a  property, and initialize it to an empty string:
```swift
@State private var searchText: String = ""
```

```
To make it easier to share the search query among different views, you can create a published value inside an observable object that’s part of your app’s model:
```swift
class Model: ObservableObject {
    @Published var searchText: String = ""
}
```

In either case, pass a  to this string into the searchable view modifier by adding the dollar sign (`$`) prefix to the value:
```
In either case, pass a  to this string into the searchable view modifier by adding the dollar sign (`$`) prefix to the value:
```swift
struct ContentView: View {
    @EnvironmentObject private var model: Model
    @State private var departmentId: Department.ID?
    @State private var productId: Product.ID?

    var body: some View {
        NavigationSplitView {
            DepartmentList(departmentId: $departmentId)
        } content: {
            ProductList(departmentId: departmentId, productId: $productId)
                .searchable(text: $model.searchText)
        } detail: {
            ProductDetails(productId: productId)
        }
    }
}
```

#### 
In addition to a search string, the search field can also display tokens when you use one of the searchable modifiers that has a `tokens` parameter, like .
You create tokens by defining a group of values that conform to the  protocol, then instantiate the collection of values. For example you can create an enumeration of fruit tokens:
```swift
enum FruitToken: String, Identifiable, Hashable, CaseIterable {
    case apple
    case pear
    case banana
    var id: Self { self }
}
```

```
Then add a new published property to your model to store a collection of tokens:
```swift
@Published var tokens: [FruitToken] = []
```

```
To display tokens, provide a  to the `tokens` array as the searchable modifier’s `tokens` input parameter, and describe how to draw each token using the `token` closure. From the closure, return the  that represents the token given as an input. For example, you can use a  view to represent each token:
```swift
ProductList(departmentId: departmentId, productId: $productId)
    .searchable(text: $model.searchText, tokens: $model.tokens) { token in
        switch token {
        case .apple: Text("Apple")
        case .pear: Text("Pear")
        case .banana: Text("Banana")
        }
    }
```

#### 
You can enable people to mutate part of the data that represents a token by using a  in the `token` closure. For example, suppose you have fruit token data that contains both a kind and a hydration property:
```swift
struct FruitToken: String, Identifiable, Hashable, CaseIterable {
    enum Kind {
        case apple
        case pear
        case banana
        var id: Self { self }
    }

    enum Hydration: String, Identifiable, Hashable, CaseIterable {
        case hydrated
        case dehydrated
    }

    var kind: Kind
    var hydration: Hydration = .hydrated
}
```

```
With your new model, specify a  to the token in the `token` closure by adding a dollar sign (`$`). Use the binding to create a picker for the `hydration` property and a label that uses the `kind` property:
```swift
ProductList(departmentId: departmentId, productId: $productId)
    .searchable(text: $model.searchText, tokens: $model.tokens) { $token in
        Picker(selection: $token.hydration) {
            ForEach(FruitToken.Hydration.allCases) { hydration in
                switch hydration {
                case .hydrated: Text("Hydrated")
                case .dehydrated: Text("Dehydrated")
                }
            }
        } label: {
            switch token.kind {
            case .apple: Text("Apple")
            case .pear: Text("Pear")
            case .banana: Text("Banana")
            }
        }
    }
```

#### 
#### 
When you detect changes in the search query, your app can begin a search. How you perform the search operation depends on how your app stores and presents data. One approach is to filter the elements that appear in a  based on whether a field in the list’s items matches the search query. For example, you can create a method that returns only the items in an array of products with names that match the search text or one of the tokens currently in the search field:
```swift
func filteredProducts(
    products: [Product],
    searchText: String,
    tokens: [FruitToken]
) -> [Product] {
    guard !searchText.isEmpty || !tokens.isEmpty else { return products }
    return products.filter { product in
        product.name.lowercased().contains(searchText.lowercased()) ||
        tokens.map({ $0.rawValue }).contains(product.name.lowercased())
    }
}
```


## Populating SwiftUI menus with adaptive controls
> https://developer.apple.com/documentation/swiftui/populating-swiftui-menus-with-adaptive-controls

### 
#### 
#### 
To render a menu item that performs a given action closure, use the `Button` control:
A well-declared SwiftUI  resembles its ultimate rendered appearance: the contents of the menu visually adapt to the purpose of each element. For example, inserting a `Button` in the menu’s closure renders an actionable menu item, while inserting a `Menu` creates a submenu item.
To render a menu item that performs a given action closure, use the `Button` control:
```swift
Menu("Actions") {
    Button("Duplicate") {
        // Duplicate action.
    }
    Button("Rename") {
        // Rename action.
    }
    Button("Delete…") {
        // Delete action.
    }
}
```

To show a symbol next to the menu item title, use the  initializer:
```swift
Menu("Actions") {
    Button("Duplicate", systemImage: "doc.on.doc") {
        // Duplicate action.
    }
    Button("Rename", systemImage: "pencil") {
        // Rename action.
    }
    Button("Delete…", systemImage: "trash") {
        // Delete action.
    }
}
```

You can also construct menu actions by adding the label closure initializers on `Button`. This method provides more flexibility for your subtitles.
You can also construct menu actions by adding the label closure initializers on `Button`. This method provides more flexibility for your subtitles.
To add a title and subtitle to a menu item, populate the control’s label closure with two  views, in which the first text represents the title, and the second represents the subtitle. The following example shows this hierarchical style applied to the views:
```swift
Menu("Actions") {
    Button {
        // Duplicate action.
    } label: {
        Text("Duplicate")
        Text("Duplicate the component")
    }
    Button {
        // Rename action.
    } label: {
        Text("Rename")
        Text("Rename the component")
    }
    Button {
        // Delete action.
    } label: {
        Text("Delete…")
        Text("Delete the component")
    }
}
```

You can insert an icon by replacing the first `Text` with a :
You can insert an icon by replacing the first `Text` with a :
```swift
Menu("Actions") {
    Button {
        // Duplicate action.
    } label: {
        Label("Duplicate", systemImage: "doc.on.doc")
        Text("Duplicate the component")
    }
    Button {
        // Rename action.
    } label: {
        Label("Rename", systemImage: "pencil")
        Text("Rename the component")
    }
    Button {
        // Delete action.
    } label: {
        Label("Delete…", systemImage: "trash")
        Text("Delete the component")
    }
}
```

Add a visual warning cue to menu items that are destructive by nature. Add a  role to `Button` to tint the menu item red. Use `destructive` only for actions that require caution.
```swift
Menu("Actions") {
    // ...

    Button("Delete…", systemImage: "trash", role: .destructive) {
        // Delete action.
    }
}
```

On macOS, menu items constructed with a `Label` render without an icon by default. Use the  style to override the system behavior and explicitly render an icon for the menu items.
```swift
Menu("Actions") {
    // ...
}
.labelStyle(.titleAndIcon)
```

Menus are also great for representing toggled items. To render a toggled menu item, you can add a `Toggle` to the menu’s content.
Because SwiftUI controls adapt to their context, a `Toggle` in a menu automatically appears with a checkmark indicating its on or off state.
Menus are also great for representing toggled items. To render a toggled menu item, you can add a `Toggle` to the menu’s content.
Because SwiftUI controls adapt to their context, a `Toggle` in a menu automatically appears with a checkmark indicating its on or off state.
```swift
Menu("Actions") {
    // ...

    Toggle(
        "Favorite",
        systemImage: "suit.heart",
        isOn: $isFavorite)
}
```

Just like `Button`, initialize a `Toggle` with a label closure for more flexibility.
Just like `Button`, initialize a `Toggle` with a label closure for more flexibility.
```swift
Menu("Actions") {
    // ...

    Toggle(isOn: $isFavorite) {
        Label("Favorite", systemImage: "suit.heart")
        Text("Adds the component to the favorites list")
    }
}
```

Use a  within a menu to let people choose from a list of options:
```swift
enum Flavor: String, CaseIterable, Identifiable {
    case chocolate, vanilla, strawberry
    var id: Self { self }
}

@State private var selectedFlavor: Flavor = .chocolate

var body: some View {
    Picker("Flavor", selection: $selectedFlavor) {
        ForEach(Flavor.allCases) { flavor in
            Text(flavor.rawValue.capitalized)
                .tag(flavor)
        }
    }
}
```

This example embeds a picker within a menu, displaying multiple selectable items. Although you can select several options, only one item is active at any given time. The selected item, identified with a checkmark, indicates the current selection.
Adding a picker to a menu creates a more convenient and customized layout than several individual toggles. A picker provides a single interface to manage multiple options, ensuring a person can only select one item at a time. Multiple toggles might be more appropriate when your content doesn’t require mutual exclusivity.
```swift
enum Flavor: String, CaseIterable, Identifiable {
    case chocolate, vanilla, strawberry
    var id: Self { self }
}

@State private var selectedFlavor: Flavor = .chocolate
@State private var includesToppings: Bool = false

var body: some View {
    Menu("Ice Cream Order") {
        Button("Special request") {
            // Create a special request.
        }

        Toggle("Include toppings", isOn: $includesToppings)

        Picker("Flavor", selection: $selectedFlavor) {
            ForEach(Flavor.allCases) { flavor in
                Text(flavor.rawValue.capitalized)
                    .tag(flavor)
            }
        }
    }
}
```

#### 
By default, picker options in menus appear inline. SwiftUI implicitly applies the `inline` style, allowing you to select options without navigating away from the current view. The inline style works well for settings or configurations that require immediate context.
When you apply the `menu` style to a picker within a menu, it transforms into a submenu, presenting options in a hierarchical manner. This style helps organize complex menus with categorized options.
```swift
enum Flavor: String, CaseIterable, Identifiable {
    case chocolate, vanilla, strawberry
    var id: Self { self }
}

@State private var selectedFlavor: Flavor = .chocolate
@State private var includesToppings: Bool = false

var body: some View {
    Menu("Ice Cream Order") {
        Button("Special request") {
            // Create a special request.
        }

        Toggle("Include toppings", isOn: $includesToppings)

        Picker("Flavor", selection: $selectedFlavor) {
            ForEach(Flavor.allCases) { flavor in
                Text(flavor.rawValue.capitalized)
                    .tag(flavor)
            }
        }
        .pickerStyle(.menu)
    }
}
```

Palette pickers work best in compact scenarios in which someone chooses from a set of symbols. Palette pickers minimize icons, and turn into a horizontal scroll if there’s limited space.
```swift
enum Flavor: String, CaseIterable, Identifiable {
    case chocolate, vanilla, strawberry
    var id: Self { self }
}

@State private var selectedFlavor: Flavor = .chocolate
@State private var includesToppings: Bool = false

var body: some View {
    Menu("Ice Cream Order 3") {
        Button("Special request") {
            // Create a special request.
        }
        Toggle("Include toppings", isOn: $includesToppings)
        Picker("Flavor", selection: $selectedFlavor) {
            Text("🟤")
                .tag(Flavor.chocolate)
            Text("⚪️")
                .tag(Flavor.vanilla)
            Text("🔴")
                .tag(Flavor.strawberry)
        }
        .pickerStyle(.palette)
    }
}
```

Menus can also handle numerical values with sliders and steppers.
```swift
@State private var quantity: Int = 1

Menu("Actions") {
    // ...

    Stepper(value: $quantity) {
        Text("Quantity: \(quantity)")
    }
}
```

#### 
SwiftUI provides multiple ways to group items within menus, including submenus, sections, and dividers.
Submenus group items hierarchically, hiding content until needed. A submenu keeps the main menu uncluttered, while providing access to additional options when necessary:
```swift
Menu("General Settings") {
    // The General Settings submenu.
    Button("Wi-Fi") { openWiFiSettings() }
    Button("Bluetooth") { openBluetoothSettings() }
    Button("Notifications") { openNotificationSettings() }
    
    // The Account Settings submenu.
    Menu("Account Settings") {
        Button("Profile") { openProfileSettings() }
        Button("Security") { openSecuritySettings() }
        Button("Privacy") { openPrivacySettings() }
    }
    
    // The Advanced Settings submenu.
    Menu("Advanced Settings") {
        Button("Developer Options") { openDeveloperOptions() }
        Button("System Update") { openSystemUpdate() }
        Button("Backup & Restore") { openBackupRestore() }
    }
}
```

In the example above, the Settings menu populates with two submenus, grouping related and less-prominent settings actions.
You can also organize items with sections. The  view groups items while keeping all elements visible, often with section headers for clarity. This style is useful for organizing related items within the root-level menu, providing clear separation and context for each group.
```swift
Menu("Settings") {
    // The General Settings submenu.
    Section("General Settings") {
        Button("Wi-Fi") { openWiFiSettings() }
        Button("Bluetooth") { openBluetoothSettings() }
        Button("Notifications") { openNotificationSettings() }
    }
    
    // The Account Settings submenu.
    Section("Account Settings") {
        Button("Profile") { openProfileSettings() }
        Button("Security") { openSecuritySettings() }
        Button("Privacy") { openPrivacySettings() }
    }
    
    // The Advanced Settings submenu.
    Section("Advanced Settings") {
        Button("Developer Options") { openDeveloperOptions() }
        Button("System Update") { openSystemUpdate() }
        Button("Backup & Restore") { openBackupRestore() }
    }
}
```

#### 
When you want to display a few related actions in a single row within a menu, consider using a . This method provides a compact, horizontally-grouped layout of up to four items.
```swift
Menu("Edit") {
    ControlGroup {
        Button {
            // Undo action
        } label: {
            Label("Undo", systemImage: "arrow.uturn.backward")
        }
        
        Button {
            // Redo action
        } label: {
            Label("Redo", systemImage: "arrow.uturn.forward")
        }
        
        Button {
            // Copy action
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }
    }
    
    Divider()
    
    // Additional menu items here...
}
```

#### 
Beyond populating a menu’s content, SwiftUI also offers a set of APIs to modify the default behavior of menu items.
SwiftUI offers a set of APIs to modify the default behavior of menu items. On iOS and iPadOS, the system rearranges menu items by default so the first items in a menu appear closest to the viewer’s point of interaction. To override this behavior and keep items in the order you define, use the  modifier:
```swift
Menu("Settings", systemImage: "ellipsis.circle") {
    Button("Select") {
        // Select folders
    }
    Button("New Folder") {
        // Create folder
    }
    Picker("Appearance", selection: $appearance) {
        Label("Icons", systemImage: "square.grid.2x2").tag(Appearance.icons)
        Label("List", systemImage: "list.bullet").tag(Appearance.list)
    }
}
.menuOrder(.fixed)
```

- Increase and decrease actions that disable menu dismissal, letting someone click or tap them repeatedly to adjust the font size without re-opening the menu each time.
- A reset action that reverts the font to a default size. Because the action doesn’t disable the dismissal, the menu closes after resetting.
```swift
Menu("Font size") {
    Button(action: increase) {
        Label("Increase", systemImage: "plus.magnifyingglass")
    }
    .menuActionDismissBehavior(.disabled)
    Button("Reset", action: reset)
    Button(action: decrease) {
        Label("Decrease", systemImage: "minus.magnifyingglass")
    }
    .menuActionDismissBehavior(.disabled)
}
```


## Preparing views for localization
> https://developer.apple.com/documentation/swiftui/preparing-views-for-localization

### 
#### 
To ease the translation process, provide hints to translators that share how and where your app displays the strings of a  view. To add a hint, use the optional `comment` parameter to the text view initializer . When you localize your app with Xcode, it includes the comment string along with the string. For example, the following text view includes a comment:
```swift
Text("Explore",
     comment: "The title of the tab bar item that navigates to the Explore screen.")
```

#### 
You can localize many SwiftUI views that have a string label by providing a string that SwiftUI interprets as a . The system uses the key to retrieve a localized value from your string catalog at runtime, or uses the string directly if it can’t find the key in the catalog. For example, SwiftUI uses the string input to the following  initializer as a localized string key:
```swift
Label("Message", image: "msgSymbol")
```

```
If you additionally want to provide a comment for localization, you can use an explicit  view instead:
```swift
Label {
    Text("Message",
         comment: "A label that displays 'Message' and a corresponding image.")
} icon: {
    Image("msgSymbol")
}
```


## Reducing view modifier maintenance
> https://developer.apple.com/documentation/swiftui/reducing-view-modifier-maintenance

### 
#### 
When you create your custom modifier, name it to reflect the purpose of the collection. For example, if you repeatedly apply the  font style and a secondary color scheme to views to represent a secondary styling, collect them together as `CaptionTextFormat`:
```swift
struct CaptionTextFormat: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
```

```
Apply your modifier using the  method. The following code applies the above example to a  instance:
```swift
Text("Some additional information...")
    .modifier(CaptionTextFormat())
```

#### 
To make your custom view modifier conveniently accessible, extend the  protocol with a function that applies your modifier:
```swift
extension View {
    func captionTextFormat() -> some View {
        modifier(CaptionTextFormat())
    }
}
```

```
Apply the modifier to a text view by including this extension:
```swift
Text("Some additional information...")
    .captionTextFormat()
```


## Restoring your app’s state with SwiftUI
> https://developer.apple.com/documentation/swiftui/restoring-your-app-s-state-with-swiftui

### 
#### 
#### 
#### 
SwiftUI has the concept of “storing scene data” or . Operating similar to , scene storage is a property wrapper type that consists of a key/value pair. The key makes it possible for the system to save and restore the value correctly. The value is required to be of a `plist` type, so the system can save and restore it correctly. iOS ingests this scene storage using the key/value and then reads and writes to persisted, per-scene storage. The OS manages saving and restoring scene storage on the user’s behalf. The underlying data that backs scene storage is not directly available, so the app must access it via `@SceneStorage` property wrapper. The OS makes no guarantees as to when and how often the data will be persisted. The data in scene storage is not necessarily equivalent to an application’s data model. Scene storage is intended to be used  the data model. Ultimately, consider scene storage a “state scoped to a scene”. Don’t use scene storage with sensitive data.
Each view that needs its own state preservation implements a `@SceneStorage` property wrapper. For example `ContentView` uses one to restore the selected product:
```swift
@SceneStorage("ContentView.selectedProduct") private var selectedProduct: String?
```

`DetailView` uses one to restore its current selected tab:
```
`DetailView` uses one to restore its current selected tab:
```swift
@SceneStorage("DetailView.selectedTab") private var selectedTab = Tabs.detail
```

#### 
Each SwiftUI view that wants to advertise an `NSUserActivity` for handoff, Spotlight, etc. must specify a  view modifier to advertise the `NSUserActivity`. The `activityType` parameter is the user activity’s type, the `isActive` parameter indicates whether a user activity of the specified type is advertised (this parameter defaults to `true`), and whether it uses the specified handler to fill in the user-activity contents. The scope of the user activity applies only to the scene or window in which the view is. Multiple views can advertise the same activity type, and the handlers can all contribute to the contents of the user activity. Note that handlers are only called for `userActivity` view modifiers where the `isActive` parameter is `true`. If none of the `userActivity` view modifiers specify `isActive` as `true`, the user activity will not be advertised by iOS.
Each SwiftUI view that wants to handle incoming `NSUserActivities` must specify a  view modifier. This takes the `NSUserActivity` type and a handler to invoke when the view receives the specified activity type for the scene or window in which the view is.
```swift
.onContinueUserActivity(DetailView.productUserActivityType) { userActivity in
    if let product = try? userActivity.typedPayload(Product.self) {
        selectedProduct = product.id.uuidString
    }
}
```

#### 
1. In Xcode set a breakpoint in `DetailView.swift` at `onContinueUserActivity` closure.
10. Tap it. Note that `DetailView` `onContinueUserActivity` closure is called. The `DetailView` will show the Cherries product.

## Scoping a search operation
> https://developer.apple.com/documentation/swiftui/scoping-a-search-operation

### 
#### 
Start by creating a type that conforms to the  protocol to represent the possible scopes. For example, you can use an enumeration to scope a product search to just fruits or just vegetables:
```swift
enum ProductScope {
    case fruit
    case vegetable
}
```

```
Then create a property to store the current scope, either as a state variable in a view, or a published property in your model:
```swift
@Published var scope: ProductScope = .fruit
```

#### 
To use the scope information, bind the current scope to the  modifier. You also indicate a set of views that correspond to the different scopes. Like the  modifier, the scopes modifier operates on the searchable modifier that’s closer to the modified view, so it needs to follow the searchable modifier:
```swift
ProductList(departmentId: departmentId, productId: $productId)
    .searchable(text: $model.searchText, tokens: $model.tokens) { token in
        switch token {
        case .apple: Text("Apple")
        case .pear: Text("Pear")
        case .banana: Text("Banana")
        }
    }
    .searchScopes($model.scope) {
        Text("Fruit").tag(ProductScope.fruit)
        Text("Vegetable").tag(ProductScope.vegetable)
    }
```

#### 

## Suggesting search terms
> https://developer.apple.com/documentation/swiftui/suggesting-search-terms

### 
#### 
Suggest search text by providing a collection of views to the  view modifier. This modifier applies to the  modifier that appears before it.
When someone activates the search interface, it presents the suggestion views as a list of choices below the query string. Associate a string with each suggestion view by adding the  modifier to the view inside the search suggestions closure. For example, you can include emoji with fruit types that you suggest as possible products to search for, and provide the corresponding search string as a search completion in each case:
```swift
ProductList(departmentId: departmentId, productId: $productId)
    .searchable(text: $model.searchText)
    .searchSuggestions {
        Text("🍎 Apple").searchCompletion("apple")
        Text("🍐 Pear").searchCompletion("pear")
        Text("🍌 Banana").searchCompletion("banana")
    }
```

#### 
You can also suggest tokens for the search field. In this case, associate a suggestion view with a token using the version of the  modifier that takes tokens as input:
```swift
ProductList(departmentId: departmentId, productId: $productId)
    .searchable(text: $model.searchText, tokens: $model.tokens) { token in
        switch token {
        case .apple: Text("Apple")
        case .pear: Text("Pear")
        case .banana: Text("Banana")
        }
    }
    .searchSuggestions {
        Text("Apple").searchCompletion(FruitToken.apple)
        Text("Pear").searchCompletion(FruitToken.pear)
        Text("Banana").searchCompletion(FruitToken.banana)
    }
```

#### 
As a convenience when you have a collection of suggestions that exactly matches the list of tokens, you can create a collection of possible tokens to suggest. For example, you can add a published `suggestions` property to your model that contains all the possible tokens:
```swift
@Published var suggestions: [FruitToken] = FruitToken.allCases
```

```
Then you can provide this array to one of the searchable modifiers that takes a `suggestedTokens` input parameter, like . SwiftUI uses this to generate the suggestions automatically:
```swift
ProductList(departmentId: departmentId, productId: $productId)
    .searchable(
        text: $model.searchText,
        tokens: $model.tokens,
        suggestedTokens: $model.suggestions
    ) { token in
        switch token {
        case .apple: Text("Apple")
        case .pear: Text("Pear")
        case .banana: Text("Banana")
        }
    }
```

#### 
You can update the suggestions that you provide as conditions change. For example, you can specify an array of `suggestedSearches` that you store in your app’s model:
```swift
ProductList(departmentId: departmentId, productId: $productId)
    .searchable(text: $model.searchText)
    .searchSuggestions {
        ForEach(model.suggestedSearches) { suggestion in
            Label(suggestion.title,  image: suggestion.image)
                .searchCompletion(suggestion.text)
        }
    }
```


## Technology-specific views
> https://developer.apple.com/documentation/swiftui/technology-specific-views

### 
For example, to use the  view in your app, import both SwiftUI and MapKit.
```swift
import SwiftUI
import MapKit

struct MyMapView: View {
    // Center the map on Joshua Tree National Park.
    var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )

    var body: some View {
        Map(initialPosition: .region(region))
    }
}
```


## Understanding the navigation stack
> https://developer.apple.com/documentation/swiftui/understanding-the-navigation-stack

### 
You can present destinations on a `NavigationStack` using:
#### 
Below is an example with two links inside a `NavigationStack`:
Enclose a  in a navigation structure higher up in the view-hierarchy—an ancestor view, for example. If this condition isn’t met, the link typically appears as disabled.
Below is an example with two links inside a `NavigationStack`:
```swift
struct DestinationView: View {
    var body: some View {
        NavigationStack {
            NavigationLink {
                ColorDetail(color: .mint, text: "Mint")
            } label: {
                Text("Mint")
            }
            
            NavigationLink {
                ColorDetail(color: .red, text: "Red")
            } label: {
                Text("Red")
            }
        }
    }
}

struct ColorDetail: View {
    var color: Color
    var text: String

    var body: some View {
        VStack {
            Text(text)
            color
         }
    }
}
```

Use the stateful navigation techniques described in  to track when a navigation link triggers, instead of  or `View/task(priority:_:)`.
Use the stateful navigation techniques described in  to track when a navigation link triggers, instead of  or `View/task(priority:_:)`.
Use a  modifier to navigate programmatically by providing a binding to a `Boolean` value. For example, you can programmatically push `ColorDetail` view onto the stack:
```swift
struct DestinationView: View { 
    @State private var showDetails = false
    var favoriteColor: Color
    
    NavigationStack {
        VStack {
            Circle()
                .fill(favoriteColor)
            Button("Show details") {
                showDetails = true
            }
        }
        .navigationDestination(isPresented: $showDetails) {
            ColorDetail(color: favoriteColor, text: color.description)
        }
    }
}
```

#### 
The following example implements `DestinationView` as a series of navigation links:
When you add data to the navigation path, SwiftUI maps the data type to a view, then pushes it onto the navigation stack when someone taps the link. To describe the view the stack displays, use the  view modifier inside a `NavigationStack`.
The following example implements `DestinationView` as a series of navigation links:
```swift
NavigationStack {
    List {
        NavigationLink("Mint", value: Color.mint)
        NavigationLink("Red", value: Color.red)
    }
    .navigationDestination(for: Color.self) { color in
        ColorDetail(color: color, text: color.description)
    }
}
```

In the example above, SwiftUI uses the value type—in this case, `Color`—to determine the appropriate navigation destination. With value-based navigation, you can define a variety of possible destinations for a single stack When someone taps “Mint”, SwiftUI pushes `ColorDetail` view with a value `.mint` onto the stack.
Value-based navigation shines in scenarios with mixed destination types. You can extend your app to handle recipe-related content in addition to colors:
```swift
struct ValueView: View {
    private var recipes: [Recipe] = [.applePie, .chocolateCake]
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Mint", value: Color.mint)
                NavigationLink("Red", value: Color.red)
                ForEach(recipes) { recipe in
                    NavigationLink(recipe.description, value: recipe)
                }
            }
            .navigationDestination(for: Color.self) { color in
                ColorDetail(color: color, text: color.description)
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}

struct RecipeDetailView: View {
    var recipe: Recipe
    
    var body: some View {
        Text(recipe.description)
    }
}

enum Recipe: Identifiable, Hashable, Codable {
    case applePie
    case chocolateCake
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .applePie:
            return "Apple Pie"
        case .chocolateCake:
            return "Chocolate Cake"
        }
    }
}
```

In this example, the `NavigationStack` supports two destination types: `Color` for colors, and `Recipe` for recipes. SwiftUI determines the correct destination view based on the data type of the value from the navigation link.
Use  when you need to navigate to a view based on the presence of an item. When the item binding is non-nil, SwiftUI passes the value into the destination closure and pushes the view onto the stack. For example:
```swift
struct ContentView: View {
    private var recipes: [Recipe] = [.applePie, .chocolateCake]
    @State private var selectedRecipe: Recipe?
    
    var body: some View {
        NavigationStack {
            List(recipes, selection: $selectedRecipe) { recipe in
                NavigationLink(recipe.description, value: recipe)
            }
            .navigationDestination(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}
```

#### 
Use , which takes a binding to a `NavigationPath` argument, when you want to observe the navigation state for this stack.
The `NavigationPath` data type is a heterogeneous collection type that accepts any `Hashable` values. You can add to the path by calling  or when people tap value-destination links such as .
When you push a value onto the stack using , you append the value to the path, as shown below:
```swift
struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("Mint", value: Color.mint)
                NavigationLink("Red", value: Color.red)
            }
            .navigationDestination(for: Color.self) { color in
                ColorDetail(color: color)
            }
        }
    }
}
```

 also provides an initializer in which the path parameter takes a  to a `RandomAccessCollection` and a `RangeReplaceableCollection` argument. You can store the path as a property in an object that leverages the  macro data type, and use property observers such as `willSet` and `didSet` or the  modifier to respond to changes when the value-destination link triggers.
In this case, the navigation path is a homogenous collection type that accepts a standard type, such as `Array`, or a custom data type as shown below:
```swift
@Observable
class NavigationManager {
    var path: [Color] = [] {
        willSet {
            print("will set to \(newValue)")
        }
        
        didSet {
            print("didSet to \(path)")
        }
    }
}

struct ContentView: View {
    @State private var navigationManager = NavigationManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            List {
                NavigationLink("Mint", value: Color.mint)
                NavigationLink("Red", value: Color.red)
            }
            .navigationDestination(for: Color.self) { color in
                ColorDetail(color: color, text: color.description)
            }
        }
    }
}
```

In the example above, the `willSet` and `didSet` property observers track when a navigation link triggers.
You can also use the reference to `path` variable to perform programmatic navigation. For example, you can pop a view off the stack:
In the example above, the `willSet` and `didSet` property observers track when a navigation link triggers.
You can also use the reference to `path` variable to perform programmatic navigation. For example, you can pop a view off the stack:
```swift
@Observable
class NavigationManager {
    var path: [Color] = [] {
        willSet {
            print("will set to \(newValue)")
        }
        
        didSet {
            print("didSet to \(path)")
        }
    }
    
    @discardableResult
    func navigateBack() -> Color? {
        path.popLast()
    }
}
```

```
Use a standard type when your stack displays views that rely on a single type of data, and `NavigationPath` when you need to present multiple data types in a single stack, as in the following example:
```swift
struct ValueView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink("Mint", value: Color.mint)
                NavigationLink("Red", value: Color.red)
                NavigationLink("Apple Pie", value: Recipe.applePie)
                NavigationLink("Chocolate Cake", value: Recipe.chocolateCake)
            }
            .navigationDestination(for: Color.self) { color in
                ColorDetail(color: color)
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}
```

When composed together, the navigation APIs allow you to use both styles of links, depending on what works best.
Here, when someone taps on the link “View Mint Color”, SwiftUI pushes the value-based destination link onto the stack, followed by a view-destination link:
```swift
struct ContentView: View {
    @State private var navigationManager = NavigationManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            NavigationLink("View Mint Color", value: Color.mint)
                .navigationDestination(for: Color.self) { color in
                    NavigationLink("Push Recipe View") {
                        RecipeDetailView(recipe: .applePie)
                    }
                }
        }
    }
}
```

After the code in this example runs, and someone clicks each `NavigationLink`, the navigation stack builds up with three views:
After the code in this example runs, and someone clicks each `NavigationLink`, the navigation stack builds up with three views:
SwiftUI keeps track of the entire navigation path. The underlying data structure looks like the following example:
```swift
Root → [Color.mint] → [RecipeDetailView]
```

```
Conceptually, SwiftUI stacks view-based destinations on top of the value-based destinations in the stack’s navigation path. For example, the code below replaces `RecipeDetailView` from the above example with a `NavigationLink`:
```swift
struct ContentView: View {
    @State private var navigationManager = NavigationManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            NavigationLink("View Mint Color", value: Color.mint)
                .navigationDestination(for: Color.self) { color in
                    NavigationLink("Push Recipe View") {
                        NavigationLink("Push another view", value: Color.pink)
                    }
                }
        }
    }
}
```

When you run the revised example, the view-destination link is still on the top of the stack.
If you use a heterogenous or homogeneous path on the stack, you may observe changes to the navigation path over time, as shown below:
```swift
@Observable
class NavigationManager {
    var path: [Color] = [] {
        didSet {
            print("didSet to \(path)")
        }
    }
}

struct ContentView: View {
    @State private var navigationManager = NavigationManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            NavigationLink("View Mint Color", value: Color.mint)
                .navigationDestination(for: Color.self) { color in
                    NavigationLink("Push Recipe View") {
                        RecipeDetailView(recipe: .applePie)
                    }
                }
        }
    }
}
```

```
When someone navigates through the app, it prints the following logs:
```swift
New path: []
New Path: [Color.mint]
```

#### 
In iOS, state restoration is especially important at the window or scene level, because windows come and go frequently. For this reason, it’s important to think about state restoration for navigation path in the same way you handle restoring your app’s state at the window or scene level. See  to learn about storing scene data.
Using `Codable`, you can manually persist and load the navigation stack path in one of two ways, depending on whether the path data type is homogeneous or heterogeneous. Store a homogenous path as in the following example:
```swift
@Observable
class NavigationManager {
    var path: [Recipe] = [] {
        didSet {
            save()
        }
    }
    
    /// The URL for the JSON file that stores the navigation path.
    private static var dataURL: URL {
        .documentsDirectory.appending(path: "NavigationPath.json")
    }
    
    init() {
        do {
            // Load the data model from the 'NavigationPath' data file found in the Documents directory.
            let path = try load(url: NavigationManager.dataURL)
            self.path = path
        } catch {
            // Handle error.
        }
    }
    
    func save() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(path)
            try data.write(to: NavigationManager.dataURL)
        } catch {
            // Handle error.
        }
    }
    
    /// Load the navigation path from a previously saved state.
    func load(url: URL) throws -> [Recipe] {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        let decoder = JSONDecoder()
        return try decoder.decode([Recipe].self, from: data)
    }
}

struct ContentView: View {
    @State private var navigationManager = NavigationManager()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            List {
                NavigationLink("Mint", value: Color.mint)
                NavigationLink("Red", value: Color.red)
                NavigationLink("Apple Pie", value: Recipe.applePie)
                NavigationLink("Chocolate Cake", value: Recipe.chocolateCake)
            }
            .navigationDestination(for: Color.self) { color in
                ColorDetail(color: color, text: color.description)
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}
```

Store a heterogeneous path using `NavigationPath`, as shown in the following example:
In the above example, when the `path` changes, `didSet` property observer triggers and the `save` function is called. The function saves the new path to disk enabling the app to restore it when initializing `NavigationManager`.
Store a heterogeneous path using `NavigationPath`, as shown in the following example:
```swift
@Observable
class NavigationManager {
    var path = NavigationPath() {
        didSet {
            save()
        }
    }
    
    /// The URL for the JSON file that stores the navigation path.
    private static var dataURL: URL {
        .documentsDirectory.appending(path: "NavigationPath.json")
    }
    
    init() {
        do {
            // Load the data model from the 'NavigationPath' data file found in the Documents directory.
            let path = try load(url: NavigationManager.dataURL)
            self.path = path
        } catch {
            // Handle error
        }
    }
    
    func save() {
        guard let codableRepresentation = path.codable else { return }
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(codableRepresentation)
            try data.write(to: NavigationManager.dataURL)
        } catch {
            //Handle error.
        }
    }
    
    /// Load the navigation path from a previously saved data.
    func load(url: URL) throws -> NavigationPath {
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        let decoder = JSONDecoder()
        let path = try decoder.decode(NavigationPath.CodableRepresentation.self, from: data)
        return NavigationPath(path)
    }
}

```


## Wishlist: Planning travel in a SwiftUI app
> https://developer.apple.com/documentation/swiftui/wishlist-planning-travel-in-a-swiftui-app

### 
#### 
SwiftUI views conform to the  protocol and define their content through a computed `body` property. Each view returns a description of what appears on screen, and SwiftUI handles the rendering.
Wishlist builds custom views by combining built-in components like , , , , and :
```swift
struct TripCard: View {
    var trip: Trip
    var size: Size

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            TripImageView(url: trip.photoURL)
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipShape(.rect(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 0) {
                Text(trip.name)
                    .font(.body)

                if let subtitle = trip.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
```

#### 
SwiftUI updates views automatically when their dependencies change. Mark model classes with  to opt into automatic change tracking. In Wishlist, the `@Observable` macro synthesizes the necessary code to publish changes made to any stored property:
```swift
@Observable
class DataSource {
    var trips: [Trip.ID: Trip] {
        didSet {
            updateGoalAchievements()
        }
    }
    var searchText = ""
}
```

The `DataSource` class stores trips in a  keyed by trip ID for efficient lookup. The `didSet` property observer calls `updateGoalAchievements()` whenever the `trips` dictionary changes, keeping goal progress synchronized with trip completion. Any views that read from the `trips` dictionary, like `RecentTripsPageView`, automatically update when the dictionary changes, such as when adding or removing a trip.
To share this data across the sample app, Wishlist creates a state with the  property wrapper inside the  struct, then injects the data into the view hierarchy with the  modifier:
```swift
@main
struct WishlistApp: App {
    @State private var dataSource = DataSource()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataSource)
        }
    }
}
```

```
Inside a view, Wishlist gets the observable object using its type, then creates a property and provides the object’s type to the  property wrapper:
```swift
struct WishlistView: View {
    @Environment(DataSource.self) private var dataSource

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    RecentTripsPageView()
                    ForEach(TripCollection.allCases) { tripCollection in
                        TripCollectionView(
                            tripCollection: tripCollection,
                            cardSize: tripCollection.cardSize,
                            namespace: namespace
                        )
                    }
                }
            }
        }
    }
}
```

SwiftUI automatically tracks property access within the view’s body. When any observed property changes, SwiftUI updates any parts of the view that depend on the value.
Some built-in views and modifiers in SwiftUI, like  and , take a  to a property. This lets these views and modifiers write back changes to the property. Use the  property wrapper to create bindings to properties of an `Observable` object. This includes global variables, properties that exist outside of SwiftUI types, or even local variables. For example, the sample app creates a `@Bindable` variable within a view’s body:
```swift
struct SearchView: View {
    @Environment(DataSource.self) private var dataSource

    var body: some View {
        @Bindable var dataSource = dataSource

        NavigationStack {
            SearchResultsListView()
                .searchable(text: $dataSource.searchText)
        }
    }
}
```

#### 
In the sample app, the `WishlistView` view uses a  and  `toolbarItem` placement to customize the title’s visual appearance.
SwiftUI separates visual presentation from semantic meaning when displaying navigation titles.
In the sample app, the `WishlistView` view uses a  and  `toolbarItem` placement to customize the title’s visual appearance.
```swift
NavigationStack {
    ScrollView {
        // Content
    }
    .toolbar {
        ToolbarItem(placement: .title) {
            ExpandedNavigationTitle(title: "Wishlist")
        }
    }
    .navigationTitle("Wishlist")
    .toolbarTitleDisplayMode(.inline)
}
```

#### 
In Wishlist, when a person deletes an activity, `withAnimation` ensures the removal animates smoothly:
Choose the right approach based on whether you’re animating a discrete action or responding to specific property changes.
In Wishlist, when a person deletes an activity, `withAnimation` ensures the removal animates smoothly:
```swift
Button("Delete", role: .destructive) {
    withAnimation {
        model.removeActivity(activity)
    }
}
```

The `withAnimation` block establishes an animation transaction. Any view changes that `removeActivity(_:)` triggers animate automatically, sharing the same animation curve and timing.
For finer control, apply animations to specific views using the `animation(_:value:)` modifier. This value-based approach creates a targeted animation that only triggers when the specified value changes, affecting only the view hierarchy where the modifier appears. In the activity completion button in Wishlist, the checkmark icon animates its appearance only when `isComplete` toggles, leaving other view changes unanimated:
```swift
Image(systemName: activity.isComplete ? "checkmark.circle.fill" : "circle")
    .foregroundStyle(activity.isComplete ? Color.accentColor : .gray)
    .contentTransition(.symbolEffect)
    .animation(.snappy, value: activity.isComplete)
```

#### 
To customize animated transitions between views, apply  to the source view and  with the transition   to the destination view using matching identifiers. Use the  property wrapper to create a unique value that associates the source and destination.
In Wishlist, when someone taps a trip card, it smoothly zooms and expands into the trip detail screen, maintaining visual continuity throughout the navigation. Dismissing the detail view reverses the animation, zooming back down into the original card position.
```swift
struct WishlistView: View {
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            ...
            ForEach(TripCollection.allCases) { tripCollection in
                TripCollectionView(
                    tripCollection: tripCollection,
                    namespace: namespace
                )
            }
        }
    }
}

struct TripCollectionView: View {
    var tripCollection: TripCollection
    var namespace: Namespace.ID

    var body: some View {
        ...
        ForEach(dataSource.trips(in: tripCollection)) { trip in
            NavigationLink {
                TripDetailView(trip: trip)
                    .navigationTransition(.zoom(sourceID: trip.id, in: namespace))
            } label: {
                TripCard(trip: trip, size: cardSize)
                    .matchedTransitionSource(id: trip.id, in: namespace)
            }
        }
        ...
    }
}
```


