# Apple CREATEML Skill


## Building an Action Classifier Data Source
> https://developer.apple.com/documentation/createml/building-an-action-classifier-data-source

### 
#### 
#### 
- An integer of seconds, for example: `0`, `3`, or `5`.
- A floating point number of seconds, for example: `0.0`, `3.14`, or `60.5`.
- A string of minutes and seconds, for example: `01:03`.
- A string of minutes, seconds, and fractional seconds, for example: `01:03.14`.
- A string of hours, minutes, and seconds, for example: `05:01:03`.
- A string of hours, minutes, and seconds, for example: `05:01:03`.
Use the these indices to specify when an example clip begins and ends within its video file. For example, if a single video file contains squats and lunges, you can use that file in multiple annotations with different time indices, as shown in this CSV file example:
```other
video, label, start, end
lunge23.mov, Lunge, 0, 3.1
squats_13.mov, Squat, 0, 5
Jumping Jacks 1.mov, Jumping Jacks, 0, 4.7
Various_Exercises.mov, Lunge, 0.0, 2.2
Various_Exercises.mov, Lunge, 8:3.2, 8:4.5
Various_Exercises.mov, Squat, 1:59:5.8, 1:59:7
Various_Exercises.mov, Squat, 1:59:14, 1:59:15.1
```

```
To create an annotation file in JSON format, create an array of annotation objects at the root of the file. The following example shows the JSON equivalent of the preceding CSV file:
```other
 [
  {
    "video" : "lunge23.mov",
    "label" : "Lunge",
    "start" : 0,
    "end"   : 3.1
  },
  {
    "video" : "squats_13.mov",
    "label" : "Squat",
    "start" : 0,
    "end"   : 5
  },
  {
    "video" : "Jumping Jacks 1.mov",
    "label" : " Jumping Jacks",
    "start" : 0,
    "end"   : 4.7
  },
  {
    "video" : "Various_Exercises.mov",
    "label" : "Lunge",
    "start" : 0.0,
    "end"   : 2.2
  },
  {
    "video" : "Various_Exercises.mov",
    "label" : "Lunge",
    "start" : "8:3.2",
    "end"   : "8:4.5"
  },
  {
    "video" : "Various_Exercises.mov",
    "label" : "Squat",
    "start" : "1:59:5.8",
    "end"   : "1:59:7"
  },
  {
    "video" : "Various_Exercises.mov",
    "label" : "Squat",
    "start" : "1:59:14",
    "end"   : "1:59:15.1"
  }
]
```


## Creating a text classifier model
> https://developer.apple.com/documentation/createml/creating-a-text-classifier-model

### 
#### 
Start by gathering textual data and importing it into an  instance. You can create a data table from JSON and CSV formats. Or, if your textual data is in a collection of files, you can sort them into folders, using the folder names as labels, similar to the image data source used in .
As an example, consider a JSON file containing movie reviews that you’ve categorized by sentiment. Each entry contains a pair of keys, the `text` and the `label`. The values of those keys are the input samples used to train your model. The JSON snippet below shows three pairs of sentences with their sentiment labels.
```javascript
// JSON file
[
    {
        "text": "The movie was fantastic!",
        "label": "positive"
    }, {
        "text": "Very boring. Fell asleep.",
        "label": "negative"
    }, {
        "text": "It was just OK.",
        "label": "neutral"
    } ...
]
```

```
In a macOS playground, create a data frame using the  framework.
```swift
import TabularData

let data = try DataFrame(contentsOfJSONFile: URL(fileURLWithPath: "<#/path/to/read/data.json#>"))
```

#### 
The data you use to train your model needs to be different from the data you use to evaluate your model. Use the  method to split your data into two data frames, one for training and the other for testing. The training data frame contains the majority of your data, and the testing data frame contains the remaining 20 percent.
```swift
let (trainingData, testingData) = data.stratifiedSplit(on: "text", by: 0.8)
```

