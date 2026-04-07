# Apple ARKIT Skill


## Adding an Apple Pay Button or a Custom Action in AR Quick Look
> https://developer.apple.com/documentation/arkit/adding-an-apple-pay-button-or-a-custom-action-in-ar-quick-look

### 
#### 
To select a style of Apple Pay button for your AR experience, append the `applePayButtonType` parameter to your website URL.
To select a style of Apple Pay button for your AR experience, append the `applePayButtonType` parameter to your website URL.
```javascript
https://example.com/biplane.usdz#applePayButtonType=plain
```

#### 
Append the `callToAction` URL parameter with the custom text as the value. The following example URL renders a banner with the text “Add to cart”:
Append the `callToAction` URL parameter with the custom text as the value. The following example URL renders a banner with the text “Add to cart”:
```javascript
https://example.com/biplane.usdz#callToAction=Add%20to%20cart
```

#### 
If AR Quick Look can’t fit the subtitle and price on one line, it truncates the subtitle with an ellipsis. The following example URL renders the banner.
```javascript
https://example.com/biplane.usdz#applePayButtonType=buy&checkoutTitle=Biplane%20Toy&checkoutSubtitle=Rustic%20finish%20with%20rotating%20propeller&price=$15
```

#### 
To take full control of the banner’s graphics, supply a custom HTML file through the `custom` URL parameter. The following example URL renders a banner from a custom file named `comingSoonBanner`.
```swift
https://example.com/biplane.usdz#custom=https://example.com/customBanners/comingSoonBanner.html

```

#### 
When you display a custom banner, you can set the banner height using the `customHeight` URL parameter.
Supply a value of `small`, `medium`, or `large` to set the banner height to 81, 121, or 161 points, respectively. For example:
When you display a custom banner, you can set the banner height using the `customHeight` URL parameter.
Supply a value of `small`, `medium`, or `large` to set the banner height to 81, 121, or 161 points, respectively. For example:
```javascript
https://example.com/biplane.usdz#custom=https://example.com/my-custom-page.html&customHeight=large
```

#### 
When the user taps the Apple Pay button or custom action button, WebKit sends a DOM message to the `<a>` element of your code that references the 3D asset.
```javascript
<a id="ar-link" rel="ar" href="https://example.com/cool-model.usdz#applePayButtonType=pay....etc">  <img src="poster.jpg"></a>
```

To be notified of the tap, define a JavaScript listener for the `message` event on your anchor.
```
To be notified of the tap, define a JavaScript listener for the `message` event on your anchor.
```javascript
const linkElement = document.getElementById("ar-link");
linkElement.addEventListener("message", function (event) { ... }, false);
```

```
When WebKit invokes your listener, check the `data` property. A value of `_apple_ar_quicklook_button_tapped` confirms the user tapped the banner in AR Quick Look.
```swift
const linkElement = document.getElementById("ar-link");
linkElement.addEventListener("message", function (event) {   
    if (event.data == "_apple_ar_quicklook_button_tapped") {
        // Handle the user tap.   
    }
}, false);
```

#### 

## Adding realistic reflections to an AR experience
> https://developer.apple.com/documentation/arkit/adding-realistic-reflections-to-an-ar-experience

### 
### 
### 
As with any AR experience, you run a session with a world tracking configuration and whatever other options you want to enable. (For example, this app allows you to place virtual objects on flat surfaces, so it enables horizontal plane detection.) To generate environment textures, also set the configuration’s  property:
```swift
let configuration = ARWorldTrackingConfiguration()
configuration.planeDetection = .horizontal
configuration.environmentTexturing = .automatic
sceneView.session.run(configuration)
```

### 
### 
Automatic environment texturing is all you need for basic environmental lighting or reflection effects. To render reflections more realistically, however, each reflective object needs an environment probe texture that accurately captures the area close to that object. For example, in the images above, the virtual sphere reflects the real cup when the cup is close to the sphere’s real-world position.
To more precisely define environment probes, choose  environment texturing when you configure your AR session, then create your own  instance for each virtual object you want to use environmental lighting with. Initialize each probe’s  and position (using  based on the size of the corresponding virtual object:
```swift
// Make sure the probe encompasses the object and provides some surrounding area to appear in reflections.
var extent = object.extents * object.simdScale
extent.x *= 3 // Reflect an area 3x the width of the object.
extent.z *= 3 // Reflect an area 3x the depth of the object.

// Also include some vertical area around the object, but keep the bottom of the probe at the
// bottom of the object so that it captures the real-world surface underneath.
let verticalOffset = SIMD3<Float>(0, extent.y, 0)
let transform = float4x4(translation: object.simdPosition + verticalOffset)
extent.y *= 2

// Create the new environment probe anchor and add it to the session.
let probeAnchor = AREnvironmentProbeAnchor(transform: transform, extent: extent)
sceneView.session.add(anchor: probeAnchor)
```

### 

## Combining user face-tracking and world tracking
> https://developer.apple.com/documentation/arkit/combining-user-face-tracking-and-world-tracking

### 
### 
This app tracks the user’s face in a world-tracking session on iOS 13 and iPad OS 13 or later, on devices with a front TrueDepth camera that return `true` to . To prevent the app from running an unsupported configuration, check whether the iOS device supports simultaneous world and user face-tracking.
```swift
guard ARWorldTrackingConfiguration.supportsUserFaceTracking else {
    //swiftlint:disable:next line_length
    fatalError("This sample code requires iOS 13 / iPad OS 13, and an iOS device with a front TrueDepth camera. Note: 2020 iPads do not support user face-tracking while world tracking.")
}
```

The sample app sets the  property to `true` on the world-tracking configuration when app loads the view controller.
If the device running the app doesn’t support user face-tracking in a world-tracking session, the sample project will stop. In your app, consider gracefully degrading the AR experience in this case, such as by presenting the user with an error message and continuing the experience without it.
The sample app sets the  property to `true` on the world-tracking configuration when app loads the view controller.
```swift
configuration.userFaceTrackingEnabled = true
```

```
The sample app then starts the session by running the configuration when the view controller is about to appear onscreen.
```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    arView.session.run(configuration)
}
```

### 
The app checks whether a robot head preview exists and creates one if not. ARKit calls the implementation of  every frame, which makes it a good location for a periodic check.
```swift
func session(_ session: ARSession, didUpdate frame: ARFrame) {
    if headPreview == nil, case .normal = frame.camera.trackingState {
        addHeadPreview()
    }
    //...
```

### 
ARKit provides the app with an updated anchor when the user changes their expression, position, or orientation with respect to the world. If there’s an active robot head preview, the app applies these changes to the head.
```swift
func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    anchors.compactMap { $0 as? ARFaceAnchor }.forEach { headPreview?.update(with: $0) }
}
```

### 
In the robot head’s `update(with faceAnchor:)` function, the app reads the user’s current expression by interpreting the anchor’s .
In the robot head’s `update(with faceAnchor:)` function, the app reads the user’s current expression by interpreting the anchor’s .
```swift
let blendShapes = faceAnchor.blendShapes
```

```
Blend shapes are `Float` values normalized within the range `[0..1]`, with `0` representing the facial feature’s rest position, and `1` representing the opposite––the feature in its most pronounced state. To begin processing the values, the app stores them locally by accessing the anchor’s  array.
```swift
guard let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
    let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float,
    let eyeBrowLeft = blendShapes[.browOuterUpLeft] as? Float,
    let eyeBrowRight = blendShapes[.browOuterUpRight] as? Float,
    let jawOpen = blendShapes[.jawOpen] as? Float,
    let upperLip = blendShapes[.mouthUpperUpLeft] as? Float,
    let tongueOut = blendShapes[.tongueOut] as? Float
    else { return }
```

### 
Blend shape values can apply in unique ways depending on an app’s requirements. The sample app uses blend shapes to make the robot head appear to mimic the user’s expression, such as applying the brow and lip values to offset the robot’s brow and lip positions.
```swift
eyebrowLeftEntity.position.y = originalEyebrowY + 0.03 * eyeBrowLeft
eyebrowRightEntity.position.y = originalEyebrowY + 0.03 * eyeBrowRight
tongueEntity.position.z = 0.1 * tongueOut
jawEntity.position.y = originalJawY - jawHeight * jawOpen
upperLipEntity.position.y = originalUpperLipY + 0.05 * upperLip
```

```
The entity for the robot’s eye opens or closes when the sample app applies the corresponding blend shape value as a scale factor.
```swift
eyeLeftEntity.scale.z = 1 - eyeBlinkLeft
eyeRightEntity.scale.z = 1 - eyeBlinkRight
```

### 
In addition to capturing the user’s expression using the front camera, ARKit records the position of the user’s face with respect to the world. By design, the user’s face anchor is always located behind the rear camera. To serve the goal of mimicking the user with the robot head, the sample app applies the face anchor’s position to make the robot head always visible. First, it sets the robot head’s initial position equal to that of the camera.
```swift
let camera = AnchorEntity(.camera)
arView.scene.addAnchor(camera)

// Attach a robot head to the camera anchor.
let robotHead = RobotHead()
camera.addChild(robotHead)
```

```
Then the app offsets its z-position in the same amount as the camera’s distance from the user’s face.
```swift
let cameraTransform = parent.transformMatrix(relativeTo: nil)
let faceTransformFromCamera = simd_mul(simd_inverse(cameraTransform), faceAnchor.transform)
self.position.z = -faceTransformFromCamera.columns.3.z
```

### 
The sample app also uses the anchor’s orientation to direct the front of the robot’s head continually toward the camera. It starts by accessing the anchor’s orientation.
```swift
let rotationEulers = faceTransformFromCamera.eulerAngles
```

Then it adds `pi` to the `y`-Euler angle to turn it on the y-axis.
```
Then it adds `pi` to the `y`-Euler angle to turn it on the y-axis.
```swift
let mirroredRotation = Transform(pitch: rotationEulers.x, yaw: -rotationEulers.y + .pi, roll: rotationEulers.z)
```

```
To effect the change, the app applies the updated Euler angles to the robot head’s orientation.
```swift
self.orientation = mirroredRotation.rotation
```

### 
To demonstrate the variety of expressions tracked during the session, the sample app places the robot head in the physical environment when the user taps the screen. When the app initially previews the expressions, it positions the robot head at a fixed offset from the camera. When the user taps the screen, the app reanchors the robot head by updating its position to its current world location.
```swift
@objc
func handleTap(recognizer: UITapGestureRecognizer) {
    guard let robotHeadPreview = headPreview, robotHeadPreview.isEnabled, robotHeadPreview.appearance == .tracked else {
        return
    }
    let headWorldTransform = robotHeadPreview.transformMatrix(relativeTo: nil)
    robotHeadPreview.anchor?.reanchor(.world(transform: headWorldTransform))
    robotHeadPreview.appearance = .anchored
    // ...
```

```
Setting the `headPreview` to `nil` prevents the app from updating the facial expression `session(didUpdate anchors:)`, which freezes that expression on the placed robot head.
```swift
self.headPreview = nil
```

When ARKit calls `session(didUpdate frame:)` again, the app checks whether a robot head preview exists, and creates one if not.
```
When ARKit calls `session(didUpdate frame:)` again, the app checks whether a robot head preview exists, and creates one if not.
```swift
func session(_ session: ARSession, didUpdate frame: ARFrame) {
    if headPreview == nil, case .normal = frame.camera.trackingState {
        addHeadPreview()
    }
```


## Configuration Objects
> https://developer.apple.com/documentation/arkit/configuration-objects

### 
#### 
#### 
#### 
In iOS 16, you can enable a 4K and high dynamic range (HDR) video format. In addition, you can customize your session’s video settings through the underlying AV capture device.
To determine whether your session supports 4K, call .
```swift
guard let hiResFormat = ARWorldTrackingConfiguration.recommendedVideoFormatFor4KResolution else {
   print("4K video format not supported."); return }
```

Then, create a configuration with the format. You can also indicate the intent to enable HDR by setting  to `true`.
```
Then, create a configuration with the format. You can also indicate the intent to enable HDR by setting  to `true`.
```swift
var config = ARWorldTrackingConfiguration()
config.videoFormat = hiResFormat
config.videoHDRAllowed = true
session.run(config)
```

```
If the device supports a configurable capture session, the  provides the underlying capture device that you can adjust as needed.
```swift
if let device = ARWorldTrackingConfiguration.configurableCaptureDeviceForPrimaryCamera {
   do { try device.lockForConfiguration()
      // Configure capture settings here.
      device.unlockForConfiguration()
   } catch { /* Error handling. */ }
}
```

#### 
In iOS 16, you can enable high-resolution frame capture by calling  on your configuration. If the device supports high-resolution stills, the function returns a video format you can use to start a session:
```swift
guard let hiResFormat = type(of: config).recommendedVideoFormatForHighResolutionFrameCapturing else {
    fatalError("The device doesn't support high-resolution stills.") }
config.videoFormat = hiResFormat
arSession.run(config)
```

```
During the session, capture a high-resolution still frame at any time by calling :
```swift
arSession.captureHighResolutionFrame { (frame, error) in
    if let frame = frame {
        saveHiResFrame(frame)
    } else { /* Error handling. */ }
```


## Creating a collaborative session
> https://developer.apple.com/documentation/arkit/creating-a-collaborative-session

### 
### 
Collaborative sessions are available when your session uses . To enable collaboration, set  to `true`.
Collaborative sessions are available when your session uses . To enable collaboration, set  to `true`.
```swift
configuration = ARWorldTrackingConfiguration()

// Enable a collaborative session.
configuration?.isCollaborationEnabled = true

// Enable realistic reflections.
configuration?.environmentTexturing = .automatic

// Begin the session.
arView.session.run(configuration!)
```

### 
When collaboration is enabled, ARKit periodically invokes , which provides collaboration data that you can share with nearby users. You are responsible for sending collaboration data over the network, including choosing the network framework and implementing the code. The data you send is a serialized version of the  object provided by your session. Before you send collaboration data over the network, first serialize it using [.
```swift
func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
    guard let multipeerSession = multipeerSession else { return }
    if !multipeerSession.connectedPeers.isEmpty {
        guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
        else { fatalError("Unexpectedly failed to encode collaboration data.") }
        // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
        let dataIsCritical = data.priority == .critical
        multipeerSession.sendToAllPeers(encodedData, reliably: dataIsCritical)
    } else {
        print("Deferred sending collaboration to later because there are no peers.")
    }
}
```

### 
You choose the network protocol with which to share collaboration data. This sample app sends collaboration data using .
```swift
func sendToPeers(_ data: Data, reliably: Bool, peers: [MCPeerID]) {
    guard !peers.isEmpty else { return }
    do {
        try session.send(data, toPeers: peers, with: reliably ? .reliable : .unreliable)
    } catch {
        print("error sending data to peers \(peers): \(error.localizedDescription)")
    }
}
```

### 
When you receive collaboration data from peer users, you instantiate an  object with it, and pass the object to your session via .
```swift
func receivedData(_ data: Data, from peer: MCPeerID) {
    if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
        arView.session.update(with: collaborationData)
        return
    }
    // ...
```

### 
For ARKit to know where two users are with respect to each other, it has to recognize overlap across their respective world maps. When ARKit succeeds in fitting the two world maps together, it can begin sharing those users’ respective locations and any anchors they created with each other.
To aid ARKit with world map merging, a user must point their device near an area that another user has viewed. The sample app accomplishes this by asking the users to hold their devices side by side.
```swift
messageLabel.displayMessage("""
    A peer wants to join the experience.
    Hold the phones next to each other.
    """, duration: 6.0)
```

### 
The first time ARKit successfully merges world data from another user, it calls your app’s , passing in an  that identifies the other user. This action notifies you of the merging event.
```swift
func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    for anchor in anchors {
        if let participantAnchor = anchor as? ARParticipantAnchor {
            messageLabel.displayMessage("Established joint experience with a peer.")
            // ...
```

### 
When ARKit successfully merges two users’ world data, you can then initiate actions to begin the multiuser experience. The sample adds virtual content in the real-world location of newly joined peer users to visualize them in AR.
```swift
let anchorEntity = AnchorEntity(anchor: participantAnchor)

let coordinateSystem = MeshResource.generateCoordinateSystemAxes()
anchorEntity.addChild(coordinateSystem)

let color = participantAnchor.sessionIdentifier?.toRandomColor() ?? .white
let coloredSphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.03),
                                materials: [SimpleMaterial(color: color, isMetallic: true)])
anchorEntity.addChild(coloredSphere)

