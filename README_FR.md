# 🚗 GARAGE — Système de Diagnostic Automobile par Intelligence Artificielle

> **Une plateforme multimodale de pointe** combinant analyse audio, vision par ordinateur et prédiction de prix pour un diagnostic véhicule complet et intelligent.

---

## 📋 Table des Matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Technologies](#-technologies)
- [Installation](#-installation)
- [Endpoints API](#-endpoints-api)
- [Fonctionnalités](#-fonctionnalités)
- [Modèles de Deep Learning](#-modèles-de-deep-learning)
- [Exemples d'utilisation](#-exemples-dutilisation)

---

## 🎯 Vue d'ensemble

**GARAGE** est une plateforme de diagnostic automobile full-stack qui analyse l'état d'un véhicule selon **trois modalités principales** :

| Modalité | Description |
|----------|-------------|
| 🎙️ **Diagnostic Audio** | Classification des sons moteur pour la détection de pannes |
| 👁️ **Diagnostic Visuel** | Détection en temps réel des dommages et composants |
| 💰 **Prédiction de Prix** | Estimation des coûts de réparation par Machine Learning |

> Construit avec un backend **FastAPI**, un frontend mobile **Flutter**, et propulsé par des modèles de deep learning à l'état de l'art.

---

## 🏗️ Architecture

### Backend

```
Application FastAPI
├── Routes (Routeurs)
│   ├── /garage/user        → Authentification, Profil, Historique
│   ├── /garage/audio       → Classification audio moteur
│   ├── /garage/taule       → Détection visuelle des dommages
│   └── /garage/rag         → Assistant IA (Chat)
├── Modèles de Deep Learning
│   ├── AST (Audio Spectrogram Transformer)
│   ├── YOLO v8 (Détection d'objets)
│   └── CatBoost (Régression)
├── Agent IA (LangGraph)
│   └── LLM Qwen2.5-7B
├── Base de Données
│   ├── SQLite ou PostgreSQL
│   └── SQLAlchemy ORM
└── File de Tâches
    └── Celery + Redis (traitement asynchrone)
```

### Frontend

```
lib/
├── providers/
│   └── TokenProvider.dart
├── screens/
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
├── services/
│   ├── audio_services.dart
│   ├── taule_analysis_services.dart
│   ├── taule_services.dart
│   └── user_services.dart
├── theme/
│   └── app_theme.dart
├── widgets/
│   └── custom_widgets.dart
├── main.dart
└── routes.dart
```

---

## 🛠️ Technologies

### Backend

| Composant | Technologie |
|-----------|-------------|
| Framework | FastAPI (Python) |
| Modèle Audio | Audio Spectrogram Transformer — HuggingFace |
| Modèle Vision | YOLO v8 — Ultralytics |
| Modèle Prix | CatBoost — Gradient Boosting |
| LLM | Qwen2.5-7B via HuggingFace |
| Orchestration | LangGraph (Machine à États) |
| Base de Données | SQLite / PostgreSQL avec SQLAlchemy |
| File de Tâches | Celery + Redis |
| Accélération | Inférence optimisée CUDA (GPU) |

### Frontend

| Composant | Technologie |
|-----------|-------------|
| Framework | Flutter |
| Audio | `record`, `audioplayers` |
| Caméra | `camera`, `image_picker` |
| Gestion d'état | Provider |
| Stockage local | SharedPreferences |
| Notifications | flutter_local_notifications |

---

## 🔌 Endpoints API

### 🎙️ Diagnostic Audio

```http
POST /garage/audio/predict
Content-Type: multipart/form-data
```

```json
// Corps de la requête
{ "audio_file": "<fichier .wav ou .mp3>" }

// Réponse
{ "label": "bad_ignition", "confidence": 0.95 }
```

---

### 👁️ Diagnostic Visuel

```http
POST /garage/taule/predict
Content-Type: multipart/form-data
```

```json
// Corps de la requête
{ "image_file": "<fichier .jpg ou .png>" }

// Réponse
{ "detections": ["rouille", "bosse"], "confidence_scores": [0.92, 0.87] }
```

---

### 💰 Prédiction de Prix

```http
POST /garage/price/predict
Content-Type: application/json
```

```json
// Corps de la requête
{
  "year": 2020,
  "kilometres": 45000,
  "make": "Toyota",
  "model": "Camry",
  "trim": "SE",
  "fuel": "essence",
  "transmission": "automatique",
  "body_type": "berline",
  "doors": 4,
  "seats": 5,
  "engine_size": 2.5,
  "engine_power": 203,
  "drive_train": "FWD",
  "color": "argent"
}

// Réponse
{ "estimated_price": 15500, "confidence": 0.89 }
```

---

### 🤖 Assistant IA

```http
POST /garage/rag/chat
Content-Type: application/json
```

```json
// Corps de la requête
{ "message": "Que signifie ce diagnostic audio ?", "session_id": "user_123" }

// Réponse
{ "response": "L'analyse audio a détecté..." }
```

---

### 👤 Gestion des Utilisateurs

```http
POST /garage/user/register   → Inscription
POST /garage/user/login      → Connexion
GET  /garage/user/profile    → Profil utilisateur
GET  /garage/user/history    → Historique des diagnostics
```

---

## ✨ Fonctionnalités

### 🎙️ Classification Audio

Détection de **7 classes de pannes moteur** :

| Panne | Description |
|-------|-------------|
| `bad_ignition` | Allumage défectueux |
| `cv_joint` | Problème de cardan |
| `fuel_pump` | Défaillance de la pompe à carburant |
| `shock_absorber` | Amortisseurs endommagés |
| `serpentine_belt` | Usure de la courroie serpentine |
| `tie_rod` | Problème de tirant de direction |
| `worn_brakes` | Freins usés |

**Spécifications du modèle :**
- Entrée : Audio 16kHz, 128 mel-spectrogrammes
- Architecture : 12 couches, 12 têtes d'attention, 768 dimensions cachées
- Framework : HuggingFace Transformers

---

### 👁️ Détection Visuelle

- Détection d'objets en temps réel avec **YOLO v8**
- Suivi multi-objets
- Filtrage par seuil de confiance (défaut : 0.5)
- Inférence optimisée GPU
- Sortie d'image annotée

---

### 💰 Prédiction de Prix

Analyse de **14 attributs véhicule** :

- Année de fabrication et kilométrage
- Marque, modèle et niveau de finition
- Type de carburant et transmission
- Carrosserie, portes, places assises
- Caractéristiques moteur, transmission, couleur

Propulsé par un **régresseur CatBoost** pour une estimation précise des coûts.

---

### 🤖 Assistant IA Conversationnel

- Orchestration **LangGraph**
- Intégration **LLM Qwen2.5-7B**
- Outils disponibles : prédiction audio, vision, prix, récupération de données, recherche web
- Réponses contextualisées et naturelles

---

## 🧠 Modèles de Deep Learning

### Audio Spectrogram Transformer (AST)

- **Modèle** : `MIT/ast-finetuned-audioset-10-10-0.4593`
- **Entrée** : Mel-spectrogramme (128 bins, 1024 frames max)
- **Fréquence d'échantillonnage** : 16kHz
- **Sortie** : Classification en 7 classes

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

---

### YOLO v8

- **Framework** : Ultralytics
- **Entrée** : Image ou frame vidéo
- **Sortie** : Boîtes englobantes, étiquettes de classe, scores de confiance

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

---

### CatBoost Regressor

- **Algorithme** : Régression par Gradient Boosting
- **Caractéristiques d'entrée** : 14 attributs véhicule
- **Sortie** : Estimation du coût de réparation

```python
from catboost import CatBoostRegressor
import pandas as pd

model = CatBoostRegressor()
model.load_model("deep_learning/prediction_model.cbm")
predictions = model.predict(vehicle_data)
```

---

## 🚀 Exemples d'Utilisation

### 🎙️ Flux de Diagnostic Audio

```
1. L'utilisateur enregistre le son du moteur via l'application Flutter
2. L'audio est envoyé à /garage/audio/predict
3. Le modèle AST classifie le son
4. L'agent LangGraph interprète les résultats
5. L'assistant IA explique les conclusions en langage naturel
```

### 👁️ Flux de Diagnostic Visuel

```
1. L'utilisateur capture une photo du véhicule
2. L'image est envoyée à /garage/taule/predict
3. YOLO v8 détecte les dommages et anomalies
4. Les résultats sont annotés et retournés
5. La sévérité des dommages est évaluée
```

### 💰 Flux de Prédiction de Prix

```
1. L'utilisateur saisit les caractéristiques du véhicule
2. Les données sont envoyées à /garage/price/predict
3. Le modèle CatBoost estime le coût de réparation
4. L'intervalle de confiance est retourné
5. Des comparaisons historiques sont fournies
```

---

## 📱 Fonctionnalités du Frontend

- 🎙️ **Enregistrement audio en temps réel** avec le package `record`
- 📸 **Intégration caméra** pour des photos instantanées des dommages
- 📦 **Mode hors-ligne** avec mise en cache locale
- 🔔 **Notifications push** pour les résultats de diagnostic
- 📊 **Historique des diagnostics** avec stockage SQLite
- 🌙 **Mode sombre** supporté

---

## 📄 Licence

**MIT License** — Voir le fichier `LICENSE` pour plus de détails.

---

<div align="center">

**Construit avec ❤️ grâce à FastAPI, Flutter et des modèles ML de pointe**

</div>
