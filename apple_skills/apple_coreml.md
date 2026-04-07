# Apple COREML Skill


## Detecting human body poses in an image
> https://developer.apple.com/documentation/coreml/detecting-human-body-poses-in-an-image

### 
#### 
The sample starts by getting an image from the device’s built-in camera using an  (see ).
```swift
if captureSession.isRunning {
    captureSession.stopRunning()
}

captureSession.beginConfiguration()

captureSession.sessionPreset = .vga640x480

try setCaptureSessionInput()

try setCaptureSessionOutput()

captureSession.commitConfiguration()
```

#### 
```swift
// Attempt to lock the image buffer to gain access to its memory.
guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess
    else {
        return
}

// Create Core Graphics image placeholder.
var image: CGImage?

// Create a Core Graphics bitmap image from the pixel buffer.
VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)

// Release the image buffer.
CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)

DispatchQueue.main.sync {
    delegate.videoCapture(self, didCaptureFrame: image)
}
```

#### 
```swift
// Wrap the image in an instance of PoseNetInput to have it resized
// before being passed to the PoseNet model.
let input = PoseNetInput(image: image, size: self.modelInputSize)
```

#### 
The sample app then proceeds to pass the input to the PoseNet’s  function to obtain its outputs, which the app uses to detect poses.
```swift
guard let prediction = try? self.poseNetMLModel.prediction(from: input) else {
    return
}
```

}
```
```swift
let poseNetOutput = PoseNetOutput(prediction: prediction,
                                  modelInputSize: self.modelInputSize,
                                  modelOutputStride: self.outputStride)

DispatchQueue.main.async {
    self.delegate?.poseNet(self, didPredict: poseNetOutput)
}
```

#### 
The sample uses one of two algorithms to locate the joints of either one person or multiple persons. The single-person algorithm, the simplest and fastest, inspects the model’s outputs to locate the most prominent joints in the image and uses these joints to construct a single pose.
```swift
var pose = Pose()

// For each joint, find its most likely position and associated confidence
// by querying the heatmap array for the cell with the greatest
// confidence and using this to compute its position.
pose.joints.values.forEach { joint in
    configure(joint: joint)
}

// Compute and assign the confidence for the pose.
pose.confidence = pose.joints.values
    .map { $0.confidence }.reduce(0, +) / Double(Joint.numberOfJoints)

// Map the pose joints positions back onto the original image.
pose.joints.values.forEach { joint in
    joint.position = joint.position.applying(modelToInputTransformation)
}

return pose
```

```
The multiple-person algorithm first identifies a set of candidate root joints as starting points. It uses these root joints to find neighboring joints and repeats the process until it has located all 17 joints of each person. For example, the algorithm may find a left knee with a high confidence, and then search for its adjacent joints, the left ankle and left hip.
```swift
var detectedPoses = [Pose]()

// Iterate through the joints with the greatest confidence, referred to here as
// candidate roots, using each as a starting point to assemble a pose.
for candidateRoot in candidateRoots {
    // Ignore any candidates that are in the proximity of joints of the
    // same type and have already been assigned to an existing pose.
    let maxDistance = configuration.matchingJointDistance
    guard !detectedPoses.contains(candidateRoot, within: maxDistance) else {
        continue
    }

    var pose = assemblePose(from: candidateRoot)

    // Compute the pose's confidence by dividing the sum of all
    // non-overlapping joints, from existing poses, by the total
    // number of joints.
    pose.confidence = confidence(for: pose, detectedPoses: detectedPoses)

    // Ignore any pose that has a confidence less than the assigned threshold.
    guard pose.confidence >= configuration.poseConfidenceThreshold else {
        continue
    }

    detectedPoses.append(pose)

    // Exit early if enough poses have been detected.
    if detectedPoses.count >= configuration.maxPoseCount {
        break
    }
}

// Map the pose joints positions back onto the original image using
// the pre-computed transformation matrix.
detectedPoses.forEach { pose in
    pose.joints.values.forEach { joint in
        joint.position = joint.position.applying(modelToInputTransformation)
    }
}

return detectedPoses
```