#### 
If your data contains a single language, use the conditional random fields algorithm  or the transfer learning algorithm  and set its  to the Embeddings from Language Models (ELMo) embedding feature extractor .
Use the  parameter to specify the evaluation data that’s held out from training your model. During the training process, use the validation data to estimate your model’s ability to correctly classify new examples. Depending on the validation accuracy, the classifier algorithm might adjust values within the model — or stop the training process, if the accuracy is high enough. Since the split of your data is random, you might get a different result each time you train your model.
```swift
let parameters = MLTextClassifier.ModelParameters(
    validation: .split(strategy: .automatic),
    algorithm: .transferLearning(.bertEmbedding, revision: 1),
    language: .english
)
```

#### 
Create an instance of  with your training data frame and the column names.
```swift
let sentimentClassifier = try MLTextClassifier(
    trainingData: trainingData,
    textColumn: "text",
    labelColumn: "label",
    parameters: parameters
)
```

```
To measure how accurately the model (`sentimentClassifier`) performs on the training and validation data, use the  properties of the model’s  and  properties.
```swift
// Calculate training accuracy as a percentage.
let trainingAccuracy = (1.0 - sentimentClassifier.trainingMetrics.classificationError) * 100

// Calculate validation accuracy as a percentage.
let validationAccuracy = (1.0 - sentimentClassifier.validationMetrics.classificationError) * 100
```

#### 
Next, evaluate your trained model’s performance by testing it against sentences it’s never seen before. Pass your testing data frame to the  method, which returns an  instance.
```swift
let evaluationMetrics = sentimentClassifier.evaluation(on: testingData, textColumn: "text", labelColumn: "label")
```

```
To get the evaluation accuracy, use the  property of the returned  instance.
```swift
// Calculate evaluation accuracy as a percentage.
let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100
```

#### 
When your model is performing well enough, you’re ready to save it so you can use it in your app. Use the  method to write the Core ML model file to disk. Provide any information about the model, like its author, version, or description in an  instance.
```swift
let metadata = MLModelMetadata(author: "John Appleseed",
                               shortDescription: "A model trained to classify movie review sentiment",
                               version: "1.0")

try sentimentClassifier.write(to: URL(fileURLWithPath: "<#/path/to/save/SentimentClassifier.mlmodel#>"),
                              metadata: metadata)
```

Specify the file name using the `fileURLWithPath:` parameter, in the above code, `SentimentClassifier.mlmodel`.
#### 
With your app open in Xcode, drag the `SentimentClassifier.mlmodel` file into the navigation pane. Xcode compiles the model and generates a `SentimentClassifier` class for use in your app. Select the `SentimentClassifier.mlmodel` file in Xcode to view additional information about the model.
Create an  in the Natural Language framework from the `SentimentClassifier` to ensure that the tokenization is consistent between training and deployment. Then use  to generate predictions on new text inputs.
```swift
import NaturalLanguage
import CoreML

let mlModel = try SentimentClassifier(configuration: MLModelConfiguration()).model

let sentimentPredictor = try NLModel(mlModel: mlModel)
sentimentPredictor.predictedLabel(for: "It was the best I've ever seen!")
```


## Creating a word tagger model
> https://developer.apple.com/documentation/createml/creating-a-word-tagger-model

