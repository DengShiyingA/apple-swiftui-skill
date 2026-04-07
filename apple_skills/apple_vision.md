# Apple VISION Skill


## Analyzing a selfie and visualizing its content
> https://developer.apple.com/documentation/vision/analyzing-a-selfie-and-visualizing-its-content

### 
#### 
#### 
The sample uses  to allow a person to select the selfies to analyze, and sets the maximum number of images to 5 through the `maxSelectionCount` parameter. For more information on using `PhotosPicker`, see :
```swift
PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 5, matching: .images) {
    Text("Select Selfies")
}
```

The sample performs the `Vision` requests and displays the images using data, so the app converts each  to data:
```
The sample performs the `Vision` requests and displays the images using data, so the app converts each  to data:
```swift
for photo in selectedPhotos {
    if let image = try? await photo.loadTransferable(type: Data.self) {
        selectedPhotosData.append(image)
    }
}
```

#### 
By default, `DetectFaceLandmarksRequest` and `DetectFaceCaptureQualityRequest` need to locate the faces first before performing the rest of the request. Setting the `inputFaceObservations` property prevents the sample from performing `DetectFaceRectanglesRequest` more than once (which is unnecessary).
Using the `score` method on a `FaceObservation`, the sample sets the selfie’s score. The function returns the new `Selfie` object, which holds the photo, the score, and the results of the `DetectFaceLandmarksRequest`:
```swift
func processSelfie(photo: Data) async throws -> Selfie {
    /// Instantiate the `Vision` requests.
    let detectFacesRequest = DetectFaceRectanglesRequest()
    var qualityRequest = DetectFaceCaptureQualityRequest()
    var landmarksRequest = DetectFaceLandmarksRequest()
    
    /// Perform `DetectFaceRectanglesRequest` to locate all faces in the photo.
    let handler = ImageRequestHandler(photo)
    let faceObservations = try await handler.perform(detectFacesRequest)
    
    /// Set the faces that `DetectFaceLandmarksRequest` and `DetectFaceCaptureQualityRequest` analyze.
    landmarksRequest.inputFaceObservations = faceObservations
    qualityRequest.inputFaceObservations = faceObservations
        
    /// Perform `DetectFaceCaptureQualityRequest` and `DetectFaceLandmarksRequest` on the photo.
    let (qualityResults, landmarksResults) = try await handler.perform(qualityRequest, landmarksRequest)
    
    var score: Float = 0
    /// Set the capture-quality score of the photo if `Vision` detects one face.
    if qualityResults.count == 1 {
        score = qualityResults[0].captureQuality!.score
    /// Set the average capture-quality score if `Vision` detects multiple faces.
    } else if qualityResults.count > 1 {
        for face in qualityResults {
            score += face.captureQuality!.score
        }
        score /= Float(qualityResults.count)
    }
        
    return Selfie(photo: photo, score: score, landmarksResults: landmarksResults)
}
```

```
Analyzing a large collection of selfies with `Vision` requests can take time, so the app uses Swift concurrency to help with speed and efficiency. Using , the app processes the images in parallel. When the `processSelfie` method returns a new `Selfie` object, the app adds it to the `selfies` array. After the app processes all the images, it sorts the `selfies` array by capture-quality score. The function returns the new array of `Selfie` objects:
```swift
func processAllSelfies(photos: [Data]) async throws -> [Selfie] {
    var selfies = [Selfie]()
    
    try await withThrowingTaskGroup(of: Selfie.self) { group in
        for photo in photos {
            group.addTask {
                return try await processSelfie(photo: photo)
            }
        }
        
        /// Only add the photo to the `selfies` array if Vision detects a face.
        for try await selfie in group where selfie.facesDetected > 0 {
            selfies.append(selfie)
        }
    }
    
    /// Sort the selfies in descending order of their capture-quality scores.
    selfies.sort { $0.score > $1.score }
    
    return selfies
}
```

#### 
The sample provides custom `Shape` implementations to draw a rectangle around each face, and the face landmarks. For face rectangles, the app uses the  property on a `FaceObservation`. The `boundingBox` property contains the location and dimensions of the box in the form of a . The sample converts the `NormalizedRect` to a , and returns a  to draw the rectangle:
```swift
struct BoundingBox: Shape {
    private let normalizedRect: NormalizedRect
    
    init(observation: any BoundingBoxProviding) {
        normalizedRect = observation.boundingBox
    }
    
    func path(in rect: CGRect) -> Path {
        let rect = normalizedRect.toImageCoordinates(rect.size, origin: .upperLeft)
        return Path(rect)
    }
}
```

The sample creates a `BoundingBox` object for each face in the photo, and overlays them on the image:
```
The sample creates a `BoundingBox` object for each face in the photo, and overlays them on the image:
```swift
.overlay {
    ForEach(selfie.landmarkResults, id: \.self) { observation in
        BoundingBox(observation: observation)
            .stroke(.red, lineWidth: 2)
    }
}
```

#### 
To create and display face landmarks on the image, the sample uses the custom `FaceLandmark` structure. Each `FaceObservation` from the `DetectFaceLandmarksRequest` contains a collection of landmarks as regions. A region contains all the points the sample needs to draw the outline. The possible regions are `faceContour`, `innerLips`, `leftEye`, `leftEyebrow`, `leftPupil`, `medianLine`, `nose`, `noseCrest`, `outerLips`, `rightEye`, `rightEyebrow`, and `rightPupil`.
The sample converts a region’s  collection to a  collection, and draws a path from one point to the next. When it reaches the last point, the sample closes the path:
```swift
struct FaceLandmark: Shape {
    let region: FaceObservation.Landmarks2D.Region
    
    func path(in rect: CGRect) -> Path {
        let points = region.pointsInImageCoordinates(rect.size, origin: .upperLeft)
        let path = CGMutablePath()
        
        path.move(to: points[0])
        
        for index in 1..<points.count {
            path.addLine(to: points[index])
        }
        
        if region.pointsClassification == .closedPath {
            path.closeSubpath()
        }
        
        return Path(path)
    }
}
```

For each face `Vision` detects in an image, the sample creates `FaceLandmark` objects and overlays them on the image:
```
For each face `Vision` detects in an image, the sample creates `FaceLandmark` objects and overlays them on the image:
```swift
.overlay {
    ForEach(selfie.landmarksResults, id: \.self) { observation in
        FaceLandmark(region: observation.landmarks!.faceContour)
            .stroke(.white, lineWidth: 2)
        
        // ..
    }
}
```


## Applying Matte Effects to People in Images and Video
> https://developer.apple.com/documentation/vision/applying-matte-effects-to-people-in-images-and-video

### 
#### 
The app uses two Vision requests to perform its logic:  and . It uses `VNDetectFaceRectanglesRequest` to detect a bounding rectangle around a person’s face. The observation the request produces also includes the , , and new in iOS and tvOS 15 and macOS 12, the  angles of the rectangle. The app uses the angles to dynamically calculate background colors as the user moves their head.
```swift
// Create a request to detect face rectangles.
facePoseRequest = VNDetectFaceRectanglesRequest { [weak self] request, _ in
    guard let face = request.results?.first as? VNFaceObservation else { return }
    // Generate RGB color intensity values for the face rectangle angles.
    self?.colors = AngleColors(roll: face.roll, pitch: face.pitch, yaw: face.yaw)
}
facePoseRequest.revision = VNDetectFaceRectanglesRequestRevision3
```

Because the sample processes live video, it chooses `.balanced`, which provides a mixture of accuracy and performance. It also sets the format of the mask image that the request generates to an 8-bit, one-component format where `0` represents black.
```swift
// Create a request to segment a person from an image.
segmentationRequest = VNGeneratePersonSegmentationRequest()
segmentationRequest.qualityLevel = .balanced
segmentationRequest.outputPixelFormat = kCVPixelFormatType_OneComponent8
```