#### 
For each detected pose, the sample app draws a wireframe over the input image, connecting the lines between the joints and then drawing circles for the joints themselves.
```swift
let dstImageSize = CGSize(width: frame.width, height: frame.height)
let dstImageFormat = UIGraphicsImageRendererFormat()

dstImageFormat.scale = 1
let renderer = UIGraphicsImageRenderer(size: dstImageSize,
                                       format: dstImageFormat)

let dstImage = renderer.image { rendererContext in
    // Draw the current frame as the background for the new image.
    draw(image: frame, in: rendererContext.cgContext)

    for pose in poses {
        // Draw the segment lines.
        for segment in PoseImageView.jointSegments {
            let jointA = pose[segment.jointA]
            let jointB = pose[segment.jointB]

            guard jointA.isValid, jointB.isValid else {
                continue
            }

            drawLine(from: jointA,
                     to: jointB,
                     in: rendererContext.cgContext)
        }

        // Draw the joints as circles above the segment lines.
        for joint in pose.joints.values.filter({ $0.isValid }) {
            draw(circle: joint, in: rendererContext.cgContext)
        }
    }
}
```


## Downloading and Compiling a Model on the User’s Device
> https://developer.apple.com/documentation/coreml/downloading-and-compiling-a-model-on-the-user-s-device

### 
#### 
Download the model definition file (ending in `.mlmodel`) onto the user’s device by using , , or another networking toolkit. Then compile the model definition by calling .
```swift
let compiledModelURL = try MLModel.compileModel(at: modelDescriptionURL)
```

```
This creates a new, compiled model file with the same name as the model description but ending in `.mlmodelc`. Create a new  instance by passing the compiled model  to its initializer.
```swift
let model = try MLModel(contentsOf: compiledModelURL)
```

#### 
 saves models it compiles to a temporary location. If your app can reuse the model later, reduce your resource consumption by saving the compiled model to a permanent location.
Build the  to a permanent location that your app can access in the future, such as Application Support.
```swift
let fileManager = FileManager.default
let appSupportURL = fileManager.urls(for: .applicationSupportDirectory,
                                     in: .userDomainMask).first!
```

```
Create the  for the permanent compiled model file.
```swift
let compiledModelName = compiledModelURL.lastPathComponentlet
permanentURL = appSupportURL.appendingPathComponent(compiledModelName)
```

```
Move or copy the file to its permanent location.
```swift
// Copy the file to the permanent location, replacing it if necessary.
_ = try fileManager.replaceItemAt(permanentURL,
                                  withItemAt: compiledModelURL)

```


## Finding answers to questions in a text document
> https://developer.apple.com/documentation/coreml/finding-answers-to-questions-in-a-text-document

### 
#### 
#### 
#### 
The sample does this by using an , which breaks up a string into word tokens, each of which is a substring of the original.
```swift
// Store the tokenized substrings into an array.
var wordTokens = [Substring]()

// Use Natural Language's NLTagger to tokenize the input by word.
let tagger = NLTagger(tagSchemes: [.tokenType])
tagger.string = rawString

// Find all tokens in the string and append to the array.
tagger.enumerateTags(in: rawString.startIndex..<rawString.endIndex,
                     unit: .word,
                     scheme: .tokenType,
                     options: [.omitWhitespace]) { (_, range) -> Bool in
    wordTokens.append(rawString[range])
    return true
}