### 
#### 
As an example, consider a JSON file containing sentences with words that you’ve tagged. Each entry contains a pair of keys—`tokens` and `labels`:
- The value for the `tokens` key is an array of words and punctuation in an individual sentence.
- The value for `labels` is an array of corresponding labels, or tags, for each of those tokens.
The arrays are the same length, resulting in a one-to-one mapping between each token and its corresponding label.
The JSON snippet below shows three pairs of tokenized sentences with their associated labels.
```javascript
// JSON file
[
    {
        "tokens": ["AirPods", "are", "a", "fantastic", "Apple", "product", "."],
        "labels": ["PROD", "NONE", "NONE", "NONE", "ORG", "NONE", "NONE"]
    },
    {
        "tokens": ["The", "iPhone", "takes", "stunning", "photos", "."],
        "labels": ["NONE", "PROD", "NONE", "NONE", "NONE", "NONE"]
    },
    {
        "tokens": ["Start", "building", "a", "native", "Mac", "app", "from", "your", "current", "iPad", "app", "using", "Mac", "Catalyst", "."],
        "labels": ["NONE", "NONE", "NONE", "NONE", "PROD", "NONE", "NONE", "NONE", "NONE", "PROD", "NONE", "NONE", "PROD", "PROD", "NONE"]
    }
]
```

```
In a macOS playground, create the data table using the  method of .
```javascript
import CreateML

let data = try MLDataTable(contentsOf:
    URL(fileURLWithPath: "<#/path/to/read/data.json#>"))
```

#### 
Generally, the testing dataset is significantly smaller than the training dataset. You might want to use about 80 percent of your overall data to train the model, and 20 percent to test it. However, it’s more important that the testing data is high-quality: as close as possible to real-world examples, well-distributed, and balanced. Use your best data for your testing data.
One way to generate training and testing data from your dataset is to use the  method of . This method splits your data into two tables, one for training and the other for testing. Specify a `0.8` split to create a training data table that contains 80 percent of your data, and a testing data table that contains the remaining 20 percent.
```swift
let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)
```

#### 
Create an instance of  with your training data table and the names of your columns. Training begins immediately.
```swift
let wordTagger = try MLWordTagger(trainingData: trainingData,
                             tokenColumn: "tokens",
                             labelColumn: "labels")
```

Training and validation data must be entirely separate, with no overlap. If you want to make this split yourself, you can set aside around 5 to 10 percent of your training data as your validation data, and provide that data by setting custom model parameters. If you don’t do the split yourself, Create ML automatically sets aside a small percentage of the training data to use for validating the model’s progress during the training phase. Because the data is split randomly, you might get a different result each time you train the model.
To see how accurately the model performed on the training and validation data, use the  property of the model’s  and  properties.
```swift
// Training accuracy as a percentage
let trainingAccuracy = (1.0 - wordTagger.trainingMetrics.taggingError) * 100

// Validation accuracy as a percentage
let validationAccuracy = (1.0 - wordTagger.validationMetrics.taggingError) * 100
```

#### 
Next, evaluate your trained model’s performance by testing it against sentences it’s never seen before. Pass your testing data table to the  method, which returns an  instance.
```swift
let evaluationMetrics = wordTagger.evaluation(on: testingData,
                                              tokenColumn: "tokens",
                                              labelColumn: "labels")
```

```
To get the evaluation accuracy, use the  property of the returned  instance.
```swift
// Evaluation accuracy as a percentage
let evaluationAccuracy = (1.0 - evaluationMetrics.taggingError) * 100
```

#### 
When your model is performing well enough, you’re ready to save it so you can use it in your app. Use the  method to write the Core ML model file (in this example, `AppleTagger.mlmodel`) to disk. Provide any information about the model, like its author, version, or description, in an  instance.
```swift
let metadata = MLModelMetadata(author: "Jane Appleseed",
                               shortDescription: "A model trained to tag Apple products.",
                               version: "1.0")

try wordTagger.write(to: URL(fileURLWithPath: "<#/path/to/save/AppleTagger.mlmodel#>"),
                              metadata: metadata)
```

