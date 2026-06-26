# 🚗 GARAGE - AI-Powered Vehicle Diagnostic System

A multimodal AI backend application for comprehensive vehicle diagnostics combining audio classification, computer vision, and price prediction.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technologies](#technologies)
- [Installation](#installation)
- [API Endpoints](#api-endpoints)
- [Features](#features)
- [Deep Learning Models](#deep-learning-models)
- [Usage Examples](#usage-examples)

## 🎯 Overview

GARAGE is a full-stack diagnostic platform that analyzes vehicle conditions through three main modalities:

- **Audio Diagnostics**: Engine sound classification for fault detection
- **Visual Diagnostics**: Real-time vehicle damage and component detection
- **Price Prediction**: ML-based repair cost estimation

Built with FastAPI backend, Flutter mobile frontend, and powered by state-of-the-art deep learning models.

## 🏗️ Architecture

### Backend Structure

```
FastAPI Application
├── Routes (Routers)
│   ├── /garage/user        → Authentication, Profile, History
│   ├── /garage/audio       → Engine audio classification
│   ├── /garage/taule       → Visual damage detection
│   └── /garage/rag         → AI Assistant Chat
├── Deep Learning Models
│   ├── AST (Audio Spectrogram Transformer)
│   ├── YOLO v8 (Object Detection)
│   └── CatBoost (Regression)
├── AI Agent (LangGraph)
│   └── Qwen2.5-7B LLM
├── Database
│   ├── SQLite or PostgreSQL
│   └── SQLAlchemy ORM
└── Task Queue
    └── Celery + Redis (async processing)
```

### Frontend Structure

lib
├── providers
│   └── TokenProvider.dart
├── screens
│   ├── AddAudioAnalysisScreen.dart
│   ├── AddTauleAnalysisScreen.dart
│   ├── AllAnalyses_Screen.dart
│   ├── AllIssuesScreen.dart
│   ├── AllPannes_Screen.dart
│   ├── AnalysisDetailsScreen.dart
│   ├── ChatScreen.dart
│   ├── DashboardScreen.dart
│   ├── IssueDetailsScreen.dart
│   ├── LoginScreen.dart
│   ├── PricePredictionScreen.dart
│   ├── RegisterScreen.dart
│   └── SplashScreen.dart
├── services
│   ├── audio_services.dart
│   ├── taule_analysis_services.dart
│   ├── taule_services.dart
│   └── user_services.dart
├── theme
│   └── app_theme.dart
├── widgets
│   └── custom_widgets.dart
├── main.dart
└── routes.dart


## 🛠️ Technologies

### Backend
- **Framework**: FastAPI (Python)
- **Audio Model**: Audio Spectrogram Transformer (AST) - HuggingFace
- **Vision Model**: YOLO v8 - Ultralytics
- **Price Model**: CatBoost - Gradient Boosting
- **LLM**: Qwen2.5-7B via HuggingFace
- **Orchestration**: LangGraph (State Machine)
- **Database**: SQLite/PostgreSQL with SQLAlchemy
- **Task Queue**: Celery + Redis
- **GPU Support**: CUDA-optimized inference

### Frontend
- **Framework**: Flutter
- **Audio**: `record`, `audioplayers`
- **Camera**: `camera`, `image_picker`
- **State Management**: Provider
- **Storage**: SharedPreferences
- **Notifications**: flutter_local_notifications

## 🔌 API Endpoints

### Audio Diagnostics
```
POST /garage/audio/predict
Content-Type: multipart/form-data
Body: audio_file (wav, mp3)
Response: { "label": "bad_ignition", "confidence": 0.95 }
```

### Vision Diagnostics
```
POST /garage/taule/predict
Content-Type: multipart/form-data
Body: image_file (jpg, png)
Response: { "detections": ["rust", "dent"], "confidence_scores": [0.92, 0.87] }
```

### Price Prediction
```
POST /garage/price/predict
Content-Type: application/json
Body: {
  "year": 2020,
  "kilometres": 45000,
  "make": "Toyota",
  "model": "Camry",
  "trim": "SE",
  "fuel": "gasoline",
  "transmission": "automatic",
  "body_type": "sedan",
  "doors": 4,
  "seats": 5,
  "engine_size": 2.5,
  "engine_power": 203,
  "drive_train": "FWD",
  "color": "silver"
}
Response: { "estimated_price": 15500, "confidence": 0.89 }
```

### AI Assistant
```
POST /garage/rag/chat
Content-Type: application/json
Body: { "message": "What does the audio diagnosis mean?", "session_id": "user_123" }
Response: { "response": "The audio analysis detected..." }
```

### User Management
```
POST /garage/user/register
POST /garage/user/login
GET /garage/user/profile
GET /garage/user/history
```

## ✨ Features

### Audio Classification
- **7 Engine Fault Classes**:
  - Bad ignition (allumage défectueux)
  - CV joint issues (problème de cardan)
  - Fuel pump problems (pompe à carburant)
  - Shock absorber issues (amortisseurs)
  - Serpentine belt wear (courroie serpentine)
  - Tie-rod issues (tirant de direction)
  - Worn brakes (freins usés)

- **Model Specs**:
  - Input: 16kHz audio, 128 mel-spectrograms
  - Architecture: 12 layers, 12 attention heads, 768 hidden dims
  - Framework: HuggingFace Transformers

### Vision Detection
- Real-time object detection via YOLO v8
- Multi-object tracking
- Confidence threshold filtering (default: 0.5)
- GPU-optimized inference
- Annotated image output

### Price Prediction
- **14 Vehicle Attributes** analyzed:
  - Production year, mileage
  - Make, model, trim level
  - Fuel type, transmission
  - Body type, doors, seats
  - Engine specs, drivetrain, color

- **CatBoost Regressor** for accurate cost estimation

### AI Assistant
- LangGraph orchestration
- Qwen2.5-7B LLM integration
- Tools: audio prediction, vision prediction, price prediction, data retrieval, web search
- Context-aware responses

## 🧠 Deep Learning Models

### Audio Spectrogram Transformer (AST)
- **Model**: MIT/ast-finetuned-audioset-10-10-0.4593
- **Input**: Mel-spectrogram (128 bins, 1024 frames max)
- **Sampling Rate**: 16kHz
- **Output**: 7-class classification

```python
from transformers import AutoModelForAudioClassification, AutoFeatureExtractor
import torch

audio_model = AutoModelForAudioClassification.from_pretrained(
    "MIT/ast-finetuned-audioset-10-10-0.4593"
)
feature_extractor = AutoFeatureExtractor.from_pretrained(
    "MIT/ast-finetuned-audioset-10-10-0.4593"
)

def predict_audio(audio_model, inputs):
    outputs_logits = audio_model(**inputs).logits
    predicted_class = torch.argmax(outputs_logits, dim=-1).item()
    label = audio_model.config.id2label[predicted_class]
    return label
```

### YOLO v8
- **Framework**: Ultralytics
- **Input**: Image or video frame
- **Output**: Bounding boxes, class labels, confidence scores

```python
from ultralytics import YOLO
import cv2

model = YOLO("car_model.pt")

def predict_vision(model, image, result_image_path, confidence_threshold=0.5):
    results = model(image)[0]
    mask = results.boxes.conf >= confidence_threshold
    filtered_results = results[mask]
    class_names = model.names
    detected_classes = [class_names[int(c)] for c in filtered_results.boxes.cls]
    filtered_results.save(filename=result_image_path)
    return detected_classes
```

### CatBoost Regressor
- **Algorithm**: Gradient Boosting Regression
- **Input Features**: 14 vehicle attributes
- **Output**: Repair cost estimation

```python
from catboost import CatBoostRegressor
import pandas as pd

model = CatBoostRegressor()
model.load_model("deep_learning/prediction_model.cbm")
predictions = model.predict(vehicle_data)
```

## 🚀 Usage Examples

### Audio Diagnosis Flow
1. User records engine sound via Flutter app
2. Audio sent to `/garage/audio/predict`
3. AST model classifies the audio
4. LangGraph agent interprets results
5. AI Assistant explains findings in natural language

### Visual Diagnosis Flow
1. User captures vehicle image
2. Image sent to `/garage/taule/predict`
3. YOLO v8 detects damage/issues
4. Results annotated and returned
5. Damage severity assessed

### Price Prediction Flow
1. User inputs vehicle specifications
2. Data sent to `/garage/price/predict`
3. CatBoost model estimates repair cost
4. Confidence interval returned
5. Historical comparisons provided

## 📱 Frontend Features

- **Real-time audio recording** with `record` package
- **Camera integration** for instant damage photos
- **Offline-first** with local caching
- **Push notifications** for diagnostic results
- **Diagnostic history** with SQLite storage
- **Dark mode support**


## 📄 License

MIT License - See LICENSE file for details
à
---

**Built with ❤️ using FastAPI, Flutter, and cutting-edge ML models**
