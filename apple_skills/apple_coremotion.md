# Apple COREMOTION Skill


## Accessing submersion data
> https://developer.apple.com/documentation/coremotion/accessing-submersion-data

### 
- Add the `underwater-depth` Background Mode capability to the app.
#### 
#### 
#### 
To make sure your app continues to run, and remains visible, you need to add the `underwater-depth` Background Mode to your app’s `Info.plist` file. This background mode lets your app run as the frontmost app during a dive session.
Open the `Info.plist` file as XML by Control-clicking it in the Project navigator and selecting Open As > Source Code. Next, edit the string value for the  key so that it contains the `underwater-depth` value.
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>WKBackgroundModes</key>
    <array>
        <string>underwater-depth</string>
    </array>
</dict>
</plist>

```

If your app doesn’t already have an `Info.plist` file, you can add a placeholder, and then edit it using the following steps:
3. Choose an option to use as a placeholder from the Session Type pop-up menu. The `Info.plist` file appears in the Project navigator.
4. Open the `Info.plist` file as XML source code and replace the placeholder string value for the  key with the `underwater-depth` value.
#### 
Before creating a submersion manager, verify that the data is available on the current device.
```swift
guard CMWaterSubmersionManager.waterSubmersionAvailable else {
    return false
}
```

#### 
To begin receiving submersion data, instantiate a  object and assign a .
```swift
// Instantiate the submersion manager.
submersionManager = CMWaterSubmersionManager()

// Assign the submersion manager delegate.
submersionManager.delegate = self
```

```
Your delegate begins to receive data as soon as you assign it. For example, your delegate receives both event notifications and errors.
```swift
// Respond to events.
nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate event: CMWaterSubmersionEvent) {

    let submerged: Bool?
    switch event.state {
    case .unknown:
        logger.info("*** Received an unknown event. ***")
        submerged = nil

    case .notSubmerged:
        logger.info("*** Not Submerged Event ***")
        submerged = false

    case .submerged:
        logger.info("*** Submerged Event ***")
        submerged = true

    @unknown default:
        fatalError("*** Unknown event received: \(event.state) ***")
    }

    Task {
        await myAdd(event: event)
        if let submerged {
            await mySet(submerged: submerged)
        }
    }
}

// Respond to errors.
nonisolated func manager(_ manager: CMWaterSubmersionManager, errorOccurred error: Error) {
    logger.error("*** An error occurred: \(error.localizedDescription) ***")
}

```

```
Your delegate also begins receiving measurement updates. If the watch isn’t submerged, the updates only include surface pressure and submersion state data. After submersion, it also receives water pressure and depth data. The system sends measurement updates three times a second while the watch is submerged. When the watch is on the surface, the system provides updates at a slower rate, and may stop providing updates if the watch isn’t moving.
```swift
nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterSubmersionMeasurement) {

    logger.info("*** Received a depth measurement. ***")

    let currentDepth: String
    if let depth = measurement.depth {
        currentDepth = "\(depth.value) \(depth.unit)"
    } else {
        currentDepth = "None"
    }

    let currentSurfacePressure: String
    let surfacePressure = measurement.surfacePressure
    currentSurfacePressure = "\(surfacePressure.value) \(surfacePressure.unit)"

    let currentPressure: String
    if let pressure = measurement.pressure {
        currentPressure = "\(pressure.value) \(pressure.unit)"
    } else {
        currentPressure = "None"
    }

    logger.info("*** Depth: \(currentDepth) ***")
    logger.info("*** Surface Pressure: \(currentSurfacePressure) ***")
    logger.info("*** Pressure: \(currentPressure) ***")

    let submerged: Bool?
    switch measurement.submersionState {
    case .unknown:
        logger.info("*** Unknown Depth ***")
        submerged = nil
    case .notSubmerged:
        logger.info("*** Not Submerged ***")
        submerged = false
    case .submergedShallow:
        logger.info("*** Shallow Depth ***")
        submerged = true
    case .submergedDeep:
        logger.info("*** Deep Depth ***")
        submerged = true
    case .approachingMaxDepth:
        logger.info("*** Approaching Max Depth ***")
        submerged = true
    case .pastMaxDepth:
        logger.info("*** Past Max Depth ***")
        submerged = true
    case .sensorDepthError:
        logger.info("*** A depth error has occurred. ***")
        submerged = nil
    @unknown default:
        fatalError("*** An unknown measurement depth state: \(measurement.submersionState)")
    }

    Task {
        await myAdd(measurement: measurement)
        if let submerged {
            await mySet(submerged: submerged)
        }
    }
}
```

```
The watch also receives water temperature data when it’s submerged.
```swift
nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterTemperature) {
    let temp = measurement.temperature
    let uncertainty = measurement.temperatureUncertainty
    let currentTemperature = "\(temp.value) +/- \(uncertainty.value) \(temp.unit)"

    logger.info(("*** \(currentTemperature) ***"))

    Task {
        await myAdd(temperature:measurement)
    }
}
```

