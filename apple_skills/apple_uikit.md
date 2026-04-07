# Apple UIKIT Skill


## About the UI restoration process
> https://developer.apple.com/documentation/uikit/about-the-ui-restoration-process

### 
#### 
Before state restoration even begins, UIKit loads your app’s default view controllers from your storyboards. Because UIKit loads these view controllers automatically, it’s better not to create them using a restoration class or your app delegate. For all other view controllers, assign a restoration class only if the view controller isn’t defined in your storyboards. You might also assign a restoration class to prevent the creation of your view controller in specific circumstances. For example, you might want to avoid displaying the view controller if the associated restoration archive refers to stale or missing data.
When recreating view controllers in code, always reassign a value to the view controller’s  property in addition to any other initialization. Also assign a value to the  property as appropriate. Assigning these values at creation time ensures that the view controller will be preserved during the next cycle.
```swift
func viewController(withRestorationIdentifierPath 
                    identifierComponents: [Any], 
                    coder: NSCoder) -> UIViewController? {
   let vc = MyViewController()
        
   vc.restorationIdentifier = identifierComponents.last as? String
   vc.restorationClass = MyViewController.self
        
   return vc
}
```


## Adapting your app when traits change
> https://developer.apple.com/documentation/uikit/adapting-your-app-when-traits-change

### 
#### 
To track a trait change automatically, add code that references a trait in one of the methods that UIKit supports for automatic trait tracking, such as  in . In the following example, the implementation applies a layout appropriate for a smaller view when the size class is , or a layout appropriate for a larger view when the size class is :
```swift
class MyView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()

        if traitCollection.horizontalSizeClass == .compact {
          // Apply compact layout.
        } else {
          // Apply regular layout.
        }
    }
}
```

#### 
To track a specific trait or group of traits outside the automatic methods, use the registration methods in the  protocol. Select the trait or list of traits that you want to observe, and then specify a block of code or method to process each time those traits change. For example:
```swift
override func viewDidLoad() {
    super.viewDidLoad()

    registerForTraitChanges([
        UITraitHorizontalSizeClass.self,
        UITraitVerticalSizeClass.self
    ]) { (self: Self, previousTraitCollection: UITraitCollection) in
        self.updateLayout()
    }
}

func updateLayout() {
    let isCompact = traitCollection.horizontalSizeClass == .compact
    // Update your layout based on the size class.
}
```

UIKit provides predefined trait sets that group related traits for common use cases, such as color change or image lookups. These semantic sets simplify your code when you need to respond to multiple related traits.
The following example uses  to register for all traits that affect color appearance, including user interface style, contrast level, and accessibility settings:
```swift
registerForTraitChanges(UITraitCollection.systemTraitsAffectingColorAppearance) {
    (self: Self, previousTraitCollection: UITraitCollection) in
    self.updateColors()
}
```

Trait registrations remain active for the lifetime of the object that created them. When the view or view controller deallocates, UIKit automatically removes all associated trait registrations, eliminating the need for manual cleanup in most cases.
If you need to unregister before deallocation, store the  token the registration method returns and call the  method:
```swift
private var traitRegistration: UITraitChangeRegistration?

func startObservingTraits() {
    traitRegistration = registerForTraitChanges([UITraitHorizontalSizeClass.self]) {
        (self: Self, previousTraitCollection: UITraitCollection) in
        self.updateLayout()
    }
}

func stopObservingTraits() {
    unregisterForTraitChanges(traitRegistration)
    traitRegistration = nil
}
```

#### 
If your code currently uses , migrate to automatic trait tracking or trait registration for better performance and maintainability.
Remove implementations that check for trait changes in , such as this example:
```swift
override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    if traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
        updateLayout()
    }
}
```

```
Replace them with implementations in methods that support automatic trait tracking, such as this example:
```swift
override func layoutSubviews() {
    super.layoutSubviews()

    updateLayout(traitCollection.horizontalSizeClass)
}
```

```
Or, replace them with implementations that set up trait registrations in your setup code, as in the following example:
```swift
override func viewDidLoad() {
    super.viewDidLoad()

    registerForTraitChanges([UITraitHorizontalSizeClass.self]) {
        (self: Self, previousTraitCollection: UITraitCollection) in
        self.updateLayout()
    }
}
```


## Add Home Screen quick actions
> https://developer.apple.com/documentation/uikit/add-home-screen-quick-actions

### 
#### 
If the quick actions appropriate for an app never change, define them as static quick actions using the project’s `Info.plist` file. This sample project defines two static quick actions: one for searching and one for sharing. The `UIApplicationShortcutItems` key in the `Info.plist` file contains an array of two dictionaries that represent the two static quick actions.
```xml
<key>UIApplicationShortcutItems</key>
<array>
    <dict>
        <key>UIApplicationShortcutItemType</key>
        <string>SearchAction</string>
        <key>UIApplicationShortcutItemIconType</key>
        <string>UIApplicationShortcutIconTypeSearch</string>
        <key>UIApplicationShortcutItemTitle</key>
        <string>Search</string>
        <key>UIApplicationShortcutItemSubtitle</key>
        <string>Search for an item</string>
    </dict>
    <dict>
        <key>UIApplicationShortcutItemType</key>
        <string>ShareAction</string>
        <key>UIApplicationShortcutItemIconType</key>
        <string>UIApplicationShortcutIconTypeShare</string>
        <key>UIApplicationShortcutItemTitle</key>
        <string>Share</string>
        <key>UIApplicationShortcutItemSubtitle</key>
        <string>Share an item</string>
    </dict>
</array>
```

For information about other `Info.plist` keys available for configuring Home Screen quick actions, see .
#### 
Dynamic quick actions depend on specific data or state of the app. Configure dynamic Home Screen quick actions by setting the  property of the shared  instance to an array of  objects.
Set dynamic screen quick actions at any point, but the sample sets them in the  function of the scene delegate. During the transition to a background state is a good time to update any dynamic quick actions, because the system executes this code before the user returns to the Home Screen.
```swift
func sceneWillResignActive(_ scene: UIScene) {
    // Transform each favorite contact into a UIApplicationShortcutItem.
    let application = UIApplication.shared
    application.shortcutItems = ContactsData.shared.favoriteContacts.map { contact -> UIApplicationShortcutItem in
        return UIApplicationShortcutItem(type: ActionType.favoriteAction.rawValue,
                                         localizedTitle: contact.name,
                                         localizedSubtitle: contact.email,
                                         icon: UIApplicationShortcutIcon(systemImageName: "star.fill"),
                                         userInfo: contact.quickActionUserInfo)
    }
}
```

#### 
Define quick action icons with the `UIApplicationShortcutIcon` class in two different ways: with a template image or SF Symbol.
Define quick action icons with the `UIApplicationShortcutIcon` class in two different ways: with a template image or SF Symbol.
With a template image name:
```swift
UIApplicationShortcutIcon(type: .favorite)
```

```
With an SF Symbol name:
```swift
UIApplicationShortcutIcon(systemImageName: "star.fill")
```

```
As mentioned earlier, this sample app creates two static quick actions in its `Info.plist` with their icons set to `UIApplicationShortcutItemIconType`.
```xml
<key>UIApplicationShortcutItemIconType</key>
<string>UIApplicationShortcutIconTypeSearch</string>
```

```
Create a quick action icon with an SF Symbol:
```xml
<key>UIApplicationShortcutItemIconSymbolName</key>
<string>square.stack.3d.up</string>
```

1. `UIApplicationShortcutItemIconSymbolName`
2. `UIApplicationShortcutItemIconFile`
3. `UIApplicationShortcutItemIconType`
#### 
The dynamic quick actions in this sample all have the same  because they all perform the same action. However, the contact information associated with each is different and the sample passes it through to the  dictionary.
```swift
var quickActionUserInfo: [String: NSSecureCoding] {
    /** Encode the name of the contact into the userInfo dictionary so it can be passed
        back when a quick action is triggered. Note: In the real world, it's more appropriate
        to encode a unique identifier for the contact than for the name.
    */
    return [ SceneDelegate.favoriteIdentifierInfoKey: self.identifier as NSSecureCoding ]
}
```

Static Home Screen quick actions can also pass  data by including it in the `UIApplicationShortcutItemUserInfo` key in the app’s `Info.plist` file.
#### 
When someone initiates a Home Screen quick action, the app is notified in one of these ways:
- If the app isn’t already loaded, it’s launched and passes details of the shortcut item in through the `connectionOptions` parameter of the  function.
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    /** Process the quick action if the user selected one to launch the app.
        Grab a reference to the shortcutItem to use in the scene.
    */
    if let shortcutItem = connectionOptions.shortcutItem {
        // Save it off for later when we become active.
        savedShortCutItem = shortcutItem
    }
}
```

```
- If your app is already loaded, the system calls the  function of your scene delegate.
```swift
func windowScene(_ windowScene: UIWindowScene,
                 performActionFor shortcutItem: UIApplicationShortcutItem,
                 completionHandler: @escaping (Bool) -> Void) {
    let handled = handleShortCutItem(shortcutItem: shortcutItem)
    completionHandler(handled)
}
```

#### 
3. Set a breakpoint in SceneDelegate.swift, function `scene(_:willConnectTo:options:)` to be used when someone chooses a shortcut.

## Adding Writing Tools support to a custom UIKit view
> https://developer.apple.com/documentation/uikit/adding-writing-tools-support-to-a-custom-uiview

### 
#### 
A  object manages interactions between your view and the Writing Tools feature. In iOS, this object is a type of  object, and you attach it to your view only when you want to support Writing Tools. To manage your view-specific behavior, you provide a delegate object when setting up the coordinator. Your delegate provides Writing Tools with initial text to evaluate, incorporates changes, provides proofreading marks, and provides preview objects to use during animations.
Attach a coordinator object to your view, typically when creating and configuring that view. Supply a delegate object that adopts the  protocol and has access to your view’s text content and layout information. The following example shows an extension to a custom view that creates the coordinator and initializes it with the view itself. The custom method checks to see if Writing Tools is available before creating a coordinator object and adding it to the view.
```swift
class MyTextView : UIView {
    var coordinator: UIWritingToolsCoordinator?

   //…
}

extension MyTextView : UIWritingToolsCoordinator.Delegate {

    func configureWritingTools() {
        guard UIWritingToolsCoordinator.isWritingToolsAvailable else { return }
        guard coordinator == nil else { return }
        
        coordinator = UIWritingToolsCoordinator(delegate:self)
        addInteraction(coordinator!)
    }
   //…
}
```

#### 
At configuration time, you also specify the types of text content your view supports using your coordinator’s  property. The models that Writing Tools uses to evaluate your text can generate plain or formatted text. Writing Tools supports all types of output by default, but you can limit it to specific types as needed.
The following code updates the previous example method, and adds some preferred behaviors for the coordinator object. In addition to wanting the inline experience for Writing Tools interactions, the method requests that the system generate rich text and optional list-based content. Providing a specific list of result options tells Writing Tools to generate only that type of content. You might provide this information if your view doesn’t support specific types of content, like tables.
```swift
func configureWritingTools() {
    guard UIWritingToolsCoordinator.isWritingToolsAvailable else { return }
    guard coordinator == nil else { return }

    coordinator = UIWritingToolsCoordinator(delegate:self)
    coordinator?.preferredBehavior = .complete
    coordinator?.preferredResultOptions = [.richText, .list]
    addInteraction(coordinator!)
}
```

#### 
A  object is a data object that you fill with the requested text. Context objects provide the common ground that you and Writing Tools use to communicate throughout a single operation. For each request, you create one context object for each text-storage object that has text for Writing Tools to consider. Most views have only one text-storage object and therefore create only one context object. However, a view that uses multiple subviews to manage different parts of its content might assign separate text-storage objects to each subview. In that scenario, you create one context object for each subview that contains the requested text.
To request your view’s context object, the coordinator calls your delegate’s  method. Use the parameters of that method to determine if Writing Tools wants all of your view’s text or only some of it. The following example creates a single context object with either the currently selected text or the view’s full text. After creating the context, the custom `storeContexts` method saves a reference to the context for subsequent tasks.
```swift
func writingToolsCoordinator(_ writingToolsCoordinator: UIWritingToolsCoordinator, 
        requestsContextsFor scope: UIWritingToolsCoordinator.ContextScope,
        completion: @escaping ([UIWritingToolsCoordinator.Context]) -> Void) {

    // Store the created contexts for the completion handler.
    var contexts = [UIWritingToolsCoordinator.Context]()
                
    switch scope {
    case .userSelection:
        let context = getContextObjectForSelection()
        contexts.append(context)
        break
            
    case .fullDocument:
        let context = getContextObjectForFullDocument()
        contexts.append(context)
        break

    case .visibleArea:
        let context = getContextObjectForVisibleArea()
        contexts.append(context)
        break

    default:
        break
    }
        
    // Save references to the contexts for later delegate calls.
    storeContexts(contexts)
        
    // Deliver the contexts to Writing Tools.
    completion(contexts)
}
```

After you create a context object, cache any additional information that you need to map the text in your context object to the text in your view’s text storage. You need to know where the content for each context object starts, in order to update your text storage later. One option is to create a dictionary that maps the context object’s identifier to the starting location of its text in your text storage. You can use that value to adjust any context-specific ranges that Writing provides you later.
The following example shows a method that the delegate uses to create a context object for the current text selection. The method calls the custom `getSelectedTextToEvaluate` function, which returns an expanded version of the text that includes both the selection and some of the surrounding text. The method also returns the starting location of that expanded text in the view’s text storage. Because the text selection is now in the middle of the text, the method initializes the context object with a range that provides the location of only the selected text, relative to the start of `textToEvaluate`. The method saves the actual starting location in a dictionary variable, mapping the value to the context’s unique identifier.
```swift
var startingLocationsForContexts = [UUID : Int]()

func getContextObjectForSelection() -> UIWritingToolsCoordinator.Context {
    // Get the text to evaluate, which includes the text selection and some
    // of the surrounding text. The method returns (NSAttributedString, Int),
    // which represents the text itself, and the starting location of that
    // text in the view's text storage.
    let (textToEvaluate, startLocation) = getSelectedTextToEvaluate()

    // Get the NSRange for the text selection, relative to the text storage.
    let textSelectionRange = getTextSelectionRange()
    var contextRange = textSelectionRange
        
    // The view guarantees that startLocation is less than or equal to the
    // selection range. Adjust contextRange so that location 0 corresponds
    // to the first character in textToEvaluate. Keep the length the same.
    contextRange.location = textSelectionRange.location - startLocation
        
    // Create the new context object.
    let context = UIWritingToolsCoordinator.Context(attributedString: textToEvaluate, range: contextRange)
    
    // Save the starting location of the text, relative to the text storage.
    startingLocationsForContexts[context.identifier] = startLocation
    
    return context
}
```

#### 
After evaluating your view’s text, Writing Tools delivers any suggested changes to your delegate object. If your view adopts the limited experience, Writing Tools waits until the person accepts any changes before delivering them to your view. If you adopt the complete experience, Writing Tools delivers the changes before the person accepts them. If the person later rejects the changes, Writing Tools delivers a new set of changes that restore your view’s original text.
In your delegate’s  method, incorporate the specified change into your view’s text storage. Writing Tools calls this method for each distinct change it needs to make, and it might call the method multiple times with different range values for the same context object. The following simple example validates the provided range information and validates the view’s own cached information for the context object. If everything is valid, the method then calculates the correct range of text to replace and creates a transaction to perform the replacement. Before returning, the method executes the provided completion handler with the text it incorporated, if any.
```swift
func writingToolsCoordinator(_ writingToolsCoordinator: UIWritingToolsCoordinator, 
        replace range: NSRange, 
        in context: UIWritingToolsCoordinator.Context, 
        proposedText replacementText: NSAttributedString, 
        reason: UIWritingToolsCoordinator.TextReplacementReason, 
        animationParameters: UIWritingToolsCoordinator.AnimationParameters?, 
        completion: @escaping (NSAttributedString?) -> Void) {
        
    // Make sure there's a valid starting location in the text storage.
    guard let startingLocation = startingLocationsForContexts[context.identifier] 
        else { completion(nil); return }
    guard let textStorage = textContentStorage.textStorage else { completion(nil); return }

    // Determine the correct location in the text storage.
    let adjustedRange = NSRange(location: startingLocation + range.location, length: range.length)
        
    // Update the view’s NSTextContentManager using a transaction.
    textContentStorage.performEditingTransaction {
        textStorage.replaceCharacters(in: adjustedRange, with: replacementText)
    }
    
    completion(replacementText)
}
```

#### 
When working on your view’s selected text, Writing Tools updates the text selection to account for any text updates. Use your delegate’s  method to update the selected text in your view. The method delivers an array of range values to allow for views to create discontiguous selections. If your view supports only a continuous range of selected characters, update your view’s selection based on the first element in the `ranges` array.
When implementing your delegate method, remember to update range values to account for the offset to the start of the text in your context object. The following example creates an adjusted set of ranges by adding the starting location recorded at the start of the operation for the context object. It then passes that information to the view’s text engine to highlight the appropriate ranges of text.
```swift
func writingToolsCoordinator(_ writingToolsCoordinator: UIWritingToolsCoordinator, 
        select ranges: [NSValue], 
        in context: UIWritingToolsCoordinator.Context, 
        completion: @escaping () -> Void) {
        
    guard let startingLocation = startingLocationsForContexts[context.identifier] 
              else { completion(); return }
    var adjustedRanges = [NSRange]()
        
    for value in ranges {
        let range = value.rangeValue
        let newRange = NSRange(location: startingLocation + range.location, length: range.length)
        adjustedRanges.append(newRange)
    }

    // Highlight the specified text in the view.
    selectTextInDocument(adjustedRanges)
    completion()
}
```

#### 
To create a preview image of your text, use your layout manager and a  to generate the image in your delegate’s  method. Use your layout manager to get the frame rectangle that surrounds the specified text, and configure your image renderer with the size of that rectangle. In your rendering code, configure a clipping path to limit drawing to the area that contains only the specified text, and render that text onto a clear background.
The following example shows an implementation of the  method that creates a preview image for the view’s text. The method relies on the view’s layout manager to get the text rectangles that surround each line of text in the specified range. It also uses the layout manager to draw the text within the block of the graphics renderer. The image renderer generates an image with the rendered text, which the method places in an image view and uses to create a  object. Setting the frame rectangle of the image view tells Writing Tools where to place that image in the overall text view. When creating animations, Writing Tools applies the required visual effects to the provided image view instead of to the text itself.
```swift
func writingToolsCoordinator(_ writingToolsCoordinator: UIWritingToolsCoordinator, 
        requestsPreviewFor textAnimation: UIWritingToolsCoordinator.TextAnimation, 
        of range: NSRange, 
        in context: UIWritingToolsCoordinator.Context, 
        completion: @escaping (UITargetedPreview?) -> Void) {
        
    let textRange = MyTextRange(range)         // Create the view's custom subclass of NSTextRange.
    let textRects = getTextRectangles(range)   // Returns an array of NSValue<NSRect*>.

    if !textRange.isEmpty {
        // Get the frame rectangle that encloses the text.
        let textFrame = unionRect(for: textRects.map({$0.cgRectValue}))
            
        // Create the image renderer and render the image.
        let renderer = UIGraphicsImageRenderer(bounds: textFrame)
        let image = renderer.image { context in
            // Limit drawing to the text rectangles.
            context.cgContext.clip(to: textRects.map({$0.cgRectValue}))
                
            // Draw the specified range of text using the view's layout manager.
            drawTextInRange(range)
        }
        // Create an image view and set its frame to match the area with the text.
        let imageView = UIImageView(image:image)
        imageView.frame = textFrame
            
        // Create the targeted preview.
        let parameters = UIPreviewParameters(textLineRects: 
                       textRects.map({NSValue(cgRect: $0.cgRectValue)}))
        let target = UIPreviewTarget(container: self, center: self.center)
        let preview = UITargetedPreview(view: imageView, parameters: parameters, target: target)
            
        completion(preview)
    }
    else {
        completion(nil)
    }
}
```

#### 
If someone chooses a proofreading option, Writing Tools evaluates your view’s text and asks you to provide proofreading marks to decorate the view. For each mark, Writing Tools asks you to provide a Bézier path that underlines the text in a particular range. The following example uses the view’s layout manager to get the bounding rectangles for the specified range of text. It then flattens those rectangles to create a line shape underneath the text and passes the resulting paths to the completion handler. The code creates separate shapes for each rectangle to account for situations where a proofreading mark extends onto multiple lines of text.
```swift
func writingToolsCoordinator(_ writingToolsCoordinator: UIWritingToolsCoordinator, 
        requestsUnderlinePathsFor range: NSRange, 
        in context: UIWritingToolsCoordinator.Context, 
        completion: @escaping ([UIBezierPath]) -> Void) {

    let textRects = getTextRectangles(range)   // Returns an array of NSValue<NSRect*>.
        
    var paths = [UIBezierPath]()
    for rect in textRects.map({$0.cgRectValue}) {
        let underlineHeight: CGFloat = 2
        let newRect = CGRect(x: rect.origin.x, y: rect.origin.y + rect.height - (underlineHeight/2), 
                             width: rect.width, height: underlineHeight)
        paths.append(UIBezierPath(rect: newRect))
    }
                
    completion(paths)

}
```

```
In addition to providing the proofreading mark shapes, Writing Tools also asks you to provide the bounding rectangles for the text itself. Writing Tools uses these bounding rectangles to draw highlights around your text. The following example retrieves the bounding rectangles for the specified range of text and passes a Bézier path for each rectangle to the completion handler:
```swift
func writingToolsCoordinator(_ writingToolsCoordinator: UIWritingToolsCoordinator, 
        requestsBoundingBezierPathsFor range: NSRange, 
        in context: UIWritingToolsCoordinator.Context, 
        completion: @escaping ([UIBezierPath]) -> Void) {

    let textRects = getTextRectangles(range)   // Returns an array of NSValue<NSRect*>.
        
    var paths = [UIBezierPath]()
    for rect in textRects.map({$0.cgRectValue}) {
        paths.append(UIBezierPath(rect: rect))
    }
                
    completion(paths)
}
```

#### 
#### 

## Adding a custom font to your app
> https://developer.apple.com/documentation/uikit/adding-a-custom-font-to-your-app

### 
#### 
#### 
#### 
#### 
You can create an instance of your custom font in source code. To do this, you need to know the font name.  However, the name of the font isn’t always obvious, and rarely matches the font file name. A quick way to find the font name is to get the list of fonts available to your app, which you can do with the following code:
```swift
for family in UIFont.familyNames.sorted() {
    let names = UIFont.fontNames(forFamilyName: family)
    print("Family: \(family) Font names: \(names)")
}
```

```
Once you know the font name, create an instance of the custom font using . If your app supports Dynamic Type, you can also get a scaled instance of your font, as shown here:
```swift
guard let customFont = UIFont(name: "CustomFont-Light", size: UIFont.labelFontSize) else {
    fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
    )
}
label.font = UIFontMetrics.default.scaledFont(for: customFont)
label.adjustsFontForContentSizeCategory = true
```


## Adding headers and footers to table sections
> https://developer.apple.com/documentation/uikit/adding-headers-and-footers-to-table-sections

### 
To create a basic header or footer with a text label, override the  or  method of your table’s data source object. The table view creates a standard header or footer for you and inserts it into the table at the specified location.
```swift
// Create a standard header that includes the returned text.
override func tableView(_ tableView: UITableView, titleForHeaderInSection 
                            section: Int) -> String? {
   return "Header \(section)"
}

// Create a standard footer that includes the returned text.
override func tableView(_ tableView: UITableView, titleForFooterInSection 
                            section: Int) -> String? {
   return "Footer \(section)"
}

```

#### 
Always use a  object for your headers and footers. That view supports the same reuse model that cells employ, allowing you to recycle views instead of creating them every time. After you register your header or footer view, use the table view’s  method to request instances of that view. If recycled header or footer views are available, the table view returns those first, before creating new ones.
You can use a  object as is and add views to its  property, or you can subclass and add your views. Position your subviews inside the content view by using a stack view or Auto Layout constraints. To change the background behind your content, modify the  property of the header-footer view. The following example code shows a custom header view that positions the image and label views at creation time.
```swift
class MyCustomHeader: UITableViewHeaderFooterView {
    let title = UILabel()
    let image = UIImageView()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }

    func configureContents() {
        image.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(image)
        contentView.addSubview(title)

        // Center the image vertically and place it near the leading
        // edge of the view. Constrain its width and height to 50 points.
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            image.widthAnchor.constraint(equalToConstant: 50),
            image.heightAnchor.constraint(equalToConstant: 50),
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        
            // Center the label vertically, and use it to fill the remaining
            // space in the header view. 
            title.heightAnchor.constraint(equalToConstant: 30),
            title.leadingAnchor.constraint(equalTo: image.trailingAnchor, 
                   constant: 8),
            title.trailingAnchor.constraint(equalTo: 
                   contentView.layoutMarginsGuide.trailingAnchor),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
```

```
Register your header view as part of configuring your table view.
```swift
override func viewDidLoad() {
   super.viewDidLoad()
   
   // Register the custom header view.
   tableView.register(MyCustomHeader.self, 
       forHeaderFooterViewReuseIdentifier: "sectionHeader")
}
```

```
In your delegate’s  method, create and configure your custom view. The following example code dequeues the registered custom header and configures its title and image properties.
```swift
override func tableView(_ tableView: UITableView, 
        viewForHeaderInSection section: Int) -> UIView? {
   let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
               "sectionHeader") as! MyCustomHeader
   view.title.text = sections[section]
   view.image.image = UIImage(named: sectionImages[section])

   return view
}
```

#### 

## Adding menus and shortcuts to the menu bar and user interface
> https://developer.apple.com/documentation/uikit/adding-menus-and-shortcuts-to-the-menu-bar-and-user-interface

### 
#### 
#### 
Menu commands consist of `UICommand`, `UIKeyCommand`, and  objects that are grouped in a `UIMenu` container.
#### 
This sample inserts a `UIKeyCommand` called Command-O into the File Menu and creates a corresponding keyboard shortcut:
This sample inserts a `UIKeyCommand` called Command-O into the File Menu and creates a corresponding keyboard shortcut:
```swift
class func openMenu() -> UIMenu {
    let openCommand =
        UIKeyCommand(title: NSLocalizedString("OpenTitle", comment: ""),
                     image: nil,
                     action: #selector(AppDelegate.openAction),
                     input: "o",
                     modifierFlags: .command)
    let openMenu =
        UIMenu(title: "",
               image: nil,
               identifier: .openMenu,
               options: .displayInline,
               children: [openCommand])
    return openMenu
}
```

Notice that the `UIKeyCommand` title is a localized string using the  function, which can display the menu name in multiple languages.
Notice that the `UIKeyCommand` title is a localized string using the  function, which can display the menu name in multiple languages.
This sample inserts the Open command into the middle of the menu bar’s File menu:
```swift
builder.insertChild(MenuController.openMenu(), atStartOfMenu: .file)
```

#### 
This sample implements `canPerformAction:withSender:` to determine if these edit operations are supported.
Editing operations, such as cut, copy, paste, and delete, are commonly used in most apps. This sample app provides these operations through the Edit menu, where the user can edit the sample’s left-side content or its primary table-view content. These operations represent the first-responder functions `cut(_ sender: Any?)`, `copy(_ sender: Any?)`, `paste(_ sender: Any?)`, `delete(_ sender: Any?)`.
This sample implements `canPerformAction:withSender:` to determine if these edit operations are supported.
```swift
override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if action == #selector(printContent) {
        // Allow for printing if a table view cell is selected.
        return tableView.indexPathForSelectedRow != nil
    } else if action == #selector(newAction(_:)) {
        // User wants to perform a New operation.
        return true
    } else {
        switch (tableView.indexPathForSelectedRow, action) {
        
        // These Edit commands are supported.
        case let (_?, action) where action == #selector(cut(_:)) ||
                                    action == #selector(copy(_:)) ||
                                    action == #selector(delete(_:)):
            return true
        case (_?, _):
            // Allow the nextResponder to make the determination.
            return super.canPerformAction(action, withSender: sender)
            
        // Paste is supported if the pasteboard has text.
        case (.none, action) where action == #selector(paste(_:)):
            return (UIPasteboard.general.string != nil) ? true :
                // Allow the nextResponder to make the determination.
                super.canPerformAction(action, withSender: sender)
        case (.none, _):
            return false
        }
    }
}
```

#### 
In the sample, you can change the primary or left-side table view’s selection by using . These key commands are connected to the up and down arrow keys and are added directly to the table view. The following example shows how to add the down arrow key as a `UIKeyCommand`:
```swift
let downArrowCommand =
    UIKeyCommand(input: UIKeyCommand.inputDownArrow,
                 modifierFlags: [],
                 action: #selector(PrimaryViewController.downArrowAction(_:)))
addKeyCommand(downArrowCommand)
```

```
The sample also demonstrates how to add menu commands as command-key equivalents. The following example shows how to create a menu with all four arrow keys as command keys:
```swift
class func navigationMenu() -> UIMenu {
    let keyCommands = [ UIKeyCommand.inputRightArrow,
                        UIKeyCommand.inputLeftArrow,
                        UIKeyCommand.inputUpArrow,
                        UIKeyCommand.inputDownArrow ]
    let arrows = Arrows.allCases
    
    let arrowKeyChildrenCommands = zip(keyCommands, arrows).map { (command, arrow) in
        UIKeyCommand(title: arrow.localizedString(),
                     image: nil,
                     action: #selector(AppDelegate.navigationMenuAction(_:)),
                     input: command,
                     modifierFlags: .command,
                     propertyList: [CommandPListKeys.ArrowsKeyIdentifier: arrow.rawValue])
    }
    
    let arrowKeysGroup = UIMenu(title: "",
                  image: nil,
                  identifier: .arrowsMenu,
                  options: .displayInline,
                  children: arrowKeyChildrenCommands)
    
    return UIMenu(title: NSLocalizedString("NavigationTitle", comment: ""),
                  image: nil,
                  identifier: .navMenu,
                  options: [],
                  children: [arrowKeysGroup])
}
```

#### 
#### 
The sample implements , where it can adjust the Style menu as the user selects between one or more font styles: plain, bold, italic, underline.
```swift
// The font style menu item check marks used in the Style menu.
var fontMenuStyleStates = Set<String>()

// Update the state of a given command by adjusting the Style menu.
// Note: Only command groups that are added will be called to validate.
override func validate(_ command: UICommand) {
    // Obtain the plist of the incoming command.

    if let fontStyleDict = command.propertyList as? [String: String] {
        // Check if the command comes from the Style menu.
        if let fontStyle = fontStyleDict[MenuController.CommandPListKeys.StylesIdentifierKey] {
            // Update the Style menu command state (checked or unchecked).
            command.state = fontMenuStyleStates.contains(fontStyle) ? .on : .off
        }
    } else {
        // Validate the disabled command. This keeps the menu item disabled.
        if let commandPlistString = command.propertyList as? String {
            if commandPlistString == MenuController.disabledCommand {
                command.attributes = .disabled
            }
        }
    }
}
```

#### 

## Adding user-focusable elements to a tvOS app
> https://developer.apple.com/documentation/uikit/adding-user-focusable-elements-to-a-tvos-app

### 
#### 
In Xcode, search the Library pane for the item you want to add to your app, and drag it to your app’s storyboard. Several UIKit elements are focusable by default, including buttons (), text fields (), and table cells (). The top-left item is in focus when your app launches. (In right-to-left languages, the top-right item is initially in focus.) You don’t need to do anything to UIKit elements that are focusable by default. However, you can add SceneKit and SpriteKit nodes as focusable elements. To make a SceneKit or SpriteKit node focusable, set the  property of the node to `focusable`, as shown below.
```swift
node.focusBehavior = .focusable
```

#### 

## Adjusting your layout with keyboard layout guide
> https://developer.apple.com/documentation/uikit/adjusting-your-layout-with-keyboard-layout-guide

### 
When your app presents a keyboard, you want it to integrate well into your layout. This sample code project demonstrates how to configure constraints when you set  to `true` on the  property in `UIView` to adapt your layout to the movement of the floating keyboard onscreen. The sample illustrates several concepts, such as handling when the keyboard is close to the top of the screen, and adapting the layout when the additional views don’t have constraints with a direct relationship to the `keyboardLayoutGuide`.
When you use `keyboardLayoutGuide` and leave `followsUndockedKeyboard` set to the default value of `false`, the guide matches the keyboard when it docks. When the keyboard isn’t onscreen, the guide is at the bottom of the window and has a height equal to the bottom of the current . By default, when the keyboard undocks, the guide behaves the same as when you dismiss the keyboard or the keyboard isn’t visible. You can use the guide like any other layout guide.
```swift
view.keyboardLayoutGuide.topAnchor.constraint(
    equalToSystemSpacingBelow: textView.bottomAnchor, multiplier: 1.0).isActive = true
```

#### 
For more precise layout responses to the undocked keyboard, the sample sets `followsUndockedKeyboard` to `true` and then creates tracking constraints that activate and deactivate when the keyboard approaches or leaves an edge. Tracking constraints only apply when `followsUndockedKeyboard` is `true`.
```swift
// This is necessary to allow the various edge constraints to engage.
view.keyboardLayoutGuide.followsUndockedKeyboard = true
```

#### 
The following example shows how to pin a view to the top of the `keyboardLayoutGuide` when the guide is `awayFrom` the top edge, and to the bottom of the view’s  when it’s `near` the top edge:
```swift
// When the keyboard isn't near the top, tie the edit view to the keyboard layout guide (it
// deactivates when near the top).
let editViewOnKeyboard = view.keyboardLayoutGuide.topAnchor.constraint(equalTo: editView.bottomAnchor)
editViewOnKeyboard.identifier = "editViewOnKeyboard"
view.keyboardLayoutGuide.setConstraints([editViewOnKeyboard], activeWhenAwayFrom: .top)

// When the keyboard is near the top, tie the edit view to the bottom anchor of the safeAreaLayoutGuide, so that it doesn't go offscreen.
let editViewOnBottom = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: editView.bottomAnchor)
editViewOnBottom.identifier = "editViewOnBottom"
view.keyboardLayoutGuide.setConstraints([editViewOnBottom], activeWhenNearEdge: .top)
```

```
The sample demonstrates that it isn’t necessary to pin views to the `keyboardLayoutGuide` to affect their constraints when the keyboard approaches an edge. The guide can take any array of constraints in the layout and activate and deactivate them when necessary. For example, the following code shows an `imageView` with no constraint relationships to the `keyboardLayoutGuide` itself, but the image moves to the opposite side of the screen from the keyboard to stay visible as the keyboard moves around:
```swift
let centeredImage = imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
centeredImage.identifier = "centeredImage"
view.keyboardLayoutGuide.setConstraints([centeredImage], activeWhenAwayFrom: [.leading, .trailing])

let imageViewToLeading = imageView.leadingAnchor.constraint(
    equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1.0)
imageViewToLeading.identifier = "imageViewToLeading"

let nearTrailingConstraints = [ editViewToUndockedKeyboardTrailing, imageViewToLeading ]
view.keyboardLayoutGuide.setConstraints(nearTrailingConstraints, activeWhenNearEdge: .trailing)

let imageViewToTrailing = view.safeAreaLayoutGuide.trailingAnchor.constraint(
    equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1.0)
imageViewToTrailing.identifier = "imageViewToTrailing"

let nearLeadingConstraints = [ editViewToKeyboardLeading, imageViewToTrailing ]
view.keyboardLayoutGuide.setConstraints(nearLeadingConstraints, activeWhenNearEdge: .leading)
```

#### 
- Are always `awayFrom` leading, trailing, and top edges
- Are always `near` the bottom edge
- Are always `awayFrom` leading, trailing, and bottom edges
- Can be `near` the top edge
- Can be `awayFrom` all edges
- Can be `near` any edge or any two adjacent edges
- Is always `awayFrom` the top edge and `near` the bottom edge
- Can be `near` the leading or trailing edge when in a collapsed state
#### 
The sample shows constraints that are active when `near` or `awayFrom` multiple edges. The system activates or deactivates the constraints only when the position of the keyboard meets all edge requirements. Because a docked keyboard is `awayFrom` leading and trailing edges, but `near` the bottom edge, the constraint in the example below only activates when the keyboard undocks and is `awayFrom` the leading and trailing edges. This situation happens with undocked full or split keyboards, and with a floating keyboard in the horizontal middle of the screen.
```swift
let editCenterXToKeyboard = view.keyboardLayoutGuide.centerXAnchor.constraint(equalTo: editView.centerXAnchor)
editCenterXToKeyboard.identifier = "editCenterXToKeyboard"

view.keyboardLayoutGuide.setConstraints([editCenterXToKeyboard], activeWhenAwayFrom: [.leading, .trailing, .bottom])
```


## Adopting drag and drop in a custom view
> https://developer.apple.com/documentation/uikit/adopting-drag-and-drop-in-a-custom-view

### 
#### 
#### 
To enable dragging, dropping, or both, attach interactions to views. A convenient place for this code is in an app’s  method.
Add the drag interaction:
```swift
let dragInteraction = UIDragInteraction(delegate: self)
imageView.addInteraction(dragInteraction)
```

```
Add the drop interaction:
```swift
let dropInteraction = UIDropInteraction(delegate: self)
view.addInteraction(dropInteraction)
```

```
Enabling drag and drop for an image view, which this project uses, requires an additional step. You must explicitly enable user interaction, like this:
```swift
imageView.isUserInteractionEnabled = true
```

#### 
The  method is the one essential method for allowing dragging from a view.
```swift
func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
    guard let image = imageView.image else { return [] }

    let provider = NSItemProvider(object: image)
    let item = UIDragItem(itemProvider: provider)
    item.localObject = image
    
    /*
         Returning a non-empty array, as shown here, enables dragging. You
         can disable dragging by instead returning an empty array.
    */
    return [item]
}
```

#### 
To enable a view to consume data from a drop session, you implement three delegate methods.
First, your app can refuse the drag items based on their uniform type identifiers (UTIs), the state of your app, or other requirements. Here, the implementation allows a user to drop only a single item that conforms to the `kUTTypeImage` UTI:
```swift
func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
    return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]) && session.items.count == 1
}
```

```
Second, you must tell the system how you want to consume the data, which is typically by copying it. You specify this choice by way of a drop proposal:
```swift
func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
    let dropLocation = session.location(in: view)
    updateLayers(forDropLocation: dropLocation)

    let operation: UIDropOperation

    if imageView.frame.contains(dropLocation) {
        /*
             If you add in-app drag-and-drop support for the .move operation,
             you must write code to coordinate between the drag interaction
             delegate and the drop interaction delegate.
        */
        operation = session.localDragSession == nil ? .copy : .move
    } else {
        // Do not allow dropping outside of the image view.
        operation = .cancel
    }

    return UIDropProposal(operation: operation)
}
```

