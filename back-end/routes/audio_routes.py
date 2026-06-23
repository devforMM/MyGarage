import os
import asyncio
import subprocess
from fastapi import APIRouter, Depends, HTTPException, File, UploadFile
from sqlalchemy.orm import Session

from bd_initialization.Bridge import get_session
from bd_initialization.DataBase_models import AudioIssue
from server.server_utils import get_curent__user
from server.celery_script import audio_prediction

audio_router = APIRouter()

@audio_router.post("/issues")
async def create_audio_issue(
    user=Depends(get_curent__user), 
    audio_file: UploadFile = File(...), 
    database: Session = Depends(get_session)
):
    """Uploads an audio file, processes it via Celery, and saves the diagnostic record."""
    try:
        # Prepare file structure
        issue_index = len(user.audio_issues) + 1
        issue_folder = os.path.join("users_files", f"user_{user.id}", "audio_issues", f"issue-{issue_index}")
        os.makedirs(issue_folder, exist_ok=True)

        m4a_path = os.path.join(issue_folder, "audio.m4a")
        wav_path = os.path.join(issue_folder, "audio.wav")

        # Save uploaded file
        with open(m4a_path, "wb") as f:
            f.write(await audio_file.read())

        # Convert to WAV (16kHz, mono) for the model
        subprocess.run([
            "ffmpeg", "-y", "-i", m4a_path, "-ar", "16000", "-ac", "1", 
            "-acodec", "pcm_s16le", wav_path
        ], check=True)

        # Trigger background prediction task
        task = audio_prediction.delay(wav_path)
        while not task.ready():
            await asyncio.sleep(1)

        result = task.get()
        
        # Save record to database
        issue_record = AudioIssue(
            audio_path=m4a_path,
            classe=result["predicted_classe"],
            user=user
        )
        database.add(issue_record)
        database.commit()

        return {"message": "Audio issue created successfully", "class": issue_record.classe}
    
    except Exception as e:
        database.rollback()
        raise HTTPException(status_code=500, detail=f"Error processing audio: {str(e)}")

@audio_router.get("/issues")
def list_audio_issues(user=Depends(get_curent__user)):
    """Retrieves all audio issues for the authenticated user."""
    return {"issues": [{"id": i.id, "predicted_class": i.classe} for i in user.audio_issues]}

@audio_router.get("/issues/{issue_id}")
def get_audio_issue(issue_id: int, user=Depends(get_curent__user), database=Depends(get_session)):
    """Retrieves details of a specific audio diagnostic report."""
    issue = database.query(AudioIssue).filter(AudioIssue.id == issue_id, AudioIssue.id_user == user.id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Issue not found")

    return {
        "id": issue.id,
        "predicted_class": issue.classe,
        "audio_path": issue.audio_path.replace("\\", "/"),
    }