arView.scene.addAnchor(anchorEntity)
```

### 
### 
To distinguish virtual content by user, you choose a different color for each user. The sample app uses the `toRandomColor` function to assign user colors.
```swift
let color = anchor.sessionIdentifier?.toRandomColor() ?? .white
```

```
The random color function works by applying a modulo operation to the anchor’s session ID, and interpreting the result as an index into a color array.
```swift
func toRandomColor() -> UIColor {
    var firstFourUUIDBytesAsUInt32: UInt32 = 0
    let data = withUnsafePointer(to: self) {
        return Data(bytes: $0, count: MemoryLayout.size(ofValue: self))
    }
    _ = withUnsafeMutableBytes(of: &firstFourUUIDBytesAsUInt32, { data.copyBytes(to: $0) })

    let colors: [UIColor] = [.red, .green, .blue, .yellow, .magenta, .cyan, .purple,
    .orange, .brown, .lightGray, .gray, .darkGray, .black, .white]
    
    let randomNumber = Int(firstFourUUIDBytesAsUInt32) % colors.count
    return colors[randomNumber]
}
```

### 
When ARKit notifies you of a new nonparticipant anchor in , place a block geometry tinted with the color calculated in the previous section.
```swift
let coloredCube = ModelEntity(mesh: MeshResource.generateBox(size: boxLength),
                              materials: [SimpleMaterial(color: color, isMetallic: true)])
// Offset the cube by half its length to align its bottom with the real-world surface.
coloredCube.position = [0, boxLength / 2, 0]

// Attach the cube to the ARAnchor via an AnchorEntity.
//   World origin -> ARAnchor -> AnchorEntity -> ModelEntity
let anchorEntity = AnchorEntity(anchor: anchor)
anchorEntity.addChild(coloredCube)
arView.scene.addAnchor(anchorEntity)
```


## Creating a fog effect using scene depth
> https://developer.apple.com/documentation/arkit/creating-a-fog-effect-using-scene-depth

### 
### 
In order to avoid running an unsupported configuration, the sample app first checks whether the device supports scene depth.
```swift
if !ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) ||
    !ARWorldTrackingConfiguration.supportsFrameSemantics(.smoothedSceneDepth) {
    // Ensure that the device supports scene depth and present
    //  an error-message view controller, if not.
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "unsupportedDeviceMessage")
}
```

If the device supports scene depth, the sample app creates a world-tracking configuration and enables the  option on the uct`` property.
If the device running the app doesn’t support scene depth, the sample project will stop. Optionally, the app could present the user with an error message and continue the experience without scene depth.
If the device supports scene depth, the sample app creates a world-tracking configuration and enables the  option on the uct`` property.
```swift
configuration.frameSemantics = .smoothedSceneDepth
```

```
Then, the sample project begins the AR experience by running the session.
```swift
session.run(configuration)
```

### 
ARKit exposes the depth buffer documentation/arkit/ardepthdata/depthmap) as a  on the current frame’s  or  property, depending on the enabled frame semantics. This sample app visualizes  by default. The raw depth values in  can create a flicker whereas smoothing the depth differences across frames visualizes a more realistic fog effect. For debug purposes, the sample allows switching between  and  with an onscreen toggle.
```swift
guard let sceneDepth = frame.smoothedSceneDepth ?? frame.sceneDepth else {
    print("Failed to acquire scene depth.")
    return
}
var pixelBuffer: CVPixelBuffer!
pixelBuffer = sceneDepth.depthMap
```

```
Every pixel in the depth buffer maps to a region of the visible scene, which defines that region’s distance from the device in meters. Because the sample project draws to the screen using Metal, it converts the pixel buffer to a Metal texture as required to transfer the depth data to the GPU for rendering.
```swift
var texturePixelFormat: MTLPixelFormat!
setMTLPixelFormat(&texturePixelFormat, basedOn: pixelBuffer)
depthTexture = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat: texturePixelFormat, planeIndex: 0)
```

```
To set the depth texture’s Metal pixel format, the sample project calls  with the  and chooses an appropriate mapping based on the result.
```swift
fileprivate func setMTLPixelFormat(_ texturePixelFormat: inout MTLPixelFormat?, basedOn pixelBuffer: CVPixelBuffer!) {
    if CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_DepthFloat32 {
        texturePixelFormat = .r32Float
    } else if CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_OneComponent8 {
        texturePixelFormat = .r8Uint
    } else {
        fatalError("Unsupported ARDepthData pixel-buffer format.")
    }
}
```

### 
As a benefit of rendering its graphics with Metal, this app has at its disposal the display conveniences of MPS. The sample project uses the MPS Gaussian Blur filter to make realistic fog. When instantiating the filter, the sample project passes a `sigma` of `5` to specify a 5-pixel radius blur.
```swift
blurFilter = MPSImageGaussianBlur(device: device, sigma: 5)
```

MPS requires input and output images that define the source and destination pixel data for the filter operation.
```swift
let inputImage = MPSImage(texture: depthTexture, featureChannels: 1)
let outputImage = MPSImage(texture: filteredDepthTexture, featureChannels: 1)
```

The sample app passes the input and output images to the blur’s `encode` function, which schedules the blur to happen on the GPU.
```
The sample app passes the input and output images to the blur’s `encode` function, which schedules the blur to happen on the GPU.
```swift
blur.encode(commandBuffer: commandBuffer, sourceImage: inputImage, destinationImage: outputImage)
```

### 
Metal renders by providing to the GPU a fragment shader that draws the app’s graphics. Since the sample project renders a camera image, it packages up the camera image for the fragment shader by calling `setFragmentTexture`.
```swift
renderEncoder.setFragmentTexture(CVMetalTextureGetTexture(cameraImageY), index: 0)
renderEncoder.setFragmentTexture(CVMetalTextureGetTexture(cameraImageCbCr), index: 1)
```

```
Next, the sample app packages up the filtered depth texture.
```swift
renderEncoder.setFragmentTexture(filteredDepthTexture, index: 2)
```

```
The sample project’s GPU-side code fields the texture arguments in the order of the `index` argument. For example, the fragment shader fields the texture with index `0` above as the argument containing the suffix `texture(0)`, as shown in the example below.
```cpp
fragment half4 fogFragmentShader(FogColorInOut in [[ stage_in ]],
texture2d<float, access::sample> cameraImageTextureY [[ texture(0) ]],
texture2d<float, access::sample> cameraImageTextureCbCr [[ texture(1) ]],
depth2d<float, access::sample> arDepthTexture [[ texture(2) ]],
```

```
To output a rendering, Metal calls the fragment shader once for every pixel it draws to the destination. The sample project’s fragment shader begins by reading the RGB value of the current pixel in the camera image. The object “`s`” is a `sampler`, which enables the shader to inspect a texture at a specific location. The value `in.texCoordCamera` refers to this pixel’s relative location within the camera image.
```cpp
constexpr sampler s(address::clamp_to_edge, filter::linear);

// Sample this pixel's camera image color.
float4 rgb = ycbcrToRGBTransform(
    cameraImageTextureY.sample(s, in.texCoordCamera),
    cameraImageTextureCbCr.sample(s, in.texCoordCamera)
);
half4 cameraColor = half4(rgb);
```

```
By sampling the depth texture at `in.texCoordCamera`, the shader queries for depth at the same relative location that it did for the camera image, and obtains the current pixel’s distance in meters from the device.
```cpp
float depth = arDepthTexture.sample(s, in.texCoordCamera);
```

```
To determine the amount of fog that covers this pixel, the sample app calculates a fraction using the current pixel’s distance divided by the distance at which the fog effect fully saturates the scene.
```cpp
float fogPercentage = depth / fogMax;
```

```
The `mix` function mixes two colors based on a percentage. The sample project passes in the RGB values, fog color, and fog percentage to create the right amount of fog for the current pixel.
```cpp
half4 foggedColor = mix(cameraColor, fogColor, fogPercentage);
```

### 
ARKit provides the  property within  to measure the accuracy of the corresponding depth data . Although this sample project doesn’t factor depth confidence into its fog effect, confidence data could filter out lower-accuracy depth values if the app’s algorithm required it.
To provide a sense for depth confidence, this sample app visualizes confidence data at runtime using the `confidenceDebugVisualizationEnabled` in the `Shaders.metal` file.
```swift
// Set to `true` to visualize confidence.
bool confidenceDebugVisualizationEnabled = false;
```

```
When the renderer accesses the current frame’s scene depth, the sample project creates a Metal texture of the  to draw it on the GPU.
```swift
pixelBuffer = sceneDepth.confidenceMap
setMTLPixelFormat(&texturePixelFormat, basedOn: pixelBuffer)
confidenceTexture = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat: texturePixelFormat, planeIndex: 0)
```

While the renderer schedules its drawing, the sample project packages up the confidence texture for the GPU by calling `setFragmentTexture`.
```
While the renderer schedules its drawing, the sample project packages up the confidence texture for the GPU by calling `setFragmentTexture`.
```swift
renderEncoder.setFragmentTexture(CVMetalTextureGetTexture(confidenceTexture), index: 3)
```

```
The GPU-side code fields confidence data as the fragment shader’s third texture argument.
```cpp
texture2d<uint> arDepthConfidence [[ texture(3) ]])
```

```
To access the confidence value of the current pixel’s depth, the fragment shader samples the confidence texture at `in.texCoordCamera`. Each confidence value in this texture is a `uint` equivalent of its corresponding case in the  enum.
```cpp
uint confidence = arDepthConfidence.sample(s, in.texCoordCamera).x;
```

```
Based on the confidence value at the current pixel, the fragment shader creates a normalized percentage of the confidence color to overlay.
```cpp
float confidencePercentage = (float)confidence / (float)maxConfidence;
```

The sample project calls the `mix` function to blend the confidence color into the processed pixel based on the confidence percentage.
```
The sample project calls the `mix` function to blend the confidence color into the processed pixel based on the confidence percentage.
```cpp
return mix(confidenceColor, foggedColor, confidencePercentage);
```


## Creating a multiuser AR experience
> https://developer.apple.com/documentation/arkit/creating-a-multiuser-ar-experience

### 
### 
### 
### 
The sample `MultipeerSession` class provides a simple abstraction around the  features this app uses. After the main view controller creates a `MultipeerSession` instance (at app launch), it starts running an  to broadcast the device’s ability to join multipeer sessions and an  to find other devices:
```swift
session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
session.delegate = self

serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: MultipeerSession.serviceType)
serviceAdvertiser.delegate = self
serviceAdvertiser.startAdvertisingPeer()

serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MultipeerSession.serviceType)
serviceBrowser.delegate = self
serviceBrowser.startBrowsingForPeers()
```

```
When the  finds another device, it calls the  delegate method. To invite that other device to a shared session, call the browser’s  method:
```swift
public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
    // Invite the new peer to the session.
    browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
}
```

When the other device receives that invitation,  calls the  delegate method. To accept the invitation, call the provided `invitationHandler`:
```
When the other device receives that invitation,  calls the  delegate method. To accept the invitation, call the provided `invitationHandler`:
```swift
func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                didReceiveInvitationFromPeer peerID: MCPeerID,
                withContext context: Data?,
                invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    // Call handler to accept invitation and join the session.
    invitationHandler(true, self.session)
}
```

### 
An  object contains a snapshot of all the spatial mapping information that ARKit uses to locate the user’s device in real-world space. Reliably sharing a map to another device requires two key steps: finding a good time to capture a map, and capturing and sending it.
ARKit provides a  value that indicates whether it’s currently a good time to capture a world map (or if it’s better to wait until ARKit has mapped more of the local environment). This app uses that value to provide visual feedback on its Send World Map button:
```swift
switch frame.worldMappingStatus {
case .notAvailable, .limited:
    sendMapButton.isEnabled = false
case .extending:
    sendMapButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
case .mapped:
    sendMapButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
@unknown default:
    sendMapButton.isEnabled = false
}
mappingStatusLabel.text = frame.worldMappingStatus.description
```

```
When the user taps the Send World Map button, the app calls  to capture the map from the running ARSession, then serializes it to a  object with  and sends it to other devices in the multipeer session:
```swift
sceneView.session.getCurrentWorldMap { worldMap, error in
    guard let map = worldMap
        else { print("Error: \(error!.localizedDescription)"); return }
    guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
        else { fatalError("can't encode map") }
    self.multipeerSession.sendToAllPeers(data)
}
```

### 
When a device receives data sent by another participant in the multipeer session, the delegate method provides that data. To make use of it, the app uses  to deserialize an  object, then creates and runs a new  using that map as the :
```swift
if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
    // Run the session with the received world map.
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    configuration.initialWorldMap = worldMap
    sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    
    // Remember who provided the map for showing UI feedback.
    mapProvider = peer
}
```

### 
To create an ongoing shared AR experience, where each user’s actions affect the AR scene visible to other users, after each device relocalizes to the same world map you should share only the information needed to recreate each user action. For example, in this app the user can tap to place a virtual 3D character in the scene. That character is static, so all that is needed to place the character on another participating device is the character’s position and orientation in world space.
This app communicates virtual character positions by sharing  objects between peers. When one user taps in the scene, the app creates an anchor and adds it to the local , then serializes that  using  and sends it to other devices in the multipeer session:
```swift
// Place an anchor for a virtual character. The model appears in renderer(_:didAdd:for:).
let anchor = ARAnchor(name: "panda", transform: hitTestResult.worldTransform)
sceneView.session.add(anchor: anchor)

// Send the anchor info to peers, so they can place the same content.
guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
    else { fatalError("can't encode anchor") }
self.multipeerSession.sendToAllPeers(data)
```

```
When other peers receive data from the multipeer session, they test for whether that data contains an archived ; if so, they decode it and add it to their session:
```swift
if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
    // Add anchor to the session, ARSCNView delegate adds visible content.
    sceneView.session.add(anchor: anchor)
}
```


## Creating an immersive ar experience with audio
> https://developer.apple.com/documentation/arkit/creating-an-immersive-ar-experience-with-audio

### 
### 
- This sample code supports `Relocalization` and therefore, it requires ARKit 1.5 (iOS 11.3) or greater
### 
### 
To play audio from a given position in 3D space, create an  from an audio file. This sample loads the file from the bundle in `viewDidLoad`:
To play audio from a given position in 3D space, create an  from an audio file. This sample loads the file from the bundle in `viewDidLoad`:
```swift
// As an environmental sound layer, audio should play indefinitely
audioSource.loops = true
// Decode the audio from disk ahead of time to prevent a delay in playback
audioSource.load()
```

```
Then, the audio source is configured and prepared:
```swift
// As an environmental sound layer, audio should play indefinitely
audioSource.loops = true
// Decode the audio from disk ahead of time to prevent a delay in playback
audioSource.load()
```

```
When you’re ready to play the sound, create an , passing it the audio source:
```swift
// Create a player from the source and add it to `objectNode`
objectNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
```


## Creating screen annotations for objects in an AR experience
> https://developer.apple.com/documentation/arkit/creating-screen-annotations-for-objects-in-an-ar-experience

### 
### 
To annotate an object in an AR experience, you first determine where it is in the physical environment. This sample app enables the user to tap the screen to place a sticky note by first adding a tap gesture recognizer to the view.
```swift
func arViewGestureSetup() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnARView))
    arView.addGestureRecognizer(tapGesture)
    
    let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedDownOnARView))
    swipeGesture.direction = .down
    arView.addGestureRecognizer(swipeGesture)
}
```

```
When the input handler is called, you read the tap screen coordinates by calling .
```swift
let touchLocation = sender.location(in: arView)
```

```
To get a 3D world position that corresponds to the tap location, cast a ray from the camera’s origin through the touch location to check for intersection with any real-world surfaces along that ray.
```swift
guard let raycastResult = arView.raycast(from: touchLocation, allowing: .estimatedPlane, alignment: .any).first else {
    messageLabel.displayMessage("No surface detected, try getting closer.", duration: 2.0)
    return
}
```

### 
To keep track of a real-world location, you create an anchor positioned there. RealityKit implements an anchor as an  conforming to . Thus, you implement those protocols when designing a sticky note in RealityKit.
```swift
class StickyNoteEntity: Entity, HasAnchoring, HasScreenSpaceView {
    // ...
```

```
Create the entity by calling its initializer and passing in the ray-cast result’s .
```swift
let note = StickyNoteEntity(frame: frame, worldTransform: raycastResult.worldTransform)
```

In the sticky note entity’s `init` function, position the entity at the tap location by setting its transformation matrix to the argument .
```
In the sticky note entity’s `init` function, position the entity at the tap location by setting its transformation matrix to the argument .
```swift
init(frame: CGRect, worldTransform: simd_float4x4) {
    super.init()
    self.transform.matrix = worldTransform
    // ...
```

