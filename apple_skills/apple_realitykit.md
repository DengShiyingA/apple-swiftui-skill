# Apple REALITYKIT Skill


## Animating entity rotation with a system
> https://developer.apple.com/documentation/realitykit/animated-rotation-with-a-system

### 
#### 
After creating the entity in `ContentView` the sample adds an instance of the `RotationComponent` to the entity:
After creating the entity in `ContentView` the sample adds an instance of the `RotationComponent` to the entity:
```swift
telescopeScene.components[RotationComponent.self] = RotationComponent()
```

By default, the rotation speed is `0.0` and the axis of rotation is the x-axis.
#### 
The `ContentView` type has two `@State` variables that control the animation:
The `ContentView` type has two `@State` variables that control the animation:
```swift
@State var axis: RotationAxis = .x
@State var rotating: Bool = false
```

- `RotationAxis` is an enumeration with one case for each ordinal direction.
- The `rotating` value sets the `speed` to `0.0` when `rotating` is `false`, and `1.0` when `rotating` is `true`.
#### 
The system calls the `RealityView` `update:` block when the `rotating` or `speed` values change.
The system calls the `RealityView` `update:` block when the `rotating` or `speed` values change.
```swift
update: { context in
  telescope?.components[RotationComponent.self]?.rotationAxis = axis
  telescope?.components[RotationComponent.self]?.speed = rotating ? 1.0 : 0.0
}
```

#### 
The framework calls the `RotationSystem` function  for each frame. The sample includes a query to quickly find entities that have the component:
The framework calls the `RotationSystem` function  for each frame. The sample includes a query to quickly find entities that have the component:
```swift
static let rotationQuery = EntityQuery(where: .has(RotationComponent.self))
```

```
This function uses `rotationQuery` to find relevant entities. The function then sets the orientation of the entities based on the values in the attached component:
```swift
for entity in context.entities(matching: Self.rotationQuery, updatingSystemWhen: .rendering) {
  guard let component: RotationComponent = entity.components[RotationComponent.self] else { continue }
  if component.speed == 0 { continue }
  entity.setOrientation(simd_quatf(angle: component.speed * Float(context.deltaTime),
                                   axis: component.axis),
                        relativeTo: entity)
}
```

While the component’s `speed` value isn’t zero, the system animates the entity’s rotation around `axis`.

## Applying core image filters as a postprocess effect
> https://developer.apple.com/documentation/realitykit/applying-core-image-filters-as-a-postprocess-effect

### 
#### 
If you set the callback at launch, RealityKit calls it before it draws the first frame. This is a good place to do setup tasks, especially processor-intensive or time-consuming tasks, such as loading images, or tasks that require access to the , which RealityKit passes to the callback function.
To create a  callback, write a function that takes a single  parameter and has no return value. In that function, create and store a  and do any other necessary setup tasks, such as loading textures needed by the filter.
```swift
func setupCoreImage(device: MTLDevice) {
    // Create a CIContext and store it in a property.
    ciContext = CIContext(mtlDevice: device)

    // Do other expensive tasks, like loading images, here.
}
```

```
Next, register the function as a callback by assigning it to the  property of the view’s  property.
```swift
arView.renderCallbacks.prepareWithDevice = setupCoreImage
```

#### 
#### 
Next, create the render callback function. Once you register it, RealityKit calls it every frame before displaying the rendered scene. In the callback, configure your , convert the source color texture — which contains the frame buffer — into a , and set it as the filter’s image input. Then, create a , and render the filter to it.
```swift
func postProcessWithCoreImage(context: ARView.PostProcessContext) {

    // Create and configure the Core Image filter.
    let filter = CIFilter.falseColor()
    filter.color0 = CIColor.blue
    filter.color1 = CIColor.yellow

    // Convert the frame buffer from a Metal texture to a CIImage, and 
    // set the CIImage as the filter's input image.
    guard let input = CIImage(mtlTexture: context.sourceColorTexture) else {
        fatalError("Unable to create a CIImage from sourceColorTexture.")
    }
    filter.setValue(input, forKey: kCIInputImageKey)

    // Get a reference to the filter's output image.
    guard let output = filter.outputImage else {
        fatalError("Error applying filter.")
    }

    // Create a render destination and render the filter to the context's command buffer.
    let destination = CIRenderDestination(mtlTexture: context.compatibleTargetTexture,
                                          commandBuffer: context.commandBuffer)
    destination.isFlipped = false
    _ = try? self.ciContext.startTask(toRender: output, to: destination)
}
```

#### 
To apply the effect, register the function as the  render callback for the .
```swift
arView.renderCallbacks.postProcess = postProcessWithCoreImage
```


## Applying realistic material and lighting effects to entities
> https://developer.apple.com/documentation/realitykit/applying-realistic-material-and-lighting-effects-to-entities

### 
#### 
This example demonstrates how to create a PBR material that uses a color and a single `roughness` and `metallic` value for the entire material:
This example demonstrates how to create a PBR material that uses a color and a single `roughness` and `metallic` value for the entire material:
```swift
var material = PhysicallyBasedMaterial()
material.baseColor.tint = .orange
material.roughness = PhysicallyBasedMaterial.Roughness(
    floatLiteral: 0.0
)
material.metallic = PhysicallyBasedMaterial.Metallic(
    floatLiteral: 1.0
)
```

```
And the following example shows how to create a PBR material using UV-mapped image textures for all three properties:
```swift
var material = PhysicallyBasedMaterial()

if let baseResource = try? TextureResource.load(named: "entity_basecolor") {
    let baseTexture = MaterialParameters.Texture(baseResource)
    material.baseColor = PhysicallyBasedMaterial.BaseColor(
        texture: baseTexture
    )
}

if let metalResource = try? TextureResource.load(named: "entity_metallic") {
    let metalTexture = MaterialParameters.Texture(metalResource)
    material.metallic = PhysicallyBasedMaterial.Metallic(
        texture: metalTexture
    )
}

if let roughnessResource = try? TextureResource.load(named: "entity_roughness") {
    let roughnessTexture = MaterialParameters.Texture(roughnessResource)
    material.roughness = PhysicallyBasedMaterial.Roughness(
        texture: roughnessTexture
    )
}
```

#### 
RealityKit’s `PhysicallyBasedMaterial` supports normal maps using the  property.
To add a `normal` map to your entity, load it as a texture resource, and use the resource to create a `PhysicallyBasedMaterial.Normal` instance, as in this example:
```swift
if let normalResource = try? TextureResource.load(named: "entity_normals") {
    let normalTexture = MaterialParameters.Texture(normalResource)
    material.normal = PhysicallyBasedMaterial.Normal(
        texture: normalTexture
    )
}
```

#### 
By default, RealityKit materials are opaque, but RealityKit can render entities with transparency to simulate real-world objects. To render a material with transparency, change the  value from `.opaque` to `.transparent`. The `.transparent` enumeration case takes an associated value that controls the amount of transparency.
To specify opacity, create a `PhysicallyBasedMaterial.Opacity` object. You can specify opacity for the entire entity using a single value between `0.0` and `1.0`, where `1.0` is fully opaque and `0.0` is fully transparent.
```swift
material.blending = .transparent(
    opacity: PhysicallyBasedMaterial.Opacity(floatLiteral: 0.5)
)
```

```
You can also specify opacity using an image texture (sometimes called an  or ). In an alpha map, black pixels represent fully transparent parts of the entity, white pixels represent fully opaque parts of the entity, and gray pixels represent parts of the entity that are partially transparent.
```swift
if let opacityResource = try? TextureResource.load(named: "entity_opacity") {
    let opacityMap = MaterialParameters.Texture(opacityResource)
    let opacityValue = PhysicallyBasedMaterial.Opacity(texture: opacityMap)
    material.blending = .transparent(opacity: opacityValue)
}
```

#### 
Use the  property to simulate the bright highlights found on certain  (nonmetallic) materials like cut gemstones and faceted glass, which have specular highlights much brighter than the ones RealityKit creates from just the core properties.
Here’s how to specify specular using a single value for the entire material:
```swift
material.specular = PhysicallyBasedMaterial.Specular(
    floatLiteral: 0.8
)
```

```
The following example demonstrates how to specify specular using a UV-mapped image texture:
```swift
if let specularResource = try? TextureResource.load(named: "entity_specular") {
    let specularTexture = MaterialParameters.Texture(specularResource)
    material.specular = PhysicallyBasedMaterial.Specular(
        texture: specularTexture
    )
}
```

This example shows how to specify  using a single value for the entire material:
```swift
let sheenTint = PhysicallyBasedMaterial.Color(
    red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0
)
material.sheen = PhysicallyBasedMaterial.SheenColor(
    tint: sheenTint
)
```

```
And this example demonstrates how to specify  using a UV-mapped image texture:
```swift
if let sheenResource = try? TextureResource.load(named: "entity_sheen") {
    let sheenMap = MaterialParameters.Texture(sheenResource)
    material.sheen = PhysicallyBasedMaterial.SheenColor(
        texture: sheenMap
    )
}
```

#### 
In RealityKit, you adjust anisotropy using two parameters:  and . To control the amount of anisotropy, use . Specifying a value of `0.0` results in an entirely isotropic appearance, while nonzero values up to `1.0` simulate the appearance of increasingly anisotropic objects. Change the angle of anisotropy to affect the direction in which the specular highlights stretch with , which also takes a value between `0.0 `and `1.0.` `A` value of `0.0` means a rotation of 0° and a value of `1.0` indicates a rotation of 360°. To determine the  value to use, divide the desired angle in degrees by `360.0` or the desired angle in radians by pi times 2.
```swift
let angleDegrees: Float = 125
let anisotropyAngleFromDegrees = angleDegrees / 360

let angleRadians: Float = 2.181662
let anisotropyAngleFromRadians = angleRadians / (2 * .pi)
```

```
The following example demonstrates how to specify anisotropy using single values for the entire material:
```swift
material.anisotropyLevel = PhysicallyBasedMaterial.AnisotropyLevel(
    floatLiteral: 0.5
)
material.anisotropyAngle = PhysicallyBasedMaterial.AnisotropyAngle(
    floatLiteral: 0.5
)
```

```
And this example shows how to specify anisotropy using a UV-mapped image texture for  and a separate image for :
```swift
if let anisoLevelResource = try? TextureResource.load(named: "entity_aniso_level") {
    let anisoLevelMap = MaterialParameters.Texture(anisoLevelResource)
    material.anisotropyLevel = PhysicallyBasedMaterial.AnisotropyLevel(
        texture: anisoLevelMap
    )
}

if let anisoAngleResource = try? TextureResource.load(named: "entity_aniso_angle") {
    let anisoAngleMap = MaterialParameters.Texture(anisoAngleResource)
    material.anisotropyAngle = PhysicallyBasedMaterial.AnisotropyAngle(
        texture: anisoAngleMap
    )
}
```


## Bringing your SceneKit projects to RealityKit
> https://developer.apple.com/documentation/realitykit/bringing-your-scenekit-projects-to-realitykit

### 
### 
### 
#### 
#### 
At its core is the `CharacterMovementComponent`, which stores motion data and input state:
The `CharacterMovement` package provides a flexible system for controlling character movement in 3D space, supporting multiple input methods across different platforms. This package simplifies one of the most complex aspects of migrating from SceneKit: implementing responsive character controls.
At its core is the `CharacterMovementComponent`, which stores motion data and input state:
```swift
// Create a basic movement component for a character.
var moveComponent = CharacterMovementComponent(characterProxy: "Max")

// Add the component to your character entity.
character.components.set(moveComponent)
```

```
The component handles multiple input sources simultaneously, combining them for smooth control:
```swift
// Example: Processing touch input from a virtual thumbstick.
ThumbStickView(updatingValue: $movementThumbstick)
    .onChange(of: movementThumbstick) { _, newValue in
        // Convert 2D input to 3D movement direction.
        let movementVector: SIMD3<Float> = [Float(newValue.x), 0, Float(newValue.y)] / 5
        character.components[CharacterMovementComponent.self]?.controllerDirection = movementVector
    }

// Example: Processing keyboard input.
func processKeyboardInput(wasd: SIMD2<Float>) {
    // Convert WASD input to 3D movement direction.
    character.components[CharacterMovementComponent.self]?.wasdDirection = [wasd.x, 0, wasd.y]
}
```

```
The package also handles character state management, transitioning between animations based on movement:
```swift
// Define animations for different character states.
var animations = [CharacterStateComponent.CharacterState: AnimationResource]()
animations[.idle] = idleAnimation.repeat()
animations[.walking] = walkAnimation.repeat()
animations[.jump] = jumpAnimation.combineWithAudio(named: "jump")

// Create and add the state component to your character.
let stateComponent = CharacterStateComponent(animations: animations)
character.components.set(stateComponent)

// Trigger actions through the movement component.
character.components[CharacterMovementComponent.self]?.jumpPressed = true
```

#### 
The `WorldCameraComponent` manages spherical coordinate positioning around a target:
The `WorldCamera` package provides a component-based solution for positioning a camera around an entity of interest in 3D space, particularly useful for third-person games, while accounting for platform differences.
The `WorldCameraComponent` manages spherical coordinate positioning around a target:
```swift
// Create a simple world camera component to follow a character.
var worldCameraComponent = WorldCameraComponent(
    azimuth: .pi,    // Position behind the character.
    elevation: 0.2,  // Slightly above the character.
    radius: 3        // Position 3 meters away from the character.
)
```

```
To avoid jarring behaviors, the system can also implement soft camera movements by having the camera follow a target. The `WorldCamera` package provides a `FollowComponent` to perform smooth transitions as the target moves:
```swift
// Apply a softer movement in the y-axis, avoiding sharp movements when the character jumps.
let followSmoothing: SIMD3<Float> = [3, 1.2, 3]

// Create a camera entity with both components.
let worldCamera = Entity(components:
    worldCameraComponent,
    FollowComponent(targetId: target.id, smoothing: )
)

#if !os(visionOS)
// Add the actual camera component for rendering on non-visionOS platforms.
worldCamera.addChild(Entity(components: PerspectiveCameraComponent()))
#endif
```

#### 
The `AgentComponent` package adds autonomous behavior to enemy entities, allowing them to chase or flee from the player character.
The `AgentComponent` package adds autonomous behavior to enemy entities, allowing them to chase or flee from the player character.
This example defines a patrol area for an enemy:
```swift
let wanderPathPoints: [SIMD3<Float>] = [
    [-1, -0.25, 13], [ 1, -0.25, 13],
    [-1, -0.25, 12], [ 1, -0.25, 12],
    [-1, -0.25, 11], [ 1, -0.25, 11],
    [-1, -0.25, 10], [ 1, -0.25, 10]
]
let stayOnPath = GKPath(points: wanderPathPoints, radius: 0.75, cyclical: true)
let centerGoal = GKGoal(toStayOn: stayOnPath, maxPredictionTime: 1)
let chasingType: AgentComponent.AgentType = .chasing(id: hero.id, distance: 3, speed: 3)
```

Next, the app creates an `AgentComponent` with behavior parameters and applies it to the entity:
```
Next, the app creates an `AgentComponent` with behavior parameters and applies it to the entity:
```swift
let chasingComponent = AgentComponent(
    agentType: chasingType,
    wanderSpeed: 3, wanderGoal: GKGoal(toWander: 1),
    centerGoal: centerGoal,
    constraints: .position(y: .exact(-0.25))
)
chasing.components.set(chasingComponent)
```

### 
You can invoke `scntool` by typing `xcrun scntool` into a terminal window:
To convert an SCN asset to USDZ, you can use:
```sh
xcrun scntool --convert max.scn --format usdz
```

```
If you have a separate SCN file, which contains animation data, you can append this too:
```sh
xcrun scntool --convert max.scn --format usdz --append-animation max_spin.scn
```

### 
Portrait mode provides a grounded experience where users can still see their physical surroundings while engaging with immersive content, perfect for games like platformers.
Pyro Panda uses the new portrait aspect ratio for immersive spaces by first declaring a  with the aspect ratio :
```swift
var immersionStyle: ProgressiveImmersionStyle {
    .progressive(
        0.1...0.5,
        initialAmount: 0.15,
        aspectRatio: .portrait
    )
}
```

The app assigns this immersion style to the `ImmersiveWindow`, to apply the portrait styling:
```
The app assigns this immersion style to the `ImmersiveWindow`, to apply the portrait styling:
```swift
ImmersiveSpace(id: appModel.immersiveSpaceID) {
    // ...
}.immersionStyle(
    selection: .constant(self.immersionStyle),
    in: self.immersionStyle
)
```

### 
RealityKit is built for modern hardware, with capabilities that may exceed what older devices can handle. The sample shows you how to gracefully handle hardware compatibility:
```swift
var supportsFullGame: Bool {
    // Check if the device supports Apple GPU Family 2 or later.
    return MTLCreateSystemDefaultDevice()?.supportsFamily(.apple2) ?? false
}
```

```
With this simple check, the app provides an appropriate experience based on hardware capabilities:
```swift
if supportsFullGame {
    RealityView { content in
        // Full game experience.
    }
} else {
    // Fallback experience.
    gameNotSupportedUI()
}
```


## Checking the pixel format of a postprocess effect’s output texture
> https://developer.apple.com/documentation/realitykit/checking-the-pixel-format-of-a-postprocess-effect-s-output-texture

### 
Some device GPUs require that the output texture for postprocess effects be in a specific format. If the current device doesn’t support , convert the output texture to  before encoding the processed framebuffer to it. An easy way to do that, is to add a derived property to  using an extension:
```swift
extension RealityKit.ARView.PostProcessContext {
    // Returns the output texture, ensuring that the pixel format is 
    // appropriate for the current device's GPU.
    var compatibleTargetTexture: MTLTexture! {
        if self.device.supportsFamily(.apple2) {
            return targetColorTexture
        } else {
            return targetColorTexture.makeTextureView(pixelFormat: .bgra8Unorm)!
        }
    }
}
```


## Combining 2D and 3D views in an immersive app
> https://developer.apple.com/documentation/realitykit/combining-2d-and-3d-views-in-an-immersive-app

### 
- The red arch is a reality view attachment containing a `UIView` in a `UIViewRepresentable` with a custom 2D arc shape.
- The blue arch is a reality view attachment containing a SwiftUI `View` with a custom 2D arc shape.
The cloud attachments at the locations of tap gestures are `RealityViewAttachments` containing  with an SF Symbols image.
#### 
This sample creates 3D assets in an asset creator and imports them into Reality Composer Pro as `.usdc` files.
This sample creates 3D assets in an asset creator and imports them into Reality Composer Pro as `.usdc` files.
The app then configures the appearance of the  by setting the material of the , which is the  that affects appearance. The following code example demonstrates loading a model and configuring the material:
```swift
/// Creates an entity from the data model for each Reality Composer Pro asset.
func createEntity(for item: EntityData) async -> Entity {
    
    // Load the entity from Reality Composer Pro.
    let realityComposerEntity = try! await Entity(named: item.title, in: realityKitContentBundle)
    
    // Find the model component entity and model component.
    guard
        let modelEntity = realityComposerEntity.findEntity(named: item.title),
        var modelComponent = modelEntity.components[ModelComponent.self]
    else {
        return Entity()
    }
    
    // Set the material if it has a simple material.
    if let material = item.simpleMaterial {
        modelComponent.materials = [material]
    }
    
    // Set the model component.
    modelEntity.components.set(modelComponent)
    
    return modelEntity
}
```

#### 
The sample includes the remaining four arches as reality view attachments by creating attachments of various types in the `attachments` closure of a reality view instance. These types include both SwiftUI and UIKit to exemplify how to use any framework in your visionOS app.
```swift
// Iterate over the attachments array and create the various arches.
ForEach(rainbowModel.archAttachments) { entity in
    // Create an attachment with an ID that the `update` closure references.
    Attachment(id: "\(entity.title.rawValue)ArchAttachmentEntity") {
        createArchAttachment(for: entity.title)
    }
}
```

}
```
```swift
/// Creates the arch view for each attachment based on the color.
@ViewBuilder func createArchAttachment(for arch: ArchAttachmentColor) -> some View {
        switch arch {
        case .blue:
            SwiftUIArcView(color: .blue)
        case .orange:
            UIViewArcViewRep(color: .orange)
        case .pink:
            SwiftUIArcView(color: .pink)
        case .red:
            CALayerArcViewRep(color: .red)
    }
}
```