#### 
The sample captures video from the front-facing camera and performs the requests on each frame. After the requests finish processing, the app retrieves the image mask from result of the segmentation request and passes it and original frame to the the app’s `blend(original:mask:)` method for further processing.
```swift
private func processVideoFrame(_ framePixelBuffer: CVPixelBuffer) {
    // Perform the requests on the pixel buffer that contains the video frame.
    try? requestHandler.perform([facePoseRequest, segmentationRequest],
                                on: framePixelBuffer,
                                orientation: .right)
    
    // Get the pixel buffer that contains the mask image.
    guard let maskPixelBuffer =
            segmentationRequest.results?.first?.pixelBuffer else { return }
    
    // Process the images.
    blend(original: framePixelBuffer, mask: maskPixelBuffer)
}
```

#### 
The sample processes the results of the requests by taking the original frame, the mask image, and a background image that it dynamically generates based on the roll, pitch, and yaw angles of the user’s face. It creates a  object for each image.
```swift
// Create CIImage objects for the video frame and the segmentation mask.
let originalImage = CIImage(cvPixelBuffer: framePixelBuffer).oriented(.right)
var maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)

// Scale the mask image to fit the bounds of the video frame.
let scaleX = originalImage.extent.width / maskImage.extent.width
let scaleY = originalImage.extent.height / maskImage.extent.height
maskImage = maskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))

// Define RGB vectors for CIColorMatrix filter.
let vectors = [
    "inputRVector": CIVector(x: 0, y: 0, z: 0, w: colors.red),
    "inputGVector": CIVector(x: 0, y: 0, z: 0, w: colors.green),
    "inputBVector": CIVector(x: 0, y: 0, z: 0, w: colors.blue)
]

// Create a colored background image.
let backgroundImage = maskImage.applyingFilter("CIColorMatrix",
                                               parameters: vectors)
```

The app then scales the mask image to fit the bounds of the captured video frame, and dynamically generates a background image using a `CIColorMatrix` filter.
It blends the images and sets the result as the current image, which causes the view to render it on screen.
```swift
// Blend the original, background, and mask images.
let blendFilter = CIFilter.blendWithRedMask()
blendFilter.inputImage = originalImage
blendFilter.backgroundImage = backgroundImage
blendFilter.maskImage = maskImage

// Set the new, blended image as current.
currentCIImage = blendFilter.outputImage?.oriented(.left)
```


## Classifying images for categorization and search
> https://developer.apple.com/documentation/vision/classifying-images-for-categorization-and-search

### 
#### 
If an app can’t tolerate false positive results, the  method allows for a high-precision filter. A high-precision filter retains a smaller number of observations, but less chance to contain false positives. Increasing precision decreases recall, and increasing recall decreases precision. Testing can help determine the balance point that returns the best results for a specific use case.
The app stores the final results in the `observations` dictionary. The dictionary’s key is the identifier (the label of the observation), and its value is the confidence level.
```swift
// Returns an `ImageFile` object based on the `ClassifyImageRequest` results.
func classifyImage(url: URL) async throws -> ImageFile {
    var image = ImageFile(url: url)
    
    // Vision request to classify an image.
    let request = ClassifyImageRequest()
    
    // Perform the request on the image, and return an array of `ClassificationObservation` objects.
    let results = try await request.perform(on: url)
        // Use `hasMinimumPrecision` for a high-recall filter.
        .filter { $0.hasMinimumPrecision(0.1, forRecall: 0.8) }
        // Use `hasMinimumRecall` for a high-precision filter.
        // .filter { $0.hasMinimumRecall(0.01, forPrecision: 0.9) }
    
    // Add each classification identifier and its respective confidence level into the observations dictionary.
    for classification in results {
        image.observations[classification.identifier] = classification.confidence
    }
    
    return image
}
```

```
Processing a large collection of images can take time, so the app uses Swift concurrency to help with speed and efficiency. Using , the app processes the images in parallel instead of sequentially in a loop. When the request returns results, the app adds each image’s observations to an array. For more information on using Swift concurrency, see .
```swift
func classifyAllImages(urls: [URL]) async throws -> [ImageFile] {
    var images = [ImageFile]()
    
    try await withThrowingTaskGroup(of: ImageFile.self) { group in
        for url in urls {
            group.addTask {
                return try await classifyImage(url: url)
            }
        }
        
        for try await image in group {
            images.append(image)
        }
    }
    
    return images
}
```

#### 
The sample provides the ability to search for images by their classification labels. If the search bar is empty, the app presents all the images. If the search bar is not empty, the app only presents images with classification labels equal to the search term.
```swift
var searchResults: [ImageFile] {
    if searchTerm.isEmpty {
        // If the search bar is empty, keep all of the images available.
        return images
    } else {
        // The only images that are available are those that contain classification labels equal to the search term.
        return images.filter({ $0.observations.keys.contains(searchTerm) })
    }
}
```

```
Clicking an image navigates to the results view and displays the results of the image analysis. Using a `ForEach` loop, the app iterates through the observations. The  method sorts the observations in descending order of their confidence levels. The `ForEach` loop accesses the values of the observation with the dictionary’s key and value keywords. Note that any confidence values of `0.0` are greater than zero due to rounding.
```swift
List {
    if image.observations.isEmpty {
        Text("No observations found with significant confidence.")
            .font(.title2)
            .padding(10)
    }
                
    ForEach(image.observations.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
        Text("\(value, specifier: "%.2f"): \(key.capitalized)")
            .font(.title2)
            .padding(10)
    }
}
```


## Detecting Human Body Poses in Images
> https://developer.apple.com/documentation/vision/detecting-human-body-poses-in-images

### 
#### 
Vision provides its body pose-detection capabilities through , an image-based request type that detects key body points. The following example shows how to use  to perform a  for detecting body points in the specified .
```swift
// Get the CGImage on which to perform requests.
guard let cgImage = UIImage(named: "bodypose")?.cgImage else { return }

// Create a new image-request handler.
let requestHandler = VNImageRequestHandler(cgImage: cgImage)

// Create a new request to recognize a human body pose.
let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)

do {
    // Perform the body pose-detection request.
    try requestHandler.perform([request])
} catch {
    print("Unable to perform the request: \(error).")
}
```

#### 
After the request handler processes the request, it calls the request’s completion closure, passing it the request and any errors that occurred. Retrieve the observations by querying the request object for its , which it returns as an array of  objects. The request returns a unique observation for each detected human body pose, with each containing the recognized points and a confidence score indicating the accuracy of the observation.
```swift
func bodyPoseHandler(request: VNRequest, error: Error?) {
    guard let observations =
            request.results as? [VNHumanBodyPoseObservation] else { 
        return 
    }
    
    // Process each observation to find the recognized body pose points.
    observations.forEach { processObservation($0) }
}
```

#### 
Retrieve the points of interest from the observation by calling its  method. The argument you pass to this method is a key that identifies all of the points for a particular body region (see  for supported values). This method returns the recognized points for the region as a dictionary of  objects keyed by joint name. Each instance of  provides the `X` and `Y` coordinates, in normalized space, and a confidence score for the point. Ignore any recognized points with a  value of 0, because they’re invalid.
The following code example retrieves all of the recognized points for the torso and maps them to an array of  objects. The example first retrieves the recognized points of the torso by calling with the  key. It then iterates over the specific point keys of the torso and retrieves their associated  object. Finally, if a point’s  score is greater than 0, it extracts the point’s coordinates as a .
```swift
func processObservation(_ observation: VNHumanBodyPoseObservation) {
    
    // Retrieve all torso points.
    guard let recognizedPoints =
            try? observation.recognizedPoints(.torso) else { return }
    
    // Torso joint names in a clockwise ordering.
    let torsoJointNames: [VNHumanBodyPoseObservation.JointName] = [
        .neck,
        .rightShoulder,
        .rightHip,
        .root,
        .leftHip,
        .leftShoulder
    ]
    
    // Retrieve the CGPoints containing the normalized X and Y coordinates.
    let imagePoints: [CGPoint] = torsoJointNames.compactMap {
        guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }
        
        // Translate the point from normalized-coordinates to image coordinates.
        return VNImagePointForNormalizedPoint(point.location,
                                              Int(imageSize.width),
                                              Int(imageSize.height))
    }
    
    // Draw the points onscreen.
    draw(points: imagePoints)
}
```

