# Apple AVFOUNDATION Skill


## AVCam: Building a camera app
> https://developer.apple.com/documentation/avfoundation/avcam-building-a-camera-app

### 
#### 
#### 
The capture service performs the session configuration in its `setUpSession()` method. It retrieves the default camera and microphone for the host device and adds them as inputs to the capture session.
```swift
// Retrieve the default camera and microphone.
let defaultCamera = try deviceLookup.defaultCamera
let defaultMic = try deviceLookup.defaultMic

// Add inputs for the default camera and microphone devices.
activeVideoInput = try addInput(for: defaultCamera)
try addInput(for: defaultMic)
```

```
To add the inputs, it uses a helper method that creates a new  for the specified camera or microphone device and adds it to the capture session, if possible.
```swift
// Adds an input to the capture session to connect the specified capture device.
@discardableResult
private func addInput(for device: AVCaptureDevice) throws -> AVCaptureDeviceInput {
    let input = try AVCaptureDeviceInput(device: device)
    if captureSession.canAddInput(input) {
        captureSession.addInput(input)
    } else {
        throw CameraError.addInputFailed
    }
    return input
}
```

```
After adding the device inputs, the method configures the capture session for the app’s default photo capture mode. It optimizes the pipeline for high-resolution photo quality output by setting the capture session’s  preset. Finally, to enable the app to capture photos, it adds an  instance to the session.
```swift
// Configure the session for photo capture by default.
captureSession.sessionPreset = .photo

// Add the photo capture output as the default output type.
if captureSession.canAddOutput(photoCapture.output) {
    captureSession.addOutput(photoCapture.output)
} else {
    throw CameraError.addOutputFailed
}
```

#### 
To preview the content a camera is capturing, AVFoundation provides a Core Animation layer subclass called  . SwiftUI doesn’t support using layers directly, so instead, the app hosts this layer in a  subclass called `PreviewView`. It overrides the  property to make the preview layer the backing for the view.
```swift
class PreviewView: UIView, PreviewTarget {
    
    // Use `AVCaptureVideoPreviewLayer` as the view's backing layer.
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    func setSession(_ session: AVCaptureSession) {
        // Connects the session with the preview layer, which allows the layer
        // to provide a live view of the captured content.
        previewLayer.session = session
    }
}
```

To make this view accessible to SwiftUI, the app wraps it as a  type called `CameraPreview`.
```
To make this view accessible to SwiftUI, the app wraps it as a  type called `CameraPreview`.
```swift
struct CameraPreview: UIViewRepresentable {
    
    private let source: PreviewSource
    
    init(source: PreviewSource) {
        self.source = source
    }
    
    func makeUIView(context: Context) -> PreviewView {
        let preview = PreviewView()
        // Connect the preview layer to the capture session.
        source.connect(to: preview)
        return preview
    }
    
    func updateUIView(_ previewView: PreviewView, context: Context) {
        // No implementation needed.
    }
}
```

#### 
The initial capture configuration is complete, but before the app can successfully start the capture session, it needs to determine whether it has authorization to use device inputs. The system requires that a person explicitly authorize the app to capture input from cameras and microphones. To determine the app’s status, the capture service defines an asynchronous `isAuthorized` property as follows:
```swift
var isAuthorized: Bool {
    get async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        // Determine whether a person previously authorized camera access.
        var isAuthorized = status == .authorized
        // If the system hasn't determined their authorization status,
        // explicitly prompt them for approval.
        if status == .notDetermined {
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        }
        return isAuthorized
    }
}
```

#### 
The app starts in photo capture mode. Changing modes requires a reconfiguration of the capture session as follows:
```swift
func setCaptureMode(_ captureMode: CaptureMode) throws {
    
    self.captureMode = captureMode
    
    // Change the configuration atomically.
    captureSession.beginConfiguration()
    defer { captureSession.commitConfiguration() }
    
    // Configure the capture session for the selected capture mode.
    switch captureMode {
    case .photo:
        // The app needs to remove the movie capture output to perform Live Photo capture.
        captureSession.sessionPreset = .photo
        captureSession.removeOutput(movieCapture.output)
    case .video:
        captureSession.sessionPreset = .high
        try addOutput(movieCapture.output)
    }

    // Update the advertised capabilities after reconfiguration.
    updateCaptureCapabilities()
}
```

#### 
The app provides a button that lets people switch between the front and back cameras and, in iPadOS, connected external cameras. To change the active camera, the app reconfigures the session as follows:
```swift
// Changes the device the service uses for video capture.
private func changeCaptureDevice(to device: AVCaptureDevice) {
    // The service must have a valid video input prior to calling this method.
    guard let currentInput = activeVideoInput else { fatalError() }
    
    // Bracket the following configuration in a begin/commit configuration pair.
    captureSession.beginConfiguration()
    defer { captureSession.commitConfiguration() }
    
    // Remove the existing video input before attempting to connect a new one.
    captureSession.removeInput(currentInput)
    do {
        // Attempt to connect a new input and device to the capture session.
        activeVideoInput = try addInput(for: device)
        // Configure a new rotation coordinator for the new device.
        createRotationCoordinator(for: device)
        // Register for device observations.
        observeSubjectAreaChanges(of: device)
        // Update the service's advertised capabilities.
        updateCaptureCapabilities()
    } catch {
        // Reconnect the existing camera on failure.
        captureSession.addInput(currentInput)
    }
}
```

#### 
The capture service delegates handling of the app’s photo capture features to the `PhotoCapture` object, which manages the life cycle of and interaction with an . The app captures photos with this object by calling its  method, passing it an object that describes photo capture settings to enable and a delegate for the system to call as capture proceeds. To use this delegate-based API in an `async` context , the app wraps this call with a checked throwing continuation as follows:
```swift
/// The app calls this method when the user taps the photo capture button.
func capturePhoto(with features: EnabledPhotoFeatures) async throws -> Photo {
    // Wrap the delegate-based capture API in a continuation to use it in an async context.
    try await withCheckedThrowingContinuation { continuation in
        
        // Create a settings object to configure the photo capture.
        let photoSettings = createPhotoSettings(with: features)
        
        let delegate = PhotoCaptureDelegate(continuation: continuation)
        monitorProgress(of: delegate)
        
        // Capture a new photo with the specified settings.
        photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
    }
}
```

```
When the system finishes capturing a photo, it calls the delegate’s  method. The delegate object’s implementation of this method uses the continuation to resume execution by returning a photo or throwing an error.
```swift
func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {

    // If an error occurs, resume the continuation by throwing an error, and return.
    if let error {
        continuation.resume(throwing: error)
        return
    }
    
    /// Create a photo object to save to the `MediaLibrary`.
    let photo = Photo(data: photoData, isProxy: isProxyPhoto, livePhotoMovieURL: livePhotoMovieURL)
    // Resume the continuation by returning the captured photo.
    continuation.resume(returning: photo)
}
```

#### 
The capture service delegates handling of the app’s video capture features to the `MovieCapture` object, which manages the life cycle of and interaction with an . To start recording a movie, the app calls the movie file output’s  method, which takes a URL to write the move to and a delegate for the system to call when recording completes.
```swift
/// Starts movie recording.
func startRecording() {
    // Return early if already recording.
    guard !movieOutput.isRecording else { return }

    // Start a timer to update the recording time.
    startMonitoringDuration()
    
    delegate = MovieCaptureDelegate()
    movieOutput.startRecording(to: URL.movieFileURL, recordingDelegate: delegate!)
}
```

```
To finish recording the video, the app calls the movie file output’s  method, which causes the system to call the delegate to handle the captured output. To adapt this delegate-based callback, the app wraps this interaction in a checked throwing continuation as follows:
```swift
/// Stops movie recording.
/// - Returns: A `Movie` object that represents the captured movie.
func stopRecording() async throws -> Movie {
    // Use a continuation to adapt the delegate-based capture API to an async interface.
    return try await withCheckedThrowingContinuation { continuation in
        // Set the continuation on the delegate to handle the capture result.
        delegate?.continuation = continuation
        
        /// Stops recording, which causes the output to call the `MovieCaptureDelegate` object.
        movieOutput.stopRecording()
        stopMonitoringDuration()
    }
}
```

```
When the app calls the movie file output’s  method, the system calls the delegate, which resumes execution either by returning a movie or throwing an error.
```swift
func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    if let error {
        // If an error occurs, throw it to the caller.
        continuation?.resume(throwing: error)
    } else {
        // Return a new movie object.
        continuation?.resume(returning: Movie(url: outputFileURL))
    }
}
```


## AVCamFilter: Applying filters to a capture stream
> https://developer.apple.com/documentation/avfoundation/avcamfilter-applying-filters-to-a-capture-stream

### 
#### 
#### 
AVCamFilter uses `PreviewMetalView`, a custom subclass of , instead of a  as its preview view, because the standard  gets its frames directly from the , with no opportunity for the app to apply effects to those frames. By subclassing `MTKView`, AVCamFilter can apply the rose-colored filter and depth grayscale filter before rendering each frame.
The `PreviewMetalView` defines its rendering behavior in `draw`. It creates a Metal texture from the image buffer, so it can transform and render that texture to the image:
```swift
let width = CVPixelBufferGetWidth(previewPixelBuffer)
let height = CVPixelBufferGetHeight(previewPixelBuffer)

if textureCache == nil {
    createTextureCache()
}
var cvTextureOut: CVMetalTexture?
CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                          textureCache!,
                                          previewPixelBuffer,
                                          nil,
                                          .bgra8Unorm,
                                          width,
                                          height,
                                          0,
                                          &cvTextureOut)
```

#### 
The custom `FilterRenderer` class serves as the parent for all rendering classes, such as the rose-colored filter and the grayscale converter. `RosyMetalRenderer` and `DepthToGrayscaleConverter` are both subclasses of `FilterRenderer` which provide specific filtering functionality.
`FilterRenderer` encapsulates all the resources and functions necessary to render an effect to the image. For example, it allocates a pool of output buffers for rendering:
```swift
var pixelBuffers = [CVPixelBuffer]()
var error: CVReturn = kCVReturnSuccess
let auxAttributes = [kCVPixelBufferPoolAllocationThresholdKey as String: allocationThreshold] as NSDictionary
var pixelBuffer: CVPixelBuffer?
while error == kCVReturnSuccess {
    error = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, pool, auxAttributes, &pixelBuffer)
    if let pixelBuffer = pixelBuffer {
        pixelBuffers.append(pixelBuffer)
    }
    pixelBuffer = nil
}
pixelBuffers.removeAll()
```

```
`FilterRenderer` also maintains a retained buffer count to tell renderers how many buffers it can hold at one time. This hint prepares the renderer to size and preallocate its pool before beginning to render the scene:
```swift
func prepare(with inputFormatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int)

// Release resources.
func reset()

// The format description of the output pixel buffers.
var outputFormatDescription: CMFormatDescription? { get }

// The format description of the input pixel buffers.
var inputFormatDescription: CMFormatDescription? { get }

// Render the pixel buffer.
func render(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer?
```

#### 
- `RosyCIRenderer` applies a Core Image  filter to the input buffer.
- `RosyMetalRenderer` creates a Metal texture from the image buffer and applies the shader in `RosyEffect.metal`.
- `RosyMetalRenderer` creates a Metal texture from the image buffer and applies the shader in `RosyEffect.metal`.
Both approaches run on the GPU for optimal performance. Because the Core Image approach doesn’t require GPU command queues, `RosyCIRenderer` involves less direct manipulation of the GPU than its Metal counterpart and chains more seamlessly with other Core Image filters. Unlike the Metal function, `RosyCIRenderer` requires the creation and application of a :
```swift
ciContext = CIContext()
rosyFilter = CIFilter(name: "CIColorMatrix")
rosyFilter!.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
```

```
In the Metal approach, AVCamFilter sets up a command queue and thread groups to do the rendering:
```swift
guard let inputTexture = makeTextureFromCVPixelBuffer(pixelBuffer: pixelBuffer, textureFormat: .bgra8Unorm),
    let outputTexture = makeTextureFromCVPixelBuffer(pixelBuffer: outputPixelBuffer, textureFormat: .bgra8Unorm) else {
        return nil
}

// Set up command queue, buffer, and encoder.
guard let commandQueue = commandQueue,
    let commandBuffer = commandQueue.makeCommandBuffer(),
    let commandEncoder = commandBuffer.makeComputeCommandEncoder() else {
        print("Failed to create a Metal command queue.")
        CVMetalTextureCacheFlush(textureCache!, 0)
        return nil
}

commandEncoder.label = "Rosy Metal"
commandEncoder.setComputePipelineState(computePipelineState!)
commandEncoder.setTexture(inputTexture, index: 0)
commandEncoder.setTexture(outputTexture, index: 1)

// Set up the thread groups.
let width = computePipelineState!.threadExecutionWidth
let height = computePipelineState!.maxTotalThreadsPerThreadgroup / width
let threadsPerThreadgroup = MTLSizeMake(width, height, 1)
let threadgroupsPerGrid = MTLSize(width: (inputTexture.width + width - 1) / width,
                                  height: (inputTexture.height + height - 1) / height,
                                  depth: 1)
commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

commandEncoder.endEncoding()
commandBuffer.commit()
```

```
The function, `RosyEffect.metal`, sets the output color of a pixel to its input color, so most of the image content remains the same, resulting in a transparent effect. However, the kernel excludes the green component, giving the image a rose-colored appearance:
```None
kernel void rosyEffect(texture2d<half, access::read>  inputTexture  [[ texture(0) ]],
					   texture2d<half, access::write> outputTexture [[ texture(1) ]],
					   uint2 gid [[thread_position_in_grid]])
{
    // Don't read or write outside of the texture.
    if ((gid.x >= inputTexture.get_width()) || (gid.y >= inputTexture.get_height())) {
        return;
    }

    half4 inputColor = inputTexture.read(gid);

    // Set the output color to the input color, excluding the green component.
    half4 outputColor = half4(inputColor.r, 0.0, inputColor.b, 1.0);

    outputTexture.write(outputColor, gid);
}
```

#### 
When the user tweaks the “MixFactor” slider, AVCamFilter modulates the intensity of the filter’s mixture:
```swift
dataOutputQueue.async {
    self.videoDepthMixer.mixFactor = mixFactor
}
processingQueue.async {
    self.photoDepthMixer.mixFactor = mixFactor
}
```

```
The sample accomplishes this in code by setting the mix parameter in `VideoMixer.swift`. This helper class marshals mixing commands in a command queue, buffer, and encoder. When the mix factor changes, the rendering pipeline pulls in those changes by varying the bytes in a rendered fragment:
```swift
var parameters = MixerParameters(mixFactor: mixFactor)

commandEncoder.label = "Video Mixer"
commandEncoder.setRenderPipelineState(renderPipelineState!)
commandEncoder.setVertexBuffer(fullRangeVertexBuffer, offset: 0, index: 0)
commandEncoder.setFragmentTexture(inputTexture0, index: 0)
commandEncoder.setFragmentTexture(inputTexture1, index: 1)
commandEncoder.setFragmentSamplerState(sampler, index: 0)
withUnsafeMutablePointer(to: &parameters) { parametersRawPointer in
    commandEncoder.setFragmentBytes(parametersRawPointer, length: MemoryLayout<MixerParameters>.size, index: 0)
}
commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
commandEncoder.endEncoding()
```

The Metal function, `Mixer.metal`, specifies the mixing operation for each fragment:
```
The Metal function, `Mixer.metal`, specifies the mixing operation for each fragment:
```None
fragment half4 fragmentMixer( VertexIO        inputFragment    [[ stage_in ]],
                              texture2d<half> mixerInput0      [[ texture(0) ]],
                              texture2d<half> mixerInput1      [[ texture(1) ]],
                              const device    mixerParameters& mixerParameters [[ buffer(0) ]],
                              sampler         samplr           [[ sampler(0) ]])
{
    half4 input0 = mixerInput0.sample(samplr, inputFragment.textureCoord);
    half4 input1 = mixerInput1.sample(samplr, inputFragment.textureCoord);

    half4 output = mix(input0, input1, half(mixerParameters.mixFactor));

    return output;
}
```

#### 
AVCamFilter streams depth data in addition to RGB video by maintaining buffers dedicated to depth information. The `CameraViewController` refreshes these buffers by adhering to the  protocol and implementing the delegate method :
```swift
var depthFormatDescription: CMFormatDescription?
CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                             imageBuffer: depthData.depthDataMap,
                                             formatDescriptionOut: &depthFormatDescription)
if let unwrappedDepthFormatDescription = depthFormatDescription {
    videoDepthConverter.prepare(with: unwrappedDepthFormatDescription, outputRetainedBufferCountHint: 2)
}
```

`outputRetainedBufferCountHint` is the number of pixel buffers the renderer retains as it draws the scene. AVCamFilter’s depth converter preallocates its buffers with an `outputRetainedBufferCountHint` of 2 frames of latency to cover the `dispatch_async` call.
The `DepthToGrayscaleConverter` class converts depth values to grayscale pixels in the preview. Like the rose-colored filter, `DepthToGrayscaleConverter` relies on a Metal function, `DepthToGrayscale.metal`, to perform texture transformations:
```None
kernel void depthToGrayscale(texture2d<float, access::read> inputTexture   [[ texture(0) ]],
						                 texture2d<float, access::write> outputTexture [[ texture(1) ]],
                             constant converterParameters& converterParameters [[ buffer(0) ]],
                             uint2 gid [[ thread_position_in_grid ]])
{
    // Don't read or write outside of the texture.
    if ((gid.x >= inputTexture.get_width()) || (gid.y >= inputTexture.get_height())) {
        return;
    }

    float depth = inputTexture.read(gid).x;

    // Normalize the value between 0 and 1.
    depth = (depth - converterParameters.offset) / (converterParameters.range);

    float4 outputColor = float4(float3(depth), 1.0);

    outputTexture.write(outputColor, gid);
}
```

#### 
Without smoothing, the depth data in each frame may have gaps or holes. Smoothing the depth data reduces the effect of frame-to-frame discrepancies by interpolating previous and subsequent frames to fill in the holes. To achieve this smoothing in code, set a parameter on :
```swift
sessionQueue.async {
    self.depthDataOutput.isFilteringEnabled = smoothingEnabled
}
```

#### 
AVCamFilter also shows how to change the frame rate at which the camera delivers depth data. When the user moves the “FPS” (frames per second) slider, the app converts this user-facing representation of frame rate to its inverse, frame duration, for setting the video device’s   accordingly:
```swift
try self.videoInput.device.lockForConfiguration()
self.videoInput.device.activeDepthDataMinFrameDuration = duration
self.videoInput.device.unlockForConfiguration()
```


## Adding a display mask rectangle metadata track to a movie file
> https://developer.apple.com/documentation/avfoundation/adding-a-display-mask-rectangle-metadata-track-to-a-movie-file

### 
### 
The sample requires three arguments:
```bash
./AVAddDisplayMaskTrack <input-path> <output-path> <display-mask-type>
```

The `display-mask-type` argument indicates the display mask to write to the movie file:
### 
The sample provides a `MovieProcessor` class that contains the app’s metadata processing logic. When you run the app, it passes the command-line arguments you specify to the `MovieProcessor` class’s `processMovie(inputPath:outputPath:displayMaskType:)` method. This method sets up the reading and writing functionality using  and , respectively.
To allow the app to append metadata during asset writing, this method calls `addDisplayMaskMetadataTrack(to:videoInput:videoInfo:)` to create an  that writes a timed metadata track for the display mask rectangle. Before creating the writer input, this method creates a  for the display mask metadata. The format description uses the boxed metadata (`mebx`) type and pairs the  identifier with the  data type:
```swift
// Define the metadata specifications for the monoscopic display mask rectangle.
let metadataSpecifications: [[String: Any]] = [[
    kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as String:
        kCMMetadataIdentifier_QuickTimeMetadataDisplayMaskRectangleMono as String,
    kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as String:
        kCMMetadataBaseDataType_RasterRectangleValue as String
]]

// Create the `CMMetadataFormatDescription` for the monoscopic display mask rectangle
// in boxed metadata (`mebx`) type.
var metadataFormatDesc: CMMetadataFormatDescription? = nil
let status = CMMetadataFormatDescriptionCreateWithMetadataSpecifications(
    allocator: kCFAllocatorDefault,
    metadataType: kCMMetadataFormatType_Boxed,
    metadataSpecifications: metadataSpecifications as CFArray,
    formatDescriptionOut: &metadataFormatDesc
)
```

With the format description in place, the method creates an  for the metadata track. It sets  to `false` because the app writes metadata samples as fast as it can process them, rather than receiving them from a live capture source. It also sets the  to match the video track to align the metadata sample timestamps precisely with the video frames:
```swift
// Create the `AVAssetWriterInput` for the display mask metadata track and attach it to `AVAssetWriter`.
metadataInput = AVAssetWriterInput(mediaType: .metadata, outputSettings: nil, sourceFormatHint: metadataFormatDesc)
guard let metadataInput else {
    throw ProcessingError.writerInputCreationFailed("DisplayMask metadata.")
}

