import os
import cv2
import torch
import subprocess
from celery import Celery
import librosa
from bd_initialization.DataBase_models import SessionLocal, AnalyseTaule

from deep_learning.functions import (
    load_prediction_model, load_audio_model, 
    load_vision_model, load_feature_extractor,
    predict_audio, predict_vision
)

# --- Configuration ---
device = "cuda" if torch.cuda.is_available() else "cpu"
celery_app = Celery("worker", broker="redis://localhost:6379/0", backend="redis://localhost:6379/0")

# --- Model Initialization ---
price_model = load_prediction_model()
audio_model = load_audio_model()
vision_model = load_vision_model()
audio_extractor = load_feature_extractor()

# --- Helpers ---

def collect_detections(results, conf_threshold=0.6):
    """Filters results and returns a list of detected labels."""
    detections = []
    for box in results.boxes:
        conf = float(box.conf[0])
        if conf >= conf_threshold:
            detections.append({
                "label": vision_model.names[int(box.cls[0])],
                "confidence": round(conf, 3)
            })
    return detections

# --- Tasks ---

@celery_app.task
def audio_prediction(audio_path):
    try:
        model = audio_model.to(device)
        audio, sr = librosa.load(audio_path, sr=16000)
        inputs = audio_extractor(audio, sampling_rate=sr, return_tensors="pt").to(device)
        return {"predicted_classe": predict_audio(model, inputs)}
    except Exception as e:
        return {"erreur": f"Audio analysis error: {e}"}

@celery_app.task
def taule_prediction(image_path, result_image_path):
    try:
        model = vision_model.to(device)
        return {"detected_classes": predict_vision(model, image_path, result_image_path)}
    except Exception as e:
        return {"error": f"Taule analysis error: {e}"}

@celery_app.task
def run_full_video_inspection(original_video_path, analysed_video_path, user_id):
    database = SessionLocal()
    all_detections = []
    
    cap = cv2.VideoCapture(original_video_path)
    fps = cap.get(cv2.CAP_PROP_FPS) or 30
    
    # Prepare paths
    avi_path = analysed_video_path.rsplit('.', 1)[0] + '.avi'
    output_mp4 = analysed_video_path if analysed_video_path.endswith('.mp4') else analysed_video_path.rsplit('.', 1)[0] + '.mp4'
    
    writer = cv2.VideoWriter(avi_path, cv2.VideoWriter_fourcc(*'MPEG'), float(fps), (1280, 720))
    
    try:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret: break
            
            frame = cv2.resize(frame, (1280, 720))
            results = vision_model(frame, conf=0.6)
            
            if results and len(results[0].boxes) > 0:
                annotated = results[0].plot()
                all_detections.extend(collect_detections(results[0]))
            else:
                annotated = frame
            
            writer.write(cv2.cvtColor(annotated, cv2.COLOR_RGB2BGR) if len(annotated.shape) == 3 else annotated)
        
        writer.release()
        cap.release()
        
        # Convert to MP4 via FFmpeg
        subprocess.run(['ffmpeg', '-y', '-i', avi_path, '-vcodec', 'libx264', '-preset', 'fast', output_mp4], check=True)
        os.remove(avi_path)
        
        # Save to Database
        analyse = AnalyseTaule(
            original_path=original_video_path, analysed_path=output_mp4,
            id_user=user_id, detections=list({d["label"]: d for d in all_detections}.values()),
            type="video"
        )
        database.add(analyse)
        database.commit()
        return {"status": "done"}
        
    except Exception as e:
        database.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        database.close()