```
Finally, after the user lifts their finger from the screen, indicating their intent to drop the drag items, your view has one opportunity to request particular data representations of the drag items:
```swift
func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
    // Consume drag items (in this example, of type UIImage).
    session.loadObjects(ofClass: UIImage.self) { imageItems in
        let images = imageItems as! [UIImage]

        /*
             If you do not employ the loadObjects(ofClass:completion:) convenience
             method of the UIDropSession class, which automatically employs
             the main thread, explicitly dispatch UI work to the main thread.
             For example, you can use `DispatchQueue.main.async` method.
        */
        self.imageView.image = images.first
    }

    // Perform additional UI updates as needed.
    let dropLocation = session.location(in: view)
    updateLayers(forDropLocation: dropLocation)
}
```


## Adopting drag and drop in a table view
> https://developer.apple.com/documentation/uikit/adopting-drag-and-drop-in-a-table-view

### 
#### 
#### 
To enable dragging, dropping, or both, specify a table view as its own drag or drop delegate. A convenient place for this code is in an app’s  method. This code enables both dragging and dropping:
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dragInteractionEnabled = true
    tableView.dragDelegate = self
    tableView.dropDelegate = self

    navigationItem.rightBarButtonItem = editButtonItem
}
```

#### 
To provide data for dragging from a table view, implement the  method. Here’s the model-agnostic portion of this code:
```swift
func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    return model.dragItems(for: indexPath)
}
```

```
The following helper function, used by the `tableView(_:itemsForBeginning:at:)` method, serves as an interface to the data model in this sample code project:
```swift
func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
    let placeName = placeNames[indexPath.row]

    let data = placeName.data(using: .utf8)
    let itemProvider = NSItemProvider()
    
    itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
        completion(data, nil)
        return nil
    }

    return [
        UIDragItem(itemProvider: itemProvider)
    ]
}
```

#### 
To consume data from a drop session in a table view, you implement three delegate methods.
First, your app can refuse the drag items based on their class, the state of your app, or other requirements. This project’s implementation allows a user to drop only instances of the  class. Here is the model-agnostic portion of this code:
```swift
func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
    return model.canHandle(session)
}
```

```
The following helper function, used by the  method, serves as the interface to the data model:
```swift
func canHandle(_ session: UIDropSession) -> Bool {
    return session.canLoadObjects(ofClass: NSString.self)
}
```

```
Second, you must tell the system how you want to consume the data, which is typically by copying it. You specify this choice by way of a drop proposal:
```swift
func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
    var dropProposal = UITableViewDropProposal(operation: .cancel)
    
    // Accept only one drag item.
    guard session.items.count == 1 else { return dropProposal }
    
    // The .move drag operation is available only for dragging within this app and while in edit mode.
    if tableView.hasActiveDrag {
        if tableView.isEditing {
            dropProposal = UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
    } else {
        // Drag is coming from outside the app.
        dropProposal = UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }

    return dropProposal
}
```

```
Finally, after the user lifts their finger from the screen, indicating their intent to drop the drag items, your table view has one opportunity to request particular data representations of the drag items:
```swift
/**
     This delegate method is the only opportunity for accessing and loading
     the data representations offered in the drag item. The drop coordinator
     supports accessing the dropped items, updating the table view, and specifying
     optional animations. Local drags with one item go through the existing
     `tableView(_:moveRowAt:to:)` method on the data source.
*/
func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    let destinationIndexPath: IndexPath
    
    if let indexPath = coordinator.destinationIndexPath {
        destinationIndexPath = indexPath
    } else {
        // Get last index path of table view.
        let section = tableView.numberOfSections - 1
        let row = tableView.numberOfRows(inSection: section)
        destinationIndexPath = IndexPath(row: row, section: section)
    }
    
    coordinator.session.loadObjects(ofClass: NSString.self) { items in
        // Consume drag items.
        let stringItems = items as! [String]
        
        var indexPaths = [IndexPath]()
        for (index, item) in stringItems.enumerated() {
            let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
            self.model.addItem(item, at: indexPath.row)
            indexPaths.append(indexPath)
        }

        tableView.insertRows(at: indexPaths, with: .automatic)
    }
}
```


## Adopting hover support for Apple Pencil
> https://developer.apple.com/documentation/uikit/adopting-hover-support-for-apple-pencil

### 
#### 
#### 
The sample project uses a , which reacts when a person presses and holds a touch for a minimum period of time, to draw strokes with Apple Pencil.
The app implements the `DrawGestureRecognizer` subclass, which extends the capabilities of its superclass  to track the `currentTouch` and `currentEvent`. These additional properties provide the information necessary to implement high-fidelity drawing.
```swift
class DrawGestureRecognizer: UILongPressGestureRecognizer {
    
    weak var currentTouch: UITouch?
    weak var currentEvent: UIEvent?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        currentTouch = touches.first
        currentEvent = event
    }
    
    override func reset() {
        super.reset()
        currentTouch = nil
        currentEvent = nil
    }
}
```

```
The drawing implementation is in the `drawGesture(_:)` method. During the  state of the draw gesture, this method attempts to retrieve additional touches associated with the main touch `currentTouch` through . This extra touch data creates a smoother drawing experience with lower latency and higher precision.
```swift
case .changed:
    if let drawGR = drawGestureRecognizer,
       let currentTouch = drawGR.currentTouch,
       let currentEvent = drawGR.currentEvent,
       let touches = currentEvent.coalescedTouches(for: currentTouch) {
        for touch in touches {
            let point = touch.preciseLocation(in: self)
            updatePath(point: point)
        }
    } else {
        updatePath(point: point)
    }
```

#### 
The sample project uses a hover gesture recognizer to generate a visual preview of the stroke before Apple Pencil touches down on the iPad screen. A  reacts when a pointer from a pointing device such as Apple Pencil moves over a user-interface element. When a person hovers the Apple Pencil a short distance above the iPad screen, the app generates a preview.
The sample project creates an instance of  to handle the hover gesture.
```swift
let hoverGesture = UIHoverGestureRecognizer(target: self, action: #selector(hoverGesture(_:)))
```

```
The hover preview implementation is in the `hoverGesture(_:)` method. This method waits for the draw gesture to end before starting hover preview rendering. This delay ensures that drawing and previewing don’t occur at the same time to create overlapping visual effects in the UI.
```swift
guard !isDrawing else { return }
```

#### 
The sample calculates the preview alpha value in the `hoverGesture(_:)` method using the following values:
- `maxPreviewZOffset`—A constant that represents the maximum distance between the Apple Pencil and the iPad screen. The sample uses the maximum distance `1.0` because `zOffset` is normalized.
- `fadeZOffset`—A constant that represents the threshold distance at which the preview alpha switches between fully opaque and partially opaque, causing the visual preview effect to begin fading out.
```swift
previewAlpha = 1.0 - max(zOffset - fadeZOffset, 0.0) / (maxPreviewZOffset - fadeZOffset)
```

#### 
By default, hover gestures work with pointing devices such as trackpads as well as Apple Pencil. For example, running the sample code project on an iPad with a connected trackpad renders a hover preview when the pointer passes over the drawing canvas. However, this sample provides a different hover experience for Apple Pencil than for a trackpad, so the default behavior might be unsuitable for trackpad input.
To restrict the hover preview to Apple Pencil input only and disable it for a trackpad, uncomment the following line of code and run the app again:
```swift
// hoverGesture.allowedTouchTypes = [ UITouch.TouchType.pencil.rawValue as NSNumber ]
```


## Adopting system selection UI in custom text views
> https://developer.apple.com/documentation/uikit/adopting-system-selection-ui-in-custom-text-views

### 
#### 
If your app handles text input through a custom text view that builds on , you can display the system selection UI manually. Create a  interaction and add it to your custom text view that adopts .
```swift
// Set up the interaction.
let selectionDisplayInteraction = UITextSelectionDisplayInteraction(textInput: documentView,
                                                     delegate: self)
documentView.addInteraction(selectionDisplayInteraction)
```

```
When your custom text view becomes active or becomes first responder, activate the interaction.
```swift
// Activate the interaction when the text view becomes active.
func didBecomeActive() {
    selectionDisplayInteraction.isActivated = true
}
```

#### 
When a person interacts with text in your custom text view, notify the interaction as the state of the text selection changes.
```swift
// Notify the interaction when the text selection changes.
func didChangeSelection() {
    selectionDisplayInteraction.setNeedsSelectionUpdate()
}
```

#### 
#### 
Your custom text view can also display the system UI for the loupe, which people use for placing the text cursor in large bodies of text. When a person interacts with your custom text view in a way that you want to display the loupe, such as a pan gesture, call  on a  object. The system animates the presentation and placement of the loupe according to the starting point you provide. Call  to track the movement of the loupe as a person moves the text cursor, and  to hide the loupe and end the session.
The following code shows how to show the loupe using a pan gesture recognizer.
```swift
// Show a loupe with a pan gesture.
var loupeSession: UITextLoupeSession?

func didRecognizePanGesture(_ gesture: UIPanGestureRecognizer) {
    let location = gesture.location(in: view)
    let cursorView = selectionDisplayInteraction.cursorView
    switch gesture.state {
    case .began:
        loupeSession = UITextLoupeSession.begin(at: location,
                                                fromSelectionWidgetView: cursorView,
                                                in: view)
    case .changed:
        loupeSession?.move(to: location, withCaretRect: cursorView.frame,
                           trackingCaret: true)
    case .ended, .cancelled, .failed:
        loupeSession?.invalidate()
        loupeSession = nil
    default:
        break
    }
}
```

#### 
When your custom text view becomes inactive or resigns first responder status, make sure to deactivate the interaction.
```swift
// Deactivate the interaction when the text view becomes inactive.
func didBecomeInactive() {
    selectionDisplayInteraction.isActivated = false
}
```


## Allowing the simultaneous recognition of multiple gestures
> https://developer.apple.com/documentation/uikit/allowing-the-simultaneous-recognition-of-multiple-gestures

### 
To allow a gesture recognizer to operate simultaneously with other gestures, assign a delegate object that implements the  method to it. UIKit calls this method for pairs of gesture recognizers attached to the same view. Returning `true` allows both gestures to process events simultaneously.
The following code shows the  method from the app shown in the previous image. This method returns `true` when the gesture recognizers are attached to the same view. If the gesture recognizers are attached to different views, or if one of the objects is a long press gesture recognizer, this method returns `false`.
```swift
func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
       shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
   // If the gesture recognizer's view isn't one of the squares, do not
   // allow simultaneous recognition.
   if gestureRecognizer.view != self.yellowView && 
            gestureRecognizer.view != self.cyanView && 
            gestureRecognizer.view != self.magentaView {
      return false
   }
   // If the gesture recognizers are on different views, do not allow
   // simultaneous recognition.
   if gestureRecognizer.view != otherGestureRecognizer.view {
      return false
   }
   // If either gesture recognizer is a long press, do not allow
   // simultaneous recognition.
   if gestureRecognizer is UILongPressGestureRecognizer || 
          otherGestureRecognizer is UILongPressGestureRecognizer {
      return false
   }
 
   return true
}
```


## Asynchronously loading images into table and collection views
> https://developer.apple.com/documentation/uikit/asynchronously-loading-images-into-table-and-collection-views

### 
#### 
In the sample, the class `ImageCache.swift` demonstrates a basic mechanism for image loading from a URL with  and caching the downloaded images using . Views such as `UITableView` and `UICollectionView` are subclasses of `UIScrollView`.
As the user scrolls in a view, the app requests the same image repeatedly. This sample holds onto the relevant completion blocks until the image loads, then passes the image to all of the requesting blocks so the API only has to make one call to fetch an image for a given URL. The following code shows how the sample project constructs a basic caching and loading method:
```swift
// Returns the cached image if available, otherwise asynchronously loads and caches it.
final func load(url: NSURL, item: Item, completion: @escaping (Item, UIImage?) -> Swift.Void) {
    // Check for a cached image.
    if let cachedImage = image(url: url) {
        DispatchQueue.main.async {
            completion(item, cachedImage)
        }
        return
    }
    // In case there are more than one requestor for the image, we append their completion block.
    if loadingResponses[url] != nil {
        loadingResponses[url]?.append(completion)
        return
    } else {
        loadingResponses[url] = [completion]
    }
    // Go fetch the image.
    ImageURLProtocol.urlSession().dataTask(with: url as URL) { (data, response, error) in
        // Check for the error, then data and try to create the image.
        guard let responseData = data, let image = UIImage(data: responseData),
            let blocks = self.loadingResponses[url], error == nil else {
            DispatchQueue.main.async {
                completion(item, nil)
            }
            return
        }
        // Cache the image.
        self.cachedImages.setObject(image, forKey: url, cost: responseData.count)
        // Iterate over each requestor for the image and pass it back.
        for block in blocks {
            DispatchQueue.main.async {
                block(item, image)
            }
            return
        }
    }.resume()
}
```

#### 
Generally the app should wait until the data source requests a cell to fetch and set an image. The sample project demonstrates one approach to fetching and displaying an image on a reusable view:
```swift
var content = cell.defaultContentConfiguration()
content.image = item.image
ImageCache.publicCache.load(url: item.url as NSURL, item: item) { (fetchedItem, image) in
    if let img = image, img != fetchedItem.image {
        var updatedSnapshot = self.dataSource.snapshot()
        if let datasourceIndex = updatedSnapshot.indexOfItem(fetchedItem) {
            let item = self.imageObjects[datasourceIndex]
            item.image = img
            updatedSnapshot.reloadItems([item])
            self.dataSource.apply(updatedSnapshot, animatingDifferences: true)
        }
    }
}
cell.contentConfiguration = content
```


## Auditing pointer usage
> https://developer.apple.com/documentation/uikit/auditing-pointer-usage

### 
#### 
When you cast pointers to an integer type, use pointer types consistently to ensure that all of your variables are large enough to hold an address.
The code below casts a pointer to an `int` type to perform arithmetic on the address. In the 32-bit runtime, this code works because an `int` type and a pointer are the same size. However, in the 64-bit runtime, a pointer is larger than an `int` type, so the assignment loses some of the pointer’s data. To address this, remove the casts. The compiler-generated code now advances the pointer correctly.
```objc
int *c = something passed in as an argument...

int *d = (int *)((int)c + 4); // Incorrect.

int *d = c + 1;               // Correct.
```

#### 
Always use `sizeof` to obtain the correct size for any structure or variable you allocate. Never call `malloc` with an explicit size to allocate space for a variable.
```objc
// Incorrect.
uint32_t *x = (uint32_t *)malloc(4);

// Correct.
uint32_t *x = (uint32_t *)malloc(sizeof(uint32_t));
```

Search your code for any instance of `malloc` that isn’t followed by `sizeof`.
#### 
To read an object’s `isa` field, use the class property or call the  function instead. To write to an object’s `isa` field, call the  function.
#### 
| `int` | `%d` |
| `long` | `%ld` |
| `long long` | `%lld` |
| `size_t` | `%zu` |
| `ptrdiff_t` | `%td` |
| any pointer | `%p` |
| `int[N]_t` (such as `int32_t`) | `PRId[N]` (such as `PRId32`) |
| `uint[N]_t` | `PRIu[N]` |
| `int_least[N]_t` | `PRIdLEAST[N]` |
| `uint_least[N]_t` | `PRIuLEAST[N]` |
| `int_fast[N]_t` | `PRIdFAST[N]` |
| `uint_fast[N]_t` | `PRIuFAST[N]` |
| `intptr_t` | `PRIdPTR` |
| `uintptr_t` | `PRIuPTR` |
| `intmax_t` | `PRIdMAX` |
| `uintmax_t` | `PRIuMAX` |
This example code prints an `intptr_t` variable (a pointer-sized integer) and a pointer.
| `uintmax_t` | `PRIuMAX` |
This example code prints an `intptr_t` variable (a pointer-sized integer) and a pointer.
```objc
#include <inttypes.h>
void *foo;
intptr_t k = (intptr_t) foo;
void *ptr = &k;

printf("The value of k is %" PRIdPTR "\n", k);
printf("The value of ptr is %p\n", ptr);
```


## Building an app with a document browser
> https://developer.apple.com/documentation/uikit/building-an-app-with-a-document-browser

### 
#### 
Apps based on a document browser also declare the document types that they can open. The sample code app declares support for text files in the project editor’s Info pane. For more information on setting the document type, see .
Finally, the sample code configures the document browser in the `DocumentBrowserViewController` class’s `viewDidLoad()` method. Specifically, it enables document creation, and disables multiple document selection. This lets users create new documents from the browser, while also preventing them from opening more than one document at a time.
```swift
allowsDocumentCreation = true
allowsPickingMultipleItems = false
```

#### 
When the user creates a new document, the system calls the document browser delegate’s  method.
```swift
// Create a new document.
func documentBrowser(_ controller: UIDocumentBrowserViewController,
                     didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
    
    os_log("==> Creating A New Document.", log: .default, type: .debug)
    
    let doc = TextDocument()
    let url = doc.fileURL
    
    // Create a new document in a temporary location.
    doc.save(to: url, for: .forCreating) { (saveSuccess) in
        
        // Make sure the document saved successfully.
        guard saveSuccess else {
            os_log("*** Unable to create a new document. ***", log: .default, type: .error)
            
            // Cancel document creation.
            importHandler(nil, .none)
            return
        }
        
        // Close the document.
        doc.close(completionHandler: { (closeSuccess) in
            
            // Make sure the document closed successfully.
            guard closeSuccess else {
                os_log("*** Unable to create a new document. ***", log: .default, type: .error)
                
                // Cancel document creation.
                importHandler(nil, .none)
                return
            }
            
            // Pass the document's temporary URL to the import handler.
            importHandler(url, .move)
        })
    }
}
```

#### 
#### 
The document browser provides two built-in animations: one for loading a file, another for transitioning to and from the document view.
To enable either of the system-provided document browser animations, first you need to request a transition controller for the document by calling the  method.
```swift
transitionController = transitionController(forDocumentAt: documentURL)
```

```
To enable the loading animation, assign a  object to the transition controller when you begin to load the document.
```swift
// Set up the loading animation.
transitionController!.loadingProgress = doc.loadProgress
```


## Changing the appearance of selected and highlighted cells
> https://developer.apple.com/documentation/uikit/changing-the-appearance-of-selected-and-highlighted-cells

### 
#### 
#### 
The cell’s  property references the view to display as the background of the cell when it loads for the first time and when it isn’t highlighted or selected. When the cell’s state changes to highlighted or selected, the collection view modifies the properties of a cell to indicate the new state. It doesn’t, however, automatically change the visual appearance of the cell. That is, unless you set the cell’s  property to a view.
Setting the  to a view causes the collection view to replace the default background with the selected background when highlighting or selecting a cell. Your app doesn’t need to do anything else. The collection view changes the cell’s visual appearance automatically as the cell’s state changes. For example, the sample app uses the  property to change the cell’s background color from red to blue when selecting the cell.
```swift
override func awakeFromNib() {
    super.awakeFromNib()
    
    let redView = UIView(frame: bounds)
    redView.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
    self.backgroundView = redView

    let blueView = UIView(frame: bounds)
    blueView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 1, alpha: 1)
    self.selectedBackgroundView = blueView
}
```

#### 
Providing a selected background view in a cell is an easy way to have the collection view change the cell’s appearance based on its state, but you can do more than just changing the background. You can, for example, display a checkmark icon in selected cells or distinguish between highlighted and selected states visually.
The collection view’s  has methods that provide you many opportunities to tweak the selection and highlighting appearance of your collection view. For example, if you prefer to draw the selection state of the cell yourself, you can leave the  property set to `nil`. Then apply any visual changes to the cell in the  delegate method. The sample app uses this method, along with the selected background, to show a star in the selected cell. The app removes the star in the  delegate method.
```swift
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
        cell.showIcon()
    }
}

func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
        cell.hideIcon()
    }
}
```

```
If you prefer to draw the highlight state, use the  and  delegate methods. The sample app uses these two methods to display a different shade of red as the highlighted background color. Because cells in this app use the blue view for their , the delegate must apply its changes to the content view of the cells to ensure the changes are visible.
```swift
func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) {
        cell.contentView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
    }
}

func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) {
        cell.contentView.backgroundColor = nil
    }
}
```


## Checking the availability of 3D Touch
> https://developer.apple.com/documentation/uikit/checking-the-availability-of-3d-touch

### 
To determine if 3D Touch is available on a device, check the  property of any object — such as your app’s views and view controllers — that adopts the  protocol. The following code shows how you might use this property to enable or disable features at load time from your view controller. Use the  method to detect changes to 3D Touch availability while your app is running.
```swift
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // Check the trait collection to see if force is available.
        if self.traitCollection.forceTouchCapability == .available {
            // Enable 3D Touch features
        } else {
            // Fall back to other non-3D Touch features.
        }
    }
 
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Update the app's 3D Touch support.
        if self.traitCollection.forceTouchCapability == .available {
            // Enable 3D Touch features
        } else {
            // Fall back to other non-3D Touch features.
        }
    }
}
```


## Choosing a specific interface style for your iOS app
> https://developer.apple.com/documentation/uikit/choosing-a-specific-interface-style-for-your-ios-app

### 
#### 
- Windows—Everything in the window adopts the style, including the root view controller and all presentation controllers that display content in that window.
The following code example enables a light appearance for a view controller and all of its views.
```swift
    override func viewDidLoad() {
        super.viewDidLoad()

        // Always adopt a light interface style.    
        overrideUserInterfaceStyle = .light
    }
```

#### 
#### 

## Choosing a user interface idiom for your Mac app
> https://developer.apple.com/documentation/uikit/choosing-a-user-interface-idiom-for-your-mac-app

### 
#### 
#### 
Because the system sets control sizes appropriately when the user interface idiom is , the system no longer needs to scale your app’s interface to match Mac sizing. Screen points are identical in size to those in AppKit-based apps. However, if your app has hard-coded sizes or uses images sized for iPad, you may need to update your app to accommodate the size differences. You may also need to adjust auto layout constraints.
Some controls provide additional settings that help you achieve a more Mac-like appearance. For instance,  can appear as a checkbox when idiom is  by setting  to . Then set  to the text of the checkbox.
```swift
let showFavoritesAtTop = UISwitch()
showFavoritesAtTop.preferredStyle = .checkbox
if traitCollection.userInterfaceIdiom == .mac {
    showFavoritesAtTop.title = "Always show favorite recipes at the top"
}
```

#### 
To determine if your app is running in the Mac idiom, compare the value of the  property with . When the comparison is , you can tailor the behavior of your app for the Mac; for example, to display a different child view.
```swift
let childViewController: UIViewController
if traitCollection.userInterfaceIdiom == .mac {
    childViewController = MacOptimizedChildViewController()
} else {
    childViewController = ChildViewController()
}
addChild(childViewController)
childViewController.view.frame = view.bounds
view.addSubview(childViewController.view)
childViewController.didMove(toParent: self)
```

#### 
To provide a slider with an appearance that’s consistent in both iPad and Mac versions of the app, set the  of the slider to . This behavioral style tells the slider to behave as if the user interface idiom is  even though the app is using the Mac idiom.
Remember, macOS doesn’t scale the interface of apps that use the Mac idiom so you may need to update your app to accommodate size differences even when the preferred behavioral style is . For example, a slider with a custom thumb image may need an image of a different size for the Mac app than the one used in the iPad app.
```swift
let slider = UISlider()
slider.minimumValue = 0
slider.maximumValue = 1
slider.value = 0.5
slider.preferredBehavioralStyle = .pad

if slider.traitCollection.userInterfaceIdiom == .mac {
    slider.setThumbImage(#imageLiteral(resourceName: "customSliderThumbMac"), for: .normal)
} else {
    slider.setThumbImage(#imageLiteral(resourceName: "customSliderThumb"), for: .normal)
}
```

#### 
Even when your Mac app runs in the  idiom, you may need to change the appearance or behavior of your Mac app. Use the `targetEnvironment()` compilation conditional to choose a different code path depending on the target environment.
For example, if your iPad app displays a delete item confirmation in a popover next to a delete button but you want to display the confirmation as an alert in your Mac app, add a `targetEnvironment()` conditional to determine the preferred style of the alert controller.
```swift
let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
    if dataStore.delete(recipe) {
        self.recipe = nil
    }
}

let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

#if targetEnvironment(macCatalyst)
let preferredStyle = UIAlertController.Style.alert
#else
let preferredStyle = UIAlertController.Style.actionSheet
#endif

let alert = UIAlertController(title: "Are you sure you want to delete \(recipe.title)?", message: nil, preferredStyle: preferredStyle)
alert.addAction(deleteAction)
alert.addAction(cancelAction)

if let popoverPresentationController = alert.popoverPresentationController {
    popoverPresentationController.barButtonItem = sender as? UIBarButtonItem
}

present(alert, animated: true, completion: nil)
```


## Computing the perpendicular force of Apple Pencil
> https://developer.apple.com/documentation/uikit/computing-the-perpendicular-force-of-apple-pencil

### 
On a 3D Touch device, force from a person’s fingers is measured perpendicular to the surface of the screen. However, force reported by Apple Pencil is measured along its long axis, which often isn’t perpendicular to the screen. Instead of using the Apple Pencil force values as is, you might want to compute only the perpendicular portion of the force so that you can use the same code for touches originating from a person’s fingers or from Apple Pencil.
The following code shows how to add a `perpendicularForce` property to the  class to report the perpendicular force supplied by Apple Pencil. For touches involving Apple Pencil, this method divides the reported force value by the sine of the pencil’s altitude. For other touches, it reports the existing force value.
```swift
extension UITouch {
    var perpendicularForce: CGFloat {
        if type == .pencil {
            return force / sin(altitudeAngle)
        } else {
            return force
        }
    }
}

```


## Configuring a custom keyboard interface
> https://developer.apple.com/documentation/uikit/configuring-a-custom-keyboard-interface

### 
#### 
Use the  to determine the current text input view’s keyboard input type. For each keyboard type that your app supports, configure your interface accordingly. One way to do this is by implementing  in your view controller, then compare the ‘s  to your keyboard’s current display. If it’s different, update your interface accordingly.
```swift
let keyboardType = textDocumentProxy.keyboardType

switch(keyboardType) {
case .asciiCapable: …
case .emailAddress: …
case .numberPad: …
…
}
```

#### 
#### 
UIInputViewController conforms to the  protocol to give access to a wide variety of properties related to these common behaviors. These properties indicate which settings are currently active for things like autocompletion type, autocapitalization type, enabling the Return key, smart quotes, dashes, and more. See  for a complete list.
Another common behavior is the ability to dismiss the keyboard. Users can end editing in the current text input view by dismissing the keyboard. You can implement a button to dismiss the keyboard by calling :
```swift
@IBAction func dismissButtonTapped(_ sender: Any) {
    dismissKeyboard()
}
```

#### 
#### 
#### 

## Configuring and displaying symbol images in your UI
> https://developer.apple.com/documentation/uikit/configuring-and-displaying-symbol-images-in-your-ui

### 
#### 
In SwiftUI, you use `Image(systemName:)` to load a system symbol image and `Image(_:)` to load your custom symbol, as the following code shows:
The following examples show how to load a system symbol and a custom symbol across frameworks.
In SwiftUI, you use `Image(systemName:)` to load a system symbol image and `Image(_:)` to load your custom symbol, as the following code shows:
```swift
// Create a system symbol image.
Image(systemName: "multiply.circle.fill")

// Create a custom symbol image using an asset in an asset catalog in Xcode.
Image("custom.multiply.circle")
```

```
In UIKit, a  object includes methods for loading the symbol image with specific traits or configuration options. When you load system symbol images, use , , or . When you load your custom symbol images from an asset catalog, use , , or .
```swift
// Create a system symbol image.
let image = UIImage(systemName: "multiply.circle.fill")                  

// Create a custom symbol image using an asset in an asset catalog in Xcode.
let image = UIImage(named: "custom.multiply.circle")
```

```
When you use AppKit, use  to load a system symbol image, and  to load your custom symbol image.
```swift
// Create a system symbol image with an accessibility description.
let image = NSImage(systemSymbolName: "multiply.circle.fill",
                    accessibilityDescription: "A multiply symbol inside a filled circle.")

// Create a custom symbol image using an asset in an asset catalog in Xcode.
let image = NSImage(named: "custom.multiply.circle")
```

#### 
To make the symbol image blend in with the rest of your content, you create a  or  object with information about how to style the symbol image. Configure the object with the text style you use for neighboring labels and text views, or specify the font you use in those views. You can add weight information to give the symbol image a thinner or thicker appearance, and you can specify whether you want the image to appear slightly larger or smaller than the neighboring text.
In UIKit, you assign configuration data to the  property of the `UIImageView` that contains your symbol image. Typically, you apply configuration data only to image views. For other types of system views, UIKit provides configuration data based on system requirements. For example, bars configure the symbol images in their bar button items to match the bar’s configuration. The only other time you might use configuration data is when drawing the image directly. In that case, use the  method to create a version of your image that includes the specified configuration data.
```swift
// Create a configuration object that the system initializes with two palette colors.
var config = UIImage.SymbolConfiguration(paletteColors: [.systemTeal, .systemGray5])

// Apply a configuration that scales to the system font point size of 42.
config = config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 42.0)))

// Apply the configuration to an image view.
imageView.preferredSymbolConfiguration = config
```

```
If you’re using SwiftUI, there are several modifiers available to configure a symbol image, as the following code shows:
```swift
Image(systemName: "multiply.circle.fill")
      .foregroundStyle(.teal, .gray)
      .font(.system(size: 42.0))
```

```
In AppKit, you create a configuration object and set  on .
```swift
var configuration = NSImage.SymbolConfiguration(paletteColors: [.systemTeal, .systemGray])
configuration = config.applying(.init(textStyle: .title1))
imageView.symbolConfiguration = config
```

#### 
SF Symbols contains four rendering modes: monochrome, palette, hierarchical, and multicolor. Symbols don’t have an intrinsic color, so by default, the system uses the tint color to render them. For example, the following code illustrates applying a tint color to an entire image:
```swift
// Create a system symbol image and apply a tint using SwiftUI.
Image(systemName: "multiply.circle.fill")
      .foregroundColor(.red)

// Create a symbol image with a tint using UIKit.
imageView.image = image?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
```

```
In SwiftUI, you set the rendering mode using , and apply colors using `foregroundStyle(_:)`. If a symbol doesn’t support the rendering mode you choose, the system uses the monochrome version. Using `foregroundStyle` with multiple colors implies switching to palette rendering mode, so you can omit setting the rendering mode.
```swift
// Create a system symbol image in palette rendering mode.
Image(systemName: "multiply.circle.fill")
      .foregroundStyle(.teal, .gray)
```

```
In UIKit and AppKit, you use a symbol configuration object to modify a symbol’s rendering mode. In AppKit, you apply a configuration using , whereas in UIKit, you apply a configuration by using , as the code below shows:
```swift
// Create an object configured for palette rendering mode.
let config = UIImage.SymbolConfiguration(paletteColors: [.systemTeal, .systemGray])

// Create a new symbol image using the configuration object.
imageView.image = image.applyingSymbolConfiguration(config)
```

#### 
In iOS 16 and later, the system can dynamically apply colors to system and custom symbols using a percentage value to convey the strength or progress over time. For example, the following code creates a symbol of a speaker wave with two of the three bars highlighted:
```swift
// Create a system symbol image at 36% intensity.
let image = UIImage(systemName: "speaker.wave.3", variableValue: 0.36)
```

#### 
There are nine symbol weights corresponding to a weight of the San Francisco system font, helping you achieve precise weight matching between symbols and adjacent text, while supporting flexibility for different sizes and context.
By specifying a scale, you adjust a symbol’s emphasis compared to adjacent text without disrupting the weight matching with text that uses the same point size.  See  (SwiftUI),  (UIKit), and  (AppKit).
```swift
// Create a large scaled symbol image using SwiftUI.
Image(systemName: "multiply.circle.fill")
      .imageScale(.large)

// Create a large scaled symbol image using UIKit.
var config = UIImage.SymbolConfiguration(scale: .large)
imageView.image = image.applyingSymbolConfiguration(config)

// Create a large scaled symbol image using AppKit.
var config = NSImage.SymbolConfiguration(scale: .large)
imageView.image = image.withSymbolConfiguration(config)
```

#### 
In SwiftUI, you use the modifier `symbolVariant(_:)` to apply a variant. Search the SF Symbols app to find the variants the multiply symbol supports, such as `circle`, `circle.fill`, `square`, and `square.fill`.
```swift
// Create a system symbol image that is enclosed with a filled circle variant.
Image(systemName: "multiply")
      .symbolVariant(.circle.fill)
```

#### 
Because of the typographical nature of SF Symbols, when you position an image view containing a symbol image next to a label, you should align the views using their baselines. To align views in your storyboard, select the two views and add a first baseline constraint. Programmatically, you create this constraint by setting the  of both views to be equal, as the following code example shows:
All system symbol images include baseline information, and `UIImage` exposes the baseline value as an offset from the bottom of the image. Typically, the baseline of a symbol image aligns with the bottom of any text that appears in the image, but even symbol images without text have a baseline. In AppKit, a symbol’s baseline corresponds to the bottom of the  property, and in UIKit you can add a baseline to any image by calling its  method.
```swift
// Create a custom symbol image.
let image = UIImage(named: "custom.multiply.circle")

// Add an offset of 2.0 points from the baseline.
let baselineImage = image?.withBaselineOffset(fromBottom: 2.0)
```

```
In SwiftUI, you use  to baseline align a symbol with text.
```swift
HStack(alignment: .firstTextBaseline) {
    Image(systemName: "menucard")
    Text("SF Symbols")
}
```

#### 
Programmatically, you need to use #`available` to load assets appropriately.
Depending on the operating systems you support, you may need to provide assets that you fall back to. For example, SF Symbols is only supported in iOS 13 and later. In your asset catalog you might have a symbol image named `gamecontroller`, and a fallback PNG asset named `gamecontroller` that you use for earlier operating system versions. Using Interface Builder, set an image view with your asset named `gamecontroller` and it loads the first available asset based on the platform.
Programmatically, you need to use #`available` to load assets appropriately.
```swift
if #available(iOS 13.0, *) {
    // Load an SF Symbol image.
} else {
    // Load a PNG asset.
}
```


## Configuring the cells for your table
> https://developer.apple.com/documentation/uikit/configuring-the-cells-for-your-table

### 
#### 
Reuse identifiers facilitate the creation and recycling of your table’s cells. A reuse identifier is a string that you assign to each prototype cell of your table. In your storyboard, select your prototype cell and assign a nonempty value to its identifier attribute. Each cell in a table view must have a unique reuse identifier.
When you need a cell object at runtime, call the table view’s  method, passing the reuse identifier for the cell you want. The table view maintains an internal queue of already-created cells. If the queue contains a cell of the requested type, the table view returns that cell. If not, it creates a new cell using the prototype cell in your storyboard. Reusing cells improves performance by minimizing memory allocations during critical times, such as during scrolling.
```swift
var cell = tableView.dequeueReusableCell(withIdentifier: "myCellType", for: indexPath)
```

#### 
In your  method, configure the content of your cell using the , , and  properties of . Those properties contain views, but the cell object only assigns a view if the style supports the corresponding content. For example, the Basic cell style doesn’t support a detail string, so the  property is `nil` for that style. The following example code shows how to configure a cell that uses the basic cell style.
```swift
override func tableView(_ tableView: UITableView, 
             cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   // Reuse or create a cell. 
   let cell = tableView.dequeueReusableCell(withIdentifier: "basicStyle", for: indexPath)

   // For a standard cell, use the UITableViewCell properties.
   cell.textLabel!.text = "Title text"
   cell.imageView!.image = UIImage(named: "bunny")
   return cell
}
```

#### 
For custom cells, you need to define a  subclass to access your cell’s views. Add outlets to your subclass and connect those outlets to the corresponding views in your prototype cell.
```swift
class FoodCell: UITableViewCell {
    @IBOutlet var name : UILabel?
    @IBOutlet var plantDescription : UILabel?
    @IBOutlet var picture : UIImageView?
}
```

```
In the  method of your data source, use your cell’s outlets to assign values to any views.
```swift
override func tableView(_ tableView: UITableView, 
             cellForRowAt indexPath: IndexPath) -> UITableViewCell {

   // Reuse or create a cell of the appropriate type.
   let cell = tableView.dequeueReusableCell(withIdentifier: "foodCellType", 
                         for: indexPath) as! FoodCell

   // Fetch the data for the row.
   let theFood = foods[indexPath.row]
        
   // Configure the cell’s contents with data from the fetched object.
   cell.name?.text = theFood.name
   cell.plantDescription?.text = theFood.description
   cell.picture?.image = theFood.picture
        
   return cell
}
```

#### 
A table view tracks the height of rows separately from the cells that represent them.  provides default sizes for rows, but you can override the default height by assigning a custom value to the table view’s  property. Always use this property when the height of all of your rows is the same. Doing so is more efficient than returning the height values from your delegate object.
If the row heights aren’t all the same, or can change dynamically, provide the heights using the  method of your delegate object. When you implement this method, you must provide values for every row in your table. The following example code shows how to return a custom height for the first row of each section and use the default height for all other rows.
```swift
override func tableView(_ tableView: UITableView, 
           heightForRowAt indexPath: IndexPath) -> CGFloat {
   // Make the first row larger to accommodate a custom cell.
  if indexPath.row == 0 {
      return 80
   }

   // Use the default size for all other rows.
   return UITableView.automaticDimension
}
```

#### 
#### 

## Creating a custom container view controller
> https://developer.apple.com/documentation/uikit/creating-a-custom-container-view-controller

### 
#### 
4. Call the  method of the child view controller to notify it that the transition is complete.
The following example code instantiates a new child view controller from a storyboard and embeds it as a child of the current view controller. After calling , the code adds the child’s view to the view hierarchy and sets up some layout constraints to size and position it. At the end of the process, it notifies the child.
```swift
// Create a child view controller and add it to the current view controller.
let storyboard = UIStoryboard(name: "Main", bundle: .main)
if let viewController = storyboard.instantiateViewController(identifier: "imageViewController")
                                    as? ImageViewController {
   // Add the view controller to the container.
   addChild(viewController)
   view.addSubview(viewController.view)
            
   // Create and activate the constraints for the child’s view.
   onscreenConstraints = configureConstraintsForContainedView(containedView: viewController.view,
                             stage: .onscreen)
   NSLayoutConstraint.activate(onscreenConstraints)
     
   // Notify the child view controller that the move is complete.       
   viewController.didMove(toParent: self)
}

