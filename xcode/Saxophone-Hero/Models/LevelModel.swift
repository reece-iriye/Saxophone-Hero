import Foundation

class LevelModel: Codable{
    var notesArray: [Double] = []
    var noteLengths: [Double] = []
    var highScores: [[Int]] = Array(repeating: Array(repeating: 0, count: 5), count: 3) // 3x5 2D array
    var highScoresNames: [[String]] = Array(repeating: Array(repeating: "No Name", count: 5), count: 3) // 3x5 2D array

    init(notesArray: [Double], noteLengths: [Double]) {
        self.notesArray = notesArray
        self.noteLengths = noteLengths
    }

    func getScores(difficulty: Int) -> [String] {
        let scores = highScores[difficulty]
        let names = highScoresNames[difficulty]

        // Zip the scores and names arrays and map them to the desired format
        let formattedScores = zip(names, scores).map { name, score in
            if score != 0 {
                return "\(name): \(score)"
            } else {
                return "None"
            }
        }

        return formattedScores
    }
    
    func updateHighScores(score: Int, name: String, difficulty: Int) {
        var scores = highScores[difficulty]
        var names = highScoresNames[difficulty]

        // Check if the new score is higher than any existing score
        if let index = scores.firstIndex(where: { $0 < score }) {
            // Insert the new score and name at the appropriate position
            scores.insert(score, at: index)
            names.insert(name, at: index)

            // Remove the last element if the array exceeds 5 entries
            if scores.count > 5 {
                scores.removeLast()
                names.removeLast()
            }
        }

        // Update the highScores and highScoresNames arrays
        highScores[difficulty] = scores
        highScoresNames[difficulty] = names
    }
    
}
