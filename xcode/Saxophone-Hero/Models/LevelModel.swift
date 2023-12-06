import Foundation

class LevelModel: NSObject {
    var notesArray: [Double] = []
    var noteLengths: [Double] = []
    var highScores: [[Double]] = Array(repeating: Array(repeating: 0, count: 5), count: 3) // 3x5 2D array // Top 5 high scores
    var highAccuracies: [[Double]] = Array(repeating: Array(repeating: 0.0, count: 5), count: 3) // 3x5 2D array // Top 5 high scores

    init(notesArray: [Double], noteLengths: [Double]) {
        self.notesArray = notesArray
        self.noteLengths = noteLengths
        print(self.notesArray.count)
        print(self.noteLengths.count)
    }
    
    func getNotes() -> [Double] {
        return notesArray
    }
    
    func getLengths() -> [Double] {
        return noteLengths
    }
    
    func getScores(difficulty:Int) -> [Double] {
        return highScores[difficulty]
    }
    
    func getAccuracies(difficulty:Int) -> [Double] {
        return highAccuracies[difficulty]
    }
}