```

#### 
1. Call the child’s  method with the value `nil`.
#### 
#### 

## Creating a custom keyboard
> https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard

### 
#### 
#### 
If applicable to your custom keyboard, edit the keyboard extension’s `Info.plist` to configure the following options:
Set these keys in the  >  dictionary of the `Info.plist` file:
#### 
Use the  property on  to determine if you should display a button to switch keyboards. If the user has only one keyboard enabled, there’s no need to show a keyboard switching interface. On iPhones with Face ID, iOS automatically shows the globe icon below your keyboard view and sets this property to , indicating that you shouldn’t show your button.
Configure your keyboard switching button with an action targeting the  method of your input view controller subclass. The default custom keyboard template does this by adding an action to the button:
```swift
nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
```

#### 
Custom keyboards run in an isolated process that doesn’t have direct access to the text input view.  provides a  property allowing your keyboard to access the text input view. You use this proxy to get the selected text, insert or delete text, manipulate the text insertion position, and get surrounding textual context in order to support things like autocorrect or autocomplete.
```swift
// Insert a string into the text input view.
textDocumentProxy.insertText("Hello world.")

// Get the currently selected text
let selectedText = textDocumentProxy.selectedText
```

#### 
#### 
For more information on crash logs related to memory usage limits, see  and `EXC_CRASH (SIGQUIT)`.

## Creating custom navigation interactions
> https://developer.apple.com/documentation/uikit/creating-custom-navigation-interactions

### 
#### 
#### 
To get focus to move to Button 4 when the user swipes down from Button 2 or Button 3, a focus guide is required. Create a focus guide and add it to the current view. The focus guide is detectable by the focus engine and redirects focus as indicated.
```swift
let myFocusGuide = UIFocusGuide()
self.view.addLayoutGuide(myFocusGuide)
```

#### 
When the user swipes down from Button 2 or Button 3, the focus should move to Button 4. To make this happen, you need to programmatically add constraints to the focus guide. The focus guide needs to be as wide as Button 2 and Button 3 combined. Set the focus guide’s left constraint to Button 2’s left constraint and its right constraint to Button 3’s right constraint. For convenience, this example sets the focus guide’s top and bottom constraints to Button 4’s top and bottom constraints. Finally, the  property is set to Button 4. The following image shows the location and size of the focus guide created using the constraints in the following code.
```swift
myFocusGuide.leftAnchor.constraint(equalTo: button_2.leftAnchor).isActive = true
myFocusGuide.rightAnchor.constraint(equalTo: button_3.rightAnchor).isActive = true
myFocusGuide.topAnchor.constraint(equalTo: button_4.topAnchor).isActive = true
myFocusGuide.bottomAnchor.constraint(equalTo: button_4.bottomAnchor).isActive = true
myFocusGuide.preferredFocusEnvironments = [button_4]
```


## Creating custom symbol images for your app
> https://developer.apple.com/documentation/uikit/creating-custom-symbol-images-for-your-app

### 
#### 
#### 
The Symbols layer contains up to 27 sublayers, each representing a symbol image variant. Identifiers of symbol variants have the form `<weight>-<{S, M, L}>`, where  corresponds to a weight of the San Francisco system font and , , or  matches the small, medium, or large symbol scale.
```xml
<g id="Symbols">
    <g id="Regular-M" transform="matrix(1 0 0 1 2855.62 1556)">   
        <!-- Path and style details for the Regular-M image variant. -->
    </g>
</g> 
```

- It contains the interpolation sources `Ultralight-S`, `Regular-S`, and `Black-S`.
#### 
The Guides layer contains an uppercase letter  in outline form for each scale in the San Francisco system font as a reference glyph. Use the reference glyphs in the template as guides for how a symbol image looks next to text.
Beginning with template version 3, each image variant of a symbol can have its own margin guides. This allows the margins to vary slightly by weight and scale instead of using a fixed margin for all variants. The explicit margin guides have the form `left-margin-<variant-specifier>` or `right-margin-<variant-specifier>`. The following example represents the left and right guides of the `Regular-S` symbol variant:
```xml
<g id="Guides">
    <line id="left-margin-Regular-S" style="fill:none;stroke:#00AEEF;stroke-width:0.5;opacity:1.0;" x1="1403.33" x2="1403.33" y1="600.784" y2="720.121"/>
    <line id="right-margin-Regular-S" style="fill:none;stroke:#00AEEF;stroke-width:0.5;opacity:1.0;" x1="1496.36" x2="1496.36" y1="600.784" y2="720.121"/>
</g>
```

#### 
#### 
#### 
#### 
If you want to control your symbol’s appearance in rendering modes other than monochrome, you can annotate your symbol. SF Symbols applies annotations to individual shape objects in the form of a CSS style, using a class name that has the form `multicolor-<layer index>:<color name>` or `hierarchical-<layer index>:<hierarchy level>`, and starts the layer index at zero. You set the color name to either a system color, a named color from the app’s asset catalog, or any constant that doesn’t dynamically resolve. A shape can have both multicolor and hierarchical annotations, and they don’t have to be in the same layer.
```xml
<style>
    .multicolor-0:systemBlueColor { fill:#007AFF; opacity:1.0 }
    .multicolor-1:white { fill:#FFFFFF; opacity:1.0 }
    .multicolor-2:tintColor { fill:#007AFF; opacity:1.0 }
    .hierarchical-0:tertiary { fill:#8E8E8E }
    .hierarchical-1:primary { fill:#212121 }
</style>

<g id="Symbols">
    <!-- A variant containing three shapes with multicolor and hierarchical annotations. -->
    <g id="Regular-M" transform="matrix(1 0 0 1 2853.78 1556)">
        <!-- The shape is in the first multicolor layer, whose fill color is systemBlueColor. It’s also in the first layer for hierarchical rendering, and the level is primary. -->
        <path class="multicolor-0:systemBlueColor hierarchical-1:primary" d="...">
   
        <!-- Two additional shapes. --><path class="multicolor-1:white hierarchical-1:primary" d="...">
        <path class="multicolor-2:tintColor hierarchical-0:tertiary" d="...">
     </g>
</g>
```

#### 
System and custom symbols can dynamically apply colors by using a percentage value to convey the strength or progress over time. For example, a wireless signal strength symbol can reflect full signal strength at 100% or no signal at 0%. In SF Symbols, select your symbol and open the color inspector. Each layer allows you to activate variable color for it. The vector file contains the thresholds for your symbol.
```xml
<style>
    <!-- A symbol that contains three variable color layers --> 
    .monochrome-0 {fill:#000000}
    .monochrome-1 {fill:#000000}
    .monochrome-2 {fill:#000000;-sfsymbols-variable-threshold:0.0}
    .monochrome-3 {fill:#000000;-sfsymbols-variable-threshold:0.34}
    .monochrome-4 {fill:#000000;-sfsymbols-variable-threshold:0.68}
</style>
```

#### 
If your minimum deployment target is iOS 15 or later, you only need the version 3 template. If your minimum deployment target is iOS 14, you need to export a version 2, 3, and 4 template, and use the appropriate asset depending on a version check. Use the latest template when sharing with a colleague because they can import it into their SF Symbols app to continue editing and annotating.
The following code example shows the latest template version file — preserving identifiers, but omitting pathing details — and includes additional notes for each area:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--Generator: Apple Native CoreSVG 168-->
<!DOCTYPE svg
  PUBLIC "-//W3C//DTD SVG 1.1//EN"
         "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="3300" height="2200">

<style>
<!-- 
Class names have the form <rendering mode style>-<layer index>:<color name>. Rendering mode is either hierarchical or multicolor, layer index is an integer between [0...N], and color name is either a system color, a named color from your app's asset catalog, or a constant (in which case it doesn't dynamically resolve).

If the color name isn't a system color and isn't in the asset catalog, a style can have a fill attribute. You can use an opacity attribute, and a custom attribute `-sfsymbols-clear-behind:true`, which, when present, occludes other shapes in the symbol that you annotate with that style, and blends with anything behind the symbol. The system may ignore other attributes you add.

Version 4 of the symbol template supports variable color thresholds by using `-sfsymbols-variable-threshold`.
-->
  .multicolor-0:systemBlueColor {fill:#007AFF;-sfsymbols-variable-threshold:0.0}
  .multicolor-1:tertiaryLabelColor {fill:#BDBDBD;-sfsymbols-clear-behind:true}
  .multicolor-2:white {fill:#FFFFFF;opacity:0.4}
  .hierarchical-0:tertiary {fill:#8E8E8E}
  .hierarchical-1:primary {fill:#212121;-sfsymbols-clear-behind:true}
</style>

<g id="Notes">
<!-- 
The symbol template supports rendering mode annotations and path interpolation.
-->
  <text id="template-version">Template v.3.0</text>
</g>

<g id="Guides">
  <line id="Baseline-S" x1="..." x2="..." y1="..." y2="..."/>
  <line id="Capline-S" x1="..." x2="..." y1="..." y2="..."/>
  <line id="Baseline-M" x1="..." x2="..." y1="1126" y2="..."/>
  <line id="Capline-M" x1="..." x2="..." y1="1055.54" y2="..."/>
  <line id="Baseline-L" x1="..." x2="..." y1="1556" y2="..."/>
  <line id="Capline-L" x1="..." x2="..." y1="1485.54" y2="..."/>

  <!-- 
  The symbol template supports explicit margins for each variant.
  -->
  <line id="left-margin-Ultralight-S" x1="..." x2="..." y1="..." y2="..."/>
  <line id="right-margin-Ultralight-S" x1="..." x2="..." y1="..." y2="..."/>
  <line id="left-margin-Regular-S" x1="..." x2="..." y1="..." y2="..."/>
  <line id="right-margin-Regular-S" x1="..." x2="..." y1="..." y2="..."/>
  <line id="left-margin-Black-S" x1="..." x2="..." y1="..." y2="..."/>
  <line id="right-margin-Black-S" x1="..." x2="..." y1="..." y2="..."/>
</g>

<g id="Symbols">
<!-- 
The symbol template generates variants from the following source variants: Black-S, Regular-S, and Ultralight-S. When you create other variants, the system uses them instead of interpolation for that configuration.
-->
  <g id="Black-S">
  <!-- 
  The system concatenates together all shapes for each rendering mode layer. A shape may be present in many layers. Shapes you nest within other shapes, and have opposite path windings, knock holes through their containing shapes.  
  -->
    <path class="multicolor-0:systemBlueColor hierarchical-0:tertiary" d="..."/>
    <path class="multicolor-1:tertiaryLabelColor hierarchical-1:primary" d="..."/>
    <path class="multicolor-0:systemBlueColor multicolor-1:tertiaryLabelColor hierarchical-1:primary" d="..."/>
    <path class="multicolor-2:white hierarchical-1:primary" d="..."/>
  </g>

  <g id="Regular-S">
    <path class="multicolor-0:systemBlueColor hierarchical-0:tertiary" d="..."/>
    <path class="multicolor-1:tertiaryLabelColor hierarchical-1:primary" d="..."/>
    <path class="multicolor-0:systemBlueColor multicolor-1:tertiaryLabelColor hierarchical-1:primary" d="..."/>
    <path class="multicolor-2:white hierarchical-1:primary" d="..."/>
  </g>
  
  <g id="Ultralight-S">
    <path class="multicolor-0:systemBlueColor hierarchical-0:tertiary" d="..."/>
    <path class="multicolor-1:tertiaryLabelColor hierarchical-1:primary" d="..."/>
    <path class="multicolor-0:systemBlueColor multicolor-1:tertiaryLabelColor hierarchical-1:primary" d="..."/>
    <path class="multicolor-2:white hierarchical-1:primary" d="..."/>
  </g>
</g>
</svg>
```

#### 

## Creating self-sizing table view cells
> https://developer.apple.com/documentation/uikit/creating-self-sizing-table-view-cells

### 
#### 
To add support for Dynamic Type, the cell assigns a scaled font to each label. For the headline label, the preferred font with the  text style is used. The preferred font is the system font, which can scale to different sizes. Its initial text size is determined by the font metric for the `headline` text style.
```swift
headlineLabel.font = UIFont.preferredFont(forTextStyle: .headline)
headlineLabel.adjustsFontForContentSizeCategory = true
```

```
For the body label, a custom font is used. However, in order to support Dynamic Type with a custom font, a version of the font must be created that adopts the font metric for a particular text style. In the case of the body label, the Palatino custom font is used with the  text style.
```swift
guard let palatino = UIFont(name: "Palatino", size: 18) else {
    fatalError("""
        Failed to load the "Palatino" font.
        Since this font is included with all versions of iOS that support Dynamic Type, verify that the spelling and casing is correct.
        """
    )
}
bodyLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: palatino)
bodyLabel.adjustsFontForContentSizeCategory = true
```

#### 
#### 
The width of both labels should extend to fill the width of the cell’s content view, and the headline label should appear above the body label. To accomplish this, Auto Layout constraints are added to each label starting with constraints that define the label width. For the headline label, constraints are added that tell the label to fill the space between the content view’s leading and trailing margins. For the body label, constraints are added that set its leading and trailing anchors equal to the headline label’s leading and trailing anchors.
```swift
headlineLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
headlineLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true

bodyLabel.leadingAnchor.constraint(equalTo: headlineLabel.leadingAnchor).isActive = true
bodyLabel.trailingAnchor.constraint(equalTo: headlineLabel.trailingAnchor).isActive = true
```

#### 
2. Set the spacing between the body label and the bottom of the cell’s content view.
3. Set the spacing between the headline and body labels.
```swift
headlineLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: contentView.layoutMarginsGuide.topAnchor, multiplier: 1).isActive = true

contentView.layoutMarginsGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: bodyLabel.lastBaselineAnchor, multiplier: 1).isActive = true

bodyLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: headlineLabel.lastBaselineAnchor, multiplier: 1).isActive = true
```

#### 

## Customizing a document-based app’s launch experience
> https://developer.apple.com/documentation/uikit/customizing-a-document-based-app-s-launch-experience

### 
#### 
- Set the Supports Document Browser key (`UISupportsDocumentBrowser`) in the Custom iOS Target Properties section of the Info tab.
When implementing your  method, verify that you have a valid document and a valid view before updating the view. For more information, see .
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // Configure your launch options.
    mySetupTextView()
}

override func documentDidOpen() {
    mySetupTextView()
}

func mySetupTextView() {
    
    // Make sure you have a valid document.
    guard let document = document as? MyDocument else { return }
            
    // Make sure you have a valid view.
    guard let view else { return }
    
    // Make sure the document is open.
    guard !document.documentState.contains(.closed) else { return }

    // Configure the view.
    textView.text = document.text
}
```

#### 
The document viewer uses app intents to create new documents. It also uses the  structure to specify the different ways your app can create documents.  already provides a default intent and the corresponding `.default` enumeration value.
To add your own intents, start by extending  and adding values for your intents.
```swift
// Extend the creation intent enumeration to add custom options for document creation.
extension UIDocument.CreationIntent {
    static let template = UIDocument.CreationIntent("template")
}
```

```
Then call the  class’s  method to create the intent. Set the intent’s title, and assign it to your  instance’s  or  properties. By default, the system automatically sets the document view controller’s  to the default create document action.
```swift
// Provide an action for the secondary action.
let templateAction = LaunchOptions.createDocumentAction(withIntent: .template)

// Set the intent's title.
templateAction.title = "Choose a Template"

// Add the intent to an action.
launchOptions.secondaryAction = templateAction
```

```
Finally, implement the  protocol’s  method. The system calls this method when something triggers one of the create document intents. In your implementation, use the controller’s  to determine the intent. Create the document, and then pass the URL and the  to the `intentHandler`.
```swift
override func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {

    switch controller.activeDocumentCreationIntent {
    case .template:
        
        // Let someone select a template, and return
        // a URL to that template.
        let templateURL = myPresentTemplateSelection()
        
        // Pass the URL to the import handler.
        importHandler(templateURL, .copy)
        
    default:
        
        // Create the default document.
        let newDocumentURL = myCreateEmptyDocument()
        
        // Pass the URL to the import handler.
        importHandler(newDocumentURL, .move )
    }
}
```

#### 
- Use  to access and configure the document browser controller.
Typically, you configure the launch options in your view controller’s  method.
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Assign the view controller as the browser delegate.
    launchOptions.browserViewController.delegate = self
    
    // Customize launch options.
    launchOptions.title = "My Text Editor"
    launchOptions.background.backgroundColor = .darkGray
    
    // Provide an action for the secondary action.
    let templateAction = LaunchOptions.createDocumentAction(withIntent: .template)
    templateAction.title = "Choose a Template"
    launchOptions.secondaryAction = templateAction
    
    mySetupTextView()
}
```


## Customizing collection view layouts
> https://developer.apple.com/documentation/uikit/customizing-collection-view-layouts

### 
#### 
In practice, on iPhone devices in portrait mode, `ColumnFlowLayout` displays a single vertical column of cells. In landscape mode, or on an iPad, it displays a grid layout.
Use the  function to compute the available screen width of the device and set the  property accordingly.
```swift
override func prepare() {
    super.prepare()

    guard let collectionView = collectionView else { return }
    
    let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
    let maxNumColumns = Int(availableWidth / minColumnWidth)
    let cellWidth = (availableWidth / CGFloat(maxNumColumns)).rounded(.down)
    
    self.itemSize = CGSize(width: cellWidth, height: cellHeight)
    self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
    self.sectionInsetReference = .fromSafeArea
}
```

#### 
The  method is called whenever a layout is invalidated. Override this method to calculate the position and size of every cell, as well as the total dimensions for the entire layout.
```swift
override func prepare() {
    super.prepare()
    
    guard let collectionView = collectionView else { return }

    // Reset cached information.
    cachedAttributes.removeAll()
    contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
    
    // For every item in the collection view:
    //  - Prepare the attributes.
    //  - Store attributes in the cachedAttributes array.
    //  - Combine contentBounds with attributes.frame.
    let count = collectionView.numberOfItems(inSection: 0)
    
    var currentIndex = 0
    var segment: MosaicSegmentStyle = .fullWidth
    var lastFrame: CGRect = .zero
    
    let cvWidth = collectionView.bounds.size.width
    
    while currentIndex < count {
        let segmentFrame = CGRect(x: 0, y: lastFrame.maxY + 1.0, width: cvWidth, height: 200.0)
        
        var segmentRects = [CGRect]()
        switch segment {
        case .fullWidth:
            segmentRects = [segmentFrame]
            
        case .fiftyFifty:
            let horizontalSlices = segmentFrame.dividedIntegral(fraction: 0.5, from: .minXEdge)
            segmentRects = [horizontalSlices.first, horizontalSlices.second]
            
        case .twoThirdsOneThird:
            let horizontalSlices = segmentFrame.dividedIntegral(fraction: (2.0 / 3.0), from: .minXEdge)
            let verticalSlices = horizontalSlices.second.dividedIntegral(fraction: 0.5, from: .minYEdge)
            segmentRects = [horizontalSlices.first, verticalSlices.first, verticalSlices.second]
            
        case .oneThirdTwoThirds:
            let horizontalSlices = segmentFrame.dividedIntegral(fraction: (1.0 / 3.0), from: .minXEdge)
            let verticalSlices = horizontalSlices.first.dividedIntegral(fraction: 0.5, from: .minYEdge)
            segmentRects = [verticalSlices.first, verticalSlices.second, horizontalSlices.second]
        }
        
        // Create and cache layout attributes for calculated frames.
        for rect in segmentRects {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: currentIndex, section: 0))
            attributes.frame = rect
            
            cachedAttributes.append(attributes)
            contentBounds = contentBounds.union(lastFrame)
            
            currentIndex += 1
            lastFrame = rect
        }

        // Determine the next segment style.
        switch count - currentIndex {
        case 1:
            segment = .fullWidth
        case 2:
            segment = .fiftyFifty
        default:
            switch segment {
            case .fullWidth:
                segment = .fiftyFifty
            case .fiftyFifty:
                segment = .twoThirdsOneThird
            case .twoThirdsOneThird:
                segment = .oneThirdTwoThirds
            case .oneThirdTwoThirds:
                segment = .fiftyFifty
            }
        }
    }
}
```

Override the  property, providing a size for the collection view.
```swift
override var collectionViewContentSize: CGSize {
    return contentBounds.size
}
```

Override , defining the layout attributes for a geometric region. The collection view calls this function periodically to display items, which is known as .
```swift
override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var attributesArray = [UICollectionViewLayoutAttributes]()
    
    // Find any cell that sits within the query rect.
    guard let lastIndex = cachedAttributes.indices.last,
          let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else { return attributesArray }
    
    // Starting from the match, loop up and down through the array until all the attributes
    // have been added within the query rect.
    for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
        guard attributes.frame.maxY >= rect.minY else { break }
        attributesArray.append(attributes)
    }
    
    for attributes in cachedAttributes[firstMatchIndex...] {
        guard attributes.frame.minY <= rect.maxY else { break }
        attributesArray.append(attributes)
    }
    
    return attributesArray
}
```

```
Also provide the layout attributes for a specific item by implementing . The collection view calls this function periodically to display one particular item, which is known as .
```swift
override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cachedAttributes[indexPath.item]
}
```

The  function is called for every bounds change from the collection view, or whenever its size or origin changes. This function is also called frequently during scrolling. The default implementation returns `false`, or, if the size and origin change, it returns `true`.
```swift
override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    guard let collectionView = collectionView else { return false }
    return !newBounds.size.equalTo(collectionView.bounds.size)
}
```

#### 
- `insert` with a `Person` object and insertion index.
- `delete` with an index.
- `move` from one index to another.
- `reload` with an index.
First, the `reload` operations are performed without animation because no cell movement is involved:
- `reload` with an index.
First, the `reload` operations are performed without animation because no cell movement is involved:
```swift
// Perform any cell reloads without animation because there is no movement.
UIView.performWithoutAnimation {
    collectionView.performBatchUpdates({
        for update in remoteUpdates {
            if case let .reload(index) = update {
                people[index].isUpdated = true
                collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    })
}
```

```
Next, the remaining operations are animated:
```swift
// Animate all other update types together.
collectionView.performBatchUpdates({
    var deletes = [Int]()
    var inserts = [(person:Person, index:Int)]()

    for update in remoteUpdates {
        switch update {
        case let .delete(index):
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            deletes.append(index)
            
        case let .insert(person, index):
            collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
            inserts.append((person, index))
            
        case let .move(fromIndex, toIndex):
            // Updates that move a person are split into an addition and a deletion.
            collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                    to: IndexPath(item: toIndex, section: 0))
            deletes.append(fromIndex)
            inserts.append((people[fromIndex], toIndex))
            
        default: break
        }
    }
    
    // Apply deletions in descending order.
    for deletedIndex in deletes.sorted().reversed() {
        people.remove(at: deletedIndex)
    }
    
    // Apply insertions in ascending order.
    let sortedInserts = inserts.sorted(by: { (personA, personB) -> Bool in
        return personA.index <= personB.index
    })
    for insertion in sortedInserts {
        people.insert(insertion.person, at: insertion.index)
    }
    
    // The update button is enabled only if the list still has people in it.
    navigationItem.rightBarButtonItem?.isEnabled = !people.isEmpty
})
```


## Customizing the behavior of segue-based presentations
> https://developer.apple.com/documentation/uikit/customizing-the-behavior-of-segue-based-presentations

### 
#### 
#### 
#### 
Because UIKit creates and presents the view controller automatically during a segue, use the  method to pass any data to that view controller before the segue occurs. Implement the method on the view controller containing the object that initiated the segue. Fetch the new view controller from the provided  object, along with information about which segue was triggered.
In the following code example, the current view controller fetches the image associated with the selected table row and passes that image to the new view controller.
```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  // Get the new view controller.
   if let imageVC = segue.destination as? ImageViewController {

      // Fetch the image for the selected row. 
      let image = getImageForSelectedRow()
      imageVC.currentImage = image
   }
}
```

#### 

## Customizing the document browser
> https://developer.apple.com/documentation/uikit/customizing-the-browser

### 
#### 
#### 
#### 
#### 
The following example programmatically creates a document browser for `.txt` files:
For detailed instructions on setting the  key, see .
The following example programmatically creates a document browser for `.txt` files:
```swift
let browser = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: ["public.plain-text"])
```

> **important:**  You must always call the `importHandler`. If you can’t create a new document, pass `nil` for the URL and  for the import mode.

## Data delivery with drag and drop
> https://developer.apple.com/documentation/uikit/data-delivery-with-drag-and-drop

### 
#### 
The table view in the sample app displays a list of contacts. When the user begins dragging a contact, the system calls the  method. The method’s implementation retrieves the contact from the list using the `at` parameter to determine the contact’s location within the list. The method then creates an item provider with the contact object and wraps the item provider in a  object. The method places the drag item into an array which it returns to the system. Finally, the system adds the drag item to the current drag session.
```swift
func tableView(_ tableView: UITableView,
               itemsForBeginning session: UIDragSession,
               at indexPath: IndexPath) -> [UIDragItem] {
    let contactCard = dataSource.clients[indexPath.row]
    let dragItem = UIDragItem(itemProvider: NSItemProvider(object: contactCard))
    return [dragItem]
}
```

```
The user may select multiple contacts to drag to another app. Each time the user selects a contact, the system calls the  method. Similar to beginning a drag session, this method creates an item provider for the selected contact, creates a drag item that contains the item provider, and returns an array containing the drag item so the system can add the drag item to the drag session.
```swift
func tableView(_ tableView: UITableView,
               itemsForAddingTo session: UIDragSession,
               at indexPath: IndexPath,
               point: CGPoint) -> [UIDragItem] {
    // use this to NOT allow additional items to the drag:
    // return []

    let contactCard = dataSource.clients[indexPath.row]
    let dragItem = UIDragItem(itemProvider: NSItemProvider(object: contactCard))
    dragItem.localObject = true // makes it faster to drag and drop content within the same app
    return [dragItem]
}
```

#### 
The `loadObject` method asks the `ContactCard` class for the contact card object. The class, which conforms to the  protocol, implements the  class method, which creates and initializes a contact card object with the item provider data.
When the user drops a contact at a specific location within the table view, the completion handler (from the `loadObject` call) creates a placeholder that displays a gap at the drop location. Next, the handler inserts the dropped contact into the list of contacts at the index path of the drop location. And finally, the completion handler replaces the placeholder with a view displaying the contact.
```swift
_ = dropItem.dragItem.itemProvider.loadObject(
    ofClass: ContactCard.self,
    completionHandler: { (data, error) in
        if error == nil {
            DispatchQueue.main.async {
                let placeHolder = UITableViewDropPlaceholder(
                    insertionIndexPath: destinationIndexPath!,
                    reuseIdentifier: ClientsDataSource.tableCellIdentifier,
                    rowHeight: UITableView.automaticDimension)

                let placeHolderContext = coordinator.drop(dropItem.dragItem, to: placeHolder)

                placeHolderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
                    // Update our data source with the newly dropped contact.
                    if let newContact = data as? ContactCard {
                        self.dataSource.clients.insert(newContact, at: insertionIndexPath.item)
                    }
                })
            }
        } else {
            print("""
                There was an error in loading the drop item: ### \(#function),
                \(String(describing: error?.localizedDescription))
                """)
        }
    })
```

```
When the user drops the contact on an empty location in the table view, the completion handler adds the dropped contact to the end of the list without displaying a gap.
```swift
_ = dropItem.dragItem.itemProvider.loadObject(
    ofClass: ContactCard.self,
    completionHandler: { (data, error) in
        if error == nil {
            if let newContact = data as? ContactCard {
                self.dataSource.clients.append(newContact)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } else {
            print("""
                There was an error in loading the drop item: ### \(#function),
                \(String(describing: error?.localizedDescription))
                """)
        }
    })
```


## Detecting changes in the preferences window
> https://developer.apple.com/documentation/uikit/detecting-changes-in-the-preferences-window

### 
#### 
#### 
When the user changes preferences in the Preferences window, the window saves them to the application domain of the user defaults system. To store and retrieve the preference values within the app, the sample app uses . However, when the sample app launches for the first time, the preference values don’t exist in the user defaults system. If the app tries retrieving a value,  returns `nil`.
To ensure that the app always retrieves a non-`nil` value, the sample app registers the default preference values with the registration domain. However, this domain doesn’t persist these values between app launches, so the sample app registers the default values each time the user launches the app.
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // To ensure that the app has a good set of preference values, register
    // the default values each time the app launches.
    registerDefaultPreferenceValues()

    return true
}
```

```
The method `registerDefaultPreferenceValues()` retrieves the default values from the Settings bundle by retrieving the preference specifiers from the `Root.plist` file and parsing the specifiers for their default value. After retrieving the values, the method registers the default values.
```swift
func registerDefaultPreferenceValues() {
    let preferenceSpecifiers = retrieveSettingsBundlePreferenceSpecifiers(from: "Root.plist")
    let defaultValuesToRegister = parse(preferenceSpecifiers)

    // Register the default values with the registration domain.
    UserDefaults.standard.register(defaults: defaultValuesToRegister)
}
```

```
To parse the preference specifiers, the `parse()` method loops through the array of specifiers, copying the default values into the dictionary `defaultValuesToRegister`. If the method detects the `PSChildPaneSpecifier` type, it gets the name of the child pane property list file, and merges the default values in the file into the `defaultValuesToRegister` dictionary. After gathering the default values, the method returns the dictionary to the caller.
```swift
func parse(_ preferenceSpecifiers: [NSDictionary]) -> [String: Any] {
    var defaultValuesToRegister = [String: Any]()

    // Parse the preference specifiers, copying the default values
    // into the `defaultValuesToRegister` dictionary.
    for preferenceItem in preferenceSpecifiers {
        if let key = preferenceItem["Key"] as? String,
            let defaultValue = preferenceItem["DefaultValue"] {
            defaultValuesToRegister[key] = defaultValue
        }

        // Add child pane preference specifiers.
        if let type = preferenceItem["Type"] as? String,
            type == "PSChildPaneSpecifier" {
            if var file = preferenceItem["File"] as? String {
                if file.hasSuffix(".plist") == false {
                    file += ".plist"
                }
                let morePreferenceSpecifiers = retrieveSettingsBundlePreferenceSpecifiers(from: file)
                let moreDefaultValuesToRegister = parse(morePreferenceSpecifiers)
                defaultValuesToRegister.merge(moreDefaultValuesToRegister) { (current, _) in current }
            }
        }
    }
    
    return defaultValuesToRegister
}
```

#### 
After registering the default values with the registration domain, the app can retrieve a preference value without the possibility of encountering an unavailable value. To simplify access to the background color preference value, the sample app extends  to include properties for each preference value.
```swift
extension UserDefaults {

    @objc dynamic var backgroundColorValue: Int {
        return integer(forKey: "backgroundColorValue")
    }
    
    @objc dynamic var someRandomOption: Bool {
        return bool(forKey: "someRandomOption")
    }

}
```

#### 
As the user changes the background color setting in the Preferences window, the app changes the background color of its main view. To accomplish this, the view controller for the main view creates a subscriber in the  method. When the background color value changes, the subscriber receives the new value, maps it to a  object, and assigns the color to the view’s  property.
```swift
var subscriber: AnyCancellable?   // Subscriber of preference changes.

override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's initial background color to the color specified in Preferences.
    if let colorSetting = BackgroundColors(rawValue: UserDefaults.standard.backgroundColorValue) {
        view.backgroundColor = colorSetting.currentColor()
    }
    
    // Listen for changes to the background color preference made in the Preferences window.
    subscriber = UserDefaults.standard
        .publisher(for: \.backgroundColorValue, options: [.initial, .new])
        .map( { BackgroundColors(rawValue: $0)?.currentColor() })
        .assign(to: \UIView.backgroundColor, on: self.view)
}
```


## Disabling the pull-down gesture for a sheet
> https://developer.apple.com/documentation/uikit/disabling-the-pull-down-gesture-for-a-sheet

### 
#### 
To disable dismissal of a view controller presentation, set  to `true`.
To disable dismissal of a view controller presentation, set  to `true`.
```swift
// If there are unsaved changes, enable the Save button and disable the ability to
// dismiss using the pull-down gesture.
saveButton.isEnabled = hasChanges
isModalInPresentation = hasChanges
```

#### 
To perform an action when the user attempts to dismiss a presentation that has disabled dismissal, set the presentation’s delegate as the code below shows:
```swift
// Set the editViewController to be the delegate of the presentationController for this presentation.
// editViewController can then respond to attempted dismissals.
navigationController.presentationController?.delegate = editViewController
```

```
After setting the delegate, implement  and perform the action. The example below shows the presentation of an instance of :
```swift
func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
    // The system calls this delegate method whenever the user attempts to pull
    // down to dismiss and `isModalInPresentation` is false.
    // Clarify the user's intent by asking whether they want to cancel or save.
    confirmCancel(showingSave: true)
}

// MARK: - Cancellation Confirmation

func confirmCancel(showingSave: Bool) {
    // Present a UIAlertController as an action sheet to have the user confirm losing any
    // recent changes.
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    // Only ask if the user wants to save if they attempt to pull to dismiss, not if they tap Cancel.
    if showingSave {
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            self.delegate?.editViewControllerDidFinish(self)
        })
    }
    
    alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
        self.delegate?.editViewControllerDidCancel(self)
    })
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    // If presenting the alert controller as a popover, point the popover at the Cancel button.
    alert.popoverPresentationController?.barButtonItem = cancelButton
    
    present(alert, animated: true, completion: nil)
}
```


## Display text with a custom layout
> https://developer.apple.com/documentation/uikit/display-text-with-a-custom-layout

### 
#### 
When laying out a line of text, TextKit calls the   method from  to determine the position and size of the line, which TextKit calls a . By creating a subclass of `NSTextContainer` to return a custom line fragment rectangle in the method, apps can implement a custom-shaped text container.
This sample uses the `CircleTextContainer` class to implement a circular text container. To calculate a line fragment rectangle that fits in the inscribed circle of the container’s bounds, the class calls the implementation of `super` to retrieve the default rectangle, then adjusts its `origin.x` and `width` according to the current line origin and container size.
```swift
override func lineFragmentRect(forProposedRect proposedRect: CGRect,
                               at characterIndex: Int,
                               writingDirection baseWritingDirection: NSWritingDirection,
                               remaining remainingRect: UnsafeMutablePointer<CGRect>?) -> CGRect {
    let rect = super.lineFragmentRect(forProposedRect: proposedRect,
                                      at: characterIndex,
                                      writingDirection: baseWritingDirection,
                                      remaining: remainingRect)
    let containerWidth = Float(size.width), containerHeight = Float(size.height)

    let diameter = fminf(containerWidth, containerHeight)
    let radius = diameter / 2.0
    
    // Vertical distance from the line center to the container center.
    let yDistance = fabsf(Float(rect.origin.y + rect.size.height / 2.0) - radius)
    // The new line width.
    let width = (yDistance < radius) ? 2.0 * sqrt(radius * radius - yDistance * yDistance) : 0.0
    // Horizontal distance from rect.origin.x to the starting point of the line.
    let xOffset = (containerWidth > diameter) ? (containerWidth - diameter) / 2.0 : 0.0
    // The starting x of the line.
    let xPosition = CGFloat(xOffset + Float(rect.origin.x) + radius - width / 2.0)
    return CGRect(x: xPosition, y: CGFloat(rect.origin.y), width: CGFloat(width), height: rect.size.height)
}
```

#### 
To lay out text with a custom text container, apps simply set up a text view with the container, and let TextKit do the rest. The   method from  serves this purpose, and this sample uses it to create a `UITextView` instance with its circular text container.
```swift
let textContainer = CircleTextContainer(size: .zero)
textContainer.widthTracksTextView = true

let layoutManager = NSLayoutManager()
layoutManager.addTextContainer(textContainer)
textStorage.addLayoutManager(layoutManager)

textView = UITextView(frame: CGRect.zero, textContainer: textContainer)
```

With this configuration, the TextKit class that coordinates the layout and display of characters,  , automatically uses the line fragment rectangles that `CircleTextContainer` returns to lay out the text.
`NSLayoutManager` supports laying out text in multiple text containers, so implementing a two-column layout is as easy as adding a second text container to the layout manager, as the code below shows:
```swift
let firstTextContainer = NSTextContainer()
firstTextContainer.widthTracksTextView = true
firstTextContainer.heightTracksTextView = true

let secondTextContainer = NSTextContainer()
secondTextContainer.widthTracksTextView = true
secondTextContainer.heightTracksTextView = true
secondTextContainer.lineBreakMode = .byTruncatingTail

let layoutManager = NSLayoutManager()
layoutManager.addTextContainer(firstTextContainer)
layoutManager.addTextContainer(secondTextContainer)

textStorage.addLayoutManager(layoutManager)

let firstTextView = UITextView(frame: .zero, textContainer: firstTextContainer)
firstTextView.isScrollEnabled = false
view.addSubview(firstTextView)