return wordTokens
```

#### 
For speed and efficiency, the BERT model operates on token IDs, which are numbers that represent tokens, rather than operating on the text tokens themselves.
```swift
let subTokenID = BERTVocabulary.tokenID(of: searchTerm)
```

Secondary wordpieces, such as  and , each appear in the vocabulary with two leading pound signs, as `##har` and `##gic`.
#### 
- `wordIDs` — Accepts the document and question texts
- `wordTypes` — Tells the BERT model which elements of `wordIDs` are from the document
The sample creates the `wordIDs` array by arranging the token IDs in the following order:
1. A  token ID, which has a value of `101` and appears as `"[CLS]"` in the vocabulary file
3. A  token ID, which has a value of `102` and appears as `"[SEP]"` in the vocabulary file
6. One or more  token IDs for the remaining, unused elements, which have a value of `0` and appear as `"[PAD]"` in the vocabulary file
5. Another separator token ID
6. One or more  token IDs for the remaining, unused elements, which have a value of `0` and appear as `"[PAD]"` in the vocabulary file
```swift
// Start the wordID array with the `classification start` token.
var wordIDs = [BERTVocabulary.classifyStartTokenID]

// Add the question tokens and a separator.
wordIDs += question.tokenIDs
wordIDs += [BERTVocabulary.separatorTokenID]

// Add the document tokens and a separator.
wordIDs += document.tokenIDs
wordIDs += [BERTVocabulary.separatorTokenID]

// Fill the remaining token slots with padding tokens.
let tokenIDPadding = BERTInput.maxTokens - wordIDs.count
wordIDs += Array(repeating: BERTVocabulary.paddingTokenID, count: tokenIDPadding)
```

```
Next, the sample prepares the `wordTypes` input by creating an array of the same length, where all the elements that correspond to the document text are `1` and all others are `0`.
```swift
// Set all of the token types before the document to 0.
var wordTypes = Array(repeating: 0, count: documentOffset)

// Set all of the document token types to 1.
wordTypes += Array(repeating: 1, count: document.tokens.count)

// Set the remaining token types to 0.
let tokenTypePadding = BERTInput.maxTokens - wordTypes.count
wordTypes += Array(repeating: 0, count: tokenTypePadding)
```

Next, the sample creates an  for each input and copies the contents from the arrays, which it uses to create a `BERTQAFP16Input` feature provider.
> **note:** The BERT model in this sample requires a one-dimensional  input with 384 elements. Models from other sources may have different inputs or shapes.
```swift
// Create the MLMultiArray instances.
let tokenIDMultiArray = try? MLMultiArray(wordIDs)
let wordTypesMultiArray = try? MLMultiArray(wordTypes)

// Unwrap the MLMultiArray optionals.
guard let tokenIDInput = tokenIDMultiArray else {
    fatalError("Couldn't create wordID MLMultiArray input")
}

guard let tokenTypeInput = wordTypesMultiArray else {
    fatalError("Couldn't create wordType MLMultiArray input")
}

// Create the BERT input MLFeatureProvider.
let modelInput = BERTQAFP16Input(wordIDs: tokenIDInput,
                                 wordTypes: tokenTypeInput)
```

#### 
You use the BERT model to predict where to find an answer to the question in the document text, by giving the model your input feature provider with the input  instances.
```swift
guard let prediction = try? bertModel.prediction(input: modelInput) else {
    return "The BERT model is unable to make a prediction."
}
```

#### 
1. Converting each output logit  into a `Double` array.
3. Finding the indices, in each array, to the 20 logits with the highest values.
4. Searching through the 20 x 20 or fewer combinations of logits for the best combination.
```swift
// Convert the logits MLMultiArrays to [Double].
let startLogits = prediction.startLogits.doubleArray()
let endLogits = prediction.endLogits.doubleArray()

// Isolate the logits for the document.
let startLogitsOfDoc = [Double](startLogits[range])
let endLogitsOfDoc = [Double](endLogits[range])

// Only keep the top 20 (out of the possible ~380) indices for faster searching.
let topStartIndices = startLogitsOfDoc.indicesOfLargest(20)
let topEndIndices = endLogitsOfDoc.indicesOfLargest(20)

// Search for the highest valued logit pairing.
let bestPair = findBestLogitPair(startLogits: startLogitsOfDoc,
                                 bestStartIndices: topStartIndices,
                                 endLogits: endLogitsOfDoc,
                                 bestEndIndices: topEndIndices)
