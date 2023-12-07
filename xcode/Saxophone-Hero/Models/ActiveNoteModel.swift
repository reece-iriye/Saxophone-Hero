
import UIKit
import CoreML


class ActiveNoteModel: NSObject {
    
    // Rest Note is 13
    let restNote: Int = 13
    
    // Create instance of machine learning model
    var pitchDetector: MelSpectrogramCNN?
    
    override init() {
        super.init()
        
        // Declare the CoreML Model for Pitch Detection
        do {
            self.pitchDetector = try MelSpectrogramCNN(configuration: MLModelConfiguration())
        } catch {
            fatalError("Failed to load model: \(error)")
        }
    }
    
    
    func retrieveCurrentPitch(audioData: [Float]) -> Int {
        guard let pitchDetector = self.pitchDetector else {
            fatalError("Model Not Found in Scope")
        }

        // Data Preprocessing to match the input format of the model
        let processedData = self.preprocessTimeData(audioData)

        // Creating Model Input
        let modelInput = MelSpectrogramCNNInput(data: processedData)

        do {
            let prediction = try pitchDetector.prediction(input: modelInput)
            // Convert prediction to integer pitch value
            let pitchValue = self.processPrediction(prediction)
            return pitchValue
        } catch {
            fatalError("Error during prediction: \(error)")
        }
    }
    
    // Helper function to preprocess time data
    func preprocessTimeData(_ data: [Float]) -> MLMultiArray {
        // Ensure the data is of the correct length
        guard data.count == 4410 else {
            fatalError("Input data must have exactly 4410 elements.")
        }

        // Conduct the prediction with a ML
        do {
            let mlArray = try MLMultiArray(shape: [1, 4410], dataType: .float32)
            for (index, element) in data.enumerated() {
                mlArray[index] = NSNumber(value: element)
            }
            return mlArray
        } catch {
            fatalError("Error creating MLMultiArray: \(error)")
        }
    }

    // Helper function to process prediction output
    func processPrediction(_ prediction: MelSpectrogramCNNOutput) -> Int {
        // Retrieve the LogitsArray from MelSpectrogram CNN Output
        let logitsArray = prediction.linear_1

        // Calculate softmax and obtain value with largest probability
        let probabilities = self.softmax(logits: logitsArray)
        let predictedPitch = self.indexOfMax(in: probabilities) // Finding the index of the max probability
        return predictedPitch
    }

    // Softmax implementation
    func softmax(logits: MLMultiArray) -> [Double] {
        var expValues = [Double]()
        let total = logits.count

        // Calculate the sum of the exponentials of the logits
        var sumExp = 0.0
        for i in 0..<total {
            let expValue = exp(logits[i].doubleValue)
            expValues.append(expValue)
            sumExp += expValue
        }

        // Normalize each value
        return expValues.map { $0 / sumExp }
    }

    // Function to find the index of the maximum value in an array
    func indexOfMax(in array: [Double]) -> Int {
        guard !array.isEmpty else {
            fatalError("Array is empty")
        }
        
        // Assign these values to be negative infinity
        var maxIndex = -1
        var maxValue = -Double.infinity

        for (index, value) in array.enumerated() {
            if value > maxValue {
                maxValue = value
                maxIndex = index
            }
        }

        // In Mel Spectrogram CNN, notes are labeled from 0 to 11 from high C to low F
        return maxIndex
    }
    
    // Retrieve a rest
    func retrieveRestNote() -> Int {
        return self.restNote  // 13 is what we are using for showcasing a rest
    }
}
