import Foundation

class LevelModel {
    var notesArray: [Double] = []
    var noteLengths: [Double] = []
    var highScores: [[Int]] = Array(repeating: Array(repeating: 0, count: 5), count: 3) // 3x5 2D array
    var highScoresStr: [[String]] = Array(repeating: Array(repeating: "None", count: 5), count: 3) // 3x5 2D array

    init(notesArray: [Double], noteLengths: [Double]) {
        self.notesArray = notesArray
        self.noteLengths = noteLengths
    }

    func getScores(difficulty:Int) -> [String]{
        return highScoresStr[difficulty]
    }
    
    func updateHighScoresStr(tempoIndex: Int, playerName: String, newScore: Int) {
            // Update highScoresStr based on highScores, playerName, and newScore
            let highScores = self.highScores[tempoIndex]
            var updatedHighScoresStr: [String] = []

            var addedNewScore = false

            for (index, score) in highScores.enumerated() {
                if index < highScoresStr[tempoIndex].count {
                    if newScore > score && !addedNewScore {
                        // Insert the new score with the player name
                        let scoreStr = "\(playerName): \(newScore)"
                        updatedHighScoresStr.append(scoreStr)
                        addedNewScore = true
                    } else {
                        // Use the existing string for other entries
                        updatedHighScoresStr.append(highScoresStr[tempoIndex][index])
                    }
                } else {
                    // Use "None" for entries without a score
                    updatedHighScoresStr.append("None")
                }
            }

            self.highScoresStr[tempoIndex] = updatedHighScoresStr
        }
    
}