```

#### 

## Integrating a Core ML Model into Your App
> https://developer.apple.com/documentation/coreml/integrating-a-core-ml-model-into-your-app

### 
This sample app uses a trained model, `MarsHabitatPricer.mlmodel`, to predict habitat prices on Mars.
#### 
#### 
Use the generated `MarsHabitatPricer` class’s initializer to create the model:
Xcode also uses information about the model’s inputs and outputs to automatically generate a custom programmatic interface to the model, which you use to interact with the model in your code. For `MarsHabitatPricer.mlmodel`, Xcode generates interfaces to represent the model (`MarsHabitatPricer`), the model’s inputs (`MarsHabitatPricerInput`), and the model’s output (`MarsHabitatPricerOutput`).
Use the generated `MarsHabitatPricer` class’s initializer to create the model:
```swift
let marsHabitatPricer = try? MarsHabitatPricer(configuration: .init())
```

#### 
This sample app uses a `UIPickerView` to get the model’s input values from the user:
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
```
Access the `price` property of `marsHabitatPricerOutput` to get a predicted price and display the result in the app’s UI.
```swift
// Format the price for display in the UI.
let price = output.price
priceLabel.text = priceFormatter.string(for: price)
```

#### 

## Making Predictions with a Sequence of Inputs
> https://developer.apple.com/documentation/coreml/making-predictions-with-a-sequence-of-inputs

### 
#### 
#### 
#### 
Listing 1. Initializing a network by using `nil` as the first state
This network was trained to generate the rest of a sentence from the play, given two prompt words from a sentence. Begin processing a sequence of inputs with this model by passing in the first word from the prompt and `nil` as the previous state.
Listing 1. Initializing a network by using `nil` as the first state
```swift
// Create the prompt to use as an example
let prompt = ["O", "Romeo"]
// Use the generated input API to create the network's input, with no state
let modelInput = ShakespeareLanguageModelInput(previousWord: prompt[0], stateIn: nil)
// Predict the 2nd word and generate a model state for "O"
var modelOutput = try model.prediction(input: modelInput)
```

In this sample code the `ShakespeareLanguageModelInput` class, generated by Xcode, is used to store the two inputs for the prediction call.
#### 
Create an input using the second word from the prompt and the output state from the prediction as the input state. Use that input with the model to generate a prediction for the third word of the sentence.
Listing 2. Predicting the third word by using the second word and the state after processing the first word
```swift
// Set up the input for the second word (ignoring the predicted words)
modelInput.previousWord = prompt[1]
// Use the output model state as the input model state for the next word
modelInput.stateIn = modelOutput.stateOut
// Predict the third word
modelOutput = try model.prediction(input: modelInput)
// The third word is now in modelOutput.nextWord
```

However, once the two word prompt has been processed, the output `nextWord` is the most likely third word in the sentence. It will be used as the input word, to generate the fourth word in the sentence. Using the output as input is repeated to generate the rest of the sentence.
Listing 3. Using the next word prediction as the input word, to generate the rest of the sentence
```swift
// Feed the next word and output state back into the network,
// while the predicted word isn't the end of the sentence.
while modelOutput.nextWord != "</s>" {
    // Update the inputs from the network's output
    modelInput.previousWord = modelOutput.nextWord
    modelInput.stateIn = modelOutput.stateOut
    // Predict the next word
    modelOutput = try model.prediction(input: modelInput)
}
```

#### 
Reset the input context by using `nil` as the input state (as in Listing 1), to start making predictions on a new sentence.

## Personalizing a Model with On-Device Updates
> https://developer.apple.com/documentation/coreml/personalizing-a-model-with-on-device-updates

### 
#### 
3. Group all the feature providers in an .
Each time the user adds a new emoji sticker, the app prompts the user to make three drawings, and uses those drawings to update the drawing classifier. It does this by first creating an  that contains the feature values for a drawing and its label. The app appends each feature provider to an array, which it uses to create an  at the end of the function.
```swift
 var featureProviders = [MLFeatureProvider]()

 let inputName = "drawing"
 let outputName = "label"
         
 for drawing in trainingDrawings {
     let inputValue = drawing.featureValue
     let outputValue = MLFeatureValue(string: String(emoji))
     
     let dataPointFeatures: [String: MLFeatureValue] = [inputName: inputValue,
                                                        outputName: outputValue]
     
     if let provider = try? MLDictionaryFeatureProvider(dictionary: dataPointFeatures) {
         featureProviders.append(provider)
     }
 }
 
return MLArrayBatchProvider(array: featureProviders)
```

