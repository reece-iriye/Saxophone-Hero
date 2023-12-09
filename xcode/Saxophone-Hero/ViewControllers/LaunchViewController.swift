
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
    
    @IBAction func setDifficulty(_ sender: UISlider) {
        let difficulty = Int(sender.value)
        
        if(difficulty == 0){
            flame1.isHidden = true;
            flame2.isHidden = true;
            flame3.isHidden = true;
            difficultyLabel.text = "Difficulty-Easy";
        }
        else if(difficulty == 1){
            flame1.isHidden = false;
            flame2.isHidden = true;
            flame3.isHidden = true;
            difficultyLabel.text = "Difficulty-Medium";
        }
        else{
            flame1.isHidden = false;
            flame2.isHidden = false;
            flame3.isHidden = false;
            difficultyLabel.text = "Difficulty-Hard";
        }
    }
    
    override func viewDidLoad() {
        
    }
}