#### 

## Detecting Objects in Still Images
> https://developer.apple.com/documentation/vision/detecting-objects-in-still-images

### 
#### 
- : The  image format for data from a live feed and movies.  `CVPixelBuffer` objects don’t contain orientation, so supply it in the initializer .
#### 
Create a  object with the image to be processed.
```swift
// Create a request handler.
let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                orientation: orientation,
                                                options: [:])
```

If you’re making multiple requests from the same image (for example, detecting facial features as well as faces), create and bundle all requests to pass into the image request handler. Vision runs each request and executes its completion handler on its own thread.
You can pair each request with a completion handler to run request-specific code after Vision finishes all requests. The sample draws boxes differently based on the type of request, so this code differs from request to request. Specify your completion handler when initializing each request.
```swift
lazy var rectangleDetectionRequest: VNDetectRectanglesRequest = {
    let rectDetectRequest = VNDetectRectanglesRequest(completionHandler: self.handleDetectedRectangles)
    // Customize & configure the request to detect only certain rectangles.
    rectDetectRequest.maximumObservations = 8 // Vision currently supports up to 16.
    rectDetectRequest.minimumConfidence = 0.6 // Be confident.
    rectDetectRequest.minimumAspectRatio = 0.3 // height / width
    return rectDetectRequest
}()
```

```
After you’ve created all your requests, pass them as an array to the request handler’s synchronous . Vision computations may consume resources and take time, so use a background queue to avoid blocking the main queue as it executes.
```swift
// Send the requests to the request handler.
DispatchQueue.global(qos: .userInitiated).async {
    do {
        try imageRequestHandler.perform(requests)
    } catch let error as NSError {
        print("Failed to perform image request: \(error)")
        self.presentAlert("Image Request Failed", error: error)
        return
    }
}
```

#### 
- In the  object’s completion handler, use the callback’s observation parameter to retrieve detection information.  The callback results may contain multiple observations, so loop through the observations array to process each one.
For example, the sample uses facial observations and their landmarks’ bounding boxes to locate the features and draw a rectangle around them.
```swift
// Perform drawing on the main thread.
DispatchQueue.main.async {
    guard let drawLayer = self.pathLayer,
        let results = request?.results as? [VNFaceObservation] else {
            return
    }
    self.draw(faces: results, onImageWithBounds: drawLayer.bounds)
    drawLayer.setNeedsDisplay()
}
```

```
Even when Vision calls its completion handlers on a background thread, always dispatch UI calls like the path-drawing code to the main thread. Access to UIKit, AppKit & resources must be serialized, so changes that affect the app’s immediate appearance belong on the main thread.
```swift
CATransaction.begin()
for observation in faces {
    let faceBox = boundingBox(forRegionOfInterest: observation.boundingBox, withinImageBounds: bounds)
    let faceLayer = shapeLayer(color: .yellow, frame: faceBox)
    
    // Add to pathLayer on top of image.
    pathLayer?.addSublayer(faceLayer)
}
CATransaction.commit()
```

#### 

## Detecting moving objects in a video
> https://developer.apple.com/documentation/vision/detecting-moving-objects-in-a-video

### 
#### 
#### 
Before the sample app creates a trajectory request, it gets sample buffers based on the selected source — live capture or a prerecorded video — in `CameraViewController`. After the  or  retrieves a sample buffer, it passes to the `ContentAnalysisViewController`. The sample app creates a  to perform the trajectory request with.
```swift
let visionHandler = VNImageRequestHandler(cmSampleBuffer: buffer,
                                          orientation: orientation,
                                          options: [:])
```

```
The sample app sets up a  object to define what the sample app looks for. It looks for trajectories after `1/60` second of video, and returns trajectories with a length of `6` or greater. Generally, developers use a shorter length for real-time apps, and longer lengths to observe finer and longer curves.
```swift
detectTrajectoryRequest = VNDetectTrajectoriesRequest(frameAnalysisSpacing: CMTime(value: 10, timescale: 600),
                                                      trajectoryLength: 6) { [weak self] (request: VNRequest, error: Error?) -> Void in
    
    guard let results = request.results as? [VNTrajectoryObservation] else {
        return
    }
    
    DispatchQueue.main.async {
        self?.processTrajectoryObservation(results: results)
    }
    
}
```

```
After the sample app creates the `VNDetectTrajectoriesRequest`, it configures additional options that describe the radius of the object it’s looking for. To improve the efficiency of the analysis, it also specifies the region of interest.
```swift
// Following optional bounds by checking for the moving average radius
// of the trajectories the app is looking for.
detectTrajectoryRequest.objectMinimumNormalizedRadius = 10.0 / Float(1920.0)
detectTrajectoryRequest.objectMaximumNormalizedRadius = 30.0 / Float(1920.0)

// Help manage the real-time use case to improve the precision versus delay tradeoff.
detectTrajectoryRequest.targetFrameTime = CMTimeMake(value: 1, timescale: 60)

// The region of interest where the object is moving in the normalized image space.
detectTrajectoryRequest.regionOfInterest = normalizedFrame
```

#### 
The first step in processing the results involves filtering the `VNTrajectoryObservation` based on the following conditions:
- The trajectory length increases to `8`, which indicates a throw instead of smaller movements.
- The trajectory confidence is greater than `0.9`.
- The trajectory confidence is greater than `0.9`.
When the results meet the above conditions, the sample app deems the observation a valid trajectory. The sample app confirms the trajectory and makes any necessary correction to the path. If a left-to-right moving trajectory begins too far from a fixed region, the sample extrapolates it back to the region by using the available quadratic equation coefficients.
```swift
for trajectory in results {
    // Filter the trajectory.
    if filterParabola(trajectory: trajectory) {
        // Verify and correct an incomplete path.
        trajectoryView.points = correctTrajectoryPath(trajectoryToCorrect: trajectory)
        
        // Display a transition.
        trajectoryView.performTransition(.fadeIn, duration: 0.05)
        
        // Determine the size of the moving object that the app tracks.
        print("The object's moving average radius: \(trajectory.movingAverageRadius)")
    }
}
```


## Extracting phone numbers from text in images
> https://developer.apple.com/documentation/vision/extracting-phone-numbers-from-text-in-images

### 
The  encapsulates all the necessary logic to recognize text in an image. There are two recognition levels you can choose from, to prioritize accuracy or speed of recognition. Additional configuration properties enable you to specify the languages to recognize, use language correction during recognition, specify the area of the live video to scan, and more. With all of these capabilities, there are tradeoffs between convenience, accuracy, and performance.
First the app creates a request to recognize text:
```swift
// Set up the Vision request before letting ViewController set up the camera
// so it exists when the first buffer is received.
request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
```

```
Next, in the delegate method that Vision calls when it writes a sample buffer, the app configures the request to use fast recognition, disable language correction, and set a small rectangular region of interest. Then, the app performs the request:
```swift
// Configure for running in real time.
request.recognitionLevel = .fast
// Language correction doesn't help in recognizing phone numbers and also
// slows recognition.
request.usesLanguageCorrection = false
// Only run on the region of interest for maximum speed.
request.regionOfInterest = regionOfInterest