#### 
You can start an extended runtime session as the wearer begins their dive.
```swift
func myStartDiveSession() {
    logger.info("*** Starting a dive session. ***")

    // Create the extended runtime session.
    let session = WKExtendedRuntimeSession()

    // Assign a delegate to the session.
    session.delegate = self

    // Start the session.
    session.start()

    self.extendedRuntimeSession = session
    diveSessionRunning = true
}
```

#### 
Starting an extended runtime session automatically enables Water Lock on the watch. As a result, the system disables the watch’s touchscreen for the duration of the dive. If you want the wearer to interact with your app during the dive, you need to enable interaction using either the Digital Crown or the Action button.
Many views, like , , and , automatically respond to the Digital Crown. The wearer can interact with these elements without needing any changes to the user interface.
```swift
struct MyPickerView: View {

    enum Action: String, CaseIterable, Identifiable {
        case none, action1, action2, action3
        var id: Self { self }
    }

    @State var selection: Action = .none

    var body: some View {
        Text(selection.rawValue)
        Picker("Action", selection: $selection) {
            ForEach(Action.allCases) { action in
                Text(action.rawValue.capitalized)
            }
        }
    }
}
```

```
You can also use the  view modifier to respond directly when the wearer rotates the Digital Crown.
```swift
struct DigitalCrown: View {
    @State private var crownValue = 0.0

    var body: some View {
        Text("\(crownValue)")
            .focusable()
            .digitalCrownRotation($crownValue,
                                  from: 1,
                                  through: 10,
                                  by: 1.0,
                                  sensitivity: .low,
                                  isHapticFeedbackEnabled: true)
    }
}
```

```
For the Action button, implement a  to launch your app and prepare for a new dive when the wearer first presses the Action button. You can then donate an  for the Action button’s next action. If the wearer presses the Action button any other time during the session, it triggers the next action. Your app can have only one next action at a time, and donating a new intent changes the next action — letting you customize the next action based on your app’s current state.
```swift
// Create an intent to launch your app and set up the dive manager.
struct MyStartDiveSessionIntent: StartDiveIntent {

    static var title: LocalizedStringResource = "Starting a dive session."

    func perform() async throws -> some IntentResult {
        logger.debug("*** Starting a dive session. ***")

        await MyDiveManager.shared.start()
        return .result(actionButtonIntent: MyBeginDescent())
    }
}

// Create an intent that defines the Action button's next action.
struct MyBeginDescent: AppIntent {

    static var title: LocalizedStringResource = "Start Your Descent"

    func perform() async throws -> some IntentResult {
        logger.debug("*** Starting the descent. ***")
        await MyDiveManager.shared.beginDescent()
        return .result()
    }
}

```

#### 
If you don’t explicitly start an extended runtime session, the system automatically starts a session when the wearer descends below 1 meter. It then passes the session to your app delegate’s  method. To use this session, add a delegate and save it to a variable that remains in scope for the entire dive’s duration.
```swift
func handle(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
    // The system starts a session because the wearer is more than
    // 1 meter underwater without an active extended runtime session.

    let submersionSession = MySubmersionSession.shared

    // Assign a delegate to the session.
    extendedRuntimeSession.delegate = submersionSession

    submersionSession.extendedRuntimeSession = extendedRuntimeSession
    submersionSession.diveSessionRunning = true
}
```

#### 
#### 

