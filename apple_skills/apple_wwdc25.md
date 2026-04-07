# WWDC25 — Apple 新特性
> 来源：developer.apple.com/documentation/updates/wwdc2025


---
# TECHNOLOGYOVERVIEWS

## Adopting Liquid Glass
> https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass

### 
If you have an existing app, adopting Liquid Glass doesn’t mean reinventing your app from the ground up. Start by building your app in the latest version of Xcode to see the changes. As you review your app, use the following sections to understand the scope of changes and learn how you can adopt these best practices in your interface.


##### 
If your app uses standard components from SwiftUI, UIKit, or AppKit, your interface picks up the latest look and feel on the latest platform releases for iOS, iPadOS, macOS, tvOS, and watchOS. In Xcode, build your app with the latest SDKs, and run it on the latest platform releases to see the changes in your interface.

### 
Interfaces across Apple platforms feature a new dynamic  called Liquid Glass, which combines the optical properties of glass with a sense of fluidity. This material forms a distinct functional layer for controls and navigation elements. It affects how the interface looks, feels, and moves, adapting in response to a variety of factors to help bring focus to the underlying content.
 In system frameworks, standard components like bars, sheets, popovers, and controls automatically adopt this material. System frameworks also dynamically adapt these components in response to factors like element overlap and focus state. Take advantage of this material with minimal code by using standard components from SwiftUI, UIKit, and AppKit.
 Any custom backgrounds and appearances you use in these elements might overlay or interfere with Liquid Glass or other effects that the system provides, such as the scroll edge effect. Make sure to check any custom backgrounds in elements like split views, tab bars, and toolbars. Prefer to remove custom effects and let the system determine the background appearance, especially for the following elements:
 Translucency and fluid morphing animations contribute to the look and feel of Liquid Glass, but can adapt to people’s needs. For example, people can choose a preferred look for Liquid Glass in their device’s settings, or turn on accessibility settings that reduce transparency or motion in the interface. These settings can remove or modify certain effects. If you use standard components from system frameworks, this experience adapts automatically. Ensure you test your app’s custom elements, colors, and animations with different configurations of these settings.
 If you apply Liquid Glass effects to a custom control, do so sparingly. Liquid Glass seeks to bring attention to the underlying content, and overusing this material in multiple custom controls can provide a subpar user experience by distracting from that content. Limit these effects to the most important functional elements in your app. To learn more, read .

### 
 take on a design that’s dynamic and expressive. Updates to the icon grid result in a standardized iconography that’s visually consistent across devices and concentric with hardware and other elements across the system. App icons now contain layers, which dynamically respond to lighting and other visual effects the system provides. iOS, iPadOS, and macOS all now offer default (light), dark, clear, and tinted appearance variants, empowering people to personalize the look and feel of their Home Screen.

 Apply key design principles to help your app icon shine:
- Provide a visually consistent, optically balanced design across the platforms your app supports.
- Consider a simplified design comprised of solid, filled, overlapping semi-transparent shapes.
- Let the system handle applying masking, blurring, and other visual effects, rather than factoring them into your design.
 The system automatically applies effects like reflection, refraction, shadow, blur, and highlights to your icon layers. Determine which elements of your design make sense as foreground, middle, and background elements, then define separate layers for them. You can perform this task in the design app of your choice.
 Drag and drop app icon layers that you export from your design app directly into the Icon Composer app. Icon Composer lets you add a background, create layer groupings, adjust layer attributes like opacity, and preview your design with system effects and appearances. Icon Composer is available in the latest version of Xcode and for download from . To learn more, read .

 The system applies masking to produce your final icon shape — rounded rectangle for iOS, iPadOS, and macOS, and circular for watchOS. Keep elements centered to avoid clipping. Irregularly shaped icons receive a system-provided background. See how your app icon looks with the updated grids to determine whether you need to make adjustments. Download these grids from .

### 
Controls have a refreshed look across platforms, and come to life when a person interacts with them. For controls like sliders and toggles, the knob transforms into Liquid Glass during interaction, and  fluidly morph into menus and popovers. The shape of the hardware informs the curvature of controls, so many controls adopt rounder forms to elegantly nestle into the corners of windows and displays. Controls also feature an option for an extra-large size, allowing more space for labels and accents.
 If you use standard controls from system frameworks and don’t hard-code their layout metrics, your app adopts changes to shapes and sizes automatically when you rebuild your app with the latest version of Xcode. Review changes to the following controls and any others and make sure they continue to look at home with the rest of your interface:
 Be judicious with your use of  in controls and navigation so they stay legible. If you do apply color to these elements, leverage system colors, or define a custom color with light and dark variants, and an increased contrast option for each variant.
 Prefer to use standard spacing metrics instead of overriding them, and avoid overcrowding or layering Liquid Glass elements on top of each other.
 Scroll views offer a  that helps maintain sufficient legibility and contrast for controls by obscuring content that scrolls beneath them. System bars like toolbars adopt this behavior by default. If you use a custom bar with elements like controls, text, or icons that have content scrolling beneath them, you can register those views to use a scroll edge effect with these APIs:
 Across Apple platforms, the shape of the hardware informs the curvature, size, and shape of nested interface elements, including controls, sheets, popovers, windows, and more. Help maintain a sense of visual continuity in your interface by using rounded shapes that are concentric to their containers using these APIs:
. Instead of creating buttons with custom Liquid Glass effects, you can adopt the look and feel of the material with minimal code by using one of the following button style APIs:

### 
Liquid Glass applies to the topmost layer of the interface, where you define your navigation. Key navigation elements like  and  float in this Liquid Glass layer to help people focus on the underlying content.
 It’s more important than ever for your app to have a clear and consistent navigation structure that’s distinct from the content you provide. Ensure that you clearly separate your content from navigation elements, like tab bars and sidebars, to establish a distinct functional layer above the content layer.
 If your app uses a tab-based navigation, you can allow the tab bar to adapt into a sidebar depending on the context by using the following APIs:
  are optimized to create a consistent and familiar experience for sidebar and inspector layouts across platforms. You can use the following standard system APIs for split views to build these types of layouts with minimal code:
 If you have these types of components in your app’s navigation structure, audit the safe area compatibility of content next to the sidebar and inspector to help make sure underlying content is peeking through appropriately.
 A background extension effect creates a sense of extending a background under a sidebar or inspector, without actually scrolling or placing content under it. A background extension effect mirrors the adjacent content to give the impression of stretching it under the sidebar, and applies a blur to maintain legibility of the sidebar or inspector. This effect is perfect for creating a full, edge-to-edge content experience in apps that use split views, such as for hero images on product pages.
 Tab bars can help elevate the underlying content by receding when a person scrolls up or down. You can opt into this behavior and configure the tab bar to minimize when a person scrolls down or up. The tab bar expands when a person scrolls in the opposite direction.

### 
 have a refreshed look across platforms. They adopt Liquid Glass, and menu items for common actions use icons to help people quickly scan and identify those actions. New to iPadOS, apps also have a  for faster access to common commands.
 For menu items that perform standard actions like Cut, Copy, and Paste, the system uses the menu item’s selector to determine which icon to apply. To adopt icons in those menu items with minimal code, make sure to use standard selectors.
 For consistency and predictability, make sure the actions you surface at the top of your contextual menu match the swipe actions you provide for the same item.
 take on a Liquid Glass appearance, and provide a grouping mechanism for toolbar items, letting you choose which actions to display together.
 Group items that perform similar actions or affect the same part of the interface, and maintain consistent groupings and placement across platforms.
You can create a fixed spacer to separate items that share a background using these APIs:
 Consider representing common actions in toolbars with  instead of text. This approach helps declutter the interface and increase the ease of use for common actions. For consistency, don’t mix text and icons across items that share a background.
 Regardless of what you show in the interface, always specify an accessibility label for each icon. This way, people who prefer a text label can opt into this information by turning on accessibility features like VoiceOver or Voice Control.
 Review anything custom you do to display items in your toolbars, like your use of fixed spacers or custom items, as these can appear inconsistent with system behavior.
 If you see an empty toolbar item without any content, your app might be hiding the view in the toolbar item instead of the item itself. Instead, hide the entire toolbar item, using these APIs:

### 
 adopt rounder corners to fit controls and navigation elements. In iPadOS, apps show window controls and support continuous window resizing. Instead of transitioning between specific preset sizes, windows resize fluidly down to a minimum size.
 Allow people to resize their window to the width and height that works for them, and adjust your content accordingly.
 To support continuous window resizing, split views automatically reflow content for every size using beautiful, fluid transitions. Make sure to use standard system APIs for split views to get these animations with minimal code:
 Make sure you specify safe areas for your content so the system can automatically adjust the window controls and title bar in relation to your content.
Modal views like sheets and action sheets adopt Liquid Glass.  feature an increased corner radius, and half sheets are inset from the edge of the display to allow content to peek through from beneath them. When a half sheet expands to full height, it transitions to a more opaque appearance to help maintain focus on the task.
 Inside the sheet, check for content and controls that might appear too close to rounder sheet corners. Outside the sheet, check that any content peeking through between the inset sheet and display edge looks as you expect.
 Check whether you add a visual effect view to your popover’s content view, and remove those custom background views to provide a consistent experience with other sheets across the system.
An  originates from the element that initiates the action, instead of from the bottom edge of the display. When active, an action sheet also lets people interact with other parts of the interface.
 Position an action sheet’s anchor next to the control it originates from. Make sure to set the source view or item to indicate where to originate the action sheet and create the inline appearance.

### 
Style updates to  help you organize and showcase your content so it can shine through the Liquid Glass layer. To give content room to breathe, organizational components like lists, tables, and forms have a larger row height and padding. Sections have an increased corner radius to match the curvature of controls across the system.
 Lists, tables, and forms optimize for legibility by adopting title-style capitalization for . This means section headers no longer render entirely in capital letters regardless of the capitalization you provide. Make sure to update your section headers to title-style capitalization to match your app’s text to this systemwide convention.
 Use SwiftUI forms with the  to automatically update your form layouts.

### 
Platform conventions for location and behavior of search optimize the experience for each device and use case. To provide an engaging search experience in your app, review these  design conventions.
 In iOS, when a person taps a search field to give it focus, it slides upwards as the keyboard appears. Test this experience in your app to make sure the search field moves consistently with other apps and system experiences.
 If your app’s search appears as part of a tab bar, make sure to use the standard system APIs for indicating which tab is the search tab. The system automatically separates the search tab from other tabs and places it at the trailing end to make your search experience consistent with other apps and help people find content faster.

### 
Liquid Glass can have a distinct appearance and behavior across different platforms, contexts, and input methods. Test your app across devices to understand how the material looks and feels across platforms.
 Liquid Glass changes are minimal in watchOS, so they appear automatically when you open your app on the latest release even if you don’t build against the latest SDK. However, to make sure your app picks up this appearance, adopt standard toolbar APIs and button styles from watchOS 10.
 Across apps and system experiences in tvOS, standard buttons and controls take on a Liquid Glass appearance when focus moves to them. For consistency with the system experience, consider applying these effects to custom controls in your app when they gain focus by adopting the standard focus APIs. Apple TV 4K (2nd generation) and newer models support Liquid Glass effects. On older devices, your app maintains its current appearance.
 If you apply these effects to custom elements, make sure to combine them using a , which helps optimize performance while fluidly morphing Liquid Glass shapes into each other.
 It’s a good idea to regularly assess and improve your app’s performance, and building your app with the latest SDKs provides an opportunity to check in. Profile your app to gather information about its current performance and find any opportunities for improving the user experience. To learn more, read .
To update and ship your app with the latest SDKs while keeping your app as it looks when built against previous versions of the SDKs, you can add the  key to your project’s Info pane.

## Apple Intelligence and machine learning
> https://developer.apple.com/documentation/TechnologyOverviews/ai-machine-learning

Intelligent features make people’s experiences on a device more personal. Apple incorporates intelligent features into many of its frameworks and technologies, making it easy to adopt those features quickly in your own apps. When a framework doesn’t do what you need it to, you can customize its behavior by training a model with your own data — like training a new sound classification model to detect your own sound. Of course, if you have your own machine learning models, you can also incorporate them into your app in a way that works well with Apple hardware and the system’s other intelligent features.

### 
Apple Intelligence is the personal intelligence system that helps you communicate, work, and express yourself. It combines generative models with your personal context to deliver intelligence that is most useful and relevant to people, while designed with privacy in mind. Now you have direct access to the on-device model at the core of Apple Intelligence, so you can build experiences that are smart, private, and work even without internet connectivity.

### 
Run your own prompts on the on-device model at the core of Apple Intelligence to enhance your existing features with model capabilities like text extraction and summarization. When you prompt the model, provide your Swift data type that it uses to avoid making structural mistakes — allowing you to focus on your prompts and not parsing JSON schemas. The models can also call your own code to help perform additional tasks that might need real-time information or content thatʼs in a local database.

### 
Many system frameworks use machine learning models to make difficult tasks easier, and make seemingly impossible tasks possible. You can use system frameworks that help with performing analysis of , , and .

### 
Create your own machine learning models when you need more customization than what the system technologies provide. Use the  when you want a fast, user-friendly way to create and train models with your own data. If you already have a model you’ve built, you can convert it to the Core ML format with Core ML tools and deploy it into your app.

## Liquid Glass
> https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass

### 
Interfaces across Apple platforms feature a new dynamic material called Liquid Glass, which combines the optical properties of glass with a sense of fluidity. Learn how to adopt this material and embrace the design principles of Apple platforms to create beautiful interfaces that establish hierarchy, create harmony, and maintain consistency across devices and platforms.

Standard components from SwiftUI, UIKit, and AppKit like controls and navigation elements pick up the appearance and behavior of this material automatically. You can also implement these effects in custom interface elements.

### 
If you have an existing app, adopting Liquid Glass doesn’t mean reinventing your app from the ground up. Start by building your app in the latest version of Xcode to see the changes. Then, follow best practices in your interface to help your app look right at home on Apple platforms.

### 
The Landmarks app showcases how to create a beautiful and engaging user experience using SwiftUI and Liquid Glass. Explore how the Landmarks app implements the look and feel of the Liquid Glass material throughout its interface.

- Configure an app icon with Icon Composer.
- Create an edge-to-edge content experience with the background extension effect.
- Enhance the edge-to-edge content experience by extending horizontal scroll views under a sidebar or inspector.
- Make your interface adaptable to changing window sizes.
- Explore search conventions across platforms.
- Apply Liquid Glass effects to custom interface elements and animations.
To learn more, see .

### 
The Human Interface Guidelines contains guidance and best practices that can help you design a great experience for any Apple platform. Browse the HIG to discover more about adapting your interface for Liquid Glass.
- Define a layout and choose a navigation structure that puts the most important content in focus.
- Reimagine your app icon with simple, bold layers that offer dimensionality and consistency across devices and appearances.
- Be judicious with your use of color in controls and navigation so they stay legible and allow your content to infuse them and shine through.
- Ensure interface elements fit in with software and hardware design across devices.
- Adopt standard iconography and predictable action placement across platforms.
To learn more, read the .

###


---
# FOUNDATIONMODELS

## Generating Swift data structures with guided generation
> https://developer.apple.com/documentation/FoundationModels/generating-swift-data-structures-with-guided-generation

### 
When you perform a request, the model returns a raw string in its natural language format. Raw strings require you to manually parse the details you want. Instead of working with raw strings, the framework provides guided generation, which gives strong guarantees that the response is in a format you expect.
To use guided generation, describe the output you want as a new Swift type. When you make a request to the model, include your custom type and the framework performs the work necessary to fill in and return an object with the parameters filled in for you. The framework uses constrained sampling when generating output, which defines the rules on what the model can generate. Constrained sampling prevents the model from producing malformed output and provides you with results as a type you define.
For more information about creating a session and prompting the model, see .

### 
To conform your type to , describe the type and the parameters to guide the response of the model. The framework supports generating content with basic Swift types like `Bool`, `Int`, `Float`, `Double`, `Decimal`, and `Array`. For example, if you only want the model to return a numeric result, call  using the type `Float`:

```swift
let prompt = "How many tablespoons are in a cup?"
let session = LanguageModelSession(model: .default)

// Generate a response with the type `Float`, instead of `String`.
let response = try await session.respond(to: prompt, generating: Float.self)
```
A schema provides the ability to control the values of a property, and you can specify guides to control values you associate with it. The framework provides two macros that help you with schema creation. Use  on structures, actors, and enumerations; and only use  with stored properties.
When you add descriptions to `Generable` properties, you help the model understand the semantics of the properties. Keep the descriptions as short as possible — long descriptions take up additional context size and can introduce latency. The following example creates a type that describes a cat and includes a name, an age that’s constrained to a range of values, and a short profile:

```swift
@Generable(description: "Basic profile information about a cat")
struct CatProfile {
    // A guide isn't necessary for basic fields.
    var name: String

    @Guide(description: "The age of the cat", .range(0...20))
    var age: Int

    @Guide(description: "A one sentence profile about the cat's personality")
    var profile: String
}
```

> **note:** The model generates `Generable` properties in the order they’re declared.

You can nest custom `Generable` types inside other `Generable` types, and mark enumerations with associated values as `Generable`. The `Generable` macro ensures that all associated and nested values are themselves generable. This allows for advanced use cases like creating complex data types or dynamically generating views at runtime.

### 
After creating your type, use it along with a  to prompt the model. When you use a `Generable` type it prevents the model from producing malformed output and prevents the need for any manual string parsing.

```swift
// Generate a response using a custom type.
let response = try await session.respond(
    to: "Generate a cute rescue cat",
    generating: CatProfile.self
)
```

### 
If you don’t know what you want the model to produce at compile time use  to define what you need. For example, when you’re working on a restaurant app and want to restrict the model to pick from menu options that a restaurant provides. Because each restaurant provides a different menu, the schema won’t be known in its entirety until runtime.

```swift
// Create the dynamic schema at runtime.
let menuSchema = DynamicGenerationSchema(
    name: "Menu",
    properties: [
        DynamicGenerationSchema.Property(
            name: "dailySoup",
            schema: DynamicGenerationSchema(
                name: "dailySoup",
                anyOf: ["Tomato", "Chicken Noodle", "Clam Chowder"]
            )
        )

        // Add additional properties.
    ]
)
```
After creating a dynamic schema, use it to create a  that you provide with your request. When you try to create a generation schema, it can throw an error if there are conflicting property names, undefined references, or duplicate types.

```swift
// Create the schema.
let schema = try GenerationSchema(root: menuSchema, dependencies: [])

// Pass the schema to the model to guide the output.
let response = try await session.respond(
    to: "The prompt you want to make.",
    schema: schema
)
```
The response you get is an instance of . You can decode the outputs from schemas you define at runtime by calling  for the property you want.

## Improving the safety of generative model output
> https://developer.apple.com/documentation/FoundationModels/improving-the-safety-of-generative-model-output

### 
Generative AI models have powerful creativity, but with this creativity comes the risk of unintended or unexpected results. For any generative AI feature, safety needs to be an essential part of your design.
The Foundation Models framework has two base layers of safety, where the framework uses:
- An on-device language model that has training to handle sensitive topics with care.
-  that aim to block harmful or sensitive content, such as self-harm, violence, and adult materials, from both model input and output.
Because safety risks are often contextual, some harms might bypass both built-in framework safety layers. It’s vital to design additional safety layers specific to your app. When developing your feature, decide what’s acceptable or might be harmful in your generative AI feature, based on your app’s use case, cultural context, and audience.
For more information on designing generative AI experiences responsibly, see Human Interface Guidelines > Foundations > .

### 
When you send a prompt to the model,  check the input prompt and the model’s output. If either fails the guardrail’s safety check, the model session throws a  error:

```swift
do {
    let session = LanguageModelSession()
    let topic = // A potentially harmful topic.
    let prompt = "Write a respectful and funny story about \(topic)."
    let response = try await session.respond(to: prompt)
} catch LanguageModelSession.GenerationError.guardrailViolation {
    // Handle the safety error.
}
```
If you encounter a guardrail violation error for any built-in prompt in your app, experiment with re-phrasing the prompt to determine which phrases are activating the guardrails, and avoid those phrases. If the error is thrown in response to a prompt created by someone using your app, give people a clear message that explains the issue. For example, you might say “Sorry, this feature isn’t designed to handle that kind of input” and offer people the opportunity to try a different prompt.

### 
The on-device language model may not be suitable for handling all requests and may refuse requests for a topic. When you generate a string response, and the model refuses a request, it generates a message that begins with a refusal like “Sorry, I can’t help with”.
Design your app experience with refusal messages in mind and present the message to the person using your app. You might not be able to programmatically determine whether a string response is a normal response or a refusal, so design the experience to anticipate both. If it’s critical to determine whether the response is a refusal message, initialize a new  and prompt the model to classify whether the string is a refusal.
When you use guided generation to generate Swift structures or types, there’s no placeholder for a refusal message. Instead, the model throws a  error. When you catch the error, you can ask the model to generate a string refusal message:

```swift
do {
    let session = LanguageModelSession()
    let topic = ""  // A sensitive topic.
    let response = try session.respond(
        to: "List five key points about: \(topic)",
        generating: [String].self
    )
} catch LanguageModelSession.GenerationError.refusal(let refusal, _) {
    // Generate an explanation for the refusal.
    if let message = try? await refusal.explanation {
        // Display the refusal message.
    }
}
```
Display the explanation in your app to tell people why a request failed, and offer people the opportunity to try a different prompt. Retrieving an explanation message is asynchronous and takes time for the model to generate.
If you encounter a refusal message, or refusal error, for any built-in prompts in your app, experiment with re-phrasing your prompt to avoid any sensitive topics that might cause the refusal.
For more information about guided generation, see .

### 
Safety risks increase when a prompt includes direct input from a person using your app, or from an unverified external source, like a webpage. An untrusted source makes it difficult to anticipate what the input contains. Whether accidentally or on purpose, someone could input sensitive content that causes the model to respond poorly.

> **tip:** The more you can define the intended usage and outcomes for your feature, the more you can ensure generation works great for your app’s specific use cases. Add boundaries to limit out-of-scope usage and minimize low generation quality from out-of-scope uses.

Whenever possible, avoid open input in prompts and place boundaries for controlling what the input can be. This approach helps when you want generative content to stay within the bounds of a particular topic or task. For the highest level of safety on input, give people a fixed set of prompts to choose from. This gives you the highest certainty that sensitive content won’t make its way into your app:

```swift
enum TopicOptions {
    case family
    case nature
    case work 
}
let topicChoice = TopicOptions.nature
let prompt = """
    Generate a wholesome and empathetic journal prompt that helps \
    this person reflect on \(topicChoice)
    """
```
If your app allows people to freely input a prompt, placing boundaries on the output can also offer stronger safety guarantees. Using guided generation, create an enumeration to restrict the model’s output to a set of predefined options designed to be safe no matter what:

```swift
@Generable
enum Breakfast {
    case waffles
    case pancakes
    case bagels
    case eggs 
}
let session = LanguageModelSession()
let userInput = "I want something sweet."
let prompt = "Pick the ideal breakfast for request: \(userInput)"
let response = try await session.respond(to: prompt, generating: Breakfast.self)
```

### 
Consider adding detailed session  that tell the model how to handle sensitive content. The language model prioritizes following its instructions over any prompt, so instructions are an effective tool for improving safety and overall generation quality. Use uppercase words to emphasize the importance of certain phrases for the model:

```swift
do {
    let instructions = """
        ALWAYS respond in a respectful way. \
        If someone asks you to generate content that might be sensitive, \
        you MUST decline with 'Sorry, I can't do that.'
        """
    let session = LanguageModelSession(instructions: instructions)
    let prompt = // Open input from a person using the app.
    let response = try await session.respond(to: prompt)
} catch LanguageModelSession.GenerationError.guardrailViolation {
    // Handle the safety error.
}
```

> **note:** A session obeys instructions over a prompt, so don’t include input from people or any unverified input in the instructions. Using unverified input in instructions makes your app vulnerable to prompt injection attacks, so write instructions with content you trust.

If you want to include open-input from people, instructions for safety are recommended. For an additional layer of safety, use a format string in normal prompts that wraps people’s input in your own content that specifies how the model should respond:

```swift
let userInput = // The input a person enters in the app.
let prompt = """
    Generate a wholesome and empathetic journal prompt that helps \
    this person reflect on their day. They said: \(userInput)
    """
```

### 
If you allow prompt input from people or outside sources, consider adding your own deny list of terms. A deny list is anything you don’t want people to be able to input to your app, including unsafe terms, names of people or products, or anything that’s not relevant to the feature you provide. Implement a deny list similarly to guardrails by creating a function that checks the input and the model output:

```swift
let session = LanguageModelSession()
let userInput = // The input a person enters in the app.
let prompt = "Generate a wholesome story about: \(userInput)"

// A function you create that evaluates whether the input 
// contains anything in your deny list.
if verifyText(prompt) { 
    let response = try await session.respond(to: prompt)
    
    // Compare the output to evaluate whether it contains anything in your deny list.
    if verifyText(response.content) { 
        return response 
    } else {
        // Handle the unsafe output.
    }
} else {
    // Handle the unsafe input.
}
```
A deny list can be a simple list of strings in your code that you distribute with your app. Alternatively, you can host a deny list on a server so your app can download the latest deny list when it’s connected to the network. Hosting your deny list allows you to update your list when you need to and avoids requiring a full app update if a safety issue arise.

### 
The default  guardrails may throw a  error for sensitive source material. For example, it may be appropriate for your app to work with certain inputs from people and unverified sources that might contain sensitive content:
- When you want the model to tag the topic of conversations in a chat app when some messages contain profanity.
- When you want to use the model to explain notes in your study app that discuss sensitive topics.
To allow the model to reason about sensitive source material, use  when you initialize :

```swift
let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
```
This mode only works for generating a string value. When you use guided generation, the framework runs the default guardrails against model input and output as usual, and generates  and errors as usual.
Before you use permissive content mode, consider what’s appropriate for your audience. The session skips the guardrail checks in this mode, so it never throws a  error when generating string responses.
However, even with the  guardrails off, the on-device system language model still has a layer of safety. For some content, the model may still produce a refusal message that’s similar to, “Sorry, I can’t help with.”

### 
Conduct a risk assessment to proactively address what might go wrong. Risk assessment is an exercise that helps you brainstorm potential safety risks in your app and map each risk to an actionable mitigation. You can write a risk assessment in any format that includes these essential elements:
- List each AI feature in your app.
- For each feature, list possible safety risks that could occur, even if they seem unlikely.
- For each safety risk, score how serious the harm would be if that thing occurred, from mild to critical.
- For each safety risk, assign a strategy for how you’ll mitigate the risk in your app.
For example, an app might include one feature with the fixed-choice input pattern for generation and one feature with the open-input pattern for generation, which is higher safety risk:
| Feature | Harm | Severity | Mitigation |
| Player can input any text to chat with nonplayer characters in the coffee shop. | A character might respond in an insensitive or harmful way. | Critical | Instructions and prompting to steer characters responses to be safe; safety testing. |
| Image generation of an imaginary dream customer, like a fairy or a frog. | Generated image could look weird or scary. | Mild | Include in the prompt examples of images to generate that are cute and not scary; safety testing. |
| Player can make a coffee from a fixed menu of options. | None identified. |  |  |
| Generate a review of the coffee the player made, based on the customer’s order. | Review could be insulting. | Moderate | Instructions and prompting to encourage posting a polite review; safety testing. |
Besides obvious harms, like a poor-quality model output, think about how your generative AI feature might affect people, including real-world scenarios where someone might act based on information generated by your app.

### 
Although most people will interact with your app in respectful ways, it’s important to anticipate possible failure modes where certain input or contexts could cause the model to generate something harmful. Especially if your app takes input from people, test your experience’s safety on input like:
- Input that is nonsensical, snippets of code, or random characters.
- Input that includes sensitive content.
- Input that includes controversial topics.
- Vague or unclear input that could be misinterpreted.
Create a list of potentially harmful prompt inputs that you can run as part of your app’s tests. Include every prompt in your app — even safe ones — as part of your app testing. For each prompt test, log the timestamp, full input prompt, the model’s response, and whether it activates any built-in safety or mitigations you’ve included in your app. When starting out, manually read the model’s response on all tests to ensure it meets your design and safety goals. To scale your tests, consider using a frontier LLM to auto-grade the safety of each prompt. Building a test pipeline for prompts and safety is a worthwhile investment for tracking changes in how your app responds over time.
Someone might purposefully attempt to break your feature or produce bad output — especially someone who won’t be harmed by their actions. But, keep in mind that it’s very important to identify cases where someone might  be harmed during normal app use.