Attachments can contain views from other frameworks that adopt the `UIViewRepresentable` protocol.
#### 
The sample loads the attachments as reality view attachments in the `update` closure of the reality view. If there’s an existing attachment for an `id`, the sample adds the attachment entity as a subentity of the plane entity to display it in the scene, and then configures the scale and position.
```swift
// Add and configure attachments.
for viewAttachmentEntity in rainbowModel.archAttachments {
    
    // Check whether there's an attachment.
    if let attachment = attachments.entity(for: "\(viewAttachmentEntity.title)ArchAttachmentEntity") {
        
        attachment.name = viewAttachmentEntity.title.rawValue
        
        // Add it as a subentity of the plane.
        plane?.addChild(attachment)
        
        // Set the scale and position.
        attachment.scale = viewAttachmentEntity.scale
        attachment.setPosition(viewAttachmentEntity.position, relativeTo: yellowArch)
    }
}
```

```
This method sets the scales and positions for each attachment by using the yellow arch’s bounding box. This ensures each arch is smaller and further back than the previous. The app applies these scale and position values to each entity in the `update` closure as the code example below shows:
```swift
/// Updates the array containing the scale and position for each attachment entity.
func scaleAndPositionArches(yellowArchSize: BoundingBox) {
    // MARK: - Scaling properties
    
    // Set the x scale to be the same as the yellow arch.
    // Set the y scale to be double the yellow arch to account for the larger frame due to the SwiftUI view.
    var archScale = SIMD3(x: yellowArchSize.extents.x, y: yellowArchSize.max.y * 2, z: 1)
    
    // MARK: - Positioning properties
    
    // Set the y position to be the same as the yellow arch.
    let yPosition = yellowArchSize.min.y
    
    // Set the z position to be 0.1 meters back.
    var zPosition: Float = -0.1
    var position = SIMD3(x: 0, y: yPosition, z: zPosition)
    
    for (index, attachment) in rainbowModel.archAttachments.enumerated() {
        
        // Push the arch back by 0.1 meters.
        zPosition -= 0.1
        position.z = zPosition
        
        // Update the attachments in the view attachment array to include position and scale.
        rainbowModel.archAttachments[index] = ArchAttachment(title: attachment.title, position: position, scale: archScale)
        
        // Scale the next attachment to be 75% of the size of the previous arch.
        archScale *= 3 / 4
    }
}
```

#### 
Follow these steps to add attachments to RealityKit entities and position them at the tapped location. Ensure that your entities have both an  and a .
```swift
/// Sets the components necessary for hover and tap gestures.
func configureForTapGesture(entity: Entity) async {
    // Set the hover effect component.
    entity.components.set(HoverEffectComponent())
    
    // Find the `ModelComponent` to get the mesh and create a static mesh in the shape of the entity.
    guard let modelComponent = entity.components[ModelComponent.self] else { return }
    let entityMesh = modelComponent.mesh
    let shapeResource = try! await ShapeResource.generateStaticMesh(from: entityMesh)
    entity.components.set(CollisionComponent(shapes: [shapeResource]))
    
    // Set the input target component.
    entity.components.set(InputTargetComponent())
}
```

```
Add a  to the `RealityView` and make sure it uses , or specify which entities to target with . Then use  to convert the location of the tap gesture from the local coordinate space of the entity to the scene’s coordinate space.
```swift
.simultaneousGesture(
    SpatialTapGesture()
        .targetedToAnyEntity()
        .onEnded { value in
            // Convert the tap location to the scene's coordinate space.
            var location3D = value.convert(value.location3D, from: .local, to: .scene)
            // Move the z index forward to ensure it doesn't overlap with the entity.
            location3D.z += 0.02
            
            // You don't need to set the position of attachments on entities relative to the root entity, so pass `nil` here.
            // The system handles this with the location conversion.
            rainbowModel.tapAttachments.append(CloudTapAttachment(position: location3D, parent: nil))
        }
)
```

Create the attachment in the `attachments` closure by iterating over the array of attachments.
```
Create the attachment in the `attachments` closure by iterating over the array of attachments.
```swift
// Iterate over the tap attachments and provide content for each.
ForEach(rainbowModel.tapAttachments) { cloud in
    Attachment(id: cloud.position) {
        Image(systemName: "cloud.fill")
    }
}
```

Finally, add each attachment in the `update` closure by iterating over the array of attachments and setting their stored position and root entity.
```
Finally, add each attachment in the `update` closure by iterating over the array of attachments and setting their stored position and root entity.
```swift
for cloud in rainbowModel.tapAttachments {
    if let cloudEntity = attachments.entity(for: cloud.position) {
        // Scale the attachment larger and add it.
        cloudEntity.scale = [5, 5, 5]
        cloudEntity.name = "\(cloud.position)tapEntity"
        root.addChild(cloudEntity)
        
        // Set the position of the attachment.
        cloudEntity.setPosition(cloud.position, relativeTo: cloud.parent)
    }
}
```


## Configuring Collision in RealityKit
> https://developer.apple.com/documentation/realitykit/configuring-collision-in-realitykit

### 
`CollisionGroup` conforms to , which means you typically create individual groups by assigning each group a different bit flag value. If each group has a distinct bit representing it, that allows you to configure collision filters that collide with, or ignore any combination of individual collision groups using `OptionSet`’s various methods.
Here is how the four collision groups in this sample project are defined:
```swift
    let planeGroup = CollisionGroup(rawValue: 1 << 0)
    let cubeGroup = CollisionGroup(rawValue: 1 << 1)
    let beveledCubeGroup = CollisionGroup(rawValue: 1 << 2)
    let sphereGroup = CollisionGroup(rawValue: 1 << 3)
```

For example, here is how this sample creates the filter for the `cubeGroup`, used by cubes so they collide with everything except other cubes:
You don’t assign collision groups directly to entities. Instead, you create filters that define the collision properties for individual entities. Assigning a collision filter to an entity automatically places that entity into the collision filter’s group or groups.
For example, here is how this sample creates the filter for the `cubeGroup`, used by cubes so they collide with everything except other cubes:
```swift
    let cubeMask = CollisionGroup.all.subtracting(cubeGroup)
    let cubeFilter = CollisionFilter(group: cubeGroup,
                                      mask: cubeMask)
```

After creating a collision filter, assign it to all the entities that should use that filter, like this:
```swift
    cube1.collision?.filter = cubeFilter
    cube2.collision?.filter = cubeFilter
    cube3.collision?.filter = cubeFilter
```

### 

## Construct an immersive environment for visionOS
> https://developer.apple.com/documentation/realitykit/construct-an-immersive-environment-for-visionos

### 
### 
### 
When creating , pass `false` to the intializer’s `applyPostProcessToneMap` parameter for better performance and more accurate colors; for example:
All shaders aren’t created equal. Physically based rendering (PBR) materials are considerably more complex than unlit materials, which just map a texture or color onto an object without requiring lighting calculations. Most 3D modeling applications provide a way to bake lighting into a texture, creating the illusion of a lighted entity. Baking lighting into your model’s textures isn’t always possible, but when you use an unlit material instead of a PBR material, you improve your environment’s performance. The sample app uses unlit materials as much as possible to limit pixel shader cost.
When creating , pass `false` to the intializer’s `applyPostProcessToneMap` parameter for better performance and more accurate colors; for example:
```swift
let material = UnlitMaterial(color: .white,
                             applyPostProcessToneMap: false)
```

### 
### 
### 
### 
### 
### 
To control the lighting of your scene, provide an image-based lighting (IBL) texture. For best results, use a 1024x512 pixel HDRI image saved as an `.exr` file. Load the image, then use it to create an `ImageBasedLightComponent` on the root node of your `RealityView`, as shown below:
```swift
  if let resource = try? EnvironmentResource.generate(fromEquirectangular: myHDRImage) {}
    rootNode.components.set(ImageBasedLightComponent(
        environment: resource,
        intensityExponent: overallIntensityExponent
    ))
}
```

### 

## Creating 3D objects from photographs
> https://developer.apple.com/documentation/realitykit/creating-3d-objects-from-photographs

### 
#### 
RealityKit Object Capture is only available on Mac computers that meet the minimum requirements for performing object reconstruction, including a GPU with at least 4 GB of RAM and ray tracing support. It is also available on select iOS devices with LiDAR capabilities.
Before using any Object Capture APIs, check whether the device your code is running on meets those requirements, and only proceed if it does.
```swift
guard PhotogrammetrySession.isSupported else {
    // Inform user and don't proceed with reconstruction.
}
```

#### 
Begin by creating a  with a URL that points to the desired output location for the generated USDZ file and the desired level of detail for the model. Next, use that request, along with a URL pointing to the directory containing your images, to create the  object.
```swift
let inputFolderUrl = URL(fileURLWithPath: "/tmp/MyInputImages/")
let url = URL(fileURLWithPath: "MyObject.usdz")
var request = PhotogrammetrySession.Request.modelFile(url: url, 
                                                      detail: .full)
guard let session = try PhotogrammetrySession(input: inputFolderUrl) else {
    return } 
```

#### 
RealityKit uses an  of  objects to deliver status updates about the object-creation process in the background. To update your app’s UI or to take other actions as a result of these status updates, create an `async` task and use a `for`-`try`-`await` loop on .
```swift
let waiter = async {
    do {
        for try await output in session.outputs {
            switch output {
                case .processingComplete:
                    // RealityKit has processed all requests.
                case .requestError(let request, let error):
                    // Request encountered an error.
                case .requestComplete(let request, let result):
                    // RealityKit has finished processing a request.
                case .requestProgress(let request, let fractionComplete):
                    // Periodic progress update. Update UI here.
                case .inputComplete: 
                    // Ingestion of images is complete and processing begins.
                case .invalidSample(let id, let reason):
                    // RealityKit deemed a sample invalid and didn't use it.
                case .skippedSample(let id):
                    // RealityKit was unable to use a provided sample.
                case .automaticDownsampling:
                    // RealityKit downsampled the input images because of
                    // resource constraints.
                case .processingCancelled
                    // Processing was canceled.
                @unknown default:
                    // Unrecognized output.
            }
        }
    } catch {
        print("Output: ERROR = \(String(describing: error))")
        // Handle error.
    }
}
```

```
Once you’ve created a session and registered to receive status updates, start the object-creation process by calling . RealityKit processes the photographs in the background and notifies your app when the process completes or fails.
```swift
session.process(requests: [request])
```

#### 
RealityKit’s default photogrammetry settings work for the vast majority of input images. If, however, you have image sets that are low contrast or lack many identifying landmarks, you can override the default values to compensate by creating a  object and passing it into the initializer when you create your .
To simplify the object-creation process, you can use a custom configuration to provide images to the  in sequence by listing adjacent images together, or to control support for object masking, which blocks out portions of an image around an object.
```swift
let config = Configuration()

// Use slower, more sensitive landmark detection.
config.featureSensitivity = .high
// Adjacent images are next to each other.
config.sampleOrdering = .sequential
// Object masking is enabled.
config.isObjectMaskingEnabled = true

let session = try PhotogrammetrySession(input: inputFolderUrl, 
                                        configuration:config)
```


## Creating a dynamic height and normal map with low-level texture
> https://developer.apple.com/documentation/realitykit/creating-a-dynamic-height-map-with-low-level-texture

### 
### 
Create a height map  by describing its pixel format, width, height, and usage:
```swift
/// The low-level texture that stores the height and normal information of the height map.
var heightMapTexture: LowLevelTexture

init(dimensions: SIMD2<UInt32>) throws {
    // Initialize the texture with an RGBA pixel format where the alpha channel stores height,
    // while the red, green, and blue channels store the surface normal direction.
    let textureDescriptor = LowLevelTexture.Descriptor(pixelFormat: .rgba32Float,
                                                       width: Int(dimensions.x),
                                                       height: Int(dimensions.y),
                                                       textureUsage: [.shaderRead, .shaderWrite])
    self.heightMapTexture = try LowLevelTexture(descriptor: textureDescriptor)
}
```

### 
Write height data to the texture on the GPU by dispatching a Metal compute shader. For example, you can create a height map with waves that oscillate outward from the center of the texture by setting the height of each pixel to the sine of the pixel’s distance from the center:
```cpp
/// Generates a height map in the shape of a sine wave moving outward from the center of the texture.
[[kernel]]
void generateSineWaveHeightMap(texture2d<float, access::read> heightMapIn [[texture(0)]],
                               texture2d<float, access::write> heightMapOut [[texture(1)]],
                               constant float &time [[buffer(2)]],
                               constant float &amplitude [[buffer(3)]],
                               uint2 pixelCoords [[thread_position_in_grid]]) {
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (pixelCoords.x >= heightMapIn.get_width() || pixelCoords.y >= heightMapIn.get_height()) { return; }
    
    // Compute texture coordinates ranging from 0 to 1 along each axis.
    float2 uv = float2(pixelCoords.x / (heightMapIn.get_width() - 1.0),
                       pixelCoords.y / (heightMapIn.get_height() - 1.0));
    
    // Get the distance to the center of the texture in texture coordinate space.
    float distanceToCenter = length(uv - 0.5);
    // Normalize the distance to a range from 0 to 2π along the horizontal and vertical axes.
    float normalizedDistanceToCenter = (distanceToCenter / 0.5) * (2 * M_PI_F);

    // Get sine as a function of the normalized distance to the center of the texture times the wave count,
    // subtracting time to animate it outward over time.
    float waveCount = 3;
    float sine = sin(normalizedDistanceToCenter * waveCount - time);
    // Convert sine to the range 0 to 1.
    float sine01 = (sine + 1) / 2;
    
    // Generate height from the sine function.
    float height = amplitude * sine01;
    
    // Read the current height map data.
    float4 heightMapData = heightMapIn.read(pixelCoords);
    // Update the alpha channel with the new height.
    heightMapData.a = height;
    // Write the updated height data to height map.
    heightMapOut.write(heightMapData, pixelCoords);
}
```

### 
Create a helper method that makes the  for a given compute shader function:
```swift
/// The device Metal selects as the default.
let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()

/// Makes a compute pipeline for the compute function with the given name.
func makeComputePipeline(named name: String) -> MTLComputePipelineState? {
    guard let function = metalDevice?.makeDefaultLibrary()?.makeFunction(name: name) else {
        return nil
    }
    return try? metalDevice?.makeComputePipelineState(function: function)
}
```

Get the  for the `generateSineWaveHeightMap` compute shader function:
```
Get the  for the `generateSineWaveHeightMap` compute shader function:
```swift
private let sineWaveHeightPipeline: MTLComputePipelineState = makeComputePipeline(named: "generateSineWaveHeightMap")!
```

```
Next, calculate the number of threads and threadgroups to dispatch:
```swift
let threadWidth = sineWaveHeightPipeline.threadExecutionWidth
let threadHeight = sineWaveHeightPipeline.maxTotalThreadsPerThreadgroup / threadWidth
let threadsPerThreadgroup = MTLSize(width: threadWidth, height: threadHeight, depth: 1)
let threadgroups = MTLSize(width: (Int(dimensions.x) + threadWidth - 1) / threadWidth,
                           height: (Int(dimensions.y) + threadHeight - 1) / threadHeight,
                           depth: 1)
```

```
Then, define the time and amplitude parameters:
```swift
private var time: Float = 0
private var amplitude: Float = 0.05
```

```
Finally, dispatch the `generateSineWaveHeightMap` function in every frame with an , passing it both a readable and a writable version of the height map , as well as the time and the amplitude:
```swift
// Increment time.
time += deltaTime

// Set the compute shader pipeline to `generateSineWaveHeightMap`.
computeEncoder.setComputePipelineState(sineWaveHeightPipeline)

// Pass a readable version of the height map texture to the compute shader.
computeEncoder.setTexture(heightMapTexture.read(), index: 0)
// Pass a writable version of the height map texture to the compute shader.
computeEncoder.setTexture(heightMapTexture.replace(using: commandBuffer), index: 1)

// Pass the time to the compute shader.
computeEncoder.setBytes(&time, length: MemoryLayout<Float>.size, index: 2)
// Pass the amplitude to the compute shader.
computeEncoder.setBytes(&amplitude, length: MemoryLayout<Float>.size, index: 3)

