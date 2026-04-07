# Apple SWIFT Skill


## About Imported Cocoa Error Parameters
> https://developer.apple.com/documentation/swift/about-imported-cocoa-error-parameters

### 
#### 
Swift examines Objective-C method declarations and translates them into Swift throwing methods, with shorter names when possible.
For example, consider the  method from . In Objective-C, it’s declared like this:
```occ
- (BOOL)removeItemAtURL:(NSURL *)URL
                  error:(NSError **)error;
```

```
In Swift, it’s imported like this:
```swift
func removeItem(at: URL) throws
```

Notice that the  method is imported by Swift with a `Void` return type, no error parameter, and a `throws` declaration.

## Adopting Common Protocols
> https://developer.apple.com/documentation/swift/adopting-common-protocols

### 
- You can compare instances of an  type by using the equal-to (`==`) and not-equal-to (`!=`) operators.
- An instance of a  type can reduce its value mathematically to a single integer, which is used internally by sets and dictionaries to make lookups consistently fast.
Many standard library types are both equatable and hashable, including strings, integers, floating-point values, Boolean values, and collections of equatable and hashable types. The `==` comparison and the `contains(_:)` method call in the following example depend on strings and integers being equatable:
```swift
if username == "Arturo" {
    print("Hi, Arturo!")
}

let favoriteNumbers = [4, 7, 8, 9]
if favoriteNumbers.contains(todaysDate.day) {
    print("It's a good day today!")
}
```

#### 
You can make many custom types equatable and hashable by simply declaring these protocol conformances in the same file as the type’s original declaration. Add `Equatable` and `Hashable` to the list of adopted protocols when declaring the type, and the compiler automatically fills in the requirements for the two protocols:
```swift
/// A position in an x-y coordinate system.
struct Position: Equatable, Hashable {
    var x: Int
    var y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}
```

```
With `Equatable` conformance, you can use the equal-to operator (`==`) or the not-equal-to operator (`!=`) with any two instances of the `Position` type.
```swift
let availablePositions = [Position(0, 0), Position(0, 1), Position(1, 0)]
let gemPosition = Position(1, 0)

for position in availablePositions {
    if gemPosition == position {
        print("Gem found at (\(position.x), \(position.y))!")
    } else {
        print("No gem at (\(position.x), \(position.y))")
    }
}
// No gem at (0, 0)
// No gem at (0, 1)
// Gem found at (1, 0)!

```

```
`Hashable` conformance means that you can store positions in a set and quickly check whether you’ve visited a position before, as shown in the following example:
```swift
var visitedPositions: Set = [Position(0, 0), Position(1, 0)]
let currentPosition = Position(1, 3)

if visitedPositions.contains(currentPosition) {
    print("Already visited (\(currentPosition.x), \(currentPosition.y))")
} else {
    print("First time at (\(currentPosition.x), \(currentPosition.y))")
    visitedPositions.insert(currentPosition)
}
// First time at (1, 3)

```

- For a structure,  its stored properties must conform to `Equatable` and `Hashable`.
#### 
You need to manually implement `Equatable` and `Hashable` conformance for a type in these cases:
- You want to customize the type’s conformance.
- You want to extend a type declared in another file or module to conform.
```swift
class Player {
    var name: String
    var position: Position

    init(name: String, position: Position) {
        self.name = name
        self.position = position
    }
}
```

```
The `Player` type is a class, so it doesn’t qualify for automatic synthesis of the `Equatable` or `Hashable` requirements. To make this class conform to the `Equatable` protocol, declare conformance in an extension and implement the  static `==` operator method. Compare each significant property for equality in your `==` method’s implementation:
```swift
extension Player: Equatable {
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.name == rhs.name && lhs.position == rhs.position
    }
}
```

```
To make `Player` conform to the `Hashable` protocol, declare conformance in another extension and implement the `hash(into:)` method. In the `hash(into:)` method, call the `combine(_:)` method on the provided hasher with each significant property:
```swift
extension Player: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(position)
    }
}
```

#### 
`NSObject` subclasses inherit conformance to the `Equatable` and `Hashable` protocols, with equality based on instance identity. If you need to customize this behavior, override the  method and  property instead of the `==` operator method and `hashValue` property.
```swift
extension MyNSObjectSubclass {
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? MyNSObjectSubclass
            else { return false }
        return self.firstProperty == other.firstProperty 
            && self.secondProperty == other.secondProperty
    }

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(firstProperty)
        hasher.combine(secondProperty)
        return hasher.finalize()
    }
}
```


## Applying Macros
> https://developer.apple.com/documentation/swift/applying-macros

### 
#### 
The syntax you use to call a macro varies slightly, depending on whether you attach the macro to a declaration.
To attach a macro to a declaration, write an at sign (`@`) before the macro’s name and write any macro arguments after its name. This syntax is the same as writing an attribute. For example:
```swift
@Observable
public final class MyObject {
    public var someProperty: String = ""
    public var someOtherProperty: Int = 0
    fileprivate var somePrivateProperty: Int = 1
}
```

A macro that’s attached to a declaration generates code and adds that code to the declaration. For example, the  macro in the code above adds additional members to the `MyObject` class so it implements the  protocol, and marks `MyObject` as conforming to `Observable`.
To call a macro without attaching it to a declaration, write a number sign (`#`) before the macro’s name and write any macro arguments after its name. This syntax is the same as `#if` and other compile-time operations. For example:
```swift
let messagePredicate = #Predicate<Message> { message in
    message.recipient == "John Appleseed"
}
```

#### 

## Calling Functions With Pointer Parameters
> https://developer.apple.com/documentation/swift/calling-functions-with-pointer-parameters

### 
#### 
When you call a function that is declared as taking an `UnsafePointer<Type>` argument, you can pass any of the following:
- A `[Type]` value, which is passed as a pointer to the start of the array.
The pointer you pass to the function is only guaranteed to be valid for the duration of the function call. Do not persist the pointer and access it after the function has returned.
This example shows the different ways that you can call the a function that takes a constant pointer:
```swift
func takesAPointer(_ p: UnsafePointer<Float>) {
    // ...
}

var x: Float = 0.0
takesAPointer(&x)
takesAPointer([1.0, 2.0, 3.0])
```

When you call a function that takes an `UnsafeRawPointer` argument, you can pass the same operands as `UnsafePointer<Type>`, but with any type as `Type`.
This example shows the different ways that you can call a function that takes a constant raw pointer:
```swift
func takesARawPointer(_ p: UnsafeRawPointer?)  {
    // ...
}

var x: Float = 0.0, y: Int = 0
takesARawPointer(&x)
takesARawPointer(&y)
takesARawPointer([1.0, 2.0, 3.0] as [Float])
let intArray = [1, 2, 3]
takesARawPointer(intArray)
takesARawPointer("How are you today?")
```

#### 
When you call a function that is declared as taking an `UnsafeMutablePointer<Type>` argument, you can pass any of the following:
- An `UnsafeMutablePointer<Type>` value.
- An in-out expression of type `[Type]` that contains a mutable variable, property, or subscript reference, which is passed as a pointer to the start of the array, and is lifetime-extended for the duration of the call.
This example shows the different ways that you can call a function that takes a mutable pointer:
```swift
func takesAMutablePointer(_ p: UnsafeMutablePointer<Float>) {
    // ...
}

var x: Float = 0.0
var a: [Float] = [1.0, 2.0, 3.0]
takesAMutablePointer(&x)
takesAMutablePointer(&a)
```