#### 
With your app open in Xcode, drag the `AppleTagger.mlmodel` file into the navigation pane. Xcode compiles the model and generates an `AppleTagger` class for use in your app. Select the `AppleTagger.mlmodel` file in Xcode to view additional information about the model.
Create an  in the Natural Language framework from the `AppleTagger` to ensure that the tokenization is consistent between training and deployment. Attach the model to an  to tag sentences or paragraphs, using an existing or custom .
```swift
import NaturalLanguage 
import CoreML

let text = "The iPad is my favorite Apple product."

do {
    let mlModel = try AppleTagger(configuration: MLModelConfiguration()).model

    let customModel = try NLModel(mlModel: mlModel)
    let customTagScheme = NLTagScheme("Apple")
    
    let tagger = NLTagger(tagSchemes: [.nameType, customTagScheme])
    tagger.string = text
    tagger.setModels([customModel], forTagScheme: customTagScheme)
    
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, 
                         scheme: customTagScheme, options: .omitWhitespace) { tag, tokenRange  in
        if let tag = tag {
            print("\(text[tokenRange]): \(tag.rawValue)")
        }
        return true
    }
} catch {
    print(error)
}
```


## Creating an Image Classifier Model
> https://developer.apple.com/documentation/createml/creating-an-image-classifier-model

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
To use your model in code, you only need to change one line. The project instantiates the MobileNet model in exactly one place in the `ImagePredictor` class.
```swift
// Create an instance of the image classifier's wrapper class.
let imageClassifierWrapper = try? MobileNet(configuration: defaultConfig)
```

```
Change this line to use your image classification model class instead:
```swift
// Create an instance of the image classifier's wrapper class.
let imageClassifierWrapper = try? AnimalClassifier(configuration: defaultConfig)
```

#### 

## Detecting human actions in a live video feed
> https://developer.apple.com/documentation/createml/detecting-human-actions-in-a-live-video-feed

### 
### 
### 
The app’s `VideoCapture`class configures the device’s camera to generate video frames by creating an .
The app’s `VideoCapture`class configures the device’s camera to generate video frames by creating an .
When the app first launches, or when the user rotates the device or switches between cameras, video capture configures a camera input, a frame output, and the connection between them in its `configureCaptureSession()` method.
```swift
let input = AVCaptureDeviceInput.createCameraInput(position: cameraPosition)

let output = AVCaptureVideoDataOutput.withPixelFormatType(kCVPixelFormatType_32BGRA)

let success = configureCaptureConnection(input, output)
return success ? output : nil
```

The `AVCaptureVideoDataOutput.withPixelFormatType(_:)` method creates an  that produces frames with a specific pixel format.
The `configureCaptureConnection(_:_:)` method configures the relationship between the capture session’s camera input and video output by:
- Deciding whether to horizontally flip the video
- Enabling image stabilization when applicable
```swift
if connection.isVideoOrientationSupported {
    // Set the video capture's orientation to match that of the device.
    connection.videoOrientation = orientation
}

if connection.isVideoMirroringSupported {
    connection.isVideoMirrored = horizontalFlip
}

if connection.isVideoStabilizationSupported {
    if videoStabilizationEnabled {
        connection.preferredVideoStabilizationMode = .standard
    } else {
        connection.preferredVideoStabilizationMode = .off
    }
}
```

The method keeps the app operating in real time — and avoids building up a frame backlog — by setting the video output’s  property to `true`.
```
The method keeps the app operating in real time — and avoids building up a frame backlog — by setting the video output’s  property to `true`.
```swift
// Discard newer frames if the app is busy with an earlier frame.
output.alwaysDiscardsLateVideoFrames = true
```

### 
The video capture publishes frames from its capture session by creating a  in its `createVideoFramePublisher()` method.
The video capture publishes frames from its capture session by creating a  in its `createVideoFramePublisher()` method.
```swift
// Create a new passthrough subject that publishes frames to subscribers.
let passthroughSubject = PassthroughSubject<Frame, Never>()

// Keep a reference to the publisher.
framePublisher = passthroughSubject
```