The sample makes each `MLDictionaryFeatureProvider` by initializing it with a dictionary of two  instances keyed by strings. The feature values are:
- The underlying image of the drawing keyed by `"drawing"`
- The emoji character as a string keyed by `"label"`
- The emoji character as a string keyed by `"label"`
The sample creates a feature value for the emoji string by using . However, to convert the drawing’s underlying  into a feature value, the sample acquires the image constraint of the model’s image input feature.
```swift
let imageFeatureValue = try? MLFeatureValue(cgImage: preparedImage,
                                            constraint: imageConstraint)
return imageFeatureValue!
```

The sample gets the drawing classifier’s `"drawing"`  by inspecting the .
```
The sample gets the drawing classifier’s `"drawing"`  by inspecting the .
```swift
/// - Tag: ImageConstraintProperty
extension UpdatableDrawingClassifier {
    /// Returns the image constraint for the model's "drawing" input feature.
    var imageConstraint: MLImageConstraint {
        let description = model.modelDescription
        
        let inputName = "drawing"
        let imageInputDescription = description.inputDescriptionsByName[inputName]!
        
        return imageInputDescription.imageConstraint!
    }
}
```

#### 
- The location of the compiled model youʼd like to update (`.mlmodelc`)
- A completion handler with a single  parameter
The sample updates the drawing classifier model it’s currently using, which could be the original drawing classifier model or a previously updated model.
```swift
// Create an Update Task.
guard let updateTask = try? MLUpdateTask(forModelAt: url,
                                   trainingData: trainingData,
                                   configuration: nil,
                                   completionHandler: completionHandler)
    else {
        print("Could't create an MLUpdateTask.")
        return
}
```

> **important:** An update task can only update a  model file—one whose name ends with `.mlmodelc`.
#### 
You begin an update task by calling its  method.
```swift
updateTask.resume()
```

#### 
Use your completion handler to save the updated model in the  to disk. The sample saves the updated model to the file system by first writing the model to a temporary location. Next, the sample moves the updated model to a permanent location, replacing any previously saved updated model.
```swift
let updatedModel = updateContext.model
let fileManager = FileManager.default
do {
    // Create a directory for the updated model.
    try fileManager.createDirectory(at: tempUpdatedModelURL,
                                    withIntermediateDirectories: true,
                                    attributes: nil)
    
    // Save the updated model to temporary filename.
    try updatedModel.write(to: tempUpdatedModelURL)
    
    // Replace any previously updated model with this one.
    _ = try fileManager.replaceItemAt(updatedModelURL,
                                      withItemAt: tempUpdatedModelURL)
    
    print("Updated model saved to:\n\t\(updatedModelURL)")
} catch let error {
    print("Could not save updated model to the file system: \(error)")
    return
}
```

#### 
Use your updated model by loading it with the model’s  initializer. The sample loads a new instance of `UpdatableDrawingClassifier` with the  of the updated model file the app saved in the previous step.
```swift
guard FileManager.default.fileExists(atPath: updatedModelURL.path) else {
    // The updated model is not present at its designated path.
    return
}

// Create an instance of the updated model.
guard let model = try? UpdatableDrawingClassifier(contentsOf: updatedModelURL) else {
    return
}