When you call a function that is declared as taking an `UnsafeMutableRawPointer` argument, you can pass the same operands as `UnsafeMutablePointer<Type>`, but for any type as `Type`.
This example shows the different ways that you can call a function that takes a mutable raw pointer:
```swift
func takesAMutableRawPointer(_ p: UnsafeMutableRawPointer?)  {
    // ...
}

var x: Float = 0.0, y: Int = 0
var a: [Float] = [1.0, 2.0, 3.0], b: [Int] = [1, 2, 3]
takesAMutableRawPointer(&x)
takesAMutableRawPointer(&y)
takesAMutableRawPointer(&a)
takesAMutableRawPointer(&b)
```

#### 
When you call a function that is declared as taking an `AutoreleasingUnsafeMutablePointer<Type>`, you can pass any of the following:
- An `AutoreleasingUnsafeMutablePointer<Type>` value.
#### 
When calling a function that takes a C function pointer argument, you can pass a top-level Swift function, a closure literal, a closure declared with the `@convention(c)` attribute, or `nil`. You can also pass a closure property of a generic type or a generic method as long as no generic type parameters are referenced in the closure’s argument list or body.
For example, consider Core Foundation’s `CFArrayCreateMutable(_:_:_:)` function. The `CFArrayCreateMutable(_:_:_:)` function takes a `CFArrayCallBacks` structure, which is initialized with function pointer callbacks:
```swift
func customCopyDescription(_ p: UnsafeRawPointer?) -> Unmanaged<CFString>? {
    // return an Unmanaged<CFString>? value
}

var callbacks = CFArrayCallBacks(
    version: 0,
    retain: nil,
    release: nil,
    copyDescription: customCopyDescription,
    equal: { (p1, p2) -> DarwinBoolean in
        // return Bool value
    }
)
var mutableArray = CFArrayCreateMutable(nil, 0, &callbacks)
```


## Calling Objective-C APIs Asynchronously
> https://developer.apple.com/documentation/swift/calling-objective-c-apis-asynchronously

### 
#### 
Swift imports Objective-C methods that take a completion handler as two related Swift methods: a method that takes a closure, and an asynchronous method that doesn’t take a closure. For example, consider the  method from PassKit. In Objective-C, it’s declared like this:
```occ
- (void)presentWithCompletion:(void (^)(BOOL success))completion;
```

```
However, in Swift, it’s imported as two methods:
```swift
func present(completion: ((Bool) -> Void)? = nil)

func present() async -> Bool
```

The first version, `present(completion:)`, has a return type of `Void` and takes a completion handler. The second version, `present()`, returns a Boolean value and is an asynchronous method.
Methods whose completion handlers populate a  pointer parameter also become throwing methods in Swift, as described in . The `NSError` parameter on an asynchronous throwing method must also be nullable, which indicates that the parameter is used only to communicate an error. For example, consider the  method from . In Objective-C, it’s declared like this:
```occ
- (void)writeData:(NSData *)data
          timeout:(NSTimeInterval)timeout
completionHandler:(void (^) (NSError * _Nullable error))completionHandler;
```

```
As in the previous example, Swift imports this Objective-C method as two methods: an asynchronous method that takes a closure, and an asynchronous throwing method.
```swift
func write(
    _ data: Data, 
    timeout: TimeInterval, 
    completionHandler: @escaping (Error?) -> Void
)

func write(_ data: Data, timeout: TimeInterval) async throws
```

```
Methods whose completion handlers take multiple arguments become methods that return a tuple. For example, the  method from PassKit is declared like this in Objective-C:
```occ
- (void)signData:(NSData *)signData 
withSecureElementPass:(PKSecureElementPass *)secureElementPass 
      completion:(void (^)(NSData *signedData, NSData *signature, NSError *error))completion;
```

```
In Swift it‘s imported as two methods, an asychronous method that takes a closure and an asynchronous throwing method that returns a tuple:
```swift
func sign(
    _ signData: Data, 
    using secureElementPass: PKSecureElementPass, 
    completion: @escaping (Data?, Data?, Error?) -> Void
)

func sign(_ signData: Data, 
    using secureElementPass: PKSecureElementPass
) async throws -> (Data, Data)
```

#### 
- The method has a `void` return type.
- The block has a `void` return type.
- `WithCompletion`
- `WithCompletionHandler`
- `WithCompletionBlock`
- `WithReplyTo`
- `WithReply`
- `completion`
- `withCompletion`
- `completionHandler`
- `withCompletionHandler`
- `completionBlock`
- `withCompletionBlock`
- `replyTo`
- `withReplyTo`
- `reply`
- `replyTo`
- If the selector starts with `get`, that prefix is removed and leading initialisms are converted to lowercase.
- If the selector ends with `Asynchronously`, that suffix is removed.

## Choosing Between Structures and Classes
> https://developer.apple.com/documentation/swift/choosing-between-structures-and-classes

### 
#### 
#### 
#### 
#### 
Use structures when you’re modeling data that contains information about an entity with an identity that you don’t control.
In an app that consults a remote database, for example, an instance’s identity may be fully owned by an external entity and communicated by an identifier. If the consistency of an app’s models is stored on a server, you can model records as structures with identifiers. In the example below, `jsonResponse` contains an encoded `PenPalRecord` instance from a server:
```swift
struct PenPalRecord {
    let myID: Int
    var myNickname: String
    var recommendedPenPalID: Int
}

var myRecord = try JSONDecoder().decode(PenPalRecord.self, from: jsonResponse)
```

#### 

## Customizing Your C Code for Swift
> https://developer.apple.com/documentation/swift/customizing-your-c-code-for-swift

### 
#### 
The example below shows several functions that are all related to a `Color` type. The `CF_SWIFT_NAME` macro is applied to each function, giving each one a new name for Swift that’s nested together under the `Color` type:
```occ
Color ColorCreateWithCMYK(float c, float m, float y, float k) CF_SWIFT_NAME(Color.init(c:m:y:k:));

float ColorGetHue(Color color) CF_SWIFT_NAME(getter:Color.hue(self:));
void ColorSetHue(Color color, float hue) CF_SWIFT_NAME(setter:Color.hue(self:newValue:));

Color ColorDarkenColor(Color color, float amount) CF_SWIFT_NAME(Color.darken(self:amount:));

extern const Color ColorBondiBlue CF_SWIFT_NAME(Color.bondiBlue);

Color ColorGetCalibrationColor(void) CF_SWIFT_NAME(getter:Color.calibration());
Color ColorSetCalibrationColor(Color color) CF_SWIFT_NAME(setter:Color.calibration(newValue:));
```

#### 
Here’s how Swift imports the related functions above into a single type:
```swift
extension Color {
    init(c: Float, m: Float, y: Float, k: Float)

    var hue: Float { get set }

    func darken(amount: Float) -> Color

    static var bondiBlue: Color

    static var calibration: Color
}
```

> **note:** You can’t reorder or change the number of arguments for type members imported using the `CF_SWIFT_NAME` macro.

## Default Literal Types
> https://developer.apple.com/documentation/swift/default-literal-types

### 
This example declares the `numberOfCookies` constant, using an integer literal to express its value:
This example declares the `numberOfCookies` constant, using an integer literal to express its value:
```swift
let numberOfCookies = 5
// type(of: numberOfCookies) == Int.self
```


## Designating Nullability in Objective-C APIs
> https://developer.apple.com/documentation/swift/designating-nullability-in-objective-c-apis

### 
In Objective-C, you work with references to objects by using pointers that can be null, called `nil` in Objective-C. In Swift, all values — including object instances — are guaranteed to be non-null. Instead, you represent a value that could be missing as wrapped in an optional type. When you need to indicate that a value is missing, you use the value `nil`.
You can annotate declarations in your Objective-C code to indicate whether an instance can have a null or `nil` value. Those annotations change how Swift imports your declarations. For an example of how Swift imports unannotated declarations, consider the following code:
```occ
@interface MyList : NSObject
- (MyListItem *)itemWithName:(NSString *)name;
- (NSString *)nameForItem:(MyListItem *)item;
@property (copy) NSArray<MyListItem *> *allItems;
@end
```