// Dispatch the compute shader.
computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
```

### 
Derive the normal direction at each pixel in the height map by computing the difference between the pixel’s neighboring height values:
```cpp
/// Derives normal directions from a height map, storing them in the texture's rgb channels.
[[kernel]]
void deriveNormalsFromHeightMap(texture2d<float, access::read> heightMapIn [[texture(0)]],
                                texture2d<float, access::write> heightMapOut [[texture(1)]],
                                constant float2 &cellSize [[buffer(2)]],
                                uint2 pixelCoords [[thread_position_in_grid]]) {
    // Get the dimensions of the height map.
    uint2 dimensions = uint2(heightMapIn.get_width(), heightMapIn.get_height());
    
    // Skip out-of-bounds threads.
    if (any(pixelCoords >= dimensions)) { return; }
    
    // The current pixel coordinate minus one in both dimensions, guaranteed to be in bounds.
    uint2 pixelCoordsMinusOne = max(pixelCoords, 1) - 1;
    // The current pixel coordinate plus one in both dimensions, guaranteed to be in bounds.
    uint2 pixelCoordsPlusOne = min(pixelCoords + 1, dimensions - 1);
    
    // Sample the current pixel along with its four neighbors.
    float height = heightMapIn.read(pixelCoords).a;
    float leftHeight = heightMapIn.read(uint2(pixelCoordsMinusOne.x, pixelCoords.y)).a;
    float rightHeight = heightMapIn.read(uint2(pixelCoordsPlusOne.x, pixelCoords.y)).a;
    float bottomHeight = heightMapIn.read(uint2(pixelCoords.x, pixelCoordsMinusOne.y)).a;
    float topHeight = heightMapIn.read(uint2(pixelCoords.x, pixelCoordsPlusOne.y)).a;
    
    // Compute the normal direction using central differences.
    float3 normal = normalize(float3((leftHeight - rightHeight) / (cellSize.x * 2),
                                     (bottomHeight - topHeight) / (cellSize.y * 2),
                                     1));
    
    // Write the normal direction to the height map.
    heightMapOut.write(float4(normal, height), pixelCoords);
}
```

```
Get the  for this compute function:
```swift
private let deriveNormalsPipeline: MTLComputePipelineState = makeComputePipeline(named: "deriveNormalsFromHeightMap")!
```

```
Finally, dispatch this compute function with an , passing in both a readable and a writable version of the height map low-level texture:
```swift
// Set the compute shader pipeline to `deriveNormalsFromHeightMap`.
computeEncoder.setComputePipelineState(deriveNormalsPipeline)

// Pass a readable version of the height map texture to the compute shader.
computeEncoder.setTexture(heightMapTexture.read(), index: 0)
// Pass a writable version of the height map texture to the compute shader.
computeEncoder.setTexture(heightMapTexture.replace(using: commandBuffer), index: 1)

// Pass the cell size to the compute shader.
computeEncoder.setBytes(&cellSize, length: MemoryLayout<SIMD2<Float>>.size, index: 2)

// Dispatch the compute shader.
computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
```


## Creating a plane with low-level mesh
> https://developer.apple.com/documentation/realitykit/creating-a-plane-with-low-level-mesh

### 
### 
Start by defining a custom vertex structure in a  header file:
```cpp
struct PlaneVertex {
    simd_float3 position;
    simd_float3 normal;
};
```

### 
Define a structure that constructs the plane low-level mesh with size and dimensions:
```swift
struct PlaneMesh {
    /// The plane low-level mesh.
    var mesh: LowLevelMesh!
    /// The size of the plane mesh.
    let size: SIMD2<Float>
    /// The number of vertices in each dimension of the plane mesh.
    let dimensions: SIMD2<UInt32>
    /// The maximum offset depth for the vertices of the plane mesh.
    ///
    /// Use this to ensure the bounds of the plane encompass its vertices, even if they are offset.
    let maxVertexDepth: Float
    
    ...
    
    /// Initializes the plane mesh by creating a low-level mesh and filling its vertex and index buffers
    /// to form a plane with given size and dimensions.
    init(size: SIMD2<Float>, dimensions: SIMD2<UInt32>, maxVertexDepth: Float = 1) throws {
        self.size = size
        self.dimensions = dimensions
        self.maxVertexDepth = maxVertexDepth
        
        // Create the low-level mesh.
        self.mesh = try createMesh()

        // Fill the mesh's vertex buffer with data.
        initializeVertexData()
        
        // Fill the mesh's index buffer with data.
        initializeIndexData()
        
        // Initialize the mesh parts.
        initializeMeshParts()
    }
}
```

### 
Start by specifying the layout of the vertex data with a  array and a  array:
```swift
/// Creates a low-level mesh with `PlaneVertex` vertices.
private func createMesh() throws -> LowLevelMesh {
    // Define the vertex attributes of `PlaneVertex`.
    let positionAttributeOffset = MemoryLayout.offset(of: \PlaneVertex.position) ?? 0
    let normalAttributeOffset = MemoryLayout.offset(of: \PlaneVertex.normal) ?? 16
    
    let positionAttribute = LowLevelMesh.Attribute(semantic: .position, format: .float3, offset: positionAttributeOffset)
    let normalAttribute = LowLevelMesh.Attribute(semantic: .normal, format: .float3, offset: normalAttributeOffset)
    
    let vertexAttributes = [positionAttribute, normalAttribute]
    
    // Define the vertex layouts of `PlaneVertex`.
    let vertexLayouts = [LowLevelMesh.Layout(bufferIndex: 0, bufferStride: MemoryLayout<PlaneVertex>.stride)]
```

These arrays define which properties in your custom vertex structure represent the different components of the vertex, such as position, normal, color, and so on, as well as their memory layout.
Next, derive the number of vertices and indices in the mesh from its dimensions:
```swift
    // Derive the vertex and index count from the dimensions.
    let vertexCount = Int(dimensions.x * dimensions.y)
    let indicesPerTriangle = 3
    let trianglesPerCell = 2
    let cellCount = Int((dimensions.x - 1) * (dimensions.y - 1))
    let indexCount = indicesPerTriangle * trianglesPerCell * cellCount
```

```
Finally, create the low-level mesh by describing its vertex capacity, attributes, layouts, and index capacity:
```swift
    // Create a low-level mesh with the necessary `PlaneVertex` capacity.
    let meshDescriptor = LowLevelMesh.Descriptor(vertexCapacity: vertexCount,
                                                 vertexAttributes: vertexAttributes,
                                                 vertexLayouts: vertexLayouts,
                                                 indexCapacity: indexCount)
    return try LowLevelMesh(descriptor: meshDescriptor)
}
```

### 
Start by defining a helper method that converts a two-dimensional vertex coordinate to a one-dimensional vertex buffer array index:
```swift
/// Converts a 2D vertex coordinate to a 1D vertex buffer index.
private func vertexIndex(_ xCoord: UInt32, _ yCoord: UInt32) -> UInt32 {
    xCoord + dimensions.x * yCoord
}
```

```
Next, initialize the vertices of the low-level mesh by setting their normal directions and positioning them to form a plane with the given size:
```swift
/// Initialize the vertices of the mesh, positioning them to form an xy-plane with the given size.
private func initializeVertexData() {
    // Initialize mesh vertex positions and normals.
    mesh.withUnsafeMutableBytes(bufferIndex: 0) { rawBytes in
        // Convert `rawBytes` into a `PlaneVertex` buffer pointer.
        let vertices = rawBytes.bindMemory(to: PlaneVertex.self)
        
        // Define the normal direction for the vertices.
        let normalDirection: SIMD3<Float> = [0, 0, 1]

        // Iterate through each vertex.
        for xCoord in 0..<dimensions.x {
            for yCoord in 0..<dimensions.y {
                // Remap the x and y vertex coordinates to the range [0, 1].
                let xCoord01 = Float(xCoord) / Float(dimensions.x - 1)
                let yCoord01 = Float(yCoord) / Float(dimensions.y - 1)
                
                // Derive the vertex position from the remapped vertex coordinates and the size.
                let xPosition = size.x * xCoord01 - size.x / 2
                let yPosition = size.y * yCoord01 - size.y / 2
                let zPosition = Float(0)
                
                // Get the current vertex from the vertex coordinates and set its position and normal.
                let vertexIndex = Int(vertexIndex(xCoord, yCoord))
                vertices[vertexIndex].position = [xPosition, yPosition, zPosition]
                vertices[vertexIndex].normal = normalDirection
            }
        }
    }
}
```

Loop over the vertices within the  callback for best performance, as calling this method repeatedly is costly.
Finally, fill the index buffer by iterating through each cell in the mesh and adding the vertices of the two triangles that make up the cell in a counterclockwise winding order:
```swift
/// Initializes the indices of the mesh two triangles at a time for each cell in the mesh.
private func initializeIndexData() {
    mesh.withUnsafeMutableIndices { rawIndices in
        // Convert `rawIndices` into a UInt32 pointer.
        guard var indices = rawIndices.baseAddress?.assumingMemoryBound(to: UInt32.self) else { return }
        
        // Iterate through each cell.
        for xCoord in 0..<dimensions.x - 1 {
            for yCoord in 0..<dimensions.y - 1 {
                /*
                   Each cell in the plane mesh consists of two triangles:
                    
                              topLeft     topRight
                                     |\ ̅ ̅|
                     1st Triangle--> | \ | <-- 2nd Triangle
                                     | ̲ ̲\|
                  +y       bottomLeft     bottomRight
                   ^
                   |
                   *---> +x
                 
                 */
                let bottomLeft = vertexIndex(xCoord, yCoord)
                let bottomRight = vertexIndex(xCoord + 1, yCoord)
                let topLeft = vertexIndex(xCoord, yCoord + 1)
                let topRight = vertexIndex(xCoord + 1, yCoord + 1)
                
                // Create the 1st triangle with a counterclockwise winding order.
                indices[0] = bottomLeft
                indices[1] = bottomRight
                indices[2] = topLeft
                
                // Create the 2nd triangle with a counterclockwise winding order.
                indices[3] = topLeft
                indices[4] = bottomRight
                indices[5] = topRight
                
                indices += 6
            }
        }
    }
}
```

### 
Initialize the mesh parts by specifying the mesh’s index count, topology, and bounds:
```swift
/// Initializes mesh parts, indicating topology and bounds.
func initializeMeshParts() {
    // Create a bounding box that encompasses the plane's size and max vertex depth.
    let bounds = BoundingBox(min: [-size.x / 2, -size.y / 2, 0],
                             max: [size.x / 2, size.y / 2, maxVertexDepth])
    
    mesh.parts.replaceAll([LowLevelMesh.Part(indexCount: mesh.descriptor.indexCapacity,
                                             topology: .triangle,
                                             bounds: bounds)])
}
```

### 
View `PlaneMesh`’s low-level mesh by creating a  from it and adding that to the  of an entity in the scene:
View `PlaneMesh`’s low-level mesh by creating a  from it and adding that to the  of an entity in the scene:
```swift
RealityView { content in
    // Create a plane mesh.
    if let planeMesh = try? PlaneMesh(size: [1, 1], dimensions: [16, 16]),
       let mesh = try? MeshResource(from: planeMesh.mesh) {
        // Create an entity with the plane mesh.
        let planeEntity = Entity()
        let planeModel = ModelComponent(mesh: mesh, materials: [SimpleMaterial()])
        planeEntity.components.set(planeModel)
        
        // Add the plane entity to the scene.
        content.add(planeEntity)
    }
}
```

The following image shows the result of rendering a `PlaneMesh`’s low-level mesh in the scene:

## Designing scene hierarchies for efficient physics simulation
> https://developer.apple.com/documentation/realitykit/designing-scene-hierarchies-for-efficient-physics-simulation

### 
#### 
#### 
By default, RealityKit uses the scene’s root entity as the origin of the physics simulation and simulates objects at their actual size. You can alternatively designate a different entity in your scene to be the  by using the  property of your . Designating an entity as the physics origin means that all physics calculations are relative to the specified entity rather than the scene’s root entity. For more information about when to specify a separate physics origin, see .
```swift
arView.physicsOrigin = entity
```

You can’t specify a different physics origin using Reality Composer. Instead, designate an entity in a loaded Reality Composer scene as the physics entity or add a new entity to the loaded scene to act as the physics origin.
This example shows how to retrieve a named entity from your Reality Composer scene and specify it as the physics origin:
```swift
    let boxAnchor = try! Experience.loadBox()
    arView.scene.anchors.append(boxAnchor)
    if let physicsRoot = boxAnchor.findEntity(named: "Physics Root") {
        self.arView.physicsOrigin = physicsRoot
    }
```

#### 
#### 
When changing velocities or applying forces or impulses to simulated objects, apply the changes relative to the physics origin. Specifying units relative to the physics origin eliminates the need to account for scale changes made to the rendered scene.
 internally stores velocity values relative to the physics origin. Specifying forces and impulses relative to the physics origin eliminates the need for the physics engine to convert or translate values and therefore results in better performance.
```swift
// Apply impulse to shoot the object up.
let impulseStrength = 10
let impulseDirection = SIMD3<Float>(0, 1, 0)
model.applyLinearImpulse(impulseStrength * impulseDirection, relativeTo: arView.physicsOrigin)
```

#### 
#### 
For best results, keep the mass of your scene’s objects at their calculated mass. Entities with substantially increased mass result in a proportional increase in momentum, which can make the physics simulation unstable. To simulate heavy, dense objects like gold or lead, leave the mass at its calculated value and increase the entity’s density property. The pre-defined physics materials available in Reality Composer use density to simulate heavy materials.
```swift
// Use the initializer with density instead of mass.
model.physicsBody = .init(shapes: [boxShape], density: 200)
```


## Docking a video player in an immersive scene
> https://developer.apple.com/documentation/realitykit/docking-a-video-player-in-an-immersive-scene

### 
#### 
#### 
#### 
Create an immersive picker view that toggles the immersive scene through existing immersive space APIs.
```swift
struct ImmersivePickerView: View {
    let appModel: AppModel
    
    /// An asynchronous call returns after dismissing the immersive space.
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    /// An asynchronous call returns after opening the immersive space.
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    var body: some View {
        // Add a button to toggle the immersive environment.
        Button("Sky Dome", systemImage: "photo") {
            Task {
                if appModel.immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                } else {
                    await openImmersiveSpace(id: appModel.immersiveSpaceID)
                }
            }
        }
    }
}
```

```
Use  to include this picker as an option in the list of immersive scene selections.
```None
AVPlayerView(viewModel: avPlayerViewModel)
    .immersiveEnvironmentPicker {
        ImmersivePickerView(appModel: appModel)
    }
```

#### 
The Immersive Environment App template comes with a Reality Composer Pro project that includes a `Player` entity with the docking region. To customize the docking-region settings in Xcode, open the Reality Composer Pro package and remove the `Video_Dock` entity that contains the `Player` entity.
Within your `ImmersiveView`, create a docking-region component with a width of your choice. The docking region uses a cinematic `2.4:1` width-height ratio to determine the height.
```swift
// Create a docking-region component to customize your docking region.
var dockingRegionComponent = DockingRegionComponent()
// Set the docking region width to 9.6 meters.
dockingRegionComponent.width = 9.6
```

```
Create a docking entity and position the entity where you want to dock the AV player. Then attach the docking-region component to the docking entity.
```swift
// Create a docking entity as a docking anchor.
let dockingEntity = Entity()

// Set the position of your dock, in meters.
dockingEntity.position = [0, 2, -10]

// Attach the docking-region component to the docking entity.
dockingEntity.components.set(dockingRegionComponent)
```

And, finally, add it to your `RealityView`.
```
And, finally, add it to your `RealityView`.
```swift
content.add(dockingEntity)
```


## Generating interactive geometry with RealityKit
> https://developer.apple.com/documentation/realitykit/generating-interactive-geometry-with-realitykit

### 
### 
The sample defines the custom vertex data structure for its plane mesh in an MSL header file:
```cpp
struct PlaneVertex {
    simd_float3 position;
    simd_float3 normal;
};
```

### 
The sample creates the plane low-level mesh by defining its vertex attributes, vertex layouts, and the number of vertices and indices it has capacity for:
```swift
/// The number of vertices in each dimension of the plane mesh.
let dimensions: SIMD2<UInt32>

...

/// Creates a low-level mesh with `PlaneVertex` vertices.
private func createMesh() throws -> LowLevelMesh {
    // Define the vertex attributes of `PlaneVertex`.
    let positionAttributeOffset = MemoryLayout.offset(of: \PlaneVertex.position) ?? 0
    let normalAttributeOffset = MemoryLayout.offset(of: \PlaneVertex.normal) ?? 16
    
    let positionAttribute = LowLevelMesh.Attribute(semantic: .position, format: .float3, offset: positionAttributeOffset)
    let normalAttribute = LowLevelMesh.Attribute(semantic: .normal, format: .float3, offset: normalAttributeOffset)
    
    let vertexAttributes = [positionAttribute, normalAttribute]
    
    // Define the vertex layouts of `PlaneVertex`.
    let vertexLayouts = [LowLevelMesh.Layout(bufferIndex: 0, bufferStride: MemoryLayout<PlaneVertex>.stride)]
    
    // Derive the vertex and index counts from the dimensions.
    let vertexCount = Int(dimensions.x * dimensions.y)
    let indicesPerTriangle = 3
    let trianglesPerCell = 2
    let cellCount = Int((dimensions.x - 1) * (dimensions.y - 1))
    let indexCount = indicesPerTriangle * trianglesPerCell * cellCount
    
    // Create a low-level mesh with the necessary `PlaneVertex` capacity.
    let meshDescriptor = LowLevelMesh.Descriptor(vertexCapacity: vertexCount,
                                                 vertexAttributes: vertexAttributes,
                                                 vertexLayouts: vertexLayouts,
                                                 indexCapacity: indexCount)
    return try LowLevelMesh(descriptor: meshDescriptor)
}
```

### 
The sample defines a custom `ComputeUpdateContext` structure that contains the necessary context for dispatching compute shader functions in every frame:
```swift
struct ComputeUpdateContext {
    /// The number of seconds elapsed since the last frame.
    let deltaTime: TimeInterval
    /// The command buffer for the current frame.
    let commandBuffer: MTLCommandBuffer
    /// The compute command encoder for the current frame.
    let computeEncoder: MTLComputeCommandEncoder
}
```

The sample dispatches compute shader functions in every frame by passing this structure to each `ComputeSystem` in the app (see ).
The sample dispatches compute shader functions in every frame by passing this structure to each `ComputeSystem` in the app (see ).
`HeightMapMesh` is an example of a `ComputeSystem`. It implements the `ComputeSystem`  protocol’s `update` method to dispatch compute shaders that generate a height map and modify the vertex positions and normals of a mesh in each frame:
```swift
class HeightMapMesh: ComputeSystem {
    ...

    /// Updates the height map mesh by generating a height map, deriving normals from it, and then setting the vertex positions and normals.
    func update(computeContext: ComputeUpdateContext) {
        ...
        
        // Generate the height map height values.
        heightMap.generateHeight(computeContext: computeContext, heightMapComputeParams: heightMapComputeParams)
        // Update the height map normal directions.
        heightMap.updateNormals(computeContext: computeContext, heightMapComputeParams: heightMapComputeParams)
        
        // Update the vertex positions and normals.
        updateVertices(computeContext: computeContext)
    }
}
```

### 
The sample creates a height map with  by specifying its pixel format, dimensions, and usage:
```swift
struct HeightMap {
    ...
   
    /// The low-level texture that stores the height and normal information of the height map.
    var heightMapTexture: LowLevelTexture
    
    init(dimensions: SIMD2<UInt32>) throws {
        // Initialize the texture with an RGBA pixel format where the alpha channel stores height,
        // while the red, green, and blue channels store the surface normal direction.
        let textureDescriptor = LowLevelTexture.Descriptor(pixelFormat: .rgba32Float,
                                                           width: Int(dimensions.x),
                                                           height: Int(dimensions.y),
                                                           textureUsage: [.shaderRead, .shaderWrite])
        self.heightMapTexture = try LowLevelTexture(descriptor: textureDescriptor)
    }
    
    ...
}
```