metadataInput.expectsMediaDataInRealTime = false
metadataInput.mediaTimeScale = videoInfo.timescale
```

```
The method then creates an  to append timed metadata groups to the writer input. The adaptor provides a convenient way to write  objects, which package metadata items with their time ranges, rather than working directly with sample buffers:
```swift
// Create the metadata adaptor for the display mask metadata's `AVAssetWriterInput`.
metadataAdaptor = AVAssetWriterInputMetadataAdaptor(assetWriterInput: metadataInput)
```

```
Finally, the method adds the metadata input to the asset writer and establishes a track association between the metadata track and the video track. The render metadata source association (`rndr`) is required so the playback system knows which video track the display mask metadata applies to. The playback system ignores this metadata when this association doesn’t exist.
```swift
if writer.canAdd(metadataInput) {
    writer.add(metadataInput)

    // Add the `rndr` track association between the display mask metadata track and
    // the enabled video track.
    metadataInput.addTrackAssociation(withTrackOf: videoInput, type: AVAssetTrack.AssociationType.renderMetadataSource.rawValue)
} else {
    throw ProcessingError.cannotAddWriterInput("DisplayMask metadata.")
}
```

### 
To see the specific calculations each path uses, see `MovieProcessor.swift` file in the sample project and look at `Type 1 static display mask calculation.` and `Type 2 dynamic display mask initialization/update calculation.` marks.
Despite writing different metadata, both paths follow a similar pattern. They request data from the metadata input when it’s ready, create a timed metadata group for the display mask rectangle, and append it to the metadata adaptor:
```swift
metadataInput.requestMediaDataWhenReady(on: queue) {
    while metadataInput.isReadyForMoreMediaData {
        let rasterRectangle = // Calculate the raster rectangle parameters for this media sample.

        // Create the timed metadata group and append it.
        let metadataGroup = self.createMetadataGroupForDisplayMask(
            rasterRectangle: rasterRectangle,
            sampleTime: sampleTime,
            sampleDuration: sampleDuration
        )
        // Append the metadata group.
        metadataAdaptor.append(metadataGroup)
    }
}
```

The `createMetadataGroupForDisplayMask(rasterRectangle:sampleTime:sampleDuration:)` method creates the timed metadata group:
```
The `createMetadataGroupForDisplayMask(rasterRectangle:sampleTime:sampleDuration:)` method creates the timed metadata group:
```swift
private func createMetadataGroupForDisplayMask(rasterRectangle: [Int],
                sampleTime: CMTime, sampleDuration: CMTime) -> AVTimedMetadataGroup {
    let metadataItem = AVMutableMetadataItem()
    metadataItem.identifier = AVMetadataIdentifier(
        kCMMetadataIdentifier_QuickTimeMetadataDisplayMaskRectangleMono as String)
    metadataItem.value = rasterRectangle as NSArray
    metadataItem.dataType = kCMMetadataBaseDataType_RasterRectangleValue as String

    // Wrap the metadata item in `AVTimedMetadataGroup`.
    let timedMetadataGroup = AVTimedMetadataGroup(
        items: [metadataItem],
        timeRange: CMTimeRange(start: sampleTime, duration: sampleDuration)
    )

    return timedMetadataGroup
}
```


## Adopting smart framing in your camera app
> https://developer.apple.com/documentation/avfoundation/adopting-smart-framing-in-your-camera-app

### 
### 
Start by verifying whether the person’s device supports smart framing:
```swift
func findAndConfigureSmartFramingDevice() -> AVCaptureDevice? {
    // Configure the discovery session to find an Ultra Wide front camera.
    let discoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInUltraWideCamera],
        mediaType: .video,
        position: .front
    )

    // Find the first matching device and format that supports smart framing.
    guard let device = discoverySession.devices.first,
          let format = device.formats.first(where: \.isSmartFramingSupported) else {
        // Return nil if the device doesn't have an Ultra Wide front camera.
        return nil
    }

    if device.activeFormat.isSmartFramingSupported {
        // Return the device if already configured for smart framing.
        return device
    } else {
        // Otherwise, attempt to configure the device and return it, if successful.
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            // Set the smart framing format as active.
            device.activeFormat = format
            return device
        } catch {
            return nil
        }
    }
}
```

### 
After finding a supported capture device, configure its monitoring behavior by accessing the device’s associated  object:
```swift
func configureSmartFraming() async {
    // Access the smart framing monitor, if available.
    guard let monitor = currentDevice?.smartFramingMonitor else { return }
    // Enable all supported framings.
    monitor.enabledFramings = monitor.supportedFramings
}
```

### 
With the smart framing monitor configured, it’s ready to start generating framing recommendations. To respond to new recommendations, key-value observe the monitor’s  property like shown below:
```swift
func startMonitoring() async {
    // Return early if the monitor doesn't exist or is currently monitoring.
    guard let monitor = currentDevice?.smartFramingMonitor, !monitor.isMonitoring else { return }

    // Key-value observe changes to the monitor's framing recommendations.
    framingObservation = monitor.observe(\.recommendedFraming, options: [.new]) { [weak self] monitor, change in
        // Access the recommended framing.
        guard let self, let framing = monitor.recommendedFraming else { return }
        // Configure the device with the latest recommendation.
        Task { await self.applyRecommendedFraming(framing) }
    }

    do {
        // Start monitoring for framing recommendations.
        try monitor.startMonitoring()
    } catch {
        logger.error("Unable to start monitoring: \(error)")
    }
}
```

The code example configures an observer to respond to new framing recommendations. When it observes a new value, it calls a method to apply the framing to the capture device. After configuring the observer, the example calls the monitor’s   method to generate framing recommendations.
To disable smart framing, and allow a person to manually frame their shot, invalidate your key-value observation and call the monitor’s  method, as shown here:
```swift
func stopMonitoring() async {
    // Stop key-value observing the monitor.
    framingObservation?.invalidate()
    framingObservation = nil

    guard let monitor = currentDevice?.smartFramingMonitor else { return }
    // Stop monitoring for smart framing recommendations.
    monitor.stopMonitoring()
}
```

### 
When the monitor generates new framing recommendations, apply them by setting the device’s dynamic aspect ratio and video zoom factor as follows:
```swift
private func applyRecommendedFraming(_ framing: AVCaptureFraming) async {
    guard let device = currentDevice else { return }
    do {
        // Request exclusive control of the device.
        try device.lockForConfiguration()
        do {
            // Set the recommended aspect ratio and zoom factor.
            try await device.setDynamicAspectRatio(framing.aspectRatio)
            device.videoZoomFactor = CGFloat(framing.zoomFactor)
        } catch {
            logger.error("Failed to set aspect ratio: \(error)")
        }
        // Release exclusive control of the device.
        device.unlockForConfiguration()
    } catch {
        logger.error("Failed to lock device for configuration: \(error)")
    }
}
```


## Capturing a bracketed photo sequence
> https://developer.apple.com/documentation/avfoundation/capturing-a-bracketed-photo-sequence

### 
#### 
- Use  to create a bracket with custom exposure durations and ISO sensitivity values for each photo in the bracket.
To define a bracket, create an array of one of these types, with values that describe the settings variations you want to capture. For example, the code below defines a bracket that captures three images at three different exposure values.
```swift
// Get AVCaptureBracketedStillImageSettings for a set of exposure values.
let exposureValues: [Float] = [-2, 0, +2]
let makeAutoExposureSettings = AVCaptureAutoExposureBracketedStillImageSettings.autoExposureSettings(exposureTargetBias:)
let exposureSettings = exposureValues.map(makeAutoExposureSettings)

```

#### 
Instead of the  object you create when shooting a single photo, to shoot a bracketed capture you’ll need an  object. This object combines the general settings that apply to all photos in the bracket with your bracket settings that specify how each photo differs from the rest of the bracket.
As with single-image capture, you create a photo settings object by choosing the image codec and file format for the resulting photos, but you also provide the bracket settings you’ve chosen.
```swift
// Create photo settings for HEIF/HEVC capture and no RAW output
// and enable cross-bracket image stabilization.
let photoSettings = AVCapturePhotoBracketSettings(rawPixelFormatType: 0,
    processedFormat: [AVVideoCodecKey : AVVideoCodecType.hevc],
    bracketedSettings: exposureSettings)
photoSettings.isLensStabilizationEnabled =
    self.photoOutput.isLensStabilizationDuringBracketedCaptureSupported

// Shoot the bracket, using a custom class to handle capture delegate callbacks.
let captureProcessor = PhotoCaptureProcessor()
self.photoOutput.capturePhoto(with: photoSettings, delegate: captureProcessor)

```

#### 

## Capturing and saving Live Photos
> https://developer.apple.com/documentation/avfoundation/capturing-and-saving-live-photos

### 
#### 
For a still photo your capture session needs only a video input, but a Live Photo includes sound, so you’ll need to also connect an audio capture device to your session:
```swift
enum CameraError: Error {
    case configurationFailed
    // ... additional error cases ...
}

func configureSession() throws {
    captureSession.beginConfiguration()
    
    // ... add camera input and photo output ...
    
    guard let audioDevice = AVCaptureDevice.default(for: .audio),
          let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice) else {
              throw CameraError.configurationFailed
    }
    
    if captureSession.canAddInput(audioDeviceInput) {
        captureSession.addInput(audioDeviceInput)
    } else {
        throw CameraError.configurationFailed
    }
    
    // ... configure photo output and start running ...
    
    captureSession.commitConfiguration()
}
```

Because you’re already using a built-in camera device for video (see ), you can simply use the default audio capture device—the system automatically uses the best microphone configuration for the camera position.
Capturing Live Photos requires an internal reconfiguration of the capture pipeline, which takes time and interrupts any in-progress captures. Before shooting your first Live Photo, make sure you’ve configured the pipeline appropriately by enabling Live Photo capture on your  object:
```swift
let photoOutput = AVCapturePhotoOutput()

// Attempt to add the photo output to the session.
if captureSession.canAddOutput(photoOutput) {
    captureSession.sessionPreset = .photo
    captureSession.addOutput(photoOutput)
} else {
    throw CameraError.configurationFailed
}

// Configure the photo output's behavior.
photoOutput.isHighResolutionCaptureEnabled = true
photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported

// Start the capture session.
captureSession.startRunning()
```

#### 
Once your photo output is ready for Live Photos, you can choose still image or Live Photo capture for each shot. To capture a Live Photo, create an  object, choosing the format for the still image portion of the Live Photo and providing a URL for writing the movie portion of the Live Photo. Then, call  to trigger capture:
```swift
let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
photoSettings.livePhotoMovieFileURL = // output url

// Shoot the Live Photo, using a custom class to handle capture delegate callbacks.
let captureProcessor = LivePhotoCaptureProcessor()
photoOutput.capturePhoto(with: photoSettings, delegate: captureProcessor)
```

#### 
A Live Photo appears to users in the Photos app as a single asset, but it’s actually composed of separate files: the primary still image, and a movie file containing motion and sound from the moments before and after. The capture system delivers these results separately, as soon as each becomes available.
The  method delivers the still image portion of the Live Photo as an  object. Because you’ll need to save the still image and movie files together, it’s best to extract the image file data from the  and keep it until the movie file finishes recording, as shown below. (You can also use this method to indicate in your UI that the still image has been captured.)
```swift
func photoOutput(_ output: AVCapturePhotoOutput,
                 didFinishProcessingPhoto photo: AVCapturePhoto,
                 error: Error?) {
    guard error != nil else {
        print("Error capturing Live Photo still: \(error!)");
        return
    }
    
    // Get and process the captured image data.
    processImage(photo.fileDataRepresentation())
}
```

```
The  method fires later, indicating that the URL you specified when triggering the capture now contains a complete movie file. Once you have both the still image and movie portions of your Live Photo, you can save them together:
```swift
func photoOutput(_ output: AVCapturePhotoOutput,
                 didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL,
                 duration: CMTime,
                 photoDisplayTime: CMTime,
                 resolvedSettings: AVCaptureResolvedPhotoSettings,
                 error: Error?) {
    
    guard error != nil else {
        print("Error capturing Live Photo movie: \(error!)");
        return
    }
    
    guard let stillImageData = stillImageData else { return }
    
    // Save Live Photo.
    saveLivePhotoToPhotosLibrary(stillImageData: stillImageData,
                                 livePhotoMovieURL: outputFileURL)
}
```

#### 
Use the  class to create a single Photos asset consisting of media from multiple files—in the case of a Live Photo, the still image and its paired video. As in , you’ll need to wrap that request in a  change block, and first make sure that your app has the user’s permission to access Photos.
```swift
func saveLivePhotoToPhotosLibrary(stillImageData: Data, livePhotoMovieURL: URL) {    PHPhotoLibrary.requestAuthorization { status in
        guard status == .authorized else { return }
        
        PHPhotoLibrary.shared().performChanges({
            // Add the captured photo's file data as the main resource for the Photos asset.
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: stillImageData, options: nil)
            
            // Add the movie file URL as the Live Photo's paired video resource.
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true
            creationRequest.addResource(with: .pairedVideo, fileURL: livePhotoMovieURL, options: options)
        }) { success, error in
            // Handle completion.
        }
    }
}
```

#### 
- The  method tells you that a Live Photo movie is no longer recording: implement this method to hide the indicator. (Note that the movie file is not yet available at this time.)
You can have multiple Live Photo captures running at the same time, so it’s best to use these methods to keep track of the number of captures “in flight” and hide your indicator only when that number reaches zero:
```swift
class LivePhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    // ... other PhotoCaptureDelegate methods and supporting properties ...
    
    // A handler to call when Live Photo capture begins and ends.
    var livePhotoStatusHandler: (Bool) -> () = { _ in }
    
    // A property for tracking in-progress captures and updating UI accordingly.
    var livePhotosInProgress = 0 {
        didSet {
            // Update the UI accordingly based on the value of this property
        }
    }
    
    // Call the handler when PhotoCaptureDelegate methods indicate Live Photo capture is in progress.
    func photoOutput(_ output: AVCapturePhotoOutput,
                     willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        let capturingLivePhoto = (resolvedSettings.livePhotoMovieDimensions.width > 0 && resolvedSettings.livePhotoMovieDimensions.height > 0)
        livePhotoStatusHandler(capturingLivePhoto)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL,
                     resolvedSettings: AVCaptureResolvedPhotoSettings) {
        livePhotoStatusHandler(false)
    }
}
```


## Capturing depth using the LiDAR camera
> https://developer.apple.com/documentation/avfoundation/capturing-depth-using-the-lidar-camera

### 
#### 
#### 
The sample app’s `CameraController` class provides the code that configures and manages the capture session, and handles the delivery of new video and depth data. It begins its configuration by retrieving the LiDAR camera. It calls the capture device’s  class method, passing it the new  device type available in iOS 15.4 and later.
```swift
// Look up the LiDAR camera.
guard let device = AVCaptureDevice.default(.builtInLiDARDepthCamera, for: .video, position: .back) else {
    throw ConfigurationError.lidarDeviceUnavailable
}
```

```
After retrieving the device, the app configures it with a specific video and depth format. It asks the device for its supported formats and finds the best nonbinned, full-range YUV color format that matches the sample app’s preferred width and supports depth capture. Finally, it sets the active formats on the device as in the following code example:
```swift
// Find a match that outputs video data in the format the app's custom Metal views require.
guard let format = (device.formats.last { format in
    format.formatDescription.dimensions.width == preferredWidthResolution &&
    format.formatDescription.mediaSubType.rawValue == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange &&
    !format.isVideoBinned &&
    !format.supportedDepthDataFormats.isEmpty
}) else {
    throw ConfigurationError.requiredFormatUnavailable
}

// Find a match that outputs depth data in the format the app's custom Metal views require.
guard let depthFormat = (format.supportedDepthDataFormats.last { depthFormat in
    depthFormat.formatDescription.mediaSubType.rawValue == kCVPixelFormatType_DepthFloat16
}) else {
    throw ConfigurationError.requiredFormatUnavailable
}

// Begin the device configuration.
try device.lockForConfiguration()

// Configure the device and depth formats.
device.activeFormat = format
device.activeDepthDataFormat = depthFormat

// Finish the device configuration.
device.unlockForConfiguration()
```

#### 
The app operates in streaming or photo mode. To enable streaming output, it creates an instance of  and  to capture video sample buffers and depth data, respectively. It configures them as follows:
```swift
// Create an object to output video sample buffers.
videoDataOutput = AVCaptureVideoDataOutput()
captureSession.addOutput(videoDataOutput)

// Create an object to output depth data.
depthDataOutput = AVCaptureDepthDataOutput()
depthDataOutput.isFilteringEnabled = isFilteringEnabled
captureSession.addOutput(depthDataOutput)

// Create an object to synchronize the delivery of depth and video data.
outputVideoSync = AVCaptureDataOutputSynchronizer(dataOutputs: [depthDataOutput, videoDataOutput])
outputVideoSync.setDelegate(self, queue: videoQueue)
```

Because the video and depth data stream from separate output objects, the sample uses an  to synchronize the delivery from both outputs to a single callback. The `CameraController` class adopts the synchronizer’s  protocol and responds to the delivery of new video and depth data.
To handle photo capture, the app also creates an instance of . It optimizes the output for high-quality capture and adds the output to the capture session.
```swift
// Create an object to output photos.
photoOutput = AVCapturePhotoOutput()
photoOutput.maxPhotoQualityPrioritization = .quality
captureSession.addOutput(photoOutput)

// Enable delivery of depth data after adding the output to the capture session.
photoOutput.isDepthDataDeliveryEnabled = true
```

#### 
After configuring the capture session’s inputs and outputs as required, the app is ready to start capturing data. The app starts in streaming mode, which uses the video data and depth data outputs and an `AVCaptureDataOutputSynchronizer` to synchronize the delivery of their data. The app adopts the synchronizer’s delegate protocol and implements its  method to handle the delivery, as the following example shows:
```swift
func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer,
                            didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
    // Retrieve the synchronized depth and sample buffer container objects.
    guard let syncedDepthData = synchronizedDataCollection.synchronizedData(for: depthDataOutput) as? AVCaptureSynchronizedDepthData,
          let syncedVideoData = synchronizedDataCollection.synchronizedData(for: videoDataOutput) as? AVCaptureSynchronizedSampleBufferData else { return }
    
    guard let pixelBuffer = syncedVideoData.sampleBuffer.imageBuffer,
          let cameraCalibrationData = syncedDepthData.depthData.cameraCalibrationData else { return }
    
    // Package the captured data.
    let data = CameraCapturedData(depth: syncedDepthData.depthData.depthDataMap.texture(withFormat: .r16Float, planeIndex: 0, addToCache: textureCache),
                                  colorY: pixelBuffer.texture(withFormat: .r8Unorm, planeIndex: 0, addToCache: textureCache),
                                  colorCbCr: pixelBuffer.texture(withFormat: .rg8Unorm, planeIndex: 1, addToCache: textureCache),
                                  cameraIntrinsics: cameraCalibrationData.intrinsicMatrix,
                                  cameraReferenceDimensions: cameraCalibrationData.intrinsicMatrixReferenceDimensions)
    
    delegate?.onNewData(capturedData: data)
}
```

#### 
When you tap the app’s Camera button in the upper-left corner of the user interface, the app switches to photo mode. When this occurs, the app calls its `capturePhoto()` method, which creates a photo settings object, requests depth delivery on it, and initiates a photo capture.
```swift
func capturePhoto() {
    var photoSettings: AVCapturePhotoSettings
    if  photoOutput.availablePhotoPixelFormatTypes.contains(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        photoSettings = AVCapturePhotoSettings(format: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ])
    } else {
        photoSettings = AVCapturePhotoSettings()
    }
    
    // Capture depth data with this photo capture.
    photoSettings.isDepthDataDeliveryEnabled = true
    photoOutput.capturePhoto(with: photoSettings, delegate: self)
}
```

```
When the framework finishes the photo capture, it calls the photo output’s delegate method and passes it the  object that contains the image and depth data. The sample retrieves the data from the photo, stops the stream until the user returns to streaming mode, and, similarly to the video case, packages the captured data for delivery to the app’s user interface layer.
```swift
func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    
    // Retrieve the image and depth data.
    guard let pixelBuffer = photo.pixelBuffer,
          let depthData = photo.depthData,
          let cameraCalibrationData = depthData.cameraCalibrationData else { return }
    
    // Stop the stream until the user returns to streaming mode.
    stopStream()
    
    // Convert the depth data to the expected format.
    let convertedDepth = depthData.converting(toDepthDataType: kCVPixelFormatType_DepthFloat16)
    
    // Package the captured data.
    let data = CameraCapturedData(depth: convertedDepth.depthDataMap.texture(withFormat: .r16Float, planeIndex: 0, addToCache: textureCache),
                                  colorY: pixelBuffer.texture(withFormat: .r8Unorm, planeIndex: 0, addToCache: textureCache),
                                  colorCbCr: pixelBuffer.texture(withFormat: .rg8Unorm, planeIndex: 1, addToCache: textureCache),
                                  cameraIntrinsics: cameraCalibrationData.intrinsicMatrix,
                                  cameraReferenceDimensions: cameraCalibrationData.intrinsicMatrixReferenceDimensions)
    
    delegate?.onNewPhotoData(capturedData: data)
}
```


## Capturing photos in RAW and Apple ProRAW formats
> https://developer.apple.com/documentation/avfoundation/capturing-photos-in-raw-and-apple-proraw-formats

### 
#### 
To determine whether your app’s photo output supports the Apple ProRAW format in the current environment, add the output to a capture session that has a connected video source, and query its  property. If the current environment supports the Apple ProRAW format, you can enable the photo output to use it by setting its  property to  as the example below shows:
```swift
private let captureSession = AVCaptureSession()
private let photoOutput = AVCapturePhotoOutput()

