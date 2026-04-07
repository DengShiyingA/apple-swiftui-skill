# Apple SAFARISERVICES Skill


## Adding a web development tool to Safari Web Inspector
> https://developer.apple.com/documentation/safariservices/adding-a-web-development-tool-to-safari-web-inspector

### 
#### 
Then, in your extension’s `manifest.json` file, do the following:
- Add the `devtools_page` key, and specify your tool’s HTML file.
- Add or update the `permissions` entry to include the `devtools` permission.
- Add the `devtools_page` key, and specify your tool’s HTML file.
- Add or update the `permissions` entry to include the `devtools` permission.
```javascript
{
    ...
    "devtools_page": "example_devtool.html",
    "permissions": "devtools"
    ...
}
```

#### 

## Adjusting settings for a toolbar item
> https://developer.apple.com/documentation/safariservices/adjusting-settings-for-a-toolbar-item

### 
2. Fill out the appropriate fields in the `Info.plist` file.
#### 
Provide an `InfoPlist.strings` file and include localized text for a custom key based on your toolbar identifier. For example, to provide a Polish translation for a toolbar item with an identifier of `translate`, add the following entry to your strings file:
```swift
"Toolbar Button Label for Identifier: translate" = "Przetłumacz";
```

#### 
To update a toolbar item’s image dynamically, Safari uses the   method for `SFSafariToolbarItem`. Setting the image to `nil` sets the default image.
#### 
#### 
#### 
#### 
#### 

## Adjusting settings for contextual menu items
> https://developer.apple.com/documentation/safariservices/adjusting-settings-for-contextual-menu-items

### 
#### 
To localize a contextual menu, provide an `InfoPlist.strings` file and include localized text for a custom key based on your command string. For example, to provide a Polish translation for a menu item with a command string of `Add`, you add the following entry to your strings file:
```swift
"Context Menu Item Label for Command: Add" = "Dodaj";

```

#### 
#### 
To pass information from the current webpage to your app extension when the user chooses your menu item, you need to inject a JavaScript file; see . When the user Control-clicks a webpage, Safari sends out a `contextmenu` event. Your script can add a listener for this event, and react to it by inserting information into the user info dictionary. If the user later selects one of your contextual menu items, Safari sends this dictionary when it calls your app extension.
For example, to capture the currently selected text in a webpage, use the following code:
```javascript
document.addEventListener("contextmenu", handleContextMenu, false);
function handleContextMenu(event) {
    var selectedText =  window.getSelection().toString();
    safari.extension.setContextMenuEventUserInfo(event,
        { "selectedText": selectedText });
}
```

#### 

## Blocking content with your Safari web extension
> https://developer.apple.com/documentation/safariservices/blocking-content-with-your-safari-web-extension

### 
#### 
To use the Declarative Net Request API in your Safari web extension, first request permission. In your Xcode project, add the declarative net request permission to the permissions list in your `manifest.js` file.
```javascript
{
 ...
   "permissions": [
    "declarativeNetRequest",
    "activeTab"
  ],
  ...
}
```

#### 
You specify rules for content blocking in rulesets, which are files with `json` describing the content blocking rules. Add references to ruleset files that you create in your `manifest.js` file to tell Safari to use them. For example:
```javascript
{
   ...
   "declarative_net_request" : {
    "rule_resources" : [{
      "id": "ruleset_for_images",
      "enabled": true,
      "path": "image_rules.json"
    }, {
      "id": "ruleset_for_scripts",
      "enabled": false,
      "path": "script_rules.json"
    }]
  },
  ...
}
```

```
Build your rules describing how you want to block content, and add them to your ruleset files. For example:
```javascript
{
    "id": 1,
    "priority": 1,
    "action": { "type": "block" },
    "condition": {
        "regexFilter": ".*",
        "resourceTypes": [ "script" ]
    }
}

```

#### 
After a user installs and uses your extension, adjust content blocking using dynamic rules. Add, change, or remove rules that persist between browser sessions using `updateDynamicRules`. Add, change, or remove rules that apply only to the current session using `updateSessionRules`.
```swift
var rule = {
    id: 1,
    priority: 1,
    action: { type: "block" },
    condition: {
        urlFilter: "||example.com",
        resourceTypes: [ "main_frame", "script" ]
    }
};

await browser.declarativeNetRequest.updateDynamicRules({ addRules: [ rule ] });

