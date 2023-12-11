import Foundation

class GameManager {
    static let shared = GameManager()

    var currentDifficulty = 0
    var currentLevel = 0
    var currentPlayer = "No Name"
    let difficulties = [60,90,120]
    var levels: [LevelModel] = []

    private let levelsKey = "levelsKey"

    private init() {
        // Load levels from UserDefaults
//        if let savedLevelsData = UserDefaults.standard.data(forKey: levelsKey),
//           let savedLevels = try? JSONDecoder().decode([LevelModel].self, from: savedLevelsData) {
//            levels = savedLevels
//        } else {
            // If loading fails or levels haven't been saved yet, initialize default levels
            let level1 = LevelModel(
                // Notes for Level 1
                notesArray: [6.0, 7.0, 8.0, 6.0, 7.0, 8.0, 8.0, 8.0, 8.0, 8.0, 7.0, 7.0, 7.0, 7.0, 6.0, 7.0, 8.0],
//                notesArray: [9.0, 10.0, 11.0, 9.0, 10.0, 11.0, 11.0, 11.0, 11.0, 11.0, 10.0, 10.0, 10.0, 10.0, 9.0, 10.0, 11.0],
                // Note types   for Level 1
                noteLengths: [2.0, 2.0, 4.0, 2.0, 2.0, 4.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 4.0])
            levels.append(level1)

            let level2 = LevelModel(
                // Notes for Level 2
                notesArray: [0.0, 1.0, 2.0, 3.0, 13.0, 4.0, 3.0, 2.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 13.0, 13.0, 2.0, 13.0, 3.0, 4.0, 5.0, 6.0, 5.0, 4.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 13.0, 7.0, 6.0, 2.0, 2.0, 13.0, 0.0, 1.0, 3.0, 13.0, 13.0, 7.0, 4.0, 4.0, 13.0, 13.0, 4.0, 2.0, 3.0, 4.0, 5.0, 13.0],
                // Note types for Level 2
                noteLengths: [1.5, 0.5, 0.5, 0.5, 0.5, 2.0, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 2.5, 2.0, 0.5, 0.5, 0.5, 0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5, 1.5, 1.0, 1.0, 0.5, 1.5, 1.0, 2.0, 0.5, 0.5, 3.0, 1.5, 1.5, 0.5, 2.5, 2.0, 4.0, 0.5, 0.5, 3.0, 1.0, 0.5, 0.5, 1.0, 1.0, 0.5, 3.5, 4.0])
            levels.append(level2)
        }
//    }
    
    func addHighScore(levelIndex: Int, tempoIndex: Int, score: Int) {
        guard levelIndex < levels.count, tempoIndex < 3 else {
            // Invalid level or tempo index
            return
        }

        let level = levels[levelIndex]


        // Update Scores in LevelModel
        level.updateHighScores(score: score, name:self.currentPlayer, difficulty: self.currentDifficulty)
        
        self.saveLevels()
    }
    
    func changeDifficulty(num:Int) {
        currentDifficulty = num
    }
    
    private func saveLevels() {
        if let levelsData = try? JSONEncoder().encode(levels) {
            UserDefaults.standard.set(levelsData, forKey: levelsKey)
        }
    }
}