> **tip:** Prioritize protecting people using your app with good intentions. Accidental safety failures often only occur in specific contexts, which make them hard to identify during testing. Test for a longer series of interactions, and test for inputs that could become sensitive only when combined with other aspects of your app.

Don’t engage in any testing that could cause you or others harm. Apple’s built-in responsible AI and safety measures, like safety guardrails, are built by experts with extensive training and support. These built-in measures aim to block egregious harms, allowing you to focus on the borderline harmful cases that need your judgement. Before conducting any safety testing, ensure that you’re in a safe location and that you have the health and well-being support you need.

### 
Somewhere in your app, it’s important to include a way that people can report potentially harmful content. Continuously monitor the feedback you receive, and be responsive to quickly handling any safety issues that arise. If someone reports a safety concern that you believe isn’t being properly handled by Apple’s built-in guardrails, report it to Apple with .
The Foundation Models framework offers utilities for feedback. Use  to retrieve language model session transcripts from people using your app. After collecting feedback, you can serialize it into a JSON file and include it in the report you send with Feedback Assistant.

### 
Apple releases updates to the system model as part of regular OS updates. If you participate in the developer beta program you can test your app with new model version ahead of people using your app. When the model updates, it’s important to re-run your full prompt tests in addition to your adversarial safety tests because the model’s response may change. Your risk assessment can help you track any change to safety risks in your app.
Apple may update the built-in guardrails at any time outside of the regular OS update cycle. This is done to rapidly respond, for example, to reported safety concerns that require a fast response. Include all of the prompts you use in your app in your test suite, and run tests regularly to identify when prompts start activating the guardrails.


---
# SWIFTUI

## Creating visual effects with SwiftUI
> https://developer.apple.com/documentation/SwiftUI/creating-visual-effects-with-swiftui

### 

> **note:** This sample code project is associated with WWDC24 session 10151: .

## Landmarks: Building an app with Liquid Glass
> https://developer.apple.com/documentation/SwiftUI/Landmarks-Building-an-app-with-Liquid-Glass

### 
Landmarks is a SwiftUI app that demonstrates how to use the new dynamic and expressive design feature, Liquid Glass. The Landmarks app lets people explore interesting sites around the world. Whether it’s a national park near their home or a far-flung location on a different continent, the app provides a way for people to organize and mark their adventures and receive custom activity badges along the way. Landmarks runs on iPad, iPhone, and Mac.

Landmarks uses a  to organize and navigate to content in the app, and demonstrates several key concepts to optimize the use of Liquid Glass:
- Stretching content behind the sidebar and inspector with the background extension effect.
- Extending horizontal scroll views under a sidebar or inspector.
- Leveraging the system-provided glass effect in toolbars.
- Applying Liquid Glass effects to custom interface elements and animations.
- Building a new app icon with Icon Composer.
The sample also demonstrates several techniques to use when changing window sizes, and for adding global search.

### 
The sample applies a background extension effect to the featured landmark header in the top view, and the main image in the landmark detail view. This effect extends and blurs the image under the sidebar and inspector when they’re open, creating a full edge-to-edge experience.

To achieve this effect, the sample creates and configures an  that extends to both the leading and trailing edges of the containing view, and applies the  modifier to the image. For the featured image, the sample adds an overlay with a headline and button after the modifier, so that only the image extends under the sidebar and inspector.

> **note:** The sample also extends the image beyond the top safe area, and adds logic to interactively extend the image when you scroll down beyond the view’s bounds. While this improves the experience of the image in the app, it isn’t required to implement the background extension effect.

For more information, see .

### 
Within each continent section in `LandmarksView`, an instance of `LandmarkHorizontalListView` shows a horizontally scrolling list of landmark views. When open, the landmark views can scroll underneath the sidebar or inspector.
To achieve this effect, the app aligns the scroll views next to the leading and trailing edges of the containing view.

For more information, see .

### 
In `LandmarkDetailView`, the sample adds toolbar items for:
- sharing a landmark
- adding or removing a landmark from a list of Favorites
- adding or removing a landmark from Collections
- showing or hiding the inspector
The system applies Liquid Glass to toolbar items automatically:

The sample also organizes the toolbar into related groups, instead of having all the buttons in one group. For more information, see .

### 
Badges provide people with a visual indicator of the activities they’ve recorded in the Landmarks app. When a person completes all four activities for a landmark, they earn that landmark’s badge. The sample uses custom Liquid Glass elements with badges, and shows how to coordinate animations with Liquid Glass.

To create a custom Liquid Glass badge, Landmarks uses a view with an `Image` to display a system symbol image for the badge. The badge has a background hexagon `Image` filled with a custom color. The badge view uses the  modifier to apply Liquid Glass to the badge.
To demonstrate the morphing effect that the system provides with Liquid Glass animations, the sample organizes the badges and the toggle button into a , and assigns each badge a unique .
For more information, see . For information about building custom views with Liquid Glass, see .

### 
Landmarks includes a dynamic and expressive app icon composed in Icon Composer. You build app icons with four layers that the system uses to produce specular highlights when a person moves their device, so that the icon responds as if light was reflecting off the glass. The Settings app allows people to personalize the icon by selecting light, dark, clear, or tinted variants of your app icon as well.
For more information on creating a new app icon, see .
For design guidance, see Human Interface Guidelines >  .

## Managing user interface state
> https://developer.apple.com/documentation/SwiftUI/managing-user-interface-state

### 
Store data as state in the least common ancestor of the views that need the data to establish a single  that’s shared across views. Provide the data as read-only through a Swift property, or create a two-way connection to the state with a binding. SwiftUI watches for changes in the data, and updates any affected views as needed.

Don’t use state properties for persistent storage because the life cycle of state variables mirrors the view life cycle. Instead, use them to manage transient state that only affects the user interface, like the highlight state of a button, filter settings, or the currently selected list item. You might also find this kind of storage convenient while you prototype, before you’re ready to make changes to your app’s data model.

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
Marking the property as state tells the framework to manage the underlying storage. Your view reads and writes the data, found in the state’s  property, by using the property name. When you change the value, SwiftUI updates the affected parts of the view. For example, you can add a button to the `PlayerView` that toggles the stored value when tapped, and that displays a different image depending on the stored value:

```swift
Button(action: {
    self.isPlaying.toggle()
}) {
    Image(systemName: isPlaying ? "pause.circle" : "play.circle")
}
```
Limit the scope of state variables by declaring them as private. This ensures that the variables remain encapsulated in the view hierarchy that declares them.

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
While the value of the episode property is a constant for `PlayerView`, it doesn’t need to be constant in this view’s parent view. When the user selects a different episode in the parent, SwiftUI detects the state change and recreates the `PlayerView` with a new input.

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
When you want to apply animations to specific views, rather than across all views triggered by a change in state, use the  view modifier instead.

## Model data
> https://developer.apple.com/documentation/SwiftUI/model-data

### 
SwiftUI offers a declarative approach to user interface design. As you compose a hierarchy of views, you also indicate data dependencies for the views. When the data changes, either due to an external event or because of an action that the user performs, SwiftUI automatically updates the affected parts of the interface. As a result, the framework automatically performs most of the work that view controllers traditionally do.

The framework provides tools, like state variables and bindings, for connecting your app’s data to the user interface. These tools help you maintain a single source of truth for every piece of data in your app, in part by reducing the amount of glue logic you write. Select the tool that best suits the task you need to perform:
- Manage transient UI state locally within a view by wrapping value types as  properties.
- Share a reference to a source of truth, like local state, using the  property wrapper.
- Connect to and observe reference model data in views by applying the  macro to the model data type. Instantiate an observable model data type directly in a view using a  property. Share the observable model data with other views in the hierarchy without passing a reference using the  property wrapper.

#### 
SwiftUI implements many data management types, like  and , as Swift property wrappers. Apply a property wrapper by adding an attribute with the wrapper’s name to a property’s declaration.

```swift
@State private var isVisible = true // Declares isVisible as a state variable.
```
The property gains the behavior that the wrapper specifies. The state and data flow property wrappers in SwiftUI watch for changes in your data, and automatically update affected views as necessary. When you refer directly to the property in your code, you access the wrapped value, which for the `isVisible` state property in the example above is the stored Boolean.

```swift
if isVisible == true {
    Text("Hello") // Only renders when isVisible is true.
}
```
Alternatively, you can access a property wrapper’s projected value by prefixing the property name with the dollar sign (`$`). SwiftUI state and data flow property wrappers project a , which is a two-way connection to the wrapped value, allowing another view to access and mutate a single source of truth.

```swift
Toggle("Visible", isOn: $isVisible) // The toggle can update the stored value.
```
For more information about property wrappers, see  in .

## Populating SwiftUI menus with adaptive controls
> https://developer.apple.com/documentation/SwiftUI/Populating-SwiftUI-menus-with-adaptive-controls

### 
Menus are versatile components you can populate adaptively and use to organize commands, actions, or items in your app.
In tight layouts or smaller devices, menus optimize space by displaying options on demand. Use menus to conceal complex interface options when actions can be logically grouped. You have options for configuring your menus, with various controls like , , , , and more. This adaptability ensures that your menus remain flexible and succinct while supporting complex use cases.

> **note:** While the code for creating a menu in SwiftUI is largely the same across platforms, the system may display the menu differently depending on the device.


#### 
Make your menus simple and flexible, able to adapt to various interfaces, such as regular and compact size classes on iOS and iPadOS and across macOS, tvOS, and visionOS.
A menu consists of three components:
- Label: A view that describes the purpose of the menu.
- Content: A closure that uses a  to define the items inside the menu.
- Primary action: An optional closure that performs an action when someone clicks or taps the menu, instead of the default primary action of opening the menu. When provided, opening the menu becomes the secondary action, such as opening after a long press gesture instead of a tap.
For design guidance, see Human Interface Guidelines > .

#### 
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


> **note:** SwiftUI controls and views are adaptive, and represent functionality and meaning, as well as visual representation. When you open a menu, the menu items appear in a context-appropriate order depending on the platform. For more information, see .

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

You can choose picker styles such as , , and .

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
While submenus and sections are containers that group items, the `Divider` view provides a simple way to visually separate items within a menu. Unlike `Section`, `Divider` isn’t a container, but serves as a visual break that divides groups of items to organize and group like-commands for improved usability and uniformity across apps.

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

> **note:** On macOS, menu items typically follow the standard macOS ordering rules, and don’t reorder for proximity.

By default, menus dismiss as soon as someone clicks or taps an item. If you want the person to make multiple selections, or repeat an action without reopening the menu, override this behavior with the  modifier on specific items.
The following code demonstrates:
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


---
# UIKIT

## Views and controls
> https://developer.apple.com/documentation/UIKit/views-and-controls

### 
Views and controls are the visual building blocks of your app’s user interface. Use them to draw and organize your app’s content onscreen.

Views can host other views. Embedding one view inside another creates a containment relationship between the host view (known as the ) and the embedded view (known as the ). View hierarchies make it easier to manage views.
You can also use views to do any of the following:
- Respond to touches and other events (either directly or in coordination with gesture recognizers).
- Draw custom content using Core Graphics or UIKit classes.
- Support drag and drop interactions.
- Respond to focus changes.
- Animate the size, position, and appearance attributes of the view.
 is the root class for all views and defines their common behavior.  defines additional behaviors that are specific to buttons, switches, and other views designed for user interactions.
For additional information about how to use views and controls, see . To see examples of UIKit controls, see .


---
# ALARMKIT

## Scheduling an alarm with AlarmKit
> https://developer.apple.com/documentation/AlarmKit/scheduling-an-alarm-with-alarmkit

### 
An alarm is an alert that presents at a pre-determined time based on a schedule or after a countdown. It overrides both a device’s focus and silent mode, if necessary.
This sample project uses AlarmKit to create and manage different types of alarms. In this app people can create and manage:
-  which alert only once at a specified time in the future.
-  which alert with a weekly cadence.
-  which alert after a countdown, and start immediately.
This project also includes a widget extension for setting up the custom countdown Live Activity associated with an alarm.

> **note:** This sample code project is associated with WWDC25 session 230: .


### 
This sample prompts people to authorize the app to allow AlarmKit to schedule alarms and create alerts by calling  on . Otherwise, when a person adds their first alarm, AlarmKit automatically requests this authorization on behalf of the app, before scheduling the alarm. If this sample doesn’t get this authorization, then any alarm created by the app isn’t scheduled and subsequently doesn’t alert.

```swift
do {
    let state = try await alarmManager.requestAuthorization()
    return state == .authorized
} catch {
    print("Error occurred while requesting authorization: \(error)")
    return false
}
```
The sample includes the  key in the app’s `Info.plist` with a descriptive string explaining why it schedules alarms. This string appears in the system prompt when requesting authorization, in this sample the string is:

```None
We'll schedule alerts for alarms you create within our app.
```
If the `NSAlarmKitUsageDescription` key is missing or its value is an empty string, apps can’t schedule alarms with AlarmKit.

### 
The sample app creates an alarm with either, or both, a countdown duration and a schedule, based on the options a person sets.
 uses the selected `TimeInterval` for the  pre-alert countdown, which displays the alert when the countdown reaches 0.
 enables people to set a one-time alarm, or configure a weekly schedule. For single-occurrence alarms, the  property is set to . For recurring alarms, the `repeats` property is set to  with an associated array `Locale.Weekday`, indicating the days of the week the alarm alerts.

```swift
let time = Alarm.Schedule.Relative.Time(hour: hour, minute: minute)
return .relative(.init(
    time: time,
    repeats: weekdays.isEmpty ? .never : .weekly(Array(weekdays))
))
```

### 
AlarmKit provides a presentation for each of the three alarm states - , , and . Because `Countdown` and `Paused` are optional presentations, this sample doesn’t use them if the alarm only has an `Alert` state.

```swift
let alertContent = AlarmPresentation.Alert(title: userInput.localizedLabel,
        stopButton: .stopButton,
        secondaryButton: secondaryButton,
        secondaryButtonBehavior: secondaryButtonBehavior)

guard userInput.countdownDuration != nil else {
    // An alarm without countdown specifies only an alert state.
    return AlarmPresentation(alert: alertContent)
}

// With countdown enabled, provide a presentation for both a countdown and paused state.
let countdownContent = AlarmPresentation.Countdown(title: userInput.localizedLabel,
        pauseButton: .pauseButton)

let pausedContent = AlarmPresentation.Paused(title: "Paused",
        resumeButton: .resumeButton)

return AlarmPresentation(alert: alertContent, countdown: countdownContent, paused: pausedContent)
```
Alongside the , the sample includes another action button in the alerting UI. This action depends on  and .

```swift
var secondaryButtonBehavior: AlarmPresentation.Alert.SecondaryButtonBehavior? {
    switch selectedSecondaryButton {
    case .none: nil
    case .countdown: .countdown
    case .openApp: .custom
    }
}
```
When the `secondaryButtonBehavior` property is set to , the secondary button is a `Repeat` action, which re-triggers the alarm after a certain `TimeInterval`, as specified in . If the `secondaryButtonBehavior` is set to , the alarm alert displays an `Open` action to launch the app.

```swift
let secondaryButton: AlarmButton? = switch secondaryButtonBehavior {
    case .countdown: .repeatButton
    case .custom: .openAppButton
    default: nil
}
```

> **note:** The system forwards the alert presentation to a paired watch (if any) to notify people when an alarm is alerting.

The content for these presentations is wrapped into , along with , and . The tint color associates the alarms with the sample app and also differentiates them from other app’s alarms on the person’s device.

```swift
let attributes = AlarmAttributes(presentation: alarmPresentation(with: userInput),
        metadata: CookingData(),
        tintColor: Color.blue)
```

### 
The sample uses a unique identifier to track alarms registered with AlarmKit. The sample manages and updates alarm states, such as  and , using this identifier.
When a person taps the button in the alerting UI, the  automatically handles stop or countdown functionalities, depending on the button type.

> **tip:** You can add additional actions for each button type using , which you can configure using .


```swift
let id = UUID()
let alarmConfiguration = AlarmConfiguration(countdownDuration: userInput.countdownDuration,
        schedule: userInput.schedule,
        attributes: attributes,
        stopIntent: StopIntent(alarmID: id.uuidString),
        secondaryIntent: secondaryIntent(alarmID: id, userInput: userInput))
```
This sample creates the alarm ID and  and schedules the alarm with .

```swift
let alarm = try await alarmManager.schedule(id: id, configuration: alarmConfiguration)
```

### 
At initialization, the `ViewModel` subscribes to alarm events from . This enables the sample app to have the latest state of an alarm even if the alarm state updated while the sample app isn’t running.

```swift
Task {
    for await incomingAlarms in alarmManager.alarmUpdates {
        updateAlarmState(with: incomingAlarms)
    }
}
```

> **note:** An  that’s not included in the  asynchronous stream is no longer scheduled with AlarmKit.


### 
The sample app adds a widget extension target to customize non-alerting presentations in the Dynamic Island, Lock Screen, and StandBy. The widget extension receives the same  structure that you provide to  when scheduling alarms. It includes the metadata provided in the  section above.

> **important:** AlarmKit expects a widget extension if an app supports a countdown presentation. Otherwise, the system may unexpectedly dismiss alarms and fail to alert. For more information, see .


---
# ACTIVITYKIT

## Creating custom views for Live Activities
> https://developer.apple.com/documentation/ActivityKit/creating-custom-views-for-live-activities

### 
To support Live Activities in your app, you must provide layouts for each Live Activity presentation. Because Live Activities appear automatically across a person’s devices, views you use for your Live Activities automatically adapt to provide a default layout. To offer the best user experience and make the most of the available space, create reusable, custom views that automatically adapt for each Live Activity presentation.

#### 
The different presentations are key to creating layouts for your Live Activities. By requiring you to support each presentation, the system can render your Live Activity across devices without you having to add code for each device:
- In StandBy, the system expands the Lock Screen presentation to fill the whole screen.
- On Apple Watch, Live Activities automatically appear in the Smart Stack and as alerts using the compact presentation.
- In CarPlay, Live Activities automatically appear on the Home Screen using the compact presentation.
To offer a great experience in StandBy, on Apple Watch, and in CarPlay, provide flexible custom views to keep people informed about the state of a Live Activity and offer interactivity:
- To tell the system that you provide a custom layout on Apple Watch and in CarPlay, pass   to the   view modifier.
- To tell the system that your Live Activity adapts its layout on the Lock Screen of iPhone and iPad, for example in StandBy, pass  to the `supplementalActivityFamilies(_:)`  view modifier.
The following example shows how an app might configure a Live Activity that provides different view layouts for small and medium activity families:

```swift
struct AdventureActivityConfiguration: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AdventureAttributes.self) { context in
            // Create the presentation that appears on the Lock Screen and as a
            // banner on the Home Screen of devices that don't support the
            // Dynamic Island.
            // ...
        } dynamicIsland: { context in
            // Create the presentations that appear in the Dynamic Island.
            DynamicIsland {
                // Create the expanded presentation.
                // ...
            } compactLeading: {
                // Create the compact leading presentation.
                // ...
            } compactTrailing: {
                // Create the compact trailing presentation.
                // ...
            } minimal: {
                // Create the minimal presentation.
                // ...
            }
        }
        ..supplementalActivityFamilies([.small, .medium])
    }
}
```
In your view code, use the  environment value to detect the activity family and change the Live Activity layout accordingly.
The following example shows how a view might respond to different activity families:

```swift
struct CustomSupplementalActivityView: View {
    @Environment(\.activityFamily) var activityFamily
    var context: ActivityViewContext<EmojiRangersAttributes>
    
    var body: some View {
        switch activityFamily {
        case .small:
            SmallSupplementalView(context: context)
        case .medium:
            MediumSupplementalView(context: context)
        }
    }
}
```

> **note:** Live Activities automatically appear in the Menu bar of a paired Mac, offering interactivity and allowing people to launch your app with iPhone Mirroring. Live Activities that appear in the Menu bar use unchanged compact, minimal, and expanded presentations.

For more information about reusing custom views across widgets and Live Activities, refer to .

#### 
Limiting the content you display is key to offering glanceable, easy-to-read Live Activities. Aim to use the system’s default content margins for your Live Activities and only show content that’s relevant to the person viewing it. However, you may want to change the system’s default content margin to display more content or provide a custom user interface that matches your app. To set custom content margins, use .  The following example results in a margin of eight points for the trailing edge of an expanded Live Activity.

```swift
struct AdventureActivityConfiguration: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AdventureAttributes.self) { context in
            // Create the presentation that appears on the Lock Screen and as a
            // banner on the Home Screen of devices that don't support the
            // Dynamic Island.
            // ...
        } dynamicIsland: { context in
            // Create the presentations that appear in the Dynamic Island.
            DynamicIsland {
                // Create the expanded presentation.
                // ...
            } compactLeading: {
                // Create the compact leading presentation.
                // ...
            } compactTrailing: {
                // Create the compact trailing presentation.
                // ...
            } minimal: {
                // Create the minimal presentation.
                // ...
            }
            .contentMargins(.trailing, 8, for: .expanded)
            .contentMargins(.all, 20, for: .expanded)
        }
    }
}
```
If you repeatedly use the `contentMargins(_:_:for:)` modifier, the system uses the innermost specified values for a mode.

> **note:** Avoid placing content too close to the edges of the Dynamic Island.


#### 
Live Activities in the Dynamic Island use a black background color with white text. Use the  modifier to apply a subtle tint color to the border of the Dynamic Island when the device is in Dark Mode and change text color as needed.

> **note:** You can’t change the background color of Live Activities in the Dynamic Island.

By default, the Lock Screen presentation — including the banner that appears on devices that don’t support the Dynamic island — uses a solid white background color in Light Mode and a solid black background color in Dark Mode. To set a custom background color for the Lock Screen presentation, use the  modifier. Be sure to choose a color that works well in both Dark or Light Mode or use different background colors that best fit each appearance. To set the translucency of the custom background color, use the  view modifier or specify an opaque background color.
If you choose a custom background color for the Lock Screen presentation, use the  view modifier to customize the text color of the auxiliary button that allows people to end the Live Activity on the Lock Screen.

> **note:** On devices that include an Always-On display, the system dims the screen to preserve battery life and renders Live Activities on the Lock Screen as if in Dark Mode. Use SwiftUI’s  environment value to detect reduced luminance on devices with an Always-On display and use colors and images that look great with reduced luminance.

## Launching your app from a Live Activity
> https://developer.apple.com/documentation/ActivityKit/launching-your-app-from-a-live-activity

### 
People can tap a Live Activity to launch your app. To let them view more content or make changes to an ongoing task, open your app to the scene that matches the content of the Live Activity.

#### 
If you don’t explicitly provide a deep link into your app, the system opens your app and passes an  to , , or . Implement the appropriate callback and check whether the `NSUserActivity` object’s  is . Then, add code to open a screen in your app that fits the context of the active Live Activity.

> **important:** In CarPlay, tapping your Live Activity only launches your app if it supports CarPlay. For more information about adding CarPlay support to your app, refer to .


#### 
With deep links, you specify an URL that directly launches a specific scene in your app, and choose different scenes for each Live Activity presentation:
- To create a deep link into your app from the Lock Screen, compact leading, compact trailing, and minimal presentations, use . When the compact leading and trailing presentations are visible, make sure both link to the same screen in your app.
- To create a deep link into your app from the extended presentation, use `widgetURL(_:)`  or SwiftUI’s .

#### 
Live Activities automatically appear in the Smart Stack on Apple Watch, and the system shows the Live Activity more prominently on Apple Watch when it receives updates with an alert. When a Live Activity receives an update:
- If a person doesn’t actively use an app on Apple Watch, the system displays an alert that uses the compact presentation’s leading and trailing views, and then launches the Smart Stack, displaying the Live Activity at the top of the stack.
- If a person actively uses any app on Apple Watch, the system shows an alert to let them know about the updated Live Activity.
Tapping the alert displays the Live Activity on Apple Watch and the option to launch the app on iPhone. You can opt-in to give people the ability to open your Watch app from your Live Activity. In the Build Settings for your watchOS app target, add the `Supports Launch for Live Activity Attribute Types` key in the `Info.plist` section. To launch your Watch app for all your Live Activities, leave its value empty. To launch for specific Live Activities, add an item for each  conforming type that launches your watchOS app.


---
# APPINTENTS

## App Shortcuts
> https://developer.apple.com/documentation/AppIntents/app-shortcuts

### 
Create a preconfigured App Shortcut that enables people to discover and run your app intent without any configuration. By creating App Shortcuts, you make your app’s functionality instantly available for use in Shortcuts, Spotlight, and Siri from the moment a person installs your app — without any setup in the Shortcuts app or an Add to Siri button. On iPhone models that support the Action button, people can associate your preconfigured App Shortcut on the Action button for quick access of your app’s functionality.

> **note:** Apple may extract anonymized App Shortcuts data such as localized phrases, display representation values, and the title and description of related intents. Machine learning models use this data when training to help improve the App Shortcuts experience.

Key app functionalities that people use to complete a task quickly and that you expose to the system with app intents are great candidates for App Shortcuts. For each high-value app intent, create an App Shortcut that specifies the intended action, the required parameters, the spoken phrases someone uses to run it, and the short title and the image that appear in the Shortcuts app.
To offer an App Shortcut:
1. Create an app intent for a key app functionality as described in .
2. Create the  object for your app intent using the  initializer with phrases people can use to run the app intent and with the metadata that appears in the Shortcuts app.
3. Implement the  protocol that provides the App Shortcuts you offer to the Shortcuts app.
With these three steps, you make your app’s functionality more discoverable and enable people to interact with your app in a lightweight way. However, the system displays a default interface for your App Shortcut. To display a custom view for each shortcut, return a SwiftUI view in your app intent’s  method.

> **note:**  and .


### 
With App Shortcuts, you can also preconfigure phrases for app intents that use specific parameters. When you include parameters, people can use one phrase to start an interaction with an app without Siri having to ask for clarification. For example, a meditation app could offer an app intent to start a meditation with the phrase “Start a meditation”. Because the app offers many different meditations, Siri would require an additional clarification which meditation a person wants to start.
With an App Shortcut, you can supply preconfigured parameters ahead of time that enable a person to skip this clarification step. For example, the meditation app could provide parameterized phrases where each phrase represents a common meditation. A person could then start a meditation with one phrase like “Start a mindfulness meditation.” or “Start a short meditation.”

### 
Although App Shortcuts don’t require a person to do any configuration in the Shortcuts app or by using the Add to Siri button, you may want to present elements in your app to tell people about an available App Shortcut. You have two options:
-  and  present a view that tells a person that an App Shortcut is available.
-  enables you to display a link to your App Shortcut.
`ShortcutsLink` is especially convenient if your app displays a list of its available App Shortcuts.

## Making actions and content discoverable and widely available
> https://developer.apple.com/documentation/AppIntents/making-actions-and-content-discoverable-and-widely-available

### 
The App Intents framework offers functionality to express your app’s actions and data in a way that enables deep integration with system capabilities Apple Intelligence provides and system experiences like Spotlight. Use App Intents to enable people to view your app’s content and to use its actions when and where they need them — whether they’re using your app or are elsewhere in the system.
The App Intents API is a fundamental framework that facilitates deep integration with system experiences across platforms and devices. You use the framework to express data and actions once to build a reusable foundation for many experiences and features. For example, use App Intents to integrate your app with Siri and Apple Intelligence, then reuse the code to create controls and interactive widgets in combination with .

> **note:** Siri’s personal context understanding, onscreen awareness, and in-app actions are in development and will be available with a future software update.


#### 
When you use the App Intents framework to express your app’s actions and data, you integrate your app with system experiences that offer broad visibility for your app and content and make its functionality available outside of the app itself; for example:
- People will use Siri to perform app actions.
- People find App Shortcuts you create in the Shortcuts app and initiate them throughout the system, across platforms and devices with Siri, Spotlight, the Action button, Apple Pencil Pro, and more.
- Using the Shortcuts app, people create custom shortcuts with your app’s functionality and entirely new workflows across apps.
- People reduce distractions with Focus, and you use the App Intents framework to respond to Focus changes.
On supported devices, the App Intents framework will provide integration with Apple Intelligence, a personal intelligence system that deeply integrates powerful generative models into the core of iPhone, iPad, and Mac. Siri will draw on the capabilities of Apple Intelligence to deliver assistance that’s natural, contextually relevant, and personal for everyone, including in the apps they use every day. The App Intents framework will enable you to express your app’s capabilities and content, giving the system access to this context and integrating your app with Siri and Apple Intelligence, and unlocking new ways for people to interact with it from anywhere on their device. For more information, refer to .