### 
The sample writes height data to the low-level texture in every frame on the GPU by dispatching Metal compute shaders. For example, the compute shader function `generateSineWaveHeightMap` writes height values to the texture in the shape of a sine wave moving outward from the center of the texture over time:
```cpp
[[kernel]]
void generateSineWaveHeightMap(texture2d<float, access::read> heightMapIn [[texture(0)]],
                               texture2d<float, access::write> heightMapOut [[texture(1)]],
                               constant float &time [[buffer(2)]],
                               constant float &amplitude [[buffer(3)]],
                               uint2 pixelCoords [[thread_position_in_grid]]) {
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (pixelCoords.x >= heightMapIn.get_width() || pixelCoords.y >= heightMapIn.get_height()) { return; }
    
    // Compute texture coordinates ranging from 0 to 1 along each axis.
    float2 uv = float2(pixelCoords.x / (heightMapIn.get_width() - 1.0),
                       pixelCoords.y / (heightMapIn.get_height() - 1.0));
    
    // Get the distance to the center of the texture in texture coordinate space.
    float distanceToCenter = length(uv - 0.5);
    // Normalize the distance to a range from 0 to 2π along the horizontal and vertical axes.
    float normalizedDistanceToCenter = (distanceToCenter / 0.5) * (2 * M_PI_F);

    // Get sine as a function of the normalized distance to the center of the texture times the wave count,
    // subtracting time to animate it outward over time.
    float waveCount = 3;
    float sine = sin(normalizedDistanceToCenter * waveCount - time);
    // Convert sine to the range 0 to 1.
    float sine01 = (sine + 1) / 2;
    
    // Generate height from the sine function.
    float height = amplitude * sine01;
    
    // Read the current height map data.
    float4 heightMapData = heightMapIn.read(pixelCoords);
    // Update the alpha channel with the new height.
    heightMapData.a = height;
    // Write the updated height data to height map.
    heightMapOut.write(heightMapData, pixelCoords);
}
```

The following video shows the texture the `generateSineWaveHeightMap` compute function creates:
The following video shows the texture the `generateSineWaveHeightMap` compute function creates:
The sample dispatches this compute shader function in `SineWaveHeightMapGenerator`, passing in both the height map low-level texture, the time, and the amplitude:
```swift
class SineWaveHeightMapGenerator: HeightMapGenerator {
    /// Compute pipeline corresponding to the Metal compute shader function `generateSineWaveHeightMap`.
    ///
    /// See `SineWaveComputeShader.metal`.
    private let sineWaveHeightPipeline: MTLComputePipelineState = makeComputePipeline(named: "generateSineWaveHeightMap")!
    
    /// The number of seconds elapsed since the person reset this generator.
    private var time: Float = 0
    
    /// The amplitude of the sine wave this generator generates.
    private var amplitude: Float = 0.05

    ...
    
    /// Dispatches a Metal compute shader to generate a height map in the shape of a sine wave.
    func generateHeightMap(computeContext: ComputeUpdateContext,
                           heightMapTexture: LowLevelTexture,
                           heightMapComputeParams: HeightMapComputeParams) {
        // Get deltaTime.
        let deltaTime = Float(computeContext.deltaTime)
        // Get the command buffer and compute encoder.
        let commandBuffer = computeContext.commandBuffer
        let computeEncoder = computeContext.computeEncoder
        // Get the threadgroups.
        let threadgroups = heightMapComputeParams.threadgroups
        let threadsPerThreadgroup = heightMapComputeParams.threadsPerThreadgroup
        
        // Increment time.
        time += deltaTime
        
        // Set the compute shader pipeline to `generateSineWaveHeightMap`.
        computeEncoder.setComputePipelineState(sineWaveHeightPipeline)
        
        // Pass a readable version of the height map texture to the compute shader.
        computeEncoder.setTexture(heightMapTexture.read(), index: 0)
        // Pass a writable version of the height map texture to the compute shader.
        computeEncoder.setTexture(heightMapTexture.replace(using: commandBuffer), index: 1)
        
        // Pass the time to the compute shader.
        computeEncoder.setBytes(&time, length: MemoryLayout<Float>.size, index: 2)
        // Pass the amplitude to the compute shader.
        computeEncoder.setBytes(&amplitude, length: MemoryLayout<Float>.size, index: 3)
        
        // Dispatch the compute shader.
        computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
    }
}
```

The sample defines the `makeComputePipeline` method as follows:
```
The sample defines the `makeComputePipeline` method as follows:
```swift
/// The device Metal selects as the default.
let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()

...

/// Makes a compute pipeline for the compute function with the given name.
func makeComputePipeline(named name: String) -> MTLComputePipelineState? {
    guard let function = metalDevice?.makeDefaultLibrary()?.makeFunction(name: name) else {
        return nil
    }
    return try? metalDevice?.makeComputePipelineState(function: function)
}
```

### 
The sample abstracts the generation of height maps by defining a `HeightMapGenerator` protocol:
The sample abstracts the generation of height maps by defining a `HeightMapGenerator` protocol:
```swift
protocol HeightMapGenerator {
    /// Resets the height map.
    func reset()
    
    /// Generates the height map.
    func generateHeightMap(computeContext: ComputeUpdateContext,
                           heightMapTexture: LowLevelTexture,
                           heightMapComputeParams: HeightMapComputeParams)
}
```

The following videos show the custom height map textures the `TerrainHeightMapGenerator` and `WaterSurfaceHeightMapGenerator` create:
The following videos show the custom height map textures the `TerrainHeightMapGenerator` and `WaterSurfaceHeightMapGenerator` create:
The `HeightMap` structure calls the `generateHeightMap` method of its active height map generator, passing in the height map low-level texture and the compute update context necessary to dispatch compute shader functions with the texture:
```swift
struct HeightMap {
    ...
    
    /// The generator that generates the height values of the height map.
    var heightMapGenerator: HeightMapGenerator = SineWaveHeightMapGenerator()

    /// The low-level texture that stores the height and normal information of the height map.
    var heightMapTexture: LowLevelTexture
    
    ...
    
    /// Generates the height values in the alpha channel of the height map using the current `heightMapGenerator`.
    func generateHeight(computeContext: ComputeUpdateContext, heightMapComputeParams: HeightMapComputeParams) {
        heightMapGenerator.generateHeightMap(computeContext: computeContext,
                                             heightMapTexture: heightMapTexture,
                                             heightMapComputeParams: heightMapComputeParams)
    }
    
    ...
}
```

### 
The sample defines a structure containing the information necessary to update the mesh’s vertex data on the GPU:
```cpp
struct MeshParams {
    simd_uint2 dimensions;
    simd_float2 size;
    float maxVertexDepth;
};
```

These parameters are suitable for updating the vertices of the plane low-level mesh on the GPU, but you can define parameters that conform to your custom mesh and vertex format. Declare this structure in an MSL header file so that you can send it to the GPU (see ).
Next, the sample updates the position and normal of each vertex in the low-level mesh with a compute shader function that reads this information from the height map low-level texture:
```cpp
[[kernel]]
void setVertexData(constant MeshParams &params [[buffer(0)]],
                   device PlaneVertex *vertices [[buffer(1)]],
                   texture2d<float, access::read> heightMap [[texture(2)]],
                   uint2 vertexCoords [[thread_position_in_grid]]) {
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (any(vertexCoords >= params.dimensions)) { return; }
    
    // Calculate the 1D vertex buffer index given its 2D x, y coordinates.
    uint vertexIndex = vertexCoords.x + params.dimensions.x * vertexCoords.y;
    // Get the current vertex.
    device PlaneVertex &vert = vertices[vertexIndex];
    
    // Sample the height map pixel corresponding to this vertex.
    float4 heightMapData = heightMap.read(vertexCoords);
    // Extract the normal direction and the height.
    float3 normal = heightMapData.rgb;
    float height = heightMapData.a;
    
    // Convert the x and y vertex coordinates to the range [0, 1].
    float2 vertexCoords01 = float2(vertexCoords) / float2(params.dimensions - 1);
    
    // Get the x and y position from the size.
    float2 xyPosition = params.size * vertexCoords01 - params.size / 2;
    // Get the z position from the height, clamping it within
    // the bounds of the mesh that `maxVertexDepth` defines.
    float zPosition = clamp(height, 0., params.maxVertexDepth);
    
    // Update the vertex position and normal.
    vert.position = float3(xyPosition, zPosition);
    vert.normal = normal;
}
```

Here, the `maxVertexDepth` parameter defines the maximum z offset position for vertices, so that they remain within the bounds of the mesh (see ). You can take your own approach to ensuring your vertices remain within bounds.
The sample passes the mesh parameters, vertex buffer, and height map to the compute function before dispatching it:
```swift
private func updateVertices(computeContext: ComputeUpdateContext) {
    // Set the compute shader pipeline to `setVertexData`.
    computeContext.computeEncoder.setComputePipelineState(setVerticesPipeline)
    
    // Pass the mesh parameters to the compute shader.
    computeContext.computeEncoder.setBytes(&meshParams, length: MemoryLayout<MeshParams>.size, index: 0)
    // Pass the vertex buffer to the compute shader.
    let vertexBuffer = planeMesh.mesh.replace(bufferIndex: 0, using: computeContext.commandBuffer)
    computeContext.computeEncoder.setBuffer(vertexBuffer, offset: 0, index: 1)
    // Pass the height map to the compute shader.
    computeContext.computeEncoder.setTexture(heightMap.heightMapTexture.read(), index: 2)
    
    // Dispatch the compute shader.
    computeContext.computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerThreadgroup)
}
```

### 
The sample creates a custom `HeightMapMeshEntity` class with a  to display the `HeightMapMesh`:
The sample creates a custom `HeightMapMeshEntity` class with a  to display the `HeightMapMesh`:
```swift
class HeightMapMeshEntity: Entity, HasModel {
    /// The height map mesh this entity renders.
    var heightMapMesh: HeightMapMesh?
    
    /// Sets up the entity by creating a `HeightMapMesh` and adding the necessary components.
    private func setup(size: SIMD2<Float>, dimensions: SIMD2<UInt32>, maxVertexDepth: Float) {
        // Try to create a `HeightMapMesh` and get its low-level mesh.
        guard let heightMapMesh = try? HeightMapMesh(size: size, dimensions: dimensions, maxVertexDepth: maxVertexDepth),
              let planeMesh = try? MeshResource(from: heightMapMesh.planeMesh.mesh) else {
            assertionFailure("Failed to create height map mesh and get its low-level mesh.")
            return
        }
        self.heightMapMesh = heightMapMesh
        
        // Add a compute system component with the height map mesh as its compute system.
        self.components.set(ComputeSystemComponent(computeSystem: heightMapMesh))

        // Add a model component with the plane mesh.
        self.components.set(ModelComponent(mesh: planeMesh, materials: [SimpleMaterial()]))

        // Make this entity capable of receiving gestures by giving it an input target component and a collider.
        self.components.set(InputTargetComponent())
        let collisionBoxDepth: Float = 0.025
        let collisionBox = ShapeResource.generateBox(width: size.x, height: size.y, depth: collisionBoxDepth)
            .offsetBy(translation: [0, 0, -collisionBoxDepth / 2])
        self.components.set(CollisionComponent(shapes: [collisionBox]))
    }
    
    /// The custom initializer.
    ///
    /// Sets up the `heightMapMesh` with given size, dimensions, and maximum vertex depth.
    init(size: SIMD2<Float>, dimensions: SIMD2<UInt32>, maxVertexDepth: Float) {
        super.init()
        setup(size: size, dimensions: dimensions, maxVertexDepth: maxVertexDepth)
    }
    
    /// The default initializer.
    required init() {
        super.init()
        setup(size: [1, 1], dimensions: [512, 512], maxVertexDepth: 1)
    }
}
```

The following video shows a `HeightMapMeshEntity` displaying the mesh its `HeightMapMesh` generates with the `SineWaveHeightMapGenerator`.
### 
To start, the sample captures the person’s interaction position and state with a , passing that information to `HeightMapMesh`:
The sample allows the mesh to respond to a person’s interactions by passing interaction data to the GPU, which uses it to modify the height map, which in turn updates the vertices of the mesh.
To start, the sample captures the person’s interaction position and state with a , passing that information to `HeightMapMesh`:
```swift
.gesture(
    DragGesture()
        .targetedToEntity(heightMapMeshEntity)
        .onChanged({ value in
            let interactionPosition = value.convert(value.location3D,
                                                    from: .local,
                                                    to: heightMapMeshEntity)
            heightMapMeshEntity.heightMapMesh?.interactionPosition = interactionPosition
            heightMapMeshEntity.heightMapMesh?.isInteractionHappening = true
        })
        .onEnded({ value in
            heightMapMeshEntity.heightMapMesh?.isInteractionHappening = false
        })
)
```

`HeightMapMesh` passes this interaction information to the active `HeightMapGenerator`, which can use it to generate its height map.
`HeightMapMesh` passes this interaction information to the active `HeightMapGenerator`, which can use it to generate its height map.
For example, `WaterSurfaceHeightMapGenerator` takes the interaction position and passes it to a compute shader with a custom structure that the sample defines in an MSL header file:
```cpp
struct WaterParams {
    float deltaTime;
    float waterSpeed;
    simd_float2 disturbancePosition;
    float disturbanceRadius;
    float disturbanceAmount;
    simd_uint2 dimensions;
    simd_float2 size;
    simd_float2 cellSize;
};
```

```
It dispatches a compute shader to disturb the height of the water at the `interactionPosition` whenever an interaction is happening, by storing the interaction position in this structure’s `disturbancePosition` property:
```swift
class WaterSurfaceHeightMapGenerator: HeightMapGenerator {
    ...

    // Disturbs the water surface by dispatching a compute shader that increases/decreases the height
    // of the water around the disturbance position.
    func disturbWaterSurface(computeContext: ComputeUpdateContext,
                             heightMapTexture: LowLevelTexture,
                             heightMapComputeParams: HeightMapComputeParams,
                             waterParams: inout WaterParams) {
        // Dispatch the disturbance compute function.
        computeContext.computeEncoder.setComputePipelineState(disturbWaterSurfacePipeline)
        computeContext.computeEncoder.setBytes(&waterParams, length: MemoryLayout<WaterParams>.size, index: 0)
        computeContext.computeEncoder.setTexture(heightMapTexture.read(), index: 1)
        computeContext.computeEncoder.setTexture(heightMapTexture.replace(using: computeContext.commandBuffer), index: 2)
        computeContext.computeEncoder.dispatchThreadgroups(heightMapComputeParams.threadgroups,
                                                           threadsPerThreadgroup: heightMapComputeParams.threadsPerThreadgroup)
    }
    
    ...
    
    func generateHeightMap(computeContext: ComputeUpdateContext,
                           heightMapTexture: LowLevelTexture,
                           heightMapComputeParams: HeightMapComputeParams) {
        ...
        
        // Disturb the water surface downward at the position the person is interacting with it,
        // if an interaction is happening.
        if heightMapComputeParams.isInteractionHappening {
            waterParams.disturbancePosition = simd_make_float2(heightMapComputeParams.interactionPosition)
            waterParams.disturbanceRadius = 7 * waterParams.cellSize.x
            waterParams.disturbanceAmount = 250 * waterParams.cellSize.x * waterParams.deltaTime
            disturbWaterSurface(computeContext: computeContext,
                                heightMapTexture: heightMapTexture,
                                heightMapComputeParams: heightMapComputeParams,
                                waterParams: &waterParams)
        }
        
        ...
    }
}
```

```
The `disturbWaterSurface` compute shader function subtracts height from the height map around the disturbance position, simulating the effect of the person’s interaction pushing the water downward:
```cpp
[[kernel]]
void disturbWaterSurface(constant WaterParams &params [[buffer(0)]],
                         texture2d<float, access::read> heightMapIn [[texture(1)]],
                         texture2d<float, access::write> heightMapOut [[texture(2)]],
                         uint2 pixelCoords [[thread_position_in_grid]]) {
    // Skip out-of-bounds threads.
    // https://developer.apple.com/documentation/metal/compute_passes/calculating_threadgroup_and_grid_sizes
    if (any(pixelCoords >= params.dimensions)) { return; }

    // Get the current state of the height map.
    float4 heightMapData = heightMapIn.read(pixelCoords);
    
    // Convert the position of the current pixel to the same coordinate space as the disturbance position.
    float2 currentPosition = float2(remap(pixelCoords.x, float2(0, params.dimensions.x - 1), float2(-params.size.x / 2, params.size.x / 2)),
                                    remap(pixelCoords.y, float2(0, params.dimensions.y - 1), float2(-params.size.y / 2, params.size.y / 2)));
    // Disturb the height of the water closer to the disturbance position.
    float distance = length(currentPosition-params.disturbancePosition);
    if (distance <= params.disturbanceRadius) {
        heightMapData.a -= params.disturbanceAmount * pow((params.disturbanceRadius-distance)/(params.disturbanceRadius), 2);
    }
    
    // Write modified height map data back to the height map.
    heightMapOut.write(heightMapData, pixelCoords);
}
```


## Handling different-sized objects in physics simulations
> https://developer.apple.com/documentation/realitykit/handling-different-sized-objects-in-physics-simulations

### 
#### 
#### 
To set up a scene like this, instead of using the  as both the scene root and the physics origin, add two empty entities as children of the anchor before adding any entities or a Reality Composer scene. One of the two entities functions as the scene root and the other acts as the physics origin. The following code shows how to set up a hierarchy like this:
```swift
// Create an anchor entity.
let myAnchor = AnchorEntity()

// Create the scene root.
let sceneRootEntity = Entity()
sceneRootEntity.name = "Scene Root"
myAnchor.addChild(sceneRootEntity)

// Create the physics origin.
let physicsRootEntity = Entity()
physicsOriginEntity.name = "Physics Origin"
myAnchor.addChild(physicsOriginEntity)