private func setupSession() throws {
    
    // Start the capture session configuration.
    captureSession.beginConfiguration()
    
    // Configure the session for photo capture.
    captureSession.sessionPreset = .photo
    
    // Connect the default video device.
    let videoInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
    if captureSession.canAddInput(videoInput) {
        captureSession.addInput(videoInput)
        currentVideoInput = videoInput
    } else {
        throw CameraError.setupFailed
    }
    
    // Connect and configure the capture output.
    if captureSession.canAddOutput(photoOutput) {
        captureSession.addOutput(photoOutput)
        
        // Use the Apple ProRAW format when the environment supports it.
        photoOutput.isAppleProRAWEnabled = photoOutput.isAppleProRAWSupported
    } else {
        throw CameraError.setupFailed
    }
    
    // Session configuration is complete. Commit the configuration.
    captureSession.commitConfiguration()
}

```

#### 
Capturing photos in RAW and Apple ProRAW formats requires only minor changes to the basic photography workflow in . Begin by creating an  object that specifies the RAW format to capture, and optionally, a processed format to capture if your app supports creating RAW+JPEG files. The capture pipeline only supports the RAW formats in the photo output’s  array.
The example below finds the appropriate RAW format, choosing the Apple ProRAW format when it’s in an enabled state, and the Bayer RAW format when it’s not. It creates a photo settings object that specifies the RAW and processed formats, and a delegate object to monitor the capture progress. Finally, it calls the photo output’s  method, passing it the photo settings and delegate objects.
```swift
let query = photoOutput.isAppleProRAWEnabled ?
    { AVCapturePhotoOutput.isAppleProRAWPixelFormat($0) } :
    { AVCapturePhotoOutput.isBayerRAWPixelFormat($0) }

// Retrieve the RAW format, favoring the Apple ProRAW format when it's in an enabled state.
guard let rawFormat =
        photoOutput.availableRawPhotoPixelFormatTypes.first(where: query) else {
    fatalError("No RAW format found.")
}

// Capture a RAW format photo, along with a processed format photo.
let processedFormat = [AVVideoCodecKey: AVVideoCodecType.hevc]
let photoSettings = AVCapturePhotoSettings(rawPixelFormatType: rawFormat,
                                           processedFormat: processedFormat)

// Create a delegate to monitor the capture process.
let delegate = RAWCaptureDelegate()
captureDelegates[photoSettings.uniqueID] = delegate

// Remove the delegate reference when it finishes its processing.
delegate.didFinish = {
    self.captureDelegates[photoSettings.uniqueID] = nil
}

// Tell the output to capture the photo.
photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
```

```
The Apple ProRAW format supports capturing up to a full-resolution JPEG image to use as a thumbnail photo. Set  on your photo settings object as the following example shows:
```swift
// Select the first available codec type, which is JPEG.
guard let thumbnailPhotoCodecType =
    photoSettings.availableRawEmbeddedThumbnailPhotoCodecTypes.first else {
    // Handle the failure to find an available thumbnail photo codec type.
}

// Select the maximum photo dimensions as thumbnail dimensions if a full-size thumbnail is desired.
// The system clamps these dimensions to the photo dimensions if the capture produces a photo with smaller than maximum dimensions.
let dimensions = photoSettings.maxPhotoDimensions

photoSettings.rawEmbeddedThumbnailPhotoFormat = [
    AVVideoCodecKey: thumbnailPhotoCodecType,
    AVVideoWidthKey: dimensions.width,
    AVVideoHeightKey: dimensions.height
]
```

#### 
The photo output calls its delegate’s  method at least once for each format you request, and possibly additional times, depending on your capture settings. Using the capture settings in the previous section results in the photo output calling this delegate method twice: once for the RAW or Apple ProRAW image, and again for the processed image. In each invocation, get the photo’s file data by calling its  method and store it as necessary. If you call this method on a RAW or Apple ProRAW photo, it returns the data in the industry-standard DNG file format. If you call it on processed images, it returns the compressed bitmap image data.
The following code shows an example implementation of the  method. It writes the RAW file to disk and stores a reference to the processed photo’s compressed bitmap data for later use.
```swift
class RAWCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    private var rawFileURL: URL?
    private var compressedData: Data?
    
    var didFinish: (() -> Void)?
    
    // Store the RAW file and compressed photo data until the capture finishes.
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        guard error == nil else {
            print("Error capturing photo: \(error!)")
            return
        }
        
        // Access the file data representation of this photo.
        guard let photoData = photo.fileDataRepresentation() else {
            print("No photo data to write.")
            return
        }
        
        if photo.isRawPhoto {
            // Generate a unique URL to write the RAW file.
            rawFileURL = makeUniqueDNGFileURL()
            do {
                // Write the RAW (DNG) file data to a URL.
                try photoData.write(to: rawFileURL!)
            } catch {
                fatalError("Couldn't write DNG file to the URL.")
            }
        } else {
            // Store compressed bitmap data.
            compressedData = photoData
        }
    }
    
    private func makeUniqueDNGFileURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = ProcessInfo.processInfo.globallyUniqueString
        return tempDir.appendingPathComponent(fileName).appendingPathExtension("dng")
    }
}
```

#### 
By default, when you ask for the file data representation of an Apple ProRAW photo, you get the data in full lossless quality. If you’re willing to accept some lossy compression to achieve smaller file sizes, you can customize the compression settings by calling  and passing it a custom object that conforms to the  protocol. The following code shows an example implementation of this protocol that applies minimal compression to the output image:
```swift
class AppleProRAWCustomizer: NSObject, AVCapturePhotoFileDataRepresentationCustomizer {
    
    // Customize the compression settings.
    func replacementAppleProRAWCompressionSettings(for photo: AVCapturePhoto, 
                                                   defaultSettings: [String : Any], 
                                                   maximumBitDepth: Int) -> [String : Any] {
        
        // Reduce the bit depth and quality of the final file.
        return [AVVideoAppleProRAWBitDepthKey: maximumBitDepth - 2, 
                AVVideoQualityKey: 0.95]
    }
}
```

```
To use this customizer when retrieving the file data representation of a ProRAW photo, create a new instance of your customizer and pass it to the  method as the example below shows:
```swift
// Get a minimally compressed representation of the file data.
let customizer = AppleProRAWCustomizer()
let photoData = photo.fileDataRepresentation(with: customizer)
```

#### 
The photo output indicates when it finishes the capture request by calling the delegate’s  method. This callback provides an opportunity to save the captured photos to the user’s Photos library. For more information about configuring your app to access the user’s Photos library, see .
To save the captured photos to the user’s Photos library, create a single Photos asset that associates the RAW or Apple ProRAW data with the processed data. Create an instance of , then specify the DNG version as the asset’s main  resource, and the processed image as an  resource. Perform the request inside a change block as the example below shows:
```swift
// After both RAW and compressed versions are complete, add them to the Photos library.
func photoOutput(_ output: AVCapturePhotoOutput,
                 didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                 error: Error?) {
    
    // Call the "finished" closure, if you set it.
    defer { didFinish?() }
    
    guard error == nil else {
        print("Error capturing photo: \(error!)")
        return
    }
    
    // Ensure the RAW and processed photo data exists.
    guard let rawFileURL = rawFileURL,
          let compressedData = compressedData else {
        print("The expected photo data isn't available.")
        return
    }
    
    // Request add-only access to the user's Photos library (if the user hasn't already granted that access).
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        
        // Don't continue unless the user granted access.
        guard status == .authorized else { return }
        
        PHPhotoLibrary.shared().performChanges {
            
            let creationRequest = PHAssetCreationRequest.forAsset()
            
            // Save the RAW (DNG) file as the main resource for the Photos asset.
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true
            creationRequest.addResource(with: .photo,
                                        fileURL: rawFileURL,
                                        options: options)
            
            // Add the compressed (HEIF) data as an alternative resource.
            creationRequest.addResource(with: .alternatePhoto,
                                        data: compressedData,
                                        options: nil)
            
        } completionHandler: { success, error in
            // Process the Photos library error.
        }
    }
}
```


## Capturing photos with depth
> https://developer.apple.com/documentation/avfoundation/capturing-photos-with-depth

### 
#### 
To capture depth maps, you’ll need to first select a  or  capture device as your session’s video input. Even if an iOS device has a dual camera or TrueDepth camera, selecting the default back- or front-facing camera doesn’t enable depth capture.
Capturing depth also requires an internal reconfiguration of the capture pipeline, briefly delaying capture and interrupting any in-progress captures. Before shooting your first depth photo, make sure you configure the pipeline appropriately by enabling depth capture on your  object.
```swift
// Select a depth-capable capture device.
guard let videoDevice = AVCaptureDevice.default(.builtInDualCamera,
    for: .video, position: .back)
    else { fatalError("No dual camera.") }
guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
    self.captureSession.canAddInput(videoDeviceInput)
    else { fatalError("Can't add video input.") }
self.captureSession.beginConfiguration()
self.captureSession.addInput(videoDeviceInput)

// Set up photo output for depth data capture.
let photoOutput = AVCapturePhotoOutput()
guard self.captureSession.canAddOutput(photoOutput)
    else { fatalError("Can't add photo output.") }
self.captureSession.addOutput(photoOutput)
self.captureSession.sessionPreset = .photo
// Enable delivery of depth data after adding the output to the capture session.
photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
self.captureSession.commitConfiguration()
```

#### 
Once your photo output is ready for depth capture, you can request that any individual photos capture a depth map along with the color image. Create an  object, choosing the format for the color image. Then, enable depth capture and depth output (and any other settings you’d like for that photo) and call the  method.
```swift
let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
photoSettings.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported

// Shoot the photo, using a custom class to handle capture delegate callbacks.
let captureProcessor = PhotoCaptureProcessor()
photoOutput.capturePhoto(with: photoSettings, delegate: captureProcessor)
```

#### 
#### 
The TrueDepth camera projects an infrared light pattern in front of the camera and images that pattern with an infrared camera. By observing how objects in the scene distorts the pattern, the capture system can calculate the distance rom the camera to each point in the image.
The TrueDepth camera produces disparity maps by default so that the resulting depth data is similar to that produced by a dual camera device. However, unlike a dual camera device, the TrueDepth camera can directly measure depth (in meters) with  accuracy. To capture depth instead of disparity, set the  of the capture device before starting your capture session:
```swift
// Select a depth (not disparity) format that works with the active color format.
let availableFormats = captureDevice.activeFormat.supportedDepthDataFormats

let depthFormat = availableFormats.filter { format in
    let pixelFormatType =
        CMFormatDescriptionGetMediaSubType(format.formatDescription)
    
    return (pixelFormatType == kCVPixelFormatType_DepthFloat16 ||
            pixelFormatType == kCVPixelFormatType_DepthFloat32)
}.first

// Set the capture device to use that depth format.
captureSession.beginConfiguration()
captureDevice.activeDepthDataFormat = depthFormat
captureSession.commitConfiguration()
```


## Capturing still and Live Photos
> https://developer.apple.com/documentation/avfoundation/capturing-still-and-live-photos

### 
#### 
Some capture options affect the internal configuration of the media capture pipeline. Because changing those options causes the pipeline to reconfigure itself, which takes time, enable them before offering the user the ability to shoot photos with those settings. Otherwise, the configuration delay could prevent the user from capturing a photo at the right moment.
For example, to configure the capture pipleline to support Live Photos, enable that property on the photo output, as shown below. After you’ve enabled Live Photo capture, you can choose for each individual shot whether to use still or Live Photo capture for each shot (see ).
```swift
self.captureSession.beginConfiguration()

let photoOutput = AVCapturePhotoOutput()
photoOutput.isHighResolutionCaptureEnabled = true
photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported

guard self.captureSession.canAddOutput(photoOutput) else { return }
self.captureSession.sessionPreset = .photo
self.captureSession.addOutput(photoOutput)

self.previewView.session = captureSession

self.captureSession.commitConfiguration()
self.captureSession.startRunning()
```

#### 
- To shoot in RAW format, use  with one of the  supported by the photo output.
After creating a photo settings object, you can choose other settings for the photo. For example, the code below creates a settings object for HEIF/HEVC shooting, with automatic flash and image stabilization.
```swift
let photoSettings: AVCapturePhotoSettings
if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
    photoSettings = AVCapturePhotoSettings(format:
        [AVVideoCodecKey: AVVideoCodecType.hevc])
} else {
    photoSettings = AVCapturePhotoSettings()
}
photoSettings.flashMode = .auto
photoSettings.isAutoStillImageStabilizationEnabled =
    self.photoOutput.isStillImageStabilizationSupported

```

#### 
#### 
The `delegate` you pass to the  method is an object to track the progress of and handle results from that photo capture. Capturing a photo is an asynchronous process with multiple steps that unfold over time. Because your app can trigger additional captures while earlier captures are still processing, your delegate implementation should be able to handle multiple captures at once. An easy way to handle concurrent captures is to define a class adopting the  protocol and create a separate instance of that class for each capture:
```swift
class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    // ...
}

let captureProcessor = PhotoCaptureProcessor()
self.photoOutput.capturePhoto(with: photoSettings, delegate: captureProcessor)
```


## Capturing thumbnail and preview images
> https://developer.apple.com/documentation/avfoundation/capturing-thumbnail-and-preview-images

### 
#### 
After you create an  object for the kind of photo you plan to shoot, use its  dictionary to specify the format and size of preview image you want.
```swift
if photoSettings.availablePreviewPhotoPixelFormatTypes.count > 0 {
    photoSettings.previewPhotoFormat = [
        kCVPixelBufferPixelFormatTypeKey : photoSettings.availablePreviewPhotoPixelFormatTypes.first!,
        kCVPixelBufferWidthKey : 512,
        kCVPixelBufferHeightKey : 512
    ] as [String: Any]
}

```

```
To request that a thumbnail version of the photo be embedded in the resulting image file, use the photo settings object’s  dictionary to specify the format and size of the thumbnail.
```swift
photoSettings.embeddedThumbnailPhotoFormat = [
    AVVideoCodecKey: AVVideoCodecType.jpeg,
    AVVideoWidthKey: 1024,
    AVVideoHeightKey: 1024,
]
```

#### 
When the photo output calls your delegate’s  method, you can get the preview image from the   property. A pixel buffer provides direct access to pixel data, so you can process or display it using other graphics technologies such as Metal, Vision, or Core Image. One way to simply display the preview image in your UI is to use Core Image to wrap the buffer in a UIImage object:
```swift
func showPreview(for photo: AVCapturePhoto) {
    guard let previewPixelBuffer = photo.previewPixelBuffer else { return }
    let ciImage = CIImage(cvPixelBuffer: previewPixelBuffer)
    let uiImage = UIImage(ciImage: ciImage)
    self.imageView.image = uiImage
}

```


## Capturing uncompressed image data
> https://developer.apple.com/documentation/avfoundation/capturing-uncompressed-image-data

### 
#### 
To capture in an uncompressed format, create a photo settings object with . In the format dictionary, specify the  with one of the values listed in the photo output’s  array. The example below chooses a 32-bit BGRA pixel format, which is useful in some GPU processing workflows:
```swift
// Choose a 32-bit BGRA pixel format and verify the camera supports it.
let pixelFormatType = kCVPixelFormatType_32BGRA
guard self.photoOutput.availablePhotoPixelFormatTypes.contains(pixelFormatType) else { return }
let photoSettings = AVCapturePhotoSettings(format:
    [ kCVPixelBufferPixelFormatTypeKey as String : pixelFormatType ])

// Shoot the photo, using a custom class to handle capture delegate callbacks.
let layerOrientation = previewView.videoPreviewLayer.connection!.videoOrientation
let colorSpace = self.videoCaptureDevice.activeColorSpace
let captureProcessor = UncompressedCaptureProcessor(orientation: layerOrientation,
                                                    colorSpace: colorSpace)
self.photoOutput.capturePhoto(with: photoSettings, delegate: captureProcessor)

```

#### 
As with other formats, you receive uncompressed data capture results to your delegate’s  method as an  object. To access the uncompressed pixel data directly, use the photo’s  property.
For example, the following code applies a Core Image filter directly to the pixel buffer and writes the filtered image to a PNG file:
```swift
class UncompressedCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    
    // Hold on to the separately delivered RAW and compressed photo data until capture is finished.
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error != nil else { print("Error capturing photo: \(error!)"); return }
        
        // Create a CIImage from the pixel buffer and apply a filter
        let image = CIImage(cvPixelBuffer: photo.pixelBuffer!)
        let imageOrientation = self.imageOrientation(for: videoOrientation)
        let filteredImage = image.oriented(imageOrientation)
            .applyingFilter("CIPhotoEffectNoir", parameters: [:])
        
        let imageColorSpace = self.imageColorSpace(for: colorSpace)
        guard let pngData = CIContext()
            .pngRepresentation(of: filteredImage, format: kCIFormatBGRA8, colorSpace: imageColorSpace)
            else { print("Error creating filtered PNG image"); return }
        self.exportToFile(pngData)
    }
}
```


## Choosing a capture device
> https://developer.apple.com/documentation/avfoundation/choosing-a-capture-device

### 
#### 
If you know exactly what kind of capture devices you’re looking for, use one of the  convenience methods to select a default device. For example, the code below selects the best available back-facing camera: either the dual camera on supported devices, or the single (wide-angle) camera on single-camera devices.
```swift
if let device = AVCaptureDevice.default(.builtInDualCamera,
                                        for: .video, position: .back) {
    return device
} else if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                               for: .video, position: .back) {
    return device
} else {
    fatalError("Missing expected back camera device.")
}
```

#### 
To see the entire set of devices matching certain criteria so that you can use your own logic to choose one, use the  class. First, create a discovery session for the kinds of devices you need:
```swift
let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
    [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
    mediaType: .video, position: .unspecified)
```

```
Then, read the discovery session’s  list to find matching devices and choose one that suits your needs. The discovery session automatically sorts its  list based on the device types you asked for, so you can use the array order to find the best device with certain features. For example, because the discovery session shown above searches for depth-capable devices before the wide-angle camera and allows any device position, the first item in its devices list matching a specified position is the best depth capture device for that position (or a fallback device):
```swift
func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
    let devices = self.discoverySession.devices
    guard !devices.isEmpty else { fatalError("Missing capture devices.")}

    return devices.first(where: { device in device.position == position })!
}
```


## Configuring your app for media playback
> https://developer.apple.com/documentation/avfoundation/configuring-your-app-for-media-playback

### 
#### 
An audio session category defines the general audio behavior your app requires. AVFoundation defines several audio session categories you can use, but the one most relevant for media playback apps is . This category indicates that media playback is a central feature of your app. When you specify this category, the system doesn’t silence your app’s audio when someone sets the Ring/Silent switch to silent mode in iOS only. Enabling this category means your app can play background audio if you’re using the Audio, AirPlay, and Picture in Picture background mode as explained in the section below.
Use an  object to configure your app’s audio session. An audio session is a singleton object you use to set the audio session , , and other settings. To configure the audio session for optimized playback of movies:
```swift
class PlayerModel: ObservableObject {
    
    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // Configure the app for playback of long-form movies.
            try session.setCategory(.playback, mode: .moviePlayback)
        } catch {
            // Handle error.
        }
    }
}
```

#### 

## Controlling the transport behavior of a player
> https://developer.apple.com/documentation/avfoundation/controlling-the-transport-behavior-of-a-player

### 
#### 
When you create a player item, it starts with a status of , which means the system hasn’t attempted to load its media for playback. Only when you associate the item with an  object does the system begin loading an asset’s media.
To know when the player item is ready for playback, observe the value of its  property. Add this observation before you call the player’s  method, because associating the player item with a player is the system’s cue to load the item’s media:
```swift
var statusObservation: NSKeyValueObservation?

