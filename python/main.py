#!usr/bin/python
"""
NOTE:
    For this application to run properly, MongoDB must be running.


=========================================================
IMPORTS
=========================================================
"""

# Imports for managing server access, routing, and database logic
import uvicorn
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel
from motor.motor_asyncio import AsyncIOMotorClient

# Imports for handling data and ML model development & execution
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import LabelEncoder, OneHotEncoder
import torch
import torch.nn as nn
import torch.nn.functional as F 
from torch.utils.data import DataLoader, TensorDataset
import torchaudio.transforms as T

# Standard library imports
import joblib  # To save and load Scikit-Learn models
import os
from typing import List, Tuple, Dict, Union, Any

"""
=========================================================
GLOBAL VARIABLES, CLASSES, AND NECESSARY CODE BLOCKS TO EXECUTE
=========================================================
"""

# Initialize FastAPI app
app = FastAPI()

# MongoDB client setup with database name of `mydatabase` 
mongo_client: AsyncIOMotorClient = (
    AsyncIOMotorClient("mongodb://localhost:27017")
)
db = mongo_client.mydatabase

# Declare Logistic Regression model
logistic_model = LogisticRegression()

# Create a label encoder object
label_encoder = LabelEncoder()
one_hot_encoder = OneHotEncoder(sparse_output=False)

# Fit the label encoder and one-hot encoder with the known labels
known_labels = np.array(["Chris", "Reece"])
label_encoder.fit(known_labels)
one_hot_encoder.fit(known_labels.reshape(-1, 1))