```
Swift imports each object instance parameter, return value, and property as an implicitly wrapped optional:
```swift
class MyList: NSObject {
    func item(withName name: String!) -> MyListItem!
    func name(for item: MyListItem!) -> String!
    var allItems: [MyListItem]!
}
```

#### 
- Without a nullability annotation or with a null_resettable annotation—Imported as implicitly unwrapped optionals
The following code shows the `MyList` type after annotation. The return types of the two methods are annotated as `nullable`, because the methods return `nil` if the list doesn’t contain the given list item or name. All other object instances are annotated as `nonnull`.
```occ
@interface MyList : NSObject
- (nullable MyListItem *)itemWithName:(nonnull NSString *)name;
- (nullable NSString *)nameForItem:(nonnull MyListItem *)item;
@property (copy, nonnull) NSArray<MyListItem *> *allItems;
@end
```

With these annotations, Swift imports the `MyList` type without using any implicitly wrapped optionals:
```
With these annotations, Swift imports the `MyList` type without using any implicitly wrapped optionals:
```swift
class MyList: NSObject {
    func item(withName name: String) -> MyListItem?
    func name(for item: MyListItem) -> String?
    var allItems: [MyListItem]
}
```

#### 
You can simplify the process of annotating your Objective-C code by marking entire regions as audited for nullability. Within a section of code demarcated by the `NS_ASSUME_NONNULL_BEGIN` and `NS_ASSUME_NONNULL_END` macros, you only need to annotate the nullable type declarations. Unannotated declarations within the audited region are treated as nonnullable.
Marking the `MyList` declaration as audited for nullability reduces the number of annotations that are required. Swift imports the type the same way as in the previous section.
```occ
NS_ASSUME_NONNULL_BEGIN

@interface MyList : NSObject
- (nullable MyListItem *)itemWithName:(NSString *)name;
- (nullable NSString *)nameForItem:(MyListItem *)item;
@property (copy) NSArray<MyListItem *> *allItems;
@end

NS_ASSUME_NONNULL_END
```

Note that `typedef` types aren’t assumed to be nonnull, even within audited regions, because they aren’t inherently nullable.

## Grouping Related Objective-C Constants
> https://developer.apple.com/documentation/swift/grouping-related-objective-c-constants

### 
- `NS_ENUM` for simple enumerations
- `NS_CLOSED_ENUM` for simple enumerations that can never gain new cases
- `NS_OPTIONS` for enumerations whose cases can be grouped into sets of options
- `NS_TYPED_ENUM` for enumerations with a raw value type that you specify
- `NS_TYPED_EXTENSIBLE_ENUM` for enumerations that you expect might gain more cases
#### 
Use the `NS_ENUM` macro for simple groups of constants.
The example below uses the macro to declare a `UITableViewCellStyle` enumeration that groups several different view styles for table views:
Use the `NS_ENUM` macro for simple groups of constants.
The example below uses the macro to declare a `UITableViewCellStyle` enumeration that groups several different view styles for table views:
```occ
typedef NS_ENUM(NSInteger, UITableViewCellStyle) {
    UITableViewCellStyleDefault,
    UITableViewCellStyleValue1,
    UITableViewCellStyleValue2,
    UITableViewCellStyleSubtitle
};
```

In Swift, the `UITableViewCellStyle` enumeration is imported like this:
```
In Swift, the `UITableViewCellStyle` enumeration is imported like this:
```swift
enum UITableViewCellStyle: Int {
    case `default`
    case value1
    case value2
    case subtitle
}
```

#### 
Don’t use the `NS_CLOSED_ENUM` macro if:
In these scenarios, use the `NS_ENUM` macro instead.
#### 
The example below shows how to apply the `NS_OPTIONS` macro and assign raw values that are mutually exclusive:
You use the `NS_OPTIONS` macro when two or more constants in a grouping of constants can be combined. For example, the output formatting for a  instance can be sorted and can use ample white space at the same time, so it’s valid to specify both options in an option set: `[.sorted, .prettyPrinted]`.
The example below shows how to apply the `NS_OPTIONS` macro and assign raw values that are mutually exclusive:
```occ
typedef NS_OPTIONS(NSUInteger, UIViewAutoresizing) {
        UIViewAutoresizingNone                 = 0,
        UIViewAutoresizingFlexibleLeftMargin   = 1 << 0,
        UIViewAutoresizingFlexibleWidth        = 1 << 1,
        UIViewAutoresizingFlexibleRightMargin  = 1 << 2,
        UIViewAutoresizingFlexibleTopMargin    = 1 << 3,
        UIViewAutoresizingFlexibleHeight       = 1 << 4,
        UIViewAutoresizingFlexibleBottomMargin = 1 << 5
};
```

Here’s how the `UIViewAutoresizing` type is imported to Swift:
The increasing sequence of nonnegative integers used along with the bitwise left shift operator (`<<`) ensures that each option in the option set takes up a unique bit in the binary representation of the raw value.
Here’s how the `UIViewAutoresizing` type is imported to Swift:
```swift
public struct UIViewAutoresizing: OptionSet {
    public init(rawValue: UInt)

    public static var flexibleLeftMargin: UIViewAutoresizing { get }
    public static var flexibleWidth: UIViewAutoresizing { get }
    public static var flexibleRightMargin: UIViewAutoresizing { get }
    public static var flexibleTopMargin: UIViewAutoresizing { get }
    public static var flexibleHeight: UIViewAutoresizing { get }
    public static var flexibleBottomMargin: UIViewAutoresizing { get }
}
```

#### 
The example below uses the `NS_TYPED_ENUM` macro to declare the different colors used by a traffic light:
You use the `NS_TYPED_ENUM` to group constants with a raw value type that you specify. Use `NS_TYPED_ENUM` for sets of constants that  logically have values added in a Swift extension, and use `NS_TYPED_EXTENSIBLE_ENUM` for sets of constants that  be expanded in an extension.
The example below uses the `NS_TYPED_ENUM` macro to declare the different colors used by a traffic light:
```occ
// Store the three traffic light color options as 0, 1, and 2.
typedef long TrafficLightColor NS_TYPED_ENUM;

TrafficLightColor const TrafficLightColorRed;
TrafficLightColor const TrafficLightColorYellow;
TrafficLightColor const TrafficLightColorGreen;
```

Here’s how the `TrafficLightColor` type is imported to Swift:
The number of colors that a traffic light uses isn’t expected to grow, so it’s not declared to be extensible.
Here’s how the `TrafficLightColor` type is imported to Swift:
```swift
struct TrafficLightColor: RawRepresentable, Equatable, Hashable {
    typealias RawValue = Int

    init(rawValue: RawValue)
    var rawValue: RawValue { get }

    static var red: TrafficLightColor { get }
    static var yellow: TrafficLightColor { get }
    static var green: TrafficLightColor { get }
}
```

Extensible enumerations are imported in a similar fashion to nonextensible ones, except that they receive an additional initializer.
The examples below show how a `FavoriteColor` type is declared, imported, and extended. The first one declares the `FavoriteColor` type and adds a single enumeration case for the color blue:
```occ
typedef long FavoriteColor NS_TYPED_EXTENSIBLE_ENUM;
FavoriteColor const FavoriteColorBlue;
```

```
The additional initializer omits the label requirement for its first parameter:
```swift
struct FavoriteColor: RawRepresentable, Equatable, Hashable {
    typealias RawValue = Int

    init(_ rawValue: RawValue)
    init(rawValue: RawValue)
    var rawValue: RawValue { get }

    static var blue: FavoriteColor { get }
}
```

You can add extensions to extensible enumerations later in your Swift code.
The example below adds another favorite color:
```swift
extension FavoriteColor {
    static var green: FavoriteColor {
        return FavoriteColor(1) // blue is 0, green is 1, and new favorite colors could follow
    }
}
```