```
Let RealityKit know about your entity by adding it to the scene hierarchy. RealityKit then registers an  for your entity with ARKit.
```swift
// Add the sticky note to the scene's entity hierarchy.
arView.scene.addAnchor(note)
```

### 
For the purposes of this sample app, the sticky note entity has no geometry and thus, no appearance. Its anchor provides a 3D location only, and it’s the sticky note’s screen-space annotation that has an appearance. To display it, you define the sticky note’s annotation. Following RealityKit’s entity-component model, design a component that houses the annotation, which in this case is a view. See `ScreenSpaceComponent.swift`.
```swift
struct ScreenSpaceComponent: Component {
    var view: StickyNoteView?
    //...
```

```
As a prepackaged UI element that renders text for you,  is useful as a screen-space annotation.
```swift
class StickyNoteView: UIView {
    var textView: UITextView!
    // ...
```

```
Expose the screen-space component in its own protocol.
```swift
protocol HasScreenSpaceView: Entity {
    var screenSpaceComponent: ScreenSpaceComponent { get set }
}
```

Implement the protocol in your entity; see `StickyNoteEntity.swift`.
```
Implement the protocol in your entity; see `StickyNoteEntity.swift`.
```swift
class StickyNoteEntity: Entity, HasAnchoring, HasScreenSpaceView {
    // ...
```

```
To display the entity’s annotation, add the sticky-note view to the view hierarchy.
```swift
// Add the sticky note's view to the view hierarchy.
guard let stickyView = note.view else { return }
arView.insertSubview(stickyView, belowSubview: trashZone)
```

```
To put the annotation in the right place on the screen, ask the  to convert its entity’s world location to a 2D screen point.
```swift
guard let projectedPoint = arView.project(note.position) else { return }
```

```
To enhance visual accuracy, center the note’s view around the anchor’s projected world location.
```swift
setPositionCenter(projectedPoint)
```

```
To do that, calculate the midpoint and set the view’s origin.
```swift
view.frame.origin = CGPoint(x: centerPoint.x, y: centerPoint.y)
```

### 
Because users move their device during an AR experience, the annotation’s screen position quickly becomes out of sync with its anchor’s world position. To keep the annotation’s screen position accurate, call ‘s `project` function every frame, updating the annotation’s position with the result.
```swift
// Updates the screen position of the note based on its visibility
note.projection = Projection(projectedPoint: projectedPoint, isVisible: isVisible)
note.updateScreenPosition()
```

### 
A benefit of using  types for screen annotations is that they simplify user interaction. The sample implements sticky notes using , which enables users to more easily edit their text. The sample implements minimal gesture recognizer code to manage sticky notes.
The following code enables the capability to create a note by tapping the screen.
```swift
@objc
func tappedOnARView(_ sender: UITapGestureRecognizer) {
    
    // Ignore the tap if the user is editing a sticky note.
    for note in stickyNotes where note.isEditing { return }
    
    // Create a new sticky note at the tap location.
    insertNewSticky(sender)
}
```

```
By implementing its own tap gesture recognizer to control editing,   enables the user to tap an existing note to edit its text. To be notified when the user edits a note, override ’s `textViewDidBeginEditing(_ textView:)` delegate callback.
```swift
extension ViewController: UITextViewDelegate {
    
    // - Tag: TextViewDidBeginEditing
    func textViewDidBeginEditing(_ textView: UITextView) {

        // Get the main view for this sticky note.
        guard let stickyView = textView.firstSuperViewOfType(StickyNoteView.self) else { return }
        // ...

```

```
The following code enables the capability to move a note by panning the screen.
```swift
@objc
func panOnStickyView(_ sender: UIPanGestureRecognizer) {
    
    guard let stickyView = sender.view as? StickyNoteView else { return }
    
    let panLocation = sender.location(in: arView)
    
    // Ignore the pan if any StickyViews are being edited.
    for note in stickyNotes where note.isEditing { return }
    
    panStickyNote(sender, stickyView, panLocation)
}
```

```
When the user pans to reposition a sticky note, you convert the screen touch location to a 3D world position using . The user can then reposition the sticky note’s anchor in the real world versus simply moving the annotation to a new arbitrary screen location. If a ray cast from the final screen location in the pan gesture doesn’t produce an intersection with a 3D world location, don’t move the sticky note there.
```swift
fileprivate func attemptRepositioning(_ stickyView: StickyNoteView) {
    // Conducts a ray-cast for feature points using the panned position of the StickyNoteView
    let point = CGPoint(x: stickyView.frame.midX, y: stickyView.frame.midY)
    if let result = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .any).first {
        stickyView.stickyNote.transform.matrix = result.worldTransform
    } else {
        messageLabel.displayMessage("No surface detected, unable to reposition note.", duration: 2.0)
        stickyView.stickyNote.shouldAnimate = true
    }
}
```

```
The following portion of the pan gesture handler enables the capability to remove a sticky note when the user drags it to the text that says “delete” at the top of the screen.
```swift
if stickyView.isInTrashZone {
    deleteStickyNote(stickyView.stickyNote)
    // ...
```

### 
Keeping screen-space annotations to a minimum will maximize the user’s immersion in the AR experience. The sample app makes sticky notes small when the user isn’t editing text, minimizing distractions so they can focus on the real-world environment. But for similar reasons, you should enlarge a sticky note when the user is editing text. To create a seamless transition between editing and nonediting states, animate the sticky note’s size instead of changing it abruptly. See the   `animateStickyViewToEditingFrame` function.
```swift
func animateStickyViewToEditingFrame(_ stickyView: StickyNoteView, keyboardHeight: Double) {
    let safeFrame = view.safeAreaLayoutGuide.layoutFrame
    let height = safeFrame.height - keyboardHeight
    let inset = height * 0.05
    let editingFrame = CGRect(origin: safeFrame.origin, size: CGSize(width: safeFrame.width, height: height)).insetBy(dx: inset, dy: inset)
    UIViewPropertyAnimator(duration: 0.2, curve: .easeIn) {
        stickyView.frame = editingFrame
        //...
```

```
Bring even more focus to the editing experience by dimming the background and by lighting the sticky note that the user is editing.
```swift
stickyView.blurView.effect = UIBlurEffect(style: .light)
```

```
To prevent the user from losing track of a sticky note’s real-world location, animate the note smoothly from one position to the next. For example, if an annotation fails to reposition, animate the sticky note back to its original screen position. This increases the user’s ability to track the annotation if they want to try moving it again.
```swift
if shouldAnimate {
    animateTo(projectedPoint)
    // ...
```

```
To animate the note’s movement, you continually set its location using a .
```swift
func animateTo(_ point: CGPoint) {

    let animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear) {
        self.setPositionCenter(point)
    }
    // ...
```


## Detecting Images in an AR Experience
> https://developer.apple.com/documentation/arkit/detecting-images-in-an-ar-experience

### 
#### 
3. Use the  method to run a session with your configuration.
The code below shows how the sample app performs these steps when starting or restarting the AR experience.
```swift
guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", 
                                                             bundle: nil) else {
    fatalError("Missing expected asset catalog resources.")
}

let configuration = ARWorldTrackingConfiguration()
configuration.detectionImages = referenceImages
session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
```

#### 
When ARKit detects one of your reference images, the session automatically adds a corresponding  to its list of anchors. To respond to an image being detected, implement an appropriate , , or  method that reports the new anchor being added to the session. (This example app uses the  method for the code shown below.)
To use the detected image as a trigger for AR content, you’ll need to know its position and orientation, its size, and which reference image it is. The anchor’s inherited  property provides position and orientation, and its  property tells you which  object was detected. If your AR content depends on the extent of the image in the scene, you can then use the reference image’s  to set up your content, as shown in the code below.
```swift
func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let imageAnchor = anchor as? ARImageAnchor else { return }
    let referenceImage = imageAnchor.referenceImage
    updateQueue.async {
        
        // Create a plane to visualize the initial position of the detected image.
        let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                height: referenceImage.physicalSize.height)
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 0.25
        
        /*
            `SCNPlane` is vertically oriented in its local coordinate space, but
            `ARImageAnchor` assumes the image is horizontal in its local space, so
            rotate the plane to match.
            */
        planeNode.eulerAngles.x = -.pi / 2
        
        /*
            Image anchors are not tracked after initial detection, so create an
            animation that limits the duration for which the plane visualization appears.
            */
        planeNode.runAction(self.imageHighlightAction)
        