```


## Creating a content blocker
> https://developer.apple.com/documentation/safariservices/creating-a-content-blocker

### 
#### 
#### 
In your Xcode project, open the folder with the same title as your content blocker. This folder contains the action request handler and a JSON file, along with a property list file and an entitlements file. Open the `blockerList.json` file.
In the JSON file, write rules to define content-blocking behaviors. Each rule is a JSON object containing action and trigger dictionaries. The action tells Safari what to do when it encounters a match for the trigger. The trigger tells Safari when to perform the corresponding action. Content blockers are JSON arrays of these rules.
```javascript
[
    {
        "trigger": {
            ...
        },
        "action": {
            ...
        }
    },
    {
        "trigger": {
            ...
        },
        "action": {
            ...
        }
    }
]
```

#### 
A trigger dictionary must include a `url-filter` key, which specifies a pattern to match the URL against. The remaining keys are optional and modify the behavior of the trigger. For example, you can limit the trigger to specific domains or have it not apply when Safari finds a match for a specific domain.
For example, to write a trigger for image and style sheet resources that Safari finds on any domain except those specified, add the following to the JSON file:
```swift
"trigger": {
        "url-filter": ".*",
        "resource-type": ["image", "style-sheet"],
        "unless-domain": ["your-content-server.com", "trusted-content-server.com"]
}
```

In `url-filter`, match more than just a specific URL, using regular expressions.
| `.*` | Matches all strings with a dot appearing zero or more times. Use this syntax to match every URL. |
| `.` | Matches any character. |
| `\.` | Explicitly matches the dot character. |
| `[a-b]` | Matches a range of alphabetic characters. |
| `(abc)` | Matches groups of the specified characters. |
| `+` | Matches the preceding term one or more times. |
| `*` | Matches the preceding character zero or more times. |
| `?` | Matches the preceding character zero or one time. |
| `url-filter-is-case-sensitive` | A Boolean value. The default value is `false`. |
| `load-context` | An array of strings that specify loading contexts. Valid values are `top-frame` and `child-frame`. |
#### 
There are only two valid fields for actions: `type` and `selector`. An action type is required. If the type is `css-display-none`, a `selector` is required as well; otherwise, the `selector` is optional.
For example, you can specify the following type and selector:
```swift
"action": {
        "type": "css-display-none",
        "selector": "#newsletter, :matches(.main-page, .article) .news-overlay"
}
```

| `block` | Stops loading of the resource. If Safari caches the resource, it ignores the cache. |
| `ignore-previous-rules` | Ignores previously triggered actions. |
| `make-https` | Changes a URL from `http` to `https`. This doesn’t affect URLs with a specified (nondefault) port and links using other protocols. |

## Importing data exported from Safari
> https://developer.apple.com/documentation/safariservices/importing-data-exported-from-safari

### 
#### 
Safari exports bookmarks in an HTML file using the . The Reading List is a sub-folder with the identifier `com.apple.ReadingList`.
#### 
#### 
#### 
The top-level object in the history JSON file contains a `history` key, which has a value that is an array of objects representing websites that Safari visited. Each object in the array contains these keys:
When the web server redirects Safari to a different URL, the history list contains all of the URLs in the chain of redirections. Link items in the redirection chain by comparing the `url` and `time_usec` fields in one history item with the `destination_url` and `destination_time_usec` of the item that redirected Safari to it, and the `source_url` and `source_time_usec` of the item that it redirected Safari to, for example:
```javascript
...
{
   "url" : "https://maps.apple.com/",
   "time_usec" : 1722367302951213,
   "destination_url" : "https://www.apple.com/maps/",
   "destination_time_usec" : 1722367302951310
},
{
   "url" : "https://www.apple.com/maps/",
   "time_usec" : 1722367302951310,
   "title" : "Maps - Apple",
   "source_url" : "https://maps.apple.com/",
   "source_time_usec" : 1722367302951213
},
...
```

#### 
The top-level object in the payment cards JSON file contains a `payment_cards` key, which has a value that is an array of objects representing the payment cards the person stored in Safari. Each object in the array contains these keys:
The object looks like this example:
```javascript
{
  "card_number" : "0000000000000000",
  "card_name" : "My Bank Card",
  "cardholder_name" : "Mei Chen",
  "card_expiration_month" : 11,
  "card_expiration_year" : 2027,
  "card_last_used_time_usec" : 1722730594744987
}
```

#### 
The `marketplace_lookup` object contains these keys:

## Injecting a script into a webpage
> https://developer.apple.com/documentation/safariservices/injecting-a-script-into-a-webpage

### 
#### 
#### 
To access the resources in your app extension’s bundle from within your scripts, create a URL at runtime that references the resource relative to the root of the app extension’s bundle. The `safari.extension.baseURI` property specifies the location of the bundle’s resource directory.
The code example below demonstrates how to use this property. This code adds a new image element to the webpage. The system stores the image inside the Resources folder and references it at runtime.
```javascript
var newElement = document.createElement("img");
newElement.src = safari.extension.baseURI + "myDog.jpeg";
```

#### 
The injected scripts execute before the webpage fully loads, so you can take action as the system adds resources to the webpage. During that time, `document.body` is `null`. To take action after the document loads, listen for the `DOMContentLoaded` event. The code example below registers a document event handler to call after the content loads:
```javascript
document.addEventListener("DOMContentLoaded", function(event) {
    safari.extension.dispatchMessage("Hello World!");
});
```

#### 
The example code below injects a new element into the webpage after the webpage loads. This example uses a resource stored in the bundle and shows how to register the document event handler:
```swift
// Create an image and insert it at the top of the body.
document.addEventListener("DOMContentLoaded", function(event) {
    var newElement = document.createElement("img");
    newElement.src = safari.extension.baseURI + "myCat.jpg";
    document.body.insertBefore(newElement,
    document.body.firstChild);
});
```


## Messaging between a webpage and your Safari web extension
> https://developer.apple.com/documentation/safariservices/messaging-between-a-webpage-and-your-safari-web-extension

### 
#### 
To enable messaging from webpages, add `externally_connectable` to your extension’s `manifest.json` file. Include a list of webpages that you want to send messages to your extension in the `matches` attribute.
```javascript
{ 
    "externally_connectable": {
        "matches": [ "*://*.apple.com/*" ]
    }
}
```

If you don’t provide the `matches` attribute or you provide an empty list, no webpages can send messages to your extension.
#### 
Send a message from a webpage to your extension using `browser.runtime.sendMessage`. Provide your extension’s identifier, the message data, and a closure to handle the response from your extension.
```javascript
browser.runtime.sendMessage("com.example.connectable-ext.Extension (team_identifier)", {greeting: "Hello!"}, function(response) {
    console.log("Received response from the background page:");
    console.log(response.farewell);
});
```

Your extension’s identifier is a string that consists of the bundle identifier for your extension, and your team identifier in parentheses. Find your team identifier in your  in the Membership tab under Account Settings. Note that extension identifiers can be different across browsers. For more information about finding the right extension identifier for Safari, see .
In your extension’s background page, listen for incoming messages webpages and send responses.
```javascript
browser.runtime.onMessageExternal.addListener(function(message, sender, sendResponse) {
    console.log("Received message from the sender:");
    console.log(message.greeting);
    sendResponse({farewell: "Goodbye from the background page!"});
});
```

#### 
If your extension needs to handle more continuous data from a webpage, establish a port connection between the webpage and your extension.
```javascript
let port = browser.runtime.connect("extensionID");
```

```
In your extension’s background page, listen for incoming port connection requests.
```javascript
browser.runtime.onConnectExternal.addListener(function(port) {
    console.log("Connection request received!");
});
```