func playMedia(at url: URL) {
    let asset = AVAsset(url: url)
    let playerItem = AVPlayerItem(
        asset: asset,
        automaticallyLoadedAssetKeys: [.tracks, .duration, .commonMetadata]
    )
    // Key-value observe the status property before associating with player.
    statusObservation = playerItem.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
        guard let self else { return }
        Task { @MainActor in
            switch item.status {
            case .readyToPlay:
                // Ready to play. Present playback UI.
            case .failed:
                // A failure while loading media occurred.
            default:
                break
            }
        }
    }
    // Set the item as the player's current item.
    player.replaceCurrentItem(with: playerItem)
}
```

#### 
A player provides the  and  methods as its primary means of controlling its playback rate. When a player item is ready for playback, call the player’s  method to request that playback begins at the , which has an initial value of `1.0` (the natural rate). By default, a player automatically waits to start playback until it has sufficient media data available to minimize stalling. You can determine whether a player is in a paused, waiting to play, or playing state by observing its  value:
```swift
var isPlaying = false
var timeControlObservation: NSKeyValueObservation?

private func observePlayingState() {
    timeControlObservation = player.observe(\.timeControlStatus, options: [.new, .initial]) { [weak self] player, _ in
        guard let self else { return }
        Task { @MainActor in
            self.isPlaying = player.timeControlStatus == .playing
        }
    }
}
```

```
Observe changes to the  property by observing notifications of type . Observing this notification is similar to key-value observing the  property, but provides additional information about the reason for the rate change. Retrieve the reason from the notification’s  dictionary using the  constant:
```swift
// Observe changes to the playback rate asynchronously.
private func observeRateChanges() async {
    let name = AVPlayer.rateDidChangeNotification
    for await notification in NotificationCenter.default.notifications(named: name) {
        guard let reason = notification.userInfo?[AVPlayer.rateDidChangeReasonKey] as? AVPlayer.RateDidChangeReason else {
            continue
        }
        switch reason {
        case .appBackgrounded:
            // The app transitioned to the background.
        case .audioSessionInterrupted:
            // The system interrupts the app’s audio session.
        case .setRateCalled:
            // The app set the player’s rate.
        case .setRateFailed:
            // An attempt to change the player’s rate failed.
        default:
            break
        }
    }
}
```

#### 
You can seek through a media timeline in several ways using the methods of  and . The most common way is to use the player’s  method, passing it a destination  value. Call this method in an asynchronous context:
```swift
// Handle time update request from user interface.
func seek(to timeInterval: TimeInterval) async {
    // Create a CMTime value for the passed in time interval.
    let time = CMTime(seconds: timeInterval, preferredTimescale: 600)
    await avPlayer.seek(to: time)
}
```

You can call this method a single time to seek to the location, but you can also call it continuously such as when you use a  view.
The  method is a convenient way to quickly seek through your presentation, but it’s tuned for speed rather than precision. This means the actual time to which the player seeks may differ slightly from the time you request. If you need to implement precise seeking behavior, use the  method, which lets you indicate the tolerated amount of deviation from your target time (before and after). For example, if you need to provide sample-accurate seeking behavior, specify tolerance values of zero:
```swift
// Seek precisely to the specified time.
await avPlayer.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
```


## Converting side-by-side 3D video to multiview HEVC and spatial video
> https://developer.apple.com/documentation/avfoundation/converting-side-by-side-3d-video-to-multiview-hevc-and-spatial-video

### 
#### 
- `--spatial` (or `-s`) to indicate that you want to include spatial metadata
- `--baseline` (or `-b`) to provide a baseline in millimeters (for example, `--baseline 64.0` for a 64mm baseline)
- `--fov` (or `-f`) to provide a horizontal field of view in degrees (for example, `--fov 80.0` for an 80-degree field of view)
- `--disparityAdjustment` (or `-d`) to provide a disparity adjustment (for example, `--disparityAdjustment 0.02` for a 2% positive disparity shift)
#### 
The app starts by loading the side-by-side video, creating an . The app calls  to load video tracks, and then selects the first track available as the side-by-side input.
```swift
let asset = AVURLAsset(url: url)
reader = try AVAssetReader(asset: asset)

// Get the side-by-side video track.
guard let videoTrack = try await asset.loadTracks(withMediaCharacteristic: .visual).first else {
    fatalError("Error loading side-by-side video input")
}
```

```
The app also stores the frame size for the side-by-side video, and calculates the size of the output frames.
```swift
sideBySideFrameSize = try await videoTrack.load(.naturalSize)
eyeFrameSize = CGSize(width: sideBySideFrameSize.width / 2, height: sideBySideFrameSize.height)
```

To finish loading the video, the app creates an  and then adds this output stream to the `AVAssetReader`.
```
To finish loading the video, the app creates an  and then adds this output stream to the `AVAssetReader`.
```swift
let readerSettings: [String: Any] = [
    kCVPixelBufferIOSurfacePropertiesKey as String: [String: String]()
]
sideBySideTrack = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerSettings)

if reader.canAdd(sideBySideTrack) {
    reader.add(sideBySideTrack)
}

if !reader.startReading() {
    fatalError(reader.error?.localizedDescription ?? "Unknown error during track read start")
}
```

#### 
With the reader initialized, the app calls the `async` method `transcodeToMVHEVC(output:spatialMetadata:)` to generate the output file. First, the app creates a new  pointing to the video output location, and then configures the necessary information on the output to indicate that the file contains MV-HEVC video.
```swift
var multiviewCompressionProperties: [CFString: Any] = [
    kVTCompressionPropertyKey_MVHEVCVideoLayerIDs: MVHEVCVideoLayerIDs,
    kVTCompressionPropertyKey_MVHEVCViewIDs: MVHEVCViewIDs,
    kVTCompressionPropertyKey_MVHEVCLeftAndRightViewIDs: MVHEVCLeftAndRightViewIDs,
    kVTCompressionPropertyKey_HasLeftStereoEyeView: true,
    kVTCompressionPropertyKey_HasRightStereoEyeView: true
]
```

The sample app uses `0` for the left eye layer/view ID and `1` for the right eye layer/view ID.
 and  are `true`, because the output contains a layer for each eye. , , and  define the layer and view IDs to use for multiview HEVC encoding. In the sample app, these are all the same.
The sample app uses `0` for the left eye layer/view ID and `1` for the right eye layer/view ID.
```swift
let MVHEVCVideoLayerIDs = [0, 1]

// For simplicity, choose view IDs that match the layer IDs.
let MVHEVCViewIDs = [0, 1]

// The first element in this array is the view ID of the left eye.
let MVHEVCLeftAndRightViewIDs = [0, 1]
```

#### 
If the person calling this command-line app requested to add spatial metadata to the output file, and provided the necessary spatial metadata, the app converts that metadata to expected units and scales, and adds an additional compression property key for each metadata value. The app also specifies that the input uses a rectilinear projection, to indicate that it has the expected projection for spatial video.
```swift
if let spatialMetadata {

    let baselineInMicrometers = UInt32(1000.0 * spatialMetadata.baselineInMillimeters)
    let encodedHorizontalFOV = UInt32(1000.0 * spatialMetadata.horizontalFOV)
    let encodedDisparityAdjustment = Int32(10_000.0 * spatialMetadata.disparityAdjustment)

    multiviewCompressionProperties[kVTCompressionPropertyKey_ProjectionKind] = kCMFormatDescriptionProjectionKind_Rectilinear
    multiviewCompressionProperties[kVTCompressionPropertyKey_StereoCameraBaseline] = baselineInMicrometers
    multiviewCompressionProperties[kVTCompressionPropertyKey_HorizontalFieldOfView] = encodedHorizontalFOV
    multiviewCompressionProperties[kVTCompressionPropertyKey_HorizontalDisparityAdjustment] = encodedDisparityAdjustment

}
```

#### 
The app transcodes video by directly copying pixels from the source frame. Writing track data to a video file requires an . The sample app uses an  to provide pixel data from the source, writing to the output.
```swift
let multiviewSettings: [String: Any] = [
    AVVideoCodecKey: AVVideoCodecType.hevc,
    AVVideoWidthKey: self.eyeFrameSize.width,
    AVVideoHeightKey: self.eyeFrameSize.height,
    AVVideoCompressionPropertiesKey: multiviewCompressionProperties
]

guard multiviewWriter.canApply(outputSettings: multiviewSettings, forMediaType: AVMediaType.video) else {
    fatalError("Error applying output settings")
}

let frameInput = AVAssetWriterInput(mediaType: .video, outputSettings: multiviewSettings)

let sourcePixelAttributes: [String: Any] = [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
    kCVPixelBufferWidthKey as String: self.sideBySideFrameSize.width,
    kCVPixelBufferHeightKey as String: self.sideBySideFrameSize.height
]

let bufferInputAdapter = AVAssetWriterInputTaggedPixelBufferGroupAdaptor(assetWriterInput: frameInput, sourcePixelBufferAttributes: sourcePixelAttributes)
```

```
The `AVAssetWriterInput` source uses the same `outputSettings` as `videoWriter`, and the created pixel buffer adapter has the same frame size as the source. The app follows the best practice of calling  to check the input adapter compatibility before calling  to use it as a source.
```swift
guard multiviewWriter.canAdd(frameInput) else {
    fatalError("Error adding side-by-side video frames as input")
}
multiviewWriter.add(frameInput)
```

#### 
The app calls  and  in sequence to start the video writing process, and then iterates over available frame inputs with .
```swift
guard multiviewWriter.startWriting() else {
    fatalError("Failed to start writing multiview output file")
}
multiviewWriter.startSession(atSourceTime: CMTime.zero)

// The dispatch queue executes the closure when media reads from the input file are available.
frameInput.requestMediaDataWhenReady(on: DispatchQueue(label: "Multiview HEVC Writer")) {
```

#### 
To perform the data transfer from the source track, the pixel input adapter requires a pixel buffer as a source. The app creates a  to allow for reading data from the video source, and uses the `AVAssetWriterInputTaggedPixelBufferGroupAdaptor`’s existing pixel buffer pool to allocate pixel buffers for the new multiview eye layers.
```swift
var session: VTPixelTransferSession? = nil
guard VTPixelTransferSessionCreate(allocator: kCFAllocatorDefault, pixelTransferSessionOut: &session) == noErr, let session else {
    fatalError("Failed to create pixel transfer")
}
guard let pixelBufferPool = bufferInputAdapter.pixelBufferPool else {
    fatalError("Failed to retrieve existing pixel buffer pool")
}
```

#### 
After preparing resources, the app then begins a loop to process frames until there’s no more data, or the input read has stopped to buffer data. The  property of an input source is `true` if another frame is immediately available to process. When a frame is ready, a  instance is created from it.
The app is now ready to handle sampling. If there’s an available sample, the app processes it in the `convertFrame` method, then calls , copying the side-by-side sample buffer’s  timestamp to the new multiview timestamp.
```swift
while frameInput.isReadyForMoreMediaData && bufferInputAdapter.assetWriterInput.isReadyForMoreMediaData {
    if let sampleBuffer = self.sideBySideTrack.copyNextSampleBuffer() {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            fatalError("Failed to load source samples as an image buffer")
        }
        let taggedBuffers = self.convertFrame(fromSideBySide: imageBuffer, with: pixelBufferPool, in: session)
        let newPTS = sampleBuffer.outputPresentationTimeStamp
        if !bufferInputAdapter.appendTaggedBuffers(taggedBuffers, withPresentationTime: newPTS) {
            fatalError("Failed to append tagged buffers to multiview output")
        }
```

```
Input reading finishes when there are no more sample buffers to process from the input stream. The app calls  to close the stream, and  to complete the multiview video write. The app also calls  on its associated , to return to the `await` call, then breaks from the processing loop.
```swift
frameInput.markAsFinished()
multiviewWriter.finishWriting {
    continuation.resume()
}

break
```

#### 
In the `convertFrame` method, the app processes the left- and right-eye images for the frame by `layerID`, using `0` for the left eye and `1` for the right. First, the app creates a pixel buffer from the pool.
```swift
var pixelBuffer: CVPixelBuffer?
CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBuffer)
guard let pixelBuffer else {
    fatalError("Failed to create pixel buffer for layer \(layerID)")
}
```

```
The method then uses its passed `VTPixelTransferSession` to copy the pixels from the side-by-side source, placing them into the created output sample buffer by cropping the frame to include only one eye’s image.
```swift
// Crop the transfer region to the current eye.
let apertureOffset = -(self.eyeFrameSize.width / 2) + CGFloat(layerID) * self.eyeFrameSize.width
let cropRectDict = [
    kCVImageBufferCleanApertureHorizontalOffsetKey: apertureOffset,
    kCVImageBufferCleanApertureVerticalOffsetKey: 0,
    kCVImageBufferCleanApertureWidthKey: self.eyeFrameSize.width,
    kCVImageBufferCleanApertureHeightKey: self.eyeFrameSize.height
]
CVBufferSetAttachment(imageBuffer, kCVImageBufferCleanApertureKey, cropRectDict as CFDictionary, CVAttachmentMode.shouldPropagate)
VTSessionSetProperty(session, key: kVTPixelTransferPropertyKey_ScalingMode, value: kVTScalingMode_CropSourceToCleanAperture)

// Transfer the image to the pixel buffer.
guard VTPixelTransferSessionTransferImage(session, from: imageBuffer, to: pixelBuffer) == noErr else {
    fatalError("Error during pixel transfer session for layer \(layerID)")
}
```

The app then calls  to crop the image to the aperture frame with . Next, the app calls  to copy source pixels to the destination buffer.
The final step is to create a  for the eye image to return to the calling output writer.
```swift
let tags: [CMTag] = [.videoLayerID(Int64(layerID)), .stereoView(eye)]
let buffer = CMTaggedBuffer(tags: tags, buffer: .pixelBuffer(pixelBuffer))
taggedBuffers.append(buffer)
```


## Creating auxiliary depth data manually
> https://developer.apple.com/documentation/avfoundation/creating-auxiliary-depth-data-manually

### 
#### 
- `kCVPixelFormatType_DepthFloat16 = 'hdep'`: An IEEE754-2008 binary16 (half float), describing the depth (distance to an object) in meters
- `kCVPixelFormatType_DepthFloat32 = 'fdep'`: An IEEE754-2008 binary32 float, describing the depth (distance to an object) in meters
#### 
 returns `nil` if the image doesn’t contain `auxiliaryImageDataType` data.
-  → One of the Core Video `CVPixelBuffer.h` depth or disparity formats
#### 
2. Create the image destination.
3. Create the image, using helper methods from .
```swift
// Add an image to the destination.
CGImageDestinationAddImage(cgImageDestination, renderedCGImage, attachments)  

// Use AVDepthData to get the auxiliary data dictionary.         
var auxDataType :NSString? 
let auxData = depthData.dictionaryRepresentation(forAuxiliaryDataType: &auxDataType)  

// Add auxiliary data to the image destination. 
CGImageDestinationAddAuxiliaryDataInfo(cgImageDestination, auxDataType!, auxData! as CFDictionary)  

if CGImageDestinationFinalize(cgImageDestination) {  
	return data as Data
}  
```


## Creating images from a video asset
> https://developer.apple.com/documentation/avfoundation/creating-images-from-a-video-asset

### 
#### 
Create an instance of  by passing it a video asset to retrieve images from. A generator supports creating images from local and remote file–based media, and also from HTTP Live Streaming (HLS) video that provides I-frame only renditions.
```swift
let asset: AVAsset = // A video asset.
let generator = AVAssetImageGenerator(asset: asset)
```

An image generator is ready to produce images when you create it, but it also provides configurable properties that you can use to customize its behavior. One property that you typically set is its . By default, a generator produces images at the video’s native resolution, which is often larger than required, and can be CPU and memory intensive. Instead, set a value for its  property to constrain the size of its output. For example, you can constrain the width to a specific value, and specify `0` to proportionally scale the height, by setting a maximum size as follows.
```swift
// Generate the equivalent of a 150-pixel-wide @2x image.
generator.maximumSize = CGSize(width: 300, height: 0)
```

#### 
By default, an image generator creates images near the time you request, but its actual time may be slightly before or after for efficiency sake. To change the amount of time you allow the generator to deviate from the requested time, set the value of its  and  properties. For example, to allow image generation to occur over a time range that starts no earlier than your requested time, and no later than two seconds after, set its tolerance values as shown below.
```swift
// Configure the generator's time tolerance values.
generator.requestedTimeToleranceBefore = .zero
generator.requestedTimeToleranceAfter = CMTime(seconds: 2, preferredTimescale: 600)
```

#### 
Retrieving and decoding the media data that a generator requires to produce images takes an unknown amount of time. It’s not safe to perform image generation synchronously because it blocks the calling thread, which can degrade your app’s user experience and may even result in a crash. Instead, perform image generation asynchronously.
To create a single image from the video timeline, call the asynchronous  method, passing it your requested time. The following example shows how to create an image for the first frame in the video.
```swift
// Generate an image at time zero.
let (image, actualTime) = try await generator.image(at: .zero)
```

```
Because the time at which it creates an image may vary from your requested time, the method returns the actual image-generation time along with the image in a tuple. If you don’t require this information, you can retrieve the image more succinctly as shown below.
```swift
// Generate an image at time zero. Access the image alone.
let image = try await generator.image(at: .zero).image
```

```
You can also use an image generator to create a sequence of images from the video timeline. To generate multiple images from a video asset, call the asynchronous  method as shown below.
```swift
let times: [CMTime] = // An array of times at which to create images.
for await result in generator.images(for: times) {
    switch result {
    case .success(requestedTime: let requested, image: let image, actualTime: let actual):
        // Process the image for the requested time.
    case .failure(requestedTime: let requested, error: let error):
        // Handle the failure for the requested time.
    }
}
```


## Debugging AVFoundation audio mixes, compositions, and video compositions
> https://developer.apple.com/documentation/avfoundation/debugging-avfoundation-audio-mixes-compositions-and-video-compositions

### 
#### 
#### 
#### 
The `PlayerViewController` class has an outlet to the `CompositionDebugView` object in the `Main.storyboard`.
The `PlayerViewController` class has an outlet to the `CompositionDebugView` object in the `Main.storyboard`.
```swift
@IBOutlet weak var compositionDebugView: CompositionDebugView!
```

```
The `PlayerViewController` creates a player item to display the composition in the upper portion of the screen using an  that presents a native user interface to control playback. It creates this player item from the composition, video composition, and audio mix that the `SimpleEditor` creates from the video files in the project.
```swift
// Create a player item from the simple editor composition.
self.playerItem = AVPlayerItem(asset: self.editor.composition())
/*
 Set the player item's video composition and audio mix playback
 settings from the corresponding values in the simple editor.
*/
self.playerItem.videoComposition = self.editor.videoComposition()
self.playerItem.audioMix = self.editor.audioMix()
```

```
To synchronize its player item with the `CompositionDebugView`, the `PlayerViewController` calls the `CompositionDebugView` `synchronize` function, passing the player item as a parameter.
```swift
// Set the player item on the debug view to synchronize playback.
self.compositionDebugView.synchronize(with: self.playerItem)
```

```
The `CompositionDebugView` `synchronize` function uses the passed-in player item parameter to synchronize with its own drawing. It builds its visual display from the composition, video composition, and audio mix associated with the player item.
```swift
func synchronize(with playerItem: AVPlayerItem) {
    self.playerItem = playerItem
    
    if let composition = playerItem.asset as? AVMutableComposition {
        compositionTrackSegmentInfo = trackSegmentInfo(from: composition.tracks)
        duration = CMTimeMaximum(duration, composition.duration)
    }

    if let audioMix = playerItem.audioMix {
        volumeRampAsPoints = volumeRampPoints(from: audioMix, duration: duration)
    }

    if let videoComposition = playerItem.videoComposition {
        videoCompositionStages = videoCompStageInfo(from: videoComposition.instructions)
    }

    drawingLayer.setNeedsDisplay()
    self.setNeedsDisplay()
}
```

#### 
The `SimpleEditor` class initialization creates an  to merge the videos.
The `SimpleEditor` class initialization creates an  to merge the videos.
```swift
private lazy var editorComposition: AVMutableComposition = {
    var comp = AVMutableComposition()
```

```
Then the `SimpleEditor` initializer calls the `createComposition` function to stitch the provided video clips together. It inserts the clips into alternating video and audio tracks in the composition.
```swift
/*
 Place clips into alternating video and audio tracks in the composition,
 and overlap them with transitionDuration. Set up the video composition to cycle
 between "pass through A", "transition from A to B", and "pass through B".
*/
var nextClipStart = CMTime.zero
for clipIndex in 0..<clips.count {
    // Alternating targets: 0, 1, 0, 1, ...
    let asset = clips[clipIndex].asset
    let clipTimeRange = clips[clipIndex].availableTimeRange
    do {
        let clipVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        try compVideoTrks[clipIndex % 2].insertTimeRange(clipTimeRange, of: clipVideoTrack, at: nextClipStart)
        let clipAudioTracks = asset.tracks(withMediaType: AVMediaType.audio)
        if clipAudioTracks.isEmpty {
            SimpleEditorUtils.display("Each clip must have an audio track.")
            return false
        }
        try compAudioTrks[clipIndex % 2].insertTimeRange(clipTimeRange, of: clipAudioTracks[0], at: nextClipStart)
```

```
The sample overlaps the end of the first clip with the start of the second clip, and creates time ranges for a transition effect during the overlap period. The first clip ends with the transition, and the second clip begins with the transition. To set up the transition effect for the overlap period only, the sample enables compositing during the overlap, and disables it for the rest of the video composition. To do that, the sample creates a passthrough time range for each clip that excludes the transition period. This passthrough time range instructs the video compositor to pass through the frames without compositing.
```swift
passThroughTimeRanges[clipIndex] = CMTimeRangeMake(start: nextClipStart, duration: clipTimeRange.duration)
if clipIndex > 0 {
    passThroughTimeRanges[clipIndex].start = CMTimeAdd(passThroughTimeRanges[clipIndex].start,
                    transitionDuration)
}
passThroughTimeRanges[clipIndex].duration = CMTimeSubtract(passThroughTimeRanges[clipIndex].duration,
                    transitionDuration)

/*
 The end of this clip overlaps the start of the next by
 transitionDuration.
*/
nextClipStart = CMTimeSubtract(CMTimeAdd(nextClipStart, clipTimeRange.duration), transitionDuration)

// Retain the time range for the transition to the next item.
if clipIndex + 1 < clips.count {
    transitionTimeRanges[clipIndex] = CMTimeRangeMake(start: nextClipStart, duration: transitionDuration)
}
```

#### 
The `SimpleEditor` class initialization creates an  to apply effects between clips, and an  for mixing the audio tracks.
The `SimpleEditor` class initialization creates an  to apply effects between clips, and an  for mixing the audio tracks.
```swift
private var editorAudioMix = AVMutableAudioMix()

private lazy var editorVideoComposition: AVMutableVideoComposition = {
    var videoComp = AVMutableVideoComposition()
    // Every videoComposition needs these properties to be set:
    videoComp.frameDuration = CMTimeMake(value: 1, timescale: frameDuration)
    videoComp.renderSize = editorComposition.naturalSize
    return videoComp
}()
```

```
Then the `SimpleEditor` initializer calls the `createVideoCompAndAudioMix` function to add an opacity ramp transition between the video clips, and a volume ramp between the audio tracks.
```swift
instructions.append(passThroughInstruction)

if currIndex + 1 < clips.count {
    // Add a transition from clip i to clip i+1.
    let transitionInstruction = AVMutableVideoCompositionInstruction()
    transitionInstruction.timeRange = transitionTimeRanges[currIndex]
    let fromLayer = AVMutableVideoCompositionLayerInstruction(assetTrack:
                        compVideoTracks[alternatingIndex])
    let toLayer = AVMutableVideoCompositionLayerInstruction(assetTrack:
                    compVideoTracks[1 - alternatingIndex])
    // Sets an opacity ramp to apply during the specified time range.
    toLayer.setOpacityRamp(fromStartOpacity: 0.0, toEndOpacity: 1.0,
                        timeRange: transitionTimeRanges[currIndex])

    transitionInstruction.layerInstructions = [toLayer, fromLayer]

    instructions.append(transitionInstruction)

    // Add an audio mix to the first clip to fade in the volume ramps.
    let trackMix1 = AVMutableAudioMixInputParameters(track: compAudioTracks[0])
    trackMix1.setVolumeRamp(fromStartVolume: 1.0, toEndVolume: 0.0,
                            timeRange: transitionTimeRanges[0])

    trackMixArray.append(trackMix1)

    // Add an audio mix to the second clip to fade out the volume ramps.
    let trackMix2 = AVMutableAudioMixInputParameters(track: compAudioTracks[1])
    trackMix2.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: 1.0,
                            timeRange: transitionTimeRanges[0])
    trackMix2.setVolumeRamp(fromStartVolume: 1.0, toEndVolume: 1.0,
                            timeRange: passThroughTimeRanges[1])
    trackMixArray.append(trackMix2)
}

editorAudioMix.inputParameters = trackMixArray
editorVideoComposition.instructions = instructions
```

#### 
The sample implements the  protocol methods in the `SimpleEditor` class to debug the video composition. These methods identify errors and indicate whether validation of a video composition needs to continue after finding specific errors.
The sample’s implementation of each of these functions displays an appropriate error dialog, and returns `false` to stop any further validation of the video composition. See the  documentation for more information.
```swift
func videoComposition(_ videoComposition: AVVideoComposition, shouldContinueValidatingAfterFindingEmptyTimeRange timeRange: CMTimeRange) -> Bool {
        SimpleEditorUtils.display("Empty time range detected during validation.")
        return false // Stop validation after finding errors.
}

func videoComposition(_ videoComposition: AVVideoComposition, shouldContinueValidatingAfterFindingInvalidTimeRangeIn videoCompositionInstruction: AVVideoCompositionInstructionProtocol) -> Bool {
        SimpleEditorUtils.display("Invalid time range detected during validation.")
        return false // Stop validation after finding errors.
}

func videoComposition(_ videoComposition: AVVideoComposition, shouldContinueValidatingAfterFindingInvalidValueForKey key: String) -> Bool {
        SimpleEditorUtils.display("Invalid value for \(key) detected during validation.")
        return false // Stop validation after finding errors.
}

func videoComposition(_ videoComposition: AVVideoComposition, shouldContinueValidatingAfterFindingInvalidTrackIDIn videoCompositionInstruction: AVVideoCompositionInstructionProtocol, layerInstruction: AVVideoCompositionLayerInstruction, asset: AVAsset) -> Bool {
        SimpleEditorUtils.display("Invalid track ID detected during validation.")
        return false // Stop validation after finding errors.
}
```


## Enhancing live video by leveraging TrueDepth camera data
> https://developer.apple.com/documentation/avfoundation/enhancing-live-video-by-leveraging-truedepth-camera-data

### 
#### 
#### 
Set up an  on a separate thread via the session queue. Initialize this session queue before configuring the camera for capture.
```swift
// Communicate with the session and other session objects on this queue.
private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], autoreleaseFrequency: .workItem)
```

```
The  method is a blocking call which can take a long time. Dispatch session setup to the sessionQueue so the main queue isn’t blocked, allowing the app’s UI to stay responsive.
```swift
sessionQueue.async {
    self.configureSession()
}
```

Setting up the camera for video capture follows many of the same steps as normal video capture. See  for details on configuring streaming setup.
On top of normal setup, request depth data by declaring a separate output:
```swift
private let depthDataOutput = AVCaptureDepthDataOutput()
```

```
Explicitly add this output type to your capture session:
```swift
if session.canAddOutput(depthDataOutput) {
    session.addOutput(depthDataOutput)
    depthDataOutput.isFilteringEnabled = true
    if let connection = depthDataOutput.connection(with: .depthData) {
        connection.isEnabled = true
    } else {
        print("No AVCaptureConnection")
    }
} else {
    print("Could not add depth data output to the session")
    setupResult = .configurationFailed
    session.commitConfiguration()
    return
}
```

```
Search for the highest resolution available with floating-point depth values, and lock the configuration to the format.
```swift
let depthFormats = videoDevice.activeFormat.supportedDepthDataFormats
let depth32formats = depthFormats.filter({
    CMFormatDescriptionGetMediaSubType($0.formatDescription) == kCVPixelFormatType_DepthFloat32
})
if depth32formats.isEmpty {
    print("Device does not support Float32 depth format")
    setupResult = .configurationFailed
    session.commitConfiguration()
    return
}

let selectedFormat = depth32formats.max(by: { first, second in
    CMVideoFormatDescriptionGetDimensions(first.formatDescription).width <
        CMVideoFormatDescriptionGetDimensions(second.formatDescription).width })
```

```
Synchronize the normal RGB video data with depth data output. The first output in the dataOutputs array is the master output.
```swift
outputSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [videoDataOutput, depthDataOutput, metadataOutput])
outputSynchronizer!.setDelegate(self, queue: dataOutputQueue)
```

#### 
Assume the foreground to be a human face. You can accomplish face detection through the Vision framework’s , but this sample doesn’t need anything else from Vision, so it’s simpler to consult the  for .
```swift
self.session.addOutput(metadataOutput)
if metadataOutput.availableMetadataObjectTypes.contains(.face) {
    metadataOutput.metadataObjectTypes = [.face]
}
```

```
Using the , locate the face’s bounding box and center. Assume there is only one face and take the first one in the metadata object.
```swift
if let syncedMetaData: AVCaptureSynchronizedMetadataObjectData =
    synchronizedDataCollection.synchronizedData(for: metadataOutput) as? AVCaptureSynchronizedMetadataObjectData,
    let firstFace = syncedMetaData.metadataObjects.first,
    let connection = self.videoDataOutput.connection(with: AVMediaType.video),
    let face = videoDataOutput.transformedMetadataObject(for: firstFace, connection: connection) {
    let faceCenter = CGPoint(x: face.bounds.midX, y: face.bounds.midY)
```

