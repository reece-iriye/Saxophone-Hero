import UIKit
import SpriteKit
import CoreMotion

// ChatGPT Assisted in the Code for the SKAction extension here:
// We asked ChatGPT about keeping a block oscellating forever, and it helped with
// generating this code.
//
// This SKAction extension provides a custom oscillation action for SKNodes.
// The purpose is to allow for back-and-forth oscillation of the Physics Body block.
extension SKAction {

    // This function creates a custom action that makes an SKNode oscillate around a midpoint.
    // - Parameters:
    //     - a: amplitude, the amount the height will vary.
    //     - t: timePeriod, the duration for one complete oscillation cycle.
    //     - midPoint: the central point around which the oscillation occurs.
    static func oscillation(amplitude a: CGFloat, timePeriod t: Double, midPoint: CGPoint) -> SKAction {
        // Custom action calculates the sinusoidal oscillation for a given 'currentTime'.
        let action = SKAction.customAction(withDuration: t) { node, currentTime in
            let displacement = a * sin(2 * .pi * currentTime / CGFloat(t))
            node.position.x = midPoint.x + displacement
        }

        return action
    }
}

// ChatGPT helped us add comments to be more explicit throughout this code.
// MazeGameScene class defines the behavior and appearance of the game's main scene.
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: Raw Motion Functions
    
    // This object interfaces with the device's motion hardware.
    let motion = CMMotionManager()
    
    // The queue for handling device motion
    let deviceMotionQueue = OperationQueue()
    
    // This function starts the process of receiving motion updates.
    // It configures the motion manager to periodically fetch and handle motion data.
    func startMotionUpdates(){
        // Check if the device supports motion updates.
        if self.motion.isDeviceMotionAvailable{
            // Set the interval at which motion updates are fetched.
            self.motion.deviceMotionUpdateInterval = 0.1
            // Start fetching motion updates using the given frame of reference.
            // The handler (`handleMotion`) processes these updates.
            self.motion.startDeviceMotionUpdates(
                using: .xMagneticNorthZVertical,
                to: self.deviceMotionQueue,  // Ensure motion updates aren't on the main queue
                withHandler: self.handleMotion
            )
        }
    }
    
    // This function handles the motion data by setting the game's gravity according to the device's attitude.
    // - Parameters:
    //     - motionData: Contains the attitude (roll, pitch, NOT YAW) of the device.
    //     - error: Contains any error information if motion fetching failed.
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        // If there's valid motion data, extract the device's attitude (roll, pitch).
        if let attitude = motionData?.attitude {
            // Convert the roll and pitch into a gravity vector and set it as the physics world's gravity.
            self.physicsWorld.gravity = CGVector(
                dx: CGFloat(5*attitude.roll),
                
                // MAKE SURE THAT PITCH IS NEGATIVE FOR LOGICAL ANGLING
                dy: CGFloat(-5*attitude.pitch)
                
            )
        }
    }
    
    // MARK: View Hierarchy Functions
    
    // Declaring the main maze boundary walls.
    let topWall = SKSpriteNode()
    let bottomWall = SKSpriteNode()
    let leftWall = SKSpriteNode()
    let rightWall = SKSpriteNode()
    
    // Declaring the internal walls of the maze.
    let bottomInnerWall = SKSpriteNode()
    let middleInnerWall = SKSpriteNode()
    let topInnerWall = SKSpriteNode()
    
    // Declaring other game objects and audio.
    let player = SKSpriteNode(imageNamed: "player") // The main character/player of the game.
    let gameplayAudio = SKAudioNode(fileNamed: "GameAudio") // Audio played during the game.
    let winAudio = SKAudioNode(fileNamed: "WinAudio") // Instantiates a new audio node for the victory sound.

    let finishLine = SKSpriteNode() // The goal/end point of the game.
    let obstacleBlock = SKSpriteNode() // A dynamic obstacle block.
    
    // This function is called automatically when the scene is presented by a view.
    // It initializes the game elements and sets up the initial game state.
    override func didMove(to view: SKView) {
        
        // Assigning the current scene as the delegate to handle physics contact events.
        self.physicsWorld.contactDelegate = self
        
        // Set the background color of the scene to a light blue.
        self.backgroundColor = SKColor(red: 2/255.0, green: 255/255.0, blue: 254/255.0, alpha: 1.0)
        
        // Begin collecting data from the device's motion sensors (e.g., accelerometer) to implement gravity effects.
        self.startMotionUpdates()
        
        // Adds the finish line to the game at the specified position.
        self.addFinishAtPoint(CGPoint(x: size.width * 0.25, y: size.height * 0.85))
        
        // Spawns the player in the game scene.
        self.spawnPlayer()
        
        // Creates and places all walls within the game scene.
        self.addAllTheGameWalls()
        
        // Initialize and set the gameplay audio to loop indefinitely.
        self.gameplayAudio.autoplayLooped = true
        // Add the audio node to the scene.
        self.addChild(gameplayAudio)
        // Begin playback of the gameplay audio.
        self.gameplayAudio.run(SKAction.play())
        
        // Creates an obstacle block at the given position in the game scene.
        self.createObstacleBlock(xPos: size.width/2, yPos: (size.height*0.85)/2)
        // Add the obstacle block node to the scene.
        self.addChild(obstacleBlock)
        
        // Create an oscillation action for the obstacle block.
        // This will make the block move back and forth around its starting position.
        let oscillate = SKAction.oscillation(
            amplitude: 95, // The maximum distance the block will move from its starting position.
            timePeriod: 15, // The time taken for one complete oscillation.
            midPoint: obstacleBlock.position // The central point of the oscillation.
        )
        // Apply the oscillation action to the obstacle block and make it repeat indefinitely.
        self.obstacleBlock.run(SKAction.repeatForever(oscillate))
    }
    
    
    // MARK: Create Sprites Functions
    
    // Creates and initializes the finish line at the specified point.
    func addFinishAtPoint(_ point:CGPoint){
        
        // Set the finish line's color to red.
        self.finishLine.color = UIColor.red
        
        // Define the size of the finish line based on the scene's width and height.
        self.finishLine.size = CGSize(
            width: size.width*0.05,
            height: size.height * 0.11
        )
        
        // Set the position of the finish line to the passed-in point.
        self.finishLine.position = point
        
        // Create a physics body for the finish line using its size.
        self.finishLine.physicsBody = SKPhysicsBody(rectangleOf: finishLine.size)
        
        // Set physics body properties related to contact and collision detection.
        self.finishLine.physicsBody?.contactTestBitMask = 0x00000001
        self.finishLine.physicsBody?.collisionBitMask = 0x00000001
        self.finishLine.physicsBody?.categoryBitMask = 0x00000001
        
        // Make sure the finish line can interact with other physics bodies.
        self.finishLine.physicsBody?.isDynamic = true
        
        // Pin the finish line in its position so it doesn't move.
        self.finishLine.physicsBody?.pinned = true
        
        // Add the finish line to the scene.
        self.addChild(finishLine)
        
    }
    
    // Creates and initializes an obstacle block at the specified x and y positions.
    func createObstacleBlock(xPos: Double, yPos: Double) {
        
        // Define the size of the obstacle block based on the scene's width.
        self.obstacleBlock.size = CGSize(
            width: size.width*0.1,
            height: size.width*0.1
        )
        
        // Set the position of the obstacle block using the provided x and y values.
        self.obstacleBlock.position = CGPoint(
            x: xPos,
            y: yPos
        )
        
        // Set the obstacle block's color to black.
        self.obstacleBlock.color = .black
        
        // Create a y-constraint to ensure the block remains at the same vertical position.
        let yConstraint = SKConstraint.positionY(SKRange(constantValue: yPos))
        self.obstacleBlock.constraints = [yConstraint]
        
        // Create a physics body for the obstacle block using its size.
        self.obstacleBlock.physicsBody = SKPhysicsBody(
            rectangleOf: self.obstacleBlock.size
        )
                
        // Set various physics properties for the obstacle block.
        self.obstacleBlock.physicsBody?.isDynamic = true            // Make the block dynamic, allowing it to interact with other objects.
        self.obstacleBlock.physicsBody?.affectedByGravity = false   // Ensure the block is not affected by gravity.
        self.obstacleBlock.physicsBody?.contactTestBitMask = 0x00000001   // Properties related to contact detection.
        self.obstacleBlock.physicsBody?.collisionBitMask = 0x00000001     // Properties related to collision detection.
        self.obstacleBlock.physicsBody?.categoryBitMask = 0x00000001      // Define the category to which the block belongs for physics interactions.
    }
    
    
    // Instantiates the player sprite at the bottom corner of the scene.
    func spawnPlayer() {
        
        // Define the player's size based on the scene's width.
        self.player.size = CGSize(width: size.width*0.1, height: size.width*0.1)
        
        // Set the player's position to be at the specified coordinates.
        self.player.position = CGPoint(x: size.width * 0.30, y: size.height * 0.15)
        
        // Create a physics body for the player using its size.
        self.player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        
        // Initialize the player with a velocity of 0.
        self.player.physicsBody?.velocity = CGVector.zero
        
        // Increase the player's linear damping to make movement slower. (LIKE DRAG FORCE OPERATING AGAINST THE BODY)
        self.player.physicsBody?.linearDamping = 1
        
        // Ensure the player can interact with other physics bodies in the scene.
        self.player.physicsBody?.isDynamic = true
        
        // Set up physics body properties related to contact and collision detection.
        self.player.physicsBody?.contactTestBitMask = 0x00000001
        self.player.physicsBody?.collisionBitMask = 0x00000001
        self.player.physicsBody?.categoryBitMask = 0x00000001
        
        // Add the player sprite to the scene.
        self.addChild(player)
    }
    
    // Removes the player sprite from the scene.
    func deletePlayer() {
        // Detach the player node from its parent node in the scene.
        self.player.removeFromParent()
    }
    
    // Executes the sequence of events when the player reaches the finish line.
    // Our WIN SEQUENCE and the implementation of audio into the game as a whole
    // are what we are intending to be our EXCEPTIONAL CREDIT.
    func playWinSequence() {
        
        // Removes the player from the scene.
        self.deletePlayer()
        
        // Removes game's walls and the finish line from the scene.
        self.deleteWallsAndFinish()
        
        // Pauses the ongoing gameplay audio.
        self.gameplayAudio.run(SKAction.pause())
        
        // Removes the gameplay audio node from the scene.
        self.gameplayAudio.removeFromParent()
        
        // Ensures the victory audio doesn't loop after playing once.
        self.winAudio.autoplayLooped = false
        
        // Adds the victory audio node to the scene.
        self.addChild(self.winAudio)
        
        // Plays the victory audio.
        self.winAudio.run(SKAction.play())
        
        // Changes the background color of the scene to black.
        self.backgroundColor = .black
        
        // Defines the scale actions to animate the appearance of the victory image.
        
        // Quickly enlarges the image to 4 times its original size.
        let scaleUpAction = SKAction.scale(to: 4.0, duration: 0.05)
        
        // Gradually shrinks the image back to 2 times its original size.
        let scaleDownAction = SKAction.scale(to: 2.0, duration: 0.5)
        
        // Creates and sets up the victory image in the center of the scene.
        let backgroundImage = SKSpriteNode(imageNamed: "winnerScreen")
        backgroundImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundImage.xScale = 2.0 // Doubles the width of the image.
        backgroundImage.yScale = 2.0 // Doubles the height of the image.
        
        // Adds the victory image to the scene.
        self.addChild(backgroundImage)
        
        // Animates the victory image by first enlarging it quickly and then shrinking it back more slowly.
        backgroundImage.run(scaleUpAction) {
            backgroundImage.run(scaleDownAction)
        }
    }
    
    // Function to set up and add all the maze walls (boundary and inner) to the game scene.
    func addAllTheGameWalls() {
        // Define standard thickness for vertical walls and a separate thickness for horizontal walls.
        let wallThickness = CGFloat(80)  // Standard wall thickness for vertical walls
        let horizontalWallThickness = CGFloat(60)  // Thickness for horizontal walls
        
        // Set up and add the top boundary wall to the scene.
        self.topWall.color = .black
        self.topWall.size = CGSize(
            width: size.width,
            height: wallThickness
        )
        self.topWall.position = CGPoint(
            x: size.width / 2,
            y: size.height - wallThickness / 2
        )
        self.topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        self.topWall.physicsBody?.isDynamic = false  // Wall remains stationary during gameplay
        self.addChild(topWall)
        
        // Set up and add the bottom boundary wall to the scene.
        self.bottomWall.color = .black
        self.bottomWall.size = CGSize(
            width: size.width,
            height: wallThickness
        )
        self.bottomWall.position = CGPoint(
            x: size.width / 2,
            y: wallThickness / 2
        )
        self.bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        self.bottomWall.physicsBody?.isDynamic = false
        self.addChild(bottomWall)
        
        // Set up and add the left boundary wall to the scene.
        self.leftWall.color = .black
        self.leftWall.size = CGSize(
            width: wallThickness,
            height: size.height
        )
        self.leftWall.position = CGPoint(x: wallThickness / 2, y: size.height / 2)
        self.leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        self.leftWall.physicsBody?.isDynamic = false
        self.addChild(leftWall)
        
        // Set up and add the right boundary wall to the scene.
        self.rightWall.color = .black
        self.rightWall.size = CGSize(
            width: wallThickness,
            height: size.height
        )
        self.rightWall.position = CGPoint(
            x: size.width - wallThickness / 2,
            y: size.height / 2
        )
        self.rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        self.rightWall.physicsBody?.isDynamic = false
        self.addChild(rightWall)
        
        // Define a thinner thickness for some inner horizontal walls.
        let horizontalWallThicknessThin = CGFloat(20) // Thickness for thinner horizontal walls
        
        // Set up and add the first (bottom) inner horizontal wall to the scene.
        let bottomInnerWallLength = size.width * 0.4
        self.bottomInnerWall.color = .black
        self.bottomInnerWall.size = CGSize(
            width: bottomInnerWallLength,
            height: horizontalWallThickness
        )
        self.bottomInnerWall.position = CGPoint(
            x: bottomInnerWallLength / 2,
            y: size.height * 0.25
        )
        self.bottomInnerWall.physicsBody = SKPhysicsBody(rectangleOf: self.bottomInnerWall.size)
        self.bottomInnerWall.physicsBody?.isDynamic = false
        self.addChild(bottomInnerWall)
        
        // Set up and add the second (middle) thinner inner horizontal wall to the scene.
        let middleInnerWallLength = size.width * 0.5
        self.middleInnerWall.color = .black
        self.middleInnerWall.size = CGSize(width: middleInnerWallLength, height: horizontalWallThicknessThin)
        self.middleInnerWall.position = CGPoint(x: size.width - middleInnerWallLength / 2, y: size.height * 0.5)
        self.middleInnerWall.physicsBody = SKPhysicsBody(rectangleOf: self.middleInnerWall.size)
        self.middleInnerWall.physicsBody?.isDynamic = false
        self.addChild(self.middleInnerWall)
        
        // Set up and add the third (top) inner horizontal wall to the scene.
        let topInnerWallLength = size.width * 0.6
        self.topInnerWall.color = .black
        self.topInnerWall.size = CGSize(width: topInnerWallLength, height: horizontalWallThickness)
        self.topInnerWall.position = CGPoint(x: topInnerWallLength / 2, y: size.height * 0.75)
        self.topInnerWall.physicsBody = SKPhysicsBody(rectangleOf: topInnerWall.size)
        self.topInnerWall.physicsBody?.isDynamic = false
        self.addChild(self.topInnerWall)
    }
    
    // Removes the maze walls (boundary and inner) and the finish line from the game scene.
    func deleteWallsAndFinish() {
        // Remove boundary walls
        self.topWall.removeFromParent()
        self.bottomWall.removeFromParent()
        self.leftWall.removeFromParent()
        self.rightWall.removeFromParent()
        
        // Remove inner walls
        self.topInnerWall.removeFromParent()
        self.middleInnerWall.removeFromParent()
        self.bottomInnerWall.removeFromParent()
        
        // Remove finish line
        self.finishLine.removeFromParent()
    }
    
    // Stops the gameplay audio.
    // This function is called by us when leaving the view controller.
    func stopTheAudio() {
        // Stops the gameplay audio's if they are playing and/or are active
        self.gameplayAudio.run(SKAction.stop())
        self.winAudio.run(SKAction.stop())
        
        // Removes the gameplay and win audio nodes from the scene.
        self.gameplayAudio.removeFromParent()
        self.winAudio.removeFromParent()
    }
    
    // MARK: =====Delegate Functions=====
    
    // Called when two physics bodies first contact each other.
    //
    // This function handles the collision between the player and other game objects.
    // If the player reaches the finish line, it triggers the winning sequence.
    // If the player hits anything else, it removes the player, resets the game's gravity,
    // and then respawns the player at its starting position.
    func didBegin(_ contact: SKPhysicsContact) {
        // Check if player reached the finish line
        if contact.bodyA.node == self.finishLine || contact.bodyB.node == self.finishLine {
            self.playWinSequence()
        }
        
        // Check if player collided with any object except the finish line
        if (contact.bodyA.node == self.player && contact.bodyB.node != self.finishLine)
            || (contact.bodyB.node == self.player && contact.bodyA.node != self.finishLine) {
            self.deletePlayer()
            
            // Reset the gravity for a brief moment
            self.physicsWorld.gravity = CGVector.zero
            
            // Respawn the player
            self.spawnPlayer()
        }
    }
}
