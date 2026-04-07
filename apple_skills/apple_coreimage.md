# Apple COREIMAGE Skill


## Applying a Chroma Key Effect
> https://developer.apple.com/documentation/coreimage/applying-a-chroma-key-effect

### 
#### 
The value for green in the source image falls within the slice beginning at 108° (`108/360` = `0.3`) and ending at 144° (`144/360` = `0.4`). You’ll set transparency to `0` for this range in the color cube.
To create the color cube, iterate across all values of red, green, and blue, entering a value of 0 for combinations that the filter wiill set to transparent. Refer to the numbered list for details on each step to the routine.
```swift
- (CIFilter<CIColorCube> *) chromaKeyFilterHuesFrom:(CGFloat)minHue to:(CGFloat)maxHue {
    // 1
    const unsigned int size = 64;
    const size_t cubeDataSize = size * size * size * 4;
    NSMutableData* cubeData = [[NSMutableData alloc] initWithCapacity:(cubeDataSize * sizeof(float))];
    
    // 2
    for (int z = 0; z < size; z++) {
        CGFloat blue = ((double)z)/(size-1);
        for (int y = 0; y < size; y++) {
            CGFloat green = ((double)y)/(size-1);
            for (int x = 0; x < size; x++) {
                CGFloat red = ((double)x)/(size-1);
                
                // 3
                CGFloat hue = [self hueFromRed:red green:green blue:blue];
                float alpha = (hue >= minHue && hue <= maxHue) ? 0 : 1;
                // 4
                float premultipliedRed = red * alpha;
                float premultipliedGreen = green * alpha;
                float premultipliedBlue = blue * alpha;
                [cubeData appendBytes:&premultipliedRed length:sizeof(float)];
                [cubeData appendBytes:&premultipliedGreen length:sizeof(float)];
                [cubeData appendBytes:&premultipliedBlue length:sizeof(float)];
                [cubeData appendBytes:&alpha length:sizeof(float)];
            }
        }
    }

    // 5
    CIFilter<CIColorCube> *colorCubeFilter = CIFilter.colorCubeFilter;
    colorCubeFilter.cubeDimension = size;
    colorCubeFilter.cubeData = cubeData;
    return colorCubeFilter;
}
```

> **note:**  The framework doesn’t have built-in direct conversion between color spaces, but you can access the hue of a  created with RGB values. Create a  from the raw RGB values and then read the hue from it.
```swift
- (CGFloat) hueFromRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    UIColor* color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
    CGFloat hue, saturation, brightness;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    
    return hue;
}
```

#### 
Apply the color cube filter to a foreground image by setting its `inputImage` parameter and then accessing the `outputImage`.
Apply the color cube filter to a foreground image by setting its `inputImage` parameter and then accessing the `outputImage`.
```swift
CIFilter<CIColorCube>* chromaKeyFilter = [self chromaKeyFilterHuesFrom:0.3 to:0.4];
chromaKeyFilter.inputimage = foregroundCIImage
CIImage* sourceCIImageWithoutBackground = chromaKeyFilter.outputImage;
```

#### 
Chain a  filter to the color cube filter to composite a background image to the greenscreened output. The transparency in the colorcube-filtered image allows the composited background image to show through.
```swift
CIFilter<CICompositeOperation> *compositor = CIFilter.sourceOverCompositingFilter
compositor.inputImage = sourceCIImageWithoutBackground
compositor.backgroundImage = backgroundCIImage
CIImage* compositedCIImage = compositor.outputImage;
```


## Customizing Image Transitions
> https://developer.apple.com/documentation/coreimage/customizing-image-transitions

### 
#### 
Filters in the transition category require your program to load both source and target images in order to transform the source into the destination.
```swift
NSURL* sourceURL = [[NSBundle mainBundle] URLForResource:@"YourSourceImage" withExtension:@"JPG"];
_sourceCIImage = [CIImage imageWithContentsOfURL:sourceURL];

NSURL* destinationURL = [[NSBundle mainBundle] URLForResource:@"YourTargetImage" withExtension:@"JPG"];
_finalCIImage = [CIImage imageWithContentsOfURL:destinationURL];
```