```
Depth maps differ from their normal camera image counterparts in resolution; as a result, normal image coordinates differ from depth map coordinates by a scale factor. Compute the scale factor and transform the face’s center to depth map coordinates.
```swift
let scaleFactor = CGFloat(CVPixelBufferGetWidth(depthPixelBuffer)) / CGFloat(CVPixelBufferGetWidth(videoPixelBuffer))
let pixelX = Int((faceCenter.x * scaleFactor).rounded())
let pixelY = Int((faceCenter.y * scaleFactor).rounded())
```

```
Once you have the face in depth map coordinates, threshold the image to create a binary mask image, where the foreground pixels are `1`, and the background pixels are `0`.
```swift
let depthWidth = CVPixelBufferGetWidth(depthPixelBuffer)
let depthHeight = CVPixelBufferGetHeight(depthPixelBuffer)

CVPixelBufferLockBaseAddress(depthPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

for yMap in 0 ..< depthHeight {
    let rowData = CVPixelBufferGetBaseAddress(depthPixelBuffer)! + yMap * CVPixelBufferGetBytesPerRow(depthPixelBuffer)
    let data = UnsafeMutableBufferPointer<Float32>(start: rowData.assumingMemoryBound(to: Float32.self), count: depthWidth)
    for index in 0 ..< depthWidth {
        if data[index] > 0 && data[index] <= depthCutOff {
            data[index] = 1.0
        } else {
            data[index] = 0.0
        }
    }
}
```

#### 
The depth map doesn’t share the RGB image’s sharp resolution, so the mask may contain holes along the interface between foreground and background. Once you have a downsampled mask image, use a Gaussian filter to smooth out the holes, so the interface doesn’t look jagged or pixelated. Clamp your image before filtering it, and crop it afterward, so it retains the proper size when applied with the original image.
```swift
let depthMaskImage = CIImage(cvPixelBuffer: depthPixelBuffer, options: [:])

// Smooth edges to create an alpha matte, then upscale it to the RGB resolution.
let alphaUpscaleFactor = Float(CVPixelBufferGetWidth(videoPixelBuffer)) / Float(depthWidth)
let alphaMatte = depthMaskImage.clampedToExtent()
    .applyingFilter("CIGaussianBlur", parameters: ["inputRadius": blurRadius])
    .applyingFilter("CIGammaAdjust", parameters: ["inputPower": gamma])
    .cropped(to: depthMaskImage.extent)
    .applyingFilter("CIBicubicScaleTransform", parameters: ["inputScale": alphaUpscaleFactor])
```

#### 
The final step is applying your filtered smooth binary mask to the input video frame.
Because you’ve performed image processing in Core Image using the `CIGaussianBlur` and `CIGammaAdjust` filters, it’s most computationally efficient to apply the resulting mask in Core Image, as well. That means converting your video from  format to  format, allowing you to apply the alpha matte to the original image, and blend in your custom background image with the `CIBlendWithMask` filter.
```swift
let image = CIImage(cvPixelBuffer: videoPixelBuffer)

// Apply alpha matte to the video.
var parameters = ["inputMaskImage": alphaMatte]
if let background = self.backgroundImage {
    parameters["inputBackgroundImage"] = background
}

let output = image.applyingFilter("CIBlendWithMask", parameters: parameters)
```

```
Update your preview to display the final composited image onscreen.
```swift
previewView.image = output
```


## Enhancing your app experience with the Camera Control
> https://developer.apple.com/documentation/avfoundation/enhancing-your-app-experience-with-the-camera-control

### 
#### 
Adopting system controls is straightforward. You create an instance by passing it an  object to configure and, optionally, an action to perform after a change occurs. The system calls this action on the `@MainActor` so your app can update its user interface in response to value changes.
```swift
// Retrieve the capture device to configure.
guard let device = activeVideoInput?.device else { return }

// Create a control to adjust the device's video zoom factor.
let systemZoomSlider = AVCaptureSystemZoomSlider(device: device) { zoomFactor in
    // Calculate and display a zoom value.
    let displayZoom = device.displayVideoZoomFactorMultiplier * zoomFactor
    // Update the user interface.
}

// Create a control to adjust the device's exposure bias.
let systemBiasSlider = AVCaptureSystemExposureBiasSlider(device: device)
```

#### 
- : A control that selects a value by index from a mutually exclusive set.
Create an instance of these controls by specifying a localized title that describes the control’s action, a symbol name from the SF Symbols library that defines its visual representation, and a collection of values:
```swift
// Create a control to adjust a capture device's lens position.
let focusSlider = AVCaptureSlider("Focus", symbolName: "scope", in: 0...1)

// Retrieve the titles from a list of camera filters.
let titles = filters.map { $0.localizedTitle }

// Create a control to select from a list of camera filters.
let filterPicker = AVCaptureIndexPicker("Filters", symbolName: "camera.filters", localizedIndexTitles: titles)
```

Each control type defines a `value` property that represents its current state, which it updates in response to user interaction. If the state a control represents can change from elsewhere in your app, such as other UI that selects a camera filter, update the control’s `value` property accordingly to keep its state in sync.
You define a control’s behavior by calling its  method, which takes an action to perform and a delegate queue on which to call it. Because camera apps typically use multiple actors to define key parts of their functionality, specifying the dispatch queue to use provides the flexibility to target a control’s behavior as necessary. For example, an app that isolates its camera behavior to a `CameraService` actor can define a serial dispatch queue to use as the actor’s executor as shown below:
```swift
actor CameraService {
    
    private let captureSession = AVCaptureSession()

    // A serial dispatch queue to use as the actor's executor.
    private let sessionQueue = DispatchSerialQueue(label: "com.myapp.sessionQueue")
    
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }
}
```

```
The app can then define a control’s action to target the session queue as follows:
```swift
// Create a control to adjust a capture device's lens position.
let focusSlider = AVCaptureSlider("Focus", symbolName: "scope", in: 0...1)
// Perform the slider's action on the session queue.
focusSlider.setActionQueue(sessionQueue) { lensPosition in
    do {
        try device.lockForConfiguration()
        device.setFocusModeLocked(lensPosition: lensPosition)
        device.unlockForConfiguration()
    } catch {
        print("Unable to change the lens position: \(error)")
    }
}
```

#### 
You make controls available to the system by adding them to your app’s capture session. Like the interfaces  defines for configuring a session’s inputs and outputs, it provides similar API for configuring capture controls as shown here:
```swift
func configureControls(_ controls: [AVCaptureControl]) {
    
    // Verify the host system supports controls; otherwise, return early.
    guard captureSession.supportsControls else { return }
    
    // Begin configuring the capture session.
    captureSession.beginConfiguration()
    
    // Remove previously configured controls, if any.
    for control in captureSession.controls {
        captureSession.removeControl(control)
    }
    
    // Iterate over the passed in controls.
    for control in controls {
        // Add the control to the capture session if possible.
        if captureSession.canAddControl(control) {
            captureSession.addControl(control)
        } else {
            print("Unable to add control \(control).")
        }
    }
    
    // Commit the capture session configuration.
    captureSession.commitConfiguration()
}
```

#### 
For the system to present the configured controls, a capture session needs to define a controls delegate. The framework provides the  protocol for this purpose that defines the following methods to respond to control activation and presentation events:
```swift
func sessionControlsDidBecomeActive(_ session: AVCaptureSession) {
    // The system presented controls.
}

func sessionControlsWillEnterFullscreenAppearance(_ session: AVCaptureSession) {
    // Hide user interface that distracts from control interactions.
}

func sessionControlsWillExitFullscreenAppearance(_ session: AVCaptureSession) {
    // Restore previously hidden user interface.
}

func sessionControlsDidBecomeInactive(_ session: AVCaptureSession) {
    // The system dismissed controls.
}
```


## Exporting video to alternative formats
> https://developer.apple.com/documentation/avfoundation/exporting-video-to-alternative-formats

### 
#### 
4. Create and configure an  instance, and then use it to perform the export.
The following example defines a method and then uses it to perform these steps:
```swift
func export(video: AVAsset,
            withPreset preset: String = AVAssetExportPresetHighestQuality,
            toFileType outputFileType: AVFileType = .mov,
            atURL outputURL: URL) async {
    
    // Check the compatibility of the preset to export the video to the output file type.
    guard await AVAssetExportSession.compatibility(ofExportPreset: preset,
                                                   with: video,
                                                   outputFileType: outputFileType) else {
        print("The preset can't export the video to the output file type.")
        return
    }
    
    // Create and configure the export session.
    guard let exportSession = AVAssetExportSession(asset: video,
                                                   presetName: preset) else {
        print("Failed to create export session.")
        return
    }
    exportSession.outputFileType = outputFileType
    exportSession.outputURL = outputURL
    
    // Convert the video to the output file type and export it to the output URL.
    await exportSession.export()
}

let video = // Your source AVAsset video. //
let outputURL = // The destination URL for your exported video. //

// Use a preset that encodes to H.264 to convert a video to the .mov file type,
// and asynchronously perform the export.
Task {
    await export(video: video,
                 withPreset: AVAssetExportPresetHighestQuality,
                 toFileType: .mov,
                 atURL: outputURL)
}
```


## Implementing flexible enhanced buffering for your content
> https://developer.apple.com/documentation/avfoundation/implementing-flexible-enhanced-buffering-for-your-content

### 
To implement flexible enhanced buffering, complete the following steps.
1. Create a serialization queue to perform all playback operations on, and create the audio renderer and the render synchronizer to establish the media timeline.
```swift
let serializationQueue = DispatchQueue(label: "sample.buffer.player.serialization.queue")
let audioRenderer = AVSampleBufferAudioRenderer()
let renderSynchronizer = AVSampleBufferRenderSynchronizer()
```

```
1. Observe when the renderer has flushed enqueued audio, such as when the rate of playback increases or decreases, and re-enqueue audio data starting from the time the flush occurred.
```swift
automaticFlushObserver = NotificationCenter.default.addObserver(forName: .AVSampleBufferAudioRendererWasFlushedAutomatically,
                                                                object: audioRenderer,
                                                                queue: nil) { [weak self] notification in
    self?.serializationQueue.async { [weak self] in
        guard let self = self else { return } 
        // Restart from the point where the flush interrupts the audio.
        let restartTime = (notification.userInfo?[AVSampleBufferAudioRendererFlushTimeKey] as? NSValue)?.timeValue
        self.autoflushPlayback(restartingAt: restartTime)
    }
}
```

```
1. Add the audio renderer to the render synchronizer, to tell the audio renderer to follow the media timeline.
```swift
renderSynchronizer.addRenderer(audioRenderer)
```

1. Tell the audio renderer to start processing audio data, and set the render synchronizer’s rate to `1` to start playback.
```
1. Tell the audio renderer to start processing audio data, and set the render synchronizer’s rate to `1` to start playback.
```swift
serializationQueue.async { [weak self] in
    guard let self = self else { return }
    // Start processing audio data and stop when there's no more data.
    self.audioRenderer.requestMediaDataWhenReady(on: serializationQueue) { [weak self] in
        guard let self = self else { return }
        while self.audioRenderer.isReadyForMoreMediaData {
            let sampleBuffer = self.nextSampleBuffer() // Returns nil at end of data.
            if let sampleBuffer = sampleBuffer {
                self.audioRenderer.enqueue(sampleBuffer)
            } else {
                // Tell the renderer to stop requesting audio data.
                audioRenderer.stopRequestingMediaData()
            }
        }
    }

    // Start playback at the natural rate of the media.
    self.renderSynchronizer.rate = 1.0
}
```


## Implementing simple enhanced buffering for your content
> https://developer.apple.com/documentation/avfoundation/implementing-simple-enhanced-buffering-for-your-content

### 
To implement simple enhanced buffering, complete the following steps.
1. Create a player.
```swift
let player = AVQueuePlayer()
```

1. Identify a URL that points to local or cloud content that you want to play.
2. Create an  instance with a URL, and then create an  instance with that asset.
```swift
let url = URL(string: "http://www.examplecontenturl.com")!
let asset = AVAsset(url: url)
let item = AVPlayerItem(asset: asset)
```

```
1. Give the player item to the player.
```swift
player.insert(item, after: nil)
```

