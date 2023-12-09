import Foundation

class GameManager {
    static let shared = GameManager()

    var currentDifficulty = 0
    var currentLevel = 0
    var currentPlayer = "No Name"
    let difficulties = [60,90,120]
    var levels: [LevelModel] = []

    private init() {
        // Initialize levels or load them from a file/database
        // Example: Add a level with tempo 60
        let level1 = LevelModel(notesArray: [5.0,6.0,7.0,5.0,6.0,7.0,7.0,7.0,7.0,7.0,6.0,6.0,6.0,6.0,5.0,6.0,7.0], noteLengths: [2.0,2.0,4.0,2.0,2.0,4.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,2.0,4.0])
        levels.append(level1)

        // Add more levels and high scores as needed
        let level2 = LevelModel(notesArray: [0.0,1.0,2.0,3.0,13.0,4.0,3.0,2.0,0.0,1.0,2.0,3.0,4.0,5.0,13.0,13.0,2.0,13.0,3.0,4.0,5.0,6.0,5.0,4.0,2.0,3.0,4.0,5.0,6.0,7.0,13.0,7.0,6.0,2.0,2.0,13.0,0.0,1.0,3.0,13.0,13.0,7.0,4.0,4.0,13.0,13.0,4.0,2.0,3.0,4.0,5.0,13.0],
        noteLengths: [1.5,0.5,0.5,0.5,0.5,2.0,0.5,1.0,1.0,1.0,1.0,1.0,0.5,2.5,2.0,0.5,0.5,0.5,0.5,1.0,1.0,1.0,1.0,1.0,0.5,1.5,1.0,1.0,0.5,1.5,1.0,2.0,0.5,0.5,3.0,1.5,1.5,0.5,2.5,2.0,4.0,0.5,0.5,3.0,1.0,0.5,0.5,1.0,1.0,0.5,3.5,4.0])
        levels.append(level2)
    
    }
    
    func addHighScore(levelIndex: Int, tempoIndex: Int, score: Int) {
            guard levelIndex < levels.count, tempoIndex < 3 else {
                // Invalid level or tempo index
                return
            }

            let level = levels[levelIndex]

            // Check if the score is a high score
            if score > level.highScores[tempoIndex].last ?? 0 {
                // Insert the new score into the high scores array
                level.highScores[tempoIndex].append(score)
                level.highScores[tempoIndex].sort(by: >) // Sort in descending order
                level.highScores[tempoIndex].removeLast() // Keep only the top 5 scores

                // Get the player's name from the GameManager
                let playerName = currentPlayer

                // Update highScoresStr in LevelModel
                level.updateHighScoresStr(tempoIndex: currentDifficulty, playerName: playerName, newScore: score)
            }
        }
    
    func changeDifficulty(num:Int) {
        currentDifficulty = num
    }
}