        // Add the plane visualization to the scene.
        node.addChildNode(planeNode)
    }
        DispatchQueue.main.async {
        let imageName = referenceImage.name ?? ""
        self.statusViewController.cancelAllScheduledMessages()
        self.statusViewController.showMessage("Detected image “\(imageName)”")
    }
}
```

#### 
#### 

## Displaying a point cloud using scene depth
> https://developer.apple.com/documentation/arkit/displaying-a-point-cloud-using-scene-depth

### 
### 
To display a camera feed, the sample project defines a SwiftUI  whose  contains a single window. To abstract view code from window code, the sample project wraps all of its display in a single  called `MetalDepthView`.
```swift
@main
struct PointCloudDepthSample: App {
    var body: some Scene {
        WindowGroup {
            MetalDepthView()
```

```
Because Depth Cloud draws graphics using Metal, the sample project displays the camera feed by defining custom GPU code. The sample project accesses ARKit’s camera feed in its `ARReceiver.swift` file and wraps it in a custom `ARData` object for eventual transfer to the GPU.
```swift
arData.colorImage = frame.capturedImage
```

### 
Devices require the LiDAR Scanner to access the scene’s depth. In the depth-visualization view’s  definition, the app prevents running an unsupported configuration by checking if the device supports scene depth.
```swift
if !ARWorldTrackingConfiguration.supportsFrameSemantics([.sceneDepth, .smoothedSceneDepth]) {
    Text("Unsupported Device: This app requires the LiDAR Scanner to access the scene's depth.")
```

To separate data acquisition from its display, the sample app wraps ARKit calls in its `ARProvider` class.
```
To separate data acquisition from its display, the sample app wraps ARKit calls in its `ARProvider` class.
```swift
var arProvider: ARProvider = ARProvider()
```

```
The AR provider runs a world-tracking configuration and requests information about the scene’s depth by configuring the scene-depth frame semantics (see . and ).
```swift
let config = ARWorldTrackingConfiguration()
config.frameSemantics = [.sceneDepth, .smoothedSceneDepth]
arSession.run(config)
```

### 
In response to the configuration’s scene-depth frame semantics, the framework defines the frame’s  properties of  and . on the session’s .
```swift
func session(_ session: ARSession, didUpdate frame: ARFrame) {
    if(frame.sceneDepth != nil) && (frame.smoothedSceneDepth != nil) {
        arData.depthImage = frame.sceneDepth?.depthMap
        arData.depthSmoothImage = frame.smoothedSceneDepth?.depthMap
```

Because the sample project draws its graphics using Metal, the app’s CPU code bundles up data that its GPU code needs to display the experience. To model the physical environment with a point cloud, the app needs camera capture data to color each point and depth data to position them.
The sample project positions each point in GPU code, so the CPU side packages the depth data in a Metal texture for use on the GPU.
```swift
depthContent.texture = lastArData?.depthImage?.texture(withFormat: .r32Float, planeIndex: 0, addToCache: textureCache!)!
```

```
The sample project colors each point in GPU code, so the CPU side packages the camera data for use on the GPU.
```swift
colorYContent.texture = lastArData?.colorImage?.texture(withFormat: .r8Unorm,
                                                        planeIndex: 0,
                                                        addToCache: textureCache!)!
colorCbCrContent.texture = lastArData?.colorImage?.texture(withFormat: .rg8Unorm,
                                                           planeIndex: 1,
                                                           addToCache: textureCache!)!
```

### 
In the `pointCloudVertexShader` function (see the sample project’s `shaders.metal` file), the sample project creates a point for every value in the depth texture and determines the point’s color by sampling that depth-texture value’s position in the camera image. Each vertex calculates its `x` and `y` location in the camera image by converting its position in the one-dimensional vertex array, to a 2D position in the depth texture.
```swift
uint2 pos;
// Count the rows that are depth-texture-width wide to determine the y-value.
pos.y = vertexID / depthTexture.get_width();

// The x-position is the remainder of the y-value division.
pos.x = vertexID % depthTexture.get_width();
```

```
The system’s camera-capture pipeline represents data in YUV format, which the sample project models using a luminance map (`colorYtexture`) and a blue versus red chromaticity map (`colorCbCrtexture`). The GPU color format is RGBA, which requires the sample project to convert the camera data to display it. The shader samples the luminance and chromaticity textures at the vertex’s `x,` `y` position and applies a static conversion factor.
```swift
constexpr sampler textureSampler (mag_filter::linear,
                                  min_filter::linear);
out.coor = { pos.x / (depthTexture.get_width() - 1.0f), pos.y / (depthTexture.get_height() - 1.0f) };
half y = colorYtexture.sample(textureSampler, out.coor).r;
half2 uv = colorCbCrtexture.sample(textureSampler, out.coor).rg - half2(0.5h, 0.5h);
// Convert YUV to RGB inline.
half4 rgbaResult = half4(y + 1.402h * uv.y, y - 0.7141h * uv.y - 0.3441h * uv.x, y + 1.772h * uv.x, 1.0h);
```

### 
To display a camera feed by using a point cloud, the project defines a  object, `MetalPointCloud`, which contains an  that displays Metal content.
To display a camera feed by using a point cloud, the project defines a  object, `MetalPointCloud`, which contains an  that displays Metal content.
```swift
struct MetalPointCloud: UIViewRepresentable {
```

The project inserts the point cloud view into the view hierarchy by embedding it within the `MetalDepthView` layout.
```
The project inserts the point cloud view into the view hierarchy by embedding it within the `MetalDepthView` layout.
```swift
HStack() {
    Spacer()
    MetalPointCloud(arData: arProvider,
                    confSelection: $selectedConfidence,
                    scaleMovement: $scaleMovement).zoomOnTapModifier(
                        height: geometry.size.width / 2 / sizeW * sizeH,
                        width: geometry.size.width / 2, title: "")
```

As representable of , the Metal texture view defines a coordinator, `CoordinatorPointCloud`.
```
As representable of , the Metal texture view defines a coordinator, `CoordinatorPointCloud`.
```swift
func makeCoordinator() -> CoordinatorPointCloud {
    return CoordinatorPointCloud(arData: arData, confSelection: $confSelection, scaleMovement: $scaleMovement)
}
```

The point cloud coordinator extends `MTKCoordinator`, which the sample shares across its other views that display Metal content.
```
The point cloud coordinator extends `MTKCoordinator`, which the sample shares across its other views that display Metal content.
```swift
final class CoordinatorPointCloud: MTKCoordinator {
```

As an , `MTKCoordinator` handles relevant events that occur throughout the Metal view life cycle.
```
As an , `MTKCoordinator` handles relevant events that occur throughout the Metal view life cycle.
```swift
class MTKCoordinator: NSObject, MTKViewDelegate {
```

In the `UIView` representable’s `makeUIView` implementation, the sample project assigns the coordinator as the view’s delegate.
```
In the `UIView` representable’s `makeUIView` implementation, the sample project assigns the coordinator as the view’s delegate.
```swift
func makeUIView(context: UIViewRepresentableContext<MetalPointCloud>) -> MTKView {
    let mtkView = MTKView()
    mtkView.delegate = context.coordinator
```

```
At runtime, the display link then calls the Metal coordinator’s  implementation to issue CPU-side rendering commands.
```swift
override func draw(in view: MTKView) {
    content = arData.depthContent
    let confidence = (arData.isToUpsampleDepth) ? arData.upscaledConfidence:arData.confidenceContent
    guard arData.lastArData != nil else {
```

### 
The sample project draws the point cloud on the GPU. The point cloud view packages up several textures that its corresponding GPU code requires as input.
```swift
encoder.setVertexTexture(content.texture, index: 0)
encoder.setVertexTexture(confidence.texture, index: 1)
encoder.setVertexTexture(arData.colorYContent.texture, index: 2)
encoder.setVertexTexture(arData.colorCbCrContent.texture, index: 3)
```

```
Similarly, the point cloud view packages up several calculated properties that its corresponding GPU code requires as input.
```swift
encoder.setVertexBytes(&pmv, length: MemoryLayout<matrix_float4x4>.stride, index: 0)
encoder.setVertexBytes(&cameraIntrinsics, length: MemoryLayout<matrix_float3x3>.stride, index: 1)
encoder.setVertexBytes(&confSelection, length: MemoryLayout<Int>.stride, index: 2)
```

```
To call into the GPU functions that draw the point cloud, the sample defines a pipeline state that queues up its `pointCloudVertexShader` and `pointCloudFragmentShader` Metal functions (see the project’s `shaders.metal` file).
```swift
pipelineDescriptor.vertexFunction = library.makeFunction(name: "pointCloudVertexShader")
pipelineDescriptor.fragmentFunction = library.makeFunction(name: "pointCloudFragmentShader")
```

```
On the GPU, the point cloud vertex shader determines each point’s color and position on the screen. In the function signature, the vertex shader receives the input textures and properties sent by the CPU code.
```cpp
vertex ParticleVertexInOut pointCloudVertexShader(
    uint vertexID [[ vertex_id ]],
    texture2d<float, access::read> depthTexture [[ texture(0) ]],
    texture2d<float, access::read> confTexture [[ texture(1) ]],
    constant float4x4& viewMatrix [[ buffer(0) ]],
    constant float3x3& cameraIntrinsics [[ buffer(1) ]],
    constant int &confFilterMode [[ buffer(2) ]],
    texture2d<half> colorYtexture [[ texture(2) ]],
    texture2d<half> colorCbCrtexture [[ texture(3) ]]
    )
{ // ...
```

```
The code bases the point’s world position on its location and depth in the camera feed.
```cpp
float xrw = ((int)pos.x - cameraIntrinsics[2][0]) * depth / cameraIntrinsics[0][0];
float yrw = ((int)pos.y - cameraIntrinsics[2][1]) * depth / cameraIntrinsics[1][1];
float4 xyzw = { xrw, yrw, depth, 1.f };
```

```
The point’s screen position is a product of its world position and the argument projection matrix.
```cpp
float4 vecout = viewMatrix * xyzw;
```

```
The vertex function outputs the point’s screen position, along with the point’s color as a converted RGB result.
```cpp
out.color = rgbaResult;
out.clipSpacePosition = vecout;
```

```
The fragment shader receives the vertex function output in its function signature.
```cpp
fragment half4 pointCloudFragmentShader(
    ParticleVertexInOut in [[stage_in]])
```

```
After filtering any points that are too close to the device’s camera, the fragment shader queues the remaining points for display by returning the color of each vertex.
```cpp
if (in.depth < 1.0f)
    discard_fragment();
else
{
    return in.color;
```

### 
The point cloud’s screen position is a factor of its projection matrix. In the sample project’s `calcCurrentPMVMatrix` function (see `MetalPointCloud.swift`), the function sets up a basic matrix.
```swift
func calcCurrentPMVMatrix(viewSize: CGSize) -> matrix_float4x4 {
    let projection: matrix_float4x4 = makePerspectiveMatrixProjection(fovyRadians: Float.pi / 2.0,
                                                                      aspect: Float(viewSize.width) / Float(viewSize.height),
                                                                      nearZ: 10.0, farZ: 8000.0)
```

```
To adjust the point cloud’s orientation with respect to the user, the sample app conversely sets up translation and rotation offsets for the camera’s pose.
```swift
// Randomize the camera scale.
translationCamera.columns.3 = [150 * sinf, -150 * cossqr, -150 * scaleMovement * sinsqr, 1]
// Randomize the camera movement.
cameraRotation = simd_quatf(angle: staticAngle, axis: SIMD3(x: -sinsqr / 3, y: -cossqr / 3, z: 0))
```

```
The sample project applies the camera pose offset to the original projection matrix before returning the adjusted result.
```swift
let rotationMatrix: matrix_float4x4 = matrix_float4x4(cameraRotation)
let pmv = projection * rotationMatrix * translationCamera * translationOrig * orientationOrig
return pmv
//#-end-code-li
```

### 
The sample project uses MPS to enlarge the depth buffer; see the `ARDataProvider.swift` file. The `ARProvider` class initializer creates a guided filter to enlarge the depth buffer.
```swift
guidedFilter = MPSImageGuidedFilter(device: metalDevice, kernelDiameter: guidedFilterKernelDiameter)
```

```
To align the sizes of the related visuals — the camera image and confidence texture — the AR provider uses an MPS bilinear scale filter.
```swift
mpsScaleFilter = MPSImageBilinearScale(device: metalDevice)
```

In the `processLastARData` routine, the AR provider creates an additional Metal command buffer for a compute pass that enlarges the depth buffer.
```
In the `processLastARData` routine, the AR provider creates an additional Metal command buffer for a compute pass that enlarges the depth buffer.
```swift
if isToUpsampleDepth {
```

```
The AR provider converts the input depth data to RGB format, as required by the guided filter.
```swift
let convertYUV2RGBFunc = lib.makeFunction(name: "convertYCbCrToRGBA")
pipelineStateCompute = try metalDevice.makeComputePipelineState(function: convertYUV2RGBFunc!)
```

```
After encoding the bilinear scale and guided filters, the AR provider sets the enlarged depth buffer.
```swift
depthContent.texture = destDepthTexture
```

### 
To display the depth and confidence visualizations, Depth Cloud defines a  object, `MetalTextureView`, which contains an  that displays Metal content (see the project’s `MetalTextureView.swift` file). This setup is similar to `MetalDepthView`, except that the sample app stores the view’s displayable content in a single texture.
```swift
encoder.setFragmentTexture(content.texture, index: 0)
```

```
The project inserts the depth visualization view into the view hierarchy by embedding it within the `MetalDepthView` layout in the project’s `MetalViewSample.swift` file.
```swift
ScrollView(.horizontal) {
    HStack() {
        MetalTextureViewDepth(content: arProvider.depthContent, confSelection: $selectedConfidence)
            .zoomOnTapModifier(height: sizeH, width: sizeW, title: isToUpsampleDepth ? "Upscaled Depth" : "Depth")
```

```
The depth visualization view’s contents consist of a texture that contains depth data from the AR session’s current frame.
```swift
depthContent.texture = lastArData?.depthImage?.texture(withFormat: .r32Float, planeIndex: 0, addToCache: textureCache!)!
```

The depth-texture view’s coordinator, `CoordinatorDepth`, assigns a shader that fills the texture.
```
The depth-texture view’s coordinator, `CoordinatorDepth`, assigns a shader that fills the texture.
```swift
pipelineDescriptor.fragmentFunction = library.makeFunction(name: "planeFragmentShaderDepth")
```

The `planeFragmentShaderDepth` shader (see `shaders.metal`) converts the depth values into RGB, as required to display them.
```
The `planeFragmentShaderDepth` shader (see `shaders.metal`) converts the depth values into RGB, as required to display them.
```cpp
fragment half4 planeFragmentShaderDepth(ColorInOut in [[stage_in]], texture2d<float, access::sample> textureDepth [[ texture(0) ]])
{
    constexpr sampler colorSampler(address::clamp_to_edge, filter::nearest);
    float4 s = textureDepth.sample(colorSampler, in.texCoord);
    
    // Size the color gradient to a maximum distance of 2.5 meters.
    // The LiDAR Scanner supports a value no larger than 5.0; the
    // sample app uses a value of 2.5 to better distinguish depth
    // in smaller environments.
    half val = s.r / 2.5h;
    half4 res = getJetColorsFromNormalizedVal(val);
    return res;
```

```
Similarly, the project inserts the confidence visualization view into the view hierarchy by embedding it within the `MetalDepthView` layout in the project’s `MetalViewSample.swift` file.
```swift
MetalTextureViewConfidence(content: arProvider.confidenceContent)
    .zoomOnTapModifier(height: sizeH, width: sizeW, title: "Confidence")
```

```
The confidence visualization view’s contents consist of a texture that contains confidence data from the AR session’s current frame.
```swift
confidenceContent.texture = lastArData?.confidenceImage?.texture(withFormat: .r8Unorm, planeIndex: 0, addToCache: textureCache!)!
```

The confidence-texture view’s coordinator, `CoordinatorConfidence`, assigns a shader that fills the texture.
```
The confidence-texture view’s coordinator, `CoordinatorConfidence`, assigns a shader that fills the texture.
```swift
pipelineDescriptor.fragmentFunction = library.makeFunction(name: "planeFragmentShaderConfidence")
```

The `planeFragmentShaderConfidence` shader (see `shaders.metal`) converts the depth values into RGB, as required to display them.
```
The `planeFragmentShaderConfidence` shader (see `shaders.metal`) converts the depth values into RGB, as required to display them.
```cpp
fragment half4 planeFragmentShaderConfidence(ColorInOut in [[stage_in]], texture2d<float, access::sample> textureIn [[ texture(0) ]])
{
    constexpr sampler colorSampler(address::clamp_to_edge, filter::nearest);
    float4 s = textureIn.sample(colorSampler, in.texCoord);
    float res = round( 255.0f*(s.r) ) ;
    int resI = int(res);
    half4 color = half4(0.0h, 0.0h, 0.0h, 0.0h);
    if (resI == 0)
        color = half4(1.0h, 0.0h, 0.0h, 1.0h);
    else if (resI == 1)
        color = half4(0.0h, 1.0h, 0.0h, 1.0h);
    else if (resI == 2)
        color = half4(0.0h, 0.0h, 1.0h, 1.0h);
    return color;
}
```


## Displaying an AR Experience with Metal
> https://developer.apple.com/documentation/arkit/displaying-an-ar-experience-with-metal

### 
#### 
There are two ways to access  objects produced by an AR session, depending on whether your app favors a pull or a push design pattern.
If you prefer to control frame timing (the pull design pattern), use the session’s  property to get the current frame image and tracking information each time you redraw your view’s contents. For example, see the following function that a custom renderer calls as part of its regular update process:
```swift
func updateGameState() {        
    guard let currentFrame = session.currentFrame else {
        return
    }    
    updateSharedUniforms(frame: currentFrame)
    updateAnchors(frame: currentFrame)
    updateCapturedImageTextures(frame: currentFrame)
    
    if viewportSizeDidChange {
        viewportSizeDidChange = false
        
        updateImagePlane(frame: currentFrame)
    }
}
```

#### 
Each  object’s  property contains a pixel buffer captured from the device camera. To draw this image as the backdrop for your custom view, you’ll need to create textures from the image content and submit GPU rendering commands that use those textures.
The pixel buffer’s contents are encoded in a biplanar YCbCr (also called YUV) data format; to render the image you’ll need to convert this pixel data to a drawable RGB format. For rendering with Metal, you can perform this conversion most efficiently in GPU shader code. Use  APIs to create two Metal textures from the pixel buffer—one each for the buffer’s luma (Y) and chroma (CbCr) planes:
```swift
func updateCapturedImageTextures(frame: ARFrame) {
    // Create two textures (Y and CbCr) from the provided frame's captured image.
    let pixelBuffer = frame.capturedImage
    if (CVPixelBufferGetPlaneCount(pixelBuffer) < 2) {
        return
    }
    capturedImageTextureY = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat:.r8Unorm, planeIndex:0)!
    capturedImageTextureCbCr = createTexture(fromPixelBuffer: pixelBuffer, pixelFormat:.rg8Unorm, planeIndex:1)!
}

func createTexture(fromPixelBuffer pixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, planeIndex: Int) -> MTLTexture? {
    var mtlTexture: MTLTexture? = nil
    let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
    let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
    
    var texture: CVMetalTexture? = nil
    let status = CVMetalTextureCacheCreateTextureFromImage(nil, capturedImageTextureCache, pixelBuffer, nil, pixelFormat, width, height, planeIndex, &texture)
    if status == kCVReturnSuccess {
        mtlTexture = CVMetalTextureGetTexture(texture!)
    }
    
    return mtlTexture
}
```

```
Next, encode render commands that draw those two textures using a fragment function that performs YCbCr to RGB conversion with a color transform matrix:
```cpp
fragment float4 capturedImageFragmentShader(ImageColorInOut in [[stage_in]],
                                            texture2d<float, access::sample> capturedImageTextureY [[ texture(kTextureIndexY) ]],
                                            texture2d<float, access::sample> capturedImageTextureCbCr [[ texture(kTextureIndexCbCr) ]]) {
    
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);
    
    const float4x4 ycbcrToRGBTransform = float4x4(
        float4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
        float4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
        float4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
        float4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
    );
    
    // Sample Y and CbCr textures to get the YCbCr color at the given texture coordinate.
    float4 ycbcr = float4(capturedImageTextureY.sample(colorSampler, in.texCoord).r,
                          capturedImageTextureCbCr.sample(colorSampler, in.texCoord).rg, 1.0);
    
    // Return the converted RGB color.
    return ycbcrToRGBTransform * ycbcr;
}
```

#### 
AR experiences typically focus on rendering 3D overlay content so that the content appears to be part of the real world seen in the camera image. To achieve this illusion, use the  class to model the position and orientation of your own 3D content relative to real-world space. Anchors provide transforms that you can reference during rendering.
For example, the Xcode template creates an anchor located about 20 cm in front of the device whenever a user taps on the screen:
```swift
func handleTap(gestureRecognize: UITapGestureRecognizer) {
    // Create an anchor using the camera's current position.
    if let currentFrame = session.currentFrame {
        
        // Create a transform with a translation of 0.2 meters in front of the camera.
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        let transform = simd_mul(currentFrame.camera.transform, translation)
        
        // Add a new anchor to the session.
        let anchor = ARAnchor(transform: transform)
        session.add(anchor: anchor)
    }
}
```

```
In your rendering engine, use the  property of each  object to place visual content. The Xcode template uses each of the anchors added to the session in its `handleTap` method to position a simple cube mesh:
```swift
func updateAnchors(frame: ARFrame) {
    // Update the anchor's uniform buffer with transforms of the current frame's anchors.
    anchorInstanceCount = min(frame.anchors.count, kMaxAnchorInstanceCount)
    
    var anchorOffset: Int = 0
    if anchorInstanceCount == kMaxAnchorInstanceCount {
        anchorOffset = max(frame.anchors.count - kMaxAnchorInstanceCount, 0)
    }
    
    for index in 0..<anchorInstanceCount {
        let anchor = frame.anchors[index + anchorOffset]
        
        // Flip the Z axis to convert geometry from right handed to left handed.
        var coordinateSpaceTransform = matrix_identity_float4x4
        coordinateSpaceTransform.columns.2.z = -1.0
        
        let modelMatrix = simd_mul(anchor.transform, coordinateSpaceTransform)
        
        let anchorUniforms = anchorUniformBufferAddress.assumingMemoryBound(to: InstanceUniforms.self).advanced(by: index)
        anchorUniforms.pointee.modelMatrix = modelMatrix
    }
}
```

#### 
When you configure shaders for drawing 3D content in your scene, use the estimated lighting information in each  object to produce more realistic shading. See the following code that an app’s custom renderer performs while updating its shared uniforms:
```swift
// Set up the scene's lighting with the ambient intensity, if available.
var ambientIntensity: Float = 1.0
if let lightEstimate = frame.lightEstimate {
    ambientIntensity = Float(lightEstimate.ambientIntensity) / 1000.0
}
let ambientLightColor: vector_float3 = vector3(0.5, 0.5, 0.5)
uniforms.pointee.ambientLightColor = ambientLightColor * ambientIntensity
```


## Occluding virtual content with people
> https://developer.apple.com/documentation/arkit/occluding-virtual-content-with-people

### 
### 
People occlusion is supported on Apple A12 and later devices. Before attempting to enable people occlusion, verify that the user’s device supports it.
```swift
guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
    fatalError("People occlusion is not supported on this device.")
}
```

### 
If the user’s device supports people occlusion, enable it by adding the
arconfiguration/framesemantics/3194576-personsegmentationwithdepth  option to your configuration’s frame semantics.
```swift
config.frameSemantics.insert(.personSegmentationWithDepth)
```

```
Any time you change your session’s , rerun the session to effect the configuration change.
```swift
arView.session.run(config)
```

### 
You might choose to disable people occlusion for performance reasons if, for example, no virtual content is present in the scene, or if the device has reached a serious or critical  (see ). To temporarily disable people occlusion, remove that option from your app’s .
```swift
config.frameSemantics.remove(.personSegmentationWithDepth)
```

```
Then, rerun your session to effect the configuration change.
```swift
arView.session.run(config)
```


## Placing objects and handling 3D interaction
> https://developer.apple.com/documentation/arkit/placing-objects-and-handling-3d-interaction

### 
### 
To enable your app to detect real-world surfaces, you use a world tracking configuration. For ARKit to establish tracking, the user must physically move their device to allow ARKit to get a sense of perspective. To communicate this need to the user, you use a view provided by ARKit that presents the user with instructional diagrams and verbal guidance, called  For example, when you start the app, the first thing the user sees is a message and animation from the coaching overlay telling them to move their device left and right, repeatedly, in order to get started.
To enable the user to place virtual content on a horizontal surface, you set the coaching overlay goal accordingly.
```swift
func setGoal() {
    coachingOverlay.goal = .horizontalPlane
}
```

### 
To make sure the coaching overlay provides guidance to the user whenever ARKit determines it’s necessary, you set  to `true`.
To make sure the coaching overlay provides guidance to the user whenever ARKit determines it’s necessary, you set  to `true`.
```swift
func setActivatesAutomatically() {
    coachingOverlay.activatesAutomatically = true
}
```

```
The coaching overlay activates automatically when the app starts, or when tracking degrades past a certain threshold. In those situations, ARKit notifies your delegate by calling . In response to this event, hide your app’s UI to enable the user to focus on the instructions that the coaching overlay provides.
```swift
func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    upperControlsView.isHidden = true
}
```

```
When the coaching overlay determines that the goal has been met, it disappears from the user’s view. ARKit notifies your delegate that the coaching process has ended, which is when you show your app’s main user interface.
```swift
func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    upperControlsView.isHidden = false
}
```

### 
To give the user an idea of where they can place virtual content, annotate the environment to give them a preview. The sample app draws a square that gives the user visual confirmation of the shape and alignment of the surfaces that ARKit is aware of.
To figure out where to put the square in the real world, you use an  to ask ARKit where any surfaces exist in the real world. First, you create a ray-cast query that defines the 2D point on the screen you’re interested in. Because the focus square is aligned with the center of the screen, you create a query for the screen center.
```swift
func getRaycastQuery(for alignment: ARRaycastQuery.TargetAlignment = .any) -> ARRaycastQuery? {
    return raycastQuery(from: screenCenter, allowing: .estimatedPlane, alignment: alignment)
}
```

```
Then, you execute the ray-cast query by asking the session to cast it.
```swift
func castRay(for query: ARRaycastQuery) -> [ARRaycastResult] {
    return session.raycast(query)
}
```

```
ARKit returns a position in the `results` parameter that includes the depth of where that point lies on a surface in the real world. To give the user a preview of where on the real-world surface a user can place their virtual content, update the focus square’s position using the ray-cast result’s :
```swift
func setPosition(with raycastResult: ARRaycastResult, _ camera: ARCamera?) {
    let position = raycastResult.worldTransform.translation
    recentFocusSquarePositions.append(position)
    updateTransform(for: raycastResult, camera: camera)
}
```

```
The ray-cast result also indicates how the surface is angled with respect to gravity. To preview the angle at which the user’s virtual content can be placed on the surface, update the focus square’s  with the result’s orientation.
```swift
func updateOrientation(basedOn raycastResult: ARRaycastResult) {
    self.simdOrientation = raycastResult.worldTransform.orientation
}
```

```
If your app offers different types of virtual content, give the user an interface to choose from. The sample app exposes a selection menu when the user taps the plus button. When the user chooses an item from the list, you instantiate the corresponding 3D model and anchor it in the world at the focus square’s current position.
```swift
func placeVirtualObject(_ virtualObject: VirtualObject) {
    guard focusSquare.state != .initializing, let query = virtualObject.raycastQuery else {
        self.statusViewController.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
        if let controller = self.objectsViewController {
            self.virtualObjectSelectionViewController(controller, didDeselectObject: virtualObject)
        }
        return
    }
   
    let trackedRaycast = createTrackedRaycastAndSet3DPosition(of: virtualObject, from: query,
                                                              withInitialResult: virtualObject.mostRecentInitialPlacementResult)
    
    virtualObject.raycast = trackedRaycast
    virtualObjectInteraction.selectedObject = virtualObject
    virtualObject.isHidden = false
}
```

### 
As the session runs, ARKit analyzes each camera image and learns more about the layout of the physical environment. When ARKit updates its estimated size and position of real-world surfaces, you may need to update the position of your app’s virtual content to match. To help make it easy, ARKit notifies you when it corrects its understanding of the scene by way of an .
```swift
func createTrackedRaycastAndSet3DPosition(of virtualObject: VirtualObject, from query: ARRaycastQuery,
                                          withInitialResult initialResult: ARRaycastResult? = nil) -> ARTrackedRaycast? {
    if let initialResult = initialResult {
        self.setTransform(of: virtualObject, with: initialResult)
    }
    
    return session.trackedRaycast(query) { (results) in
        self.setVirtualObject3DPosition(results, with: virtualObject)
    }
}
```

```
ARKit successively repeats the query you provide to a tracked ray cast, and it calls the closure you provide only when the results differ from prior results. The code you provide in the closure is your response to ARKit’s updated scene understanding. In this case, you check your ray-cast intersections against the updated planes and apply those positions to your app’s virtual content.
```swift
private func setVirtualObject3DPosition(_ results: [ARRaycastResult], with virtualObject: VirtualObject) {
    
    guard let result = results.first else {
        fatalError("Unexpected case: the update handler is always supposed to return at least one result.")
    }
    
    self.setTransform(of: virtualObject, with: result)
    
    // If the virtual object is not yet in the scene, add it.
    if virtualObject.parent == nil {
        self.sceneView.scene.rootNode.addChildNode(virtualObject)
        virtualObject.shouldUpdateAnchor = true
    }
    
    if virtualObject.shouldUpdateAnchor {
        virtualObject.shouldUpdateAnchor = false
        self.updateQueue.async {
            self.sceneView.addOrUpdateAnchor(for: virtualObject)
        }
    }
}
```

### 
Because ARKit continues to call them, tracked ray casts can increasingly consume resources as the user places more virtual content. Stop the tracked ray cast when you no longer need refined positions over time, such as when a virtual balloon takes flight, or when you remove a virtual object from your scene.
```swift
func removeVirtualObject(at index: Int) {
    guard loadedObjects.indices.contains(index) else { return }
    
    // Stop the object's tracked ray cast.
    loadedObjects[index].stopTrackedRaycast()
    
    // Remove the visual node from the scene graph.
    loadedObjects[index].removeFromParentNode()
    // Recoup resources allocated by the object.
    loadedObjects[index].unload()
    loadedObjects.remove(at: index)
}
```

```
To stop a tracked ray cast, you call its  function:
```swift
func stopTrackedRaycast() {
    raycast?.stopTracking()
    raycast = nil
}
```

### 
To allow users to move virtual content in the world after they’ve placed it, implement a pan gesture recognizer.
```swift
func createPanGestureRecognizer(_ sceneView: VirtualObjectARView) {
    let panGesture = ThresholdPanGesture(target: self, action: #selector(didPan(_:)))
    panGesture.delegate = self
    sceneView.addGestureRecognizer(panGesture)
}
```

```
When the user pans an object, you request its position along the object’s path across the plane. Because the object’s position is transitory, use a  instead of using a tracked ray cast. In this case, a one-time hit test is appropriate because you don’t need refined position results over time for these requests.
```swift
func translate(_ object: VirtualObject, basedOn screenPos: CGPoint) {
    object.stopTrackedRaycast()
    
    // Update the object by using a one-time position request.
    if let query = sceneView.raycastQuery(from: screenPos, allowing: .estimatedPlane, alignment: object.allowedAlignment) {
        viewController.createRaycastAndUpdate3DPosition(of: object, from: query)
    }
}
```

```
Ray casting gives you orientation information about the surface at a given screen point. While dragging, you avoid quick changes in orientation by subtracting the gesture’s rotation from the current object rotation.
```swift
@objc
func didRotate(_ gesture: UIRotationGestureRecognizer) {
    guard gesture.state == .changed else { return }
    
    trackedObject?.objectRotation -= Float(gesture.rotation)
    
    gesture.rotation = 0
}
```

### 
In cases where tracking conditions are poor, ARKit invokes your delegate’s . In these circumstances, the positions of your app’s virtual content may be inaccurate with respect to the camera feed, so hide your virtual content.
```swift
func hideVirtualContent() {
    virtualObjectLoader.loadedObjects.forEach { $0.isHidden = true }
}
```

```
Restore your app’s virtual content when tracking conditions improve. To notify you of improved conditions, ARKit calls your delegate’s function, passing in a camera  equal to .
```swift
func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    statusViewController.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
    switch camera.trackingState {
    case .notAvailable, .limited:
        statusViewController.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
    case .normal:
        statusViewController.cancelScheduledMessage(for: .trackingStateEscalation)
        showVirtualContent()
    }
}
```

### 
When a session is interrupted, ARKit asks if you want to try to restore the AR experience. You do that by opting in to , by overriding  and returning `true`.
```swift
func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
    return true
}
```

```
During relocalization, the coaching overlay displays tailored instructions to the user. To allow the user to focus on the coaching process, hide your app’s UI when coaching is enabled.
```swift
func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    upperControlsView.isHidden = true
}
```

```
When ARKit succeeds in restoring the experience, show your app’s UI again so everything appears the way it was before the interruption. When the coaching overlay disappears from the user’s view, ARKit invokes your  callback, which is where you restore your app’s UI.
```swift
func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    upperControlsView.isHidden = false
}
```

### 
If the user decides to give up on restoring the session, you restart the experience in your delegate’s  function. ARKit invokes this callback when the user taps the coaching overlay’s Start Over button.
```swift
func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
    restartExperience()
}
```


## Previewing a Model with AR Quick Look
> https://developer.apple.com/documentation/arkit/previewing-a-model-with-ar-quick-look

### 
#### 
You provide content for your AR experience in `.usdz` or `.reality` format:
- To browse a library of `.usdz` files, see the .
- To browse a library of `.reality` assets, use Reality Composer. For more information, see `Creating 3D Content with Reality Composer`.
#### 
In your app, you enable AR Quick Look by providing  with a supported input file. The following code demonstrates previewing a scene named `myScene` from the app bundle.
```swift
import UIKit
import QuickLook
import ARKit

class ViewController: UIViewController, QLPreviewControllerDataSource {

    override func viewDidAppear(_ animated: Bool) {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true, completion: nil)
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let path = Bundle.main.path(forResource: "myScene", ofType: "reality") else { fatalError("Couldn't find the supported input file.") }
        let url = URL(fileURLWithPath: path)
        return url as QLPreviewItem
    }    
}
```

To prevent the user from scaling your virtual content or to customize the default share sheet behavior, use `ARQuickLookPreviewItem` instead of .
#### 
In your web page, you enable AR Quick Look by linking a supported input file.
```javascript
<div>
    <a rel="ar" href="/assets/models/my-model.usdz">
        <img src="/assets/models/my-model-thumbnail.jpg">
    </a>
</div>
```


## Recognizing and Labeling Arbitrary Objects
> https://developer.apple.com/documentation/arkit/recognizing-and-labeling-arbitrary-objects

### 
### 
The sample code’s `classificationRequest` property, `classifyCurrentImage() method, and `processClassifications(for:error:)` method manage:
- A Core ML image-classifier model, loaded from an `mlmodel` file bundled with the app using the Swift API that Core ML generates for the model
### 
The sample `ViewController` class manages the AR session and displays AR overlay content in a SpriteKit view. ARKit captures video frames from the camera and provides them to the view controller in the  method, which then calls the `classifyCurrentImage()` method to run the Vision image classifier.
```swift
func session(_ session: ARSession, didUpdate frame: ARFrame) {
    // Do not enqueue other buffers for processing while another Vision task is still running.
    // The camera stream has only a finite amount of buffers available; holding too many buffers for analysis would starve the camera.
    guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
        return
    }
    
    // Retain the image buffer for Vision processing.
    self.currentBuffer = frame.capturedImage
    classifyCurrentImage()
}
```

### 
The `classifyCurrentImage()` method uses the view controller’s `currentBuffer` property to track whether Vision is currently processing an image before starting another Vision task.
```swift
// Most computer vision tasks are not rotation agnostic so it is important to pass in the orientation of the image with respect to device.
let orientation = CGImagePropertyOrientation(UIDevice.current.orientation)

let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: orientation)
visionQueue.async {
    do {
        // Release the pixel buffer when done, allowing the next buffer to be processed.
        defer { self.currentBuffer = nil }
        try requestHandler.perform([self.classificationRequest])
    } catch {
        print("Error: Vision request failed with error \"\(error)\"")
    }
}
```

### 
The `processClassifications(for:error:) method stores the best-match result label produced by the image classifier and displays it in the corner of the screen. The user can then tap in the AR scene to place that label at a real-world position. Placing a label requires two main steps.
First, a tap gesture recognizer fires the `placeLabelAtLocation(sender:)` action. This method uses the ARKit  method to estimate the 3D real-world position corresponding to the tap, and adds an anchor to the AR session at that position.
```swift
@IBAction func placeLabelAtLocation(sender: UITapGestureRecognizer) {
    let hitLocationInView = sender.location(in: sceneView)
    let hitTestResults = sceneView.hitTest(hitLocationInView, types: [.featurePoint, .estimatedHorizontalPlane])
    if let result = hitTestResults.first {
        
        // Add a new anchor at the tap location.
        let anchor = ARAnchor(transform: result.worldTransform)
        sceneView.session.add(anchor: anchor)
        
        // Track anchor ID to associate text with the anchor after ARKit creates a corresponding SKNode.
        anchorLabels[anchor.identifier] = identifierString
    }
}
```

```
Next, after ARKit automatically creates a SpriteKit node for the newly added anchor, the  delegate method provides content for that node. In this case, the sample `TemplateLabelNode` class creates a styled text label using the string provided by the image classifier.
```swift
func view(_ view: ARSKView, didAdd node: SKNode, for anchor: ARAnchor) {
    guard let labelText = anchorLabels[anchor.identifier] else {
        fatalError("missing expected associated label for anchor")
    }
    let label = TemplateLabelNode(text: labelText)
    node.addChild(label)
}
```


## Saving and loading world data
> https://developer.apple.com/documentation/arkit/saving-and-loading-world-data

### 
### 
### 
### 
An  object contains a snapshot of all the spatial mapping information that ARKit uses to locate the user’s device in real-world space. To save a map that can reliably be used for restoring your AR session later, you’ll first need to find a good time to capture the map.
ARKit provides a  value that indicates whether it’s currently a good time to capture a world map (or if it’s better to wait until ARKit has mapped more of the local environment). This app uses that value to provide visual feedback and choose when to make the Save Experience button available:
```swift
// Enable Save button only when the mapping status is good and an object has been placed
switch frame.worldMappingStatus {
case .extending, .mapped:
    saveExperienceButton.isEnabled =
        virtualObjectAnchor != nil && frame.anchors.contains(virtualObjectAnchor!)
default:
    saveExperienceButton.isEnabled = false
}
statusLabel.text = """
Mapping: \(frame.worldMappingStatus.description)
Tracking: \(frame.camera.trackingState.description)
"""
```

```
When the user taps the Save Experience button, the app calls  to capture the map from the running ARSession, then serializes it to a  object with  and writes it to local storage:
```swift
sceneView.session.getCurrentWorldMap { worldMap, error in
    guard let map = worldMap
        else { self.showAlert(title: "Can't get current world map", message: error!.localizedDescription); return }
    
    // Add a snapshot image indicating where the map was captured.
    guard let snapshotAnchor = SnapshotAnchor(capturing: self.sceneView)
        else { fatalError("Can't take snapshot") }
    map.anchors.append(snapshotAnchor)
    
    do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
        try data.write(to: self.mapSaveURL, options: [.atomic])
        DispatchQueue.main.async {
            self.loadExperienceButton.isHidden = false
            self.loadExperienceButton.isEnabled = true
        }
    } catch {
        fatalError("Can't save map: \(error.localizedDescription)")
    }
}
```

### 
When the app launches, it checks local storage for a world map file it may have saved in an earlier session:
```swift
do {
    guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
        else { fatalError("No ARWorldMap in archive.") }
    return worldMap
} catch {
    fatalError("Can't unarchive ARWorldMap from file data: \(error)")
}
```

```
If that file exists and can be deserialized as an  object, the app makes its Load Experience button available. When you tap the button, the app tells ARKit to attempt resuming the session captured in that world map, by creating and running an  using that map as the :
```swift
let configuration = self.defaultConfiguration // this app's standard world tracking settings
configuration.initialWorldMap = worldMap
sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
```

### 
Saving a world map also archives all anchors currently associated with the AR session. After you successfully run a session from a saved world map, the session contains all anchors previously saved in the map. You can use saved anchors to restore virtual content from a previous session.
In this app, after relocalizing to a previously saved world map, the virtual object placed in the previous session automatically appears at its saved position. The same  delegate method  fires both when you directly add an anchor to the session and when the session restores anchors from a world map. To determine which saved anchor represents the virtual object, this app uses the   property.
```swift
func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard anchor.name == virtualObjectAnchorName
        else { return }
    
    // save the reference to the virtual object anchor when the anchor is added from relocalizing
    if virtualObjectAnchor == nil {
        virtualObjectAnchor = anchor
    }
    node.addChildNode(virtualObject)
}
```


## Scanning and Detecting 3D Objects
> https://developer.apple.com/documentation/arkit/scanning-and-detecting-3d-objects

### 
### 
### 
### 
2. Drag `.arobject` files from the Finder into the newly created resource group.
To enable object detection in an AR session, load the reference objects you want to detect as  instances, provide those objects for the  property of an , and run an  with that configuration:
```swift
let configuration = ARWorldTrackingConfiguration()
guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "gallery", bundle: nil) else {
    fatalError("Missing expected asset catalog resources.")
}
configuration.detectionObjects = referenceObjects
sceneView.session.run(configuration)
```

```
When ARKit detects one of your reference objects, the session automatically adds a corresponding  to its list of anchors. To respond to an object being recognized, implement an appropriate , , or  method that reports the new anchor being added to the session. For example, in a SceneKit-based app you can implement  to add a 3D asset to the scene, automatically matching the position and orientation of the anchor:
```swift
func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    if let objectAnchor = anchor as? ARObjectAnchor {
        node.addChildNode(self.model)
    }
}
```

### 
This sample app provides one way to create reference objects. You can also scan reference objects in your own app—for example, to build asset management tools for defining AR content that goes into other apps you create.
A reference object encodes a slice of the internal spatial-mapping data that ARKit uses to track a device’s position and orientation. To enable the high-quality data collection required for object scanning, run a session with :
```swift
let configuration = ARObjectScanningConfiguration()
configuration.planeDetection = .horizontal
sceneView.session.run(configuration, options: .resetTracking)
```

During your object-scanning AR session, scan the object from various angles to make sure you collect enough spatial data to recognize it. (If you’re building your own object-scanning tools, help users walk through the same steps this sample app provides.)
After scanning, call  to produce an  from a region of the user environment mapped by the session:
```swift
// Extract the reference object based on the position & orientation of the bounding box.
sceneView.session.createReferenceObject(
    transform: boundingBox.simdWorldTransform,
    center: SIMD3<Float>(), extent: boundingBox.extent,
    completionHandler: { object, error in
        if let referenceObject = object {
            // Adjust the object's origin with the user-provided transform.
            self.scannedReferenceObject = referenceObject.applyingTransform(origin.simdTransform)
            self.scannedReferenceObject!.name = self.scannedObject.scanName
            
            if let referenceObjectToMerge = ViewController.instance?.referenceObjectToMerge {
                ViewController.instance?.referenceObjectToMerge = nil
                
                // Show activity indicator during the merge.
                ViewController.instance?.showAlert(title: "", message: "Merging previous scan into this scan...", buttonTitle: nil)
                
                // Try to merge the object which was just scanned with the existing one.
                self.scannedReferenceObject?.mergeInBackground(with: referenceObjectToMerge, completion: { (mergedObject, error) in

                    if let mergedObject = mergedObject {
                        self.scannedReferenceObject = mergedObject
                        ViewController.instance?.showAlert(title: "Merge successful",
                                                           message: "The previous scan has been merged into this scan.", buttonTitle: "OK")
                        creationFinished(self.scannedReferenceObject)

                    } else {
                        print("Error: Failed to merge scans. \(error?.localizedDescription ?? "")")
                        let message = """
                                Merging the previous scan into this scan failed. Please make sure that
                                there is sufficient overlap between both scans and that the lighting
                                environment hasn't changed drastically.
                                Which scan do you want to use for testing?
                                """
                        let thisScan = UIAlertAction(title: "Use This Scan", style: .default) { _ in
                            creationFinished(self.scannedReferenceObject)
                        }
                        let previousScan = UIAlertAction(title: "Use Previous Scan", style: .default) { _ in
                            self.scannedReferenceObject = referenceObjectToMerge
                            creationFinished(self.scannedReferenceObject)
                        }
                        ViewController.instance?.showAlert(title: "Merge failed", message: message, actions: [thisScan, previousScan])
                    }
                })
            } else {
                creationFinished(self.scannedReferenceObject)
            }
        } else {
            print("Error: Failed to create reference object. \(error!.localizedDescription)")
            creationFinished(nil)
        }
    })