## Getting movement disorder symptom data
> https://developer.apple.com/documentation/coremotion/getting-movement-disorder-symptom-data

### 
Apps that use the `CMMovementDisorderManager` must:
1. Provide a motion usage description in your WatchKit extension’s `Info.plist` file.
#### 
#### 
The following example shows how to set up your movement disorder manager, and begin monitoring the user’s symptoms:
```swift
// Check to see if the movement disorder manager is available.
guard CMMovementDisorderManager.isAvailable() else {
    // The movement disorder manager is not availble on this device.
    return
}

// Instantiate the Movement Disorder Manager
movementDisorderManager = CMMovementDisorderManager()

// Start monitoring the user. The maximum duration is seven days.
movementDisorderManager.monitorKinesias(forDuration: 60.0 * 60.0 * 24.0 * 7.0)
```

After you start monitoring, the manager leverages the  to record high-rate accelerometer data passively. When enabled, the  records 100 Hz samples. The movement disorder algorithms then periodically and opportunistically use this data to calculate tremors and dyskinetic symptoms.
The movement disorder manager stores the results of these calculations on the device for seven days. To access the results, use the manager to query for the desired results, as shown in this example:
```swift
// Get the end date for the last batch of results.
guard let endDate = movementDisorderManager.lastProcessedDate() else {
    // The manager has not processed any results yet.
    return
}

// Get the last batch of tremor results.
movementDisorderManager.queryTremor(from: previousDate, to: endDate) { (tremorResults, error) in
    
    // Check for errors.
    if let error = error {
        // Handle the error here.
        print("*** An error occurred: \(error.localizedDescription) ***")
        return
    }
    
    // Do something with the tremor results here.
}

// Get the last batch of dyskinetic symptom results.
movementDisorderManager.queryDyskineticSymptom(from: previousDate, to: endDate) { (dyskineticSymptomResults, error) in
    
    // Check for errors.
    if let error = error {
        // Handle the error here.
        print("*** An error occurred: \(error.localizedDescription) ***")
        return
    }
    
    // Do something with the dyskinetic symptom results here.
}

previousDate = endDate
```

#### 

## Getting processed device-motion data
> https://developer.apple.com/documentation/coremotion/getting-processed-device-motion-data

### 
#### 
#### 
#### 
Both options require you to specify the frequency of updates from the system using the  property of your `CMMotionManager` type. The maximum update frequency is hardware dependent, but is usually at least 100 Hz. If you specify an update frequency greater than what the hardware supports, Core Motion uses the maximum frequency instead.
The following example configures the device-motion service to deliver updates 50 times per second, and to deliver attitude data relative to magnetic north. When starting device motion without a closure, it’s your responsibility to check the  property of your `CMMotionManager` at regular intervals. This example sets up a timer to check the value of the property and apply the latest data to the app’s content:
```swift
func startDeviceMotion() {
    if motion.isDeviceMotionAvailable {
        self.motion.deviceMotionUpdateInterval = 1.0 / 50.0
        self.motion.showsDeviceMovementDisplay = true
        self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
        
        // Configure a timer to fetch the motion data.
        self.timer = Timer(fire: Date(), interval: (1.0 / 50.0), repeats: true,
                           block: { (timer) in
                            if let data = self.motion.deviceMotion {
                                // Get the attitude relative to the magnetic north reference frame.
                                let x = data.attitude.pitch
                                let y = data.attitude.roll
                                let z = data.attitude.yaw
                                
                                // Use the motion data in your app.
                            }
        })
        
        // Add the timer to the current run loop.
        RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
    }
}
```

```
To process a steady stream of events, start the device-motion services using an  object and a closure of type . Each time Core Motion receives a new data value, it runs your closure on the operation queue. Each new data value comes with a  value, which you can use to verify the timeliness of the data and discard data that’s older than a certain threshold. The following example uses an operation queue to process 60 updates per second:
```swift
func startQueuedUpdates() {
   if motion.isDeviceMotionAvailable {
      self.motion.deviceMotionUpdateInterval = 1.0 / 60.0
      self.motion.showsDeviceMovementDisplay = true
      self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, 
               to: self.queue, withHandler: { (data, error) in
         // Make sure the data is valid before accessing it.
         if let validData = data {
            // Get the attitude relative to the magnetic north reference frame. 
            let roll = validData.attitude.roll
            let pitch = validData.attitude.pitch
            let yaw = validData.attitude.yaw

            // Use the motion data in your app.
         }
      })
   }
}