## Handling Cocoa Errors in Swift
> https://developer.apple.com/documentation/swift/handling-cocoa-errors-in-swift

### 
#### 
In Swift, calling a method that throws requires explicit error handling. Because Cocoa methods with errors parameters are imported as throwing methods, you handle them using Swift’s `do`-`catch` statement.
Here’s an example of how you handle an error when calling a method in Objective-C:
```occ
NSFileManager *fileManager = [NSFileManager defaultManager];
NSURL *fromURL = [NSURL fileURLWithPath:@"/path/to/old"];
NSURL *toURL = [NSURL fileURLWithPath:@"/path/to/new"];
NSError *error = nil;
BOOL success = [fileManager moveItemAtURL:fromURL toURL:toURL error:&error];
if (!success) {
    NSLog(@"Error: %@", error.domain);
}
```

```
Here’s how you handle the same error in Swift:
```swift
let fileManager = FileManager.default
let fromURL = URL(fileURLWithPath: "/path/to/old")
let toURL = URL(fileURLWithPath: "/path/to/new")
do {
    try fileManager.moveItem(at: fromURL, to: toURL)
} catch let error as NSError {
    print("Error: \(error.domain)")
}
```

You can also use the `do`-`catch` statement to match on specific Cocoa error codes to differentiate possible failure conditions:
```
You can also use the `do`-`catch` statement to match on specific Cocoa error codes to differentiate possible failure conditions:
```swift
do {
    try fileManager.moveItem(at: fromURL, to: toURL)
} catch CocoaError.fileNoSuchFile {
    print("Error: no such file exists")
} catch CocoaError.fileReadUnsupportedScheme {
    print("Error: unsupported scheme (should be 'file://')")
}
```

#### 
You throw Cocoa errors by initializing a Cocoa error type and passing in the relevant error domain and code:
```swift
throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, userInfo: nil)
```

#### 
You use custom error domains in Cocoa to group related categories of errors. The example below uses the `NS_ERROR_ENUM` macro to group error constants:
```occ
extern NSErrorDomain const MyErrorDomain;
typedef NS_ERROR_ENUM(MyErrorDomain, MyError) {
    specificError1 = 0,
    specificError2 = 1
};
```

```
This example shows how to throw errors using that custom error type in Swift:
```swift
func customThrow() throws {
    throw NSError(
        domain: MyErrorDomain,
        code: MyError.specificError2.rawValue,
        userInfo: [
            NSLocalizedDescriptionKey: "A customized error from MyErrorDomain."
        ]
    )
}
```

```
This example shows how to catch errors from a particular error domain and bring attention to unhandled errors from other error domains:
```swift
do {
    try customThrow()
} catch MyError.specificError1 {
    print("Caught specific error #1")
} catch let error as MyError where error.code == .specificError2 {
    print("Caught specific error #2, ", error.localizedDescription)
    // Prints "Caught specific error #2. A customized error from MyErrorDomain."
} catch let error {
    fatalError("Some other error: \(error)")
}
```

#### 

## Handling Dynamically Typed Methods and Objects in Swift
> https://developer.apple.com/documentation/swift/handling-dynamically-typed-methods-and-objects-in-swift

### 
In Objective-C, the `id` type represents objects that are instances of any Objective-C class. The `id` type is instead imported by Swift as the `Any` type. When you pass a Swift instance to an Objective-C API, it’s bridged as an `id` parameter so that it’s usable in the API as an Objective-C object. When `id` values are imported into Swift as `Any`, the runtime automatically handles bridging back to either class references or value types.
```swift
var x: Any = "hello" as String
x as? String   // String with value "hello"
x as? NSString // NSString with value "hello"

x = "goodbye" as NSString
x as? String   // String with value "goodbye"
x as? NSString // NSString with value "goodbye"
```

#### 
You can use the conditional type cast operator (`as?`), which returns an optional value of the type you are trying to downcast to:
When you work with objects of type `Any` where you know the underlying type, it’s often useful to downcast those objects to the underlying type. However, because the `Any` type can refer to any type, a downcast to a more specific type isn’t guaranteed by the compiler to succeed.
You can use the conditional type cast operator (`as?`), which returns an optional value of the type you are trying to downcast to:
```swift
let userDefaults = UserDefaults.standard
let lastRefreshDate = userDefaults.object(forKey: "LastRefreshDate") // lastRefreshDate is of type Any?
if let date = lastRefreshDate as? Date {
    print("\(date.timeIntervalSinceReferenceDate)")
}
```

If you’re completely certain about the type of the object, you can use the forced downcast operator (`as!`) instead.
```
If you’re completely certain about the type of the object, you can use the forced downcast operator (`as!`) instead.
```swift
let myDate = lastRefreshDate as! Date
let timeInterval = myDate.timeIntervalSinceReferenceDate
```

```
However, if a forced downcast fails, a runtime error is triggered:
```swift
let myDate = lastRefreshDate as! String // Error
```


## Importing Swift into Objective-C
> https://developer.apple.com/documentation/swift/importing-swift-into-objective-c

### 
#### 
When you’re building an app target, you can import your Swift code into any Objective-C `.m` file within that same target using this syntax and substituting the appropriate name:
```occ
#import "ProductModuleName-Swift.h"
```

#### 
1. Under Build Settings, in Packaging, make sure the Defines Module setting for that framework target is set to Yes.
2. Import the Swift code from that framework target into any Objective-C `.m` file within that target using this syntax and substituting the appropriate names:
```occ
#import <ProductName/ProductModuleName-Swift.h>
```

#### 
When declarations in an Objective-C header file refer to a Swift class or protocol that comes from the same target, importing the generated header creates a cyclical reference. To avoid this, use a forward declaration of the Swift class or protocol to reference it in an Objective-C interface.
```occ
// MyObjcClass.h
@class MySwiftClass;
@protocol MySwiftProtocol;

@interface MyObjcClass : NSObject
- (MySwiftClass *)returnSwiftClassInstance;
- (id <MySwiftProtocol>)returnInstanceAdoptingSwiftProtocol;
// ...
@end
```


## Improving Objective-C API Declarations for Swift
> https://developer.apple.com/documentation/swift/improving-objective-c-api-declarations-for-swift

### 
#### 
The example below shows an Objective-C API that can be expressed more succinctly once it’s imported into Swift:
```occ
@interface Color : NSObject

- (void)getRed:(nullable CGFloat *)red
         green:(nullable CGFloat *)green
          blue:(nullable CGFloat *)blue
         alpha:(nullable CGFloat *)alpha;

@end
```

```
Calling the `getRed(red:green:blue:alpha:)` method in Swift requires passing four in-out parameters. A reimagined Swift computed property that expresses the same functionality—getting the components of a color—can be written as a four-element tuple:
```swift
var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
```

#### 
The example below adds the `NS_REFINED_FOR_SWIFT` macro to the `getRed(red:green:blue:alpha:)` method:
Applying the `NS_REFINED_FOR_SWIFT` macro exposes the existing Objective-C API for reuse in your refined API. The existing API is renamed with double underscores (`__`) when it’s imported, to help prevent you from accidentally using the existing API elsewhere.
The example below adds the `NS_REFINED_FOR_SWIFT` macro to the `getRed(red:green:blue:alpha:)` method:
```occ
@interface Color : NSObject

- (void)getRed:(nullable CGFloat *)red
         green:(nullable CGFloat *)green
          blue:(nullable CGFloat *)blue
         alpha:(nullable CGFloat *)alpha NS_REFINED_FOR_SWIFT;