```


## Specifying a lighting environment in AR Quick Look
> https://developer.apple.com/documentation/arkit/specifying-a-lighting-environment-in-ar-quick-look

### 
#### 
To define the lighting environment in the asset’s `.usda` textual format using a tool like , add the following metadata:
To define the lighting environment in the asset’s `.usda` textual format using a tool like , add the following metadata:
```None
// asset.usda
#usda 1.0
(
    customLayerData = {
        dictionary Apple = {
            int preferredIblVersion = 2
        }
    }
)
```

A value of `1` indicates the classic lighting environment, and a value of `2` indicates the new lighting environment.
#### 
Alternatively, you can use `usdzconvert` in the Apple  suite to output from another file format. Pass an integer value between `0` and `2` for the `--preferrediblversion` argument to add this metadata in the file, as the following example shows:
```swift
usdzconvert fireHydrant.obj --useObjMtl --preferrediblversion 2 
```

#### 

## Streaming an AR experience
> https://developer.apple.com/documentation/arkit/streaming-an-ar-experience

### 
### 
AR Stream displays the device’s camera feed by configuring a window with a view controller that displays an  (see the sample project’s `Main.storyboard` file). By default, runs a session with a world-tracking configuration . To receive notifications of the view’s session events, the project’s view controller (see `ViewController` in the sample project) assigns itself as the session delegate.
```swift
arView.session.delegate = self
```

### 
To show the user’s physical environment to the remote user, AR Stream uses ReplayKit to open a screen-recording session with .
```swift
RPScreenRecorder.shared().startCapture {
```

```
The screen recording captures the contents of the app’s main window, which includes any augmentations that RealityKit may add to the camera feed. In the  closure, the sample project passes the captured screen (`sampleBuffer`) to the `compressAndSend` function for eventual transmission over the network. The sample project also passes in the session’s current frame to conform the screen captures to the camera-image size.
```swift
if type == .video {
    guard let currentFrame = arView.session.currentFrame else { return }
    videoProcessor.compressAndSend(sampleBuffer, arFrame: currentFrame) {
```

### 
The sample project’s `VideoProcessor` class implements the `compressAndSend` function, which uses  to compress the captured video frames.
The sample project’s `VideoProcessor` class implements the `compressAndSend` function, which uses  to compress the captured video frames.
```swift
VTCompressionSessionEncodeFrame(compressionSession,
    imageBuffer: imageBuffer,
    presentationTimeStamp: presentationTimeStamp,
    duration: .invalid,
    frameProperties: nil,
    infoFlagsOut: nil) {
```

```
To ensure timely compression for the real-time streaming use case of the app, the video processor enables the compression session’s  option.
```swift
VTSessionSetProperty(compressionSession, key: kVTCompressionPropertyKey_RealTime,
    value: kCFBooleanTrue)
```

```
After the  finishes encoding a frame, the app creates a `VideoFrameData` instance using the compressed frame and the inverse view and projection matrices from the corresponding .
```swift
let videoFrameData = VideoFrameData(sampleBuffer: sampleBuffer, arFrame: arFrame)
```

The project serializes and encodes the `VideoFrameData` as JSON data, and passes the data to its `sendHandler`.
```
The project serializes and encodes the `VideoFrameData` as JSON data, and passes the data to its `sendHandler`.
```swift
do {
    let data = try JSONEncoder().encode(videoFrameData)
    // Invoke the caller's handler to send the data.
    sendHandler(data)
} catch {
    fatalError("Failed to encode videoFrameData as JSON with error: "
        + error.localizedDescription)
}
```

```
The screen-recording closure defines the send handler to contain code that uses  to transmit the video data over the local network.
```swift
multipeerSession.sendToAllPeers(data, reliably: true)
```

### 
When the app receives `VideoFrameData` from another device, it decodes the JSON data.
When the app receives `VideoFrameData` from another device, it decodes the JSON data.
```swift
func receivedData(_ data: Data, from peer: MCPeerID) {
    // Try to decode the received data and handle it appropriately.
    if let videoFrameData = try? JSONDecoder().decode(VideoFrameData.self,
        from: data) {
```

```
To house the transmitted video frame, AR Stream reconstructs a sample buffer.
```swift
let sampleBuffer = videoFrameData.makeSampleBuffer()
```

The system can display only uncompressed data, so the video processor decompresses the video frame using  within its `decompress` function.
```
The system can display only uncompressed data, so the video processor decompresses the video frame using  within its `decompress` function.
```swift
VTDecompressionSessionDecodeFrame(decompressionSession,
    sampleBuffer: sampleBuffer,
    flags: [],
    infoFlagsOut: nil) {
```

```
AR Stream draws the video frame to the screen using its renderer object (see `Renderer` in the sample project). The renderer enqueues the frame data for imminent display.
```swift
// Update the PipView aspect ratio to match the camera-image dimensions.
let width = CGFloat(CVPixelBufferGetWidth(imageBuffer))
let height = CGFloat(CVPixelBufferGetHeight(imageBuffer))
overlayViewController?.setPipViewConstraints(width: width, height: height)

overlayViewController?.renderer.enqueueFrame(
    pixelBuffer: imageBuffer,
    presentationTimeStamp: presentationTimeStamp,
    inverseProjectionMatrix: videoFrameData.inverseProjectionMatrix,
    inverseViewMatrix: videoFrameData.inverseViewMatrix)
```

### 
The sample project’s `AppDelegate` configures the PiP view in a secondary window. Because ReplayKit’s screen recording captures only the main window, the PiP view displays only the remote user’s camera feed.
```swift
overlayWindow = UIWindow(windowScene: windowScene)

let storyBoard = UIStoryboard(name: "Main", bundle: nil)
let overlayViewController = storyBoard.instantiateViewController(
    identifier: "OverlayViewController")
overlayWindow.rootViewController = overlayViewController
overlayWindow.makeKeyAndVisible()

// Make sure the overlayWindow is always above the main window.
overlayWindow.windowLevel = window.windowLevel + 1
```

### 
When the remote user taps the PiP view, the project responds by recording the tap location.
```swift
@objc
func tapped(_ sender: UITapGestureRecognizer) {
    guard let view = sender.view else { return }
    let location = sender.location(in: view)
```

```
The sample project uses the inverse matrices that the user sends to enable the remote user to interact with the user’s AR experience.
```swift
guard let inverseProjectionMatrix = renderer.lastDrawnInverseProjectionMatrix,
    let inverseViewMatrix = renderer.lastDrawnInverseViewMatrix else {
    return
}
```

```
The project converts the tap location and inverse matrices into a ray cast that describes the location and direction in the user’s  world coordinate system (see the `makeRay` function in the sample project).
```swift
let rayQuery = makeRay(from: location,
    viewportSize: view.frame.size,
    inverseProjectionMatrix: simd_float4x4(inverseProjectionMatrix),
    inverseViewMatrix: simd_float4x4(inverseViewMatrix))
```

```
Then, the sample project encodes the ray cast as JSON data and sends it to the connected peer.
```swift
let data = try JSONEncoder().encode(rayQuery)
multipeerSession?.sendToAllPeers(data, reliably: true)
```

### 
In the project’s `ViewController`, the `receivedData` function receives a `Ray` object when the remote user taps the PiP view.
In the project’s `ViewController`, the `receivedData` function receives a `Ray` object when the remote user taps the PiP view.
```swift
} else if let rayQuery = try? JSONDecoder().decode(Ray.self, from: data) {
```

To hand the remote user’s tap gesture to ARKit as if the user is tapping the screen, the sample project uses the `Ray` data to create an .
```
To hand the remote user’s tap gesture to ARKit as if the user is tapping the screen, the sample project uses the `Ray` data to create an .
```swift
trackedRaycast = arView.session.trackedRaycast(
    ARRaycastQuery(
        origin: rayQuery.origin,
        direction: rayQuery.direction,
        allowing: .estimatedPlane,
        alignment: .any)
    ) {
```

```
When the tracked ray cast intersects with a surface in the user’s environment, the app records the resulting location.
```swift
if let result = raycastResults.first {
    marker.transform.matrix = result.worldTransform
```

### 
The project creates this visual marker using a ball-shaped .
```swift
let marker: AnchorEntity = {
    let entity = AnchorEntity()
    entity.addChild(ModelEntity(mesh: .generateSphere(radius: 0.05)))
    entity.isEnabled = false
    return entity
}()
```

```
At app launch, the marker is invisible by default as the project readies the marker for display by adding it to the scene.
```swift
arView.scene.addAnchor(marker)
```

When the app receives a `Ray` from the remote user and adjusts the marker’s position, the project displays the marker by enabling it.
```
When the app receives a `Ray` from the remote user and adjusts the marker’s position, the project displays the marker by enabling it.
```swift
marker.isEnabled = true
```


## Tracking accessories in volumetric windows
> https://developer.apple.com/documentation/arkit/tracking-accessories-in-volumetric-windows

### 
#### 
> **note:** Simulator doesn’t support accessory tracking, so you need a physical device to run the sample app.
```swift
    if !AccessoryTrackingProvider.isSupported {
        state = .accessoryTrackingNotSupported
        return
    }
    
    // Listen for connected and disconnected controllers.
    NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect,
                                           object: nil,
                                           queue: nil) { notification in
        if let controller = notification.object as? GCController {
            guard controller.productCategory == GCProductCategorySpatialController else {
                return
            }
            
            //...
        }
    }
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect,
                                           object: nil,
                                           queue: nil) { notification in
        if let controller = notification.object as? GCController {
            if controller.productCategory == GCProductCategorySpatialController {
                //...
            }
        }
    }
```

```
An  running  implicitly requests authorization. Your app can handle this with an  session event. If the player authorizes the tracking, the code in the `authorizationChanged` handler starts controller tracking.
```swift
private func monitorARKitSessionEvents() async {
    for await event in arkitSession.events {
        switch event {
            case .dataProviderStateChanged(_, let newState, let error):
                if newState == .stopped {
                    if let error {
                        print("An error occurred: \(error)")
                        state = .arkitSessionError
                    }
                }
        case .authorizationChanged(let type, let authorizationStatus):
            if type == .accessoryTracking {
                if authorizationStatus == .denied {
                    state = .accessoryTrackingNotAuthorized
                } else if authorizationStatus == .allowed {
                    state = .startingUp
                    // ...
                }
            }
        default:
            break
        }
    }
}
```

#### 
Within its tracking code, the sample requests all available controllers with . Create a trackable ARKit  object from the returned  device. Passing the available accessories to the  allows the sample to access  updates when running in an  object. Accessory events are available asynchronously from . During tracking, the sample performs several operations — verifying the controllers presence within the volume, syncing the tennis ball position with the controllers, and checking for the player performing a throw or shake action.
```swift
let accessoryTracking = AccessoryTrackingProvider(accessories: accessories)

do {
    try await arkitSession.run([accessoryTracking])
    state = .inGame
    gameState = .startNewGame
} catch {
    return
}

for await update in accessoryTracking.anchorUpdates {
    process(update)
}
```

The system uses the  update closure to verify that the controllers are located within the volume, and the sample generates a bounding box that the volume determines. If at least one controller is connected and located within the volume bounds, the app state updates accordingly. If all controllers exist outside the bounds, an Out of Bounds message displays on the volume’s toolbar.
For each tracked accessory, the app generates a tennis ball entity, and repositions it while handling accessory-tracking anchor updates. The transform of  is relative to . The app contains the tennis ball model within a `RealityView`, in a volume, unaligned with the world reference coordinate space. It’s a complex process to convert the tracked accessory position to the placement of the tennis ball. The sample determines whether the accessory is inside the volume using the anchor’s  method to eliminate the complexity. The tennis ball entity doesn’t render when the accessories move outside the volume.
```swift
let aimPoint = controllerAnchor.coordinateSpace(for: .aim, correction: .rendered)

if let realityViewFromAimPointTransform = try? realityViewOrigin.transform(from: aimPoint) {
    let aimPointPosition = realityViewFromAimPointTransform.matrix.columns.3.xyz
    isInsideRealityView = realityViewEdges.contains(aimPointPosition)
}
```

#### 
During anchor update processing, the sample handles the tennis ball throw and shake to reset action checking. The app triggers a throw by tracking the peak velocity of the accessory, and determining when the current velocity decreases by 0.6 m/s. The app provides the accessory’s velocity as a 3D vector in the accessory anchor’s local coordinate space. To obtain the correct velocity, the app transforms the vector relative to the `gameRoot` coordinate space with the `convert(value:, to:)` method. To strike the cans, the ball associated with the tossing accessory anchor sustains a velocity matching that of the anchor. If the system doesn’t register a throw within 1 second, it resets the throw tracking.
```swift
guard let anchor = controller.anchor else { return }

let controllerSpeed = length(anchor.velocity)
controller.pendingThrow.peakSpeed = max(controller.pendingThrow.peakSpeed, controllerSpeed)

if controller.pendingThrow.peakSpeed > 1.2 &&
    controllerSpeed < controller.pendingThrow.peakSpeed - 0.6 {
    // Trigger a throw if:
    // The controller's peak speed is more than 1.2 m/s.
    // The controller's speed drops more than 0.6 m/s below the peak.
    if controller.triggeredThrow == nil {
        controller.pendingThrow.anchor = anchor
        
        controller.triggeredThrow = controller.pendingThrow
        controller.pendingThrow = Throw()
        
        Task {
            // Allow the next throw after 1 second.
            try? await Task.sleep(for: .milliseconds(1000))
            controller.triggeredThrow = nil
        }
    }
}
```

```
The app triggers a reset by rotating the accessory quickly clockwise and counterclockwise around the z-axis. The anchor’s  property provides the current rate of rotation.
```swift
guard let anchor = controller.anchor else { return }

let controllerZAngularVelocity = anchor.angularVelocity[2]
controller.pendingShake.peakAngularVelocity = max(controller.pendingShake.peakAngularVelocity, controllerZAngularVelocity)
```

```
Checking for positive and negative angular velocities of 90 deg/s, the sample increases the shake count on each change of direction.
```swift
let halfPi: Float = .pi / 2

if controllerZAngularVelocity < controller.pendingShake.peakAngularVelocity - halfPi &&
    abs(anchor.angularVelocity[0]) < halfPi && abs(anchor.angularVelocity[1]) < halfPi {
    // Detect a controller oscillation on the z-axis if:
    // The controller's angular velocity on the z-axis drops more than 90 deg/s below the peak angular velocity.
    // The controller's angular velocity on the other axes is less than 90 deg/s.
    let controllerPosition: SIMD3<Float> = anchor.originFromAnchorTransform.columns.3.xyz
    
    // Reset the shake if the user moves too much.
    if let shakePrevPos = controller.pendingShake.initialPosition {
        guard length(controllerPosition - shakePrevPos) < 0.2 else {
            controller.pendingShake = Shake()
            return
        }
    }
    
    if controllerZAngularVelocity < -halfPi {
        if controller.pendingShake.currentDirection == .counterClockwise {
            controller.pendingShake.oscillationCount += 1
        }
        controller.pendingShake.currentDirection = .clockwise
    } else if controllerZAngularVelocity > halfPi {
        if controller.pendingShake.currentDirection == .clockwise {
            controller.pendingShake.oscillationCount += 1
        }
        controller.pendingShake.currentDirection = .counterClockwise
    }
    
    if controller.pendingShake.oscillationCount == 1 {
        controller.pendingShake.initialPosition = controllerPosition
    }
```

```
If the shake direction changes six times, the app performs the action and resets the cans into a stack, ready for the next game.
```swift
    if controller.triggeredShake == nil && controller.pendingShake.oscillationCount >= 6 {
        controller.triggeredShake = controller.pendingShake
        controller.pendingShake = Shake()
        
        gameState = .startNewGame
        
        Task {
            // Reset the triggered shake after 0.5 seconds.
            try? await Task.sleep(for: .milliseconds(500))
            controller.triggeredShake = nil
        }
    }
```


## Tracking and altering images
> https://developer.apple.com/documentation/arkit/tracking-and-altering-images

### 
### 
As shown below, you can use Vision in real-time to check the camera feed for rectangles. You perform this check up to 10 times a second by using `RectangleDetector` to schedule a repeating timer with an `updateInterval` of `0.1` seconds.
```swift
init() {
    self.updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
        if let capturedImage = ViewController.instance?.sceneView.session.currentFrame?.capturedImage {
            self?.search(in: capturedImage)
        }
    }
}
```

Because Vision requests can be taxing on the processor, check the camera feed no more than 10 times a second. Checking for rectangles more frequently may cause the app’s frame rate to decrease, without noticeably improving the app’s results.
When you make Vision requests in real-time with an ARKit–based app, you should do so serially. By waiting for one request to finish before invoking another, you ensure that the AR experience remains smooth and free of interruptions. In the `search` function, you use the `isBusy` flag to ensure you’re only checking for one rectangle at a time:
```swift
private func search(in pixelBuffer: CVPixelBuffer) {
    guard !isBusy else { return }
    isBusy = true
    
    // ...
}
```

The sample sets the `isBusy` flag to `false` when a Vision request completes or fails.
### 
When Vision finds a rectangle in the camera feed, it provides you with the rectangle’s precise coordinates through a . You apply those coordinates to a Core Image perspective correction filter to crop it, leaving you with just the image data inside the rectangular shape.
```swift
private func completedVisionRequest(_ request: VNRequest?, error: Error?) {
    defer {
        isBusy = false
    }
    // Only proceed if a rectangular image was detected.
    guard let rectangle = request?.results?.first as? VNRectangleObservation else {
        guard let error = error else { return }
        print("Error: Rectangle detection failed - Vision request returned an error. \(error.localizedDescription)")
        return
    }
    guard let filter = CIFilter(name: "CIPerspectiveCorrection") else {
        print("Error: Rectangle detection failed - Could not create perspective correction filter.")
        return
    }
    let width = CGFloat(CVPixelBufferGetWidth(currentCameraImage))
    let height = CGFloat(CVPixelBufferGetHeight(currentCameraImage))
    let topLeft = CGPoint(x: rectangle.topLeft.x * width, y: rectangle.topLeft.y * height)
    let topRight = CGPoint(x: rectangle.topRight.x * width, y: rectangle.topRight.y * height)
    let bottomLeft = CGPoint(x: rectangle.bottomLeft.x * width, y: rectangle.bottomLeft.y * height)
    let bottomRight = CGPoint(x: rectangle.bottomRight.x * width, y: rectangle.bottomRight.y * height)
    
    filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
    filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
    filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
    filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
    
    let ciImage = CIImage(cvPixelBuffer: currentCameraImage).oriented(.up)
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    
    guard let perspectiveImage: CIImage = filter.value(forKey: kCIOutputImageKey) as? CIImage else {
        print("Error: Rectangle detection failed - perspective correction filter has no output image.")
        return
    }
    delegate?.rectangleFound(rectangleContent: perspectiveImage)
}
```

### 
To prepare to track the cropped image, you create an , which provides ARKit with everything it needs, like its look and physical size, to locate that image in the physical environment.
```swift
let possibleReferenceImage = ARReferenceImage(referenceImagePixelBuffer, 
                                              orientation: .up, 
                                              physicalWidth: CGFloat(0.5))
```

```
ARKit requires that reference images contain sufficient detail to be recognizable; for example, a plain white image cannot be tracked. To prevent ARKit from failing to track a reference image, you validate it first before attempting to use it.
```swift
possibleReferenceImage.validate { [weak self] (error) in
    if let error = error {
        print("Reference image validation failed: \(error.localizedDescription)")
        return
    }
    // ...
```

### 
Provide the reference image to ARKit to get updates on where the image lies in the camera feed when the user moves their device. Do that by creating an image tracking session and passing the reference image in to the configuration’s .
```swift
let configuration = ARImageTrackingConfiguration()
configuration.maximumNumberOfTrackedImages = 1
configuration.trackingImages = trackingImages
sceneView.session.run(configuration, options: runOptions)
```

```
Vision made the initial observation about where the image lies in 2D space in the camera feed, but ARKit resolves its location in 3D space, in the physical environment. When ARKit succeeds in recognizing the image, it creates an  and a SceneKit node at the right position. You save the anchor and node that ARKit gives you by passing them to an `AlteredImage` object.
```swift
func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    alteredImage?.add(anchor, node: node)
    setMessageHidden(true)
}
```

### 
When Vision finds a rectangular shape in the user’s environment, you pass the camera’s image data defined by that rectangle into a new `AlteredImage`.
```swift
guard let newAlteredImage = AlteredImage(rectangleContent, referenceImage: possibleReferenceImage) else { return }
```

```
The following code shows how you choose the artistic style to apply to the image by inputting the integer index to the Core ML model. Then, you process the image by calling the Core ML model’s .
```swift
let input = StyleTransferModelInput(image: self.modelInputImage, index: self.styleIndexArray)
let output = try AlteredImage.styleTransferModel.prediction(input: input, options: options)
```

### 
To complete the augmented reality effect, you cover the original image with the altered image. First, add a visualization node to hold the altered image as a child of the node provided by ARKit.
```swift
node.addChildNode(visualizationNode)
```

```
When Core ML produces the output image, you call `imageAlteringComplete(_:)` to pass the model’s output image into the visualization node’s `display` function, where you set the image as the visualization node’s contents.
```swift
func imageAlteringComplete(_ createdImage: CVPixelBuffer) {
    guard fadeBetweenStyles else { return }
    modelOutputImage = createdImage
    visualizationNode.display(createdImage)
}
```

### 
This sample demonstrates real-time image processing by switching artistic styles over time. By calling `selectNextStyle`, you can make successive alterations of the original image. `styleIndex` is the integer input to the Core ML model that determines the style of the output.
```swift
func selectNextStyle() {
    styleIndex = (styleIndex + 1) % numberOfStyles
}
```

```
The sample’s `VisualizationNode` fades between two images of differing style, which creates the effect that the tracked image is constantly transforming into a new look. You accomplish this effect by defining two SceneKit nodes. One node displays the current altered image, and the other displays the previous altered image.
```swift
private let currentImage: SCNNode
private let previousImage: SCNNode
```

```
You fade between these two nodes by running an opacity animation:
```swift
SCNTransaction.begin()
SCNTransaction.animationDuration = fadeDuration
currentImage.opacity = 1.0
previousImage.opacity = 0.0
SCNTransaction.completionBlock = {
    self.delegate?.visualizationNodeDidFinishFade(self)
}
SCNTransaction.commit()
```

When the animation finishes, you begin altering the original image with the next artistic style by calling `createAlteredImage` again:
```
When the animation finishes, you begin altering the original image with the next artistic style by calling `createAlteredImage` again:
```swift
func visualizationNodeDidFinishFade(_ visualizationNode: VisualizationNode) {
    guard fadeBetweenStyles, anchor != nil else { return }
    selectNextStyle()
    createAlteredImage()
}
```

### 
As part of the image tracking feature, ARKit continues to look for the image throughout the AR session. If the image itself moves, ARKit updates the  with its corresponding image’s new location in the physical environment, and calls your delegate’s  to notify your app of the change.
```swift
func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    alteredImage?.update(anchor)
}
```

```
The sample app tracks a single image at a time. To do that, you invalidate the current image tracking session if an image the app was tracking is no longer visible. This, in turn, enables Vision to start looking for a new rectangular shape in the camera feed.
```swift
func update(_ anchor: ARAnchor) {
    if let imageAnchor = anchor as? ARImageAnchor, self.anchor == anchor {
        self.anchor = imageAnchor
        // Reset the timeout if the app is still tracking an image.
        if imageAnchor.isTracked {
            resetImageTrackingTimeout()
        }
    }
}
```


## Tracking and visualizing faces
> https://developer.apple.com/documentation/arkit/tracking-and-visualizing-faces

### 
#### 
Like other uses of ARKit, face tracking requires configuring and running a session (an  object) and rendering the camera image together with virtual content in a view. This sample uses  to display 3D content with SceneKit, but you can also use SpriteKit or build your own renderer using Metal (see  and .
Face tracking differs from other uses of ARKit in the class you use to configure the session. To enable face tracking, create an instance of , configure its properties, and pass it to the  method of the AR session associated with your view, as shown here:
```swift
guard ARFaceTrackingConfiguration.isSupported else { return }
let configuration = ARFaceTrackingConfiguration()
if #available(iOS 13.0, *) {
    configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
}
configuration.isLightEstimationEnabled = true
sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
```

#### 
When face tracking is active, ARKit automatically adds objects to the running AR session, containing information about the user’s face, including its position and orientation. (ARKit detects and provides information about only face at a time. If multiple faces are present in the camera image, ARKit chooses the largest or most clearly recognizable face.)
In a SceneKit-based AR experience, you can add 3D content corresponding to a face anchor in the  or  delegate method. ARKit manages a SceneKit node for the anchor, and updates that node’s position and orientation on each frame, so any SceneKit content you add to that node automatically follows the position and orientation of the user’s face.
```swift
func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    // This class adds AR content only for face anchors.
    guard anchor is ARFaceAnchor else { return nil }
    
    // Load an asset from the app bundle to provide visual content for the anchor.
    contentNode = SCNReferenceNode(named: "coordinateOrigin")
    
    // Add content for eye tracking in iOS 12.
    self.addEyeTransformNodes()
    
    // Provide the node to ARKit for keeping in sync with the face anchor.
    return contentNode
}
```

#### 
Your AR experience can use this mesh to place or draw content that appears to attach to the face. For example, by applying a semitransparent texture to this geometry you could paint virtual tattoos or makeup onto the user’s skin.
To create a SceneKit face geometry, initialize an  object with the Metal device your SceneKit view uses for rendering, and assign that geometry to the SceneKit node tracking the face anchor.
```swift
func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    guard let sceneView = renderer as? ARSCNView,
        anchor is ARFaceAnchor else { return nil }
    
    #if targetEnvironment(simulator)
    #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.") // swiftlint:disable:this line_length
    #else
    let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
    let material = faceGeometry.firstMaterial!
    
    material.diffuse.contents = #imageLiteral(resourceName: "wireframeTexture") // Example texture map image.
    material.lightingModel = .physicallyBased
    
    contentNode = SCNNode(geometry: faceGeometry)
    #endif
    return contentNode
}
```

ARKit updates its face mesh conform to the shape of the user’s face, even as the user blinks, talks, and makes various expressions. To make the displayed face model follow the user’s expressions, retrieve an updated face meshes in the  delegate callback, then update the  object in your scene to match by passing the new face mesh to its  method:
```swift
func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    guard let faceGeometry = node.geometry as? ARSCNFaceGeometry,
        let faceAnchor = anchor as? ARFaceAnchor
        else { return }
    
    faceGeometry.update(from: faceAnchor.geometry)
}
```

#### 
This technique creates the illusion that the real face interacts with virtual objects, even though the face is a 2D camera image and the virtual content is a rendered 3D object. For example, if you place an occlusion geometry and virtual glasses on the user’s face, the face can obscure the frame of the glasses.
To create an occlusion geometry for the face, start by creating an  object as in the previous example. However, instead of configuring that object’s SceneKit material with a visible appearance, set the material to render depth but not color during rendering:
```swift
let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
faceGeometry.firstMaterial!.colorBufferWriteMask = []
occlusionNode = SCNNode(geometry: faceGeometry)
occlusionNode.renderingOrder = -1
```

#### 
For additional creative uses of face tracking, you can texture-map the live 2D video feed from the camera onto the 3D geometry that ARKit provides. After mapping pixels in the camera video onto the corresponding points on ARKit’s face mesh, you can modify that mesh, creating illusions such as resizing or distorting the user’s face in 3D.
First, create an  for the face and assign the camera image to its main material.  automatically sets the scene’s  material to use the live video feed from the camera, so you can set the geometry to use the same material.
```swift
// Show video texture as the diffuse material and disable lighting.
let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!, fillMesh: true)!
let material = faceGeometry.firstMaterial!
material.diffuse.contents = sceneView.scene.background.contents
material.lightingModel = .constant
```

```
To correctly align the camera image to the face, you’ll also need to modify the texture coordinates that SceneKit uses for rendering the image on the geometry. One easy way to perform this mapping is with a SceneKit shader modifier (see the  protocol). The shader code here applies the coordinate system transformations needed to convert each vertex position in the mesh from 3D scene space to the 2D image space used by the video texture:
```metal
// Transform the vertex to the camera coordinate system.
float4 vertexCamera = scn_node.modelViewTransform * _geometry.position;

// Camera projection and perspective divide to get normalized viewport coordinates (clip space).
float4 vertexClipSpace = scn_frame.projectionTransform * vertexCamera;
vertexClipSpace /= vertexClipSpace.w;

// XY in clip space is [-1,1]x[-1,1], so adjust to UV texture coordinates: [0,1]x[0,1].
// Image coordinates are Y-flipped (upper-left origin).
float4 vertexImageSpace = float4(vertexClipSpace.xy * 0.5 + 0.5, 0.0, 1.0);
vertexImageSpace.y = 1.0 - vertexImageSpace.y;

// Apply ARKit's display transform (device orientation * front-facing camera flip).
float4 transformedVertex = displayTransform * vertexImageSpace;

// Output as texture coordinates for use in later rendering stages.
_geometry.texcoords[0] = transformedVertex.xy;
```

```
When you assign a shader code string to the  entry point, SceneKit configures its renderer to automatically run that code on the GPU for each vertex in the mesh. This shader code also needs to know the intended orientation for the camera image, so the sample gets that from the ARKit  method and passes it to the shader’s `displayTransform` argument:
```swift
// Pass view-appropriate image transform to the shader modifier so
// that the mapped video lines up correctly with the background video.
let affineTransform = frame.displayTransform(for: .portrait, viewportSize: sceneView.bounds.size)
let transform = SCNMatrix4(affineTransform)
faceGeometry.setValue(SCNMatrix4Invert(transform), forKey: "displayTransform")
```

#### 
As a basic demonstration of blend shape animation, this sample includes a simple model of a robot character’s head, created using SceneKit primitive shapes. (See the `robotHead.scn` file in the source code.)
To get the user’s current facial expression, read the  dictionary from the face anchor in the  delegate callback. Then, examine the key-value pairs in that dictionary to calculate animation parameters for your 3D content and update that content accordingly.
```swift
let blendShapes = faceAnchor.blendShapes
guard let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
    let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float,
    let jawOpen = blendShapes[.jawOpen] as? Float
    else { return }
eyeLeftNode.scale.z = 1 - eyeBlinkLeft
eyeRightNode.scale.z = 1 - eyeBlinkRight
jawNode.position.y = originalJawY - jawHeight * jawOpen
```


## Tracking and visualizing planes
> https://developer.apple.com/documentation/arkit/tracking-and-visualizing-planes

### 
### 
### 
The  class provides high-precision motion tracking and enables features to help you place virtual content in relation to real-world surfaces. To start an AR session, create a session configuration object with the options you want (such as plane detection), then call the  method on the  object of your  instance:
```swift
let configuration = ARWorldTrackingConfiguration()
configuration.planeDetection = [.horizontal, .vertical]
sceneView.session.run(configuration)
```

### 
After you’ve set up your AR session, you can use SceneKit to place virtual content in the view.
When plane detection is enabled, ARKit adds and updates anchors for each detected plane. By default, the  class adds an  object to the SceneKit scene for each anchor. Your view’s delegate can implement the  method to add content to the scene. When you add content as a child of the node corresponding to the anchor, the `ARSCNView` class automatically moves that content as ARKit refines its estimate of the plane’s position.
```swift
func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    // Place content only for anchors found by plane detection.
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
    // Create a custom object to visualize the plane geometry and extent.
    let plane = Plane(anchor: planeAnchor, in: sceneView)
    
    // Add the visualization to the ARKit-managed node so that it tracks
    // changes in the plane anchor as plane estimation continues.
    node.addChildNode(plane)
}
```

```
ARKit offers two ways to track the area of an estimated plane. A plane anchor’s  describes a convex polygon tightly enclosing all points that ARKit currently estimates to be part of the same plane (easily visualized using . ARKit also provides a simpler estimate in a plane anchor’s  and ], which together describe a rectangular boundary (easily visualized using .
```swift
// Create a mesh to visualize the estimated shape of the plane.
guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!)
    else { fatalError("Can't create plane geometry") }
meshGeometry.update(from: anchor.geometry)
meshNode = SCNNode(geometry: meshGeometry)

// Create a node to visualize the plane's bounding rectangle.
let extentPlane: SCNPlane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
extentNode = SCNNode(geometry: extentPlane)
extentNode.simdPosition = anchor.center

// `SCNPlane` is vertically oriented in its local coordinate space, so
// rotate it to match the orientation of `ARPlaneAnchor`.
extentNode.eulerAngles.x = -.pi / 2
```

```
ARKit continually updates its estimates of each detected plane’s shape and extent. To show the current estimated shape for each plane, this sample app also implements the  method, updating the  and  objects to reflect the latest information from ARKit.
```swift
func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    // Update only anchors and nodes set up by `renderer(_:didAdd:for:)`.
    guard let planeAnchor = anchor as? ARPlaneAnchor,
        let plane = node.childNodes.first as? Plane
        else { return }
    
    // Update ARSCNPlaneGeometry to the anchor's new estimated shape.
    if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
        planeGeometry.update(from: planeAnchor.geometry)
    }

    // Update extent visualization to the anchor's new bounding rectangle.
    if let extentGeometry = plane.extentNode.geometry as? SCNPlane {
        extentGeometry.width = CGFloat(planeAnchor.extent.x)
        extentGeometry.height = CGFloat(planeAnchor.extent.z)
        plane.extentNode.simdPosition = planeAnchor.center
    }
    
    // Update the plane's classification and the text position
    if #available(iOS 12.0, *),
        let classificationNode = plane.classificationNode,
        let classificationGeometry = classificationNode.geometry as? SCNText {
        let currentClassification = planeAnchor.classification.description
        if let oldClassification = classificationGeometry.string as? String, oldClassification != currentClassification {
            classificationGeometry.string = currentClassification
            classificationNode.centerAlign()
        }
    }
    
}
```

```
On some hardware, ARKit can also classify detected planes, reporting which kind of common real-world surface that plane represents (for example, a table, floor, or wall). In this example, the  method also displays and updates a text label to show that information when running on hardware that supports it.
```swift
// Display the plane's classification, if supported on the device
if #available(iOS 12.0, *), ARPlaneAnchor.isClassificationSupported {
    let classification = anchor.classification.description
    let textNode = self.makeTextNode(classification)
    classificationNode = textNode
    // Change the pivot of the text node to its center
    textNode.centerAlign()
    // Add the classification node as a child node so that it displays the classification
    extentNode.addChildNode(textNode)
}
```


## Tracking geographic locations in AR
> https://developer.apple.com/documentation/arkit/tracking-geographic-locations-in-ar

### 
### 
### 
At the application entry point (see the sample project’s `AppDelegate.swift`), the sample app prevents running an unsupported configuration by checking whether the device supports geotracking.
```swift
if !ARGeoTrackingConfiguration.isSupported {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "unsupportedDeviceMessage")
}
```

### 
### 
This  captures the view mostly from public streets and routes accessible by car. As a result, geotracking doesn’t support areas within the city that are gated or accessible only to pedestrians, as ARKit lacks localization imagery there.
Because localization imagery depicts specific regions on the map, geotracking only supports areas where Apple has collected localization imagery in advance. Before starting a session, the sample project checks whether geotracking supports the user’s location by calling .
```swift
ARGeoTrackingConfiguration.checkAvailability { (available, error) in
    if !available {
        let errorDescription = error?.localizedDescription ?? ""
        let recommendation = "Please try again in an area where geotracking is supported."
        let restartSession = UIAlertAction(title: "Restart Session", style: .default) { (_) in
            self.restartSession()
        }
        self.alertUser(withTitle: "Geotracking unavailable",
                       message: "\(errorDescription)\n\(recommendation)",
                       actions: [restartSession])
    }
}
```

```
ARKit requires a network connection to download localization imagery. The  function will return `false` if a network connection is unavailable. If geotracking is available, the sample project runs a session.
```swift
let geoTrackingConfig = ARGeoTrackingConfiguration()
geoTrackingConfig.planeDetection = [.horizontal]
arView.session.run(geoTrackingConfig, options: .removeExistingAnchors)
```

### 
To begin a geotracking session, the framework undergoes several geotracking states. At any point, the session can require action from the user to progress to the next state. To instruct the user on what to do, the sample project uses a  with the  goal.
```swift
func setupCoachingOverlay() {
    coachingOverlay.delegate = self
    arView.addSubview(coachingOverlay)
    coachingOverlay.goal = .geoTracking
```

### 
After the app localizes and begins a geotracking session, the sample app monitors the geotracking state and instructs the user by presenting text with a label.
```swift
self.trackingStateLabel.text = text
```

As the user moves along a street, the framework continues to download localization imagery as needed to maintain a precise understanding of the user’s position in the world. If the  state reason occurs after the session localized, it may indicate a network issue arose. If this state reason persists for some time, an app may ask the user to check the internet connection.
While the session runs, the status reason  occurs if the user crosses into an area where ARKit lacks geotracking support. To enable the session to continue, the sample project presents text to guide the user back to a supported area.
```swift
case .notAvailableAtLocation: return "Geotracking is unavailable here. Please return to your previous location to continue"
```

### 
- Coaching overlay activates and displays the text: “Slow down”.
The sample app reacts by disabling the user interface until the user complies with the coaching.
```swift
func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    mapView.isUserInteractionEnabled = false
    undoButton.isEnabled = false
    hideUIForCoaching(true)
}
```

```
ARKit dismisses the coaching overlay when the tracking status improves. To resume the user’s ability to interact with the app, the sample project reenables the user interface.
```swift
func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    mapView.isUserInteractionEnabled = true
    undoButton.isEnabled = true
    hideUIForCoaching(false)
}
```

### 
The sample project acquires the user’s geographic coordinate (`CLLocationCoordinate2D`) from the map view at the screen location where the user tapped.
```swift
func handleTapOnMapView(_ sender: UITapGestureRecognizer) {
    let point = sender.location(in: mapView)
    let location = mapView.convert(point, toCoordinateFrom: mapView)
```

```
With the user’s latitude and longitude, the sample project creates a location anchor.
```swift
geoAnchor = ARGeoAnchor(coordinate: location)
```

Because the map view returns a 2D coordinate with no altitude, the sample calls , which defaults the location anchor’s altitude to ground level.
To begin tracking the anchor, the sample project adds it to the session.
```swift
arView.session.add(anchor: geoAnchor)
```

```
The sample project listens for the location anchor in  and visualizes it in AR by adding a placemark entity to the scene.
```swift
func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    for geoAnchor in anchors.compactMap({ $0 as? ARGeoAnchor }) {
        // Effect a spatial-based delay to avoid blocking the main thread.
        DispatchQueue.main.asyncAfter(deadline: .now() + (distanceFromDevice(geoAnchor.coordinate) / 10)) {
            // Add an AR placemark visualization for the geo anchor.
            self.arView.scene.addAnchor(Entity.placemarkEntity(for: geoAnchor))
```

```
To establish visual correspondence in the map view, the sample project adds an  that represents the anchor on the map.
```swift
let anchorIndicator = AnchorIndicator(center: geoAnchor.coordinate)
self.mapView.addOverlay(anchorIndicator)
```

### 
When the user taps the camera feed, the sample project casts a ray at the screen-tap location to determine its intersection with a real-world surface.
```swift
if let result = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .any).first {
```

```
The raycast result’s translation describes the intersection’s position in ARKit’s local coordinate space. To convert that point to a geographic location, the sample project calls the session-provided utility .
```swift
arView.session.getGeoLocation(forPoint: worldPosition) { (location, altitude, error) in
```

### 
To ensure the best possible user experience, an app must monitor and react to the geotracking . When possible, the sample project displays the accuracy as part of its state messaging to the user. The session populates accuracy in its  in state .
```swift
if geoTrackingStatus.state == .localized {
    text += "Accuracy: \(geoTrackingStatus.accuracy.description)"
```

### 
The sample project uses updates from  to center the user in the map view. When the user moves around, Core Location notifies the delegate of any updates in geographic position. The sample project monitors this event by implementing the relevant callback.
```swift
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
```

```
When the user’s position changes, the sample project pans the map to center the user.
```swift
let camera = MKMapCamera(lookingAtCenter: location.coordinate,
                         fromDistance: CLLocationDistance(250),
                         pitch: 0,
                         heading: mapView.camera.heading)
mapView.setCamera(camera, animated: false)
```


## Visualizing and interacting with a reconstructed scene
> https://developer.apple.com/documentation/arkit/visualizing-and-interacting-with-a-reconstructed-scene

### 
### 
To enable scene meshes, the sample sets a world-configuration’s  property to one of the mesh options.
```swift
arView.automaticallyConfigureSession = false
let configuration = ARWorldTrackingConfiguration()
configuration.sceneReconstruction = .meshWithClassification
```

```
The sample uses RealityKit’s  to render its graphics. To visualize meshes at runtime,  offers the  debugging option.
```swift
arView.debugOptions.insert(.showSceneUnderstanding)
```

To begin the AR experience, the sample configures and runs the session when the app first starts, in the main view controller’s `viewDidLoad` callback.
```swift
arView.session.run(configuration)
```

#### 
When an app enables plane detection with scene reconstruction, ARKit considers that information when making the mesh. Where the LiDAR scanner may produce a slightly uneven mesh on a real-world surface, ARKit flattens the mesh where it detects a plane on that surface.
To demonstrate the difference that plane detection makes on meshes, this app displays a toggle button. In the button handler, the sample adjusts the plane-detection configuration and restarts the session to effect the change.
```swift
@IBAction func togglePlaneDetectionButtonPressed(_ button: UIButton) {
    guard let configuration = arView.session.configuration as? ARWorldTrackingConfiguration else {
        return
    }
    if configuration.planeDetection == [] {
        configuration.planeDetection = [.horizontal, .vertical]
        button.setTitle("Stop Plane Detection", for: [])
    } else {
        configuration.planeDetection = []
        button.setTitle("Start Plane Detection", for: [])
    }
    arView.session.run(configuration)
}
```

### 
Apps that retrieve surface locations using meshes can achieve unprecedented accuracy. By considering the mesh, raycasts can intersect with nonplanar surfaces, or surfaces with little or no features, like white walls.
To demonstrate accurate raycast results, this app casts a ray when the user taps the screen. The sample specifies the  allowable-target, and  alignment option, as required to retrieve a point on a meshed, real-world object.
```swift
if let result = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any).first {
    // ...
```

When the user’s raycast returns a result, this app gives visual feedback by placing a small sphere at the intersection point.
```swift
let resultAnchor = AnchorEntity(world: result.worldTransform)
resultAnchor.addChild(sphere(radius: 0.01, color: .lightGray))
arView.scene.addAnchor(resultAnchor, removeAfter: 3)
```

### 
When the  property of  is `true`, RealityKit disables classification by default because it isn’t required for occlusion and physics. To enable mesh classification, the sample overrides the default by setting the  property to .
```swift
arView.automaticallyConfigureSession = false
let configuration = ARWorldTrackingConfiguration()
configuration.sceneReconstruction = .meshWithClassification
```

```
This app attempts to retrieve a classification for the intersection point from the mesh.
```swift
nearbyFaceWithClassification(to: result.worldTransform.position) { (centerOfFace, classification) in
    // ...
```

```
The mesh consists of triangles, called . ARKit assigns a classification for each face, and the app searches through the mesh for a face near the intersection point. If the face has a classification, the app displays it onscreen. Because this routine involves extensive processing, the sample processes the mesh faces asynchronously, so the renderer doesn’t stall.
```swift
DispatchQueue.global().async {
    for anchor in meshAnchors {
        for index in 0..<anchor.geometry.faces.count {
            // Get the center of the face so that we can compare it to the given location.
            let geometricCenterOfFace = anchor.geometry.centerOf(faceWithIndex: index)
            
            // Convert the face's center to world coordinates.
            var centerLocalTransform = matrix_identity_float4x4
            centerLocalTransform.columns.3 = SIMD4<Float>(geometricCenterOfFace.0, geometricCenterOfFace.1, geometricCenterOfFace.2, 1)
            let centerWorldPosition = (anchor.transform * centerLocalTransform).position
             
            // We're interested in a classification that is sufficiently close to the given location––within 5 cm.
            let distanceToFace = distance(centerWorldPosition, location)
            if distanceToFace <= 0.05 {
                // Get the semantic classification of the face and finish the search.
                let classification: ARMeshClassification = anchor.geometry.classificationOf(faceWithIndex: index)
                completionBlock(centerWorldPosition, classification)
                return
            }
        }
    }
```

```
With the classification in-hand, the sample creates 3D text to display it.
```swift
let textEntity = self.model(for: classification)
```

```
To prevent the mesh from partially occluding the text, the sample offsets the text slightly to help readability. The sample calculates the offset in the negative direction of the ray, which effectively moves the text slightly toward the camera, which is away from the surface.
```swift
let rayDirection = normalize(result.worldTransform.position - self.arView.cameraTransform.translation)
let textPositionInWorldCoordinates = result.worldTransform.position - (rayDirection * 0.1)
```

```
To make the text always appear the same size on screen, the sample applies a scale based on text’s distance from the camera.
```swift
let raycastDistance = distance(result.worldTransform.position, self.arView.cameraTransform.translation)
textEntity.scale = .one * raycastDistance
```

```
To display the text, the sample puts it in an anchored entity at the adjusted intersection-point, which is oriented to face the camera.
```swift
var resultWithCameraOrientation = self.arView.cameraTransform
resultWithCameraOrientation.translation = textPositionInWorldCoordinates
let textAnchor = AnchorEntity(world: resultWithCameraOrientation.matrix)
textAnchor.addChild(textEntity)
self.arView.scene.addAnchor(textAnchor, removeAfter: 3)
```

```
To visualize the location of the face’s vertex from which the classification was retrieved, the sample creates a small sphere at the vertex’s real-world position.
```swift
if let centerOfFace = centerOfFace {
    let faceAnchor = AnchorEntity(world: centerOfFace)
    faceAnchor.addChild(self.sphere(radius: 0.01, color: classification.color))
    self.arView.scene.addAnchor(faceAnchor, removeAfter: 3)
    // ...
}
```

#### 
 is a feature where parts of the real world cover an app’s virtual content, from the camera’s perspective. To achieve this illusion, RealityKit checks for any meshes in front of virtual content, viewed by the user, and omits drawing any part of the virtual content obscured by those meshes. The sample enables occlusion by adding the  option to the environment’s  property.
```swift
arView.environment.sceneUnderstanding.options.insert(.occlusion)
```

#### 
With scene meshes, virtual content can interact with the physical environment realistically because the meshes give RealityKit’s physics engine an accurate model of the world. The sample enables physics by adding the  option to the environment’s  property.
```swift
arView.environment.sceneUnderstanding.options.insert(.physics)
```

```
To detect when virtual content comes in contact with a meshed, real-world object, the sample defines the text’s proportions using a collision shape in the `addAnchor(_:,removeAfter:)`  extension.
```swift
if model.collision == nil {
    model.generateCollisionShapes(recursive: true)
    model.physicsBody = .init()
}
```

```
When this app classifies an object and displays some text, it waits three seconds before dropping the virtual text. When the sample sets the text’s ’s  to , the text reacts to gravity by falling.
```swift
Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { (timer) in
    model.physicsBody?.mode = .dynamic
}
```