A passthrough subject is a concrete implementation of  that adapts imperative code to work with . It immediately publishes the instance you pass to its  method, if it has a subscriber at that time.
Next, the video capture registers itself as the video output’s delegate so it receives the video frames from the capture session by calling the output’s  method.
```swift
// Set the video capture as the video output's delegate.
videoDataOutput.setSampleBufferDelegate(self, queue: videoCaptureQueue)
```

The video capture forwards each frame it receives to its `framePublisher` by passing the frame to its  method.
```
The video capture forwards each frame it receives to its `framePublisher` by passing the frame to its  method.
```swift
extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput frame: Frame,
                       from connection: AVCaptureConnection) {

        // Forward the frame through the publisher.
        framePublisher?.send(frame)
    }
}
```

### 
The sample processes each video frame, and its derivative data, with a series of methods that it connects together into a chain of  publishers in the `VideoProcessingChain` class.
Each time the video capture creates a new frame publisher it notifies the main view controller, which then assigns the publisher to the video-processing chain’s `upstreamFramePublisher` property:
```swift
func videoCapture(_ videoCapture: VideoCapture,
                  didCreate framePublisher: FramePublisher) {
    updateUILabelsWithPrediction(.startingPrediction)
    
    // Build a new video-processing chain by assigning the new frame publisher.
    videoProcessingChain.upstreamFramePublisher = framePublisher
}
```

- 
For example, the publisher that subscribes to the initial frame publisher is a  that converts each `Frame` (a type alias of ) it receives into a  by calling the video-processing chain’s `imageFromFrame(_:)` method.
```swift
// Create the chain of publisher-subscribers that transform the raw video
// frames from upstreamFramePublisher.
frameProcessingChain = upstreamFramePublisher
    // ---- Frame (aka CMSampleBuffer) -- Frame ----

    // Convert each frame to a CGImage, skipping any that don't convert.
    .compactMap(imageFromFrame)

    // ---- CGImage -- CGImage ----

    // Detect any human body poses (or lack of them) in the frame.
    .map(findPosesInFrame)

    // ---- [Pose]? -- [Pose]? ----
```

### 
> **important:** Improve your app’s efficiency by creating and reusing a single  instance.
```swift
// Create a request handler for the image.
let visionRequestHandler = VNImageRequestHandler(cgImage: frame)

// Use Vision to find human body poses in the frame.
do { try visionRequestHandler.perform([humanBodyPoseRequest]) } catch {
    assertionFailure("Human Pose Request failed: \(error)")
}
```

When the request completes, the method creates and returns a `Pose` array that contains one pose for every  instance in the request’s  property.
```
When the request completes, the method creates and returns a `Pose` array that contains one pose for every  instance in the request’s  property.
```swift
let poses = Pose.fromObservations(humanBodyPoseRequest.results)
```

The `Pose` structure in this sample serves three main purposes:
### 
The next publisher in the chain is a map that chooses a single pose from the array of poses by using the video-processing chain’s `isolateLargestPose(_:)` method. This method selects the the most prominent pose by passing a closure to the pose array’s  method.
```swift
private func isolateLargestPose(_ poses: [Pose]?) -> Pose? {
    return poses?.max(by:) { pose1, pose2 in pose1.area < pose2.area }
}
```

### 
The next publisher in the chain is a map that publishes the  from the pose’s `multiArray` property by using the video processing chain’s `multiArrayFromPose(_:)` method.
```swift
private func multiArrayFromPose(_ item: Pose?) -> MLMultiArray? {
    return item?.multiArray
}
```

The `Pose` initializer copies the multiarray from its  parameter by calling the observation’s  method.
```
The `Pose` initializer copies the multiarray from its  parameter by calling the observation’s  method.
```swift
// Save the multiarray from the observation.
multiArray = try? observation.keypointsMultiArray()
```

### 
- The video-processing chain’s `gatherWindow(previousWindow:multiArray:)` method as the scan publisher’s transform.
- An empty multiarray-optional array as the scan publisher’s initial value.
- The video-processing chain’s `gatherWindow(previousWindow:multiArray:)` method as the scan publisher’s transform.
```swift
// ---- MLMultiArray? -- MLMultiArray? ----

