# Apple COMBINE Skill


## Controlling Publishing with Connectable Publishers
> https://developer.apple.com/documentation/combine/controlling-publishing-with-connectable-publishers

### 
#### 
To use a  in your own Combine code, use the  operator to wrap an existing publisher with a  instance. The following code shows how  fixes the data task publisher race condition described above. Typically, attaching a sink — identified here by the  it returns, `cancellable1` — would cause the data task to start immediately. In this scenario, the second sink, identified as `cancellable2`, doesn’t attach until one second later, and the data task publisher might complete before the second sink attaches. Instead, explicitly using a  causes the data task to start only after the app calls , which it does after a two-second delay.
```swift
let url = URL(string: "https://example.com/")!
let connectable = URLSession.shared
    .dataTaskPublisher(for: url)
    .map() { $0.data }
    .catch() { _ in Just(Data() )}
    .share()
    .makeConnectable()

cancellable1 = connectable
    .sink(receiveCompletion: { print("Received completion 1: \($0).") },
          receiveValue: { print("Received data 1: \($0.count) bytes.") })

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    self.cancellable2 = connectable
        .sink(receiveCompletion: { print("Received completion 2: \($0).") },
              receiveValue: { print("Received data 2: \($0.count) bytes.") })
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    self.connection = connectable.connect()
}
```

#### 
For cases like these,  provides the  operator. This operator immediately calls  when a  attaches to the publisher with the  method.
The following example uses , so a subscriber immediately receives elements from a once-a-second . Without , the example would need to explicitly start the timer publisher by calling  at some point.
```swift
let cancellable = Timer.publish(every: 1, on: .main, in: .default)
    .autoconnect()
    .sink() { date in
        print ("Date now: \(date)")
     }
```


## Performing Key-Value Observing with Combine
> https://developer.apple.com/documentation/combine/performing-key-value-observing-with-combine

### 
#### 
In the following example, the type `UserInfo` supports KVO for its `lastLogin` property, as described in . The  method uses the `observe(_:options:changeHandler:)` method to set up a closure that handles any change to the property. The closure receives an  object that describes the change event, retrieves the  property, and prints it. The  method changes the value, which calls the closure and prints the message.
```swift
class UserInfo: NSObject {
    @objc dynamic var lastLogin: Date = Date(timeIntervalSince1970: 0)
}
@objc var userInfo = UserInfo()
var observation: NSKeyValueObservation?

override func viewDidLoad() {
    super.viewDidLoad()
    observation = observe(\.userInfo.lastLogin, options: [.new]) { object, change in
        print ("lastLogin now \(change.newValue!).")
    }
}

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    userInfo.lastLogin = Date()
}
```

#### 
To convert KVO code to Combine, replace the `observe(_:options:changeHandler:)` method with an . You get an instance of this publisher by calling `publisher(for:)` on the parent object, as shown in the following example’s  method:
```swift
class UserInfo: NSObject {
    @objc dynamic var lastLogin: Date = Date(timeIntervalSince1970: 0)
}
@objc var userInfo = UserInfo()
var cancellable: Cancellable?

override func viewDidLoad() {
    super.viewDidLoad()
    cancellable = userInfo.publisher(for: \.lastLogin)
        .sink() { date in print ("lastLogin now \(date).") }
}

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    userInfo.lastLogin = Date()
}
```


## Processing Published Elements with Subscribers
> https://developer.apple.com/documentation/combine/processing-published-elements-with-subscribers

### 
#### 
#### 
This concept of controlling flow by signaling a subscriber’s readiness to receive elements is called .
Each publisher keeps track of its current unsatisfied demand, meaning how many more elements a subscriber has requested. Even automated sources like Foundation’s  only produce elements when they have pending demand. The following example code illustrates this behavior.
```swift
// Publisher: Uses a timer to emit the date once per second.
let timerPub = Timer.publish(every: 1, on: .main, in: .default)
    .autoconnect()

// Subscriber: Waits 5 seconds after subscription, then requests a
// maximum of 3 values.
class MySubscriber: Subscriber {
    typealias Input = Date
    typealias Failure = Never
    var subscription: Subscription?
    
    func receive(subscription: Subscription) {
        print("published                             received")
        self.subscription = subscription
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            subscription.request(.max(3))
        }
    }
    
    func receive(_ input: Date) -> Subscribers.Demand {
        print("\(input)             \(Date())")
        return Subscribers.Demand.none
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print ("--done--")
    }
}

// Subscribe to timerPub.
let mySub = MySubscriber()
print ("Subscribing at \(Date())")
timerPub.subscribe(mySub)
```