```

#### 

## Getting raw accelerometer events
> https://developer.apple.com/documentation/coremotion/getting-raw-accelerometer-events

### 
#### 
#### 
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


## Getting raw gyroscope events
> https://developer.apple.com/documentation/coremotion/getting-raw-gyroscope-events

### 
#### 
#### 
Before you start the delivery of gyroscope updates, specify an update frequency by assigning a value to the  property. The maximum frequency at which you can request updates is hardware-dependent but is usually at least 100 Hz. If you request a frequency that is greater than what the hardware supports, Core Motion uses the supported maximum instead.
The next example shows a method that configures gyroscope updates to occur 50 times per second. The method then configures a timer to fetch those updates at the same frequency and do something with the data. You could configure the timer to fire at a lower frequency, but doing so would waste power by causing the hardware to generate more updates than were actually used.
```swift
func startGyros() {
   if motion.isGyroAvailable {
      self.motion.gyroUpdateInterval = 1.0 / 50.0
      self.motion.startGyroUpdates()

      // Configure a timer to fetch the accelerometer data.
      self.timer = Timer(fire: Date(), interval: (1.0/50.0), 
             repeats: true, block: { (timer) in
         // Get the gyro data.
         if let data = self.motion.gyroData {
            let x = data.rotationRate.x
            let y = data.rotationRate.y
            let z = data.rotationRate.z

            // Use the gyroscope data in your app. 
         }
      })

      // Add the timer to the current run loop.
      RunLoop.current.add(self.timer!, forMode: .defaultRunLoopMode)
   }
}

func stopGyros() {
   if self.timer != nil {
      self.timer?.invalidate()
      self.timer = nil

      self.motion.stopGyroUpdates()
   }
}
```

#### 
Before you start the delivery of gyroscope updates, specify an update frequency by assigning a value to the  property. The maximum frequency at which you can request updates is hardware-dependent but is usually at least 100 Hz. If you request a frequency that is greater than what the hardware supports, Core Motion uses the supported maximum instead.
The next example shows a method from the  sample code project, which you can examine for more context. The app displays a real-time graph of rotation data from the onboard gyroscopes. The user configures the update frequency for the gyroscopes using a slider, the changing of which results in a call to the `startUpdatesWithSliderValue:` method shown in the example. This method restarts the gyroscope updates with the new frequency. Each time a new sample is received, the specified block is queued on the main thread. That block updates the app’s graph view and labels with the new rotation values.
```objc
static const NSTimeInterval gyroMin = 0.01;
- (void)startUpdatesWithSliderValue:(int)sliderValue {
   // Determine the update interval
   NSTimeInterval delta = 0.005;
   NSTimeInterval updateInterval = gyroMin + delta * sliderValue;

   // Create a CMMotionManager
   CMMotionManager *mManager = [(APLAppDelegate *)
            [[UIApplication sharedApplication] delegate] sharedManager];
   APLGyroGraphViewController * __weak weakSelf = self;

   // Check whether the gyroscope is available
   if ([mManager isGyroAvailable] == YES) {
      // Assign the update interval to the motion manager
      [mManager setGyroUpdateInterval:updateInterval];
      [mManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] 
               withHandler:^(CMGyroData *gyroData, NSError *error) {
         [weakSelf.graphView addX:gyroData.rotationRate.x 
                  y:gyroData.rotationRate.y 
                  z:gyroData.rotationRate.z];
         [weakSelf setLabelValueX:gyroData.rotationRate.x 
                  y:gyroData.rotationRate.y 
                  z:gyroData.rotationRate.z];
      }];
   }
   self.updateIntervalLabel.text = [NSString stringWithFormat:@"%f", updateInterval];
}
- (void)stopUpdates{
   CMMotionManager *mManager = [(APLAppDelegate *)
            [[UIApplication sharedApplication] delegate] sharedManager];
   if ([mManager isGyroActive] == YES) {
      [mManager stopGyroUpdates];
   }
}
```