# Specify Mel Spectrogram CNN Architecture
class MelSpectrogramCNN(nn.Module):
    def __init__(self, n_mels, n_frames):
        super(MelSpectrogramCNN, self).__init__()
        self.conv1 = nn.Conv2d(1, 32, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
        self.conv2 = nn.Conv2d(32, 64, kernel_size=(3, 3), stride=(1, 1), padding=(1, 1))
        self.pool = nn.MaxPool2d(kernel_size=(2, 2), stride=(2, 2), padding=(1, 1))
        
        # Calculate the size of the layer before the fully connected layer
        # flat_size = 64 * 33 * 12 = 25344
        self.fc_input_size = 25344 
        
        self.fc1 = nn.Linear(self.fc_input_size, 500)
        self.fc2 = nn.Linear(500, 2)  # 2 classes

    def forward(self, x):
        x = self.pool(F.relu(self.conv1(x)))
        x = self.pool(F.relu(self.conv2(x)))
        # Print the size here to debug
        flat_size = x.size(1) * x.size(2) * x.size(3) # Correctly calculate the flattened size
        x = x.view(-1, flat_size)  # Flatten the tensor
        x = F.relu(self.fc1(x))
        x = self.fc2(x)
        return x

# Declare Mel Spectogram models and necessary variables
spectogram_cnn = MelSpectrogramCNN(n_mels=128, n_frames=40)

# Function to load machine learning models from the file system.
def load_machine_learning_models():
    """
    Function to load machine learning models from the file system.
    """
    logistic_regression_path = "../ml_models/logistic_regression_model.pkl"
    mel_spectrogram_cnn_path = "../ml_models/mel_spectrogram_cnn.pth"

    # Load Logistic Regression model if exists, else create a new one
    if os.path.exists(logistic_regression_path):
        logistic_model = joblib.load(logistic_regression_path)
    else:
        logistic_model = LogisticRegression()
        joblib.dump(logistic_model, logistic_regression_path)

    # Load Mel Spectrogram CNN model if exists, else create a new one
    spectogram_cnn = MelSpectrogramCNN(n_mels=128, n_frames=40)  # Create an instance of the model
    if os.path.exists(mel_spectrogram_cnn_path):
        state_dict = torch.load(mel_spectrogram_cnn_path)
        spectogram_cnn.load_state_dict(state_dict)  # Load the state dictionary into the model
    else:
        torch.save(spectogram_cnn.state_dict(), mel_spectrogram_cnn_path)    

    return {
        "Logistic Regression": logistic_model, 
        "Spectrogram CNN": spectogram_cnn, 
    }

# `model_dictionary` is a global dictionary to store machine learning models
model_dictionary: Dict[str, Union[LogisticRegression, nn.Module]] = (
    load_machine_learning_models()
)

"""
=========================================================
PYDANTIC MODELS
=========================================================
"""

class PredictionRequest(BaseModel):
    raw_audio: List[float] 
    ml_model_type: str  # Model Types: "Logistic Regression", "Spectrogram CNN"

class PredictionResponse(BaseModel):
    audio_prediction: str  # Predictions: "Reece", "Chris"

class DataPoint(BaseModel):
    raw_audio: List[float]
    audio_label: str  # "Reece", "Chris"
    ml_model_type: str  # "Logistic Regression", "Spectrogram CNN"

class ResubAccuracyResponse(BaseModel):
    resub_accuracy: str

class ModelAccuraciesResponse(BaseModel):
    spectrogram_cnn_accuracy: str 
    logistic_regression_accuracy: str

"""
=========================================================
ROUTES
=========================================================
"""

@app.post("/predict_one/", response_model=PredictionResponse)
async def predict_one(request: PredictionRequest) -> PredictionResponse:
    """
    Accepts a feature vector and a ML model type, and uses the machine learning
    model associated with the dsid to make a prediction. If the model for the
    given ML is not already loaded, it attempts to load it and make a prediction. 
    If the model cannot be loaded or does not exist, an HTTPException is raised.

    Parameters
    ----------
    request : PredictionRequest
        A Pydantic model that includes a feature vector and a model type.

    Returns
    -------
    PredictionResponse
        A Pydantic model that includes the prediction result as a string.
        
    Raises
    ------
    HTTPException
        An error response with status code 500 if the model cannot be loaded,
        or with status code 404 if no data can be found for the given model.

    Example
    -------
    POST /predict_one/
    {
        "feature": [0.0102, 0.2031, 0.923231, 0.0000123, ...],
        "model_type": "Logistic Regression"
    }
    Response:
    {
        "prediction": "Reece"
    }
    """
    # Load in necessary variables and identify the model that will be used for the
    # prediction task
    feature_values = np.array(request.raw_audio)
    model_type: str = request.ml_model_type
    if model_dictionary.get(model_type) is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Could not load model for {model_type}"
        )
    
    if model_type == "Logistic Regression":
        # Specify logistic regression model
        model = model_dictionary[model_type]

        # Predict using the feature values and reverse encode the prediction
        predicted_label_encoded = model.predict(feature_values.reshape(1,-1))
        audio_prediction = label_encoder.inverse_transform(predicted_label_encoded)
    
        # Return the predicted audio
        return {
            "audio_prediction": audio_prediction[0] 
        }

    elif model_type == "Spectrogram CNN":
        # Convert raw audio data to Mel Spectrogram
        waveform = torch.tensor(request.raw_audio).float().view(1,-1)
        mel_spectrogram_transform = T.MelSpectrogram(
            sample_rate=44100,
            n_fft=2048,  # This can be adjusted based on the desired time resolution
            win_length=None,  # Window length, can be set to n_fft by default
            hop_length=512,  # This controls the overlap between frames; adjust as needed
            n_mels=128,  # Number of Mel filters
        )
        mel_spectrogram = mel_spectrogram_transform(waveform)

        # Add a channel dimension and pass to the CNN
        mel_spectrogram = mel_spectrogram.view(1, 1, mel_spectrogram.size(1), mel_spectrogram.size(2))
        model = model_dictionary[model_type]

        # Predict using the Mel Spectrogram and reverse encode the prediction
        prediction = model(mel_spectrogram)
        predicted_label_index = prediction.argmax(dim=1)
        audio_prediction = known_labels[predicted_label_index.item()]

        # Return the predicted audio
        return {
            "audio_prediction": audio_prediction 
        }
    