let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: textOrientation, options: [:])
do {
    try requestHandler.perform([request])
} catch {
    print(error)
}
```

#### 

## Generating high-quality thumbnails from videos
> https://developer.apple.com/documentation/vision/generating-thumbnails-from-videos

### 
#### 
The `Frame` structure contains the information about a specific frame in the video that the sample uses to determine the best frame to use as a thumbnail. It accepts a `CMTime` to represent the timestamp of the frame, a `Float` value for the overall score of the frame, and a  to enable comparison to other frames:
```swift
struct Frame {
    /// The timestamp of the frame.
    let time: CMTime

    /// The score of the frame.
    let score: Float

    /// The feature-print observation of the frame.
    let observation: FeaturePrintObservation
}
```

```
To present the results of each frame, the sample creates a `Thumbnail` class that conforms to the  protocol. This ensures that the class has a unique identity for  to display the results. This class accepts a `CGImage` to store the image of the frame, and a `Frame` to establish a connection between the frame and the thumbnail:
```swift
class Thumbnail: Identifiable {
    /// The image that captures from the video frame.
    let image: CGImage

    /// The frame that the thumbnail represents.
    let frame: Frame

    // ...
}
```

#### 
The sample processes videos frame by frame using the . The sample first initializes the video processor with the video URL, then create the instances of the requests the sample uses to process the video:
```swift
func processVideo(for videoURL: URL, progression: Binding<Float>) async -> [Thumbnail] {
    /// The instance of the `VideoProcessor` with the local path to the video file.
    let videoProcessor = VideoProcessor(videoURL)

    /// The request to calculate the aesthetics score for each frame.
    let aestheticsScoresRequest = CalculateImageAestheticsScoresRequest()

    /// The request to generate feature prints from an image.
    let imageFeaturePrintRequest = GenerateImageFeaturePrintRequest()

    /// The array to store information for the frames with the highest scores.
    var topFrames: [Frame] = []

    // ...
}
```

The  calculates the aesthetic scores for each frame. To ensure that the thumbnail results represent different scenes rather than variations of the same frame,  computes the similarity between the frames.
The sample calculates a time interval for the video processor to process approximately 100 frames, adds the `aestheticsScoresRequest` and `imageFeaturePrintRequest` to the video processor, then starts the video-analysis process. To store the timestamp and the results from the video-processor stream, the sample creates two dictionaries: `aestheticsResults` and `featurePrintResults`:
```swift
do {
    /// The time interval for the video-processing cadence.
    let interval = CMTime(
        seconds: totalDuration / framesToEval,
        preferredTimescale: timeScale
    )

    /// The video-processing cadence to process only 100 frames.
    let cadence = VideoProcessor.Cadence.timeInterval(interval)

    /// The stream that adds the aesthetics scores request to the video processor.
    let aestheticsScoreStream = try await videoProcessor.addRequest(aestheticsScoresRequest, cadence: cadence)

    /// The stream that adds the image feature-print request to the video processor.
    let featurePrintStream = try await videoProcessor.addRequest(imageFeaturePrintRequest, cadence: cadence)
    
    // Start to analyze the video.
    videoProcessor.startAnalysis()

    /// The dictionary to store the timestamp and the aesthetics score.
    var aestheticsResults: [CMTime: Float] = [:]

    /// The dictionary to store the timestamp and the feature-print observation.
    var featurePrintResults: [CMTime: FeaturePrintObservation] = [:]

    // ...

    // Solve for the top-rated frames.
    topFrames = await calculateTopFrames(aestheticsResults: aestheticsResults, featurePrintResults: featurePrintResults)
} 
```

#### 
The function uses `aestheticsResults` and `featurePrintResults` to identify three frames that have the highest aesthetic scores and are different from each other:
```swift
for (time, score) in aestheticsResults {
    /// The `FeaturePrintObservation` for the timestamp.
    guard let featurePrint = featurePrintResults[time] else { continue }

    /// The new frame at that timestamp.
    let newFrame = Frame(time: time, score: score, observation: featurePrint)

    /// The variable that tracks whether to add the image based on image similarity.
    var isSimilar = false

    // Iterate through the current top-rated frames to check whether any of them
    // are similar to the new frame and find the insertion index.
    for (index, frame) in topFrames.enumerated() {
        if let distance = try? featurePrint.distance(to: frame.observation), distance < similarityThreshold {
            // Replace the frame if the new frame has a higher score.
            if newFrame.score > frame.score {
                topFrames[index] = newFrame
            }
            isSimilar = true
            break
        }

        // ...
    }
}
```


## Identifying 3D human body poses in images
> https://developer.apple.com/documentation/vision/identifying-3d-human-body-poses-in-images

### 
#### 
The observation contains a collection of 17  objects that contain the 3D position of a joint you specify, and the parent joint it connects to. The framework doesn’t return a partial list of joints, so you get all 17 joints or none.
The request doesn’t require images with depth data to run. However, providing depth data improves detection accuracy.
```swift
import Vision

// Get an image from the project bundle. 
guard let filePath = Bundle.main.path(forResource: "bodypose", ofType: "heic") else { 
    return 
} 
let fileUrl = URL(fileURLWithPath: filePath) 

// Create an object to process the request.  
let requestHandler = VNImageRequestHandler(url: fileUrl) 

// Create a request to detect a body pose in 3D space. 
let request = VNDetectHumanBodyPose3DRequest() 

do {    
    // Perform the body pose request.    
    try requestHandler.perform([request])    

    // Get the observation.    
    if let observation = request.results?.first {        
        // Handle the observation.    
    }
} catch {
    print("Unable to perform the request: \(error).") 
}
```

#### 
A  provides body pose information in 3D space, in meters. The framework normalizes 2D points — from other framework requests — to a lower-left origin. Points that a 3D body pose request returns are relative to the scene in the real world, with an origin at the root joint, located between the  and .
To get a list of the available joint names, call . Joints are also grouped by their location on the body. For example, the left arm group provides the left shoulder, elbow and wrist joints. To get a list of the group names, call .
```swift
// Get a recognized joint by using a joint name. 
let leftShoulder = try observation.recognizedPoint(.leftShoulder) 
let leftElbow = try observation.recognizedPoint(.leftElbow) 
let leftWrist = try observation.recognizedPoint(.leftWrist) 

// Get a collection of joints by using a joint group name. 
let leftArm = try observation.recognizedPoints(.leftArm)
```

#### 
Use  to project a 3D joint coordinate back to a 2D input image for the body joint you specify. For instance, if you want to align the 3D body pose with the 2D input image, use  to get the root joint position in the input image.
A  is useful if your app is only working with one area of the body, and simplifies determining the angle between a child and parent joint.
```swift
import simd 

var angleVector: simd_float3 = simd_float3() 

// Get the position relative to the parent shoulder joint. 
let childPosition = leftElbow.localPosition 
let translationChild = simd_make_float3(childPosition.columns.3[0], 
                                        childPosition.columns.3[1], 
                                        childPosition.columns.3[2]) 

// The rotation around the x-axis. 
let pitch = (Float.pi / 2) 

// The rotation around the y-axis. 
let yaw = acos(translationChild.z / simd_length(translationChild)) 

// The rotation around the z-axis. 
let roll = atan2((translationChild.y), (translationChild.x)) 

// The angle between the elbow and shoulder joint. 
angleVector = simd_float3(pitch, yaw, roll)
```

#### 

## Identifying Trajectories in Video
> https://developer.apple.com/documentation/vision/identifying-trajectories-in-video

