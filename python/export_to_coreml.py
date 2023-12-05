# Import CoreML Tools for converting PyTorch to CoreML type
import coremltools as ct

# Import PyTorch
import torch
import torch.nn as nn
import torch.nn.functional as F
import torchaudio.transforms as T


# Create Machine Learning model class
class MelSpectrogramCNN(nn.Module):
    def __init__(self, n_mels=256, n_fft=4410, win_length=None, hop_length=200, sample_rate=44100, n_classes=12):
        super(MelSpectrogramCNN, self).__init__()
        # Define Mel Spectrogram layer
        self.mel_spectrogram = T.MelSpectrogram(
            sample_rate=sample_rate,
            n_fft=n_fft,
            win_length=win_length,
            hop_length=hop_length,
            n_mels=n_mels,
        )
        
        # Define a small CNN for demonstration purposes
        self.conv1 = nn.Conv2d(1, 16, kernel_size=3, stride=1, padding=1)
        self.conv2 = nn.Conv2d(16, 32, kernel_size=3, stride=1, padding=1)
        self.conv3 = nn.Conv2d(32, 64, kernel_size=3, stride=1, padding=1)
        self.pool = nn.MaxPool2d(2, 2)

        # Number of pooling layers
        num_pool_layers = 3

        # After each pooling layer with kernel size 2, the size is halved
        # Initial size is [32, 1, 256, 23]
        conv_output_height = n_mels // (2**num_pool_layers)  # After pooling layers
        conv_output_width = 23 // (2**num_pool_layers)  # After pooling layers
        
        # Calculate the correct number of flattened features after the conv and pooling layers
        # Number of output channels from the last conv layer is 64
        flattened_size = 64 * conv_output_height * conv_output_width
        self.fc1 = nn.Linear(flattened_size, 500)
        self.fc2 = nn.Linear(500, n_classes)

    def forward(self, data):
        # Ensure input data is of type float (torch.float32)
        waveform = torch.tensor(data, dtype=torch.float32).unsqueeze(1) 

        # Convert waveform to Mel Spectrogram
        mel_spectrogram = self.mel_spectrogram(waveform)
        
        # Pass through CNN layers
        x = self.pool(F.relu(self.conv1(mel_spectrogram)))
        x = self.pool(F.relu(self.conv2(x)))
        x = self.pool(F.relu(self.conv3(x)))
        
        # Flatten the tensor for the fully connected layer
        x = x.view(x.size(0), -1)
        x = F.relu(self.fc1(x))
        x = self.fc2(x)
        return x


# Main method for loading CoreML model into its file
def main() -> None:
    # Load the trained PyTorch model
    model = MelSpectrogramCNN()
    model.load_state_dict(torch.load('./pytorch_model/mel_spectrogram_cnn.pth'))

    # Load the trained PyTorch model into eval mode
    model.eval()

    # Create some dummy input data that matches the model's input shape
    # The input to the MelSpectrogramCNN model is raw audio data
    dummy_input = torch.rand(1, 4410)  # Batch size of 1, 1 channel, 4410 samples

    # Trace the model with a dummy input
    traced_model = torch.jit.trace(model, dummy_input)

    # Convert to Core ML using the Unified Conversion API
    mlmodel = ct.convert(
        traced_model,
        inputs=[ct.TensorType(shape=dummy_input.shape)],  # Define the input type
    )

    # Save the Core ML model
    mlmodel.save('../xcode/Saxophone-Hero/CoreML/MelSpectrogramCNN.mlpackage')


if __name__ == "__main__":
    main()