@end
```

- Initializer methods are imported by Swift with double underscores (`__`) prepended to their first argument labels.
- Other methods are imported with double underscores (`__`) prepended to their base names.
#### 
You reuse an API by using its new name to call it in the implementation of a new API in Swift.
The implementation of the new `rgba` property reuses the existing `__getRed(red:green:blue:alpha:)` method to ensure that functionality remains the same between Swift and Objective-C:
```swift
extension Color {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        __getRed(red: &r, green: &g, blue: &b, alpha: &a)
        return (red: r, green: g, blue: b, alpha: a)
    }
}
```


## Maintaining State in Your Apps
> https://developer.apple.com/documentation/swift/maintaining-state-in-your-apps

### 
#### 
Consider an app that requires a user to log into an account. When the app is first opened, the user is unknown, so the state of the app could be called . After the user has registered or logged into an account, the state is . After some time of inactivity, the user’s session may expire, leaving the app in a  state.
You can use an enumeration to specify the exact states needed for your app. This approach defines an `App` class with a nested `State` enumeration that includes only the specific states you need:
```swift
class App {
    enum State {
        case unregistered
        case loggedIn(User)
        case sessionExpired(User)
    }

    var state: State = .unregistered

    // ...
}
```

#### 
- For every change in state, you need to provide updates for both `user` and `sessionExpired` in tandem.

## Making Objective-C APIs Unavailable in Swift
> https://developer.apple.com/documentation/swift/making-objective-c-apis-unavailable-in-swift

### 
#### 
To prevent a declaration in an Objective-C API from being imported, pass a single parameter to the `NS_SWIFT_UNAVAILABLE` macro. The parameter indicates what a developer using Swift should do instead of using the part of the API you’re making unavailable.
In this example, an Objective-C class that provides a convenience initializer that takes variadic arguments for key-value pairs suggests using a dictionary literal instead:
```occ
+ (instancetype)collectionWithValues:(NSArray *)values
                             forKeys:(NSArray<NSCopying> *)keys
NS_SWIFT_UNAVAILABLE("Use a dictionary literal instead.");
```

Attempting to call the `collectionWithValues:forKeys:` method in Swift results in a compiler error.
#### 

## Managing a Shared Resource Using a Singleton
> https://developer.apple.com/documentation/swift/managing-a-shared-resource-using-a-singleton

### 
#### 
You create simple singletons using a static type property, which is guaranteed to be lazily initialized only once, even when accessed across multiple threads simultaneously:
```swift
class Singleton {
    static let shared = Singleton()
}
```

```
If you need to perform additional setup beyond initialization, you can assign the result of the invocation of a closure to the global constant:
```swift
class Singleton {
    static let shared: Singleton = {
        let instance = Singleton()
        // setup code
        return instance
    }()
}
```


## Marking API Availability in Objective-C
> https://developer.apple.com/documentation/swift/marking-api-availability-in-objective-c

### 
#### 
Use the `API_AVAILABLE` macro to add availability information in Objective-C:
Use the `API_AVAILABLE` macro to add availability information in Objective-C:
```occ
@interface MyViewController : UIViewController
- (void) newMethod API_AVAILABLE(ios(11), macosx(10.13));
@end
```

This is equivalent to using the `@available` attribute on a declaration in Swift:
```
This is equivalent to using the `@available` attribute on a declaration in Swift:
```swift
@available(iOS 11, macOS 10.13, *)
func newMethod() {
    // Use iOS 11 APIs.
}
```

#### 
Use the `@available()` keyword to check availability information in a conditional statement in Objective-C:
Use the `@available()` keyword to check availability information in a conditional statement in Objective-C:
```occ
if (@available(iOS 11, *)) {
    // Use iOS 11 APIs.
} else {
    // Alternative code for earlier versions of iOS.
}
```

```
This is equivalent to the following conditional in Swift:
```swift
if #available(iOS 11, *) {
    // Use iOS 11 APIs.
} else {
    // Alternative code for earlier versions of iOS.
}
```


## Preventing Timing Problems When Using Closures
> https://developer.apple.com/documentation/swift/preventing-timing-problems-when-using-closures

### 
#### 
When you pass a closure to an API, consider  that closure will be called relative to the other code in your app. In synchronous APIs, the result of calling the closure will be available immediately after you pass the closure. In asynchronous APIs, the result won’t be available until sometime later; this difference affects how you write code both  your closure as well as the code  your closure.
The example below defines two functions, `now(_:)` and `later(_:)`. You can call both functions the same way: with a trailing closure and no other arguments. Both `now(_:)` and `later(_:)` accept a closure and call it, but `later(_:)` waits a couple seconds before calling its closure.
```swift
import Dispatch
let queue = DispatchQueue(label: "com.example.queue")

func now(_ closure: () -> Void) {
    closure()
}

func later(_ closure: @escaping () -> Void) {
    queue.asyncAfter(deadline: .now() + 2) {
        closure()
    }
}
```

The `now(_:)` and `later(_:)` functions represent the two most common categories of APIs you’ll encounter in methods from app frameworks that take closures: synchronous APIs like `now(_:)`, and asynchronous APIs like `later(_:)`.
Because calling a closure can change the local and global state of your app, the code you write on the lines after passing a closure needs to be written with a careful consideration of  that closure is called. Even something as simple as printing a sequence of letters can be affected by the timing of a closure call:
```swift
later {
    print("A") // Eventually prints "A"
}
print("B") // Immediately prints "B"

now {
    print("C") // Immediately prints "C"
}
print("D") // Immedately prints "D"

// Prevent the program from exiting immediately if you're running this code in Terminal.
let semaphore = DispatchSemaphore(value: 0).wait(timeout: .now() + 10)
```

#### 
If you’re going to pass a closure to an API that might call it multiple times, omit code that’s intended to make a one-time change to external state.
The example below creates a  and an array of data lines to write to the file that the handle refers to:
```swift
import Foundation

let file = FileHandle(forWritingAtPath: "/dev/null")!
let lines = ["x,y", "1,1", "2,4", "3,9", "4,16"]
```

```
To write each line to the file, pass a closure to the  method:
```swift
lines.forEach { line in
    file.write("\(line)\n".data(using: .utf8)!)
}
```

```
When you’re finished using a , close it using . The correct placement of the call to  is outside of the closure:
```swift
lines.forEach { line in
    file.write("\(line)\n".data(using: .utf8)!)
}

file.closeFile()
```

```
If you misunderstand the requirements of , you might place the call inside the closure. Doing so crashes your app:
```swift
lines.forEach { line in
    file.write("\(line)\n".data(using: .utf8)!)
    file.closeFile() // Error
}
```

#### 
The example below defines a `Lottery` enumeration that randomly picks a winning number and calls a completion handler if the right number is guessed:
If there’s a chance that a closure you pass to an API won’t be called, don’t put code that’s critical to continuing your app in the closure.
The example below defines a `Lottery` enumeration that randomly picks a winning number and calls a completion handler if the right number is guessed:
```swift
enum Lottery {
    static var lotteryWinHandler: (() -> Void)?

    @discardableResult static func pickWinner(guess: Int) -> Bool {
        print("Running the lottery.")
        if guess == Int.random(in: 0 ..< 100_000_000), let winHandler = lotteryWinHandler {
            winHandler()
            return true
        }

        return false
    }
}
```

```
Writing code that depends on the completion handler being called is dangerous. There’s no guarantee that the random guess will be correct, so important actions like paying bills—scheduled for after you win the lottery—might never happen.
```swift
func payBills() {
    amountOwed = 0
}

var amountOwed = 25
let myLuckyNumber = 42

Lottery.lotteryWinHandler = {
    print("Congratulations!")
    payBills()
}

// You get 10 chances at winning.
for _ in 1...10 {
    Lottery.pickWinner(guess: myLuckyNumber)
}

if amountOwed > 0 {
    fatalError("You need to pay your bills before proceeding.")
}

// Code placed below this line runs only if the lottery was won.
```