#### 
The key difference of transition filters from their normal filter chain counterparts is the dependence on time.  After creating a  from the  category, you set the value of the `time` parameter to a float between `0.0` and `1.0` to indicate how far along the transition has progressed.
Write each transition filter to accept time as an input parameter, and reapply the filter at a regular interval to transform the image from its source state to the target state.
```swift
#import <simd/simd.h>

- (CIImage*) dissolveFilterImage:(CIImage*)inputImage
                              to:(CIImage*)targetImage
                          atTime:(NSTimeInterval)time {
    NSTimeInterval t = simd_smoothstep(0, 1, time);
    CIFilter<CIDissolveTransition> *filter = CIFilter.dissolveTransitionFilter;
    filter.inputImage = inputImage;
    filter.targetImage = targetImage;
    filter.time = t;
    return filter.outputImage;
}
```

#### 
Like the dissolve transition, you can write the pixelate transition filter as a time-dependent function as well.
```swift
#import <simd/simd.h>

- (CIImage*) pixelateFilterImage:(CIImage*)inputImage atTime:(NSTimeInterval)time {
    NSTimeInterval scale = simd_smoothstep(1, 0, fabs(time));
    CIFilter<CIPixellate> *filter = CIFilter.pixellateFilter;
    filter.inputImage = inputImage;
    filter.scale = 100 * scale;
    return filter.outputImage;
}
```

#### 
2. Add to your app’s main run loop to begin the transition. Start time at `0.0` and track time through the update function.
```swift
_displayLink = [CADisplayLink displayLinkWithTarget:self 
                                           selector:@selector(stepTime)];
```

To begin the transition effect, add the  to your program’s main run loop, so it can execute each time step and redraw the transitioning .
```swift
- (void) beginTransition {
    _time = 0;
    _dt = 0.005;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(stepTime)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}
```

The  should call a time-stepping function on each pass through the run loop.  Inside this function, recompute the filtered image with that frame’s `time` variable.
```swift
- (void) stepTime {
    _time += _dt;

    // End transition after 1 second
    if (_time > 1) {
        [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else {
        _dissolvedCIImage = [self dissolveFilterImage:_sourceCIImage
                                                  to:_finalCIImage
                                              atTime:_time];
        
        _pixellatedCIImage = [self pixellateFilterImage:_dissolvedCIImage
                                                 atTime:_time];
        
        // imageView and ciContext are ivars of the class, initialized elsewhere.
        [self showCIImage:_pixellatedCIImage in:_imageView usingContext:_ciContext];
    }
}
```

```
As a convenience, the following helper function shows a CIImage in a UIImageView.
```swift
- (void) showCIImage:(CIImage*)ciImage
         inImageView:(UIImageView*)imageView
        usingContext:(CIContext*)context {
    CGImageRef cgImage = [context createCGImage:ciImage
                                       fromRect:ciImage.extent];
    
    UIImage* uiImage = [UIImage imageWithCGImage:cgImage];
    
    imageView.image = uiImage;
}
```

#### 

## Generating an animation with a Core Image Render Destination
> https://developer.apple.com/documentation/coreimage/generating-an-animation-with-a-core-image-render-destination

### 
- For view update, the `MetalView` structure conforms to the  or  protocol of the SwiftUI life cycle.
- For state changes, the Renderer is a `StateObject` conforming to the  protocol.
#### 
MetalKit calls the `draw(in:)` delegate function of the `Renderer` automatically.
For more information about drawing with MetalKit see .
MetalKit calls the `draw(in:)` delegate function of the `Renderer` automatically.
```swift
final class Renderer: NSObject, MTKViewDelegate, ObservableObject {
```

```
An image-supplying function parameterized by both timestamp and scale factor initializes the `Renderer`. This function combines checkerboard and hue-adjustment filters to generate animated checkerboard pattern images cropped to a fixed size.
```swift
// Create a Metal view with its own renderer.
let renderer = Renderer(imageProvider: { (time: CFTimeInterval, scaleFactor: CGFloat, headroom: CGFloat) -> CIImage in
    
    var image: CIImage
    
    // Animate a shifting red and yellow checkerboard pattern.
    let pointsShiftPerSecond = 25.0
    let checkerFilter = CIFilter.checkerboardGenerator()
    checkerFilter.width = 20.0 * Float(scaleFactor)
    checkerFilter.color0 = CIColor.red
    checkerFilter.color1 = CIColor.yellow
    checkerFilter.center = CGPoint(x: time * pointsShiftPerSecond, y: time * pointsShiftPerSecond)
    image = checkerFilter.outputImage ?? CIImage.empty()
    
    // Animate the hue of the image with time.
    let colorFilter = CIFilter.hueAdjust()
    colorFilter.inputImage = image
    colorFilter.angle = Float(time)
    image = colorFilter.outputImage ?? CIImage.empty()
```

After the sample initializes the `Renderer`, the `Renderer` makes a command buffer and gets the .
```
After the sample initializes the `Renderer`, the `Renderer` makes a command buffer and gets the .
```swift
if let commandBuffer = commandQueue.makeCommandBuffer() {
    
    // Add a completion handler that signals `inFlightSemaphore` when Metal and the GPU have fully
    // finished processing the commands that the app encoded for this frame.
    // This completion indicates that Metal and the GPU no longer need the dynamic buffers that
    // Core Image writes to in this frame.
    // Therefore, the CPU can overwrite the buffer contents without corrupting any rendering operations.
    let semaphore = inFlightSemaphore
    commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
        semaphore.signal()
    }
    