let secondTextView = UITextView(frame: .zero, textContainer: secondTextContainer)
secondTextView.isScrollEnabled = false
view.addSubview(secondTextView)
```

#### 
To create an appealing UI, some apps may have their text wrap around a certain shape. They can achieve that by using the  property from `NSTextContainer` to reserve an exclusive area for the shape in a text container.
This sample uses the following code to set up an exclusive area where `translatedCirclePath` is a  instance using the text container’s coordinate system.
```swift
textView.textContainer.exclusionPaths = [translatedCirclePath]
```

#### 
The detailed implementation of the glyphs substitutions and the layout adjustment is as follows:
- Begin the glyph substitutions by invalidating the glyphs and layout of the ending characters.
```swift
layoutManager.invalidateGlyphs(forCharacterRange: endingWordsCharRange, changeInLength: 0,
                               actualCharacterRange: nil)
layoutManager.invalidateLayout(forCharacterRange: endingWordsCharRange,
                               actualCharacterRange: nil)
```

```
- Implement the   method from  to substitute the glyphs. TextKit calls this delegate method before storing the glyphs to give apps an opportunity to change the glyphs and their properties.
```swift
let ellipsisStartIndex = ellipsisIntersection.location
for index in ellipsisStartIndex..<ellipsisStartIndex + ellipsisIntersection.length {
    if index == ellipsisGlyphRange!.location {
        finalGlyphs[index - glyphRange.location] = myGlyphs[0]
    } else {
        finalProps[index - glyphRange.location] = .controlCharacter
    }
}
let flexibleSpaceStartIndex = flexibleSpaceIntersection.location
for index in  flexibleSpaceStartIndex..<flexibleSpaceStartIndex + flexibleSpaceIntersection.length {
    finalProps[index - glyphRange.location] = .controlCharacter
}
```

- Implement the   method to return the  `NSLayoutManager.ControlCharacterAction.whitespace` action for the flexible space character.
```
- Implement the   method to return the  `NSLayoutManager.ControlCharacterAction.whitespace` action for the flexible space character.
```swift
func layoutManager(_ layoutManager: NSLayoutManager, shouldUse action: NSLayoutManager.ControlCharacterAction,
                   forControlCharacterAt charIndex: Int) -> NSLayoutManager.ControlCharacterAction {
    if let flexibleSpaceGlyphRange = self.flexibleSpaceGlyphRange,
        flexibleSpaceGlyphRange.contains(layoutManager.glyphIndexForCharacter(at: charIndex)) {
        return .whitespace
    }
    return action
}
```

```
- Implement the   method to return a bounding box that can fill up the current line fragment rectangle.
```swift
func layoutManager(_ layoutManager: NSLayoutManager,
                   boundingBoxForControlGlyphAt glyphIndex: Int,
                   for textContainer: NSTextContainer,
                   proposedLineFragment proposedRect: CGRect,
                   glyphPosition: CGPoint,
                   characterIndex charIndex: Int) -> CGRect {
    guard let flexibleSpaceGlyphRange = self.flexibleSpaceGlyphRange,
        flexibleSpaceGlyphRange.contains(glyphIndex) else {
        return CGRect(x: glyphPosition.x, y: glyphPosition.y, width: 0, height: proposedRect.height)
    }
    let padding = textContainer.lineFragmentPadding * 2
    let width = proposedRect.width - (glyphPosition.x - proposedRect.minX) - padding
    let rect = CGRect(x: glyphPosition.x, y: glyphPosition.y, width: width, height: proposedRect.height)
    return rect
}
```

```
- Implement the   method to move the extra line out of the text container.
```swift
func layoutManager(_ layoutManager: NSLayoutManager,
                   shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<CGRect>,
                   lineFragmentUsedRect: UnsafeMutablePointer<CGRect>,
                   baselineOffset: UnsafeMutablePointer<CGFloat>,
                   in textContainer: NSTextContainer,
                   forGlyphRange glyphRange: NSRange) -> Bool {
    guard let ellipsisGlyphRange = self.ellipsisGlyphRange,
        glyphRange.location > ellipsisGlyphRange.location else {
            return false
    }
    let originX = textContainer.size.width
    lineFragmentRect.pointee.origin = CGPoint(x: originX, y: lineFragmentRect.pointee.origin.y)
    return true
}
```


## Displaying a checkbox in your Mac app built with Mac Catalyst
> https://developer.apple.com/documentation/uikit/displaying-a-checkbox-in-your-mac-app-built-with-mac-catalyst

### 
#### 
To display text alongside the checkbox, set the  property.
```swift
let showFavoritesAtTop = UISwitch()
showFavoritesAtTop.title = "Always show favorite recipes at the top"
```

#### 

## Displaying searchable content by using a search controller
> https://developer.apple.com/documentation/uikit/displaying-searchable-content-by-using-a-search-controller

### 
#### 
Use `MainTableViewController`, a subclass of , to create a search controller. The search controller searches and filters a set of `Product` objects and displays them in a table called `ResultsTableController`. This table controller is displayed as the user enters a search string and is dismissed when the search is complete.
```swift
override func viewDidLoad() {
    super.viewDidLoad()

    let nib = UINib(nibName: "TableCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: tableViewCellIdentifier)
    
    resultsTableController =
        self.storyboard?.instantiateViewController(withIdentifier: "ResultsTableController") as? ResultsTableController
    // This view controller is interested in table view row selections.
    resultsTableController.tableView.delegate = self
    
    searchController = UISearchController(searchResultsController: resultsTableController)
    searchController.delegate = self
    searchController.searchResultsUpdater = self
    searchController.searchBar.autocapitalizationType = .none
    searchController.searchBar.delegate = self // Monitor when the search button is tapped.
    
    searchController.searchBar.scopeButtonTitles = [Product.productTypeName(forType: .all),
                                                    Product.productTypeName(forType: .birthdays),
                                                    Product.productTypeName(forType: .weddings),
                                                    Product.productTypeName(forType: .funerals)]

    // Place the search bar in the navigation bar.
    navigationItem.searchController = searchController
    
    // Make the search bar always visible.
    navigationItem.hidesSearchBarWhenScrolling = false
    
    /** Search presents a view controller by applying normal view controller presentation semantics.
        This means that the presentation moves up the view controller hierarchy until it finds the root
        view controller or one that defines a presentation context.
    */
    
    /** Specify that this view controller determines how the search controller is presented.
        The search controller should be presented modally and match the physical size of this view controller.
    */
    definesPresentationContext = true
    
    setupDataSource()
}
```

#### 
This sample uses the  protocol, along with , to filter search results from the group of available products. `NSComparisonPredicate` is a foundation class that specifies how data should be fetched or filtered using search criteria. The search criteria are based on what the user types in the search bar, which can be a combination of product title, year introduced, and price.
To prepare for a search, the search bar content is trimmed of all leading and trailing space characters. Then the search string is passed to the `findMatches` function, which returns the `NSComparisonPredicate` used in the search. The product list results are applied to the search results table as a filtered list.
```swift
func updateSearchResults(for searchController: UISearchController) {
       // Update the filtered array based on the search text.
       let searchResults = products

       // Strip out all the leading and trailing spaces.
       let whitespaceCharacterSet = CharacterSet.whitespaces
       let strippedString =
           searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet)
       let searchItems = strippedString.components(separatedBy: " ") as [String]

       // Build all the "AND" expressions for each value in searchString.
       let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
           findMatches(searchString: searchString)
       }

       // Match up the fields of the Product object.
       let finalCompoundPredicate =
           NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)

       let filteredResults = searchResults.filter { finalCompoundPredicate.evaluate(with: $0) }

       // Apply the filtered results to the search results table.
       if let resultsController = searchController.searchResultsController as? ResultsTableController {
           resultsController.filteredProducts = filteredResults
           resultsController.tableView.reloadData()

           resultsController.resultsLabel.text = resultsController.filteredProducts.isEmpty ?
               NSLocalizedString("NoItemsFoundTitle", comment: "") :
               String(format: NSLocalizedString("Items found: %ld", comment: ""),
                      resultsController.filteredProducts.count)
       }
   }
```


## Elevating your iPad app with a tab bar and sidebar
> https://developer.apple.com/documentation/uikit/elevating-your-ipad-app-with-a-tab-bar-and-sidebar

### 
#### 
Create a  and assign an array of  objects to its  property. To create a tab, call . In the closure, return the view controller your app presents when someone selects the tab. If you use SF Symbols for your tab’s image, be sure to select the outline variant. The system automatically selects the correct variant (outline or filled) based on the context. Additionally, you can change a tab’s properties, such as  or , at runtime, and the system automatically updates its appearance.
```swift
// Create the tab bar controller.
let tabBarController = UITabBarController()

// Assign an array of tabs.
tabBarController.tabs = [

   UITab(title: "First",
         image: UIImage(systemName: "1.circle"),
         identifier: "First Tab") { _ in
             // Return the view controller that the tab displays.
             MyFirstViewController()
         },
   
   UITab(title: "Second",
         image: UIImage(systemName: "2.circle"),
         identifier: "Second Tab") { _ in
             // Return the view controller that the tab displays.
             MySecondViewController()
         },
   
   UITab(title: "Third",
         image: UIImage(systemName: "3.circle"),
         identifier: "Third Tab") { _ in
             // Return the view controller that the tab displays.
             MyThirdViewController()
         }
]
```

```
To add a search tab, create a  instance and add it to the tabs array.
```swift
// Create a search tab.
UISearchTab { _ in 
    // Return the view controller that the tab displays.
    UINavigationController(
        rootViewController: MySearchViewController()
    )
}

```

#### 
Use  and  classes to create a hierarchy of tabs. If the tabs array contains at least one tab group, the system automatically displays the tabs as both a tab bar and a sidebar. Otherwise, it only displays the array as a tab bar. You can also explicitly define how the system displays your tabs by setting the  object’s  property.
```swift
// Enable the sidebar.
tabBarController.mode = .tabSidebar

// Get the sidebar.
let sidebar = tabBarController.sidebar

// Show the sidebar.
sidebar.isHidden = false
```

#### 
You can use  to define a section of items in the sidebar. Provide an array of tabs for the section’s content and a view controller to display when someone selects the section from the tab bar.
```swift
let sectionOne = UITabGroup(
    title: "Section 1",
    image: UIImage(systemName: "1.square.fill"),
    identifier: "Section one",
    children:
        [
            UITab(
                title: "Subitem A",
                image: UIImage(systemName: "a.circle"),
                identifier: "Section 1, item A"
            ) { _ in
                MyFirstSubitemTabViewController()
            },
            
            UITab(
                title: "Subitem B",
                image: UIImage(systemName: "b.circle"),
                identifier: "Section 1, item B"
            ) { _ in
                MySecondSubitemTabViewController()
            },
            
            UITab(
                title: "Subitem C",
                image: UIImage(systemName: "c.circle"),
                identifier: "Section 1, item C"
            ) { _ in
                MyThirdSubitemTabViewController()
            },
        ]) { _ in
            // Return a view controller that the system displays when someone selects the section in the tab bar.
            MySectionViewController()
        }
```

#### 
You can add actions to the sidebar by setting a tab group’s  property. These actions function like buttons that you place inside the tab group.
```swift
// Create the action.
let refreshAction = UIAction(title: "Refresh", image: UIImage(systemName: "arrow.clockwise")) { _ in
    myAction()
}

// Assign the action.
sectionOne.sidebarActions = [refreshAction]
```

#### 
To create an item that appears in the sidebar, but that people can’t add to the tab bar, set the  property to . To create an item that people can add to or remove from the sidebar, set its  property to . If someone removes an item from the sidebar, the system also removes it from the tab bar.
```swift
// Create the tab.
var customizableItem = UITab(
        title: "Optional",
        image: UIImage(systemName: "questionmark.app"),
        identifier: "Optional Item"
) { _ in
    MyOptionalViewController()
}

// Let people add and remove this item in the sidebar.
customizableItem.allowsHiding = true

// Set the item as hidden in the sidebar by default.
customizableItem.isHiddenByDefault = true
```

```
To let people reorganize items within a tab group, set the group’s  property to .
```swift
sectionOne.allowsReordering = true
```

#### 

## Enabling document sharing
> https://developer.apple.com/documentation/uikit/enabling-document-sharing

### 
#### 
If the user selects your app from the activity view, the system launches your app and calls your app delegate’s  method. Implement this method to call your document browser’s  method to reveal and import the document, as shown in this example:
```swift
func application(_ app: UIApplication, open inputURL: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
    // Reveal and import the document at the URL.
    guard let documentBrowserViewController = window?.rootViewController as? DocumentBrowserViewController else {
        fatalError("The root view is not a document browser!")
    }

    documentBrowserViewController.revealDocument(at: inputURL, importIfNeeded: true) { (revealedDocumentURL, error) in
        
        guard error == nil else {
            os_log("Failed to reveal the document at %@. Error: %@",
                   log: OSLog.default,
                   type: .error,
                   inputURL as CVarArg,
                   error! as CVarArg)
            return
        }
        
        guard let url = revealedDocumentURL else {
            os_log("No URL revealed",
                   log: OSLog.default,
                   type: .error)
            
            return
        }
        
        // You can do something
        // with the revealed document here.
        os_log("Revealed URL: %@",
               log: OSLog.default,
               type: .debug,
               url.path)
        
        // Present the Document View Controller for the revealed URL.
        documentBrowserViewController.presentDocument(at: revealedDocumentURL!)
    }

    return true
}    
```


## Encrypting Your App’s Files
> https://developer.apple.com/documentation/uikit/encrypting-your-app-s-files

### 
-  The file is accessible only when the device is unlocked.
To create and encrypt a new file in one step, construct a data object with the file’s contents and call the  method. When calling the method, specify the data protection option that you want applied to the file. The following code shows an example of how to write out the contents of a  instance to a file and encrypt it using the complete protection level.
```swift
do {
   try data.write(to: fileURL, options: .completeFileProtection)
}
catch {
   // Handle errors.
}
```

```
To change the data protection level of an existing file, use the  method of . When calling this method, assign the new data protection option to the  resource key. The following code shows an example that adds this key to an existing file.
```swift
do {
   try (fileURL as NSURL).setResourceValue( 
                  URLFileProtection.complete,
                  forKey: .fileProtectionKey)
}
catch {
   // Handle errors.
}
```

#### 

## Enhancing your app with fluid transitions
> https://developer.apple.com/documentation/uikit/enhancing-your-app-with-fluid-transitions

### 
#### 
To use the zoom transition, set the  property to  on a new view controller, and pass a closure that returns the view you’re zooming from. Then push the view controller onto the navigation stack.
```swift
// Create a detail view controller for the selected item.
let detailViewController = MyDetailViewController(itemID: itemID)

// Set the preferred transition to zoom.
detailViewController.preferredTransition = .zoom { [self] _ in
    
    // Return the thumbnail view for the selected item.
    return thumbnail(for: itemID)
}

// Push the detail view controller onto the navigation stack.
navigationController?.pushViewController(detailViewController, animated: true)
```

If your app lets people swipe between different items without leaving the detail view, the thumbnail you want to zoom back to can change. To look up the correct thumbnail, use the context that the system passes to the closure.
```swift
// Create a detail view controller for the selected item.
let detailViewController = MyDetailViewController(itemID: itemID)

// Set the preferred transition to zoom.
detailViewController.preferredTransition = .zoom { context in
    
    // Use the context to determine the current item.
    guard let controller = context.zoomedViewController as? MyDetailViewController else {
        fatalError("Unable to access the current view controller.")
    }
    
    // Return the thumbnail for the current item.
    return self.thumbnail(for: controller.itemID)
}

// Push the detail view controller onto the navigation stack.
navigationController?.pushViewController(detailViewController, animated: true)
```

> **note:**  You can also use the `preferredTransition` property for other system transitions, such as , , , and .
#### 
#### 

## Estimating the height of a table’s scrolling area
> https://developer.apple.com/documentation/uikit/estimating-the-height-of-a-table-s-scrolling-area

### 
When estimating the heights of headers, footers, and rows, speed is more important than precision. The table view asks for estimates for every item in your table, so don’t perform long-running operations in your delegate methods. Instead, generate estimates that are close enough to be useful for scrolling. The table view replaces your estimates with the actual item heights as those items appear onscreen.
The example code below computes the estimated height for table rows of different heights. The cell for the first row always uses a custom style that includes multiple rows of text. All other rows use the Basic style provided by the table view.
```swift
let cellMarginSize: CGFloat = 4.0
override func tableView(_ tableView: UITableView, 
         estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
   // Choose an appropriate default cell size.
   var cellSize = UITableView.automaticDimension
        
   // The first cell is always a title cell. Other cells use the Basic style.
   if indexPath.row == 0 {
      // Title cells consist of one large title row and two body text rows.
      let largeTitleFont = UIFont.preferredFont(forTextStyle: .largeTitle)
      let bodyFont = UIFont.preferredFont(forTextStyle: .body)
            
      // Get the height of a single line of text in each font.
      let largeTitleHeight = largeTitleFont.lineHeight + largeTitleFont.leading
      let bodyHeight = bodyFont.lineHeight + bodyFont.leading
            
      // Sum the line heights plus top and bottom margins to get the final height.
      let titleCellSize = largeTitleHeight + (bodyHeight * 2.0) + (cellMarginSize * 2)

      // Update the estimated cell size.
      cellSize = titleCellSize
   }
        
   return cellSize
}
```


## Extending your app’s background execution time
> https://developer.apple.com/documentation/uikit/extending-your-app-s-background-execution-time

### 
The following code shows an example that configures a background task so that the app may save data to its server, which could take longer than five seconds. The  method returns an identifier that you must save and pass to the  method.
```swift
func sendDataToServer(data: NSData) {
   // Perform the task on a background queue.
   DispatchQueue.global().async {
      // Request the task assertion and save the ID.
      self.backgroundTaskID = UIApplication.shared.
                 beginBackgroundTask(withName: "Finish Network Tasks") {
         // End the task if time expires.
         UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
         self.backgroundTaskID = UIBackgroundTaskInvalid
      }
            
      // Send the data synchronously.
      self.sendAppDataToServer(data: data)
            
      // End the task assertion.
      UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
      self.backgroundTaskID = UIBackgroundTaskInvalid
   }
}
```


## Filling a table with data
> https://developer.apple.com/documentation/uikit/filling-a-table-with-data

### 
#### 
Before it appears onscreen, a table view asks you to specify the total number of rows and sections. Your data source object provides this information using two methods:
```swift
func numberOfSections(in tableView: UITableView) -> Int  // Optional 
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
```

In your implementations of these methods, return the row and section counts as quickly as possible. Doing so might require you to structure your data in a way that makes it easy to retrieve the row and section information. For example, consider using arrays to manage your table’s data. Arrays are good tools for organizing both sections and rows because they match the natural organization of the table view itself.
The example code below shows an implementation of the data source methods that return the number of rows and sections in a multisection table. In this table, each row displays a string, so the implementation stores an array of strings for each section. To manage the sections, the implementation uses an array (called `hierarchicalData`) of arrays. To get the number of sections, the data source returns the number of items in the `hierarchicalData` array. To get the number of rows in a specific section, the data source returns the number of items in the respective child array.
```swift
var hierarchicalData = [[String]]() 
 
override func numberOfSections(in tableView: UITableView) -> Int {
   return hierarchicalData.count
}
   
override func tableView(_ tableView: UITableView, 
                        numberOfRowsInSection section: Int) -> Int {
   return hierarchicalData[section].count
}

```

#### 
- Set the cell style to `custom`, or set it to one of the standard cell styles.
#### 
For standard cell styles,  contains properties with the views you need to configure. For custom cells, you add views to your cell at design time and outlets to access them.
The example code below shows a version of the data source method that configures a cell containing a single text label. The cell uses the Basic style, one of the standard cell styles. For Basic-style cells, the  property of  contains a label view that you configure with your data.
```swift
override func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   // Ask for a cell of the appropriate type.
   let cell = tableView.dequeueReusableCell(withIdentifier: "basicStyleCell", for: indexPath)
        
   // Configure the cell’s contents with the row and section number.
   // The Basic cell style guarantees a label view is present in textLabel.
   cell.textLabel!.text = "Row \(indexPath.row)"
   return cell
}
```

#### 
#### 
3. Change the table view’s Content attribute (in the Attributes inspector) to `Static Cells`.

## Getting the user’s attention with alerts and action sheets
> https://developer.apple.com/documentation/uikit/getting-the-user-s-attention-with-alerts-and-action-sheets

### 
#### 
To display an alert, create a  object, configure it, and then call  with the object as a parameter, as shown in the following code. Configuring the alert controller includes specifying the title and message that you want the person to see and the actions they can select. Add at least one action — represented by a  object — to an alert controller before you present it.
```swift
@IBAction func agreeToTerms() {
   // Create the action buttons for the alert.
   let defaultAction = UIAlertAction(title: "Agree", 
                        style: .default) { (action) in
	// Respond to the person's selection of the action.
   }
   let cancelAction = UIAlertAction(title: "Disagree", 
                        style: .cancel) { (action) in
	// Respond to the person's selection of the action.
   }
   
   // Create and configure the alert controller.     
   let alert = UIAlertController(title: "Terms and Conditions",
         message: "Click Agree to accept the terms and conditions.",
         preferredStyle: .alert)
   alert.addAction(defaultAction)
   alert.addAction(cancelAction)
        
   self.present(alert, animated: true) {
      // The system presented the alert.
   }
}
```

#### 
Display an action sheet inside a popover on both iPhone and iPad. To display your action sheet in a popover, specify your popover’s anchor point using the  property of your alert controller.
```swift
@IBAction func deleteItem() {
   let destroyAction = UIAlertAction(title: "Delete", 
             style: .destructive) { (action) in
	// Respond to user selection of the action.
   }
   let cancelAction = UIAlertAction(title: "Cancel", 
             style: .cancel) { (action) in
	// Respond to user selection of the action.
   }
        
   let alert = UIAlertController(title: "Delete the image?", 
               message: "", 
               preferredStyle: .actionSheet)
   alert.addAction(destroyAction)
   alert.addAction(cancelAction)
        
   alert.popoverPresentationController?.sourceItem = 
               self.trashButton
        
   self.present(alert, animated: true) {
      // The system presented the alert.
   }
}
```


## Handling input from Apple Pencil
> https://developer.apple.com/documentation/uikit/handling-input-from-apple-pencil

### 
#### 
When a touch object contains estimated properties, UIKit also provides a value in the  property. Use this value as a key to a dictionary that you maintain to identify the touch later. Set the value of that key to the app-specific object that you use to store the touch information. When UIKit later reports the real values, use the index to look up your app-specific object and replace the estimated values with the real values.
The following code shows the `addSamples` method of an app that captures touch data. For each touch, the method creates a custom `StrokeSample` object with the touch information. If the force value of the touch is only an estimate, the `registerForEstimates` method caches the sample in a dictionary using the value in the  property as the key.
```swift
var estimates: [NSNumber: StrokeSample]
 
func addSamples(for touches: [UITouch]) {
   if let stroke = strokeCollection?.activeStroke {
      for touch in touches {
         if touch == touches.last {
            let sample = StrokeSample(point: touch.location(in: self), 
                                 forceValue: touch.force)
            stroke.add(sample: sample)
            registerForEstimates(touch: touch, sample: sample)
         } else {
            let sample = StrokeSample(point: touch.location(in: self), 
                                 forceValue: touch.force, coalesced: true)
            stroke.add(sample: sample)
            registerForEstimates(touch: touch, sample: sample)
         }
      }
      self.setNeedsDisplay()
   }
}
 
func registerForEstimates(touch : UITouch, sample : StrokeSample) {
   if touch.estimatedPropertiesExpectingUpdates.contains(.force) {
      estimates[touch.estimationUpdateIndex!] = sample
   }
}
```

When UIKit receives the actual values for a touch, it calls the  method of your responder or gesture recognizer. Use that method to replace estimated data with the real values provided by UIKit.
The following code shows an example of the  method, which updates the force value for the cached `StrokeSample` objects created in the previous code example. The method uses the value in the  property to retrieve the `StrokeSample` object from the `estimates` dictionary. It then updates the force value and removes the sample from the dictionary.
```swift
override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
   for touch in touches {
      // If the force value is no longer an estimate, update it.
      if !touch.estimatedPropertiesExpectingUpdates.contains(.force) {
         let index = touch.estimationUpdateIndex!
         var sample = estimates[index]
         sample?.force = touch.force
 
         // Remove the key and value from the dictionary.
         estimates.removeValue(forKey: index)
      }
   }
}
```


## Handling key presses made on a physical keyboard
> https://developer.apple.com/documentation/uikit/handling-key-presses-made-on-a-physical-keyboard

### 
#### 
To determine what key they pressed, iterate through the set of presses, inspecting the  property of each press. Use  to determine the text value of the key, and whether the responder should handle the key press or not. If the responder doesn’t handle the key press, call  on the superclass to send the press event to the next responder in the active responder chain.
For example, the following code listing handles someone pressing either the left or right arrow.
```swift
// Handle someone pressing a key on a physical keyboard.
override func pressesBegan(_ presses: Set<UIPress>, 
                           with event: UIPressesEvent?) {
    
    var didHandleEvent = false
    
    for press in presses {
        
        // Get the pressed key.
        guard let key = press.key else { continue }
        
        if key.charactersIgnoringModifiers == UIKeyCommand.inputLeftArrow {
            // Someone pressed the left arrow key.
            // Respond to the key-press event.
            didHandleEvent = true
        }
        if key.charactersIgnoringModifiers == UIKeyCommand.inputRightArrow {
            // Someone pressed the right arrow key.
            // Respond to the key-press event.
            didHandleEvent = true
        }
    }
    
    if didHandleEvent == false {
        // If someone presses a key that you're not handling,
        // pass the event to the next responder.
        super.pressesBegan(presses, with: event)
    }
}
```

#### 
Override the responder’s  method to detect when someone releases a key. To get information about the key, do the same as you did when detecting a key press; inspect the  property of each press in the `presses` set. For example, the following code listing handles someone releasing either the left or right arrow key.
```swift
// Handle someone releasing a key on a physical keyboard.
override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    
    var didHandleEvent = false
    
    for press in presses {
        
        // Get the released key.
        guard let key = press.key else { continue }
        
        if key.charactersIgnoringModifiers == UIKeyCommand.inputLeftArrow {
            // Someone released the left arrow key.
            // Respond to the event.
            didHandleEvent = true
        }
        if key.charactersIgnoringModifiers == UIKeyCommand.inputRightArrow {
            // Someone released the right arrow key.
            // Respond to the event.
            didHandleEvent = true
        }
    }
    
    if didHandleEvent == false {
        // If someone releases a key that you're not handling,
        // pass the event to the next responder.
        super.pressesEnded(presses, with: event)
    }
}
```


## Handling long-press gestures
> https://developer.apple.com/documentation/uikit/handling-long-press-gestures

### 
Long-press gestures are continuous gestures, meaning that your action method may be called multiple times as the state changes. After a person’s fingers have touched the screen for the minimum amount of time, a long-press gesture recognizer enters the  state. The gesture recognizer moves to the  state if the fingers move or if any other changes occur to the touches. The gesture recognizer remains in the  state as long as the fingers remain down, even if those fingers move outside of the initial view. When a person’s fingers lift from the screen, the gesture recognizer enters the  state.
The following code shows an action method that displays a context menu on top of the view. It displays the context menu at the beginning of the gesture, while a person’s finger is still on the screen. The view controller that implements this method also sets itself as the first responder so that it can respond to menu actions selected by a person.
```swift
@IBAction func showResetMenu(_ gestureRecognizer: UILongPressGestureRecognizer) {
   if gestureRecognizer.state == .began {
      self.becomeFirstResponder()
      self.viewForReset = gestureRecognizer.view

      // Configure the menu item to display
      let menuItemTitle = NSLocalizedString("Reset", comment: "Reset menu item title")
      let action = #selector(ViewController.resetPiece(controller:))
      let resetMenuItem = UIMenuItem(title: menuItemTitle, action: action)

      // Configure the shared menu controller
      let menuController = UIMenuController.shared
      menuController.menuItems = [resetMenuItem]

      // Set the location of the menu in the view.
      let location = gestureRecognizer.location(in: gestureRecognizer.view)
      let menuLocation = CGRect(x: location.x, y: location.y, width: 0, height: 0)
      menuController.setTargetRect(menuLocation, in: gestureRecognizer.view!)

      // Show the menu.
      menuController.setMenuVisible(true, animated: true)
   }
}
```


## Handling pan gestures
> https://developer.apple.com/documentation/uikit/handling-pan-gestures

### 
To simplify tracking, use the pan gesture recognizer’s  method to get the distance that the person’s finger has moved from the original touch location. At the beginning of the gesture, a pan gesture recognizer stores the initial point of contact for the person’s fingers. (If the gesture involves multiple fingers, the gesture recognizer uses the center point of the set of touches.) Each time the fingers move, the  method reports the distance from the original location.
The following code shows an action method used to drag a view around the screen. When the gesture begins, this method saves the initial position of the view. It then updates the position of the view based on the movement of a person’s fingers.
```swift
var initialCenter = CGPoint()  // The initial center point of the view.
@IBAction func panPiece(_ gestureRecognizer: UIPanGestureRecognizer) {   
   guard gestureRecognizer.view != nil else { return }
   let piece = gestureRecognizer.view!
   // Get the changes in the X and Y directions relative to
   // the superview's coordinate space.
   let translation = gestureRecognizer.translation(in: piece.superview)
   if gestureRecognizer.state == .began {
      // Save the view's original position. 
      self.initialCenter = piece.center
   }
      // Update the position for the .began, .changed, and .ended states
   if gestureRecognizer.state != .cancelled {
      // Add the X and Y translation to the view's original position.
      let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
      piece.center = newCenter
   }
   else {
      // On cancellation, return the piece to its original location.
      piece.center = initialCenter
   }
}

```


## Handling pinch gestures
> https://developer.apple.com/documentation/uikit/handling-pinch-gestures

### 
The following code demonstrates how to resize a view linearly using a pinch gesture recognizer. This action method applies the current scale factor to the view’s transform and then resets the gesture recognizer’s  property to `1.0`. Resetting the scale factor causes the gesture recognizer to report only the amount of change since the value was reset, which results in linear scaling of the view.
```swift
@IBAction func scalePiece(_ gestureRecognizer: UIPinchGestureRecognizer) {
    guard gestureRecognizer.view != nil else { return }

    if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
        gestureRecognizer.view?.transform = (gestureRecognizer.view?.transform.
                    scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale))!
        gestureRecognizer.scale = 1.0
    }
}
```


## Handling rotation gestures
> https://developer.apple.com/documentation/uikit/handling-rotation-gestures

### 
The following code demonstrates how to rotate a view in a way that follows a person’s fingers. This action method applies the current rotation factor to the view’s transform and then resets the gesture recognizer’s  property to `0.0`. Resetting the rotation factor causes the gesture recognizer to report only the amount of change since the value was reset, which results in the linear rotation of the view.
```swift
@IBAction func rotatePiece(_ gestureRecognizer : UIRotationGestureRecognizer) {
   // Move the anchor point of the view's layer to the center of a
   // person's two fingers. This creates a more natural looking rotation.
   guard gestureRecognizer.view != nil else { return }
        
   if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
      gestureRecognizer.view?.transform = gestureRecognizer.view!.transform.rotated(by: gestureRecognizer.rotation)
      gestureRecognizer.rotation = 0
   }
}
```


## Handling row selection in a table view
> https://developer.apple.com/documentation/uikit/handling-row-selection-in-a-table-view

### 
#### 
#### 
When the user taps a row, the table view calls the delegate method . At this point, your app performs the action, such as displaying the details of the selected hiking trail:
```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedTrail = trails[indexPath.row]
    
    if let viewController = storyboard?.instantiateViewController(identifier: "TrailViewController") as? TrailViewController {
        viewController.trail = selectedTrail
        navigationController?.pushViewController(viewController, animated: true)
    }
}
```

```
If you respond to the cell selection by pushing a new view controller onto the navigation stack, deselect the cell when the view controller pops off the stack. If you’re using a  to display a table view, you get the behavior by setting the  property to . Otherwise, you can clear the selection in your view controller’s  method:
```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let selectedIndexPath = tableView.indexPathForSelectedRow {
        tableView.deselectRow(at: selectedIndexPath, animated: animated)
    }
}
```

#### 
#### 
When providing a selection list in your app, don’t use the cell’s selected state to indicate the state of the item. Instead, display a checkmark or an accessory view. To indicate the state using a checkmark, implement the  delegate method, then deselect the cell with , followed by setting the cell’s  property to .
For example, an app for backpackers may let users create a packing list—an inclusive list of camping gear like sleeping bags and tents. When the user taps an item to indicate that they packed that piece of gear, the app unselects the row, updates the item’s data model, and displays a checkmark in the row for packed items. Tapping the item again marks the item as unpacked and removes the checkmark. Here’s an example:
```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Unselect the row, and instead, show the state with a checkmark.
    tableView.deselectRow(at: indexPath, animated: false)
    
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    
    // Update the selected item to indicate whether the user packed it or not.
    let item = packingList[indexPath.row]
    let newItem = PackingItem(name: item.name, isPacked: !item.isPacked)
    packingList.remove(at: indexPath.row)
    packingList.insert(newItem, at: indexPath.row)
    
    // Show a check mark next to packed items.
    if newItem.isPacked {
        cell.accessoryType = .checkmark
    } else {
        cell.accessoryType = .none
    }
}
```

Managing an exclusive list is similar. Deselect the row and display a checkmark or an accessory view to indicate the selected state. But unlike an inclusive list, limit the exclusive list to only one selected item at a time.
For instance, the backpacker’s app may let users filter the list of hiking trails based on a single difficulty level: easy, moderate, and hard. With this kind of exclusive list, the app must remove the checkmark from the previous selection, and display a checkmark for the current selection. The app must also remember which item is the currently selected item. For example:
```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Unselect the row.
    tableView.deselectRow(at: indexPath, animated: false)
    
    // Did the user tap on a selected filter item? If so, do nothing.
    let selectedFilterRow = selectedFilters[indexPath.section]
    if selectedFilterRow == indexPath.row {
        return
    }

    // Remove the checkmark from the previously selected filter item.
    if let previousCell = tableView.cellForRow(at: IndexPath(row: selectedFilterRow, section: indexPath.section)) {
        previousCell.accessoryType = .none
    }
    
    // Mark the newly selected filter item with a checkmark.
    if let cell = tableView.cellForRow(at: indexPath) {
        cell.accessoryType = .checkmark
    }
    
    // Remember this selected filter item.
    selectedFilters[indexPath.section] = indexPath.row
}
```


## Handling swipe gestures
> https://developer.apple.com/documentation/uikit/handling-swipe-gestures

### 
The following code shows a skeletal action method for a swipe gesture recognizer. You use a method like this to perform a task when the gesture is recognized. Because the gesture is discrete, the gesture recognizer doesn’t enter the began or changed states.
```swift
@IBAction func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .ended {
        // Perform action.
    }
}
```


## Handling tap gestures
> https://developer.apple.com/documentation/uikit/handling-tap-gestures

### 
A  object provides event handling capabilities similar to those of a button — it detects a tap in its view and reports that tap to your action method. Tap gestures are discrete, so your action method is called only when the tap gesture is recognized successfully. You can configure a tap gesture recognizer to require any number of taps — for example, single taps or double taps — before your action method is called.
The following code shows an action method that responds to a successful tap in a view by animating that view to a new location. Always check the gesture recognizer’s  property before taking any actions, even for a discrete gesture recognizer.
```swift
@IBAction func tapPiece(_ gestureRecognizer: UITapGestureRecognizer) {
   guard gestureRecognizer.view != nil else { return }
        
   if gestureRecognizer.state == .ended {      // Move the view down and to the right when tapped.
      let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
         gestureRecognizer.view!.center.x += 100
         gestureRecognizer.view!.center.y += 100
      })
      animator.startAnimation()
   }
}
```


## Handling text interactions in custom keyboards
> https://developer.apple.com/documentation/uikit/handling-text-interactions-in-custom-keyboards

### 
#### 
The text document proxy conforms to the  protocol, providing methods for inserting and deleting text. To insert a character or string into the current input view:
```swift
textDocumentProxy.insertText("Hello world.")
```

```
To delete the character preceding the current insertion point:
```swift
textDocumentProxy.deleteBackward()
```

```
You can determine if the input view has any text at all using the  property:
```swift
if textDocumentProxy.hasText {
    // Do something with the text
}

```

#### 
To move the insertion point in the text input view, use the  method. For example, if you want to implement a forward delete action, move the insertion position forward by one character then delete backwards:
```swift
// Move the text insertion position forward 1 character
textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)

// Delete the previous character
textDocumentProxy.deleteBackward()
```

#### 
While your keyboard is active, the user may perform operations that change the text or selection. Your custom keyboard controller, a subclass of  that conforms to the  protocol, can automatically be informed of these text and selection changes. You can override two sets of methods in this delegate protocol to receive these notifications. The first set is called when text is changing, and the second is called when the selection is changing. Because your keyboard extension doesn’t have direct access to the text input field, the argument is `nil`.
```swift
func textWillChange(_ textInput: UITextInput?)
func textDidChange(_ textInput: UITextInput?)

func selectionWillChange(_ textInput: UITextInput?)
func selectionDidChange(_ textInput: UITextInput?)
```

#### 
To perform certain operations like autocomplete or autocapitalization, you may need additional context of the text surrounding what the user is typing. You can access the context before and after the insertion point as follows:
```swift
let precedingText = textDocumentProxy.documentContextBeforeInput ?? ""
let followingText = textDocumentProxy.documentContextAfterInput ?? ""
let selectedText = textDocumentProxy.selectedText ?? ""
let fullText = "\(precedingText)\(selectedText)\(followingText)"
```

#### 
Some text input operations require multiple actions in order to complete a single character or word. For example, your keyboard might support a language that requires multiple keystrokes to compose a single character.  allows you to insert text and mark some or all of it for subsequent editing operations. The following code shows how you could insert a combining accent character as marked text using :
```swift
let accentCharacter = " \u{0301}"
let range = NSRange(location: 0, length: accentCharacter.count)
textDocumentProxy.setMarkedText(accentCharacter, selectedRange: range)
```

```
Calling `setMarkedText` selects the text specified by `range`. Subsequent insertions replace the characters selected in the range. In the example above, a space with a combining acute accent is shown. If the next character input by the user is an `a`, you could then insert a combined `á`.
```swift
textDocumentProxy.insertText("a\u{0301}")
```