// Add the anchor and specify the physics origin.
arView.scene.addAnchor(myAnchor);
self.arView.physicsOrigin = physicsOriginEntity
```


## Implementing postprocess effects using Metal compute functions
> https://developer.apple.com/documentation/realitykit/implementing-postprocess-effects-using-metal-compute-functions

### 
#### 
#### 
Add a new file to your Xcode project using the Metal File template. It doesn’t matter what filename you choose because Metal loads compute functions by the function name. As long as you include the file that contains the compute function in your build target, Metal is able to find and load it at runtime. A postprocess compute function executes once for each pixel in the rendered scene and is responsible for setting the final color of its pixel.
Here’s a compute function that inverts every pixel of a passed framebuffer.
```other
[[kernel]]
void postProcessInvert(uint2 gid [[thread_position_in_grid]],
                       texture2d<half, access::read> inColor [[texture(0)]],
                       texture2d<half, access::write> outColor [[texture(1)]])
{
    // Check to make sure that the specified thread_position_in_grid value is
    // within the bounds of the framebuffer. This ensures that non-uniform size
    // threadgroups don't trigger an error. For more information, see:
    // https://developer.apple.com/documentation/metal/calculating_threadgroup_and_grid_sizes
    if (gid.x >= inColor.get_width() || gid.y >= inColor.get_height()) {    
        return;
    }

    // Invert the pixel's color by subtracting it from 1.0.
    outColor.write(1.0 - inColor.read(gid), gid);
}
```

#### 
To use the Metal compute function in your  render callback, retrieve the default , then load your compute function and store the resulting  object. Load the pipeline state object during startup and store it in a property because you’ll need it in your postprocess callback. A good place to create and store it is in a  render callback, which RealityKit calls once it has finished its setup but before it renders the next frame and passes it a reference to the  where the scene displays. If you assign the callback during app startup, RealityKit calls your method before it renders the first frame.
Here’s an example that loads the invert compute function from above and stores its pipeline state object in a property.
```swift
func loadPostprocessingShader(device: MTLDevice) {
    guard let library = device.makeDefaultLibrary() else {
        fatalError()
    }

    if let invertKernel = library.makeFunction(name: "postProcessInvert") {
        // Create a pipeline state object and store it in a property.
        invertPipeline = try? device.makeComputePipelineState(function: invertKernel)
    }
} 
```

```
To make RealityKit call your function, assign it to the  property of the  property on your  during app startup.
```swift
arView.renderCallbacks.postProcess = loadPostprocessingShader
```

#### 
Because the sample compute function above defines `inColor` as `[[texture(0)]]`, you need to use an index value of `0` when calling  to pass . You can also use  to pass non-texture data to your compute function. For more information on using that  to pass non-texture data, see .
Once you’ve assigned the needed textures and data to the encoder, use  to start the compute function.
```swift
func postProcess(context: ARView.PostProcessContext) {
    guard let encoder = context.commandBuffer.makeComputeCommandEncoder() else {
        return
    }

    encoder.setComputePipelineState(pipeline)
    encoder.setTexture(context.sourceColorTexture, index: 0)
    encoder.setTexture(context.compatibleTargetTexture, index: 1)

    let threadsPerGrid = MTLSize(width: context.sourceColorTexture.width,
                                 height: context.sourceColorTexture.height,
                                 depth: 1)

    let w = pixelatePipeline.threadExecutionWidth
    let h = pixelatePipeline.maxTotalThreadsPerThreadgroup / w
    let threadsPerThreadgroup = MTLSizeMake(w, h, 1)

    encoder.dispatchThreads(threadsPerGrid,
                            threadsPerThreadgroup: threadsPerThreadgroup)
    encoder.endEncoding()
}
```

#### 
To apply the effect, register the function as the  render callback for the .
```swift
arView.renderCallbacks.postProcess = postProcess
```


## Implementing scene understanding and reconstruction in your RealityKit app
> https://developer.apple.com/documentation/realitykit/realitykit-scene-understanding

### 
#### 
To enable scene-understanding in an iOS or macOS RealityKit app, insert options into  like this:
```swift
arView.environment.sceneUnderstanding.options.insert(.occlusion)
arView.environment.sceneUnderstanding.options.insert(.physics)
arView.environment.sceneUnderstanding.options.insert(.collision)
arView.environment.sceneUnderstanding.options.insert(.receivesLighting)
```

```
Or, if you’re using , you can configure the same options using .
```swift
let session = SpatialTrackingSession()
let config = SpatialTrackingSession.Configuration(
    tracking:[],
    sceneUnderstanding:[
        .occlusion,
        .physics,
        .collision,
        .shadow
])
await session.run(config)
```

#### 
After turning on scene-understanding options, RealityKit automatically generates entities representing real-world geometry with a .
You can get these entities by using an . Here’s an example of rendering a custom debug material with scene-understanding meshes:
```swift
var debugMaterial = UnlitMaterial(color: .green)
debugMaterial.triangleFillMode = .lines

let sceneUnderstandingQuery = EntityQuery(where: .has(SceneUnderstandingComponent.self) && .has(ModelComponent.self))
let queryResult = scene.performQuery(sceneUnderstandingQuery)
queryResult.forEach { entity in
    entity.components[ModelComponent.self]?.materials = [debugMaterial]
}
```

With  or , scene-understanding meshes can participate in physics simulations and collision events.
Here’s an example of identifying scene-understanding meshes in a collision event:
```swift
let _ = content.subscribe(to: CollisionEvents.Began.self) { event in
    if event.entityA.components.has(SceneUnderstandingComponent.self) {
        // The entityA is a scene-understanding mesh.
    }
}
```

#### 
#### 
To enable scene reconstruction for a visionOS app, use a .
```swift
let arSession = ARKitSession()
let sceneReconstruction = SceneReconstructionProvider(modes: [])

Task {
    do {
        try await arSession.run([sceneReconstruction])
    } catch {
        // Handle the error.
    }
}
```


## Implementing systems for entities in a scene
> https://developer.apple.com/documentation/realitykit/implementing-systems-for-entities-in-a-scene

### 
#### 
Create a system by a creating a class that conforms to the  protocol and implements two methods:  and . Perform the setup for your system in , or add an empty implementation if your system doesn’t need any setup. Add the logic needed to run your system in , which RealityKit calls every frame automatically.
```swift
class MySystem: System {
    required init(scene: Scene) { 
        // Perform required initialization or setup.
    }

    func update(context: SceneUpdateContext) {
        // RealityKit automatically calls this on
        // every update for every scene.
    }
}
```

#### 
To efficiently retrieve entities from a scene, use an , which you can use to fetch all entities, or just a subset of entities relevant to your system. While some systems operate on every entity in the scene, most only operate on a defined subset, often based on the entities’ components. A physics simulation system, for example, only needs to operate on entities that participate in the scene’s physics simulation and a rendering system only needs to operate on entities that are visible. To retrieve a subset of your scene’s entities, create a  with your criteria and pass the predicate into the initializer when creating your entity query.
Create your query as a static property of your system unless your query criteria changes between update calls. If the criteria changes between update calls, create the query in your update method. Use the entity query with  in your  method to iterate over all the entities that your system depends on.
```swift
struct MyComponent: Component {
    // Optionally, put any needed state here.
}

class MySystem: System {

    // Define a query to return all entities with a MyComponent.
    private static let query = EntityQuery(where: .has(MyComponent.self))

    // Initializer is required. Use an empty implementation if there's no setup needed.
    required init(scene: Scene) { }

    // Iterate through all entities containing a MyComponent.
    func update(context: SceneUpdateContext) {
        for entity in context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        ) {
            // Make per-update changes to each entity here.
        }
    }
}
```

#### 
#### 
If a system relies on another system to function, or if you need to specify the update order for multiple systems, declare a  array in your system. To tell RealityKit that a dependency must update before your system, use the  enumeration case, passing the other system as a parameter. For dependencies that must update after your system, use , instead.
```swift
class SystemB: RealityKit.System {
    static var dependencies: [SystemDependency] { 
        [.after(SystemA.self),        // Run SystemB after SystemA.
         .before(SystemC.self)]       // Run SystemB before SystemC.
     }
    // ... 
}
```

#### 
You don’t create  instances manually. RealityKit creates them for you, but only if you tell RealityKit about your system by calling its  method before displaying your app’s . Once you’ve registered your system, RealityKit automatically creates an instance on your system for every active scene, then repeatedly calls its  method every scene update.
```swift
MySystem.registerSystem()
```


## Improving the Accessibility of RealityKit Apps
> https://developer.apple.com/documentation/realitykit/improving-the-accessibility-of-realitykit-apps

### 
#### 
#### 
You can also configure entities to work with assistive technologies in code. To enable accessibility support for an , set its   property to `True` and provide a short descriptive name using . If you want to provide a more detailed description, set .
Because these properties were introduced in iOS 14, any code that sets or reads their values should be wrapped in an availability macro if your project’s deployment target is iOS 13. Setting these values on an older version of iOS results in a runtime exception.
```swift
if #available(iOS 14.0, *) {
    ball.isAccessibilityElement = true
    ball.accessibilityLabel = "a bowling ball"
    ball.accessibilityDescription = "Tap and drag to roll the ball towards the pins."
}
```


## Improving the Performance of a RealityKit App
> https://developer.apple.com/documentation/realitykit/improving-the-performance-of-a-realitykit-app

### 
#### 
To address performance problems, you need data. RealityKit provides a debugging option to collect a basic set of statistics, like CPU utilization, ECS operations, and memory footprint. Add the  option to the  option set of your :
```swift
arView.debugOptions.insert(.showStatistics)
```

#### 
#### 
#### 
- Substitute simpler models with fewer polygons in place of your standard models.
- Reduce the rendering resolution by scaling the  property of the view, whose default value depends on the device:
```swift
// Capture the default value after you initialize the view.
let defaultScaleFactor = arView.contentScaleFactor

// Scale as needed. For example, here the scale factor is
// set to 75% of the default value.
arView.contentScaleFactor = 0.75 * defaultScaleFactor
```


## Loading entities from a file
> https://developer.apple.com/documentation/realitykit/loading-entities-from-a-file

### 
#### 
Use the `load(named:in:)` method to load an entity hierarchy from a USD or Reality file stored in a bundle. This method returns only after the operation completes. Omit the bundle parameter from the method call to load from the app’s main bundle:
```swift
let entity = try? Entity.load(named: "MyEntity") 
```

```
To load an entity stored at a specific location in the file system, create a file URL and use the  method instead:
```swift
let url = URL(fileURLWithPath: "path/to/MyEntity.usdz")
let entity = try? Entity.load(contentsOf: url)
```

#### 
Synchronous load operations block the thread on which you call them. To maintain a smooth user interface, use an asynchronous load instead. The entity initializer has an asynchronous overload. For example, load from a bundle asynchronously by calling the method:
```swift
_ = try! await Entity(named: "MyEntity")   // From the app's main bundle.
```

#### 
When you want to load a composition rooted by an anchor entity, you can instead use the  method, or one of its siblings. These methods behave like the related load methods, except that they specifically return an  instance that you can add to your scene:
```swift
if let anchor = try? Entity.loadAnchor(named: "MyEntity") {
    arView.scene.addAnchor(anchor)
}
```

#### 

## Loading remote assets in multiplayer apps
> https://developer.apple.com/documentation/realitykit/loading-remote-assets

### 
### 
### 
### 
If you’re not able to load all assets ahead of time, one way to ensure that all peers have finished loading assets is to broadcast a message using  when each peer is done loading. The host app can then keep track of which peers have sent that message and only add the resources to the  once all peers have notified it that they have finished loading. You can also have your app broadcast a different message when a peer is unable to load a particular asset. If a peer is unable to load an asset, the host can choose to send that peer a copy of the resource or to disconnect that peer.
Here’s a simple example of sending a sync message to connected peers:
```swift
enum SyncMessage: String {
    case beganAssetLoad
    case assetLoadFinishedSuccessfully
    case assetLoadFailed
}

private func notifyPeers(message: SyncMessage) {
    do {
        let messageData = Data(message.rawValue.utf8)
        let messageJSON = try JSONEncoder().encode(messageData)
        try session.send(messageJSON, toPeers: myPeers, with: .reliable)
    } catch {
        // Handle error here.
    }
}
```

### 

## Modifying RealityKit rendering using custom materials
> https://developer.apple.com/documentation/realitykit/modifying-realitykit-rendering-using-custom-materials

### 
#### 
To use a custom material, first write a surface shader in Metal. Start by adding a new file to your Xcode project using the Metal File template. You can use any function name you want for your surface shader, but you must prefix your function with the `[[visible]]` keyword. Your function must have no return value and take a single parameter of type `realitykit::surface_parameters`.
The following code listing shows an empty surface shader:
```cpp
#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;

[[visible]]
void myEmptyShader(realitykit::surface_parameters params)
{

}
```

Here are the accessor methods on `realitykit::surface_parameters`, along with what you use them for:
The following surface shader calculates and sets the fragment’s base color based on the `tint` and `color` values from the material’s  property.
Here are the accessor methods on `realitykit::surface_parameters`, along with what you use them for:
The following surface shader calculates and sets the fragment’s base color based on the `tint` and `color` values from the material’s  property.
```cpp
#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;

constexpr sampler textureSampler(address::clamp_to_edge, filter::bicubic);

[[visible]]
void mySurfaceShader(realitykit::surface_parameters params)
{
    // Retrieve the base color tint from the entity's material.
    half3 baseColorTint = (half3)params.material_constants().base_color_tint();

    // Retrieve the entity's texture coordinates.
    float2 uv = params.geometry().uv0();

    // Flip the texture coordinates y-axis. This is only needed for entities
    // loaded from USDZ or .reality files.
    uv.y = 1.0 - uv.y;

    // Sample a value from the material's base color texture based on the 
    // flipped UV coordinates.
    auto tex = params.textures();
    half3 color = (half3)tex.base_color().sample(textureSampler, uv).rgb;

    // Multiply the tint by the sampled value from the texture, and
    // assign the result to the shader's base color property.
    color *= baseColorTint;
    params.surface().set_base_color(color);
}
```

#### 
As with surface shaders, you can name your geometry modifier function anything you want, but you must prefix it with the `[[visible]]` keyword. A geometry shader must have no return value and take a single parameter of type `realitykit::geometry_parameters`.
The following code shows an empty geometry modifier.
```cpp
#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

[[visible]]
void emptyGeometryModifier(realitykit::geometry_parameters params)
{
}
```

To move vertices before RealityKit renders your entity, call `params.geometry().set_model_position_offset()` or `params.geometry().set_world_position_offset()` with the amount to offset the vertex. Changes made in the geometry modifier only affect how RealityKit renders the model; they don’t affect the original entity in the RealityKit scene. For example, moving a model to a new location in the geometry modifier won’t affect its location for collision detection or other physics calculation.
The following example implements a simple geometry shader that moves every vertex along the z-axis by an amount calculated from the elapsed time.
```cpp
#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

[[visible]]
void simpleGeometryModifier(realitykit::geometry_parameters params)
{
    float3 zOffset = float3(0.0, 0.0, params.uniforms().time() / 50.0);
    params.geometry().set_world_position_offset(zOffset);
}
```

#### 
To create a custom material for an entity, first load the Metal library that contains your shader functions, then load the functions by name, as the following sample code demonstrates:
```swift
// Get the Metal Device.
guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("Error creating default metal device.")
}

// Get a reference to the Metal library.
let library = device.makeDefaultLibrary()

// Load a geometry modifier function named myGeometryModifier.
let geometryModifier = CustomMaterial.GeometryModifier(named: "myGeometryModifier", 
                                                       in: library)

// Load a surface shader function named mySurfaceShader.
let surfaceShader = CustomMaterial.SurfaceShader(named: "mySurfaceShader", 
                                                 in: library)
```

#### 
| `.clearcoat` | Uses PBR techniques, including clearcoat. | All |
| `.unlit` | Renders without any shading or lighting calculations. The result is similar to using an . | Uses `set_emissive_color()` only |
#### 
In your Swift code, create a custom material using your loaded shader functions and selected lighting model. To create a custom material from scratch, use , as the following code demonstrates:
```swift
let customMaterial: CustomMaterial
do {
    try customMaterial = CustomMaterial(surfaceShader: surfaceShader,
                                        geometryModifier: geometryModifier,
                                        lightingModel: .lit)
} catch {
    fatalError(error.localizedDescription)
}

let mesh = MeshResource.generateSphere(radius: 0.5 )
let modelEntity = ModelEntity(mesh: mesh, materials: [customMaterial])
```

```
Alternatively, you can create a custom material from a model’s existing material. When working with entities loaded from USDZ or `.reality` files, this approach preserves all of the material attributes from the original file. The following code demonstrates loading a model and creating a custom material based on the entity’s existing material:
```swift
// Load a USDZ from the file system.
guard let robot = try? Entity.load(named: "Robot") else { 
    return 
}

// Make sure the entity has a ModelComponent.
guard var modelComponent = robot.components[ModelComponent.self] else { 
    return 
}

// Loop through the entity's materials and replace the existing material with
// one based on the original material.
guard let customMaterials = try? modelComponent.materials.map({ material -> CustomMaterial in
    let customMaterial = try CustomMaterial(from: material, surfaceShader: surfaceShader)
    return customMaterial
}) else { return}
modelComponent.materials = customMaterials
robot.components[ModelComponent.self] = modelComponent
```


## Passing Metal command objects around your application
> https://developer.apple.com/documentation/realitykit/passing-metal-command-objects-around-your-application

### 
### 
Start by creating a structure that contains the context necessary to dispatch compute shader functions in every frame:
```swift
/// A structure containing the context a `ComputeSystem` needs to dispatch compute commands in every frame.
struct ComputeUpdateContext {
    /// The number of seconds elapsed since the last frame.
    let deltaTime: TimeInterval
    /// The command buffer for the current frame.
    let commandBuffer: MTLCommandBuffer
    /// The compute command encoder for the current frame.
    let computeEncoder: MTLComputeCommandEncoder
}
```

You can choose not to include the `deltaTime` property in your structure, or you can add additional properties, such as .
Next, define a protocol with an update method that takes `ComputeUpdateContext` as a parameter:
You can choose not to include the `deltaTime` property in your structure, or you can add additional properties, such as .
Next, define a protocol with an update method that takes `ComputeUpdateContext` as a parameter:
```swift
/// A protocol that enables its adoptees to dispatch their own compute commands in every frame.
protocol ComputeSystem {
    @MainActor
    func update(computeContext: ComputeUpdateContext)
}
```

### 
Create a component that holds a `ComputeSystem`:
Create a component that holds a `ComputeSystem`:
```swift
/// A component that contains a `ComputeSystem`.
struct ComputeSystemComponent: Component {
    let computeSystem: ComputeSystem
}
```

```
Then, create a custom  that finds all entities with a `ComputeSystemComponent` in every frame and passes that frame’s `ComputeUpdateContext` to their `ComputeSystem` instances:
```swift
/// A class that updates the `ComputeSystem` of each `ComputeSystemComponent` with `ComputeUpdateContext` in every frame.
class ComputeDispatchSystem: System {
    /// The application's command queue.
    ///
    /// A single, global command queue to use throughout the entire application.
    static let commandQueue: MTLCommandQueue? = makeCommandQueue(labeled: "Compute Dispatch System Command Queue")
    
    /// The query this system uses to get all entities with a `ComputeSystemComponent` in every frame.
    let query = EntityQuery(where: .has(ComputeSystemComponent.self))
    
    required init(scene: Scene) { }
    
    /// Updates all compute systems with the current frame's `ComputeUpdateContext`.
    func update(context: SceneUpdateContext) {
        // Get all entities with a `ComputeSystemComponent` in every frame.
        let computeSystemEntities = context.entities(matching: query, updatingSystemWhen: .rendering)
        
        // Create the command buffer and compute encoder responsible for dispatching all compute commands this frame.
        guard let commandBuffer = Self.commandQueue?.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        
        // Enqueue the command buffer.
        commandBuffer.enqueue()
        
        // Dispatch all compute systems to encode their compute commands.
        let computeContext = ComputeUpdateContext(deltaTime: context.deltaTime,
                                                  commandBuffer: commandBuffer,
                                                  computeEncoder: computeEncoder)
        for computeSystemEntity in computeSystemEntities {
            if let computeSystemComponent = computeSystemEntity.components[ComputeSystemComponent.self] {
                computeSystemComponent.computeSystem.update(computeContext: computeContext)
            }
        }
        
        // Stop encoding compute commands and commit them to run on the GPU.
        computeEncoder.endEncoding()
        commandBuffer.commit()
    }
}
```

