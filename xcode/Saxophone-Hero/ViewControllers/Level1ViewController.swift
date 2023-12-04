import UIKit
import SpriteKit

class Level1ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true

        // Create and configure the scene
        let tempo = 120
        // Generate an array of 50 doubles from 0.0 to 11.0
        let notesArray: [Double] = [0.0,1.0,2.0,13.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0] // Replace with your actual notes
        let noteLengthsArray: [Double] = [1,1,1,1,0.5,1,2,1,2,2,1]
        let scene = GameScene(size: skView.bounds.size, tempo: tempo, notesArray: notesArray, noteLengths: noteLengthsArray)

        scene.scaleMode = .aspectFill

        // Present the scene
        skView.presentScene(scene)

        // Handle user input (for example, tap gestures to move the player up and down)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        skView.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            if let gameScene = (view as? SKView)?.scene as? GameScene {
                let tapLocation = gesture.location(in: view)
                gameScene.handleInput(yCoordinate: tapLocation.y)
            }
    }

    // ... (any additional code you may need)
}
