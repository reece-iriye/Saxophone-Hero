import SpriteKit

class GameScene: SKScene {

    var screenWidth:CGFloat!
    var screenHeight:CGFloat!
    var velocity:CGFloat!
    var noteHeights:[CGFloat] = [0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.15, 0.15]
//    [0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.15]
    var currentNote:Int = 0
    var attacking:Bool = false  // No initial attack state for the character
    
    var repeatAttackAnimation:SKAction!
    var repeatRunAnimation:SKAction!
    
    var scoreLabel: SKLabelNode!
    
    // Player sprite
    var player: SKNode!
    
    struct AudioConstants{
        static let AUDIO_BUFFER_SIZE = 4410
    }
    
    // Set up model for reading in audio
    let audio = AudioModel(buffer_size: AudioConstants.AUDIO_BUFFER_SIZE)
    
    // Set up model for interpreting audio
    let activeNoteModel = ActiveNoteModel()

    // Score variable
    var score: Int = 0 {
        didSet {
            // Update your UI or perform actions on score change
        }
    }
    
    var tempo: Int = 120 // Default tempo
    var notesArray: [CGFloat] = [] // Default empty notes array
    var noteLengths: [Double] = []

    // Convenience initializer to pass tempo and notesArray
    convenience init(size: CGSize, tempo: Int, notesArray: [Double], noteLengths: [Double]) {
        self.init(size: size)
        // Get the size of the screen or the view
        let screenSize = UIScreen.main.bounds.size

        // Now you have the width and height of the screen or view
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        self.tempo = tempo
        self.notesArray = notesArray.map { CGFloat($0) }
        self.noteLengths = noteLengths
        self.calculateVelocity()
    }

    // Initial setup of the scene
    override func didMove(to view: SKView) {
        var textures:[SKTexture] = []
        let atlas = SKTextureAtlas(named: "Sprites")
        for i in 1...atlas.textureNames.count {
            let textureName = "walk_\(i)"
            let texture = atlas.textureNamed(textureName)
            textures.append(texture)
        }
        
        let runAnimation = SKAction.sequence([
            SKAction.animate(with: [textures[1]], timePerFrame: 0.15),
            SKAction.animate(with: [textures[3]], timePerFrame: 0.15)
        ])
        let attackAnimation = SKAction.sequence([
            SKAction.animate(with: [textures[0]],timePerFrame: 0.05),
            SKAction.animate(with: [textures[2]],timePerFrame: 0.05),
            SKAction.animate(with: [textures[0]],timePerFrame: 0.05),
            SKAction.animate(with: [textures[2]],timePerFrame: 0.05),
        ])
        
        SKAction.animate(withNormalTextures: [textures[1],textures[2],textures[1],textures[2]], timePerFrame: 0.05)
        self.repeatRunAnimation = SKAction.repeatForever(runAnimation)
        self.repeatAttackAnimation = SKAction.repeatForever(attackAnimation)
        
        self.setupBackground()
        self.setupPlayer()
        
        // Create and add the score label
        self.setupScoreLabel()
        
        self.beginSpawns()
        
        // start up the audio model here, querying microphone
        self.audio.startMicrophoneProcessing(withFps: 20) // preferred number of FFT calculations per second, we don't use vDSP FFT though as a note
        
        self.audio.play()
    }
    
    func beginSpawns() {
        self.startSpawningMeasures()

        let noteSpawnDelay = SKAction.wait(forDuration: (1/(Double(tempo/60))*4))

        // Use SKAction.run to execute the startSpawningNotes method after the delay
        let startSpawningNotesAction = SKAction.run {
            self.startSpawningNotes()
        }

        let noteSpawnSequence = SKAction.sequence([noteSpawnDelay, startSpawningNotesAction])

        // Run the sequence
        run(noteSpawnSequence)
    }
    
