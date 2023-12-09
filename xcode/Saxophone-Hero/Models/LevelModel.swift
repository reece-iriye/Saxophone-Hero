import Foundation

class LevelModel {
    var notesArray: [Double] = []
    var noteLengths: [Double] = []
    var tempo: Int = 0
    var highScores: [[Int]] = Array(repeating: Array(repeating: 0, count: 5), count: 3) // 3x5 2D array

    init(notesArray: [Double], noteLengths: [Double]) {
        self.notesArray = notesArray
        self.noteLengths = noteLengths
    }
}
