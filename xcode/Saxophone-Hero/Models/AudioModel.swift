import Foundation
import Accelerate


class AudioModel {
    
    // MARK: Properties
    private var BUFFER_SIZE:Int
    var timeData:[Float]
    var maximums:[Float]
    var index:Int
    
    // MARK: Public Methods
    init(buffer_size:Int) {
        // anything not lazily instatntiated should be allocated here
        self.BUFFER_SIZE = buffer_size
        self.timeData = Array.init(repeating: 0.0, count: BUFFER_SIZE)
        self.maximums = Array.init(repeating: 0.0, count: 20)
        self.index = 0
    }
    
    // public function for starting processing of microphone data
    func startMicrophoneProcessing(withFps:Double){
        self.audioManager?.inputBlock = self.handleMicrophone
        
        // repeat this fps times per second using the timer class
        Timer.scheduledTimer(timeInterval: 1.0/withFps, target: self,
                            selector: #selector(self.runEveryInterval),
                            userInfo: nil,
                            repeats: true)
    }
    
    // You must call this when you want the audio to start being handled by our model
    func play(){
        self.audioManager?.play()
    }
   
    // You must call this when you want the audio to stop being handled by our model
    func pause(){
        self.audioManager?.pause()
    }
    
    //==========================================
    // MARK: Private Properties
    private lazy var audioManager:Novocaine? = {
        return Novocaine.audioManager()
    }()
    
    private lazy var outputBuffer:CircularBuffer? = {
        return CircularBuffer.init(
            numChannels: Int64(self.audioManager!.numOutputChannels),
            andBufferSize: Int64(self.BUFFER_SIZE)
        )
    }()
    
    private lazy var inputBuffer:CircularBuffer? = {
        return CircularBuffer.init(
            numChannels: Int64(self.audioManager!.numInputChannels),
            andBufferSize: Int64(self.BUFFER_SIZE)
        )
    }()
    
    
    //==========================================
    // MARK: Model Callback Methods
    @objc
    private func runEveryInterval(){
        if self.inputBuffer != nil {
            // copy data to swift array
            self.inputBuffer!.fetchFreshData(
                &self.timeData,
                withNumSamples: Int64(self.BUFFER_SIZE)
            )
        }
    }
    
    private func handleMicrophone (data:Optional<UnsafeMutablePointer<Float>>, numFrames:UInt32, numChannels: UInt32) {
        self.inputBuffer?.addNewFloatData(data, withNumSamples: Int64(numFrames))
    }
}