Then, use `port.postMessage` to send a message through the port, and `port.onMessage` to receive a message from the port.

## Messaging between the app and JavaScript in a Safari web extension
> https://developer.apple.com/documentation/safariservices/messaging-between-the-app-and-javascript-in-a-safari-web-extension

### 
#### 
From a script running in the browser or Mac web app, use `browser.runtime.sendNativeMessage` to send a message to the native app extension:
To enable sending messages from JavaScript to the native app extension, add `nativeMessaging` to the list of `permissions` in the `manifest.json` file.
From a script running in the browser or Mac web app, use `browser.runtime.sendNativeMessage` to send a message to the native app extension:
```javascript
browser.runtime.sendNativeMessage("application.id", {message: "Hello from background page"}, function(response) {
    console.log("Received sendNativeMessage response:");
    console.log(response);
});
```

```
Safari ignores the `application.id` parameter and only sends the message to the containing app’s native app extension. To receive the message, implement the `beginRequest:with:` function in the native app extension to handle the message:
```swift
func beginRequest(with context: NSExtensionContext) {
        guard let item = context.inputItems.first as? NSExtensionItem,
              let userInfo = item.userInfo as? [String: Any],
              let message = userInfo[SFExtensionMessageKey] else {
            context.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        if let profileIdentifier = userInfo[SFExtensionProfileKey] as? UUID {
            // Perform profile specific tasks.
        } else {
            // Perform normal browsing tasks.
        }

        let response = NSExtensionItem()
        response.userInfo = [ SFExtensionMessageKey: [ "Response to": message ] ]
            
        context.completeRequest(returningItems: [response], completionHandler: nil)
}
```

#### 
To enable sending messages from the Safari web extension’s containing macOS app to its JavaScript scripts running in the browser or Mac web app, add `nativeMessaging` to the list of `permissions` in the `manifest.json` file. Send messages from the macOS app to notify the web scripts of important events, like when the user clicks a button or when data that the JavaScript script uses changes. You can’t send messages from a containing iOS app to your web extension’s JavaScript scripts.
To prepare the JavaScript script to receive messages from the macOS app, use `browser.runtime.connectNative` to establish a port connection to the containing app:
```javascript
let port = browser.runtime.connectNative("application.id");
```

Safari ignores the `application.id` parameter and only allows the script to establish a port connection with the containing macOS app.
Safari ignores the `application.id` parameter and only allows the script to establish a port connection with the containing macOS app.
Send a message to the JavaScript script from the macOS app using `dispatchMessageWithName:toExtensionWithIdentifier:userInfo` in `SFSafariApplication`:
```swift
@IBAction func sendMessageToExtension(_ sender: AnyObject?) {
    let messageName = "Hello from App"
    let messageInfo = ["AdditionalInformation":"Goes Here"]
    SFSafariApplication.dispatchMessage(withName: messageName, toExtensionWithIdentifier: extensionBundleIdentifier, userInfo: messageInfo) { error in
        debugPrint("Message attempted. Error info: \(String.init(describing: error))")
    }
}
```

To receive the message in the JavaScript script, add a closure using `port.onMessage.addListener` to process the message.
```
To receive the message in the JavaScript script, add a closure using `port.onMessage.addListener` to process the message.
```javascript
port.onMessage.addListener(function(message) {
    console.log("Received native port message:");
    console.log(message);
});
```


## Optimizing your web extension for Safari
> https://developer.apple.com/documentation/safariservices/optimizing-your-web-extension-for-safari

### 
#### 
#### 
To enable basic support for Dark Mode in your extension’s visual elements, add the following code to your CSS files:
```other
:root {
    color-scheme: light dark;
}
```

#### 
Make your background page nonpersistent by setting the `persistent` attribute to `false` in your extension’s `manifest.json` file.
Consider making your background page nonpersistent in macOS when it’s primarily event-driven and responds to user interactions. In iOS, you must make your background page nonpersistent. Safari unloads your nonpersistent background page when the user isn’t directly interacting with the extension, which reduces memory usage and improves battery life. Your background page must be nonpersistent or you must declare your background script as a service worker if you’re using manifest version 3. Use a service worker for better compatibility with other browsers.
Make your background page nonpersistent by setting the `persistent` attribute to `false` in your extension’s `manifest.json` file.
```javascript
"background": {
    "scripts": ["background.js"],
    "persistent": false
}
```

```
Or, declare your background script as a service worker.
```javascript
"background": {
    "service_worker": "background.js"
}
```

- Use the `Storage` API to save and restore state.
- Use the `Alarms` API instead of `setTimeout`.
#### 
When you build features in your web extension that need a specific version of Safari, specify the required versions in your `manifest.json` file.
When you build features in your web extension that need a specific version of Safari, specify the required versions in your `manifest.json` file.
```javascript
"browser_specific_settings": {
    "safari": {
        "strict_min_version": "14.0",
        "strict_max_version": "14.*"
    }
}
```


## Packaging a web extension for Safari
> https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari

### 
#### 
To run the packager, open the Terminal app and run the `xcrun` command with the `safari-web-extension-packager` option, providing the path for your existing extension files.
```other
xcrun safari-web-extension-packager /path/to/extension
```

> **note:** This tool used to be named `safari-web-extension-converter`.
#### 
The packager generates and opens your new Xcode project. The packager reports any manifest keys that the current version of Safari doesn’t support.
```other
Warning: The following keys in your manifest.json are not supported by your 
current version of Safari. If these are critical to your extension, you 
should review your code to see if you need to make changes to support Safari:
downloads
offline_enabled

```

#### 
#### 
If you have an existing Xcode project with a macOS Safari web extension, and you want to add support for iOS to it, use the packager with the `--rebuild-project` option.
```other
xcrun safari-web-extension-packager --rebuild-project /path/to/myExtension/myExtension.xcodeproj
```


## Passing messages between Safari app extensions and injected scripts
> https://developer.apple.com/documentation/safariservices/passing-messages-between-safari-app-extensions-and-injected-scripts

### 
| `extension` | A proxy for the app extension. Use it to retrieve information about your app extension and to pass messages to it. |
| `self` | A proxy for your injected script. Use it to install event listeners to respond to messages from your app extension. |
#### 
Call `safari.extension.dispatchMessage.`
Call `safari.extension.dispatchMessage.`
```javascript
safari.extension.dispatchMessage("Hello World");

```

The parameter for  is a string that identifies the message you want to send. You create your own message names and decide what those messages mean for your app extension.
You can optionally send additional user data to accompany the message.
```javascript
safari.extension.dispatchMessage("InterestingMessage",  { "key": "value" });
```

The user data must be a JavaScript object made up of keys and values that conform to the W3C standard for safe passing of structured data, such as Boolean objects, numeric values, strings, arrays, and so on.
For example, the following code sends an array in a message:
```javascript
var myArray = ["a", "b", "c"];
safari.extension.dispatchMessage("passArray", { "key": myArray });
```

When the app extension receives the message, the system calls the extension handler’s  method. This method’s parameters include the message name, the page that sends the message, and, if part of the message, a user dictionary:
In Safari 17 and later, check whether the user is browsing with a profile if you need to limit any extension logic to the profile, such as fetching or storing data. To do that, implement the  method.
```swift
- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
    NSExtensionItem *item = context.inputItems.firstObject;
    NSDictionary *userInfo = item.userInfo;
    NSUUID *profileIdentifier = userInfo[SFExtensionProfileKey];
    
    if (profileIdentifier != nil) {
        // Remember profile identifier for future method calls.
    } else {
        // Handle normal browsing. 
    }
}
```

#### 
When the app extension needs to send a message to an injected script, it calls the  method on the target page.
The message is a packaged event with a type of `message`. To respond to the message, the injected script registers an event listener for message events using `safari.self.addEventListener.`
```swift
safari.self.addEventListener("message", handleMessage);