#### 
Across devices, your app’s content and actions appear in additional system experiences you create with a combination of the App Intents framework and other frameworks. As a result, adopting App Intents not only helps you adopt features the framework enables directly, it allows you to easily support additional system experiences that increase your app’s reach and allow people to personalize how they use your app. Use the App Intents framework to describe actions and content together with:
-  to offer interactive and configurable widgets, watch complications, and controls
-  to offer interactive Live Activities
-  to enable people to find your content using semantic search in Spotlight

#### 
If you’re new to the App Intents framework, first evaluate your app’s functionality and content. The framework is a fundamental building block for apps, and enables a broad range of user experiences, so it’s important to design a new app with App Intents functionality in mind. Similarly, consider a measured, thoughtful approach when adopting App Intents in your existing app.
To get started:
1. Understand the role of the App Intents framework and the experiences it enables.
2. Review key framework concepts and create a first implementation that launches your app with an  and add an App Shortcut. For more information, see  and .
3. Express additional actions and content using the App Intents framework.
4. Integrate actions and content with Siri and Apple Intelligence. For more information, see  and .
5. Depending on your app’s functionality, add support for additional system experiences and interactions that fit your app’s functionality. For example, respond to Focus changes as described in  or add support for the Action button and squeeze gestures on Apple Pencil Pro, as described in .

#### 
If you’re currently using the App Intents framework in your app, you might limit app intents to selected actions and content. The App Intents framework will provide integration with Siri and Apple Intelligence for every action of your app and its content. Review your app’s actions and content, and consider expressing actions and content with App Intents.

#### 
People use app intents to automate workflows with custom shortcuts and . As a result, removing  code or an App Shortcut from your app can break people’s workflows and confuse or frustrate them because previously available functionality might stop working. Keep this in mind when you adopt the App Intents framework and consider a deprecation strategy for your  code. When you plan to remove an , give people notice about your intention to remove the app intent. Publish a release where you change an existing  to  and offer people a suggested replacement. After giving people enough time to update their custom shortcuts and move to new App Shortcuts, remove the  from your app.

#### 
For new functionality, use the App Intents framework to integrate your app with system experiences like widgets, controls, and Live Activities. Siri and Apple Intelligence automatically will leverage SiriKit intents. For existing functionality keep existing SiriKit implementations and take a measured approach to replacing SiriKit code with App Intents. If you remove code that uses SiriKit, give people advance notice about changes to avoid breaking their existing custom shortcuts and make sure to provide the same or comparable functionality that uses App Intents.
For more information about migrating your SiriKit code to App Intents, see .


---
# AVFOUNDATION

## Media playback
> https://developer.apple.com/documentation/AVFoundation/media-playback

### 
You use a player to manage the playback and timing of a media asset, for example starting and stopping playback, and seeking to a particular time. A player manages the playback of a single media asset at a time. The framework also provides a queue player that queues media assets to play sequentially.

> **note:**  When you use AVFoundation, Apple may collect metrics to help improve the framework.

You create an instance of  to play a media asset. A player item manages the timing and presentation state of an asset played by the player. A player item also contains player item tracks that correspond to the tracks in the asset. You direct the output of a player to a specialized Core Animation layer, a player layer, or a synchronized layer.

> **important:**  You must call the  function if your app requires Afterburner accelerated playback and decoding of ProRes and ProRes RAW video files.

## Observing playback state in SwiftUI
> https://developer.apple.com/documentation/AVFoundation/observing-playback-state-in-swiftui

### 
An essential task when building custom media players is observing the state of playback objects to determine their readiness for playback and track other important lifecycle events. The way you typically do this is using key-value observing, but starting in iOS 26, tvOS 26, macOS 26, and visionOS 26, AVFoundation provides a new way to monitor playback state based on the  framework. AVFoundation supports this framework by making its core playback types conform to the  protocol. This means you can use  or , along with their associated  and  objects to drive state changes directly within your SwiftUI views.

### 
AVFoundation supports monitoring playback state with Observation, but it doesn’t enable this feature by default. Instead, you opt-in to this behavior by setting a `true` value for the  `isObservationEnabled` property of the  class.

```swift
// Opt-in to observing with the Observation framework.
AVPlayer.isObservationEnabled = true
```
Perform this opt-in early in your app lifecycle, such as in your main  structure or  (in a mixed UIKit and SwiftUI app). This setting is global to your app and must be set  creating playback objects. Attempting to change its value after creating these objects results in AVFoundation throwing an exception.

### 
You define a single source of truth in your app using a SwiftUI  variable. This property wrapper always instantiates its default value when SwiftUI creates a view. When using it to store playback objects, either directly or as part of a custom `@Observable` model object, avoid performance issues or other potential side effects by deferring the creation of these objects by using the doc://com.apple.documentation/documentation/swiftui/view/task(priority:_:) modifier. For example, in a simple playback case you could define a state variable to hold a player object and initialize it like shown below:

```swift
struct PlayerView: View {
    let url: URL
    // Don't create the player directly to avoid performance issues or other side effects.
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            if let player {
                VideoView(player: player)
                TransportView(player: player)
            } else {
                LoadingView()
            }
        }
        // Use the task modifier to defer creating the player to ensure
        // SwiftUI creates it only once when it first presents the view.
        .task {
            player = AVPlayer(url: url)
        }
    }
}
```
Using the task modifier ensures that SwiftUI initializes the player object only once when it first presents the view.

### 
Because the playback objects adopt the  protocol, you can use them directly within SwiftUI views like any other `@Observable` object. For example, you can pass a player instance to a view and have the view automatically redraw itself as playback state changes.

```swift
struct TransportView: View {
    
    // A player object passed from the view that owns the player reference.
    let player: AVPlayer
    
    // Observe the time control status property to determine whether playback is active.
    private var isPlaying: Bool {
        player.timeControlStatus == .playing
    }
    
    var body: some View {
        // A button that toggles the state of playback.
        Button {
            if isPlaying {
                player.pause()
            } else {
                player.play()
            }
        } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
        }
        // Observe the player item's status property to determine when to enable the button.
        .disabled(player.currentItem?.status != .readyToPlay)
    }
}
```
The transport view defines an `isPlaying` property that uses the player object’s  property to determine whether it’s actively playing media. It uses this property to drive changes to the button’s presentation and behavior. The view also observes the current player item and enables the button only after the item’s  indicates it’s ready to play.

> **note:** You can use Observation to monitor general state properties like a player’s  or , but it isn’t suitable for observing continuous state changes like the current playback time. Instead, use the dedicated periodic and boundary time observation methods for this purpose. For more information, see .


---
# ADATTRIBUTIONKIT

## Configuring attribution rules for your app
> https://developer.apple.com/documentation/AdAttributionKit/configuring-attribution-rules-for-your-app

### 
AdAttributionKit provides a mechanism to configure the attribution rules that you change in your app by adding and configuring keys in the information property list.
The structure of the AdAttributionKit additions to the information property list include stanzas that you can use to control the duration of impressions that the system considers eligible for attribution for your app. You can also control the cooldown period — the minimum amount of time that needs to pass between conversions before the system accepts new conversions.
There are two main configuration sections:
- The AttributionWindows settings that controls the time duration that impressions will be valid in your app.
- The AttributionCooldown settings that allows your app to specify how often a conversion can happen.
Inside each of these sections are additional keys that that tune the behavior of their respective controls and allow you defined what ad networks they pertain to, or if they’re global settings.

### 
AdAttributionKit uses your app’s information property list to hold its configuration settings. To enable this configuration, add a new dictionary named `AdAttributionKitConfigurations` to the information property list.
Inside this dictionary, you place additional dictionaries, or individual keys that control the attribution windows and cooldown periods, depending on your app’s requirements. To create the `AdAttributionKitConfigurations` dictionary, open your app’s Xcode project and follow these steps:
1. Open your app’s project in Xcode.
2. Go to the file navigator.
3. Locate your app’s target, and select its filename.
4. Click the app’s Info panel.
5. Click the plus (+) button next to any existing entry to create a new element in the information property list.
6. Set the new element’s name to `AdAttributionKitConfigurations`.
7. Click the Type menu for the new `AdAttributionKitConfigurations` element, and select `Dictionary` as its type.
8. Click the disclosure triangle next to the `AdAttributionKitConfigurations` element to open it.
To complete the configuration, add one or more of the following addition-controlling elements, depending on the AdAttributionKit configuration you want to use with your app.

> **note:** For clarity, these examples show XML renderings of the dictionaries and keys that control the AdAttributionKit attribution windows and cooldown periods. In practice, use Xcode’s’ information property list editor to create and edit these settings.


### 
You can specify the time duration that impressions are valid in your app by using configurable attribution windows. By default, view impressions are valid for 1 day after someone has seen them, and click impressions are valid for 30 days. With configurable attribution windows, you can specify a duration from 1 to 7 days for view impressions, and 1 to 30 days for click impressions.
To create configurations for individual or global ad networks, `AdAttributionKitConfigurations` needs a dictionary to contain them. To create this dictionary, follow these steps:
1. Inside the new `AdAttributionKitConfigurations`, add a new element named `AttributionWindows`.
2. Click the Type menu for the new `AttributionWindows` element, and set its type to `Dictionary`.
3. Click the disclosure triangle next to the new `AttributionWindows` element to open it.
Your app can configure the attribution window globally, so that the framework applies it to all conversions, as well as on a per-ad network basis. This allows you to control the levels of granularity and define the attribution rules that make the most sense for your business. The system uses the following order of precedence for configurations: ad network > global > system default, where an ad network configuration always takes precedence over a global or system default configuration.

### 
There are two types of global settings the attribution window settings support:  that apply to ad networks, and  that control specific parameters relating to conversions for the ad networks you specify.
To override the built-in, global attribution window settings, follow these steps:
1. Create a new dictionary named `global` inside the `AttributionWindows` dictionary in your app’s information property list.
2. Inside this dictionary, create another, nested dictionary called `install`. This describes the kind of operation whose window you’re defining.
3. Inside the `install` dictionary, you can specify numeric values for either `click` or `view` values. The click value determines the number of days that click impressions are valid for your app globally, with a range from `1` to `30` days. The view value determines the number of days that view impressions are valid for your app globally, with a range from  `1` to `7` days. This example shows an XML rendering of a `global` dictionary inside the `AttributionWindows` dictionary that constrains `view` to `3` days:

```xml
    <key>AdAttributionKitConfigurations</key>
    <dict>
        <key>AttributionWindows</key>
        <dict>
            <key>global</key>
            <dict>
                <key>install</key>
                <dict>
                    <key>view</key>
                    <integer>3</integer>
                </dict>
            </dict>
        </dict>
  </dict>
```

### 
You can also overwrite attribution windows for your app on a per-ad network basis, giving you more granular control of your app’s attribution windows for each partner you work with. To configure an attribution window for an ad network, follow these steps:
1. Create a new dictionary named `AttributionWindows` inside of the `AdAttributionKitConfigurations` dictionary in your app’s information property list.
2. Add additional dictionaries to the `AttributionWindows` dictionary — one per ad network — to control the `click` and `view` windows for that network. These network-specific dictionaries need to have a key name that matches the ad network’s ID (for example, `test.adattributionkit`). For more information on ad network IDs, see .
3. Inside this dictionary, add an `install` dictionary — following the same steps as for the `global` configuration — to control either the `click` or `view` duration. As with the `global` settings, this `install` dictionary needs to be inside the `AttributionWindows` dictionary.
The time ranges are the same as for the global install dictionary. This example shows an XML rendering of a dictionary for the ad network `test.adattributionkit`, constraining clicks to `23` days:

```xml
        <key>AttributionWindows</key>
        <dict>
            <key>test.adattributionkit</key>
            <dict>
                <key>install</key>
                <dict>
                    <key>click</key>
                    <integer>23</integer>
                </dict>
            </dict>
        </dict>
```
Additionally, you can specify the key `ignoreInteractionType` inside the install dictionary. You can set the `ignoreInteractionType`key to `view` or `click`, which tells the system to ignore impressions with either a `view` or `click` ad interaction type from the specific ad network during attribution. This is useful for prioritizing either `view` or `click` attributions for your app when working with a specific ad network.
The following code shows an XML rendering of an `AdAttributionKitConfigurations` dictionary that contains `AttributionWindows` settings for both `global` and a specific ad network:

```xml
    <key>AdAttributionKitConfigurations</key>
    <dict>
        <key>AttributionWindows</key>
        <dict>
            <key>global</key>
            <dict>
                <key>install</key>
                <dict>
                    <key>view</key>
                    <integer>3</integer>
                </dict>
            </dict>
            <key>com.apple.test.itms11.2</key>
            <dict>
                <key>install</key>
                <dict>
                    <key>ignoreInteractionType</key>
                    <string>view</string>
                    <key>click</key>
                    <integer>5</integer>
                </dict>
        </dict>
    </dict>
```

> **important:** You can only ignore an interaction type for ad network configurations. The system doesn’t recognize ignored interaction types in global configurations.


### 
Configurable attribution cooldown allows your app to specify a duration after the last conversion in which the system won’t create any new conversions for your app. Consider the following scenario: someone installs your app from an ad, then within two hours taps another ad and re-engages back into your app. By default, the system creates a re-engagement conversion for the second tap, but your business model may consider the initial conversion as the more important signal. Configurable attribution cooldown allows you to specify a period in which the system ignores subsequent re-engagements.
You can specify a cooldown period for install conversions as well as re-engagement conversions. To specify a cooldown period after an install conversion, follow these steps:
1. Define a dictionary with the key `AttributionCooldown` inside the `AdAttributionKitConfigurations` dictionary.
2. Inside `AttributionCooldown`, add a new element with the name `install-cooldown-hours`.
3. Using the Type menu, set its type to `Number`. This value represents the number of hours the system will wait after an install conversion before accepting new conversions.
This example shows an XML rendering of a dictionary for the `AttributionCooldown` that sets the installation cooldown period to 24 hours:

```xml
            <key>AttributionCooldown</key>
            <dict>
                 <key>install-cooldown-hours</key>
                 <integer>24</integer>
            </dict>
```
Alternatively, you can specify a cooldown period after a re-engagement conversion. In this case, name the number key `re-engagement-cooldown-hours`. This value represents the number of hours the system waits after a re-engagement conversion before accepting new conversions.
The system accepts values with a range of `0` to `720` hours for both install and re-engagement cooldown periods.

## Identifying the parameters in a postback
> https://developer.apple.com/documentation/AdAttributionKit/identifying-the-parameters-in-a-postback

### 
The lists in this article describe all the possible parameters you can get in a postback. To verify that Apple signed the postback, see .

### 
The JSON stanza your servers receive resembles the following:

```json
{
  "jws-string": "eyJraWQiOiJhcHBsZS1kZXZlbG9wbWVudC1pZGVudGlmaWVyXC8xIiwiYWxnIjoiRVMyNTYifQ.eyJwb3N0YmFjay1pZGVudGlmaWVyIjoiODU1NDZFQjctRkQzOS00NEJDLTg5OTAtQzk4QTRBQzM2QTQ5IiwicHVibGlzaGVyLWl0ZW0taWRlbnRpZmllciI6MCwibWFya2V0cGxhY2UtaWRlbnRpZmllciI6ImNvbS5hcHBsZS5BcHBTdG9yZSIsImltcHJlc3Npb24tdHlwZSI6ImFwcC1pbXByZXNzaW9uIiwiYWQtbmV0d29yay1pZGVudGlmaWVyIjoiZGV2ZWxvcG1lbnQuYWRhdHRyaWJ1dGlvbmtpdCIsImRpZC13aW4iOnRydWUsInBvc3RiYWNrLXNlcXVlbmNlLWluZGV4IjowLCJjb252ZXJzaW9uLXR5cGUiOiJyZS1lbmdhZ2VtZW50Iiwic291cmNlLWlkZW50aWZpZXIiOiIxMjM0IiwiYWR2ZXJ0aXNlZC1pdGVtLWlkZW50aWZpZXIiOjEwNzM4MDI3NzU2fQ.bAdNwKd6OfHK9tofvjjua4X_JPcFTxXPQSspD9gZkinw97pY7R1aI-LSjl-oxZZF3_K2H5JK5TSEBee4_1U4oQ",
  "conversion-value": 24,
  "ad-interaction-type": "click",
  "country-code": "US"
}
```
The keys in this stanza may include:

### 
The JWS header of the postback consists of two parameters and resembles the following structure:

```json
{
  "kid": "apple-development-identifier/1",
  "alg": "ES256"
}
```
The keys for this structure are:

### 
The JWS decoded payload of the postback resembles the following structure:

```json
{
  "postback-identifier": "85546EB7-FD39-44BC-8990-C98A4AC36A49",
  "publisher-item-identifier": 0,
  "marketplace-identifier": "com.apple.AppStore",
  "impression-type": "app-impression",
  "ad-network-identifier": "development.adattributionkit",
  "did-win": true,
  "postback-sequence-index": 0,
  "conversion-type": "re-engagement",
  "source-identifier": "1234",
  "advertised-item-identifier": 10738027756
}
```
The keys the framework delivers in this structure may include the following:

### 
The signature is a combination of the JSON Web Signature (JWS) header and payload components that Apple signs using its private key.
For more information about verifying the postback’s signature, see . For more information about receiving postbacks, see .

### 
To help ensure crowd anonymity, Apple assigns a postback data tier to app downloads. The postback data tier determines whether certain parameters appear in the postback, as well as the number of digits in the hierarchical source identifier. The following postback parameters are subject to the postback data tier:
- `coarse-conversion-value`
- `conversion-value`
- `source-identifier` (affects the number of digits the postback returns)
- `publisher-item-identifier`
- `marketplace-identifier`
- `country-code`

## Receiving postbacks in multiple conversion windows
> https://developer.apple.com/documentation/AdAttributionKit/receiving-postbacks-in-multiple-conversion-windows

### 
AdAttributionKit supports three conversion windows that can result in up to three postbacks for a winning ad attribution. The conversion window begins when the user first launches the app. The first conversion window spans days 0 to 2; the second window spans days 3 to 7; and the third window spans days 8 to 35. Apps can update conversion values during all three time-windows.
To be eligible to receive multiple postbacks, the advertised app needs to call or to update the conversion values during each conversion window.
You can receive a single postback in the following cases:
- If the app’s postback data tier is Tier 0, the system sends only the first postback.
- Nonwinning ad attributions receive only one postback.

### 
By default, the system waits until the end of a conversion window to get the final conversion value. Apps can continue to update the conversion value until the end of the conversion window. When the conversion window ends, the system prepares the postback and sends it after a random delay:

The random delay is 24 to 48 hours for the first postback, and 24 to 144 hours for the second and third postbacks.
The method provides an option for you to lock in and finalize a conversion value before the conversion window ends. You can choose to lock the conversion value in any or all conversion windows. Below illustrates an app that locks the conversion value during the second conversion window:

After receiving a locked conversion value, the system immediately prepares the postback and ignores any further conversion value updates in the same conversion window. The system sends the postbacks after the same random delay following the locked conversion: a 24 to 48-hour delay for the first postback, and a 24 to 144-hour delay for the second and third postbacks. The system ignores further updates to the conversion value for the remaining time in the same conversion window.

### 
To help maintain users’ privacy and ensure crowd anonymity, the device may limit the data that AdAttributionKit sends in postbacks. Apple determines a postback data tier that it assigns to each app download. The following depicts a hypothetical relationship between the tiers and relative crowd sizes.

The postback data tier takes into account the crowd size associated with the app or domain displaying the ad, the advertised app, the country the advertised app was installed in, and the hierarchical source identifier that the ad network provides. The system computes the postback data tier for the two-, three-, and four-digit hierarchical source identifiers. It selects the source identifier with the highest postback data tier. If multiple source identifiers share the highest postback data tier, the system selects the source identifier with the most digits. If the highest postback data tier is Tier 1 or Tier 0, the system always selects the two-digit source identifier.
The postback data tier affects the following fields in the postback, which may be present or absent, or may contain a limited number of digits:
- `source-identifier`, the hierarchical source identifier that may include two, three, or four digits
- `conversion-value`, a fine-grained conversion value available only in the first postback
- `coarse-conversion-value`, a coarse conversion value that the system sends instead of the conversion value in lower postback data tiers, and in the second and third postbacks
- `publisher-item-identifier`, the app item identifier of the publisher app
- `marketplace-identifier`, the bundle id of the alternative marketplace from which the conversion came; the framework omits this property from Tier 0 postbacks.
- `country-code`, an optional field representing the country the app is installed in. The system adds this field if the crowd size for a particular country is Tier 3.
The remaining postback data fields aren’t dependent on the postback data tier and appear in all postbacks, based on the AdAttributionKit version of the postback.

### 
The first conversion window ends two days after the user first launches the app. The system prepares the postback after the conversion window ends, unless you use a lock. If you use a postback lock, the system prepares the first postback when the app calls  with the lock in an enabled state. The system then sends the postback after a random 24 to 48-hour delay.
The postback data tier determines the data you receive in the first postback, as follows.
For ads in Tier 3, the first postback contains:
- `source-identifier`, the hierarchical source identifier with two, three, or four digits
- `conversion-value`, the fine-grained conversion value, if the app provides one
- `publisher-item-identifier`, the identifier for ads that display in apps
- `country-code`, an optional field representing the country the app is installed in. The system adds this field if the crowd size for a particular country is Tier 3.
For ads in Tier 2, the first postback contains:
- `source-identifier`, the hierarchical source identifier with two, three, or four digits
- `conversion-value`, the fine-grained conversion value, if the app provides one
For ads in Tier 1, the first postback contains:
- `source-identifier`, the hierarchical source identifier with two digits
- `coarse-conversion-value`, a coarse value, if the app provides one
For ads in Tier 0, the first postback contains the source-identifier, which is the hierarchical source identifier, with two digits.

### 
The second conversion window ends seven days after the user first launches the app, and the third conversion window ends after 35 days. The system prepares the second and third postbacks after their conversion windows end, and sends them after a random 24 to 144-hour delay.
If you use a lock with the second or third conversion value updates, the system prepares the postback when you call  with the lock in an enabled state. The system sends the postback after a random 24 to 144-hour delay.
The postback data tier determines the data you receive in the postbacks, as follows.
For ads in Tier 1, Tier 2, and Tier 3, the second and third postbacks contain:
- source-identifier, the hierarchical source identifier with two digits
- coarse-conversion-value, the coarse conversion value, if the app provides one
For ads in Tier 0, the system doesn’t send a second or third postback.


---
# APPCLIP

## Configuring App Clip experiences
> https://developer.apple.com/documentation/AppClip/configuring-the-launch-experience-of-your-app-clip

### 
People launch your App Clip by performing an  — for example, by scanning an App Clip Code or tapping a Smart App Banner on a website. Upon launch, the App Clip receives an  that determines what information appears on the App Clip card. To offer the best launch experience for a person’s current context, use the invocation URL on launch to update the UI of your App Clip.
To configure invocation URLs and the metadata that appears on the App Clip card, create the required  in . For more advanced use cases — for example, to associate an App Clip with a physical location or to create an App Clip for multiple businesses — configure optional .

> **important:**  In some cases, the App Clip doesn’t receive an invocation URL upon launch. Make sure to handle this use case in your code. For more information on responding to invocations where the invocation URL isn’t available, refer to  .

The actual configuration of your App Clip experiences typically happens when you upload the first build that contains an App Clip to App Store Connect. However, it’s important to understand how App Clip experiences work before you start developing your App Clip. Identify invocations and invocation URLs, and plan changes to your code before or in parallel with the implementation of your App Clip. Additionally, to support advanced App Clip experiences or iOS versions older than iOS 16.4, you need to make changes to your server to associate your App Clip with your website.

#### 
People don’t search the App Store for an App Clip. They discover it when and where they need it, and launch the App Clip by performing one of the following invocations:
- Scanning an App Clip Code, NFC tag, or QR code at a physical location
- Tapping a location-based suggestion from Siri Suggestions
- Tapping a link in the Maps app
- Tapping a Smart App Banner on a website in Safari or an app that uses 
- Tapping the action button of an App Clip card that appears in Safari or an  (requires iOS 15 or later)
- Tapping a link that someone shares in the Messages app (as a text message only)
- Tapping an App Clip preview or link to an App Clip in another app (requires iOS 17 or later)
- Tapping a link to an App Clip in an email or on a website

With each invocation, the system verifies whether the invocation URL matches the invocation URL in App Store Connect. After it verifies the invocation, the system uses the invocation URL to determine which App Clip experience to use for launching your App Clip. It then uses the App Clip experience’s metadata to populate the App Clip card and passes the invocation URL to the App Clip.

> **important:**  When people install the corresponding app for an App Clip, the full app replaces the App Clip. Every invocation from that moment on launches the full app instead of the App Clip. As a result, the full app must handle all invocations and offer the same functionality that the App Clip provides.


#### 
No matter which invocation method you want to support, you need to create a default App Clip experience in . With a default App Clip experience, App Store Connect generates a default App Clip link that supports common invocations, without requiring any changes to your server. For some App Clips, this default experience and the default App Clip link may be enough to provide their functionality.
However, your App Clip might benefit from using a custom link for your default experience, or the generated App Clip demo link. Additionally, depending on the functionality your app and App Clip provide, you may need to configure advanced App Clip experiences in addition to the default App Clip experience.
The following table shows the invocations each experience and link type supports:
| Invocations and URL constraints | Default App Clip experience with default link | Default App Clip experience with an associated website | App Clip demo link | Advanced App Clip experience |
| A Smart App Banner or the App Clip card on your website | No | Yes | No | Yes, if you associate your website with the App Clip. |
| A shared link to an App Clip in the Messages app | Yes | Yes | Yes, with a limited preview. | Yes, if you associate your website with the App Clip. |
| QR codes | Yes | Yes | Yes | Yes |
| NFC tags | Yes | Yes | Yes | Yes |
| App Clip Codes | No | No | Yes, if you use the short version of the demo link. | Yes |
| Maps | No | No | No | Yes |
| Spotlight search | Yes, excluding location-based Spotlight suggestions. | Yes, excluding location-based Spotlight suggestions. | Yes, excluding location-based Spotlight suggestions. | Yes |
| Another app that uses | Yes | Yes | Yes | Yes |
| Another app that uses  or | Yes | Yes | Yes | No |
| Supports URL parameters | Yes | Yes | No | Yes |
If you don’t have a website for your app or don’t want to support invocations that require an associated website, configure the default experience and use the default link for your invocations. If you support iOS 16.3 and earlier or want to support additional invocations, including showing an App Clip card on your website, associate your website with your App Clip.

> **important:** Testing and using default and demo links requires your app and App Clip to pass App Store review and to be available in the App Store. For more information on testing App Clips, see .

You can use the generated demo URL to offer a demo version of your app that launches from physical and digital experiences. Note that the demo URL doesn’t replace the default App Clip experience. It allows you to use the default App Clip experience, support digital and physical invocations, and create an App Clip with a larger uncompressed binary size. For more information, see .
Configure an advanced App Clip experience if:
- You want your App Clip to support all possible invocations on devices that run iOS 16.3 and earlier.
- You want to display a Smart App Banner and an App Clip card on an additional website that uses a different subdomain or domain.
- You need to associate your App Clip with a physical location.
- You create an App Clip for multiple businesses to use.

#### 
An App Clip always requires a corresponding full app, and you submit your App Clip binary together with your full app’s binary to . After you’ve uploaded your full app to App Store Connect, configure a default App Clip experience. Navigate to the page for the app version that offers an App Clip, expand the App Clip section, and provide the following metadata for the App Clip card:
- A header image
- Copy for the App Clip card’s subtitle
- The call-to-action verb that appears on the Action button people tap to launch the App Clip
For your default App Clip experience, the invocation URL that’s available to the App Clip on launch can be:
- The default App Clip link that the system generates for you for your default App Clip experience
- The App Clip demo link that the system generates for you
- The URL of the website you associated with the App Clip and that displays the Smart App Banner and the App Clip card