## Renaming Objective-C APIs for Swift
> https://developer.apple.com/documentation/swift/renaming-objective-c-apis-for-swift

### 
#### 
The example below renames a class and one of its properties:
```occ
NS_SWIFT_NAME(Sandwich.Preferences)
@interface SandwichPreferences : NSObject

@property BOOL includesCrust NS_SWIFT_NAME(isCrusty);

@end

@interface Sandwich : NSObject
@end
```

The `SandwichPreferences` class and its `includesCrust` property are renamed to `Sandwich.Preferences` and `isCrusty` for Swift:
```
The `SandwichPreferences` class and its `includesCrust` property are renamed to `Sandwich.Preferences` and `isCrusty` for Swift:
```swift
var preferences = Sandwich.Preferences()
preferences.isCrusty = true
```

```
You use the `NS_SWIFT_NAME` macro as a prefix for classes and protocols. For all other kinds of declaration—such as properties, enumeration cases, and type aliases—you use the macro as a suffix. The following example uses the macro as a suffix to rename an enumeration:
```occ
typedef NS_ENUM(NSInteger, SandwichBreadType) {
    brioche, pumpernickel, pretzel, focaccia
} NS_SWIFT_NAME(SandwichPreferences.BreadType);
```


## Updating an App to Use Swift Concurrency
> https://developer.apple.com/documentation/swift/updating_an_app_to_use_swift_concurrency

### 
#### 
#### 
The `HealthKitController` type contains several calls to the HealthKit SDK. In SDKs that support Swift concurrency, frameworks add `async`-`await` versions of most functions that previously took completion handlers. You can remove completion handlers by updating these calls to use the `async`-`await` versions. You suspend the `store.save()` operation by adding the `await` keyword. Execution resumes after the `await` completes. An `async` function can also be a throwing function, which you call by prepending `try await` to the function call. Wrap the call in a `do-catch` statement instead of using an `Error?` type as a parameter to the completion handler.
```swift
// Save the sample to the HealthKit store.
do {
    try await store.save(caffeineSample)
    self.logger.debug("\(mgCaffeine) mg Drink saved to HealthKit")
} catch {
    self.logger.error("Unable to save \(caffeineSample) to the HealthKit store: \(error.localizedDescription)")
}
```

To `await` the results of a completion handler in these cases, add a `continuation`:
In some cases an SDK call requires using a completion handler. For example, a call to  takes a completion handler, but the call that needs to `await` is the call to .
To `await` the results of a completion handler in these cases, add a `continuation`:
```swift
private func queryHealthKit() async throws -> ([HKSample]?, [HKDeletedObject]?, HKQueryAnchor?) {
    return try await withCheckedThrowingContinuation { continuation in
        // Create a predicate that only returns samples created within the last 24 hours.
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-24.0 * 60.0 * 60.0)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
        
        // Create the query.
        let query = HKAnchoredObjectQuery(
            type: caffeineType,
            predicate: datePredicate,
            anchor: anchor,
            limit: HKObjectQueryNoLimit) { (_, samples, deletedSamples, newAnchor, error) in
            
            // When the query ends, check for errors.
            if let error = error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: (samples, deletedSamples, newAnchor))
            }
            
        }
        store.execute(query)
    }
}
```

