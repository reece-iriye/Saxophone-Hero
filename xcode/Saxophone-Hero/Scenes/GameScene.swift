import SpriteKit

class GameScene: SKScene {

    var screenWidth:CGFloat!
    var screenHeight:CGFloat!
    var velocity:CGFloat!
    var noteHeights:[CGFloat] = [0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.15]
    var currentNote:Int = 0
    
    // Player sprite
    var player: SKSpriteNode!

    // Score variable
    var score: Int = 0 {
        didSet {
            // Update your UI or perform actions on score change
        }
    }
    
    var tempo: Int = 120 // Default tempo
    var notesArray: [CGFloat] = [] // Default empty notes array

    // Convenience initializer to pass tempo and notesArray
    convenience init(size: CGSize, tempo: Int, notesArray: [Double]) {
        self.init(size: size)
        // Get the size of the screen or the view
        let screenSize = UIScreen.main.bounds.size

        // Now you have the width and height of the screen or view
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        self.tempo = tempo
        self.notesArray = notesArray.map { CGFloat($0) }
        self.calculateVelocity()
    }

    // Initial setup of the scene
    override func didMove(to view: SKView) {
        
        setupBackground()
        setupPlayer()
        // You can now access tempo and notesArray in your scene
        print("Tempo: \(tempo)")
        print("Notes Array: \(notesArray)")
        
        beginSpawns()
        
            
    }
    
    func beginSpawns() {
        self.startSpawningMeasures()

        let noteSpawnDelay = SKAction.wait(forDuration: (1/(Double(tempo/60))*4.35))

        // Use SKAction.run to execute the startSpawningNotes method after the delay
        let startSpawningNotesAction = SKAction.run {
            self.startSpawningNotes()
        }

        let noteSpawnSequence = SKAction.sequence([noteSpawnDelay, startSpawningNotesAction])

        // Run the sequence
        run(noteSpawnSequence)
    }

    
    func calculateVelocity() {
        let measuresPerMinute = tempo/4
        let screenPerMeasure = 0.4*screenWidth
        let pixelsPerMinute = screenPerMeasure*CGFloat(measuresPerMinute)
        velocity = pixelsPerMinute/600
    }

    // Function to set up the background
    func setupBackground() {
        // Add your sheet music background or any other background setup code here
        self.backgroundColor = .white
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
        player = SKSpriteNode(color: .blue, size: CGSize(width: screenHeight*0.05, height: screenHeight*0.05))
        player.position = CGPoint(x: screenWidth*0.16, y: size.height / 2)
        addChild(player)
    }
    
    func startSpawningMeasures() {
        let measureSpawnAction = SKAction.run {
            self.spawnMeasure(xCoordinate: self.screenWidth)
        }

        let measureSpawnDelay = SKAction.wait(forDuration: (1/(Double(tempo/60)))*4) // Adjust the duration as needed

        let measureSpawnSequence = SKAction.sequence([measureSpawnAction, measureSpawnDelay])
        let measureSpawnForever = SKAction.repeatForever(measureSpawnSequence)

        run(measureSpawnForever)
    }

    // Function to start spawning blocks
    func startSpawningNotes() {
        let noteSpawnAction = SKAction.run {
            self.spawnNote()
        }

        let noteSpawnDelay = SKAction.wait(forDuration: 1/(Double(tempo/60))) // Adjust the duration as needed

        let noteSpawnSequence = SKAction.sequence([noteSpawnAction, noteSpawnDelay])
        let noteSpawnForever = SKAction.repeatForever(noteSpawnSequence)

        run(noteSpawnForever)
    }

    // Function to spawn blocks
    func spawnNote() {
        // Create a block sprite
        let note = SKSpriteNode(color: .red, size:CGSize(width: screenHeight*0.05, height: screenHeight*0.05))
        print(currentNote)
        print(notesArray[currentNote])
        note.position = CGPoint(x: screenWidth, y: screenHeight*noteHeights[Int(notesArray[currentNote])])
        self.currentNote += 1
        // Set the initial position of the block based on the array of notes
        // You need to implement your own logic to determine the vertical position based on the notes array

        // Add the block to the scene
        addChild(note)

        // Set the block's velocity to move towards the left
        let moveLeft = SKAction.moveBy(x: -velocity, y: 0, duration: 0.1) // Adjust the duration and velocity as needed
        let moveLeftForever = SKAction.repeat(moveLeft, count: 100)
        
        let wait = SKAction.wait(forDuration: 1.0) // Adjust the delay as needed
        let remove = SKAction.removeFromParent()

        // Spawn, move, wait, and remove actions
        let sequence = SKAction.sequence([moveLeftForever, wait, remove])

        // Run the actions
        note.run(sequence)
    }
    
    // Function to spawn blocks
    func spawnMeasure(xCoordinate: CGFloat) {
        // Create a block sprite
        let line = SKSpriteNode(color: .black, size: CGSize(width: 5, height: self.screenHeight*0.4))
        
        line.position = CGPoint(x: xCoordinate, y: size.height / 2)
        
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


    // Function to handle collisions
    override func update(_ currentTime: TimeInterval) {
        enumerateChildNodes(withName: "block") { node, _ in
            if self.player.intersects(node) {
                // Collision detected, add to score and remove the block
                self.score += 1
                node.removeFromParent()
            }
        }
    }

    // Handle user input (call this function when you receive input from the notes)
    func handleInput(yCoordinate: CGFloat) {
            let moveAction = SKAction.moveTo(y: 380-yCoordinate, duration: 0.1)
            player.run(moveAction)
            print(player.position)
    }
}