#### 
The default App Clip link is a URL generated by Apple that invokes your App Clip without additional setup on your server. They follow this URL scheme: `https://appclip.apple.com/id?=<bundle_id>&key=value.` Instead of the `<bundle_id>` placeholder, your default App Clip link includes the bundle ID of your app. Optionally, it can include parameters you pass with the invocation, represented as `&key=value`. For example, a default App Clip link from a QR code for a coffee shop’s app might be `https://appclip.apple.com/id?=com.example.Clip&promotion=WWDC23.` , using `promotion` as the `key` and `WWDC23` as the value for the launch parameters.
App Store Connect generates an App Clip demo link when you configure the default App Clip experience. With the demo link, you can offer an App Clip that’s a demo version of your app. Its uncompressed App Clip binary can be larger in size and supports all invocations, including physical invocations. However, App Clip demo links can’t contain URL parameters.

> **note:** If you provide a task-oriented App Clip that helps people achieve a goal, often while they are on-the-go and might experience slow internet connections, use the autogenerated default App Clip link or a custom short invocation URL – which requires you to associate your App Clip with your website. Reserve usage of the demo URL if you offer a demo version of your app.

The default and demo App Clip links offer functionality without changes to your server. However, associating your App Clip with your website and making changes to your server comes with benefits: The website can display a Smart App Banner or the App Clip card. For example, a shop might associate its App Clip with its website on https://example.com. To launch the App Clip, the website displays a Smart App Banner at various locations, for example:
- `https://example.com/menu`
- `https://example.com/contact`
- `https://example.com/menu/breakfast`
- `https://example.com/menu/lunch`
The website also displays the App Clip card on `https://appclip.example.com/,` a dedicated page that promotes the App Clip. Upon launch, the App Clip receives the website’s URL as the invocation URL and displays the functionality in the App Clip that matches the URL — for example, the coffee shop’s lunch menu.
For additional information about associating your App Clip with your website, refer to  .

#### 
The App Clip card is the first thing people see when they discover your App Clip, which makes the App Clip card’s design especially important. To explore different imagery and text, and to test their appearance on your device, use local experiences as described in .
An effective App Clip card matches a person’s context. For example, a business with multiple physical locations might display imagery that matches the person’s current location. Each physical location might correspond to a different image and text on the App Clip card. However, it’s not possible to programmatically change the content on the App Clip card. Instead, configure an advanced App Clip experience in App Store Connect for each context that needs its own App Clip card. You can choose text and imagery for each advanced App Clip experience.
You can also localize the text that appears on the App Clip card in App Store Connect. For more information on localization, refer to  .

> **note:**  Keep the text that appears on the App Clip card short: Use up to 30 characters for the title and up to 56 characters for the subtitle.


#### 
To support additional invocations (for example, from scanning an App Clip Code), create an advanced App Clip experience in .

> **important:**  If you’re using a URL with a different domain than the default App Clip link, make sure the system can verify the association between your App Clip and the domain. For more information, refer to  .

In App Store Connect, select your App, and then select the iOS app version for which you want to add an advanced App Clip experience. Then, click Edit Advanced Experiences and create an advanced App Clip experience. For more information, refer to   in the App Store Connect Help.

> **important:**  To set up an advanced App Clip experience that appears in Apple Maps, create a place association that connects the App Clip experience to a physical location. Apple Maps uses any location data that you provide solely for matching an App Clip experience to an existing location. If it can’t find a match, Apple Maps doesn’t use the provided location data.

In your Xcode project, add or modify code for both your App Clip and your full app to respond to the new URL you registered. For more information, refer to  .
Consider the previous example for a coffee shop’s App Clip: It would use the default App Clip experience with `https://example.com` because that’s the domain associated with the App Clip. In addition, it would use one advanced App Clip experience with `https://example.com` as its invocation URL, and generate an App Clip Code for the advanced App Clip experience. In its code, the App Clip handles the invocation from an App Clip Code just like an invocation from Smart App Banners, the App Clip card on a website, and the Messages app.

#### 
In general, try to register as few URLs as possible, and register generic URLs to take advantage of . Upon invocation, the system matches the invocation URL against URLs you registered as part of your advanced App Clip experiences. The system then chooses the App Clip experience with the URL that has the most specific matching prefix. This means that you can register one URL to cover many cases.
Consider the example for a coffee shop. By registering one advanced App Clip experience with `https://example.com` as its invocation URL, it’s possible to handle invocation URLs, for example:
- `https://example.com/menu`
- `https://example.com/contact`
- `https://example.com/menu/breakfast`
Upon launch, the App Clip receives a URL, then extracts path components and query parameters and uses them to update its UI so that it corresponds to the URL and matches the person’s context.
If the coffee shop has multiple physical locations, its App Clip could use one advanced App Clip experience for each location with a different header image, metadata, and invocation URL — for example, `https://example.com/location1`, `https://example.com/location2`, and so on. The App Clip could then, similar to the previous example, extract path components and query parameters to update its UI for each App Clip experience.
For additional information, refer to  .

#### 
An App Clip Code is immediately recognizable to people and lets them know that an App Clip is available. The App Clip Code offers a fast and secure launch experience for your App Clip that people trust. Although App Clip Codes are a great way to launch your App Clip, an App Clip Code can only contain a limited amount of information in its visual code or NFC tag. If you plan to support invocations from App Clip Codes, refer to   and .

#### 
In some cases — for example, if you already use shortened URLs to deep link into your app — you may want to launch your App Clip from a short URL in addition to a long URL. In other cases, you may want to redirect from the short URL to a URL with a long path or many query parameters.
You may create both short and long URLs, as well as make URL redirects to launch App Clips. However, you need to set up both the short URL and the long URL to invoke your App Clip. For example, you may want to use `https://some.subdomain.example.com/path/to/thing?query=1234` as the invocation URL for your App Clip and a shorter URL — for example, `https://appclip.example.com?id=1` — that redirects to the long URL. For the URL forwarding to work, add both `https://some.subdomain.example.com` and `https://appclip.example.com` to your list of associated domains. Make sure to place an AASA file into the corresponding `.well-known` directory for each subdomain. Then, create App Clip experiences for both URLs.
For additional information, refer to   and .

#### 
The App Store Connect website offers a convenient way to create and manage your default and advanced App Clip experiences. However, if you need to manage a large number of App Clip experiences, using the website may be too cumbersome. For example, say your App Clip allows people to order food at a chain restaurant with dozens, hundreds, or even thousands of locations. For each location, you likely want to display imagery on the App Clip card for that specific restaurant. As a result, you need to create an advanced App Clip experience for each location.
To help you create and manage a large number of App Clip experiences, use the App Store Connect API to automate these tasks. For more information, refer to  .


---
# AUTHENTICATIONSERVICES

## Implementing User Authentication with Sign in with Apple
> https://developer.apple.com/documentation/AuthenticationServices/implementing-user-authentication-with-sign-in-with-apple

### 
This sample app, Juice, uses the  framework to provide users an interface to set up accounts and sign in with their Apple ID. The app presents a form in which the user can create and set up an account for the app, then authenticates the user’s Apple ID with Sign in with Apple, and displays the user’s account data.
For more information about implementing Sign in with Apple on iOS 12 and earlier, see .

#### 
To configure the sample code project, perform the following steps in Xcode:
1. On the Signing & Capabilities pane,  to a unique identifier (you must change the bundle ID to proceed).
2.  and  so Xcode can enable the Sign in with Apple capability with your provisioning profile.
3. Choose a run destination from the scheme pop-up menu that you’re signed into with an Apple ID and that uses Two-Factor Authentication.
4. If necessary, click Register Device in the Signing & Capabilities pane to create the provisioning profile.
5. In the toolbar, click Run, or choose Product > Run (⌘R).

#### 
In the sample app, `LoginViewController` displays a login form and a Sign in with Apple button () in its view hierarchy. The view controller also adds itself as the button’s target, and passes an action to be invoked when the button receives a touch-up event.

```swift
func setupProviderLoginView() {
    let authorizationButton = ASAuthorizationAppleIDButton()
    authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
    self.loginProviderStackView.addArrangedSubview(authorizationButton)
}
```
For more information about which Sign in with Apple buttons are available on different Apple platforms, see .

> **important:** When adding the Sign in with Apple button to your storyboard, you must also set the control’s class value to `ASAuthorizationAppleIDButton` in Xcode’s Identity Inspector.


#### 
When the user taps the Sign in with Apple button, the view controller invokes the `handleAuthorizationAppleIDButtonPress()` function, which starts the authentication flow by performing an authorization request for the users’s full name and email address. The system then checks whether the user is signed in with their Apple ID on the device. If the user is not signed in at the system-level, the app presents an alert directing the user to sign in with their Apple ID in Settings.

```swift
@objc
func handleAuthorizationAppleIDButtonPress() {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
}
```

> **important:** The user must enable Two-Factor Authentication to use Sign in with Apple so that access to the account is secure.

The authorization controller calls the  function to get the window from the app where it presents the Sign in with Apple content to the user in a modal sheet.

```swift
func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.view.window!
}
```
If the user is signed in at the system-level with their Apple ID, the sheet appears describing the Sign in with Apple feature, followed by another sheet allowing the user to edit the information in their account. The user can edit their first and last name, choose another email address as their contact information, and hide their email address from the app. If the user chooses to hide their email address from the app, Apple generates a proxy email address to forward email to the user’s private email address. Lastly, the user enters the password for the Apple ID, then clicks Continue to create the account.

#### 
If the authentication succeeds, the authorization controller invokes the  delegate function, which the app uses to store the user’s data in the keychain.

```swift
func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
    case let appleIDCredential as ASAuthorizationAppleIDCredential:
        
        // Create an account in your system.
        let userIdentifier = appleIDCredential.user
        let fullName = appleIDCredential.fullName
        let email = appleIDCredential.email
        
        // For the purpose of this demo app, store the `userIdentifier` in the keychain.
        self.saveUserInKeychain(userIdentifier)
        
        // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
        self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
    
    case let passwordCredential as ASPasswordCredential:
    
        // Sign in using an existing iCloud Keychain credential.
        let username = passwordCredential.user
        let password = passwordCredential.password
        
        // For the purpose of this demo app, show the password credential as an alert.
        DispatchQueue.main.async {
            self.showPasswordCredentialAlert(username: username, password: password)
        }
        
    default:
        break
    }
}
```

> **note:** In your implementation, the `ASAuthorizationControllerDelegate.authorizationController(controller:didCompleteWithAuthorization:)` delegate function should create an account in your system using the data contained in the user identifier.

If the authentication fails, the authorization controller invokes the  delegate function to handle the error.

```swift
func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
}
```
Once the system authenticates the user, the app displays the `ResultViewController` which shows the user information requested from the framework, including the user-provided full name and email address. The view controller also displays a Sign Out button and stores the user data in the keychain. When the user taps the Sign Out button, the app deletes the user information from the view controller and the keychain, and presents the `LoginViewController` to the user.

#### 
The `LoginViewController.performExistingAccountSetupFlows()` function checks if the user has an existing account by requesting both an Apple ID and an iCloud keychain password. Similar to `handleAuthorizationAppleIDButtonPress()`, the authorization controller sets its presentation content provider and delegate to the `LoginViewController` object.

```swift
func performExistingAccountSetupFlows() {
    // Prepare requests for both Apple ID and password providers.
    let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                    ASAuthorizationPasswordProvider().createRequest()]
    
    // Create an authorization controller with the given requests.
    let authorizationController = ASAuthorizationController(authorizationRequests: requests)
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
}
```
The `authorizationController(controller:didCompleteWithAuthorization:)` delegate function checks whether the credential is an Apple ID () or a password credential (). If the credential is a password credential, the system displays an alert allowing the user to authenticate with the existing account.

#### 
The sample app only shows the Sign in with Apple user interface when necessary. The app delegate checks the status of the saved user credentials immediately after launch in the `AppDelegate.application(_:didFinishLaunchingWithOptions:)` function.
The  function retrieves the state of the user identifier saved in the keychain. If the user granted authorization for the app (for example, the user is signed into the app with their Apple ID on the device), then the app continues executing. If the user revoked authorization for the app, or the user’s credential state not found, the app displays the log in form by invoking the `showLoginViewController()` function.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
        switch credentialState {
        case .authorized:
            break // The Apple ID credential is valid.
        case .revoked, .notFound:
            // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
            DispatchQueue.main.async {
                self.window?.rootViewController?.showLoginViewController()
            }
        default:
            break
        }
    }
    return true
}
```


---
# BACKGROUNDASSETS

## Configuring an unmanaged Background Assets project
> https://developer.apple.com/documentation/BackgroundAssets/configuring-an-unmanaged-background-assets-project

### 
To opt out of Managed Background Assets, add a Self-Hosted, Unmanaged extension target to your project, configure the App Groups capability for both the app and extension target, and add some Background Asset keys to the app’s information property list. Then the system notifies your extension when system events occur so that your extension can initiate downloads.

> **note:** For information about Apple-Hosted Background Assets, see .

The system launches the extension during the first install and subsequent updates, before a person launches the app, and periodically in the background when the app isn’t running. The sequence of events is:
1. A person installs or updates your app on the device.
2. The system prevents the app from launching and begins downloading your manifest file using the URL you provide.
3. During the manifest download, the system reports progress to the App Store.
4. When the download completes, the system launches your app extension, sending it a content request with the location of the manifest file on disk.
5. The extension uses the manifest file, which should contains the asset URLs and file sizes, to return a set of download requests to the system.
6. The system pauses, or terminates, the extension and begins the downloads.
7. When the downloads complete, the system notifies the extension and allows the app to launch.
The flow for periodic content requests is identical to the app install and updates, except the system determines when periodic events occur, depending on a person’s usage and their system settings. For example, the system factors in whether a person enables the Low Power Mode and Background App Refresh settings.

> **note:** It’s your responsibility to create manifest files for your self-hosted, unmanaged assets (using your format of choice) that your code parses to get the URLs and file sizes to the system.


#### 
Choose New > Target, select the Background Download template under Application Extension, and click Next. In the dialog, enter a product name, choose Self-Hosted, Unmanaged as the extension type, and click Finish. In the next dialog, click Activate to use the extension scheme Xcode creates.
If you don’t have an Xcode project for your app, first create one from an Application template under the platform you support, such as iOS or macOS. For more information, see .

#### 
Add your app and extension targets to the same app group so that they can communicate and share data.
Add the App Groups capability to both your app and extension target. For macOS apps, also add the App Sandbox capability to both targets. For more information, see .
Then, add both targets to the same app group. In the project editor, select the app target, and then add a unique ID for the group under App Groups on the Signing & Capabilities pane. Xcode automatically selects the new group ID. Select the extension target, then go to App Groups, click Refresh, and select the same group ID.
The app and extension are now in the same app group and can share the asset files. For more information on configuring app groups, and additional steps for macOS apps, see .

#### 
Configure Background Assets for your app target by setting information property list keys. In the project editor, select the app target and click the Info tab. Then, add the following keys to the information property list file:
For more examples of these information property list keys, see the  sample code project. For more information on editing the information property list file, see .


---
# BACKGROUNDTASKS

## Performing long-running tasks on iOS and iPadOS
> https://developer.apple.com/documentation/BackgroundTasks/performing-long-running-tasks-on-ios-and-ipados

### 
On iOS and iPadOS, apps can execute long-running jobs using the Continuous Background Task (), which enables your app’s critical work that can take minutes or more, to complete in the background if a person backgrounds the app before the job completes.
Unlike other  subclasses,  starts in the foreground. In addition, your app needs to run the task only in response to someone’s action, such as tapping a button. If a person backgrounds the app before the task completes, a continuous background task can still perform operations, for example, Core ML processing or sensor data analysis, that leverage the GPU (on supported devices). In the background, continuous background tasks can also use the network and perform intenstive CPU-based operations, for example, image processing with Core Image, Vision, and Accelerate. Example tasks include:
- Exporting video in a film-editing app, or audio in a digital audio workstation (DAW)
- Creating thumbnails for a new batch of photo uploads
- Applying visual filters (HDR, etc) or compressing images for social media posts
For added flexibility, you can set the system to fail any task if, under resource constraints, the system can’t begin processing the task immediately. Otherwise, the system queues the task to begin as soon as possible.

When the system runs a continuous background task and a person backgrounds the app, the system keeps them informed of the task’s progress through a system interface. For power and performance considerations, people can cancel a continuous background task if they desire, through the interface. Your app regularly reports progress of the task, which enables the system to make informed suggestions through the interface about possibly stuck tasks that a person can cancel.
If a person cancels a task through the interface, the framework invokes the task’s expiration handler and the app handles the failure. Otherwise, the framework returns control to the app’s completion handler with a success status.


### 
To begin a job that you want to complete even if a person backgrounds the app, start by creating a task request (). Choose a name the system can use to identify the specific job in the `taskIdentifier` parameter of the initializer and prefix it with your app’s bundle ID:

```swift
private let taskIdentifier = "<bundle-id><task-name>" // Use your app's bundle ID.   

// Create the task request. 
let request = BGContinuedProcessingTaskRequest(
    identifier: taskIdentifier,
    title: "A video export",
    subtitle: "About to start...",
)
```
Make the `task-name` portion of the task identifier unique for this specific job. The system displays the `title` and `subtitle` arguments you choose in a Live Activity, where a person can monitor the job’s progress and cancel it, if they choose.

### 
If your job includes API that can utilize the GPU, enable background GPU use for your task by setting  to . First, check whether the device supports background GPU use by seeing if  contains `.gpu`:

```swift
if BGTaskScheduler.supportedResources.contains(.gpu) {
    request.requiredResources = .gpu
}
```
The system requires your app to have the  entitlement with a value of `true` to use the GPU in the background. To do that, enable the Background GPU Access capability on your app’s target. For more information about capabilities in Xcode, see .

### 
When the system is busy or resource constrained, it might queue your task request for later execution. The default submission strategy, , instructs the system to add your task request to a queue if there’s no immediately available room to run it.
If instead you want the task submission to fail if the system is unable to run the task immediately, set  to   .

```swift
request.strategy = .fail
```
The system cancels a `fail` task right away if it can’t begin processing the task immediately, for example, when the system reaches a maximum number of concurrent tasks.

### 
To run the job, register the task request with the shared  using the unique `taskIdentifier`:

```swift
BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
    guard let task = task as? BGContinuedProcessingTask else { return }
    ... 
```
The  launch handler provides the  reference for you to control execution.
Inside the launch handler, define your task’s long-running code:

```swift
// App-defined function that registers a continuous background task and defines its long-running work.
private func register() {
    // Submission bookkeeping. 
    if submitted {
        return
    }
    submitted = true
    
    // Register the continuous background task. 
    scheduler.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
        guard let task = task as? BGContinuedProcessingTask else {
            return
        }
        /* Do long-running work here. */
    }
}

```
Next, submit the request by passing it to the shared scheduler’s  method:

```swift
// App-defined function that submits a video export job through a continuous background task.
private func submit() {
    // Create the task request. 
    let request = BGContinuedProcessingTaskRequest(identifier: taskIdentifier, title: "A video export", subtitle: "About to start...")

    // Submit the task request.
    do {
        try scheduler.submit(request)
    } catch {
        print("Failed to submit request: \(error)")
    }
}
```

### 
The system displays the job and other continuous background tasks in a Live Activity to inform people of background task progress. It’s important to display accurate progress, as a person can cancel a task through the Live Activity widget if the task appears to be stuck.
To set progress, use the  protocol that  conforms to:

```swift
// Create a progress instance.
let stepCount: Int64 = 100 // For example, percentage of completion.
let progress = Progress(totalUnitCount: stepCount)

for i in 1...stepCount {
    // Update progress.
    task.progress.completedUnitCount = Int64(i)
} 
```
The system also prioritizes the termination of tasks that reflect minimal progress, if resource constraints occur at run time.

### 
Prepare to handle task failure or success by checking the tasks :

```swift
/// App-defined function that exports a video through a continuous background task.
func export(_ task: BGContinuedProcessingTask) -> Result<(), PipelineError> {
    var wasExpired = false

    // Check the expiration handler to confirm job completion.
    task.expirationHandler = {
        wasExpired = true
    }

    // Update progress.
    let progress = task.progress
    progress.totalUnitCount = 100
    while !progress.isFinished && !wasExpired {
        progress.completedUnitCount += 1
        let formattedProgress = String(format: "%.2f", progress.fractionCompleted * 100)

        // Update task for displayed progress.
        task.updateTitle(task.title, subtitle: "Completed \(formattedProgress)%")
        sleep(1)
    }

    // Check progress to confirm job completion.
    if progress.isFinished {
        return .success(())
    } else {
        return .failure(.expired)
    }
}
```
A task can fail if your code encounters an error or the system expires your task, as occurs when a person cancels the task in the system UI.

> **note:** The system cancels any running tasks if a person closes the app in the app switcher, but the app doesn’t receive an indication of cancellation in that case.


---
# COMBINE

## Receiving and Handling Events with Combine
> https://developer.apple.com/documentation/Combine/receiving-and-handling-events-with-combine

### 
The Combine framework provides a declarative approach for how your app processes events. Rather than potentially implementing multiple delegate callbacks or completion handler closures, you can create a single processing chain for a given event source. Each part of the chain is a Combine operator that performs a distinct action on the elements received from the previous step.
Consider an app that needs to filter a table or collection view based on the contents of a text field. In AppKit, each keystroke in the text field produces a  that you can subscribe to with Combine. After receiving the notification, you can use operators to change the content and timing of event delivery, and use the final result to update your app’s user interface.

#### 
To receive the text field’s notifications with Combine, access the default instance of  and call its  method. This call takes the notification name and source object that you want notifications from, and returns a publisher that produces notification elements.

```swift
let pub = NotificationCenter.default
    .publisher(for: NSControl.textDidChangeNotification, object: filterField)
```
You use a  to receive elements from the publisher. The subscriber defines an associated type, , to declare the type that it receives. The publisher also defines a type, , to declare what it produces. The publisher and subscriber both define a type, , to indicate the kind of error they produce or receive. To connect a subscriber to a producer, the  must match the , and the  types must also match.
Combine provides two built-in subscribers, which automatically match the output and failure types of their attached publisher:
-  takes two closures. The first closure executes when it receives , which is an enumeration that indicates whether the publisher finished normally or failed with an error. The second closure executes when it receives an element from the publisher.
-  immediately assigns every element it receives to a property of a given object, using a key path to indicate the property.
For example, you can use the sink subscriber to log when the publisher completes, and each time it receives an element:

```swift
let sub = NotificationCenter.default
    .publisher(for: NSControl.textDidChangeNotification, object: filterField)
    .sink(receiveCompletion: { print ($0) },
          receiveValue: { print ($0) })
```
Both the `sink(receiveCompletion:receiveValue:)` and  subscribers request an unlimited number of elements from their publishers. To control the rate at which you receive elements, create your own subscriber by implementing the  protocol.

#### 
The sink subscriber in the previous section performs all its work in the `receiveValue` closure. This could be burdensome if it needs to perform a lot of custom work with received elements or maintain state between invocations. The advantage of Combine comes from combining operators to customize event delivery.
For example, the  provided by Foundation’s  uses  as its  type. This isn’t a convenient type to receive in the callback if what you need is the text field’s string value.
Since a publisher’s output is essentially a sequence of elements over time, Combine offers sequence-modifying operators like , , and . The behavior of these operators is similar to their equivalents in the Swift standard library. To change the output type of the publisher, you add a  operator whose closure returns a different type. In this case, you can get the notification’s object as an , and then get the field’s .

```swift
let sub = NotificationCenter.default
    .publisher(for: NSControl.textDidChangeNotification, object: filterField)
    .map( { ($0.object as! NSTextField).stringValue } )
    .sink(receiveCompletion: { print ($0) },
          receiveValue: { print ($0) })
```
After the publisher chain produces the type you want, replace `sink(receiveCompletion:receiveValue:)` with . The following example takes the strings it receives from the publisher chain and assigns them to the `filterString` of a custom view model object:

```swift
let sub = NotificationCenter.default
    .publisher(for: NSControl.textDidChangeNotification, object: filterField)
    .map( { ($0.object as! NSTextField).stringValue } )
    .assign(to: \MyViewModel.filterString, on: myViewModel)
```

#### 
You can extend the  instance with an operator that performs actions that you’d otherwise need to code manually. Here are three ways you could use operators to improve this event-processing chain:
- Rather than updating the view model with any string typed into the text field, you could use the  operator to ignore input under a certain length or to reject non-alphanumeric characters.
- If the filtering operation is expensive — for example, if it’s querying a large database — you might want to wait for the user to stop typing. For this, the  operator lets you set a minimum period of time that must elapse before a publisher emits an event. The  class provides conveniences for specifying the time delay in seconds or milliseconds.
- If the results update the UI, you can deliver callbacks to the main thread by calling the  method. By specifying the  instance provided by the  class as the first parameter, you tell Combine to call your subscriber on the main run loop.
The resulting publisher declaration follows:

```swift
let sub = NotificationCenter.default
    .publisher(for: NSControl.textDidChangeNotification, object: filterField)
    .map( { ($0.object as! NSTextField).stringValue } )
    .filter( { $0.unicodeScalars.allSatisfy({CharacterSet.alphanumerics.contains($0)}) } )
    .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
    .receive(on: RunLoop.main)
    .assign(to:\MyViewModel.filterString, on: myViewModel)