```
1. Start playback.
```swift
player.play()
```


## Loading media data asynchronously
> https://developer.apple.com/documentation/avfoundation/loading-media-data-asynchronously

### 
#### 
The framework builds its asynchronous property-loading capabilities around two key types:  and . The framework uses the  class to define type-safe identifiers for properties with values that require asynchronous loading, and uses the  protocol to define the interface for objects to load properties asynchronously. , , and  adopt this protocol, which provides them an asynchronous  method with the following signature:
```swift
public func load<T>(_ property: AVAsyncProperty<Self, T>) async throws -> T
```

```
Call this method from an asynchronous context, and specify the `await` keyword to indicate that execution can suspend until it finishes loading the data. The method returns a type-safe value if it successfully loads the property, or throws an error if it fails.
```swift
// A CMTime value.
let duration = try await asset.load(.duration)
// An array of AVMetadataItem for the asset.
let metadata = try await asset.load(.metadata)
```

```
If you know in advance that you require loading several asset properties, you can use a variation of the  method that takes multiple identifiers and returns its result in a tuple. Like loading a single property value, loading several properties at the same time is also a type-safe operation.
```swift
// A CMTime value and an array of AVMetadataItem.
let (duration, metadata) = try await asset.load(.duration, .metadata)
```

#### 
 also provides a  method that returns the status of a property identifier. It returns an  value that indicates the state of the property’s value using the cases shown in the example below:
```swift
// Determine the loaded status of the metadata property.
switch asset.status(of: .metadata) {
case .notYetLoaded:
    // The initial state of a property.
case .loading:
    // The asset is actively loading the property value.
case .loaded(let metadata):
    // The property is ready to use.
case .failed(let error):
    // The property value fails to load.
}
```

```
The `.loaded` and `.failed` cases provide an associated value. The `.loaded` case contains the previously loaded property value, and the `.failed` case contains an error that indicates the reason for the failure. Having access to an associated value enables you to perform operations like checking a property’s status and accessing its value in a single step.
```swift
// Verify the metadata property is in a loaded state.
if case .loaded(let metadata) = asset.status(of: .metadata) {
    // Process the loaded value.
    processMetadata(metadata)
}
```

#### 
Some properties provide arrays of values, such as an asset’s  or its . In many cases, you’re interested in only a subset of those values.  and  also provide methods to filter their collections to only the values that you require. For example, the code listing below determines the audio sample rates that an asset contains. It calls the asset’s  to retrieve only its audio tracks. It iterates over each track and asynchronously loads the track’s format descriptions. Finally, it retrieves the sample rates from the stream description and sorts the results.
```swift
// Load the asset's audio tracks asynchronously.
let audioTracks = try await asset.loadTracks(withMediaType: .audio)
var allDescriptions = [CMFormatDescription]()
for track in audioTracks {
    // Load each audio track's format descriptions asynchronously.
    allDescriptions.append(contentsOf: try await track.load(.formatDescriptions))
}
// Collect the unique sample rates, and sort them from highest to lowest.
let sampleRates = Set(allDescriptions).map {
    Float($0.audioStreamBasicDescription?.mSampleRate ?? 0)
}.sorted(by: { $0 > $1 })
```


## Monitoring playback progress in your app
> https://developer.apple.com/documentation/avfoundation/monitoring-playback-progress-in-your-app

### 
#### 
The most common way to observe a player’s current time is at regular intervals. Observing it this way is useful when driving the state of a time display in a player’s user interface.
To observe the player’s current time at regular intervals, call its  method. This method takes a  value that represents the interval at which to observe the time, a serial dispatch queue, and a callback that the player invokes at the specified time interval. The following example adds an observer that the player calls every half-second during normal playback:
```swift
@Published private(set) var duration: TimeInterval = 0.0
@Published private(set) var currentTime: TimeInterval = 0.0

private let player = AVPlayer()
private var timeObserver: Any?

/// Adds an observer of the player timing.
private func addPeriodicTimeObserver() {
    // Create a 0.5 second interval time.
    let interval = CMTime(value: 1, timescale: 2)
    timeObserver = player.addPeriodicTimeObserver(forInterval: interval,
                                                  queue: .main) { [weak self] time in
        guard let self else { return }
        // Update the published currentTime and duration values.
        currentTime = time.seconds
        duration = player.currentItem?.duration.seconds ?? 0.0
    }
}

/// Removes the time observer from the player.
private func removePeriodicTimeObserver() {
    guard let timeObserver else { return }
    player.removeTimeObserver(timeObserver)
    self.timeObserver = nil
}
```

#### 
Another way to observe the player is when it crosses specific times boundaries during playback. You can respond to the passage of these times by updating your player UI or performing other actions.
To have the player notify your app as it cross specific points in the media timeline, call the player’s  method. This method takes an array of  objects that wrap  values that define your boundary times, a serial dispatch queue, and a callback closure. The following example shows how to define boundary times for each quarter of playback:
```swift
/// Adds an observer of the player traversing specific times during standard playback.
private func addBoundaryTimeObserver() async throws {
    
    // Asynchronously load the duration of the asset.
    let duration = try await asset.load(.duration)
    
    // Divide the asset's duration into quarters.
    let quarterDuration = CMTimeMultiplyByRatio(duration,
                                                multiplier: 1,
                                                divisor: 4)
    
    var currentTime = CMTime.zero
    var times = [NSValue]()
    
    // Calculate boundary times.
    while currentTime < duration {
        currentTime = currentTime + quarterDuration
        times.append(NSValue(time:currentTime))
    }
    
    timeObserver = player.addBoundaryTimeObserver(forTimes: times,
                                                  queue: .main) { [weak self] in
        // Update the percentage complete in the user interface.
    }
}
```


## Observing playback state in SwiftUI
> https://developer.apple.com/documentation/avfoundation/observing-playback-state-in-swiftui

### 
### 
AVFoundation supports monitoring playback state with Observation, but it doesn’t enable this feature by default. Instead, you opt-in to this behavior by setting a `true` value for the  `isObservationEnabled` property of the  class.
```swift
// Opt-in to observing with the Observation framework.
AVPlayer.isObservationEnabled = true
```

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


## Presenting chapter markers
> https://developer.apple.com/documentation/avfoundation/presenting-chapter-markers

### 
#### 
Chapter markers are a type of timed metadata that apply only to ranges of time within the asset’s timeline. You retrieve an asset’s chapter metadata using either the  or  methods. These methods become callable without blocking after you asynchronously load the value of the asset’s  key.
```swift
let asset = AVAsset(url: <# Asset URL #>)
let chapterLocalesKey = "availableChapterLocales"
 
asset.loadValuesAsynchronously(forKeys: [chapterLocalesKey]) {
    var error: NSError?
    let status = asset.statusOfValue(forKey: chapterLocalesKey, error: &error)
    if status == .loaded {
        let languages = Locale.preferredLanguages
        let chapterMetadata = asset.chapterMetadataGroups(bestMatchingPreferredLanguages: languages)
        // Process chapter metadata.
    }
    else {
        // Handle other status cases.
    }
}
```

#### 
The value returned from the methods described above is an array of  objects, each representing an individual chapter marker. An  object contains a , defining the time range to which its metadata applies, an array of  objects representing the chapter’s title, and optionally, its thumbnail image. The following example shows how to convert the  data into an array of custom model objects, called `Chapter`, to pass to the app’s view layer.
```swift
func convertTimedMetadataGroupsToChapters(groups: [AVTimedMetadataGroup]) -> [Chapter] {
    return groups.map { group in
        // Retrieve the title metadata items.
        let titleItems = AVMetadataItem.metadataItems(from: group.items,
                                                      filteredByIdentifier: .commonIdentifierTitle)

        // Retrieve the artwork metadata items.
        let artworkItems = AVMetadataItem.metadataItems(from: group.items,
                                                        filteredByIdentifier: .commonIdentifierArtwork)

        var title = "Default Title"
        var image = UIImage(named: "placeholder")!

        if let titleValue = titleItems.first?.stringValue {
            title = titleValue
        }

        if let imgData = artworkItems.first?.dataValue, let imageValue = UIImage(data: imgData) {
            image = imageValue
        }

        return Chapter(time: group.timeRange.start, title: title, image: image)
    }
}
```


## Processing spatial video with a custom video compositor
> https://developer.apple.com/documentation/avfoundation/processing-spatial-video-with-a-custom-video-compositor

### 
### 
### 
To indicate that they support processing spatial video, both implementations override the  property and provide a value of `true`.
The sample provides two  implementations: `MonoOutputCompositor` and `StereoOutputCompositor`. Both process mono or stereo input, but output either monoscopic or stereoscopic video respectively.
To indicate that they support processing spatial video, both implementations override the  property and provide a value of `true`.
```swift
/// A Boolean value that indicates whether the custom compositor supports source tagged buffers.
let supportsSourceTaggedBuffers = true
```

```
The framework calls the compositor’s  method to process each video frame, passing an  that provides access to the source frame data. The implementation handles both spatial and mono video sources:
```swift
func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {

    // If no track identifier is found, cancel the request and return.
    guard let firstTrackIDNumber = request.sourceTrackIDs.first else {
        request.finishCancelledRequest()
        return
    }

    let firstTrackID = CMPersistentTrackID(truncating: firstTrackIDNumber)

    // Attempt to retrieve the tagged buffers in the source track.
    if let taggedBuffers = request.sourceTaggedDynamicBuffers(byTrackID: firstTrackID) {
        // Process the tagged buffers from stereoscopic source track.
        processTaggedBuffers(taggedBuffers: taggedBuffers, request: request)
    }
    // Attempt to retrieve the monoscopic video frame in the source track.
    else if let pixelBuffer = request.sourceFrame(byTrackID: firstTrackID) {
        // Process pixel buffer from monoscopic source track.
        processMonoscopicBuffer(sourcePixelBuffer: pixelBuffer, request: request)
    }
    // No source frames were found. Finish with an error.
    else {
        request.finish(with: CompositorError.invalidSource)
    }
}
```

### 
The sample creates a video composition using the app’s `VideoCompositionBuilder` structure. This type’s `build()` method creates an  for the selected asset and indicates to use the custom compositor:
```swift
/// Builds a video composition object.
func build() async throws -> AVVideoComposition {

    // Create the video composition configuration object for the asset.
    var configuration = try await AVVideoComposition.Configuration(for: asset)
    // Specify the custom compositor implementation class to use.
    configuration.customVideoCompositorClass = compositorConfiguration.class

    ...

    return AVVideoComposition(configuration: configuration)
}
```

The configuration includes two key properties for spatial video:
The builder configures the output based on whether the compositor produces stereo or mono output:
```swift
if compositorConfiguration.outputsStereo {
    // Wrap the instructions in the app's custom instruction type.
    configuration.instructions = configuration.instructions.compactMap {
        SpatialVideoCompositionInstruction(
            instruction: $0,
            spatialConfiguration: spatialConfiguration,
            projectionTag: projectionTag
        )
    }
    configuration.outputBufferDescription = [
        [.stereoView(.leftEye), projectionTag, .mediaType(.video)],
        [.stereoView(.rightEye), projectionTag, .mediaType(.video)]
    ]
} else {
    configuration.outputBufferDescription = nil
    configuration.spatialVideoConfigurations = []
}
```

### 
Integrating the custom compositor for playback is straightforward. The sample’s `SampleModel` class creates an  with the video composition:
Integrating the custom compositor for playback is straightforward. The sample’s `SampleModel` class creates an  with the video composition:
```swift
/// Creates a new player to play the movie at the specified URL.
/// - Parameter url: The URL of the movie file to play.
private func makePlayer(url: URL) async throws -> AVPlayer {
    let asset = AVURLAsset(url: url)
    let playerItem = AVPlayerItem(asset: asset)
    // Create a video composition for the currently user-selected custom compositor.
    if let videoComposition = try await makeVideoComposition(for: asset) {
        playerItem.videoComposition = videoComposition
        playerItem.seekingWaitsForVideoCompositionRendering = true
    }
    return AVPlayer(playerItem: playerItem)
}
```

### 
The sample’s `ExportSessionExporter` class demonstrates export using . The export method selects the appropriate preset based on the video composition’s output type:
```swift
func export(asset: AVAsset, videoComposition: AVVideoComposition? = nil) async throws {

    // If this method receives a video composition that produces stereo output, use an MV-HEVC preset.
    // Note: the `outputsStereo` property is an app-specific extension.
    let preset = if let videoComposition, videoComposition.outputsStereo {
        AVAssetExportPresetMVHEVC4320x4320
    }
    // Otherwise, use a standard HEVC preset.
    else {
        AVAssetExportPresetHEVCHighestQuality
    }

    // Attempt to create an export session with the selected preset.
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: preset) else {
        throw ExportError.noExportSession
    }

    // If a valid video composition was passed to this method, set it on the export session.
    if let videoComposition {
        exportSession.videoComposition = videoComposition
    }

    ...
}
```

### 
The sample’s `ReaderWriterExporter` class provides fine-grained export control using  and . This approach requires more setup but offers greater flexibility over the export process.
The core export operation uses a read-write loop that processes each video frame:
```swift
// The read-write loop is executed in a dedicated dispatch queue.
writerInput.requestMediaDataWhenReady(on: DispatchQueue(label: "com.apple.spatialcompositor.reader")) {
    while writerInput.isReadyForMoreMediaData {

        guard let sampleBuffer = readerOutput.copyNextSampleBuffer() else {
            // A nil sample buffer indicates the end of the input.
            finishWritingAndResume()
            return
        }

        if let taggedBuffers = sampleBuffer.taggedBuffers, let taggedPixelBufferGroupReceiver {
            // Send tagged buffers to writer input via tagged pixel buffer group receiver.
            // Make sure the tagged buffers are `CMTaggedDynamicBuffers` with `layerID` tags.
            let wellFormedTaggedBuffers = taggedBuffers.ensureLayerIDTagsAndMakeDynamic(leftEyeLayer: 0, rightEyeLayer: 1)
            do {
                let pts = sampleBuffer.presentationTimeStamp
                if try !taggedPixelBufferGroupReceiver.appendImmediately(wellFormedTaggedBuffers, with: pts) {
                    finishWritingAndResume(error: .appendTaggedBuffersFailed)
                    return
                }
            } catch {
                finishWritingAndResume(error: .appendTaggedBuffersFailed)
                return
            }
        } else {
            // The reader output is a normal sample buffer. Send to writer input directly.
            writerInput.append(sampleBuffer)
        }
        // Send async notification for progress update.
        let percent = (Double) (sampleBuffer.presentationTimeStamp.seconds / assetDuration)
        statusContinuation.yield(ExporterStatus.exporting(progress: percent))
    }
}
```


## Providing an integrated view of your timeline when playing HLS interstitials
> https://developer.apple.com/documentation/avfoundation/providing-an-integrated-view-of-your-timeline-when-playing-hls-interstitials

### 
#### 
Open a Terminal window, change to the `/Source/LiveStreamExample/` directory, and run the following command to start the stream:
Using the examples under the Live stream examples section of the app requires running a local test stream. The project includes a Go script that starts a local web server that hosts this example stream. You must have  installed to run this script.
Open a Terminal window, change to the `/Source/LiveStreamExample/` directory, and run the following command to start the stream:
```None
go run liveStreamGenerator.go --http :8443 map.mp4 segment0.m4s segment1.m4s segment2.m4s
```


## Reading multiview 3D video files
> https://developer.apple.com/documentation/avfoundation/reading-multiview-3d-video-files

### 
#### 
The app first displays a button labeled Open MVHEVC File. When selected, the button presents an  for choosing video media. Next, the app initializes a `MediaDetailViewModel`, loading this file as an . Before opening the file to present any elements for a stereo video frame, the app ensures a playable, readable file, and gets its total length in time. This is all performed in the initializer.
```swift
init(filename: URL) {
    asset = AVURLAsset(url: filename)
    Task { @MainActor in
        do {
            let (duration, isPlayable, isReadable) = try await asset.load(.duration, .isPlayable, .isReadable)
            self.duration = duration.seconds
            self.isPlayable = isPlayable
            self.isReadable = isReadable
        } catch {
            self.error = error
        }
    }
}
```

#### 
After confirming the track is readable video data, the app initializes a `StereoViewModel`by calling  requesting a  track. This check confirms that the file meets the MV-HEVC specification and has valid stereo data.
```swift
if let track = try await asset.loadTracks(withMediaCharacteristic: .containsStereoMultiviewVideo).first {
    self.track = track
```

```
Next, the app pulls available timestamps for each frame in the track by calling `presentationTimesFor(track:asset:)`. The app places a video sample cursor at the start of the track with , then creates a new  and .
```swift
guard let cursor = track.makeSampleCursorAtFirstSampleInDecodeOrder() else {
    return []
}
let sampleBufferGenerator = AVSampleBufferGenerator(asset: asset, timebase: nil)
var presentationTimes = [CMTime]()
let request = AVSampleBufferRequest(start: cursor)
var numSamples: Int64 = 0
```

```
To read the timestamps, obtain the sample buffer for the current cursor from , then add the  for the frame. The cursor steps forward by calling , reading and caching timestamps for each frame in the buffer. When `stepInDecodeOrder(byCount:)` returns no next frame, sample times are in the cache and reading the video track completes.
```swift
repeat {
    let buf = try sampleBufferGenerator.makeSampleBuffer(for: request)
    presentationTimes.append(buf.presentationTimeStamp)
    numSamples = cursor.stepInDecodeOrder(byCount: 1)
} while numSamples == 1
```

#### 
After preparing timestamps, the app calls `loadVideoLayerIdsForTrack()` to get the layer IDs for the two tracks associated with the left and right eyes. The app calls to retrieve metadata, then filters the layer data out of the first available track’s . The filter predicate is , extracting only video layer IDs.
```swift
private func loadVideoLayerIdsForTrack(_ videoTrack: AVAssetTrack) async throws -> [Int64]? {
    let formatDescriptions = try await videoTrack.load(.formatDescriptions)
    var tags = [Int64]()
    if let tagCollections = formatDescriptions.first?.tagCollections {
        tags = tagCollections.flatMap({ $0 }).compactMap { tag in
            tag.value(onlyIfMatching: .videoLayerID)
        }
    }
    return tags
}
```

#### 
With the timestamp and left eye and right eye video layers identified, `readBufferFromAsset(at:)` calls the `readNextBufferFromAsset()` method of the app to retrieve and display the frame data. The method starts with a series of `guard` checks to ensure read access to the track, creates a local copy of the sample buffer by calling , and retrieves the tagged video buffers from the track.
```swift
guard let assetReader, let trackOutput else {
    return
}
guard assetReader.status == .reading else {
    publishState(.error(message: "UNEXPECTED STATUS \(assetReader.status)"))
    return
}
guard let sampleBuffer = trackOutput.copyNextSampleBuffer() else {
    publishState(.error(message: "READING SAMPLE BUFFER, STATUS \(assetReader.status), ERROR \(String(describing: assetReader.error))"))
    return
}
guard let taggedBuffers = sampleBuffer.taggedBuffers else {
    publishState(.error(message: "SAMPLE BUFFER CONTAINS NO TAGGED BUFFERS: \(sampleBuffer)"))
    return
}
guard taggedBuffers.count == 2 else {
    publishState(.error(message: "EXPECTED 2 TAGGED BUFFERS, GOT \(taggedBuffers.count)"))
    return
}
```

```
The app parses each  from the returned sample buffers into an image for display using . The app creates an  and sets it to the view content as either `leftEye` or `rightEye` depending on whether the view contains a  for the left or right eye.
```swift
taggedBuffers.forEach { taggedBuffer in
    switch taggedBuffer.buffer {
    case let .pixelBuffer(pixelBuffer):
        let ciimage = CIImage(cvPixelBuffer: pixelBuffer)
        let context: CIContext = CIContext(options: nil)
        let cgImage: CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
        let tags = taggedBuffer.tags
        Task {
            await MainActor.run {
                let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: 320, height: 240))
                if tags.contains(.stereoView(.leftEye)) {
                    leftEye = nsImage
                } else if tags.contains(.stereoView(.rightEye)) {
                    rightEye = nsImage
                }
            }
        }
    case .sampleBuffer(let samp):
        publishState(.error(message: "EXPECTED PIXEL BUFFER, GOT SAMPLE BUFFER \(samp)"))
    @unknown default:
        publishState(.error(message: "EXPECTED PIXEL BUFFER TYPE, GOT \(taggedBuffer.buffer)"))
    }
}
```


## Requesting authorization to capture and save media
> https://developer.apple.com/documentation/avfoundation/requesting-authorization-to-capture-and-save-media

### 
#### 
- If your app uses device cameras, include the  key in your app’s `Info.plist` file.
- If your app uses device microphones, include the  key in your app’s `Info.plist` file.
#### 
#### 
Always test the   method before setting up a capture session. If the user hasn’t granted or denied capture permission, the authorization status is . In this case, use the  method to tell the system to prompt the user.
Call  before starting capture, but only at a time that’s appropriate for your app. For example, if photo or video capture isn’t the main focus of your app, check for permission only when the user invokes your app’s camera-related features. Here’s an example:
```swift
var isAuthorized: Bool {
    get async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        // Determine if the user previously authorized camera access.
        var isAuthorized = status == .authorized
        
        // If the system hasn't determined the user's authorization status,
        // explicitly prompt them for approval.
        if status == .notDetermined {
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        }
        
        return isAuthorized
    }
}

func setUpCaptureSession() async {
    guard await isAuthorized else { return }
    // Set up the capture session.
}
```

#### 

## Retrieving media metadata
> https://developer.apple.com/documentation/avfoundation/retrieving-media-metadata

### 
#### 
 provides several ways to access its metadata. You can retrieve all of its metadata by loading the value of its  property. Alternatively, you can retrieve a subset of items that are common to all of the metadata formats it holds by loading the value of its  property.
To retrieve format-specific collections of metadata, like  or , call an asset’s  method, passing it a specific  to load. The example below iterates over the  an asset contains, and loads each format’s metadata items to process their values.
```swift
// A local or remote asset to inspect.
let asset = AVURLAsset(url: url)
for format in try await asset.load(.availableMetadataFormats) {
    let metadata = try await asset.loadMetadata(for: format)
    // Process the format-specific metadata collection.
    print("The available metadata format is \(metadata)")
}
```

#### 
After you load a collection of metadata, you can filter it to specific values using the class methods of . The example below shows how to use the  method to find items with an identifier of .
```swift
// Load the asset's metadata.
let metadata = try await asset.load(.metadata)
        
// Find the title in the common key space.
let titleItems = AVMetadataItem.metadataItems(from: metadata,
                                              filteredByIdentifier: .commonIdentifierTitle)
guard let item = titleItems.first else { return }
// Process the title item.
```

#### 
Retrieve the data a metadata item holds by loading its  property, which is an object that adopts the  and  protocols. You can manually cast the value to an appropriate type, but it’s safer and more convenient to use the metadata item’s type conversion properties. Instead of loading the  property, load its , , , or  properties as appropriate to convert it to a specific type. For example, the code listing below shows how to retrieve the artwork associated with an iTunes music track as a data value:
```swift
// The collection of iTunes metadata.
let iTunesMetadata = try await asset.loadMetadata(for: .iTunesMetadata)

// Filter metadata to find the asset's artwork.
guard let artworkItem = AVMetadataItem.metadataItems(from: iTunesMetadata,
                                                     filteredByIdentifier: .iTunesMetadataCoverArt).first else { return }

// Retrieve a Data object that contains the image data.
guard let imageData = try await artworkItem.load(.dataValue) else { return }
```


## Saving captured photos
> https://developer.apple.com/documentation/avfoundation/saving-captured-photos

### 
#### 
#### 
Use the   to request access to the photo library at an appropriate time, such as when the user first opens your app’s camera feature. Here’s an example:
```swift
var isPhotoLibraryReadWriteAccessGranted: Bool {
    get async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        // Determine if the user previously authorized read/write access.
        var isAuthorized = status == .authorized
        
        // If the system hasn't determined the user's authorization status,
        // explicitly prompt them for approval.
        if status == .notDetermined {
            isAuthorized = await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
        }
        
        return isAuthorized
    }
}
```

#### 
3. Create a  to add the photo resource.
The following code provides an example of this workflow:
```swift
func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if let error {
        print("Error processing photo: \(error.localizedDescription)")
        return
    }
    
    Task {
        await save(photo: photo)
    }
}

func save(photo: AVCapturePhoto) async {
    // Confirm the user granted read/write access.
    guard await isPhotoLibraryReadWriteAccessGranted else { return }
    
    // Create a data representation of the photo and its attachments.
    if let photoData = photo.fileDataRepresentation() {
        PHPhotoLibrary.shared().performChanges {
            // Save the photo data.
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: photoData, options: nil)
        } completionHandler: { success, error in
            if let error {
                print("Error saving photo: \(error.localizedDescription)")
                return
            }
        }
    }
}
```


## Selecting subtitles and alternative audio tracks
> https://developer.apple.com/documentation/avfoundation/selecting-subtitles-and-alternative-audio-tracks

### 
#### 
After you’ve retrieved the array of available options, you call the asset’s  method, passing it the desired characteristic. This method returns the associated `AVMediaSelectionGroup` object, or `nil` if no groups exist for the specified characteristic.
`AVMediaSelectionGroup` acts as a container for a collection of mutually exclusive `AVMediaSelectionOption` objects. The following example shows how you retrieve an asset’s media-selection groups and display their available options:
```swift
for characteristic in asset.availableMediaCharacteristicsWithMediaSelectionOptions {
    print("\(characteristic)")

    // Retrieve the AVMediaSelectionGroup for the specified characteristic.
    if let group = asset.mediaSelectionGroup(forMediaCharacteristic: characteristic) {
        // Print its options.
        for option in group.options {
            print("  Option: \(option.displayName)")
        }
    }
}
```

```
The output for an asset containing audio and subtitle media options looks similar to the following:
```swift
[AVMediaCharacteristicAudible]
  Option: English
  Option: Spanish

[AVMediaCharacteristicLegible]
  Option: English
  Option: German
  Option: Spanish
  Option: French
```

#### 
After you’ve retrieved an `AVMediaSelectionGroup` object for a particular media characteristic and identified the desired `AVMediaSelectionOption` object, the next step is to select it. You select a media option by calling  on the active . For instance, to present the asset’s Spanish subtitle option, you could select it as follows:
```swift
if let group = asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible) {
    let locale = Locale(identifier: "es-ES")
    let options =
        AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
    if let option = options.first {
        // Select Spanish-language subtitle option
        playerItem.select(option, in: group)
    }
}
```


## Setting up a capture session
> https://developer.apple.com/documentation/avfoundation/setting-up-a-capture-session

### 
#### 
All capture sessions need at least one capture input and capture output. Capture inputs ( subclasses) are media sources—typically recording devices like the cameras and microphone built into an iOS device or Mac. Capture outputs ( subclasses) use data provided by capture inputs to produce media, like image and movie files.
To use a camera for video input (to capture photos or movies), select an appropriate , create a corresponding , and add it to the session:
```swift
captureSession.beginConfiguration()
let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                          for: .video, position: .unspecified)
guard
    let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
    captureSession.canAddInput(videoDeviceInput)
    else { return }