```
In this example, a helper method assists in the creation of the Metal command queue:
```swift
/// The device Metal selects as the default.
let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()

/// Makes a command queue with the given label.
func makeCommandQueue(labeled label: String) -> MTLCommandQueue? {
    guard let metalDevice, let queue = metalDevice.makeCommandQueue() else {
        return nil
    }
    queue.label = label
    return queue
}
```

### 
You can dispatch your compute shader functions in every frame by creating a custom `ComputeSystem` and implementing its `update` method:
You can dispatch your compute shader functions in every frame by creating a custom `ComputeSystem` and implementing its `update` method:
```swift
struct MyComputeSystem: ComputeSystem {
    func update(computeContext: ComputeUpdateContext) {
        // Dispatch compute shader functions here.
    }
}
```

Be sure to register the `ComputeDispatchSystem` so that the `update` method fires every frame:
```
Be sure to register the `ComputeDispatchSystem` so that the `update` method fires every frame:
```swift
ComputeDispatchSystem.registerSystem()
```

Finally, attach your custom `ComputeSystem` to an entity with a `ComputeSystemComponent`:
```
Finally, attach your custom `ComputeSystem` to an entity with a `ComputeSystemComponent`:
```swift
let myComputeSystem = MyComputeSystem()
let myComputeEntity = Entity()
myComputeEntity.components.set(ComputeSystemComponent(computeSystem: myComputeSystem))
```


## Passing Structured Data to a Metal Compute Function
> https://developer.apple.com/documentation/realitykit/passing-structured-data-to-a-metal-compute-function

### 
#### 
Create a new header file in your Xcode project. In the file, define a C struct with the properties you need to send from Swift to your Metal compute function. The struct should only contain simple datatypes. Don’t pass textures, samplers, or other complex objects in your struct. Also, don’t use any datatype that doesn’t have a consistent size in both Metal and Swift and on all devices. An `int` datatype, for example, can have different sizes on different devices. Instead, use datatypes like `int32_t`, `uint16_t`, or `float`, which are the same size everywhere.
```occ
#include <simd/simd.h>

#ifndef MyArguments_h
#define MyArguments_h
struct MyArguments
{
    float widgetTolerance
    uint32_t widgetHeight;
};
#endif /* MyArguments_h */
```

#### 
If your project already has a bridging header, import the struct header file in it. If your project doesn’t have a bridging header, create a new header file in your project to import the struct’s header. By importing using a bridging header, Swift sees the C struct as a Swift struct. Because Metal is a superset of C++, which is a superset of C, Metal interprets the same struct as a Metal struct.
```occ
#import "MyArguments.h"
```

```
If you created a new bridging header, you must tell Xcode that it’s your project’s bridging header. To do that, go to the build settings for your target and look for a setting called Objective-C Bridging Header. Set it to the path of the bridging header file you created. Don’t use an absolute path. Instead, create a path relative to `$(PROJECT_DIR)`, which points to your project’s main directory. Your entry should look something like this:
```other
$(PROJECT_DIR)/$(PROJECT_NAME)/MyProject-Bridging-Header.h
```

#### 
In your Swift code, create an instance of the struct to hold the values to send to your compute function. Then, in the code that dispatches your compute function, call  and pass the struct as a data buffer before you call  to execute the compute function.
```swift
var args = MyArguments(widgetTolerance: 0.3493, widgetHeight: 5)
encoder.setBytes(&args, length: MemoryLayout<MyArguments>.stride, index: 0)
```

#### 
In the Metal file that contains your compute function, include the new header file after including .
```other
#include <metal_stdlib>
#include "MyArguments.h" 

using namespace metal;
```

```
In your compute function, retrieve the buffer using `[[buffer(``)]]` and cast it to your struct. Metal allows you to do that as a function parameter, or you can retrieve it in the body of your function and store it in a variable. Make sure the index value you pass to `[[buffer(``)]]` matches the index value you used in your  call. Your compute function can access members of the retrieved struct using the `->` operator.
```other
[[kernel]]
void myPostProcess(uint2 gid [[thread_position_in_grid]],
                         texture2d<half, access::read> inColor [[texture(0)]],
                         texture2d<half, access::write> outColor [[texture(1)]],
                         constant MyArguments *args [[buffer(0)]])
{
    auto widgetHeight = args->widgetHeight;
    auto widgetTolerance = args->widgetTolerance;

    // Your compute function logic goes here.
}
```


## Presenting images in RealityKit
> https://developer.apple.com/documentation/realitykit/presenting-images-in-realitykit

### 
### 
This sample displays images using `mono` and `spatial3D` viewing modes.
### 
To display an image, create an  and attach it to an entity in your scene. You can attach it to any entity, and you’ll also want to attach it to one that has no visual representation in your scene. This sample creates an empty  property called `contentEntity` in the `AppModel` class for that purpose.
```swift
var contentEntity: Entity = Entity()
```

In the  `make` closure, the app calls an asynchronous method to create an  and adds it to `contentEntity`.
```
In the  `make` closure, the app calls an asynchronous method to create an  and adds it to `contentEntity`.
```swift
await appModel.createImagePresentationComponent()
```

```
The `createImagePresentationComponent` function creates an  from a 2D image, then creates an image presentation component with that image and attaches it to the `contentEntity`:
```swift
func createImagePresentationComponent() async {
    guard let imageURL else {
        print("ImageURL is nil.")
        return
    }
    spatial3DImageState = .notGenerated
    spatial3DImage = nil
    do {
        spatial3DImage = try await ImagePresentationComponent.Spatial3DImage(contentsOf: imageURL)
    } catch {
        print("Unable to initialize spatial 3D image: \(error.localizedDescription)")
    }

    guard let spatial3DImage else {
        print("Spatial3DImage is nil.")
        return
    }
    
    let imagePresentationComponent = ImagePresentationComponent(spatial3DImage: spatial3DImage)
    contentEntity.components.set(imagePresentationComponent)
    if let aspectRatio = imagePresentationComponent.aspectRatio(for: .mono) {
        imageAspectRatio = CGFloat(aspectRatio)
    }
}
```

The `createImagePresentationComponent` method stores the  of the newly created ImagePresentationComponent in the `AppModel`.
The app implements an   modifier for `aspectRatio` in the `AppModel` to ensure that the  size matches the image.
The `createImagePresentationComponent` method stores the  of the newly created ImagePresentationComponent in the `AppModel`.
The app implements an   modifier for `aspectRatio` in the `AppModel` to ensure that the  size matches the image.
```swift
.onChange(of: appModel.imageAspectRatio) { _, newAspectRatio in
    guard let windowScene = sceneDelegate.windowScene else {
        print("Unable to get the window scene. Resizing is not possible.")
        return
    }

    let windowSceneSize = windowScene.effectiveGeometry.coordinateSpace.bounds.size

    //  width / height = aspect ratio
    // Change ONLY the width to match the aspect ratio.
    let width = newAspectRatio * windowSceneSize.height

    // Keep the height the same.
    let size = CGSize(width: width, height: UIProposedSceneSizeNoPreference)

    UIView.performWithoutAnimation {
        // Update the scene size.
        windowScene.requestGeometryUpdate(.Vision(size: size))
    }
}
```

### 
In the `update` closure of the , the app retrieves the presentation screen size of the image presentation component using the entity’s  property. This ensures that update is called when the `presentationScreenSize` changes.
```swift
guard let presentationScreenSize = appModel
    .contentEntity
    .observable
    .components[ImagePresentationComponent.self]?
    .presentationScreenSize, presentationScreenSize != .zero else {
        print("Unable to get a valid presentation screen size from the content entity.")
        return
}
```

The app sets the z axis position of the `contentEntity` to 0.0. This displays the image presentation component flush against the background.
```
The app sets the z axis position of the `contentEntity` to 0.0. This displays the image presentation component flush against the background.
```swift
let originalPosition = appModel.contentEntity.position(relativeTo: nil)
appModel.contentEntity.setPosition(SIMD3<Float>(originalPosition.x, originalPosition.y, 0.0), relativeTo: nil)
```