```

#### 
A publisher continues to emit elements until it completes normally or fails. If you no longer want to subscribe to the publisher, you can cancel the subscription. The subscriber types created by `sink(receiveCompletion:receiveValue:)` and  both implement the  protocol, which provides a  method:

```swift
sub?.cancel()
```
If you create a custom , the publisher sends a  object when you first subscribe to it. Store this subscription, and then call its  method when you want to cancel publishing. When you create a custom subscriber, you should implement the  protocol, and have your  implementation forward the call to the stored subscription.


---
# COREBLUETOOTH

## Transferring Data Between Bluetooth Low Energy Devices
> https://developer.apple.com/documentation/CoreBluetooth/transferring-data-between-bluetooth-low-energy-devices

### 
This sample shows how to transfer data between two iOS devices, with one acting as a Bluetooth central and the other as a peripheral, by using a  on the peripheral side that changes its value. The value change is automatically picked up on the central side. The sample also shows how the central side can write data to a  on the peripheral side.
This sample shows how to handle flow control in this scenario. It also covers a rudimentary way to use the Received Signal Strength Indicator (RSSI) value to determine whether data transfer is feasible.

#### 
1. Run the sample on two devices that support Bluetooth LE.
2. On one device, tap the “Central” button. This device will be the central mode device. The device will begin scanning for a peripheral device that is advertising the Transfer Service.
3. On the other device, tap the “Peripheral” button. This device will be the peripheral mode device.
4. On the peripheral mode device, tap the advertise on/off switch, to enable peripheral mode advertising of the data in the text field.
5. Bring the two devices close to each other.

#### 
The device running in central mode creates a , assigning the `CentralViewController` as the manager’s delegate. It calls  to discover other Bluetooth devices, passing in the UUID of the service it’s searching for.

```swift
centralManager.scanForPeripherals(withServices: [TransferService.serviceUUID],
                                   options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
```
When the central manager discovers a peripheral with a matching service UUID, it calls . The sample’s implementation of this method uses the `rssi` (Received Signal Strength Indicator) parameter to determine whether the signal is strong enough to transfer data. RSSI values are provided as negative numbers, with a theortetical maximum of `0`. The sample proceeds with transfer if the `rssi` is greater than or equal to `-50`. If the peripheral’s signal is strong enough, the method saves the peripheral as the property `discoveredPeripheral` and calls  to connect to it.

```swift
func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                    advertisementData: [String: Any], rssi RSSI: NSNumber) {
    
    // Reject if the signal strength is too low to attempt data transfer.
    // Change the minimum RSSI value depending on your app’s use case.
    guard RSSI.intValue >= -50
        else {
            os_log("Discovered perhiperal not in expected range, at %d", RSSI.intValue)
            return
    }
    
    os_log("Discovered %s at %d", String(describing: peripheral.name), RSSI.intValue)
    
    // Device is in range - have we already seen it?
    if discoveredPeripheral != peripheral {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it.
        discoveredPeripheral = peripheral
        
        // And finally, connect to the peripheral.
        os_log("Connecting to perhiperal %@", peripheral)
        centralManager.connect(peripheral, options: nil)
    }
}
```

#### 
The device running in peripheral mode creates a  and assigns its `PeripheralViewController` as the manager’s delegate.
When the  method indicates that Bluetooth has powered on, the sample calls a private `setupPeripheral()` method to create a  called `transferCharacteristic`. It then creates a  from the characteristic and adds the service to the .

```swift
private func setupPeripheral() {
    
    // Build our service.
    
    // Start with the CBMutableCharacteristic.
    let transferCharacteristic = CBMutableCharacteristic(type: TransferService.characteristicUUID,
                                                     properties: [.notify, .writeWithoutResponse],
                                                     value: nil,
                                                     permissions: [.readable, .writeable])
    
    // Create a service from the characteristic.
    let transferService = CBMutableService(type: TransferService.serviceUUID, primary: true)
    
    // Add the characteristic to the service.
    transferService.characteristics = [transferCharacteristic]
    
    // And add it to the peripheral manager.
    peripheralManager.add(transferService)
    
    // Save the characteristic for later.
    self.transferCharacteristic = transferCharacteristic

}
```
The user interface provides a  that starts or stops advertising of the peripheral’s service UUID.

```swift
@IBAction func switchChanged(_ sender: Any) {
    // All we advertise is our service's UUID.
    if advertisingSwitch.isOn {
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [TransferService.serviceUUID]])
    } else {
        peripheralManager.stopAdvertising()
    }
}
```
Once the central device discovers and connects to the peripheral, the peripheral side sends the data from the text field to the central. `PeripheralViewController` sends the data in chunks — each sized to the maximum value the central can receive — by setting the value of its `transferCharacteristic` property to the latest chunk. When finished, it sends the value `EOM` (for “end of message”).

#### 
Back on the central device, a call to the central manager delegate’s  tells the app that it has discovered the peripheral’s transfer characteristic. The sample’s implementation of this method calls  to start receiving updates to the characteristic’s value.
When the value does update — meaning text is available — the central manager calls the delegate method . The sample looks to see if the data is a chunk or an end-of-message marker. If the data is a chunk, the code appends the chunk to an internal buffer containing the peripheral’s message. If the data is an end-of-message marker, it converts the buffer to a string and sets it as the contents of the text field.

```swift
func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    // Deal with errors (if any)
    if let error = error {
        os_log("Error discovering characteristics: %s", error.localizedDescription)
        cleanup()
        return
    }
    
    guard let characteristicData = characteristic.value,
        let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
    
    os_log("Received %d bytes: %s", characteristicData.count, stringFromData)
    
    // Have we received the end-of-message token?
    if stringFromData == "EOM" {
        // End-of-message case: show the data.
        // Dispatch the text view update to the main queue for updating the UI, because
        // we don't know which thread this method will be called back on.
        DispatchQueue.main.async() {
            self.textView.text = String(data: self.data, encoding: .utf8)
        }
        
        // Write test data
        writeData()
    } else {
        // Otherwise, just append the data to what we have previously received.
        data.append(characteristicData)
    }
}
```
Once the transfer is complete, you can press the “Back” button on each device and reassign the central and peripheral roles, to perform the transfer in the opposite direction.


---
# COREIMAGE

## Applying a Chroma Key Effect
> https://developer.apple.com/documentation/CoreImage/applying-a-chroma-key-effect

### 
Use the chroma key effect, also known as bluescreening or greenscreening, to replace the background of an image by setting a color or range of colors to transparent.

You apply this technique in three steps:
1. Create a cube map for the  filter to determine which colors to set transparent.
2. Apply the  filter to the image to make pixels transparent.
3. Use the  filter to place the image over the background image.

#### 
A color cube is a 3D color-lookup table that uses the R, G, and B values from the image to lookup a color. To filter out green from the image, create a color map with the green portion set to transparent pixels.
A simple way to construct a color map with these characteristics is to model colors using an HSV (hue-saturation-value) representation. HSV represents hue as an angle around the central axis, as in a color wheel. In order to make a chroma key color from the source image transparent, set its lookup table value to `0` when its hue is in the correct color range.

The value for green in the source image falls within the slice beginning at 108° (`108/360` = `0.3`) and ending at 144° (`144/360` = `0.4`). You’ll set transparency to `0` for this range in the color cube.
To create the color cube, iterate across all values of red, green, and blue, entering a value of 0 for combinations that the filter wiill set to transparent. Refer to the numbered list for details on each step to the routine.

```swift
- (CIFilter<CIColorCube> *) chromaKeyFilterHuesFrom:(CGFloat)minHue to:(CGFloat)maxHue {
    // 1
    const unsigned int size = 64;
    const size_t cubeDataSize = size * size * size * 4;
    NSMutableData* cubeData = [[NSMutableData alloc] initWithCapacity:(cubeDataSize * sizeof(float))];
    
    // 2
    for (int z = 0; z < size; z++) {
        CGFloat blue = ((double)z)/(size-1);
        for (int y = 0; y < size; y++) {
            CGFloat green = ((double)y)/(size-1);
            for (int x = 0; x < size; x++) {
                CGFloat red = ((double)x)/(size-1);
                
                // 3
                CGFloat hue = [self hueFromRed:red green:green blue:blue];
                float alpha = (hue >= minHue && hue <= maxHue) ? 0 : 1;
                // 4
                float premultipliedRed = red * alpha;
                float premultipliedGreen = green * alpha;
                float premultipliedBlue = blue * alpha;
                [cubeData appendBytes:&premultipliedRed length:sizeof(float)];
                [cubeData appendBytes:&premultipliedGreen length:sizeof(float)];
                [cubeData appendBytes:&premultipliedBlue length:sizeof(float)];
                [cubeData appendBytes:&alpha length:sizeof(float)];
            }
        }
    }

    // 5
    CIFilter<CIColorCube> *colorCubeFilter = CIFilter.colorCubeFilter;
    colorCubeFilter.cubeDimension = size;
    colorCubeFilter.cubeData = cubeData;
    return colorCubeFilter;
}
```
1. Allocate memory. The color cube has three dimensions, each with four elements of data (RGBA).
2. Use a for-loop to iterate through each color combination of red, green, and blue, simulating a color gradient.
3. Convert RGB to HSV, as in the `hueFromRed` function. Even though the color cube exists in RGB color space, it’s easier to isolate and remove color based on hue. Input `0` for green hues to indicate complete removal; use `1` for other hues to leave those colors intact. To specify green as a hue value, convert its angle in the hue pie chart to a range of `0` to `1`. The green in the sample image has hue between `0.3` (`108` out of `360` degrees`)` and `0.4` (`144` out of `360` degrees). Your shade of green may differ, so adjust the range accordingly.
4. The  filter requires premultiplied alpha values, meaning that the values in the lookup table have their transparency baked into their stored entries rather than applied when accessed.
5. Create a  filter with the cube data.

> **note:**  The framework doesn’t have built-in direct conversion between color spaces, but you can access the hue of a  created with RGB values. Create a  from the raw RGB values and then read the hue from it.


```swift
- (CGFloat) hueFromRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    UIColor* color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
    CGFloat hue, saturation, brightness;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    
    return hue;
}
```

#### 
Apply the color cube filter to a foreground image by setting its `inputImage` parameter and then accessing the `outputImage`.

```swift
CIFilter<CIColorCube>* chromaKeyFilter = [self chromaKeyFilterHuesFrom:0.3 to:0.4];
chromaKeyFilter.inputimage = foregroundCIImage
CIImage* sourceCIImageWithoutBackground = chromaKeyFilter.outputImage;
```
The output image contains the foreground with all green pixels made transparent.
The filter passes through each pixel in the input image, looks up its color in the color cube, and replaces the source color with the color in the color cube at the nearest position.

#### 
Chain a  filter to the color cube filter to composite a background image to the greenscreened output. The transparency in the colorcube-filtered image allows the composited background image to show through.

```swift
CIFilter<CICompositeOperation> *compositor = CIFilter.sourceOverCompositingFilter
compositor.inputImage = sourceCIImageWithoutBackground
compositor.backgroundImage = backgroundCIImage
CIImage* compositedCIImage = compositor.outputImage;
```
The foreground of the source image now appears in front of the background landscape without any trace of the green screen.


---
# CORELOCATION

## Converting between coordinates and user-friendly place names
> https://developer.apple.com/documentation/CoreLocation/converting-between-coordinates-and-user-friendly-place-names

### 
The  object reports locations as a latitude/longitude pair. While these values uniquely represent any location on the planet, they are not values that users immediately associate with the location. Users are more familiar with names that describe a location, such as street names or city names. The  class lets you convert between geographic coordinates and the user-friendly names associated with that location. You can convert from either a latitude/longitude pair to a user friendly place name, or the other way around.

User place names are represented by a  object, which contains properties for specifying the street name, city name, country or region name, postal code, and many others. Placemarks also contain properties describing relevant geographic features or points of interest at the location, such as the names of mountains, rivers, businesses, or landmarks.
Geocoder objects are one-shot objects—that is, you use each object to make a single conversion. You can create multiple geocoder objects and perform multiple conversions, but Apple rate limits the number of conversions you can perform. Making too many requests in a short period of time may cause some of those requests to fail. For tips on how to manage any conversions, see the overview of .

#### 
If you have a  object, call the  method of your geocoder object to retrieve a  object for that location. Typically, you convert coordinates into placemarks when you want to display information about the location to the user. For example, if the user selects a location on a map, you might want to show the address at that location.
Listing 1 shows how to obtain placemark information for the last location reported by the  object. Because calls to the geocoder object are asynchronous, the caller of this method passes in a completion handler, which is executed with the results.
Listing 1. Reverse geocoding a coordinate

```swift
func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                -> Void ) {
    // Use the last reported location.
    if let lastLocation = self.locationManager.location {
        let geocoder = CLGeocoder()
            
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(lastLocation, 
                    completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else {
	         // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
    }
    else {
        // No location was available.
        completionHandler(nil)
    }
}
```

#### 
If you have user-provided address information, call the methods of  to obtain the corresponding location data. The  class provides options for converting a user-typed string or for converting a dictionary of address-related information. That information is forwarded to Apple servers, which interpret the information and return the results.
Depending on the precision of the user-provided information, you may receive one result or multiple results. For example, passing a string of “100 Main St., USA” may return many results unless you also specify a search region or additional details. To help you decide which result is correct, the geocoder actually returns  objects, which contain both the coordinate and the original information that you provided.
Listing 2 shows how you might obtain a coordinate value from a user-provided string. The example calls the provided completion handler with only the first result. If the string does not correspond to any location, the method calls the completion handler with an error and an invalid coordinate.
Listing 2. Getting a coordinate from an address string

```swift
func getCoordinate( addressString : String, 
        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(addressString) { (placemarks, error) in
        if error == nil {
            if let placemark = placemarks?[0] {
                let location = placemark.location!
                    
                completionHandler(location.coordinate, nil)
                return
            }
        }
            
        completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
    }
}
```


---
# COREML

## Integrating a Core ML Model into Your App
> https://developer.apple.com/documentation/CoreML/integrating-a-core-ml-model-into-your-app

### 
This sample app uses a trained model, `MarsHabitatPricer.mlmodel`, to predict habitat prices on Mars.

#### 
Add the model to your Xcode project by dragging the model into the project navigator.
You can see information about the model—including the model type and its expected inputs and outputs—by opening the model in Xcode. In this sample, the inputs are the number of solar panels and greenhouses, as well as the lot size of the habitat (in acres). The output is the predicted price of the habitat.

#### 
Xcode also uses information about the model’s inputs and outputs to automatically generate a custom programmatic interface to the model, which you use to interact with the model in your code. For `MarsHabitatPricer.mlmodel`, Xcode generates interfaces to represent the model (`MarsHabitatPricer`), the model’s inputs (`MarsHabitatPricerInput`), and the model’s output (`MarsHabitatPricerOutput`).
Use the generated `MarsHabitatPricer` class’s initializer to create the model:

```swift
let marsHabitatPricer = try? MarsHabitatPricer(configuration: .init())
```

#### 
This sample app uses a `UIPickerView` to get the model’s input values from the user:

```swift
func selectedRow(for feature: Feature) -> Int {
    return pickerView.selectedRow(inComponent: feature.rawValue)
}

let solarPanels = pickerDataSource.value(for: selectedRow(for: .solarPanels), feature: .solarPanels)
let greenhouses = pickerDataSource.value(for: selectedRow(for: .greenhouses), feature: .greenhouses)
let size = pickerDataSource.value(for: selectedRow(for: .size), feature: .size)
```

#### 
The `MarsHabitatPricer` class has a generated `prediction(solarPanels:greenhouses:size:)` method that’s used to predict a price from the model’s input values—in this case, the number of solar panels, the number of greenhouses, and the size of the habitat (in acres). The result of this method is a `MarsHabitatPricerOutput` instance.

```swift
// Use the model to make a price prediction.
let output = try marsHabitatPricer.prediction(solarPanels: solarPanels,
                                              greenhouses: greenhouses,
                                              size: size)
```
Access the `price` property of `marsHabitatPricerOutput` to get a predicted price and display the result in the app’s UI.

```swift
// Format the price for display in the UI.
let price = output.price
priceLabel.text = priceFormatter.string(for: price)
```

> **note:** The generated `prediction(solarPanels:greenhouses:size:)` method can throw an error. The most common type of error you’ll encounter when working with Core ML occurs when the details of the input data don’t match the details the model is expecting—for example, an image in the wrong format.


#### 
Xcode compiles the Core ML model into a resource that’s been optimized to run on a device. This optimized representation of the model is included in your app bundle and is what’s used to make predictions while the app is running on a device.


---
# COREMOTION

## Getting raw accelerometer events
> https://developer.apple.com/documentation/CoreMotion/getting-raw-accelerometer-events

### 
An accelerometer measures changes in velocity along one axis. All iOS devices have a three-axis accelerometer, which delivers acceleration values in each of the three axes shown in the next illustration. The values reported by the accelerometers are measured in increments of the gravitational acceleration, with the value `1.0` representing an acceleration of 9.8 meters per second (per second) in the given direction. Acceleration values may be positive or negative depending on the direction of the acceleration.

You access the raw accelerometer data using the classes of the Core Motion framework. Specifically, the  class provides the interfaces for enabling the accelerometer hardware. When enabling the hardware, choose the interfaces that are best suited for your app. You can pull the accelerometer data only when you need it, or you can ask the framework to push updates to your app at regular intervals. Each technique involves different configuration steps and has a different use case.

> **important:**  If your app relies on the presence of accelerometer hardware, configure the `UIRequiredDeviceCapabilities` key of its `Info.plist` file with the `accelerometer` value. For more information about the meaning of this key, see .

For information about the coordinate axes of different device types, see .

#### 
Accelerometer data might be unavailable for a variety of reasons, so verify that the data is available before you try to obtain it. Check the value of the  property of `CMMotionManager` and make sure it’s `true`. If it’s `false`, starting updates doesn’t deliver any data to your app.

> **important:**  In visionOS, accelerometer data is available only when your app has an open immersive space. For more information, see .


#### 
For apps that process accelerometer data on their own schedule, such as games, use the  method of  to start the delivery of accelerometer data. When you call this method, the system enables the accelerometer hardware and begins updating the  property of your  object. However, the system does not notify you when it updates that property. You must explicitly check the value of the property when you need the accelerometer data.
Before you start the delivery of accelerometer updates, specify an update frequency by assigning a value to the  property. The maximum frequency at which you can request updates is hardware-dependent but is usually at least 100 Hz. If you request a frequency that is greater than what the hardware supports, Core Motion uses the supported maximum instead.
The example below shows a method that configures accelerometer updates to occur 50 times per second. The method then configures a timer to fetch those updates at the same frequency and do something with the data. You could configure the timer to fire at a lower frequency, but doing so would waste power by causing the hardware to generate more updates than were actually used.

```swift
let motion = CMMotionManager()

func startAccelerometers() {
   // Make sure the accelerometer hardware is available. 
   if self.motion.isAccelerometerAvailable {
      self.motion.accelerometerUpdateInterval = 1.0 / 50.0  // 50 Hz
      self.motion.startAccelerometerUpdates()

      // Configure a timer to fetch the data.
      self.timer = Timer(fire: Date(), interval: (1.0/50.0), 
            repeats: true, block: { (timer) in
         // Get the accelerometer data.
         if let data = self.motion.accelerometerData {
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z

            // Use the accelerometer data in your app.
         }
      })

      // Add the timer to the current run loop.
      RunLoop.current.add(self.timer!, forMode: .defaultRunLoopMode)
   }
}
```

#### 
When you want to capture all of the incoming accelerometer data, perhaps so you can analyze it for movement patterns, use the  method of . This method pushes each new set of accelerometer values to your app by executing your handler block on the specified queue. The queueing of these blocks ensures that your app receives all of the accelerometer data, even if your app becomes busy and is unable to process updates for a brief period of time.
Before you start the delivery of accelerometer updates, specify an update frequency by assigning a value to the  property. The maximum frequency at which you can request updates is hardware-dependent but is usually at least 100 Hz. If you request a frequency that is greater than what the hardware supports, Core Motion uses the supported maximum instead.
The following example shows a method from the  sample code project, which you can examine for more context. The app displays a real-time graph of accelerometer data. The user configures the update frequency for the accelerometers using a slider, the changing of which results in a call to the `startUpdatesWithSliderValue:` method shown in the example. This method restarts the accelerometer updates with the new frequency. Each time a new sample is received, the specified block is queued on the main thread. That block updates the app’s graph view and labels with the new accelerometer values.

```objc
static const NSTimeInterval accelerometerMin = 0.01;
- (void)startUpdatesWithSliderValue:(int)sliderValue {
    // Determine the update interval.
    NSTimeInterval delta = 0.005;
    NSTimeInterval updateInterval = accelerometerMin + delta * sliderValue;
    // Create a CMMotionManager object.
    CMMotionManager *mManager = [(APLAppDelegate *)
            [[UIApplication sharedApplication] delegate] sharedManager];
    APLAccelerometerGraphViewController * __weak weakSelf = self;
    // Check whether the accelerometer is available.
    if ([mManager isAccelerometerAvailable] == YES) {
        // Assign the update interval to the motion manager.
        [mManager setAccelerometerUpdateInterval:updateInterval];
        [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
               withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [weakSelf.graphView addX:accelerometerData.acceleration.x 
                  y:accelerometerData.acceleration.y 
                  z:accelerometerData.acceleration.z];
        [weakSelf setLabelValueX:accelerometerData.acceleration.x 
                  y:accelerometerData.acceleration.y 
                  z:accelerometerData.acceleration.z];
      }];
   }
   self.updateIntervalLabel.text = [NSString stringWithFormat:@"%f", updateInterval];
}
- (void)stopUpdates {
   CMMotionManager *mManager = [(APLAppDelegate *)
            [[UIApplication sharedApplication] delegate] sharedManager];
   if ([mManager isAccelerometerActive] == YES) {
      [mManager stopAccelerometerUpdates];
   }
}
```


---
# CREATEML

## Creating an Image Classifier Model
> https://developer.apple.com/documentation/CreateML/creating-an-image-classifier-model

### 
An  is a machine learning model that recognizes images. When you give it an image, it responds with a category label for that image.

You train an image classifier by showing it many examples of images you’ve already labeled. For example, you can train an image classifier to recognize animals by gathering photos of elephants, giraffes, lions, and so on.

After the image classifier finishes training, you assess its accuracy and, if it performs well enough, save it as a Core ML model file. You then import the model file into your Xcode project to use the image classifier in your app.

#### 
Use at least 10 images per category, but keep in mind that an image classifier performs better with a more diverse set of images. Consider including images of each category from multiple angles and in different lighting conditions.
Balance the number of images for each category. For example, don’t use 10 images for one category and then 1000 images for another.
The images can be in any format you can open in the Quicktime Player, such as JPEG and PNG. They don’t have to be a particular size, nor do they need to be the same size as each other. However, it’s best to use images that are at least 299 x 299 pixels.
If possible, gather images that best represent what you expect the model to see when you use it in your app. For example, if your app classifies images from a device’s camera in an outdoor setting, gather outdoor images from an identical or similar camera.

> **note:** By default, the image classifier uses the scene print feature extractor to accelerate the training process and works best with real-world objects. For more information, see .


#### 
Prepare a training dataset by sorting the images into subfolders. Give each subfolder a name for the category of images contained within it. For example, you might use the label `Cheetah` for all the images of cheetahs.


#### 
Testing your model with a testing dataset is a quick way to see how well your trained model might perform in the real world.
If your dataset has enough images, say 25 or more per category, create a testing dataset by duplicating the folder structure of the training dataset. Then move about 20 percent of the images from each category into the equivalent category folder in the testing dataset.

#### 
Use Create ML to create an image classifier project. With Xcode open, Control-click the Xcode icon in the Dock and choose Open Developer Tool > Create ML. Or, from the Xcode menu, choose Open Developer Tool > Create ML.
In Create ML, choose File > New Project to see the list of model templates. Select Image Classification and click Next.

Change the project’s default name to a more meaningful one. If applicable, enter additional information for the models that come from this project, such as one or more authors and a short description.


#### 
Drag the folder with your training dataset into the Training Data well in the project window.

If applicable, drag the folder with your testing dataset into the Testing Data well in the project window.

You can adjust the following parameters before training your image classifier:


#### 
Click the Train button to start the training session. Create ML begins the session by quickly separating some of your training data into a validation dataset. Next, Create ML extracts features, such as edges, corners, textures, and regions of color, from the remaining training images. Create ML uses the images’ features to iteratively train the model and then checks its accuracy with the validation dataset.

Create ML shows its progress in a graph, where the black and gray lines represent the model’s accuracy with the training and validation datasets, respectively.

#### 
When Create ML finishes training the model, it tests the model using the testing dataset. When it’s finished testing the model, Create ML shows the training, validation, and testing accuracy scores in the Evaluation tab. Models typically have higher accuracy scores on the training dataset because it learned from those images. In this example, the image classifier model correctly identified:
- 100 percent of the training images
- 95 percent of the validation images
- 97 percent of the testing images

 is the number of true positives divided by the sum of true positives and false positives.  is the number of true positives divided by the sum of true positives and false negatives.
If the evaluation performance isn’t good enough, you may need to train a new model with a dataset that has more variety. For example, you can gather additional images from new angles or in new environments, or add one or more image augmentation options. For details about evaluating a model, as well as strategies for improving the model’s performance, see .

#### 
Click the Preview tab to try out the model with images it hasn’t seen before. To see the model’s predictions, drag image files to the column below the Train button.


#### 
When you’re satisfied with the model’s performance, save it to the file system (in a Core ML format). From the Output tab, save the model using any of these options:
- Click the Save button to save the model to the file system.
- Click the Export button to open the model in Xcode.
- Click the Share button to send the model to someone else, such as through Mail or Messages.
- Drag the model’s icon anywhere that accepts a file.


#### 
The last step is to add your trained model to an Xcode project. For example, your image classifier model can replace the model in the  sample.
Download the sample and open the project in Xcode. Drag your model file into the navigation pane. Xcode adds the model to your project and shows you the model’s metadata, operating system availability, class labels, and so on.

To use your model in code, you only need to change one line. The project instantiates the MobileNet model in exactly one place in the `ImagePredictor` class.

```swift
// Create an instance of the image classifier's wrapper class.
let imageClassifierWrapper = try? MobileNet(configuration: defaultConfig)
```
Change this line to use your image classification model class instead:

```swift
// Create an instance of the image classifier's wrapper class.
let imageClassifierWrapper = try? AnimalClassifier(configuration: defaultConfig)
```
These models are interchangeable because both take an image as input, and both output a label string. With your model substitution, the sample app classifies images as before, except now it uses your model and its associated labels.

#### 
You can use Create ML to train a useful image classifier with very little code or machine learning expertise, as described in the sections above. However, you can also use an  instance to script the model training process. The general tasks are the same: prepare data, train a model, assess performance, and save the Core ML model file. The difference is that you do everything programmatically.
For example, you can initialize two  instances, one for the training dataset and another for the testing dataset. Use the training data source to initialize an image classifier with . Then use the testing data source with its  method, and assess the values in the  instance it returns.


---
# EVENTKIT

## Creating events and reminders
> https://developer.apple.com/documentation/EventKit/creating-events-and-reminders

### 
Once you have permission to access a person’s Calendar and Reminder data, you can create, display, and edit events and reminders.

#### 
Create a new event with the  method of the  class.
You can edit the details of a new event or an event you previously fetched from the Calendar database by setting the event’s corresponding properties. Some of the details you can edit include:
- The event’s title with the  property.
- The event’s start and end dates with the  and  properties.
- The calendar with which the event is associated with the  property.
- The alarms associated with the event with the  property (see “” for more details).
- The event’s recurrence rule, if it is a repeating event, with the `recurrenceRules` property (see “” for more details).

> **note:**  In iOS, you have the option of letting users modify event data with the event view controllers provided in the EventKit UI framework. For information on how to use these event view controllers, see .


##### 

> **important:**  If your app modifies a user’s Calendar database, it must get confirmation from the user before doing so. An app should never modify the Calendar database without specific instruction from the user.

Save your changes to the Calendar database with the  method . If you want to remove an event from the Calendar database, use the `EKEventStore` method . Whether you are saving or removing an event, implementing the respective method automatically syncs your changes with the calendar the event belongs to (CalDAV, Exchange, and so on).
If you are saving a recurring event, your changes can apply to all future occurrences of the event by specifying  for the span parameter of the  method. Likewise, you can remove all future occurrences of an event by specifying  for the `span` parameter of the  method.

> **note:**  If you pass `NO` to the `commit` parameter, make sure that you later invoke the  method to permanently save your changes.


#### 
Reminders are tasks that may be tied to a specific time or location. They are similar to calendar events, but can be marked complete and may not necessarily span an exact period of time.
Because  inherits from , you can perform the same methods on a reminder as you would on an event, such as adding an alarm with  or setting a recurrence rule with .

> **important:**  If your iOS app links on macOS and you need to access Reminders data, be sure to include the  key in your `Info.plist` file.

You can create reminders using the  class method. The  and  properties are required. The calendar for a reminder is the list with which it is grouped.
Like events, reminders can trigger time-based or location-based alarms to alert the user of a certain task. Read “`Setting an Alarm`” for more information on how to attach alarms to calendar items.

##### 
To save a reminder to the Calendar database, call the  method. To remove an event, call the  method. The  and  properties must explicitly be set before you save the reminder.

> **note:**  Just like when saving or removing events, make sure that if you pass `NO` to the `commit` parameter, you later invoke the  method to save your changes.


##### 
To associate a start date or due date with a reminder, use the  and  properties. To complete a reminder, set the completed property to `YES`, which automatically sets  to the current date.

> **important:**  If your app modifies a user’s Calendar database, it must get confirmation from the user before doing so. An app should never modify the Calendar database without specific instruction from the user.


---
# GAMECONTROLLER

## Discovering and tracking spatial game controllers and styli
> https://developer.apple.com/documentation/GameController/discovering-and-tracking-spatial-game-controllers-and-styli

### 
The Game Controller framework provides the ability to discover spatial game controllers and stylus, allows you to connect, read button or thumbstick inputs, and play haptics. After you connect to a device, you use  or  to combine tracking data with input from the device.

### 
To begin developing with spatial game controllers, you need to configure your Xcode project. To add the spatial game controller profile to your project, perform the following steps:
1. In Xcode, select your project in Xcode’s project navigator.
2. Select your project’s target.
3. Click the Signing & Capabilities tab in the project editor.
4. Add the Game Controller capability.
5. Select the Spatial Gamepad profile.

> **note:** You don’t need to enable the Spatial Gamepad profile if your app only supports stylus input.


### 
The system can notify your app when a spatial game controller connects or disconnects by listening for  and . A notification that includes information as to whether the controller provides spatial input:

```swift
NotificationCenter.default.addObserver(
        forName: NSNotification.Name.GCControllerDidConnect,
        object: nil,
        queue: nil) { notification in
    if let controller = notification.object as? GCController {
        switch controller.productCategory {
            case GCProductCategorySpatialController:
                // A spatial controller connected.
            default:
                // A standard controller connected.
        }
    }
}
```
More than one controller can connect to a device at a time. You can use the connection notification to track each connection as they happen, or check  to iterate through an up-to-date list of the currently connected controllers.
To get notifications for styli, use  and . These notifications provide a , and you can get a list of all currently connected styli by querying .

> **note:** Use  and  when your app launches to get the initial connection state. Checking for controllers and styli isn’t synchronous and may return an empty list even with an accessory in a connected state.


### 
You use  to access the button and thumbstick inputs of a spatial controller. When you work with spatial game controllers, the input button mapping expose the following inputs:

```swift
input.buttons[.a] // Cross button (Right), Square button (Left)
input.buttons[.b] // Circle button (Right), Triangle button (Left)
input.buttons[.grip] // Grip button
input.buttons[.trigger] // Trigger button
input.buttons[.thumbstickButton] // Thumbstick "press"
input.buttons[.menu] // Menu button
input.dpads[.thumbstick] // Joystick
```
Use  to access inputs from a spatial stylus accessory. A stylus exposes the following inputs:

```swift
input.buttons[.stylusTip] // Tip pressure sensor
input.buttons[.stylusPrimaryButton] // Primary side button
input.buttons[.stylusSecondaryButton] // Secondary side button
```
For information on polling for input and receiving callbacks, see . For more information on how to play haptics, see .

### 
In , an  provides a way to tether virtual content to physical locations or objects in your real work space. For example, an image in your environment, your hands, or a spatial game controller. On visionOS, accessory anchoring works in immersive and shared spaces.
Use  with a  or  to anchor virtual content onto the accessory. Each controller and stylus accessory has a list of possible locations you can anchor to, and depends on the accessory you use. You can anchor virtual content to a location on the accessory by specifying a  from a list of possible .

```swift
let device = // A connected controller or stylus.
guard let source = try await AnchoringComponent.AccessoryAnchoringSource(device: device) else {
     // Get a list of location names available for the device.
     let names = source.accessoryLocationNames
     
     // Get a named location on a controller, like `aim`, `grip`, or `grip_surface`.
     let aimLocation = source.locationName(named: "aim")
     
     // Create an entity that targets a location you want to anchor to.
     let aimEntity = AnchorEntity(.accessory(from: source, location: aimLocation),
                                  trackingMode: .predicted)
}
```
For apps that don’t depend on high location accuracy, use the  tracking mode. If you need higher location accuracy — at the cost of higher latency — use  tracking mode.
Before using  to get the transforms of a spatial game controller, your app needs request permission to track an accessory. Set  in your app’s `Info.plist` file that explains how your app intends to use tracking information.

```swift
// Configure a spatial tracking session.
let configuration = SpatialTrackingSession.Configuration(tracking: [.accessory])
let session = SpatialTrackingSession()
await session.run(configuration)

// Get the anchor transform from an entity.
let aimTransform = aimEntity.transformMatrix(relativeTo: nil)
```
If you use , tracking works similarly to the object and image tracking APIs. For more information about tracking accessories, see .


---
# HEALTHKIT

## Saving data to HealthKit
> https://developer.apple.com/documentation/HealthKit/saving-data-to-healthkit

### 
Your app can create new samples and add them to the HealthKit store. Although all sample types follow a similar procedure, each type has its own variations:
1. Look up the type identifier for your data. For example, to record the user’s weight, you use the  type identifier. For the complete list of type identifiers, see .
2. Use the convenience methods on the  class to create the correct object type for your data. For example, to save the user’s weight, you’d create an  object using the  method. For a list of convenience methods, see .
3. Instantiate an object of the matching  subclass using the object type.
4. Save the object to the HealthKit store using the  method.
Each  subclass has its own convenience methods for instantiating sample objects, which modify the steps described in the list above.

For quantity samples, create an instance of the  class. The quantity’s units must correspond to the allowable units described in the type identifier’s documentation. For example, the  documentation states that it uses length units. Therefore, your quantity must use centimeters, meters, feet, inches, or another compatible unit. For more information, see .

For category samples, the sample’s value must correspond to the enum described in the type identifier’s documentation. For example, the  documentation states that it uses the  enum. Therefore, you must pass a value from this enum when creating this sample. For more information, see .

For correlations, you must first create all the sample objects that the correlation will contain. The correlation’s type identifier describes both the type and the number of objects that can be contained. Don’t save the contained objects into the HealthKit store. They’re stored as part of the correlation. For more information, see .

> **important:**  In iOS 17.2 and later, the Journal app encourages people to reflect on their day-to-day experiences, including physical accomplishments, workouts, and emotions and moods. If your app saves data to HealthKit, high-level summaries of that data can appear as suggestions in the Journal app, or in other apps that use the  framework.


#### 
When saving data to the HealthKit store, you often need to choose between using a single sample to represent the data or splitting the data across multiple, smaller samples. A single, long sample is better from a performance perspective; however, multiple smaller samples gives the user a more detailed look into how their data changes over time. Ideally, you want to find a sample size that’s granular enough to provide the user with useful historical data and you should avoid saving samples that are 24 hours long or longer.
When recording a workout, you can use high frequency data (a minute or less per sample) to provide intensity charts and otherwise analyze the user’s performance over the workout. For less intensive activity, like daily step counts, samples of an hour or less often work best. This lets you produce meaningful daily and hourly graphs.
Most sample types have restrictions on duration. If you attempt to save a sample that doesn’t meet those restrictions, it fails to save. For more details on checking the duration restrictions, refer to .

#### 
The Health app gives users access to all of the data in their HealthKit store. Users can view, add, delete, and manage their data.
Specifically, users can:
- See a dashboard containing their current health data.
- Access all the data stored in HealthKit. Users can view the data by type, by app, or by device.
- Manage each app’s permission to read and write from the HealthKit store.
As a result, the Health app has a few important impacts on developing HealthKit apps. First, remember that users can always modify their data outside your app or even change your permission to access their data. As a result, your app should always query for the current data in the HealthKit store or perform background queries to track changes to the store.
Second, you can also use the Health app to view the data your app is saving to the HealthKit store. This can be particularly useful during early testing, to verify that your app is saving everything as expected.


---
# IMMERSIVEMEDIASUPPORT

## Authoring Apple Immersive Video
> https://developer.apple.com/documentation/ImmersiveMediaSupport/authoring-apple-immersive-video

### 

> **note:** This sample code project is associated with WWDC25 session 403: .


#### 
Running this sample requires  a zip file that contains an example QuickTime movie and supporting content. When the download completes, expand the zip file.
To run the app in Xcode, choose Product > Scheme > Edit Scheme, and update the command-line argument paths to reference the downloaded files:


---
# MAPKIT

## MapKit for SwiftUI
> https://developer.apple.com/documentation/MapKit/mapkit-for-swiftui

### 
Like MapKit for AppKit and UIKit, MapKit for SwiftUI allows you to take advantage of map styles ranging from satellite imagery to rich, 3D perspective imagery to present vivid maps. Using  you can configure your maps to show  and  views, or — for more specialized content — you can design your own SwiftUI views to place on the map. To add even more interactivity, MapKit for SwiftUI supports overlays to highlight areas on the map, enabling you to animate paths and directions using , or make it easy for people to dig deeper into on the ground details with tappable points of interest. People who use your app can also explore at street level using  and Look Around viewer.

> **note:**  For more information about integrating MapKit into your app using SwiftUI, see WWDC23 session 10043:


---
# METAL

## Synchronizing passes with producer barriers
> https://developer.apple.com/documentation/Metal/synchronizing-passes-with-producer-barriers

### 
Producer queue barriers are coarse synchronization primitives that resolve access conflicts between commands in different passes that you submit to the same command queue, including passes from other command buffers. Producer barriers are convenient for synchronizing passes that modify common resources that multiple, subsequent passes in the same queue load later on.

> **note:**  Producer barriers are only available to Metal 4 encoder types.

When your app encodes commands that access a resource from different passes — or different stages within a single pass — it creates an access conflict when at least one command modifies that resource. This conflict happens because the GPU can run multiple commands at the same time, including those from:
- Multiple passes
- Different stages of a pass, such as the  and  stages of a compute pass
- Multiple instances of a stage, such as two or more dispatch commands within a compute pass
For more information about resource access conflicts and GPU stages, see  and , respectively.

> **tip:**  As an alternative to a producer queue barrier, create a consumer queue barrier in the consumer pass. For more information, see .

Start by identifying which memory operations from subsequent passes in the same queue introduce a conflict and resolve them with an intraqueue barrier in the producing pass.

#### 
The following code example encodes three compute passes. The first pass runs a single copy command:
The second pass runs a copy command and a dispatch command:
The third pass runs a single dispatch command:
The example has at least one access conflict because passes 2 and 3 both access a common resource, `bufferD`:
- The copy command from the second pass stores to `bufferD`.
- The dispatch command from the third pass loads from `bufferD`.

Without synchronization, the GPU can run all three passes and their stages in parallel, which can yield inconsistent results in resources with access conflicts.


#### 
To resolve access conflicts between passes from the same command queue, use a producer barrier by calling the encoder’s  method.
Each producer queue barrier temporarily blocks the GPU from running the specific stage types, which you pass to the `beforeQueueStages` parameter, in all subsequent passes in the same queue. The barrier unblocks those stages when all the stage types you pass to the `afterStages` parameter finish running in the pass and all previous passes.

> **important:**  The stages you pass to the `afterStages` parameter of the  method apply to the pass you’re encoding and all previous passes, but the stages of the `beforeQueueStages` parameter only apply to subsequent passes.

The following example modifies the code that encodes the second pass by adding a producer queue barrier just before the dispatch command stage in the second pass.
In this example, the barrier prevents the GPU from running the dispatch stage in the third pass until the blit stages in both the first and second pass finish storing their modifications.

The barrier unblocks the dispatch stage of the third pass when the blit stage from the first pass finishes running because it’s the last blit stage to finish of all the passes that apply to the `afterStages` parameter.
For more information about other synchronization mechanisms, see these articles in the series:
- 
- 
-

## Understanding the Metal 4 core API
> https://developer.apple.com/documentation/Metal/understanding-the-metal-4-core-api

### 
Metal 4 improves runtime performance and memory efficiency while making it easier to adapt your apps and games from other platforms, such as DirectX and Vulkan.
Metal 4 introduces new types for existing concepts and several new ones, including:
- Command queues
- Command buffers
- Command encoders
- Command allocators
- Argument tables
- Texture view pools
- Next generation barriers
Metal 4 introduces several types with the `MTL4` prefix that are completely independent from the original `MTL` types they replace, such as  versus . Other types are common to all versions of Metal.
| Metal 4 | Metal |
|  |  |
|  |  |
|  |  |
|  |  |
At runtime, your app can detect whether the current system supports Metal 4. For devices that support Metal 4, you can create an , otherwise, create an . The type of queue you create determines which family of types you work with. For more information, see .
You can incrementally adopt Metal 4 over time, which is convenient for larger projects. Portions of your app can individually switch to submitting work to an  instance. When applicable, an app can synchronize the work it sends to an  with other parts of the app that send work to  instances. For more information, see .

#### 
Metal 4 introduces a new command queue protocol, , which reduces CPU runtime and memory overhead by sending work to the GPU when you commit a command buffer. This means your app can submit work from any thread. You create a Metal 4 command queue by calling an  factory method, such as .
Metal 4 command queues can commit multiple command buffers as a group. Apps can encode subsets of GPU work to multiple command buffers — each on a separate worker thread. When the worker threads finish encoding to their respective command buffers, you send the command buffers to the GPU as a whole by committing them to an  instance with one of its methods, such as . This is similar to how you use an , but different in that you can also apply other types of work in addition to rendering.
You can synchronize work between command queues with an  instance, or synchronize work on the CPU and other Metal devices with an  instance. Events work with any combination of  and  instances. This interoperability makes it easier for you to:
- Coordinate work between your app’s Metal 4 queues and existing Metal code.
- Transition to Metal 4 over time and incrementally adopt its features.
You can synchronize work within the same queue by adding a barrier (see ).

#### 
Metal 4 introduces , which is more efficient and works differently than  in the following ways:
- You create a Metal 4 command buffer by calling an  factory method, such as , instead of from a queue.
- You submit a command buffer to any  instance that belongs to the same device by calling one of its methods, such as , unlike  which has its own  method.
- You can reuse and repurpose each command buffer indefinitely by starting over, encoding new commands, and committing it again, instead of allocating a new buffer.
- Unlike the default behavior of , you may need to consider a resource’s retain count because each  instance doesn’t create strong references to resources. This is similar to creating an  with the  method of an .

After committing a command buffer to a queue, you can use it again by calling its  method. You can then encode commands to the buffer as if it were a new instance. This is different from previous versions of Metal that require you to create a new transient, single-use command buffer when you need to commit more work to a queue.

#### 
The  is a companion type that provides memory for command buffers. You associate a command allocator with one command buffer at a time by calling its  method. When you finish encoding commands to a command buffer, you can apply the allocator to another command buffer by first calling the current command buffer’s  method and then another command buffer’s  method.
Each allocator manages the memory that your app needs to encode commands into the command buffer that you associate with it. Like command buffers, you create each new  instance by calling a factory method of an , such as .
Your app can manage the memory that it requires by using a command allocator for each frame’s work. When the GPU finishes the work for that frame, call the  method to release the memory for reuse.
Apps can render frames by reusing a series of allocators, one for each frame it might have in flight at the same time to begin working on the next frame.
For example, the sample code project,  (Hello Triangle), works with three frames at the same time:
At any point, each in-flight frame is in a different part of its life cycle.
- The current frame is what the app displays until the GPU finishes rendering the next frame.
- Meanwhile, the GPU is rendering the first future frame from the most recent command buffers that the app submits to the GPU.
- The app encodes the second future frame — either on the CPU or GPU — and submits the frame when other frames advance to the next stage in their life cycle.

#### 
The , , is a base protocol for other work-specific protocols that Metal provides, including:
- 
- 
- 
The base command encoder protocol defines a different interface and default behavior than its earlier counterpart, . The most important difference with Metal 4 encoders is that they don’t have methods that bind individual buffers, textures, and heaps. Instead, you configure the resource bindings in an argument table and then bind that table to one or more pipeline stages with a command encoder.
Use  to encode inference commands that apply  models into a command buffer, alongside your app’s rendering and computation workloads. For more information, see .
The  protocol is the equivalent to its earlier counterpart, , and has most of the same rendering methods. `MTL4RenderCommandEncoder` differs from `MTLRenderCommandEncoder` by removing methods that manage resource bindings and residency sets, and methods that configure store-action options and tessellation. Instead, `MTL4RenderCommandEncoder` gives you the ability to:
- Add a residency set to either an encoder’s command buffer, or the command queue you submit that command buffer to.
- Create an argument table, configure it with bindings to resources, and then assign it to an encoder that refers to those resources.
- Apply mesh shader techniques to replace tessellation functionality.

> **note:** Store-action options (see ) aren’t available because they don’t apply to Apple silicon GPUs.

`MTL4RenderCommandEncoder` also supports encoding a render pass across command buffers by:
- Suspending the work at the end of one render encoder
- Resuming the work after the beginning of the next render encoder in the sequence
This technique conceptually replaces the  protocol and simplifies encoding a render pass in parallel with multiple threads because each thread can have its own render encoder instead of tying all of them to a single render encoder.
The  protocol is a new type that combines the functionality of its three predecessors:
- 
- 
- 

#### 
Metal 4 introduces an  type that stores bindings to resources, such as data buffers, textures, and samplers, on an encoder’s behalf. Argument tables can reduce your app’s memory footprint because:
- Metal 4 encoders don’t require memory for storing the binding tables for every resource type, at every stage.
- Each table consumes only the memory it needs to store its resource bindings.
Each  instance stores a list for each resource type, which your app creates and maintains.
- Create or reuse an  instance.
- Configure how many bindings of each type it stores by configuring its properties, including  and .
- Create an argument table by passing the descriptor instance to an  factory method, such as .
- Add or update bindings to the argument table by calling its methods, such as  and .
Assign an argument table to one or more stages of a command encoder, and then the commands you encode with it can refer to the resources in the argument table’s lists, such as textures and data buffers. You can also apply a single argument table to the stages of multiple encoders at the same time.
As your app adds render or dispatch work to a command buffer by calling an encoder’s methods, the encoder looks up the resources that the method needs from the encoder’s argument table.
The design adds flexibility for reducing your app’s CPU and memory overhead. For example, in Metal 4 you can create a single argument table that stores bindings to resources that apply to multiple encoders, and then reuse that argument table indefinitely. This approach is more efficient than previous Metal encoder types, where each encoder instance manages its own resource binding tables. In Metal 4, the memory and runtime savings add up with each common resource your encoders share, and each time you assign the argument table to a new encoder.

> **tip:**  Create and configure separate argument tables for your app’s disparate types of work so that each table only manages the common resources for similar or overlapping tasks.


#### 
Earlier versions of Metal support tracking data hazards for textures and heaps you create with hazard tracking (see the `hazardTrackingMode` property of the  and  types, respectively).
In Metal 4, the framework considers all resources untracked. You need to synchronize pipeline stages that can concurrently access a resource if any of the shaders in these pipelines modify it. For example, apps commonly encode a pass that writes to a common buffer that a later pass needs to read from to do its work, such as rendering to a texture.
One of the most efficient ways to synchronize work between two or more passes is to add a . A barrier tells the GPU that it needs to avoid a race condition by delaying the start of a pipeline stage until a previous stage finishes, so that it’s safe to access the results of that stage. For example, if an app encodes a compute pass that produces data that a subsequent render pass consumes in its fragment shader, the app needs to add a barrier between the dispatch stage of the compute pass and the fragment stage of the render pass. In that scenario, the barrier signals to the GPU that it needs to wait before running the fragment stage of the render pass until the dispatch stage of the compute pass finishes modifying common resources.

#### 
Metal 4 introduces the  protocol which creates lightweight texture views that can reduce your app’s memory footprint compared to creating the equivalent instances of . Each  instance is a heavyweight type that stores a texture’s underlying data and metadata. Each texture also has an implicit , which is the default format interpretation of the texture’s underlying data. With a texture view pool, you can create lightweight texture views that interpret and access a texture’s underlying data with a different format than its original. For example, you can create an  instance with its  equal to , and then create a new texture view of the same texture that interprets the underlying data as if its pixel format is .
Every texture view has a unique , which includes:
- Texture views you create with an  instance’s methods, which is the return value of those methods
- Implicit texture views that Metal assigns to each  you create, which you can access with a texture’s  property
The resource IDs that a texture pool creates are part of a contiguous range of values that belong to that pool. For example, for a texture view pool that has 20 texture views, you can get the resource ID of the fifth texture view by adding `4` to the first texture view’s resource ID. Similarly, you can get the resource ID of the last (twentieth) texture view by adding `19` to the first texture view’s resource ID.
You can reuse a resource ID within a texture view pool, such as when you no longer need it, by reassigning the index of that pool with another view of any texture.
A texture view pool has a contiguous range of `MTLResourceID` values that you can manage by creating lightweight texture views, each of which gets its own resource ID. You can repurpose any ID in the pool to another view when you no longer need the view that it currently represents.


---
# PASSKIT

## Offering Apple Pay in Your App
> https://developer.apple.com/documentation/PassKit/offering-apple-pay-in-your-app

### 
This sample shows the implementation of an integrated Apple Pay eCommerce experience across iOS and watchOS. The sample app demonstrates how to use the Apple Pay button, display the Apple Pay payment sheet, make payment requests, and accept coupon codes.
The sample ticket booking app implements buying a ticket using Apple Pay in:
- An iOS app.
- A watchOS app.
A shared `PaymentHandler` class handles payment in each of the apps.

> **note:** This sample code project is associated with WWDC21 session .


#### 
Test Apple Pay payments with this sample by configuring the bundle identifiers and Apple Pay configuration items in Xcode. Doing this requires an Apple developer account. Before building the app, complete these four steps:
1. Change the bundle ID for each target so that it’s unique for your developer account; change `example` in the bundle ID to something that represents you or your organization.
2. In the build settings, update the value of the user-defined `OFFERING_APPLE_PAY_BUNDLE_PREFIX` setting to match the prefix of the bundle IDs you changed in step 1. For example, if you changed `example` in each bundle ID to your organization name, change `example` in `OFFERING_APPLE_PAY_BUNDLE_PREFIX` to the same organization name. Xcode configures the required merchant ID for Apple Pay in each target when you build the project.
3. Set up the Apple Pay Merchant Identity and Apple Pay Payment Processing certificates. For more information on setting up a merchant identity and processing certificates, see .
4. Set the signing option for the iOS app to “Automatically manage signing.”
Running this app on an iPhone or Apple Watch requires an Apple Pay card. Running in Simulator doesn’t require a card.

> **note:** Not all Apple Pay features are supported in the iOS simulator. Testing Apple Pay is unsupported in the watchOS simulator.

For more information about processing an Apple Pay payment using a payment platform or merchant bank, see . To set up your sandbox environment for testing, see .

#### 
Apple Pay includes pre-built buttons to start a payment interaction, or to set up payment methods. The iOS app displays the payment button if the device can make payments, and it contains at least one payment card; otherwise it displays the button to add a payment.
This sample checks for the ability to make payments using , and checks for available payment cards using . Both of these methods are part of .

```swift
static let supportedNetworks: [PKPaymentNetwork] = [
    .amex,
    .discover,
    .masterCard,
    .visa
]

class func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
    return (PKPaymentAuthorizationController.canMakePayments(),
            PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks))
}
```
The iOS app displays the payment button by adding an instance of .

> **note:** The sample app doesn’t display the add button if a device can’t accept payments due to hardware limitations, parental controls, or any other reasons.


```swift
let result = PaymentHandler.applePayStatus()
var button: UIButton?