To protect the stored properties on the controller when accessed asynchronously, change `HealthKitController` from a `class` type to an `actor`:
```
To protect the stored properties on the controller when accessed asynchronously, change `HealthKitController` from a `class` type to an `actor`:
```swift
actor HealthKitController {
```

Calls to `async` functions from synchronous functions are made by creating new asynchronous tasks, which can use `await` to wait for completion:
```
Calls to `async` functions from synchronous functions are made by creating new asynchronous tasks, which can use `await` to wait for completion:
```swift
// Handle background refresh tasks.
case let backgroundTask as WKApplicationRefreshBackgroundTask:
    
    Task {
        // Check for updates from HealthKit.
        let model = CoffeeData.shared
        
        let success = await model.healthKitController.loadNewDataFromHealthKit()
            
        if success {
            // Schedule the next background update.
            scheduleBackgroundRefreshTasks()
            self.logger.debug("Background Task Completed Successfully!")
        }
        
        // Mark the task as ended, and request an updated snapshot, if necessary.
        backgroundTask.setTaskCompletedWithSnapshot(success)
    }
```

#### 
The `CoffeeData` class implements `ObservableObject` and has an `@Published` property to feed the SwiftUI views. To ensure that all updates to this property are made on the main thread, place the type on the main actor:
```swift
@MainActor
class CoffeeData: ObservableObject {
```

#### 
Several methods on the  protocol used to configure the app’s timeline take completion handlers, which you can replace with their `async` equivalents:
Several methods on the  protocol used to configure the app’s timeline take completion handlers, which you can replace with their `async` equivalents:
```swift
// Define whether the complication is visible when the watch is unlocked.
func privacyBehavior(for complication: CLKComplication) async -> CLKComplicationPrivacyBehavior {
    // This is potentially sensitive data. Hide it on the lock screen.
    .hideOnLockScreen
}
```


## Using Delegates to Customize Object Behavior
> https://developer.apple.com/documentation/swift/using-delegates-to-customize-object-behavior

### 
#### 
Cocoa APIs often provide protocols that include delegate methods. When an event occurs—such as a user resizing a window—a class that’s a delegator will detect the event and call delegate methods on the class you specify as the delegate. Delegate methods can customize how an app responds to an event.
The example below adopts the  protocol and implements its  method:
```swift
class MyDelegate: NSObject, NSWindowDelegate {
    func window(_ window: NSWindow, willUseFullScreenContentSize proposedSize: NSSize) -> NSSize {
        return proposedSize
    }
}
```

#### 
The Cocoa delegation pattern doesn’t require that delegates are instantiated. If you don’t need to respond to events, you don’t need to create a delegate. Before you call a method on an object’s delegate, make sure that the delegate isn’t `nil`.
The example below creates an  and uses optional chaining to check that the window’s delegate exists before sending a message to the delegate.
```swift
let myWindow = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 5120, height: 2880),
    styleMask: .fullScreen,
    backing: .buffered,
    defer: false
)

myWindow.delegate = MyDelegate()
if let fullScreenSize = myWindow.delegate?.window(myWindow, willUseFullScreenContentSize: mySize) {
    print(NSStringFromSize(fullScreenSize))
}
```


## Using Imported C Functions in Swift
> https://developer.apple.com/documentation/swift/using-imported-c-functions-in-swift

### 
Swift imports any function declared in a C header as a Swift global function.
For example, consider the following C function declarations:
```occ
int product(int multiplier, int multiplicand);
int quotient(int dividend, int divisor, int *remainder);

struct Point2D createPoint2D(float x, float y);
float distance(struct Point2D from, struct Point2D to);
```

```
Here’s how Swift imports them:
```swift
func product(_ multiplier: Int32, _ multiplicand: Int32) -> Int32
func quotient(_ dividend: Int32, _ divisor: Int32, _ remainder: UnsafeMutablePointer<Int32>) -> Int32

func createPoint2D(_ x: Float, _ y: Float) -> Point2D
func distance(_ from: Point2D, _ to: Point2D) -> Float
```

#### 
For example, here’s how to call the `vasprintf(_:_:_:)` function in Swift:
In Swift, you can call C variadic functions, such as `vasprintf(_:_:_:)`, using the Swift  or  functions. The `withVaList(_:_:)` function takes an array of  values and provides a  value within the body of a closure parameter, whereas the `getVaList(_:)` function returns this value directly. With either function, you pass the resulting `CVaListPointer` value as the `va_list` argument of the C variadic function.
For example, here’s how to call the `vasprintf(_:_:_:)` function in Swift:
```swift
func swiftprintf(format: String, arguments: CVarArg...) -> String? {
    return withVaList(arguments) { va_list in
        var buffer: UnsafeMutablePointer<Int8>? = nil
        return format.withCString { cString in
            guard vasprintf(&buffer, cString, va_list) != 0 else {
                return nil
            }

            return String(validatingUTF8: buffer!)
        }
    }
}
print(swiftprintf(format: "√2 ≅ %g", arguments: sqrt(2.0))!)
// Prints "√2 ≅ 1.41421"
```

#### 
| `const Type *` | <Type> |
| `Type *` | <Type> |
| `Type * const *` | <Type> |
| `Type * __strong *` | <Type> |
| `Type **` | <Type> |
| `const void *` |  |
| `void *` |  |

## Using Imported C Macros in Swift
> https://developer.apple.com/documentation/swift/using-imported-c-macros-in-swift

### 
Swift automatically imports simple, constant-like macros, declared with the `#define` directive, as global constants. Macros are imported when they use literals for string, floating-point, or integer values, or use operators like `+`, `-`, `>`, and `==` between literals or previously defined macros. This example defines some simple macros in a C header:
```occ
#define FADE_ANIMATION_DURATION 0.35
#define VERSION_STRING "2.2.10.0a"
#define MAX_RESOLUTION 1268

#define HALF_RESOLUTION (MAX_RESOLUTION / 2)
#define IS_HIGH_RES (MAX_RESOLUTION > 1024)
```

```
When imported into Swift, the macros in the above example are equivalent to these constant declarations:
```swift
let FADE_ANIMATION_DURATION = 0.35
let VERSION_STRING = "2.2.10.0a"
let MAX_RESOLUTION = 1268

let HALF_RESOLUTION = 634
let IS_HIGH_RES = true
```

#### 

## Using Imported C Structs and Unions in Swift
> https://developer.apple.com/documentation/swift/using-imported-c-structs-and-unions-in-swift

### 
#### 
If all imported members have default values, Swift also provides a default initializer that takes no arguments. For example, given the following C structure:
```occ
struct Color {
    float r, g, b;
};
typedef struct Color Color;
```

```
When you import the Color structure, the Swift version is equivalent to the following:
```swift
public struct Color {
    var r: Float
    var g: Float
    var b: Float

    init()
    init(r: Float, g: Float, b: Float)
}
```

#### 
Swift imports C unions as Swift structures. Although Swift doesn’t support natively declared unions, a C union imported as a Swift structure still behaves like a C union. For example, consider a C union named `SchroedingersCat` that has an `isAlive` and an `isDead` field:
```occ
union SchroedingersCat {
    bool isAlive;
    bool isDead;
};
```

```
In Swift, it’s imported like this:
```swift
struct SchroedingersCat {
    var isAlive: Bool { get set }
    var isDead: Bool { get set }

    init(isAlive: Bool)
    init(isDead: Bool)

    init()
}
```

Because unions in C use the same base memory address for all of their fields, all of the computed properties in a union imported by Swift use the same underlying memory. As a result, changing the value of a property on an instance of the imported structure changes the value of all other properties defined by that structure.
In the example below, changing the value of the `isAlive` computed property on an instance of the `SchroedingersCat` structure also changes the value of the instance’s `isDead` computed property:
```swift
var mittens = SchroedingersCat(isAlive: false)

print(mittens.isAlive, mittens.isDead)
// Prints "false false"

mittens.isAlive = true
print(mittens.isDead)
// Prints "true"
```

#### 
#### 
C `struct` and `union` types can define fields that have no name or that are of an unnamed type. Unnamed fields consist of a nested `struct` or `union` type with named fields.
For example, consider a C structure named `Cake` that contains the fields `layers` and `height` nested within an unnamed union type, and a field `toppings` of an unnamed struct type:
```occ
struct Cake {
    union {
        int layers;
        double height;
    };

    struct {
        bool icing;
        bool sprinkles;
    } toppings;
};
```

After the `Cake` structure has been imported, you can use the default initializer to create an instance and use it as follows:
```
After the `Cake` structure has been imported, you can use the default initializer to create an instance and use it as follows:
```swift
var simpleCake = Cake()
simpleCake.layers = 5
print(simpleCake.toppings.icing)
// Prints "false"
```

```
The imported `Cake` structure and its nested types are imported with a memberwise initializer that you can use to initialize the structure with custom values for its fields:
```swift
let cake = Cake(
    .init(layers: 2),
    toppings: .init(icing: true, sprinkles: false)
)

print("The cake has \(cake.layers) layers.")
// Prints "The cake has 2 layers."
print("Does it have sprinkles?", cake.toppings.sprinkles ? "Yes." : "No.")
// Prints "Does it have sprinkles? No."
```


## Using Imported Lightweight Generics in Swift
> https://developer.apple.com/documentation/swift/using-imported-lightweight-generics-in-swift

### 
Objective-C type declarations that use lightweight generic parameterization are imported by Swift with information about the type of their contents preserved. For example, given the following Objective-C property declarations:
```occ
@property NSArray<NSDate *> *dates;
@property NSCache<NSObject *, id<NSDiscardableContent>> *cachedData;
@property NSDictionary <NSString *, NSArray<NSLocale *> *> *supportedLocales;
```

```
Here’s the Swift version of those declarations when you import them:
```swift
var dates: [Date]
var cachedData: NSCache<NSObject, NSDiscardableContent>
var supportedLocales: [String: [Locale]]
```

A parameterized class written in Objective-C is imported into Swift as a generic class with the same number of type parameters. All Objective-C generic type parameters imported by Swift have a type constraint that requires that type to be a class (`T: AnyObject`).
If the Objective-C generic parameterization specifies class or protocols qualifications, the imported Swift declaration has a constraint that requires that type to be a subclass of the specified class or to conform to the specified protocol. For an unspecialized Objective-C type, Swift infers the generic parameterization for the imported class type constraints. For example, consider the following Objective-C class and category declarations:
```occ
@interface List<T: id<NSCopying>> : NSObject
- (List<T> *)listByAppendingItemsInList:(List<T> *)otherList;
@end

@interface ListContainer : NSObject
- (List<NSValue *> *)listOfValues;
@end

@interface ListContainer (ObjectList)
- (List *)listOfObjects;
@end
```

```
When you import these declarations into Swift, the `NSCopying` protocol qualification of the `List` type and the `NSValue` class qualification of the `listOfValues` method are preserved. In addition, the unqualified `listOfObjects` method uses the `NSCopying` generic constraint inferred from the `List` type.
```swift
class List<T: NSCopying> : NSObject {
    func listByAppendingItemsInList(otherList: List<T>) -> List<T>
}

class ListContainer : NSObject {
    func listOfValues() -> List<NSValue>
}

extension ListContainer {
    func listOfObjects() -> List<NSCopying>
}
```


## Using Imported Protocol-Qualified Classes in Swift
> https://developer.apple.com/documentation/swift/using-imported-protocol-qualified-classes-in-swift

### 
Objective-C classes qualified by one or more protocols, like the one in the example below, are imported by Swift as protocol composition types. The following Objective-C property refers to a view controller that also acts a data source and delegate:
```occ
@property UIViewController<UITableViewDataSource, UITableViewDelegate> * myController;
```

```
When you import it, here’s the Swift interface:
```swift
var myController: UIViewController & UITableViewDataSource & UITableViewDelegate
```

```
An Objective-C protocol-qualified metaclass is imported by Swift as a protocol metatype, which is a type that represents the type of a protocol itself. For example, given the following Objective-C method that performs an operation on the specified class:
```occ
- (void)doSomethingForClass:(Class<NSCoding>)codingClass;
```

```
When you import it, here’s the Swift interface:
```swift
func doSomething(for codingClass: NSCoding.Type)
```


## Using Key-Value Observing in Swift
> https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift

### 
#### 
Mark properties that you want to observe through key-value observing with both the `@objc` attribute and the `dynamic` modifier. The example below defines the `MyObjectToObserve` class with a property—`myDate`—that can be observed:
```swift
class MyObjectToObserve: NSObject {
    @objc dynamic var myDate = NSDate(timeIntervalSince1970: 0) // 1970
    func updateDate() {
        myDate = myDate.addingTimeInterval(Double(2 << 30)) // Adds about 68 years.
    }
}
```

#### 
In the example below, the `\.objectToObserve.myDate` key path refers to the `myDate` property of `MyObjectToObserve`:
An instance of an observer class manages information about changes made to one or more properties. When you create an observer, you start observation by calling the `observe(_:options:changeHandler:)` method with a key path that refers to the property you want to observe.
In the example below, the `\.objectToObserve.myDate` key path refers to the `myDate` property of `MyObjectToObserve`:
```swift
class MyObserver: NSObject {
    @objc var objectToObserve: MyObjectToObserve
    var observation: NSKeyValueObservation?

    init(object: MyObjectToObserve) {
        objectToObserve = object
        super.init()

        observation = observe(
            \.objectToObserve.myDate,
            options: [.old, .new]
        ) { object, change in
            print("myDate changed from: \(change.oldValue!), updated to: \(change.newValue!)")
        }
    }
}
```

You use the `oldValue` and `newValue` properties of the  instance to see what’s changed about the property you’re observing.
#### 
You associate the property you want to observe with its observer by passing the object to the initializer of the observer:
```swift
let observed = MyObjectToObserve()
let observer = MyObserver(object: observed)
```

#### 
Objects that are set up to use key-value observing—such as `observed` above—notify their observers about property changes. The example below changes the `myDate` property by calling the `updateDate` method. That method call automatically triggers the observer’s change handler:
```swift
observed.updateDate() // Triggers the observer's change handler.
// Prints "myDate changed from: 1970-01-01 00:00:00 +0000, updated to: 2038-01-19 03:14:08 +0000"
```


## Using Objective-C Runtime Features in Swift
> https://developer.apple.com/documentation/swift/using-objective-c-runtime-features-in-swift

### 
#### 
In Objective-C, a selector is a type that refers to the name of an Objective-C method. In Swift, Objective-C selectors are represented by the  structure, and you create them using the `#selector` expression.
In Swift, you create a selector for an Objective-C method by placing the name of the method within the `#selector` expression: `#selector(MyViewController.tappedButton(_:))`. To construct a selector for a property’s Objective-C getter or setter method, prefix the property name using the `getter:` or `setter:` label, like `#selector(getter: MyViewController.myButton)`. The example below shows a selector being used as part of the target-action pattern to call a method in response to the  event.
```swift
import UIKit
class MyViewController: UIViewController {
    let myButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let action = #selector(MyViewController.tappedButton)
        myButton.addTarget(self, action: action, forControlEvents: .touchUpInside)
    }

    @objc func tappedButton(_ sender: UIButton?) {
        print("tapped button")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
```

#### 
You use the `#keyPath` string expression to create compiler-checked keys and key paths that can be used by KVC methods like  and . The `#keyPath` string expression accepts chained method or property references. It also supports chaining through optional values within a chain, such as `#keyPath(Person.bestFriend.name)`. Key paths created using the `#keyPath` string expression don’t pass type information about the properties or methods they reference to the APIs that accept key paths.
The example below defines a `Person` class, creates two instances of it, and uses several `#keyPath` string expressions to access properties and properties of those properties:
```swift
class Person: NSObject {
    @objc var name: String
    @objc var friends: [Person] = []
    @objc var bestFriend: Person? = nil

    init(name: String) {
        self.name = name
    }
}

let gabrielle = Person(name: "Gabrielle")
let jim = Person(name: "Jim")
let yuanyuan = Person(name: "Yuanyuan")
gabrielle.friends = [jim, yuanyuan]
gabrielle.bestFriend = yuanyuan

#keyPath(Person.name)
// "name"
gabrielle.value(forKey: #keyPath(Person.name))
// "Gabrielle"
#keyPath(Person.bestFriend.name)
// "bestFriend.name"
gabrielle.value(forKeyPath: #keyPath(Person.bestFriend.name))
// "Yuanyuan"
#keyPath(Person.friends.name)
// "friends.name"
gabrielle.value(forKeyPath: #keyPath(Person.friends.name))
// ["Yuanyuan", "Jim"]
```


## Working with Core Foundation Types
> https://developer.apple.com/documentation/swift/working-with-core-foundation-types

### 
#### 
#### 
When Swift imports APIs that have not been annotated, the compiler cannot automatically memory-manage the returned Core Foundation objects. Swift wraps these returned Core Foundation objects in an  structure. All indirectly returned Core Foundation objects are unmanaged as well. For example, here’s an unannotated C function:
```occ
CFStringRef StringByAddingTwoStrings(CFStringRef s1, CFStringRef s2)
```

```
And here’s how Swift imports it:
```swift
func StringByAddingTwoStrings(_: CFString!, _: CFString!) -> Unmanaged<CFString>! {
    // ...
}
```

The `Unmanaged` structure provides two methods to convert an unmanaged object to a memory-managed object—`takeUnretainedValue()` and `takeRetainedValue()`. Both of these methods return the original, unwrapped type of the object. You choose which method to use based on whether the API you are invoking returns an unretained or a retained object.
For example, suppose the C function above doesn’t retain the `CFString` object before returning it. To start using the object, you use the `takeUnretainedValue()` function.
```swift
let memoryManagedResult = StringByAddingTwoStrings(str1, str2).takeUnretainedValue()
// memoryManagedResult is a memory managed CFString
```

You can also invoke the `retain()`, `release()`, and `autorelease()` methods on unmanaged objects, but this approach is not recommended.

## Working with Foundation Types
> https://developer.apple.com/documentation/swift/working-with-foundation-types

### 
#### 
| `AffineTransform` | `NSAffineTransform` |
| `Array` | `NSArray` |
| `Calendar` | `NSCalendar` |
| `CharacterSet` | `NSCharacterSet` |
| `Data` | `NSData` |
| `DateComponents` | `NSDateComponents` |
| `DateInterval` | `NSDateInterval` |
| `Date` | `NSDate` |
| `Decimal` | `NSDecimalNumber` |
| `Dictionary` | `NSDictionary` |
| `IndexPath` | `NSIndexPath` |
| `IndexSet` | `NSIndexSet` |
| `Locale` | `NSLocale` |
| `Measurement` | `NSMeasurement` |
| `Notification` | `NSNotification` |
| Swift numeric types (`Int`, `Float`, and so on) | `NSNumber` |
| `PersonNameComponents` | `NSPersonNameComponents` |
| `Set` | `NSSet` |
| `String` | `NSString` |
| `TimeZone` | `NSTimeZone` |
| `URL` | `NSURL` |
| `URLComponents` | `NSURLComponents` |
| `URLQueryItem` | `NSURLQueryItem` |
| `URLRequest` | `NSURLRequest` |
| `UUID` | `NSUUID` |
When Swift code imports Objective-C APIs, the importer replaces Foundation reference types with their corresponding value types. For this reason, you should almost never need to use a bridged reference type directly in your own code.
If you need the reference semantics that come with the Foundation reference type, you can access it with its original `NS` class name prefix. Cast between a Swift value type and its corresponding reference type by using the `as` keyword.
```swift
let dataValue = Data(base64Encoded: myString)
let dataReference = dataValue as NSData?
```

#### 
- Classes specific to Objective-C or inherently tied to the Objective-C runtime, like `NSObject`, `NSAutoreleasePool`, `NSException`, and `NSProxy`
- Platform-specific classes, like `NSBackgroundActivity`, `NSUserNotification`, and `NSXPCConnection`