```
If the range passed to  only covers a portion of the string passed in, the nonselected portion is marked with a background color. You could use this to display autocompleted content. For example, if you supported autocompletion of names and the user had typed “Anth”, you might display “Anthony” as the autocompletion:
```swift
let text = "Anthony"
let range = NSRange(location: 4, length: 3)
textDocumentProxy.setMarkedText(text, selectedRange: range)
```


## Illustrating the force, altitude, and azimuth properties of touch input
> https://developer.apple.com/documentation/uikit/illustrating-the-force-altitude-and-azimuth-properties-of-touch-input

### 
#### 
The current force is reported by the  property of .
```swift
force = touch.force
```

```
The force value input affects the result of handling a `UITouch`. In this sample, force is interpreted as a value representing the magnitude of a point in a line, including a lower bound on the force value usable by the app.
```swift
var magnitude: CGFloat {
    return max(force, 0.025)
}
```

```
This sample uses the magnitude value to affect drawing on the canvas, including the line width value.
```swift
context.setLineWidth(point.magnitude)
```

#### 
Apple Pencil reports its altitude as an angle relative to the device surface through the  property on `UITouch`.
Apple Pencil reports its altitude as an angle relative to the device surface through the  property on `UITouch`.
```swift
let altitudeAngle = touch.altitudeAngle
```

```
In this sample project, the line length extends to the edge of the diagram when Apple Pencil is fully horizontal. If Apple Pencil is perfectly vertical, the line length reduces to a dot under Apple Pencil’s tip. The line length calculation transforms the altitude angle relative to the radius of the diagram.
```swift
/*
 Make the length of the indicator's line representative of the `altitudeAngle`. When the angle is
 zero radians (parallel to the screen surface) the line will be at its longest. At `.pi` / 2 radians,
 only the dot on top of the indicator will be visible directly beneath the touch location.
 */
let altitudeRadius = (1.0 - altitudeAngle / (CGFloat.pi / 2)) * radius
var lineTransform = CGAffineTransform(scaleX: altitudeRadius, y: 1)
```

```
Apple Pencil reports its direction, or azimuth, relative to the view Apple Pencil interacts with. A drawing app might use azimuth information to change the shape or strength of a particular drawing tool. Access the azimuth information with the  and  methods of `UITouch`.
```swift
let azimuthAngle = touch.azimuthAngle(in: canvasView)
let azimuthUnitVector = touch.azimuthUnitVector(in: canvasView)
```

```
The interactive diagram demonstrates how altitude, azimuth angle, and azimuth unit vector values can be used together. Here, the azimuth angle rotates around the diagram opposite the actual azimuth value, and the dot at the end of the altitude line moves by combining the altitude and azimuth unit vector properties. A transform efficiently applies the calculated rotation of the line and position of the dot to the diagram so that it remains responsive to small changes in Apple Pencil’s position.
```swift
// Draw the azimuth indicator line as opposite the azimuth by rotating `.pi` radians, for easy visualization.
var rotationTransform = CGAffineTransform(rotationAngle: azimuthAngle)
rotationTransform = rotationTransform.rotated(by: CGFloat.pi)

var dotPositionTransform = CGAffineTransform(translationX: -azimuthUnitVector.dx * altitudeRadius, y: -azimuthUnitVector.dy * altitudeRadius)
dotPositionTransform = dotPositionTransform.concatenating(centeringTransform)
```

#### 
Touch Canvas contains a debug drawing mode that allows you to view the operation of the properties in detail for different types of input, such as the difference between strokes drawn at different speeds with Apple Pencil. The debug mode enables the interactive diagram for altitude and azimuth, and changes the color of individual line segments to identify if the  for the line segment included data from  or .
The sample uses the double-tap feature of the second generation Apple Pencil to toggle  mode when the user configures the preferred double tap action to switch tools. The sample app ignores the other preferred actions. See  for more information.
```swift
func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
    guard UIPencilInteraction.preferredTapAction == .switchPrevious else { return }
    
    /* The tap interaction is a quick way for the user to switch tools within an app.
     Toggling the debug drawing mode from Apple Pencil is a discoverable action, as the button
     for debug mode is on screen and visually changes to indicate what the tap interaction did.
     */
    toggleDebugDrawing(sender: debugButton)
}
```


## Implementing Peek and Pop
> https://developer.apple.com/documentation/uikit/implementing-peek-and-pop

### 
#### 
When configuring the `ColorItemViewController`, enable the “Use Preferred Explicit Size” option in the View Controller section of the Attributes inspector. Set the “Content Size” to have 0 width and an appropriate height. Zero width configures the view controller to automatically resize to the device width when the user peeks at the content.
When implementing the `ColorsViewControllerBase` view controller, resist the temptation of using either  or  when preparing to execute a segue. If you configure the storyboard with the default implementation of Peek and Pop, these methods return `nil` at the time of segue execution. Instead, use the segue’s `sender` property to access the cell initiating the peek.
```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let selectedTableViewCell = sender as? UITableViewCell,
        let indexPath = tableView.indexPath(for: selectedTableViewCell)
        else { preconditionFailure("Expected sender to be a valid table view cell") }

    guard let colorItemViewController = segue.destination as? ColorItemViewController
        else { preconditionFailure("Expected a ColorItemViewController") }

    // Pass over a reference to the ColorData object and the specific ColorItem being viewed.
    colorItemViewController.colorData = colorData
    colorItemViewController.colorItem = colorData.colors[indexPath.row]
}
```

#### 
The `ColorsViewControllerCode` view controller adds code to manually register for Peek and Pop instead of using the storyboard to customize the segue. Call  to register a class which implements the  protocol, and then pass in a view which responds to the 3D Touch.
```swift
override func viewDidLoad() {
    super.viewDidLoad()

    registerForPreviewing(with: self, sourceView: tableView)
}
```

```
The protocol requires the implementation of two methods. When the system detects the 3D Touch, it calls , passing a `previewingContext` object that conforms to the  protocol. Use this method to configure and pass back a view controller for the peek.
```swift
func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    // First, get the index path and view for the previewed cell.
    guard let indexPath = tableView.indexPathForRow(at: location),
        let cell = tableView.cellForRow(at: indexPath)
        else { return nil }

    // Enable blurring of other UI elements and a zoom-in animation while peeking.
    previewingContext.sourceRect = cell.frame

    // Create and configure an instance of the color item view controller to show for the peek.
    guard let viewController = storyboard?.instantiateViewController(withIdentifier: "ColorItemViewController") as? ColorItemViewController
        else { preconditionFailure("Expected a ColorItemViewController") }

    // Pass over a reference to the ColorData object and the specific ColorItem being viewed.
    viewController.colorData = colorData
    viewController.colorItem = colorData.colors[indexPath.row]

    return viewController
}
```

```
When the system detects enough pressure in the 3D Touch to pop the view controller, it calls . Take the passed-in view controller and present it to the user.
```swift
func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    // Push the configured view controller onto the navigation stack.
    navigationController?.pushViewController(viewControllerToCommit, animated: true)
}
```

#### 
To enable Peek Quick Actions for the `ColorItemViewController`, you must override the default implementation of the  property to return an array of  or  objects.
Both a star/unstar action and a delete action are available as quick actions using the following code:
```swift
override var previewActionItems: [UIPreviewActionItem] {
    let starAction = UIPreviewAction(title: starButtonTitle(), style: .default, handler: { [unowned self] (_, _) in
        guard let colorItem = self.colorItem
            else { preconditionFailure("Expected a color item") }

        colorItem.starred.toggle()
    })

    let deleteAction = UIPreviewAction(title: "Delete", style: .destructive) { [unowned self] (_, _) in
        guard let colorData = self.colorData
            else { preconditionFailure("Expected a reference to the color data container") }

        guard let colorItem = self.colorItem
            else { preconditionFailure("Expected a color item") }

        colorData.delete(colorItem)
    }

    return [ starAction, deleteAction ]
}
```


## Implementing a Continuous Gesture Recognizer
> https://developer.apple.com/documentation/uikit/implementing-a-continuous-gesture-recognizer

### 
#### 
A continuous gesture recognizer that tracks touch events needs a way to store that information. You cannot simply store references to the  objects that you receive because UIKit reuses those objects and overwrites any old values. Instead, you must define custom data structures to store the touch information you need.
The following code shows the definition of a `StrokeSample` struct, whose purpose is to store the location associated with a touch. In your own implementation, you might add other properties to this struct to store information such as the timestamp or the force of the touch.
```swift
struct StrokeSample {
    let location: CGPoint 
 
    init(location: CGPoint) {
        self.location = location
    }
}
```

```
The following code shows the partial definition of a `TouchCaptureGesture` class used to capture touch information. This class stores touch data in the `samples` property, which is an array of `StrokeSample` structs. The class also stores the  object associated with the first finger so that it can ignore any other touches. The implementation of the  method ensures that the `samples` property is initialized properly when loading the gesture recognizer from an Interface Builder file.
```swift
class TouchCaptureGesture: UIGestureRecognizer, NSCoding {
   var trackedTouch: UITouch? = nil
   var samples = [StrokeSample]() 
 
   required init?(coder aDecoder: NSCoder) {
      super.init(target: nil, action: nil) 
 
      self.samples = [StrokeSample]()
   } 
   func encode(with aCoder: NSCoder) { }   
   // Overridden methods to come...
}
```

#### 
The following code shows the  method of the `TouchCaptureGesture` class. The gesture fails immediately if the initial event contains two touches. If there is only one touch, the touch object is saved in the `trackedTouch` property and the custom `addSample` helper method creates a new `StrokeSample` struct with the touch data. After the first touch occurs, any new touches added to the event sequence are ignored.
```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
   if touches.count != 1 {
      self.state = .failed
   } 
 
   // Capture the first touch and store some information about it.
   if self.trackedTouch == nil {
      if let firstTouch = touches.first {
         self.trackedTouch = firstTouch
         self.addSample(for: firstTouch)
         state = .began
      }
   } else {
      // Ignore all but the first touch.
      for touch in touches {
         if touch != self.trackedTouch {
            self.ignore(touch, for: event)
         }
      }
   }
}
 
func addSample(for touch: UITouch) {
   let newSample = StrokeSample(location: touch.location(in: self.view))
   self.samples.append(newSample)
}
```

```
The  and  methods (shown in the following code) record each new sample and update the gesture recognizer’s state. Setting the state to  is equivalent to setting the state to  and results in a call to the gesture recognizer’s action method.
```swift
override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
   self.addSample(for: touches.first!)
   state = .changed
}
 
override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
   self.addSample(for: touches.first!)
   state = .ended
}
```

#### 
Always implement the  and  methods in your gesture recognizers and use them to perform any cleanup. The following code shows the implementation of these methods for the `TouchCaptureGesture` class. Both methods restore the gesture recognizer’s properties to their initial values.
```swift
override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
   self.samples.removeAll()
   state = .cancelled
} 
 
override func reset() {
   self.samples.removeAll()
   self.trackedTouch = nil
}
```


## Implementing a Multi-Touch app
> https://developer.apple.com/documentation/uikit/implementing-a-multi-touch-app

### 
#### 
- The  and  methods remove the subview associated with each touch that ended.
The following code shows the main implementation of the `TouchableView` class and its touch handling methods. Each method iterates through the touches and performs the needed actions. The `touchViews` dictionary uses the  objects as keys to retrieve the subviews the user is manipulating onscreen.
```swift
class TouchableView: UIView {
   var touchViews = [UITouch:TouchSpotView]() 
 
   override init(frame: CGRect) {
      super.init(frame: frame)
      isMultipleTouchEnabled = true
   }
 
   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      isMultipleTouchEnabled = true
   }
 
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      for touch in touches {
         createViewForTouch(touch: touch)
      }
   }
 
   override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      for touch in touches {
         let view = viewForTouch(touch: touch) 
         // Move the view to the new location.
         let newLocation = touch.location(in: self)
         view?.center = newLocation
      }
   }
 
   override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      for touch in touches {
         removeViewForTouch(touch: touch)
      }
   }
 
   override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      for touch in touches {
         removeViewForTouch(touch: touch)
      }
   }
  
   // Other methods... 
}
```

```
Several helper methods handle creation, management, and disposal of the subviews, as shown in the following code. The `createViewForTouch` method creates a new `TouchSpotView` object and adds it to the `TouchableView` object, animating the view to its full size. The `removeViewForTouch` method removes the corresponding subview and updates the class data structures. The `viewForTouch` method is a convenience method for retrieving the view associated with a given touch event.
```swift
func createViewForTouch( touch : UITouch ) {
   let newView = TouchSpotView()
   newView.bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
   newView.center = touch.location(in: self)
 
   // Add the view and animate it to a new size.
   addSubview(newView)
   UIView.animate(withDuration: 0.2) {
      newView.bounds.size = CGSize(width: 100, height: 100)
   }
 
   // Save the views internally.
   touchViews[touch] = newView
}
 
func viewForTouch (touch : UITouch) -> TouchSpotView? {
   return touchViews[touch]
}
 
func removeViewForTouch (touch : UITouch ) {
   if let view = touchViews[touch] {
      view.removeFromSuperview()
      touchViews.removeValue(forKey: touch)
   }
}
```

#### 
The `TouchSpotView` class (shown in the following code) represents the custom subviews that draw the gray circles onscreen. `TouchSpotView` maintains its circular shape by setting the  property of the layer each time its  property changes.
```swift
class TouchSpotView : UIView {
   override init(frame: CGRect) {
      super.init(frame: frame)
      backgroundColor = UIColor.lightGray
   }
 
   // Update the corner radius when the bounds change.
   override var bounds: CGRect {
      get { return super.bounds }
      set(newBounds) {
         super.bounds = newBounds
         layer.cornerRadius = newBounds.size.width / 2.0
      }
   }
}
```


## Implementing a discrete gesture recognizer
> https://developer.apple.com/documentation/uikit/implementing-a-discrete-gesture-recognizer

### 
#### 
#### 
With the conditions defined, add properties to your gesture recognizer to track any needed information. For the checkmark gesture, the gesture recognizer needs to know the starting point of the gesture so that it can compare that point to the final point. It also needs to know whether the user’s finger is moving downward or upward.
The following code shows the first part of a custom `CheckmarkGestureRecognizer` class definition. This class stores the initial touch point and the current phase of the gesture. The class also stores the   object associated with the first finger so that it can ignore any other touches.
```swift
enum CheckmarkPhases {
    case notStarted
    case initialPoint
    case downStroke
    case upStroke
} 
class CheckmarkGestureRecognizer : UIGestureRecognizer {
    var strokePhase : CheckmarkPhases = .notStarted
    var initialTouchPoint : CGPoint = CGPoint.zero
    var trackedTouch : UITouch? = nil
   // Overridden methods to come...
```

#### 
The following code shows the  method, which sets up the initial conditions for recognizing the gesture. The gesture fails immediately if the initial event contains two touches. If there is only one touch, the touch object is saved in the `trackedTouch` property. Because UIKit reuses  objects, and therefore overwrites their properties, this method also saves the location of the touch in the `initialTouchPoint` property. After the first touch occurs, any new touches added to the event sequence are ignored.
```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
   super.touchesBegan(touches, with: event)
   if touches.count != 1 {
      self.state = .failed
   } 
 
   // Capture the first touch and store some information about it.
   if self.trackedTouch == nil {
      self.trackedTouch = touches.first
      self.strokePhase = .initialPoint
      self.initialTouchPoint = (self.trackedTouch?.location(in: self.view))!
   } else {
      // Ignore all but the first touch.
      for touch in touches {
         if touch != self.trackedTouch {
            self.ignore(touch, for: event)
         }
      }
   }
}
```

```
When touch information changes, UIKit calls the  method. The following code shows the implementation of this method for the checkmark gesture. This method verifies that the first touch is the correct one, which it should be because all subsequent touches were ignored. It then looks at the movement of that touch. When the initial movement is down and to the right, this method sets the `strokePhase` property to `downStroke`. When the motion changes direction and starts moving upward, the method changes the stroke phase to `upStroke`. If the gesture deviates from this pattern in any way, the method sets the gesture’s state to failed.
```swift
override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
   super.touchesMoved(touches, with: event)
   let newTouch = touches.first 
   // There should be only the first touch.
   guard newTouch == self.trackedTouch else { 
      self.state = .failed 
      return
   } 
   let newPoint = (newTouch?.location(in: self.view))!
   let previousPoint = (newTouch?.previousLocation(in: self.view))!
   if self.strokePhase == .initialPoint {
      // Make sure the initial movement is down and to the right.
      if newPoint.x >= initialTouchPoint.x && newPoint.y >= initialTouchPoint.y {
         self.strokePhase = .downStroke
      } else {         self.state = .failed
      }
   } else if self.strokePhase == .downStroke {
      // Always keep moving left to right.
      if newPoint.x >= previousPoint.x {
         // If the y direction changes, the gesture is moving up again.
         // Otherwise, the down stroke continues.
         if newPoint.y < previousPoint.y {
            self.strokePhase = .upStroke
         }
      } else {
        // If the new x value is to the left, the gesture fails.
        self.state = .failed
      }
   } else if self.strokePhase == .upStroke {
      // If the new x value is to the left, or the new y value
      // changed directions again, the gesture fails.
      if newPoint.x < previousPoint.x || newPoint.y > previousPoint.y {
         self.state = .failed
      }
   }
}
```

```
At the end of the touch sequence, UIKit calls the  method. The following code shows the implementation of this method for the checkmark gesture. If the gesture has not already failed, this method determines whether the gesture was moving upward when it ended and determines whether the final point is higher than the initial point. If both conditions are true, the method sets the state to ; otherwise, the gesture fails.
```swift
override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
   super.touchesEnded(touches, with: event) 
   let newTouch = touches.first
   let newPoint = (newTouch?.location(in: self.view))!
   // There should be only the first touch.
   guard newTouch == self.trackedTouch else { 
      self.state = .failed 
      return
   } 
   // If the stroke was moving up and the final point is
   // above the initial point, the gesture succeeds.
   if self.state == .possible && 
         self.strokePhase == .upStroke && 
         newPoint.y < initialTouchPoint.y {
      self.state = .recognized
   } else {
      self.state = .failed
   }
}
```

#### 
In addition to tracking the touches, the `CheckmarkGestureRecognizer` class implements the  and  methods. The class uses these methods to reset the gesture recognizer’s local properties to appropriate values. The following code shows the implementations of these methods.
```swift
override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
   super.touchesCancelled(touches, with: event)
   self.initialTouchPoint = CGPoint.zero
   self.strokePhase = .notStarted
   self.trackedTouch = nil
   self.state = .cancelled
}
 
override func reset() {
   super.reset()
   self.initialTouchPoint = CGPoint.zero
   self.strokePhase = .notStarted
   self.trackedTouch = nil
}
```


## Implementing coalesced touch support in an app
> https://developer.apple.com/documentation/uikit/implementing-coalesced-touch-support-in-an-app

### 
#### 
The main view of the app uses incoming touch events to build a set of `Stroke` objects. The following image shows the definition of the `Stroke` class and the associated `StrokeSample` class, which store information about each touch event.
```swift
class Stroke {
    var samples = [StrokeSample]()
    func add(sample: StrokeSample) {
        samples.append(sample)
    }
}
 
struct StrokeSample {
    let location: CGPoint
    let coalescedSample: Bool
    init(point: CGPoint, coalesced : Bool = false) {
        location = point
        coalescedSample = coalesced
    }
}

```

```
The main view maintains a collection of `Stroke` objects that have been created using the `StrokeCollection` class, the implementation of which is shown in the following code. The `strokes` property of this class stores the completed strokes and the `activeStroke` property contains a stroke object that’s currently being modified. Calling the `acceptActiveStroke` method moves the active stroke to the set of completed strokes.
```swift
class StrokeCollection {
    var strokes = [Stroke]()
    var activeStroke: Stroke? = nil
 
    func acceptActiveStroke() {
        if let stroke = activeStroke {
            strokes.append(stroke)
            activeStroke = nil
        }
    }
}
```

#### 
The following code shows the portion of the main drawing view that creates new `Stroke` objects. The view doesn’t support multitouch, so only the first touch event needs to be tracked. The  method creates a new stroke object and marks it as the active stroke. New touch data is added to the active stroke until the  method is called, at which point the stroke is accepted into the stroke collection. If the touch sequence is interrupted for any reason, the  method abandons the currently active stroke.
```swift
class DrawingView : UIView {
   var strokeCollection: StrokeCollection? {
      didSet {
         // If the strokes change, redraw the view's content.
         if oldValue !== strokeCollection {
            setNeedsDisplay()
         }
      }
   }
 
   // Initialization methods...
 
   // Touch Handling methods
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      // Create a new stroke and make it the active stroke.
      let newStroke = Stroke()
      strokeCollection?.activeStroke = newStroke
 
      // The view does not support multitouch, so get the samples
      //  for only the first touch in the event.
      if let coalesced = event?.coalescedTouches(for: touches.first!) {
         addSamples(for: coalesced)
      }
   }
 
   override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      if let coalesced = event?.coalescedTouches(for: touches.first!) {
         addSamples(for: coalesced)
      }
   }
 
   override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      // Accept the current stroke and add it to the stroke collection.
      if let coalesced = event?.coalescedTouches(for: touches.first!) {
         addSamples(for: coalesced)
      }
      // Accept the active stroke.
      strokeCollection?.acceptActiveStroke()
   }
 
   override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      // Clear the last stroke.
      strokeCollection?.activeStroke = nil
   }
 
   // More methods...
}
```

```
The touch input methods of `DrawingView` use the `addSamples` method (shown in the following code) to incorporate new touches into the active stroke. This method creates a new `StrokeSample` for each touch point and adds that sample to the active stroke. The example flags coalesced touches internally, but the touches are no different from the regular touches reported by the system.
```swift
func addSamples(for touches: [UITouch]) {
   if let stroke = strokeCollection?.activeStroke {
      // Add all of the touches to the active stroke.
      for touch in touches {
         if touch == touches.last {
            let sample = StrokeSample(point: touch.preciseLocation(in: self))
            stroke.add(sample: sample)
         } else {
            // If the touch is not the last one in the array,
            //  it was a coalesced touch. 
            let sample = StrokeSample(point: touch.preciseLocation(in: self), 
                                  coalesced: true)
            stroke.add(sample: sample)
         }
      } 
      // Update the view.
      self.setNeedsDisplay()
   }
}
```


## Implementing modern collection views
> https://developer.apple.com/documentation/uikit/implementing-modern-collection-views

### 
#### 
The code examples shown here are from the iOS target, but you can find macOS-equivalent examples in the `.swift` files for the macOS target.
#### 
The Grid example shows how to create a grid layout by using fractional sizing to make a row of five equally sized items. It creates a horizontal group with items that are each 20% of the width of the group by using `.fractionalWidth(0.2)`. Each row of five items is repeated multiple times in a single section to create a grid.
```swift
let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                     heightDimension: .fractionalHeight(1.0))
let item = NSCollectionLayoutItem(layoutSize: itemSize)

let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .fractionalWidth(0.2))
let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                 subitems: [item])

let section = NSCollectionLayoutSection(group: group)

let layout = UICollectionViewCompositionalLayout(section: section)
return layout
```

#### 
The Inset Items Grid example builds on the layout from the Grid example, showing how to add spacing around items by using the  property. Here, this property applies even spacing around the edges of each item.
```swift
let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                     heightDimension: .fractionalHeight(1.0))
let item = NSCollectionLayoutItem(layoutSize: itemSize)
item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
```

#### 
The Two-Column Grid example shows how to create a two-column layout by making a group with the exact number of items specified in the `count` parameter of . This approach simplifies specifying exactly how many items a group contains. In this case, the `count` parameter takes precedence over `itemSize`, and item size is computed automatically to fit the specified number of items.
```swift
let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                     heightDimension: .fractionalHeight(1.0))
let item = NSCollectionLayoutItem(layoutSize: itemSize)

let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .absolute(44))
let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
let spacing = CGFloat(10)
group.interItemSpacing = .fixed(spacing)
```

#### 
The Distinct Sections example shows how to display different layout arrangements in different sections of the same collection view layout. Creating a layout with different sections requires a compositional layout with a section provider. The code in the section provider accesses the section’s index (`sectionIndex`) to determine which section it’s configuring, and displays a different layout for each section.
```swift
let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
    layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

    guard let sectionLayoutKind = SectionLayoutKind(rawValue: sectionIndex) else { return nil }
    let columns = sectionLayoutKind.columnCount

    // The group auto-calculates the actual item width to make
    // the requested number of columns fit, so this widthDimension is ignored.
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                         heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

    let groupHeight = columns == 1 ?
        NSCollectionLayoutDimension.absolute(44) :
        NSCollectionLayoutDimension.fractionalWidth(0.2)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: groupHeight)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: columns)

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
    return section
}
return layout
```

#### 
The Adaptive Sections example shows how to create a layout that adapts to the environment it’s displayed in. In this example, the number of columns shown changes based on the available screen size. Creating a layout that adapts to a new environment requires a compositional layout with a section provider. The code in the section provider accesses the amount of available space in the current layout environment (`layoutEnvironment.container.effectiveContentSize`), and displays a different number of columns based on the available width.
```swift
let layout = UICollectionViewCompositionalLayout {
    (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
    guard let layoutKind = SectionLayoutKind(rawValue: sectionIndex) else { return nil }

    let columns = layoutKind.columnCount(for: layoutEnvironment.container.effectiveContentSize.width)

    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                         heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

    let groupHeight = layoutKind == .list ?
        NSCollectionLayoutDimension.absolute(44) : NSCollectionLayoutDimension.fractionalWidth(0.2)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: groupHeight)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: columns)
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
    return section
}
return layout
```

#### 
The Item Badges example shows how to add supplementary views like badges to the items in a collection view. It creates and adds a badge to the top trailing corner of each item by creating a supplementary item for the badge, and passing in that supplementary item when creating the item itself. The data source configures each badge in its .
```swift
let badgeAnchor = NSCollectionLayoutAnchor(edges: [.top, .trailing], fractionalOffset: CGPoint(x: 0.3, y: -0.3))
let badgeSize = NSCollectionLayoutSize(widthDimension: .absolute(20),
                                      heightDimension: .absolute(20))
let badge = NSCollectionLayoutSupplementaryItem(
    layoutSize: badgeSize,
    elementKind: ItemBadgeSupplementaryViewController.badgeElementKind,
    containerAnchor: badgeAnchor)

let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                     heightDimension: .fractionalHeight(1.0))
let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [badge])
item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
```

#### 
The Section Headers/Footers example shows how to add headers and footers to each section of the collection view. It creates boundary supplementary items to represent the header and the footer, and sets them as the section’s .
```swift
let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .estimated(44))
let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
    layoutSize: headerFooterSize,
    elementKind: SectionHeadersFootersViewController.sectionHeaderElementKind, alignment: .top)
let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
    layoutSize: headerFooterSize,
    elementKind: SectionHeadersFootersViewController.sectionFooterElementKind, alignment: .bottom)
section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
```

```
The example uses supplementary registrations for the header and footer to configure their content and appearance.
```swift
let headerRegistration = UICollectionView.SupplementaryRegistration
<TitleSupplementaryView>(elementKind: SectionHeadersFootersViewController.sectionHeaderElementKind) {
    (supplementaryView, string, indexPath) in
    supplementaryView.label.text = "\(string) for section \(indexPath.section)"
    supplementaryView.backgroundColor = .lightGray
    supplementaryView.layer.borderColor = UIColor.black.cgColor
    supplementaryView.layer.borderWidth = 1.0
}
```

```
The collection view uses these supplementary registrations to dequeue the configured headers and footers in the diffable data source’s .
```swift
dataSource.supplementaryViewProvider = { (view, kind, index) in
    return self.collectionView.dequeueConfiguredReusableSupplementary(
        using: kind == SectionHeadersFootersViewController.sectionHeaderElementKind ? headerRegistration : footerRegistration, for: index)
}
```

#### 
The Pinned Section Headers example shows how to pin a section header to its section. This way, the header shows while any portion of the section it’s attached to is visible during scrolling, and the footer stays in place. This example sets the header’s  property to `true` and increases its  to a value greater than `1` so the header appears on top of the section during scrolling.
```swift
let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(44)),
    elementKind: PinnedSectionHeaderFooterViewController.sectionHeaderElementKind,
    alignment: .top)
let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(44)),
    elementKind: PinnedSectionHeaderFooterViewController.sectionFooterElementKind,
    alignment: .bottom)
sectionHeader.pinToVisibleBounds = true
sectionHeader.zIndex = 2
section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
```

```
The example uses supplementary registrations for the header and footer to configure their content and appearance. The collection view uses these supplementary registrations to dequeue the configured headers and footers in the diffable data source’s .
```swift
dataSource.supplementaryViewProvider = { (view, kind, index) in
    return self.collectionView.dequeueConfiguredReusableSupplementary(
        using: kind == PinnedSectionHeaderFooterViewController.sectionHeaderElementKind ? headerRegistration : footerRegistration, for: index)
}
```

#### 
The Section Background Decoration example shows how to distinguish sections by adding section backgrounds. It creates a section background by making a decoration item using . It then sets that decoration item as the section’s  property.
```swift
let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(
    elementKind: SectionDecorationViewController.sectionBackgroundDecorationElementKind)
sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
section.decorationItems = [sectionBackgroundDecoration]
```

```
The following code then registers the background view with the layout by using .
```swift
let layout = UICollectionViewCompositionalLayout(section: section)
layout.register(
    SectionBackgroundDecorationView.self,
    forDecorationViewOfKind: SectionDecorationViewController.sectionBackgroundDecorationElementKind)
return layout
```

#### 
The Nested Groups example shows how to create flexible layout arrangements by nesting groups inside of other groups. It creates a vertical group with two items, and combines the vertical group with an item in a horizontal parent group.
```swift
let leadingItem = NSCollectionLayoutItem(
    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7),
                                      heightDimension: .fractionalHeight(1.0)))
leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

let trailingItem = NSCollectionLayoutItem(
    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .fractionalHeight(0.3)))
trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
let trailingGroup = NSCollectionLayoutGroup.vertical(
    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                       heightDimension: .fractionalHeight(1.0)),
    repeatingSubitem: trailingItem,
    count: 2)
let nestedGroup = NSCollectionLayoutGroup.horizontal(
    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .fractionalHeight(0.4)),
    subitems: [leadingItem, trailingGroup])
```

#### 
The Orthogonal Sections example shows how to create a section that scrolls horizontally in an otherwise vertically scrolling layout. Setting a section’s  property to a value other than  causes the section to lay out its contents perpendicular to the main layout axis. In this case, because the layout scrolls vertically by default, the section scrolls horizontally.
```swift
section.orthogonalScrollingBehavior = .continuous
```

#### 
The Orthogonal Section Behaviors example shows each of the options for . Each section of the layout demonstrates a different orthogonal scrolling behavior, showcasing the differences between the scrolling and paging options. In this case, because the layout scrolls vertically by default, the sections themselves scroll horizontally.
```swift
case continuous, continuousGroupLeadingBoundary, paging, groupPaging, groupPagingCentered, none
func orthogonalScrollingBehavior() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
    switch self {
    case .none:
        return UICollectionLayoutSectionOrthogonalScrollingBehavior.none
    case .continuous:
        return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuous
    case .continuousGroupLeadingBoundary:
        return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
    case .paging:
        return UICollectionLayoutSectionOrthogonalScrollingBehavior.paging
    case .groupPaging:
        return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPaging
    case .groupPagingCentered:
        return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
    }
}
```

#### 
The `performQuery(with:)` method updates the data and the user interface. The method takes the currently typed filter text and generates a list of mountains that contain that text in their names. Then, it constructs a representation of the newly filtered data using a snapshot. The snapshot contains the same single section as before, but now, instead of containing items representing every mountain, it only contains the filtered mountains.
The method then calls , applying the data from the snapshot to the diffable data source. The diffable data source stores the data from the snapshot as the new state of data, calculates the difference between the previous state and the new state, and triggers the user interface to display the new state.
```swift
func performQuery(with filter: String?) {
    let mountains = mountainsController.filteredMountains(with: filter).sorted { $0.name < $1.name }

    var snapshot = NSDiffableDataSourceSnapshot<Section, MountainsController.Mountain>()
    snapshot.appendSections([.main])
    snapshot.appendItems(mountains)
    dataSource.apply(snapshot, animatingDifferences: true)
}
```

#### 
The Settings: Wi-Fi example shows how to update the data and the user interface in a table view that uses multiple kinds of sections and items. It recreates the Wi-Fi page in iOS Settings, letting the user toggle the Wi-Fi switch on and off to view the available and current Wi-Fi networks.
The `updateUI(animated:)` method determines which sections and items to display based on whether Wi-Fi is enabled. If Wi-Fi is disabled, the method adds only the `.config` section and its items to the snapshot. If Wi-Fi is enabled, the method adds the `.networks` section and its items as well.
```swift
let configItems = configurationItems.filter { !($0.type == .currentNetwork && !controller.wifiEnabled) }

currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()

currentSnapshot.appendSections([.config])
currentSnapshot.appendItems(configItems, toSection: .config)

if controller.wifiEnabled {
    let sortedNetworks = controller.availableNetworks.sorted { $0.name < $1.name }
    let networkItems = sortedNetworks.map { Item(network: $0) }
    currentSnapshot.appendSections([.networks])
    currentSnapshot.appendItems(networkItems, toSection: .networks)
}

self.dataSource.apply(currentSnapshot, animatingDifferences: animated)
```

#### 
The Insertion Sort Visualization example shows how to update data incrementally, displaying the visible progress as the data changes from an initial state to a final state. It shows rows of color swatches, originally in a random order, that it then iteratively sorts into spectral order.
The key difference between this example and the other diffable data source examples is that this example doesn’t create an empty snapshot to update the state of the data. Instead, the `performSortStep()` method retrieves the current state of the collection view’s data by using `dataSource.snapshot()`. Then, it modifies only one part of that snapshot to perform the visual sorting step by step.
```swift
// Get the current state of the UI from the data source.
var updatedSnapshot = dataSource.snapshot()

// For each section, if needed, step through and perform the next sorting step.
updatedSnapshot.sectionIdentifiers.forEach {
    let section = $0
    if !section.isSorted {

        // Step the sort algorithm.
        section.sortNext()
        let items = section.values

        // Replace the items for this section with the newly sorted items.
        updatedSnapshot.deleteItems(items)
        updatedSnapshot.appendItems(items, toSection: section)

        sectionCountNeedingSort += 1
    }
}
```

#### 
The Simple List example shows how to create a basic list layout that adapts to any screen size. It creates a configuration with one of the system-defined list appearances. Then, it creates a list layout by passing the configuration to . This approach generates a compositional layout with a single section styled as a list.
```swift
let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
return UICollectionViewCompositionalLayout.list(using: config)
```

#### 
The List Appearances example shows each of the options for . Tapping the name of the appearance in the navigation bar changes the list to another appearance, showcasing each of the list styles. Each list uses the  header mode, which makes each section of the list expandable and collapsible.
```swift
var config = UICollectionLayoutListConfiguration(appearance: self.appearance)
config.headerMode = .firstItemInSection
```

#### 
The List with Custom Cells example shows how to configure a custom list cell subclass. The example focuses on `CustomListCell`, a custom subclass of  that combines several kinds of subviews into one cell. It sets the appearance and content of these views using content configurations.
The `updateConfiguration(using:)` method sets up the cell’s initial appearance and content. The system calls this method every time the cell’s configuration state changes to update the cell’s appearance for that new state. To configure the list content view, it fetches the default list content configuration for the current state.
```swift
var content = defaultListContentConfiguration().updated(for: state)
```

Then, it customizes the configuration’s values and assigns that configuration to the  property of `listContentView`.
Then, it customizes the configuration’s values and assigns that configuration to the  property of `listContentView`.
For the image view and label, the `updateConfiguration(using:)` method fetches a default value cell configuration for the current state and stores it in `valueConfiguration`. It copies the preconfigured default styling and metrics from this configuration into the custom views to ensure consistency with the system styles.
```swift
categoryIconView.tintColor = valueConfiguration.imageProperties.resolvedTintColor(for: tintColor)
categoryIconView.preferredSymbolConfiguration = .init(font: valueConfiguration.secondaryTextProperties.font, scale: .small)
```

```
To register the custom cell subclass with the collection view, this example uses a cell registration. The cell registration configures each cell with the data from its corresponding item. It also adds a disclosure indicator cell accessory to the cell.
```swift
let cellRegistration = UICollectionView.CellRegistration<CustomListCell, Item> { (cell, indexPath, item) in
    cell.updateWithItem(item)
    cell.accessories = [.disclosureIndicator()]
}
```

```
The diffable data source uses that cell registration when it dequeues the cell.
```swift
return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
```

#### 
The Emoji Explorer example shows how to create a compositional layout with multiple types of sections. The example contains an orthogonally scrolling section, an outline section, and a list section in one compositional layout. The `createLayout()` method defines a section provider to supply each section.
For the top section, it enables horizontal scrolling by setting the  property.
```swift
section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
```

```
The outline section uses the  list appearance. It’s populated using a section snapshot to create a hierarchical data structure.
```swift
let rootItem = Item(title: String(describing: category), hasChildren: true)
outlineSnapshot.append([rootItem])
let outlineItems = category.emojis.map { Item(emoji: $0) }
outlineSnapshot.append(outlineItems, to: rootItem)
```

```
The list section uses the  list appearance. The configuration for this section adds a swipe action to each cell that lets the cell be marked as Favorite.
```swift
configuration.leadingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
    guard let self = self else { return nil }
    guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
    return self.leadingSwipeActionConfigurationForListCellItem(item)
}
```

```
Each section has a corresponding cell registration to configure its own type of cell. The collection view uses those registrations to dequeue the configured cells to display in each section.
```swift
switch section {
case .recents:
    return collectionView.dequeueConfiguredReusableCell(using: gridCellRegistration, for: indexPath, item: item.emoji)
case .list:
    return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: item)
case .outline:
    if item.hasChildren {
        return collectionView.dequeueConfiguredReusableCell(using: outlineHeaderCellRegistration, for: indexPath, item: item.title!)
    } else {
        return collectionView.dequeueConfiguredReusableCell(using: outlineCellRegistration, for: indexPath, item: item.emoji)
    }
}
```