@app.post("/upload_labeled_datapoint_and_update_model/")
async def upload_labeled_datapoint_and_update_model(data: DataPoint) -> Dict[str, Any]:
    """
    Receives a labeled data point and stores it in the database.
    The data point includes a feature vector, a label, and the model we'd like our
    data to be used in training. Then, the associated machine learning model for 
    the specified dataset ID is retrained. If successful, saves the model and returns 
    the resubstitution accuracy.

    Parameters
    ----------
    data: DataPoint
        The labeled data point to be stored, including its features, label, and model of interest

    Returns
    -------
    dict
        A dictionary containing the ID of the inserted data point and a summary of the features.
    """
    # Insert data into MongoDB
    insert_result = await db.labeledinstances.insert_one({
        "raw_audio": data.raw_audio,
        "audio_label": data.audio_label,
        "model_type": data.ml_model_type,
    })

    # Retrieve all data points for this model_type from MongoDB
    cursor = db.labeledinstances.find({"model_type": data.ml_model_type})
    data_points = await cursor.to_list(length=None)

    if data.ml_model_type == "Logistic Regression": 
        # Convert data to features and labels suitable for Logistic Regression
        features, labels = convert_to_numpy_dataset(data_points)

        # Train the model
        model, accuracy = retrain_logistic_regression_model(features, labels)

        # Update the model in the dictionary
        model_dictionary[data.ml_model_type] = model

        # Save updated model to file path
        logistic_regression_path = "../ml_models/logistic_regression_model.pkl" 
        joblib.dump(model, logistic_regression_path)

        print(accuracy)

        # Return the accuracy of the retrained model
        return {"resub_accuracy": str(np.round(accuracy, 1))}

    elif data.ml_model_type == "Spectrogram CNN":
        # Convert data to PyTorch dataset
        features, labels = convert_to_pytorch_dataset(data_points)

        # Train the model
        model, accuracy = await retrain_pytorch_model(features, labels)

        # Update the model in the dictionary
        model_dictionary[data.ml_model_type] = model

        # CODE BELOW DISABLED.
        # Save updated model to file path
        # spectrogram_regression_path = "../ml_models/mel_spectrogram_cnn.pth" 
        # joblib.dump(model, spectrogram_regression_path)

        # Return the accuracy of the trained model
        return {"resub_accuracy": str(np.round(accuracy, 1))}

    else:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=f"No model found for {data.ml_model_type}"
        )


@app.get("/model_accuracies/", response_model=ModelAccuraciesResponse)
async def get_model_accuracies():
    """
    Returns the accuracies for both the Spectrogram CNN and Logistic Regression models.
    """
    # Retrieve actual accuracies
    spectrogram_cnn_accuracy: str = await calculate_spectrogram_cnn_accuracy()
    logistic_regression_accuracy: str = await calculate_logistic_regression_accuracy()

    return {
        "spectrogram_cnn_accuracy": spectrogram_cnn_accuracy,
        "logistic_regression_accuracy": logistic_regression_accuracy
    }


@app.get("/print_database/")
async def print_database():
    """
    Retrieves and prints all documents in the MongoDB collection to the console.
    """
    cursor = db.labeledinstances.find({})
    data_points = await cursor.to_list(length=None)
    for dp in data_points:
        print(dp)
    return {"detail": "Printed all data to console."}


@app.delete("/clear_database/")
async def clear_database():
    """
    Deletes all data from the MongoDB collection used by this application.
    """
    # Assuming the collection is named 'labeledinstances'
    delete_result = await db.labeledinstances.delete_many({})

    if delete_result.acknowledged:
        return {"detail": f"Deleted {delete_result.deleted_count} items."}
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to clear database."
        )


@app.get("/print_data_count/")
async def print_data_count():
    """
    Retrieves and prints the count of documents grouped by 'model_type' and 'audio_label'.
    """
    pipeline = [
        {
            "$group": {
                "_id": {
                    "model_type": "$model_type",
                    "audio_label": "$audio_label"
                },
                "count": {"$sum": 1}
            }
        },
        {
            "$sort": {"_id": 1}  # Sorting by the group identifier
        }
    ]
    cursor = db.labeledinstances.aggregate(pipeline)
    data_counts = await cursor.to_list(length=None)
    for count in data_counts:
        print(f"Model Type: {count['_id']['model_type']}, Audio Label: {count['_id']['audio_label']}, Count: {count['count']}")
    return {"detail": "Printed data counts to console."}


"""
=========================================================
HELPER FUNCTIONS
=========================================================
"""

def convert_to_numpy_dataset(data_points: List[Dict]) -> Tuple[np.ndarray, np.ndarray]:
    """
    Convert the list of data points to NumPy arrays for features and labels.
    """
    # Extract FFT features for Logistic Regression
    features_list = [np.fft.fft(np.array(dp["raw_audio"])).real for dp in data_points]
    labels_list = [dp["audio_label"] for dp in data_points]

    # Encode labels using label encoder
    labels_encoded = label_encoder.transform(labels_list)

    features = np.array(features_list)
    labels = labels_encoded

    return features, labels


def retrain_logistic_regression_model(
    features: np.ndarray,
    labels: np.ndarray,
) -> Tuple[LogisticRegression, float]:
    """
    Retrain the Logistic Regression model using the provided features and labels.
    """
    model: LogisticRegression = model_dictionary["Logistic Regression"]
    model.fit(features, labels)

    # Evaluate training accuracy
    accuracy = 100 * model.score(features, labels)

    return model, accuracy


