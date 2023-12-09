
import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var Level1Player1: UILabel!
    @IBOutlet weak var Level1Player2: UILabel!
    @IBOutlet weak var Level1Player3: UILabel!
    @IBOutlet weak var Level1Player4: UILabel!
    @IBOutlet weak var Level1Player5: UILabel!
    
    @IBOutlet weak var Level2Player1: UILabel!
    @IBOutlet weak var Level2Player2: UILabel!
    @IBOutlet weak var Level2Player3: UILabel!
    @IBOutlet weak var Level2Player4: UILabel!
    @IBOutlet weak var Level2Player5: UILabel!
    
    @IBOutlet weak var flame1: UIImageView!
    @IBOutlet weak var flame2: UIImageView!
    @IBOutlet weak var flame3: UIImageView!
    
    @IBOutlet weak var difficultyLabel: UILabel!
    
    let gameManager = GameManager.shared
    
    @IBAction func setDifficulty(_ sender: UISlider) {
        let difficulty = Int(sender.value)
        
        if(difficulty == 0){
            flame1.isHidden = true;
            flame2.isHidden = true;
            flame3.isHidden = true;
            difficultyLabel.text = "Difficulty-Easy";
            gameManager.currentDifficulty = 0
        }
        else if(difficulty == 1){
            flame1.isHidden = false;
            flame2.isHidden = true;
            flame3.isHidden = true;
            difficultyLabel.text = "Difficulty-Medium";
            gameManager.currentDifficulty = 1
        }
        else{
            flame1.isHidden = false;
            flame2.isHidden = false;
            flame3.isHidden = false;
            difficultyLabel.text = "Difficulty-Hard";
            gameManager.currentDifficulty = 2
        }
    }
    
    
    
    override func viewDidLoad() {
        self.reloadLabels()
    }
    
    func reloadLabels() {
        let level1Scores = gameManager.levels[0].getScores(difficulty: gameManager.currentDifficulty)
        let level2Scores = gameManager.levels[1].getScores(difficulty: gameManager.currentDifficulty)
        
        Level1Player1.text = level1Scores[0]
        Level1Player2.text = level1Scores[1]
        Level1Player3.text = level1Scores[2]
        Level1Player4.text = level1Scores[3]
        Level1Player5.text = level1Scores[4]
        
        Level2Player1.text = level2Scores[0]
        Level2Player2.text = level2Scores[1]
        Level2Player3.text = level2Scores[2]
        Level2Player4.text = level2Scores[3]
        Level2Player5.text = level2Scores[4]
    }
}