```

```
The event that passes into the event handler is a `SafariExtensionMessageEvent` object. Its `name` property identifies the message, and its `message` property contains the dictionary of user data.
```javascript
function handleMessage(event) {
    console.log(event.name);
    console.log(event.message);
}
```


## Troubleshooting your Safari app extension
> https://developer.apple.com/documentation/safariservices/troubleshooting-your-safari-app-extension

### 
 Check that the deployment target for your app is set to the system you are testing on.
 In the Terminal app, type the following command:
```swift
pluginkit -mAvvv -p com.apple.Safari.extension
```

```
 In the JavaScript environment, use the console.log command to print messages to the Safari debugging console:
```swift
console.log("injection script on " + document.location.href);
```


## Troubleshooting your Safari web extension
> https://developer.apple.com/documentation/safariservices/troubleshooting-your-safari-web-extension

### 
#### 
Check that the deployment targets for your app and extension are the same, and are earlier than or the same as the version of the system you’re testing on. If not, lower the deployment targets or update your system, if possible. Note that your project may encounter errors if you set the deployment target below the minimum level required to support features in your extension.
After you complete these steps for macOS, verify that Safari sees your extension. In the Terminal app, type the following command to see a list of installed extensions:
```other
pluginkit -mAvvv -p com.apple.Safari.web-extension
```

#### 
#### 
#### 
#### 

## Updating a Safari web extension
> https://developer.apple.com/documentation/safariservices/updating-a-safari-web-extension

### 
#### 
#### 
#### 
For more information, see .
If your alternative source editor supports custom build commands, configure it to use `xcodebuild` from the command line to build your extension’s macOS app container.
```other
xcodebuild -scheme HelloWorld\ \(macOS\) build
```

Run the `xcodebuild` command from the top directory of your Xcode project, and replace the `-scheme` parameter with the name of your Xcode project.
#### 

## Using Safari app extension default keys
> https://developer.apple.com/documentation/safariservices/using-safari-app-extension-default-keys

### 
#### 
The code example below represents the overall structure of a typical `NSExtension` dictionary. Keep this structure in mind as you configure each element of your app extension.
```other
<dict>
	<key>NSExtensionPointIdentifier</key>
	<string>com.apple.Safari.extension</string>
	<key>NSExtensionPrincipalClass</key>
	<string>SafariExtensionHandler</string>
	<key>SFSafariToolbarItem</key>
	<dict>
		<key>Action</key>
		<string>Command</string>
		<key>Identifier</key>
		<string>Button</string>
		<key>Image</key>
		<string>ToolbarItemIcon.pdf</string>
		<key>Label</key>
		<string>Your Button</string>
	</dict>
	<key>SFSafariContextMenu</key>
	<array>
		<dict>
			<key>Text</key>
			<string>Search for selected text in MyApplication.</string>
			<key>Command</key>
			<string>Search</string>
		</dict>
		<dict>
			<key>Text</key>
			<string>Add an entry for selected text in MyApplication.</string>
			<key>Command</key>
			<string>Add</string>
		</dict>
	</array>
	<key>SFSafariContentScript</key>
	<array>
		<dict>
			<key>Script</key>
			<string>script.js</string>
		</dict>
	</array>
	<key>SFSafariStyleSheet</key>
	<array>
		<dict>
			<key>Style Sheet</key>
			<string>style.css</string>
		</dict>
	</array>
	<key>SFSafariWebsiteAccess</key>
	<dict>
		<key>Allowed Domains</key>
		<array>
			<string>*.webkit.org</string>
		</array>
		<key>Level</key>
		<string>Some</string>
	</dict>
