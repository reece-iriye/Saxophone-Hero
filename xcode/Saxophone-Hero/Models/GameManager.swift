import Foundation

class GameManager {
    static let shared = GameManager()

    var levels: [LevelModel] = []

    private init() {
        // Initialize levels or load them from a file/database
        // Example: Add a level with tempo 60
        let level1 = LevelModel(notesArray: [0.5, 0.75, 0.25, 0.5], noteLengths: [0.5, 0.25, 0.5, 0.25])
        levels.append(level1)

        // Add more levels and high scores as needed
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
        }
    }
}