if result.canMakePayments {
    button = PKPaymentButton(paymentButtonType: .book, paymentButtonStyle: .black)
    button?.addTarget(self, action: #selector(ViewController.payPressed), for: .touchUpInside)
} else if result.canSetupCards {
    button = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
    button?.addTarget(self, action: #selector(ViewController.setupPressed), for: .touchUpInside)
}

if let applePayButton = button {
    let constraints = [
        applePayButton.centerXAnchor.constraint(equalTo: applePayView.centerXAnchor),
        applePayButton.centerYAnchor.constraint(equalTo: applePayView.centerYAnchor)
    ]
    applePayButton.translatesAutoresizingMaskIntoConstraints = false
    applePayView.addSubview(applePayButton)
    NSLayoutConstraint.activate(constraints)
}
```
The watchOS app adds the button to the storyboard as an instance of .

#### 
The app defines two shipping methods: delivery with estimated shipping dates and on-site collection. The payment sheet displays the delivery information for the chosen shipping method, including estimated delivery dates. Configuring the dates requires a calendar, start date components, and end date components

```swift
func shippingMethodCalculator() -> [PKShippingMethod] {
    // Calculate the pickup date.
    
    let today = Date()
    let calendar = Calendar.current
    
    let shippingStart = calendar.date(byAdding: .day, value: 3, to: today)!
    let shippingEnd = calendar.date(byAdding: .day, value: 5, to: today)!
    
    let startComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: shippingStart)
    let endComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: shippingEnd)
     
    let shippingDelivery = PKShippingMethod(label: "Delivery", amount: NSDecimalNumber(string: "0.00"))
    shippingDelivery.dateComponentsRange = PKDateComponentsRange(start: startComponents, end: endComponents)
    shippingDelivery.detail = "Ticket sent to you address"
    shippingDelivery.identifier = "DELIVERY"
    
    let shippingCollection = PKShippingMethod(label: "Collection", amount: NSDecimalNumber(string: "0.00"))
    shippingCollection.detail = "Collect ticket at festival"
    shippingCollection.identifier = "COLLECTION"
    
    return [shippingDelivery, shippingCollection]
}
```

#### 
Both iOS and watchOS implementations start the payment process by calling the `startPayment` method of the shared `PaymentHandler`. Updates to the payment sheet use the completion handlers implemented by both apps. The `startPayment` method stores the completion handlers because the Apple Pay functionality is asynchronous; and then the method creates an array of  to display the charges on the payment sheet.

```swift
let ticket = PKPaymentSummaryItem(label: "Festival Entry", amount: NSDecimalNumber(string: "9.99"), type: .final)
let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "1.00"), type: .final)
let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "10.99"), type: .final)
paymentSummaryItems = [ticket, tax, total]
```
The app configures a  using the list of payment items and other details.

```swift
let paymentRequest = PKPaymentRequest()
paymentRequest.paymentSummaryItems = paymentSummaryItems
paymentRequest.merchantIdentifier = Configuration.Merchant.identifier
paymentRequest.merchantCapabilities = .capability3DS
paymentRequest.countryCode = "US"
paymentRequest.currencyCode = "USD"
paymentRequest.supportedNetworks = PaymentHandler.supportedNetworks
paymentRequest.shippingType = .delivery
paymentRequest.shippingMethods = shippingMethodCalculator()
paymentRequest.requiredShippingContactFields = [.name, .postalAddress]
#if !os(watchOS)
paymentRequest.supportsCouponCode = true
#endif
```
Next the app displays the payment sheet by calling  with the payment request. Both apps present the payment sheet using `present(completion:)`.
The payment sheet handles all user interactions, including payment confirmation. It requests updates using the completion handlers stored by the `startPayment` method when a user updates the sheet.

```swift
paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
paymentController?.delegate = self
paymentController?.present(completion: { (presented: Bool) in
    if presented {
        debugPrint("Presented payment controller")
    } else {
        debugPrint("Failed to present payment controller")
        self.completionHandler(false)
    }
})
```

#### 
The `PaymentHandler` class handles coupons by implementing the  protocol method .
After the user enters an accepted coupon code, the method adds a new `PKPaymentSummaryItem` displaying the discount, and adjusts the `PKPaymentSummaryItem` with the discounted total.

> **note:** This method is wrapped in a conditional compilation flag as watchOS 8 doesn’t support coupon codes.


```swift
#if !os(watchOS)

func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                    didChangeCouponCode couponCode: String,
                                    handler completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void) {
    // The `didChangeCouponCode` delegate method allows you to make changes when the user enters or updates a coupon code.
    
    func applyDiscount(items: [PKPaymentSummaryItem]) -> [PKPaymentSummaryItem] {
        let tickets = items.first!
        let couponDiscountItem = PKPaymentSummaryItem(label: "Coupon Code Applied", amount: NSDecimalNumber(string: "-2.00"))
        let updatedTax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "0.80"), type: .final)
        let updatedTotal = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "8.80"), type: .final)
        let discountedItems = [tickets, couponDiscountItem, updatedTax, updatedTotal]
        return discountedItems
    }
    
    if couponCode.uppercased() == "FESTIVAL" {
        // If the coupon code is valid, update the summary items.
        let couponCodeSummaryItems = applyDiscount(items: paymentSummaryItems)
        completion(PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: applyDiscount(items: couponCodeSummaryItems)))
        return
    } else if couponCode.isEmpty {
        // If the user doesn't enter a code, return the current payment summary items.
        completion(PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: paymentSummaryItems))
        return
    } else {
        // If the user enters a code, but it's not valid, we can display an error.
        let couponError = PKPaymentRequest.paymentCouponCodeInvalidError(localizedDescription: "Coupon code is not valid.")
        completion(PKPaymentRequestCouponCodeUpdate(errors: [couponError], paymentSummaryItems: paymentSummaryItems, shippingMethods: shippingMethodCalculator()))
        return
    }
}