// Use this updated model to make predictions in the future.
updatedDrawingClassifier = model
```


## Using Core ML for semantic image segmentation
> https://developer.apple.com/documentation/coreml/using-core-ml-for-semantic-image-segmentation

### 
#### 
To use a model with a different name, but using the same semantics, replace the source code references in `ViewModel` with the model class for `Model` and `ModelOutput`:
```swift
final class ViewModel: ObservableObject {
    typealias Model = DETRResnet50SemanticSegmentationF16P8
    typealias ModelOutput = DETRResnet50SemanticSegmentationF16P8Output
}
```

#### 
How long it takes to load a model depends on many factors, including the size of the model. The sample app loads the segmentation model asynchronously to avoid blocking the calling thread:
```swift
nonisolated func loadModel() async {
    do {
        let model = try Model()
        let labels = model.model.segmentationLabels
        await didLoadModel(model, labels: labels)
    } catch {
        Task { @MainActor in
            errorMessage = "The model failed to load: \(error.localizedDescription)"
        }
    }
}
```

```
In the `MainView`, the sample loads the model using the `task` modifier, and displays a progress view to display the load time. The sample uses the `ObservableObject` protocol to observe when the loading is complete:
```swift
var body: some View {
    VStack(spacing: 20) {
        
        // Other existing view configuration.

        // Display a load message when the sample loads the model.
        if !viewModel.isModelLoaded {
            ProgressView("Loading model...")
        }

        // Display an error message.
        if let message = viewModel.errorMessage, !message.isEmpty {
            Text("Error: \(message)")
        }
    }
    .photosPicker(isPresented: $viewModel.showPhotoPicker, selection: $viewModel.selectedPhoto)
    .task {
        // Load the model asynchronously.
        if loadModel {
            await viewModel.loadModel()
        }
    }

```

#### 
- A `label` list that contains the user-readable names for each label
- A `color` list for suggested colors — as hexadecimal RGB codes — an app can use
The sample app reads the segmentation labels from the model metadata by calling the `readSegmentationLabels` method in `MLModel`. For more information about the format `Core ML` uses for metadata, see :
```swift
extension MLModel {
    /// The segmentation labels specified in the metadata.
    var segmentationLabels: [String] {
        if let metadata = modelDescription.metadata[.creatorDefinedKey] as? [String: Any],
           let params = metadata["com.apple.coreml.model.preview.params"] as? String,
           let data = params.data(using: .utf8),
           let parsed = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let labels = parsed["labels"] as? [String] {
            return labels
        } else {
            return []
        }
    }
}
```

#### 
The 8-bit DETR model takes a `CVPixelBuffer` with the type `kCVPixelFormatType_32ARGB` as the input, and generates a `ShapedArray` of `Int32` as output. For both arrays, the model uses fixed dimensions with the size `(448, 448)`. These values are specific to the model, and can be different for another model. To perform inference on the image-segmentation model, the sample app calls the `performInference` method. After inference, the sample app gets the result array from the `semanticPredictionsShapedArray` property:
```swift
// Resize the input image to the target size.
let resizedImage = await CIImage(cgImage: inputImage.cgImage!).resized(to: targetSize)

// Get the pixel buffer for the image.
let pixelBuffer = context.render(resizedImage, pixelFormat: kCVPixelFormatType_32ARGB)

// Perform inference.
let result = try model.prediction(image: pixelBuffer)

// Get the result.
let resultArray = result.semanticPredictionsShapedArray
```

#### 
Based on the selection, the sample app colors the labeled regions by calling the `renderMask` method in `ViewModel`:
Based on the selection, the sample app colors the labeled regions by calling the `renderMask` method in `ViewModel`:
```swift
func renderMask() throws -> CGImage? {
    guard let resultArray else {
        return nil
    }

    // Convert the results to a mask.
    var bitmap = resultArray.scalars.map { labelIndex in
        let label = self.labelNames[Int(labelIndex)]
        if label == selectedLabel {
            return 0xFFFFFF00 as UInt32
        } else {
            return 0x00000000 as UInt32
        }
    }

    // Convert the mask to an image.
    let width = resultArray.shape[1]
    let height = resultArray.shape[0]
    let image = bitmap.withUnsafeMutableBytes { bytes in
        let context = CGContext(
            data: bytes.baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue  // RGB0
        )
        return context?.makeImage()
    }

    return image!
}
```