```
The subscriber’s `receive(subscription:)` implementation uses a five-second delay before it requests any elements from the publisher. During this period, the publisher exists and has a valid subscriber, but has zero demand, so it doesn’t produce elements. It only starts publishing elements after the delay expires and the subscriber gives it a nonzero demand, as seen in the following output:
```text
Subscribing at 2019-12-09 18:57:06 +0000
published                             received
2019-12-09 18:57:11 +0000             2019-12-09 18:57:11 +0000
2019-12-09 18:57:12 +0000             2019-12-09 18:57:12 +0000
2019-12-09 18:57:13 +0000             2019-12-09 18:57:13 +0000
```

#### 

## Receiving and Handling Events with Combine
> https://developer.apple.com/documentation/combine/receiving-and-handling-events-with-combine

### 
#### 
To receive the text field’s notifications with Combine, access the default instance of  and call its  method. This call takes the notification name and source object that you want notifications from, and returns a publisher that produces notification elements.
```swift
let pub = NotificationCenter.default
    .publisher(for: NSControl.textDidChangeNotification, object: filterField)
```

-  immediately assigns every element it receives to a property of a given object, using a key path to indicate the property.
For example, you can use the sink subscriber to log when the publisher completes, and each time it receives an element:
```swift
let sub = NotificationCenter.default
    .publisher(for: NSControl.textDidChangeNotification, object: filterField)
    .sink(receiveCompletion: { print ($0) },
          receiveValue: { print ($0) })
```

#### 
For example, the  provided by Foundation’s  uses  as its  type. This isn’t a convenient type to receive in the callback if what you need is the text field’s string value.
Since a publisher’s output is essentially a sequence of elements over time, Combine offers sequence-modifying operators like , , and . The behavior of these operators is similar to their equivalents in the Swift standard library. To change the output type of the publisher, you add a  operator whose closure returns a different type. In this case, you can get the notification’s object as an , and then get the field’s .
```swift
let sub = NotificationCenter.default
    .publisher(for: NSControl.textDidChangeNotification, object: filterField)
    .map( { ($0.object as! NSTextField).stringValue } )
    .sink(receiveCompletion: { print ($0) },
          receiveValue: { print ($0) })
```

```
After the publisher chain produces the type you want, replace `sink(receiveCompletion:receiveValue:)` with . The following example takes the strings it receives from the publisher chain and assigns them to the `filterString` of a custom view model object:
```swift
let sub = NotificationCenter.default
    .publisher(for: NSControl.textDidChangeNotification, object: filterField)
    .map( { ($0.object as! NSTextField).stringValue } )
    .assign(to: \MyViewModel.filterString, on: myViewModel)
```

#### 
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


## Replacing Foundation Timers with Timer Publishers
> https://developer.apple.com/documentation/combine/replacing-foundation-timers-with-timer-publishers

### 
#### 
Consider the following snippet, which uses  to update the `lastUpdated` property of a data model once a second, on a specific dispatch queue:
Consider the following snippet, which uses  to update the `lastUpdated` property of a data model once a second, on a specific dispatch queue:
```swift
var timer: Timer?
override func viewDidLoad() {
    super.viewDidLoad()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        self.myDispatchQueue.async() {
            self.myDataModel.lastUpdated = Date()
        }
    }
}
```

#### 
The next example shows how to use a  to replace the previous example. It uses Combine’s operators to perform the tasks that were in the previous example’s closure:
```swift
var cancellable: Cancellable?
override func viewDidLoad() {
    super.viewDidLoad()
    cancellable = Timer.publish(every: 1, on: .main, in: .default)
        .autoconnect()
        .receive(on: myDispatchQueue)
        .assign(to: \.lastUpdated, on: myDataModel)
}
```

- The  operator ensures that its subsequent operators run on the specified dispatch queue. This replaces the `async()` call from before.
- The  operator updates the data model, by using a key path to set the `lastUpdate` property.

## Routing Notifications to Combine Subscribers
> https://developer.apple.com/documentation/combine/routing-notifications-to-combine-subscribers