#### 
The Emoji Explorer - List example shows how to create a list with cells that use the value cell style. It applies a content configuration with the default value cell style to each of the cells in the list.
```swift
var contentConfiguration = UIListContentConfiguration.valueCell()
contentConfiguration.text = emoji.text
contentConfiguration.secondaryText = String(describing: emoji.category)
cell.contentConfiguration = contentConfiguration
```


## Incorporating predicted touches into an app
> https://developer.apple.com/documentation/uikit/incorporating-predicted-touches-into-an-app

### 
#### 
The `StrokeGestureRecognizer` class collects drawing-related touch input and uses it to create a `Stroke` object representing the path to render. In addition to the touches that actually occurred, the class also gathers any predicted touches. The following code shows the portion of the gesture recognizer’s `append` method that’s responsible for gathering the predicted touches. The `collector` block called by this code processes each touch event. The parameters to that block indicate whether the touch is an actual touch or a predicted touch.
```swift
// Collect predicted touches only while the gesture is ongoing. 
if (usesPredictedSamples && stroke.state == .active) {
   if let predictedTouches = event?.predictedTouches(for: touchToAppend) {
      for touch in predictedTouches {
         collector(stroke, touch, view, false, true)
      }
   }
}
```

The collection of touch input results in the creation of `StrokeSample` objects, which are then added to the current `Stroke` object. Stroke objects store predicted touches separately from other touches. Keeping them separate makes it easier to remove them later, and keeps them from being accidentally confused with the real touch input. Each time the app adds a new set of actual touches, it discards the preceding set of predicted samples.
The following code shows a portion of the `Stroke` class, which represents the touches associated with a single drawn line. For each new set of touches, the class adds the actual touches to its primary list of samples. Any predicted touches are then stored in the `predictedSamples` property. Each time `StrokeGestureRecognizer` calls the `Stroke` method `add`, the method moves the last set of predicted touches to the `previousPredictedSamples` property and are ultimately discarded. Thus, `Stroke` maintains only the last set of predicted touches.
```swift
class Stroke {
    static let calligraphyFallbackAzimuthUnitVector = CGVector(dx: 1.0, dy:1.0).normalize! 
    var samples: [StrokeSample] = []
    var predictedSamples: [StrokeSample] = []
    var previousPredictedSamples: [StrokeSample]?
    var state: StrokeState = .active
    var sampleIndicesExpectingUpdates = Set<Int>()
    var expectsAltitudeAzimuthBackfill = false
    var hasUpdatesFromStartTo: Int?
    var hasUpdatesAtEndFrom: Int? 
    var receivedAllNeededUpdatesBlock: (() -> ())?
 
    func add(sample: StrokeSample) -> Int {
        let resultIndex = samples.count
        if hasUpdatesAtEndFrom == nil {
            hasUpdatesAtEndFrom = resultIndex
        }
 
        samples.append(sample)
        if previousPredictedSamples == nil {
            previousPredictedSamples = predictedSamples
        }
 
        if sample.estimatedPropertiesExpectingUpdates != [] {
            sampleIndicesExpectingUpdates.insert(resultIndex)
        }
 
        predictedSamples.removeAll()
        return resultIndex
    } 
 
    func addPredicted(sample: StrokeSample) {
        predictedSamples.append(sample)
    } 
 
    func clearUpdateInfo() {
        hasUpdatesFromStartTo = nil
        hasUpdatesAtEndFrom = nil
        previousPredictedSamples = nil
    } 
 
    // Other methods...
}
```

#### 
During rendering, the app treats predicted touches like actual touches. It breaks down the contents of each `Stroke` object into one or more `StrokeSegment` objects, which the drawing code fetches using a `StrokeSegmentIterator` object. The following code shows the implementation of this class. As the drawing code iterates over the stroke samples, the `sampleAt` method returns the samples for the actual touches first. Only after the method returns all of the actual touch samples does the iterator return the samples for any predicted touches. Thus, the predicted touches are always located at the end of the stroked line.
```swift
class StrokeSegmentIterator: IteratorProtocol {
    private let stroke: Stroke
    private var nextIndex: Int
    private let sampleCount: Int
    private let predictedSampleCount: Int
    private var segment: StrokeSegment!
 
    init(stroke: Stroke) {
        self.stroke = stroke
        nextIndex = 1
        sampleCount = stroke.samples.count
        predictedSampleCount = stroke.predictedSamples.count
        if (predictedSampleCount + sampleCount > 1) {
            segment = StrokeSegment(sample: sampleAt(0)!)
            segment.advanceWithSample(incomingSample: sampleAt(1))
        }
    } 
 
    func sampleAt(_ index: Int) -> StrokeSample? {
        if (index < sampleCount) {
            return stroke.samples[index]
        }
        let predictedIndex = index - sampleCount
        if predictedIndex < predictedSampleCount {
            return stroke.predictedSamples[predictedIndex]
        } else {
            return nil
        }
    }
 
    func next() -> StrokeSegment? {
        nextIndex += 1
        if let segment = self.segment {
            if segment.advanceWithSample(incomingSample: sampleAt(nextIndex)) {
                return segment
            }
        }
        return nil
    }
}
```


## Integrating pointer interactions into your iPad app
> https://developer.apple.com/documentation/uikit/integrating-pointer-interactions-into-your-ipad-app

### 
#### 
#### 
#### 
A pointer interaction is described by a pointer style or visual representation. The pointer style is made up of both a  with a , and a . A commonly used shape for pointer effects is a rounded rectangle. A pointer shape or `UIPointerShape` requires a , which describes that shape. The sample associates a pointer interaction to a shape view by adding one like this:
```swift
shapeView.addInteraction(UIPointerInteraction(delegate: self))
```

#### 
For a shape view to describe its appearance during a pointer interaction, it must provide a . `UITargetedPreview` gives UIKit a view to which to apply an effect during pointer interactions:
```swift
func targetedPreview() -> UITargetedPreview? {
    let parameters = UIPreviewParameters()
    
    // Use the entire view's shape for the preview.
    let visiblePath = viewPath
    parameters.visiblePath = visiblePath
    
    return UITargetedPreview(view: self, parameters: parameters)
}
```

#### 
#### 
The sample creates either a region or shape, defined for each of its shape views, so a pointer interaction detects where to interact. The sample also implements  as the . This delegate is called by UIKit as the pointer moves within the pointer interaction’s view. Returning a  in which to apply a pointer style or returning `nil` indicates that this interaction does not customize the pointer for the current location.
```swift
func pointerInteraction(_ interaction: UIPointerInteraction,
                        regionFor request: UIPointerRegionRequest,
                        defaultRegion: UIPointerRegion) -> UIPointerRegion? {
    var pointerRegion: UIPointerRegion? = nil
    
    if let view = interaction.view as? ShapeView {
        // Pointer has entered one of the shape views.
 
        // Check for modifiers keys pressed while inside the view path.
        if request.modifiers.contains(.command) && request.modifiers.contains(.alternate) {
            // Command + Option were both pressed, dim the view.
            view.alpha = 0.50
        } else {
            if view.alpha != 1.0 { view.alpha = 1.0 }
        }
        
        // The user interacted with the inner path region.
        pointerRegion =
            UIPointerRegion(rect: view.innerPath.bounds,
                            identifier: ShapeView.regionIdentifier)
    } else if let view = interaction.view as? AlphaControl {
        // Pointer has entered the alpha control.
        if view.bounds.contains(request.location) {
            pointerRegion =
                UIPointerRegion(rect: view.bounds,
                                identifier: AlphaControl.regionIdentifier)
        }
    }
  
    return pointerRegion
}
```

#### 
Below is an example of handling the  to a `ShapeView`:
A  changes the frame color of a shape view to blue when the cursor is positioned over it. If the user presses the command key while hovering, the frame color toggles to pink.
Below is an example of handling the  to a `ShapeView`:
```swift
func hoverShape(_ gestureRecognizer: UIHoverGestureRecognizer) {
    guard let shapeViewToUse = gestureRecognizer.view as? ShapeView else { return }

    switch gestureRecognizer.state {
    case .began, .changed:
        // User hovered within the view's path, change the view's border color.
        var pathViewColor = UIColor.systemTeal
        if gestureRecognizer.modifierFlags.contains(.command) {
            // If the command key is pressed while hovering change frame color to pink.
            pathViewColor = UIColor.systemPink
        }
        shapeViewToUse.viewPathColor = pathViewColor
        shapeViewToUse.setNeedsDisplay()

    case .ended, .cancelled:
        // User left the view, restore the border color.
        shapeViewToUse.restoreOuterFrameColor()

    default:
        break
    }
}
```

#### 

## Leveraging touch input for drawing apps
> https://developer.apple.com/documentation/uikit/leveraging-touch-input-for-drawing-apps

### 
#### 
With Speed Sketch, users can draw by moving their finger or Apple Pencil across the screen, and the system reports the touches to the app. Speed Sketch captures these touches using the custom gesture recognizer, `StrokeGestureRecognizer`.
The stroke gesture recognizer receives each touch event, and appends data from the touches to an array of data samples.
```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if trackedTouch == nil {
        trackedTouch = touches.first
        initialTimestamp = trackedTouch?.timestamp
        collectForce = trackedTouch!.type == .pencil || view?.traitCollection.forceTouchCapability == .available
        if !isForPencil {
            // Give other gestures, such as pan and pinch, a chance by
            // slightly delaying the .began state.
            fingerStartTimer = Timer.scheduledTimer(
                withTimeInterval: cancellationTimeInterval,
                repeats: false,
                block: { [weak self] (timer) in
                    guard let strongSelf = self else { return }
                    if strongSelf.state == .possible {
                        strongSelf.state = .began
                    }
                }
            )
        }
    }
    if append(touches: touches, event: event) {
        if isForPencil {
            state = .began
        }
    }
}

override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if append(touches: touches, event: event) {
        if state == .began {
            state = .changed
        }
    }
}

override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if append(touches: touches, event: event) {
        stroke.state = .done
        state = .ended
    }
}

override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    if append(touches: touches, event: event) {
        stroke.state = .cancelled
        state = .failed
    }
}
```

The  method sets a timer to give other gesture recognizers, such as pan and pinch, time to handle touches that the user makes with their finger. This behavior is unique to drawing apps such as Speed Sketch that start capturing and drawing a stroke the moment the user touches the screen.
In order to track finger and Apple Pencil touches separately, Speed Sketch uses two instances of `StrokeGestureRecognizer`: one for finger touches and the other to track touches coming from Apple Pencil.
```swift
self.fingerStrokeRecognizer = setupStrokeGestureRecognizer(isForPencil: false)
self.pencilStrokeRecognizer = setupStrokeGestureRecognizer(isForPencil: true)
```

```
To simplify the code, the app uses a helper method to create the gesture recognizers.
```swift
func setupStrokeGestureRecognizer(isForPencil: Bool) -> StrokeGestureRecognizer {
    let recognizer = StrokeGestureRecognizer(target: self, action: #selector(strokeUpdated(_:)))
    recognizer.delegate = self
    recognizer.cancelsTouchesInView = false
    scrollView.addGestureRecognizer(recognizer)
    recognizer.coordinateSpaceView = cgView
    recognizer.isForPencil = isForPencil
    return recognizer
}
```

```
The gesture recognizer distinguishes between the touch types by setting the  property to  when tracking Apple Pencil touches, and to  when tracking touches from a finger.
```swift
var isForPencil: Bool = false {
    didSet {
        if isForPencil {
            allowedTouchTypes = [UITouch.TouchType.pencil.rawValue as NSNumber]
        } else {
            allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        }
    }
}
```

```
Each time the user draws a stroke on the screen, the stroke gesture recognizer calls the `strokeUpdate(_:)` method. This method checks to see if the recognizer is for Apple Pencil, and if so, puts the app into pencil mode. While the app is in pencil mode, the user can use one finger to pan the drawing canvas. When the app isn’t in pencil mode — that is, when the user is drawing with their finger — the user uses two fingers to pan the drawing canvas.
```swift
var pencilMode = false {
    didSet {
        if pencilMode {
            scrollView.panGestureRecognizer.minimumNumberOfTouches = 1
            pencilButton.isHidden = false
            if let view = fingerStrokeRecognizer.view {
                view.removeGestureRecognizer(fingerStrokeRecognizer)
            }
        } else {
            scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
            pencilButton.isHidden = true
            if fingerStrokeRecognizer.view == nil {
                scrollView.addGestureRecognizer(fingerStrokeRecognizer)
            }
        }
    }
}
```

#### 
The stroke gesture recognizer receives touch events from the system. For most apps, the time span between each touch event is enough to handle the gesture. However, users of drawing apps expect greater precision, which requires the app to gather all the touches reported since the last delivered touch event.
To gather the additional touches, Speed Sketch calls the  method. This method returns an array of  objects representing the touches received by the system but not delivered in the last event. The additional touches allow Speed Sketch to provide a smoother rendering of the stroke by storing the coalesced touches as part of the stroke’s data sample.
```swift
if collectsCoalescedTouches {
    if let event = event {
        let coalescedTouches = event.coalescedTouches(for: touchToAppend)!
        let lastIndex = coalescedTouches.count - 1
        for index in 0..<lastIndex {
            saveStrokeSample(stroke: stroke, touch: coalescedTouches[index], view: view, coalesced: true, predicted: false)
        }
        saveStrokeSample(stroke: stroke, touch: coalescedTouches[lastIndex], view: view, coalesced: false, predicted: false)
    }
} else {
    saveStrokeSample(stroke: stroke, touch: touchToAppend, view: view, coalesced: false, predicted: false)
}
```

```
In addition to coalesced touches, Speed Sketch uses touch data predicted by the system as a way to enhance the perceived accuracy of the app’s drawing capabilities. Speed Sketch retrieves the predicted touches by calling the  method for the event, then saves the touches as part of the data sample for the stroke.
```swift
if usesPredictedSamples && stroke.state == .active {
    if let predictedTouches = event?.predictedTouches(for: touchToAppend) {
        for touch in predictedTouches {
            saveStrokeSample(stroke: stroke, touch: touch, view: view, coalesced: false, predicted: true)
        }
    }
}
```

```
The app replaces the predicted touches with actual touches as they become available.
```swift
override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
    for touch in touches {
        guard let index = touch.estimationUpdateIndex else {
            continue
        }
        if let (stroke, sampleIndex) = outstandingUpdateIndexes[Int(index.intValue)] {
            var sample = stroke.samples[sampleIndex]
            let expectedUpdates = sample.estimatedPropertiesExpectingUpdates
            if expectedUpdates.contains(.force) {
                sample.force = touch.force
                if !touch.estimatedProperties.contains(.force) {
                    // Only remove the estimate flag if the new value isn't estimated as well.
                    sample.estimatedProperties.remove(.force)
                }
            }
            sample.estimatedPropertiesExpectingUpdates = touch.estimatedPropertiesExpectingUpdates
            if touch.estimatedPropertiesExpectingUpdates == [] {
                outstandingUpdateIndexes.removeValue(forKey: sampleIndex)
            }
            stroke.update(sample: sample, at: sampleIndex)
        }
    }
}
```

#### 
Apple Pencil can sense tilt (altitude), force (pressure), and orientation (azimuth), which drawing apps can use to affect the appearance of strokes. For instance, Speed Sketch uses azimuth to enhance the strokes when using the app’s Calligraphy drawing tool.
```swift
func drawCalligraphy(in context: CGContext,
                     toSample: StrokeSample,
                     fromSample: StrokeSample,
                     forceAccessBlock: (_ sample: StrokeSample) -> CGFloat) {

    var fromAzimuthUnitVector = Stroke.calligraphyFallbackAzimuthUnitVector
    var toAzimuthUnitVector = Stroke.calligraphyFallbackAzimuthUnitVector

    if fromSample.azimuth != nil {

        if lockedAzimuthUnitVector == nil {
            lockedAzimuthUnitVector = fromSample.azimuthUnitVector
        }
        fromAzimuthUnitVector = fromSample.azimuthUnitVector
        toAzimuthUnitVector = toSample.azimuthUnitVector
        if fromSample.altitude! > azimuthLockAltitudeThreshold {
            fromAzimuthUnitVector = lockedAzimuthUnitVector!
        }
        if toSample.altitude! > azimuthLockAltitudeThreshold {
            toAzimuthUnitVector = lockedAzimuthUnitVector!
        } else {
            lockedAzimuthUnitVector = toAzimuthUnitVector
        }

    }
    // Rotate 90 degrees
    let calligraphyTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
    fromAzimuthUnitVector = fromAzimuthUnitVector.applying(calligraphyTransform)
    toAzimuthUnitVector = toAzimuthUnitVector.applying(calligraphyTransform)

    let fromUnitVector = fromAzimuthUnitVector * forceAccessBlock(fromSample)
    let toUnitVector = toAzimuthUnitVector * forceAccessBlock(toSample)

    context.beginPath()
    context.addLines(between: [
        fromSample.location + fromUnitVector,
        toSample.location + toUnitVector,
        toSample.location - toUnitVector,
        fromSample.location - fromUnitVector
        ])
    context.closePath()

    context.drawPath(using: .fillStroke)

}
```

```
Speed Sketch also displays the altitude and azimuth data as part of the stroke when the user selects the Debug drawing tool.
```swift
func drawDebugMarkings(in context: CGContext, fromSample: StrokeSample) {

    let isEstimated = fromSample.estimatedProperties.contains(.azimuth)
    guard displayOptions == .debug,
        fromSample.predicted == false,
        fromSample.azimuth != nil,
        (!fromSample.coalesced || isEstimated) else {
            return
    }

    let length = CGFloat(20.0)
    let azimuthUnitVector = fromSample.azimuthUnitVector
    let azimuthTarget = fromSample.location + azimuthUnitVector * length
    let altitudeStart = azimuthTarget + (azimuthUnitVector * (length / -2.0))
    let transformToApply = CGAffineTransform(rotationAngle: fromSample.altitude!)
    let altitudeTarget = altitudeStart + (azimuthUnitVector * (length / 2.0)).applying(transformToApply)

    // Draw altitude as black line coming from the center of the azimuth.
    altitudeSettings(in: context)
    context.beginPath()
    context.move(to: altitudeStart)
    context.addLine(to: altitudeTarget)
    context.strokePath()

    // Draw azimuth as blue (or orange if estimated) line.
    azimuthSettings(in: context)
    if isEstimated {
        context.setStrokeColor(UIColor.orange.cgColor)
    }
    context.beginPath()
    context.move(to: fromSample.location)
    context.addLine(to: azimuthTarget)
    context.strokePath()

}
```

- Ignoring double tap
Speed Sketch doesn’t have an eraser tool or color pallet, but it does have different drawing tools: Calligraphy, Ink, and Debug. When the user’s preferred double-tap action is  and the user double-taps their finger on Apple Pencil, Speed Sketch switches to the tool last used by the user. The sample app ignores the other preferred actions.
```swift
func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
    if UIPencilInteraction.preferredTapAction == .switchPrevious {
        leftRingControl.switchToPreviousTool()
    }
}
```

```
In order for Speed Sketch to receive the double-tap event, it adds a  object to the canvas view.
```swift
let pencilInteraction = UIPencilInteraction()
pencilInteraction.delegate = self
view.addInteraction(pencilInteraction)
```


## Making a view into a drag source
> https://developer.apple.com/documentation/uikit/making-a-view-into-a-drag-source

### 
#### 
3. Add the interaction to the view’s  property.
Here’s how to do this using a custom helper method, which you’d typically call within a view controller’s  method:
```swift
func customEnableDragging(on view: UIView, dragInteractionDelegate: UIDragInteractionDelegate) {
    let dragInteraction = UIDragInteraction(delegate: dragInteractionDelegate)
    view.addInteraction(dragInteraction)
}
```

#### 
A drag item encapsulates a source app’s promises for providing a variety of data representations for one model object.
To create a drag item, implement the  method in your drag interaction delegate, as shown here in a minimal form:
```swift
func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
    // Cast to NSString is required for NSItemProviderWriting support.
    let stringItemProvider = NSItemProvider(object: "Hello World" as NSString)
    return [
        UIDragItem(itemProvider: stringItemProvider)
    ]
}
```

#### 

## Making a view into a drop destination
> https://developer.apple.com/documentation/uikit/making-a-view-into-a-drop-destination

### 
#### 
3. Add the interaction to the view’s  property.
Here’s how to do this:
```swift
func customEnableDropping(on view: UIView, dropInteractionDelegate: UIDropInteractionDelegate) {
    let dropInteraction = UIDropInteraction(delegate: dropInteractionDelegate)
    view.addInteraction(dropInteraction)
}
```

#### 
When the user moves the touch point of a drag session over a drop destination, you can immediately refuse it, or you can tell the system to continue its conversation with your delegate object. Provide your response as follows:
```swift
func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
    // Ensure the drop session has an object of the appropriate type
    return session.canLoadObjects(ofClass: UIImage.self)
}
```

#### 
For a view to be eligible to accept the data from a drop session, you  implement the  protocol method. In your implementation, return a drop proposal—a  object that specifies the drop operation type, a constant from the  enumeration.
Provide a drop proposal like this:
```swift
func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        // Propose to the system to copy the item from the source app
        return UIDropProposal(operation: .copy)
}

```

#### 
The final step of the conversation between the drop interaction delegate and the system is when your app consumes the data the user has dragged from the source app. Here, your drop interaction delegate asks the drop session to load its drag items:
```swift
func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
    // Consume drag items (in this example, of type UIImage).
    session.loadObjects(ofClass: UIImage.self) { imageItems in
        let images = imageItems as! [UIImage]
        self.imageView.image = images.first
    }
    // Perform additional UI updates as needed.
}
```

#### 

## Managing functions and function pointers
> https://developer.apple.com/documentation/uikit/managing-functions-and-function-pointers

### 
#### 
#### 
If you pass a function pointer in your code, its calling conventions must take the same set of parameters everywhere in the code. Never cast a variadic function to a function that takes a fixed number of parameters (or vice versa).
The following code shows an example of a problematic function call:
```objc
int MyFunction(int a, int b, ...);

int (*action)(int, int, int) = (int (*)(int, int, int)) MyFunction;
action(1,2,3); // Incorrect.
```

#### 
#### 
The Objective-C runtime directly calls the function that implements the method, so the calling conventions are mismatched. You must cast the  function to a prototype that matches the method function being called.
The following code shows proper form for dispatching a message to an object, using the low-level message functions:
```objc
- (int) doSomething:(int) x {
   return x + 2;
}

- (void) doSomethingElse {
    int (*action)(id, SEL, int) = (int (*)(id, SEL, int)) objc_msgSend;
    action(self, @selector(doSomething:), 0);
}
```


## Optimizing your iPad app for Mac
> https://developer.apple.com/documentation/uikit/optimizing-your-ipad-app-for-mac

### 
#### 
#### 
#### 
iPad apps using a split view controller get a Mac-style vertical split view when running in macOS. You can help your iPad app look more at home on Mac by applying Liquid Glass to the primary view controller’s background. To do this, set your split view controller’s  to , as shown in the following code.
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let splitViewController = window!.rootViewController as! UISplitViewController
    let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count - 1] as! UINavigationController
    navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
    
    // Add a Liquid Glass background to the primary view controller.
    splitViewController.primaryBackgroundStyle = .sidebar
    
    splitViewController.delegate = self
    
    return true
}
```

#### 
Mac users rely on a pointer to interact with apps, whether selecting a text field or moving a window. As the user moves the pointer over UI elements, some elements should change their appearance. For example, a web browser highlights a link as the pointer moves over it.
To detect when the user moves the pointer over a view in your app, add a  to that view. This tells your app when the pointer enters or leaves the view, or moves while over it.
```swift
class ViewController: UIViewController {

    @IBOutlet var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let hover = UIHoverGestureRecognizer(target: self, action: #selector(hovering(_:)))
        button.addGestureRecognizer(hover)
    }

    @objc
    func hovering(_ recognizer: UIHoverGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed:
            button.titleLabel?.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        case .ended:
            button.titleLabel?.textColor = UIColor.link
        default:
            break
        }
    }
}
```


## Performing one-time setup for your app
> https://developer.apple.com/documentation/uikit/performing-one-time-setup-for-your-app

### 
#### 
- `~/Library/Caches/` — Store temporary data files that can be easily regenerated or downloaded.
- `~/Library/Caches/` — Store temporary data files that can be easily regenerated or downloaded.
To obtain a URL for one of the directories in your app’s container, use the  method of .
```swift
let appSupportURL = FileManager.default.urls(for: 
      .applicationSupportDirectory, in: .userDomainMask)

let cachesURL = FileManager.default.urls(for: 
      .cachesDirectory, in: .userDomainMask)
```


## Pointer interactions
> https://developer.apple.com/documentation/uikit/pointer-interactions

### 
#### 
5. Return  from that delegate method.
This example uses a custom helper method, which you typically call within a view controller’s  method:
```swift
func customPointerInteraction(on view: UIView, pointerInteractionDelegate: UIPointerInteractionDelegate) {
    let pointerInteraction = UIPointerInteraction(delegate: pointerInteractionDelegate)
    view.addInteraction(pointerInteraction)
}
```

```
The  delegate method is called when the pointer enters the view’s region. The following example shows an interaction that applies a  effect by returning a  object:
```swift
func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
    var pointerStyle: UIPointerStyle? = nil

    if let interactionView = interaction.view {
        let targetedPreview = UITargetedPreview(view: interactionView)
        pointerStyle = UIPointerStyle(effect: UIPointerEffect.lift(targetedPreview))
    }
    return pointerStyle
}
```

#### 
Including animations can be helpful in pointer interactions, especially when views contain elements that interfere with pointer effects. For example, hiding the separator bars in a  when the pointer enters the control allows the active segment effect to appear visually uncluttered.
The following example performs a simple animation to change the alpha value of the view when the pointer enters and exits the region:
```swift
func pointerInteraction(_ interaction: UIPointerInteraction, willEnter region: UIPointerRegion, animator: UIPointerInteractionAnimating) {
    if let interactionView = interaction.view {
        animator.addAnimations {
            interactionView.alpha = 0.5
        }
    }
}

func pointerInteraction(_ interaction: UIPointerInteraction, willExit region: UIPointerRegion, animator: UIPointerInteractionAnimating) {
    if let interactionView = interaction.view {
        animator.addAnimations {
            interactionView.alpha = 1.0
        }
    }
}
```

#### 

## Positioning content relative to the safe area
> https://developer.apple.com/documentation/uikit/positioning-content-relative-to-the-safe-area

### 
#### 
The following code shows the  method of the container view controller that extends the safe area of its child view controller to account for the custom views, as shown in the image. Make your modifications in this method because the safe area insets for a view aren’t accurate until the view is added to a view hierarchy.
```swift
override func viewDidAppear(_ animated: Bool) {
   var newSafeArea = UIEdgeInsets()
   // Adjust the safe area to accommodate 
   //  the width of the side view.
   if let sideViewWidth = sideView?.bounds.size.width {
      newSafeArea.right += sideViewWidth
   }
   // Adjust the safe area to accommodate 
   //  the height of the bottom view.
   if let bottomViewHeight = bottomView?.bounds.size.height {
      newSafeArea.bottom += bottomViewHeight
   }
   // Adjust the safe area insets of the 
   //  embedded child view controller.
   let child = self.childViewControllers[0]
   child.additionalSafeAreaInsets = newSafeArea
}
```


## Preferring one gesture over another
> https://developer.apple.com/documentation/uikit/preferring-one-gesture-over-another

### 
For any two gesture recognizers involved in a potential conflict, only one needs an associated delegate object, and that object must conform to the  protocol. In your delegate, implement the methods you need for the appropriate resolution. The best way to see how to use these methods is with a few examples.
The following code shows how to recognize tap and double-tap gestures in the same view. The view in this example has two  objects, one of which is configured to require two taps. Normally, the single-tap gesture would always be recognized before the double-tap gesture, but you can use the  method to reverse that behavior. The implementation of this method prevents the single-tap gesture from being recognized until after the double-tap gesture recognizer explicitly reaches the failed state, which happens when the touch sequence contains only one tap.
```swift
func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, 
         shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
   // Don't recognize a single tap until a double-tap fails.
   if gestureRecognizer == self.tapGesture && 
          otherGestureRecognizer == self.doubleTapGesture {
      return true
   }
   return false
}
```

```
The following code shows how to recognize a swipe gesture before a pan gesture. In this case, the delegate object is attached to the swipe gesture recognizer and implements the  method. The logic of this method prevents the pan gesture from being recognized until the swipe gesture fails.
```swift
func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, 
         shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
   // Do not begin the pan until the swipe fails. 
   if gestureRecognizer == self.swipeGesture && 
          otherGestureRecognizer == self.panGesture {
      return true
   }
   return false
}
```

```
The following code shows an alternative way to configure the dependency between a swipe and a pan gesture. Instead of attaching a delegate object to the swipe gesture, this example attaches the delegate to the pan gesture. Because of the change, the delegate must now implement the  method and require the swipe to fail. The end results are the same as those from the previous example.
```swift
func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, 
         shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
   if gestureRecognizer == self.panGesture && 
          otherGestureRecognizer == self.swipeGesture {
      return true
   }
   return false
}
```


## Prefetching collection view data
> https://developer.apple.com/documentation/uikit/prefetching-collection-view-data

### 
#### 
The root view controller uses an instance of the `CustomDataSource` class to provide data to its  instance. The `CustomDataSource` class implements the `UICollectionViewDataSourcePrefetching` protocol to begin fetching the data required to populate cells.
```swift
class CustomDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
```

```
In addition to assigning the `CustomDataSource` instance to the collection view’s  property, the sample code project also assigns it to the  property.
```swift
// Set the collection view's data source.
collectionView.dataSource = dataSource

// Set the collection view's prefetching data source.
collectionView.prefetchDataSource = dataSource
```

#### 
Prefetching data is a tool to use when loading data is a slow or expensive process — for example, when fetching data over the network. In these circumstances, it’s best to perform data loading asynchronously. In this sample, the `AsyncFetcher` class fetches data asynchronously, simulating a network request.
First, the sample implements the  prefetch method, invoking the appropriate method on the asynchronous fetcher.
```swift
func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    // Begin asynchronously fetching data for the requested index paths.
    for indexPath in indexPaths {
        let model = models[indexPath.row]
        asyncFetcher.fetchAsync(model.identifier)
    }
}
```

When prefetching is complete, the sample adds the cell’s data to the `AsyncFetcher`‘s cache, so it’s ready to use when the cell displays. The cell’s background color changes from white to red when data is available for that cell.
```swift
/**
 Configures the cell for display based on the model.
 
 - Parameters:
     - data: An optional `DisplayData` object to display.
 
 - Tag: Cell_Config
*/
func configure(with data: DisplayData?) {
    backgroundColor = data?.color
}
```

#### 
Before populating a cell, the `CustomDataSource` checks for any prefetched data that it can use. If none is available, the `CustomDataSource` makes a fetch request and the cell updates in the fetch request’s completion handler.
```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
        fatalError("Expected `\(Cell.self)` type for reuseIdentifier \(Cell.reuseIdentifier). Check the configuration in Main.storyboard.")
    }
    
    let model = models[indexPath.row]
    let identifier = model.identifier
    cell.representedIdentifier = identifier
    
    // Check if the `asyncFetcher` has already fetched data for the specified identifier.
    if let fetchedData = asyncFetcher.fetchedData(for: identifier) {
        // The system has fetched and cached the data; use it to configure the cell.
        cell.configure(with: fetchedData)
    } else {
        // There is no data available; clear the cell until the fetched data arrives.
        cell.configure(with: nil)

        // Ask the `asyncFetcher` to fetch data for the specified identifier.
        asyncFetcher.fetchAsync(identifier) { fetchedData in
            DispatchQueue.main.async {
                /*
                 The `asyncFetcher` has fetched data for the identifier. Before
                 updating the cell, check whether the collection view has recycled it to represent other data.
                 */
                guard cell.representedIdentifier == identifier else { return }
                
                // Configure the cell with the fetched image.
                cell.configure(with: fetchedData)
            }
        }
    }

    return cell
}
```

#### 
The sample implements the  delegate method to cancel any in-progress data fetches that are no longer required.
```swift
func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    // Cancel any in-flight requests for data for the specified index paths.
    for indexPath in indexPaths {
        let model = models[indexPath.row]
        asyncFetcher.cancelFetch(model.identifier)
    }
}
```


## Presenting content on a connected display
> https://developer.apple.com/documentation/uikit/presenting-content-on-a-connected-display

### 
#### 
#### 
When a display connects to an iOS device, the system provides a scene for your app. Your app receives the scene through the  method on your scene delegate. You can use the method and the session object it provides to configure and attach a window to the scene. The system displays the window you provide on the window scene’s current screen.
This example configures a window to render on a scene’s display.
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    if session.role == .windowApplication {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
}
```

#### 
#### 
Use the scene delegate’s  method if your app needs to know when a scene is changing screens.
This example uses a display link and updates the link when the scene changes screens.
```swift
class ExternalDisplaySceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var screen: UIScreen?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        if session.role == .windowExternalDisplayNonInteractive {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = ExternalDisplayViewController()
            self.window = window
            window.makeKeyAndVisible()
            ...
            setupDisplayLinkIfNecessary()
        }
    }

    func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection) {
        setupDisplayLinkIfNecessary()
    }

    weak var linkedScreen: UIScreen?

    func setupDisplayLinkIfNecessary() {
        let currentScreen = self.screen
        if currentScreen != linkedScreen {
            // Set up display link
            ...
            self.linkedScreen = currentScreen
        }
    }

    ...
}
```

#### 

## Preserving your app’s UI across launches
> https://developer.apple.com/documentation/uikit/preserving-your-app-s-ui-across-launches

### 
#### 
You opt-in to state preservation and restoration by implementing your app delegate’s  and  methods. Both methods return a Boolean value indicating whether the associated process should occur, and in most cases you simply return . However, you can return  at times when restoring your app’s interface might not be appropriate.
When UIKit calls your  method, you can save data in addition to returning . You might save data that you intend to use during the restoration process. For example, the following code shows an example that saves the app’s current version number. At restoration time, the  method checks the version number in the archive and prevents restoration from occurring if it doesn’t match the expected version.
```swift
func application(_ application: UIApplication, 
            shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
   // Save the current app version to the archive.
   coder.encode(11.0, forKey: "MyAppVersion")
        
   // Always save state information.
   return true
}
    
func application(_ application: UIApplication, 
            shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
   // Restore the state only if the app version matches.
   let version = coder.decodeFloat(forKey: "MyAppVersion")
   if version == 11.0 {
      return true
   }
    
   // Don't restore from old data.    
   return false
}
```

#### 
#### 
State preservation isn’t a substitute for saving your app’s data to disk. UIKit can discard state preservation data at its discretion, allowing your app to return to its default state. Use the preservation process to store information about the state of your app’s user interface, such as the currently selected row of a table. Don’t use it to store the data contained in that table.
The following code shows an example of a view controller with text fields for gathering a first and last name. If one of the text fields contains an unsaved value, the method saves the unsaved value and an identifier for which text field contains that value. In this case, the unsaved value isn’t part of the app’s persistent data; it’s a temporary value that can be discarded if needed.
```swift
override func encodeRestorableState(with coder: NSCoder) {
   super.encodeRestorableState(with: coder)
        
   // Save the user ID so that we can load that user later.
   coder.encode(userID, forKey: "UserID")

   // Write out any temporary data if editing is in progress.
   if firstNameField!.isFirstResponder {
      coder.encode(firstNameField?.text, forKey: "EditedText")
      coder.encode(Int32(1), forKey: "EditField")
   }
   else if lastNameField!.isFirstResponder {
      coder.encode(lastNameField?.text, forKey: "EditedText")
      coder.encode(Int32(2), forKey: "EditField")
   }
   else {
      // No editing was in progress.
      coder.encode(Int32(0), forKey: "EditField")
   }
}
```

#### 
UIKit loads both the view controller and its views from your storyboard initially. After those objects have been loaded and initialized, UIKit begins restoring their state information. Use your  methods to return your view controller to its previous state.
The following code shows the method for decoding the state that was encoded in the previous example. This method restores the view controller’s data from the preserved user ID. If a text field was being edited, this method also restores the in-progress value and makes the corresponding text field the first responder, which displays the keyboard for that text field.
```swift
override func decodeRestorableState(with coder: NSCoder) {
   super.decodeRestorableState(with: coder)
   
   // Restore the first name and last name from the user ID.
   let identifier = coder.decodeObject(forKey: "UserID") as! String
   setUserID(identifier: identifier)

   // Restore an in-progress value that was not saved.
   let activeField = coder.decodeInteger(forKey: "EditField")
   let editedText = coder.decodeObject(forKey: "EditedText") as! 
                         String?

   switch activeField {
      case 1:
         firstNameField?.text = editedText
         firstNameField?.becomeFirstResponder()
         break
            
      case 2:
         lastNameField?.text = editedText
         lastNameField?.becomeFirstResponder()
         break
            
     default:
         break  // Do nothing.
  }
}
```


## Providing access to directories
> https://developer.apple.com/documentation/uikit/providing-access-to-directories

### 
#### 
To prompt the user to select a directory, create a document picker and set the content type to open to the type . Then set the document picker’s delegate and present it.
```swift
// Create a document picker for directories.
let documentPicker =
    UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
documentPicker.delegate = self

// Set the initial directory.
documentPicker.directoryURL = startingDirectory