```
To display the image at an appropriate size, the app wraps a  inside a :
```swift
GeometryReader3D { geometry in
    RealityView { content in
```

In the `make` and `update` closure of the , the app converts the geometry reader’s frame bounds into the scene’s coordinate space:
```
In the `make` and `update` closure of the , the app converts the geometry reader’s frame bounds into the scene’s coordinate space:
```swift
let availableBounds = content.convert(geometry.frame(in: .local), from: .local, to: .scene)
```

Then, the app calls the `scaleImagePresentationToFit` method which scales the image to fit into the geometry reader’s frame bounds:
```
Then, the app calls the `scaleImagePresentationToFit` method which scales the image to fit into the geometry reader’s frame bounds:
```swift
scaleImagePresentationToFit(in: availableBounds)
```

```
The `scaleImagePresentationToFit` method calculates x and y scale values to preserve the aspect ratio of the presented image at the current , and sets those scale values as the content entity’s scale:
```swift
func scaleImagePresentationToFit(in boundsInMeters: BoundingBox) {
    guard let imagePresentationComponent = appModel.contentEntity.components[ImagePresentationComponent.self] else {
        return
    }

    let presentationScreenSize = imagePresentationComponent.presentationScreenSize
    let scale = min(
        boundsInMeters.extents.x / presentationScreenSize.x,
        boundsInMeters.extents.y / presentationScreenSize.y
    )

    appModel.contentEntity.scale = SIMD3<Float>(scale, scale, 1.0)
}
```

### 
This sample adds the images to the component first, then generates the spatial scene on a button press. It does that by first declaring an enumeration in the app data model to represent the current status of the displayed image.
```swift
enum Spatial3DImageState {
    case notGenerated
    case generating
    case generated
}
```

```
The app currently displays a 2D image in an . When the viewer clicks the Show as 3D button for the first time, it checks to see if the spatial 3D image has been generated, and returns if it has to avoid doing unnecessary work.
```swift
guard spatial3DImageState == .notGenerated else {
    print("Spatial 3D image already generated or generation is in progress.")
    return
}
```

```
The viewing mode of the image presentation component changes to , calls  on the spatial 3D image it displays, and sets the image state to `.generated` so it knows not to generate it again:
```swift
guard var imagePresentationComponent = contentEntity.components[ImagePresentationComponent.self] else {
    print("ImagePresentationComponent is missing from the entity.")
    return
}
// Set the desired viewing mode before generating so that it will trigger the
// generation animation.
imagePresentationComponent.desiredViewingMode = .spatial3D
contentEntity.components.set(imagePresentationComponent)

// Generate the Spatial3DImage scene.
spatial3DImageState = .generating
try await spatial3DImage.generate()
spatial3DImageState = .generated
```


## Reducing CPU Utilization in Your RealityKit App
> https://developer.apple.com/documentation/realitykit/reducing-cpu-utilization-in-your-realitykit-app

### 
#### 
#### 
#### 
#### 
On the other hand, data synchronization can be a better option than repeated calculation of the same data. For example, it might be better to perform an expensive calculation that produces a small number of bytes only once, and share the result with other devices.
When using synchronization, try to minimize the number of synchronized entities. Each entity that requires synchronization consumes CPU time. You can turn off synchronization for a particular entity by deleting its  component:
```swift
entity.synchronization = nil
```

#### 
#### 

## Reducing GPU Utilization in Your RealityKit App
> https://developer.apple.com/documentation/realitykit/reducing-gpu-utilization-in-your-realitykit-app

### 
#### 
- Use multiple textures of varying sizes to cover a mesh that doesn’t require maximum resolution everywhere.
Reducing texture information also helps to reduce your app’s memory footprint. To estimate the amount of memory an uncompressed texture consumes in bytes, use the following formula:
```swift
memory = channels × width × height × 4/3
```

#### 
#### 
Polygon count doesn’t affect the time needed for effects like depth of field or motion blur. Nevertheless, these effects do consume GPU time. So carefully select which effects to include by balancing your app’s visual appearance requirements against its performance constraints.
You deactivate effects by adding options like  to the  option set, and activate the effect by removing the option:
```swift
// Turn off motion blur.
arView.renderOptions.insert(.disableMotionBlur)

// Turn on motion blur.
arView.renderOptions.remove(.disableMotionBlur)
```

#### 
#### 

## Rendering stereoscopic video with RealityKit
> https://developer.apple.com/documentation/realitykit/rendering-stereoscopic-video-with-realitykit

### 
`VideoMaterial` and `VideoPlayerComponent` offer two distinct options for controlling playback.
### 
The structure of the app is simple. `PlayerModel` is an  custom type that’s injected into the SwiftUI  for visibility to the root `ContentView`. This model includes a property of type `PlayerState`, which is a Swift enumeration that reflects the current player state. It also includes an instance of type `LoopingVideoPlayer`, which exposes the underlying `AVSampleBufferVideoRenderer`.
```swift
/// The main app structure.
@main
struct RealityKitPlaybackApp: App {
    /// An object that controls the video playback behavior.
    @State private var player = PlayerModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(player)
                .frame(width: 1600, height: 900)
        }
        // Expressly constrain window size to that of its content.
        .windowResizability(.contentSize)
        // Disable background glass.
        .windowStyle(.plain)
    }
}
```

### 
Use the `PlayerModel` as a property exposed from `ContentView`:
Use the `PlayerModel` as a property exposed from `ContentView`:
```swift
/// A reference to the player.
@Environment(PlayerModel.self) private var player
```

`ContentView` also defines an  to house the  at the root of this scene:
```
`ContentView` also defines an  to house the  at the root of this scene:
```swift
/// The root entity of the scene.
private let entity = Entity()
```

```
In the `RealityView` `make` closure, the app instantiates a `VideoPlayerComponent`, passing the player’s video renderer. It then adds the video player to the root entity. The sample uses `scaleFactor`, a type property set to `0.5`, to scale the root entity to half its default size.
```swift
RealityView { content in
    // Initialize the video player with the supplied renderer.
    let videoPlayerComponent = VideoPlayerComponent(videoRenderer: player.videoRenderer)
    entity.components.set(videoPlayerComponent)

    // Scale the root entity and add it to the view.
    entity.scale = SIMD3<Float>(repeating: Self.scaleFactor)
    content.add(entity)
}
// Set the frame to 0 so that the RealityView's origin exists on the same plane as the window.
.frame(depth: 0)
```

- 
- 
```swift
// Begin playback when ready.
.onChange(of: player.isReadyToPlay) { _, ready in
    if ready {
        player.play()
    }
}
// Monitor the scene phase and stop playback when entering the background.
.onChange(of: scenePhase) { _, scenePhase in
    if scenePhase == .background {
        player.stop()
    }
}
// Start loading the player.
.task {
    await player.load()
}
```

### 
`LoopingVideoPlayer` is a custom type that coordinates continuous playback of the sample video. To achieve this, it manages multiple instances of another custom type, `SerialProcessor`.
The player has two key properties: a video renderer and a synchronizer to control the rendering timeline:
```swift
/// The synchronizer that controls the underlying video renderer.
private let synchronizer = AVSampleBufferRenderSynchronizer()

/// The video renderer that enqueues individual frames for playback.
let videoRenderer = AVSampleBufferVideoRenderer()
```

```
When the system creates the player, it adds the renderer to the synchronizer, and initializes an  with a URL to the underlying video:
```swift
/// Initializes a player with the specified asset URL.
/// - Parameter assetURL: A URL for the asset that the app plays.
init(assetURL: URL) {
    synchronizer.addRenderer(videoRenderer)
    asset = AVURLAsset(url: assetURL)
}
```

```
To prepare for playback, the processor loads the asset duration asynchronously with . The sample uses duration to trigger looping at the end of each playback cycle with . The sample initializes the first serial processor with the video renderer and asset:
```swift
/// Begin loading the player.
func load() async throws {
    // Determine the duration of the underlying video asset.
    let duration = try await asset.load(.duration)

    // Use the asset duration as the boundary period with which to loop.
    timeObserver = synchronizer.addBoundaryTimeObserver(forTimes: [NSValue(time: duration)], queue: nil) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.loop(rate: self.synchronizer.rate)
        }
    }

    // Prepare the processor that the app uses for the initial playback loop.
    enqueueProcessor()
}
```

### 
The app begins playback by calling `loop(rate:)` for the first time. The initial rate of the render synchronizer is `0.0`, meaning that playback has stopped. Passing `1.0` starts playback at the natural rate of the media.
```swift
/// Begin playback by starting the loop.
func play() {
    guard !isLooping else { return }
    isLooping = true
    loop(rate: 1)
}
```

```
The app starts the loop by dequeueing a serial processor instance. It specifies the time and rate of the render synchronizer with . It then enqueues the next serial processor instance and increments the loop count:
```swift
/// Executes a logical playback loop.
/// - Parameter rate: The rate with which to playback content.
private func loop(rate: Float) {
    guard isLooping, let nextProcessor else {
        return
    }

    let currentProcessor = nextProcessor
    process(with: currentProcessor)
    synchronizer.setRate(rate, time: .zero)

    enqueueProcessor()
    loopCount += 1
}
```

```
The boundary time observer initiates subsequent loops. Playback continues until someone closes the scene. At that time, the sample calls `stop()` to dispose of the player’s resources:
```swift
/// End playback by stopping the loop and resetting relevant state.
func stop() {
    nextProcessor = nil
    isLooping = false
    loopCount = 0
    
    synchronizer.rate = 0
    if let timeObserver {
        synchronizer.removeTimeObserver(timeObserver)
        self.timeObserver = nil
    }

    if let loopingTask {
        loopingTask.cancel()
        self.loopingTask = nil
    }
}
```

### 
With side-by-side input, the sample places left- and right-eye images next to each other as part of a single frame. The sample splits the frame into separate images, copies them to distinct left- and right-eye layers, and writes them as a multi-layer frame.
The processor begins when the sample calls  to load video tracks, and then selects the first available track as the side-by-side input.
```swift
// Load the asset.
guard let videoTrack = try await asset.loadTracks(withMediaCharacteristic: .visual).first else {
    fatalError("Error loading side-by-side video input")
}
```

```
The processor also loads the natural size of the side-by-side video for later use:
```swift
// Determine the size of the video track, which reflects frame packing.
let videoFrameSize = try await videoTrack.load(.naturalSize)
```

```
The processor specifies  settings in its `readerSettings` dictionary. Because the sample manages its own pixel buffer allocations, it uses an empty array as the value corresponding to the  key. These settings create an . To finish loading the video, the sample obtains an output provider from the , and starts reading.
```swift
// Setup the asset reader.
let readerSettings: [String: Any] = [
    kCVPixelBufferIOSurfacePropertiesKey as String: [String: String]()
]
let videoTrackOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerSettings)
let assetReader = try AVAssetReader(asset: asset)
let videoTrackOutputProvider = assetReader.outputProvider(for: videoTrackOutput)
try assetReader.start()
```

### 
To prepare for processing the video input, the sample creates a  to read raw  input and write processed `CVPixelBuffers` as output.
To prepare for processing the video input, the sample creates a  to read raw  input and write processed `CVPixelBuffers` as output.
```swift
// Setup the pixel transfer session.
var transferSession: VTPixelTransferSession?
let sessionResult = VTPixelTransferSessionCreate(
    allocator: kCFAllocatorDefault,
    pixelTransferSessionOut: &transferSession
)
guard sessionResult == kCVReturnSuccess, let transferSession else {
    fatalError("Failed to create pixel transfer session: \(sessionResult)")
}
VTSessionSetProperty(transferSession, key: kVTPixelTransferPropertyKey_ScalingMode, value: kVTScalingMode_CropSourceToCleanAperture)
```

```
For efficiency, the sample creates a  to allocate pixel buffers for the processed multi-layer output. It creates a pool with attributes that include the pixel format type and size of the eye frame. The sample derives the eye frame size from the natural video size, previously loaded. It then merges these specified attributes with .
```swift
// Setup the pixel buffer pool.
let eyeFrameSize = CVImageSize(
    width: Int(videoFrameSize.width / stereoMetadata.horizontalScale),
    height: Int(videoFrameSize.height / stereoMetadata.verticalScale)
)
let defaultAttributes = CVPixelBufferCreationAttributes(
    pixelFormatType: CVPixelFormatType(rawValue: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
    size: eyeFrameSize
)
let recommendedAttributes = videoRenderer.recommendedPixelBufferAttributes
guard let mergedAttributes = CVPixelBufferAttributes(merging: [CVPixelBufferAttributes(defaultAttributes), recommendedAttributes]),
      let creationAttributes = CVPixelBufferCreationAttributes(mergedAttributes),
      let pixelBufferPool = try? CVMutablePixelBuffer.Pool(pixelBufferAttributes: creationAttributes)
else {
    fatalError("Failed to create pixel buffer pool")
}
```

### 
To begin processing, the processor waits for the video renderer to indicate that it is ready to begin rendering. The private `untilReadyForMoreMediaData()` function achieves this with a call to . As the sample reads the asset, the `videoTrackOutputProvider` supplies a stream of sample buffers for processing. As the sample receives these sample buffers, the processor calls `transform(from:with:in:)` to convert the side-by-side frame input into stereo-encoded output. The sample then enqueues the stereo-encoded frames to the video renderer. Processing concludes once the stream of sample buffers is exhausted.
```swift
// Explicitly tear down resources when processing concludes.
defer {
    videoRenderer.stopRequestingMediaData()
    assetReader.cancelReading()
    VTPixelTransferSessionInvalidate(transferSession)
}

// Monitor & process frames while renderer is ready.
for await _ in mediaDataReadyStream() {
    try Task.checkCancellation()

    while videoRenderer.isReadyForMoreMediaData {
        guard let sampleBuffer = try await videoTrackOutputProvider.next() else {
            return
        }

        if let transformedBuffer = try transform(from: sampleBuffer, with: pixelBufferPool, in: transferSession) {
            videoRenderer.enqueue(transformedBuffer)
        }
    }
}
```

### 
The processor creates individual left- and right-eye images in the transformation function. It specifies layer ID `0` for the left eye, and `1` for the right eye.
```None
let layerIDs = [0, 1]
let eyeComponents: [CMStereoViewComponents] = [.leftEye, .rightEye]
var taggedBuffers = [CMTaggedDynamicBuffer]()
for (layerID, eye) in zip(layerIDs, eyeComponents) {
    // ...
```

```
The function uses the `VTPixelTransferSession` to copy pixels from the side-by-side source pixel buffer, crop to the frame for the current eye, and place them into the destination pixel buffer.
```swift
// Crop the transfer region to the current eye.
let bufferSize = pixelBufferPool.pixelBufferAttributes.size
let apertureOffset = stereoMetadata.apertureOffset(for: bufferSize, layerID: layerID)
let cropRectDict = [
    kCVImageBufferCleanApertureHorizontalOffsetKey: apertureOffset.horizontal,
    kCVImageBufferCleanApertureVerticalOffsetKey: apertureOffset.vertical,
    kCVImageBufferCleanApertureWidthKey: bufferSize.width,
    kCVImageBufferCleanApertureHeightKey: bufferSize.height
]
CVBufferSetAttachment(sourceImageBuffer, kCVImageBufferCleanApertureKey, cropRectDict as CFDictionary, .shouldPropagate)
VTSessionSetProperty(transferSession, key: kVTPixelTransferPropertyKey_ScalingMode, value: kVTScalingMode_CropSourceToCleanAperture)

// Transfer the image to the pixel buffer.
pixelBuffer.withUnsafeBuffer { cvPixelBuffer in
    let transferResult = VTPixelTransferSessionTransferImage(transferSession, from: sourceImageBuffer, to: cvPixelBuffer)
    guard transferResult == kCVReturnSuccess else {
        fatalError("Error during pixel transfer session for layer \(layerID): \(transferResult)")
    }
}
```

```
The sample creates the individual left and right pixel buffers, adorns them with  metadata, and stores them as  pairs.
```swift
// Create and append a tagged buffer for this eye.
let tags: [CMTag] = [.videoLayerID(Int64(layerID)), .stereoView(eye), .mediaType(.video)]
taggedBuffers.append(CMTaggedDynamicBuffer(tags: tags, content: .pixelBuffer(CVReadOnlyPixelBuffer(pixelBuffer))))
```

```
Finally, the sample combines the tagged buffers with the presentation timestamp and duration of the input sample buffer and creates the final output sample buffer.
```swift
let buffer = CMReadySampleBuffer(
    taggedBuffers: taggedBuffers,
    formatDescription: CMTaggedBufferGroupFormatDescription(taggedBuffers: taggedBuffers),
    presentationTimeStamp: cmSampleBuffer.presentationTimeStamp,
    duration: cmSampleBuffer.duration
)
```


## Responding to gestures on an entity
> https://developer.apple.com/documentation/realitykit/responding-to-gestures-on-an-entity

### 
#### 
The sample defines the `ActiveComponent`, which keeps track of the `active` state of the entity.
The sample defines the `ActiveComponent`, which keeps track of the `active` state of the entity.
```swift
public class ActiveComponent: Component {
    public var active: Bool = false
}
```

This sample has one entity, a cube that’s `0.1` units in each direction. The sample creates the entity then adds the components.
```
This sample has one entity, a cube that’s `0.1` units in each direction. The sample creates the entity then adds the components.
```swift
var cube = ModelEntity(mesh: .generateBox(size: 0.1),
                       materials: [SimpleMaterial(color: .orange, isMetallic: false)])

cube.components.set(InputTargetComponent())
cube.components.set(CollisionComponent(shapes: [ShapeResource.generateBox(size: SIMD3<Float>(0.1, 0.1, 0.1))]))
cube.components.set(HoverEffectComponent())
cube.components.set(ActiveComponent())
```

```
The sample has a  attached to the `RealityView`. As the person interacting with the app looks around and pinches, the system uses the input target component and the collision component to determine intent. The system considers all entities in the scene because the sample calls . When the person pinches on the cube the system invokes the gesture’s `onEnded` block, which toggles the `active` flag.
```swift
.gesture(SpatialEventGesture()
    .targetedToAnyEntity()
    .onEnded { value in
        value.entity.components[ActiveComponent.self]?.active.toggle()
    })
```

The `attachments:` block creates an attachment with the name of the `cube` entity.
```
The `attachments:` block creates an attachment with the name of the `cube` entity.
```swift
attachments: {
    Attachment(id: cube.id) {
        Text("\(cube.name)")
            .padding()
            .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 5.0))
            .tag(cube.id)
    }
}
```

```
The attachment’s `id` is set to the ID of the `cube` so that it’s easy to find in the `update:` block of `RealityView`. In the `update:` block, the sample finds the `ActiveComponent` from the cube and then finds the attachment using the ID of the cube. If the active value is `true` the code adds a  to the attachment. The system ensures entities with a `BillboardComponent` always face the person. The `RealityView` `update` block adds the attachment entity as a subentity of the cube and sets the position to `[0.0, 0.1, 0.0]`.
```swift
update: { content, attachments in
    guard let component = cube.components[ActiveComponent.self] else { return }
    guard let attachmentEntity = attachments.entity(for: cube.id) else { return }
    if component.active {
        attachmentEntity.components.set(BillboardComponent())
        cube.addChild(attachmentEntity)
        attachmentEntity.setPosition(SIMD3<Float>(0.0, 0.1, 0.0),
                                     relativeTo: cube)
    } else {
        cube.removeChild(attachmentEntity)
    }
}
```


## Simulating particles in your visionOS app
> https://developer.apple.com/documentation/realitykit/simulating-particles-in-your-visionos-app

### 
#### 
You can turn any entity into a particle emitter, including one that’s already in your app’s scene. The app creates a new entity with the default initializer .
```swift
let emitterEntity = Entity()
```

#### 
Create a  instance by calling one of its initializers.
```swift
var emitterComponent = ParticleEmitterComponent()
```

```
You can also create a particle emitter from a preset by accessing one of the properties of the  type.
```swift
typealias Presets = ParticleEmitterComponent.Presets

switch presetSelection {
    case .default:
        emitterComponent = ParticleEmitterComponent()
    case .fireworks:
        emitterComponent = Presets.fireworks
    case .impact:
        emitterComponent = Presets.impact
    case .magic:
        emitterComponent = Presets.magic
    case .rain:
        emitterComponent = Presets.rain
    case .snow:
        emitterComponent = Presets.snow
    case .sparks:
        emitterComponent = Presets.sparks
}
```

#### 
Add the particle emitter  component to an entity by calling the  method of its  property.
```swift
// Add the particle component to the entity.
emitterEntity.components.set(emitterComponent)
```

#### 
Add the entity with the particle emitter component to the scene by calling the  method of the  instance from a .
```swift
// Add the emitter entity to the scene.
content.add(emitterEntity)
```

#### 
You can alter the behavior of a particle system by changing the values of a  instance’s properties. For example, the  property adjusts the starting speed of the particles as the emitter creates them, and the  property modifies how many times per second the emitter creates a new particle.
```swift
emitterComponent.speed = 0.2
emitterComponent.mainEmitter.birthRate = 150

emitterEntity.components.set(emitterComponent)
```

#### 
A particle with a constant color maintains the same color throughout its lifetime, but a particle with an evolving color gradually changes from one color to another over the duration of its lifetime.
The app has two methods that configure particles with a constant color. The `setConstantColor(_:)` method creates a  instance by passing the color a person selects in the app’s UI to the  enumeration case, and then creates a constant color from that value.
```swift
typealias ParticleEmitter = ParticleEmitterComponent.ParticleEmitter
typealias ParticleColor = ParticleEmitter.ParticleColor
typealias ParticleColorValue = ParticleColor.ColorValue

// ...

func setConstantColor(_ swiftUIColor: SwiftUI.Color) {
    // Create a single color value instance.
    let color1 = ParticleEmitter.Color(swiftUIColor)
    let singleColorValue = ParticleColorValue.single(color1)

    // Create a constant color from the single color value.
    let constantColor = ParticleColor.constant(singleColorValue)

    // Change the particle color for the emitter.
    emitterComponent.mainEmitter.color = constantColor

    // Replace the entity's emitter component with the current configuration.
    emitterEntity.components.set(emitterComponent)
}
```

The app’s `setRandomColor(_:_:)` method also creates a constant color that’s random by passing two colors from the app’s UI to the  enumeration case.
```
The app’s `setRandomColor(_:_:)` method also creates a constant color that’s random by passing two colors from the app’s UI to the  enumeration case.
```swift
func setRandomColor(_ swiftUIColor1: SwiftUI.Color,
                    _ swiftUIColor2: SwiftUI.Color) {
    // Create a random color value instance between two colors.
    let color1 = ParticleEmitter.Color(swiftUIColor1)
    let color2 = ParticleEmitter.Color(swiftUIColor2)
    let randomColor = ParticleColorValue.random(a: color1, b: color2)

    // Create a constant color from the random color value.
    let constantColor = ParticleColor.constant(randomColor)

    // Change the particle color for the emitter.
    emitterComponent.mainEmitter.color = constantColor

    // Replace the entity's emitter component with the current configuration.
    emitterEntity.components.set(emitterComponent)
}
```

The enumeration case creates a color value from the two input colors by selecting a random interpolation value between them.
The app’s `setEvolvingColor(_:_:)` method configures an emitter’s particles so that they shift from one color to another over time by creating an evolving color.
```swift
func setEvolvingColor(_ swiftUIColor1: SwiftUI.Color,
                      _ swiftUIColor2: SwiftUI.Color) {

    // Create two single color value instances.
    let color1 = ParticleEmitter.Color(swiftUIColor1)
    let color2 = ParticleEmitter.Color(swiftUIColor2)
    let singleColorValue1 = ParticleColorValue.single(color1)
    let singleColorValue2 = ParticleColorValue.single(color2)

    // Create an evolving color that shifts from one color value to another.
    let evolvingColor = ParticleColor.evolving(start: singleColorValue1,
                                               end: singleColorValue2)

    // Change the particle color for the emitter.
    emitterComponent.mainEmitter.color = evolvingColor

    // Replace the entity's emitter component with the current configuration.
    emitterEntity.components.set(emitterComponent)
}
```

#### 
The app lets a person change the appearance of the emitter’s particles by applying an image to each. It does this by creating a  instance from an image and assigning it to the emitter’s  property.
```swift
emitterComponent.mainEmitter.image = textureResource
```

The app generates a texture resource in its `generateTextureFromSystemName(_:)` method by taking these steps:
3. Retrieve the image from the context.
4. Pass the final image to the texture resource type’s factory method.
```swift
func generateTextureFromSystemName( _ name: String) -> TextureResource? {
    let imageSize = CGSize(width: 128, height: 128)
    
    // Create a UIImage from a symbol name.
    guard var symbolImage = UIImage(systemName: name) else {
        return nil
    }

    // Create a new version that always uses the template rendering mode.
    symbolImage = symbolImage.withRenderingMode(.alwaysTemplate)

    // Start the graphics context.
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

    // Set the color's texture to white so that the app can apply a color
    // on top of the image.
    UIColor.white.set()

    // Draw the image with the context.
    let rectangle = CGRect(origin: CGPoint.zero, size: imageSize)
    symbolImage.draw(in: rectangle, blendMode: .normal, alpha: 1.0)

    // Retrieve the image from the context.
    let contextImage = UIGraphicsGetImageFromCurrentImageContext()

    // End the graphics context.
    UIGraphicsEndImageContext()

    // Retrieve the Core Graphics version of the image.
    guard let coreGraphicsImage = contextImage?.cgImage else {
        return nil
    }

    // Generate the texture resource from the Core Graphics image.
    let creationOptions = TextureResource.CreateOptions(semantic: .raw)
    return try? TextureResource.generate(from: coreGraphicsImage,
                                         options: creationOptions)
}
```

The app presents a slider that changes the  property. In the example below, the slider’s value is `.pi / 6` radians, which is equivalent to 30º.

## Simulating physics joints in your RealityKit app
> https://developer.apple.com/documentation/realitykit/simulating-physics-joints-in-your-realitykit-app

### 
#### 
#### 
This app adds a physics body and collision shape that matches the model’s spherical shape, where `pendulumSettings.ballRadius` characterizes its radius.
To respond to forces like gravity and collisions, set the ball’s  to . Set its material to have no friction and a restitution of `1`, to result in completely elastic collisions:
```swift
let collisionShape = ShapeResource.generateSphere(
    radius: pendulumSettings.ballRadius)

var ballBody = PhysicsBodyComponent(
    shapes: [collisionShape],
    mass: pendulumSettings.ballMass,
    material: .generate(staticFriction: 0, dynamicFriction: 0, restitution: 1),
    mode: .dynamic
)
ballBody.linearDamping = 0
let ballCollision = CollisionComponent(shapes: [ballShape])

ballEntity.components.set([ballBody, ballCollision])
```

Because other forces can’t move the other end of the physics joint (`attachmentEntity`), set its  to :
```
Because other forces can’t move the other end of the physics joint (`attachmentEntity`), set its  to :
```swift
let attachmentShape = ShapeResource.generateBox(
    size: pendulumSettings.attachmentSize * pendulumSettings.ballRadius
)

var attachmentBody = PhysicsBodyComponent(
    shapes: [attachmentShape], mass: 1,
    material: .generate(staticFriction: 0, dynamicFriction: 0, restitution: 1),
    mode: .static
)
attachmentBody.linearDamping = 0
let attachmentCollision = CollisionComponent(shapes: [attachmentShape])

attachmentEntity.components.set([attachmentBody, attachmentCollision])
```

#### 
The app adds the components  and  to a common ancestor of `ballEntity` and `attachmentEntity`, to indicate where RealityKit adds the joints:
The app adds the components  and  to a common ancestor of `ballEntity` and `attachmentEntity`, to indicate where RealityKit adds the joints:
```swift
// Add physics simulation component to parent simulation entity.
parentSimulationEntity.components.set(PhysicsSimulationComponent())
// Add physics joints component to parent simulation entity.
parentSimulationEntity.components.set(PhysicsJointsComponent())
```

#### 
A joint needs two  instances on separate entities to create a physics joint.
The app creates each pin with the method  on its respective entity. Use  to access all pins an entity owns:
```swift
// Rotate hinge orientation from x to z-axis.
let hingeOrientation = simd_quatf(from: [1, 0, 0], to: [0, 0, 1])

// The attachment's pin is in the center of
// the attachment entity.
let attachmentPin = attachmentEntity.pins.set(
    named: "attachment_hinge",
    position: .zero,
    orientation: hingeOrientation
)

// The ball's pin is at the center of the
// attachment entity in local space.
let relativeJointLocation = attachmentEntity.position(
    relativeTo: ballEntity
)

let ballPin = ballEntity.pins.set(
    named: "ball_hinge",
    position: relativeJointLocation,
    orientation: hingeOrientation
)
```

Use each  as the parameters to create a new :
```swift
let revoluteJoint = PhysicsRevoluteJoint(pin0: attachmentPin, pin1: ballPin)
```

#### 
Add the new joint to the simulation. The  method finds the closest entity ancestor of the joint’s first pin that has a , and adds the joint to its  collection:
```swift
try revoluteJoint.addToSimulation()
```

#### 
The simulation shows no effect until you add motion. One way to do so is via . Give the ball a push in the negative x-direction to start the simulation:
```swift
let impulseAction = ImpulseAction(
    targetEntity: .sourceEntity,
    linearImpulse: pendulumSettings.impulsePower)
let impulseAnimation = try AnimationResource.makeActionAnimation(
    for: impulseAction)

ballEntity.playAnimation(impulseAnimation)
```

The following video shows the resulting scene, with the `ballEntity` swinging left and right on the hinge:

## Simulating physics with collisions in your visionOS app
> https://developer.apple.com/documentation/realitykit/simulating-physics-with-collisions-in-your-visionos-app

### 
#### 
The app starts by creating a scene that includes a window group with a  style so that the spheres behave like physical objects in the environment.
```swift
import SwiftUI

@main
struct PhysicsBodiesApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }.windowStyle(.volumetric)
    }
}
```

Volumetric windows are viewable from all sides and have a constant size in the environment. If you want to prioritize visibility from a distance rather than from all sides, use the  window style instead. Plain windows are resizable, which can help people see the contents of a window from a distance, but there’s one optimal viewing angle.
The app’s main view creates the spheres and an invisible containment box that keeps the spheres from drifting out of the volume.
```swift
var body: some View {
    GeometryReader3D { geometry in
        RealityView { content in
            addSpheres(content)
            content.add(containmentCollisionBox)
        } update: { content in
            let localFrame = geometry.frame(in: .local)
            let sceneFrame = content.convert(localFrame,
                                             from: .local, to: .scene)

            containmentCollisionBox.update(sceneFrame)
        }.gesture(ForceDragGesture())
    }
}
```

#### 
The app creates each sphere as a  instance with a spherical mesh.
```swift
let sphereEntity = ModelEntity(
    mesh: MeshResource.generateSphere(radius: sphereRadius),
    materials: [metallicSphereMaterial()]
)
```

Alternatively, you can create an  instance and add a  to it, which is the equivalent of a .
To customize each sphere’s appearance, the app configures a material. The app applies a unique material with a random color to each sphere by creating and configuring a new  instance.
```swift
private func metallicSphereMaterial(
    hue: CGFloat = CGFloat.random(in: (0.0)...(1.0))
) -> PhysicallyBasedMaterial {
    var material = PhysicallyBasedMaterial()

    let color = RealityKit.Material.Color(
        hue: hue,
        saturation: CGFloat.random(in: (0.5)...(1.0)),
        brightness: 0.9,
        alpha: 1.0)

    material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: color)
    material.metallic = 1.0
    material.roughness = 0.5
    material.clearcoat = 1.0
    material.clearcoatRoughness = 0.1

    return material
}
```

-  to `1.0`, which makes the material reflective.
-  of `0.5`, a relatively high value, which makes the reflections blurrier.
-  to `1.0`, which gives the material white reflections on top of the metallic ones.
- The  to `0.1`, a relatively low value, which gives sharp clear coat reflections.
To make the spheres interact with the physics system, the app adds a  and  a  to each sphere’s entity.
```swift
// Create the physics body from the same shape.
let shape = ShapeResource.generateSphere(radius: sphereRadius)
sphereEntity.components.set(CollisionComponent(shapes: [shape]))