    // Function to set up the score label
    func setupScoreLabel() {
        self.scoreLabel = SKLabelNode(text: "Score: 0")
        DispatchQueue.main.async {
            self.scoreLabel.fontName = "Helvetica"
            self.scoreLabel.fontSize = 35
            self.scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height*0.9)
            self.scoreLabel.fontColor = .white // or any contrasting color
        }
        addChild(self.scoreLabel)
    }

    
    func calculateVelocity() {
        let measuresPerMinute = self.tempo/4
        let screenPerMeasure = 0.4*screenWidth
        let pixelsPerMinute = screenPerMeasure*CGFloat(measuresPerMinute)
        self.velocity = pixelsPerMinute/600
    }

    // Function to set up the background
    func setupBackground() {
        // Add your sheet music background or any other background setup code here
        
        // Load the background texture
        let backgroundImage = SKSpriteNode(imageNamed: "background")
        
        // Set the position to the center of the scene
        backgroundImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        backgroundImage.alpha = 0.35

        // Add the background to the scene
        addChild(backgroundImage)
        
        self.createHorizontalLines()
        self.createRestZone()
        self.spawnMeasure(xCoordinate: screenWidth*0.6)
        self.spawnMeasure(xCoordinate: screenWidth*0.2)
    }
    
    func createHorizontalLines() {
        // Heights as percentages of the screen height
        let heights: [CGFloat] = [0.3, 0.4, 0.5, 0.6, 0.7]

        // Create horizontal lines
        for heightPercentage in heights {
            let lineHeight = self.size.height * heightPercentage
            let line = SKSpriteNode(color: .black, size: CGSize(width: self.size.width, height: 5))
            line.position = CGPoint(x: self.size.width / 2, y: lineHeight)
            line.zPosition = 5
            line.alpha = 0.8
            line.color = .white
            addChild(line)
        }
    }
    
    func createRestZone() {
        // Rest zone dimensions and position
        let restZoneHeightPercentage: CGFloat = 0.1
        let restZonePositionPercentage: CGFloat = 0.15

        // Calculate rest zone height and position
        let restZoneHeight = self.size.height * restZoneHeightPercentage
        let restZonePosition = self.screenHeight * restZonePositionPercentage

        // Create rest zone
        let restZone = SKSpriteNode(color: UIColor.blue.withAlphaComponent(0.5), size: CGSize(width: self.size.width, height: restZoneHeight))
        restZone.position = CGPoint(x: self.size.width / 2, y: restZonePosition)
        addChild(restZone)
    }

    // Function to set up the player sprite
    func setupPlayer() {
        self.player = SKNode()

        // Visual Node
        let visualNode = SKSpriteNode(imageNamed: "Ninja Idle.png")
        visualNode.size = CGSize(width: self.screenHeight*0.13, height: self.screenHeight*0.13)
        visualNode.name = "visualNode"
        visualNode.run(self.repeatRunAnimation, withKey: "runAnimation")
        self.player.position = CGPoint(x: self.screenWidth*0.16, y: size.height / 2)
        self.player.zPosition = 10
        self.player.addChild(visualNode)

        // Collision Node
        let collisionNode = SKSpriteNode()
        collisionNode.size = CGSize(width: self.screenHeight*0.04, height: self.screenHeight*0.04)
        collisionNode.name = "collisionNode"
        collisionNode.position = CGPoint(x: 15, y: 3)
        self.player.addChild(collisionNode)

        // Create a stroked shape node as an outline
        let outlineNode = SKShapeNode(rectOf: collisionNode.size, cornerRadius: 5.0)
        outlineNode.strokeColor = SKColor.red  // Set the color of the outline
        outlineNode.lineWidth = 2.0  // Set the width of the outline
        outlineNode.position = CGPoint(x: -collisionNode.size.width / 2, y: -collisionNode.size.height / 2)
        collisionNode.addChild(outlineNode)
        
        self.player.name = "player"
        addChild(self.player)
    }

    
    func startSpawningMeasures() {
        let measureSpawnAction = SKAction.run {
            self.spawnMeasure(xCoordinate: self.screenWidth)
        }

        let measureSpawnDelay = SKAction.wait(forDuration: (1/(Double(self.tempo/60)))*4) // Adjust the duration as needed

        let measureSpawnSequence = SKAction.sequence([measureSpawnAction, measureSpawnDelay])
        let measureSpawnForever = SKAction.repeatForever(measureSpawnSequence)

        run(measureSpawnForever)
    }

    // Function to start spawning blocks
    func startSpawningNotes() {
        var actions: [SKAction] = []
        
        for (note, length) in zip(self.notesArray.enumerated(), self.noteLengths.enumerated()) {
            let beat = 1/(Double(tempo/60))
            //let noteDuration = TimeInterval(1.0)
            let noteDuration = TimeInterval(beat*(length.element))

            let noteSpawnAction = SKAction.sequence([
                SKAction.run {
                    self.spawnNote(notePos:note.element, noteLen:length.element*0.25)
                },
                SKAction.wait(forDuration: noteDuration)
            ])

            actions.append(noteSpawnAction)

        }
        
        // Add the spawnFinish action to the sequence
        actions.append(SKAction.wait(forDuration: 2))
        
        actions.append(SKAction.run {
            self.spawnFinish()
        })

        // Run the entire sequence of actions
        run(SKAction.sequence(actions))
    }



    // Function to spawn blocks
    func spawnNote(notePos:CGFloat, noteLen:Double) {
        // Create a block sprite
        let note = SKSpriteNode(color: .red, size:CGSize(width: screenWidth*0.4*noteLen*0.98, height: screenHeight*0.05))
        note.position = CGPoint(x: screenWidth+(0.5*noteLen*0.4*screenWidth), y: screenHeight*noteHeights[Int(notePos)])
        // Set the initial position of the block based on the array of notes
        // You need to implement your own logic to determine the vertical position based on the notes array
        note.name = "note"

        // Add the block to the scene
        addChild(note)

        // Set the block's velocity to move towards the left
        let moveLeft = SKAction.moveBy(x: -velocity, y: 0, duration: 0.1) // Adjust the duration and velocity as needed
        let moveLeftForever = SKAction.repeat(moveLeft, count: 120)
        
        let remove = SKAction.removeFromParent()

        // Spawn, move, wait, and remove actions
        let sequence = SKAction.sequence([moveLeftForever, remove])

        // Run the actions
        note.run(sequence)
    }
    
    // Function to spawn blocks
    func spawnMeasure(xCoordinate: CGFloat) {
        // Create a block sprite
        let line = SKSpriteNode(color: .white, size: CGSize(width: 5, height: self.screenHeight*0.4))
        
        line.position = CGPoint(x: xCoordinate, y: size.height / 2)
        
        line.zPosition = 5
        
        line.alpha = 0.8
        
        // Add the block to the scene
        addChild(line)

        // Set the block's velocity to move towards the left
        let moveLeft = SKAction.moveBy(x: -velocity, y: 0, duration: 0.1) // Adjust the duration and velocity as needed
        let moveLeftForever = SKAction.repeat(moveLeft, count: 100)
        
        let wait = SKAction.wait(forDuration: 1.0) // Adjust the delay as needed
        let remove = SKAction.removeFromParent()

        // Spawn, move, wait, and remove actions
        let sequence = SKAction.sequence([moveLeftForever, wait, remove])

        // Run the actions
        line.run(sequence)
    }
    
    func spawnFinish() {
        // Create a block sprite
        let finishLine = SKSpriteNode(color: .green, size: CGSize(width: 50, height: self.screenHeight))
        
        finishLine.position = CGPoint(x: self.screenWidth, y: size.height / 2)
        
        finishLine.name = "finish"
        
        // Add the block to the scene
        addChild(finishLine)

        // Set the block's velocity to move towards the left
        let moveLeft = SKAction.moveBy(x: -velocity, y: 0, duration: 0.1) // Adjust the duration and velocity as needed
        let moveLeftForever = SKAction.repeat(moveLeft, count: 100)
        
        let wait = SKAction.wait(forDuration: 1.0) // Adjust the delay as needed
        let remove = SKAction.removeFromParent()

        // Spawn, move, wait, and remove actions
        let sequence = SKAction.sequence([moveLeftForever, wait, remove])

        // Run the actions
        finishLine.run(sequence)
    }


    // Function to handle collisions
    override func update(_ currentTime: TimeInterval) {
        // Immediately label colliding as false
        var isColliding = false
        
        enumerateChildNodes(withName: "note") { node, _ in
            if (self.player.childNode(withName: "collisionNode")?.intersects(node) != false) {
                // Collision with note detected, add to score and remove the note
                self.score += 1
                
                // Update score and invoke attack animation on the Main Queue
                self.scoreLabel.text = "Score: \(self.score)"
                if(!self.attacking) {
                    print("attacking")
                    self.player.childNode(withName: "visualNode")?.removeAction(forKey: "runAnimation")
                    self.player.childNode(withName: "visualNode")?.run(self.repeatAttackAnimation, withKey: "attackAnimation")
                    self.attacking = true
                }

                isColliding = true
            }
        }
        
        // If the character is attacking and not colliding with a block, replace attack animation with run animation
        if(self.attacking && !isColliding) {
            print("running")
            self.player.childNode(withName: "visualNode")?.removeAction(forKey: "attackAnimation")
            self.player.childNode(withName: "visualNode")?.run(self.repeatRunAnimation, withKey: "runAnimation")
            self.attacking = false
        }

        // End the level if the player ends up colliding with the finish line
        enumerateChildNodes(withName: "finish") { node, _ in
            if (self.player.childNode(withName: "collisionNode")?.intersects(node) != false) {
                // Collision with finish detected, trigger endLevel function
                self.endLevel()
            }
        }
        
        // Check if the amplitude of any value in timeData exceeds 0.1
        let restThreshold: Float = 0.1
        let isAmplitudeHigh = self.audio.timeData.contains { abs($0) > restThreshold }

        if isAmplitudeHigh {
            // Invoke the Mel Spectrogram CNN CoreML Model to return the current pitch
            let currentPitch: Int = self.activeNoteModel.retrieveCurrentPitch(
                audioData: self.audio.timeData
            )
            
            // Height location where player needs to move to based on note played
            let playerDestination = CGFloat(self.screenHeight * self.noteHeights[currentPitch])
            self.handleInput(yCoordinate: playerDestination)

            // Print the maximum absolute value in timeData
            if let maxAmplitude = self.audio.timeData.max(by: { abs($0) < abs($1) }) {
                print("READ Max amplitude: \(abs(maxAmplitude))")
            }
            
        } else {
            // Print the maximum absolute value in timeData
            if let maxAmplitude = self.audio.timeData.max(by: { abs($0) < abs($1) }) {
                print("SILENT Max amplitude: \(abs(maxAmplitude))")
            }
            
            // Fetch rest note
            let currentPitch: Int = self.activeNoteModel.retrieveRestNote()
            
            // Height location where player needs to move to based on note played
            let playerDestination = CGFloat(self.screenHeight * self.noteHeights[currentPitch])
            self.handleInput(yCoordinate: playerDestination)
            
//            print(playerDestination)
        }
    }
    
    func endLevel() {
        // Remove all nodes from the scene
        removeAllChildren()
        
        // Stop spawning actions for measures and finish line
        self.removeAllActions()

        // Create a label to display the score
        let endLabel = SKLabelNode(fontNamed: "Helvetica")
        
        // Update label properties
        endLabel.text = "Score: \(self.score)"
        endLabel.fontSize = 50
        endLabel.position = CGPoint(x: self.screenWidth / 2, y: self.screenHeight*0.6)
        endLabel.fontColor = .white
        
        // Add the main queue to the
        addChild(endLabel)

        // Create a player node and position it underneath the score label
        self.player = SKNode()
        let visual = SKSpriteNode(imageNamed: "Ninja Idle.png")
        visual.size = CGSize(width: self.screenHeight*0.3, height: self.screenHeight*0.2)
        self.player.addChild(visual)
        self.player.position = CGPoint(x: size.width / 2, y: endLabel.position.y - (endLabel.frame.size.height+20))
        addChild(self.player)

        // Create a button node
        let backButton = SKLabelNode(fontNamed: "Helvetica")
        backButton.text = "Back to Menu"
        backButton.fontSize = 30
        // Adjust the yOffset based on the visual node's height
        let yOffset: CGFloat = -visual.size.height / 2 - 20
        backButton.position = CGPoint(x: size.width / 2, y: self.player.position.y + yOffset-20)
        backButton.fontColor = .white
        backButton.color = .black
        backButton.name = "backButton"  // Set a name for the button to identify it later
        addChild(backButton)
    }

    // Add this function to your GameScene class
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)

            if touchedNode.name == "backButton" {
                // Handle the button tap (e.g., navigate back to the previous screen)

                // Transition back to the initial view controller
                if let view = self.view {
                    let transition = SKTransition.fade(withDuration: 0.5)
                    let initialViewController = self.view?.window?.rootViewController
                    view.presentScene(nil)  // Remove the current scene
                    initialViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }


    // Handle user input (call this function when you receive input from the notes)
    func handleInput(yCoordinate: CGFloat) {
        let moveAction = SKAction.moveTo(y: yCoordinate, duration: 0.05)
        self.player.run(moveAction)
    }
}