// Present the document picker.
present(documentPicker, animated: true, completion: nil)
```

#### 
2. Use a file coordinator to perform read or write operations on the URL’s contents.
3. After you access the URL, call .
```swift
func documentPicker(_ controller:UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    // Start accessing a security-scoped resource.
    guard let url = urls.first,
        url.startAccessingSecurityScopedResource() else {
        // Handle the failure here.
        return
    }

    // Make sure you release the security-scoped resource when you finish.
    defer { url.stopAccessingSecurityScopedResource() }

    // Use file coordination for reading and writing any of the URL’s content.
    var error: NSError? = nil
    NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { (url) in
            
        let keys : [URLResourceKey] = [.nameKey, .isDirectoryKey]
            
        // Get an enumerator for the directory's content.
        guard let fileList =
            FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys) else {
            Swift.debugPrint("*** Unable to access the contents of \(url.path) ***\n")
            return
        }
            
        for case let file as URL in fileList {
            // Start accessing the content's security-scoped URL.
            guard file.startAccessingSecurityScopedResource() else {
                // Handle the failure here.
                continue
            }

            // Do something with the file here.
            Swift.debugPrint("chosen file: \(file.lastPathComponent)")
                
            // Make sure you release the security-scoped resource when you finish.
            file.stopAccessingSecurityScopedResource()
        }
    }
}
```

#### 
To access the URL in the future, save the URL as a  using its  method.
```swift
do {
    // Start accessing a security-scoped resource.
    guard url.startAccessingSecurityScopedResource() else {
        // Handle the failure here.
        return
    }
    
    // Make sure you release the security-scoped resource when you finish.
    defer { url.stopAccessingSecurityScopedResource() }
    
    let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
    
    try bookmarkData.write(to: getMyURLForBookmark())
}
catch let error {
    // Handle the error here.
}
```

```
You can then read the bookmark, and resolve it to a security-scoped URL again.
```swift
do {
    let bookmarkData = try Data(contentsOf: getMyURLForBookmark())
    var isStale = false
    let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
    
    guard !isStale else {
        // Handle stale data here.
        return
    }
    
    // Use the URL here.
}
catch let error {
    // Handle the error here.
}
```

#### 

## Providing data to the view hierarchy with custom traits
> https://developer.apple.com/documentation/uikit/providing-data-to-the-view-hierarchy-with-custom-traits

### 
#### 
To create a custom trait, define a type that conforms to :
```swift
struct ContainedInSettingsTrait: UITraitDefinition {
    static let defaultValue = false
}
```

```
 is the only required static property. The system infers the type for your custom trait from the type of the value you set for `defaultValue`. After you define your custom trait, set its value using your trait as the key in the `traitOverrides` property of an object in your view hierarchy:
```swift
self.traitOverrides[ContainedInSettingsTrait.self] = true
```

Then, the system propagates the trait and value to that object’s descendants in the view hierarchy. For example, if the object is a view controller, the system propagates the view controller’s trait collection with the override to the view controller’s view and subviews, and to any child view controllers.
Access the value of your trait using your trait as the key in a trait collection:
```swift
let value = traitCollection[ContainedInSettingsTrait.self]
```

#### 
Add convenience properties to  and  to make your custom trait easier to access. First, extend  with a property to get the value of your custom trait from a trait collection:
```swift
extension UITraitCollection {
    var isContainedInSettings: Bool { self[ContainedInSettingsTrait.self] }
}
```

```
Next, extend  to get and set the value of your custom trait:
```swift
extension UIMutableTraits {
    var isContainedInSettings: Bool {
        get { self[ContainedInSettingsTrait.self] }
        set { self[ContainedInSettingsTrait.self] = newValue }
    }
}
```

```
Then, use standard property syntax to access and update your custom trait:
```swift
let traitCollection = UITraitCollection { mutableTraits in
    mutableTraits.isContainedInSettings = true
}

let value = traitCollection.isContainedInSettings
```

#### 
Set optional properties of  to give your trait additional system capabilities and improve debugging:
The following example demonstrates setting these optional properties:
```swift
enum MyAppTheme: Int {
    case standard, pastel, bold, monochrome
}

struct MyAppThemeTrait: UITraitDefinition {
    static let defaultValue = MyAppTheme.standard
    static let affectsColorAppearance = true
    static let name = "Theme"
    static let identifier = "com.myapp.theme"
}
```


## Removing the title bar in your Mac app built with Mac Catalyst
> https://developer.apple.com/documentation/uikit/removing-the-title-bar-in-your-mac-app-built-with-mac-catalyst

### 
#### 
If you choose to design your window without a title bar, you must remove it from the window. To remove the title bar, set the title bar’s  property to  and the  property to `nil`. The following code shows how to remove the title bar and its separator from the window during the setup of a new scene.
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    #if targetEnvironment(macCatalyst)
    if let titlebar = windowScene.titlebar {
        titlebar.titleVisibility = .hidden
        titlebar.toolbar = nil
    }
    #endif

}
```


## Requesting access to protected resources
> https://developer.apple.com/documentation/uikit/requesting-access-to-protected-resources

### 
#### 
#### 
Adhere to these requirements for every purpose string in your app, including localized purpose strings.
App Review checks for the use of protected resources, and rejects apps that contain code accessing those resources without a purpose string. For example, an app accessing location might receive the following information from App Review about the requirement that an  key be present:
```console
ITMS-90683: Missing purpose string in Info.plist. 
Your app’s code references one or more APIs that access sensitive user 
data, or the app has one or more entitlements that permit such access. 
The Info.plist file for the "{app-bundle-path}" bundle should contain a 
NSLocationWhenInUseUsageDescription key with a user-facing purpose string 
explaining clearly and completely why your app needs the data.
If you’re using external libraries or SDKs, they may reference APIs that 
require a purpose string. While your app might not use these APIs, a 
purpose string is still required. For details, visit: 
https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy/requesting_access_to_protected_resources.
```

#### 
#### 
To reset permissions for a particular service in macOS apps, run the `tccutil reset <service name>` command in Terminal. For example, to reset all permissions for AppleEvents, type:
```swift
$ tccutil reset AppleEvents
```


## Responding to changing display modes on Apple TV
> https://developer.apple.com/documentation/uikit/responding-to-changing-display-modes-on-apple-tv

### 
#### 
#### 
#### 
Implement the  method to respond to changing device traits. If your app performs expensive operations related to image generation based on the current display gamut, it’s important to verify that the display gamut has changed before performing these operations. The following code shows how to test whether the display gamut changed.
```swift
override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    let currentDisplayGamut = self.traitCollection.displayGamut
    if (previousTraitCollection?.displayGamut == .SRGB) && (currentDisplayGamut == .SRGB) {
        // Resolution didn't change. Your code goes here.
    } else if (previousTraitCollection?.displayGamut == .P3) && (currentDisplayGamut == .P3) {
        // Resolution didn't change. Your code goes here.
    } else {
        // Resolution changed. Your code goes here.
    }
}
```


## Responding to the launch of your app
> https://developer.apple.com/documentation/uikit/responding-to-the-launch-of-your-app

### 
#### 
#### 
#### 
#### 
The following code shows how you can check for a `URL` that contains information in query items in the scene’s connection options:
When UIKit connects to a scene in your app, it passes along a  object that contains information about why UIKit connected to the scene. For example, this could indicate that the user requested your app to open a , which you might use to display a screen related to information provided in the `URL`.
The following code shows how you can check for a `URL` that contains information in query items in the scene’s connection options:
```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Confirm the scene is a window scene in iOS or iPadOS. 
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Check if the scene connection options include a URL,
        // and whether the URL has query items.
        guard let linkedUrl = connectionOptions.urlContexts.first?.url,
              let linkedComponents = URLComponents(url: linkedUrl, resolvingAgainstBaseURL: false),
              let queryItems = linkedComponents.queryItems,
              !queryItems.isEmpty else {
            return
        }
        
        // Check and handle the URL and query items here.
    }
    // Other methods…
}
```

#### 
The following code shows the app delegate method for an app that handles receiving a `URL`. The code checks the launch options for an incoming URL, and whether that `URL` contains query items that you can use to configure your app. If not, the code returns `false` to indicate that your app can’t handle the launch options.
```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Check if the launch options include a URL,
        // and whether the URL has query items.
        guard let linkedUrl = launchOptions?[.url] as? URL,
              let linkedComponents = URLComponents(url: linkedUrl, resolvingAgainstBaseURL: false),
              let queryItems = linkedComponents.queryItems,
              !queryItems.isEmpty else {
            return false
        }
        
        // Check whether your app can handle the URL and query
        // items here. Then return `true` if so, otherwise `false`.
        // ...
        
        return true
    }
    // Other methods…
}
```


## Restoring your app’s state
> https://developer.apple.com/documentation/uikit/restoring-your-app-s-state

### 
#### 
#### 
To provide the necessary activity object, the sample implements the  method of its scene delegate as shown in the example below. Implementing this method tells the system that the sample supports user-activity-based state restoration. The implementation of this method returns the activity object from the scene’s  property, which the sample populates when the scene becomes inactive.
```swift
func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
    return scene.userActivity
}
```

For view-controller-based state restoration, this sample opts in to state preservation and restoration using the app delegate’s  and  methods. Both methods return a `Bool` value that indicates whether the step should occur. This sample returns `true` for both functions.
This example enables the preservation of state for the app:
```swift
func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
    return true
}
```

```
This example enables the restoration of state for the app:
```swift
func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
    return true
}
```

#### 
#### 
This example enables the state preservation of `InfoViewController`:
This sample saves the state information in the detail view controller’s  method, and it restores that state in the  method. Because it already encapsulates the view controller’s state in an  object, the implementations of these methods operate on the existing activity object. The sample then calls the required superclass methods from these methods, which allows UIKit to restore the rest of the view controller’s inherited state.
This example enables the state preservation of `InfoViewController`:
```swift
override func encodeRestorableState(with coder: NSCoder) {
    super.encodeRestorableState(with: coder)

    coder.encode(product?.identifier.uuidString, forKey: InfoViewController.restoreProductKey)
}
```

This example enables the state restoration of  `InfoViewController`:
```
This example enables the state restoration of  `InfoViewController`:
```swift
override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)
    
    guard let decodedProductIdentifier =
        coder.decodeObject(forKey: InfoViewController.restoreProductKey) as? String else {
        fatalError("A product did not exist in the restore. In your app, handle this gracefully.")
    }
    product = DataModelManager.sharedInstance.product(fromIdentifier: decodedProductIdentifier)
}
```

#### 

## Scaling fonts automatically
> https://developer.apple.com/documentation/uikit/scaling-fonts-automatically

### 
#### 
#### 
In your source code, call the  method. This method returns a  that you can assign to a label, text field, or text view. Next, set the  property on the text control to . This setting tells the text control to adjust the text size based on the Dynamic Type setting provided by the user.
```swift
label.font = UIFont.preferredFont(forTextStyle: .body)
label.adjustsFontForContentSizeCategory = true
```

If the  property is set to , the font will initially be the right size, but it won’t respond to text-size changes the user makes in Settings or Control Center. To detect such changes, override the  method in your view or view controller, and check for changes to the content size category trait. You can also observe  and update the font when the notification arrives.
If you use a custom font in your app and want to let the user control the text size, you must create a scaled instance of the font in your source code. Call , passing in a reference to the custom font that’s at a point size suitable for use with . This is the default value for the Dynamic Type setting. You can use this call on the default font metrics, or you can specify a text style, such as .
```swift
guard let customFont = UIFont(name: "CustomFont-Light", size: UIFont.labelFontSize) else {
    fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
    )
}
label.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont)
label.adjustsFontForContentSizeCategory = true
```


## Selecting multiple items with a two-finger pan gesture
> https://developer.apple.com/documentation/uikit/selecting-multiple-items-with-a-two-finger-pan-gesture

### 
#### 
To enable the two-finger pan gesture in a table view, implement the delegate method , and return `true`. The table view calls this method when it detects the two-finger touch to determine whether the app supports the multiple-selection gesture.
```swift
override func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
    return true
}
```

```
After returning `true`, the table view calls the  delegate method. The sample app uses this opportunity to switch the table view into edit mode without requiring the user to tap the Edit button. The table view also selects the current row. The user pans their two fingers up or down on the table view to select additional rows.
```swift
override func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
    // Replace the Edit button with Done, and put the
    // table view into editing mode.
    self.setEditing(true, animated: true)
}
```

```
When the user lifts their two fingers off the device, the table view calls the  delegate method. This is the app’s indication that the user is no longer using the two-finger pan gesture. The sample app’s implementation of this method doesn’t perform any action, which gives the user the opportunity to select more items using the two-finger pan gesture. The user can also select more items by moving a single finger along the edge of the table where it displays the selection checkboxes.
```swift
override func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
    print("\(#function)")
}
```

#### 
Next, implement the delegate method . As with the table view delegate variant, the sample app implementation of this method puts the collection view into edit mode.
The third and last delegate method to implement is . Here the sample app doesn’t perform any action so that the user can continue selecting items with either a tap or another pan gesture using two fingers.
```swift
func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
    // Returning `true` automatically sets `collectionView.isEditing`
    // to `true`. The app sets it to `false` after the user taps the Done button.
    return true
}

func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
    // Replace the Select button with Done, and put the
    // collection view into editing mode.
    setEditing(true, animated: true)
}

func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
    print("\(#function)")
}
```


## Setting up a document browser app
> https://developer.apple.com/documentation/uikit/setting-up-a-document-browser-app

### 
#### 
#### 
4. Add the  key, and set its value to `Owner` or `Alternate`.
These entries set the  key in your app’s `Info.plist` file as shown here:
These entries set the  key in your app’s `Info.plist` file as shown here:
```xml
<key>CFBundleDocumentTypes</key>
<array>
    <dict>
        <key>CFBundleTypeIconFiles</key>
        <array/>
        <key>CFBundleTypeName</key>
        <string>Text</string>
        <key>LSHandlerRank</key>
        <string>Alternate</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>public.plain-text</string>
        </array>
    </dict>
</array>
```


## Showing and hiding view controllers
> https://developer.apple.com/documentation/uikit/showing-and-hiding-view-controllers

### 
#### 
#### 
When you call the  or  method, UIKit determines the most appropriate context for the presentation. Specifically, it calls the  method to search for a parent view controller that implements the corresponding `show` method. If a parent implements the method and wants to handle the presentation, UIKit calls the parent’s implementation. A  object’s implementation of the  method pushes the new view controller onto its navigation stack. If no view controller handles the presentation, UIKit presents the view controller modally.
The following code example creates a view controller and shows it using the  method. The code is equivalent to creating a segue with the kind set to Show.
```swift
@IBAction func showSecondViewController() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let secondVC = storyboard.instantiateViewController(identifier: "SecondViewController")

    show(secondVC, sender: self)
}
```

#### 
#### 
Use modal presentations to create temporary interruptions in your app’s workflow, such as prompting the user for important information. A modal presentation covers the current view controller wholly or partially, depending on the presentation style you use. Full-screen presentations always replace the previous content, but sheet-style presentations may leave some of the underlying content visible. The actual appearance of each presentation style depends on the current trait environment.
To configure a modal presentation, create the new view controller and call the  method. That method animates the new view controller into position using the  style and the  transition animation. To change the styles, modify the  and  properties of the view controller you present. The following code example changes both of these styles to create a full-screen presentation using a cross-dissolve animation.
```swift
    @IBAction func presentSecondViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "SecondViewController")
        
        secondVC.modalPresentationStyle = .fullScreen
        secondVC.modalTransitionStyle = .crossDissolve
        
        present(secondVC, animated: true, completion: nil)
    }
```


## Showing help tags for views and controls using tooltip interactions
> https://developer.apple.com/documentation/uikit/showing-help-tags-for-views-and-controls-using-tooltip-interactions

### 
#### 
#### 
To show a tooltip when the pointer hovers over a view, the sample creates a  object and passes in the default tooltip text. Then the sample adds the interaction to a  using the view’s  method.
```swift
lazy var viewWithDefaultTooltip: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.systemGreen
    view.addText("Hover the pointer over this view to see its default tooltip.")

    let tooltipInteraction = UIToolTipInteraction(defaultToolTip: "The default tooltip for the view.")
    view.addInteraction(tooltipInteraction)

    return view
}()
```

```
The sample uses the same approach for other types of views too, for instance, to add a tooltip to an instance of :
```swift
lazy var labelWithTooltip: UILabel = {
    let label = UILabel()
    label.text = "Hover the pointer over this label to see its tooltip."
    label.numberOfLines = 0
    
    let tooltipInteraction = UIToolTipInteraction(defaultToolTip: "The label's tooltip.")
    label.addInteraction(tooltipInteraction)
    
    return label
}()
```

#### 
For interface elements that derive from , such as , the sample uses the  property to set the default text that appears in the tooltip instead of adding an interaction to the control.
```swift
lazy var buttonWithTooltip: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.title = "Buy"
    configuration.subtitle = "Only $9.99"
    configuration.titleAlignment = .center
    
    let action = UIAction { _ in print("Thank you for your purchase.") }

    let button = UIButton(configuration: configuration, primaryAction: action)
    button.toolTip = "Click to buy this item. You'll have a chance to change your mind before confirming your purchase."
    button.preferredBehavioralStyle = .pad
    
    return button
}()
```

#### 
Setting the  property of a tooltip interaction and setting the  property of a control are convenient ways to show tooltip text that doesn’t change while the app runs. However, there may be times when an app needs to determine the contents of the tooltip based on the state of the app or logic specific to the app. For instance, the sample app looks up the name of a view’s background color and displays the name in a tooltip when the pointer hovers over that view.
To show the background color name in a tooltip, the sample creates an instance of  and sets its  property to an instance of `ViewWithBackgroundColorTooltip`, which is a custom view that conforms to the  protocol. Then the sample adds the interaction to the view.
```swift
lazy var viewWithBackgroundColorTooltip: UIView = {
    let view = ViewWithBackgroundColorTooltip()
    view.backgroundColor = UIColor.systemYellow
    view.addText("Hover the pointer over this view to see the name of the view's background color.")

    let tooltipInteraction = UIToolTipInteraction()
    tooltipInteraction.delegate = view
    view.addInteraction(tooltipInteraction)
    
    return view
}()
```

```
Next, `ViewWithBackgroundColorTooltip` implements the  method, and returns a  object that contains the name of the background color as the text of the tooltip. If the color name isn’t available, the method returns `nil`, which prevents the tooltip from displaying.
```swift
class ViewWithBackgroundColorTooltip: UIView, UIToolTipInteractionDelegate {
    
    func toolTipInteraction(_ interaction: UIToolTipInteraction, configurationAt point: CGPoint) -> UIToolTipConfiguration? {

        let configuration: UIToolTipConfiguration?
        if let accessibilityName = backgroundColor?.accessibilityName {
            configuration = UIToolTipConfiguration(toolTip: "The color is \(accessibilityName).")
        } else {
            configuration = nil
        }
        
        return configuration
    }

}
```

#### 
To change the tooltip text of a control like the sample’s shopping cart button, the sample provides a tooltip interaction delegate as it did with the custom view. But instead of creating a tooltip interaction, it sets the button’s  property to the default text. This causes the control to create a  object and assign it to the  property. The sample then uses the property to assign a delegate to the interaction.
```swift
lazy var shoppingCartButtonWithTooltip: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.title = "Add to Cart"
    configuration.image = UIImage(systemName: "cart.circle")
    configuration.imagePlacement = NSDirectionalRectEdge.leading
    configuration.imagePadding = 4
    
    let action = UIAction { [unowned self] _ in self.cartItemCount += 1 }
    
    let button = UIButton(configuration: configuration, primaryAction: action)
    button.toolTip = "Click to add the item to your cart. Your cart is empty."
    button.toolTipInteraction?.delegate = self
    
    return button
}()
```

```
The sample also implements the  delegate method, which returns a  object that contains the tooltip text describing the purpose of the button and the number of items in the shopping cart.
```swift
func toolTipInteraction(_ interaction: UIToolTipInteraction, configurationAt point: CGPoint) -> UIToolTipConfiguration? {
    
    let text: String
    switch cartItemCount {
    case 0:
        text = "Click to add the item to your cart. Your cart is empty."
    case 1:
        text = "Click to add the item to your cart. Your cart contains \(cartItemCount) item."
    default:
        text = "Click to add the item to your cart. Your cart contains \(cartItemCount) items."
    }
    
    return UIToolTipConfiguration(toolTip: text)
}
```

#### 
In addition to setting the tooltip text in a  object, a delegate can specify the region of an interface element where the pointer must hover to trigger the display of the tooltip. The sample app, for example, shows a view that displays a tooltip after positioning the pointer over the top or bottom regions of the view, but not when the pointer is over the middle area.
To determine whether the pointer location is in the top or bottom region of the view, the sample uses the `point` value that the method  provides. When the pointer is in one of those regions, the delegate method returns a tooltip configuration that contains the tooltip text and the source rectangle, which defines the area of the view that the pointer must hover over to trigger the display of the tooltip.
```swift
class ViewWithTooltipRegion: UIView, UIToolTipInteractionDelegate {

    func toolTipInteraction(_ interaction: UIToolTipInteraction, configurationAt point: CGPoint) -> UIToolTipConfiguration? {
        
        var topRect = self.bounds
        var bottomRect = self.bounds
        
        let partHeight = self.bounds.size.height / 3
        topRect.size.height = partHeight
        bottomRect.size.height = partHeight
        bottomRect.origin.y = partHeight * 2
        
        // Display the tooltip if the pointer is within the top or bottom rects.
        if topRect.contains(point) {
            return UIToolTipConfiguration(toolTip: "Top area of the view.", in: topRect)
        } else if bottomRect.contains(point) {
            return UIToolTipConfiguration(toolTip: "Bottom area of the view.", in: bottomRect)
        }
        
        // Pointer is in the middle of the view; don't display a tooltip.
        return nil
    }
    
}
```

```
In another example, the sample uses the source rectangle of a tooltip configuration to specify the region of selected text in a text view. When hovering the pointer over the selected text, a tooltip appears but it doesn’t appear when the pointer hovers over unselected text.
```swift
class TextViewWithTooltip: UITextView, UIToolTipInteractionDelegate {
    
    func toolTipInteraction(_ interaction: UIToolTipInteraction, configurationAt point: CGPoint) -> UIToolTipConfiguration? {
        
        guard
            let selectedTextRange = self.selectedTextRange,
            selectedTextRange.isEmpty == false
        else {
            return nil
        }

        var unionedRect = firstRect(for: selectedTextRange)
        for selectionRect in selectionRects(for: selectedTextRange) {
            unionedRect = unionedRect.union(selectionRect.rect)
        }
        
        if let selectedText = text(in: selectedTextRange) {
            return UIToolTipConfiguration(toolTip: "Selected text: \(selectedText)", in: unionedRect)
        }
        
        return nil
    }
    
}
```


## Supporting Dark Mode in your interface
> https://developer.apple.com/documentation/uikit/supporting-dark-mode-in-your-interface

### 
#### 
To load a color value from an asset catalog, load the color by name:
```swift
// macOS
let aColor = NSColor(named: NSColor.Name("customControlColor"))

// iOS
let aColor = UIColor(named: "customControlColor")
```

#### 
#### 
|  |  |
If you make appearance-sensitive changes outside of these methods, your app may not draw its content correctly for the current environment. The solution is to move your code into these methods. For example, instead of setting the background color of an  object’s layer at creation time, move that code to your view’s  method instead, as shown in the code example below. Setting the background color at creation time might seem appropriate, but because  objects don’t adapt, setting it at creation time leaves the view with a fixed background color that never changes. Moving your code to  refreshes that background color whenever the environment changes.
```swift
override func updateLayer() {
   self.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor

   // Other updates.
}
```

```
If your app has code that’s not part of an  and can’t use the preferred methods listed above, it can observe the app’s  property and update  manually.
```swift
// Use a property to keep a reference to the key-value observation object.
var observation: NSKeyValueObservation?

func applicationDidFinishLaunching(_ aNotification: Notification) {
    observation = NSApp.observe(\.effectiveAppearance) { (app, _) in
        app.effectiveAppearance.performAsCurrentDrawingAppearance {
            // Invoke your non-view code that needs to be aware of the
            // change in appearance.
        }
    }
}

```

#### 
#### 
#### 

## Supporting HDR images in your app
> https://developer.apple.com/documentation/uikit/supporting-hdr-images-in-your-app

### 
#### 
#### 
To turn on HDR in the SwiftUI image view, the sample uses the `allowedDynamicRange` modifier in the film strip to show limited HDR headroom.
To turn on HDR in the SwiftUI image view, the sample uses the `allowedDynamicRange` modifier in the film strip to show limited HDR headroom.
```swift
FilmStrip(assets: $assets, selectedAsset: $selectedAsset)
    .allowedDynamicRange(.constrainedHigh)
    .frame(height: geometry.size.height / 10.0)
```

​For the UIKit main image view, the sample adds the `preferredImageDynamicRange` property to the `UIImageView`. ​
```
​For the UIKit main image view, the sample adds the `preferredImageDynamicRange` property to the `UIImageView`. ​
```swift
let view = UIImageView()
view.preferredImageDynamicRange = .high
```

​ ​For AppKit, the sample adds the property to the `NSImageView`.
```
​ ​For AppKit, the sample adds the property to the `NSImageView`.
```swift
let view = NSImageView()
view.preferredImageDynamicRange = .high
```

#### 
To ensure Core Image reads Gain Map HDR images as HDR, the sample sets the `CIImageOption.expandToHDR` property to `true`. To modify the HDR image data, it uses `CIFilter` filters.
```swift
let ciOptions: [CIImageOption: Any] = [.applyOrientationProperty: true, .expandToHDR: true]
```

```
​ ​The sample saves the image to disk if it’s an on-disk file to begin with. The sample uses a `CIContext` and `CGImageDestination` to render a `CIImage` into a `CGImage` and write it to a 10-bit HEIC image file.
```swift
let cgImage = context.createCGImage(image,
                                    from: image.extent,
                                    format: .RGB10,
                                    colorSpace: colorspace ?? CGColorSpace(name: CGColorSpace.itur_2100_PQ)!,
                                    deferred: true)
```

```
​ ​The sample writes the edited HDR image data back to the Photos library by writing a 10-bit HEIC image to the `renderedContentURL` of a `PHContentEditingOutput` object. The sample only uses this path when an image comes from the Photos library using the `PhotosPicker`.
```swift
guard let outputURL = try? output.renderedContentURL(for: .heic) else {
    print("Failed to obtain HEIC output URL.")
    return nil
}
```


## Supporting VoiceOver in your app
> https://developer.apple.com/documentation/uikit/supporting-voiceover-in-your-app

### 
#### 
#### 
#### 
#### 
#### 
#### 
There are times when adding accessibility labels and hints in Xcode isn’t enough, such as when you’re working with custom UI elements that VoiceOver doesn’t automatically recognize, or if you’re using variables as part of your accessibility labels. In those situations, you need to set the accessibility labels or hints programmatically. You specify that an element is an accessibility element, and then create a corresponding accessibility label and hint.
To make your element accessible to VoiceOver programmatically, define it as an accessibility element.
```swift
score.isAccessibilityElement = true
```

```
An element’s label might not stay the same throughout the entire life cycle of your app. For example, for a counter that keeps score as you play a game, you want to change the label as the score changes. Do this programmatically by setting the accessibility label and hint.
```swift
score.accessibilityLabel = "score: \(currentScore)"
score.accessibilityHint = "Your current score" 
```

#### 
In the image above, there are four labels on the left that VoiceOver reads from the leading to the trailing edge, in this case, left-to-right. Although every element is accessible to VoiceOver, this doesn’t provide the best user experience. On the right, VoiceOver reads the grouped labels in the intended order, which allows clear navigation.
To group the labels, create a  and add the information you want to group together.
```swift
var elements = [UIAccessibilityElement]()
let groupedElement = UIAccessibilityElement(accessibilityContainer: self)
groupedElement.accessibilityLabel = "\(nameTitle.text!), \(nameValue.text!)"
groupedElement.accessibilityFrameInContainerSpace = nameTitle.frame.union(nameValue.frame)
elements.append(groupedElement)
```


## Supporting desktop-class features in your iPad app
> https://developer.apple.com/documentation/uikit/supporting-desktop-class-features-in-your-ipad-app

### 
#### 
#### 
Center item groups are groups of controls that appear in the navigation bar to provide quick access to the app’s most important capabilities. A person can customize the navigation bar’s center items by moving, removing, or adding certain groups. To enable user customization, the app assigns a string to the navigation item’s  property.
```swift
// Set a `customizationIdentifier` and add center item groups.
navigationItem.customizationIdentifier = "editorViewCustomization"
```

```
The editor view controller configures center items and assigns them to the navigation item’s  property in `configureCenterItemGroups()`. The editor view controller creates one fixed group that people can’t move or remove from the navigation bar for the Sync Scrolling item using .
```swift
UIBarButtonItem(primaryAction: UIAction(title: "Sync Scrolling", image: syncScrollingImage) { [unowned self] action in
    syncScrolling.toggle()
    if let barButtonItem = action.sender as? UIBarButtonItem {
        barButtonItem.image = syncScrollingImage
    }
}).creatingFixedGroup(),
```

```
Other center item groups are optional, which means people can customize their placement in the navigation bar. Optional groups that have `isInDefaultCustomization` set to `false` don’t appear in the navigation bar by default. They appear in the customization popover that a person can access by choosing the customization option in the overflow menu.
```swift
UIBarButtonItem(primaryAction: UIAction(title: "Strikethrough", image: UIImage(systemName: "strikethrough")) { [unowned self] _ in
    insertTag(.strikethrough)
}).creatingOptionalGroup(customizationIdentifier: "strikethrough", isInDefaultCustomization: false),
```

#### 
A title menu appears when a person taps the navigation item’s title. This menu can surface actions that are relevant to the current document. To configure a title menu, the editor view controller assigns a closure to the navigation item’s  property.
```swift
navigationItem.titleMenuProvider = { suggested in
    let custom = [
        UIMenu(title: "Export…", image: UIImage(systemName: "arrow.up.forward.square"), children: [
            UIAction(title: "HTML", image: UIImage(systemName: "safari")) { [unowned self] _ in
                previewView.exportAsWebArchive(named: document.localizedName, presenter: self)
            },
            UIAction(title: "PDF", image: UIImage(systemName: "doc.richtext")) { [unowned self] _ in
                previewView.exportAsPDF(named: document.localizedName, presenter: self)
            }
        ])
    ]
    return UIMenu(children: suggested + custom)
}
```

#### 
#### 
The editor view supports editing the content of the document. Because the editor view is a subclass of , enabling the system Find and Replace experience takes one line of code.
```swift
// Enable Find and Replace in editor text view and register as its
// delegate.
editorTextView.isFindInteractionEnabled = true
```

#### 
The outline view is a collection view that serves as a table of contents for the document, allowing for quick navigation or taking actions on the top-level tags in the document. This view supports an enhanced multiple-selection experience when a person interacts with the app using a keyboard and pointer. The outline view enables lightweight multiple selection of the tags without placing the collection view into editing mode by setting , , and  to `true`.
```swift
// Enable multiple selection.
collectionView.allowsMultipleSelection = true

// Enable keyboard focus.
collectionView.allowsFocus = true

// Allow keyboard focus to drive selection.
collectionView.selectionFollowsFocus = true
```