</dict>
```


## Using contextual menu and toolbar item keys
> https://developer.apple.com/documentation/safariservices/using-contextual-menu-and-toolbar-item-keys

### 
#### 
The `SFSafariContextMenu` key lets your app extension add items to the context menu that appears in webpages. See  for design guidelines.
| `Text` | String | Required. A string that specifies the text to display for the context menu item. |
For example, if you add two contextual menu items, your `Info.plist` file might look like the following:
| `Command` | String | Required. A string that the context menu item sends when it activates. It contains the name of the command you want to send to your app extension when the user selects your item. |
For example, if you add two contextual menu items, your `Info.plist` file might look like the following:
```other
<key>SFSafariContextMenu</key>
<array>
	<dict>
		<key>Text</key>
		<string>Search for selected text in MyApplication.</string>
		<key>Command</key>
		<string>Search</string>
	</dict>
	<dict>
		<key>Text</key>
		<string>Add an entry for selected text in MyApplication.</string>
		<key>Command</key>
		<string>Add</string>
	</dict>
</array>
```

#### 
The `SFSafariToolbarItem` dictionary adds a toolbar item to Safari windows. See  for design guidelines.
| `Identifier` | String | Required. A string identifier for the toolbar item. This doesn’t display to the user. |
| `Label` | String | Required. A string that appears in the overflow menu, in the Customize palette, and on hover. |
| `Action` | String | Required. A string specifying the command to send when the user clicks the toolbar item. Available actions are `Command` (to send a command to the app extension) and `Popover` (to display a popover window). This action determines which methods you need to implement to handle button events. |
Here’s an example dictionary in XML:
```other
<dict>
	<key>Action</key>
	<string>Command</string>
	<key>Identifier</key>
	<string>Button</string>
	<key>Image</key>
	<string>Toolbar.pdf</string>
	<key>Label</key>
	<string>My Item</string>
</dict>
```


## Using injected style sheets and scripts
> https://developer.apple.com/documentation/safariservices/using-injected-style-sheets-and-scripts

### 
#### 
3. The webpage author’s styles that are declared as `!important`
4. Your Safari app extension styles that are declared as `!important`
At each stage, a new definition overrides any previous definition. The system adds style properties in your injected style sheets to existing page style properties, but your styles don’t override existing page styles unless you declare the new ones as `!important`.
For example, adding the following styles overrides a website using color text on a color background, and sets it to black text on a white background for a particular element:
```other
span.anElement {
    color:black;
    background:white;
}
```

#### 
You can inject `.js` files (text files that contain JavaScript functions and commands) into a webpage. The scripts in these files have access to the DOM of the webpages you inject them into. They have the same access privileges as scripts that execute from a webpage’s host. Injected scripts load each time a webpage loads, so keep them lightweight.
The system injects scripts into the top-level page and any subpages with HTML sources, such as iframes. Don’t assume that there’s only one instance of your script per browser tab. If you don’t want your injected script to execute inside iframes, preface your high-level functions with a test, as the following example shows:
```javascript
if (window.top === window) {
    // The containing frame is the top-level frame, not an iframe.
    // All non-iframe code goes before the closing brace.
}
```


