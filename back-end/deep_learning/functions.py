import torch
import pandas as pd
from transformers import AutoModelForAudioClassification, AutoFeatureExtractor
from ultralytics import YOLO
from catboost import CatBoostRegressor

# --- Audio Analysis ---
def load_audio_model(model_path="deep_learning/audio_model"):
    return AutoModelForAudioClassification.from_pretrained(model_path)

def load_feature_extractor():
    return AutoFeatureExtractor.from_pretrained("MIT/ast-finetuned-audioset-10-10-0.4593")

def predict_audio(audio_model, inputs):
    outputs_logits = audio_model(**inputs).logits
    predicted_class = torch.argmax(outputs_logits, dim=-1).item()
    return audio_model.config.id2label[predicted_class]

# --- Vision Analysis ---
def load_vision_model(model_path="deep_learning/car_model.pt"):
    return YOLO(model_path)

def predict_vision(model, image, result_image_path, confidence_threshold=0.5):
    results = model(image)[0]
    
    # Filter by confidence
    mask = results.boxes.conf >= confidence_threshold
    filtered_results = results[mask]
    
    # Extract class names
    detected_classes = [model.names[int(c)] for c in filtered_results.boxes.cls]
    
    # Save processed image
    filtered_results.save(filename=result_image_path)
    
    return detected_classes

# --- Price Prediction ---
def load_prediction_model(model_path="deep_learning/prediction_model.cbm"):
    model = CatBoostRegressor()
    return model.load_model(model_path)

def predict_price(model, input_data):
    df = pd.DataFrame([input_data.dict()])
    prediction = model.predict(df)
    return float(prediction[0])