def convert_to_pytorch_dataset(
    data_points: List[Dict],
) -> Tuple[torch.Tensor, torch.Tensor]:
    """
    Convert the list of data points to PyTorch Tensors for features and labels.
    """
    # Extract Mel Spectrogram features for CNN
    features_list = []
    mel_spectrogram_transform = T.MelSpectrogram(
        sample_rate=44100,
        n_fft=2048,  # This can be adjusted based on the desired time resolution
        win_length=None,  # Window length, can be set to n_fft by default
        hop_length=512,  # This controls the overlap between frames; adjust as needed
        n_mels=128,  # Number of Mel filters
    ) 
    
    for dp in data_points:
        waveform = torch.tensor(dp["raw_audio"]).float().view(1, -1)
        mel_spectrogram = mel_spectrogram_transform(waveform)
        mel_spectrogram = mel_spectrogram.view(1, mel_spectrogram.size(1), mel_spectrogram.size(2))
        features_list.append(mel_spectrogram)
    
    labels_list = [dp["audio_label"] for dp in data_points]

    # One-hot encode labels
    labels_encoded = one_hot_encoder.transform(np.array(labels_list).reshape(-1, 1))
    labels_encoded_tensor = torch.tensor(labels_encoded)  # Convert NumPy array to PyTorch tensor

    # Convert one-hot encoded labels to class indices for the CrossEntropyLoss
    labels_indices = torch.argmax(labels_encoded_tensor, dim=1)

    features = torch.stack(features_list)
    labels = labels_indices

    return features, labels


async def retrain_pytorch_model(
    features: torch.Tensor, 
    labels: torch.Tensor,
) -> Tuple[nn.Module, float]:
    """
    Retrain the specified model using the provided features and labels.
    """
    model: nn.Module = model_dictionary["Spectrogram CNN"]

    # Define a simple dataset and dataloader
    dataset = TensorDataset(features, labels)
    dataloader = DataLoader(dataset, batch_size=32, shuffle=True)

    # Define loss function and optimizer
    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)

    # Training loop
    for epoch in range(5):  # Train for 5 epochs
        for batch_features, batch_labels in dataloader:
            # Forward pass
            outputs = model(batch_features)
            loss = criterion(outputs, batch_labels)

            # Backward and optimize
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

    # Evaluate accuracy
    with torch.no_grad():
        correct: int = 0
        total: int = 0
        for features, labels in dataloader:
            # Make predictions with batch of features
            outputs = model(features)
            _, predicted = torch.max(outputs.data, 1)

            # Increment total correct and total logged in batch accordingly
            total += labels.size(0)
            correct += (predicted == labels).sum().item()

    # Calculate accuracy and return both model and accuracy
    accuracy = (correct / total) * 100
    return model, accuracy


async def calculate_logistic_regression_accuracy() -> str:
    """
    Helper function to calculate accuracy for Logistic Regression.
    """
    cursor = db.labeledinstances.find({"model_type": "Logistic Regression"})
    data_points = await cursor.to_list(length=None)
    if len(data_points) == 0:
        return "--.-"
    features, labels = convert_to_numpy_dataset(data_points)
    model = model_dictionary["Logistic Regression"]
    accuracy = model.score(features, labels) * 100  # Accuracy as a percentage
    return str(np.round(accuracy, 1))


async def calculate_spectrogram_cnn_accuracy() -> str:
    """
    Helper function to calculate accuracy for Mel Spectrogram CNN
    """
    cursor = db.labeledinstances.find({"model_type": "Spectrogram CNN"})
    data_points = await cursor.to_list(length=None)
    if len(data_points) == 0:
        return "--.-"
    features, labels = convert_to_pytorch_dataset(data_points)
    model = model_dictionary["Spectrogram CNN"]
    
    # Assuming you have a function that can evaluate the model and return accuracy
    accuracy = await evaluate_cnn_model(model, features, labels)
    return str(np.round(accuracy))


async def evaluate_cnn_model(model, features, labels) -> float:
    """
    Function to evaluate CNN model and return accuracy.
    """
    # Define dataloader for evaluation
    dataloader = DataLoader(TensorDataset(features, labels), batch_size=32, shuffle=False)
    
    # Evaluate the model
    correct = 0
    total = 0
    with torch.no_grad():
        for features, labels in dataloader:
            outputs = model(features)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
    
    accuracy = (correct / total) * 100
    return accuracy


"""
=========================================================
MAIN METHOD
=========================================================
"""

if __name__ == "__main__":
    # Start uvicorn server
    uvicorn.run(app, host="0.0.0.0", port=8000)