```
A person can use the keyboard and pointer to select tags, and perform a secondary click to open a context menu with relevant actions. The outline view presents a specialized context menu according to the number of tags in the selection by implementing  to return different configurations when the selection contains one or many tags.
```swift
if indexPaths.count > 1 {
    // Action titles for a multiple-item menu.
    hideTitle = "Hide Selected"
    deleteTitle = "Delete Selected"
} else {
    // Action titles for a single-item menu.
    hideTitle = "Hide"
    deleteTitle = "Delete"
}
```

#### 
In addition to performing a secondary click on a tag in the outline view, a person can tap a single tag to scroll to its corresponding location in the editor view. To distinguish the explicit user action of tapping one tag to navigate to that location in the document from selecting multiple tags, the outline view implements . The system calls this method when a person taps a single tag without extending a multiple selection of tags.
```swift
func collectionView(_ collectionView: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) {
    // Get the element at the `indexPath`.
    if let element = dataSource.itemIdentifier(for: indexPath) {
        delegate?.outline(self, didChoose: element)
    }

    // Wait a short amount of time before deselecting the cell for visual clarity.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
```


## Supporting gesture interaction in your apps
> https://developer.apple.com/documentation/uikit/supporting-gesture-interaction-in-your-apps

### 
#### 
To support gesture interaction on a view, create an appropriate gesture recognizer and associate it with the view by calling the  method, as shown below.
```swift
let resetGestureRecognizer = ResetGestureRecognizer(target: self, action: #selector(resetPieces(_:)))
view.addGestureRecognizer(resetGestureRecognizer)
```

#### 
This sample uses pan, pinch, and rotation gestures to move, scale, and rotate the views. When users pan a view, UIKit triggers the associated action method, which is `panPiece(_:)` in this sample, passing in a  instance that carries a translation. The method then calculates and moves the view to the new position, and clears the translation by setting it to `.zero` so next time, its value is still the delta relative to the current position.
```swift
let translation = panGestureRecognizer.translation(in: piece.superview)
piece.center = CGPoint(x: piece.center.x + translation.x, y: piece.center.y + translation.y)
panGestureRecognizer.setTranslation(.zero, in: piece.superview)
```

```
Similarly, when users pinch and rotate a view, this sample uses the  and  properties of `UIPinchGestureRecognizer` and `UIRotationGestureRecognizer` to calculate and apply a new , and then clears the properties.
```swift
let scale = pinchGestureRecognizer.scale
piece.transform = piece.transform.scaledBy(x: scale, y: scale)
pinchGestureRecognizer.scale = 1 // Clear scale so that it is the right delta next time.
```

pinchGestureRecognizer.scale = 1 // Clear scale so that it is the right delta next time.
```
```swift
piece.transform = piece.transform.rotated(by: rotationGestureRecognizer.rotation)
rotationGestureRecognizer.rotation = 0 // Clear rotation so that it is the right delta next time.
```

```
The `scale` and `rotation` properties are relative to the  property of the view’s . To be more intuitive when scaling or rotating a view, this sample moves the anchor point to the location of the gestures, which is usually the centroid of the touches involved in the gestures.
```swift
let locationInPiece = gestureRecognizer.location(in: piece)
let locationInSuperview = gestureRecognizer.location(in: piece.superview)
let anchorX = locationInPiece.x / piece.bounds.size.width
let anchorY = locationInPiece.y / piece.bounds.size.height
piece.layer.anchorPoint = CGPoint(x: anchorX, y: anchorY)
piece.center = locationInSuperview
```

#### 
Users sometimes intuitively expect multiple gestures to work simultaneously, like pinching and rotating a view at the same time. This sample allows that by implementing the following  method, which returns `true` to allow all gesture recognizers in this sample to work together.
```swift
func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                       shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
}
```

```
For the delegate method to take effect, this sample sets the gesture recognizer’s  property to `self`, which is the view controller that implements the method.
```swift
resetGestureRecognizer.delegate = self
```

#### 
This sample creates a custom gesture recognizer, `ResetGestureRecognizer`, which recognizes a gesture that contains at least three horizontal turnings. Users can use the gesture to easily reset the views to their initial state. To do that, move the views away from their initial positions, then put one finger on the area the colored views don’t cover, and move right, left, right, and left (or vice versa), like shaking the finger on the screen.
To recognize the gesture, this sample picks up a valid touch in , and gathers the touched locations in . When a user lifts their finger, which triggers , this sample counts the horizontal turnings in the touched path, and recognizes the gesture by setting the `state` property to `.ended` if the path has more than two turnings.
```swift
let count = countHorizontalTurning(touchedPoints: touchedPoints)
state = count > 2 ? .ended : .failed
```


## Supporting multiple windows on iPad
> https://developer.apple.com/documentation/uikit/supporting-multiple-windows-on-ipad

### 
#### 
#### 
#### 
This sample provides a `UIWindowScene` subclass called `SceneDelegate` to manage the app’s primary window scene. The  delegate function sets up the window and content.
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
        if !configure(window: window, with: userActivity) {
            Swift.debugPrint("Failed to restore from \(userActivity)")
        }
    }
    // The 'window' property will automatically be loaded with the storyboard's initial view controller.
    
    // Set the activation predicates, which operate on the 'targetContentIdentifier'.
    let conditions = scene.activationConditions
    let prefsPredicate = NSPredicate(format: "self == %@", mainSceneTargetContentIdentifier)
    // The main predicate, which expresses to the system what kind of content the scene can display.
    conditions.canActivateForTargetContentIdentifierPredicate = prefsPredicate
    // The secondary predicate, which expresses to the system that this scene is especially interested in a particular kind of content.
    conditions.prefersToActivateForTargetContentIdentifierPredicate = prefsPredicate
}
```

#### 
When it’s time to restore a scene, iOS calls your delegate `scene(_:willConnectTo:options:)`. The sample app restores the scene to its previous state through the use of .
```swift
func configure(window: UIWindow?, with activity: NSUserActivity) -> Bool {
    var configured = false

    guard activity.activityType == UserActivity.GalleryOpenDetailActivityType else { return configured }
    guard let navigationController = window?.rootViewController as? UINavigationController else { return configured }
        
    if let photoID = activity.userInfo?[UserActivity.GalleryOpenDetailPhotoAssetKey] as? String,
        let photoTitle = activity.userInfo?[UserActivity.GalleryOpenDetailPhotoTitleKey] as? String {
        // Restore the view controller with the 'photoID' and 'photoTitle'.
        if let photoDetailViewController = PhotoDetailViewController.loadFromStoryboard() {
            photoDetailViewController.photo = Photo(assetName: photoID, title: photoTitle)

            navigationController.pushViewController(photoDetailViewController, animated: false)
            configured = true
        }
    }
    return configured
}
```

#### 
This sample creates a separate window when the user drags an image from the collection view to the left or right side of the iPad screen. The sample creates a new window by implementing the `UICollectionViewDragDelegate` function  and providing a  with an associated . Then, the sample passes the photo data to the new window scene with a registered `NSUserActivity`.
```swift
func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    var dragItems = [UIDragItem]()
    let selectedPhoto = photos[indexPath.row]
    if let imageToDrag = UIImage(named: selectedPhoto.assetName) {
        let userActivity = selectedPhoto.detailUserActivity
        let itemProvider = NSItemProvider(object: imageToDrag)
        itemProvider.registerObject(userActivity, visibility: .all)

        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = selectedPhoto
        dragItems.append(dragItem)
    }
    return dragItems
}
```

```
The `NSUserActivity`  must be included in the app’s `Info.plist` under the  array. Without it, a separate window isn’t created as the photo is dragged to the edge of the device.
```swift
    <key>NSUserActivityTypes</key>
    <array>
        <string>com.apple.gallery.openDetail</string>
    </array>
```

#### 
- : Select a photo. Click the Info toolbar button or command-click the photo and select Inspect. Both create a new window containing that photo.
Both approaches use the following code to create a new window scene.
```swift
class func openInspectorSceneSessionForPhoto(_ photo: Photo, requestingScene: UIWindowScene, errorHandler: ((Error) -> Void)? = nil) {
    let options = UIWindowScene.ActivationRequestOptions()
    options.preferredPresentationStyle = .prominent
    options.requestingScene = requestingScene // The scene object that requested the activation of a different scene.
    
    // Present this scene as a secondary window separate from the main window.
    //
    // Look for an already open window scene session that matches the photo.
    if let foundSceneSession = InspectorSceneDelegate.activeInspectorSceneSessionForPhoto(photo.assetName) {
        // Inspector scene session already open, so activate it.
        UIApplication.shared.requestSceneSessionActivation(foundSceneSession, // Activate the found scene session.
                                                           userActivity: nil, // No need to pass activity for an already open session.
                                                           options: options,
                                                           errorHandler: errorHandler)
    } else {
        // No Inspector scene session found, so create a new one.
        let userActivity = photo.inspectorUserActivity

        UIApplication.shared.requestSceneSessionActivation(nil, // Pass nil means make a new one.
                                                           userActivity: userActivity,
                                                           options: options,
                                                           errorHandler: errorHandler)
    }
}
```

Through the use of a unique `NSUserActivity` , the app can distinguish which new scene to create in :
```
Through the use of a unique `NSUserActivity` , the app can distinguish which new scene to create in :
```swift
func application(_ application: UIApplication,
                 configurationForConnecting connectingSceneSession: UISceneSession,
                 options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // It's important that each UISceneConfiguration have a unique configuration name.
    var configurationName: String!

    switch options.userActivities.first?.activityType {
    case UserActivity.GalleryOpenInspectorActivityType:
        configurationName = "Inspector Configuration" // Create a photo inspector window scene.
    default:
        configurationName = "Default Configuration" // Create a default gallery window scene.
    }
    
    return UISceneConfiguration(name: configurationName, sessionRole: connectingSceneSession.role)
}
```


## Synchronizing documents in the iCloud environment
> https://developer.apple.com/documentation/uikit/synchronizing-documents-in-the-icloud-environment

### 
#### 
1. In the General pane of the `SimpleiCloudDocument` target, update the Bundle Identifier field with a new identifier.
5. Find the `NSUbiquitousContainers` entry in the `Info.plist` file, and change the iCloud container identifier there as well.
#### 
1. Provide the container’s metadata by adding an `NSUbiquitousContainers` entry to the `Info.plist` file like the example code below demonstrates.
3. Make sure the `Documents` folder exists in the iCloud container and has at least one document.
The `NSUbiquitousContainers` entry of the sample is as follows:
3. Make sure the `Documents` folder exists in the iCloud container and has at least one document.
The `NSUbiquitousContainers` entry of the sample is as follows:
```xml
    <key>NSUbiquitousContainers</key>
    <dict>
        <key>iCloud.com.example.apple-samplecode.SimpleiCloudDocument</key>
        <dict>
            <key>NSUbiquitousContainerIsDocumentScopePublic</key>
            <true/>
            <key>NSUbiquitousContainerName</key>
            <string>SimpleiCloudDocument</string>
            <key>NSUbiquitousContainerSupportedFolderLevels</key>
            <string>ANY</string>
        </dict>
    </dict>
```

#### 
2. Add the `LSSupportsOpeningDocumentsInPlace` key to the `Info.plist` file, and set the value to `YES`.
3. Implement the  method of the  `UISceneDelegate` protocol to accept the document.
#### 
iOS apps use  rather than file system APIs to discover documents in an iCloud container. When an app creates an iCloud document on one device, iCloud first synchronizes the document metadata to the other devices to tell them about the existence of the document. Then, depending on the device types, iCloud may or may not continue to synchronize the document data. For iOS devices, iCloud doesn’t synchronize the document data until an app asks (either explicitly or implicitly). When an iOS app receives a notification that a new document exists, the document data may not physically exist on the local file system, so it isn’t discoverable with file system APIs.
To watch the metadata changes in the iCloud container, the sample creates an `NSMetadataQuery` object. It uses the following code to configure and start the query to gather the changes of documents that are in the iCloud container and have an `.sicd` extension name.
```swift
metadataQuery.notificationBatchingInterval = 1
metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDataScope, NSMetadataQueryUbiquitousDocumentsScope]
metadataQuery.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, "*." + Document.extensionName)
metadataQuery.sortDescriptors = [NSSortDescriptor(key: NSMetadataItemFSNameKey, ascending: true)]
metadataQuery.start()
```

```
A query has two phases when gathering the metadata: the initial phase that collects all currently matching results, and a second phase that gathers live updates. It posts an  notification when it finishes the first phase, and an  notification each time an update occurs. To avoid potential conflicts with the system, disable the query update when accessing the results, and enable it after finishing the access, as the following example shows:
```swift
func metadataItemList() -> [MetadataItem] {
    var result = [MetadataItem]()
    metadataQuery.disableUpdates()
    if let metadataItems = metadataQuery.results as? [NSMetadataItem] {
        result = metadataItemList(from: metadataItems)
    }
    metadataQuery.enableUpdates()
    return result
}
```

#### 
Documents in this sample could potentially contain many images, and the images might be large. To load image data only when necessary, and release the data immediately after using it, the `Document` class provides public methods for directly accessing the images in the document package. As an example, the following method retrieves a full image asynchronously:
```swift
func retrieveImageAsynchronously(with imageName: String, completionHandler: @escaping (UIImage?) -> Void) {
    performAsynchronousFileAccess {
        let imageFileURL = self.fileURL.appendingPathComponent(imageName)
        let fileCoordinator = NSFileCoordinator(filePresenter: self)
        fileCoordinator.coordinate(readingItemAt: imageFileURL, options: .withoutChanges, error: nil) { newURL in
            if let imageData = try? Data(contentsOf: newURL), let image = UIImage(data: imageData) {
                completionHandler(image)
            } else {
                completionHandler(nil)
            }
        }
    }
}
```

When directly manipulating the files in the document package, the sample calls the  method to serialize the file access in the background queue, and uses  to coordinate the reading or writing.
Likewise, to avoid the default implementation that loads image data to  objects and keeps it in memory, the sample overrides the  method to directly remove or add image files when updating a document.
```swift
override func save(to url: URL, for saveOperation: UIDocument.SaveOperation, completionHandler: ((Bool) -> Void)? = nil) {
    if saveOperation != .forCreating {
        print("\(#function)")
        return performAsynchronousFileAccess {
            let fileCoordinator = NSFileCoordinator(filePresenter: self)
            fileCoordinator.coordinate(writingItemAt: self.fileURL, options: .forMerging, error: nil) { newURL in
                let success = self.fulfillUnsavedChanges()
                self.fileModificationDate = Date()
                if let completionHandler = completionHandler {
                    DispatchQueue.main.async {
                        completionHandler(success)
                    }
                }
            }
        }
    }
    super.save(to: url, for: saveOperation, completionHandler: completionHandler)
}
```

#### 
Handling version conflicts in document-based apps is straightforward because `UIDocument` does most of the heavy lifting. When a conflict occurs, `UIDocument` detects it and posts a  notification, which apps can observe and then implement their conflict resolution strategy.
The sample resolves a conflict by selecting the version that has the most recent  and removing all others. It uses file coordination to assess the version information of an iCloud document to avoid potential conflicts with the system.
```swift
private func resolveConflictsAsynchronously(document: Document, completionHandler: ((Bool) -> Void)?) {
    DispatchQueue.global().async {
        NSFileCoordinator().coordinate(writingItemAt: document.fileURL,
                                       options: .contentIndependentMetadataOnly, error: nil) { newURL in
            let shouldRevert = self.pickLatestVersion(for: newURL)
            completionHandler?(shouldRevert)
        }
    }
}
```


## UIKit Catalog: Creating and customizing views and controls
> https://developer.apple.com/documentation/uikit/uikit-catalog-creating-and-customizing-views-and-controls

### 
#### 
#### 
You can customize the appearance and behavior of a UIButton by using `UIButton.Configuration`. This sample uses a `filled()` configuration so that the button draws with a red background color:
```swift
var config = UIButton.Configuration.filled()
config.background.backgroundColor = .systemRed
button.configuration = config
```

#### 
2. Create and configure a `UIAlertController` object.
4. Present the alert controller.
The `showSimpleAlert` function uses the `NSLocalizedString` function to retrieve the alert messages in the user’s preferred language. The `showSimpleAlert` function uses those strings to create and configure the `UIAlertController` object. Although the button in the alert has the title OK, the sample uses a cancel action to ensure that the alert controller applies the proper styling to the button:
```swift
func showSimpleAlert() {
    let title = NSLocalizedString("A Short Title is Best", comment: "")
    let message = NSLocalizedString("A message needs to be a short, complete sentence.", comment: "")
    let cancelButtonTitle = NSLocalizedString("OK", comment: "")

    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    // Create the action.
    let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
        Swift.debugPrint("The simple alert's cancel action occurred.")
    }

    // Add the action.
    alertController.addAction(cancelAction)

    present(alertController, animated: true, completion: nil)
}
```

#### 
The `configureCustomSlider` function sets up a custom slider:
This sample demonstrates different ways to display a `UISlider`, a control to select a single value from a continuous range of values. Customize the appearance of a slider by assigning stretchable images for left-side tracking, right-side tracking, and the thumb. In this example, the track image is stretchable and is one pixel wide. Make the track images wider to provide rounded corners, but be sure to set these images’ `capInsets` property to allow for the corners.
The `configureCustomSlider` function sets up a custom slider:
```swift
@available(iOS 15.0, *)
func configureCustomSlider(slider: UISlider) {
    /** To keep the look the same betwen iOS and macOS:
        For setMinimumTrackImage, setMaximumTrackImage, setThumbImage to work in Mac Catalyst, use UIBehavioralStyle as ".pad",
        Available in macOS 12 or later (Mac Catalyst 15.0 or later).
        Use this for controls that need to look the same between iOS and macOS.
    */
    if traitCollection.userInterfaceIdiom == .mac {
        slider.preferredBehavioralStyle = .pad
    }
    
    let leftTrackImage = UIImage(named: "slider_blue_track")
    slider.setMinimumTrackImage(leftTrackImage, for: .normal)

    let rightTrackImage = UIImage(named: "slider_green_track")
    slider.setMaximumTrackImage(rightTrackImage, for: .normal)

    // Set the sliding thumb image (normal and highlighted).
    //
    // For fun, choose a different image symbol configuraton for the thumb's image between macOS and iOS.
    var thumbImageConfig: UIImage.SymbolConfiguration
    if slider.traitCollection.userInterfaceIdiom == .mac {
        thumbImageConfig = UIImage.SymbolConfiguration(scale: .large)
    } else {
        thumbImageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .heavy, scale: .large)
    }
    let thumbImage = UIImage(systemName: "circle.fill", withConfiguration: thumbImageConfig)
    slider.setThumbImage(thumbImage, for: .normal)
    
    let thumbImageHighlighted = UIImage(systemName: "circle", withConfiguration: thumbImageConfig)
    slider.setThumbImage(thumbImageHighlighted, for: .highlighted)

    // Set the rest of the slider's attributes.
    slider.minimumValue = 0
    slider.maximumValue = 100
    slider.isContinuous = false
    slider.value = 84

    slider.addTarget(self, action: #selector(SliderViewController.sliderValueDidChange(_:)), for: .valueChanged)
}
```

#### 
Use a `UISearchBar` to receive search-related information from the user. There are various ways to customize the look of the search bar:
The `configureSearchBar` function sets up a custom search bar:
- Set the search bar’s background image.
The `configureSearchBar` function sets up a custom search bar:
```swift
func configureSearchBar() {
    searchBar.showsCancelButton = true
    searchBar.showsBookmarkButton = true

    searchBar.tintColor = UIColor.systemPurple

    searchBar.backgroundImage = UIImage(named: "search_bar_background")

    // Set the bookmark image for both normal and highlighted states.
    let bookImage = UIImage(systemName: "bookmark")
    searchBar.setImage(bookImage, for: .bookmark, state: .normal)

    let bookFillImage = UIImage(systemName: "bookmark.fill")
    searchBar.setImage(bookFillImage, for: .bookmark, state: .highlighted)
}
```

#### 
The following `viewDidLoad` function in `CustomToolbarViewController` sets up a tinted tool bar:
This sample shows how to customize a `UIToolbar`, a specialized view that displays one or more buttons along the bottom edge of an interface. Customize a toolbar by determining its bar style (black or default), translucency, tint color, and background color.
The following `viewDidLoad` function in `CustomToolbarViewController` sets up a tinted tool bar:
```swift
override func viewDidLoad() {
    super.viewDidLoad()

    // See the `UIBarStyle` enum for more styles, including `.Default`.
    toolbar.barStyle = .black
    toolbar.isTranslucent = false

    toolbar.tintColor = UIColor.systemGreen
    toolbar.backgroundColor = UIColor.systemBlue

    let toolbarButtonItems = [
        refreshBarButtonItem,
        flexibleSpaceBarButtonItem,
        actionBarButtonItem
    ]
    toolbar.setItems(toolbarButtonItems, animated: true)
}
```

`CustomToolbarViewController` demonstrates further customization by changing the toolbar’s background image:
```
`CustomToolbarViewController` demonstrates further customization by changing the toolbar’s background image:
```swift
override func viewDidLoad() {
    super.viewDidLoad()

    let toolbarBackgroundImage = UIImage(named: "toolbar_background")
    toolbar.setBackgroundImage(toolbarBackgroundImage, forToolbarPosition: .bottom, barMetrics: .default)

    let toolbarButtonItems = [
        customImageBarButtonItem,
        flexibleSpaceBarButtonItem,
        customBarButtonItem
    ]
    toolbar.setItems(toolbarButtonItems, animated: true)
}
```

#### 
The `configurePageControl` function sets up a customized page control:
Use a `UIPageControl` to structure an app’s user interface. A  is a specialized control that displays a horizontal series of dots, each of which corresponds to a page in the app’s document or other data-model entity. Customize a page control by setting its tint color for all the page-indicator dots, and for the current page-indicator dot.
The `configurePageControl` function sets up a customized page control:
```swift
func configurePageControl() {
    // The total number of available pages is based on the number of available colors.
    pageControl.numberOfPages = colors.count
    pageControl.currentPage = 2

    pageControl.pageIndicatorTintColor = UIColor.systemGreen
    pageControl.currentPageIndicatorTintColor = UIColor.systemPurple
    
    pageControl.addTarget(self, action: #selector(PageControlViewController.pageControlValueDidChange), for: .valueChanged)
}
```

#### 
Attach a menu to a `UIButton` as shown here:
Attach menus to controls like `UIButton` and `UIBarButtonItem`. Create menus with the  class, and attach a menu to each control by setting the  property.
Attach a menu to a `UIButton` as shown here:
```swift
button.menu = UIMenu(children: [
    UIAction(title: String(format: NSLocalizedString("ItemTitle", comment: ""), "1"),
             identifier: UIAction.Identifier(ButtonMenuActionIdentifiers.item1.rawValue),
             handler: menuHandler),
    UIAction(title: String(format: NSLocalizedString("ItemTitle", comment: ""), "2"),
             identifier: UIAction.Identifier(ButtonMenuActionIdentifiers.item2.rawValue),
             handler: menuHandler)
])

button.showsMenuAsPrimaryAction = true
```

Create a `UIBarButtonItem` with a menu attached as shown here:
```
Create a `UIBarButtonItem` with a menu attached as shown here:
```swift
var customTitleBarButtonItem: UIBarButtonItem {
    let buttonMenu = UIMenu(title: "",
                            children: (1...5).map {
                               UIAction(title: "Option \($0)", handler: menuHandler)
                            })
    return UIBarButtonItem(image: UIImage(systemName: "list.number"), menu: buttonMenu)
}
```

#### 
VoiceOver and other system accessibility technologies use the information provided by views and controls to help all users navigate content. UIKit views include default accessibility support. Improve user experience by providing custom accessibility information.
In this UIKitCatalog sample, several view controllers configure the `accessibilityType` and `accessibilityLabel` properties of their associated view. Picker view columns don’t have labels, so the picker view asks its delegate for the corresponding accessibility information:
```swift
func pickerView(_ pickerView: UIPickerView, accessibilityLabelForComponent component: Int) -> String? {
    
    switch ColorComponent(rawValue: component)! {
    case .red:
        return NSLocalizedString("Red color component value", comment: "")

    case .green:
        return NSLocalizedString("Green color component value", comment: "")

    case .blue:
        return NSLocalizedString("Blue color component value", comment: "")
    }
}
```

#### 

## Updating collection views using diffable data sources
> https://developer.apple.com/documentation/uikit/updating-collection-views-using-diffable-data-sources

### 
#### 
In this sample project, `RecipeListViewController` displays a list of recipes in a collection view. Before the controller can display the recipes, it defines an instance variable to store a diffable data source.
```swift
private var recipeListDataSource: UICollectionViewDiffableDataSource<RecipeListSection, Recipe.ID>!
```

`RecipeListViewController` declares `recipeListDataSource` with `RecipeListSection` as the section identifier type, and `Recipe.ID` as the item identifier type. These identifier types tell the data source the type of values it contains.
For the section identifier type, `recipeListDataSource` uses `RecipeListSection`, an enumeration with a raw value of type  (in Swift, `Int` is hashable). Each enumeration case identifies a section of the collection view. In the sample, there’s only one section, `main`, which displays a list of recipes.
```swift
private enum RecipeListSection: Int {
    case main
}
```

For the item identifier type, `recipeListDataSource` uses `Recipe.ID`. This type comes from the `Recipe` structure, defined as:
```
For the item identifier type, `recipeListDataSource` uses `Recipe.ID`. This type comes from the `Recipe` structure, defined as:
```swift
struct Recipe: Identifiable, Codable {
    var id: Int
    var title: String
    var prepTime: Int   // In seconds.
    var cookTime: Int   // In seconds.
    var servings: String
    var ingredients: String
    var directions: String
    var isFavorite: Bool
    var collections: [String]
    fileprivate var addedOn: Date? = Date()
    fileprivate var imageNames: [String]
}
```

#### 
Next, `configureDataSource()` creates an instance of  and defines the cell provider closure. The closure receives the identifier of a recipe. It then retrieves the recipe from the backing data store (using the identifier) and passes the recipe structure to the cell registration’s handler closure.
```swift
private func configureDataSource() {
    // Create a cell registration that the diffable data source will use.
    let recipeCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Recipe> { cell, indexPath, recipe in
        var contentConfiguration = UIListContentConfiguration.subtitleCell()
        contentConfiguration.text = recipe.title
        contentConfiguration.secondaryText = recipe.subtitle
        contentConfiguration.image = recipe.smallImage
        contentConfiguration.imageProperties.cornerRadius = 4
        contentConfiguration.imageProperties.maximumSize = CGSize(width: 60, height: 60)
        
        cell.contentConfiguration = contentConfiguration
        
        if recipe.isFavorite {
            let image = UIImage(systemName: "heart.fill")
            let accessoryConfiguration = UICellAccessory.CustomViewConfiguration(customView: UIImageView(image: image),
                                                                                 placement: .trailing(displayed: .always),
                                                                                 tintColor: .secondaryLabel)
            cell.accessories = [.customView(configuration: accessoryConfiguration)]
        } else {
            cell.accessories = []
        }
    }

    // Create the diffable data source and its cell provider.
    recipeListDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
        collectionView, indexPath, identifier -> UICollectionViewCell in
        // `identifier` is an instance of `Recipe.ID`. Use it to
        // retrieve the recipe from the backing data store.
        let recipe = dataStore.recipe(with: identifier)!
        return collectionView.dequeueConfiguredReusableCell(using: recipeCellRegistration, for: indexPath, item: recipe)
    }
}
```

#### 
With the diffable data source configured, `RecipeListViewController` calls its helper method `loadRecipeData()` to perform an initial load of data into the data source, which in turn populates a collection view with recipes. This method retrieves a list of recipe identifiers and creates an instance of  . Then it adds the `main` section and recipe identifiers to the snapshot. Lastly, the method calls  to apply the snapshot to the data source, resetting the collection view to reflect the state of the data in the snapshot without computing a diff or animating the changes.
```swift
private func loadRecipeData() {
    // Retrieve the list of recipe identifiers determined based on a
    // selected sidebar item such as All Recipes or Favorites.
    guard let recipeIds = recipeSplitViewController.selectedRecipes?.recipeIds()
    else { return }
    
    // Update the collection view by adding the recipe identifiers to
    // a new snapshot, and apply the snapshop to the diffable data source.
    var snapshot = NSDiffableDataSourceSnapshot<RecipeListSection, Recipe.ID>()
    snapshot.appendSections([.main])
    snapshot.appendItems(recipeIds, toSection: .main)
    recipeListDataSource.applySnapshotUsingReloadData(snapshot)
}
```

#### 
To inform other parts of the app that the list of recipes changed — for instance, after someone adds or removes a recipe — the sample uses a notification center to send a `selectedRecipesDidChange` notification. To receive the notification, `RecipeListViewController` adds a notification observer with `selectedRecipesDidChange(_:)` as its selector.
```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(selectedRecipesDidChange(_:)),
    name: .selectedRecipesDidChange,
    object: nil
)
```

```
`selectedRecipesDidChange(_:)` is similar to `loadRecipeData()` but it uses  to apply the list of selected recipe identifiers that the notification provides instead of using . The  method performs incremental updates to the collection view instead of entirely resetting the data displayed. And because `animatingDifferences` is `true`, the collection view animates the changes as they appear.
```swift
@objc
private func selectedRecipesDidChange(_ notification: Notification) {
    // Create a snapshot of the selected recipe identifiers from the notification's
    // `userInfo` dictionary, and apply it to the diffable data source.
    guard
        let userInfo = notification.userInfo,
        let selectedRecipeIds = userInfo[NotificationKeys.selectedRecipeIds] as? [Recipe.ID]
    else { return }
    
    var snapshot = NSDiffableDataSourceSnapshot<RecipeListSection, Recipe.ID>()
    snapshot.appendSections([.main])
    snapshot.appendItems(selectedRecipeIds, toSection: .main)
    recipeListDataSource.apply(snapshot, animatingDifferences: true)

    // The design of this sample app makes it possible for the selected
    // recipe displayed in the secondary (detail) view controller to exist
    // in the new snapshot but not exist in the collection view prior to
    // applying the snapshot. For instance, while displaying the list of
    // favorite recipes, a person can unfavorite the selected recipe by tapping
    // the `isFavorite` button. This removes the selected recipe from the
    // favorites list. Tap the button again and the recipe reappears in the
    // list. In this scenario, the app needs to re-select the recipe so it
    // appears as selected in the collection view.
    selectRecipeIfNeeded()
}
```

#### 
Again, the app, not the diffable data source, detects the data changes.
To tell others parts of the app about a change to a recipe — for instance, when a person marks a recipe as a favorite — the sample sends a `recipeDidChange` notification. `RecipeListViewController` receives the notification using an observer with `recipeDidChange(_:)` as the selector.
```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(recipeDidChange(_:)),
    name: .recipeDidChange,
    object: nil
)
```

The `recipeDidChange` notification indicates that data for a single recipe changed. Because only one recipe changed, there’s no need to update the entire list of recipes shown in the collection view. Instead, the sample only updates the cell that displays the recipe that changed. For instance, when a person marks a recipe as a favorite, an icon of a heart appears beside that recipe. And when the person unmarks the recipe as a favorite, the heart disappears.
To update the cell with the latest recipe data, the `recipeDidChange(_:)` method confirms that the diffable data source contains the recipe identifier that the notification provides. Then the method retrieves the current snapshot from the data source and calls , passing in the recipe identifier. This call tells the data source to update the data displayed in the cell identified by the recipe identifier. Finally, `recipeDidChange(_:)` applies the updated snapshot to the data source.
```swift
@objc
private func recipeDidChange(_ notification: Notification) {
    guard
        // Get `recipeId` from from the `userInfo` dictionary.
        let userInfo = notification.userInfo,
        let recipeId = userInfo[NotificationKeys.recipeId] as? Recipe.ID,
        // Confirm that the data source contains the recipe.
        recipeListDataSource.indexPath(for: recipeId) != nil
    else { return }
    
    // Get the diffable data source's current snapshot.
    var snapshot = recipeListDataSource.snapshot()
    // Update the recipe's data displayed in the collection view.
    snapshot.reconfigureItems([recipeId])
    recipeListDataSource.apply(snapshot, animatingDifferences: true)
}
```

#### 
An alternative approach to storing identifiers involves populating diffable data sources and snapshots with lightweight data structures. While the data structure approach is convenient and can be a good fit in some circumstances — like for quick prototyping, or displaying a collection of static items with properties that don’t change — it carries significant limitations and tradeoffs. For instance, the  and  implementations must incorporate all properties of the structure that can change. Any changes to the data in the structure cause it to no longer be equal to the previous version, which the diffable data source uses to determine what changed when applying a new snapshot.
The sample uses this approach to show items in a sidebar. In `SidebarViewController`, the custom structure `SidebarItem` defines the properties of a sidebar item, which are `title` and `type`.
```swift
private struct SidebarItem: Hashable {
    let title: String
    let type: SidebarItemType
    
    enum SidebarItemType {
        case standard, collection, expandableHeader
    }
}
```

```
The combination of these properties determine the hashing value for each sidebar item, and because the property values don’t change, populating the snapshot with this `SidebarItem` structure instead of identifiers is an acceptable use case.
```swift
private func createSnapshotOfStandardItems() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
    let items = [
        SidebarItem(title: StandardSidebarItem.all.rawValue, type: .standard),
        SidebarItem(title: StandardSidebarItem.favorites.rawValue, type: .standard),
        SidebarItem(title: StandardSidebarItem.recents.rawValue, type: .standard)
    ]
    return createSidebarItemSnapshot(.standardItems, items: items)
}
```


## Updating data structures
> https://developer.apple.com/documentation/uikit/updating-data-structures

### 
#### 
As a result of the increased size of the 64-bit architecture, the alignment of all 64-bit integer types in the runtime changes from 4 bytes to 8 bytes. Even if you specify each integer type explicitly, the two structures may still not be identical in both runtimes. This is important to know if you have data that was created by the 32-bit version of your app that you need to read in the 64-bit version.
In the following code, the alignment changes even though the fields are declared with explicit integer types.
```objc
struct bar {
    int32_t foo0;
    int32_t foo1;
    int32_t foo2;
    int64_t bar;
};
```

If you’re defining a new data structure, organize the elements with the largest alignment values first and the smallest values last. This organization eliminates the need for most padding bytes. If you’re working with an existing structure that includes misaligned 64-bit integers, you can use a pragma to force the proper alignment. The following code shows the same data structure, but here it’s forced to use the 32-bit alignment rules.
```objc
#pragma pack(4)
struct bar {
    int32_t foo0;
    int32_t foo1;
    int32_t foo2;
    int64_t bar;
};
#pragma options align=reset
```

#### 
| `int16_t` | -32,768 to 32,767 |
| `int32_t` | -2,147,483,648 to 2,147,483,647 |
| `int64_t` | -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807 |
| `uint8_t` | 0 to 255 |
| `uint16_t` | 0 to 65,535 |
| `uint32_t` | 0 to 4,294,967,295 |
| `uint64_t` | 0 to 18,446,744,073,709,551,615 |
#### 
Inconsistent use of data types in your code can truncate results of computation and provide incorrect results. Even though the compiler warns you of many problems that result from inconsistent data types, it’s also useful to see a few variations of these patterns so that you can recognize them in your code.
When calling a function, always match the variable that receives the results to the function’s return type. If the return type is a larger integer than the receiving variable, the value is truncated. The following code shows a simple pattern that exhibits this problem.
```objc
long PerformCalculation(void);

int  x = PerformCalculation(); // Incorrect.

long y = PerformCalculation(); // Correct.
```

The `PerformCalculation` function returns a long integer. In the 32-bit runtime, both `int` and `long` are 32 bits, so the assignment to an `int` type works, even though the code is incorrect. In the 64-bit runtime, the upper 32 bits of the result are lost when the assignment is made. Instead, the result should be assigned to a long integer; this approach works consistently in both runtimes.
The same problem occurs when you pass in a value as a parameter. Here, the input parameter is truncated when executed in the 64-bit runtime.
```objc
int PerformAnotherCalculation(int input);

long i = LONG_MAX;

int x = PerformCalculation(i);
```

```
In the following code, the return value is also truncated in the 64-bit runtime, because the value returned exceeds the range of the function’s return type.
```objc
int ReturnMax()
{
    return LONG_MAX;
}
```

#### 
#### 
- Working with constants defined in the framework as `NSInteger`. Of particular note is the `NSNotFound` constant. In the 64-bit runtime, its value is larger than the maximum range of an `int` type, so truncating its value often causes errors in your app.
Don’t assume the size of `CGFloat`. As a result of the conversion, the `CGFloat` type changes to a 64-bit floating-point number. As with the `NSInteger` type, you can’t assume that `CGFloat` is a `float` or a `double`, so use it consistently. The following code shows an example that uses Core Foundation to create a `CFNumber:`
```objc
// Incorrect.
CGFloat value = 200.0;
CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &value);

// Correct.
CGFloat value = 200.0;
CFNumberCreate(kCFAllocatorDefault, kCFNumberCGFloatType, &value);
```


## Updating views automatically with observation tracking
> https://developer.apple.com/documentation/uikit/updating-views-automatically-with-observation-tracking

### 
#### 
The  method automatically tracks `Observable` properties and updates views when they change. For example, to show a message list with a status label that displays unread message information, start by creating an `Observable` model with the properties your view needs:
```swift
@Observable
class MessageModel {
    var showStatus: Bool
    var statusText: String
}
```

Then, use these properties in your view controller’s `updateProperties()` method:
```
Then, use these properties in your view controller’s `updateProperties()` method:
```swift
override func updateProperties() {
    super.updateProperties()
    statusLabel.alpha = model.showStatus ? 1.0 : 0.0
    statusLabel.text = model.statusText
}
```

#### 
Collection view and table view cells also support automatic observation tracking through their configuration update handler. For example, to show a list where each cell displays information from an `Observable` model, start by creating an `Observable` model for your list items:
```swift
@Observable
class ListItemModel {
    var icon: UIImage?
    var title: String
    var subtitle: String
}
```

```
Then, in your cell provider, set up the configuration update handler to use the model:
```swift
cell.configurationUpdateHandler = { cell, state in
    var config = UIListContentConfiguration.cell()
    config.image = model.icon
    config.text = model.title
    config.secondaryText = model.subtitle
    cell.contentConfiguration = config
}
```

#### 
Use `updateProperties()` for configuring content and styling, such as putting text in labels and adjusting colors based on data. Reserve `layoutSubviews()` for geometry calculations, such as setting a frame for a view when using Auto Layout constraints doesn’t work for your situation. This separation improves performance by avoiding unnecessary layout passes.
The following example shows a badge view that updates its count without triggering layout:
```swift
override func updateProperties() {
    super.updateProperties()
    badgeItem.badge = "\(model.count)"
}
```

#### 
2. UIKit runs `updateProperties()` if necessary, where you configure properties and styling.
3. UIKit runs `layoutSubviews()` if necessary, where you calculate geometry and positioning.

## Using background tasks to update your app
> https://developer.apple.com/documentation/uikit/using-background-tasks-to-update-your-app

### 
#### 
In iOS 13 and later, adding a  key to the `Info.plist` disables the  and  methods.
#### 
The following code registers a handler, `handleAppRefresh(task:)`, that’s called when the system runs a task request with the identifier `com.example.apple-samplecode.ColorFeed.refresh`.
```swift
BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.apple-samplecode.ColorFeed.refresh", using: nil) { task in
     self.handleAppRefresh(task: task as! BGAppRefreshTask)
}
```

To submit a task request for the system to launch your app in the background at a later time, use . When you resubmit a task, the new submission replaces the previous submission.
The code below schedules a refresh task request for the task identifier `com.example.apple-samplecode.ColorFeed.refresh` that you previously registered.
```swift
func scheduleAppRefresh() {
   let request = BGAppRefreshTaskRequest(identifier: "com.example.apple-samplecode.ColorFeed.refresh")
   // Fetch no earlier than 15 minutes from now.
   request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
   do {
      try BGTaskScheduler.shared.submit(request)
   } catch {
      print("Could not schedule app refresh: \(error)")
   }
}
```

When the system opens your app in the background, it calls the launch handler to run the task.
Your task provides an expiration handler that the system calls if it needs to terminate your task. You also add code to inform the system if the task completes successfully.
```swift
func handleAppRefresh(task: BGAppRefreshTask) {
   // Schedule a new refresh task.
   scheduleAppRefresh()

   // Create an operation that performs the main part of the background task.
   let operation = RefreshAppContentsOperation()
   
   // Provide the background task with an expiration handler that cancels the operation.
   task.expirationHandler = {
      operation.cancel()
   }

   // Inform the system that the background task is complete
   // when the operation completes.
   operation.completionBlock = {
      task.setTaskCompleted(success: !operation.isCancelled)
   }

   // Start the operation.
   operationQueue.addOperation(operation)
 }
```


## Using suggested searches with a search controller
> https://developer.apple.com/documentation/uikit/using-suggested-searches-with-a-search-controller

### 
#### 
The `MainTableViewController`, a subclass of , creates the search controller. The search controller’s search bar helps filter a set of `Product` objects and displays the results in the table view. The sample places the search controller in the `MainTableViewController's` navigation bar:
```swift
searchController = UISearchController(searchResultsController: resultsTableController)
searchController.searchResultsUpdater = self
searchController.searchBar.autocapitalizationType = .none
searchController.searchBar.searchTextField.placeholder = NSLocalizedString("Enter a search term", comment: "")
searchController.searchBar.returnKeyType = .done

// Place the search bar in the navigation bar.
navigationItem.searchController = searchController
    
// Make the search bar always visible.
navigationItem.hidesSearchBarWhenScrolling = false

// Monitor when the search controller is presented and dismissed.
searchController.delegate = self

// Monitor when the search button is tapped, and start/end editing.
searchController.searchBar.delegate = self
```

#### 
The list of suggested searches is displayed by the results controller once the search bar is tapped:
```swift
   func presentSearchController(_ searchController: UISearchController) {
       searchController.showsSearchResultsController = true
       setToSuggestedSearches()
}
```

The sample creates a `UISearchToken` as follows:
When the user first taps the search bar, the search results controller displays the suggested searches. The user chooses a suggested search, and then types additional search criteria in the search bar. Each suggested search represents a , a visual representation of a search query. Tapping a suggested search creates a search token for a particular color and the search controller places it in the search bar’s text field. This text field is represented by  which supports cut, copy, paste, and drag and drop of search tokens. Tokens always precede the text and can be selected and deleted by the user.
The sample creates a `UISearchToken` as follows:
```swift
class func searchToken(tokenValue: Int) -> UISearchToken {
    let tokenColor = ResultsTableController.suggestedColor(fromIndex: tokenValue)
    let image =
        UIImage(systemName: "circle.fill")?.withTintColor(tokenColor, renderingMode: .alwaysOriginal)
    let searchToken = UISearchToken(icon: image, text: suggestedTitle(fromIndex: tokenValue))
    
    // Set the color kind number as the token value.
    let color = ResultsTableController.colorKind(fromIndex: tokenValue).rawValue
    searchToken.representedObject = NSNumber(value: color)
    
    return searchToken
}
```

```
This sample inserts the search token into the search bar’s search text field as follows:
```swift
if let searchField = navigationItem.searchController?.searchBar.searchTextField {
    searchField.insertToken(token, at: 0)
    
    // Hide the suggested searches now that we have a token.
    resultsTableController.showSuggestedSearches = false
    
    // Update the search query with the newly inserted token.
    updateSearchResults(for: searchController)
}
```


## Verifying mathematical calculations
> https://developer.apple.com/documentation/uikit/verifying-mathematical-calculations

### 
#### 
3. Constants (unless modified by a suffix, such as `0x8L`) are treated as the smallest size that will hold the value. Hexadecimal numbers may be treated by the compiler as `int`, `long`, and `long long` types and may be either `signed` or `unsigned` types. Decimal numbers are always treated as `signed` types.
4. The sum of a signed value and an unsigned value of the same size is an unsigned value.
```objc
int a = -2;
unsigned int b = 1;
long c = a + b;
long long d = c; // To get a consistent size for printing.

printf("%lld\n", d);
```

To understand why this happens, consider that when these numbers are added, the signed value plus the unsigned value results in an unsigned value (rule 4). That result is promoted to a larger type, but this promotion doesn’t cause sign extension.
To fix this problem, cast `b` to a `long` integer. This cast forces the non-sign-extended promotion of `b` to a 64-bit type before the addition operation, thus forcing the signed integer to be promoted (in a signed fashion) to match. With that change, the result is the expected -1.
```objc
unsigned short a = 1;
unsigned long b = (a << 31);
unsigned long long c = b;

printf("%llx\n", c);
```

#### 
- If you want the bit mask value to contain zeros in the upper 32 bits in the 64-bit runtime, the usual fixed-width bit mask works as expected, because it’s extended in an unsigned fashion to a 64-bit quantity.
- If you want the bit mask value to contain ones in the upper bits, write the bit mask as the bitwise inverse of its inverse.
```objc
long function_name(long value)
{
    // Use the complement (~) operator to get ones instead of zeros.
    // Mask will be 0xfffffffc in the 32-bit runtime,
    //   or 0xfffffffffffffffc in the 64-bit runtime.
    long mask = ~0x3;
    return (value & mask);
}
```