### 
#### 
- A completion handler to process the results.
The following example shows how to create and perform a request in an app thatʼs capturing live video from the camera. Note that  requires using  objects that contain timestamps so it can correctly calculate the trajectory observationʼs time range.
```swift
// Lazily create a single instance of VNDetectTrajectoriesRequest.
private lazy var request: VNDetectTrajectoriesRequest = {
    return VNDetectTrajectoriesRequest(frameAnalysisSpacing: .zero,
                                       trajectoryLength: 15,
                                       completionHandler: completionHandler)
}()

// AVCaptureVideoDataOutputSampleBufferDelegate callback.
func captureOutput(_ output: AVCaptureOutput,
                   didOutput sampleBuffer: CMSampleBuffer,
                   from connection: AVCaptureConnection) {
    do {
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer)
        try requestHandler.perform([request])
    } catch {
        // Handle the error.
    }
}

func completionHandler(request: VNRequest, error: Error?) {
    // Process the results.
}

```

```
You can improve the performance and accuracy of the request by applying filtering criteria to it. If you know the approximate size of the objects you want to follow, you can set a minimum and maximum object size. You specify an object’s size as its normalized pixel diameters. Set the minimum size to filter out small, spurious movements like a bird flying through the scene. Likewise, set the maximum size to filter out larger objects. Like with all Vision requests, you can also set a region of interest (ROI) if you want to detect only those trajectories occurring in a particular region of the frame.
```swift
// Set the normalized (0.0 to 1.0) minimum and maximum object sizes.
request.minimumObjectSize = smallDiameter / videoWidth
request.maximumObjectSize = largeDiameter / videoWidth

// Set the ROI to the left half of the image.
request.regionOfInterest = CGRect(x: 0, y: 0, width: 0.5, height: 1.0)
```

#### 
After the handler performs the request, it calls the request’s completion closure, passing it the request and any errors that occurred. Retrieve the observations by querying the request object for its results, which it returns as an array of  objects.
```swift
func requestHandler(request: VNRequest, error: Error?) {
    guard let observations =
            request.results as? [VNTrajectoryObservation] else { return }
    
    // Process the observations.
    
}
```

#### 

## Locating and displaying recognized text
> https://developer.apple.com/documentation/vision/locating-and-displaying-recognized-text

### 
#### 
#### 
The sample app performs the request on a photo from a physical device. To enable use of the camera, the sample uses  to create a custom camera interface. Tapping the Take a Photo button on the initial view presents the camera and calls the `setup` method. This is where the camera work begins in the sample.
```swift
CameraPreview(camera: $camera)
    .task {
        /// If the app has access to the camera, set up and display a live capture preview.
        if await camera.checkCameraAuthorization() {
            didSetup = camera.setup()
        /// If the app doesn't have access, dismiss the camera and display an error.
        } else {
            showAccessError = true
            showCamera = false
        }
        
        if !didSetup {
            print("Camera setup failed.")
            showCamera = false
        }
    }
```

#### 
The two text-recognition paths are: fast and accurate. The fast path is similar to a traditional OCR approach, and the accurate path uses a neural network that’s similar to how humans read text. By default, the request uses the accurate path, so the system sets the  property to `accurate`.
Depending on the recognition level and language correction settings, the available recognition languages change. To dynamically generate a list of available languages to choose from, the app uses the  method. The app sets the recognition languages with an array of  objects, and prioritizes the first element.
```swift
func updateRequestSettings() {
    /// A Boolean value that indicates whether the system applies the language-correction model.
    imageOCR.request.usesLanguageCorrection = languageCorrection
    
    imageOCR.request.recognitionLanguages = [selectedLanguage]
    
    switch selectedRecognitionLevel {
    case "Fast":
        imageOCR.request.recognitionLevel = .fast
    default:
        imageOCR.request.recognitionLevel = .accurate
    }
}
```

#### 
After capturing a photo, the app creates an instance of the custom OCR class. This class provides an array to hold the results, the , and the `performOCR` method to handle the text recognition. The `performOCR` method performs the request on the image, which returns an array of  objects. The method then adds each observation to the observations array.
```swift
@Observable
class OCR {
    /// The array of `RecognizedTextObservation` objects to hold the request's results.
    var observations = [RecognizedTextObservation]()
    
    /// The Vision request.
    var request = RecognizeTextRequest()
    
    func performOCR(imageData: Data) async throws {
        /// Clear the `observations` array for photo recapture.
        observations.removeAll()
        
        /// Perform the request on the image data and return the results.
        let results = try await request.perform(on: imageData)
        
        /// Add each observation to the `observations` array.
        for observation in results {
            observations.append(observation)
        }
    }
}
```

```
Initially, the app performs the request once when it captures an image. If the app detects any changes to the request settings (for example, the recognition level), it performs the request again. The Vision framework’s perform method is asynchronous, so the system wraps the method in a  block.
```swift
.onChange(of: settingChanges, initial: true) {
    updateRequestSettings()
    Task {
        try await imageOCR.performOCR(imageData: imageData)
    }
}
```

#### 
This sample provides a custom implementation to display red bounding boxes where an observation occurs. An observation contains the location and the dimensions of the  in the form of a . To create a bounding box, the app first converts the `NormalizedRect` to a , and then returns a  to draw the rectangle.
```swift
struct Box: Shape {
    private let normalizedRect: NormalizedRect
    
    init(observation: any BoundingBoxProviding) {
        normalizedRect = observation.boundingBox
    }
    
    func path(in rect: CGRect) -> Path {
        let rect = normalizedRect.toImageCoordinates(rect.size, origin: .upperLeft)
        return Path(rect)
    }
}
```

```
To display the bounding boxes, the app uses the  method on the image, and creates a bounding box for each of the observations.
```swift
.overlay {
    ForEach(imageOCR.observations, id: \.uuid) { observation in
        Box(observation: observation)
            .stroke(.red, lineWidth: 1)
    }
}
```

#### 
Finally, the app displays the extracted text from the image by iterating through the observations array. If the request doesn’t recognize any text in the image, the app displays the “No text recognized” string.
```swift
/// Display the text from the captured image.
ForEach(imageOCR.observations, id: \.self) { observation in
    Text(observation.topCandidates(1).first?.string ?? "No text recognized")
        .textSelection(.enabled)
}
.foregroundStyle(.gray)
```


## Recognizing Objects in Live Capture
> https://developer.apple.com/documentation/vision/recognizing-objects-in-live-capture

### 
#### 
Although implementing AV live capture is similar from one capture app to another, configuring the camera to work best with Vision algorithms involves some subtle differences.
  This sample app feeds camera output from AVFoundation into the main view controller.  Start by configuring an  :
```swift
private let session = AVCaptureSession()
```

 It’s important to choose the right resolution for your app.  Don’t simply select the highest resolution available if your app doesn’t require it.  It’s better to select a lower resolution so Vision can process results more efficiently.  Check the model parameters in Xcode to find out if your app requires a resolution smaller than 640 x 480 pixels.
Set the camera resolution to the nearest resolution that is greater than or equal to the resolution of images used in the model:
```swift
let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
do {
    deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
} catch {
    print("Could not create video device input: \(error)")
    return
}

session.beginConfiguration()
session.sessionPreset = .vga640x480 // Model image size is smaller.
```

Vision will perform the remaining scaling.
```swift
guard session.canAddInput(deviceInput) else {
    print("Could not add video device input to the session")
    session.commitConfiguration()
    return
}
session.addInput(deviceInput)
```

```
```swift
if session.canAddOutput(videoDataOutput) {
    session.addOutput(videoDataOutput)
    // Add a video data output
    videoDataOutput.alwaysDiscardsLateVideoFrames = true
    videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
    videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
} else {
    print("Could not add video data output to the session")
    session.commitConfiguration()
    return
}
```

```
  The camera will stop working if the buffer queue overflows available memory.  To simplify buffer management, in the capture output, Vision blocks the call for as long as the previous request requires.  As a result, AVFoundation may drop frames, if necessary.  The sample app keeps a queue size of 1; if a Vision request is already queued up for processing when another becomes available, skip it instead of holding on to extras.
```swift
let captureConnection = videoDataOutput.connection(with: .video)
// Always process the frames
captureConnection?.isEnabled = true
do {
    try  videoDevice!.lockForConfiguration()
    let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
    bufferSize.width = CGFloat(dimensions.width)
    bufferSize.height = CGFloat(dimensions.height)
    videoDevice!.unlockForConfiguration()
} catch {
    print(error)
}
```

```
```swift
session.commitConfiguration()
```

