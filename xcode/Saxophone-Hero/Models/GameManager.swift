import Foundation

class GameManager:NSObject {
    static let shared = GameManager()

    var levels: [LevelModel] = []
    var currentLevel: Int = 0
    var chosenDifficulty: Int = 0

    override private init() {
        // Initialize levels or load them from a file/database
        // Example: Add a level with tempo 60
        let level1 = LevelModel(notesArray: [5.0,6.0,7.0,5.0,6.0,7.0,7.0,7.0,7.0,7.0,6.0,6.0,6.0,6.0,5.0,6.0,7.0,5.0,6.0,7.0,5.0,6.0,7.0,7.0,7.0,7.0,7.0,6.0,6.0,6.0,6.0,5.0,6.0,7.0], 
            noteLengths:[2.0,2.0,4.0,2.0,2.0,4.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,2.0,4.0,2.0,2.0,4.0,2.0,2.0,4.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,2.0,4.0])
        levels.append(level1)


        // Add more levels and high scores as needed
    }

    func addHighScore(score: Double) {
        guard currentLevel < levels.count, chosenDifficulty < 3 else {
            // Invalid level or tempo index
            return
        }

        let level = levels[currentLevel]

        // Check if the score is a high score
        if score > level.highScores[chosenDifficulty].last ?? 0 {
            // Insert the new score into the high scores array
            level.highScores[chosenDifficulty].append(score)
            level.highScores[chosenDifficulty].sort(by: >) // Sort in descending order
            level.highScores[chosenDifficulty].removeLast() // Keep only the top 5 scores
        }
    }
    
    func grabScores(level: Int) -> [[Double]]{
        let level = levels[currentLevel]
        let scores = level.getScores(difficulty: self.chosenDifficulty)
        let accuracies = level.getAccuracies(difficulty: self.chosenDifficulty)
        let combo = [scores,accuracies]
        return combo
    }
    
    func setDifficulty(difficulty:Int) {
        self.chosenDifficulty = difficulty
    }
    
    func getCurrentLevel() -> LevelModel {
        return levels[currentLevel]
    }
}