// Gather a window of multiarrays, starting with an empty window.
.scan([MLMultiArray?](), gatherWindow)

// ---- [MLMultiArray?] -- [MLMultiArray?] ----
```

```
A scan publisher behaves similarly to a map, but it also maintains a state. The following scan publisher’s state is an array of multiarray optionals that’s initially empty. As the scan publisher receives multiarray optionals from its upstream publisher, the scan publisher passes its previous state and the incoming multiarray optional as arguments to its transform.
```swift
private func gatherWindow(previousWindow: [MLMultiArray?],
                          multiArray: MLMultiArray?) -> [MLMultiArray?] {
    var currentWindow = previousWindow

    // If the previous window size is the target size, it
    // means sendWindowWhenReady() just published an array window.
    if previousWindow.count == predictionWindowSize {
        // Advance the sliding array window by stride elements.
        currentWindow.removeFirst(windowStride)
    }

    // Add the newest multiarray to the window.
    currentWindow.append(multiArray)

    // Publish the array window to the next subscriber.
    // The currentWindow becomes this method's next previousWindow when
    // it receives the next multiarray from the upstream publisher.
    return currentWindow
}
```

1. Copies the `previousWindow` parameter to `currentWindow`
2. Removes `windowStride` elements from the front of `currentWindow`, if it’s full
3. Appends the `multiArray` parameter to the end of `currentWindow`
### 
The next publisher in the chain is a , which only publishes an array window when the `gateWindow(_:)` method returns `true`.
The next publisher in the chain is a , which only publishes an array window when the `gateWindow(_:)` method returns `true`.
```swift
// Only publish a window when it grows to the correct size.
.filter(gateWindow)

// ---- [MLMultiArray?] -- [MLMultiArray?] ----
```

```
The method returns `true` if the window array contains exactly the number of elements defined in `predictionWindowSize`. Otherwise, the method returns `false`, which instructs the filter publisher to discard the current window and not publish it.
```swift
private func gateWindow(_ currentWindow: [MLMultiArray?]) -> Bool {
    return currentWindow.count == predictionWindowSize
}
```

### 
The next publisher in the chain makes an `ActionPrediction` from the multiarray window by using the `predictActionWithWindow(_:)` method as its transform.
```swift
// Make an activity prediction from the window.
.map(predictActionWithWindow)

// ---- ActionPrediction -- ActionPrediction ----
```

- Copying each each valid element in `currentWindow`
- Replacing each `nil` element in `currentWindow` with an `emptyPoseMultiArray`
- Copying each each valid element in `currentWindow`
- Replacing each `nil` element in `currentWindow` with an `emptyPoseMultiArray`
```swift
var poseCount = 0

// Fill the nil elements with an empty pose array.
let filledWindow: [MLMultiArray] = currentWindow.map { multiArray in
    if let multiArray = multiArray {
        poseCount += 1
        return multiArray
    } else {
        return Pose.emptyPoseMultiArray
    }
}
```

As the method iterates through each element in `currentWindow`, it tallies the number of non-`nil` elements with `poseCount`.
If the value of `poseCount` is too low, the method directly creates a `noPersonPrediction` action prediction.
As the method iterates through each element in `currentWindow`, it tallies the number of non-`nil` elements with `poseCount`.
If the value of `poseCount` is too low, the method directly creates a `noPersonPrediction` action prediction.
```swift
// Only use windows with at least 60% real data to make a prediction
// with the action classifier.
let minimum = predictionWindowSize * 60 / 100
guard poseCount >= minimum else {
    return ActionPrediction.noPersonPrediction
}
```

```
Otherwise, the method merges the array of multiarrays into a single, combined multiarray by calling the  initializer.
```swift
// Merge the array window of multiarrays into one multiarray.
let mergedWindow = MLMultiArray(concatenating: filledWindow,
                                axis: 0,
                                dataType: .float)
```

