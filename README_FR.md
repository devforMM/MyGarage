# 🚗 GARAGE - Système de Diagnostic Automobile Alimenté par l'IA

Une application backend multimodale basée sur l'IA pour un diagnostic complet des véhicules, combinant la classification audio, la vision par ordinateur et la prédiction de prix.

## 📋 Table des Matières

- [Aperçu](#aperçu)
- [Architecture](#architecture)
- [Technologies](#technologies)
- [Installation](#installation)
- [Points de Terminaison API](#points-de-terminaison-api)
- [Fonctionnalités](#fonctionnalités)
- [Modèles d'Apprentissage Profond](#modèles-dapprentissage-profond)
- [Exemples d'Utilisation](#exemples-dutilisation)

## 🎯 Aperçu

GARAGE est une plateforme de diagnostic complète qui analyse l'état des véhicules via trois modalités principales :

- **Diagnostics Audio** : Classification des bruits du moteur pour détecter les défauts
- **Diagnostics Visuels** : Détection en temps réel des dommages et composants du véhicule
- **Prédiction de Prix** : Estimation du coût de réparation basée sur le ML

Construit avec un backend FastAPI, une interface mobile Flutter et alimenté par des modèles d'apprentissage profond à la pointe de la technologie.

## 🏗️ Architecture

### Structure Backend

```
Application FastAPI
├── Routes (Routeurs)
│   ├── /garage/user        → Authentification, Profil, Historique
│   ├── /garage/audio       → Classification audio du moteur
│   ├── /garage/taule       → Détection visuelle des dommages
│   └── /garage/rag         → Chat Assistant IA
├── Modèles d'Apprentissage Profond
│   ├── AST (Audio Spectrogram Transformer)
│   ├── YOLO v8 (Détection d'objets)
│   └── CatBoost (Régression)
├── Agent IA (LangGraph)
│   └── LLM Qwen2.5-7B
├── Base de Données
│   ├── SQLite ou PostgreSQL
│   └── ORM SQLAlchemy
└── File d'Attente des Tâches
    └── Celery + Redis (traitement asynchrone)
```

### Structure Frontend

```
Application Flutter
├── AuthScreen
├── AudioDiagnosticScreen
├── VisualDiagnosticScreen
├── PricePredictionScreen
├── ResultScreen
└── HistoryScreen
```

## 🛠️ Technologies

### Backend
- **Framework** : FastAPI (Python)
- **Modèle Audio** : Audio Spectrogram Transformer (AST) - HuggingFace
- **Modèle Vision** : YOLO v8 - Ultralytics
- **Modèle Prix** : CatBoost - Gradient Boosting
- **LLM** : Qwen2.5-7B via HuggingFace
- **Orchestration** : LangGraph (Machine à États)
- **Base de Données** : SQLite/PostgreSQL avec SQLAlchemy
- **File d'Attente** : Celery + Redis
- **Support GPU** : Inférence optimisée CUDA

### Frontend
- **Framework** : Flutter
- **Audio** : `record`, `audioplayers`
- **Caméra** : `camera`, `image_picker`
- **Gestion d'État** : Provider
- **Stockage** : SharedPreferences
- **Notifications** : flutter_local_notifications

## 📦 Installation

### Configuration Backend

1. **Cloner le référentiel**
```bash
git clone <repo-url>
cd garage-backend
```

2. **Créer l'environnement virtuel**
```bash
python -m venv venv
source venv/bin/activate  # Sur Windows : venv\Scripts\activate
```

3. **Installer les dépendances**
```bash
pip install fastapi uvicorn
pip install torch torchvision torchaudio
pip install transformers
pip install ultralytics
pip install catboost
pip install langgraph langchain
pip install celery redis
pip install sqlalchemy
pip install pydantic
```

4. **Télécharger les modèles**
```bash
# Les modèles se téléchargent automatiquement lors de la première utilisation
# Audio : MIT/ast-finetuned-audioset-10-10-0.4593
# Vision : yolov8n.pt (ou car_model.pt)
# Prix : deep_learning/prediction_model.cbm
```

5. **Configurer l'environnement**
```bash
cp .env.example .env
# Éditer .env avec vos paramètres
```

6. **Démarrer les services**
```bash
# Redis (requis pour Celery)
redis-server

# Worker Celery
celery -A server.celery_script worker --loglevel=info

# Planificateur Celery (optionnel)
celery -A server.celery_script beat

# Serveur FastAPI
uvicorn main:app --reload --port 8000
```

### Configuration Frontend

1. **Installer le SDK Flutter** (si pas déjà installé)
```bash
flutter pub global activate fvm
fvm install
```

2. **Obtenir les dépendances**
```bash
cd garage-flutter
flutter pub get
```

3. **Exécuter sur un appareil/émulateur**
```bash
flutter run
```

## 🔌 Points de Terminaison API

### Diagnostics Audio
```
POST /garage/audio/predict
Content-Type: multipart/form-data
Body: audio_file (wav, mp3)
Réponse: { "label": "bad_ignition", "confidence": 0.95 }
```

### Diagnostics Visuels
```
POST /garage/taule/predict
Content-Type: multipart/form-data
Body: image_file (jpg, png)
Réponse: { "detections": ["rust", "dent"], "confidence_scores": [0.92, 0.87] }
```

### Prédiction de Prix
```
POST /garage/price/predict
Content-Type: application/json
Body: {
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
  "drive_train": "TI",
  "color": "argent"
}
Réponse: { "estimated_price": 15500, "confidence": 0.89 }
```

### Assistant IA
```
POST /garage/rag/chat
Content-Type: application/json
Body: { "message": "Que signifie le diagnostic audio ?", "session_id": "user_123" }
Réponse: { "response": "L'analyse audio a détecté..." }
```

### Gestion des Utilisateurs
```
POST /garage/user/register
POST /garage/user/login
GET /garage/user/profile
GET /garage/user/history
```

## ✨ Fonctionnalités

### Classification Audio
- **7 Classes de Défauts Moteur** :
  - Problème d'allumage (bad ignition)
  - Problème de cardan (CV joint)
  - Pompe à carburant (fuel pump)
  - Système d'amortissement (shock absorber)
  - Courroie serpentine (serpentine belt)
  - Tirant de direction (tie-rod)
  - Freins usés (worn brakes)

- **Spécifications du Modèle** :
  - Entrée : Audio 16kHz, 128 mel-spectrogrammes
  - Architecture : 12 couches, 12 têtes d'attention, 768 dimensions cachées
  - Framework : HuggingFace Transformers

### Détection Visuelle
- Détection d'objets en temps réel via YOLO v8
- Suivi multi-objets
- Filtrage par seuil de confiance (par défaut : 0,5)
- Inférence optimisée GPU
- Sortie d'image annotée

### Prédiction de Prix
- **14 Attributs de Véhicule** analysés :
  - Année de production, kilométrage
  - Marque, modèle, niveau de finition
  - Type de carburant, transmission
  - Type de carrosserie, portes, places
  - Spécifications du moteur, transmission, couleur

- **Régresseur CatBoost** pour une estimation précise

### Assistant IA
- Orchestration LangGraph
- Intégration LLM Qwen2.5-7B
- Outils : prédiction audio, prédiction vision, prédiction prix, récupération de données, recherche web
- Réponses conscientes du contexte

## 🧠 Modèles d'Apprentissage Profond

### Audio Spectrogram Transformer (AST)
- **Modèle** : MIT/ast-finetuned-audioset-10-10-0.4593
- **Entrée** : Mel-spectrogram (128 bins, 1024 frames max)
- **Fréquence d'échantillonnage** : 16kHz
- **Sortie** : Classification 7 classes

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
- **Framework** : Ultralytics
- **Entrée** : Image ou frame vidéo
- **Sortie** : Boîtes de délimitation, étiquettes de classe, scores de confiance

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

### Régresseur CatBoost
- **Algorithme** : Régression Gradient Boosting
- **Caractéristiques d'entrée** : 14 attributs de véhicule
- **Sortie** : Estimation du coût de réparation

```python
from catboost import CatBoostRegressor
import pandas as pd

model = CatBoostRegressor()
model.load_model("deep_learning/prediction_model.cbm")
predictions = model.predict(vehicle_data)
```

## 🚀 Exemples d'Utilisation

### Flux de Diagnostic Audio
1. L'utilisateur enregistre le bruit du moteur via l'application Flutter
2. L'audio est envoyé à `/garage/audio/predict`
3. Le modèle AST classe l'audio
4. L'agent LangGraph interprète les résultats
5. L'Assistant IA explique les résultats en langage naturel

### Flux de Diagnostic Visuel
1. L'utilisateur capture une image du véhicule
2. L'image est envoyée à `/garage/taule/predict`
3. YOLO v8 détecte les dommages/problèmes
4. Les résultats sont annotés et retournés
5. La gravité des dommages est évaluée

### Flux de Prédiction de Prix
1. L'utilisateur entre les spécifications du véhicule
2. Les données sont envoyées à `/garage/price/predict`
3. Le modèle CatBoost estime le coût de réparation
4. L'intervalle de confiance est retourné
5. Les comparaisons historiques sont fournies

## 📱 Fonctionnalités Frontend

- **Enregistrement audio en temps réel** avec le package `record`
- **Intégration de caméra** pour des photos instantanées des dommages
- **Hors ligne d'abord** avec mise en cache locale
- **Notifications push** pour les résultats diagnostiques
- **Historique des diagnostics** avec stockage SQLite
- **Support du mode sombre**

## 🔧 Configuration

### Redis
```bash
redis-server --port 6379
```

### Celery
```bash
# Worker
celery -A server.celery_script worker --loglevel=info

# Planificateur Beat
celery -A server.celery_script beat --loglevel=info
```

### Base de Données
Mettez à jour `.env` :
```
DATABASE_URL=postgresql://user:password@localhost/garage
# ou
DATABASE_URL=sqlite:///./garage.db
```

## 📊 Performance

- **Inférence audio** : ~200ms (optimisée GPU)
- **Inférence vision** : ~150ms par image
- **Prédiction de prix** : ~50ms
- **Traitement asynchrone des tâches** : File d'attente Redis

## 🤝 Contribution

1. Forker le référentiel
2. Créer une branche de fonctionnalité
3. Effectuer vos modifications
4. Soumettre une demande de fusion

## 📄 Licence

Licence MIT - Voir le fichier LICENSE pour les détails

## 📞 Support

Pour les problèmes et les questions, veuillez ouvrir une issue GitHub ou contacter l'équipe de développement.

---

**Construit avec ❤️ en utilisant FastAPI, Flutter et des modèles ML de pointe**
