# Apple XCODE Skill


## Accessing app group containers in your existing macOS app
> https://developer.apple.com/documentation/xcode/accessing-app-group-containers

### 
### 
#### 
If your app declares that it belongs to an app group that begins with `group.`, you need to include the group in your app’s provisioning profile.
Include all the restricted entitlements, including the app group entitlement, in the provisioning profile of the process; the values of these entitlements must match and account for any wildcards in the provisioning profile entitlements.
Provisioning profiles for macOS apps that you previously created might not include authorization for the app group entitlement. You can check whether macOS set the entitlements validated flag on your process at runtime by running the command `sudo launchctl procinfo <pid>` in Terminal:
```None
% sudo launchctl procinfo `pgrep <your app's executable file name>`
…
code signing info = valid
    …
    entitlements validated
…
```

#### 
- `<Developer team identifier>.<group name>` is not supported on iOS, iPadOS, tvOS, visionOS, or watchOS.
- Keychain Access Groups doesn’t support the `<Developer team identifier>.<group name>` prefixed identifier. For more information, see 
### 

## Adding a build configuration file to your project
> https://developer.apple.com/documentation/xcode/adding-a-build-configuration-file-to-your-project

### 
#### 
#### 
#### 
To specify a new value for a setting, add that setting to your configuration file using the following format:
```None
<SettingName> = <SettingValue>
```

| `Boolean` | A value of `YES` or `NO`. |
| `string` | A text string. |
| `enumeration (string)` | A predefined text string. See the settings reference for a list of valid values. |
| `string list` | A space-separated list of `string` values. If a string within the list contains spaces, surround that string with quotes. |
| `path` | A file or directory path, in POSIX form. |
| `path list` | A space-separated list of `path` values. If a path within the list contains spaces, surround the path with quotes. |
| `path list` | A space-separated list of `path` values. If a path within the list contains spaces, surround the path with quotes. |
Some examples of settings include:
```None
ONLY_ACTIVE_ARCH = YES
MACOSX_DEPLOYMENT_TARGET = 11.0
OTHER_LDFLAGS = -lncurses
```

#### 
In some cases, you might want to extend a setting rather than overwrite its current value. For example, you might want to add more flags to a compiler instead of replacing the existing flags. To extend a setting’s existing value, add the `$(inherited)` keyword to the value of your setting, as shown in the following example:
```None
OTHER_SWIFT_FLAGS = $(inherited) -v
```

#### 
To reuse an existing build setting’s value, place the name of the setting in a string of the form `$(SettingName)`. When evaluating your build settings, Xcode replaces these references with the values of the corresponding settings. For example, the following definition assigns the value of the `SYMROOT` build setting to the `OBJROOT` setting:
```None
OBJROOT = $(SYMROOT)
```

```
When replacing references, Xcode inserts the setting’s value at the same location as the original reference. You can insert references in the middle of a new value, or you can define a setting using multiple other values, as shown in the following examples:
```None
DSTROOT = /tmp/$(PROJECT_NAME).dst
CONFIGURATION_BUILD_DIR = $(BUILD_DIR)/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)
```

#### 
Add a conditional expression after a build setting to apply that setting only when a specific platform or architecture is active. To specify a conditional expression, enclose it in square brackets after the build setting name, as shown in the following example:
```None
OTHER_LDFLAGS[arch=x86_64] = -lncurses
```

| `arch` | A CPU architecture, such as `arm64` or `x86_64`. |
| `config` | The build configuration, such as `Debug` or `Release`. |
| `config` | The build configuration, such as `Debug` or `Release`. |
To add multiple conditions to the same build setting, place each condition in separate brackets after that setting’s name, as shown in the following example:
```None
OTHER_LDFLAGS[sdk=macos*][arch=x86_64] = -lncurses
```

#### 
When you specify the build configuration file for your target, you must select only one file, but that file can include settings from other configuration files. To import the settings from a different configuration file, add an `#include` statement:
```None
#include "MyOtherConfigFile.xcconfig"
```

```
If Xcode can’t find an included build configuration file, it generates build warnings. To suppress these warnings, add a question mark (?) to the `#include` command, as shown in the following example:
```None
#include? "MyOtherConfigFile.xcconfig"
```

```
Xcode looks for included build configuration files in the same directory as the current file. If your build configuration file is in a different directory, specify a relative path or an absolute path, as shown in the following examples:
```None
#include "../MyOtherConfigFile.xcconfig"    // In the parent directory.
#include "/Users/MyUserName/Desktop/MyOtherConfigFile.xcconfig" // At the specific path.
```

#### 
Add comments to your build configuration files to include notes or other information that’s relevant to you. Specify your comments on a single line preceded by two forward slashes (`//`). The build system ignores everything from the comment delimiter to the end of the current line. For example:
```None
//
//  Base Settings.xcconfig
//  Base Settings
//
//  Created by Johnny Appleseed on 7/21/21.
//
```

```
You can also place a comment at the end of a line that contains a build setting definition, as in the following example:
```None
ASSETCATALOG_COMPILER_APPICON_NAME = MyAppIcon // This is a comment. 
```


## Adding identifiable symbol names to a crash report
> https://developer.apple.com/documentation/xcode/adding-identifiable-symbol-names-to-a-crash-report

### 
#### 
A fully symbolicated crash report has function names on every frame of the backtrace, instead of hexadecimal memory addresses. Each frame represents a single function call that’s currently running on a specific thread, and provides a view of the functions from your app and the operating system frameworks that were executing at the time your app crashed. Fully symbolicated crash reports give you the most insight about the crash. Once you have a fully symbolicated crash report, consult  for details about determing the source of the crash.
An example of a fully symbolicated crash report:
```other
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   libswiftCore.dylib                0x00000001bd38da70 specialized _fatalErrorMessage+ 2378352 (_:_:file:line:flags:) + 384
1   libswiftCore.dylib                0x00000001bd38da70 specialized _fatalErrorMessage+ 2378352 (_:_:file:line:flags:) + 384
2   libswiftCore.dylib                0x00000001bd15958c _ArrayBuffer._checkInoutAndNativeTypeCheckedBounds+ 66956 (_:wasNativeTypeChecked:) + 200
3   libswiftCore.dylib                0x00000001bd15c814 Array.subscript.getter + 88
4   TouchCanvas                       0x00000001022cbfa8 Line.updateRectForExistingPoint(_:) (in TouchCanvas) + 656
5   TouchCanvas                       0x00000001022c90b0 Line.updateWithTouch(_:) (in TouchCanvas) + 464
6   TouchCanvas                       0x00000001022e7374 CanvasView.updateEstimatedPropertiesForTouches(_:) (in TouchCanvas) + 708
7   TouchCanvas                       0x00000001022df754 ViewController.touchesEstimatedPropertiesUpdated(_:) (in TouchCanvas) + 304
8   TouchCanvas                       0x00000001022df7e8 @objc ViewController.touchesEstimatedPropertiesUpdated(_:) (in TouchCanvas) + 120
9   UIKitCore                         0x00000001b3da6230 forwardMethod1 + 136
10  UIKitCore                         0x00000001b3da6230 forwardMethod1 + 136
11  UIKitCore                         0x00000001b3e01e24 -[_UIEstimatedTouchRecord dispatchUpdateWithPressure:stillEstimated:] + 340
```

A partially symbolicated crash report has function names for some of the backtrace frames, and hexadecimal addresses for other frames of the backtrace. A partially symbolicated crash report may contain enough information to understand the crash, depending upon the type of crash and which frames in the backtraces are symbolicated. However, you should still  to make the report fully symbolicated, which will give you a complete understanding of the crash.
An example of a partially symbolicated crash report:
```other
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   libswiftCore.dylib                0x00000001bd38da70 specialized _fatalErrorMessage+ 2378352 (_:_:file:line:flags:) + 384
1   libswiftCore.dylib                0x00000001bd38da70 specialized _fatalErrorMessage+ 2378352 (_:_:file:line:flags:) + 384
2   libswiftCore.dylib                0x00000001bd15958c _ArrayBuffer._checkInoutAndNativeTypeCheckedBounds+ 66956 (_:wasNativeTypeChecked:) + 200
3   libswiftCore.dylib                0x00000001bd15c814 Array.subscript.getter + 88
4   TouchCanvas                       0x00000001022cbfa8 0x1022c0000 + 49064
5   TouchCanvas                       0x00000001022c90b0 0x1022c0000 + 37040
6   TouchCanvas                       0x00000001022e7374 0x1022c0000 + 160628
7   TouchCanvas                       0x00000001022df754 0x1022c0000 + 128852
8   TouchCanvas                       0x00000001022df7e8 0x1022c0000 + 129000
9   UIKitCore                         0x00000001b3da6230 forwardMethod1 + 136
10  UIKitCore                         0x00000001b3da6230 forwardMethod1 + 136
11  UIKitCore                         0x00000001b3e01e24 -[_UIEstimatedTouchRecord dispatchUpdateWithPressure:stillEstimated:] + 340
```

Unsymbolicated crash reports contain hexadecimal addresses of executable code within the loaded binary images. These reports don’t contain any function names in the backtraces. Because an unsymbolicated crash report is rarely useful, .
An example of an unsymbolicated symbolicated crash report:
```other
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   libswiftCore.dylib                0x00000001bd38da70 0x1bd149000 + 2378352
1   libswiftCore.dylib                0x00000001bd38da70 0x1bd149000 + 2378352
2   libswiftCore.dylib                0x00000001bd15958c 0x1bd149000 + 66956
3   libswiftCore.dylib                0x00000001bd15c814 0x1bd149000 + 79892
4   TouchCanvas                       0x00000001022cbfa8 0x1022c0000 + 49064
5   TouchCanvas                       0x00000001022c90b0 0x1022c0000 + 37040
6   TouchCanvas                       0x00000001022e7374 0x1022c0000 + 160628
7   TouchCanvas                       0x00000001022df754 0x1022c0000 + 128852
8   TouchCanvas                       0x00000001022df7e8 0x1022c0000 + 129000
9   UIKitCore                         0x00000001b3da6230 0x1b3348000 + 10871344
10  UIKitCore                         0x00000001b3da6230 0x1b3348000 + 10871344
11  UIKitCore                         0x00000001b3e01e24 0x1b3348000 + 11247140
```

#### 
#### 
#### 
To determine whether the `dSYM` file you need to symbolicate a hexadecimal addresses for one of your binaries is present on your Mac:
1. Find a frame in the backtrace that isn’t symbolicated. Note the name of the binary image in the second column.
2. Look for a binary image with that name in the list of binary images at the bottom of the crash report. This list contains the build UUID of each binary image that was loaded into the process at the time of the crash. Use the `grep` command line tool to find the entry in the list of binary images:
```other
% grep --after-context=1000 "Binary Images:" <Path to Crash Report> | grep <Binary Name>
```

2. Search for the build UUID using the `mdfind` command line tool query (including quotation marks):
1. Convert the build UUID of the binary image to a 32-character string, that’s separated into groups of 8-4-4-4-12 (`XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`). All letters must be uppercase.
2. Search for the build UUID using the `mdfind` command line tool query (including quotation marks):
```other
% mdfind "com_apple_xcode_dsym_uuids == <UUID>"
```

If Spotlight finds a `dSYM` file for the build UUID, `mdfind` prints the path to the `dSYM` file.
Using the information in this example, the commands to find the `dSYM` are:
Using the information in this example, the commands to find the `dSYM` are:
```other
% grep --after-context=1000 "Binary Images:" <Path to Crash Report> | grep TouchCanvas
0x1022c0000 - 0x1022effff TouchCanvas arm64  <9cc89c5e55163f4ab40c5821e99f05c6>

% mdfind "com_apple_xcode_dsym_uuids == 9CC89C5E-5516-3F4A-B40C-5821E99F05C6"
```

If Spotlight doesn’t find a matching `dSYM`, `mdfind` won’t print anything and you’ll need to:
#### 
If you have a binary or a `dSYM` that you think can be used to symbolicate a crash report, verify that the build UUIDs match, using the `dwarfdump` command. If the build UUIDs don’t match each other or don’t match the build UUID listed in the Binary Images section of the crash report, you can’t use the files to symbolicate that crash report.
```other
% dwarfdump --uuid <PathToDSYMFile>/Contents/Resources/DWARF/<BinaryName>
% dwarfdump --uuid <PathToBinary>
```

#### 
4. Symbolicate the addresses in the backtrace using `atos` with the formula, substituting the information you gathered in previous steps:
3. Locate the `dSYM` file for the binary. If you don’t know where the `dSYM` file is located, see  to find the `dSYM` file that matches the build UUID of the binary image.
4. Symbolicate the addresses in the backtrace using `atos` with the formula, substituting the information you gathered in previous steps:
```other
% atos -arch <BinaryArchitecture> -o <PathToDSYMFile>/Contents/Resources/DWARF/<BinaryName>  -l <LoadAddress> <AddressesToSymbolicate>
```

Using the information in this example, the complete `atos` command and its output are:
Using the information in this example, the complete `atos` command and its output are:
```other
% atos -arch arm64 -o TouchCanvas.app.dSYM/Contents/Resources/DWARF/TouchCanvas -l 0x1022c0000 0x00000001022df754
ViewController.touchesEstimatedPropertiesUpdated(_:) (in TouchCanvas) + 304
```

Once you have at least a partially symbolicated crash report by using `atos`, consult  for information to determine the source of the crash.

## Adding images to your Xcode project
> https://developer.apple.com/documentation/xcode/adding-images-to-your-xcode-project

### 
#### 
1. In the Project navigator, select an asset catalog: a file with a `.xcassets` file extension.
#### 
#### 
#### 
To use the image from code, initialize an image with the name of the image set. Don’t include the file extension.
```swift
// SwiftUI
let image = Image("ImageName")

// UIKit
let image = UIImage(named: "ImageName")

// AppKit
let image = NSImage(named: "ImageName")
```


## Adding package dependencies to your app
> https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app

### 
#### 
#### 
#### 
To use a Swift package’s functionality in your app, import a package’s product as a Swift module. The following code snippet shows a view controller that imports a Swift package’s `MyLibrary` module and uses the package’s functionality:
```swift
import UIKit

// Import the module that corresponds with the Swift package’s library product MyLibrary.
import MyLibrary

class ViewController: UIViewController {

    @IBOutlet var aLabel: UILabel!
    @IBOutlet var aButton: UIButton!
    @IBOutlet var anImageView: UIImageView!
    @IBOutlet var aCustomView: CustomView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Use a string that the package exposes as a property in the MyLibrary file.
        self.aLabel.text = MyLibrary.titleText

        // Load an image that the MyLibrary package makes available through a class method.
        if let imagePath = MyClass.exampleImagePath() {
            self.anImageView.image = UIImage(contentsOfFile: imagePath)
        }

        // Use the Swift package’s CustomView class.
        self.aCustomView = CustomView()
    }

    // Show an alert by calling the package’s API.
    @IBAction func showAlert(_ sender: Any) {
        MyClass.showAlertUsing(viewController: self)
    }
}
```

#### 
#### 
#### 

## Adding structure to your documentation pages
> https://developer.apple.com/documentation/xcode/adding-structure-to-your-documentation-pages

### 
#### 
Use a filename that matches the target’s product module name. For example, for the `SlothCreator` framework, the filename is `SlothCreator.md`.
#### 
To override the default organization and manually arrange the top-level symbols in your technology, add a Topics section to your technology’s landing page. Below any content already in the Markdown file, add a double hash (`##`), a space, and the `Topics` keyword.
```markdown
## Topics
```

```
After the Topics header, create a named section for each group using a triple hash (`###`), and add one or more top-level symbols to each section. Precede each symbol with a dash (`-`) and encapsulate it in a pair of double backticks (``) .
```markdown
## Topics

### Creating sloths

- ``SlothGenerator``
- ``NameGenerator``
- ``Habitat``

### Caring for sloths

- ``Activity``
- ``CareSchedule``
- ``FoodGenerator``
- ``Sloth/Food``
```

#### 
In the extension file, replace the `Symbol` placeholder with the absolute path to the symbol. The absolute path is the target’s product module name followed by the symbol name.
```markdown
# ``SlothCreator/Sloth``
```

The Extension File template includes a `Topics` section with a single named group, ready for you to fill out. Alternatively, if your documentation catalog already contains an extension file for a specific symbol, add a `Topics` section to it by following the steps in the previous section.
As with the landing page, create named sections for each topic group using a triple hash (`###`), and add the necessary symbols to each section using the double backtick (``) syntax.
```markdown
# ``SlothCreator/Sloth``

## Topics

### Creating a sloth

- ``init(name:color:power:)``
- ``SlothGenerator``

### Activities

- ``eat(_:quantity:)``
- ``sleep(in:for:)``

### Schedule

- ``schedule``
```


## Adding supplemental content to a documentation catalog
> https://developer.apple.com/documentation/xcode/adding-supplemental-content-to-a-documentation-catalog

### 
#### 
The structure of an article is similar to symbol files or a top-level landing page, with the exception that the first level 1 header is regular content instead of a symbol reference. For example, the Getting Started with Sloths article contains the following title, single-sentence abstract or summary, and Overview section:
```markdown
# Getting started with sloths

Create a sloth and assign personality traits and abilities.

## Overview

Sloths are complex creatures that require careful creation and a suitable
habitat.
...
```

#### 

## Adding tests to your Xcode project
> https://developer.apple.com/documentation/xcode/adding-tests-to-your-xcode-project

### 
#### 
#### 
#### 
#### 
When recording a workflow that exercises the functionality you’re testing, use the test assertion functions to ensure that the final state of the UI is what you’d expect, given the actions performed during the recorded interaction.
```swift
class MyUITests: XCTestCase {
    let app = XCUIApplication()

    // MARK: - Setup and Teardown
        
    override func setUp() {
        super.setUp()
        // In UI tests, it's prudent to stop the test immediately if a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the app that they test. Do this in setup to ensure that it the app launches for each test method.
        XCUIApplication().launch()
    }

    override func tearDown() {
        // Put teardown code here. The test runner calls this method after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddition() {
        // Perform UI actions to accomplish a task.
        // Check the expected state UI value.
        if let value = app.<ui_type>[<ui_identifier>].value as? String {
            XCTAssertTrue(value = /* … */, "The function didn't return the expected result")
        }        
    }
}
```

#### 
Write performance tests to gather information on time taken, memory used, or data written, during the execution of a region of code. XCTest runs your code multiple times, measuring the requested metrics. You can set a baseline expectation for the metric, and if the measured value is significantly worse than the baseline, XCTest reports a test failure.
To test time taken by your code, call  inside your test method, and run your app’s code inside the block argument to `measure(_:)`. To measure performance using other metrics, including memory use and amount of data written to disk, call .
```swift
class PerformanceTests : XCTestCase {
    func testCodeIsFastEnough() {
        self.measure() {
          // Place performance-sensitive code here.
        }
    }
}
```


## Addressing crashes from Swift runtime errors
> https://developer.apple.com/documentation/xcode/addressing-crashes-from-swift-runtime-errors

### 
Swift uses memory safety techniques to catch programming mistakes early. Optionals require you to think about how best to handle a `nil` value. Type safety prevents casting an object to a type that doesn’t match the object’s actual type.
If you use the `!` operator to force unwrap an optional value that’s `nil`, or if you force a type downcast that fails with the `as!` operator, the Swift runtime catches these errors and intentionally crashes the app. If you can reproduce the runtime error, Xcode logs information about the issue to the console. On ARM processors, the exception info in the crash report looks like:
```other
Exception Type:  EXC_BREAKPOINT (SIGTRAP)
...
Termination Signal: Trace/BPT trap: 5
Termination Reason: Namespace SIGNAL, Code 0x5
```

```
On Intel processors (including apps for macOS, Mac Catalyst, and the simulators for iOS, iPadOS, tvOS, and watchOS), the exception info in the crash report looks like:
```other
Exception Type:        EXC_BAD_INSTRUCTION (SIGILL)
...
Exception Note:        EXC_CORPSE_NOTIFY

Termination Signal:    Illegal instruction: 4
Termination Reason:    Namespace SIGNAL, Code 0x4
```

#### 
The crash report shows the thread that encountered the runtime error, with a frame in the backtrace identifying the specific line of code.
```other
Thread 0 Crashed:
0   MyCoolApp                         0x0000000100a71a88 @objc ViewController.viewDidLoad() (in MyCoolApp) (ViewController.swift:18)
1   MyCoolApp                         0x0000000100a71a40 @objc ViewController.viewDidLoad() (in MyCoolApp) (ViewController.swift:18)
2   UIKitCore                         0x00000001c569e920 -[UIViewController _sendViewDidLoadWithAppearanceProxyObjectTaggingEnabled] + 100
3   UIKitCore                         0x00000001c56a3430 -[UIViewController loadViewIfRequired] + 936
4   UIKitCore                         0x00000001c56a3838 -[UIViewController view] + 28
```

```
In this example, thread 0 encountered the error. Frame 0 of this thread shows that the runtime error occurs on line 18 of `ViewController.swift`, in the `viewDidLoad` method:
```other
0   MyCoolApp                         0x0000000100a71a88 @objc ViewController.viewDidLoad() (in MyCoolApp) (ViewController.swift:18)
```

#### 
Look at the other frames in the backtrace to identify the exact function calls that produced the error, and determine whether you used a force unwrap or a forced downcast. A force unwrap uses the `!` operator. For example:
```swift
let image = UIImage(named: "aMissingIcon")!
print("Image size: \(image.size)")
```

Instead of the force unwrap, gracefully handle the `nil` value where it first appears in your code by using optional binding:
```
Instead of the force unwrap, gracefully handle the `nil` value where it first appears in your code by using optional binding:
```swift
if let image = UIImage(named: "aMissingIcon") {
    print("Image size: \(image.size)")
}
```

For type casts, a forced downcast uses the `as!` operator. This example crashes if `library` contains something other than a `Song` type:
See the Swift documentation for more information on .
For type casts, a forced downcast uses the `as!` operator. This example crashes if `library` contains something other than a `Song` type:
```swift
for item in library {
    let song = item as! Song
    print("Song: \(song.name), by \(song.artist)")
}
```

```
Instead of the forced downcast, gracefully handle the scenarios where the type of the object doesn’t match the expected type by using a conditional downcast:
```swift
for item in library {
    if let song = item as? Song {
         print("Song: \(song.name), by \(song.artist)")
    }
}
```


## Addressing language exception crashes
> https://developer.apple.com/documentation/xcode/addressing-language-exception-crashes

### 
Language exceptions, such as those from Objective-C, indicate programming errors discovered at runtime, such as accessing an array with an index that’s out-of-bounds or not implementing a required method of a protocol. To determine whether a crash is due to a language exception, first confirm that the crash report contains this pattern:
```other
Exception Type:  EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
```

#### 
In the `Last Exception Backtrace`, the operating system records the full backtrace of function calls leading to the exception. This backtrace ends with frames that make it clear a language exception was thrown. Further down the backtrace, you’ll find key information about what method threw the exception, and what part of your code called the method that threw the exception. For example:
```other
Last Exception Backtrace:
0   CoreFoundation                    0x1bf596a48 __exceptionPreprocess + 220
1   libobjc.A.dylib                   0x1bf2bdfa4 objc_exception_throw + 55
2   CoreFoundation                    0x1bf49b0ec -[NSException raise] + 11
3   Foundation                        0x1bf879170 -[NSObject+ 205168 (NSKeyValueCoding) setValue:forKey:] + 311
4   UIKitCore                         0x1c2ffa0b4 -[UIViewController setValue:forKey:] + 99
5   UIKitCore                         0x1c32c1234 -[UIRuntimeOutletConnection connect] + 123
6   CoreFoundation                    0x1bf470f3c -[NSArray makeObjectsPerformSelector:] + 251
7   UIKitCore                         0x1c32be3a4 -[UINib instantiateWithOwner:options:] + 1967
8   UIKitCore                         0x1c3000f18 -[UIViewController _loadViewFromNibNamed:bundle:] + 363
9   UIKitCore                         0x1c30019a4 -[UIViewController loadView] + 175
10  UIKitCore                         0x1c3001c5c -[UIViewController loadViewIfRequired] + 171
11  UIKitCore                         0x1c3002360 -[UIViewController view] + 27
12  UIKitCore                         0x1c3017a98 -[UIViewController _setPresentationController:] + 107
13  UIKitCore                         0x1c30108a4 -[UIViewController _presentViewController:modalSourceViewController:presentationController:animationController:interactionController:completion:] + 1343
14  UIKitCore                         0x1c30122b8 -[UIViewController _presentViewController:withAnimationController:completion:] + 4255
15  UIKitCore                         0x1c3014794 __63-[UIViewController _presentViewController:animated:completion:]_block_invoke + 103
16  UIKitCore                         0x1c3014c90 -[UIViewController _performCoordinatedPresentOrDismiss:animated:] + 507
17  UIKitCore                         0x1c30146e4 -[UIViewController _presentViewController:animated:completion:] + 195
18  UIKitCore                         0x1c301494c -[UIViewController presentViewController:animated:completion:] + 159
19  MyCoolApp                         0x104e8b1ac MyViewController.viewDidLoad() (in MyCoolApp) (MyViewController.swift:35)
```

#### 
The uncaught exception handler provided by the operating system logs the exception message to the console before terminating the process. If you reproduce a crash resulting from a language exception with the Xcode debugger attached to your app, you can see this message:
```other
Application Specific Information:
*** Terminating app due to uncaught exception 'NSUnknownKeyException', 
    reason: '[<MyCoolApp.MyViewController 0x105510d50> setValue:forUndefinedKey:]: 
    this class is not key value coding-compliant for the key refreshButton.'
```

If you can reproduce a language exception crash, set an exception breakpoint to pause execution and inspect your app’s state with Xcode’s debugger, as described in . To automatically print the exception message when the exception breakpoint pauses execution, add an action to the exception breakpoint that runs a debugger command:
```other
po $arg1
```

#### 
#### 
- Don’t specify the `-no_compact_unwind` flag.
- Specify the `-funwind-tables` flag if you’re including plain C code.

## Addressing missing framework crashes
> https://developer.apple.com/documentation/xcode/addressing-missing-framework-crashes

### 
#### 
The dynamic linker, `dyld`, outputs detailed information about the framework it couldn’t locate, in the `Termination Description` of the crash report:
```other
Exception Type: EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note: EXC_CORPSE_NOTIFY
Termination Description: DYLD, 
    dependent dylib '@rpath/MyFramework.framework/MyFramework' not found for '<path>/MyCoolApp.app/MyCoolApp',
    tried but didn't find: 
    '/usr/lib/swift/MyFramework.framework/MyFramework' 
    '<path>/MyCoolApp.app/Frameworks/MyFramework.framework/MyFramework' 
    '@rpath/MyFramework.framework/MyFramework' 
    '/System/Library/Frameworks/MyFramework.framework/MyFramework'
```

```
The exact message depends on the operating system and operating system version. Here’s a different example:
```other
Exception Type: EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note: EXC_CORPSE_NOTIFY
Termination Description: DYLD, Library not loaded: @rpath/MyFramework.framework/MyFramework 
    | Referenced from: <path>/MyCoolApp.app/MyCoolApp 
    | Reason: image not found
```

#### 
- Verify the framework’s build setting for Architectures (`ARCHS`) is the default value.
- Verify the framework’s build setting for Valid Architectures (`VALID_ARCHS`) is the default value.
- Verify the  key in the framework’s `Info.plist` file correctly specifies the CPU architectures the framework supports.

## Addressing watchdog terminations
> https://developer.apple.com/documentation/xcode/addressing-watchdog-terminations

### 
Users expect apps to launch quickly, and are responsive to touches and gestures. The operating system employs a watchdog that monitors launch times and app responsiveness, and terminates unresponsive apps. Watchdog terminations use the code `0x8badf00d` (pronounced “ate bad food”) in the Termination Reason of a crash report:
```other
Exception Type:  EXC_CRASH (SIGKILL)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Termination Reason: Namespace SPRINGBOARD, Code 0x8badf00d
```

#### 
When an app is slow to launch or respond to events, the termination information in the crash report contains important information about how the app spent its time. For example, an iOS app that doesn’t render the UI quickly after launch has the following in the crash report:
```other
Termination Description: SPRINGBOARD, 
    scene-create watchdog transgression: application<com.example.MyCoolApp>:667
    exhausted real (wall clock) time allowance of 19.97 seconds 
    | ProcessVisibility: Foreground 
    | ProcessState: Running 
    | WatchdogEvent: scene-create 
    | WatchdogVisibility: Foreground 
    | WatchdogCPUStatistics: ( 
    |  "Elapsed total CPU time (seconds): 15.290 (user 15.290, system 0.000), 28% CPU", 
    |  "Elapsed application CPU time (seconds): 0.367, 1% CPU" 
    | )
```

#### 
In addition to the app responsiveness watchdog, watchOS has a watchdog for background tasks. In this example, an app didn’t complete handling a  background task within the time allowance:
```other
Termination Reason: CAROUSEL, WatchConnectivity watchdog transgression. 
    Exhausted wall time allowance of 15.00 seconds.
Termination Description: SPRINGBOARD,
    CSLHandleBackgroundWCSessionAction watchdog transgression: xpcservice<com.example.MyCoolApp.watchkitapp.watchextension>:220:220 
    exhausted real (wall clock) time allowance of 15.00 seconds 
    | <FBExtensionProcess: 0x16df02a0; xpcservice<com.example.MyCoolApp.watchkitapp.watchextension>:220:220; typeID: com.apple.watchkit> 
      Elapsed total CPU time (seconds): 24.040 (user 24.040, system 0.000), 81% CPU 
    | Elapsed application CPU time (seconds): 1.223, 6% CPU, lastUpdate 2020-01-20 11:56:01 +0000
```

#### 
The backtraces are sometimes helpful in identifying what is taking so much time on the app’s main thread. For example, if an app uses synchronous networking on the main thread, networking functions are visible in the main thread’s backtrace.
```other
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   libsystem_kernel.dylib            0x00000001c22f8670 semaphore_wait_trap + 8
1   libdispatch.dylib                 0x00000001c2195890 _dispatch_sema4_wait$VARIANT$mp + 24
2   libdispatch.dylib                 0x00000001c2195ed4 _dispatch_semaphore_wait_slow + 140
3   CFNetwork                         0x00000001c57d9d34 CFURLConnectionSendSynchronousRequest + 388
4   CFNetwork                         0x00000001c5753988 +[NSURLConnection sendSynchronousRequest:returningResponse:error:] + 116  + 14728
5   Foundation                        0x00000001c287821c -[NSString initWithContentsOfURL:usedEncoding:error:] + 256
6   libswiftFoundation.dylib          0x00000001f7127284 NSString.__allocating_init+ 680580 (contentsOf:usedEncoding:) + 104
7   libswiftFoundation.dylib          0x00000001f712738c String.init+ 680844 (contentsOf:) + 96
8   MyCoolApp                         0x00000001009d31e0 ViewController.loadData() (in MyCoolApp) (ViewController.swift:21)
```

#### 
#### 

## Adopting type-aware memory allocation
> https://developer.apple.com/documentation/xcode/adopting-type-aware-memory-allocation

### 
#### 
- Add the  entitlement with the value `YES`
- Set the `CLANG_ENABLE_C_TYPED_ALLOCATOR_SUPPORT` build setting with the value `YES`
- Set the `CLANG_ENABLE_CPLUSPLUS_TYPED_ALLOCATOR_SUPPORT` build setting with the value to `YES`
#### 
#### 
- The index, in the original function’s argument list, of the argument developers use to pass the allocation’s size (the first argument is at position `1`)
For example:
```c
#if defined(_MALLOC_TYPE_ENABLED) && _MALLOC_TYPE_ENABLED

// Declare the type-aware variant of your wrapper function.
void *my_malloc_typed(size_t size, malloc_type_id_t type_id);

// Declare your wrapper function, and annotate it with a reference to the type-aware variant.
void *my_malloc(size_t size) _MALLOC_TYPED(my_malloc_typed, 1);

#else

// Declare your wrapper function without any annotation.
void *my_malloc(size_t size);

#endif
```

In your wrapper function’s type-aware variant, return a pointer to memory that you allocate using the `malloc_type_` library function variants:
```
In your wrapper function’s type-aware variant, return a pointer to memory that you allocate using the `malloc_type_` library function variants:
```c
void *my_malloc_typed(size_t size, malloc_type_id_t type_id) {
  // Implement the custom logic for your wrapper function.

  return malloc_type_malloc(size, type_id);
}
```


## Allowing apps and websites to link to your content
> https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content

### 
#### 
#### 
Apps can communicate through universal links. Supporting universal links allows other apps to send small amounts of data directly to your app without using a third-party server. 
Define the parameters that your app handles within the URL query string. The following example code for a photo library app specifies parameters that include the name of an album and the index of a photo to display.
```other
https://myphotoapp.example.com/albums?albumname=vacation&index=1
https://myphotoapp.example.com/albums?albumname=wedding&index=17
```

The calling app can ask the system to inform it when your app opens the URL.
In this example code, an app calls your universal link in iOS and tvOS:
```swift
if let appURL = URL(string: "https://myphotoapp.example.com/albums?albumname=vacation&index=1") {
    UIApplication.shared.open(appURL) { success in
        if success {
            print("The URL was delivered successfully.")
        } else {
            print("The URL failed to open.")
        }
    }
} else {
    print("Invalid URL specified.")
}
```

```
In this example code, an app calls your universal link in watchOS:
```swift
if let appURL = URL(string: "https://myphotoapp.example.com/albums?albumname=vacation&index=1") {
    WKExtension.shared().openSystemURL(appURL)
} else {
    print("Invalid URL specified.")
}
```

```
In this example code, an app calls your universal link in macOS:
```swift
if let appURL = URL(string: "https://myphotoapp.example.com/albums?albumname=vacation&index=1") {
    let configuration = NSWorkspace.OpenConfiguration()
    NSWorkspace.shared.open(appURL, configuration: configuration) { (app, error) in
        guard error == nil else {
            print("The URL failed to open.")
            return
        }
        print("The URL was delivered successfully.")
    }
} else {
    print("Invalid URL specified.")
}
```


## Analyzing a crash report
> https://developer.apple.com/documentation/xcode/analyzing-a-crash-report

### 
#### 
#### 
#### 
- How long was the app running before it crashed? Use the `Date/Time` and `Launch Time` fields to determine this.
#### 
- Are there any additional codes in the `Termination Reason` field? What does the code mean?
#### 
- Based on the exception type, is the crash due to a memory access issue? See  for how to decode the provided `VM Region Info`.
- Is there an `Application Specific Information` field? Is there a specific API named in that message? Where do you use that API in your code?
#### 
- Was a language exception thrown? What does the `Last Exception Backtrace` show?
- What mix of binaries in your app and Apple’s system frameworks are in the backtrace?
Even if the functions in the backtrace aren’t ones you directly call, they contain key clues. For example, this backtrace contains only system frameworks except for the app’s `main` function, but the crash is due to an invalid popover configuration in an iPadOS app:
```other
Last Exception Backtrace:
0   CoreFoundation                    0x1a1801190 __exceptionPreprocess + 228
1   libobjc.A.dylib                   0x1a09d69f8 objc_exception_throw + 55
2   UIKitCore                         0x1cd5d0af0 -[UIPopoverPresentationController presentationTransitionWillBegin] + 2739
3   UIKitCore                         0x1cd5d9358 __71-[UIPresentationController _initViewHierarchyForPresentationSuperview:]_block_invoke + 2175
4   UIKitCore                         0x1cd5d6ea4 __56-[UIPresentationController runTransitionForCurrentState]_block_invoke + 463
5   UIKitCore                         0x1cdc5c0ac _runAfterCACommitDeferredBlocks + 295
6   UIKitCore                         0x1cdc4abfc _cleanUpAfterCAFlushAndRunDeferredBlocks + 351
7   UIKitCore                         0x1cdc77a6c _afterCACommitHandler + 115
8   CoreFoundation                    0x1a179250c __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__ + 31
9   CoreFoundation                    0x1a178d234 __CFRunLoopDoObservers + 411
10  CoreFoundation                    0x1a178d7b0 __CFRunLoopRun + 1227
11  CoreFoundation                    0x1a178cfc4 CFRunLoopRunSpecific + 435
12  GraphicsServices                  0x1a398e79c GSEventRunModal + 103
13  UIKitCore                         0x1cdc50c38 UIApplicationMain + 211
14  MyGreatApp                        0x10079600c main (in MyGreatApp) (AppDelegate.swift:12)
15  libdyld.dylib                     0x1a124d8e0 start + 3
```

#### 
#### 

## Build settings reference
> https://developer.apple.com/documentation/xcode/build-settings-reference

### 
#### 
 `ACTION`
#### 
 `ADDITIONAL_SDKS`
#### 
 `ALLOW_TARGET_PLATFORM_SPECIALIZATION`
#### 
 `ALTERNATE_GROUP`
The group name or gid for the files listed under the `ALTERNATE_PERMISSIONS_FILES` setting.
#### 
 `ALTERNATE_MODE`
Permissions used for the files listed under the `ALTERNATE_PERMISSIONS_FILES` setting.
#### 
 `ALTERNATE_OWNER`
The owner name or uid for the files listed under the `ALTERNATE_PERMISSIONS_FILES` setting.
#### 
 `ALTERNATE_PERMISSIONS_FILES`
#### 
 `ALTERNATIVE_DISTRIBUTION_WEB`
#### 
 `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES`
#### 
 `ALWAYS_SEARCH_USER_PATHS`
#### 
 `APPLICATION_EXTENSION_API_ONLY`
#### 
 `APPLY_RULES_IN_COPY_FILES`
#### 
 `APPLY_RULES_IN_COPY_HEADERS`
#### 
 `APP_SHORTCUTS_ENABLE_FLEXIBLE_MATCHING`
#### 
 `ARCHS`
#### 
 `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES`
#### 
 `ASSETCATALOG_COMPILER_APPICON_NAME`
Name of an app icon set for the target’s default app icon. The contents will be merged into the `Info.plist`.
#### 
 `ASSETCATALOG_COMPILER_COMPLICATION_NAME`
#### 
 `ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS`
#### 
 `ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOL_FRAMEWORKS`
#### 
 `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS`
#### 
 `ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME`
#### 
 `ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS`
#### 
 `ASSETCATALOG_COMPILER_INCLUDE_INFOPLIST_LOCALIZATIONS`
#### 
 `ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME`
Name of an asset catalog launch image set whose contents will be merged into the `Info.plist`.
#### 
 `ASSETCATALOG_COMPILER_LEADERBOARD_IDENTIFIER_PREFIX`
#### 
 `ASSETCATALOG_COMPILER_LEADERBOARD_SET_IDENTIFIER_PREFIX`
#### 
 `ASSETCATALOG_COMPILER_OPTIMIZATION`
#### 
 `ASSETCATALOG_COMPILER_SKIP_APP_STORE_DEPLOYMENT`
#### 
 `ASSETCATALOG_COMPILER_STANDALONE_ICON_BEHAVIOR`
#### 
 `ASSETCATALOG_COMPILER_STICKER_PACK_IDENTIFIER_PREFIX`
#### 
 `ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME`
#### 
 `ASSETCATALOG_NOTICES`
#### 
 `ASSETCATALOG_OTHER_FLAGS`
#### 
 `ASSETCATALOG_WARNINGS`
#### 
 `ASSET_PACK_MANIFEST_URL_PREFIX`
#### 
 `AUTOMATION_APPLE_EVENTS`
#### 
 `BUILD_COMPONENTS`
#### 
 `BUILD_LIBRARY_FOR_DISTRIBUTION`
#### 
 `BUILD_ONLY_KNOWN_LOCALIZATIONS`
#### 
 `BUILD_VARIANTS`
#### 
 `BUILT_PRODUCTS_DIR`
#### 
 `BUNDLE_LOADER`
#### 
 `CLANG_ADDRESS_SANITIZER_CONTAINER_OVERFLOW`
#### 
 `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES`
#### 
 `CLANG_ANALYZER_DEADCODE_DEADSTORES`
#### 
 `CLANG_ANALYZER_DIVIDE_BY_ZERO`
#### 
 `CLANG_ANALYZER_GCD`
#### 
 `CLANG_ANALYZER_GCD_PERFORMANCE`
#### 
 `CLANG_ANALYZER_LIBKERN_RETAIN_COUNT`
#### 
 `CLANG_ANALYZER_LOCALIZABILITY_EMPTY_CONTEXT`
Warn when a call to an `NSLocalizedString()` macro is missing a context comment for the localizer.
#### 
 `CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED`
#### 
 `CLANG_ANALYZER_MEMORY_MANAGEMENT`
#### 
 `CLANG_ANALYZER_MIG_CONVENTIONS`
#### 
 `CLANG_ANALYZER_NONNULL`
Check for misuses of `nonnull` parameter and return types.
#### 
 `CLANG_ANALYZER_NULL_DEREFERENCE`
#### 
 `CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION`
#### 
 `CLANG_ANALYZER_OBJC_ATSYNC`
Warn on `nil` pointers used as mutexes for `@synchronized`.
#### 
 `CLANG_ANALYZER_OBJC_COLLECTIONS`
Warn if `CF` collections are created with non-pointer-size values. Check if `NS` collections are initialized with non-Objective-C type elements.
#### 
 `CLANG_ANALYZER_OBJC_DEALLOC`
Warn when an instance is improperly cleaned up in `-dealloc`.
#### 
 `CLANG_ANALYZER_OBJC_GENERICS`
#### 
 `CLANG_ANALYZER_OBJC_INCOMP_METHOD_TYPES`
#### 
 `CLANG_ANALYZER_OBJC_NSCFERROR`
Warn if functions accepting `CFErrorRef` or `NSError` cannot indicate that an error occurred.
#### 
 `CLANG_ANALYZER_OBJC_RETAIN_COUNT`
#### 
 `CLANG_ANALYZER_OBJC_SELF_INIT`
Check that `super init` is properly called within an Objective-C initialization method.
#### 
 `CLANG_ANALYZER_OBJC_UNUSED_IVARS`
#### 
 `CLANG_ANALYZER_OSOBJECT_C_STYLE_CAST`
#### 
 `CLANG_ANALYZER_SECURITY_BUFFER_OVERFLOW_EXPERIMENTAL`
#### 
 `CLANG_ANALYZER_SECURITY_FLOATLOOPCOUNTER`
#### 
 `CLANG_ANALYZER_SECURITY_INSECUREAPI_GETPW_GETS`
Warn on uses of `getpw` and `gets`. The functions are dangerous as they may trigger a buffer overflow.
#### 
 `CLANG_ANALYZER_SECURITY_INSECUREAPI_MKSTEMP`
#### 
 `CLANG_ANALYZER_SECURITY_INSECUREAPI_RAND`
Warn on uses of `rand`, `random`, and related functions, which produce predictable random number sequences. Use `arc4random` instead.
#### 
 `CLANG_ANALYZER_SECURITY_INSECUREAPI_STRCPY`
Warn on uses of the `strcpy` and `strcat` functions, which can result in buffer overflows. Use `strlcpy` or `strlcat` instead.
#### 
 `CLANG_ANALYZER_SECURITY_INSECUREAPI_UNCHECKEDRETURN`
#### 
 `CLANG_ANALYZER_SECURITY_INSECUREAPI_VFORK`
Warn on uses of the `vfork` function, which is inherently insecure. Use the safer `posix_spawn` function instead.
#### 
 `CLANG_ANALYZER_SECURITY_KEYCHAIN_API`
#### 
 `CLANG_ANALYZER_USE_AFTER_MOVE`
#### 
 `CLANG_CXX_LANGUAGE_STANDARD`
#### 
 `CLANG_CXX_STANDARD_LIBRARY_HARDENING`
This setting defines the value of the `_LIBCPP_HARDENING_MODE` preprocessor macro.
#### 
 `CLANG_DEBUG_INFORMATION_LEVEL`
#### 
 `CLANG_ENABLE_CPLUSPLUS_TYPED_ALLOCATOR_SUPPORT`
#### 
 `CLANG_ENABLE_CPP_STATIC_DESTRUCTORS`
#### 
 `CLANG_ENABLE_C_TYPED_ALLOCATOR_SUPPORT`
#### 
 `CLANG_ENABLE_MODULES`
#### 
 `CLANG_ENABLE_MODULE_DEBUGGING`
#### 
 `CLANG_ENABLE_OBJC_ARC`
#### 
 `CLANG_ENABLE_OBJC_ARC_EXCEPTIONS`
#### 
 `CLANG_ENABLE_OBJC_WEAK`
#### 
 `CLANG_ENABLE_STACK_ZERO_INIT`
#### 
 `CLANG_INDEX_STORE_IGNORE_MACROS`
#### 
 `CLANG_LINK_OBJC_RUNTIME`
#### 
 `CLANG_MODULES_AUTOLINK`
#### 
 `CLANG_MODULES_DISABLE_PRIVATE_WARNING`
#### 
 `CLANG_OPTIMIZATION_PROFILE_FILE`
The path to the file of the profile data to use when `CLANG_USE_OPTIMIZATION_PROFILE` is enabled.
#### 
 `CLANG_STATIC_ANALYZER_MODE`
The depth the static analyzer uses during the Build action. Use `Deep` to exercise the full power of the analyzer. Use `Shallow` for faster analysis.
#### 
 `CLANG_STATIC_ANALYZER_MODE_ON_ANALYZE_ACTION`
#### 
 `CLANG_TIDY_BUGPRONE_ASSERT_SIDE_EFFECT`
#### 
 `CLANG_TIDY_BUGPRONE_INFINITE_LOOP`
#### 
 `CLANG_TIDY_BUGPRONE_MOVE_FORWARDING_REFERENCE`
#### 
 `CLANG_TIDY_BUGPRONE_REDUNDANT_BRANCH_CONDITION`
#### 
 `CLANG_TIDY_MISC_REDUNDANT_EXPRESSION`
#### 
 `CLANG_TRIVIAL_AUTO_VAR_INIT`
#### 
 `CLANG_UNDEFINED_BEHAVIOR_SANITIZER_INTEGER`
#### 
 `CLANG_UNDEFINED_BEHAVIOR_SANITIZER_NULLABILITY`
#### 
 `CLANG_USE_OPTIMIZATION_PROFILE`
When this setting is enabled, `clang` will use the optimization profile collected for a target when building it.
#### 
 `CLANG_USE_RESPONSE_FILE`
#### 
 `CLANG_WARN_ASSIGN_ENUM`
#### 
 `CLANG_WARN_ATOMIC_IMPLICIT_SEQ_CST`
#### 
 `CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING`
#### 
 `CLANG_WARN_BOOL_CONVERSION`
#### 
 `CLANG_WARN_COMMA`
#### 
 `CLANG_WARN_COMPLETION_HANDLER_MISUSE`
#### 
 `CLANG_WARN_CONSTANT_CONVERSION`
#### 
 `CLANG_WARN_CXX0X_EXTENSIONS`
#### 
 `CLANG_WARN_DELETE_NON_VIRTUAL_DTOR`
#### 
 `CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS`
#### 
 `CLANG_WARN_DIRECT_OBJC_ISA_USAGE`
Warn about direct accesses to the Objective-C `isa` pointer instead of using a runtime API.
#### 
 `CLANG_WARN_DOCUMENTATION_COMMENTS`
Warns about issues in documentation comments (`doxygen`-style) such as missing or incorrect documentation tags.
#### 
 `CLANG_WARN_EMPTY_BODY`
#### 
 `CLANG_WARN_ENUM_CONVERSION`
#### 
 `CLANG_WARN_FLOAT_CONVERSION`
#### 
 `CLANG_WARN_FRAMEWORK_INCLUDE_PRIVATE_FROM_PUBLIC`
#### 
 `CLANG_WARN_IMPLICIT_FALLTHROUGH`
#### 
 `CLANG_WARN_IMPLICIT_SIGN_CONVERSION`
#### 
 `CLANG_WARN_INFINITE_RECURSION`
#### 
 `CLANG_WARN_INT_CONVERSION`
#### 
 `CLANG_WARN_MISSING_NOESCAPE`
#### 
 `CLANG_WARN_NON_LITERAL_NULL_CONVERSION`
#### 
 `CLANG_WARN_NULLABLE_TO_NONNULL_CONVERSION`
Warns when a nullable expression is used somewhere it’s not allowed, such as when passed as a `_Nonnull` parameter.
#### 
 `CLANG_WARN_OBJC_EXPLICIT_OWNERSHIP_TYPE`
#### 
 `CLANG_WARN_OBJC_IMPLICIT_ATOMIC_PROPERTIES`
Warn about `@property` declarations that are implicitly atomic.
#### 
 `CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF`
Warn about implicit retains of `self` within blocks, which can create a retain-cycle.
#### 
 `CLANG_WARN_OBJC_INTERFACE_IVARS`
Warn about instance variable declarations in `@interface`.
#### 
 `CLANG_WARN_OBJC_LITERAL_CONVERSION`
#### 
 `CLANG_WARN_OBJC_MISSING_PROPERTY_SYNTHESIS`
#### 
 `CLANG_WARN_OBJC_REPEATED_USE_OF_WEAK`
#### 
 `CLANG_WARN_OBJC_ROOT_CLASS`
Warn about classes that unintentionally do not subclass a root class, such as `NSObject`.
#### 
 `CLANG_WARN_PRAGMA_PACK`
#### 
 `CLANG_WARN_PRIVATE_MODULE`
#### 
 `CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER`
#### 
 `CLANG_WARN_RANGE_LOOP_ANALYSIS`
#### 
 `CLANG_WARN_SEMICOLON_BEFORE_METHOD_BODY`
#### 
 `CLANG_WARN_STRICT_PROTOTYPES`
#### 
 `CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION`
#### 
 `CLANG_WARN_SUSPICIOUS_MOVE`
Warn about suspicious uses of `std::move`.
#### 
 `CLANG_WARN_UNGUARDED_AVAILABILITY`
#### 
 `CLANG_WARN_UNREACHABLE_CODE`
#### 
 `CLANG_WARN_VEXING_PARSE`
#### 
 `CLANG_WARN__ARC_BRIDGE_CAST_NONARC`
Warn about using `__bridge` casts when not using ARC, where they have no effect.
#### 
 `CLANG_WARN__DUPLICATE_METHOD_MATCH`
Warn about declaring the same method more than once within the same `@interface`.
#### 
 `CLANG_WARN__EXIT_TIME_DESTRUCTORS`
#### 
 `CLANG_X86_VECTOR_INSTRUCTIONS`
#### 
 `CODE_SIGN_ENTITLEMENTS`
#### 
 `CODE_SIGN_IDENTITY`
#### 
 `CODE_SIGN_INJECT_BASE_ENTITLEMENTS`
#### 
 `CODE_SIGN_STYLE`
#### 
 `COMBINE_HIDPI_IMAGES`
#### 
 `COMPILATION_CACHE_ENABLE_CACHING`
#### 
 `COMPILATION_CACHE_ENABLE_DIAGNOSTIC_REMARKS`
#### 
 `COMPILER_INDEX_STORE_ENABLE`
#### 
 `COMPRESS_PNG_FILES`
#### 
 `CONFIGURATION`
Identifies the build configuration, such as `Debug` or `Release`, that the target uses to generate the product.
#### 
 `CONFIGURATION_BUILD_DIR`
#### 
 `CONFIGURATION_TEMP_DIR`
#### 
 `CONTENTS_FOLDER_PATH`
#### 
 `COPYING_PRESERVES_HFS_DATA`
#### 
 `COPY_HEADERS_RUN_UNIFDEF`
If enabled, headers are run through the `unifdef(1)` tool when copied to the product.
#### 
 `COPY_HEADERS_UNIFDEF_FLAGS`
#### 
 `COPY_PHASE_STRIP`
#### 
 `COREML_CODEGEN_LANGUAGE`
#### 
 `COREML_CODEGEN_SWIFT_GLOBAL_MODULE`
#### 
 `CPP_OTHER_PREPROCESSOR_FLAGS`
#### 
 `CPP_PREPROCESSOR_DEFINITIONS`
#### 
 `CREATE_INFOPLIST_SECTION_IN_BINARY`
#### 
 `CURRENT_ARCH`
#### 
 `CURRENT_PROJECT_VERSION`
This setting defines the current version of the project. The value must be a integer or floating point number, such as `57` or `365.8`.
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `CURRENT_VARIANT`
#### 
 `C_COMPILER_LAUNCHER`
#### 
 `DEAD_CODE_STRIPPING`
Activating this setting causes the `-dead_strip` flag to be passed to `ld(1)` via `cc(1)` to turn on dead code stripping.
#### 
 `DEBUG_INFORMATION_FORMAT`
#### 
 `DEBUG_INFORMATION_VERSION`
#### 
 `DEFINES_MODULE`
#### 
 `DEPLOYMENT_LOCATION`
#### 
 `DEPLOYMENT_POSTPROCESSING`
#### 
 `DEPLOYMENT_TARGET_SETTING_NAME`
#### 
 `DERIVED_FILE_DIR`
Identifies the directory into which derived source files, such as those generated by `lex` and `yacc`, are placed.
#### 
 `DERIVE_MACCATALYST_PRODUCT_BUNDLE_IDENTIFIER`
#### 
 `DEVELOPMENT_ASSET_PATHS`
#### 
 `DEVELOPMENT_TEAM`
#### 
 `DOCC_ENABLE_CXX_SUPPORT`
#### 
 `DOCC_EXTRACT_EXTENSION_SYMBOLS`
#### 
 `DOCC_EXTRACT_OBJC_INFO_FOR_SWIFT_SYMBOLS`
#### 
 `DOCC_EXTRACT_SWIFT_INFO_FOR_OBJC_SYMBOLS`
#### 
 `DOCC_HOSTING_BASE_PATH`
#### 
 `DOCUMENTATION_FOLDER_PATH`
#### 
 `DONT_GENERATE_INFOPLIST_FILE`
If enabled, don’t automatically generate an Info.plist file for wrapped products when the `INFOPLIST_FILE` build setting is empty.
#### 
 `DSTROOT`
#### 
 `DTRACE_OTHER_FLAGS`
#### 
 `DYLIB_COMPATIBILITY_VERSION`
#### 
 `DYLIB_CURRENT_VERSION`
#### 
 `DYLIB_INSTALL_NAME_BASE`
#### 
 `EAGER_LINKING`
#### 
 `EMBED_ASSET_PACKS_IN_PRODUCT_BUNDLE`
#### 
 `ENABLE_APP_SANDBOX`
#### 
 `ENABLE_CODE_COVERAGE`
#### 
 `ENABLE_CPLUSPLUS_BOUNDS_SAFE_BUFFERS`
#### 
 `ENABLE_C_BOUNDS_SAFETY`
#### 
 `ENABLE_DEBUG_DYLIB`
#### 
 `ENABLE_ENHANCED_SECURITY`
#### 
 `ENABLE_FILE_ACCESS_DOWNLOADS_FOLDER`
#### 
 `ENABLE_FILE_ACCESS_MOVIES_FOLDER`
#### 
 `ENABLE_FILE_ACCESS_MUSIC_FOLDER`
#### 
 `ENABLE_FILE_ACCESS_PICTURE_FOLDER`
#### 
 `ENABLE_HARDENED_RUNTIME`
#### 
 `ENABLE_HEADER_DEPENDENCIES`
#### 
 `ENABLE_INCOMING_NETWORK_CONNECTIONS`
#### 
 `ENABLE_INCREMENTAL_DISTILL`
Enabled the incremental `distill` option in the asset catalog compiler. This feature is experimental and should only be enabled with caution.
#### 
 `ENABLE_MODULE_VERIFIER`
#### 
 `ENABLE_NS_ASSERTIONS`
#### 
 `ENABLE_ONLY_ACTIVE_RESOURCES`
#### 
 `ENABLE_ON_DEMAND_RESOURCES`
#### 
 `ENABLE_OUTGOING_NETWORK_CONNECTIONS`
#### 
 `ENABLE_POINTER_AUTHENTICATION`
#### 
 `ENABLE_RESOURCE_ACCESS_AUDIO_INPUT`
#### 
 `ENABLE_RESOURCE_ACCESS_BLUETOOTH`
#### 
 `ENABLE_RESOURCE_ACCESS_CALENDARS`
#### 
 `ENABLE_RESOURCE_ACCESS_CAMERA`
#### 
 `ENABLE_RESOURCE_ACCESS_CONTACTS`
#### 
 `ENABLE_RESOURCE_ACCESS_LOCATION`
#### 
 `ENABLE_RESOURCE_ACCESS_PHOTO_LIBRARY`
#### 
 `ENABLE_RESOURCE_ACCESS_PRINTING`
#### 
 `ENABLE_RESOURCE_ACCESS_USB`
#### 
 `ENABLE_SECURITY_COMPILER_WARNINGS`
#### 
 `ENABLE_STRICT_OBJC_MSGSEND`
Controls whether `objc_msgSend` calls must be cast to the appropriate function pointer type before being called.
#### 
 `ENABLE_TESTABILITY`
- `GCC_SYMBOLS_PRIVATE_EXTERN` is disabled (`-fvisibility=hidden` will not be passed to `clang`).
- `-enable-testing` is passed to the Swift compiler.
- `-rdynamic` is passed to the linker.
- `STRIP_INSTALLED_PRODUCT` is disabled (`strip` will not be run on the produced binary).
#### 
 `ENABLE_TESTING_SEARCH_PATHS`
#### 
 `ENABLE_USER_SCRIPT_SANDBOXING`
#### 
 `ENABLE_USER_SELECTED_FILES`
#### 
 `EXCLUDED_ARCHS`
#### 
 `EXCLUDED_EXPLICIT_TARGET_DEPENDENCIES`
#### 
 `EXCLUDED_RECURSIVE_SEARCH_PATH_SUBDIRECTORIES`
#### 
 `EXCLUDED_SOURCE_FILE_NAMES`
#### 
 `EXECUTABLES_FOLDER_PATH`
#### 
 `EXECUTABLE_EXTENSION`
#### 
 `EXECUTABLE_FOLDER_PATH`
#### 
 `EXECUTABLE_NAME`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `EXECUTABLE_PATH`
#### 
 `EXECUTABLE_PREFIX`
#### 
 `EXECUTABLE_SUFFIX`
#### 
 `EXPORTED_SYMBOLS_FILE`
This is a project-relative path to a file that lists the symbols to export. See `ld -exported_symbols_list` for details on exporting symbols.
#### 
 `FRAMEWORKS_FOLDER_PATH`
#### 
 `FRAMEWORK_SEARCH_PATHS`
#### 
 `FRAMEWORK_VERSION`
#### 
 `FUSE_BUILD_SCRIPT_PHASES`
#### 
 `GCC_CHAR_IS_UNSIGNED_CHAR`
Enabling this setting causes `char` to be unsigned by default, disabling it causes `char` to be signed by default.
#### 
 `GCC_CW_ASM_SYNTAX`
#### 
 `GCC_C_LANGUAGE_STANDARD`
#### 
 `GCC_DYNAMIC_NO_PIC`
#### 
 `GCC_ENABLE_ASM_KEYWORD`
Controls whether `asm`, `inline`, and `typeof` are treated as keywords or whether they can be used as identifiers.
#### 
 `GCC_ENABLE_BUILTIN_FUNCTIONS`
Controls whether builtin functions that do not begin with `__builtin_` as prefix are recognized.
#### 
 `GCC_ENABLE_CPP_EXCEPTIONS`
#### 
 `GCC_ENABLE_CPP_RTTI`
#### 
 `GCC_ENABLE_EXCEPTIONS`
#### 
 `GCC_ENABLE_FLOATING_POINT_LIBRARY_CALLS`
#### 
 `GCC_ENABLE_KERNEL_DEVELOPMENT`
#### 
 `GCC_ENABLE_OBJC_EXCEPTIONS`
This setting enables `@try`/`@catch`/`@throw` syntax for handling exceptions in Objective-C code. Only applies to Objective-C. [-fobjc-exceptions]
#### 
 `GCC_ENABLE_PASCAL_STRINGS`
#### 
 `GCC_ENABLE_SSE3_EXTENSIONS`
#### 
 `GCC_ENABLE_SSE41_EXTENSIONS`
#### 
 `GCC_ENABLE_SSE42_EXTENSIONS`
#### 
 `GCC_ENABLE_TRIGRAPHS`
#### 
 `GCC_FAST_MATH`
#### 
 `GCC_GENERATE_DEBUGGING_SYMBOLS`
#### 
 `GCC_GENERATE_TEST_COVERAGE_FILES`
Activating this setting causes a `notes` file to be produced that the `gcov` code-coverage utility can use to show program coverage.
#### 
 `GCC_INCREASE_PRECOMPILED_HEADER_SHARING`
#### 
 `GCC_INLINES_ARE_PRIVATE_EXTERN`
When enabled, out-of-line copies of inline methods are declared `private extern`.
#### 
 `GCC_INPUT_FILETYPE`
#### 
 `GCC_INSTRUMENT_PROGRAM_FLOW_ARCS`
#### 
 `GCC_LINK_WITH_DYNAMIC_LIBRARIES`
#### 
 `GCC_NO_COMMON_BLOCKS`
#### 
 `GCC_OPTIMIZATION_LEVEL`
#### 
 `GCC_PRECOMPILE_PREFIX_HEADER`
#### 
 `GCC_PREFIX_HEADER`
#### 
 `GCC_PREPROCESSOR_DEFINITIONS`
Space-separated list of preprocessor macros of the form `foo` or `foo=bar`.
#### 
 `GCC_PREPROCESSOR_DEFINITIONS_NOT_USED_IN_PRECOMPS`
Space-separated list of preprocessor macros of the form `foo` or `foo=bar`. These macros are not used when precompiling a prefix header file.
#### 
 `GCC_REUSE_STRINGS`
#### 
 `GCC_SHORT_ENUMS`
#### 
 `GCC_STRICT_ALIASING`
#### 
 `GCC_SYMBOLS_PRIVATE_EXTERN`
#### 
 `GCC_THREADSAFE_STATICS`
#### 
 `GCC_TREAT_IMPLICIT_FUNCTION_DECLARATIONS_AS_ERRORS`
#### 
 `GCC_TREAT_INCOMPATIBLE_POINTER_TYPE_WARNINGS_AS_ERRORS`
#### 
 `GCC_TREAT_WARNINGS_AS_ERRORS`
#### 
 `GCC_UNROLL_LOOPS`
#### 
 `GCC_USE_STANDARD_INCLUDE_SEARCHING`
#### 
 `GCC_VERSION`
#### 
 `GCC_WARN_64_TO_32_BIT_CONVERSION`
#### 
 `GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS`
Warn about the use of deprecated functions, variables, and types (as indicated by the `deprecated` attribute).
#### 
 `GCC_WARN_ABOUT_INVALID_OFFSETOF_MACRO`
The restrictions on `offsetof` may be relaxed in a future version of the C++ standard.
#### 
 `GCC_WARN_ABOUT_MISSING_FIELD_INITIALIZERS`
 `GCC_WARN_ABOUT_MISSING_FIELD_INITIALIZERS`
Warn if a structure’s initializer has some fields missing. For example, the following code would cause such a warning because `x.h` is implicitly zero:
```None
struct s { int f, g, h; };
struct s x = { 3, 4 };
```

```
This option does not warn about designated initializers, so the following modification would not trigger a warning:
```None
struct s { int f, g, h; };
struct s x = { .f = 3, .g = 4 };
```

#### 
 `GCC_WARN_ABOUT_MISSING_NEWLINE`
#### 
 `GCC_WARN_ABOUT_MISSING_PROTOTYPES`
#### 
 `GCC_WARN_ABOUT_POINTER_SIGNEDNESS`
#### 
 `GCC_WARN_ABOUT_RETURN_TYPE`
#### 
 `GCC_WARN_ALLOW_INCOMPLETE_PROTOCOL`
#### 
 `GCC_WARN_CHECK_SWITCH_STATEMENTS`
#### 
 `GCC_WARN_FOUR_CHARACTER_CONSTANTS`
Warn about four-char literals (for example, macOS-style `OSTypes`: `'APPL'`).
#### 
 `GCC_WARN_HIDDEN_VIRTUAL_FUNCTIONS`
For example, in the following example, the `A` class version of `f()` is hidden in `B`.
Warn when a function declaration hides virtual functions from a base class.
For example, in the following example, the `A` class version of `f()` is hidden in `B`.
```None
struct A {
  virtual void f();
};

struct B: public A {
  void f(int);
};
```

```
As a result, the following code will fail to compile.
```None
B* b;
b->f();
```

#### 
 `GCC_WARN_INHIBIT_ALL_WARNINGS`
#### 
 `GCC_WARN_INITIALIZER_NOT_FULLY_BRACKETED`
 `GCC_WARN_INITIALIZER_NOT_FULLY_BRACKETED`
Warn if an aggregate or union initializer is not fully bracketed. In the following example, the initializer for `a` is not fully bracketed, but the initializer for `b` is fully bracketed.
```None
int a[2][2] = { 0, 1, 2, 3 };
int b[2][2] = { { 0, 1 }, { 2, 3 } };
```

#### 
 `GCC_WARN_MISSING_PARENTHESES`
 `GCC_WARN_MISSING_PARENTHESES`
Warn if parentheses are omitted in certain contexts, such as when there is an assignment in a context where a truth value is expected, or when operators are nested whose precedence causes confusion. Also, warn about constructions where there may be confusion as to which `if` statement an `else` branch belongs. For example:
```None
{
  if (a)
    if (b)
      foo ();
  else
    bar ();
}
```

```
In C, every `else` branch belongs to the innermost possible `if` statement, which in the example above is `if (b)`. This is often not what the programmer expects, as illustrated by indentation used in the example above. This build setting causes GCC to issue a warning when there is the potential for this confusion. To eliminate the warning, add explicit braces around the innermost `if` statement so there is no way the `else` could belong to the enclosing `if`. For example:
```None
{
  if (a)
    {
      if (b)
        foo ();
      else
        bar ();
    }
}
```

#### 
 `GCC_WARN_NON_VIRTUAL_DESTRUCTOR`
#### 
 `GCC_WARN_PEDANTIC`
#### 
 `GCC_WARN_SHADOW`
#### 
 `GCC_WARN_SIGN_COMPARE`
#### 
 `GCC_WARN_STRICT_SELECTOR_MATCH`
#### 
 `GCC_WARN_TYPECHECK_CALLS_TO_PRINTF`
#### 
 `GCC_WARN_UNDECLARED_SELECTOR`
#### 
 `GCC_WARN_UNINITIALIZED_AUTOS`
Warn if a variable might be clobbered by a `setjmp` call or if an automatic variable is used without prior initialization.
#### 
 `GCC_WARN_UNKNOWN_PRAGMAS`
#### 
 `GCC_WARN_UNUSED_FUNCTION`
#### 
 `GCC_WARN_UNUSED_LABEL`
#### 
 `GCC_WARN_UNUSED_PARAMETER`
#### 
 `GCC_WARN_UNUSED_VALUE`
#### 
 `GCC_WARN_UNUSED_VARIABLE`
#### 
 `GENERATE_INFOPLIST_FILE`
#### 
 `GENERATE_INTERMEDIATE_TEXT_BASED_STUBS`
#### 
 `GENERATE_PKGINFO_FILE`
Forces the `PkgInfo` file to be written to wrapped products even if this file is not expected.
#### 
 `GENERATE_PRELINK_OBJECT_FILE`
#### 
 `GENERATE_PROFILING_CODE`
#### 
 `GENERATE_TEXT_BASED_STUBS`
#### 
 `HEADERMAP_INCLUDES_FLAT_ENTRIES_FOR_TARGET_BEING_BUILT`
#### 
 `HEADERMAP_INCLUDES_FRAMEWORK_ENTRIES_FOR_ALL_PRODUCT_TYPES`
#### 
 `HEADERMAP_INCLUDES_PROJECT_HEADERS`
#### 
 `HEADER_DEPENDENCIES`
#### 
 `HEADER_SEARCH_PATHS`
#### 
 `IBC_COMPILER_AUTO_ACTIVATE_CUSTOM_FONTS`
Instructs the XIB compiler to add custom fonts to the application’s `Info.plist`, which will cause the fonts to activate upon application launch.
#### 
 `IBC_ERRORS`
#### 
 `IBC_FLATTEN_NIBS`
#### 
 `IBC_MODULE`
#### 
 `IBC_NOTICES`
#### 
 `IBC_OTHER_FLAGS`
#### 
 `IBC_OVERRIDING_PLUGINS_AND_FRAMEWORKS_DIR`
#### 
 `IBC_PLUGINS`
#### 
 `IBC_PLUGIN_SEARCH_PATHS`
#### 
 `IBC_STRIP_NIBS`
#### 
 `IBC_WARNINGS`
#### 
 `IBSC_COMPILER_AUTO_ACTIVATE_CUSTOM_FONTS`
#### 
 `IBSC_ERRORS`
#### 
 `IBSC_FLATTEN_NIBS`
#### 
 `IBSC_MODULE`
#### 
 `IBSC_NOTICES`
#### 
 `IBSC_OTHER_FLAGS`
#### 
 `IBSC_STRIP_NIBS`
#### 
 `IBSC_WARNINGS`
#### 
 `IMPLICIT_DEPENDENCY_DOMAIN`
#### 
 `INCLUDED_EXPLICIT_TARGET_DEPENDENCIES`
#### 
 `INCLUDED_RECURSIVE_SEARCH_PATH_SUBDIRECTORIES`
#### 
 `INCLUDED_SOURCE_FILE_NAMES`
#### 
 `INDEX_STORE_COMPRESS`
#### 
 `INDEX_STORE_ONLY_PROJECT_FILES`
#### 
 `INFOPLIST_EXPAND_BUILD_SETTINGS`
Expand build settings in the `Info.plist` file.
#### 
 `INFOPLIST_FILE`
The project-relative path to the property list file that contains the `Info.plist` information used by bundles.
#### 
 `INFOPLIST_KEY_CFBundleDisplayName`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_CLKComplicationPrincipalClass`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_GCSupportsControllerUserInteraction`
#### 
 `INFOPLIST_KEY_GCSupportsGameMode`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the GCSupportsGameMode key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_ITSEncryptionExportComplianceCode`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_LSApplicationCategoryType`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_LSBackgroundOnly`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_LSSupportsOpeningDocumentsInPlace`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_LSUIElement`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_MetalCaptureEnabled`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the MetalCaptureEnabled key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NFCReaderUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSAccessoryTrackingUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSAppDataUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSAppleEventsUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSAppleMusicUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSBluetoothAlwaysUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSBluetoothPeripheralUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSBluetoothWhileInUseUsageDescription`
#### 
 `INFOPLIST_KEY_NSCalendarsFullAccessUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSCalendarsUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSCalendarsWriteOnlyAccessUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSCameraUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSContactsUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSCriticalMessagingUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSDesktopFolderUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSDocumentsFolderUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSDownloadsFolderUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSFaceIDUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSFallDetectionUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSFileProviderDomainUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSFileProviderPresenceUsageDescription`
#### 
 `INFOPLIST_KEY_NSFinancialDataUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSFocusStatusUsageDescription`
#### 
 `INFOPLIST_KEY_NSGKFriendListUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSHandsTrackingUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSHealthClinicalHealthRecordsShareUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSHealthShareUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSHealthUpdateUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSHomeKitUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSHumanReadableCopyright`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSIdentityUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSLocalNetworkUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSLocationAlwaysAndWhenInUseUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSLocationAlwaysUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSLocationTemporaryUsageDescriptionDictionary`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSLocationUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSLocationWhenInUseUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSMainCameraUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSMainNibFile`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSMainStoryboardFile`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSMicrophoneUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSMotionUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSNearbyInteractionAllowOnceUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSNearbyInteractionUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSNetworkVolumesUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSPhotoLibraryAddUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSPhotoLibraryUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSPrincipalClass`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSRemindersFullAccessUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSRemindersUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSRemovableVolumesUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSSensorKitPrivacyPolicyURL`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSSensorKitUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSSiriUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSStickerSharingLevel`
#### 
 `INFOPLIST_KEY_NSSupportsLiveActivities`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSSupportsLiveActivitiesFrequentUpdates`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSSystemAdministrationUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSSystemExtensionUsageDescription`
#### 
 `INFOPLIST_KEY_NSUserTrackingUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSVideoSubscriberAccountUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_NSVoIPUsageDescription`
#### 
 `INFOPLIST_KEY_NSWorldSensingUsageDescription`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_OSBundleUsageDescription`
#### 
 `INFOPLIST_KEY_UIApplicationSceneManifest_Generation`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the Info.plist file to an entry suitable for a multi-window application.
#### 
 `INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_UILaunchScreen_Generation`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the Info.plist file to an empty dictionary.
#### 
 `INFOPLIST_KEY_UILaunchStoryboardName`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_UIMainStoryboardFile`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_UIRequiredDeviceCapabilities`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_UIRequiresFullScreen`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_UIStatusBarHidden`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_UIStatusBarStyle`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_UISupportedInterfaceOrientations`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_UISupportsDocumentBrowser`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_UIUserInterfaceStyle`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_WKCompanionAppBundleIdentifier`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_WKExtensionDelegateClassName`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_WKRunsIndependentlyOfCompanionApp`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_KEY_WKSupportsLiveActivityLaunchAttributeTypes`
#### 
 `INFOPLIST_KEY_WKWatchOnly`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `INFOPLIST_OTHER_PREPROCESSOR_FLAGS`
Other flags to pass to the C preprocessor when preprocessing the `Info.plist` file.
#### 
 `INFOPLIST_OUTPUT_FORMAT`
#### 
 `INFOPLIST_PATH`
#### 
 `INFOPLIST_PREFIX_HEADER`
#### 
 `INFOPLIST_PREPROCESS`
Preprocess the `Info.plist` file using the C Preprocessor.
#### 
 `INFOPLIST_PREPROCESSOR_DEFINITIONS`
Space-separated list of preprocessor macros of the form `foo` or `foo=bar`. These macros are used when preprocessing the `Info.plist` file.
#### 
 `INFOSTRINGS_PATH`
#### 
 `INIT_ROUTINE`
#### 
 `INLINE_PRIVATE_FRAMEWORKS`
#### 
 `INSTALLHDRS_COPY_PHASE`
Specifies whether the target’s Copy Files build phases are executed in `installhdr` builds.
#### 
 `INSTALLHDRS_SCRIPT_PHASE`
Specifies whether the target’s Run Script build phases are executed in `installhdr` builds. See `ACTION` for details on `installhdr` builds.
#### 
 `INSTALL_DIR`
#### 
 `INSTALL_GROUP`
The group name or `gid` for installed products.
#### 
 `INSTALL_MODE_FLAG`
#### 
 `INSTALL_OWNER`
The owner name or `uid` for installed products.
#### 
 `INSTALL_PATH`
The directory in which to install the build products. This path is prepended by the `DSTROOT`.
#### 
 `INTENTS_CODEGEN_LANGUAGE`
#### 
 `IS_MACCATALYST`
#### 
 `KEEP_PRIVATE_EXTERNS`
#### 
 `LAUNCH_CONSTRAINT_PARENT`
#### 
 `LAUNCH_CONSTRAINT_RESPONSIBLE`
#### 
 `LAUNCH_CONSTRAINT_SELF`
#### 
 `LD_CLIENT_NAME`
This setting passes the value with `-client_name` when linking the executable.
#### 
 `LD_DEPENDENCY_INFO_FILE`
#### 
 `LD_DYLIB_ALLOWABLE_CLIENTS`
This setting restricts the clients allowed to link a dylib by passing `-allowable_client` to the linker for each supplied value.
#### 
 `LD_DYLIB_INSTALL_NAME`
#### 
 `LD_ENVIRONMENT`
#### 
 `LD_EXPORT_SYMBOLS`
#### 
 `LD_GENERATE_MAP_FILE`
#### 
 `LD_MAP_FILE_PATH`
#### 
 `LD_NO_PIE`
#### 
 `LD_QUOTE_LINKER_ARGUMENTS_FOR_COMPILER_DRIVER`
#### 
 `LD_RUNPATH_SEARCH_PATHS`
#### 
 `LD_WARN_DUPLICATE_LIBRARIES`
#### 
 `LD_WARN_UNUSED_DYLIBS`
#### 
 `LEXFLAGS`
#### 
 `LEX_CASE_INSENSITIVE_SCANNER`
#### 
 `LEX_INSERT_LINE_DIRECTIVES`
#### 
 `LEX_SUPPRESS_DEFAULT_RULE`
#### 
 `LEX_SUPPRESS_WARNINGS`
Enabling this option causes `lex` to suppress its warning messages.
#### 
 `LIBRARY_LOAD_CONSTRAINT`
#### 
 `LIBRARY_SEARCH_PATHS`
#### 
 `LINKER_DISPLAYS_MANGLED_NAMES`
#### 
 `LINK_WITH_STANDARD_LIBRARIES`
#### 
 `LLVM_LTO`
#### 
 `LOCALIZATION_EXPORT_SUPPORTED`
#### 
 `LOCALIZATION_PREFERS_STRING_CATALOGS`
#### 
 `LOCALIZED_STRING_CODE_COMMENTS`
#### 
 `LOCALIZED_STRING_MACRO_NAMES`
#### 
 `LOCALIZED_STRING_SWIFTUI_SUPPORT`
#### 
 `MACH_O_TYPE`
#### 
 `MAPC_NO_WARNINGS`
Compile `.xcmappingmodel` files into `.cdm` without reporting warnings.
#### 
 `MARKETING_VERSION`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `MARKETPLACES`
#### 
 `MERGEABLE_LIBRARY`
#### 
 `MERGED_BINARY_TYPE`
#### 
 `MODULEMAP_FILE`
#### 
 `MODULEMAP_PRIVATE_FILE`
#### 
 `MODULES_FOLDER_PATH`
#### 
 `MODULE_CACHE_DIR`
#### 
 `MODULE_DEPENDENCIES`
#### 
 `MODULE_NAME`
#### 
 `MODULE_START`
#### 
 `MODULE_STOP`
#### 
 `MODULE_VERIFIER_SUPPORTED_LANGUAGES`
#### 
 `MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS`
#### 
 `MODULE_VERSION`
#### 
 `MOMC_NO_DELETE_RULE_WARNINGS`
Suppress managed object model compiler (`momc`) warnings for delete rules during the compilation of `.xcdatamodel(d)` files.
#### 
 `MOMC_NO_INVERSE_RELATIONSHIP_WARNINGS`
#### 
 `MOMC_NO_MAX_PROPERTY_COUNT_WARNINGS`
#### 
 `MOMC_NO_WARNINGS`
Suppress managed object model compiler (`momc`) warnings from output during the compilation of `.xcdatamodel(d)` files
#### 
 `MOMC_SUPPRESS_INVERSE_TRANSIENT_ERROR`
#### 
 `MTLLINKER_FLAGS`
#### 
 `MTL_COMPILER_FLAGS`
#### 
 `MTL_ENABLE_DEBUG_INFO`
#### 
 `MTL_ENABLE_INDEX_STORE`
#### 
 `MTL_ENABLE_MODULES`
#### 
 `MTL_FAST_MATH`
#### 
 `MTL_HEADER_SEARCH_PATHS`
#### 
 `MTL_IGNORE_WARNINGS`
#### 
 `MTL_LANGUAGE_REVISION`
#### 
 `MTL_MATH_FP32_FUNCTIONS`
#### 
 `MTL_MATH_MODE`
#### 
 `MTL_OPTIMIZATION_LEVEL`
#### 
 `MTL_PREPROCESSOR_DEFINITIONS`
#### 
 `MTL_TREAT_WARNINGS_AS_ERRORS`
#### 
 `NATIVE_ARCH`
#### 
 `OBJECT_FILE_DIR`
#### 
 `OBJROOT`
#### 
 `ONLY_ACTIVE_ARCH`
#### 
 `ON_DEMAND_RESOURCES_INITIAL_INSTALL_TAGS`
#### 
 `ON_DEMAND_RESOURCES_PREFETCH_ORDER`
#### 
 `OPENCL_ARCHS`
#### 
 `OPENCL_AUTO_VECTORIZE_ENABLE`
#### 
 `OPENCL_COMPILER_VERSION`
The `OpenCL` C compiler version supported by the platform.
#### 
 `OPENCL_DENORMS_ARE_ZERO`
#### 
 `OPENCL_DOUBLE_AS_SINGLE`
#### 
 `OPENCL_FAST_RELAXED_MATH`
This option causes the preprocessor macro `__FAST_RELAXED_MATH__` to be defined in the `OpenCL` program.
#### 
 `OPENCL_MAD_ENABLE`
#### 
 `OPENCL_OPTIMIZATION_LEVEL`
#### 
 `OPENCL_OTHER_BC_FLAGS`
#### 
 `OPENCL_PREPROCESSOR_DEFINITIONS`
Space-separated list of preprocessor macros of the form `foo` or `foo=bar`.
#### 
 `ORDER_FILE`
#### 
 `OSACOMPILE_EXECUTE_ONLY`
#### 
 `OTHER_CFLAGS`
#### 
 `OTHER_CODE_SIGN_FLAGS`
A list of additional options to pass to `codesign(1)`.
#### 
 `OTHER_CPLUSPLUSFLAGS`
#### 
 `OTHER_DOCC_FLAGS`
#### 
 `OTHER_IIG_CFLAGS`
#### 
 `OTHER_IIG_FLAGS`
#### 
 `OTHER_LDFLAGS`
#### 
 `OTHER_LIBTOOLFLAGS`
#### 
 `OTHER_MIGFLAGS`
#### 
 `OTHER_MODULE_VERIFIER_FLAGS`
#### 
 `OTHER_OSACOMPILEFLAGS`
#### 
 `OTHER_REZFLAGS`
#### 
 `OTHER_SWIFT_FLAGS`
#### 
 `OTHER_TAPI_FLAGS`
Options defined in this setting are passed to invocations of the `Text-Based InstallAPI` tool.
#### 
 `PACKAGE_TYPE`
#### 
 `PLIST_FILE_OUTPUT_FORMAT`
#### 
 `PLUGINS_FOLDER_PATH`
#### 
 `PRECOMPS_INCLUDE_HEADERS_FROM_BUILT_PRODUCTS_DIR`
#### 
 `PRELINK_FLAGS`
#### 
 `PRELINK_LIBS`
#### 
 `PRIVATE_HEADERS_FOLDER_PATH`
#### 
 `PROCESSED_INFOPLIST_PATH`
#### 
 `PRODUCT_BUNDLE_IDENTIFIER`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `PRODUCT_DEFINITION_PLIST`
#### 
 `PRODUCT_MODULE_NAME`
#### 
 `PRODUCT_NAME`
When `GENERATE_INFOPLIST_FILE` is enabled, sets the value of the  key in the `Info.plist` file to the value of this build setting.
#### 
 `PROJECT_NAME`
#### 
 `PROJECT_TEMP_DIR`
#### 
 `PROVISIONING_PROFILE_SPECIFIER`
#### 
 `PUBLIC_HEADERS_FOLDER_PATH`
#### 
 `REEXPORTED_FRAMEWORK_NAMES`
#### 
 `REEXPORTED_LIBRARY_NAMES`
#### 
 `REEXPORTED_LIBRARY_PATHS`
#### 
 `REFERENCEOBJECT_STRIP_USDZ`
#### 
 `REGISTER_APP_GROUPS`
#### 
 `REMOVE_CVS_FROM_RESOURCES`
Specifies whether to remove `CVS` directories from bundle resources when they are copied.
#### 
 `REMOVE_GIT_FROM_RESOURCES`
Specifies whether to remove `.git` directories from bundle resources when they are copied.
#### 
 `REMOVE_HG_FROM_RESOURCES`
Specifies whether to remove `.hg` directories from bundle resources when they are copied.
#### 
 `REMOVE_SVN_FROM_RESOURCES`
Specifies whether to remove `SVN` directories from bundle resources when they are copied.
#### 
 `RESMERGER_SOURCES_FORK`
#### 
 `RESOURCES_TARGETED_DEVICE_FAMILY`
Overrides `TARGETED_DEVICE_FAMILY` when the resource copying needs to differ from the default targeted device.
#### 
 `RETAIN_RAW_BINARIES`
#### 
 `REZ_COLLECTOR_DIR`
Specifies the directory in which the collected Resource Manager resources generated by `ResMerger` are stored before they are added to the product.
#### 
 `REZ_OBJECTS_DIR`
Specifies the directory in which compiled Resource Manager resources generated by `Rez` are stored before they are collected using `ResMerger`.
#### 
 `REZ_PREFIX_FILE`
#### 
 `REZ_PREPROCESSOR_DEFINITIONS`
#### 
 `REZ_PREPROCESSOR_UNDEFINITIONS`
#### 
 `REZ_RESOLVE_ALIASES`
#### 
 `REZ_RESOURCE_MAP_READ_ONLY`
#### 
 `REZ_SCRIPT_TYPE`
#### 
 `REZ_SEARCH_PATHS`
#### 
 `REZ_SHOW_DEBUG_OUTPUT`
#### 
 `REZ_SUPPRESS_REDECLARED_RESOURCE_TYPE_WARNINGS`
#### 
 `RUNTIME_EXCEPTION_ALLOW_DYLD_ENVIRONMENT_VARIABLES`
#### 
 `RUNTIME_EXCEPTION_ALLOW_JIT`
#### 
 `RUNTIME_EXCEPTION_ALLOW_UNSIGNED_EXECUTABLE_MEMORY`
#### 
 `RUNTIME_EXCEPTION_DEBUGGING_TOOL`
#### 
 `RUNTIME_EXCEPTION_DISABLE_EXECUTABLE_PAGE_PROTECTION`
#### 
 `RUNTIME_EXCEPTION_DISABLE_LIBRARY_VALIDATION`
#### 
 `RUN_CLANG_STATIC_ANALYZER`
Activating this setting will cause Xcode to run the `Clang` static analysis tool on qualifying source files during every build.
#### 
 `RUN_DOCUMENTATION_COMPILER`
#### 
 `SCAN_ALL_SOURCE_FILES_FOR_INCLUDES`
#### 
 `SCRIPTS_FOLDER_PATH`
#### 
 `SDKROOT`
#### 
 `SECTORDER_FLAGS`
These flags are typically used to specify options for ordering symbols within segments, for example the `-sectorder` option to `ld`.
#### 
 `SEPARATE_SYMBOL_EDIT`
#### 
 `SHARED_FRAMEWORKS_FOLDER_PATH`
#### 
 `SHARED_PRECOMPS_DIR`
#### 
 `SKIP_INSTALL`
#### 
 `SKIP_MERGEABLE_LIBRARY_BUNDLE_HOOK`
#### 
 `SRCROOT`
#### 
 `STRINGSDATA_DIR`
#### 
 `STRINGSDATA_ROOT`
#### 
 `STRINGS_FILE_INFOPLIST_RENAME`
#### 
 `STRINGS_FILE_OUTPUT_ENCODING`
#### 
 `STRING_CATALOG_GENERATE_SYMBOLS`
#### 
 `STRIPFLAGS`
#### 
 `STRIP_INSTALLED_PRODUCT`
#### 
 `STRIP_PNG_TEXT`
#### 
 `STRIP_STYLE`
#### 
 `STRIP_SWIFT_SYMBOLS`
#### 
 `SUPPORTED_PLATFORMS`
#### 
 `SUPPORTS_MACCATALYST`
#### 
 `SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD`
#### 
 `SUPPORTS_TEXT_BASED_API`
Enable to indicate that the target supports `Text-Based InstallAPI`, which will enable its generation during `install` builds.
#### 
 `SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD`
#### 
 `SWIFT_ACTIVE_COMPILATION_CONDITIONS`
#### 
 `SWIFT_APPROACHABLE_CONCURRENCY`
#### 
 `SWIFT_BRIDGING_HEADER_IS_INTERNAL`
#### 
 `SWIFT_COMPILATION_MODE`
#### 
 `SWIFT_DEFAULT_ACTOR_ISOLATION`
#### 
 `SWIFT_DISABLE_SAFETY_CHECKS`
#### 
 `SWIFT_EMIT_CONST_VALUE_PROTOCOLS`
#### 
 `SWIFT_EMIT_LOC_STRINGS`
#### 
 `SWIFT_ENABLE_BARE_SLASH_REGEX`
Enables the use of the forward slash syntax for regular-expressions (`/.../`). This is always enabled when in the Swift 6 language mode.
#### 
 `SWIFT_ENABLE_EMIT_CONST_VALUES`
#### 
 `SWIFT_ENABLE_EXPLICIT_MODULES`
#### 
 `SWIFT_ENFORCE_EXCLUSIVE_ACCESS`
#### 
 `SWIFT_INCLUDE_PATHS`
#### 
 `SWIFT_INSTALL_MODULE`
#### 
 `SWIFT_INSTALL_OBJC_HEADER`
#### 
 `SWIFT_MODULES_AUTOLINK`
Automatically link frameworks and libraries that are referenced using `import`.
#### 
 `SWIFT_OBJC_BRIDGING_HEADER`
#### 
 `SWIFT_OBJC_INTERFACE_HEADER_NAME`
Name to use for the header that is generated by the Swift compiler for use in `#import` statements in Objective-C or C++.
#### 
 `SWIFT_OBJC_INTEROP_MODE`
#### 
 `SWIFT_OPTIMIZATION_LEVEL`
#### 
 `SWIFT_PACKAGE_NAME`
#### 
 `SWIFT_PRECOMPILE_BRIDGING_HEADER`
#### 
 `SWIFT_REFLECTION_METADATA_LEVEL`
#### 
 `SWIFT_SKIP_AUTOLINKING_ALL_FRAMEWORKS`
When enabled, does not automatically link any frameworks which are referenced using `import`.
#### 
 `SWIFT_SKIP_AUTOLINKING_FRAMEWORKS`
A list of framework names which should not be automatically linked when referenced using `import`.
#### 
 `SWIFT_SKIP_AUTOLINKING_LIBRARIES`
A list of library names which should not be automatically linked when referenced using `import`.
#### 
 `SWIFT_STRICT_CONCURRENCY`
#### 
 `SWIFT_STRICT_MEMORY_SAFETY`
#### 
 `SWIFT_SUPPRESS_WARNINGS`
#### 
 `SWIFT_SYSTEM_INCLUDE_PATHS`
#### 
 `SWIFT_TREAT_WARNINGS_AS_ERRORS`
#### 
 `SWIFT_UPCOMING_FEATURE_CONCISE_MAGIC_FILE`
#### 
 `SWIFT_UPCOMING_FEATURE_DEPRECATE_APPLICATION_MAIN`
#### 
 `SWIFT_UPCOMING_FEATURE_DISABLE_OUTWARD_ACTOR_ISOLATION`
#### 
 `SWIFT_UPCOMING_FEATURE_DYNAMIC_ACTOR_ISOLATION`
#### 
 `SWIFT_UPCOMING_FEATURE_EXISTENTIAL_ANY`
Changes existential types to require explicit annotation with the `any` keyword.
#### 
 `SWIFT_UPCOMING_FEATURE_FORWARD_TRAILING_CLOSURES`
#### 
 `SWIFT_UPCOMING_FEATURE_GLOBAL_ACTOR_ISOLATED_TYPES_USABILITY`
#### 
 `SWIFT_UPCOMING_FEATURE_GLOBAL_CONCURRENCY`
#### 
 `SWIFT_UPCOMING_FEATURE_IMPLICIT_OPEN_EXISTENTIALS`
#### 
 `SWIFT_UPCOMING_FEATURE_IMPORT_OBJC_FORWARD_DECLS`
#### 
 `SWIFT_UPCOMING_FEATURE_INFER_ISOLATED_CONFORMANCES`
Infer conformances of global-actor isolated types as isolated to the same actor unless isolation is explicitly specified as `nonisolated`.
#### 
 `SWIFT_UPCOMING_FEATURE_INFER_SENDABLE_FROM_CAPTURES`
#### 
 `SWIFT_UPCOMING_FEATURE_INTERNAL_IMPORTS_BY_DEFAULT`
Switches the default accessibility of module imports to `internal` rather than `public`.
#### 
 `SWIFT_UPCOMING_FEATURE_ISOLATED_DEFAULT_VALUES`
#### 
 `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY`
#### 
 `SWIFT_UPCOMING_FEATURE_NONFROZEN_ENUM_EXHAUSTIVITY`
Enable errors when switching over nonfrozen enums without an `@unknown default` case. This is always enabled when in the Swift 6 language mode.
#### 
 `SWIFT_UPCOMING_FEATURE_NONISOLATED_NONSENDING_BY_DEFAULT`
Runs nonisolated async functions on the caller’s actor by default unless the function is explicitly marked `@concurrent`.
#### 
 `SWIFT_UPCOMING_FEATURE_REGION_BASED_ISOLATION`
#### 
 `SWIFT_VERSION`
#### 
 `SWIFT_WARNINGS_AS_ERRORS_GROUPS`
#### 
 `SWIFT_WARNINGS_AS_WARNINGS_GROUPS`
#### 
 `SYMBOL_GRAPH_EXTRACTOR_MODULE_NAME`
#### 
 `SYMBOL_GRAPH_EXTRACTOR_OUTPUT_DIR`
#### 
 `SYMROOT`
#### 
 `SYSTEM_FRAMEWORK_SEARCH_PATHS`
#### 
 `SYSTEM_HEADER_SEARCH_PATHS`
#### 
 `TAPI_DEMANGLE`
Display demangled symbols when building `Text-Based InstallAPI`.
#### 
 `TAPI_ENABLE_PROJECT_HEADERS`
Include project-level headers when building `Text-Based InstallAPI`.
#### 
 `TAPI_EXCLUDE_PRIVATE_HEADERS`
Remove private-level headers from target when building `Text-Based InstallAPI`.
#### 
 `TAPI_EXCLUDE_PROJECT_HEADERS`
Remove project-level headers from target when building `Text-Based InstallAPI`.
#### 
 `TAPI_EXCLUDE_PUBLIC_HEADERS`
Remove public-level headers from target when building `Text-Based InstallAPI`.
#### 
 `TAPI_EXTRA_PRIVATE_HEADERS`
Add private-level headers from other targets when building `Text-Based InstallAPI`.
#### 
 `TAPI_EXTRA_PROJECT_HEADERS`
Add project-level headers from other targets when building `Text-Based InstallAPI`.
#### 
 `TAPI_EXTRA_PUBLIC_HEADERS`
Add public-level headers from other targets when building `Text-Based InstallAPI`.
#### 
 `TAPI_LANGUAGE`
Selects the language mode when building `Text-Based InstallAPI`.
#### 
 `TAPI_LANGUAGE_STANDARD`
Selects the language dialect when building `Text-Based InstallAPI`.
#### 
 `TAPI_VERIFY_MODE`
Selects the level of warnings and errors to report when building `Text-Based InstallAPI`.
#### 
 `TARGETED_DEVICE_FAMILY`
#### 
 `TARGET_BUILD_DIR`
#### 
 `TARGET_NAME`
#### 
 `TARGET_TEMP_DIR`
#### 
 `TEST_HOST`
#### 
 `TREAT_MISSING_BASELINES_AS_TEST_FAILURES`
When running tests that measure performance via `XCTestCase`, report missing baselines as test failures.
#### 
 `TREAT_MISSING_SCRIPT_PHASE_OUTPUTS_AS_ERRORS`
#### 
 `UNEXPORTED_SYMBOLS_FILE`
A project-relative path to a file that lists the symbols not to export. See `ld -exported_symbols_list` for details on exporting symbols.
#### 
 `UNLOCALIZED_RESOURCES_FOLDER_PATH`
#### 
 `USER_HEADER_SEARCH_PATHS`
#### 
 `USE_HEADERMAP`
#### 
 `VALIDATE_PRODUCT`
#### 
 `VERBOSE_PBXCP`
#### 
 `VERSIONING_SYSTEM`
#### 
 `VERSION_INFO_BUILDER`
#### 
 `VERSION_INFO_EXPORT_DECL`
#### 
 `VERSION_INFO_FILE`
#### 
 `VERSION_INFO_PREFIX`
#### 
 `VERSION_INFO_SUFFIX`
#### 
 `WARNING_CFLAGS`
#### 
 `WRAPPER_EXTENSION`
#### 
 `WRAPPER_NAME`
#### 
 `WRAPPER_SUFFIX`
#### 
 `YACCFLAGS`
#### 
 `YACC_GENERATED_FILE_STEM`
#### 
 `YACC_GENERATE_DEBUGGING_DIRECTIVES`
Enabling this option changes the preprocessor directives generated by `yacc` so that debugging statements will be incorporated in the compiled code.
#### 
 `YACC_INSERT_LINE_DIRECTIVES`

## Bundling resources with a Swift package
> https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package

### 
#### 
- Core Data files; for example, `xcdatamodeld` files
- `.lproj` folders you use to provide localized resources
#### 
To add a resource that Xcode can’t handle automatically, explicitly declare it as a resource in your package manifest. The following example assumes that `text.txt` resides in `Sources/MyLibrary` and you want to include it in the `MyLibrary` target. To explicitly declare it as a package resource, you pass its file name to the target’s initializer in your package manifest:
```swift
targets: [
    .target(
        name: "MyLibrary",
        resources: [
            .process("text.txt")]
    ),
]
```

Note how the example code above uses the  function. When you explicitly declare a resource, you must choose one of these rules to determine how Xcode treats the resource file:
If a file resides inside a target’s folder and you don’t want it to be a package resource, pass it to the target initializer’s `exclude` parameter. The next example assumes that `instructions.md` is a Markdown file that contains documentation, resides at `Sources/MyLibrary` and shouldn’t be part of the package’s resource bundle. This code shows how you can exclude the file from the target by adding it to the list of excluded files:
```swift
targets: [
    .target(
        name: "MyLibrary",
        exclude:["instructions.md"]
    ),
]
```

#### 
`let settingsURL = Bundle.module.url(forResource: "settings", withExtension: "plist")`
> **important:** Always use `Bundle.module` when you access resources. A package shouldn’t make assumptions about the exact location of a resource.
`public let settingsURL = Bundle.module.url(forResource: "settings", withExtension: "plist")`

## Capturing a Metal workload programmatically
> https://developer.apple.com/documentation/xcode/capturing-a-metal-workload-programmatically

### 
#### 
Alternatively, in macOS 14 and later, you can set the environment variable on your Metal app: `MTL_CAPTURE_ENABLED=1`.
#### 
Create an  object that defines which commands you want to record and what needs to happen after the capture is complete. To capture commands for a specific  or , set the capture descriptor’s  property to point at the specific object to track, and call the  method. To stop capturing commands, call the  method.
```swift
func triggerProgrammaticCapture(device: MTLDevice) {
    let captureManager = MTLCaptureManager.shared()
    let captureDescriptor = MTLCaptureDescriptor()
    captureDescriptor.captureObject = self.device
    do {
        try captureManager.startCapture(with: captureDescriptor)
    } catch {
        fatalError("error when trying to capture: \(error)")
    }
}

func runMetalCommands(commandQueue: MTLCommandQueue) {
    let commandBuffer = commandQueue.makeCommandBuffer()!
    // Do Metal work.
    commandBuffer.commit()
    let captureManager = MTLCaptureManager.shared()
    captureManager.stopCapture()
}
```

#### 
> **important:** Set the file extension of the `outputURL` to `.gputrace` to ensure that you can replay it later in the Metal debugger. For more information on replaying GPU trace files, see .
```swift
func setupProgrammaticCaptureScope(device: MTLDevice) {
    myCaptureScope = MTLCaptureManager.shared().makeCaptureScope(device: device)
    myCaptureScope?.label = "My Capture Scope"
}

func triggerProgrammaticCaptureScope() {
    guard let captureScope = myCaptureScope else { return }
    let captureManager = MTLCaptureManager.shared()
    let captureDescriptor = MTLCaptureDescriptor()
    captureDescriptor.captureObject = captureScope
    do {
        try captureManager.startCapture(with: captureDescriptor)
    } catch {
        fatalError("error when trying to capture: \(error)")
    }
}
```

```
To define boundaries for the scoped capture, call the  object’s  and  methods just before and after the commands that you want to capture. Xcode automatically stops capturing when your app reaches the corresponding `end()` method of the capture scope.
```swift
func runMetalCommands(commandQueue: MTLCommandQueue) {
    myCaptureScope?.begin()
    let commandBuffer = commandQueue.makeCommandBuffer()!
    // Do Metal work.
    commandBuffer.commit()
    myCaptureScope?.end()
}
```

#### 
If you want to analyze the capture later, you can skip launching the Metal debugger and save the GPU command information to a GPU trace file. Call  on the capture manager to make sure the feature is available before attempting to record a trace file.
```swift
let captureManager = MTLCaptureManager.shared()

guard captureManager.supportsDestination(.gpuTraceDocument) else {
    print("Capturing to a GPU trace file isn't supported.")
    return
}
```

Then, set the capture descriptor’s destination property to `MTLCaptureDestination.gpuTraceDocument` and specify the file’s destination.
```
Then, set the capture descriptor’s destination property to `MTLCaptureDestination.gpuTraceDocument` and specify the file’s destination.
```swift
let captureDescriptor = MTLCaptureDescriptor()
captureDescriptor.captureObject = self.device
captureDescriptor.destination = .gpuTraceDocument
captureDescriptor.outputURL = self.traceURL
...
```


## Configuring Family Controls
> https://developer.apple.com/documentation/xcode/configuring-family-controls

### 
#### 
#### 
When you add the Family Controls capability, Xcode automatically updates your app target’s entitlements file to include the `com.apple.developer.family-controls` entitlement key set to `true`:
```None
<plist>
    <dict>
        <key>com.apple.developer.family-controls</key>
        <true/>
    </dict>
</plist>
```

#### 
#### 

## Configuring a multiplatform app
> https://developer.apple.com/documentation/xcode/configuring-a-multiplatform-app-target

### 
#### 
#### 
#### 
#### 
 If a framework isn’t available for a platform, surround the import with a `canImport` conditional statement:
Xcode identifies this sort of build-time issue when you build your project. To try a build on a new platform, pick the new run destination in the scheme menu that corresponds with the platform you added. If Xcode identifies any issues, navigate to them one-by-one and use the following steps to resolve them.
 If a framework isn’t available for a platform, surround the import with a `canImport` conditional statement:
```swift
#if canImport(ARKit)
import ARKit
#endif
```

```
 Frameworks that are available across multiple platforms might have individual symbols likes types, methods, or enumeration cases that are restricted to a subset of platforms. To resolve these availability issues, surround the relevant code with an `#if os` platform compilation condition statement:
```swift
Toggle(isOn: $isOn) {
    Text("Show Holidays calendar")
}
#if os(macOS)
.toggleStyle(.checkbox)
#endif
```

#### 
Ensure that your app’s user interface and experience fit the needs of each platform by adding platform-specific views and features. For example, some Mac apps include a menu bar extra that appears even when the app isn’t the frontmost app. The following adds a `MenuBarExtra` instance only in the macOS version of a scene:
```swift
var body: some Scene {
    WindowGroup {
        PrimaryView()
    }
    #if os(macOS)
    MenuBarExtra("Inspect", systemImage: "eyedropper") {
        VStack {
            Button("Action One") {
                // ...
            }
            Button("Action Two") {
                // ...
            }
        }
    }
    #endif
}
```


## Configuring an associated domain
> https://developer.apple.com/documentation/xcode/configuring-an-associated-domain

### 
#### 
6. Double-click the inserted placeholder to edit it.
Update the placeholder to contain the service your app supports and its associated domain, which must be in the following format:
```None
<service>:<fully qualified domain>
```

> **tip:** For services other than App Clips, prefix a domain with `*.` to include all of its subdomains.
| `webcredentials` | If your domain supports shared web credentials, see  for more information. |
| `authsrv` | If your domain needs to authenticate people, see  for more information. |
| `applinks` | If your domain supports universal links, see  for more information. |
| `activitycontinuation` | If your domain supports Handoff, see  for more information. |
| `appclips` | If your domain supports App Clips, see  for more information. |
#### 
#### 
6. Append the string `?mode=<alternate mode>` to the associated domain. Replace `<alternate mode>` with one of the modes shown in the list below.
| `developer+managed` | The domain is accessible only from devices that are in both `developer` and `managed` modes. |

## Configuring command-line tools settings
> https://developer.apple.com/documentation/xcode/configuring-command-line-tools-settings

### 
#### 
To identify the default Xcode app for command-line tools, choose Xcode > Settings, and click Locations in the sidebar. The Command Line Tools section of the Locations pane displays both the Xcode version number and the location of the file. 
Alternatively, you can identify the Xcode version from the command line. Enter `xcode-select` with the `--print-path` option in Terminal. This command returns the path of the active developer directory for Xcode. For example, the following command prints the path of the developer directory containing a version of Xcode:
```None
% xcode-select --print-path
/Applications/Xcode.app/Contents/Developer
```

```
If you install the Command Line Tools for Xcode package and set it as the active directory, the command `xcode-select --print-path` returns the package path, like in the following example:
```None
% xcode-select --print-path
/Library/Developer/CommandLineTools
```

```
If you have no active developer directory on your macOS computer, this command prints the following message:
```None
% xcode-select --print-path
xcode-select: error: Unable to get active developer directory. Use 
sudo `xcode-select --switch <path/to/>Xcode.app` to set one 
(or see man xcode-select)
```

#### 
 Enter your administrator password when the system prompts you to confirm the change.
Alternatively, you can set the default Xcode app for command-line tools in Terminal, using the `xcode-select` command. Enter `xcode-select` with the `--switch` option in Terminal:
```None
% sudo xcode-select --switch <path>
```

For example, the following command selects a beta version of Xcode:
```None
% sudo xcode-select --switch /Applications/Xcode-beta.app
```

```
To select the Command Line Tools for Xcode package, run the following command:
```None
% sudo xcode-select --switch /Library/Developer/CommandLineTools
```

#### 
If you want to keep the default Xcode app for the command-line tools and use a command from a different version of Xcode, set the `DEVELOPER_DIR` environment variable when you invoke the command in Terminal:
```None
% env DEVELOPER_DIR="<path>" <command>
```

The environment variable overrides the active developer directory and doesn’t require superuser permissions. It takes the path of the developer directory of the Xcode app or the Command Line Tools for Xcode package you want to use.
For example, the following command gathers a sysdiagnose from a connected device and saves it at a specific location:
```None
% env DEVELOPER_DIR="/Applications/Xcode-beta.app" xcrun devicectl device sysdiagnose --device "Work iPad" --destination ~/Downloads --gather-full-logs 

```


## Configuring webhooks in Xcode Cloud
> https://developer.apple.com/documentation/xcode/configuring-webhooks-in-xcode-cloud

### 
#### 
#### 
#### 
For more information on webhook payloads, see .
The following code snippet shows the payload Xcode Cloud sends with a request:
```json
{
    "webhook": {
        "id": "12345678-abcd-1234-5678-a12345bc4567",
        "name": "Issue Tracker",
        "url": "https://issues.example.com/webhooks"
    },
    "metadata" : {
        "type" : "metadata",
        "attributes" : {
            "createdDate" : "2021-06-07T10:00:00.000000-07:00",
            "eventType" : "BUILD_COMPLETED"
        }
    },
    "app": {
        "id": "12345678-abcd-1234-5678-a12345bc4567",
        "type": "apps"
    },
    "ciWorkflow": {
        "id": "12345678-abcd-1234-5678-a12345bc4567",
        "type": "ciWorkflows",
        "attributes": {
            "name": "Pull Requests",
            "description": "Starts Builds from Pull Requests.",
            "isEnabled": true,
            "isLockedForEditing": false
        }
    },
    "ciProduct": {
        "id": "12345678-abcd-1234-5678-a12345bc4567",
        "type": "ciProducts",
        "attributes": {
            "name": "Example App",
            "createdDate": "2021-06-07T10:00:00.000000-07:00",
            "productType": "APP"
        }
    },
    "ciBuildRun": {
        "id": "12345678-abcd-1234-5678-a12345bc4567",
        "type": "ciBuildRuns",
        "attributes": {
            "number": 12,
            "createdDate": "2021-06-07T10:00:00.000000-07:00",
            "sourceCommit": {
                "commitSha": "0123456789abcdefghij01234567890abcdefghi",
                "author": {
                    "displayName": "Anne Johnson"
                },
                "committer": {
                    "displayName": "Anne Johnson"
                },
                "htmlUrl": "https://example.com/commit/abcdef1234567890"
            },
            "destinationCommit": {
                "commitSha": "abcdefghij01234567890abcdefghi0123456789",
                "author": {
                    "displayName": "Juan Chavez"
                },
                "committer": {
                    "displayName": "Juan Chavez"
                },
                "htmlUrl": "https://example.com/commit/abcdef1234567890"
            },
            "isPullRequestBuild": true,
            "executionProgress": "COMPLETE",
            "completionStatus": "SUCCEEDED"
        }
    },
    "ciBuildActions": [{
        "id": "12345678-abcd-1234-5678-a12345bc4567",
        "type": "ciBuildActions",
        "attributes": {
            "name": "analyze",
            "actionType": "ANALYZE",
            "issueCounts": {
                "analyzerWarnings": 10,
                "errors": 0,
                "testFailures": 0,
                "warnings": 0
            },
            "executionProgress": "COMPLETE",
            "completionStatus": "SUCCEEDED",
            "isRequiredToPass": false
        },
        "relationships": {}
    }, {
        "id": "12345678-abcd-1234-5678-a12345bc4567",
        "type": "ciBuildActions",
        "attributes": {
            "name": "build",
            "actionType": "ARCHIVE",
            "issueCounts": {
                "analyzerWarnings": 0,
                "errors": 0,
                "testFailures": 0,
                "warnings": 3
            },
            "executionProgress": "COMPLETE",
            "completionStatus": "SUCCEEDED",
            "isRequiredToPass": true
        },
        "relationships": {
            "builds": {
                "id": "12345678-abcd-1234-5678-a12345bc4567",
                "type": "builds",
                "attributes": {
                    "platform": "IOS"
                }
            }
        }
    }],
    "scmProvider": {
        "type": "scmProviders",
        "attributes": {
            "scmProviderType": {
                "scmProviderType": "GITHUB_CLOUD",
                "displayName": "GitHub",
                "isOnPremise": false
            },
            "endpoint": "https://github.com/example/example.git"
        }
    },
    "scmRepository": {
        "id": "12345678-abcd-1234-5678-a12345bc4567",
        "type": "scmRepositories",
        "attributes": {
            "httpCloneUrl": "https://github.com/example/test.git",
            "sshCloneUrl": "ssh://git@github.com/example/test.git",
            "ownerName": "example",
            "repositoryName": "example app"
        }
    },
    "scmPullRequest": {
        "id": "12345678-abcd-1234-5678-a12345bc4567",
        "type": "scmPullRequests",
        "attributes": {
            "title": "Add accessibility labels.",
            "number": 123,
            "htmlUrl": "https://example.com/example/example-app/pull/123",
            "sourceRepositoryOwner": "example",
            "sourceRepositoryName": "example source repository name",
            "sourceBranchName": "annejohnson/new-features",
            "destinationRepositoryOwner": "example",
            "destinationRepositoryName": "example destination repository name",
            "destinationBranchName": "main",
            "isClosed": false,
            "isCrossRepository": false
        }
    },
    "scmGitReference": {
        "id": "12345678-abcd-1234-5678-a12345bc4567",
        "type": "scmGitReferences",
        "attributes": {
            "name": "annejohnson/new-feature",
            "canonicalName": "refs/heads/annejohnson/new-feature",
            "isDeleted": false,
            "kind": "BRANCH"
        }
    }
}
```


## Configuring your app to use alternate app icons
> https://developer.apple.com/documentation/xcode/configuring-your-app-to-use-alternate-app-icons

### 
#### 
#### 
Alternatively, you can use a build configuration file to specify alternate app icons. Add a build configuration file to your Xcode project, then add the `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES` build setting to the configuration file. Set `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES` to a list of strings matching the alternate app icons’ names.
```None
ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES = AppIcon-Green AppIcon-Blue AppIcon-Orange AppIcon-Pink AppIcon-Purple AppIcon-Teal AppIcon-Yellow
```

#### 
When people select an alternate icon in the app interface, the app calls  with the name of the new icon. This tells the system to display the new icon for this app. The system automatically displays an alert notifying people of the change. Passing `nil` displays the app’s primary icon.
```swift
UIApplication.shared.setAlternateIconName(iconName) { error in
    if let error {
        self.logger.error("Failed request to update the app’s icon: \(error)")
    }
}

```


## Configuring your first Xcode Cloud workflow
> https://developer.apple.com/documentation/xcode/configuring-your-first-xcode-cloud-workflow

### 
#### 
#### 
To find out which of your project’s schemes use the archive action, run the following command in Terminal:
```bash
xcodebuild -project Example.xcodeproj -describeAllArchivableProducts -json
```

#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 

## Creating a multiplatform binary framework bundle
> https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle

### 
#### 
#### 
Create an archive of your framework or library for each platform you wish to support by running `xcodebuild` in Terminal using the `archive` build action.
The following command archives a framework for the iOS platform:
```None
xcodebuild archive 
    -project MyFramework.xcodeproj
    -scheme MyFramework
    -destination "generic/platform=iOS"
    -archivePath "archives/MyFramework"
```

To see an extensive list of all the command options, execute `xcodebuild` with the `-help` flag.
#### 
To package the built content of a given framework or library for multiple platforms and variants into a single XCFramework bundle, execute `xcodebuild` with the `-create-xcframework` option.
The following command creates an XCFramework with variants for iOS, iOS Simulator, macOS, and Mac Catalyst:
```None
xcodebuild -create-xcframework
    -archive archives/MyFramework-iOS.xcarchive -framework MyFramework.framework
    -archive archives/MyFramework-iOS_Simulator.xcarchive -framework MyFramework.framework
    -archive archives/MyFramework-macOS.xcarchive -framework MyFramework.framework
    -archive archives/MyFramework-Mac_Catalyst.xcarchive -framework MyFramework.framework
    -output xcframeworks/MyFramework.xcframework
```

To include a static library file (`.a` file), replace `-framework` with `-library` in the command above.
To include a static library file (`.a` file), replace `-framework` with `-library` in the command above.
If the content you wish to include exists outside of an archive, provide paths for the instances of `-framework` or `-library` and include paths to headers using the additional `-headers` flag.
```None
xcodebuild -create-xcframework
    -library products/iOS/usr/local/lib/libMyLibrary.a -headers products/iOS/usr/local/include
    -library products/iOS_Simulator/usr/local/lib/libMyLibrary.a -headers products/iOS/usr/local/include
    -library products/macOS/usr/local/lib/libMyLibrary.a -headers products/macOS/usr/local/include
    -library products/Mac\ Catalyst/usr/local/lib/libMyLibrary.a -headers products/Mac\ Catalyst/usr/local/include
    -output xcframeworks/MyLibrary.xcframework
```

```
To see all the options the XCFramework utility supports, execute:
```None
xcodebuild -create-xcframework -help
```

#### 
Signing your XCFramework using your code signing identity informs developers who use your framework that it came from you and that it hasn’t been tampered with since you added the signature. To sign your framework, run the following command:
```None
% codesign --timestamp -s <identity> xcframeworks/MyLibrary.xcframework
```

#### 
- Specify the path to each of the binaries you create in a call to `xcodebuild -create-xcframework` to generate the XCFramework.
#### 
To determine the architectures an existing binary includes, execute `file` from Terminal and provide the path to the binary.
Projects that link to your XCFramework require that it contains universal binaries covering the architectures each platform builds for.
To determine the architectures an existing binary includes, execute `file` from Terminal and provide the path to the binary.
```None
file <PathToFramework>/<FrameworkName>.framework/<FrameworkName>
```

file <PathToFramework>/<FrameworkName>.framework/<FrameworkName>
```
```None
file <PathToLibrary>/libMyLibrary.a
```


## Creating a standalone Swift package with Xcode
> https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode

### 
#### 
- The `README.md` file resides at the root level of the package. It describes the functionality of your Swift package.
#### 
Swift packages don’t use `.xcodeproj` or `.xcworkspace` but rely on their folder structure and use the package manifest for additional configuration. The following code listing shows a simple package manifest. It declares the MyLibrary target, and vends it as a library product with the same name.
```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MyLibrary",
    platforms: [
        .macOS(.v10_14), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MyLibrary",
            targets: ["MyLibrary", "SomeRemoteBinaryPackage", "SomeLocalBinaryPackage"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MyLibrary",
            exclude: ["instructions.md"],
            resources: [
                .process("text.txt"),
                .process("example.png"),
                .copy("settings.plist")
            ]
        ),
        .binaryTarget(
            name: "SomeRemoteBinaryPackage",
            url: "https://url/to/some/remote/binary/package.zip",
            checksum: "The checksum of the XCFramework inside the ZIP archive."
        ),
        .binaryTarget(
            name: "SomeLocalBinaryPackage",
            path: "path/to/some.xcframework"
        )
        .testTarget(
            name: "MyLibraryTests",
            dependencies: ["MyLibrary"]),
    ]
)
```

The package manifest must begin with the string `// swift-tools-version:`, followed by a version number such as `// swift-tools-version:5.3`.
To learn more about the `PackageDescription` framework, see .
#### 
#### 
Just like apps, Swift packages can have . To declare a dependency on a remote package, use one of the functions that take the URL of the remote package as a parameter. To add a local package as a dependency, use one of the functions that take a path to the local package as a parameter. The following code snipped shows both options:
```swift
dependencies: [    
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://url/of/another/package.git", from: "1.0.0"),
    .package(path: "path/to/a/local/package/", "1.0.0"..<"2.0.0")],
```

#### 
#### 
#### 
While Swift packages are platform-independent by nature and include, for example, Linux as a target platform, Swift packages can be platform-specific. Use conditional compilation blocks to handle platform-specific code and achieve cross-platform compatibility. The following example shows how to use conditional compilation blocks:
```swift
#if os(Linux)

// Code specific to Linux

#elseif os(macOS)

// Code specific to macOS

#endif

#if canImport(UIKit)

// Code specific to platforms where UIKit is available

#endif
```

```
In addition, you may need to define a minimum deployment target. Note how the package manifest below declares minimum deployment targets by passing them in as a value to the `platforms` parameter of the  initializer. However, passing minimum deployment targets to the initializer doesn’t restrict the package to the listed platforms.
```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MyLibrary",
    platforms: [
        .macOS(.v10_14), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MyLibrary",
            targets: ["MyLibrary", "SomeRemoteBinaryPackage", "SomeLocalBinaryPackage"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MyLibrary",
            exclude: ["instructions.md"],
            resources: [
                .process("text.txt"),
                .process("example.png"),
                .copy("settings.plist")
            ]
        ),
        .binaryTarget(
            name: "SomeRemoteBinaryPackage",
            url: "https://url/to/some/remote/binary/package.zip",
            checksum: "The checksum of the XCFramework inside the ZIP archive."
        ),
        .binaryTarget(
            name: "SomeLocalBinaryPackage",
            path: "path/to/some.xcframework"
        )
        .testTarget(
            name: "MyLibraryTests",
            dependencies: ["MyLibrary"]),
    ]
)
```

#### 

## Creating and using custom capture scopes
> https://developer.apple.com/documentation/xcode/creating-and-using-custom-capture-scopes

### 
#### 
Call  on your capture scope to instruct the Metal debugger to record your app’s subsequent Metal activity. To stop recording a frame and to present the Metal debugger, call .
```swift
// Create myCaptureScope outside of your rendering loop.
myCaptureScope.begin()

if let commandBuffer = commandQueue.makeCommandBuffer() {
    // Do Metal work.
    commandBuffer.commit()
}

myCaptureScope.end()
```

#### 
To identify your custom capture scope when capturing a trace from the Metal Capture popover, set your capture scope’s label property.
```swift
myCaptureScope.label = "My Capture Scope"
```

#### 
When you perform a capture from Xcode, it defaults to the capture scope that  specifies. If the value of this property is `nil`, Xcode defines the default capture scope using drawable presentation boundaries; for example, using your calls to the methods  or .
To change the default scope, create an  instance and assign it to .
```swift
MTLCaptureManager.shared().defaultCaptureScope = myCaptureScope
```


## Creating custom modelers for intelligent instruments
> https://developer.apple.com/documentation/xcode/creating-custom-modelers-for-intelligent-instruments

### 
#### 
#### 
#### 
1. If it’s a `Mobile Agent Exec` signpost, assert a new execution bookkeeping fact.
2. If it’s a `Mobile Agent Exec` signpost  a previous  bookkeeping fact is present in working memory, then close the transition interval.
3. If it’s a `Mobile Agent Moved` signpost, assert a new transition bookkeeping fact.
4. If it’s a `Mobile Agent Moved` signpost  a previous  bookkeeping fact is present in working memory, then close the execution interval.
#### 
#### 
#### 
#### 
To remedy this, create a  `speculation rule`. The `Analysis Core` asks your modeler to speculate about the end of an interval in order to render the interval’s progress before it closes, as well as give your modelers a chance to infer how an interval might close once the trace ends.
A `speculation rule` operates very similarly to other rules within the `RECORDER` module. It too outputs entries into a data table, but only temporarily. The `speculation rule` also doesn’t have the complete information about an interval. For example, consider the `mobile-agent-recording.clp` file in the `SpeculationModeling` target. The `speculation rule` requires the presence of a `speculate` fact in the working memory. The fact includes a slot for the time at which speculation was requested.
```None
(defrule RECORDER::speculatively-record-execution
    (speculate (event-horizon ?end))
    (table (table-id ?output) (side append))
    (table-attribute (table-id ?output) (has schema mobile-agent-activity))
    (mobile-agent-execution-started (start ?start)
    (instance ?instance) (stop-kind ?stop-kind&~sentinel))
    
    =>
    (bind ?duration (- ?end ?start))
    (create-new-row ?output)
    (set-column start ?start)
    (set-column duration ?duration)
    (set-column instance ?instance)
    (set-column state "Executing")
    (set-column activity-type "Green")
    (set-column stop-kind ?stop-kind)
    (set-column-narrative activity "Executing at stop %string%" ?stop-kind)
)
```

With the speculation rule in place, the `Analysis Core` can now query the modeler when it needs to perform any speculation.
#### 
#### 
#### 
#### 
Creates a new row in an output table that is bound to the modeler. The only parameter is the INTEGER `table-id` of the bound table. This is typically matched as part of the rule, using the table schema and attributes to locate the table-id. Once the row has been created, `set-column` can be used to fill in each column of the new row. Columns that are not filled out assume a default value, which is typically the sentinel for that engineering type if one is defined.
```None
(table (side append) (table-id ?output))
(table-attribute (table-id ?output) (has schema example))
 =>
(create-new-row ?output)   ;; create the row before trying to set columns
```

#### 
Sets the specified column of the most recently created row in the RHS of the rule. The first parameter is the column mnemonic, as defined in the schema, and the second parameter is the value to set. Conversion from the implementation type (e.g. INTEGER, STRING, FLOAT, EXTERNAL-ADDRESS) to the engineering type of the column will be done automatically when possible.
```None
(set-column size-column ?example-size) ;; Sets size-column to the value ?example-size 
```

#### 
`set-column-narrative` is similar to `set-column`, except that it applies a format string to create an engineering value of type `narrative`. Narratives are like long text strings; however, each piece of the narrative is preserved and tagged with the engineering type specified in the format string. This information allows the UI to break the string down later for a richer presentation. The first argument is the column mnemonic, followed by the format string, followed by the series of arguments, as in a printf-style format string.
The format string argument contains tokens surrounded by ‘%’, such as: `Some text with a %thread% in the middle`. The value of the token must be a valid engineering type identifier. This example is a “thread” engineering type.
```None
(set-column-narrative narrative-column "Some text with a %thread% in the middle" ?thread-value)
```

#### 
#### 
The “thread” engineering type is associated with a particular process. This function takes a thread value as an argument and produces the process object with which it is associated.
```None
(bind ?proc (process-from-thread ?thread)) ;;  Extracts the process object from ?thread and store it in ?proc
(set-column process ?proc) ;; set the process column to the value ?proc
```

#### 
Extracts the INTEGER pid from its argument, which must be a `process` engineering type.
Extracts the INTEGER pid from its argument, which must be a `process` engineering type.
```None
(bind ?process (process-from-thread ?thread))
(bind ?pid (pid-from-process ?process))
```

#### 
A Boolean return function that tests the nth bit of the first argument, and returns true if it is set, false otherwise. The second argument supplies the bit index to test. The bit index ranges from [0-63], where bit 0 is the least significant bit of the INTEGER.
```None
(bit-test ?value-to-test 63) ;  returns true if the most significant bit in ?value-to-test is set
```

#### 
Returns an INTEGER by extracting a range of bits from the first argument. The return value has been shifted over such that the lowest bit in the extracted range becomes bit 0. Bit 0 is the least significant bit. The second and third arguments hold the range of bits to extract, inclusively. Conventionally, the highest bit in the range is the second argument, but if they are reversed, the function still works as expected.
```None
(extract-bits ?integer-value 63 32) ; extracts the most significant 32-bits and shifts them to the right by 32 bits.
```

#### 
Takes two 32-bit INTEGER arguments and concatenates them to create a single 64-bit INTEGER return value. This function takes the upper 32 bits of the first argument and place them into the upper 32 bits of the return value, and takes the lower 32 bits of the second argument and places them into the lower 32 bits of the return value. This function is typically useful for reconstructing a 64-bit value that has been broken apart into multiple fields. Even though the return and argument values are signed INTEGERs, they are treated as unsigned bit patterns internally.
```None
(make-int64 ?msb ?lsb)
```

#### 
Note: you cannot pass a multifield value in as a single argument. On failure, this function will return the symbol `sentinel`.
Treats its INTEGER arguments as a run of continuous memory values and extracts a UTF8 encoded string from it. The function automatically detects if the run of INTEGERs are 32-bit or 64-bit, assuming that the run is consistently one or the other, but  a mixture of both. The UTF8 encoding convention allows us to reliably make that determination with little overhead.
Note: you cannot pass a multifield value in as a single argument. On failure, this function will return the symbol `sentinel`.
```None
(memory-to-string ?part1 ?part2 ?part3) ; treats the three INTEGER arguments as a run of INTEGERs and returns the string value for it.
```

#### 
#### 
When the Analysis Core has been configured with the extra logging enabled through the Instruments Inspector, a modeler-log table is created that is written to with this function. The function does nothing when logging is disabled, although there is still a small amount of overhead in the call. The first argument is a format string, and the following arguments are interpreted like a printf-style argument.
```None
(log-narrative "Resolved stop kind code %uint64% to %string%" ?stop-kind-code ?kind)
```

#### 
Creates an empty `integer-array` and returns it.
#### 
Appends the second argument to the `integer-array` in the first argument. Does not cause rule activation.
#### 
#### 
#### 
Sorts the `integer-array` in the first argument. Does not cause rule activation.
#### 
Copies the `integer-array` in the first argument and returns the EXTERNAL-ADDRESS.

## Creating distribution-signed code for macOS
> https://developer.apple.com/documentation/xcode/creating-distribution-signed-code-for-the-mac

### 
- If you build your product using an external build system, such as `make`, add a manual signing step to your build system.
### 
You can complete each step from the Xcode app or automate the steps using `xcodebuild`.
1. Run `xcodebuild` with the `archive` action to build and archive your app.
2. Run `xcodebuild` with the `exportArchive` action to export the distribution-signed app from the archive created in step 1.
### 
2. Sign those components manually.
The commands that you use depend on your project structure. For example, imagine your product is a daemon, but it also has an associated configuration app.  The configuration app has a share extension and an embedded framework to share code between the app and the extension. An archive of this product in Xcode has the following structure:
```None
DaemonWithApp.xcarchive/
  Info.plist
  Products/
    usr/
      local/
        bin/
          Daemon
    Applications/
      ConfigApp.app/
        Contents/
          embedded.provisionprofile
          Frameworks/
            Core.framework/
              …
          PlugIns/
            Share.appex/
              Contents/
                embedded.provisionprofile
                …
          …
  …
```

```
The `Products` directory contains two items: the daemon itself (`Daemon`) and the configuration app (`ConfigApp.app`). To sign this product, first copy these items out of the archive.
```None
% mkdir "to-be-signed"
% ditto "DaemonWithApp.xcarchive/Products/usr/local/bin/Daemon" "to-be-signed/Daemon"
% ditto "DaemonWithApp.xcarchive/Products/Applications/ConfigApp.app" "to-be-signed/ConfigApp.app" 
```

### 
The following table shows the code items in the `DaemonWithApp` product and whether they’re bundled code or a main executable:
| Daemon | no | yes |
In some cases, it might not be obvious whether the code item is a main executable. To confirm, run the `file` command. A main executable says `Mach-O … executable` as the following example shows:
```None
% file "to-be-signed/ConfigApp.app/Contents/Frameworks/Core.framework/Versions/A/Core"
…
… Mach-O 64-bit dynamically linked shared library x86_64
…
% file "to-be-signed/ConfigApp.app/Contents/PlugIns/Share.appex/Contents/MacOS/Share"
…
… Mach-O 64-bit executable x86_64
…
```

`Core.framework` isn’t a main executable, but `Share.appex` is.
### 
1. `Core.framework`
2. `Share.appex `
3. `ConfigApp.app`
### 
If you have a development-signed version of your program, you can print its entitlements using the `codesign` command-line tool, and use that information as the basis for your entitlements property list file as the following example shows:
```None
% codesign -d --entitlements - --xml "to-be-signed/ConfigApp.app" | plutil -convert xml1 -o - -
…
<dict>
  <key>com.apple.application-identifier</key>
  <string>[Your Team ID].com.example.apple-samplecode.DaemonWithApp.App</string>
  <key>com.apple.developer.team-identifier</key>
  <string>[Your Team ID]</string>
  <key>com.apple.security.app-sandbox</key>
  <true/>
  <key>keychain-access-groups</key>
  <array>
    <string>[Your Team ID].com.example.apple-samplecode.DaemonWithApp.SharedKeychain</string>
  </array>
</dict>
</plist>
```

- Change the value of  from `development` to `production`.
### 
### 
- `com.apple.security.get-task-allow`
- `com.apple.security.application-groups`
If your product includes a nonbundled executable that uses a restricted entitlement, package that executable in an app-like structure.  For more information, see .
In the `DaemonWithApp` example, the configuration app and its share extension use a keychain access group to share secrets. The system grants the programs access to that group based on their `keychain-access-groups` entitlement claim, and a provisioning profile needs to authorize such claims. The app and the share extension each have their own profile. To distribute the app, update the app and share extension bundles with the corresponding distribution provisioning profile.
```None
% cp "ConfigApp-Dist.provisionprofile" "to-be-signed/ConfigApp.app/Contents/embedded.provisionprofile"
% cp "Share-Dist.provisionprofile" "to-be-signed/ConfigApp.app/Contents/PlugIns/Share.appex/Contents/embedded.provisionprofile"
```

### 
The code you copy from the Xcode archive is typically signed using a development code-signing identity.
```None
% codesign -d -vv to-be-signed/Daemon
…
Authority=Apple Development: …
…
```

For information on how to set up these code-signing identities, see .
To confirm that your code-signing identity is present and correct, run the following command:
```None
% security find-identity -p codesigning -v
  1) A06E7F3F8237330EE15CB91BE1A511C00B853358 "Apple Distribution: …"
  2) ADC03B244F4C1018384DCAFFC920F26136F6B59B "Developer ID Application: …"
     2 valid identities found
```

### 
For all code types, the basic `codesign` command looks like the following:
For all code types, the basic `codesign` command looks like the following:
```None
% codesign -s <CodeSigningIdentity> <PathToExecutable>
```

If you’re re-signing code — that is, the code you’re signing is already signed — add the `-f` option.
If you’re signing for Developer ID distribution, add the `--timestamp` option to include a secure timestamp.
> **note:** For bundled code, you don’t need to supply a code-signing identifier because `codesign` defaults to using the bundle ID.
The folloiwng code shows the complete sequence of commands to sign the `DaemonWithApp` example for Developer ID distribution:
Repeat this signing step for every code item in your product, in the order you established in “Determine the signing order” above. If you have a complex product with many code items to sign, create a script to automate this process.
The folloiwng code shows the complete sequence of commands to sign the `DaemonWithApp` example for Developer ID distribution:
```None
% codesign -s "Developer ID Application" -f --timestamp "to-be-signed/ConfigApp.app/Contents/Frameworks/Core.framework"
to-be-signed/ConfigApp.app/Contents/Frameworks/Core.framework: replacing existing signature
% codesign -s "Developer ID Application" -f --timestamp -o runtime --entitlements "Share.entitlements" "to-be-signed/ConfigApp.app/Contents/PlugIns/Share.appex"
to-be-signed/ConfigApp.app/Contents/PlugIns/Share.appex: replacing existing signature
% codesign -s "Developer ID Application" -f --timestamp -o runtime --entitlements "ConfigApp.entitlements" "to-be-signed/ConfigApp.app"
to-be-signed/ConfigApp.app: replacing existing signature
% codesign -s "Developer ID Application" -f --timestamp -o runtime -i "com.example.apple-samplecode.DaemonWithApp.Daemon" "to-be-signed/Daemon"
to-be-signed/Daemon: replacing existing signature
```

### 

## Creating enhanced security helper extensions
> https://developer.apple.com/documentation/xcode/creating-enhanced-security-helper-extensions

### 
#### 
Add the `EX_ENABLE_EXTENSION_POINT_GENERATION` user-defined build setting with the value `YES` to your app target’s build setting. In your app’s source code, create an extension to  that defines your app’s extension point. Give the extension point the  of your choosing, and the  attribute to tell the system to run your extension in the Enhanced Security runtime:
```swift
import ExtensionFoundation

extension AppExtensionPoint {
  @Definition
  static var exampleExtension: AppExtensionPoint {
    Name("exampleExtension")
    EnhancedSecurity()
  }
}
```

#### 
3. In the Xcode Project navigator, delete the extension target’s `Info.plist` file.
4. In the target build settings editor, delete the `INFOPLIST_FILE` build setting for the extension target.
4. In the target build settings editor, delete the `INFOPLIST_FILE` build setting for the extension target.
Edit the main source file for the extension, so that the  for the extension point it binds to has your app’s bundle ID as the host identifier, and the name you gave the extension point in the previous section:
```swift
import ExtensionFoundation

@main
struct MyAppHelper: ExampleExtension {
  @AppExtensionPoint.Bind
  var boundExtensionPoint: AppExtensionPoint {
    AppExtensionPoint.Identifier(host: "com.example.my-app", name: "exampleExtension")
  }
}
```

#### 
In your app, create an  to discover the Enhanced Security extension:
```swift
let monitor = try await AppExtensionPoint.Monitor(appExtensionPoint: AppExtensionPoint.exampleExtension)
guard let identity = monitor.identities.first else {     
   fatalError("Extension not found")
} 
```

```
The `identity` represents the bundle for the Enhanced Security extension you created in the previous section. Create an  with that bundle to launch the extension:
```swift
do {
  self.process = try await AppExtensionProcess(configuration: .init(appExtensionIdentity: identity, onInterruption: {
    // The system calls this closure when the extension exits.
  }))
  // Communicate with the extension.
}
catch let error {
  // The system can't launch the extension.
}
```

#### 
Use  to handle communication between your app and its Enhanced Security extension. For more information, see .
Define structures that conform to  in code you share between the app and extension, and create instances of those structures to send over XPC using the session you create:
```swift
struct Message: Identifiable, Codable {
  var id: String
  // Add properties that represent data your app sends to its extension.

  struct Response: Codable {
    // Define another structure that the extension sends back to the app in its reply.
  }
}
```

Call  in your app to create an `XPCSession` you use to send messages to the extension:
```
Call  in your app to create an `XPCSession` you use to send messages to the extension:
```swift
do {
  self.xpcSession = try process.makeXPCSession()
  try xpcSession.activate()
  // Send messages to the extension.
}
catch let error {
  // The system can't create the XPC session.
}
```

```
Use the session you create to send messages to the extension, and receive responses:
```swift
let response = try await withCheckedThrowingContinuation { continuation in
  do {
    // Construct the message the app sends to the extension.
    let message = Message()
    try xpcSession.send(Message()) { result in
      switch result {
      case .success(let reply):
        let response = (try? reply.decode(as: Message.Response.self)) ?? /* Create a default response. */
        continuation.resume(returning: response)
      case .failure(let error):
        continuation.resume(throwing: error)
      }
    }
  }
  catch {
    continuation.resume(throwing: error)
  }
}
// Interpret the response from the extension.
```

```
In the extension, create a  to accept incoming connections from the app. Call the  initializer, and use the closure to accept the XPC connection and create a session.
```swift
extension ExampleExtension {
    var configuration: some AppExtensionConfiguration {
        // Return your extension's configuration upon request.
        return ConnectionHandler(onSessionRequest: { request in
            let handler = MessageHandler(appExtension: self)
            return request.accept { session in
                return handler
            }
        })
    }
}
 
fileprivate struct MessageHandler<E: ExampleExtension>: XPCPeerHandler, Sendable {
    let appExtension: E
     
    func handleIncomingRequest(_ message: Message) -> (any Encodable)? {
        // Process the incoming message.
        return Message.Response()
    }
}

```

#### 

## Creating width and device variants of strings
> https://developer.apple.com/documentation/xcode/creating-width-and-device-variants-of-strings

### 
#### 
#### 
A  specifies variants for different available widths in the user interface. It contains a single dictionary with a single key-value pair. The key in the dictionary is `NSStringVariableWidthRuleType` and the value is another dictionary with key-value pairs for each variant. The key for a variant is a width and the value is a string.
In the following `.stringsdict` file, for the `hello `string in the code,` `the width variations are `1`, `22`, and `53`, and the values are `Hi`, `Hello`, and `Greetings and Salutations`:
```other
<plist version="1.0">
    <dict>
        <key>hello</key>
        <dict>
            <key>NSStringVariableWidthRuleType</key>
            <dict>
                <key>1</key>
                <string>Hi</string>
                <key>22</key>
                <string>Hello</string>
                <key>53</key>
                <string>Greetings and Salutations</string>
            </dict>
        </dict>
    </dict>
</plist>

```

In the code above, if the width is `2`, the macro returns `Hi`. If the width is `55`, the macro returns `Hello`.
#### 
| mac | The string to use on Mac. |
In the following `.stringsdict` file, when you pass `UserInstructions` as the string in your code, it returns `Tap here` when the app runs on an iPhone, `Click here` when it runs on a Mac, and `Press here` when it runs on an Apple TV:
```other
<plist version="1.0">
<dict>
    <key>UserInstructions</key>
    <dict>
        <key>NSStringDeviceSpecificRuleType</key>
        <dict>
            <key>iphone</key>
            <string>Tap here</string>
            <key>mac</key>
            <string>Click here</string>
            <key>appletv</key>
            <string>Press here</string>
        </dict>
    </dict>
</dict>
</plist>
```


## Customizing the Metal Performance HUD
> https://developer.apple.com/documentation/xcode/customizing-metal-performance-hud

### 
#### 
#### 
#### 
You can customize the Metal Performance HUD programmatically by configuring the `CAMetalLayer` instance’s `developerHUDProperties` dictionary with the following:
```swift
myMetalLayer.developerHUDProperties = [
    "mode": "default",
    "logging": "default",
    "positionX": 0,
    "positionY": 0,
    // ...
]
```

#### 
The configuration file is a property list file containing key-value pairs of environment variables, and you can pass it into the HUD by setting the `MTL_HUD_CONFIG_FILE` environment variable.
```None
export MTL_HUD_CONFIG_FILE=<path>
```


## Data races
> https://developer.apple.com/documentation/xcode/data-races

### 
#### 
In the following example, the `producer()` function sets the global variable `message`, and the `consumer()` function waits for a flag to set before printing the message. Because `producer()` executes on one thread and `consumer()` executes on another thread, their execution can be concurrent, creating a data race.
```swift
var message: String? = nil
var messageIsAvailable: Bool = false
// Executed on Thread #1
func producer() {
    message = "hello!"
    messageIsAvailable = true
}
// Executed on Thread #2
func consumer() {
    repeat {
        usleep(1000)
    } while !messageIsAvailable
    print(message)
}
```

Use  APIs to coordinate access to `message` across multiple threads.

## Deallocation of deallocated memory
> https://developer.apple.com/documentation/xcode/deallocation-of-deallocated-memory

### 
#### 
In the following example, the code deallocates the `p_int` variable after the call to free its memory:
In the following example, the code deallocates the `p_int` variable after the call to free its memory:
```occ
int *pointer = malloc(sizeof(int));
free(pointer);
free(pointer); // Error: free called twice with the same memory address 
```

Ensure that you call the `free` function just once for memory you allocate.

## Deallocation of nonallocated memory
> https://developer.apple.com/documentation/xcode/deallocation-of-nonallocated-memory

### 
#### 
In the following example, the `value` variable allocates on the stack, and deallocates when the function exits, so calling `free` on it is incorrect:
In the following example, the `value` variable allocates on the stack, and deallocates when the function exits, so calling `free` on it is incorrect:
```occ
int value = 42;
free(&value); // Error: free called on stack allocated variable
```

Don’t call the `free` function on variables that you allocate on the stack.

## Defining a custom URL scheme for your app
> https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app

### 
3. Handle the URLs that your app receives.
URLs must start with your custom scheme name. Add parameters for any options your app supports. For example, a photo library app might define a URL format that includes the name or index of a photo album to display. Examples of URLs for such a scheme could include the following:
```other
myphotoapp:albumname?name="albumname"
myphotoapp:albumname?index=1
```

```
Clients craft URLs based on your scheme and ask your app to open them by calling the  method of . Clients can ask the system to inform them when your app opens the URL.
```swift
let url = URL(string: "myphotoapp:Vacation?index=1")

UIApplication.shared.open(url!) { (result) in
    if result {
       // The URL was delivered successfully!
    }
}
```

#### 
#### 
When another app opens a URL containing your custom scheme, the system launches your app, if necessary, and brings it to the foreground. The system delivers the URL to your app by calling your app delegate’s  method. Add code to the method to parse the contents of the URL and take appropriate actions. To ensure the URL is parsed correctly, use  APIs to extract the components. Obtain additional information about the URL, such as which app opened it, from the system-provided options dictionary.
```swift
func application(_ application: UIApplication,
                 open url: URL,
                 options: [UIApplicationOpenURLOptionsKey : Any] = [:] ) -> Bool {

    // Determine who sent the URL.
    let sendingAppID = options[.sourceApplication]
    print("source application = \(sendingAppID ?? "Unknown")")

    // Process the URL.
    guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
        let albumPath = components.path,
        let params = components.queryItems else {
            print("Invalid URL or album path missing")
            return false
    }

    if let photoIndex = params.first(where: { $0.name == "index" })?.value {
        print("albumPath = \(albumPath)")
        print("photoIndex = \(photoIndex)")
        return true
    } else {
        print("Photo index missing")
        return false
    }
}
```

The system also uses your app delegate’s  method to open custom file types that your app supports.
If your app has opted into , and your app isn’t running, the system delivers the URL to the  delegate method after launch, and to  when your app opens a URL while running or suspended in memory.
```swift
func scene(_ scene: UIScene, 
           willConnectTo session: UISceneSession, 
           options connectionOptions: UIScene.ConnectionOptions) {

    // Determine who sent the URL.
    if let urlContext = connectionOptions.urlContexts.first {

        let sendingAppID = urlContext.options.sourceApplication
        let url = urlContext.url
        print("source application = \(sendingAppID ?? "Unknown")")
        print("url = \(url)")

        // Process the URL similarly to the UIApplicationDelegate example.
    }

    /*
     *
     */
}
```


## Diagnosing memory, thread, and crash issues early
> https://developer.apple.com/documentation/xcode/diagnosing-memory-thread-and-crash-issues-early

### 
#### 
- `-fsanitize=address` (clang)
- `-sanitize=address` (swiftc)
- `-enableAddressSanitizer YES` (xcodebuild)
#### 
- `-fsanitize=thread` (clang)
- `-sanitize=thread` (swiftc)
- `-enableThreadSanitizer YES` (xcodebuild)
#### 
To fix problems identified by Main Thread Checker, dispatch calls to your app’s main thread. The most common place where main thread errors occur is completion handler blocks. The following code wraps the text label modification with an asynchronous dispatch call to the main thread.
```swift
let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
   if let data = data {
      // Redirect to the main thread.
      DispatchQueue.main.async {
         self.label.text = "\(data.count) bytes downloaded"
      }
   }
}
task.resume()

```

#### 
- Attempts to dereference a `NULL` pointer
| `-fsanitize=alignment` |  |
| `-fsanitize=bool` |  |
| `-fsanitize=bounds` |  |
| `-fsanitize=enum` |  |
| `-fsanitize=vptr` |  |
| `-fsanitize=integer-divide-by-zero` |  |
| `-fsanitize=float-divide-by-zero` |  |
| `-fsanitize=float-cast-overflow` |  |
| `-fsanitize=nonnull-attribute` |  |
| `-fsanitize=nullability-arg` |  |
| `-fsanitize=nullability-assign` |  |
| `-fsanitize=returns-nonnull-attribute` |  |
| `-fsanitize-nullability-return` |  |
| `-fsanitize=null` |  |
| `-fsanitize=object-size` |  |
| `-fsanitize=shift` |  |
| `-fsanitize=signed-integer-overflow` |  |
| `-fsanitize=unreachable` |  |
| `-fsanitize=vla-bound` |  |

## Diagnosing performance issues early
> https://developer.apple.com/documentation/xcode/diagnosing-performance-issues-early

### 
#### 
#### 
- Ensure that the QoS of the waiting thread is the same as or lower than the QoS of the signaling thread when a synchronous variant isn’t available. Explicitly classify the QoS of the work when you create a  or an .
The code in `initiateBackgroundWork` below explicitly creates a dispatch queue with background QoS. `doBackgroundWorkAsync` signals the completion of the background work it does asynchronously at background QoS. After the background work completes, it updates the UI label on the main thread at  QoS.
```swift
func initiateBackgroundWork() {
    let dispatchSemaphore = DispatchSemaphore(value: 0)
    let backgroundQueue = DispatchQueue(label: "background_queue", 
                                        qos: .background)
    
    backgroundQueue.async {
        // Perform work on a separate thread using the quality-of-service level 
        // for background maintenance or cleanup tasks and signal when the work completes.
       doBackgroundWorkAsync {
           dispatchSemaphore.signal()
       }
       
       _ = dispatchSemaphore.wait(timeout: DispatchTime.distantFuture)
       
       DispatchQueue.main.async { [weak self] in
           self?.label.text = "Background work completed"
       }
    })
}
```

#### 
#### 
#### 
Resolution of certain performance issues may require significant code refactoring or redesign of the underlying logic. To suppress the warning for issues you intend to address at a later time, set the `PERFC_SUPPRESSION_FILE` environment variable to provide a list of classes and methods in a suppression file. The Thread Performance Checker tool only shows issues that don’t involve those classes and methods. Use the following format for your suppression file:
```other
class:UIActivityViewController
class:NSThread
method:-[UIViewController view]
method:readv
```


## Distributing binary frameworks as Swift packages
> https://developer.apple.com/documentation/xcode/distributing-binary-frameworks-as-swift-packages

### 
#### 
#### 
To declare a local, or , binary target, use  and don’t generate a checksum. Instead, include the `.xcframework` bundle in the package’s Git repository.
The following package manifest for the MyLibrary package declares a library product that includes two binary targets: `SomeRemoteBinaryPackage`, a remote, URL-based binary target; and `SomeLocalBinaryPackage`, a local, path-based binary target.
```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MyLibrary",
    platforms: [
        .macOS(.v10_14), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MyLibrary",
            targets: ["MyLibrary", "SomeRemoteBinaryPackage", "SomeLocalBinaryPackage"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MyLibrary"
        ),
        .binaryTarget(
            name: "SomeRemoteBinaryPackage",
            url: "https://url/to/some/remote/xcframework.zip",
            checksum: "The checksum of the ZIP archive that contains the XCFramework."
        ),
        .package(
            name: "SomeLocalBinaryPackage",
            path: "path/to/some.xcframework"
        )
        .testTarget(
            name: "MyLibraryTests",
            dependencies: ["MyLibrary"]),
    ]
)
```


## Distributing documentation to other developers
> https://developer.apple.com/documentation/xcode/distributing-documentation-to-other-developers

### 
1. Export your documentation, either from Xcode’s documentation viewer, or by using the `xcodebuild` command-line tool.
#### 
The documentation archive that Xcode exports uses a `.doccarchive` file extension.
To export the documentation archive from the command line, run `xcodebuild docbuild` in Terminal and copy the resulting `.doccarchive` bundle from the derived data directory. Depending on your project’s configuration, you may need to pass additional command-line options. For additional information, consult the `xcodebuild` man page.
For example, to build a documentation archive, use a command similar to the following:
```shell
xcodebuild docbuild -scheme SlothCreator -derivedDataPath ~/Desktop/SlothCreatorBuild
```

As part of the build process, `xcodebuild` produces many files in the derived data path. One way to locate the documentation archive in the build output is to use the `find` command. For example, use the following to locate the documentation archive that the `xcodebuild` command above produces:
```shell
find ~/Desktop/SlothCreatorBuild -type d -name '*.doccarchive`
```

#### 
#### 
When Xcode exports a documentation archive, it includes a single-page web app in the bundle. This web app renders the documentation content as HTML, letting you host the documentation archive on a web server.
For reference documentation and articles, the web app uses a URL path that begins with `/documentation`. For tutorials, the URL path begins with `/tutorials`. For example, if a project contains a protocol with the name `SlothGenerator`, the URL to view the `SlothGenerator` documentation might resemble the following:
```None
https://www.example.com/documentation/SlothCreator/SlothGenerator
```

2. Add a rule on the server to rewrite incoming URLs that begin with `/documentation` or `/tutorial` to `SlothCreator.doccarchive/index.html`.
The following example `.htaccess` file defines rules suitable for use with Apache:
3. Add another rule for incoming requests to support bundled resources in the documentation archive, such as CSS files and image assets.
The following example `.htaccess` file defines rules suitable for use with Apache:
```shell
# Enable custom routing.
RewriteEngine On

# Route documentation and tutorial pages.
RewriteRule ^(documentation|tutorials)\/.*$ SlothCreator.doccarchive/index.html [L]

# Route files and data for the documentation archive.
#
# If the file path doesn't exist in the website's root ...
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d

# ... route the request to that file path with the documentation archive.
RewriteRule .* SlothCreator.doccarchive/$0 [L]
```


## Division by zero
> https://developer.apple.com/documentation/xcode/division-by-zero

### 
#### 
In the following code, the `for` loop performs division by zero on its first iteration:
In the following code, the `for` loop performs division by zero on its first iteration:
```occ
int sum = 10;
for (int i = 0; i < 64; ++i) {
    sum /= i; // Error: division by zero on the first iteration
}
```


## Downloading and installing additional Xcode components
> https://developer.apple.com/documentation/xcode/downloading-and-installing-additional-xcode-components

### 
#### 
#### 
#### 
#### 
You can also download components in Terminal using the `xcodebuild` command. For example, use the command line to download Xcode components once and then install them across multiple Mac computers.
To download Simulator runtimes for a specific platform, use this syntax:
```None
xcodebuild -downloadPlatform <iOS|watchOS|tvOS|visionOS>  [-exportPath <destinationpath> -buildVersion <osversion> -architectureVariant <universal|arm64>]
```

```
For example:
```None
xcodebuild -downloadPlatform iOS -exportPath ~/Downloads
```

To specify an OS version, add the `-buildVersion` option:
```
To specify an OS version, add the `-buildVersion` option:
```None
xcodebuild -downloadPlatform iOS -exportPath ~/Downloads -buildVersion 18.0 
```

To download all the supported platforms for the version of Xcode you select, use this syntax with the `-downloadAllPlatforms` option:
```
To download all the supported platforms for the version of Xcode you select, use this syntax with the `-downloadAllPlatforms` option:
```None
xcodebuild -downloadAllPlatforms [-exportPath <path>]
```

To download the universal variant that works on both Apple silicon and Intel-based Mac computers, use the `-architectureVariant` option:
By default, Xcode downloads a variant based on your Mac computer’s architecture and whether you use Rosetta run destinations. Xcode downloads a universal variant for Intel-based Mac computers and when you use Rosetta run destinations. Otherwise, Xcode downloads an Apple silicon variant to save disk space for the platform you specify.
To download the universal variant that works on both Apple silicon and Intel-based Mac computers, use the `-architectureVariant` option:
```None
xcodebuild -downloadPlatform iOS -architectureVariant universal
```

#### 
After you download component packages, you can install them in Terminal with the `xcodebuild` command.
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

#### 
If you attempt to build an app that requires the Metal Toolchain before downloading the toolchain, a dialog appears. Click Download to download the Metal Toolchain.
Alternatively, to download and install the toolchain from the command line, run this command from Terminal:
```None
xcodebuild -downloadComponent metalToolchain
```

```
To download and install the toolchain separately, first download and export it to a file:
```None
xcodebuild -downloadComponent metalToolchain -exportPath ~/Downloads
```

```
Then, install the toolchain into Xcode:
```None
xcodebuild -importComponent metalToolchain ~/Downloads/metalToolchain.dmg
```


## Dynamic type violation
> https://developer.apple.com/documentation/xcode/dynamic-type-violation

### 
#### 
In the following code, `reinterpret_cast` creates a variable with the wrong dynamic type:
In the following code, `reinterpret_cast` creates a variable with the wrong dynamic type:
```occ
struct Animal {
    virtual const char *speak() = 0;
};
struct Cat : public Animal {
    const char *speak() override {
        return "meow";
    }
};
struct Dog : public Animal {
    const char *speak() override {
      return "woof";
    }
};
auto *dog = reinterpret_cast<Dog *>(new Cat); // Error: dog has incorrect dynamic type
dog->speak(); // Error: this call has undefined behavior
```

> **note:** This UBSan check requires runtime type information, and is incompatible with the `-fno-rtti` compiler flag.
Use `reinterpret_cast` sparingly, and only when it’s possible to verify that the cast object is an instance of the destination type.

## EXC_BREAKPOINT (SIGTRAP) and EXC_BAD_INSTRUCTION (SIGILL)
> https://developer.apple.com/documentation/xcode/sigtrap_sigill

### 
If you want to use the same technique in your own code for unrecoverable errors, call the  function in Swift, or the `__builtin_trap()` function in C. These functions allow the system to generate a crash report with thread backtraces that show how you reached the unrecoverable error.
An illegal CPU instruction means the program’s executable contains an instruction that the processor doesn’t implement or can’t execute. For example, the following program tries to perform the CPU instruction `0x00000001`, which isn’t a valid instruction on Apple silicon:
```c
#include <stdint.h>

int main(int argc, char **argv) {
    static const uint32_t sTest[] = {
        0x00000001,
    };
    typedef void (*FuncPtr)(void);
    FuncPtr f = (FuncPtr) sTest;
    f();
    return 0;
}
```


## EXC_CRASH (SIGKILL)
> https://developer.apple.com/documentation/xcode/sigkill

### 
The crash report contains a `Termination Reason` field with a code that explains the reason for the crash. In the following example, that code is `0xdead10cc`:
```other
Exception Type:  EXC_CRASH (SIGKILL)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Termination Reason: Namespace RUNNINGBOARD, Code 0xdead10cc
```

The `Termination Reason` code is one of the following values:

## EXC_CRASH (SIGSYS)
> https://developer.apple.com/documentation/xcode/sigsys

### 
For example, the code below uses system call number 12345, which isn’t valid and produces a `SIGSYS` signal.
System calls are low-level interfaces that ask the operating system to perform an action. This signal indicates that the requested system call doesn’t exist.
For example, the code below uses system call number 12345, which isn’t valid and produces a `SIGSYS` signal.
```c
#include <unistd.h>

int main(int argc, char **argv) {
    syscall(12345);
    return 0;
}
```

For a list of valid system calls, see the `syscall.h` header file.

## Editing XLIFF and string catalog files
> https://developer.apple.com/documentation/xcode/editing-xliff-and-string-catalog-files

### 
#### 
To find the user-facing strings that need translation, including the app name, search for the `<trans-unit>` element in the XLIFF file. To insert a translation of a string, add a `<target>` element to the `<trans-unit>` element containing the localized text as in:
```other
<trans-unit id="Hello, world!" xml:space="preserve">
        <source>Hello, world!</source>
        <target>Hallo, Welt!</target>
        <note>A friendly greeting.</note>
</trans-unit>
```

#### 
If you specify a table name when you internationalize your code — in other words, if you use the `Text`  method or the  function with the `tableName` parameter — Xcode groups the strings into separate `<file>` elements with `[table name].strings` as the filename. If you don’t specify a table name, Xcode uses the default `Localizable.strings` as the filename.
When you import the localizations, Xcode adds a version of the strings file for each localization to your project. In the following SwiftUI code listing, the first `Text` string appears in the default `Localized.strings` file while the Button label that specifies a table name appears in the `Buttons.strings` file:
```swift
VStack {
    Text("Hello, world!", comment:"A friendly greeting.")
        .font(.largeTitle)
        .padding()
    Button(action: pushMe){
        Text("Push Me", tableName:"Buttons", comment:"Push Me button label.")
    }
    .font(.title)
}
```

#### 

## Editing source files in Xcode
> https://developer.apple.com/documentation/xcode/editing-source-files-in-xcode

### 
#### 
#### 
3. Edit the code in the snippet below and mark placeholders with `<#placeholder name#>`.
#### 
Then annotate your code with `MARK`, `TODO`, and `FIXME` comments to enhance the power of these tools when organizing your code.
Add a `MARK` comment to add a heading to a section of code. Include a dash in the comment to instruct Xcode to show a divider line before the section in the jump bar and minimap.
```swift
// MARK: Views

/// A view with a toggle button that shows or hides earned badges in a vertical layout.
struct BadgesView: View {
```

Add a `TODO` comment to indicate where you want to do future work. The jump bar highlights the `TODO` comment with an icon for easy identification.
```
Add a `TODO` comment to indicate where you want to do future work. The jump bar highlights the `TODO` comment with an icon for easy identification.
```swift
// TODO: Support new types of badges.
func body(content: Content) -> some View {
```

Add a `FIXME` comment to note where you need to make a fix in your code. The jump bar highlights the `FIXME` comment with a different icon.
```
Add a `FIXME` comment to note where you need to make a fix in your code. The jump bar highlights the `FIXME` comment with a different icon.
```swift
// FIXME: Add hover text over the image.
Image(systemName: badge.symbolName)
```

For Objective-C, use the `#pragma mark`, `#pragma fixme`, and `#pragma todo` macros instead.
#### 

## Embedding a command-line tool in a sandboxed app
> https://developer.apple.com/documentation/xcode/embedding-a-helper-tool-in-a-sandboxed-app

### 
- You want to build a command-line tool with an external build system (for example, `make`) and then run it from your app.
#### 
#### 
Now switch back to the app (`AppWithTool`) scheme.
#### 
Add the `ToolX` executable to that build phase, making sure Code Sign On Copy is checked.
#### 
Run the following commands to confirm that Xcode constructed everything correctly:
```None
% codesign -d -vvv --entitlements :- AppWithTool.app 
…
Identifier=com.example.apple-samplecode.AppWithTool
Format=app bundle with Mach-O universal (x86_64 arm64)
CodeDirectory v=20500 size=822 flags=0x10000(runtime) hashes=14+7 location=embedded
…
Authority=Apple Distribution: …
…
TeamIdentifier=SKMME9E2Y8
…
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-only</key>
    <true/>
</dict>
</plist>
% codesign -d -vvv --entitlements :- AppWithTool.app/Contents/MacOS/ToolX 
…
Identifier=com.example.apple-samplecode.AppWithTool.ToolX
Format=Mach-O universal (x86_64 arm64)
CodeDirectory v=20500 size=796 flags=0x10000(runtime) hashes=13+7 location=embedded
…
Authority=Apple Distribution: …
…
TeamIdentifier=SKMME9E2Y8
…
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.inherit</key>
    <true/>
</dict>
</plist>
```

- The `Identifier` field is the code signing identifier.
- The `Format` field shows that the executable is universal.
- The `runtime` flag, in the `CodeDirectory` field, shows that the hardened runtime is enabled.
- The `TeamIdentifier` field is your Team ID.
- The app’s entitlements include `com.apple.security.app-sandbox` and whatever other entitlements are appropriate for this app.
- The tool’s entitlements include just `com.apple.security.app-sandbox` and `com.apple.security.inherit`.
#### 
#### 
Create a new directory and change into it:
```None
% mkdir ToolC
% cd ToolC
```

Here  stands for .
Create a source file in the directory that looks like this:
```None
% cat main.c 
#include <stdio.h>

int main(int argc, char ** argv) {
    printf("Hello Cruel World!\n");
    return 0;
}
```

Build that source file with `clang` twice, once for each architecture, and then `lipo` them together:
```
Build that source file with `clang` twice, once for each architecture, and then `lipo` them together:
```None
% clang -o ToolC-x86_64 -mmacosx-version-min=10.15 -arch x86_64 main.c
% clang -o ToolC-arm64 -mmacosx-version-min=11.0 -arch arm64 main.c
% lipo ToolC-x86_64 ToolC-arm64 -create -output ToolC 
```

The `-mmacosx-version-min` option sets the deployment target to match the AppWithTool app. For the Intel architecture, this is macOS 10.15, as discussed above. For the Apple silicon architecture, this is macOS 11.0, the first macOS release to support Apple silicon.
Create an entitlements file for the tool:
```None
% /usr/libexec/PlistBuddy -c "Add :com.apple.security.app-sandbox bool true" "ToolC.entitlements"
File Doesn't Exist, Will Create: ToolC.entitlements
% /usr/libexec/PlistBuddy -c "Add :com.apple.security.inherit bool true" ToolC.entitlements
% cat ToolC.entitlements 
…
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.inherit</key>
    <true/>
</dict>
</plist>
```

```
Sign the tool as shown below:
```None
% codesign -s - -i com.example.apple-samplecode.AppWithTool.ToolC -o runtime --entitlements ToolC.entitlements -f ToolC
```

- The `-i com.example.apple-samplecode.AppWithTool.ToolC` option sets the code signing identifier.
- The `-o runtime` option enables the hardened runtime. Again, this isn’t necessary for App Store distribution, but it’s best practice for new code.
- The `--entitlements ToolC.entitlements` option supplies the signature’s entitlements.
Add the `ToolC` executable to your Xcode project. When you do this:
In the Build Phases tab of the app target editor, add `ToolC` to the Embed Helper Tools build phase, making sure that Code Sign On Copy is checked.
#### 
To validate your work, follow the process described in , substituting `ToolC` for `ToolX` everywhere.

## Embedding nonstandard code structures in a bundle
> https://developer.apple.com/documentation/xcode/embedding-nonstandard-code-structures-in-a-bundle

### 
#### 
#### 
Imagine you’re building a Mac app to varnish waffles and want to use the fabulous open source libWaffleVarnish code.  Its build system outputs a directory structure like this:
```None
libWaffleVarnish/
  bin/
    wafflevarnish
  etc/
    wafflevarnish.config
  lib/
    libVarnish.dylib
    libWaffle.dylib
```

The `wafflevarnish` tool depends on both dynamic libraries.  The `libVarnish.dylib` library depends on `libWaffle.dylib`.  The `wafflevarnish` tool also reads the `wafflevarnish.config` configuration file.
The good news here is that libWaffleVarnish is structured in a way that makes it easy to relocate.  The `wafflevarnish` tool sets up the rpath context via an executable relative path that leads to the `lib` directory:
```None
% otool -l libWaffleVarnish/bin/wafflevarnish | grep -B 1 -A 2 LC_RPATH 
Load command 15
          cmd LC_RPATH
      cmdsize 40
         path @executable_path/../lib …
```

And both `wafflevarnish` and `libVarnish.dylib` reference their dynamic library dependencies with rpath-relative references:
```
And both `wafflevarnish` and `libVarnish.dylib` reference their dynamic library dependencies with rpath-relative references:
```None
% otool -L "libWaffleVarnish/bin/wafflevarnish"
…
    @rpath/libVarnish.dylib …
    @rpath/libWaffle.dylib …
    …
% otool -L "libWaffleVarnish/lib/libVarnish.dylib"
…
    @rpath/libVarnish.dylib …
    @rpath/libWaffle.dylib …
    …
% otool -L "libWaffleVarnish/lib/libWaffle.dylib"
…
    @rpath/libWaffle.dylib …
    …
```

For more information on the rpath mechanism, see the `dyld` man page.  If you’re unfamiliar with reading man pages, see .
#### 
Not all code with a nonstandard structure is as accommodating as libWaffleVarnish.  For example, the build system for libRubPat expresses its dependencies using absolute paths:
```None
% otool -L "libRubPat/bin/rubpat"
…
    /usr/local/libRubPat/lib/libPat.dylib …
    /usr/local/libRubPat/lib/libRub.dylib …
    …
% otool -L "libRubPat/lib/libPat.dylib"
…
    /usr/local/libRubPat/lib/libPat.dylib …
    /usr/local/libRubPat/lib/libRub.dylib …
    …
% otool -L "libRubPat/lib/libRub.dylib"
…
    /usr/local/libRubPat/lib/libRub.dylib …
    …
```

The best way to fix this problem is to update the code’s build system to use rpath-relative references.  However, this isn’t possible for libRubPat because that library is not open source.  To embed libRubPat in your bundle, use `install_name_tool` to change the paths embedded in its code items.  First remove all the code signatures:
```None
% codesign --remove-signature "libRubPat/lib/libRub.dylib"
% codesign --remove-signature "libRubPat/lib/libPat.dylib"
% codesign --remove-signature "libRubPat/bin/rubpat"
```

Changing code using `install_name_tool` breaks the seal on its code signature, a fact that `install_name_tool` warns you about.  You will be re-signing this code as part of your distribution process, so you might as well work with unsigned code and avoid a bunch of warnings.
Now change the dynamic library identifier for each library to be rpath-relative:
```None
% install_name_tool -id "@rpath/libRub.dylib" "libRubPat/lib/libRub.dylib"
% install_name_tool -id "@rpath/libPat.dylib" "libRubPat/lib/libPat.dylib"
```

This controls how the library identifies itself to the rest of the system.
Next, change each dynamic library dependency to match:
```None
% install_name_tool -change "/usr/local/libRubPat/lib/libRub.dylib" "@rpath/libWaffle.dylib" "libRubPat/lib/libPat.dylib"
% install_name_tool -change "/usr/local/libRubPat/lib/libRub.dylib" "@rpath/libWaffle.dylib" "libRubPat/bin/rubpat"
% install_name_tool -change "/usr/local/libRubPat/lib/libPat.dylib" "@rpath/libVarnish.dylib" "libRubPat/bin/rubpat"
```

```
Finally, add an executable-relative rpath to the tool:
```None
% install_name_tool -add_rpath "@executable_path/../lib" "libRubPat/bin/rubpat"
```

To confirm that you’ve fixed all the dependencies, run `otool` just like you did for libWaffleVarnish:
```
To confirm that you’ve fixed all the dependencies, run `otool` just like you did for libWaffleVarnish:
```None
% otool -l libRubPat/bin/rubpat | grep -B 1 -A 2 LC_RPATH 
Load command 17
          cmd LC_RPATH
      cmdsize 40
         path @executable_path/../lib (offset 12)

% otool -L "libRubPat/bin/rubpat"
…
    @rpath/libPat.dylib …
    @rpath/libRub.dylib …
    …
% otool -L "libRubPat/lib/libPat.dylib"
…
    @rpath/libPat.dylib …
    @rpath/libRub.dylib …
    …
% otool -L "libRubPat/lib/libRub.dylib"
…
    @rpath/libRub.dylib …
    …
```

#### 
Once you’ve confirmed that the code uses rpath-relative paths, it’s time to embed it in your bundle.  Imagine you’re building an app called MacWaffleVarnish.  The rules in  require this structure:
```None
MacWaffleVarnish.app/
  Contents/
    Info.plist
    MacOS/
      MacWaffleVarnish
      wafflevarnish
    Frameworks/
      libVarnish.dylib
      libWaffle.dylib
    Resources/
      … other resources …
      libWaffleVarnish/
        etc/
          wafflevarnish.config
```

The dynamic libraries are in `Contents/Frameworks`, the tool in `Contents/MacOS`, and the configuration file in `Contents/Resources`.
The dynamic libraries are in `Contents/Frameworks`, the tool in `Contents/MacOS`, and the configuration file in `Contents/Resources`.
To make this work, use `install_name_tool` to adjust the rpath entry in the `wafflevarnish` tool to point to the Frameworks directory rather than the lib directory:
```None
% install_name_tool -rpath "@executable_path/../lib" "@executable_path/../Frameworks" "wafflevarnish"
```

#### 
There’s one final gotcha here.  If you run the `wafflevarnish` tool you’ll see this error:
There’s one final gotcha here.  If you run the `wafflevarnish` tool you’ll see this error:
```None
% MacWaffleVarnish.app/Contents/MacOS/wafflevarnish
MacWaffleVarnish.app/Contents/MacOS/../etc/wafflevarnish.config: No such file or directory
…
```

```
It’s trying to access `wafflevarnish.config` via a path that’s relative to the executable, but you’ve moved things around such that the configuration file is no longer available at that relative path.  In many cases a tool will have a way to set the path to its configuration using a command-line argument or an environment variable.  If not, fix the problem using a symlink:
```None
MacWaffleVarnish.app/
  Contents/
    …
    MacOS/
      …
      wafflevarnish
    …
    Resources/
      …
      libWaffleVarnish/
        bin/
          wafflevarnish -> ../../MacOS/wafflevarnish
        etc/
          wafflevarnish.config
```

Now, if you run the `wafflevarnish` tool via the symlink, it finds the configuration file and all is well:
```
Now, if you run the `wafflevarnish` tool via the symlink, it finds the configuration file and all is well:
```None
% MacWaffleVarnish.app/Contents/Resources/libWaffleVarnish/bin/wafflevarnish
configuration:
  finish: gloss
…
```


## Examining the fields in a crash report
> https://developer.apple.com/documentation/xcode/examining-the-fields-in-a-crash-report

### 
#### 
A crash report begins with a header section that describes the environment the crash occurred in.
```other
Incident Identifier: 6156848E-344E-4D9E-84E0-87AFD0D0AE7B
CrashReporter Key:   76f2fb60060d6a7f814973377cbdc866fffd521f
Hardware Model:      iPhone8,1
Process:             TouchCanvas [1052]
Path:                /private/var/containers/Bundle/Application/51346174-37EF-4F60-B72D-8DE5F01035F5/TouchCanvas.app/TouchCanvas
Identifier:          com.example.apple-samplecode.TouchCanvas
Version:             1 (3.0)
Code Type:           ARM-64 (Native)
Role:                Foreground
Parent Process:      launchd [1]
Coalition:           com.example.apple-samplecode.TouchCanvas [1806]

Date/Time:           2020-03-27 18:06:51.4969 -0700
Launch Time:         2020-03-27 18:06:31.7593 -0700
OS Version:          iPhone OS 13.3.1 (17D50)
```

- `Incident Identifier`: A unique identifier for the report. Two reports never share the same `Incident Identifier`.
- `Hardware Model`: The specific device model the app was running on.
- `Path`: The location of the executable on disk. macOS replaces user-identifable path components with placeholder values to protect privacy.
- `Identifier`: The  of the process that crashed. If the binary doesn’t have a , this field contains either the process name or a placeholder value.
- `Version`: The version of the process that crashed. The value is a concatenation of the app’s  and .
- `AppStoreTools`: The version of Xcode used to compile your app’s bitcode and to thin your app to device specific variants.
- `AppVariant`: The specific variant of your app produced by app thinning. This field contains multiple values, described later in this section.
- `Code Type`: The CPU architecture of the process that crashed. The value is one of `ARM-64`, `ARM`, `X86-64`, or `X86`.
- `Parent Process`: The name and process ID (in square brackets) of the process that launched the crashed process.
- `Date/Time`: The date and time of the crash.
- `Launch Time`: The date and time the app launched.
- `OS Version`: The operating system version, including the build number, on which the crash occurred.
The `AppVariant` field contains three values separated by colons, for example, `1:iPhone10,6:12.2`. These fields represent:
- An internal system value. This value isn’t useful for diagnosing a crash. In the example, this value is `1`.
#### 
Every crash report contains exception information. This information section tells you how the process quit, but it may not fully explain why the app quit. This information is important, but is often overlooked.
```other
Exception Type:  EXC_BREAKPOINT (SIGTRAP)
Exception Codes: 0x0000000000000001, 0x0000000102afb3d0
```

- `Exception Type`: The name of the Mach exception that quit the process, along with the name of the corresponding BSD signal in parentheses. See .
- `Exception Subtype`: The human-readable description of the exception codes.
- `Exception Message`: Additional human-readable information extracted from the exception codes.
- `Triggered by Thread` or `Crashed Thread`: The thread on which the exception originated.
#### 
The operating system sometimes includes additional diagnostic information. This information uses a variety of formats, depending on reason for the crash, and isn’t present in every crash report.
Framework error messages occurring just before the process exits appear in the `Application Specific Information` field. In this example, the  framework logged an error about incorrect use of a dispatch queue:
```other
Application Specific Information:
BUG IN CLIENT OF LIBDISPATCH: dispatch_sync called on queue already owned by current thread
```

> **note:** `Application Specific Information` is sometimes elided from a crash report to avoid logging privacy-sensitive information in the message.
Process exits due to a watchdog violation contain a `Termination Description` field with information about why the watchdog triggered.
Process exits due to a watchdog violation contain a `Termination Description` field with information about why the watchdog triggered.
```other
Termination Description: SPRINGBOARD, 
    scene-create watchdog transgression: application<com.example.MyCoolApp>:667
    exhausted real (wall clock) time allowance of 19.97 seconds 
```

Process crashes due to a memory access issue contain information about the virtual memory regions in the `VM Region Info` field.
 goes into more detail about watchdog terminations and how to interpret this information.
Process crashes due to a memory access issue contain information about the virtual memory regions in the `VM Region Info` field.
```other
VM Region Info: 0 is not in any region.  Bytes before following region: 4307009536
      REGION TYPE                      START - END             [ VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->  
      __TEXT                 0000000100b7c000-0000000100b84000 [   32K] r-x/r-x SM=COW  ...pp/MyGreatApp
```

#### 
The system captures each thread of the crashed process as a backtrace, documenting the code running on the thread when the process ends. The backtraces are similar to what you see when you pause the process with the debugger. Crashes caused by a language exception include an additional backtrace, the `Last Exception Backtrace`, located before the first thread. If your crash report contains a `Last Exception Backtrace`, see  for information specific to language exception crashes.
The first line of each backtrace lists the thread number and the thread name. For privacy reasons, crash reports delivered through the  in Xcode don’t contain thread names. This example shows the backtraces for three threads; `Thread 0` crashed, and is identified as the app’s main thread by its name:
```other
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   TouchCanvas                       0x0000000102afb3d0 CanvasView.updateEstimatedPropertiesForTouches(_:) + 62416 (CanvasView.swift:231)
1   TouchCanvas                       0x0000000102afb3d0 CanvasView.updateEstimatedPropertiesForTouches(_:) + 62416 (CanvasView.swift:231)
2   TouchCanvas                       0x0000000102af7d10 ViewController.touchesMoved(_:with:) + 48400 (<compiler-generated>:0)
3   TouchCanvas                       0x0000000102af80b8 @objc ViewController.touchesMoved(_:with:) + 49336 (<compiler-generated>:0)
4   UIKitCore                         0x00000001ba9d8da4 forwardTouchMethod + 328
5   UIKitCore                         0x00000001ba9d8e40 -[UIResponder touchesMoved:withEvent:] + 60
6   UIKitCore                         0x00000001ba9d8da4 forwardTouchMethod + 328
7   UIKitCore                         0x00000001ba9d8e40 -[UIResponder touchesMoved:withEvent:] + 60
8   UIKitCore                         0x00000001ba9e6ea4 -[UIWindow _sendTouchesForEvent:] + 1896
9   UIKitCore                         0x00000001ba9e8390 -[UIWindow sendEvent:] + 3352
10  UIKitCore                         0x00000001ba9c4a9c -[UIApplication sendEvent:] + 344
11  UIKitCore                         0x00000001baa3cc20 __dispatchPreprocessedEventFromEventQueue + 5880
12  UIKitCore                         0x00000001baa3f17c __handleEventQueueInternal + 4924
13  UIKitCore                         0x00000001baa37ff0 __handleHIDEventFetcherDrain + 108
14  CoreFoundation                    0x00000001b68a4a00 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 24
15  CoreFoundation                    0x00000001b68a4958 __CFRunLoopDoSource0 + 80
16  CoreFoundation                    0x00000001b68a40f0 __CFRunLoopDoSources0 + 180
17  CoreFoundation                    0x00000001b689f23c __CFRunLoopRun + 1080
18  CoreFoundation                    0x00000001b689eadc CFRunLoopRunSpecific + 464
19  GraphicsServices                  0x00000001c083f328 GSEventRunModal + 104
20  UIKitCore                         0x00000001ba9ac63c UIApplicationMain + 1936
21  TouchCanvas                       0x0000000102af16dc main + 22236 (AppDelegate.swift:12)
22  libdyld.dylib                     0x00000001b6728360 start + 4

Thread 1:
0   libsystem_pthread.dylib           0x00000001b6645758 start_wqthread + 0

Thread 2:
0   libsystem_pthread.dylib           0x00000001b6645758 start_wqthread + 0
...
```

```
After the thread number, each line of a backtrace represents a stack frame in the backtrace.
```other
0   TouchCanvas                       0x0000000102afb3d0 CanvasView.updateEstimatedPropertiesForTouches(_:) + 62416 (CanvasView.swift:231)
```

- `TouchCanvas`. The name of the binary containing the function that is executing.
- `62416`. The number after the `+` is the byte offset from the function’s entry point to the current instruction in the function.
- `CanvasView.swift:231`. The file name and line number containing the code, if you have a `dSYM` file for the binary.
#### 
The thread state section of a crash report lists the CPU registers and their values for the crashed thread when the app crashes. Understanding the thread state is an advanced topic that requires understanding of the application binary interface (ABI). See .
```other
Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000001   x1: 0x0000000000000000   x2: 0x0000000000000000   x3: 0x000000000000000f
    x4: 0x00000000000001c2   x5: 0x000000010327f6c0   x6: 0x000000010327f724   x7: 0x0000000000000120
    x8: 0x0000000000000001   x9: 0x0000000000000001  x10: 0x0000000000000001  x11: 0x0000000000000000
   x12: 0x00000001038612b0  x13: 0x000005a102b075a7  x14: 0x0000000000000100  x15: 0x0000010000000000
   x16: 0x00000001c3e6c630  x17: 0x00000001bae4bbf8  x18: 0x0000000000000000  x19: 0x0000000282c14280
   x20: 0x00000001fe64a3e0  x21: 0x4000000281f1df10  x22: 0x0000000000000001  x23: 0x0000000000000000
   x24: 0x0000000000000000  x25: 0x0000000282c14280  x26: 0x0000000103203140  x27: 0x00000001bacf4b7c
   x28: 0x00000001fe5ded08   fp: 0x000000016d311310   lr: 0x0000000102afb3d0
    sp: 0x000000016d311200   pc: 0x0000000102afb3d0 cpsr: 0x60000000
   esr: 0xf2000001  Address size fault
```

#### 
The binary images section of a crash report lists all code loaded in the process at the time that it crashes, such as the app executable and system frameworks. Each line in the Binary Images section represents a single binary image. iOS, iPadOS, tvOS, visionOS, and watchOS use the following format:
```other
Binary Images:
0x102aec000 - 0x102b03fff TouchCanvas arm64  <fe7745ae12db30fa886c8baa1980437a> /var/containers/Bundle/Application/51346174-37EF-4F60-B72D-8DE5F01035F5/TouchCanvas.app/TouchCanvas
...
```

- `TouchCanvas`. The binary name.
- `arm64`. The CPU architecture from the binary image that the operating system loaded into the process.
- `/var/containers/.../TouchCanvas.app/TouchCanvas`. The path to the binary on disk. macOS replaces user-identifable path components with placeholder values to protect privacy.
macOS uses the following format for this section:
```other
Binary Images:
       0x1025e5000 -        0x1025e6ffb +com.example.apple-samplecode.TouchCanvas (1.0 - 1) <5ED9BD63-2A55-3DDD-B3FF-EFCF61382F6F> /Users/USER/*/TouchCanvas.app/Contents/MacOS/TouchCanvas
```

- `+com.example.apple-samplecode.TouchCanvas`. The  of the binary. The `+` prefix indicates the binary is not part of macOS.
- `1.0 - 1`. The binary’s  and .

## Gaining performance insights with the Metal Performance HUD
> https://developer.apple.com/documentation/xcode/gaining-performance-insights-with-metal-performance-hud

### 
You can also generate a performance report covering a specific duration to gain deeper insight into your app’s performance during that timeframe. For more information, see 
Turn on performance insights by setting the `MTL_HUD_INSIGHTS_ENABLED` environment variable to `1`, or through the configuration panel on macOS. See  for more details.
```None
export MTL_HUD_INSIGHTS_ENABLED=1
```

#### 

## Generating performance reports with the Metal Performance HUD
> https://developer.apple.com/documentation/xcode/generating-performance-reports-with-metal-performance-hud

### 
#### 
You can also specify a path to save the performance report to by using the `MTL_HUD_REPORT_URL` environment variable.
You can also specify a path to save the performance report to by using the `MTL_HUD_REPORT_URL` environment variable.
```None
export MTL_HUD_REPORT_URL=<path>
```

#### 

## Giving external agents access to Xcode
> https://developer.apple.com/documentation/xcode/giving-external-agents-access-to-xcode

### 
#### 
#### 
In Terminal, use the `xcrun mcpbridge` command to configure the external agent to use Xcode Tools. For example, run the following command in Terminal to give Claude Code access to your open project and Xcode capabilities:
```None
claude mcp add --transport stdio xcode -- xcrun mcpbridge
```

```
For Codex, run:
```None
codex mcp add xcode -- xcrun mcpbridge
```

To verify the configuration, enter `claude mcp list` or `codex mcp list` in Terminal.

## Identifying high-memory use with jetsam event reports
> https://developer.apple.com/documentation/xcode/identifying-high-memory-use-with-jetsam-event-reports

### 
#### 
The jetsam event report records how much memory each process used before jettisoning an app. The virtual memory system allocates and manages memory in chunks, called , and the report lists the memory use as the number of memory pages used. To convert the number of memory pages into the bytes of memory your app used, you need to know the , which is the number of bytes in one memory page.
The `pageSize` field in the jetsam event report header records the number of bytes in each memory page. In addition to the page size, the header of a jetsam report describes the overall device environment, such as the operating system version and hardware model. In this example, the page size is 16,384 bytes, or 16 KB.
```other
"crashReporterKey" : "b9aa251a63bd9e743afbb906f43eb7ea5f206292",
"product" : "iPad8,2",
"incident" : "32B05E3C-CB45-40F8-BA66-5668779740E1",
"date" : "2019-10-10 23:30:39.48 -0700",
"build" : "iPhone OS 13.1.2 (17A860)",
"memoryStatus" : {
   "pageSize" : 16384,
},
"largestProcess" : "OneCoolApp",

```

#### 
This example is one process entry in the `processes` array:
This example is one process entry in the `processes` array:
```other
{
    "uuid" : "a02fb850-9725-4051-817a-8a5dc0950872",
    "states" : [
      "frontmost"
    ],
    "lifetimeMax" : 92802,
    "purgeable" : 0,
    "coalition" : 68,
    "rpages" : 92802,
    "reason" : "per-process-limit",
    "name" : "MyCoolApp"
}
```

If the jettisoned process is your app, the value of the `reason` key explains the conditions that led to the jetsam event:
- `vm-pageshortage`: The system experienced memory pressure and needed to free background process memory for the current foreground app.
- `highwater`: A system daemon exceeded its highest-expected memory footprint.
- `jettisoned`: The system jettisoned the process for some other reason.
Each item in the `processes` array also has the following keys, which provide additional information for diagnosing the issue.
- `states`: Describes the app’s current memory use state, such as using memory as the `frontmost` app, or `suspended` and not actively using memory.
- `lifetimeMax`: The highest number of memory pages allocated during the lifetime of the process.
- `name`: The process name. See if this name matches a binary from your app, or belongs to another app or system process.
#### 

## Identifying the cause of common crashes
> https://developer.apple.com/documentation/xcode/identifying-the-cause-of-common-crashes

### 
#### 
Swift uses memory safety techniques to catch programming errors early. If the Swift runtime encounters a programming error, the runtime catches the error and intentionally crashes the app. These crashes have an identifiable pattern in the crash report. On ARM processors, the exception info in the crash report looks like:
```other
Exception Type:  EXC_BREAKPOINT (SIGTRAP)
...
Termination Signal: Trace/BPT trap: 5
Termination Reason: Namespace SIGNAL, Code 0x5
```

```
On Intel processors (including apps for macOS, Mac Catalyst, and the simulators for iOS, iPadOS, tvOS, and watchOS), the exception info in the crash report looks like:
```other
Exception Type:        EXC_BAD_INSTRUCTION (SIGILL)
...
Exception Note:        EXC_CORPSE_NOTIFY

Termination Signal:    Illegal instruction: 4
Termination Reason:    Namespace SIGNAL, Code 0x4
```

```
Additionally, the crash report shows the thread that encountered the error, with frame 0 in the backtrace identifying the specific line of code in your app containing the error, such as:
```other
Thread 0 Crashed:
0   MyCoolApp                         0x0000000100a71a88 @objc ViewController.viewDidLoad() (in MyCoolApp) (ViewController.swift:18)
```

#### 
The Objective-C runtime can detect when multiple threads concurrently write values to the same strong property; or when a thread reads a value from a strong property while another thread writes a value to the property. When the Objective-C runtime detects this situation, it catches the error and intentionally crashes the app. In most cases, the exception info in the crash report looks like this:
```console
Exception Type:    EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x400000000000bad0 -> 0x000000000000bad0 (possible pointer authentication failure)
```

```
If the crash occurs in a 32-bit process on watchOS, the exception info in the crash report looks like this:
```console
Exception Type:    EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x0000bad0
```

```
To resolve this type of crash, restructure your code so that different threads don’t concurrently read and write the property’s value. Alternatively, add the `atomic` keyword to the property declaration and ensure that all threads access the value through the property accessors:
```objc
@interface MyController : NSObject { }

@property (atomic, strong) MyAppService *service;

- (void)connectToService;
- (MyServiceResult *)updateServiceStatus;

@end

@implementation MyController

- (void)connectToService {
    dispatch_async(aQueue, ^{
        self.service = [[MyAppService alloc] init];
        [self.service connect];
    });
}

- (MyServiceResult *)updateServiceStatus {
    return self.service.status;
}

@end
```

#### 
Apple’s system frameworks throw language exceptions when they encounter certain types of programming errors at runtime, such as accessing an array with an index that’s out-of-bounds. To determine whether a crash is due to a language exception, first confirm that the crash report contains this pattern:
```other
Exception Type:  EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
```

A crash due to a language exception also has a `Last Exception Backtrace` in the crash report:
```
A crash due to a language exception also has a `Last Exception Backtrace` in the crash report:
```other
Last Exception Backtrace:
0   CoreFoundation                    0x19aae2a48 __exceptionPreprocess + 220
1   libobjc.A.dylib                   0x19a809fa4 objc_exception_throw + 55
```

#### 
The operating system employs a watchdog to monitor app responsiveness. If an app is unresponsive, the watchdog terminates it, which creates a crash report with the `0x8badf00d` code in the Termination Reason:
```other
Exception Type:  EXC_CRASH (SIGKILL)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Termination Reason: Namespace SPRINGBOARD, Code 0x8badf00d
```

```
In the crash report for an unresponsive app, the `Termination Description` contains information from the watchdog about how the app spent its time. For example:
```other
Termination Description: SPRINGBOARD, 
    scene-create watchdog transgression: application<com.example.MyCoolApp>:667
    exhausted real (wall clock) time allowance of 19.97 seconds 
    | ProcessVisibility: Foreground 
    | ProcessState: Running 
    | WatchdogEvent: scene-create 
    | WatchdogVisibility: Foreground 
    | WatchdogCPUStatistics: ( 
    |  "Elapsed total CPU time (seconds): 15.290 (user 15.290, system 0.000), 28% CPU", 
    |  "Elapsed application CPU time (seconds): 0.367, 1% CPU" 
    | )
```

#### 
 are objects that are messaged by the Objective-C runtime after they’re deallocated from memory and no longer exist. Messaging a deallocated object can cause a crash in the , `objc_retain`, or `objc_release` functions of the Objective-C runtime, such as this example with :
```other
Thread 0 Crashed:
0   libobjc.A.dylib                   0x00000001a186d190 objc_msgSend + 16
1   Foundation                        0x00000001a1f31238 __NSThreadPerformPerform + 232
2   CoreFoundation                    0x00000001a1ac67e0 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 24
```

A different pattern that also indicates a zombie object is the presence of a `Last Exception Backtrace` with a stack frame containing the  method:
```
A different pattern that also indicates a zombie object is the presence of a `Last Exception Backtrace` with a stack frame containing the  method:
```other
Last Exception Backtrace:
0   CoreFoundation                    0x1bf596a48 __exceptionPreprocess + 220
1   libobjc.A.dylib                   0x1bf2bdfa4 objc_exception_throw + 55
2   CoreFoundation                    0x1bf49a5a8 -[NSObject+ 193960 (NSObject) doesNotRecognizeSelector:] + 139
```

#### 
When your app uses memory in an unexpected way, you’ll receive a crash report about a memory access issue. These types of crash reports have a `EXC_BAD_ACCESS` exception type, plus additional information in the `VM Region Info` field. For example:
```other
Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x0000000000000000
VM Region Info: 0 is not in any region.  Bytes before following region: 4307009536

      REGION TYPE                      START - END             [ VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->
      __TEXT                 0000000100b7c000-0000000100b84000 [   32K] r-x/r-x SM=COW  ...pp/MyGreatApp
```

#### 
If an app crashes because it’s missing a required framework, the crash report contains the `EXC_CRASH (SIGABRT)` exception code. You’ll also find a `Termination Description` in the crash report, identifying the specific framework that the dynamic linker, `dyld`, couldn’t locate. Here’s an example, with extra line breaks included for readability:
```other
Exception Type: EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note: EXC_CORPSE_NOTIFY
Termination Description: DYLD, dependent dylib '@rpath/MyFramework.framework/MyFramework'
    not found for '<path>/MyCoolApp.app/MyCoolApp', tried but didn't find: 
    '/usr/lib/swift/MyFramework.framework/MyFramework' 
    '<path>/MyCoolApp.app/Frameworks/MyFramework.framework/MyFramework' 
    '@rpath/MyFramework.framework/MyFramework' 
    '/System/Library/Frameworks/MyFramework.framework/MyFramework'
```


## Improving app responsiveness
> https://developer.apple.com/documentation/xcode/improving-app-responsiveness

### 
#### 
Below there are three almost identical code examples. The first one shows how to correctly get off of the main actor if you can wrap the long-running work in a `nonisolated` `async` function. The second example shows a common mistake where the code looks as if it avoids the hang, but doesn’t. This example just causes a hang a little later due to a `Task` implicitly inheriting the actor-constraint from its surrounding context. The last example shows how to break this implicit actor-constraint inheritance by using a detached `Task` instead. The subtle differences in these examples cause completely different execution behavior. Be aware of these in your own Swift concurrency code.
The following code example shows how to successfully get your long-running work off of the main actor if the long-running function is `async` and `nonisolated`, or if you can wrap it in such a function:
```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Button("I don't hang") {
            Task { 
                await doLongRunningWork()
                updateUI()
            }
        }
    }
    @MainActor func updateUI() { /* ... */ }
}
private func doLongRunningWork() async { /* a lot of work */ } // Implicitly nonisolated due to being a free function
```

Both the `nonisolated` aspect of the function and the `async` nature of it are essential for enabling this behavior. When the long-running work only executes synchronously, it is  to wrap it in a `Task`. For example, the following code produces a hang:
```swift
// This code produces a hang. This is only for illustration purposes.
import SwiftUI

struct ContentView: View {
    var body: some View {
        Button("Hang later!") {
            // Don't do this. Use Task.detached {} instead or make `doLongRunningWork()` async.
            Task {
                doLongRunningWork()
                updateUI()
            }
        }
    }
}
private func doLongRunningWork() { /* a lot of work */ } // Nonisolated, but synchronous.
```

If making the function `async` isn’t an option, wrap it in a `detached` task to explicitly opt out from inheriting the surrounding execution context.
By default, tasks inherit their context from their enclosing context during creation. Therefore, the newly created task in the `body` property’s context is also constrained to the main actor, which means it can only execute on the main actor and does still block the main actor for a long amount of time. This just  the hang until after the immediate button action finishes. Swift concurrency enqueues the task on the main actor and executes it there shortly after, which keeps the main thread busy and prevents it from handling incoming events.
If making the function `async` isn’t an option, wrap it in a `detached` task to explicitly opt out from inheriting the surrounding execution context.
```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Button("Hang in UI interaction") {
            Task.detached {
                doLongRunningWork()
                await updateUI()
            }
        }
    }
}
private func doLongRunningWork() { /* a lot of work */ } // Nonisolated, but synchronous.
```

#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 

## Improving build efficiency with good coding practices
> https://developer.apple.com/documentation/xcode/improving-build-efficiency-with-good-coding-practices

### 
#### 
When you import headers into your source files, always include the name of the parent framework or library in your import statement. In C-based code, importing headers usually copies the contents of the header file into your source. When you include the framework name, the compiler has the option to use module maps to import the headers, which significantly reduces importation time. With module maps, the compiler loads and processes the framework’s header files once, and caches the resulting symbol information on disk. When you import the same framework from another source file, the compiler reuses the cached data, eliminating the need to again read and preprocess the header files.
Include framework names for both system frameworks and any custom frameworks you create in your projects. The following example shows import statements for both a system and custom framework, both of which have module maps. The last import statement continues to load and process the header file contents directly, rather than using an available module map.
```occ
// Imports the framework’s module map
#import <UIKit/UIKit.h>
#import <PetKit/PetKit.h>     // Custom framework

// Performs a textual inclusion of the header file.
#import "MyHeader.h"

```

#### 
#### 
The Swift compiler is capable of inferring the type of a variable from the value you assign to it. For simple values, the inference process is quick. For example, if you assign the value `0.0` to a property, the compiler can quickly determine that the type is a floating-point number. However, if you assign a complex value to a variable, the compiler must perform extra work to compute any type information.
Consider the following structure, in which the `bigNumber` property has no explicit type information. To determine the type of that property, the Swift compiler must evaluate the results of the  function, which takes a nontrivial amount of time.
```swift
struct ContrivedExample {
   var bigNumber = [4, 3, 2].reduce(1) {
      soFar, next in
      pow(next, soFar)
   }
}
```

```
Instead of letting the compiler determine the type, the best practice is to provide the type explicitly as shown in the example below. Providing explicit type information reduces the work the compiler must do, and also allows it to do more error checking.
```swift
struct ContrivedExample {
   var bigNumber : Double = [4, 3, 2].reduce(1) {
      soFar, next in
      pow(next, soFar)
   }
}
```

#### 
Delegates are a standard design pattern on Apple platforms, and provide a useful way to communicate between objects. Although delegation enables communication between arbitrary objects, always provide explicit type information for your delegate objects.
Consider the following example of a delegate declared as an optional object of any type. Although this declaration is perfectly legal, it actually creates more work for the compiler. The compiler must assume that any object in your project or referenced frameworks contains the function, and so it searches your entire project to make sure that function exists somewhere.
```swift
weak var delegate: AnyObject?
func reportSuccess() {
   delegate?.myOperationDidSucceed(self)
}
```

```
Instead of using any object, a better approach is to supply specific type information. Typically, you specify the type information using a delegate protocol, as shown in the example below. An explicit protocol helps the compiler find the method more quickly. It also allows the compiler to perform additional type checking for objects you assign to the `delegate` property.
```swift
weak var delegate: MyOperationDelegate?
func reportSuccess() {
   delegate?.myOperationDidSucceed(self)
}

protocol MyOperationDelegate {
   func myOperationDidSucceed(_ operation: MyOperation)
}
```

#### 
The Swift language allows you to write code in very expressive ways, but make sure your code doesn’t affect compile times. Consider an example of a function that uses the `reduce` function to sum a set of values. If you pass `nil` for all the arguments, the function returns `nil`, but if you pass one or more arguments, it sums the sum of those arguments. The function takes advantage of a Swift feature, in which the compiler uses the one-line expression in the closure to determine the return type of that closure.
```swift
func sumNonOptional(i: Int?, j: Int?, k: Int?) -> Int? {
   return [i, j, k].reduce(0) {
      soFar, next in
      soFar != nil && next != nil ? soFar! + next! : (soFar != nil ? soFar! : (next != nil ? next! : nil))
   }
}
```

Although this function represents legal Swift syntax, the one-line closure makes the code hard to read and harder for the compiler to evaluate. In fact, the compiler aborts with an error that states it cannot type-check the expression in a reasonable amount of time. The one-line closure is also unnecessary. The definition of the  function causes it to return the same type you pass in, which in this case is an optional integer.
Rather than use such a complex expression, it’s better to create something simpler and more readable. The following code offers the same behavior as the single-line closure version, but is easier to read and compiles quickly.
```swift
func sumNonOptional(i: Int?, j: Int?, k: Int?) -> Int? {
   return [i, j, k].reduce(0) {
      soFar, next in
      if let soFar = soFar {
         if let next = next { return soFar + next }
         return soFar
      } else {
         return next
      }
   }
}
```


## Improving code assessment by organizing tests into test plans
> https://developer.apple.com/documentation/xcode/organizing-tests-to-improve-feedback

### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
To run tests using a specific test plan from the command-line, you must explicitly name the test plan to use. To discover the test plans for `SampleApp`, run the following:
```zsh
% xcodebuild -scheme SampleApp -showTestPlans
```

```
To run the tests specified in the “Performance Tests” test plan, run the following:
```zsh
% xcodebuild -scheme SampleApp test -testPlan Performance\ Tests
```

```
To run the tests in the “Performance Tests” test plan, using only the configuration called “My Config”, run the following:
```zsh
% xcodebuild -scheme SampleApp test -testPlan Performance\ Tests --only-test-configuration My\ Config
```

```
To run the tests in the “Performance Tests” test plan, using all configurations except “My Config”, run the following:
```zsh
% xcodebuild -scheme SampleApp test -testPlan Performance\ Tests --skip-test-configuration My\ Config
```


## Improving your app’s rendering efficiency
> https://developer.apple.com/documentation/xcode/improving-your-app-s-rendering-efficiency

### 
#### 
#### 
#### 
#### 
#### 
Where possible, use  to play media assets, as it’s optimized to efficiently render audio and video. If you need to use lower-level APIs, measure your app’s power use, and choose the most efficient approach that supports your app’s features. For example,  typically uses less power to play a video than .
When you use  to decode video frames that you display in an , pass  as an image buffer attribute to  so that Video Toolbox chooses the most efficient pixel format:
```swift
_ = VTDecompressionSessionCreate(allocator: nil,
                                 formatDescription: formatDescription,
                                 decoderSpecification: nil,
                                 imageBufferAttributes: [kCVPixelBufferIOSurfaceCoreAnimationCompatibilityKey],
                                 decompressionSessionOut: &decompressionSession)
```

#### 

## Including notes for testers with a beta release of your app
> https://developer.apple.com/documentation/xcode/including-notes-for-testers-with-a-beta-release-of-your-app

### 
#### 
#### 
#### 
#### 
You can use a custom build script to generate the notes during an Xcode Cloud build. The following example provides the last three commit messages from the GIT log as the tester notes:
```None
#!/bin/zsh
#  ci_post_xcodebuild.sh

if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
  TESTFLIGHT_DIR_PATH=../TestFlight
  mkdir $TESTFLIGHT_DIR_PATH
  git fetch --deepen 3 && git log -3 --pretty=format:"%s" >! $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt
fi
```


## Installing the command-line tools
> https://developer.apple.com/documentation/xcode/installing-the-command-line-tools

### 
#### 
#### 
#### 
You can download and install the Command Line Tools for Xcode package from the command line, using the `xcode-select` command. In Terminal, enter `xcode-select` with the `--install` option, like in the following example:
```None
% xcode-select --install 
xcode-select: note: install requested for command line developer tools
```

#### 
After you install the Command Line Tools for Xcode package, verify that its version matches the one you intend to use. To check the version of the Command Line Tools for Xcode package, run the `pkgutil` command with the `--pkg-info` option in Terminal:
```None
% pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
```

```
For example, the following command lists the “Command Line Tools for Xcode 26.1 beta” package:
```None
% pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
package-id: com.apple.pkg.CLTools_Executables
version: 26.1.0.0.1.1760670222
volume: /
location: /
install-time: 1761350460
```

You can find the entire list of command-line tools the package includes at `/Library/Developer/CommandLineTools/usr/bin`.
#### 
#### 
To remove the package from your Mac, run the `sudo rm` command with the `-rf` option in Terminal:
To remove the package from your Mac, run the `sudo rm` command with the `-rf` option in Terminal:
```None
% sudo rm -rf /Library/Developer/CommandLineTools
```

> **note:** The `sudo` command requires administrator privileges. Enter your administrator password when the system prompts you.
To delete the package receipt, run the `sudo pkgutil` command with the `--forget` option in Terminal:
After removing the package, you’ll continue to receive new releases of the package in Software Update on your Mac. Delete the package receipt to opt out of software updates for the package.
To delete the package receipt, run the `sudo pkgutil` command with the `--forget` option in Terminal:
```None
% sudo pkgutil --forget com.apple.dt.commandlinetools
```

If the task succeeds, `pkgutil` prints the following message:
```
If the task succeeds, `pkgutil` prints the following message:
```None
% sudo pkgutil --forget com.apple.dt.commandlinetools
No receipt for 'com.apple.dt.commandlinetools' found at '/'.
```


## Integer overflow
> https://developer.apple.com/documentation/xcode/integer-overflow

### 
#### 
In the following code, the `x` variable has the maximum `int32_t` value before the addition, and the result of the addition overflows `x`, which the optimizer may not handle in a predictable way:
```occ
int32_t x = (1U << 31) - 1;
x += 1; // Error: the add result can't fit in x
```

> **note:** With the exception of the signed division check, enabling the `-fwrapv` compiler flag disables UBSan overflow checks.

## Interpreting the JSON format of a crash report
> https://developer.apple.com/documentation/xcode/interpreting-the-json-format-of-a-crash-report

### 
Typical JSON parsers expect a single JSON object in the body of the file. The IPS file for a crash report contains two JSON objects: an object containing IPS metadata about the report incident and an object containing the crash report data. When parsing the file, extract the JSON for the metadata object from the first line. If the `bug_type` property of the metadata object is `309`, the log type for crash reports, you can extract the JSON for the crash report data from the remainder of the text.
The following example reads the contents of a crash report into a dictionary:
```swift
    do {
        let content = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)

        /// Read the first line, the metadata object, into a dictionary.
        let metadataRange = content.lineRange(for: ..<content.startIndex)
        let metadataJSON = content[metadataRange].data(using: .utf8)
        let metadata = try JSONSerialization.jsonObject(with: metadataJSON!) as! Dictionary<String, Any>

        /// Check the `bug_type` property of the metadata for type `309`, the log type for crash reports.
        let logType = "\(metadata["bug_type"] ?? "(unknown)")"
        guard logType == "309" else {
            // Handle the error.        
            fatalError("Log type \(logType) is not a crash report.")
        }

        /// Read the remainder of the file, the crash report object, into a dictionary.
        let reportRange = content.lineRange(for: metadataRange.upperBound..<content.endIndex)
        let reportJSON = content[reportRange].data(using: .utf8)
        let report = try JSONSerialization.jsonObject(with: reportJSON!) as! Dictionary<String, Any>

        return report
    } catch {
        // Handle the error.
        fatalError("*** An error occurred while reading the crash report: \(error.localizedDescription) ***")
    }
```

#### 
| `name` | String | The name of the process the report applies to. Usually the process executable name. |
| `bundleID` | String | The bundle identifier of the process the report applies to; see . |
| `build_version` | String | The bundle version string of the process the report applies to; see . |
| `incident_id` | String | A unique identifier for the report. Two reports never share the same identifier. |
| `platform` | Number | A number identifying the platform the process was running on. For the meaning of these values, see . |
#### 
| `bundleInfo` | Dictionary | Bundle information for the process that crashed. For a description of this object‘s properties, see . |
| `captureTime` | String | The date and time of the crash. This appears in a translated report under Date/Time. |
| `coalitionName` | String | The name of the coalition containing the process. For more details, see the description above on `coalitionID`. |
| `exception` | Dictionary | Information about how the process terminated. For a description of this object‘s properties, see . |
| `modelCode` | String | The specific device model the process was running on. This appears in a translated report under Hardware Model. |
| `parentProc` | String | The name of the process that launched the crashed process. This appears in a translated report under Parent Process. |
| `procLaunch` | String | The date and time the process launched. This appears in a translated report under Launch Time. |
| `procRole` | String | The task role assigned to the process at the time of termination; see . This appears in a translated report under Role. |
| `storeInfo` | Dictionary | Store information about the process that crashed. For a description of this object‘s properties, see . |
| `termination` | Dictionary | Information about the termination of a process by another. For a description of this object‘s properties, see . |
| `translated` | Boolean | A Boolean with a `true` value for a process with X86-64 instructions running translated under Rosetta on Apple silicon. |
| `version` | Number | Crash report schema version. |
#### 
The numeric values for `platform` include:
- `1` for macOS
- `2` for iOS (includes iOS apps running under macOS on Apple silicon)
- `3` for tvOS
- `4` for watchOS
- `6` for Mac Catalyst
- `7` for iOS Simulator
- `8` for tvOS Simulator
- `9` for watchOS Simulator
#### 
| `build` | String | The build number of the operating system. Appears in a translated report inside the parentheses under OS Version. |
| `isEmbedded` | Boolean | A Boolean with a `true` value if the operating system is for an embedded platform. |
| `train` | String | A string containing the platform and OS version number. Appears in a translated report under OS Version. |
#### 
| `CFBundleIdentifier` | String | The bundle identifier for the process that crashed. Appears in a translated report under Identifier. |
| `CFBundleVersion` | String | The bundle version for the process that crashed; see . Appears in a translated report under Version. |
#### 
| `applicationVariant` | String | The specific variant of your app produced by app thinning. Appears in a translated report under App Variant. |
| `itemID` | String | The Apple identifier, a unique record for titles in the store. |
#### 
| `subtype` | String | The human-readable description of the exception codes. This appears in a translated report under Exception Subtype. |
#### 
| `flags` | Number | Options set by the terminating process for how the process terminates. |
#### 
| `id` | Number | The thread’s index number. |
#### 
| `symbol` | String | In a fully symbolicated crash report, the name of the function that is executing. |
#### 
| `arch` | String | The CPU architecture from the binary image that the operating system loaded into the process. |
| `name` | String | The binary name. |
| `path` | String | The path to the binary on disk. macOS replaces user-identifable path components with placeholder values to protect privacy. |
#### 
JSON stores numeric values as decimal numbers. Many of these numeric values, such as error codes and memory addresses, appear in a translated report as hexadecimal numbers to make them easier to interpret.
You can use the following to print a hexadecimal representation of the numbers from the decimal representation found in the JSON.
```swift
import Foundation

let decimal = 2343432205

print(String(format: "0x%lx", decimal))
// Prints "0x8badf00d".
```


## Invalid Boolean value
> https://developer.apple.com/documentation/xcode/invalid-boolean

### 
#### 
The intent of the following code is to call the `success` function when `result` is nonzero. However, because it uses a Boolean check, the compiler may, as an optimization, only emit instructions that check the least-significant bit of `predicate`, which is `0`, causing a logic error.
```occ
int result = 2;
bool *predicate = (bool *)&result;
if (*predicate) { // Error: variable is not a valid Boolean
    success();
}
```

Use integer comparison instead of a Boolean check.
```occ
int result = 2;
if (result != 0) { // Correct
  success();
}
```


## Invalid enumeration value
> https://developer.apple.com/documentation/xcode/invalid-enumeration-value

### 
#### 
In the following example, the cast to the `E` type is invalid because `2` isn’t within the enumeration’s range:
In the following example, the cast to the `E` type is invalid because `2` isn’t within the enumeration’s range:
```occ
enum E {
    a = 1
};
int value = 2;
enum E *e = (enum E *)&value;
return *e; // Error: 2 is out of the valid range for E
```


## Invalid float cast
> https://developer.apple.com/documentation/xcode/invalid-float-cast

### 
#### 
The cast from `n` to `m` results in undefined behavior because the destination type can’t represent its value.
The cast from `n` to `m` results in undefined behavior because the destination type can’t represent its value.
```occ
double n = 10e50;
float m = (float)n; // Error: 10e50 can't be represented as a float.
```


## Invalid object size
> https://developer.apple.com/documentation/xcode/invalid-object-size

### 
#### 
In the following example, the cast from `Base *` to `Derived *` is suspect because `Base` isn’t large enough to contain an instance of `Derived`:
In the following example, the cast from `Base *` to `Derived *` is suspect because `Base` isn’t large enough to contain an instance of `Derived`:
```occ
struct Base {
    int pad1;
};
struct Derived : Base {
    int pad2;
};
Derived *getDerived() {
    return static_cast<Derived *>(new Base); // Error: invalid downcast
}
```

One way to fix this issue is to avoid the downcast, such as by using instances of the `Derived` object wherever you need them.

## Invalid shift
> https://developer.apple.com/documentation/xcode/invalid-shift

### 
#### 
The following code shows a shift with an invalid shift amount because the destination type can’t represent the result:
```occ
int32_t x = 1;
x <<= 32; // Error: (1 << 32) can't be represented in an int32_t
```

Use a larger destination type, such as an `int64_t`.
#### 
In the following code, the second shift overflows `x` because `int32_t` can’t represent `((1U << 31) - 1) << 2`:
In the following code, the second shift overflows `x` because `int32_t` can’t represent `((1U << 31) - 1) << 2`:
```occ
int32_t x = (1U << 31) - 1;
x <<= 2; // Error: the shift result can't fit in x
```

Use a larger destination type, such as an `int64_t`.

## Invalid variable-length array
> https://developer.apple.com/documentation/xcode/invalid-variable-length-array

### 
#### 
In the following code, the call to the `invalid_index_returning_function` function returns a negative number that results in an invalid array:
In the following code, the call to the `invalid_index_returning_function` function returns a negative number that results in an invalid array:
```occ
int invalid_index_returning_function() {
    return -1;
}
int idx = invalid_index_returning_function();
int array[idx]; // Error: invalid array length
```


## Investigating crashes for zombie objects
> https://developer.apple.com/documentation/xcode/investigating-crashes-for-zombie-objects

### 
#### 
The Objective-C runtime can’t message objects deallocated from memory, so crashes often occur in the , `objc_retain`, or `objc_release` functions. For example, a crash where the Objective-C runtime can’t send a message to the deallocated object looks like this:
```other
Thread 0 Crashed:
0   libobjc.A.dylib                   0x00000001a186d190 objc_msgSend + 16
1   Foundation                        0x00000001a1f31238 __NSThreadPerformPerform + 232
2   CoreFoundation                    0x00000001a1ac67e0 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 24
```

```
Here’s another example, where the Objective-C runtime tries to release an object that’s already released:
```other
Thread 2 Crashed:
0   libobjc.A.dylib                 0x00007fff7478bd5c objc_release + 28
1   libobjc.A.dylib                 0x00007fff7478cc8c (anonymous namespace)::AutoreleasePoolPage::pop(void*) + 726
2   com.apple.CoreFoundation        0x00007fff485feee6 _CFAutoreleasePoolPop + 22
```

```
Another pattern that indicates a zombie object is a stack frame for an , which is a method that an object doesn’t implement. Often this kind of crash looks like code where an unexpected type of object is asked to do something it obviously can’t do, such as a number formatter class trying to play a sound. This is because the operating system reused memory that once held the deallocated object, and that memory now contains a different kind of object. A zombie identified by an unrecognized selector has a call stack with the  method:
```other
Last Exception Backtrace:
0   CoreFoundation                    0x1bf596a48 __exceptionPreprocess + 220
1   libobjc.A.dylib                   0x1bf2bdfa4 objc_exception_throw + 55
2   CoreFoundation                    0x1bf49a5a8 -[NSObject+ 193960 (NSObject) doesNotRecognizeSelector:] + 139
```

```
If you reproduce a crash like this when debugging, the console logs additional information:
```other
Terminating app due to uncaught exception 'NSInvalidArgumentException',
    reason: '-[NSNumberFormatter playSound]: 
    unrecognized selector sent to instance 0x28360dac0'
```

#### 

## Investigating memory access crashes
> https://developer.apple.com/documentation/xcode/investigating-memory-access-crashes

### 
A crash due to a memory access issue occurs when an app uses memory in an unexpected way. Memory access problems have numerous causes, such as dereferencing a pointer to an invalid memory address, writing to read-only memory, or jumping to an instruction at an invalid address. These crashes are most often identified by the `EXC_BAD_ACCESS (SIGSEGV)` or `EXC_BAD_ACCESS (SIGBUS)` exceptions in the crash report:
```other
Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x0000000000000000
```

On macOS, bad memory access crashes are occasionally identified only by a signal, such as `SIGSEGV`, `SEGV_MAPERR`, or `SEGV_NOOP`:
```
On macOS, bad memory access crashes are occasionally identified only by a signal, such as `SIGSEGV`, `SEGV_MAPERR`, or `SEGV_NOOP`:
```other
Exception Type: SIGSEGV
Exception Codes: SEGV_MAPERR at 0x41e0af0c5ab8
```

#### 
#### 
The `Exception Subtype` field in the crash report contains a `kern_return_t` value describing the error and the address of the memory that was incorrectly accessed, such as:
```other
Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x0000000000000000
```

On macOS, the `Exception Codes` field contains the exception subtype:
```
On macOS, the `Exception Codes` field contains the exception subtype:
```other
Exception Type:        EXC_BAD_ACCESS (SIGBUS)
Exception Codes:       KERN_MEMORY_ERROR at 0x00000001098c1000
```

- `EXC_ARM_DA_ALIGN`. The crashed thread tried to access memory that isn’t appropriately aligned. This exception code is rare because 64-bit ARM CPUs work with misaligned data. However, you may see this exception subtype if the memory address is both misaligned and located in an unmapped memory region. You may have other crash reports that show a memory access issue with a different exception subtype, which are likely caused by the same underlying memory access issue.
The `arm64e` CPU architecture uses pointer authentication codes with cryptographic signatures to detect and guard against unexpected changes to pointers in memory. A crash due to a possible pointer authentication failure uses the `KERN_INVALID_ADDRESS` exception subtype with an additional message on the end:
```other
Exception Type:  EXC_BAD_ACCESS (SIGBUS)
Exception Subtype: KERN_INVALID_ADDRESS at 0x00006f126c1a9aa0 -> 0x000000126c1a9aa0 (possible pointer authentication failure)
```

#### 
The `VM Region Info` field of the crash report shows the location of the specific memory that your app incorrectly accessed in relation to other sections of the app’s address space. Consider this example:
```other
Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x0000000000000000
VM Region Info: 0 is not in any region.  Bytes before following region: 4307009536
      REGION TYPE                      START - END             [ VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->  
      __TEXT                 0000000100b7c000-0000000100b84000 [   32K] r-x/r-x SM=COW  ...pp/MyGreatApp
```

Consider a different example, for a `KERN_PROTECTION_FAILURE`:
Here, a dereference to unmapped memory triggered the crash, at `0x0000000000000000`. This is an invalid address, specifically a `NULL` pointer, so the exception subtype indicates this with the `KERN_INVALID_ADDRESS` value. The `VM Region Info` field shows the location of this invalid address is 4,307,009,536 bytes before a valid region of memory in the app’s address space.
Consider a different example, for a `KERN_PROTECTION_FAILURE`:
```other
Exception Type:  EXC_BAD_ACCESS (SIGBUS)
Exception Subtype: KERN_PROTECTION_FAILURE at 0x000000016c070a30
VM Region Info: 0x16c070a30 is in 0x16c070000-0x16c074000;  bytes after start: 2608  bytes before end: 13775
      REGION TYPE                      START - END             [ VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      Stack                  000000016bfe8000-000000016c070000 [  544K] rw-/rwx SM=COW  thread 12
--->  STACK GUARD            000000016c070000-000000016c074000 [   16K] ---/rwx SM=NUL  ...for thread 11
      Stack                  000000016c074000-000000016c0fc000 [  544K] rw-/rwx SM=COW  thread 11
```

See  for more information on the `VM Region Info` field.
#### 
- If , `objc_retain`, or `objc_release` is at the top of the backtrace, the crash is due to a zombie object. See .
#### 
There are two categories of memory access issues: invalid memory fetches and invalid instruction fetches. An  occurs when code dereferences an invalid pointer. An  occurs when a function jumps to another function through a bad function pointer, or through a function call to an unexpected object. To determine which type of memory access issue caused a crash, focus on the , a register that contains the address of the instruction that caused the memory access exception. On ARM CPU architectures, this is the `pc` register. On the `x86_64` CPU architecture, this is the `rip` register.
If the program counter register isn’t the same as the exception address, the crash is due to an invalid memory fetch. For example, consider the following macOS crash report on an `x86_64` CPU:
```other
Exception Type:  SIGSEGV
Exception Codes: SEGV_MAPERR at 0x21474feae2c8
...
Thread 12 crashed with X86-64 Thread State:
   rip: 0x00007fff61f5739d    rbp: 0x00007000026c72c0    rsp: 0x00007000026c7248    rax: 0xe85e2965c85400b4 
   rbx: 0x00006000023ee2b0    rcx: 0x00007f9273022990    rdx: 0x00007000026c6d88    rdi: 0x00006000023ee2b0 
   rsi: 0x00007fff358aae0f     r8: 0x00000000000003ff     r9: 0x00006000023edbc0    r10: 0x000021474feae2b0 
   r11: 0x00007fff358aae0f    r12: 0x000060000237af10    r13: 0x00007fff61f57380    r14: 0x00006000023ee2b0 
   r15: 0x0000000000000006 rflags: 0x0000000000010202     cs: 0x000000000000002b     fs: 0x0000000000000000 
    gs: 0x0000000000000000 

```

The program counter register is `0x00007fff61f5739d`, which isn’t the same as the exception’s address of `0x21474feae2c8`. This crash is due to an invalid memory fetch.
If the program counter register is the same as the exception address, the crash is due to an invalid instruction fetch. For example, consider the following iOS crash report on an `arm64` CPU:
```other
Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x0000000000000040
...
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:
0   ???                               0x0000000000000040 0 + 64
...
Thread 0 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000002   x1: 0x0000000000000040   x2: 0x0000000000000001   x3: 0x000000016dcfe080
    x4: 0x0000000000000010   x5: 0x000000016dcfdc8f   x6: 0x000000016dcfdd80   x7: 0x0000000000000000
    x8: 0x000000010210d3c8   x9: 0x0000000000000000  x10: 0x0000000000000014  x11: 0x0000000102835948
   x12: 0x0000000000000014  x13: 0x0000000000000000  x14: 0x0000000000000001  x15: 0x0000000000000000
   x16: 0x000000010210c0b8  x17: 0x00000001021063b0  x18: 0x0000000000000000  x19: 0x0000000102402b80
   x20: 0x0000000102402b80  x21: 0x0000000204f6b000  x22: 0x00000001f6e6f984  x23: 0x0000000000000001
   x24: 0x0000000000000001  x25: 0x00000001fc47b690  x26: 0x0000000102304040  x27: 0x0000000204eea000
   x28: 0x00000001f6e78fae   fp: 0x000000016dcfdec0   lr: 0x00000001021063c4
    sp: 0x000000016dcfdec0   pc: 0x0000000000000040 cpsr: 0x40000000
   esr: 0x82000006 (Instruction Abort) Translation fault

Binary Images:
0x102100000 - 0x102107fff MyCoolApp arm64  <87760ecf8573392ca5795f0db63a44e2> /var/containers/Bundle/Application/686CA3F1-6CC5-4F84-8126-EE22D03BC161/MyCoolApp.app/MyCoolApp

```

The link register contains `0x00000001021063c4`, which is an instruction address in one of the binaries loaded in the app’s process. The Binary Images section of the crash report shows that this address is inside the `MyCoolApp` binary, because that address is in the range `0x102100000-0x102107fff` listed for that binary. With this information, you can use the `atos` command line tool with the `dSYM` file for the binary, and identify the corresponding code located at `0x00000001021063c4`:
```other
% atos -arch arm64 -o MyCoolApp.app.dSYM/Contents/Resources/DWARF/MyCoolApp -l 0x102100000 0x00000001021063c4
-[ViewController loadData] (in MyCoolApp) (ViewController.m:38)
```

 discusses how to use the `atos` command line tool in more detail.

## Localizing and varying text with a string catalog
> https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog

### 
#### 
Before you can translate text, you need to make it localizable. This involves wrapping the user-facing strings in your app in constructs that make them translatable.
In SwiftUI, all string literals within a view are automatically localizable.
```swift
// SwiftUI localizable text.
Text("Title")
```

Make general text localizable using the `String(localized:)` initializer. For apps targeting older platforms, use the `NSLocalizedString` macro.
```
Make general text localizable using the `String(localized:)` initializer. For apps targeting older platforms, use the `NSLocalizedString` macro.
```swift
// General localizable text.
String(localized: "Add a description for your collection here.")
```

```
Add comments to give context and assist localizers when translating your text. Alternatively, you can use coding intelligence later to generate comments after you create a string catalog.
```swift
// Localizable text with comments.
Text("Edit", comment: "The text label on a button to switch to editor mode.")
String(localized: "North America", comment: "The name of a continent.")
```

```
When your code isn’t running in the main bundle, use the `bundle` parameter to tell the system where to find the string at runtime. You can pass the explicit bundle name or pass the  macro to refer to the bundle that contains resources for the current target.
```swift
// Localizable text in a Swift package or framework.
Text("My Collections" bundle: #bundle, comment: "Section title above user-created collections."
```

To refer to the main app, pass `Bundle.main`, which is also the default bundle.
#### 
If your string catalog gets too big, you can create multiple string catalog files within a single Xcode project, and give each a unique name. Then choose which string catalog to use for each translation by passing the string catalog name to the `tableName` or `table` parameter to the respective localization API as follows:
```swift
// A SwiftUI localization example pointing to a specific string catalog.
Text("Explore", tableName: "Navigation")

// A general text localization example pointing to a specific string catalog.
String(localized: "Gorgeous mountain peaks!", table: "LandmarkCollectionData")
```

#### 
#### 
#### 
#### 
| One | `%lld item` |
| Other | `%lld items` |
| Other | `%lld items` |
First localize the text in your app using the value the string is dependent on, using string interpolation.
```swift
Text("\(collection.landmarks.count) items")
```

- Determines which specifier to use for the interpolated string (`%lld` representing a 64-bit integer in this case).
#### 
#### 
#### 
#### 

## Localizing package resources
> https://developer.apple.com/documentation/xcode/localizing-package-resources

### 
#### 
To localize your package’s resources, pass the optional  parameter to the package initializer in your package manifest. This example provides English as the default localization:
```swift
let package = Package(
    name: "MyLibrary",
    defaultLocalization: "en",
    platforms: [
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
)
```

When you declare a value for `defaultLocalization` in the package manifest, Xcode requires the package to contain localized resources.
#### 
Place your `.lproj` directories in a parent directory named `Resources` so you’ll recognize that it contains package resources.
- Subdirectories within a `.lproj` directory.
#### 
2. Create a directory named, for example, `Resources,` for your localized resources.
3. Create a subdirectory named `Base.lproj` and place the package’s storyboards and Interface Builder files in it.
4. Place the `.lproj` directories for all supported languages in the `Resources` directory.
`.process(”path/to/MyViewController.xib”, localization: .base)`
#### 
`let localizedString = NSLocalizedString(”a_localized_string”, bundle: Bundle.module, comment: “a comment”)`.
`UIImage(named: “image name”, in: .module, with: nil)`.

## Localizing strings that contain plurals
> https://developer.apple.com/documentation/xcode/localizing-strings-that-contain-plurals

### 
#### 
Later when you add more localizations, be sure to include the `.stringsdict` file when you select resources for the localization.
#### 
Next, add the plural rules and variants to the development language version of the `.stringsdict` file.
| `[variable]` | A dictionary that specifies the plural variants for a variable in the formatted string. |
| `[variable]` | A dictionary that specifies the plural variants for a variable in the formatted string. |
For example, enter separate dictionaries for the user-facing formatted strings you use in your code. If the formatted string contains multiple variables, enter a separate subdictionary for each variable. In the following `.stringsdict` file, the formatted strings are: `%d home(s) found`, `%d service hour(s)`, and `%d award(s)`:
```other
<plist version="1.0">
    <dict>
        <key>%d home(s) found</key>
        <dict>
            <key>NSStringLocalizedFormatKey</key>
            <string>%#@homes@</string>
            <key>homes</key>
            <dict>
                ...
            </dict>
        </dict>
        <key>%d service hour(s)</key>
        <dict>
            …
        </dict>
        <key>%d award(s)</key>
        <dict>
            …
        </dict>
    </dict>
</plist>
```

The variable dictionary for each formatted string determines which string returns from the  structure,  macro, or similar API in your code. It contains a key-value pair for each grammatical plural variant in the language, called a .
For example, the following `.stringsdict` file with English localization contains plural variants for the `zero`, `one`, and `other` categories. For the `%d home(s) found` formatted string, the API returns `No homes found` for `0`, `%d home found `for` 1`, and `%d homes found` for `other` values.
```other
<plist version="1.0">
    <dict>
        <key>%d home(s) found</key>
        <dict>
            <key>NSStringLocalizedFormatKey</key>
            <string>%#@homes@</string>
            <key>homes</key>
            <dict>
                <key>NSStringFormatSpecTypeKey</key>
                <string>NSStringPluralRuleType</string>
                <key>NSStringFormatValueTypeKey</key>
                <string>d</string>
                <key>zero</key>
                <string>No homes found</string>
                <key>one</key>
                <string>%d home found</string>
                <key>other</key>
                <string>%d homes found</string>
            </dict>
        </dict>
    </dict>
</plist>
```

| `NSStringFormatValueTypeKey` | A string format specifier for a number, as in the letter `d` for an integer. |
#### 
When you export localizations, Xcode automatically adds the language-specific categories for each formatted string to the exported XLIFF files. Localizers just need to enter the translations for each category in the XLIFF file. Then when you import localizations, Xcode updates the localized `.stringsdict` files in your project.
For example, if you export a Russian localization containing the `%d home(s) found` formatted string in a `.stringsdict` file, Xcode adds the `one`, `many`, and `other` categories to the Russian version of the XLIFF file. The localizer inserts the translations and when you import the localization, the `.stringsdict` file contains the correct variable dictionary key-value pairs for Russian.
```other
<plist version="1.0">
    <dict>
       <key>%d home(s) found</key>
         <dict>
            <key>NSStringLocalizedFormatKey</key>
            <string>%#@homes@</string>
            <key>homes</key>
            <dict>
                <key>NSStringFormatSpecTypeKey</key>                
                <string>NSStringPluralRuleType</string>
                <key>NSStringFormatValueTypeKey</key>
                <string>d</string>
                <key>one</key>
                <string>найден %d дом</string>
                <key>many</key>
                <string>найдены %d дома</string>
                <key>other</key>
                <string>найдены %d домов</string>
            </dict>
        </dict>
    </dict>
</plist>
```


## Making dependencies available to Xcode Cloud
> https://developer.apple.com/documentation/xcode/making-dependencies-available-to-xcode-cloud

### 
#### 
#### 
#### 
#### 
1. Create a directory next to your Xcode project or workspace and name it `ci_scripts`.
> **note:** You can use custom build scripts to perform a variety of tasks, but you can’t obtain administrator privileges by using `sudo`.
#### 
- Add the `Pods` directory to your Git repository by committing it.
- Exclude the `Pods` directory from source control by adding it to your `.gitignore` file.
1. Create a post-clone script as described in .
2. Add the command to the script that installs CocoaPods dependencies. The following code snippet shows a basic script to achieve this:
```bash
#!/bin/sh

# Install dependencies you manage with CocoaPods.
pod install
```

#### 

## Misaligned pointer
> https://developer.apple.com/documentation/xcode/misaligned-pointer

### 
#### 
In the following example, the `pointer` variable must have 4-byte alignment, but has only 1-byte alignment:
In the following example, the `pointer` variable must have 4-byte alignment, but has only 1-byte alignment:
```occ
int8_t *buffer = malloc(64);
int32_t *pointer = (int32_t *)(buffer + 1);
*pointer = 42; // Error: misaligned integer pointer assignment
```

Use an assignment function like `memcpy`, which can work with unaligned inputs.
Use an assignment function like `memcpy`, which can work with unaligned inputs.
```occ
int8_t *buffer = malloc(64);
int32_t value = 42;
memcpy(buffer + 1, &value, sizeof(int32_t)); // Correct
```

> **note:** The compiler can often safely optimize calls to `memcpy`, even for unaligned arguments.
#### 
In the following example, the `pointer` variable must have 8-byte alignment, but has only 1-byte alignment:
In the following example, the `pointer` variable must have 8-byte alignment, but has only 1-byte alignment:
```swift
struct A {
    int32_t i32;
    int64_t i64;
};
int8_t *buffer = malloc(32);
struct A *pointer = (struct A *)(buffer + 1);
pointer->i32 = 7; // Error: pointer is misaligned
```

One solution is to pack the structure. In the following example, the packed `A` structure prevents the compiler from adding padding between members:
One solution is to pack the structure. In the following example, the packed `A` structure prevents the compiler from adding padding between members:
```occ
struct A { ... } __attribute__((packed));
```


## Monitoring your Metal app’s graphics performance
> https://developer.apple.com/documentation/xcode/monitoring-your-metal-apps-graphics-performance

### 
#### 
#### 
#### 
#### 
- Add `MetalHudEnabled` to your app’s `Info.plist` file.
- Add `MetalHUDForceEnabled=1` in your app’s .
#### 
If you enable logging, once per second as your app runs, the HUD writes data in the following format to the console:
```None
metal-HUD: <first-frame-number-integer>,<graphics-memory-usage-float>,<process-memory-usage-float>,<first-frame-present-interval-float>,<first-frame-gpu-time-float>,...<last-frame-present-interval-float>,<last-frame-gpu-time-float>
```

When you enable shader compiler logging, as your app runs, the Metal HUD emits signposts for each compiled shader. The subsystem is `com.apple.metal.hud` and the category is `Logging`.
```None
[com.apple.metal.hud:Logging] CompileShader: name: ParticleVs compilation-time: 5496250 cached: 0
[com.apple.metal.hud:Logging] CompileShader: name: ParticlePs compilation-time: 6335000 cached: 0
```

#### 
#### 

## Naming resources and commands
> https://developer.apple.com/documentation/xcode/naming-resources-and-commands

### 
#### 
#### 
Use these methods to simplify your app development process, particularly for tasks that involve many Metal commands per buffer or encoder.
The following example demonstrates pushing and popping multiple debug groups:
```swift
func encodeRenderPass(commandBuffer: MTLCommandBuffer, descriptor: MTLRenderPassDescriptor) { 
    guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }
    renderEncoder.label = "My Render Encoder"
    renderEncoder.pushDebugGroup("My Render Pass")

        renderEncoder.pushDebugGroup("Pipeline Setup")
        // Render pipeline commands.
        renderEncoder.popDebugGroup() // Pops "Pipeline Setup".

        renderEncoder.pushDebugGroup("Vertex Setup")
        // Vertex function commands.
        renderEncoder.popDebugGroup() // Pops "Vertex Setup".

        renderEncoder.pushDebugGroup("Fragment Setup")
        // Fragment function commands.
        renderEncoder.popDebugGroup() // Pops "Fragment Setup".

        renderEncoder.pushDebugGroup("Draw Calls")
        // Drawing commands.
        renderEncoder.popDebugGroup() // Pops "Draw Calls".

    renderEncoder.popDebugGroup() // Pops "My Render Pass".
    renderEncoder.endEncoding()
}
```


## Nonnull argument violation
> https://developer.apple.com/documentation/xcode/nonnull-argument-violation

### 
#### 
In the following example, the call to the `has_nonnull_argument` function breaks the `nonnull` attribute of the parameter `p`:
In the following example, the call to the `has_nonnull_argument` function breaks the `nonnull` attribute of the parameter `p`:
```occ
void has_nonnull_argument(__attribute__((nonnull)) int *p) { 
     // ... 
}
has_nonnull_argument(NULL); // Error: nonnull parameter attribute violation
```

Correct logic errors, or remove the `nonnull` attribute and rework the called function’s logic accordingly.
#### 
In the following example, the call to the `has_nonnull_argument` function breaks the `_Nonnull` annotation of the parameter `p`:
In the following example, the call to the `has_nonnull_argument` function breaks the `_Nonnull` annotation of the parameter `p`:
```occ
void has_nonnull_argument(int * _Nonnull p) { 
     // ... 
}
has_nonnull_argument(NULL); // Error: _Nonnull annotation violation
```

Correct logic errors, or remove the `_Nonnull` attribute and rework the called function’s logic accordingly.

## Nonnull return value violation
> https://developer.apple.com/documentation/xcode/nonnull-return-value-violation

### 
#### 
In the following code, there is a violation of the `returns_nonnull` attribute of the `nonnull_returning_function` function:
In the following code, there is a violation of the `returns_nonnull` attribute of the `nonnull_returning_function` function:
```occ
__attribute__((returns_nonnull)) int *nonnull_returning_function(int *p) {
    return p; // Warning: NULL can be returned here
}
nonnull_returning_function(NULL); // Error: nonnull return value attribute violation
```

#### 
The following code violates the `_Nonnull` annotation of the return type for the `nonnull_returning_function` function:
The following code violates the `_Nonnull` annotation of the return type for the `nonnull_returning_function` function:
```occ
int *_Nonnull nonnull_returning_function(int *p) {
    return p; // Warning: NULL can be returned here
}
nonnull_returning_function(NULL); // Error: nonnull return value attribute violation
```


## Nonnull variable assignment violation
> https://developer.apple.com/documentation/xcode/nonnull-variable-assignment-violation

### 
Use this check to detect when you assign `null` to a variable with the `_Nonnull` annotation. Available in Xcode 9 and later.
#### 
In the following example, the call to `assigns_a_value` breaks the `_Nonnull` annotation of the variable `q`:
In the following example, the call to `assigns_a_value` breaks the `_Nonnull` annotation of the variable `q`:
```occ
void assigns_a_value(int *p) {     
    int *_Nonnull q = p; // Warning: null can be assigned
}
assigns_a_value(NULL); // Error: _Nonnull variable violation
```

Correct logic errors, or remove the `_Nonnull` annotation.

## Null reference creation and null pointer dereference
> https://developer.apple.com/documentation/xcode/null-reference-creation-and-null-pointer-dereference

### 
#### 
The following example demonstrates how to create a null reference. References in C++ must be nonnull:
```occ
int &x = *(int *)nullptr; // Error: null reference
```

Use a pointer instead.
```occ
int *x = nullptr; // Correct
```

#### 
The following code makes a member call on an object with a null address. The compiler may remove the null check on the `this` pointer because it requires the pointer to be `nonnull`.
```occ
struct A {
    int x;
    int getX() {
        if (!this) { // Warning: redundant null check may be removed
            return 0;
        }
        return x; // Warning: 'this' pointer is null, but is dereferenced here
    }
};
A *a = nullptr;
int x = a->getX(); // Error: member access through null pointer
```

> **important:** Always avoid null checks on the `this` pointer.

## Out-of-bounds array access
> https://developer.apple.com/documentation/xcode/out-of-bounds-array-access

### 
#### 
In the following example, out-of-bounds access of `array` occurs on the last iteration of the loop:
In the following example, out-of-bounds access of `array` occurs on the last iteration of the loop:
```occ
int array[5];
for (int i = 0; i <= 5; ++i) {
    array[i] += 1; // Error: out-of-bounds access on the last iteration
}
```


## Overflow and underflow of buffers
> https://developer.apple.com/documentation/xcode/overflow-and-underflow-of-buffers

### 
#### 
In the following example, the `global_array`, `heap_buffer`, and `stack_buffer` variables each have valid indexes in the range `[0, 9]`, but the accessed index is `10`, which causes an overflow:
```occ
int global_array[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
void foo() {
    int idx = 10;
    global_array[idx] = 42; // Error: out of bounds access of global variable
    char *heap_buffer = malloc(10);
    heap_buffer[idx] = 'x'; // Error: out of bounds access of heap allocated variable
    char stack_buffer[10];
    stack_buffer[idx] = 'x'; // Error: out of bounds access of stack allocated variable
}
```


## Overflow of C++ containers
> https://developer.apple.com/documentation/xcode/overflow-of-c-containers

### 
#### 
In the following example, the `vector` variable has valid indexes in the range `[0,2]`, but the accessed index is `3`, which causes an overflow:
In the following example, the `vector` variable has valid indexes in the range `[0,2]`, but the accessed index is `3`, which causes an overflow:
```occ
std::vector<int> vector;
vector.push_back(0);
vector.push_back(1);
vector.push_back(2);
auto *pointer = &vector[0];
return pointer[3]; // Error: out of bounds access for vector
```

#### 
You may encounter a false-positive ‘Container overflow’ error when code that isn’t compiled with Address Sanitizer modifies a container. For container overflow checks to work correctly, you need to compile all code with Address Sanitizer. If you can’t do this, turn off container overflow checks using one of the following methods:
```occ
#ifdef __cplusplus
extern "C" {
#endif
#include <sanitizer/asan_interface.h>

const char *__asan_default_options() {
    return "detect_container_overflow=0";
}
#ifdef __cplusplus
}
#endif
```


## Packaging Mac software for distribution
> https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution

### 
### 
### 
If you choose to distribute your product in a zip archive, use the `ditto` command-line tool to create that archive:
2. Run the `ditto` tool as shown below:
1. Create a directory that holds everything you want to distribute.
2. Run the `ditto` tool as shown below:
```None
% ditto -c -k --keepParent <PathToDirectory> <PathToZip>
```

### 
For information on how to set up these Installer-signing identities, see .
Run the following command to confirm that your Installer-signing identity is present and correct:
```None
% security find-identity -v               
  1) 6210ECCC616B6A72F238DE6FDDFDA1A06DEFF9FB "3rd Party Mac Developer Installer: …"
  2) C32E0E68CE92936D5532E21BAAD8CFF4A6D9BAA1 "Developer ID Installer: …"
     2 valid identities found
```

The `-v` argument filters for valid identities only. If the Installer-signing identity you need isn’t listed, see .
If your product consists of a single app, use the `productbuild` tool to create a simple Installer package for it. The following is the simplest use of `productbuild`, sufficient for submitting your app to the Mac App Store:
```None
% productbuild --sign <Identity> --component <PathToApp> /Applications <PathToPackage>
```

### 
If you choose to distribute your product in a disk image file (`.dmg`), follow these steps:
3. Use the `hdiutil` command below to create the disk image file:
2. Populate that directory with the items you want to distribute.  If you’re creating a script to automate this process, use `ditto` rather than `cp` because `ditto` preserves symlinks.
3. Use the `hdiutil` command below to create the disk image file:
```None
% hdiutil create -srcFolder <ProductDirectory> -o <DiskImageFile>
```

2. Use the `codesign` command below to sign the disk image:
1. Decide on a code-signing identifier for this disk image. If you’re signing bundled code, construct a code-signing identifier using your code’s bundle ID as the prefix followed by a unique string. Otherwise, construct the prefix by following the steps in Sign each code item in . Use a unique code-signing identifier that differs from the identifiers on your other products, including code-bundle identifiers.
2. Use the `codesign` command below to sign the disk image:
```None
% codesign -s <CodeSigningIdentity> --timestamp -i <Identifier> <DiskImageFile>
```

- Is a UDIF-format read-only zip-compressed disk image (type `UDZO`)
### 
### 
### 
Once you’ve notarized your product, staple the resulting ticket to the file you intend to distribute. For information about how to do this for an app within a zip archive, see “Staple the Ticket to Your Distribution” in . The other common container formats, installer packages and disk images, support stapling directly.  For example, to staple a ticket to a disk image:
```None
% xcrun stapler staple FlyingAnimals.dmg
```

### 

## Preparing dates, currencies, and numbers for translation
> https://developer.apple.com/documentation/xcode/preparing-dates-numbers-with-formatters

### 
#### 
To convert a date or number into a localizable string, use the Foundation formatters and styles. These APIs take instances of your date and number objects, and convert them into localizable formatted strings according to the locale of the device your app is running on.
For example, to create a localizable string from a date object, create an instance of the  you want to format and then call the  function on the date.
```swift
// The current time and date. Example output is for en_US locale.en_US locale.
let date = Date.now

// A default, formatted, localizable date string.
let defaultFormatted = date.formatted()
// "8/25/2023, 12:03 PM"
```

To vary the date components that display, or display only the time or the date, use the  method on the `Date` object passing in instances of  and .
```
To vary the date components that display, or display only the time or the date, use the  method on the `Date` object passing in instances of  and .
```swift
// The date you want to format.
let meetingDate = Date.now

// A formatted date displaying only the date.
let formattedDate = meetingDate.formatted(date: .abbreviated, time: .omitted)
// "Aug 25, 2023"

// A formatted date displaying only the time.
let formattedTime = meetingDate.formatted(date: .omitted, time: .standard)
// "12:03:10 PM"

// A formatted date displaying both the date and time.
let formattedDateAndTime = meetingDate.formatted(date: .complete, time: .complete)
// "Friday, August 25, 2023 at 12:03:10 PM PDT"
```

#### 
1. Create an instance of the `Date` object you want to format.
3. Then pass that `Date.FormatStyle` structure as an input into the the  function on the date object.
2. Create a  structure or use the  factory variable, and chain together the properties you want to display in successive function calls.
3. Then pass that `Date.FormatStyle` structure as an input into the the  function on the date object.
```swift
// A date string with specific attributes.
let myDate = Date.now
let formatStyle = Date.FormatStyle.dateTime.year().day().month()
let formatted = date.formatted(formatStyle)
// "Sep 7, 2023"
```

```
You can also achieve the same result in one line.
```swift
// Same result in one line using the `dateTime` factory variable.
let formatted = Date.now.formatted(.dateTime.year().day().month())
// "Sep 7, 2023"
```

The order of the fields you pass into the `formatted(_:)` function doesn’t matter. For example, these lines of code produce the same result.
```
The order of the fields you pass into the `formatted(_:)` function doesn’t matter. For example, these lines of code produce the same result.
```swift
// Same result.
Date.now.formatted(.dateTime.year().month().day().hour().minute().second())
Date.now.formatted(.dateTime.second().minute().hour().day().month().year())
// "Sep 7, 2023 at 10:29:52 AM"
```

```
Customize the date styles you want to display by chaining together instances of  structures along with their respective formatting properties.
```swift
// A date string for a wide month format.
let formattedWide = date.formatted(.dateTime.year().day().month(.wide))
// "September 7, 2023"

// A date string for a wide weekday.
let formattedWeekday = date.formatted(.dateTime.weekday(.wide))
// "Thursday"

// A date string for the ISO 8601 time and date standard.
let logFormat = date.formatted(.iso8601)
// "2023-09-07T17:25:39Z"

// A date string representing a file format.
let fileNameFormat = date.formatted(.iso8601.year().month().day().dateSeparator(.dash))
// "2023-09-07"
```

#### 
For example, to create a formatted version of an `Int`, call the  function on the number.
If you want to create a localizable string for a number (such as , , , or ), call `formatted()` or `formatted(_:)` on the number instance, along with the format style to display.
For example, to create a formatted version of an `Int`, call the  function on the number.
```swift
let value = 12345
// A default, formatted, localizable date string.
var formatted = value.formatted()
// "12,345"
```

```
To format the number as a percent, call `formatted(_ format:)` on the number you want to display with the  number format style. Integers convert directly into percentages using the whole number.
```swift
let number = 25
let numberFormatted = number.formatted(.percent)
// "25%"
```

```
Fractions convert between the range of 0 and 1.
```swift
let fraction = 0.25
let fractionFormatted = fraction.formatted(.percent)
// "25%"
```

```
To display a number using scientific notation, call  on the number to display using the , , and  format styles.
```swift
let scientific = 42e9
let scientificFormatted = scientific.formatted(.number.notation(.scientific))
// "4.2E10"
```

#### 
1. Look up the  of the currency you want to display (such as `"CAD"` for Canada).
2. Pass that code as a parameter to the  format style initializer .
3. Then call  on the number passing in the currency format instance.
```swift
// A number formatted in different currencies.
let amount: Decimal = 12345.67
amount.formatted(.currency(code: "JPY"))
// "¥12,346"
amount.formatted(.currency(code: "EUR").presentation(.fullName))
// "12,345.67 euros"
amount.formatted(.currency(code: "USD").grouping(.automatic))
// "$12,345.67"
```

#### 
2. Using these two dates, create a  structure setting the upper and lower bounds of the interval.
3. Then call one of the range formatters — such as  or  — passing in the time and date styles you want to display.
```swift
// An example of a time interval.

// The current time and date. Example output is for en_US locale.
let now = Date.now

// 5000 seconds from now.
let later = now + TimeInterval(5000)

// The default formatted display for a time interval.
let range = (now..<later).formatted()
// "9/8/2023, 10:44 AM – 12:07 PM"

// A time interval formatted using a predefined date format.
let noDate = (now..<later).formatted(date: .omitted, time: .complete)
// "10:44:39 AM PDT – 12:07:59 PM PDT"
```

```
To display time as a duration, you can similarly define a date range and convert that range into a duration.
```swift
// An example of a duration.

// Duration from a range of dates.
let timeDuration = (now..<later).formatted(.timeDuration)
// "1:23:20"

let components = (now..<later).formatted(.components(style: .wide))
// "1 hour, 23 minutes, 20 seconds"

let relative = later.formatted(.relative(presentation: .named, unitsStyle: .wide))
// "in 1 hour"
```

1. Pass in the number of seconds you want to display to the  function of the  structure.
2. Then call , passing in instances of  or  to achieve the format and style you want.
```swift
// Duration formatted from a single unit of time.
Duration.seconds(2000).formatted(.time(pattern: .hourMinute)) 
// "0:33"
Duration.seconds(2000).formatted(.time(pattern: .hourMinuteSecond)) 
// "0:33:20"
Duration.seconds(2000).formatted(.time(pattern: .minuteSecond)) 
// "33:20"
```

#### 
To create a localizable string in the form of a list, use the  structure along with either the  or  function to create a string representation of a  of items.
```swift
// An array of strings formatted into a list.
let sizes = ["small", "medium", "large"]
sizes.formatted(.list(type: .and, width: .narrow))
// "small, medium, large"
sizes.formatted(.list(type: .and, width: .standard))
// "small, medium, and large"
sizes.formatted(.list(type: .and, width: .short))
// "small, medium, & large"
```

```
You can also create lists using different formatting styles by calling the  function along with specific list format styles.
```swift
// A list of numbers formatted as percentages.
[25, 50, 75].formatted(.list(memberStyle: .percent, type: .or))
// "25%, 50%, or 75%"
```

#### 
2. Then call  or  on the variable to get the display style you want.
For example, say you want to convert and display the following measurements.
```swift
// Measurements to display.
let speedLimit = Measurement(value: 110, unit: UnitSpeed.kilometersPerHour)
let distanceToMoon = Measurement(value: 384400, unit: UnitLength.kilometers)
let surfBoardLength = Measurement(value: 8, unit: UnitLength.feet)
let waterTemperature = Measurement(value: 61.2, unit: UnitTemperature.fahrenheit)
```

```
To convert them using the default format, call  on the measurement object.
```swift
// Example output is for en_US locale.

// Default display for a unit of measure.
speedLimit.formatted()
// "68 mph"
distanceToMoon.formatted()
// "238,855 mi"
surfBoardLength.formatted()
// "8 ft"
waterTemperature.formatted()
// "61.2°F"
```

```
To customize the output, call the  function on the measurement using the  factory method to create the format and style you want.
```swift
// Custom display options for a unit of measure.
distanceToMoon.formatted(.measurement(width: .wide))
// "238,855 miles"
distanceToMoon.formatted(.measurement(width: .abbreviated))
// "238,855 mi"
distanceToMoon.formatted(.measurement(width: .narrow))
// "238,855mi"
```

#### 
To format dates and numbers in SwiftUI, use the `format` initializers on SwiftUI view controls to customize how those strings display.
For example, here is a SwiftUI view that displays three different localizable formats of `Date` using the  initializer from the  view.
To format dates and numbers in SwiftUI, use the `format` initializers on SwiftUI view controls to customize how those strings display.
For example, here is a SwiftUI view that displays three different localizable formats of `Date` using the  initializer from the  view.
```swift
@State private var myDate = Date.now

var body: some View {
    VStack {
        Text(myDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
        Text(myDate, format: Date.FormatStyle(date: .complete, time: .complete))
        Text(myDate, format: Date.FormatStyle().hour(.defaultDigits(amPM: .omitted)).minute())
    }
}
```

```
This example uses the  initializer of the  view to present a number as a percentage for a tip.
```swift
@State private var tip = 0.15

var body: some View {
    HStack {
        Text("Tip")
        Spacer()
        TextField("Amount", value: $tip, format: .percent)
    }
}
```

### 
To test and see how your formatters display in different languages and regions, create an instance of a  object, passing in the `identifier` of the region you want to test. Then set that locale on the output of your formatted string to see how that string displays in that language and region.
For example, you can see how your localizable strings display in French as follows.
```swift
// The locale for France French.
let frenchLocale = Locale(identifier: "fr_FR")
                        
let stages = ["50", "75", "100"]
stages.formatted(.list(type: .and).locale(frenchLocale))
// "50, 75 et 100"
stages.formatted(.list(type: .or).locale(frenchLocale))
// "50, 75 ou 100"
```

To test your formatters in SwiftUI, set the locale in the environment variable in the `#Preview` section of your code.
```
To test your formatters in SwiftUI, set the locale in the environment variable in the `#Preview` section of your code.
```swift
struct ContentView: View {
    @State private var myDate = Date.now
    @Environment(\.locale) var locale

    var body: some View {
        VStack {
            Text(myDate, format: .dateTime.second().minute().hour().day().month().year().locale(locale))
        }
    }
}

#Preview {
    Group {
        ContentView()
            .environment(\.locale, Locale(identifier: "fr_FR"))
        ContentView()
            .environment(\.locale, Locale(identifier: "pt_BR"))
    }
}
```


## Preparing your app’s text for translation
> https://developer.apple.com/documentation/xcode/preparing-your-apps-text-for-translation

### 
#### 
String literals — strings created only with double quotes — aren’t localizable by themselves.
```swift
// An example of a nonlocalizable string literal.
let name = "Lightbulbs"
```

There’s no way for the system to know whether the string literal is a user-facing string in need of translation or simply a print statement there for debugging.
To make a string localizable, create a  object using the  initializer.
```swift
// Localizable string with the same key and value.
String(localized: "Lightbulbs")
```

This initializer takes the string literal passed in as a  and assigns it to a key equal to the value of the string literal itself. Your string catalog uses this key to look up translations based on the language and locale of the user’s device, and then returns the translated value associated with that key. With this initializer, the key and underlying string value are the same. This means you can use the text of your development language as the keys for your translations.
To create localizable strings with different keys and values, use the   initializer. This initializer assigns the first string literal as the string’s key and makes the second parameter the default string value.
```swift
// Localizable string with a different key and value.
String(localized: "LIGHTING_KEY", defaultValue: "Lightbulbs")
```

```
If someone else translates your strings, consider adding helpful comments to your string initializers to provide additional context about how and when the string displays.
```swift
// Localizable string with a comment providing additional context.
String(localized: "Lightbulbs", comment: "Label: The icon name displayed on the control screen")
```

```
If the number of translations in your string catalog grows too large, consider breaking the default catalog up into several smaller catalogs. Then specify which catalog a translation comes from using the `table` parameter in the  initializer.
```swift
// Localizable string referenced from the Greetings.xcstrings string catalog file.
String(localized: "Welcome", table: "Greetings")
```

```
Use `String(localized:)` and `AttributedString(localized:)` initializers to initialize UIKit and AppKit controls as well as general Swift structures containing variables of type .
```swift
struct Accessory {
     // Nonlocalizable string literal.
     let name: String
}
// Made localizable using the String(localized:) initializer.
Accessory(name: String(localized: "Welcome"))

// Localizable string passed into a UIKit control.
let label = UILabel()
label.text = String(localized: "Welcome")

// Localizable string passed into a AppKit UI control.
let textField = NSTextField()
textField.stringValue = String(localized: "Welcome")
```

#### 
SwiftUI views that accept string literals of type  are automatically considered localizable. For example, the following strings are all automatically considered localizable in SwiftUI:
```swift
// Text made localizable with LocalizedStringKey.

Label("Thanks for shopping with us!", systemImage: "bag")
    .font(.title)
HStack {
    Button("Clear Cart") {}
    Button("Checkout") {}
}
```

```
To help translators better understand the context for a localized string, use the  initializer of your  view and provide a comment with additional details.
```swift
// Provide additional localizable data with a `TextView`.

Stepper {
    Text("Increase or decrease the item quantity", comment: "Lets the shopper increase or decrease the quantity for an item in their shopping cart")
} onIncrement: {
    // ...
} onDecrement: {
    // ...
}
```

#### 
When defining or passing localizable text in your views, use the recommended type for passing strings in Swift .
```swift
// Localizable strings in SwiftUI.

struct CardView: View {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    
    var body: some View {
        ZStack {
            Rectangle()
            VStack {
                Text(title)
                Text(subtitle)
            }
            .padding()
        }
    }
}

CardView(title: "Recent Purchases", subtitle: "Items you've ordered in the past week")
```

This type not only supports initialization using string literals, it also supports adding a comment, table name, or default value that’s different from the string key.
`LocalizedStringResource` also works for strings defined in general Swift code. For example, here’s a structure that defines a title of type `LocalizedStringResource`, which is then instantiated using a string literal and an instance of `LocalizedStringResource`, both localizable.
```swift
struct UserAction {
   let title: LocalizedStringResource
}

// Localizable text created with a string literal.
let action = UserAction(title: "Order items")

// Localizable text created with a `LocalizedStringResource`.
let actionWithComment = UserAction(title: LocalizedStringResource("Order items", comment: "Action title displayed in button"))
```

#### 
1. Identify the name of a class within the framework (in this case, `BirdSongs`).
3. Use that `Bundle` to look up the localizable string.
2. Pass that class into an instance of  using the  initializer.
3. Use that `Bundle` to look up the localizable string.
```swift
// Localizable string within a framework.
String(localized: "Songs", bundle: Bundle(for: (BirdSongs.self)))

// Localizable string within a framework in SwiftUI.
Text("Songs", bundle: Bundle(for: (BirdSongs.self)))

// Localizable string within a framework for a `LocalizedStringResource`.
LocalizedStringResource("Songs", bundle: .forClass(BirdSongs.self), comment: "Headline above the name of the song currently playing.")
```


## Preventing memory-use regressions
> https://developer.apple.com/documentation/xcode/preventing-memory-use-regressions

### 
 can measure the amount of memory allocated by your app while it executes a test case. To measure memory use, create a performance test in your app’s unit test target, and pass an instance of  to `measure(metrics:)`. Inside the block, call the code from your app that demonstrates the problematic memory use.
```swift
class MemoryTests: XCTestCase {
    func testMemoryUse() {
        self.measure(metrics: [XCTMemoryMetric()]) {
          // Use the relevant app feature here
        }
    }
}
```


## Previewing localizations
> https://developer.apple.com/documentation/xcode/previewing-localizations

### 
#### 
For SwiftUI apps, you can preview a localization by setting the  environment variable in your code. Use the  function to set the locale for all views in the view hierarchy of a SwiftUI preview. For example, if you add German to your project, you can set the locale to German (`de`):
```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
                .environment(\.locale, .init(identifier: "de"))
    }
}
```

#### 

## Previewing your app’s interface in Xcode
> https://developer.apple.com/documentation/xcode/previewing-your-apps-interface-in-xcode

### 
#### 
2. Add the `#Preview` macro to the file.
#### 
#### 
#### 
#### 
#### 
#### 
#### 
In addition to the preview options Xcode provides, you can also customize and configure previews you want to reuse programmatically.
For example, you can add a name to more easily track what each preview displays. When you pass the name of your preview as a string into the preview macro, the name appears in the title of the preview in the preview canvas.
```swift
// A preview with an assigned name.
#Preview("2x2 Grid Portrait") {
   Content()
}
```

#### 
When a view depends on a  property wrapper, you can create a functional binding for that property and pass it into your preview using the  macro. This macro works on any variable conforming to the  protocol.
```swift
struct PlayButton: View {
    @Binding var isPlaying: Bool

    var body: some View {
        Button(action: {
            self.isPlaying.toggle()
        }) {
            Image(systemName: isPlaying ? "pause.circle" : "play.circle")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 80)
        }
    }
}

#Preview {
    // Tag the dynamic property with `Previewable`.
    @Previewable @State var isPlaying = true

    // Pass it into your view.
    PlayButton(isPlaying: $isPlaying)
}
```

Tagging a dynamic property with the `Previewable` macro gets rid of the need to create wrapper views in previews.
#### 
Expensive objects — such as objects that make network calls, perform disk access, or just take considerable time and effort to setup — can make your previews take longer to load. By creating these expensive objects once, and sharing them across all your previews, you make your previews more efficient.
For example, if you have an app with an expensive  object:
```swift
@Observable
class AppState {
    // An expensive, complex, bulky object.
    var expensiveObject = "Some expensive object"
}

@main
struct MyApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ComplexView()
                .environment(appState)
        }
    }
}
```

```
You reuse that expensive object across multiple views in your app:
```swift
struct ComplexView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        Text("\(appState.expensiveObject)")
    }
}
```

```
For every view you want to preview, you recreate and pass in that expensive object:
```swift
#Preview {
    ComplexView()
        // Potentially expensive if `AppState` is large or complex.
        .environment(AppState())
}
```

1. Define a structure conforming to the `PreviewModifier` protocol.
3. Inject that shared context into the view you want to preview using the  function.
4. Add the modifier to the preview using the  macro.
```swift
// Create a struct conforming to the PreviewModifier protocol.
struct SampleData: PreviewModifier {

    // Define the object to share and return it as a shared context.
    static func makeSharedContext() async throws -> AppState {
        let appState = AppState()
        appState.expensiveObject = "An expensive object to reuse in previews"
        return appState
    }

    func body(content: Content, context: AppState) -> some View {
        // Inject the object into the view to preview.
        content
            .environment(context)
    }
}

// Add the modifier to the preview.
#Preview(traits: .modifier(SampleData())) {
    ComplexView()
}
```

#### 
The following example shows how simple data types, like `String` and `enum`, can be used to preview a view in various ways using the preview macro.
#### 

## Races on collections and other APIs
> https://developer.apple.com/documentation/xcode/races-on-collections-and-other-apis

### 
#### 
In the following example, the code enumerates a mutable array in one thread while writing to the array from another without synchronizing access:
```swift
let array: NSMutableArray = []
var sum: Int = 0
// Executed on Thread #1
for value in array {
    sum += value as! Int
}
// Executed on Thread #2
array.add(42)
```

```
```objc
NSMutableArray *array = [NSMutableArray new];
NSInteger sum = 0;
// Executed on Thread #1
for (id value in array) {  
    sum += [value integerValue];
} 
// Executed on Thread #2
[array addObject:@42];
```

Use  APIs to coordinate access to `array` across multiple threads.
#### 
In the following example, the code enumerates a mutable dictionary in one thread while writing to the dictionary from another without synchronizing access:
```swift
let dictionary: NSMutableDictionary = [:]
var sum: Int = 0
// Executed on Thread #1
for key in dictionary.keyEnumerator() {
    sum += dictionary[key] as! Int
}
// Executed on Thread #2
dictionary["forty-two"] = 42
```

```
```objc
NSMutableDictionary *dictionary = [NSMutableDictionary new];
NSInteger sum = 0;
// Executed on Thread #1
for (id key in dictionary) {
    sum += [dictionary[key] integerValue];
}
// Executed on Thread #2
dictionary[@"forty-two"] = @42;
```

Use  APIs to coordinate access to `dictionary` across multiple threads.

## Reaching of unreachable point
> https://developer.apple.com/documentation/xcode/reaching-of-unreachable-point

### 
#### 
If the `switch` statement fails to handle a value that a function returns, the program reaches  `__builtin_unreachable()`.
If the `switch` statement fails to handle a value that a function returns, the program reaches  `__builtin_unreachable()`.
```occ
switch (value_returning_function()) {
case ...:                  // Warning: if the cases are not exhaustive
default:                   // __builtin_unreachable may be reached
    __builtin_unreachable();
}
```

Ensure that `switch` statements and other control flow statements are exhaustive.

## Reading an exception message
> https://developer.apple.com/documentation/xcode/reading-an-exception-message

### 
#### 
`Foundation`‘s collection classes like , its mutable subclass , and `CoreFoundation` counterparts like  can’t contain `nil` as a value. Additionally, dictionary collections — , ,  — can’t contain `nil` as a key. If your app adds `nil` to a mutable collection, it crashes, and an exception message like this example is included in the crash report:
```None
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[__NSArrayM insertObject:atIndex:]: object cannot be nil'
```

#### 
Many APIs expect their parameters to be non-`nil` and throw exceptions if they receive `nil`. For example,  requires both its `name` and `value` to be non-`nil`. If your app adds a `nil` attribute to an attributed string, it crashes, and an exception message like this example is included in the crash report:
```None
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'NSConcreteMutableAttributedString addAttribute:value:range:: nil value'
```

Determine an appropriate non-`nil` value to use instead; otherwise, avoid setting the attribute.
#### 
You often send messages to Objective-C classes and objects by writing the method name into your source code; for example, you send  by typing `[myAttributedString addAttribute:aName value:aValue range:aRange];`. There are situations where you construct a method name — also known as a  — dynamically and send that to the class or object. A common example is setting the name of a controller method as an action in a storyboard file. If the object or class receiving the message doesn’t respond to the selector and can’t forward it to another object, your app crashes and an exception message like this example is included in the crash report:
```None
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[__NSCFBoolean insertObject:atIndex:]: unrecognized selector sent to instance 0x1e75db6c0'
```

#### 
Each of the common `Foundation` collections has an immutable class, for example, , and a corresponding mutable subclass, for example, . These Objective-C classes are interchangeable with the corresponding `CoreFoundation` types  and . It’s an error to try to change the contents of an immutable collection, for example, by appending an object. If your app tries to change the contents of an immutable collection, it crashes and an exception message like this example is included in the crash report:
```None
*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: '-[__NSCFArray insertObject:atIndex:]: mutating method sent to immutable object'
```

#### 
If your app tries to access the content of a collection or sequence outside of its range, it crashes and an exception message like this example is included in the crash report:
```None
*** Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[__NSArrayM objectAtIndex:]: index 12 beyond bounds [0 .. 0]'
```

```
In the special case of requesting an object at a particular index in an empty array, the exception message is similar to this example:
```None
*** Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[__NSArray0 objectAtIndex:]: index 12 beyond bounds for empty array'
```

#### 
The  structure uses the same type () for both its location and its length, which is also the type that collection classes use to represent indexes into the collection. It’s possible to create a range where the end of the range is beyond the values that can be represented as indexes into the collection that’s using the range. When a collection or sequence detects this case, your app crashes and an exception message like this example is included in the crash report:
```None
*** Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[NSConcreteMutableData subdataWithRange:]: range {20, 18446744073709551605} causes integer overflow'
```

#### 
When you initialize an  or  using the initializer method , you have to supply an equal number of keys and objects. If you supply arrays with different lengths, your app crashes and an exception message like this example is included in the crash report:
```None
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[NSDictionary initWithObjects:forKeys:]: count of objects (1) differs from count of keys (2)'
```

#### 
To serialize or deserialize an object using , whether to store it in a file, or send it to another process or over the network, the object must conform to . If your app attempts to encode or decode an object that doesn’t conform to `NSCoding`, it crashes and an exception message like this example is included in the crash report:
```None
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[MyClass encodeWithCoder:]: unrecognized selector sent to instance 0x600002090040'
```

Replace the object with one that conforms to `NSCoding`, or add `NSCoding` conformance to the object’s class or to a category on that class.

## Reducing disk writes
> https://developer.apple.com/documentation/xcode/reducing-disk-writes

### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
Measure the disk usage of your app by writing an XCTest performance test. Create a test that passes an instance of  to the  function. Call your code inside the block argument of `measure(metrics:block:)`, the method that writes data to disk.
The test measures the number of blocks written to the filesystem to save your data. Set a baseline expectation for the amount of disk use. The test fails if the amount of data written significantly exceeds the baseline.
```swift
func testDiskUse() {
  self.measure(metrics: [XCTStorageMetric()]) {
     // This is a disk-intensive operation.
  }
}
```

#### 
Decrease search time and avoid unnecessary writes to the disk by using appropriate indices on your database tables. For example, an email app that uses SQLite may show all inbox messages in chronological order using the following SQL statement:
```None
SELECT * FROM messages WHERE folder LIKE ‘Inbox’ ORDER BY sent_time
```

Use a partial index for columns representing information that doesn’t require searching each of the rows, such as rows that can contain `NULL`. A partial index — one with a `WHERE` clause — provides a performance advantage while taking up less disk space than a full index.
Use `EXPLAIN QUERY PLAN` to determine if a query can benefit from optimization. The following code shows the explanation of a query on an unindexed `sent_time` column.
```None
> EXPLAIN QUERY PLAN SELECT * FROM messages WHERE folder
  LIKE ‘Inbox’ ORDER BY sent_time

QUERY PLAN
|--SEARCH TABLE <>
|--SEARCH TABLE <>
--*USE TEMP B-TREE FOR ORDER BY*
```

The presence of `USE TEMP B-TREE FOR ORDER BY` in the output indicates that the query requires a temporary B-tree to sort the results.
Use `PRAGMA journal_mode` to determine your SQLite database’s journaling mode. Use `PRAGMA journal_mode=WAL` to change to write-ahead logging mode.

## Reducing your app’s disk usage
> https://developer.apple.com/documentation/xcode/reducing-your-app-s-disk-usage

### 
#### 
#### 
Use  to gather metrics on the number of files in your app’s container, and the disk space they occupy including space in the :
```swift
import MetricKit

class MetricService: NSObject, MXMetricManagerSubscriber {
    let metricManager: MXMetricManager = MXMetricManager.shared
    
    override init() {
        super.init()
        metricManager.add(self)
    }
    
    func didReceive(_ payloads: [MXMetricPayload]) {
        payloads.forEach({ payload in
            if let diskUsage = payload.diskSpaceUsageMetrics {
                // Analyze your app's disk usage.
            }
        })
    }
}
```

#### 
When you download or otherwise generate content that your app can recover if it needs to, store that content in the  or the . The system automatically deletes content in the `cachesDirectory` and `temporaryDirectory` — an operation known as  — when it detects that disk space is low.
```swift
let cacheDownloadTask = URLSession.shared.downloadTask(with: cacheURL) {
    fileURL, response, error

    // Check for download errors and handle them.

    guard let temporaryURL = fileURL else { return }
    do {
        let destinationURL = URL.cachesDirectory.appendingPathComponent(temporaryURL.lastPathComponent)
        try FileManager.default.moveItem(at: temporaryURL, to: destinationURL)
    }
    catch {
        // Handle the error.
    }
}
```

#### 
When a person isn’t using the local copy of a file that’s stored in iCloud, call  to remove the local copy while keeping the original on iCloud:
```swift
func removeLocalDocument(at localURL: URL) throws {
    let resources = try localURL.resourceValues(forKeys: [.ubiquitousItemIsUploadedKey])
    guard resources.ubiquitousItemIsUploaded == true else { return }
    FileManager.default.evictUbiquitousItem(at: localURL)
}
```

```
You can subsequently retrieve the file from iCloud by calling :
```swift
func fetchRemoteDocument(for localURL: URL) throws {
    let resources = try localURL.resourceValues(forKeys: [.ubiquitousItemIsUploadedKey])
    guard resources.ubiquitousItemIsUploaded != true else { return }
    FileManager.default.startDownloadingUbiquitousItem(at: localURL)
}
```

#### 

## Reducing your app’s launch time
> https://developer.apple.com/documentation/xcode/reducing-your-app-s-launch-time

### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
Certain code in an app must run before iOS runs your app’s `main()` function, adding to the launch time. This code includes:
- Objective-C `+load` methods defined in classes or categories.
- Functions marked with the clang attribute `__attribute__((constructor))`.
- Any function linked into the `__DATA,__mod_init_func` section of an app or framework binary.
#### 
#### 
#### 
If your app still has to run code after it has drawn its first frame, but before the user can begin using the app, that time doesn’t contribute to the launch-time metric. Extra startup activities still contribute to the user’s perception of the app’s responsiveness. For example, if your app renders a document after opening, the user will likely wait on the document to render and perceive it as part of your launch time, even though the system will end the launch measurement while you show a loading icon.
To track additional startup activities, create an  object in your app with the category . Use the `os_signpost` function to record the beginning and end of your app’s preparation tasks, as shown in the following example:
```swift
class ViewController: UIViewController {
    static let startupActivities:StaticString = "Startup Activities"
    let poiLog = OSLog(subsystem: "com.example.CocoaPictures", category: .pointsOfInterest)

    override func viewDidAppear() {
        super.viewDidAppear()
        os_signpost(.begin, log: self.poiLog, name: ViewController.startupActivities)
        // do work to prepare the view
        os_signpost(.end, log: self.poiLog, name: ViewController.startupActivities)
    }
}
```


## Reducing your app’s size
> https://developer.apple.com/documentation/xcode/reducing-your-app-s-size

### 
#### 
-  IPA files for each variant of your app. These files contain assets and binaries for only one variant.
The output folder for your exported app also contains the app size report: a file named `App Thinning Size Report.txt`. This report lists the compressed and uncompressed sizes for each of your app’s IPA files. The uncompressed size is equivalent to the size of the installed app on the device, and the compressed size is the download size of your app. The following shows the beginning of the app size report for a sample app:
```other
App Thinning Size Report for All Variants of ExampleApp

Variant: ExampleApp.ipa
Supported variant descriptors: [device: iPhone11,4, os-version: 12.0], [device: iPhone9,4, os-version: 12.0], [device: iPhone10,3, os-version: 12.0], [device: iPhone11,6, os-version: 12.0], [device: iPhone10,6, os-version: 12.0], [device: iPhone9,2, os-version: 12.0], [device: iPhone10,5, os-version: 12.0], [device: iPhone11,2, os-version: 12.0], and [device: iPhone10,2, os-version: 12.0]
App + On Demand Resources size: 6.7 MB compressed, 18.6 MB uncompressed
App size: 6.7 MB compressed, 18.6 MB uncompressed
On Demand Resources size: Zero KB compressed, Zero KB uncompressed

// Other Variants of Your App.
```

#### 
Instead of creating the app size report with Xcode, you may want to automate its generation in build scripts or continuous integration workflows. Run the following command to use `xcodebuild` to export your app for distribution and create an app thinning size report:
```other
xcodebuild -exportArchive -archivePath iOSApp.xcarchive -exportPath Release/MyApp -exportOptionsPlist OptionsPlist.plist
```

To learn more about using `xcodebuild`, see .

## Running code on a specific platform or OS version
> https://developer.apple.com/documentation/xcode/running-code-on-a-specific-version

### 
#### 
Apple platforms support many of the same technologies, but some features might not be available on every platform. For example, features on iOS devices might not make sense on a macOS devices. To prevent code from compiling on an operating system that doesn’t support the corresponding feature, add a conditional compilation block to specify the target operating system.
```swift
/// Swift
/// `iOS` specifies the operating system for which this code compiles. 
/// Change `iOS` to specify another operating system.
#if os(iOS)
   // iOS code
#endif
```

```
```objc
/// Objective-C
/// `IOS` specifies the operating system for which this code compiles. 
/// Change `IOS` to specify another operating system. For the list of 
/// compilation macros, see the /usr/include/TargetConditionals.h 
/// header file in the appropriate SDK.
#if TARGET_OS_IOS
   // iOS code
#endif
```

```
You can also compile or prevent compiling for specific environments, such as Simulator or Mac Catalyst.
```swift
/// Swift
/// `simulator` specifies an environment to compile the code for. 
/// Change `simulator` to specify another environment, such as `macCatalyst`.
#if targetEnvironment(simulator)
    // code for Simulator
#endif

```

```
```objc
/// Objective-C
/// `SIMULATOR` specifies an environment this code depends on. 
/// Change `SIMULATOR` to specify another environment, such as `MACCATALYST`.
#if TARGET_OS_SIMULATOR
    // code for Simulator
#endif
```

```
If your Swift code relies on a specific Swift package or framework, you can check to see whether you can import the package or framework. This condition tests whether it’s possible to import a module, but doesn’t actually import it. This type of check has the advantage that your code uses the package or framework if a future version of the operating system makes it available.
```swift
/// Swift
/// `UIKit` specifies a module this code depends on. 
/// Change `UIKit` to specify another module.
#if canImport(UIKit)
    // code that requires UIKit
#endif
```

#### 
- In Swift, use the `#available` compiler control statement to run code conditionally.
- In Objective-C, use the `@available` compiler directive to run code conditionally.
- In Objective-C, use the `@available` compiler directive to run code conditionally.
Platform names support both major and minor revision numbers for releases, as shown in the following example:
```swift
/// Swift
if #available(iOS 15.4.1, *) {
    // On iOS, this branch runs in versions 15.4.1 and greater. 
    // On any other OS, this branch runs in any version of that OS.
} else {
   // This branch runs in earlier iOS versions.
}
```

}
```
```objc
/// Objective-C
if (@available(iOS 15.4.1, *)) {
    // On iOS, this branch runs in versions 15.4.1 and greater. 
    // On any other OS, this branch runs in any version of that OS.
} else {
   // This branch runs in earlier iOS versions.
}
```

```
The `*` matches any other operating system. To specify versions for multiple operating systems, include multiple operating system names separated by commas.
```swift
// Swift
if #available(iOS 15, macOS 12, *) {
    // On iOS, this branch runs in iOS 15 or later.
    // On macOS, this branch runs in macOS 12 or later.
    // On any other OS, this branch will run in any version of that OS.
} else {
   // This branch runs in earlier iOS and macOS versions.
}
```

}
```
```objc
// Objective-C
if (@available(iOS 15, macOS 12, *)) {
    // On iOS, this branch runs in iOS 15 or later.
    // On macOS, this branch runs in macOS 12 or later.
    // On any other OS, this branch will run in any version of that OS.
} else {
   // This branch runs in earlier iOS and macOS versions.
}
```

#### 
- In Swift, use the `@available` attribute to indicate a declaration is available.
- In Objective-C, use the `API_AVAILABLE` macro to add availability information.
- In Swift, use the `@available` attribute to indicate a declaration is available.
- In Objective-C, use the `API_AVAILABLE` macro to add availability information.
```swift
@available(iOS 15, macOS 12, *)
func newMethod() {
    // Use iOS 15 APIs.
}
```

}
```
```objc
@interface MyViewController : UIViewController
- (void) newMethod API_AVAILABLE(ios(15));
@end
```


## Running code snippets using the playground macro
> https://developer.apple.com/documentation/xcode/running-code-snippets-using-the-playground-macro

### 
#### 
You can add one or more playgrounds to a Swift file. First, import the Playgrounds framework in your Swift file. Then wrap the code snippet that you want to run in the `#Playground` macro, for example:
```swift
import MapKit
import Playgrounds

#Playground {
    // Golden Gate Park
    let latitude = 37.768552
    let longitude = -122.481616
    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
}
```

#### 
#### 
#### 

## Running custom scripts during a build
> https://developer.apple.com/documentation/xcode/running-custom-scripts-during-a-build

### 
#### 
#### 
#### 
| `SCRIPT_INPUT_FILE_COUNT` | The total number of files available as inputs to the script. |
| `SCRIPT_INPUT_FILE_LIST_COUNT` | The total number of file lists available as inputs to the script. |
| `SCRIPT_OUTPUT_FILE_COUNT` | The total number of files described as script outputs. |
| `SCRIPT_OUTPUT_FILE_LIST_COUNT` | The total number of file lists described as script outputs. |
#### 
During your script’s execution, you can report errors, warnings, and general notes to the Xcode build system. Use these messages to diagnose problems or track your script’s progress. To write messages, use the echo command and format your message as follows:
```None
[filename]:[linenumber]: error | warning | note : [message]
```

If the `error:`, `warning:`, or `note:` string is present, Xcode adds your message to the build logs. If the issue occurs in a specific file, include the filename as an absolute path. If the issue occurs at a specific line in the file, include the line number as well. The filename and line number are optional.
Some example errors and warnings include:
```None
echo "error: An expected input file was missing."
echo "warning: Skipping a file of an unknown type."
```

#### 
When your script fails and recovery isn’t possible, return a nonzero exit code from your script. Xcode treats a nonzero exit value as a build failure, and adds appropriate information to the logs.
The following example logs an error message to standard out and triggers a build failure.
```None
echo "error: A fatal error occurred in the script."
exit 1
```


## Running tests and interpreting results
> https://developer.apple.com/documentation/xcode/running-tests-and-interpreting-results

### 
### 
To run all the tests in the active test plan, you have two options: you can run them in Xcode (choose Product > Test), or you can run the `xcodebuild` command in Terminal:
```zsh
% xcodebuild test -scheme SampleApp
```

### 
### 
### 
Xcode runs the selected test function and updates the icon to indicate the outcome.
To run a single test function in Terminal, run `xcodebuild` by giving the test function’s identifier as the parameter to the `-only-testing` option. The identifier for a test function has the form `test_target/test_type/test_function`.
```zsh
% xcodebuild test -scheme SampleApp -only-testing SampleAppTests/SampleAppTests/testEmptyArrayWhenNoOverlappingNotes
```

### 
### 
Xcode runs the test functions the selected item contains and updates the icon to indicate the outcome.
To run the test functions in a test case in Terminal, run `xcodebuild` by giving the suite’s identifier as the parameter to the `-only-testing` option. The identifier for a suite has the form `test_target/test_suite`.
```zsh
% xcodebuild test -scheme SampleApp -only-testing SampleAppTests/SampleAppTests
```

### 
### 
To repeatedly run tests in Terminal, specify the number of repetitions with the `-test-repetitions` option, optionally specifying whether the tests should repeat until success or failure, and whether to restart the test runner for each repetition:
```zsh
% xcodebuild test -scheme SampleApp -only-testing SampleAppTests/SampleAppTests/testEmptyArrayWhenNoOverlappingNotes -run-tests-until-failure -test-iterations 20
```


## Setting up StoreKit Testing in Xcode
> https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode

### 
#### 
If you rename the configuration file, be sure to keep its file extension .`storekit`.
#### 
#### 
#### 
#### 
Be sure your code uses the correct certificate in all environments. Add the following conditional compilation block to your receipt validation code to select the test certificate for testing, and the Apple root certificate, otherwise:
```swift
#if DEBUG
    let certificate = "StoreKitTestCertificate" 
#else
    let certificate = "AppleIncRootCertificate" 
#endif
```


## Setting up your project to use Xcode Cloud
> https://developer.apple.com/documentation/xcode/setting-up-your-project-to-use-xcode-cloud

### 
#### 
#### 
#### 
-  and 
If you use an IP allow list either on a self-hosted or cloud SCM provider — such as Bitbucket Server or GitHub Enterprise — make sure Xcode Cloud has access to your Git server. Check your firewall’s inbound HTTPS allow list and grant Xcode Cloud access to your Git server by adding the IP address ranges:
```other
57.103.0.0/22
57.103.64.0/18
2a01:b747:3000:200::/56
2a01:b747:3001:200::/56
2a01:b747:3002:200::/56
2a01:b747:3003:200::/56
2a01:b747:3005:200::/56
2a01:b747:3006:200::/56
2a01:b747:3004:200::/56
```


## Signing a daemon with a restricted entitlement
> https://developer.apple.com/documentation/xcode/signing-a-daemon-with-a-restricted-entitlement

### 
#### 
Switch to the Build Settings tab and remove the Enable App Sandbox (`ENABLE_APP_SANDBOX`) build setting, if present.
In the Project navigator, remove the `AppDelegate.swift`, `ViewController.swift`, `Assets.xcassets`, and `Main.storyboard` files.
Add a `main.swift` file and populate it with your daemon code.  For a minimal daemon, use this:
In the Project navigator, remove the `AppDelegate.swift`, `ViewController.swift`, `Assets.xcassets`, and `Main.storyboard` files.
Add a `main.swift` file and populate it with your daemon code.  For a minimal daemon, use this:
```swift
import Foundation

/// A helper for calling the Security framework from Swift.

func secCall<Result>(_ body: (_ resultPtr: UnsafeMutablePointer<Result?>) -> OSStatus  ) throws -> Result {
    var result: Result? = nil
    let err = body(&result)
    guard err == errSecSuccess else {
        throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
    }
    return result!
}

func main() throws {
    let me = try secCall { SecCodeCopySelf([], $0) }
    let meStatic = try secCall { SecCodeCopyStaticCode(me, [], $0) }
    let infoCF = try secCall { SecCodeCopySigningInformation(meStatic, [], $0) }
    let info = infoCF as NSDictionary
    let entitlements = info[kSecCodeInfoEntitlementsDict] as? NSDictionary
    NSLog("entitlements: %@", entitlements ?? [:])
}

try! main()
```

This code logs the current processʼs entitlements, which is a good way to confirm that youʼre set up correctly.
Build and run the daemon from Xcode.  The program logs its entitlements:
```None
2021-08-04 16:24:10.979941+0100 DaemonInAppsClothing[50219:4886989] entitlements: {
    "com.apple.application-identifier" = "SKMME9E2Y8.com.example.apple-samplecode.DaemonInAppsClothing";
    "com.apple.developer.networking.custom-protocol" = 1;
    "com.apple.developer.team-identifier" = SKMME9E2Y8;
    "com.apple.security.get-task-allow" = 1;
}
```

```
The final structure of your daemon should look like this:
```None
DaemonInAppsClothing.app/
  Contents/
    Info.plist
    MacOS/
      DaemonInAppsClothing
    PkgInfo
    _CodeSignature/
      CodeResources
    embedded.provisionprofile
```

#### 
To properly test your daemon, run it in a daemon context.  First, copy the built daemon to a secure location:
```None
% sudo mkdir "/Library/Application Support/DaemonInAppsClothing"
% sudo cp -R "DaemonInAppsClothing.app" "/Library/Application Support/DaemonInAppsClothing/"
```

Now create a `launchd` property list file that points to the daemonʼs main executable:
```
Now create a `launchd` property list file that points to the daemonʼs main executable:
```None
% /usr/libexec/PlistBuddy -c "Add :Label string com.example.apple-samplecode.DaemonInAppsClothing" "com.example.apple-samplecode.DaemonInAppsClothing.plist"
File Doesn't Exist, Will Create: com.example.apple-samplecode.DaemonInAppsClothing.plist
% /usr/libexec/PlistBuddy -c 'Add :Program string "/Library/Application Support/DaemonInAppsClothing/DaemonInAppsClothing.app/Contents/MacOS/DaemonInAppsClothing"' "com.example.apple-samplecode.DaemonInAppsClothing.plist"
% cat com.example.apple-samplecode.DaemonInAppsClothing.plist 
…
<dict>
    <key>Label</key>
    <string>com.example.apple-samplecode.DaemonInAppsClothing</string>
    <key>Program</key>
    <string>/Library/Application Support/DaemonInAppsClothing/DaemonInAppsClothing.app/Contents/MacOS/DaemonInAppsClothing</string>
</dict>
</plist>
```

Copy that to `/Library/LaunchDaemons` and then load and start your daemon:
```
Copy that to `/Library/LaunchDaemons` and then load and start your daemon:
```None
% sudo cp com.example.apple-samplecode.DaemonInAppsClothing.plist /Library/LaunchDaemons 
% sudo launchctl load /Library/LaunchDaemons/com.example.apple-samplecode.DaemonInAppsClothing.plist 
% sudo launchctl start com.example.apple-samplecode.DaemonInAppsClothing                      
```

```
Run the Console app and look in the system log.  At the point when you started the daemon, youʼll see a log entry like this:
```None
entitlements: {
    "com.apple.application-identifier" = "SKMME9E2Y8.com.example.apple-samplecode.DaemonInAppsClothing";
    "com.apple.developer.networking.custom-protocol" = 1;
    "com.apple.developer.team-identifier" = SKMME9E2Y8;
    "com.apple.security.get-task-allow" = 1;
}
```

If you miss it, run the `launchctl start` command to start your daemon again.
#### 

## Simulating location in tests
> https://developer.apple.com/documentation/xcode/simulating-location-in-tests

### 
#### 
#### 
#### 
#### 
In your UI automation tests, update the simulated device location by setting the shared  location to an instance of .
```swift
import XCTest
import CoreLocation

final class SampleAppTests: XCTestCase {

  func testExample() throws {
    XCUIDevice.shared.location = XCUILocation(location: CLLocation(latitude: 37.334886, longitude: -122.008988))
	// Launch your app and run the test.
  }
}
```


## Specifying your app’s color scheme
> https://developer.apple.com/documentation/xcode/specifying-your-apps-color-scheme

### 
#### 
If your app doesn’t have an `AccentColor` color set, create a color set manually.
#### 
#### 
By default, your accent color applies to all views and controls in your app that use a tint color, unless you override the color for a specific subset of the view hierarchy. However, you might want to incorporate the accent color into other parts of your user interface that don’t rely on a tint color, like static text elements.
To use the accent color value from an asset catalog in code, load the color like this:
```swift
// SwiftUI
Text("Accent Color")
    .foregroundStyle(Color.accentColor)

// UIKit
label.textColor = UIColor.tintColor
```


## Stepping through code and inspecting variables to isolate bugs
> https://developer.apple.com/documentation/xcode/stepping-through-code-and-inspecting-variables-to-isolate-bugs

### 
#### 
#### 
#### 
#### 
Print the value of a variable in the current stack frame using `frame variable`, or the shortened alias `v`.
To see more information than the summary of a variable shows in the variables viewer, or to change the value of a variable in the middle of a debugging session, use the console to interact with the debugger directly.
Print the value of a variable in the current stack frame using `frame variable`, or the shortened alias `v`.
```other
(lldb) v self.fruitList.title
(String) self.fruitList.title = "Healthy Fruit”
(lldb) v self.listData[0]
(String) [0] = “Banana"
```

```
The frame variable command returns only what is currently in memory and doesn’t evaluate expressions, so it returns an error if you attempt to print something more. For example, it won’t print a function or method call, an `@Published` variable, or a calculated variable.
```other
(lldb) v fruitList.fruit(at: indexPath)
error: no variable named 'fruitList' found in this frame
error: no variable named 'indexPath)' found in this frame
(lldb) v self.fruitList.calculatedFruitCount
error: "calculatedFruitCount" is not a member of "(Debugger_Demo.FruitList) self.fruitList”
```

Evaluate an expression and print the result in the console with the `expression` command, or the aliases `expr` or `p.`
```
Evaluate an expression and print the result in the console with the `expression` command, or the aliases `expr` or `p.`
```other
(lldb) p self.fruitList.calculatedFruitCount
(Int) $R18 = 9
(lldb) p fruitList.fruit(at: indexPath)
(Debugger_Demo.FruitItem) $R20 = 0x00006000013dcc90 (fruitName = "Strawberry", fruitDescription = "Small red berry with seeds on the outside.”)
(lldb) expr fruit.fruitName
(String) $R14 = "Strawberry"
(lldb) p fruit.fruitName == "Peach"
(Bool) $R16 = false
```

```
The `p` command compiles code to evaluate the expression, so it handles function calls and calculated variables. Use the references that `p` provides as parts of other expressions.
```other
(lldb) p fruit.fruitName
(String) $R2 = "Banana"
(lldb) p fruit.fruitName
(String) $R6 = "Strawberry"
(lldb) p $R2 + ", " + $R6
(String) $R8 = "Banana, Strawberry"
```

```
For some classes, using `p` may display only a memory pointer location, or may show a fully expanded view of all the attributes of the class, which can be a lot of unnecessary information. In those cases, use `po`, an alias for `expression —object-description`. This version also compiles code to evaluate the expression, but it prints an object description for the result, which you can customize for your objects.
```other
(lldb) po cell
<Debugger_Demo.ListTableViewCell: 0x7fca3450e520; baseClass = UITableViewCell; frame = (0 28; 414 43.5); clipsToBounds = YES; layer = <CALayer: 0x600001d3ed40>>
(lldb) po fruitList
Yummy Fruit: 9 items starting with Banana
```

Change the value of a variable in memory while you are debugging with either `p` or `po.`
Change the value of a variable in memory while you are debugging with either `p` or `po.`
```other
(lldb) po fruitList.title = "Tasty Fruit"
0 elements

(lldb) po fruitList
Tasty Fruit: 9 items starting with Banana
```

```
When you print an item that you declare using a protocol, `p` and `po` print an error because they don’t perform iterative dynamic type resolution. Use `v` to print variables when `p` or `po` print an error.
```other
(lldb) po fruitItem.fruitName
error: <EXPR>:3:11: error: value of type 'FruitDisplayProtocol' has no member 'fruitName'
fruitItem.fruitName
~~~~~~~~~ ^~~~~~~~~

(lldb) v fruitItem.fruitName
(String) fruitItem.fruitName = "Apple"
```


## Supporting associated domains
> https://developer.apple.com/documentation/xcode/supporting-associated-domains

### 
#### 
To add the associated domain file to your website, create a file named `apple-app-site-association` (without an extension). Update the JSON code in the file for the services you support on the domain. For universal links, be sure to list the app identifiers for your domain in the `applinks` service. Similarly, if you create an App Clip, be sure to list your App Clip’s app identifier using the `appclips` service.
The following JSON code represents the contents of a simple association file:
```other
{
  "applinks": {
      "details": [
           {
             "appIDs": [ "ABCDE12345.com.example.app", "ABCDE12345.com.example.app2" ],
             "components": [
               {
                  "#": "no_universal_links",
                  "exclude": true,
                  "comment": "Matches any URL with a fragment that equals no_universal_links and instructs the system not to open it as a universal link."
               },
               {
                  "/": "/buy/*",
                  "comment": "Matches any URL with a path that starts with /buy/."
               },
               {
                  "/": "/help/website/*",
                  "exclude": true,
                  "comment": "Matches any URL with a path that starts with /help/website/ and instructs the system not to open it as a universal link."
               },
               {
                  "/": "/help/*",
                  "?": { "articleNumber": "????" },
                  "comment": "Matches any URL with a path that starts with /help/ and that has a query item with name 'articleNumber' and a value of exactly four characters."
               }
             ]
           }
       ]
   },
   "webcredentials": {
      "apps": [ "ABCDE12345.com.example.app" ]
   },

    "appclips": {
        "apps": ["ABCDE12345.com.example.MyApp.Clip"]
    }
}
```

```
The `appIDs` and `apps` keys specify the application identifiers for the apps that are available for use on this website along with their service types. Use the following format for the values in these keys:
```javascript
<Application Identifier Prefix>.<Bundle Identifier>
```

After you construct the association file, place it in your site’s .`well-known` directory. The file’s URL should match the following format:
The `details` dictionary only applies to the  service type; other service types don’t use it. The `components` key is an array of dictionaries that provides pattern matching for components of the URL.
After you construct the association file, place it in your site’s .`well-known` directory. The file’s URL should match the following format:
```other
https://<fully qualified domain>/.well-known/apple-app-site-association
```

You must host the file using `https://` with a valid certificate and with no redirects.
#### 
Add the domains that share credentials with your app. For services other than `appclips`, you can prefix a domain with `*.` to match all of its subdomains.
Each domain you specify uses the following format:
```other
<service>:<fully qualified domain>
```

While you’re developing your app, if your web server is unreachable from the public internet, you can use the alternate mode feature to bypass the CDN and connect directly to your private domain.
You enable an alternate mode by adding a query string to your associated domain’s entitlement as follows:
```other
<service>:<fully qualified domain>?mode=<alternate mode>
```


## Supporting universal links in your app
> https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app

### 
#### 
When the system opens your app as the result of a universal link, your app receives an  object with an  value of . The activity object’s  property contains the HTTP or HTTPS URL that the user accesses. Use  APIs to extract the components of the URL. See the examples that follow.
This example code shows how to handle a universal link in macOS:
```swift
func application(_ application: NSApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool
{
    // Get URL components from the incoming user activity.
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
        let incomingURL = userActivity.webpageURL,
        let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
        return false
    }

    // Check for specific URL components that you need.
    guard let path = components.path,
    let params = components.queryItems else {
        return false
    }    
    print("path = \(path)")

    if let albumName = params.first(where: { $0.name == "albumname" } )?.value,
        let photoIndex = params.first(where: { $0.name == "index" })?.value {            
        print("album = \(albumName)")
        print("photoIndex = \(photoIndex)")
        return true  

    } else {
        print("Either album name or photo index missing")
        return false
    }
}
```

```
This example code shows how to handle a universal link in iOS and tvOS:
```swift
func application(_ application: UIApplication,
                 continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
{
    // Get URL components from the incoming user activity.
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
        let incomingURL = userActivity.webpageURL,
        let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
        return false
    }

    // Check for specific URL components that you need.
    guard let path = components.path,
    let params = components.queryItems else {
        return false
    }    
    print("path = \(path)")

    if let albumName = params.first(where: { $0.name == "albumname" } )?.value,
        let photoIndex = params.first(where: { $0.name == "index" })?.value {

        print("album = \(albumName)")
        print("photoIndex = \(photoIndex)")
        return true

    } else {
        print("Either album name or photo index missing")
        return false
    }
}
```

```
If your app has opted into , and your app is not running, the system delivers the universal link to the  delegate method after launch, and to  when the universal link is tapped while your app is running or suspended in memory.
```swift
func scene(_ scene: UIScene, willConnectTo
           session: UISceneSession,
           options connectionOptions: UIScene.ConnectionOptions) {
    
    // Get URL components from the incoming user activity.
    guard let userActivity = connectionOptions.userActivities.first,
        userActivity.activityType == NSUserActivityTypeBrowsingWeb,
        let incomingURL = userActivity.webpageURL,
        let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
        return
    }

    // Check for specific URL components that you need.
    guard let path = components.path,
        let params = components.queryItems else {
        return
    }
    print("path = \(path)")

    if let albumName = params.first(where: { $0.name == "albumname" })?.value,
        let photoIndex = params.first(where: { $0.name == "index" })?.value {
        
        print("album = \(albumName)")
        print("photoIndex = \(photoIndex)")
    } else {
        print("Either album name or photo index missing")
    }
}
```

```
This example code shows how to handle a universal link in watchOS:
```swift
func handle(_ userActivity: NSUserActivity)
{
    // Get URL components from the incoming user activity.
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
        let incomingURL = userActivity.webpageURL,
        let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else { return }

    // Check for specific URL components that you need.
    guard let path = components.path,
    let params = components.queryItems else { return }    
    print("path = \(path)")

    if let albumName = params.first(where: { $0.name == "albumname" } )?.value,
        let photoIndex = params.first(where: { $0.name == "index" })?.value {            
        print("album = \(albumName)")
        print("photoIndex = \(photoIndex)")
    } else {
        print("Either album name or photo index missing")
    }
}
```


## Swift access races
> https://developer.apple.com/documentation/xcode/swift-access-races

### 
#### 
In the following example, the `producer()` function adds messages to a global array, and the `consumer()` function removes messages from the array and prints them. Because `producer()` executes on one thread and `consumer()`  executes on another, and both call mutating methods on the array, there is an access race on `messages`.
```swift
var messages: [String] = []
// Executed on Thread #1
func producer() {
    messages.append("A message");
}
// Executed on Thread #2
func consumer() {
    repeat {
        let message = messages.remove(at: 0)
        print("\(message)")
    } while !messages.isEmpty
}
```

Use  APIs to coordinate access to `messages` across multiple threads.
#### 
In the following example, the `writeNumbers()` function writes numbers to a global string. The `writeLetters()` function writes letters to the same string. Because the two functions execute on different threads and both access `log` by reference using `inout,` there is an access race on `log`.
```swift
var log: String = ""
// Executed on Thread #1
func writeNumbers() {
    print(1, 2, 3, separator: ",", to: &log)
}
// Executed on Thread #2
func writeLetters() {
    print("a", "b", "c", separator:",", to: &log)
}
```

Use  APIs to coordinate access to `log` across multiple threads.

## Testing a release build
> https://developer.apple.com/documentation/xcode/testing-a-release-build

### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 
- The build UUID of the app archive you’re testing
To retrieve the archived app’s build UUID, run the Terminal command:
```bash
% dwarfdump -u /Path/To/YourApp.xcarchive/Products/Applications/YourApp.app/YourApp
```


## Thread leaks
> https://developer.apple.com/documentation/xcode/thread-leaks

### 
#### 
In the following example, the code creates a `thread` variable, but doesn’t close it after use:
In the following example, the code creates a `thread` variable, but doesn’t close it after use:
```occ
void *run(){
    pthread_exit(0);
}
pthread_t thread;
pthread_create(&thread, NULL, run, NULL); // Error: thread leak
sleep(1);
```

Add a call to the `pthread_join(_:_:)` function.
Add a call to the `pthread_join(_:_:)` function.
```swift
void *run(){
    pthread_exit(0);
}
pthread_t thread;
pthread_create(&thread, NULL, run, NULL);
sleep(1);
pthread_join(thread, NULL); // Correct
```


## Troubleshooting Simulator launch or animation issues
> https://developer.apple.com/documentation/xcode/troubleshooting-simulator-launch-or-animation-issues

### 
#### 
2. Run the command `sudo launchctl limit`. Provide your password when Terminal requests it, because you’re running the command as superuser.
3. Note the maximum number of processes next to `maxproc`, and the maximum number of files next to `maxfiles`.
Run the command `ps -A | wc -l` in Terminal to show the current total of running processes.
#### 
#### 
For issues that may be part of Simulator or a simulated device, please file a bug through the .
When you file a bug, include the full version number of Xcode in the bug title and in the description. To find the version number, choose Xcode > About Xcode. The full version number including the part in parentheses is in the window that Xcode displays. If the bug is with a simulated device, attach a `sysdiagnose` for that device by opening Terminal and typing the following command:
```None
xcrun simctl diagnose
```

Press Enter again to display the status of the capture as well as the path for the file with the `sysdiagnose`.
For more information on `diagnose`, run the following command:
Press Enter again to display the status of the capture as well as the path for the file with the `sysdiagnose`.
For more information on `diagnose`, run the following command:
```None
xcrun simctl diagnose --help
```


## Understanding build product layout changes in Xcode
> https://developer.apple.com/documentation/xcode/understanding-build-product-layout-changes

### 
#### 
If you open your app bundle, you see two dynamic library files (`.dylib`) in the executable directory. For example, this is part of the layout of an iOS app bundle:
```None
MyApp.app
    - MyApp
    - MyApp.debug.dylib
    - __preview.dylib
    - <other resources>
```

The symbols and Mach-O sections of an unoptimized build link into this separate `.dylib` file, unlike release builds that link into the main binary.
#### 
The build setting `ENABLE_DEBUG_DYLIB` controls this mode and defaults to `YES` if these three conditions are met:
- `SWIFT_VERSION` is set
- `SWIFT_OPTIMIZATION_LEVEL` is set to `-Onone`

## Understanding hangs in your app
> https://developer.apple.com/documentation/xcode/understanding-hangs-in-your-app

### 
#### 
Your code is involved in each of these stages, but most of it typically deals with the second stage.
Consider the Send button in a messaging app using SwiftUI. Your implementation might look like the following:
```swift
import SwiftUI 

struct MessengerView: View {
    @State var messageText: String

    var body: someView {
        // [...] other UI
        Button("Send", action: {
            messageSender.send(message: messageText)
        })
        // [...] other UI
    }
}
```

#### 
Run loops provide a mechanism for threads to wait on input sources and fire input handlers when any of those sources has data or events to process. Any thread can have a run loop. The main thread starts a run loop, the , as soon as an app finishes launching. This is the run loop that processes all incoming user interaction events.
A very simplified implementation of a run loop might resemble the following:
```swift
class RunLoop {
    var stopped = false
    
    func run() {
        repeat {
            if let work = workSet.fetchNextWorkItem() {
                processWork(work)
            } else {
                sleepUntilNewWorkArrives()
            }
        } while(!stopped)
    }
}
```

#### 

## Understanding the exception types in a crash report
> https://developer.apple.com/documentation/xcode/understanding-the-exception-types-in-a-crash-report

### 
The exception type in a crash report describes how the app terminated. It’s a key piece of information that guides how to investigate the source of the problem.
```other
Exception Type: EXC_BAD_ACCESS (SIGSEGV)
```


## Uninitialized mutexes
> https://developer.apple.com/documentation/xcode/uninitialized-mutexes

### 
#### 
In the following example, the `pthread_mutex_lock(_:)` function executes with an uninitialized `pthread_mutex_t` variable:
In the following example, the `pthread_mutex_lock(_:)` function executes with an uninitialized `pthread_mutex_t` variable:
```occ
static pthread_mutex_t mutex;
void performWork() {
    pthread_mutex_lock(&mutex); // Error: uninitialized mutex
    // ...
    pthread_mutex_unlock(&mutex);
}
```

Use the `pthread_once(_:_:)` function to initialize a mutex before you use it.
Use the `pthread_once(_:_:)` function to initialize a mutex before you use it.
```occ
static pthread_once_t once = PTHREAD_ONCE_INIT;
static pthread_mutex_t mutex;
void init() {    
    pthread_mutex_init(&mutex, NULL);
}
void performWork() {
    pthread_once(&once, init); // Correct
    pthread_mutex_lock(&mutex);
    // ...
    pthread_mutex_unlock(&mutex);
}
```


## Updating your existing codebase to accommodate unit tests
> https://developer.apple.com/documentation/xcode/updating-your-existing-codebase-to-accommodate-unit-tests

### 
#### 
When your code relies on a specific type whose behavior makes testing difficult, create a protocol that lists the methods and properties used by your code. You can use this approach when interacting with components in your own codebase or with APIs from other sources outside of your control, including platform SDKs and Swift packages. Examples of such problematic dependencies include those that access external state, including user documents or databases, or those that don’t have deterministic results, including network connections or random value generators.
The following shows a class in an app that uses an opaque service to open a file which represents an attachment handled by external dependencies. The outcome of the `openAttachment(file:with:)` method depends on whether the opaque service can handle files of the requested type, and whether the application successfully opens the file. All of these variables could introduce test failures, which would slow down development as you investigate “errors” that turn out to be transient problems unrelated to your code.
```swift
private enum AttachmentOpeningError: Error {
    case unableToOpenAttachment
}

struct AttachmentOpener {
  func openAttachment(file location: URL, with service: OpaqueService) throws {
    if (!service.open(location)) {
      throw AttachmentOpeningError.unableToOpenAttachment
    }
  }
}
```

To test code with this coupling, introduce a protocol that describes how your code interacts with the problematic dependency. Use that protocol in your code, so the class depends on the existence of the methods in the protocol, but not their specific implementation. Write an alternative implementation of the protocol that doesn’t perform the stateful or nondeterministic tasks, and use that implementation to write tests with controlled behavior.
In this listing, a protocol that includes the `open` method is defined, along with an extension to opaque class that makes it conform to the protocol.
```swift
protocol URLOpener {
    func open(_ file: URL) -> Bool
}

extension OpaqueService : URLOpener {}

struct AttachmentOpener {
    func openAttachment(file location: URL, with service: URLOpener) throws {
        if (!service.open(location)) {
            throw AttachmentOpeningError.unableToOpenAttachment
        }
    }
}

class StubService: URLOpener {
    var isSuccessful = true

    func open(_ file: URL) -> Bool {
        return isSuccessful
    }
}
```

In tests, write a different implementation of the `URLOpener` protocol that doesn’t depend on the apps installed on the user’s computer.
#### 
In each of these cases, because the objects are created by the code you want to test, you can’t pass in a different object as a parameter to the method. The object doesn’t exist until it’s created by your code, at which point it’s of the type that has the untestable behavior.
The listing below shows a `DocumentLoader` class that creates and loads a `Document`, for example, in response to a UI action. The document object it creates reads and writes data to the file system, so its behavior isn’t easy to control in a unit test.
```swift
enum DocumentError : Error {
    case cannotLoadContent
    case cannotSaveContent
}

class Document {
    private var location: URL
    private var titleContent: String?
    var title : String {
        get {
            return titleContent ?? "Untitled"
        }
        set {
            titleContent = newValue
        }
    }

    required init(fileURL: URL) {
        location = fileURL
    }
    
    func load() throws {
        do {
            let myString = try String(contentsOf: location, encoding: .utf8)
        }
        catch {
            throw DocumentError.cannotLoadContent
        }
    }
    
    func save() throws {
        do {
            try titleContent?.write(to: location, atomically: true, encoding: .utf8)
        }
        catch {
            throw DocumentError.cannotSaveContent
        }
    }
}

class DocumentLoader {
    func loadDocument(at location: URL) -> Bool {
        do {
            var document = Document(fileURL: location)
            try document.load()
            // Do something with the document, for example, present it in the app's UI.
            return true
        } catch {
            return false
        }
    }
}
```

```
To remove the coupling between the code you’re trying to test and the objects it creates, define a variable on the class under test that represents the  of object it should construct. Such a variable is called a . Set the default value to the type the class already uses. You’ll need to ensure that the initializer used to construct instances is marked `required`. This listing shows the document browser view controller delegate with that variable introduced. The delegate creates documents with the type defined by the metatype value.
```swift
class DocumentLoader {
    var DocumentClass = Document.self

    func loadDocument(at location: URL) -> Bool {
        do {
            var document = DocumentClass.init(fileURL: location)
            try document.load()
            // Do something with the document, for example, present it in the app's UI.
            return true
        } catch {
            return false
        }
    }
}
```

```
Set a different value for the metatype in tests, so your code constructs an object that doesn’t have the same untestable behavior. In tests, create a “sample” version of the document class: a class with the same interface, but which doesn’t implement the behavior that makes it hard to test. In this case, a sample document class should not interact with the file system.
```swift
class SampleDocument : Document {
    static var loadsSuccessfully : Bool = true
    static var savesSuccessfully : Bool = true
    
    override func load() throws {
        guard SampleDocument.loadsSuccessfully else {
            throw DocumentError.cannotLoadContent
        }
    }
    
    override func save() throws {
        guard SampleDocument.savesSuccessfully else {
            throw DocumentError.cannotSaveContent
        }
    }
}
```

#### 
Introducing tests for the custom app logic is desirable, to ensure that this logic works as expected and to protect against regressions. The complexity of controlling or working around the interactions between the class and the environment make testing the logic difficult.
As an example, the following account object provides a method to calculate someone’s birthday. It does the calculation by finding the number of years between the account’s recorded date of birth and today’s date.
```swift
import Foundation

enum AccountError : Error {
    case cannotCalculateAge
}

class Account {
    let name: String
    let email: String
    let userId: String
    let dateOfBirth: Date
    
    init(name: String, email: String, userId: String, dateOfBirth: Date) {
        self.name = name
        self.email = email
        self.userId = userId
        self.dateOfBirth = dateOfBirth
    }
    
    var now : Date {
        get {
            return Date()
        }
    }
    
    func age() throws -> Int {
        let calendar = Calendar.current
        let birthday = calendar.startOfDay(for: dateOfBirth)
        let today = calendar.startOfDay(for: now)
        guard let years =  calendar.dateComponents([.year], from: birthday, to: today).year else {
            throw AccountError.cannotCalculateAge
        }
        return years
    }
}
```

To overcome this complexity, subclass the `Account` and “stub out” methods that produce complex, untestable interactions, by overriding them with simpler methods. Use the subclass in your tests to verify the behavior of the custom logic, which you don’t override. You may also need to introduce a metatype value, if the code under test creates an instance of the target type.
The following listing introduces a subclass, `StubAccount`, which doesn’t rely on the system’s clock. Instead, it uses a fixed date that’s configured by the caller. Tests using this subclass provide fixed values for both the account’s date of birth and the date that represents the current date, to ensure that the calculation the `Account` object performs is correct.
```swift
class StubAccount : Account {
    private var overrideNow : Date
    
    init(name: String, email: String, userId: String, dateOfBirth: Date, overrideNow: Date) {
        self.overrideNow = overrideNow
        super.init(name: name, email: email, userId: userId, dateOfBirth: dateOfBirth)
    }
    
    override var now : Date {
        overrideNow
    }
}
```

#### 
In this example, a `LoginHandler` object participates in authenticating someone to a network service. Part of its capability is retrieving a username that the app previously used for the service, which it gets from the standard user defaults object:
```swift
class LoginHandler {
    
    var previousUsername: String? {
        get {
            UserDefaults.standard.string(forKey: "ExampleAccountUsername")
        }
    }
    
}
```

 relies on shared state that’s stored in the file system and might be modified by other code in the app or by someone editing files on their Mac. Replace direct access to the singleton object with a parameter or property that can be controlled from outside the component under test. In the app, continue to use the singleton as the collaborator for the component. In tests, supply an alternative object that’s easier to control.
The following listing shows the result of applying this change to the `LoginHandler` class listed above. The login handler gets the stored username from its `storage` object, which defaults to the user defaults singleton. An extension conforms `UserDefaults` to the `LoginStorage` protocol, so that tests can supply alternative implementations of the protocol.
```swift
protocol LoginStorage {
    func string(forKey: String) -> String?
}

extension UserDefaults : LoginStorage { }

class LoginHandler {
    private var storage: LoginStorage
    
    init(storage: LoginStorage = UserDefaults.standard) {
        self.storage = storage
    }
    
    var previousUsername: String? {
        get {
            storage.string(forKey: "ExampleAccountUsername")
        }
    }
    
}
```


## Use of deallocated memory
> https://developer.apple.com/documentation/xcode/use-of-deallocated-memory

### 
#### 
In the following example, the `unsafePointer` variable has `__unsafe_unretained` ownership. Because there are no other objects that have a strong reference to it, the autorelease pool deallocates the variable, causing it to point to invalid memory.
```occ
__unsafe_unretained MyClass *unsafePointer;
@autoreleasepool {    
    MyClass *object = [MyClass new];
    unsafePointer = object;
}
NSLog(@"%d", unsafePointer->instanceVariable); 
// Error: unsafePointer is deallocated in autorelease pool
```

#### 
This issue exists when using pointers to nonobject types, as well. In the following example, the pointer to the instance variable invalidates when deallocating the object:
```occ
int *unsafePointer;
@autoreleasepool {    
    MyClass *object = [MyClass new];
    unsafePointer = &object->instanceVariable;
}
NSLog(@"%d", *unsafePointer);
// Error: unsafePointer is invalidated when object is deallocated in autorelease pool
```


## Use of out-of-scope stack memory
> https://developer.apple.com/documentation/xcode/use-of-out-of-scope-stack-memory

### 
#### 
In the following example, the code conditionally assigns the `pointer` variable to the return value of the `integer_returning_function` function, which it then accesses out of its declaration scope:
```occ
int *pointer = NULL;
if (bool_returning_function()) {
    int value = integer_returning_function();
    pointer = &value;
}
*pointer = 42; // Error: invalid access of stack memory out of declaration scope
```

Ensure you don’t access variables outside of their declared scope, or allocate memory using the `malloc` function.

## Use of stack memory after function return
> https://developer.apple.com/documentation/xcode/use-of-stack-memory-after-function-return

### 
#### 
In the following example, the `integer_pointer_returning_function` function returns a pointer to a stack variable, and there’s an attempt to access the memory of the returned pointer:
```occ
int *integer_pointer_returning_function() {
    int value = 42;
    return &value;
}

int *integer_pointer = integer_returning_function();
*integer_pointer = 43; // Error: invalid access of returned stack memory
```


## Using the latest code signature format
> https://developer.apple.com/documentation/xcode/using-the-latest-code-signature-format

### 
#### 
To check whether an app called `MyApp.app` has the new signature, you can use the  utility:
For apps that you distribute other ways, such as Ad Hoc or through the , Xcode and the `codesign` utility have created signatures that use the new format for several years. If you signed your app on a Mac running macOS 10.14 through macOS 11, the app already has the new signature format, but your signature may not include the required DER entitlements. macOS 11 and later will sign app bundles with the new signature format that include the DER entitlements by default.
To check whether an app called `MyApp.app` has the new signature, you can use the  utility:
```other
% codesign -dv /path/to/MyApp.app
```

Look in the output for a string such as `CodeDirectory v=20500`. For any value of `v` less than `20400`, you need to re-sign your app.
To check whether the app has the DER entitlements, look for the hash list under Page size in the signature. If `-5` contains a value and `-7` contains a zero value, or is not present, you need to re-sign your app to include the new DER entitlements.
Valid signature:
```other
Page size=4096
     -7=f4c7c0ae394247097dca9b19333001200747691e1d9e25ec0cf0f35a8ade21f3
     -6=0000000000000000000000000000000000000000000000000000000000000000
     -5=7379374fd375633558fd972e33809c06e61f9f8191f67c71875899b0dc290945
     -4=0000000000000000000000000000000000000000000000000000000000000000
     -3=53cc3cc9830555e6d7bc864522fdf160b61ccc0d2fda9331368d333dfaa4fe24
```

```
Invalid signature:
```other
Page size=4096
     -5=7c741a970873bb7f6a05c1ad5b9425f4b5b1ac86645b2cb8c842a57f51818eb5
     -4=0000000000000000000000000000000000000000000000000000000000000000
     -3=f7ddc8d932def2f393dfc1719252e61b1561afeed76d32044ae0cd793e380bc6
     -2=904f563968898c7569794e19bcd9304d46ca5c0b9f09c792081bdb8ec9c04c92
```

#### 
#### 
If your app doesn’t have the new signature format, or is missing the DER entitlements in the signature, you’ll need to re-sign the app on a Mac running macOS 11 or later, which includes the DER encoding by default.
If you’re unable to use macOS 11 or later to re-sign your app, you can re-sign it from the command-line in macOS 10.14 and later. To do so, use the following command to re-sign the `MyApp.app` app bundle with DER entitlements by using a signing identity named “Your Codesign Identity” stored in the keychain:
```other
% codesign -s "Your Codesign Identity" -f --preserve-metadata --generate-entitlement-der /path/to/MyApp.app
```


## Validating your app’s Metal shader usage
> https://developer.apple.com/documentation/xcode/validating-your-apps-metal-shader-usage

### 
#### 
#### 
Shader Validation instruments all pipelines by default (`MTL_SHADER_VALIDATION_DEFAULT_STATE=all`). To change this behavior, you can set `MTL_SHADER_VALIDATION_DEFAULT_STATE=none`.
Next, you can set `MTL_SHADER_VALIDATION_ENABLE_PIPELINES` and `MTL_SHADER_VALIDATION_DISABLE_PIPELINES` to selectively enable and disable instrumentation for given pipelines. You can use the pipeline labels and Shader Validation unique identifiers (UIDs) as entries (see ). Multiple entries need to be comma-separated, without spaces (see `man MetalValidation` for more information). In the following example, the pipelines with the label `foo` are the only pipelines not instrumented by Shader Validation.
```zsh
> export MTL_SHADER_VALIDATION=1
> export MTL_SHADER_VALIDATION_DEFAULT_STATE=all
> export MTL_SHADER_VALIDATION_DISABLE_PIPELINES="foo"
...

> ./<application>
```

In the following example, `pipelineState` is the only pipeline instrumented by Shader Validation.
Alternatively, you can programmatically set your pipeline descriptor property  to either  or .
In the following example, `pipelineState` is the only pipeline instrumented by Shader Validation.
```zsh
> export MTL_SHADER_VALIDATION=1
> export MTL_SHADER_VALIDATION_DEFAULT_STATE=none
> ...

> ./<application>
```

#### 
#### 
#### 
For a complete list of settings, run `man MetalValidation` in Terminal.

## Writing 64-bit Intel code for Apple Platforms
> https://developer.apple.com/documentation/xcode/writing-64-bit-intel-code-for-apple-platforms

### 
#### 
#### 
Asynchronous Swift functions receive the address of their async frame in `r14`. `r14` is no longer a callee-saved register for such calls.
#### 
#### 
- For vectors larger than 8 bytes, the classification algorithm uses the rules from the standard psABI, including the rule that vectors larger than the maximum native vector size are classified as `MEMORY`. Just as with data layout, this means the calling convention for vector types larger than 16 bytes depends on the current target CPU features, and code may not interoperate between files compiled with different CPU features.
- The classification algorithm does not perform step (b) of the post-merger cleanup. Instead, after classification is otherwise complete (not during recursive classification), `X87UP` is converted to `SSE` when it does not follow `X87`. For example:
```None
typedef union { long double d; void *p; } odd_union;
void f(odd_union u);
```

The caller passes the first eight bytes of `u` in `rdi`, and passes the second eight bytes (the exponent bits of `u.d`) in the low bits of `xmm0`.

## Writing ARM64 code for Apple platforms
> https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms

### 
#### 
- The platforms reserve register `x18`. Don’t use this register.
#### 
- The `wchar_t` type is 32 bit and is a signed type.
- The `char` type is a signed type.
- The `long` type is 64 bit.
- The `__fp16` type uses the IEEE754-2008 format, where applicable.
| `BOOL`, `bool` | 1 | 1 |
| `char` | 1 | 1 |
| `short` | 2 | 2 |
| `int` | 4 | 4 |
| `long` | 8 | 8 |
| `long long` | 8 | 8 |
| `size_t` | 8 | 8 |
| `NSInteger` | 8 | 8 |
| `CFIndex` | 8 | 8 |
| `fpos_t` | 8 | 8 |
| `off_t` | 8 | 8 |
#### 
#### 
- Functions may ignore parameters that contain empty struct types. This behavior applies to the GNU extension in C and, where permitted by the language, in C++. The AArch64 documentation doesn’t address the issue of empty structures as parameters, but Apple chose this path for its implementation.
The following example illustrates how Apple platforms specify stack-based arguments that are not multiples of 8 bytes. On entry to the function, `s0` occupies one byte at the current stack pointer (`sp`), and `s1` occupies one byte at `sp+1`. The compiler still adds padding after `s1` to satisfy the stack’s 16-byte alignment requirements.
```swift
void two_stack_args(char w0, char w1, char w2, char w3, char w4, char w5, char w6, char w7, char s0, char s1) {}
```

```
The following example shows a function whose second argument requires 16-byte alignment. The standard ABI requires placing the second argument in the `x2` and `x3` registers, but Apple platforms allow it to be in the `x1` and `x2` registers.
```swift
void large_type(int x0, __int128 x1_x2) {} 
```

#### 
#### 
#### 
If DIT is on prior to calling `timingsafe_enable_if_supported`, it remains on after calling `timingsafe_restore_if_supported`; otherwise, it’s turned off.
To turn on timing-safe mode before performing constant-time cryptographic operations, and subsequently restore the CPU’s previous state, use the following:
```c
#include <timingsafe.h>

int cryptographic_routine() {
    timingsafe_token_t restore_token = timingsafe_enable_if_supported();
    // Perform constant-time cryptographic operations here.
    timingsafe_restore_if_supported(restore_token);
    return 0;
}
```

To determine whether a device’s CPU supports DIT, test the `hw.optional.arm.FEAT_DIT` system control using :
Alternatively, to turn on DIT with older SDKs or platforms where the APIs aren’t available, you need to check whether DIT is defined and supported by the CPU and then use low-level kernel and CPU registers. To test whether the APIs are available, use the compiler’s  directive.
To determine whether a device’s CPU supports DIT, test the `hw.optional.arm.FEAT_DIT` system control using :
```c
#include <sys/sysctl.h>
#include <stdbool.h>

bool is_DIT_supported(void) {
    static int has_DIT = -1;
    if (has_DIT == -1) {
        size_t has_DIT_size = sizeof(has_DIT);
        if (sysctlbyname("hw.optional.arm.FEAT_DIT", &has_DIT, &has_DIT_size, NULL, 0) == -1) {
            has_DIT = 0;
        }
    }
    return has_DIT;
}
```

This function returns `1` if DIT is available; `0` otherwise.
This function returns `1` if DIT is available; `0` otherwise.
To check whether DIT is turned on for the current thread, test the `dit` bit (bit 24) of the processor state register. The `dit` bit is only defined on certain devices and you can set an attribute for the function to avoid errors when compiling for unsupported devices:
```c
#ifdef __arm64__
__attribute__((target("dit")))
bool get_DIT_enabled(void) {
    return (__builtin_arm_rsr64("dit") >> 24) & 1;
}
#endif
```

```
Turn on DIT for the current thread by setting the `dit` processor state register’s value to `1`. To ensure that subsequent instruction timing reflects the updated DIT processor state, add a speculation barrier after turning on DIT. Use the `sb` instruction to add a speculation barrier:
```c
#ifdef __arm64__
__attribute__((target("sb")))
void inst_dit_speculation_barrier(void) {
  __asm__ __volatile__("sb" ::: "memory");
}
#endif
```

```
To restore the state of DIT after the sensitive operation, read and return its current status before turning on DIT:
```c
#ifdef __arm64__
__attribute__((target("dit")))
bool set_DIT_enabled(void) {
    bool was_DIT_enabled = get_DIT_enabled();
    __asm__ __volatile__("msr dit, #1");
    inst_dit_speculation_barrier();
    return was_DIT_enabled;
}
#endif
```

```
To turn off DIT for the current thread, set the `dit` processor state register’s value to `0`. To prevent turning off DIT inadvertently in nested calls, restore DIT to its previous value instead of unconditionally turning it off. Store the initial value in thread-local storage, as you can turn DIT on or off separately on different threads. If the DIT value record before turning on DIT is `0`, set the DIT value to `0`:
```c
#ifdef __arm64__
__attribute__((target("dit")))
void restore_DIT(bool was_DIT_enabled) {
    if (was_DIT_enabled == false) {
        __asm__ __volatile__("msr dit, #0");
    }
}
#endif
```

```
To test the availability of speculation barriers, use a mechanism similar to DIT, above:
```c
bool is_SB_supported(void) {
    static int has_SB = -1;
    if (has_SB == -1) {
        size_t has_SB_size = sizeof(has_SB);
        if (sysctlbyname("hw.optional.arm.FEAT_SB", &has_SB, &has_SB_size, NULL, 0) == -1) {
            has_SB = 0;
        }
    }
    return has_SB;
}
```

```
When speculation barriers aren’t supported, use:
```c
#ifdef __arm64__
void inst_dit_speculation_barrier_unsupported(void) {
  __asm__ __volatile__ ("dsb nsh" ::: "memory");
  __asm__ __volatile__ ("isb sy" ::: "memory");
}
#endif
```

```
To create functions that are available across all devices — whether they support DIT and speculation barriers — define function pointers. If the device supports DIT, set the function pointers to functions that test and change the processor state register. When DIT isn’t supported, set the function pointers to functions that do nothing, and follow the same pattern with speculation barriers:
```c
bool(* set_DIT_enabled_if_supported)(void);
void(* restore_DIT_if_supported)(bool);
bool(* get_DIT_enabled_if_supported)(void);
void(* inst_dit_speculation_barrier_if_supported)(void);

bool set_DIT_enabled(void);
void restore_DIT(bool);
bool get_DIT_enabled(void);
void inst_dit_speculation_barrier(void);

bool set_DIT_enabled_unsupported(void);
void restore_DIT_unsupported(__unused bool was_DIT_enabled);
bool get_DIT_enabled_unsupported(void);
void inst_dit_speculation_barrier_unsupported(void);

void init_DIT_control(void);

#ifdef __arm64__
__attribute__((target("dit")))
bool set_DIT_enabled(void) {
    bool was_DIT_enabled = get_DIT_enabled();
    __asm__ __volatile__("msr dit, #1");
    inst_dit_speculation_barrier_if_supported();
    return was_DIT_enabled;
}
#endif

bool get_DIT_enabled_unsupported(void) {
    return false;
}

bool set_DIT_enabled_unsupported(void) {
    return false;
}

void restore_DIT_unsupported(__unused bool was_DIT_enabled) {
    return;
}

void init_DIT_control(void) {
#ifdef __arm64__
    if (is_SB_supported()) {
        inst_dit_speculation_barrier_if_supported = inst_dit_speculation_barrier; 
    }
    else {
        inst_dit_speculation_barrier_if_supported = inst_dit_speculation_barrier_unsupported;
    }

    if (is_DIT_supported()) {
        set_DIT_enabled_if_supported = set_DIT_enabled;
        restore_DIT_if_supported = restore_DIT;
        get_DIT_enabled_if_supported = get_DIT_enabled;
    } else
#endif
    {
        set_DIT_enabled_if_supported = set_DIT_enabled_unsupported;
        restore_DIT_if_supported = restore_DIT_unsupported;
        get_DIT_enabled_if_supported = get_DIT_enabled_unsupported;
    }
#ifdef __arm64__
    inst_dit_speculation_barrier_if_supported();
#endif
}
```

```
Altogether, you protect a set of cryptographic instructions by calling the abstracted DIT enablement function prior to the cryptographic operation, and restore the previous DIT state after:
```c
#if __has_include(<timingsafe.h>)
#include <timingsafe.h>
#endif

int main(void) {
    init_DIT_control();
    // Run the rest of your program.
    return 0;
}

int cryptographic_routine(void) {
#if __has_include(<timingsafe.h>)
    if (__builtin_available(macOS 15.2, iOS 18.2, visionOS 2.2, tvOS 18.2, watchOS 11.2, *)) {
        // API-based DIT control.
        timingsafe_token_t token = timingsafe_enable_if_supported();
        // Perform constant time cryptographic operations here.
        timingsafe_restore_if_supported(token);
    } else 
#endif
    {
        // Fallback on earlier DIT control versions.
        bool was_DIT_enabled = set_DIT_enabled_if_supported();
        // Perform constant time cryptographic operations here.
        restore_DIT_if_supported(was_DIT_enabled);
    }
    return 0;
}
```


## Writing ARMv6 code for iOS
> https://developer.apple.com/documentation/xcode/writing-armv6-code-for-ios

### 
#### 
#### 
| `BOOL`, `bool` | 1 | 1 |
| `unsigned char` | 1 | 1 |
| `char`, `signed char` | 1 | 1 |
| `unsigned short` | 2 | 2 |
| `signed short` | 2 | 2 |
| `unsigned int` | 4 | 4 |
| `signed int` | 4 | 4 |
| `unsigned long` | 4 | 4 |
| `signed long` | 4 | 4 |
| `unsigned long long` | 8 | 8 |
| `signed long long` | 8 | 8 |
| `float` | 4 | 4 |
| `double` | 8 | 4 |
| `long double` | 8 | 4 |
#### 
#### 
You don’t need to include any parts of the prolog or epilog that don’t apply to your code. For example, if a function doesn’t use high registers (R8, R10, R11) or nonvolatile VFP registers, you don’t need to save them. Leaf functions don’t need to use the stack at all, except to save nonvolatile registers.
The following example shows a prolog in ARM mode. This prolog saves the contents of the VFP registers and allocates an additional 36 bytes of local storage.
```other
stmfd    sp!, {r4-r7, lr}     // Save LR, R7, R4-R6.
add      r7, sp, #12          // Adjust R7 to point to saved R7.
stmfd    sp!, {r8, r10, r11}  // Save remaining GPRs (R8, R10, R11)
fstmfdd  sp!, {d8-d15}        // Save VFP registers D8-D15,
                              //  also known as S16-S31 or Q4-Q7.
sub      sp, sp, #36          // Allocate space for local storage
```

```
The following example shows the corresponding epilog in ARM mode. The epilog deallocates the local storage and restores the registers that the prolog saved.
```other
add      sp, sp, #36         // Deallocate local storage.
fldmfdd  sp!, {d8-d15}       // Restore VFP registers.
ldmdd    sp!, {r8, r10, r11} // Restore R8-R11.
ldmdd    sp!, {r4-r7, pc}    // Restore R4-R6, saved R7,
                             //  and return to saved LR.
```

```
The following example shows a prolog in Thumb mode. This prolog doesn’t save VFP registers because Thumb-1 cannot access those registers.
```other
push   {r4-r7, lr}     // Save Lr, R7, R4-R6.
mov    r6, r11         // Move high registers to low registers, so
mov    r5, r10         //  they can be saved. (Skip this part if
mov    r4, r8          //  the routine doesn’t use R8, R10, or R11.)
push   {r4-r6)         // Save R8, R10, R11 (now in R4-R6).
add    r7, sp, #24     // Adjust R7 to point to saved R7.
sub    sp, #36         // Allocate space for local storage.
```

```
The following example shows the corresponding epilog in Thumb mode. This example restores the registers the prolog saved.
```other
add    sp, #36         // Deallocate space for local storage
pop    {r4-r6}         // Pop R8, R10, R11
mov    r8, r4          // Restore high registers.
mov    r10, r5
mov    r11, r6
pop    {r4-r7, pc)     // Restore R4-R6, saved R7, and
                       //  return to saved LR.

```

#### 

## Writing ARMv7 code for iOS
> https://developer.apple.com/documentation/xcode/writing-armv7-code-for-ios

### 
#### 
#### 
The version of Thumb in ARMv7 is compatible with ARM assembly instructions.  Specifically, Thumb is capable of saving and restoring the contents of the VFP registers, and ARMv7 assembly uses a unified set of mnemonics.
The following example shows a prolog that saves key registers, including several VFP registers. It also allocates 36 bytes for local storage.
```other
push add  {r4-r7, lr}     // save LR, R7, R4-R6.
add       r7, sp, #12     // Adjust R7 to point to saved R7.
push      {r8, r10, r11}  // Save remaining GPRs (R8, R10, R11).
vstmdb    sp!, {d8-d15}   // Save VFP/Advanced SIMD registers D8 
                          // (aka S16-S31, Q4-Q7).
sub       sp, sp, #36     // Allocate space for local storage.
```

```
The following example shows the epilog that restores the registers saved by the preceding prolog:
```other
add       sp, sp, #36     // Deallocate space for local storage.
vldmia    sp!, {d8-d15}   // Restore VFP/Advanced SIMD registers.
pop       {r8, r10, r11}  // Restore R8-R11.
pop       {r4-r7, pc}     // Restore R4-R6, saved R7, and 
                          // return to saved LR
```


## Writing custom build scripts
> https://developer.apple.com/documentation/xcode/writing-custom-build-scripts

### 
- A  that runs before Xcode Cloud runs `xcodebuild`.
- A  that Xcode Cloud runs after running `xcodebuild`.
#### 
To create the `ci_scripts` directory:
3. Name the new group `ci_scripts`.
#### 
2. Control-click the `ci_scripts` group you created earlier and choose New File.
4. Name the shell script `ci_post_clone.sh`, `ci_pre_xcodebuild.sh`, or `ci_post_xcodebuild.sh`.
6. In Terminal, make the shell script an executable by running `chmod +x $filename.sh`.
> **note:** You can’t obtain administrator privileges by using `sudo` in your custom build scripts.
#### 
#### 
Environment variables are key to custom scripts because they allow you to write flexible custom scripts with advanced control flows. For example, the following code snippet checks if the `CI_PULL_REQUEST_NUMBER` variable is present to only run a command when Xcode Cloud runs the script as part of a build from a pull request:
```bash
#!/bin/sh

if [[ -n $CI_PULL_REQUEST_NUMBER ]];
then
    echo "This build started from a pull request."

    # Perform an action only if the build starts from a pull request.
fi
```

#### 
#### 
#### 
Custom build scripts can perform critical tasks like installing dependencies or uploading build artifacts to storage. Write resilient code that handles errors gracefully, and, if a command fails, return a nonzero exit code. By returning a nonzero exit code in your custom build script, you let Xcode Cloud know that something went wrong and let it fail the build to let you know that there’s an issue.
The following build script sets the `-e` option to stop the script if a command exits with a nonzero exit code. Additionally, return a nonzero exit code in case something goes wrong:
```bash
#!/bin/sh

# Set the -e flag to stop running the script in case a command returns
# a nonzero exit code.
set -e

# A command or script succeeded.
echo "A command or script was successful."
exit 0

...

# Something went wrong.
echo "Something went wrong. Include helpful information here."
exit 1
```

#### 
When it comes to naming your helper scripts, use a filename that makes it easy to recognize the script’s purpose. For example, you might prefix helper scripts with the name of their intended platform and name the following script `platform-detect.sh` because it uses the `CI_PRODUCT_PLATFORM` variable to detect the platform for the current build:
```bash
#!/bin/sh

if [ $CI_PRODUCT_PLATFORM = 'macOS' ]
then
    ./macos_perform_example_task.sh
else
    ./iOS_perform_example_task.sh
fi
```

To help make your helper scripts more recognizable, you should avoid prefixing the script names with `ci_`.

## Writing symbol documentation in your source files
> https://developer.apple.com/documentation/xcode/writing-symbol-documentation-in-your-source-files

### 
#### 
#### 
For methods that take parameters, document those parameters directly below the summary, or the Discussion section, if you include one. Describe each parameter in isolation. Discuss its purpose and, where necessary, the range of acceptable values.
```swift
/// - Parameters:
///   - food: The food for the sloth to eat.
///   - quantity: The quantity of the food for the sloth to eat.
mutating public func eat(_ food: Food, quantity: Int) throws -> Int {
```

mutating public func eat(_ food: Food, quantity: Int) throws -> Int {
```
```swift
/// - Parameter food: The food for the sloth to eat.
/// - Parameter quantity: The quantity of the food for the sloth to eat.
mutating public func eat(_ food: Food, quantity: Int) throws -> Int {
```

#### 
For methods that return a value, include a  section in your documentation comment to describe the returned value.
```swift
/// - Returns: The sloth's energy level after eating.
mutating public func eat(_ food: Food, quantity: Int) throws -> Int {
```

#### 
If a method can throw an error, add a  section to your documentation comment. Explain the circumstances that cause the method to throw an error, and list the types of possible errors.
```swift
/// - Throws: `SlothError.tooMuchFood` if the quantity is more than 100.
mutating public func eat(_ food: Food, quantity: Int) throws -> Int {
```