var physics = PhysicsBodyComponent(
    shapes: [shape],
    density: 10_000
)

// Make each sphere float in the air by turning off gravity.
physics.isAffectedByGravity = false

// Add the physics component to the sphere.
sphereEntity.components.set(physics)
```

#### 
- `SphereAttractionSystem`
- `SphereAttractionComponent`
- `SphereAttractionComponent`
The app adds each sphere to the system by setting the custom component to the sphere’s component set.
```swift
sphereEntity.components.set(SphereAttractionComponent())
```

The sample’s `SphereAttractionComponent` structure conforms to the  protocol by implementing the  initializer and  method it requires.
```
The sample’s `SphereAttractionComponent` structure conforms to the  protocol by implementing the  initializer and  method it requires.
```swift
struct SphereAttractionSystem: System {
    let entityQuery: EntityQuery

    init(scene: RealityKit.Scene) {
        let attractionComponentType = SphereAttractionComponent.self
        entityQuery = EntityQuery(where: .has(attractionComponentType))
    }

    func update(context: SceneUpdateContext) {
        // ...
    }
}
```

The app simulates an attractive force between each sphere and all the other spheres in the scene in the custom system’s `update()` method.
```
The app simulates an attractive force between each sphere and all the other spheres in the scene in the custom system’s `update()` method.
```swift
func update(context: SceneUpdateContext) {
    let sphereEntities = context.entities(
        matching: entityQuery,
        updatingSystemWhen: .rendering
    )

    for case let sphere as ModelEntity in sphereEntities {
        var aggregateForce: SIMD3<Float>

        // Start with a force back to the center.
        let centerForceStrength = Float(0.05)
        let position = sphere.position(relativeTo: nil)
        let distance = length_squared(position)

        // Set the initial force with the inverse-square law.
        aggregateForce = normalize(position) / distanceSquared

        // Direct the force back to the center by negating the position vector.
        aggregateForce *= -centerForceStrength
        
        let neighbors = context.entities(matching: entityQuery,
                                         updatingSystemWhen: .rendering)

        for neighbor in neighbors where neighbor != sphere {

            let spherePosition = sphere.position(relativeTo: nil)
            let neighborPosition = neighbor.position(relativeTo: nil)

            let distance = length(neighborPosition - spherePosition)

            // Calculate the force from the sphere to the neighbor.
            let forceFactor = Float(0.1)
            let forceVector = normalize(neighborPosition - spherePosition)
            let neighborForce = forceFactor * forceVector / pow(distance, 2)
            aggregateForce += neighborForce
        }

        // Add the combined force from all the sphere's neighbors.
        sphere.addForce(aggregateForce, relativeTo: nil)
    }
}
```

#### 
The sample’s `ContainmentCollisionBox` class, which inherits from , creates the six faces of the containment box in its `update(_:)` method.
The app prevents the spheres from moving out of the volume by creating a relatively thin box for each of the volume’s six boundaries.
The sample’s `ContainmentCollisionBox` class, which inherits from , creates the six faces of the containment box in its `update(_:)` method.
```swift
func update(_ boundingBox: BoundingBox) {
    // ...

    // Define the constants for the faces' geometry for convenience.
    let min = boundingBox.min
    let max = boundingBox.max
    let center = boundingBox.center

    let lHandFace = SIMD3<Float>(x: min.x, y: center.y, z: center.z)
    let rHandFace = SIMD3<Float>(x: max.x, y: center.y, z: center.z)
    let lowerFace = SIMD3<Float>(x: center.x, y: min.y, z: center.z)
    let upperFace = SIMD3<Float>(x: center.x, y: max.y, z: center.z)
    let nearFace = SIMD3<Float>(x: center.x, y: center.y, z: min.z)
    let afarFace = SIMD3<Float>(x: center.x, y: center.y, z: max.z)

    // Make each box relatively thin.
    let thickness = Float(1E-3)

    // Configure the size for the left and right faces.
    var size = boundingBox.extents
    size.x = thickness

    // Create the left face of the collision containment cube.
    var face = Entity.boxWithCollisionPhysics(lHandFace, size)
    addChild(face)

    // Create the right face of the collision containment cube.
    face = Entity.boxWithCollisionPhysics(rHandFace, size)
    addChild(face)

    // Configure the size for the top and bottom faces.
    size = boundingBox.extents
    size.y = thickness

   // ...
}
```

The method creates each face by calling the `boxWithCollisionPhysics(_:_:boxMass:)` method the sample adds to  in an extension.
```
The method creates each face by calling the `boxWithCollisionPhysics(_:_:boxMass:)` method the sample adds to  in an extension.
```swift
import RealityKit

/// The default mass for a new box.
private let defaultMass1Kg = Float(1.0)

extension Entity {
    // ...
    static func boxWithCollisionPhysics(
        _ location: SIMD3<Float>,
        _ boxSize: SIMD3<Float>,
        boxMass: Float = defaultMass1Kg
    ) -> Entity {
        // Create an entity for the box.
        let boxEntity = Entity()

        // Create the box's shape from the size.
        let boxShape = ShapeResource.generateBox(size: boxSize)

        // Create a collision component with the box's shape.
        let collisionComponent = CollisionComponent(
            shapes: [boxShape],
            isStatic: true)

        // Create a physics body component with the box's shape.
        let physicsBodyComponent = PhysicsBodyComponent(
            shapes: [boxShape],
            mass: boxMass,
            mode: PhysicsBodyMode.static
        )

        // Set the entity's position in the scene.
        boxEntity.position = location

        // Add the collision physics to the box entity.
        boxEntity.components.set(collisionComponent)
        boxEntity.components.set(physicsBodyComponent)
        return boxEntity
    }
}
```

#### 
The app lets a person move the spheres within the volume by adding a `ForceDragGesture` instance to the main view.
The app lets a person move the spheres within the volume by adding a `ForceDragGesture` instance to the main view.
```swift
import SwiftUI
import RealityKit

struct ForceDragGesture: Gesture {

    var body: some Gesture {
        EntityDragGesture { entity, targetPosition in
            guard let modelEntity = entity as? ModelEntity else { return }

            let spherePosition = entity.position(relativeTo: nil)

            let direction = targetPosition - spherePosition
            var strength = length(direction)
            if strength < 1.0 {
                strength *= strength
            }

            let forceFactor: Float = 3000
            let force = forceFactor * strength * simd_normalize(direction)
            modelEntity.addForce(force, relativeTo: nil)
        }
    }
}
```

The type applies a force to the sphere where a drag gesture begins, which increases with the distance between the sphere and drag gesture’s current position, similar to a spring.
To enable gestures on the Entities, the sample adds an  as well as a  to provide feedback when a person looks at a sphere:
```swift
// Highlight the sphere when a person looks at it.
sphereEntity.components.set(HoverEffectComponent())

// Configure the sphere to receive gesture inputs.
sphereEntity.components.set(InputTargetComponent())
```

The `ForceDragGesture` type depends on the sample’s `EntityDragGesture` type, which handles the logic to start and end a drag gesture and updates its current position during the drag.
The sample also defines another gesture type, `RelocateDragGesture` which moves a sphere entity by changing its location, instead of applying a force.
```swift
import SwiftUI
import RealityKit

struct RelocateDragGesture: Gesture {
    var body: some Gesture {
        EntityDragGesture { entity, targetPosition in
            entity.setPosition(targetPosition, relativeTo: nil)
        }
    }
}
```

> **experiment:** Replace the call to `ForceDragGesture()`in the app’s main view with `RelocateDragGesture()` and compare the behavioral differences.

## Transforming RealityKit entities using gestures
> https://developer.apple.com/documentation/realitykit/transforming-realitykit-entities-with-gestures

### 
#### 
To implement the gesture functionality, the sample app first creates a `struct` that conforms to . This component marks entities that support transform gestures, and contains the logic to implement those gestures. In order to support Reality Composer Pro, the component also conforms to . To include the ability to turn different gestures on and off, the component contains three  properties, one for each of the transforms the component supports. Reality Composer Pro exposes the transforms as checkboxes, which enable or disable specific gestures for an entity.
```swift
/// A component that handles gesture logic for an entity.
public struct GestureComponent: Component, Codable {
    
    /// A Boolean value that indicates whether a gesture can drag the entity.
    public var canDrag: Bool = true
    
    /// ...
    
    /// A Boolean value that indicates whether a gesture can scale the entity.
    public var canScale: Bool = true
    
    /// A Boolean value that indicates whether a gesture can rotate the entity.
    public var canRotate: Bool = true

    /// ...
```

```
The component has two other properties for configuring the drag style, shown below:
```swift
    /// A Boolean value that indicates whether the drag gesture can move the object in an arc, similar to dragging windows or moving the keyboard.
    public var pivotOnDrag: Bool = true
    
    /// A Boolean value that indicates whether a pivot drag keeps the orientation toward the
    /// viewer throughout the drag gesture.
    ///
    /// The property only applies when `pivotOnDrag` is `true`.
    public var preserveOrientationOnPivotDrag: Bool = true
```

#### 
To implement these transform gestures, the app needs to maintain some state. The  action passes a delta from the start transform,  the delta from the previous  call, so the app needs to keep track of the entity’s starting position, rotation, and scale. For example, each time SwiftUI calls the  action for a drag gesture, the action provides the total distance dragged on each axis since the gesture started. The app also keeps track of whether a gesture is already in progress. Gestures don’t have an `.onStarted` action, so the app keeps track of whether the gesture has already started so it knows if it needs to store the starting position, rotation, or scale. Lastly, the sample app keeps a reference to the pivot entity. By parenting the dragged entity to the pivot entity, the system calculates the dragged entity’s rotation when the app rotates the pivot entity.
This component only supports dragging a single entity at a time, so there’s no need to store state on a per-entity level. As a result, the app uses a singleton object to store the state instead of a component:
```swift
public class EntityGestureState {
    
    /// The entity currently being dragged if a gesture is in progress.
    var targetedEntity: Entity?
    
    // MARK: - Drag
    
    /// The starting position.
    var dragStartPosition: SIMD3<Float> = .zero
    
    /// Marks whether the app is currently handling a drag gesture.
    var isDragging = false
    
    /// When `rotateOnDrag` is`true`, this entity acts as the pivot point for the drag.
    var pivotEntity: Entity?
    
    var initialOrientation: simd_quatf?
    
    // MARK: - Magnify
    
    /// The starting scale value.
    var startScale: SIMD3<Float> = .one
    
    /// Marks whether the app is currently handling a scale gesture.
    var isScaling = false
    
    // MARK: - Rotation
    
    /// The starting rotation value.
    var startOrientation = Rotation3D.identity
    
    /// Marks whether the app is currently handling a rotation gesture.
    var isRotating = false
    
    // MARK: - Singleton Accessor
    
    /// Retrieves the shared instance.
    static let shared = EntityGestureState()
}
```

#### 
`GestureComponent` needs to implement functions the app calls from the  and  actions for each of the three supported types of gestures. The `onChange` functions first retrieve the gesture entity and its state component, creating a new state component if one doesn’t already exist, as shown below:
```swift
mutating func onChanged(value: EntityTargetValue<DragGesture.Value>) {
    guard canDrag else { return }
    let entity = value.entity
    
    var state: GestureStateComponent = entity.gestureStateComponent ?? GestureStateComponent()

    // ...

}
```

```
The first time the app calls the function for a particular gesture, the function stores the starting position, orientation, or scale. The drag function looks like this:
```swift
if state.targetedEntity == nil {
    state.targetedEntity = value.entity
    state.initialOrientation = value.entity.orientation(relativeTo: nil)
}
```

```
Finally, the function calculates the entity’s new position, rotation, or scale by applying the information from the gesture to the starting value stored in the state component. Here’s the logic for the rotate gesture:
```swift
let flippedRotation = Rotation3D(angle: rotation.angle, 
                                 axis: RotationAxis3D(x: -rotation.axis.x,
                                                      y: rotation.axis.y,
                                                      z: -rotation.axis.z))
let newOrientation = state.startOrientation.rotated(by: flippedRotation)
entity.setOrientation(.init(newOrientation), relativeTo: nil)
```

#### 
To connect the SwiftUI gestures to the component, this sample uses an extension on  that contains functions that send the gesture information to the component. For example, here’s the gesture property that forwards the drag gesture events to the component:
```swift
/// Builds a drag gesture.
var dragGesture: some Gesture {
    DragGesture()
        .targetedToAnyEntity()
        .useGestureComponent()
}
```

```
The extension also contains a function that installs all three of the gestures to a  at once:
```swift
/// Apply this to a `RealityView` to pass gestures on to the component code.
func installGestures() -> some View {
    simultaneousGesture(dragGesture)
        .simultaneousGesture(magnifyGesture)
        .simultaneousGesture(rotateGesture)
}
```

#### 
To forward the gesture information to the entity components, the app calls the `installGestures()` function on the  returned from the initializer.
To forward the gesture information to the entity components, the app calls the `installGestures()` function on the  returned from the initializer.
```swift
RealityView { content in
    // Add the initial RealityKit content.
    if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
        content.add(scene)
    }
} update: { content in

}
.installGestures()
```

#### 
Once the app installs the gestures on the , people can manipulate any entity containing a `GestureComponent`. This sample uses a Reality Composer Pro scene to add a `GestureComponent` to each of its entities. It also adds an  and a  to those entities, because all three components are necessary for the entity to support gestures. Each of the four entities in the sample’s Reality Composer scene support a different combination of gestures.
Instead of adding the component in Reality Composer Pro, the app could add the components to entities in code, like this:
```swift
var component = GestureComponent()
component.canDrag = true 
component.canScale = false
component.canRotate = true
myEntity.components.set(component)
```


## Using Metal performance shaders to create custom postprocess effects
> https://developer.apple.com/documentation/realitykit/using-metal-performance-shaders-to-create-custom-postprocess-effects

### 
#### 
#### 
To create postprocess effects using image filters from the Metal Performance Shaders framework, create a Swift function that takes a single  parameter. In that method, create and configure an instance of the filter that you want to apply using the  property from the context. Once you’ve created an instance of the shader, call its encode method, passing the command buffer, source color texture, and output texture from the context.
```swift
    func postEffectMPSGaussianBlur(context: ARView.PostProcessContext) {
        let gaussianBlur = MPSImageGaussianBlur(device: context.device, sigma: 4)
        gaussianBlur.encode(commandBuffer: context.commandBuffer,
                            sourceTexture: context.sourceColorTexture,
                            destinationTexture: context.compatibleTargetTexture)
```

#### 
To apply the effect, register the function as the  render callback for the .
```swift
arView.renderCallbacks.postProcess = postEffectMPSGaussianBlur
```