```
Set up a preview layer on your view controller, so the camera can feed its frames into your app’s UI:
```swift
previewLayer = AVCaptureVideoPreviewLayer(session: session)
previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
rootLayer = previewView.layer
previewLayer.frame = rootLayer.bounds
rootLayer.addSublayer(previewLayer)
```

#### 
You must input the camera’s orientation properly using the device orientation.  Vision algorithms aren’t orientation-agnostic, so when you make a request, use an orientation that’s relative to that of the capture device.
```swift
let curDeviceOrientation = UIDevice.current.orientation
let exifOrientation: CGImagePropertyOrientation

switch curDeviceOrientation {
case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
    exifOrientation = .left
case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
    exifOrientation = .upMirrored
case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
    exifOrientation = .down
case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
    exifOrientation = .up
default:
    exifOrientation = .up
}
```

#### 
The Core ML model you include in your app determines which labels are used in Vision’s object identifiers.  The model in this sample app was trained in Turi Create 4.3.2 using Darknet YOLO (You Only Look Once). See  to learn how to generate your own models using Turi Create. Vision analyzes these models and returns observations as  objects.
Load the model using a :
```swift
let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
```

```
Create a  with that model:
```swift
let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
    DispatchQueue.main.async(execute: {
        // perform all the UI updates on the main queue
        if let results = request.results {
            self.drawVisionRequestResults(results)
        }
    })
})
```

Access results in the request’s completion handler, or through the `requests` property.
#### 
The `results` property is an array of observations, each with a set of labels and bounding boxes. Parse those observations by iterating through the array, as follows:
```swift
for observation in results where observation is VNRecognizedObjectObservation {
    guard let objectObservation = observation as? VNRecognizedObjectObservation else {
        continue
    }
    // Select only the label with the highest confidence.
    let topLabelObservation = objectObservation.labels[0]
    let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
    
    let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
    
    let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                    identifier: topLabelObservation.identifier,
                                                    confidence: topLabelObservation.confidence)
    shapeLayer.addSublayer(textLayer)
    detectionOverlay.addSublayer(shapeLayer)
}
```


## Recognizing Text in Images
> https://developer.apple.com/documentation/vision/recognizing-text-in-images

### 
#### 
Vision provides its text-recognition capabilities through , an image-based request type that finds and extracts text in images. The following example shows how to use  to perform a  for recognizing text in the specified .
```swift
// Get the CGImage on which to perform requests.
guard let cgImage = UIImage(named: "snapshot")?.cgImage else { return }

// Create a new image-request handler.
let requestHandler = VNImageRequestHandler(cgImage: cgImage)

// Create a new request to recognize text.
let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

do {
    // Perform the text-recognition request.
    try requestHandler.perform([request])
} catch {
    print("Unable to perform the requests: \(error).")
}
```

#### 
After the request handler processes the request, it calls the request’s completion closure, passing it the request and any errors that occurred. Retrieve the observations by querying the request object for its , which it returns as an array of  objects. Each observation provides the recognized text string, along with a confidence score that indicates the confidence in the accuracy of the recognition.
```swift
func recognizeTextHandler(request: VNRequest, error: Error?) {
    guard let observations =
            request.results as? [VNRecognizedTextObservation] else {
        return
    }
    let recognizedStrings = observations.compactMap { observation in
        // Return the string of the top VNRecognizedText instance.
        return observation.topCandidates(1).first?.string
    }
    
    // Process the recognized strings.
    processResults(recognizedStrings)
}
```

