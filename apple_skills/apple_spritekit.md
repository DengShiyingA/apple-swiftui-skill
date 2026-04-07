# Apple SPRITEKIT Skill


## Drawing SpriteKit Content in a View
> https://developer.apple.com/documentation/spritekit/drawing-spritekit-content-in-a-view

### 
#### 
Everything displayed with SpriteKit is done through a scene object, which is an instance of . Use the following code to set up a basic scene:
```swift
let scene = SKScene(size: skView.bounds.size)

// Set the scene coordinates (0, 0) to the center of the screen.
scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
```

For further discussion about how setting the `anchorPoint` changes an object’s position in the view, see .
#### 
You use node objects to display graphics in a SpriteKit view. SpriteKit provides different nodes depending on the content (see Nodes that Draw in  ). In this case, use an  to display an image in the view:
```swift
let image = SKSpriteNode(imageNamed: "myImage.png")

// Add the image to the scene.
scene.addChild(image)

```

#### 
After you set up the scene, you display it in the view by calling :
```swift
if let skView = self.view as? SKView { 
    skView.presentScene(scene)
}

```


## Getting Started with Actions
> https://developer.apple.com/documentation/spritekit/getting-started-with-actions

### 
#### 
#### 
#### 
#### 
The  method is identical to the  method, but after the action completes, your block is called, but only if the action runs to completion. If the action is removed before it completes, the completion handler is never called. The following code fades out a sprite by running a  action on it and, after the action completes, presents a new scene:
```swift
let fadeOut = SKAction.fadeOut(withDuration:2)
node.run(fadeOut) {
    skView.presentScene(newScene)
}
```

#### 
#### 

## Working with Inverse Kinematics
> https://developer.apple.com/documentation/spritekit/working-with-inverse-kinematics

### 
#### 
-  object `reach` methods that solve an IK system (that run the system to make the end effector reach a specified position).
The `shoulder` node is fixed to the scene with a constraint, and the other joints are offset in the `y` direction by the length of each section.
The following code creates a simple robot arm consisting of a fixed `shoulder` node and `upperArm`, `midArm`, and `lowerArm` sections that are joined by `elbow` and `wrist` nodes. At the end of the `wrist` is an `endEffector` node. The nodes are progressively children of each other.
The `shoulder` node is fixed to the scene with a constraint, and the other joints are offset in the `y` direction by the length of each section.
```swift
let sectionLength: CGFloat = 100
let sectionRect = CGRect(x: -10, y: -sectionLength,
                         width: 20, height: sectionLength)
   
let upperArm = SKShapeNode(rect: sectionRect)
let midArm = SKShapeNode(rect: sectionRect)
let lowerArm = SKShapeNode(rect: sectionRect)
let shoulder = SKShapeNode(circleOfRadius: 5)
let elbow = SKShapeNode(circleOfRadius: 5)
let wrist = SKShapeNode(circleOfRadius: 5)
let endEffector = SKShapeNode(circleOfRadius: 5)
   
scene.addChild(shoulder)
shoulder.addChild(upperArm)
upperArm.addChild(elbow)
elbow.addChild(midArm)
midArm.addChild(wrist)
wrist.addChild(lowerArm)
lowerArm.addChild(endEffector)
    
shoulder.constraints = [SKConstraint.positionX(SKRange(constantValue: 320),
                                               y: SKRange(constantValue: 320))]
    
let positionConstraint = SKConstraint.positionY(SKRange(constantValue: -sectionLength))
elbow.constraints =  [ positionConstraint ]
wrist.constraints = [ positionConstraint ]
endEffector.constraints = [ positionConstraint ]
```

#### 
To run the IK solver, you create an action passing it the desired location.
```swift
let reachAction = SKAction.reach(to: location,
                                 rootNode: shoulder,
                                 duration: 1.0)
     
endEffector.run(reachAction)
```