captureSession.addInput(videoDeviceInput)
```

Next, add outputs for the kinds of media you plan to capture from the camera you’ve selected. For example, to enable capturing photos, add an  to the session:
```swift
let photoOutput = AVCapturePhotoOutput()
guard captureSession.canAddOutput(photoOutput) else { return }
captureSession.sessionPreset = .photo
captureSession.addOutput(photoOutput)
captureSession.commitConfiguration()
```

#### 
It’s important to let the user see input from the camera before choosing to snap a photo or start video recording, as in the viewfinder of a traditional camera. You can provide such a preview by connecting an  to your capture session, which displays a live video feed from the camera whenever the session is running.
 is a Core Animation layer, so you can display and style it in your interface as you would any other  subclass. The simplest way to add a preview layer to a UIKit app is to define a  subclass whose  is , as shown below.
```swift
class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
```

```
Then, to use the preview layer with a capture session, set the layer’s  property:
```swift
self.previewView.videoPreviewLayer.session = self.captureSession
```

#### 

## Speech synthesis
> https://developer.apple.com/documentation/avfoundation/speech-synthesis

### 
The Speech Synthesis framework manages voice and speech synthesis, and requires two primary tasks:
Create an  instance that contains the text to speak. Optionally, configure speech parameters, such as voice and rate, for each utterance.
```swift
// Create an utterance.
let utterance = AVSpeechUtterance(string: "The quick brown fox jumped over the lazy dog.")

// Configure the utterance.
utterance.rate = 0.57
utterance.pitchMultiplier = 0.8
utterance.postUtteranceDelay = 0.2
utterance.volume = 0.8

// Retrieve the British English voice.
let voice = AVSpeechSynthesisVoice(language: "en-GB")

// Assign the voice to the utterance.
utterance.voice = voice
```

```
Pass the utterance to an  instance to produce spoken audio.
```swift
// Create a speech synthesizer.
let synthesizer = AVSpeechSynthesizer()

// Tell the synthesizer to speak the utterance.
synthesizer.speak(utterance)
```


## Streaming depth data from the TrueDepth camera
> https://developer.apple.com/documentation/avfoundation/streaming-depth-data-from-the-truedepth-camera

### 
#### 
Set up an `AVCaptureSession` on a separate thread via the session queue. Initialize this session queue before configuring the camera for capture, like so:
```swift
private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], autoreleaseFrequency: .workItem)
```

```
The `startRunning` method is a blocking call that may take time to execute. Dispatch session setup to the session queue so the main queue isn’t blocked, allowing the app’s UI to stay responsive:
```swift
sessionQueue.async {
    self.configureSession()
}
```

Setting up the camera for video capture follows many of the same steps as normal video capture. See  for details on configuring streaming setup.
On top of normal setup, request depth data by declaring a separate output:
```swift
private let depthDataOutput = AVCaptureDepthDataOutput()
```

```
Explicitly add this output type to your capture session:
```swift
session.addOutput(depthDataOutput)
depthDataOutput.isFilteringEnabled = false
if let connection = depthDataOutput.connection(with: .depthData) {
    connection.isEnabled = true
} else {
    print("No AVCaptureConnection")
}
```

```
Search for the highest resolution available with floating-point depth values, and lock the configuration to the format.
```swift
let depthFormats = videoDevice.activeFormat.supportedDepthDataFormats
let filtered = depthFormats.filter({
    CMFormatDescriptionGetMediaSubType($0.formatDescription) == kCVPixelFormatType_DepthFloat16
})
let selectedFormat = filtered.max(by: {
    first, second in CMVideoFormatDescriptionGetDimensions(first.formatDescription).width < CMVideoFormatDescriptionGetDimensions(second.formatDescription).width
})

do {
    try videoDevice.lockForConfiguration()
    videoDevice.activeDepthDataFormat = selectedFormat
    videoDevice.unlockForConfiguration()
} catch {
    print("Could not lock device for configuration: \(error)")
    setupResult = .configurationFailed
    session.commitConfiguration()
    return
}
```

Synchronize the normal RGB video data with depth data output. The first output in the `dataOutputs` array is the master output.
```
Synchronize the normal RGB video data with depth data output. The first output in the `dataOutputs` array is the master output.
```swift
outputSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [videoDataOutput, depthDataOutput])
outputSynchronizer!.setDelegate(self, queue: dataOutputQueue)
```

#### 
The sample uses JET color coding to distinguish depth values, ranging from red (close) to blue (far). A slider controls the blending of the color code and the actual color values. Touching a pixel displays its depth value.
`DepthToJETConverter` performs the conversion. It separates the color spectrum into histogram bins, colors a Metal texture from depth values obtained in the image buffer, and renders that texture into the preview.
```swift
var cvTextureOut: CVMetalTexture?
CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, nil, textureFormat, width, height, 0, &cvTextureOut)
guard let cvTexture = cvTextureOut, let texture = CVMetalTextureGetTexture(cvTexture) else {
    print("Depth converter failed to create preview texture")
    CVMetalTextureCacheFlush(textureCache, 0)
    return nil
}
```

#### 
- Double-tap the screen to reset the initial position.
The sample implements a 3D point cloud as a `PointCloudMetalView`. It uses a Metal vertex shader to control geometry and a Metal fragment shader to color individual vertices, keeping the depth texture and color texture separate:
```objective-c
CVMetalTextureCacheRef _depthTextureCache;
CVMetalTextureCacheRef _colorTextureCache;
```

```
The depth frame’s depth map provides the basis for the Metal view’s depth texture:
```objective-c
CVPixelBufferRef depthFrame = depthData.depthDataMap;
CVMetalTextureRef cvDepthTexture = nullptr;
if (kCVReturnSuccess != CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                        _depthTextureCache,
                        depthFrame,
                        nil,
                        MTLPixelFormatR16Float,
                        CVPixelBufferGetWidth(depthFrame),
                        CVPixelBufferGetHeight(depthFrame),
                        0,
                        &cvDepthTexture)) {
    NSLog(@"Failed to create depth texture");
    CVPixelBufferRelease(colorFrame);
    return;
}

id<MTLTexture> depthTexture = CVMetalTextureGetTexture(cvDepthTexture);
```

```
The RGB image provides the basis for the Metal view’s color texture:
```objective-c
CVMetalTextureRef cvColorTexture = nullptr;
if (kCVReturnSuccess != CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                        _colorTextureCache,
                        colorFrame,
                        nil,
                        MTLPixelFormatBGRA8Unorm,
                        CVPixelBufferGetWidth(colorFrame),
                        CVPixelBufferGetHeight(colorFrame),
                        0,
                        &cvColorTexture)) {
    NSLog(@"Failed to create color texture");
    CVPixelBufferRelease(colorFrame);
    return;
}

id<MTLTexture> colorTexture = CVMetalTextureGetTexture(cvColorTexture);
```

#### 
Processing depth data from a live stream may cause the device to heat up. Keep tabs on the thermal state so you can alert the user if it exceeds a dangerous threshold.
```swift
@objc
func thermalStateChanged(notification: NSNotification) {
    if let processInfo = notification.object as? ProcessInfo {
        showThermalState(state: processInfo.thermalState)
    }
}

func showThermalState(state: ProcessInfo.ThermalState) {
    DispatchQueue.main.async {
        var thermalStateString = "UNKNOWN"
        if state == .nominal {
            thermalStateString = "NOMINAL"
        } else if state == .fair {
            thermalStateString = "FAIR"
        } else if state == .serious {
            thermalStateString = "SERIOUS"
        } else if state == .critical {
            thermalStateString = "CRITICAL"
        }
        
        let message = NSLocalizedString("Thermal state: \(thermalStateString)", comment: "Alert message when thermal state has changed")
        let alertController = UIAlertController(title: "TrueDepthStreamer", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
```


## Supporting AirPlay in your app
> https://developer.apple.com/documentation/avfoundation/supporting-airplay-in-your-app

### 
#### 
In iOS, tvOS, and watchOS, set your audio session’s route-sharing policy to `.longForm`. Long-form audio is anything other than system sounds, such as music, audiobooks, or podcasts. This setting identifies the audio that an app plays, such as in the following example.
```swift
let audioSession = AVAudioSession.sharedInstance()
try audioSession.setCategory(.playback, 
                             mode: .default, 
                             policy: .longFormAudio)
```

#### 
#### 
#### 

## Supporting Continuity Camera in your macOS app
> https://developer.apple.com/documentation/avfoundation/supporting-continuity-camera-in-your-macos-app

### 
#### 
#### 
When the app performs its initial setup, it configures two instances of : one to discover video devices, and the other to discover audio devices. It initializes each discovery session with a list of devices that includes a built-in device, and also an  device. Specifying an external unknown device type enables the discovery session to find compatible iPhone cameras and microphones, as well as supported capture devices from other vendors.
```swift
// Observe device cameras. Specify `.externalUnknown` to access an iPhone camera as an `AVCaptureDevice`.
videoDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .externalUnknown],
                                                         mediaType: .video,
                                                         position: .unspecified)
// Observe device microphones. Specify `.externalUnknown` to access an iPhone microphone as an `AVCaptureDevice`.
audioDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone, .externalUnknown],
                                                         mediaType: .audio,
                                                         position: .unspecified)
```

#### 
The sample app enables automatic camera selection by default, so when it performs its initial capture session configuration, it uses the system’s preferred camera as its default camera device as shown below.
```swift
private var defaultVideoCaptureDevice: AVCaptureDevice {
    get throws {
        // Access the system's preferred camera.
        if let device = AVCaptureDevice.systemPreferredCamera {
            return device
        } else {
            // No camera is available on the host system.
            throw Error.noVideoDeviceAvailable
        }
    }
}
```

#### 
The system-preferred camera changes based on device availability and user camera selection. The sample app provides a `PreferredCameraObserver` object that key-value observes the `systemPreferredCamera` property to monitor changes. When it observes a change to the value, it updates the state of its `@Published` property value as shown below.
```swift
class PreferredCameraObserver: NSObject, ObservableObject {
    
    private let systemPreferredKeyPath = "systemPreferredCamera"
    
    @Published private(set) var systemPreferredCamera: AVCaptureDevice?
    