```
If you’d like to render the bounding rectangles around recognized text in your user interface, you can also retrieve that information from the observation. The rectangles it provides are in normalized coordinates. To render them correctly in your user interface, convert  instances from normalized coordinates to image coordinates by using the  function as shown below.
```swift
let boundingRects: [CGRect] = observations.compactMap { observation in

    // Find the top observation.
    guard let candidate = observation.topCandidates(1).first else { return .zero }
    
    // Find the bounding-box observation for the string range.
    let stringRange = candidate.string.startIndex..<candidate.string.endIndex
    let boxObservation = try? candidate.boundingBox(for: stringRange)
    
    // Get the normalized CGRect value.
    let boundingBox = boxObservation?.boundingBox ?? .zero
    
    // Convert the rectangle from normalized coordinates to image coordinates.
    return VNImageRectForNormalizedRect(boundingBox,
                                        Int(image.size.width),
                                        Int(image.size.height))
}
```

#### 

## Recognizing tables within a document
> https://developer.apple.com/documentation/vision/recognize-tables-within-a-document

### 
### 
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


## Segmenting and colorizing individuals from a surrounding scene
> https://developer.apple.com/documentation/vision/segmenting-and-colorizing-individuals-from-a-surrounding-scene

### 
#### 
#### 
The sample first determines the number of faces in the scene given the  using .
```swift
// Returns the number of people in the image.
private func countFaces(image: CIImage) async -> Int {
    // Approximate the number of people in the image.
    let request = VNDetectFaceRectanglesRequest()
    let requestHandler = VNImageRequestHandler(ciImage: image)
    do {
        try requestHandler.perform([request])
        if let results = request.results {
            return results.count
        }
    } catch {
        print("Unable to perform face detection: \(error).")
    }
    return 0
}
```

- If there are four or fewer faces, the sample uses .
- If more than four faces are detected, the sample uses , and produces a mask for all the individuals in the image.
```swift
let numFaces = await countFaces(image: image)
if numFaces <= 4 {
    request = VNGeneratePersonInstanceMaskRequest()
} else {
    request = VNGeneratePersonSegmentationRequest()
}
```

#### 
The sample sets up the image analysis requests for the image with  and processes the request for the image. The  method schedules the request. When the request completes, the segments are returned in `request.results`.
```swift
// Set up and run the request.
let requestHandler = VNImageRequestHandler(ciImage: image)
self.baseImage = image
do {
    try requestHandler.perform([request])
    
    // Get the segmentation results from the request.
    switch request.results?.first {
    case let buffer as VNPixelBufferObservation:
        segmentationResults = PersonSegmentationResults(results: buffer)
        selectedSegments = [1]
    case let instanceMask as VNInstanceMaskObservation:
        segmentationResults = InstanceMaskResults(results: instanceMask, requestHandler: requestHandler)
        selectedSegments = instanceMask.allInstances
    default:
        break
    }
```

If there are more than four faces, the sample produces a matte image for the individual segments in the image, the resulting mask is an instance of . If there are four of fewer faces, the resulting mask is an instance of .
The sample then updates the image on the main thread with the colorized mask.
```swift
let segmentedImage = await segmentationResults?.generateSegmentedImage(baseImage: image, selectedSegments: selectedSegments)

Task { @MainActor in
    // Update the UI.
    if let results = segmentationResults {
        self.segmentationCount = results.numSegments
    }
    self.segmentedImage = segmentedImage ?? UIImage(cgImage: CIContext().createCGImage(image, from: image.extent)!)
    self.showWarning = segmentationResults is PersonSegmentationResults
}
```

#### 
The sample’s `InstanceMaskResults` class generates segmented images for up to four people in a scene. It conforms to the `SegmentationResults` protocol. The sample initializes the class with the  results and a .
The `generateSegmentedImage` method asynchronously generates an image with the selected segments highlighted. It scales the masks for each segment and blends them with the base image using specified colors.
```swift
for index in selectedSegments {
    do {
        let maskPixelBuffer = try instanceMasks.generateScaledMaskForImage(forInstances: [index], from: requestHandler)
        let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
        image = blendImageWithMask(image: image, mask: maskImage, color: SegmentationModel.colors[index])
    } catch {
        print("Error generating mask: \(error).")
    }
}
```

#### 
The sample’s `PersonSegmentationResults` class generates a segmented image for every person in a scene using  from . It conforms to the `SegmentationResults` protocol. The sample’s `generateSegmentedImage` method generates the image with a mask for the foreground or the background.
If there are more than four people in the image and the person using this sample selects the mask in the foreground, `blendImageWithMask(image, mask)` applies a masks to all the detected individuals with a specific color.
```swift
if selectedSegments.contains(1) {
    // Foreground is selected.
    segmentedImage = blendImageWithMask(image: baseImage, mask: maskImage, color: SegmentationModel.colors[1])
}
```

If the person using the sample selects the background mask in the image, the sample masks the background of the image with a specific color, but leaves the people in the foreground of the image intact. This allows for selectively coloring the background of the image based on the segmentation mask.
```swift
if selectedSegments.contains(0) {
    // Background is selected.
    let blendFilter = CIFilter.blendWithMask()
    blendFilter.inputImage = baseImage
    blendFilter.backgroundImage = CIImage(color: CIColor(color: SegmentationModel.colors[0])).cropped(to: baseImage.extent)
    blendFilter.maskImage = maskImage
    segmentedImage = blendFilter.outputImage!
}
```


## Selecting a selfie based on capture quality
> https://developer.apple.com/documentation/vision/selecting-a-selfie-based-on-capture-quality

### 
First the app creates and performs a `VNDetectFaceCaptureQualityRequest` and obtains face observations from the results:
Face Capture Quality is a holistic measure that considers scene lighting, blur, occlusion, expression, pose, focus, and more. It provides a score you can use to rank multiple captures of the same person. The pre-trained underlying models score a capture lower if, for example, the image contains low light or bad focus, or if the person has a negative expression. These scores are floating-point numbers normalized between `0.0` and `1.0`.
First the app creates and performs a `VNDetectFaceCaptureQualityRequest` and obtains face observations from the results:
```swift
let faceDetectionRequest = VNDetectFaceCaptureQualityRequest()
do {
    try handler.perform([faceDetectionRequest])
    guard let faceObservations = faceDetectionRequest.results as? [VNFaceObservation] else {
        return
    }
    displayFaceObservations(faceObservations)
    if isCapturingFaces {
        saveFaceObservations(faceObservations, in: pixelBuffer)
    }
} catch {
    print("Vision error: \(error.localizedDescription)")
}
```

```
Then the app passes the face observations to `saveFaceObservations(_:in:)`, where it retrieves the `faceCaptureQuality` score for each capture. When the user presses down on the capture button, the app saves each capture’s image data along with its quality score:
```swift
let faceDetectionRequest = VNDetectFaceCaptureQualityRequest()
do {
    try handler.perform([faceDetectionRequest])
    guard let faceObservations = faceDetectionRequest.results as? [VNFaceObservation] else {
        return
    }
    displayFaceObservations(faceObservations)
    if isCapturingFaces {
        saveFaceObservations(faceObservations, in: pixelBuffer)
    }
} catch {
    print("Vision error: \(error.localizedDescription)")
}
```

```
Next, the app sorts the captures based on quality score:
```swift
// Sort faces in descending quality-score order.
savedFaces.sort { $0.qualityScore < $1.qualityScore }
```

```
Finally, the app displays the saved faces with their quality scores:
```swift
let savedFace = savedFaces[indexPath.item]
let faceImage = UIImage(contentsOfFile: savedFace.url.path)
cell.imageView.image = faceImage
cell.label.text = "\(savedFace.qualityScore)"
```

#### 

## Tracking Multiple Objects or Rectangles in Video
> https://developer.apple.com/documentation/vision/tracking-multiple-objects-or-rectangles-in-video

### 
#### 
#### 
Otherwise, to track objects, select Objects.  Then nominate objects to track by touching them in the preview and dragging boxes around them.  You can select multiple objects; the app identifies them by their , using differently colored rectangles.
The  class requires a detected object observation to initialize.  The sample provides this observation by running , or by creating one from the bounding box you drew in the preview.  It tracks multiple objects by iterating through each observation and creating a  from its bounding box.
```swift
var inputObservations = [UUID: VNDetectedObjectObservation]()
var trackedObjects = [UUID: TrackedPolyRect]()
switch type {
case .object:
    for rect in self.objectsToTrack {
        let inputObservation = VNDetectedObjectObservation(boundingBox: rect.boundingBox)
        inputObservations[inputObservation.uuid] = inputObservation
        trackedObjects[inputObservation.uuid] = rect
    }
case .rectangle:
    for rectangleObservation in initialRectObservations {
        inputObservations[rectangleObservation.uuid] = rectangleObservation
        let rectColor = TrackedObjectsPalette.color(atIndex: trackedObjects.count)
        trackedObjects[rectangleObservation.uuid] = TrackedPolyRect(observation: rectangleObservation, color: rectColor)
    }
}
```

#### 
The Vision framework handles tracking requests through a .  Whereas the  handles object detection requests on a still image, the  handles tracking requests.
Create a tracking request for each rectangle or object you’d like to track.  Seed each tracking request with the observation created during nomination.
```swift
let request: VNTrackingRequest!
switch type {
case .object:
    request = VNTrackObjectRequest(detectedObjectObservation: inputObservation.value)
case .rectangle:
    guard let rectObservation = inputObservation.value as? VNRectangleObservation else {
        continue
    }
    request = VNTrackRectangleRequest(rectangleObservation: rectObservation)
}
request.trackingLevel = trackingLevel

trackingRequests.append(request)
```

```
For each such request, call the sequence request handler’s  method, making sure to pass in the video reader’s orientation to ensure upright tracking. This method runs synchronously; use a background queue, such as `workQueue` in the sample code, so that the main queue isn’t blocked while your requests execute.
```swift
try requestHandler.perform(trackingRequests, on: frame, orientation: videoReader.orientation)
```

#### 
Access tracking results through the request’s `results` property or its completion handler.  A single tracking request represents a single tracked object in a one-to-one relationship.  If a tracking request succeeds, its  property contains  objects describing the tracked object’s new location in the frame.
```swift
guard let results = processedRequest.results else {
    continue
}
guard let observation = results.first as? VNDetectedObjectObservation else {
    continue
}
// Assume threshold = 0.5f
let rectStyle: TrackedPolyRectStyle = observation.confidence > 0.5 ? .solid : .dashed
let knownRect = trackedObjects[observation.uuid]!
switch type {
case .object:
    rects.append(TrackedPolyRect(observation: observation, color: knownRect.color, style: rectStyle))
case .rectangle:
    guard let rectObservation = observation as? VNRectangleObservation else {
        break
    }
    rects.append(TrackedPolyRect(observation: rectObservation, color: knownRect.color, style: rectStyle))
}
```

```
Use the observation’s  to determine its location, so you can update your app or UI with the tracked object’s new location.  Also use it to seed the next round of tracking.
```swift
inputObservations[observation.uuid] = observation
```


## Tracking the User’s Face in Real Time
> https://developer.apple.com/documentation/vision/tracking-the-user-s-face-in-real-time

### 
#### 
#### 
You can provide a completion handler for a Vision request handler to execute when it finishes. The completion handler indicates whether the request succeeded or resulted in an error. If the request succeeded, its  property contains data specific to the type of request that you can use to identify the object’s location and bounding box.
For face rectangle requests, the  provided via callback includes a bounding box for each detected face. The sample uses this bounding box to draw paths around each of the detected face landmarks on top of the preview image.
```swift
let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
    
    if error != nil {
        print("FaceDetection error: \(String(describing: error)).")
    }
    
    guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
          let results = faceDetectionRequest.results else {
            return
    }
    DispatchQueue.main.async {
        // Add the observations to the tracking list
        for observation in results {
            let faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
            requests.append(faceTrackingRequest)
        }
        self.trackingRequests = requests
    }
})
```

#### 
Perform any image preprocessing in the delegate method . In this delegate method, create a pixel buffer to hold image contents, determine the device’s orientation, and check whether you have a face to track.
Before the Vision framework can track an object, it must first know which object to track. Determine which face to track by creating a   and passing it a still image frame. In the case of video, submit individual frames to the request handler as they arrive in the delegate method .
```swift
let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                orientation: exifOrientation,
                                                options: requestHandlerOptions)

do {
    guard let detectRequests = self.detectionRequests else {
        return
    }
    try imageRequestHandler.perform(detectRequests)
} catch let error as NSError {
    NSLog("Failed to perform FaceRectangleRequest: %@", error)
}
```

#### 
Once you have an observation from the image request handler’s face detection, input it to the sequence request handler.
```swift
try self.sequenceRequestHandler.perform(requests,
                                         on: pixelBuffer,
                                         orientation: exifOrientation)
```

```
If the detector hasn’t found a face, create an image request handler to detect a face. Once that detection succeeds, and you have a face observation, track it by creating a .
```swift
// Setup the next round of tracking.
var newTrackingRequests = [VNTrackObjectRequest]()
for trackingRequest in requests {
    
    guard let results = trackingRequest.results else {
        return
    }
    
    guard let observation = results[0] as? VNDetectedObjectObservation else {
        return
    }
    
    if !trackingRequest.isLastFrame {
        if observation.confidence > 0.3 {
            trackingRequest.inputObservation = observation
        } else {
            trackingRequest.isLastFrame = true
        }
        newTrackingRequests.append(trackingRequest)
    }
}
```


## Training a Create ML Model to Classify Flowers
> https://developer.apple.com/documentation/vision/training-a-create-ml-model-to-classify-flowers

### 
#### 
#### 
1. In Xcode, open `ImageClassifierPlayground.playground` and display the Assistant Editor.
#### 
#### 
Registration takes and aligns two images to determine the relative difference. Vision’s registration operation uses an inexpensive, fast algorithm that tells the app if the subject is still and stable. Theoretically, the app could make a classification request on every frame buffer, but classification is a computationally expensive operation—so attempting to classify every frame could result in delays and poor performance with the UI. Classify the scene in a frame only if the registration algorithm determines that the scene and camera are still, indicating the user’s intent to classify an object.
The FlowerShop app uses  with  objects to compare consecutive frames, keeping a history of 15 frames. This amount of history amounts to half a second of capture at 30 frames per second and carries no special significance beyond empirical tuning. It takes the result of a request as `alignmentObservation.alignmentTransform` to determine if the scene is stable enough to perform classification. Check for scene stability by performing a request on the sequence request handler:
```swift
let registrationRequest = VNTranslationalImageRegistrationRequest(targetedCVPixelBuffer: pixelBuffer)
```

```
This algorithm deems a scene to be stable if the Manhattan distance between frames is less than 20:
```swift
fileprivate func sceneStabilityAchieved() -> Bool {
    // Determine if we have enough evidence of stability.
    if transpositionHistoryPoints.count == maximumHistoryLength {
        // Calculate the moving average.
        var movingAverage: CGPoint = CGPoint.zero
        for currentPoint in transpositionHistoryPoints {
            movingAverage.x += currentPoint.x
            movingAverage.y += currentPoint.y
        }
        let distance = abs(movingAverage.x) + abs(movingAverage.y)
        if distance < 20 {
            return true
        }
    }
    return false
}
```

```
After registration has determined that the scene is longer varying, the app sends the stable frame to Vision for Core ML classification:
```swift
if self.sceneStabilityAchieved() {
    showDetectionOverlay(true)
    if currentlyAnalyzedPixelBuffer == nil {
        // Retain the image buffer for Vision processing.
        currentlyAnalyzedPixelBuffer = pixelBuffer
        analyzeCurrentImage()
    }
} else {
    showDetectionOverlay(false)
}
```

#### 
The sample code sets up both a classification request and a barcode detection request. FlowerShop uses barcode identification to label an object—fertilizer—for which it has no training data. For example, the curator of a museum exhibit or owner of a flower shop can place the barcode beside or in place of an actual item, so that scanning the barcode classifies the item.
By using it as a proxy for the actual item, the app can still provide a confident classification even if the user doesn’t scan the actual item. This kind of proxy works particularly well for items that Create ML may have trouble training through images, such as fertilizer, gasoline, transparent gases, and clear liquids. Set up this kind of barcode detection using a  object:
```swift
let barcodeDetection = VNDetectBarcodesRequest(completionHandler: { (request, error) in
    if let results = request.results as? [VNBarcodeObservation] {
        if let mainBarcode = results.first {
            if let payloadString = mainBarcode.payloadStringValue {
                self.showProductInfo(payloadString)
            }
        }
    }
})
self.analysisRequests = ([barcodeDetection])

// Setup a classification request.
guard let modelURL = Bundle.main.url(forResource: "FlowerShop", withExtension: "mlmodelc") else {
    return NSError(domain: "VisionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "The model file is missing."])
}
guard let objectRecognition = createClassificationRequest(modelURL: modelURL) else {
    return NSError(domain: "VisionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "The classification request failed."])
}
self.analysisRequests.append(objectRecognition)
```

```
The sample appends the normal model-based classification request to the same array. You can create both requests at once, but the sample code staggers the classification request to guard against failure to load the Core ML model. The classification request loads the Core ML classifier into a  object:
```swift
let objectClassifier = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
let classificationRequest = VNCoreMLRequest(model: objectClassifier, completionHandler: { (request, error) in
```

```
Defining the requests and completion handlers concludes the setup stage; the second stage performs identification in real time. The sample sends the stable frame to the classifier and tells Vision to perform classification by calling :
```swift
private func analyzeCurrentImage() {
    // Most computer vision tasks are not rotation-agnostic, so it is important to pass in the orientation of the image with respect to device.
    let orientation = exifOrientationFromDeviceOrientation()
    
    let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentlyAnalyzedPixelBuffer!, orientation: orientation)
    visionQueue.async {
        do {
            // Release the pixel buffer when done, allowing the next buffer to be processed.
            defer { self.currentlyAnalyzedPixelBuffer = nil }
            try requestHandler.perform(self.analysisRequests)
        } catch {
            print("Error: Vision request failed with error \"\(error)\"")
        }
    }
}
```

```
Perform tasks asynchronously on a background queue, so the camera and user interface can keep running unhindered. Don’t continuously queue up every buffer that the camera provides; instead, drop buffers to keep the pipeline moving. The app works with a queue of one buffer, skipping subsequent frames so long as it is still processing that buffer. When one request finishes, it queues the next buffer and submits a classification request.
```swift
private let visionQueue = DispatchQueue(label: "com.example.apple-samplecode.FlowerShop.serialVisionQueue")
```

#### 
Check the results in the request’s completion handler. When you create and pass in a request, you handle results and errors and show the classification results in your app’s UI.
```swift
if let results = request.results as? [VNClassificationObservation] {
    print("\(results.first!.identifier) : \(results.first!.confidence)")
    if results.first!.confidence > 0.9 {
        self.showProductInfo(results.first!.identifier)
    }
}
```

#### 
After processing your buffers, be sure to release them to prevent them from queuing up. Because the input is a capture device that is constantly streaming frames, your app will run out of memory quickly if you don’t discard extra frames. The sample app limits the number of queued frame buffers to only one, which prevents overflow from happening and clears the buffer by setting it to `nil`:
```swift
self.currentlyAnalyzedPixelBuffer = nil
```