### 
Many frameworks deliver asynchronous events to your app with the  API. Your app may already have places where it receives and processes these notifications in callback methods or closures. For example, the following code uses  to print a message every time an iOS device rotates to portrait orientation.
```swift
var notificationToken: NSObjectProtocol?
override func viewDidLoad() {
    super.viewDidLoad()
    notificationToken = NotificationCenter.default
        .addObserver(forName: UIDevice.orientationDidChangeNotification,
                     object: nil,
                     queue: nil) { _ in
                        if UIDevice.current.orientation == .portrait {
                            print ("Orientation changed to portrait.")
                        }
    }
}
```

#### 
To take advantage of Combine, use the  to migrate your  handling code to the Combine idiom. You create this publisher with the  method , passing in the notification name in which you’re interested and a source object, if any.
Rewrite the above code in Combine as shown in the following listing. This code uses the default notification center to create a publisher for the  notification. When the code receives notifications from this publisher, it applies a filter operator to only act on portrait orientation notifications, and prints a message.
```swift
var cancellable: Cancellable?
override func viewDidLoad() {
    super.viewDidLoad()
    cancellable = NotificationCenter.default
        .publisher(for: UIDevice.orientationDidChangeNotification)
        .filter() { _ in UIDevice.current.orientation == .portrait }
        .sink() { _ in print ("Orientation changed to portrait.") }
}
```


## Using Combine for Your App’s Asynchronous Code
> https://developer.apple.com/documentation/combine/using-combine-for-your-app-s-asynchronous-code

### 
#### 
A completion handler is a closure accepted by a function that executes after the function completes its work. You typically implement this by invoking the completion handler directly when the function finishes its work, storing the closure outside the function if necessary. For example, the following function accepts a closure and then executes it after a two-second delay:
```swift
func performAsyncAction(completionHandler: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline:.now() + 2) {
        completionHandler()
    }
}
```

```
You can replace this pattern with a Combine , a publisher that performs some work and then asynchronously signals success or failure. If it succeeds, the future executes a , a closure that receives the element produced by the future. You can replace the previous function as follows:
```swift
func performAsyncActionAsFuture() -> Future <Void, Never> {
    return Future() { promise in
        DispatchQueue.main.asyncAfter(deadline:.now() + 2) {
            promise(Result.success(()))
        }
    }
}
```

```
Rather than explicitly invoking a closure when the work completes, the future invokes the promise passed to it, passing in a  that indicates success or failure. The caller receives this result asynchronously from the future. Because  is a Combine , the caller attaches it to an optional chain of operators, ending with a , like :
```swift
cancellable = performAsyncActionAsFuture()
    .sink() { _ in print("Future succeeded.") }
```

#### 
Sometimes, a long-running task generates a value that it passes to a completion handler as a parameter. To replicate this functionality in Combine, declare the parameter as the output type published by the future. The following example produces a randomly-generated integer, and passes it to the promise by declaring `Int` as the future’s output type:
```swift
func performAsyncActionAsFutureWithParameter() -> Future <Int, Never> {
    return Future() { promise in
        DispatchQueue.main.asyncAfter(deadline:.now() + 2) {
            let rn = Int.random(in: 1...10)
            promise(Result.success(rn))
        }
    }
}
```

```
By declaring that the future produces `Int` elements, the future can use the  type to pass an `Int` value to the promise. When the promise executes, the future publishes the value, which a caller can receive with a subscriber like :
```swift
cancellable = performAsyncActionAsFutureWithParameter()
    .sink() { rn in print("Got random number \(rn).") }
```

#### 
Your app may also have the common pattern of using a closure as a property to invoke when certain events happen. These properties often have names starting with `on`, and their call points look like the following:
```swift
vc.onDoSomething = { print("Did something.") }
```

```
With Combine, you can replace this pattern by using a . A subject allows you to imperatively publish a new element at any time by calling the  method. Adopt this pattern by using a `private`  or , then expose this publicly as an :
```swift
private lazy var myDoSomethingSubject = PassthroughSubject<Void, Never>()
lazy var doSomethingSubject = myDoSomethingSubject.eraseToAnyPublisher()
```

```
With this arrangement, instead of setting a closure property, callers perform their work in a subscriber, such as :
```swift
cancellable = vc.doSomethingSubject
    .sink() { print("Did something with Combine.") }
```