    override init() {
        super.init()
        // Key-value observe the `systemPreferredCamera` class property on `AVCaptureDevice`.
        AVCaptureDevice.self.addObserver(self, forKeyPath: systemPreferredKeyPath, options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case systemPreferredKeyPath:
            // Update the observer's system-preferred camera value.
            systemPreferredCamera = change?[.newKey] as? AVCaptureDevice
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
```

```
If the app has automatic camera selection enabled, when it observes a change to the system-preferred camera, it automatically switches to the new device.
```swift
// The app calls this method when the system-preferred camera changes.
private func systemPreferredCameraChanged(to captureDevice: AVCaptureDevice) async {
    
    // If the SPC changes due to a device disconnection, reset the app
    // to its default device selections.
    guard isActiveVideoInputDeviceConnected else {
        resetToDefaultDevices()
        return
    }
    
    // If the "Automatic Camera Selection" checkbox is in an enabled state,
    // automatically select the new capture device.
    if isAutomaticCameraSelectionEnabled {
        await selectCaptureDevice(captureDevice)
    }
}
```

#### 
When the app selects a new device, it removes the old device input, attempts to add an input for the new device, and if it succeeds, updates the state of the appropriate active input device as shown below.
```swift
// Remove the current input from the session.
session.removeInput(currentInput)

// Attempt to add the new device to the capture session.
let newInput = try addInput(for: device)

// Camera
if mediaType == .video {
    activeVideoInput = newInput
    if isUserSelection {
        // If the device change is due to user selection, set the UPC value,
        // which updates the state of the system-preferred camera.
        AVCaptureDevice.userPreferredCamera = device
    }
}
// Microphone
else {
    activeAudioInput = newInput
}
```

#### 
When the app’s selected camera changes, the system evaluates the new capture device’s  to determine if it supports Center Stage. If it does, the app enables the Center Stage checkbox so you can change its value. Toggling the state of the feature sets the  to  and updates its enabled state.
```swift
@Published var isCenterStageEnabled = false {
    didSet {
        guard isCenterStageEnabled != AVCaptureDevice.isCenterStageEnabled else { return }
        AVCaptureDevice.centerStageControlMode = .cooperative
        AVCaptureDevice.isCenterStageEnabled = isCenterStageEnabled
    }
}
```

```
You can also enable Center Stage, along with video effects like Portrait mode and Studio Light, in Control Center. Because the enabled state of each effect can change externally, the app also key-value observes the state of these effects. Similar to how the app observes changes to the system-preferred camera, the app key-value observes the state of the , , and  properties and updates the user interface state as the values change.
```swift
AVCaptureDevice.self.addObserver(self, forKeyPath: centerStageKeyPath, options: [.new], context: nil)
AVCaptureDevice.self.addObserver(self, forKeyPath: portraitEffectKeyPath, options: [.new], context: nil)
AVCaptureDevice.self.addObserver(self, forKeyPath: studioLightKeyPath, options: [.new], context: nil)
```


## Supporting coordinated media playback
> https://developer.apple.com/documentation/avfoundation/supporting-coordinated-media-playback

### 
#### 
#### 
The sample app plays movies, which it represents with a `Movie` structure that defines essential data about an item in its library.
The sample app plays movies, which it represents with a `Movie` structure that defines essential data about an item in its library.
```swift
struct Movie: Hashable, Codable {
    var url: URL
    var title: String
    var description: String
}
```

```
To make movie watching a group experience, the sample creates a structure called `MovieWatchingActivity` that adopts the  protocol. This protocol defines a shareable experience in the app. The activity stores the movie to share with the group, and provides supporting metadata that the system displays when a user shares an activity.
```swift
// A group activity to watch a movie together.
struct MovieWatchingActivity: GroupActivity {
    
    // The movie to watch.
    let movie: Movie
    
    // Metadata that the system displays to participants.
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.type = .watchTogether
        metadata.fallbackURL = movie.url
        metadata.title = movie.title
        return metadata
    }
}
```

> **note:** `GroupActivity` extends , so any data that an activity stores must also conform to `Codable`.
#### 
When a user selects a movie, the sample determines whether it needs to play the movie for the current user only, or share it with the group. It makes this determination by calling the activity’s asynchronous  method, which enables the system to present an interface for the user to select their preferred action.
```swift
// Create a new activity for the selected movie.
let activity = MovieWatchingActivity(movie: selectedMovie)

// Await the result of the preparation call.
switch await activity.prepareForActivation() {
    
case .activationDisabled:
    // Playback coordination isn't active, or the user prefers to play the
    // movie apart from the group. Enqueue the movie for local playback only.
    self.enqueuedMovie = selectedMovie
    
case .activationPreferred:
    // The user prefers to share this activity with the group.
    // The app enqueues the movie for playback when the activity starts.
    do {
        _ = try await activity.activate()
    } catch {
        print("Unable to activate the activity: \(error)")
    }
    
case .cancelled:
    // The user cancels the operation. Do nothing.
    break
    
default: ()
}
```

#### 
When the sample activates a `MovieWatchingActivity`, the system creates a group session. It accesses the session by calling the  method, which returns sessions for the activity as an asynchronous sequence.
```swift
// Await new sessions to watch movies together.
for await groupSession in MovieWatchingActivity.sessions() {
    // Set the app's active group session.
    self.groupSession = groupSession
    
    // Remove previous subscriptions.
    subscriptions.removeAll()
    
    // Observe changes to the session state.
    groupSession.$state.sink { [weak self] state in
        if case .invalidated = state {
            // Set the groupSession to nil to publish
            // the invalidated session state.
            self?.groupSession = nil
            self?.subscriptions.removeAll()
        }
    }.store(in: &subscriptions)
    
    // Join the session to participate in playback coordination.
    groupSession.join()
    
    // Observe when the local user or a remote participant starts an activity.
    groupSession.$activity.sink { [weak self] activity in
        // Set the movie to enqueue it in the player.
        self?.enqueuedMovie = activity.movie
    }.store(in: &subscriptions)
}
```

#### 
The last step the sample takes to enable group playback is to access the player’s coordinator and connect it with the group session. It does this by calling the coordinator object’s  method, which connects it with the coordinators of other participants in the session.
```swift
// The group session to coordinate playback with.
private var groupSession: GroupSession<MovieWatchingActivity>? {
    didSet {
        guard let session = groupSession else {
            // Stop playback if a session terminates.
            player.rate = 0
            return
        }
        // Coordinate playback with the active session.
        player.playbackCoordinator.coordinateWithSession(session)
    }
}
```

#### 
In most cases, the sample keeps playback in sync with the group. However, there are times when it needs to prevent local interruptions from impacting other participants. In these situations, it disconnects from the group temporarily by issuing a playback suspension. An  automatically issues playback suspensions for common system events like network stalls and audio session interruptions. Apps can also define custom suspensions.
The sample provides a feature that lets a viewer quickly catch up with content they miss. This action doesn’t impact the group, so the app begins a custom playback suspension. It creates an extension on  that defines a new `whatHappened` suspension reason.
```swift
extension AVCoordinatedPlaybackSuspension.Reason {
    static var whatHappened = AVCoordinatedPlaybackSuspension.Reason(rawValue: "com.example.groupwatching.suspension.what-happened")
}
```

```
When a user taps the feature’s button in the user interface, the sample calls its `performWhatHappened()`  method. In this method, it starts the custom suspension, rewinds by 10 seconds, and then plays at double speed until playback catches up with the group.
```swift
func performWhatHappened() {
    
    // Rewind 10 seconds.
    let rewindDuration = CMTime(value: 10, timescale: 1)
    let rewindTime = player.currentTime() - rewindDuration
    
    // Start a custom suspension.
    let suspension = player.playbackCoordinator.beginSuspension(for: .whatHappened)
    player.seek(to: rewindTime)
    player.rate = 2.0
    
    DispatchQueue.main.asyncAfter(deadline: .now() + rewindDuration.seconds) {
        // End the suspension and resume playback with the group.
        suspension.end()
    }
}
```


## Supporting remote interactions in tvOS
> https://developer.apple.com/documentation/avfoundation/supporting-remote-interactions-in-tvos

### 
#### 
You can automatically get support for most controls to play and navigate media by using `AVPlayerViewController`. To provide support for additional remote control events, such as previous and next track commands, use the shared `MPRemoteCommandCenter` object. In the following example, `additionalRemoteCommands` contains the previous and next track commands registered with the remote command center, and `handleCommand(_:)` performs the corresponding action for the command it receives.
```swift
private func setupAdditionalRemoteCommands() {
    additionalRemoteCommands.forEach { [weak self] remoteCommand in
        guard let self = self else { return }
        // Remove each target before you add a new one.
        remoteCommand.mediaRemoteCommand.removeTarget(nil)
        remoteCommand.mediaRemoteCommand.addTarget { _ in
            self.handleCommand(remoteCommand)
        }
    }
}
```

```
You can also customize the behavior of commands that `AVPlayerViewController` natively supports by conforming to `AVPlayerViewControllerDelegate`. For example, this code maps the `skipToPreviousChannel` event to the `channelDown` action:
```swift
func playerViewController(_ playerViewController: AVPlayerViewController,
                          skipToPreviousChannel completion: @escaping (Bool) -> Void) {
    channelDown()
    completion(true)
}
```

#### 
When you create a custom player, use `MPRemoteCommandCenter` to implement support for the full suite of commands and events a remote can send to it. The following example shows how to customize the behavior for changing playback rate and skipping backward or forward. It also shows how to add targets to handle all other supported commands:
```swift
for supportedCommand in supportedRemoteCommands {
    switch supportedCommand {
        // Define the rates and intervals for the commands that require them.
    case .changePlaybackRate:
        let allSupportedRates = rewindSupportedRates + fastForwardSupportedRates
        commandCenter
            .changePlaybackRateCommand
            .supportedPlaybackRates = allSupportedRates.map {
                $0 as NSNumber
            }

    case .skipBackward:
        commandCenter
            .skipBackwardCommand
            .preferredIntervals = [skipInterval as NSNumber]

    case .skipForward:
        commandCenter
            .skipForwardCommand
            .preferredIntervals = [skipInterval as NSNumber]

    default:
        break
    }

    // Remove each target before you add a new one.
    supportedCommand.mediaRemoteCommand.removeTarget(nil)
    supportedCommand.mediaRemoteCommand.addTarget {
        self.handle(command: supportedCommand, withCommandEvent: $0)
    }
}
```

```
Additionally, this section demonstrates using the default  object to update the Now Playing info:
```swift
var nowPlayingInfo = [String: Any]()

nowPlayingInfo[MPMediaItemPropertyTitle] = currentProgram.title
nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = currentItem.duration.seconds
nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = currentProgram.isLive
nowPlayingInfo[MPNowPlayingInfoPropertyAssetURL] = currentProgram.playlistURL
nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player.rate
nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = self.defaultPlaybackRate
nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player.currentTime().seconds

// Set any other properties that are applicable to your application.

MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
```

#### 
The third section of this project includes a screen that displays visual feedback of user interactions with a remote. It does this by reporting remote events that the view controller receives from a remote to the view so it can blink the corresponding cell:
```swift
private func reportRemoteEvent(_ remoteEvent: RemoteEvent,
                               withState state: UIGestureRecognizer.State? = nil) {
    guard let remoteEventsView = self.view as? RemoteEventsView else { return }
    remoteEventsView.remoteEventReceived(remoteEvent, withState: state)
}
```

#### 
If your app displays a guide that lists channels and their corresponding programs, the fourth section of this project shows you how to page content in response to remote commands, such as to scroll to the previous page for a channel up press:
```swift
@objc private func channelUpPressed() {
    // Because of the defined height of the cells, `indexPathsForVisibleItems`
    // has a maximum of 14 items on screen at any given time.
    guard let targetItemInPreviousPageSectionIdx = collectionView
        .indexPathsForVisibleItems.sorted().first?.section else { return }

    // For each page section, channel cell is always item 0 and program
    // cells start from 1.
    let firstProgramItemIdx = 1
    let targetItemIdx = currentlyFocusedIndexPath?.item ?? firstProgramItemIdx
    channelUpDownTargetIndexPath = IndexPath(
        item: targetItemIdx,
        section: targetItemInPreviousPageSectionIdx
    )
    // Scroll to the previous page for a channel up press.
    channelUpDownScrollDirection = .up

    setNeedsFocusUpdate()
    updateFocusIfNeeded()
}
```


## Tagging media with video color information
> https://developer.apple.com/documentation/avfoundation/tagging-media-with-video-color-information

### 
#### 
> **note:**  Each represents indices, not actual values. The  and  describe these indices in the `‘colr’` extension of type `‘nclc’`.
#### 
- If the source buffers don’t have color property tags, the writer doesn’t tag the output with any color properties.
The following example code specifies the Rec. 709 output color space for the video color properties key in the output settings:
```swift
// Use the asset writer object you create.
let writer = AVAssetWriter(contentType: .movie)
        
let colorPropertySettings = [
    AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
    AVVideoYCbCrMatrixKey: AVVideoTransferFunction_ITU_R_709_2,
    AVVideoTransferFunctionKey: AVVideoYCbCrMatrix_ITU_R_709_2
]
        
let compressionSettings: [String: Any] = [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: 1920,
    AVVideoHeightKey: 1080,
    AVVideoColorPropertiesKey: colorPropertySettings
]

let input = AVAssetWriterInput(mediaType: .video,
                               outputSettings: compressionSettings)
writer.add(input)
```

#### 
You designate a working color space for the entire video composition using the  property. Set the transfer function using the  key, and the Y’CbCr matrix using the  key. Specify values suitable for the `AVVideoColorPrimariesKey`, , and  keys, respectively.
Here’s a code example:
```swift
let videoComposition = AVMutableVideoComposition()
videoComposition.colorPrimaries = AVVideoColorPrimaries_P3_D65
videoComposition.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2
videoComposition.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2
```

#### 
If you generate Core Video source buffers for rendering (for example, using a pixel buffer pool in Metal), you should tag them with color information.
You explicitly set the color space tags in the dictionary of attachments of the buffer as shown in the example below:
```swift
CVBufferSetAttachment(pixelBuffer, kCVImageBufferColorPrimariesKey, kCVImageBufferColorPrimaries_P3_D65, .shouldPropagate)
CVBufferSetAttachment(pixelBuffer, kCVImageBufferTransferFunctionKey, kCVImageBufferTransferFunction_ITU_R_709_2, .shouldPropagate)
CVBufferSetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, kCVImageBufferYCbCrMatrix_ITU_R_709_2, .shouldPropagate)
inputPixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
```

#### 
You access the low-level details about an asset’s video track media using . A `CMFormatDescriptionRef` object describes the media of a particular type (audio, video, and so on). You get the format descriptions for the asset track’s media sample references using the   property. Look in the format description for the  extension key that defines the color properties of the media. The `CMFormatDescription.h` header defines the color primary key values.
Here’s an example that checks for the  color primary key value in the  extension:
```swift
let assetTracks = try await asset.loadTracks(withMediaType: .video)
        
for assetTrack in assetTracks {
    let formatDescriptions = try await assetTrack.load(.formatDescriptions)
    for formatDescription in formatDescriptions {
        guard let colorPrimaries = CMFormatDescriptionGetExtension(formatDescription, extensionKey: kCMFormatDescriptionExtension_ColorPrimaries) else {
            return
        }

        if CFGetTypeID(colorPrimaries) == CFStringGetTypeID() {
            let result = CFStringCompareWithOptions((colorPrimaries as! CFString),
                                                    kCMFormatDescriptionColorPrimaries_ITU_R_709_2,
                                                    CFRangeMake(0, CFStringGetLength((colorPrimaries as! CFString))),
                                                    CFStringCompareFlags.compareCaseInsensitive)

            if result == CFComparisonResult.compareEqualTo {
                // The color space is Rec. 709.
            }
        }
    }
}
```

#### 
#### 
The  media characteristic indicates that the video track contains color primaries wider than Rec. 709 that the system can’t accurately represent. A wide color space, such as P3 D65, contains additional dynamic range that may benefit from special treatment when compositing in your workflow. You should exercise care to avoid clamping the colors back to the Rec. 709 space. If you don’t, it’s generally best to stay within the Rec. 709 space for your processing.
Here’s an example:
```swift
let asset = <# Your AVAsset #>
let wideGamutTracks = asset.tracks(withMediaCharacteristic: .usesWideGamutColorSpace)
if wideGamutTracks.count > 0 {
    // Use wide color aware processing.
} else {
    // Use Rec 709 processing.
}
```

#### 
Set the   property to `true` to receive buffers in their original color space. The default value (`false`) permits implicit color conversions to a nonwide gamut color space.
```swift
let allowWideColorSettings = [AVVideoAllowWideColorKey: true]
let readerOutput = AVAssetReaderOutput(outputSettings: allowWideColorSettings) 
```

#### 
You implement the optional  property and return `true` to indicate your custom video compositor handles frames that contain wide color properties. In this case, the compositor examines and honors color space tags on every single source frame buffer.
```swift
class MyCustomVideoCompositor : AVVideoCompositing { 
   // ...
   var supportsWideColorSourceFrames: Boolean  { return true }
}
```


## Tracking photo capture progress
> https://developer.apple.com/documentation/avfoundation/tracking-photo-capture-progress

### 
#### 
#### 
#### 
#### 
#### 
- If your capture process manages other resources, clean up those resources in your `didFinishCapture` method. If you use a separate photo capture delegate object for each capture, this is a good time to remove any strong references to such objects.
The code below shows one way to manage multiple photo capture delegate objects:
```swift
class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    var completionHandler: () -> () = {}
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        completionHandler()
    }
    // ... other delegate methods to handle capture results...
}

// Keep a set of in-progress capture delegates.
var capturesInProgress = Set<PhotoCaptureProcessor>()

func shootPhoto() {    
    // Make a new capture delegate for each capture and add it to the set.
    let captureProcessor = PhotoCaptureProcessor()
    capturesInProgress.insert(captureProcessor)
    
    // Schedule for the capture delegate to be removed from the set after capture.
    captureProcessor.completionHandler = { [weak self] in
        self?.capturesInProgress.remove(captureProcessor); return
    }
    
    self.photoOutput.capturePhoto(with: self.settingsForNextPhoto(), delegate: captureProcessor)
}

```


## Using AVFoundation to play and persist HTTP live streams
> https://developer.apple.com/documentation/avfoundation/using-avfoundation-to-play-and-persist-http-live-streams

### 
#### 
#### 
To play an item, tap one of the rows in the table. Tapping the item causes a transition to a new view controller. As part of that transition, the table view creates an `AssetPlaybackManager` and assigns the appropriate asset to it, as shown in the following example:
```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)

    if segue.identifier == AssetListTableViewController.presentPlayerViewControllerSegueID {
        guard let cell = sender as? AssetListTableViewCell,
            let playerViewControler = segue.destination as? AVPlayerViewController else { return }

        /*
         Grab a reference for the destinationViewController to use in later delegate callbacks from
         AssetPlaybackManager.
         */
        playerViewController = playerViewControler

        // Load the new Asset to playback into AssetPlaybackManager.
        AssetPlaybackManager.sharedManager.setAssetForPlayback(cell.asset)
    }
}
```

Assigning an asset to the `AssetPlaybackManager` causes it to create an `AVPlayerItem` for the asset, removing any previous asset in the process:
```
Assigning an asset to the `AssetPlaybackManager` causes it to create an `AVPlayerItem` for the asset, removing any previous asset in the process:
```swift
private var asset: Asset? {
    willSet {
        /// Remove any previous KVO observer.
        guard let urlAssetObserver = urlAssetObserver else { return }
        
        urlAssetObserver.invalidate()
    }
    
    didSet {
        if let asset {
            Task {
                do {
                    if try await asset.urlAsset.load(.isPlayable) {
                        playerItem = AVPlayerItem(asset: asset.urlAsset)
                        player.replaceCurrentItem(with: playerItem)
                    } else {
                        // The asset isn't playable, so reset the player state.
                        resetPlayer()
                    }
                } catch {
                    logger.error("Unable to load `isPlayable` property.")
                }
            }
        } else {
            resetPlayer()
        }
    }
}
```

The `AssetPlaybackManager` uses KVO to monitor the `AVPlayerItem` object’s `status` and initiates playback when the `status` becomes ready to play:
```
The `AssetPlaybackManager` uses KVO to monitor the `AVPlayerItem` object’s `status` and initiates playback when the `status` becomes ready to play:
```swift
playerItemObserver = playerItem?.observe(\AVPlayerItem.status, options: [.new, .initial]) { [weak self] (item, _) in
    guard let strongSelf = self else { return }
    
    if item.status == .readyToPlay {
        if !strongSelf.readyForPlayback {
            strongSelf.readyForPlayback = true
            strongSelf.delegate?.streamPlaybackManager(strongSelf, playerReadyToPlay: strongSelf.player)
        }
    } else if item.status == .failed {
        let error = item.error
        
        logger.error("Error: \(String(describing: error?.localizedDescription))")
    }
```

#### 
When the person initiates a download by tapping the button in the corresponding stream’s table view cell, an instance of `AssetPersistenceManager` calls the following function to create an `AVAssetDownloadTask` object with an `AVAssetDownloadConfiguration` to download multiple  for the  of the stream:
```swift
func downloadStream(for asset: Asset) async throws {

    // Get the default media selections for the asset's media selection groups.
    let preferredMediaSelection = try await asset.urlAsset.load(.preferredMediaSelection)

    /*
     Creates and initializes an `AVAssetDownloadTask` using an `AVAssetDownloadConfiguration` to download multiple `AVMediaSelections`
     on an `AVURLAsset`.
     The `primaryContentConfiguration` in `AVAssetDownloadConfiguration` requests for a variant with bitrate greater than one of the
     lower bitrate variants in the asset.
     */
    let config = AVAssetDownloadConfiguration(asset: asset.urlAsset, title: asset.stream.name)
    /// Primary content configuration setup.
    let primaryQualifier = AVAssetVariantQualifier(predicate: NSPredicate(format: "peakBitRate > 265000"))
    config.primaryContentConfiguration.variantQualifiers = [primaryQualifier]
    
    /// Creation of `AVAssetDownloadTask` with the above configured `AVAssetDownloadConfiguration`.
    let task = assetDownloadURLSession.makeAssetDownloadTask(downloadConfiguration: config)

    /// To better track the `AVAssetDownloadTask`, set the `taskDescription` to something unique for the sample.
    task.taskDescription = asset.stream.name

    activeDownloadsMap[task] = asset
    
    /// Use `task.progress` value to provide download progress updates in the UI.
    let progressObservation: NSKeyValueObservation = task.progress.observe(\.fractionCompleted) { progress, _ in
        Task { @MainActor in
            var userInfo = [String: Any]()
            userInfo[Asset.Keys.name] = asset.stream.name
            userInfo[Asset.Keys.percentDownloaded] = progress.fractionCompleted
            NotificationCenter.default.post(name: .AssetDownloadProgress, object: nil, userInfo: userInfo)
        }
    }
    self.progressObservers.append(progressObservation)

    task.resume()

    var userInfo = [String: Any]()
    userInfo[Asset.Keys.name] = asset.stream.name
    userInfo[Asset.Keys.downloadState] = Asset.DownloadState.downloading.rawValue
    userInfo[Asset.Keys.downloadSelectionDisplayName] = await displayNamesForSelectedMediaOptions(preferredMediaSelection)

    NotificationCenter.default.post(name: .AssetDownloadStateChanged, object: nil, userInfo: userInfo)
}
```

#### 
Tap the button in the corresponding stream’s table view cell to reveal the accessory view, then tap Cancel to stop downloading the stream. The following function in `AssetPersistenceManager` cancels the download by calling the `URLSessionTask`  method.
```swift
func cancelDownload(for asset: Asset) {
    var task: AVAssetDownloadTask?

    for (taskKey, assetVal) in activeDownloadsMap where asset == assetVal {
        task = taskKey
        break
    }

    task?.cancel()
}
```

#### 
Tap the button in the corresponding stream’s table view cell to reveal the accessory view, then tap Delete to delete the downloaded stream file. The following function in `AssetPersistenceManager` removes a downloaded stream on the device. First the asset URL corresponding to the file on the device is identified, then the `FileManager`  method is called to remove the downloaded stream at the specified URL.
```swift
func deleteAsset(_ asset: Asset) {
    let userDefaults = UserDefaults.standard

    do {
        if let localFileLocation = localAssetForStream(withName: asset.stream.name)?.urlAsset.url {
            try FileManager.default.removeItem(at: localFileLocation)

            userDefaults.removeObject(forKey: asset.stream.name)

            var userInfo = [String: Any]()
            userInfo[Asset.Keys.name] = asset.stream.name
            userInfo[Asset.Keys.downloadState] = Asset.DownloadState.notDownloaded.rawValue

            NotificationCenter.default.post(name: .AssetDownloadStateChanged, object: nil,
                                            userInfo: userInfo)
        }
    } catch {
        logger.error("An error occured deleting the file: \(error)")
    }
}
```

#### 
For example, here’s the code to calculate the total time spent playing the stream, obtained from the `AVPlayerItemAccessLog`:
For example, here’s the code to calculate the total time spent playing the stream, obtained from the `AVPlayerItemAccessLog`:
```swift
var totalDurationWatched: Double {
    // Compute total duration watched by iterating through the AccessLog events.
    var totalDurationWatched = 0.0
    if accessLog != nil && !accessLog!.events.isEmpty {
        for event in accessLog!.events where event.durationWatched > 0 {
                totalDurationWatched += event.durationWatched
        }
    }
    return totalDurationWatched
}
```