    if let drawable = view.currentDrawable {
```

```
The `Renderer` then configures a  with the command buffer, `currentDrawable`, dimensions, and pixel format, along with a closure that returns the  for the `currentDrawable`.
```swift
// Create a destination the Core Image context uses to render to the drawable's Metal texture.
let destination = CIRenderDestination(width: Int(dSize.width),
                                      height: Int(dSize.height),
                                      pixelFormat: view.colorPixelFormat,
                                      commandBuffer: commandBuffer,
                                      mtlTextureProvider: { () -> MTLTexture in
    // Core Image calls the texture provider block lazily when starting a task to render to the destination.
    return drawable.texture
})
```

The sample uses the render destination to create an animation frame at a specific timestamp.
Finally, the sample composites the render destination’s centered image on a background and submits work to the GPU to render and present the result.
```swift
// Create a displayable image for the current time.
let time = CFTimeInterval(CFAbsoluteTimeGetCurrent() - self.startTime)
var image = self.imageProvider(time, contentScaleFactor, headroom)

// Center the image in the view's visible area.
let iRect = image.extent
let backBounds = CGRect(x: 0, y: 0, width: dSize.width, height: dSize.height)
let shiftX = round((backBounds.size.width + iRect.origin.x - iRect.size.width) * 0.5)
let shiftY = round((backBounds.size.height + iRect.origin.y - iRect.size.height) * 0.5)
image = image.transformed(by: CGAffineTransform(translationX: shiftX, y: shiftY))

// Blend the image over an opaque background image.
// This is needed if the image is smaller than the view, or if it has transparent pixels.
image = image.composited(over: self.opaqueBackground)

// Start a task that renders to the texture destination.
_ = try? self.cicontext.startTask(toRender: image, from: backBounds,
                                  to: destination, at: CGPoint.zero)

// Insert a command to present the drawable when the buffer has been scheduled for execution.
commandBuffer.present(drawable)

// Commit the command buffer so that the GPU executes the work that the Core Image Render Task issues.
commandBuffer.commit()
```

#### 
2. Query the EDR headroom for each frame and pass `headroom` to the image provider closure for the `Renderer`.
#### 
The `MetalView` opts into EDR support setting  to true on the backing . When enabled, the layer uses a wide gamut  to render colors beyond SDR range. Similarly, the  sets a wide gamut  to render the generated EDR image.
```swift
if let layer = view.layer as? CAMetalLayer {
    // Enable EDR with a color space that supports values greater than SDR.
    if #available(iOS 16.0, *) {
        layer.wantsExtendedDynamicRangeContent = true
    }
    layer.colorspace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)
    // Ensure the render view supports pixel values in EDR.
    view.colorPixelFormat = MTLPixelFormat.rgba16Float
}
```

#### 
The `Renderer` queries the current EDR headroom for each draw call using either  () or  (). If EDR headroom is unavailable the sample sets `headroom` to `1.0` clamping to SDR.
```swift
                // Determine EDR headroom and fallback to SDR, as needed.
                // Note: The headroom must be determined every frame to include changes in environmental lighting conditions.
                let screen = view.window?.screen
#if os(iOS)
                var headroom = CGFloat(1.0)
                if #available(iOS 16.0, *) {
                    headroom = screen?.currentEDRHeadroom ?? 1.0
                }
#else
                let headroom = screen?.maximumExtendedDynamicRangeColorComponentValue ?? 1.0
#endif
```

#### 
The sample’s ripple effect takes a gradient  to shade the contor of the ripple so that it appears to reflect light from the upper-left corner.  generates the gradient shading image between the current maximum RGB white, , and a fully transparent clear color, .
```swift
// Compute a shading image for the ripple effect below.
// Cast light on the upper-left corner of the shading gradient image.
let angle = 135.0 * (.pi / 180.0)
let gradient = CIFilter.linearGradient()
// Create a bright white color for a specular highlight with the current
// maximum possible pixel component values within headroom
// or a reasonable alternative.
let maxRGB = min(headroom, 8.0)
gradient.color0 = CIColor(red: maxRGB, green: maxRGB, blue: maxRGB,
                          colorSpace: CGColorSpace(name: CGColorSpace.extendedLinearSRGB)!)!
gradient.color1 = CIColor.clear
gradient.point0 = CGPoint(x: sin(angle) * 90.0 + 100.0,
                          y: cos(angle) * 90.0 + 100.0)
gradient.point1 = CGPoint(x: sin(angle) * 85.0 + 100.0,
                          y: cos(angle) * 85.0 + 100.0)
let shading = gradient.outputImage?.cropped(to: CGRect(x: 0, y: 0,
                                                       width: 200, height: 200))

// Add a shiny ripple effect to the image.
let ripple = CIFilter.rippleTransition()
ripple.inputImage = image
ripple.targetImage = image
ripple.center = CGPoint(x: 256.0 * scaleFactor,
                        y: 192.0 * scaleFactor)
ripple.time = Float(fmod(time * 0.25, 1.0))
ripple.shadingImage = shading
image = ripple.outputImage ?? CIImage()

return image.cropped(to: CGRect(x: 0, y: 0,
                                width: 512.0 * scaleFactor,
                                height: 384.0 * scaleFactor))
```


## Processing an Image Using Built-in Filters
> https://developer.apple.com/documentation/coreimage/processing-an-image-using-built-in-filters

### 
#### 
 processing occurs in a  object. Creating a  is expensive, so create one during your initial setup and reuse it throughout your app.
```swift
CIContext* context = [CIContext context];
```

#### 
The next step is to load an image to process. This example loads an image from the project bundle.
```swift
NSURL* imageURL = [[NSBundle mainBundle] URLForResource:@"YourImageName" withExtension:@"png"];
CIImage* originalCIImage = [CIImage imageWithContentsOfURL:imageURL];
self.imageView.image = [UIImage imageWithCIImage:originalCIImage];
```

#### 
Although you can chain filters without separating them into functions, the following example shows how to configure a single , the  filter.
```swift
- (CIImage*) sepiaFilterImage: (CIImage*)inputImage withIntensity:(CGFloat)intensity {
    CIFilter<CISepiaTone>* sepiaFilter = CIFilter.sepiaToneFilter;
    sepiaFilter.inputImage = inputImage;
    sepiaFilter.intensity = intensity;
    return sepiaFilter.outputImage;
}
```

```
To pass the image through the filter, call the sepia filter function.
```swift
CIImage* sepiaCIImage = [self sepiaFilterImage:originalCIImage withIntensity:0.9];
```

```
You can check the intermediate result at any point in the filter chain by converting from  to a . You can then assign this  to a  for display.
```swift
_imageView.image = [UIImage imageWithCIImage:sepiaCIImage];
```

The bloom filter accentuates the highlights of an image. You can apply it as part of a chain without factoring it into a separate function, but this example encapsulates its functionality into a function.
```swift
- (CIImage*) bloomFilterImage: (CIImage*)inputImage withIntensity:(CGFloat)intensity radius:(CGFloat)radius {
    CIFilter<CIBloom>* bloomFilter = CIFilter.bloomFilter;
    bloomFilter.inputImage = inputImage;
    bloomFilter.intensity = intensity;
    bloomFilter.radius = radius;
    return bloomFilter.outputImage;
}
```

To display the output, convert the  to a .
```swift
CIImage* bloomCIImage = [self bloomFilterImage:sepiaCIImage withIntensity:1 radius:10];
_filteredImageView.image = [UIImage imageWithCIImage:bloomCIImage];
```

Apply the  to obtain a high-quality downsampling of the image, preserving the original image’s aspect ratio through the  filter’s parameter `aspectRatio`. For built-in Core Image filters, calculate the aspect ratio as the image’s width over height.
```swift
CGFloat imageWidth = originalUIImage.size.width;
CGFloat imageHeight = originalUIImage.size.height;
CGFloat aspectRatio = imageHeight / imageWidth;
CIImage* scaledCIImage = [self scaleFilterImage:bloomCIImage withAspectRatio:aspectRatio scale:0.05];
```

```
Like other built-in filters, the  filter also outputs its result as a .
```swift
- (CIImage*) scaleFilterImage: (CIImage*)inputImage withAspectRatio:(CGFloat)aspectRatio scale:(CGFloat)scale {
    CIFilter<CILanczosScaleTransform>* scaleFilter = CIFilter.lanczosScaleTransformFilter;
    scaleFilter.inputImage = inputImage;
    scaleFilter.scale = scale;
    scaleFilter.aspectRatio = aspectRatio;
    return scaleFilter.outputImage;
}
```

> **important:**  To optimize computation, Core Image doesn’t actually render any intermediate  result until you force the  to display its content onscreen, as you might do using .
```swift
_imageView.image = [UIImage imageWithCIImage:scaledCIImage];
```


## Selectively Focusing on an Image
> https://developer.apple.com/documentation/coreimage/selectively-focusing-on-an-image

### 
#### 
The linear gradients cause the blur to taper smoothly as it approaches the focused stripe of the image. The Core Image  named  generates filters of the desired color. The linear gradient has four parameters:
Compute the start and stop points of the gradient as fractions of the image height, as obtained through . For this particular mask and example image, focus on the area near the middle, in the second quarter of the image. Set the linear gradient’s `point0` and `point1` to reflect the region through which the gradient tapers.
```swift
const CGFloat h = inputImage.extent.size.height;
CIFilter<CILinearGradient>* topGradient = CIFilter.linearGradientFilter;
topGradient.point0 = CGPointMake(0, 0.85 * h);
topGradient.color0 = CIColor.greenColor;
topGradient.point1 = CGPointMake(0, 0.6 * h);
topGradient.color1 = [CIColor colorWithRed:0 green:1 blue:0];
```

```
The lower gradient should complement the upper gradient, so that their combined coverage delineates the entire area to blur. Express the starting `inputPoint0` y-value at `0.35` of the image height and taper to `0.6`, where the top gradient began. This leaves a gap in the combined mask through which the sharp image will show.
```swift
CIFilter<CILinearGradient>* bottomGradient = CIFilter.linearGradientFilter;
bottomGradient.point0 = CGPointMake(0, 0.35 * h);
bottomGradient.color0 = CIColor.greenColor;
bottomGradient.point1 = CGPointMake(0, 0.6 * h);
bottomGradient.color1 = [CIColor colorWithRed:0 green:1 blue:0 alpha:0];
```

#### 
Since the gradients themselves are  objects, compositing them is as simple as concatenating their filter outputs to a compositing filter.  Use the built-in  named  to composite two images additively.
```swift
CIFilter<CICompositeOperation> *gradientMask = CIFilter.additionCompositingFilter
gradientMask.inputImage = topGradient.outputImage;
gradientMask.backgroundImage = bottomGradient.outputImage;
```

#### 
1. Set the `center` to a  pointing to the center of the region you want to leave unblurred.
3. Set the `radius1` to a larger fraction of the image’s dimension, like `0.3*h` in this example. Tweaking this parameter changes the extent of the blur’s tapering effect; a larger value makes the blur more gradual, whereas a smaller value makes the image transition more abruptly from sharp (at `inputRadius0`) to blur (at `inputRadius1`).
4. As with the linear gradients, set `color0` to transparency, and `color1` to a solid opaque color, to indicate the blur’s gradation from nonexistent to full.
```swift
CIFilter<CIRadialGradient> *radialMask = CIFilter.radialGradientFilter;
radialMask.center = CGPointMake(0.55 * w, 0.6 * h);
radialMask.radius0 = 0.2 * h;
radialMask.radius1 = 0.3 * h;
radialMask.color0 = [CIColor colorWithRed:0 green:1 blue:0 alpha:0];
radialMask.color1 = [CIColor colorWithRed:0 green:1 blue:0 alpha:1];
```

#### 
The final step is applying your choice of mask with the input image. The  built-in  accomplishes this task with the following input parameters:
```swift
CIFilter<CIMaskedVariableBlur> *maskedVariableBlur = CIFilter.maskedVariableBlurFilter;
maskedVariableBlur.inputImage = inputImage;
maskedVariableBlur.mask = radialMask.outputImage;
maskedVariableBlur.radius = 10;
CIImage *selectivelyFocusedCIImage = maskedVariableBlur.outputImage;
```


## Simulating Scratchy Analog Film
> https://developer.apple.com/documentation/coreimage/simulating-scratchy-analog-film

### 
#### 
Tint the original image by applying the  filter.
```swift
CIFilter<CISepiaTone> *sepiaFilter = CIFilter.sepiaToneFilter;
sepiaFilter.inputImage = inputImage;
sepiaFilter.intensity = 1.0;
CIImage *sepiaCIImage = sepiaFilter.outputImage;
```

#### 
The filter takes no inputs.
```swift
CIFilter<CIRandomGenerator> *colorNoise = CIFilter.randomGeneratorFilter;
CIImage* noiseImage = colorNoise.outputImage;
```

```
Next, apply a whitening effect by chaining the noise output to a  filter. This built-in filter multiplies the noise color values individually and applies a bias to each component. For white grain, apply whitening to the y-component of RGB and no bias.
```swift
CIVector *whitenVector = [CIVector vectorWithX:0 Y:1 Z:0 W:0];
CIVector *fineGrain = [CIVector vectorWithX:0 Y:0.005 Z:0 W:0];
CIVector *zeroVector = [CIVector vectorWithX:0 Y:0 Z:0 W: 0];
CIFilter<CIColorMatrix> *whiteningFilter = CIFilter.colorMatrixFilter;
whiteningFilter.inputImage = noiseImage;
whiteningFilter.RVector = whitenVector;
whiteningFilter.RVector = whitenVector;
whiteningFilter.BVector = whitenVector;
whiteningFilter.AVector = fineGrain;
whiteningFilter.biasVector = zeroVector;
CIImage *whiteSpecks = whiteningFilter.outputImage;
```

The `whiteSpecks` resulting from this filter have the appearance of spotty grain when viewed as an image.
Create the grainy image by compositing the whitened noise as input over the sepia-toned source image using the  filter.
```swift
CIFilter<CICompositeOperation> *speckCompositor = CIFilter.sourceOverCompositingFilter;
speckCompositor.inputImage = whiteSpecks;
speckCompositor.backgroundImage = sepiaCIImage;
CIImage *speckledImage = speckCompositor.outputImage;
```

#### 
The process for applying random-looking scratches is the same as the technique used in the white grain: color the output of the  filter.
To make the speckle resemble scratches, scale the random noise output vertically by applying a scaling .
```swift
CGAffineTransform verticalScale = CGAffineTransformMakeScale(1.5, 25);
CIImage* transformedNoise = [noiseImage imageByApplyingTransform:verticalScale];
```

```
Previously, you whitened the speckle image by applying the `CIColorMatrix` filter evenly across all color components.  For the dark scratches, instead focus on only the red component, setting the other vector inputs to zero.  This time, instead of multiplying the green, blue, and alpha channels, add bias `(0, 1, 1, 1)`.
```swift
CIFilter<CIColorMatrix>* darkeningFilter = CIFilter.colorMatrixFilter;
CIVector* darkenVector = [CIVector vectorWithX:4 Y:0 Z:0 W:0];
CIVector* darkenBias = [CIVector vectorWithX:0 Y:1 Z:1 W:1];
darkeningFilter.inputImage = noiseImage;
darkeningFilter.RVector = darkenVector;
darkeningFilter.GVector = zeroVector;
darkeningFilter.BVector = zeroVector;
darkeningFilter.AVector = zeroVector;
darkeningFilter.biasVector = darkenBias;
CIImage* randomScratches = darkeningFilter.outputImage;
```

```
The resulting scratches are cyan, so grayscale them using the  filter, which takes the minimum of the RGB values to produce a grayscale image.
```swift
CIFilter<CIMinimumComponent> *grayscaleFilter = CIFilter.minimumComponentFilter;
grayscaleFilter.inputImage = randomScratches;
CIImage *darkScratches = grayscaleFilter.outputImage;
```

#### 
Now that the components are set, you can add the scratches to the grainy sepia image produced earlier.  However, unlike the grainy texture, the scratches impact the image multiplicatively.  Instead of the  filter, which composites source over background, use the  filter to compose the scratches multiplicatively.  Set the scratched image as the filter’s input image, and tab the speckle-composited sepia image as the input background image.
```swift
CIFilter<CICompositeOperation> *oldFilmCompositor = CIFilter.multiplyCompositingFilter;
oldFilmCompositor.inputImage = darkScratches;
oldFilmCompositor.backgroundImage = speckledImage;
CIImage *oldFilmImage = oldFilmCompositor.outputImage;
```

```
Since the noise images had different dimensions than the source image, crop the composited result to the original image size to remove excess beyond the original extent.
```swift
CIImage* finalImage = [oldFilmImage imageByCroppingToRect:inputImage.extent];
```