#endif
```

#### 
When the user authorizes the payment, the system calls the  method of the  protocol. Your handler confirms that the shipping address meets the criteria needed, and then calls the completion handler to report success or failure of the payment.
The sample code contains a comment at the place you add code for processing the payment.

```swift
func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    
    // Perform basic validation on the provided contact information.
    var errors = [Error]()
    var status = PKPaymentAuthorizationStatus.success
    if payment.shippingContact?.postalAddress?.isoCountryCode != "US" {
        let pickupError = PKPaymentRequest.paymentShippingAddressUnserviceableError(withLocalizedDescription: "Sample App only available in the United States")
        let countryError = PKPaymentRequest.paymentShippingAddressInvalidError(withKey: CNPostalAddressCountryKey, localizedDescription: "Invalid country")
        errors.append(pickupError)
        errors.append(countryError)
        status = .failure
    } else {
        // Send the payment token to your server or payment provider to process here.
        // Once processed, return an appropriate status in the completion handler (success, failure, and so on).
    }
    
    self.paymentStatus = status
    completion(PKPaymentAuthorizationResult(status: status, errors: errors))
}
```
Once the sample app calls the completion handler in the  method, Apple Pay tells the app it can dismiss the payment sheet by calling . iOS and watchOS both handle dismissing the sheet as appropriate for each platform. In the iOS app, if payment succeeds the completion handler performs a segue to display a new view controller. If the payment fails, it remains on the payment sheet so the user can attempt payment with a different card or correct any issues.

```swift
@objc func payPressed(sender: AnyObject) {
    paymentHandler.startPayment() { (success) in
        if success {
            self.performSegue(withIdentifier: "Confirmation", sender: self)
        }
    }
}
```


---
# REALITYKIT

## Presenting images in RealityKit
> https://developer.apple.com/documentation/RealityKit/presenting-images-in-realitykit

### 
RealityKit apps can easily display images in 3D space using , which can display traditional 2D and  as well as generate and display  — which represents the content of an existing image in three dimensions.
Spatial scenes are different from . A  presents two separate 2D images, one to each eye, to create the illusion of a three dimensional view. , on the other hand, generate textured 3D geometry from either a  or a regular 2D image.

This sample app demonstrates how to use  and  to convert an existing 2D image to a 3D spatial scene, and how to present the 2D and 3D versions of the image using  in a SwiftUI app.

### 
Image presentation components can present images in several modes. Your apps can choose to use any or all of these modes.
This sample displays images using `mono` and `spatial3D` viewing modes.

### 
To display an image, create an  and attach it to an entity in your scene. You can attach it to any entity, and you’ll also want to attach it to one that has no visual representation in your scene. This sample creates an empty  property called `contentEntity` in the `AppModel` class for that purpose.

```swift
var contentEntity: Entity = Entity()
```
In the  `make` closure, the app calls an asynchronous method to create an  and adds it to `contentEntity`.

```swift
await appModel.createImagePresentationComponent()
```
The `createImagePresentationComponent` function creates an  from a 2D image, then creates an image presentation component with that image and attaches it to the `contentEntity`:

```swift
func createImagePresentationComponent() async {
    guard let imageURL else {
        print("ImageURL is nil.")
        return
    }
    spatial3DImageState = .notGenerated
    spatial3DImage = nil
    do {
        spatial3DImage = try await ImagePresentationComponent.Spatial3DImage(contentsOf: imageURL)
    } catch {
        print("Unable to initialize spatial 3D image: \(error.localizedDescription)")
    }

    guard let spatial3DImage else {
        print("Spatial3DImage is nil.")
        return
    }
    
    let imagePresentationComponent = ImagePresentationComponent(spatial3DImage: spatial3DImage)
    contentEntity.components.set(imagePresentationComponent)
    if let aspectRatio = imagePresentationComponent.aspectRatio(for: .mono) {
        imageAspectRatio = CGFloat(aspectRatio)
    }
}
```
The `createImagePresentationComponent` method stores the  of the newly created ImagePresentationComponent in the `AppModel`.
The app implements an   modifier for `aspectRatio` in the `AppModel` to ensure that the  size matches the image.

```swift
.onChange(of: appModel.imageAspectRatio) { _, newAspectRatio in
    guard let windowScene = sceneDelegate.windowScene else {
        print("Unable to get the window scene. Resizing is not possible.")
        return
    }

    let windowSceneSize = windowScene.effectiveGeometry.coordinateSpace.bounds.size

    //  width / height = aspect ratio
    // Change ONLY the width to match the aspect ratio.
    let width = newAspectRatio * windowSceneSize.height

    // Keep the height the same.
    let size = CGSize(width: width, height: UIProposedSceneSizeNoPreference)

    UIView.performWithoutAnimation {
        // Update the scene size.
        windowScene.requestGeometryUpdate(.Vision(size: size))
    }
}
```

### 
In the `update` closure of the , the app retrieves the presentation screen size of the image presentation component using the entity’s  property. This ensures that update is called when the `presentationScreenSize` changes.

```swift
guard let presentationScreenSize = appModel
    .contentEntity
    .observable
    .components[ImagePresentationComponent.self]?
    .presentationScreenSize, presentationScreenSize != .zero else {
        print("Unable to get a valid presentation screen size from the content entity.")
        return
}
```
The app sets the z axis position of the `contentEntity` to 0.0. This displays the image presentation component flush against the background.

```swift
let originalPosition = appModel.contentEntity.position(relativeTo: nil)
appModel.contentEntity.setPosition(SIMD3<Float>(originalPosition.x, originalPosition.y, 0.0), relativeTo: nil)
```
To display the image at an appropriate size, the app wraps a  inside a :

```swift
GeometryReader3D { geometry in
    RealityView { content in
```
In the `make` and `update` closure of the , the app converts the geometry reader’s frame bounds into the scene’s coordinate space:

```swift
let availableBounds = content.convert(geometry.frame(in: .local), from: .local, to: .scene)
```
Then, the app calls the `scaleImagePresentationToFit` method which scales the image to fit into the geometry reader’s frame bounds:

```swift
scaleImagePresentationToFit(in: availableBounds)
```
The `scaleImagePresentationToFit` method calculates x and y scale values to preserve the aspect ratio of the presented image at the current , and sets those scale values as the content entity’s scale:

```swift
func scaleImagePresentationToFit(in boundsInMeters: BoundingBox) {
    guard let imagePresentationComponent = appModel.contentEntity.components[ImagePresentationComponent.self] else {
        return
    }

    let presentationScreenSize = imagePresentationComponent.presentationScreenSize
    let scale = min(
        boundsInMeters.extents.x / presentationScreenSize.x,
        boundsInMeters.extents.y / presentationScreenSize.y
    )

    appModel.contentEntity.scale = SIMD3<Float>(scale, scale, 1.0)
}
```

### 
It can take several seconds to generate a spatial scene. To preserve the user experience, you have two options:
- You can generate the spatial scene first and then add it to the image presentation component.
- Alternatively, you can can add it to the image presentation component first and then generate the spatial scene afterwards.
If you create the spatial scene before adding it to the component, the generated spatial scene appears as soon as you add it. If you add a 2D or stereo image to the component first and then generate the spatial scene later, the component presents a conversion UI like the one in the Photos app. This indicates that it’s generating the spatial scene

> **note:** Generation and viewing of spatial scenes is not supported in the simulator.

This sample adds the images to the component first, then generates the spatial scene on a button press. It does that by first declaring an enumeration in the app data model to represent the current status of the displayed image.

```swift
enum Spatial3DImageState {
    case notGenerated
    case generating
    case generated
}
```
The app currently displays a 2D image in an . When the viewer clicks the Show as 3D button for the first time, it checks to see if the spatial 3D image has been generated, and returns if it has to avoid doing unnecessary work.

```swift
guard spatial3DImageState == .notGenerated else {
    print("Spatial 3D image already generated or generation is in progress.")
    return
}
```
The viewing mode of the image presentation component changes to , calls  on the spatial 3D image it displays, and sets the image state to `.generated` so it knows not to generate it again:

```swift
guard var imagePresentationComponent = contentEntity.components[ImagePresentationComponent.self] else {
    print("ImagePresentationComponent is missing from the entity.")
    return
}
// Set the desired viewing mode before generating so that it will trigger the
// generation animation.
imagePresentationComponent.desiredViewingMode = .spatial3D
contentEntity.components.set(imagePresentationComponent)

// Generate the Spatial3DImage scene.
spatial3DImageState = .generating
try await spatial3DImage.generate()
spatial3DImageState = .generated
```


---
# SAFARISERVICES

## Packaging and distributing Safari Web Extensions with App Store Connect
> https://developer.apple.com/documentation/SafariServices/packaging-and-distributing-safari-web-extensions-with-app-store-connect

### 
The Safari web extension packager enables you to package and distribute your Safari extensions using App Store Connect from any web browser, without requiring a Mac or access to Xcode. After packaging your extension, you can use TestFlight to test your extension or submit it to the App Store for distribution.
Safari web extension packager is also available as a command line tool which you can use alongside Xcode on a Mac. To learn more about using the command line tool, see .

#### 
To access and use the Safari Extension Packager, you need to enroll your Apple account in the Apple Developer Program. For details on how to create an Apple Account and enroll in the Apple Developer program, see 

#### 
To create an app record, the Account Holder, Admin, or an App Manager opens . Alternately, a team member with a Developer or Marketing role with access to create app records in App Store Connect can create this app record.

> **note:** The Safari web extension packager can create apps for both macOS and iOS. People can use the iOS app and extension on iOS, iPadOS, and visionOS.

Follow these steps:
1. In Apps, click the Add button (+) on the top left.
2. In the pop-up menu, select New App.
3. In the New App dialog, select the platforms (macOS, iOS, or both), and enter the app information.
- If you’re registered as a company, you have the option to .
- Choose a bundle identifier (ID) for your app. This uniquely identifies an app in the Apple ecosystem — every app needs a unique ID. It’s recommended that you use reverse domain-name notation, such as `com.example.MyApp`.
- Choose a SKU for your app. This is a number you choose that helps you keep track of your app; the SKU isn’t viewable by people using your app.
- Under User Access, choose Limited Access or Full Access. If you select Limited Access, choose who is able to access this app.
4. Click Create. Then, check for messages that indicate missing information.
For more information about creating an app record, see .


#### 
After creating an app record, navigate to the Xcode Cloud tab. Under Safari Web Extension Packager, click Upload.
Select and upload your extension files. The Safari Web Extension Package assembles the app for your extension. You need to upload the full contents of your extension, including the manifest and all related resources.
You can see the status of the packaging process on the Builds page. You can upload multiple builds at once. When packaging is complete, distribute your extension to beta testers using TestFlight. For more information on using TestFlight, see 
Review any reported exceptions, and see  for details on how to resolve them.

> **note:** The compute time needed to package web extensions is deducted from the 25 hours per month of Xcode Cloud included in your Apple Developer Program membership.



#### 
Use TestFlight to distribute beta builds of your app and extension, manage beta testers, and collect feedback. Make improvements to your extension and continue distributing builds until all issues are resolved before submitting your extension for App Store review and distribution.
For more information, see .


#### 
Before submitting your app to the App Store for review, confirm that it’s ready for public release and that you’re making the most of your product page.
Before submission,  and decide whether to , or .
When you’re ready to submit your app for review:
1. In your web browser, open App Store Connect.
2. Go to the Apps section.
3. Select your app.
4. Add the appropriate build for review.
5. Click Submit. After you submit your app, the app status changes to In Review.
Once your app is approved and ready for distribution on the App Store, its status changes to “Ready for Distribution.” For more information, see .


---
# STOREKIT

## In-App Purchase
> https://developer.apple.com/documentation/StoreKit/in-app-purchase

### 
With the In-App Purchase API, you can offer customers the opportunity to purchase digital content and services in your app. Customers can make the purchases within your app, and find your promoted products on the App Store.
The StoreKit framework connects to the App Store on your app’s behalf to prompt for, and securely process, payments. The framework then notifies your app, making the transactions for In-App Purchases available to your app on all of the customer’s devices. For each transaction that represents a current purchase, your app delivers the purchased products. To validate purchases, you can verify transactions on your server, or rely on StoreKit’s verification.

The App Store can also communicate with your server. It notifies your server of transactions and auto-renewable subscription events through , and provides the same transaction information, and more, through the .
To learn how adding In-App Purchases fits in an overall app development workflow for the App Store, see . For an overview of In-App Purchases and its features, including its configuration, testing capabilities, marketing for your products, and more, see . For an overview on subscriptions, including creating subscription groups, Family Sharing, and more, see .

#### 
To use the In-App Purchase API, you first need to configure the products that your app merchandises.
- In the early stages of development, you can configure the products in the StoreKit configuration file in Xcode, and test your code without any dependency on App Store Connect. For more information, see .
- When you’re ready for sandbox testing and production, configure the products in App Store Connect. You can add or remove products and refine or reconfigure existing products as you develop your app. For more information, see .
You can also offer apps and In-App Purchases that run on multiple platforms as a single purchase. For more information on universal purchase, see .

#### 
The In-App Purchase API takes advantage of Swift features like concurrency to simplify your In-App Purchase workflows, and SwiftUI to build stores with . Use the API to manage access to content and subscriptions, receive App Store-signed transaction information, get the history of all In-App Purchase transactions, and more.

> **note:**  Session 10114: 

The In-App Purchase API offers:
- Transaction information that’s App Store-signed in JSON Web Signature (JWS) format.
- Transaction and subscription status information that’s simple to parse in your app.
- An entitlements API, , that simplifies determining entitlements to unlock content and services for your customers.

> **note:**  Session 110404: 

To support a store in your app, implement the following functionality:
- Listen for transaction state changes using the transaction listener, , to provide up-to-date service and content while your app is running.
- Use  to merchandise your products; or request products to display from the App Store with  and enable purchases using . Unlock purchased content and services based on the purchase result, .
- Iterate through a customer’s purchases anytime using the transaction sequence , and unlock the purchased content and services.
- Optionally, validate the signed transactions and signed subscription status information that you receive from the API.

## Understanding StoreKit workflows
> https://developer.apple.com/documentation/StoreKit/understanding-storekit-workflows

### 
StoreKit offers an expansive API for creating an almost limitless variety of in-app stores. This sample app shows you precisely what you need to implement in order to get up and running with a store in your app that can implement several In-App Purchase (IAP) types, including subscriptions.

### 
The design of this sample doesn’t require any special setup, or even the creation of products in App Store Connect; it uses StoreKit Testing in Xcode and the Transaction Manager window in Xcode to test In-App Purchase.
This project comes with the following products set up locally:
- A consumable item
- A non-consumable item
- A collection of consumable items
- A monthly subscription
- A yearly (annual) subscription
- A premium yearly (annual) subscription, with a “1 month free” introductory offer.
For more information on the product types that App Store Connect supports, see 

> **note:** The transactions this app demonstrates don’t get information from App Store Connect and don’t incur charges. Xcode simulates successful transactions without processing actual payments.

To see the pre-configured local StoreKit products, select the `LocalConfiguration` file in the project’s file navigator. This file lists all of the types, descriptions, and properties of the demo products the app supports.
For more information on using the `LocalConfiguration` file, including creating products and inspecting or modifying transactions, see .
To run the app, press the Xcode run button, or press command-R. To purchase any demo products, click or tap the buy button on a product, and the system presents the payment sheet that you can either accept (purchase) or cancel. The app shows the status and results of purchases on the status display near the top of the app’s window.

### 
After you purchase products in the sample app, to reset the product to its initial unpurchased state, select Debug > StoreKit > Manage Transactions. In the sample app’s Transactions panel, select each transaction you want to delete, then click the  minus (”-”) button at the bottom of the list to delete it. In addition, to reset the consumable item information that the app stores, run the command `defaults delete com.example.apple-samplecode.StoreKitWorkflows` in Terminal.
For more information on all the capabilities StoreKit provides for the construction of in-app stores and customized StoreKit Views, see .


---
# SWIFTDATA

## Preserving your app’s model data across launches
> https://developer.apple.com/documentation/SwiftData/preserving-your-apps-model-data-across-launches

### 
Most apps define a number of custom types that model the data it creates or consumes. For example, a travel app might define classes that represent trips, flights, and booked accommodations. Using SwiftData, you can quickly and efficiently persist that data so it’s available across app launches, and leverage the framework’s integration with SwiftUI to refetch that data and display it onscreen.
By design, SwiftData supplements your existing model classes. The framework provides tools such as macros and property wrappers that enable you to expressively describe your app’s schema in Swift code, removing any reliance on external dependencies such as model and migration mapping files.

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
By default, SwiftData includes all noncomputed properties of a class as long as they use compatible types. The framework supports primitive types such as , , and , as well as complex value types such as structures, enumerations, and other value types that conform to the  protocol.
The code you write to define your model classes now serves as the source of truth for your app’s model layer, and the framework uses that to keep the persisted data in a consistent state.

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
If you’re not using SwiftUI, create a model container manually using the appropriate initializer:

```swift
import SwiftData

let container = try ModelContainer([
    Trip.self, 
    Accommodation.self
])
```

> **tip:** If a model type contains a relationship, you may omit the destination model type from the array. SwiftData automatically traverses a model’s relationships and includes any destination model types for you.

Alternatively, use  to create custom storage. The type provides a number of options to configure including whether:
- the storage exists only in memory.
- the storage is read-only.
- the app uses a specific App Group to store its model data.

```swift
let configuration = ModelConfiguration(isStoredInMemoryOnly: true, allowsSave: false)

let container = try ModelContainer(
    for: Trip.self, Accommodation.self, 
    configurations: configuration
)
```

> **important:** Automatic iCloud sync relies on the presence of the CloudKit entitlement, and SwiftData uses the first container it finds in that entitlement. If your app needs a particular container, use an instance of `ModelConfiguration` to specify that container.


#### 
To manage instances of your model classes at runtime, use a  — the object responsible for the in-memory model data and coordination with the model container to successfully persist that data. To get a context for your model container that’s bound to the main actor, use the  environment variable:

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
}
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
Following the insert, you can save immediately by invoking the context’s  method, or rely on the context’s implicit save behavior instead. Contexts automatically track changes to their known model instances and include those changes in subsequent saves. In addition to saving, you can use a context to fetch, enumerate, and delete model instances. For more information, see .

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
For more information about predicates, see .


---
# USERNOTIFICATIONS

## Scheduling a notification locally from your app
> https://developer.apple.com/documentation/UserNotifications/scheduling-a-notification-locally-from-your-app

### 
Use local notifications to get the user’s attention. You can display an alert, play a sound, or badge your app’s icon. For example, a background app could ask the system to display an alert when your app finishes a particular task. Always use local notifications to convey important information that the user wants.
The system handles delivery of notifications based on a time or location that you specify. If the delivery of the notification occurs when your app isn’t running or in the background, the system interacts with the user for you. If your app is in the foreground, the system delivers the notification to your app for handling.

#### 
Fill in the properties of a  object with the details of your notification. The fields you fill in define how the system delivers your notification. For example, to play a sound, assign a value to the  property of the object. Listing 1 shows a content object that displays an alert containing a title string and body text. You can specify multiple types of interaction in the same request.
Listing 1. Configuring the notification content

```swift
let content = UNMutableNotificationContent()
content.title = "Weekly Staff Meeting"
content.body = "Every Tuesday at 2pm"
```

#### 
Specify the conditions for delivering your notification using a , , or  object. Each trigger object requires different parameters. For example, a calendar-based trigger requires you to specify the date and time of delivery.
Listing 2 shows you how to configure a notification for the system to deliver every Tuesday at 2pm. The  structure specifies the timing for the event. Configuring the trigger with the `repeats` parameter set to  causes the system to reschedule the event after its delivery.
Listing 2. Configuring a recurring date-based trigger

```swift
// Configure the recurring date.
var dateComponents = DateComponents()
dateComponents.calendar = Calendar.current

dateComponents.weekday = 3  // Tuesday
dateComponents.hour = 14    // 14:00 hours
   
// Create the trigger as a repeating event.    
let trigger = UNCalendarNotificationTrigger(
         dateMatching: dateComponents, repeats: true)
```

#### 
Create a  object that includes your content and trigger conditions, and call the  ( method to schedule your request with the system. Listing 1 shows an example that uses the content from Listing 1 and Listing 2 to fill in the request object.
Listing 1. Registering the notification request

```swift
let uuidString = UUID().uuidString
let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

// Schedule the request with the system.
let notificationCenter = UNUserNotificationCenter.current()
do {
    try await notificationCenter.add(request)
} catch {
    // Handle errors that may occur during add.
}
```

#### 
Once scheduled, a notification request remains active until its trigger condition is met, or you explicitly cancel it. Typically, you cancel a request when conditions change and you no longer need to notify the user. For example, if the user completes a reminder, you’d cancel any active requests associated with that reminder. To cancel an active notification request, call the  method of .


---
# VISION

## Recognizing tables within a document
> https://developer.apple.com/documentation/Vision/recognize-tables-within-a-document

### 
This sample app shows how to capture document images using the device camera and extract structured data from tables. The app uses the  API to detect a table and create a contact list from the extracted data.
When you run the app, you point your device camera at a document that contains a table of information. After capturing a photo, the app analyzes the table data and displays the formatted data so you can export the information to apps like Notes or Numbers.
The sample demonstrates three main capabilities:
1. Setting up camera capture with  to photograph documents.
2. Detecting a table in a document image using Vision.
3. Parsing structured data from table cells using DataDetection.

> **note:** This sample code project is associated with WWDC25 session 272: .


### 
Because this sample app requires camera access, you’ll need to build and run this sample on a device. When you first launch the app on a device, grant the app access to the camera. In the sample project’s assets folder, open the `sampleDocuments.png` file and use the rear camera on iPad or iPhone to take a picture of the document. Optionally, if you have access to a printer, print this file and take a picture of it with your device.

### 
The app starts by showing a camera preview where you can frame and take a picture of the document. To setup this preview and capture, the app creates a capture session with `AVFoundation`:

```swift
// Performs the initial capture session configuration.
private func setUpSession() throws {
    // Return early if already set up.
    guard !isSetUp else { return }

    // Retrieve the default camera.
    guard let defaultCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
        throw CameraError.deviceUnavailable
    }

    // Add inputs for the default camera and microphone devices.
    activeVideoInput = try addInput(for: defaultCamera)

    // Configure the session preset based on the current capture mode.
    captureSession.sessionPreset = .photo
    // Add the photo capture output as the default output type.
    try addOutput(photoCapture.output)

    isSetUp = true
}
```
The `defaultCamera` uses the device’s rear camera and the `.photo` preset sets up the session to capture a picture of the document.
When you tap the capture button, the app calls `capturePhoto`:

```swift
func capturePhoto() async throws -> Data {
    try await photoCapture.capturePhoto()
}
```
This asynchronous method returns the captured photo as `Data`, which the app passes to the Vision model for analysis.

### 
The app uses Vision to find the table in the captured document image. To detect the table, the app uses . The Vision framework uses a default method for image processing: pass in the image, run the request, and get the extracted contents in an observation.

```swift
/// Process an image and return the first table detected.
private func extractTable(from image: Data) async throws -> DocumentObservation.Container.Table {

    // The Vision request.
    let request = RecognizeDocumentsRequest()

    // Perform the request on the image data and return the results.
    let observations = try await request.perform(on: image)

    // Get the first observation from the array.
    guard let document = observations.first?.document else {
        throw AppError.noDocument
    }

    // Extract the first table detected.
    guard let table = document.tables.first else {
        throw AppError.noTable
    }

    return table
}
```
The  method runs the  on the image and returns a . Each document is a container that holds text, tables, lists, or barcodes. The app accesses the table from the document’s  property.
The app highlights the detected table with a blue outline showing the boundaries.

### 
With the extracted structure, the app can access the data in the table cells. The app parses through the rows and columns to get the table data and converts it to an array of `Contact` objects:

```swift
/// Extract the name, email address, and phone number from a table into a list of contacts.
private func parseTable(_ table: DocumentObservation.Container.Table) -> [Contact] {
    var contacts = [Contact]()

    // Iterate over each row in the table.
    for row in table.rows {
        // Take the contact name from the first column.
        guard let firstCell = row.first else {
            continue
        }
        // Extract the text content from the transcript.
        let name = firstCell.content.text.transcript

        // Look for email addresses and phone numbers in the remaining cells.
        var detectedPhone: String? = nil
        var detectedEmail: String? = nil

        for cell in row.dropFirst() {
            // Get all detected data in the cell, then match emails and phone numbers to a contact. 
            for data in cell.content.text.detectedData {
                switch data.match.details {
                case .emailAddress(let email):
                    detectedEmail = email.emailAddress
                case .phoneNumber(let phoneNumber):
                    detectedPhone = phoneNumber.phoneNumber
                default:
                    break
                }
            }
        }

        // Create a contact if an email was detected.
        if let email = detectedEmail {
            let contact = Contact(name: name, email: email, phoneNumber: detectedPhone)
            contacts.append(contact)
        }
    }

    return contacts
}
```
The app takes the contact name from the first column and accesses the text content using the  property.
To process the remaining columns, the app skips the first cell by using  on the row. It uses the  framework to find email addresses and phone numbers in the `cell.content.text.detectedData` array.
The app creates a contact only when it finds an email address. After processing the table, the app stores all the contacts in an array and people can view it through the `ContactView`.

```swift
struct ContactView: View {
    let contacts: [Contact]
    var body: some View {
        Text("Contacts")
        List(contacts, id: \.name) { contact in
            HStack {
                Text(contact.name)
                Spacer()
                Text(contact.email)
                Spacer()
                Text(contact.phoneNumber ?? "")
            }
        }
    }
}
```
A person can see this list of extracted contacts in the app by clicking the View Contacts button above the photo capture. Each entry shows the contact’s name and email address, with phone numbers included when detected in the table.

### 
The app allows you to tap on the cells in the captured table and use the data within the cells to call or send a message. It uses the  property of the `DocumentObservation` to access the selected cell and to ensure that people only tap within the table bounds.

```swift
extension DocumentObservation.Container.Table {
    /// Returns the contents of a cell that someone taps.
    func cell(at point: NormalizedPoint) -> TableCell? {
        let visionPoint = point.cgPoint
        // Verify that the tap occurs inside the bounding region of the table.
        guard self.boundingRegion.normalizedPath.contains(visionPoint) else {
            return nil
        }
        // Inspect each cell.
        for row in self.rows {
            for cell in row {
                // Check if the tap occurs inside the cell.
                if cell.content.boundingRegion.normalizedPath.contains(visionPoint) {
                    return TableCell(cell)
                }
            }
        }
        return nil
    }
}
```
The method first verifies that the tap occurs within the table’s overall `boundingRegion`, then iterates through each cell’s `boundingRegion` to find the one that contains the tap. Bounding regions use normalized coordinates (`0.0` to `1.0`) relative to the image dimensions, which makes them work at any display scale.
When the method finds a cell, the app displays a popup showing the cell’s content. If the cell contains an email address, people can tap on the address to compose a message. For phone numbers, people can tap to call or send a text message.

### 
You can also export the table data in tab-separated values (TSV) format to copy and paste into compatible apps like Notes or Numbers:

```swift
/// Convert the table into a TSV string format that's compatible with pasting into Notes or Numbers.
///
/// Tables have at most one line per cell, and no cells that span multiple rows or columns.
func exportTable() async throws -> String {
    guard let rows = self.table?.rows else {
        throw AppError.noTable
    }
    // Map each row into a tab-delimited line.
    let tableRowData = rows.map { row in
        return row.map({ $0.content.text.transcript }).joined(separator: "\t")
    }
    // Create a multiline string with one row per line.
    return tableRowData.joined(separator: "\n")
}
```
Each row becomes a line in the output string, with the `transcript` property providing the recognized text from each cell. The `"\t"` separator creates the TSV format by placing tab characters between cells in the same row. The outer `joined(separator: "\n")` call puts each row on its own line.
People can tap the `Copy Table` button to copy this formatted text to the clipboard, then paste it into other apps. The table structure remains intact when pasted.


---
# WIDGETKIT

## Creating a widget extension
> https://developer.apple.com/documentation/WidgetKit/creating-a-widget-extension

### 
Widgets display relevant, glanceable content that people can quickly access for more details. Your app can provide a variety of widgets, letting people focus on the information that’s most important to them.
A good way to get started with widgets and WidgetKit is by adding a  widget to your app. A static widget doesn’t need any configuration by a person. For example, a static widget might show a stock market summary, or the next event on the person’s calendar. The  the widget shows is dynamic, but the  of data it shows is fixed. Consider the information your app presents, and choose something that people would find useful to see at a glance on their device.
Widgets can display data in many sizes, from small watch complications or Dynamic Island presentations, to extra large iPad and macOS widgets. The example that follows below focuses on a single size widget, the small system size, or . The example widget displays the status of a hypothetical game such as the health level of a character.
You build widgets using SwiftUI. While there are similarities to how you present views in your app, some aspects are unique to developing widgets. For more information about using SwiftUI, refer to . However, not all SwiftUI views work in widgets. For a list of the views that work in widgets, refer to .

#### 
The Widget Extension template provides a starting point for creating your widget. The template creates an extension target that contains a single widget. Later, you can add widgets to the same extension to display different types of information or to support additional widget sizes.
1. Open your app project in Xcode and choose File > New > Target.
2. From the Application Extension group, select Widget Extension, and then click Next.
3. Enter the name of your extension.
4. Deselect the Include Live Activity and Include Configuration App Intent checkboxes, if they’re selected.
5. Click Finish.


> **note:** Live Activities use WidgetKit and share many aspects of their design and implementation with the widgets in your app. If your app supports Live Activities, consider implementing them at the same time you add your widgets. For more information about Live Activities, refer to .

The widget extension template provides an initial implementation that conforms to the  protocol. The widget’s `body` property determines the type of content that the widget presents. Static widgets use a  for the `body` property. Other types of widget configurations include:
-  that enables user customization, such as a weather widget that needs a zip or postal code for a city, or a package-tracking widget that needs a tracking number.
-  to present live data, such as scores during a sporting event or a food delivery estimate.
-  to provide relevance clues for widgets in watchOS.
For more information about these other widget configurations, refer to , , and .

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
The widget’s provider generates a timeline for the widget, and includes the game-status details in each entry. When the date of each timeline entry arrives, WidgetKit invokes the `content` closure to display the widget’s content. Finally, the modifiers specify the name and description shown in the widget gallery, and the sizes that the widget supports.

> **important:** For an app’s widget to appear in the widget gallery, a person must launch the app that contains the widget at least once after the app is installed.

Note the usage of the `@main` attribute on this widget. This attribute indicates that the `GameStatusWidget` is the entry point for the widget extension, implying that the extension contains a single widget. To support multiple widgets, refer to the .

#### 
The timeline provider you define generates a sequence of timeline entries. Each specifies the date and time to update the widget’s content, and includes the data your widget needs to render its view. The game-status widget might define its timeline entry to include a string that represents the status of the game, as follows:

```swift
struct GameStatusEntry: TimelineEntry {
    var date: Date
    var gameStatus: String
}
```
WidgetKit calls  to request the timeline from the provider. The timeline consists of one or more timeline entries and a reload policy that informs WidgetKit when to request a subsequent timeline.

> **tip:** You can use APNs and WidgetKit push notifications to update your widgets. To build your first widget, create a widget that uses a timeline to update its data, then add push notification updates if it’s a good fit for your widget. For more information, refer to .

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
In this example, if the widget didn’t have the current status from the server, it could store a reference to the completion, perform an asynchronous request to the server to fetch the game status, and call the completion when that request completes.
For more information about generating timelines, refer to  and . For more information about handling network requests, refer to .

#### 
In order for people to be able to use your widget, it needs to be available in the widget gallery. To show your widget in the widget gallery, WidgetKit asks the provider for a  that displays generic data. WidgetKit makes this request by calling the provider’s  method with the `context` parameter’s  property set to `true`.
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
Widgets define their content using a SwiftUI view, commonly by composing other SwiftUI views. As shown in the  section, the widget configuration contains the closure that WidgetKit invokes to render the widget’s content.
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
In your widget, as you add more supported families to the widget’s configuration, you would add additional cases in the widget view’s `body` property for each additional family.

> **note:** The view declares its body with `@ViewBuilder` because the type of view it uses varies.


#### 
A placeholder view is similar to a preview snapshot, but instead of showing example data to let people see the type of data the widget displays, it shows a generic visual representation with no specific content. When WidgetKit renders your widget, it may need to render your content as a placeholder, for example, while you load data in the background or if you tell the system that your widget contains sensitive information.

#### 
Widgets and watch complications may show sensitive information and can be highly visible, especially on devices with an Always-On display. When you create your widget or watch complication, review its content and consider hiding sensitive information.
To let people decide whether a widget should show sensitive data on a locked device, mark views that contain sensitive information using the  modifier. In iOS, people can configure whether to show sensitive data on the Lock Screen and during Always On. In Settings, they can deactivate data access for Lock Screen widgets in the ALLOW ACCESS WHEN LOCKED section of Settings > Face ID & Passcode. On Apple Watch, people can configure whether to show sensitive data during Always On by Choosing Settings > Display & Brightness > Always On > Hide Sensitive Complications. They can choose to show redacted content for all or individual complications.
If a person chooses to hide privacy sensitive content, WidgetKit renders a placeholder or redactions you configure. To configure redactions, implement the  callback, read out the  property, and provide custom placeholder views. You can also choose to render a view as unredacted with the  view modifier.
As an alternative to marking individual views as privacy sensitive, for example, if your entire widget content is privacy sensitive, you can add the Data Protection capability to your widget extension. Until a person unlocks their device to match the privacy level you chose, WidgetKit displays a placeholder instead of the widget content. First, enable the Data Protection capability for your widget extension in Xcode, then set the  entitlement to the value that fits the level of privacy you want to offer:
If you choose the `NSFileProtectionCompleteUntilFirstUserAuthentication` or `NSFileProtectionNone` protection level for your widget extension:
- WidgetKit uses its default behavior and displays a placeholder until a person authenticates after they reboot their device.
- iOS widgets are available as iPhone widgets on Mac.

#### 
Widgets typically present read-only information and don’t generally support interactive elements such as scrolling lists or text input. Widgets support some interactive elements and animations. For details on adding interactivity to your widgets, refer to .
For a list of views that WidgetKit supports, refer to . WidgetKit ignores other views when it renders the widget’s content.
Although the display of a widget is based on a snapshot of your view, you can use various SwiftUI views that continue to update while your widget is visible. For more about providing dynamic content, refer to  and .

#### 
When people interact with your widget, beyond interactive elements described above, the system launches your app to handle the request. When the system activates your app, navigate to the details that correspond to the widget’s content. Your widget can specify a URL to inform the app what content to display. To configure custom URLs in your widget:
- For all widgets, add the  view modifier to a view in your widget’s view hierarchy. If the widget’s view hierarchy includes more than one `widgetURL` modifier, the behavior is undefined.
- For widgets that use , , or , add one or more  controls to your widget’s view hierarchy. You can use both `widgetURL` and `Link` controls. If the interaction targets a `Link` control, the system uses the URL in that control. For interactions anywhere else in the widget, the system uses the URL specified in the `widgetURL` view modifier.
For more details about adding links from your widgets to your app, refer to .

#### 
Xcode allows you to look at previews of your widgets without running your app in Simulator or on a test device. The following example shows the preview code from the Emoji Rangers widget of the  sample code project.

```swift
#Preview(as: .systemMedium, widget: {
    EmojiRangerWidget()
}, timeline: {
    SimpleEntry(date: Date(), relevance: nil, hero: .spouty)
})
```
As you support more widget families in your widget, you can add more preview views to see multiple sizes in a single preview.
For additional information about previewing widgets, refer to .

#### 
To give people flexible access to your app’s content, you can support additional families, add widget types, make your widgets user-configurable, or add support for Live Activities if your app presents live data. To explore a plan to support additional features, refer to .
To explore WidgetKit code for the first time, refer to the following sample code projects:
-  is the sample code project associated with the WWDC20 code-alongs , , and , where you learn how to build your first widget.
-  expands the Emoji Rangers sample code project to include Lock Screen widgets, Live Activities, interactivity, and animations.
-  and  are sample code projects that support widgets in addition to other technologies like  and .

#### 
You can include multiple widget types in your widget extension, although your app can contain multiple extensions. For example, if some of your widgets use location information and others don’t, keep the widgets that use location information in a separate extension. This allows the system to prompt someone for authorization to use location information only for the widgets from the extension that uses location information. For details about bundling multiple widgets in an extension, refer to .


---
# XCODE

## Analyzing the performance of your shipping app
> https://developer.apple.com/documentation/Xcode/analyzing-the-performance-of-your-shipping-app

### 
Use the Xcode Organizer to view anonymized performance data from your app’s users, including launch times, memory usage, UI responsiveness, and impact on the battery. Use the data to tune the next version of your app and catch regressions that make it into a specific version of your app.
In Xcode, choose Window > Organizer to open the Organizer window, and then select the desired metric or report. In some cases, the pane shows “Insufficient usage data available” because there may not be enough anonymized data reported from participating user devices. When this happens, try checking back in a few days.
When Xcode has enough information to calculate a recommendation, it displays a recommended value for a metric on the chart displaying your app’s metrics. Use this information to plan and prioritize performance engineering work.

#### 
The Xcode Organizer shows a title, description, and graph for each type of metric. In the graph, each bar represents a version of your app. Use the pop-up menus to filter the metric data for different devices and the median or high value. If your app has an App Clip available, use the pop-up menu to filter by app type and switch between viewing metrics for the main app and the App Clip.

Metrics that show   in the detail section include an associated margin of error because the existing data is limited. Use this margin of error to determine the upper and lower bounds of the displayed value. The margin of error decreases as data increases. The release date information in this section provides the date when the selected app version is ready for sale.

#### 
To explore changes between versions for a metric, such as those for Hang Rate in the image below, click the vertical bar for your selected version.
The data for both the selected and latest versions appear to the right of the graph with the higher of the two values in bold. Change information for those versions appears in the details section below the latest version data.


#### 
Xcode compares your app’s launch time metrics with other sources, including metrics from similar apps and historical data from your app. If your app has sufficient metrics data available and Xcode determines that the launch time metrics for the current version of your app are greater than the values from other sources, it displays a recommended value for the metric as a dashed line on the histogram in the Xcode Organizer.

> **note:**  In Xcode 26, metric recommendations are available for the app launch time metric.


#### 
The Xcode Organizer presents a list of smart insights whenever the system detects new performance regressions for the latest version of your app. Each item in the insights list contains information that provides a brief summary.

To the right of the list is the detail pane that shows a chart corresponding to the selected smart insight. Note that the insight for Scroll Hitch Rate for the typical percentile of samples from “iPad (All)” devices is selected. When a selected insight corresponds to more than one percentile, or to different sets of devices, the detail pane presents a scrollable list of additional charts.
To the right of the chart is the insight data showing the metric value for the latest version, as well as the average metric values for the previous four versions. Use this information to see how your latest app version is performing with respect to the average of the previous versions.
Select the Notifications button in the upper-right corner to opt in to power and performance regression notifications. Xcode sends you a notification for the latest version of each of your shipped apps when it detects a high-impact regression. A regression is considered high impact if performance data is available and indicates the latest version of your app regresses 75 percent or more compared to the average of the previous four app versions available in the App Store. Xcode notifies you once per 24-hour period when Xcode is running. To keep notifications to a minimum, Xcode sends you no more than one notification for the same app version.

#### 
Xcode displays a flame icon next to reports in the list of smart insight reports for the issues that exhibit the largest regressions over the most recent five versions of your app, if it has enough data available. Click on an individual report to view a bar chart showing the impact trend for the most recent five versions of your app. Use this information to prioritize performance engineering work.
Xcode identifies trending insights for disk writes, hang rate, and launch time metrics.

#### 
For more details about how to use the data in the Organizer panes to improve the performance of the next version of your app, see the topics below.

## Downloading and installing additional Xcode components
> https://developer.apple.com/documentation/Xcode/downloading-and-installing-additional-xcode-components

### 
Xcode lets you manage optional components yourself so that you can install only the components you use and remove the ones you don’t. For example, install the Simulator runtimes for the devices and operating systems your app runs on, or add support for platforms that you target. You download and install Xcode components in Xcode settings or using the command line.

> **note:** Developing for visionOS requires a Mac with Apple silicon.


#### 
To manage your components, choose Xcode > Settings and click Components in the sidebar. Xcode shows the installed and enabled components along with the amount of storage you can recover if you remove them.

There are three types of components:
To download and install a component in any of these sections, click the Get button next to the component.
To remove or disable components you no longer use and recover their storage space, click the information button next to the component. In the dialog that appears, click Delete or Turn Off depending on the component.
You can also install platform support when you create a project by selecting a template and clicking the Get button that appears for platforms that aren’t installed. For more information, see .

> **note:** You can create a new Xcode project or work with an existing Xcode project on a platform that Xcode is installing, but you can’t run or build the project until Xcode finishes downloading and installing the files.


#### 
You can get previously released Simulator runtimes in the Components settings. Under Other Installed Platforms, click the Add Platforms button. To filter the list in the dialog that appears, choose a platform and enter a term in the filter field in the toolbar. Then, select one or more versions in the list below, and click Download & Install.

#### 
When you open an Xcode project for a platform that doesn’t have any installed Simulator runtimes, Xcode displays a Get button next to the run destination and in the canvas. Click the Get button to download and install the most recent Simulator runtime for that platform.
The run destination in your Xcode project indicates when Xcode is downloading a Simulator runtime. You can select a run destination when Xcode completes the download and installation.

#### 
You can also download components in Terminal using the `xcodebuild` command. For example, use the command line to download Xcode components once and then install them across multiple Mac computers.
To download Simulator runtimes for a specific platform, use this syntax:

```None
xcodebuild -downloadPlatform <iOS|watchOS|tvOS|visionOS>  [-exportPath <destinationpath> -buildVersion <osversion> -architectureVariant <universal|arm64>]
```
For example:

```None
xcodebuild -downloadPlatform iOS -exportPath ~/Downloads
```
To specify an OS version, add the `-buildVersion` option:

```None
xcodebuild -downloadPlatform iOS -exportPath ~/Downloads -buildVersion 18.0 
```
To download all the supported platforms for the version of Xcode you select, use this syntax with the `-downloadAllPlatforms` option:

```None
xcodebuild -downloadAllPlatforms [-exportPath <path>]
```
By default, Xcode downloads a variant based on your Mac computer’s architecture and whether you use Rosetta run destinations. Xcode downloads a universal variant for Intel-based Mac computers and when you use Rosetta run destinations. Otherwise, Xcode downloads an Apple silicon variant to save disk space for the platform you specify.
To download the universal variant that works on both Apple silicon and Intel-based Mac computers, use the `-architectureVariant` option:

```None
xcodebuild -downloadPlatform iOS -architectureVariant universal
```

#### 
After you download component packages, you can install them in Terminal with the `xcodebuild` command.
First, select the version of Xcode you want to use with the `xcode-select -s <path-to-Xcode>` command. Next, run `xcodebuild -runFirstLaunch` to install any required system components, including the `simctl` utility. Then, run `xcodebuild` with the `-importPlatform <simruntime.dmg>` option to install the component.

```None
xcode-select -s /Applications/Xcode-beta.app
xcodebuild -runFirstLaunch
xcodebuild -importPlatform "~/Downloads/watchOS 9 beta Simulator Runtime.dmg"
```

#### 
To download and install hardware support updates in between Xcode releases, use `xcodebuild` with the `-runFirstLaunch` and `-checkForNewerComponents` options. Before running this command, select the version of Xcode you want to use with the `xcode-select -s <path-to-Xcode>` command.

```None
xcode-select -s /Applications/Xcode.app
xcodebuild -runFirstLaunch -checkForNewerComponents
```
If new components exist, the `-checkForNewerComponents` option stores the files in the `~/Library/Developer/Packages/` directory and installs the components for the Xcode version you select.

#### 
To build your Metal apps, download and install the optional Metal Toolchain for the platforms your app targets.
If a sheet appears when you first launch Xcode that lets you select components, select the app’s platforms, select Metal Toolchain under Additional Components, and click Install.
Otherwise, you can manage all your downloads, including the Metal Toolchain, using the Components settings in Xcode. Choose Xcode > Settings, click Components in the sidebar, and then click the Get button next to Metal Toolchain under Other Components on the right.
If you attempt to build an app that requires the Metal Toolchain before downloading the toolchain, a dialog appears. Click Download to download the Metal Toolchain.
Alternatively, to download and install the toolchain from the command line, run this command from Terminal:

```None
xcodebuild -downloadComponent metalToolchain
```
To download and install the toolchain separately, first download and export it to a file:

```None
xcodebuild -downloadComponent metalToolchain -exportPath ~/Downloads
```
Then, install the toolchain into Xcode:

```None
xcodebuild -importComponent metalToolchain ~/Downloads/metalToolchain.dmg
```

## Improving your app’s performance
> https://developer.apple.com/documentation/Xcode/improving-your-app-s-performance

### 
People using your app expect it to perform well. An app that takes a long time to launch, or responds slowly to input, may appear as if it isn’t working or is sluggish. An app that makes a lot of large network requests may increase a person’s data charges and drain the device battery. Similarly, an app that consumes a lot of disk space leaves a person’s device with less space for other content or apps. Any of these behaviors can frustrate people and lead them to uninstall your app.
Plan and implement performance improvements by approaching the problem scientifically:
1. Gather information about the problems your users are experiencing.
2. Measure your app’s behavior to find the causes of the problems.
3. Plan one change to improve the situation.
4. Implement the change.
5. Observe whether the app’s performance improves.
These activities form a cycle of continuous improvement, as the following illustration shows:

Minimizing resource use benefits your users and improves their perceptions of your app. Here are some specific benefits:
- Decreasing app launch time improves the user experience, and reduces the chances of the iOS watchdog timer terminating the app.
- Decreasing overall memory use reduces the likelihood of iOS freeing your app’s memory in the background, and improves responsiveness when a user switches back to your app.
- Reducing disk writes speeds up your app’s overall performance, makes it more responsive, and reduces wear on users’ device storage.
- Decreasing hang rate and hang duration improves your users’ perception of your app’s performance and responsiveness.
- Reducing battery consumption and the use of power-hungry device features makes your app more reliable, and helps ensure that the rest of a person’s device is available when needed.
- Maintaining low disk space usage allows a person to install and use more apps, and to keep more content on their device. For example, store content that your app can regenerate in the  so that the system can purge it when needed. Doing so speeds up app and system upgrades, and reduces the iCloud storage space the system requires to create an iCloud backup of the device. For more information, see .
Even when your measurements and observations show no pressing performance problems, it’s a good idea to run through the performance-improvement cycle and do preventive work to keep your app’s performance from regressing.

#### 
To thoroughly understand your app’s performance, combine information from multiple sources:
- Use the  to view metrics for launch time, user-interface responsiveness, writes to storage, memory use, and energy use, as well as diagnostic reports for disk writes, crashes, and energy. The Organizer lets you break down measurements by device model, app version, and user percentile. For more information, see .
- Use  to gather metrics and record them in your own tools. These metrics are in the form of histograms that record the frequency of observed values over a day. MetricKit goes beyond the metrics in the Metrics organizer to include average pixel luminance, cellular network conditions, and durations associated with custom `OSSignpost` events in your app.
- Get feedback from  testers about their experiences with beta versions of your app. Fill out the Test Information page for your beta version, and request that testers provide feedback about the performance of your app. Include an email address so that testers can report their findings.
- Investigate feedback from your users about their experiences with released versions of your app. Invite users to send their feedback through email or a dedicated interface within your app. Ask them about their experiences using the app — both what works well and any problems they encounter.

#### 
Use the information from your observations and your understanding of your app’s purpose and expected use patterns to spot the greatest opportunities for improvement. Some performance issues are independent of the type of app under investigation. An app that takes a long time to launch, or is unresponsive to users’ attempts to manipulate the interface, results in users feeling they have no control over the app.
The largest value for a metric you see in the Metrics organizer or in MetricKit may not indicate the most important issue to address if that value represents expected app usage. For example, energy use associated with background-audio playing is probably not a problem for a podcast player, which users expect to play in the background. However, it would be surprising to see that metric dominate if your app is a game that has no background component to its gameplay.
Seeing that value dominate the metric reports can indicate that efficiency savings are possible, but the most impactful changes may be in the use of auxiliary services that don’t impact the app’s main features. The podcast player might infrequently need to use coarse-grained location services to recommend local-interest podcasts to the listener, but the high-energy consumption associated with the frequent tracking of the user’s precise location may be a sign that a change is necessary.

#### 
Use  to profile your app with a profiling template that’s relevant to the metric you’re considering:
- Unresponsiveness and hangs: Use the  template.
- Memory issues: Use the  and  templates.
- Power-consumption issues: Use the  template.
- I/O issues: Use the  template.
- Network-related issues: Use the .
You get higher-fidelity measurements by profiling on a device instead of the simulator. If the information you gather shows that your app performs poorly on a particular class or model of device, profile on that device.
Find the code that’s causing the performance problem, and create a plan for improving it. Keep in mind that your change may not be localized to a particular line or even function, and you may need to make significant architectural changes to your app. For example, to mitigate a hang that results from synchronously downloading network resources, introduce background operations to handle the networking (see ), and perform a UI update on the main thread when the downloads are complete.

#### 
Implement the change you plan as a result of your investigation. Create an  profile in Instruments that you can compare with the  profile to ensure your change results in an improvement. Consider writing a performance test in  to protect against future regressions in performance, and to serve as a record that the problem existed and you fixed it.

#### 
After you change your app to address the most important performance issue you observe, confirm that the change has the desired effect and that the level of improvement is sufficient. Use the graphs of performance metrics for each version of your app in Xcode’s Metrics organizer to see whether the change results in an improvement or a regression.
Finally, decide whether the metric you’re working on is still the most important to address, or whether the data points to another metric for the next iteration of the performance improvement cycle.

#### 
The following articles, Xcode Help topics, and WWDC session videos contain more information about using Xcode and Instruments for measuring and improving app performance:

##### 
- 
- 
- 
- 
- 
- 
- 
- 
- 
- 

##### 
- 
- 
- 
- 
- 
- 
- 
- 
- 
- 
- 
-

## Understanding and improving SwiftUI performance
> https://developer.apple.com/documentation/Xcode/understanding-and-improving-swiftui-performance

### 
 implements a declarative approach to constructing a user interface. You describe your app’s UI and how it depends on the app’s data and environment. SwiftUI calculates the views that represent the UI, and updates the UI in response to people’s actions and to changes in the view’s dependencies, such as:
- The view’s state
- The environment
-  model data
Your app needs to compute its view bodies quickly to maintain a responsive experience for people who use the app. View bodies that take too long to run, or views that update too frequently, reduce overall system efficiency as they consume resources that the system could use elsewhere. The system requires views to update before the system renders the next display frame on the screen. If the views don’t complete their updates in time, they cause hitches in your app’s UI, giving someone a poor experience of using your app. For more information, see .
Use Instruments to detect long-running view body calculations and frequent view updates in your app, and to identify the code in your app that causes these issues. Use common SwiftUI patterns to address the problems you discover.

#### 
Follow these steps to trace your app’s SwiftUI use:
1. In Xcode, choose Product > Profile to build and open your app in Instruments.
2. Choose the SwiftUI template.
3. Click Record (red D) to start a deferred recording.
4. Interact with the features of your app you want to test.
5. In Instruments, press Stop Recording.
The Instruments timeline shows a time profile of the code in your app, in parallel with a SwiftUI track.
The SwiftUI track contains lanes which show events related to SwiftUI work that your app causes:
The Hitches timeline reports situations in which your app didn’t prepare a view update in time for the system to render its updated UI to the screen.
When you select the SwiftUI timeline, the detail view shows a summary of all SwiftUI updates in your app. Instruments organizes the updates by module, view name, and category. Use this information to understand how views in your app and in system frameworks spend time updating as you exercise your app’s features.

#### 
Expand the SwiftUI timeline track by clicking the disclosure triangle in the SwiftUI instrument’s timeline. The tracks for View Body Updates, Platform View Updates, and Other Updates show distinct timelines for each module in your app, so that you can identify whether the view that takes a long time to update is part of your app’s code, a third-party SDK, or the system.
Control-click on a long view body update in the timeline and choose Set Inspection Range and Zoom to focus on that update in the timeline and the detail view. Use the Time Profiler instrument to identify what code your app runs during the long update. Click in the Time Profiler track in the timeline to see a call tree of the functions that run during the long update. Switch to the Flame Graph view for an alternative visualization.
A single instance of a long-running update might not contain enough samples in the Time Profiler instrument to help you determine the code in your app that’s running. In this case, repeat the long-running update while you record your app in Instruments, and use multiple examples of the update to identify the code in your app that causes the update to run for a long time. Filter the call tree or flame graph to all instances of the same update by following these steps:
1. Click in the timeline in the Time Profile track, but outside the selected range, to clear the selected range.
2. In the detail view, control-click on `MySwiftUIView.body` and choose Show Calls Made by `MySwiftUIView.body`.
To reset the filter, click Callers/Callees in the Instruments bottom bar, and choose Clear Selection.
A common cause of long view body updates is performing expensive calculations in the view’s   property. Instead, perform the calculation asynchronously, and cache the result to avoid repeating the work every time the view needs to use the result of the calculation.

#### 
Not all performance problems are caused by long updates. Sometimes, an app generates a sequence of updates in which each update is short, but the large number of updates in the sequence causes SwiftUI to do a lot of work and to be active for a long time. Use the Update Groups timeline to identify groups that are active for a long time, but not associated with long updates.
Control-click on an update group and choose Set Inspection Range to focus on that group in the detail group. Use the information in the Summary: All Updates view to identify which views update as part of the group, and the count of updates.

> **note:**  You might need to manually adjust the start of the inspection range to include events that cause the update and occur before the update group starts.

Hold the pointer over an update, and then click the arrow that appears and choose Show Causes. The detail view shows a list of updates in the group, and a graphical representation of the events that caused each update, and the effects that each update caused. Nodes in the graph represent objects that generate or receive updates; for example, view bodies, environment objects, and transactions. Edges in the graph represent causal links between nodes; for example, the connection from an  object to a view that reads one of the object’s properties in its `body`.
Click on a node to see more information about that node in the inspector. Blue nodes represent objects defined by code in your app. Gray nodes represent objects defined by the system.
Click on an edge to see more information about the update the edge represents in the inspector. The inspector displays additional information Instruments captures about the update, for example, changes to your view’s properties.

> **tip:**  To simplify the presentation of the cause graph, Instruments sometimes represents the same nodes and edges in multiple places on the graph. When you click on a node or edge to view more information in the inspector, Instruments highlights all nodes and edges that represent the same object or update.

Compare the events that occur in the cause-and-effect graph with your understanding of the purpose of your views to identify unnecessary updates, or updates that are needed but happen too frequently. Examples of causes for too-frequent updates include:
- Your view observes properties on an object that has other observable properties, and updates when one of the other properties changes. Migrate your observable objects to use the  macro, which tracks the properties that a view reads and only emits change events when those properties update. For more information, see .
- The view that responds to an update causes the views it contains to update in ways that don’t contribute to meaningful changes in the UI; for example, a custom layout using a  that recalculates scroll geometry for the views it contains, including for updates that don’t result in any scroll changes. Identify a different view in your app’s view hierarchy that can receive the update and make only relevant changes to the views it contains.
For views that need to update in response to frequent updates, follow the steps in  above, to improve the efficiency of these updates.
The cause-and-effect graph in Instruments only shows one changing property for each edge. After you make a change to reduce the frequency of view updates, capture a new recording in Instruments to determine whether the update frequency is reduced, or a different property update or event also causes the same views to update.
Identify the type of event that most frequently causes your view to update, and prioritize your performance-engineering work to reduce that event’s frequency first.

#### 
A cause-and-effect graph that starts with a node that represents code in your app (a blue node), generates events that affect framework code (gray nodes), and ends with a node in your app (another blue node), signifies a situation where your app creates an event that your app needs to respond to itself, but that the SwiftUI framework mediates.
Change your code to reduce the frequency of updates that it causes, by reducing the frequency of the causing events. For example, if you use  to update the layout of subviews whenever a view’s size changes, test whether the magnitude of the change is bigger than a threshold value before updating the layout.

#### 
Keep your view bodies fast. The code in a view body needs to be efficient and rely on limited dependencies, including state and environment objects.
Move business logic and other non-UI work out of views to model types because SwiftUI recreates views, and recalculates view bodies, frequently. So, avoid performing complex, long-running tasks in your  initializer and these methods:
- 
- 
- 
- Any other modifiers that can modify view state
Consider the performance impact of complex layouts. Layout readers, for example,  and , observe layout changes in their parent views to recalculate their layouts. Reduce the scope of simultaneous layout and state updates by moving views with state dependencies that don’t affect the layout into a separate view hierarchy.
Avoid storing closures in views. Closures can capture additional state from your parent view that make the view update more often. Whenever any of the closure’s captured state changes, SwiftUI needs to recalculate the closure’s result. If the closure captures `self`, whether explicitly or because it references one of the view’s properties, then SwiftUI recalculates the closure’s result whenever any of the view’s properties changes. When accepting a closure passed to your view’s initializer that builds a child view for your view, call the closure in the initializer so you only store its return value. Don’t mark the closure .
You don’t need to do this for action closures, like the closure you pass to , or closures that require a parameter, like the closure you pass to . However, such closures could still cause excessive updates, so follow the steps in  above, to ensure that your app calls its closures efficiently.