The method generates an action prediction by passing the combined multiarray to the action classifier’s `predictActionFromWindow(_:)` helper method.
```
The method generates an action prediction by passing the combined multiarray to the action classifier’s `predictActionFromWindow(_:)` helper method.
```swift
// Make a genuine prediction with the action classifier.
let prediction = actionClassifier.predictActionFromWindow(mergedWindow)

// Return the model's prediction if the confidence is high enough.
// Otherwise, return a "Low Confidence" prediction.
return checkConfidence(prediction)
```

### 
The final component in the chain is a subscriber that notifies the video-processing chain’s delegate with the prediction using the `sendPrediction(_:)` method.
```swift
// Send the action prediction to the delegate.
.sink(receiveValue: sendPrediction)
```

```
The method sends the action prediction and the number of frames the prediction represents (`windowStride`) to the video-processing chain’s `delegate`, the main view controller.
```swift
// Send the prediction to the delegate on the main queue.
DispatchQueue.main.async {
    self.delegate?.videoProcessingChain(self,
                                        didPredict: actionPrediction,
                                        for: windowStride)
}
```

```
Each time the main view controller receives an action prediction, it updates the app’s UI with the prediction and confidence in a helper method.
```swift
func videoProcessingChain(_ chain: VideoProcessingChain,
                          didPredict actionPrediction: ActionPrediction,
                          for frameCount: Int) {

    if actionPrediction.isModelLabel {
        // Update the total number of frames for this action.
        addFrameCount(frameCount, to: actionPrediction.label)
    }

    // Present the prediction in the UI.
    updateUILabelsWithPrediction(actionPrediction)
}
```

### 
The app visualizes the result of each human body-pose request by drawing the poses on top of the frame in which  found them. Each time the video-processing chain’s `findPosesInFrame(_:)` creates an array of `Pose` instances, it sends the poses to its delegate, the main view controller.
```swift
// Send the frame and poses, if any, to the delegate on the main queue.
DispatchQueue.main.async {
    self.delegate?.videoProcessingChain(self, didDetect: poses, in: frame)
}
```

The main view controller’s `drawPoses(_:onto:)` method uses the frame as the background by first drawing the frame.
```
The main view controller’s `drawPoses(_:onto:)` method uses the frame as the background by first drawing the frame.
```swift
// Draw the camera image first as the background.
let imageRectangle = CGRect(origin: .zero, size: frameSize)
cgContext.draw(frame, in: imageRectangle)
```

```
Next, the method draws the poses by calling their `drawWireframeToContext(_:applying:)` method, which draws the pose as a wireframe of lines and circles.
```swift
// Draw all the poses Vision found in the frame.
for pose in poses {
    // Draw each pose as a wireframe at the scale of the image.
    pose.drawWireframeToContext(cgContext, applying: pointTransform)
}
```

```
The main view controller presents the finished image to the user by assigning it to its full-screen image view.
```swift
// Update the UI's full-screen image view on the main thread.
DispatchQueue.main.async { self.imageView.image = frameWithPosesRendering }
```


## Improving Your Model’s Accuracy
> https://developer.apple.com/documentation/createml/improving-your-model-s-accuracy

### 
No single metric can tell you everything about your model’s performance. To improve your model, you compare the metrics ( or  depending on your model type) among your training, validation, and testing data sets. For example, the accuracy discussed in the  article is derived from the  metric for each data set.
You can also access these values programmatically after creating a model and loading your testing data:
```swift
print("Training Metrics\n", model.trainingMetrics)
print("Validation Metrics\n", model.validationMetrics)

let evaluationMetrics = model.evaluation(on: testData)
print("Evaluation Metrics\n", evaluationMetrics)
```

#### 
#### 
#### 

