from fastapi import Depends, HTTPException, APIRouter, File, UploadFile, Request
from fastapi.responses import StreamingResponse
from bd_initialization.Bridge import get_session
from server.server_utils import get_curent__user
from bd_initialization.DataBase_models import AnalyseTaule
from deep_learning.functions import *
from server.celery_script import taule_prediction, run_full_video_inspection, celery_app
import os
import numpy as np
import cv2
import asyncio
taule_analysis_router = APIRouter()





@taule_analysis_router.post("/image_analysis")
async def create_image_analysis(
    user=Depends(get_curent__user),
    image_file: UploadFile = File(),
    database=Depends(get_session),
):
    try:
        analysis_index = len(user.analyses_taule) + 1
        analysis_folder = os.path.join(
            "users_files",
            f"user_{user.id}",
            "analyses_taule",
            f"analyse_taule-{analysis_index}",
        )
        original_image_path = os.path.join(analysis_folder, "original_image.jpg")
        analysed_image_path = os.path.join(analysis_folder, "analysed_image.jpg")
        os.makedirs(analysis_folder, exist_ok=True)

        image_content = await image_file.read()
        np_image = np.frombuffer(image_content, np.uint8)
        image = cv2.imdecode(np_image, cv2.IMREAD_COLOR)
        cv2.imwrite(original_image_path, image)

        task = taule_prediction.delay(original_image_path, analysed_image_path)
        while not task.ready():
            await asyncio.sleep(1)

        result = task.get()
        detected_classes = result.get("detected_classes", [])

        analysis_record = AnalyseTaule(
            analysed_path=analysed_image_path,
            original_path=original_image_path,
            detections=detected_classes,
            type="image",
            user=user,
        )

        database.add(analysis_record)
        database.commit()
        database.refresh(analysis_record)

        return {"message": "Taule image analysis created successfully"}
    except Exception as e:
        database.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating taule analysis: {e}")


@taule_analysis_router.get("/taule_analyses")
def get_taule_analyses(user=Depends(get_curent__user)):
    try:
        if user:
            analyses = user.analyses_taule
            return {
                "analyses": [
                    {
                        "id": a.id,
                        "detections": a.detections,
                        "type": a.type,
                        "analysed_path": a.analysed_path,
                    }
                    for a in analyses
                ]
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching analyses: {e}")
@taule_analysis_router.get("/analysis_details")
def get_analysis_details(
    analysis_id: int,
    user=Depends(get_curent__user),
    database=Depends(get_session),
):
    try:
        analysis = database.query(AnalyseTaule).filter(AnalyseTaule.id == analysis_id).first()
        if analysis:
            analysed_path = analysis.analysed_path.replace("\\", "/")
            return {
                "id": analysis.id,
                "analysed_path": analysed_path,
                "detections": analysis.detections,
                "type": analysis.type,
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching analysis details: {e}")
    


@taule_analysis_router.post("/video_analysis")
async def start_video_analysis(
    video: UploadFile = File(),
    user=Depends(get_curent__user),
):
    analysis_count = len(user.analyses_taule) + 1
    report_folder = os.path.join(
        "users_files",
        f"user_{user.id}",
        "analyses_taules",
        f"analyse-{analysis_count}",
    )
    os.makedirs(report_folder, exist_ok=True)

    original_video_path = os.path.join(report_folder, "original_video.mp4")
    output_video_path = os.path.join(report_folder, "output_video.mp4")

    video_content = await video.read()
    with open(original_video_path, "wb") as file:
        file.write(video_content)

    task = run_full_video_inspection.delay(
        original_video_path,
        output_video_path,
        user.id,
    )

    return {"task_id": task.id}





@taule_analysis_router.get("/task_status/{task_id}")
async def get_task_status(task_id: str, user=Depends(get_curent__user)):
    task = celery_app.AsyncResult(task_id)
    if task.state == "PENDING":
        return {"status": "pending"}
    elif task.state == "SUCCESS":
        return {"status": "done"}
    elif task.state == "FAILURE":
        return {"status": "error"}
    else:
        return {"status": task.state.lower()}


@taule_analysis_router.get("/video/{analysis_id}")
async def stream_video(analysis_id: int, request: Request, database=Depends(get_session)):
    analysis = database.query(AnalyseTaule).filter(AnalyseTaule.id == analysis_id).first()

    if not analysis:
        raise HTTPException(status_code=404, detail="Analysis not found")

    video_path = analysis.analysed_path

    if not os.path.exists(video_path):
        raise HTTPException(status_code=404, detail="Video not found")

    file_size = os.path.getsize(video_path)

    # ✅ Lire le header Range
    range_header = request.headers.get("Range")

    if range_header:
        # Parse "bytes=start-end"
        range_val = range_header.strip().replace("bytes=", "")
        parts = range_val.split("-")
        start = int(parts[0])
        end = int(parts[1]) if parts[1] else file_size - 1

        # Limite la taille du chunk
        end = min(end, file_size - 1)
        chunk_size = end - start + 1

        def iter_range():
            with open(video_path, "rb") as f:
                f.seek(start)
                remaining = chunk_size
                while remaining > 0:
                    data = f.read(min(1024 * 1024, remaining))
                    if not data:
                        break
                    remaining -= len(data)
                    yield data

        # ✅ 206 Partial Content
        return StreamingResponse(
            iter_range(),
            status_code=206,
            media_type="video/mp4",
            headers={
                "Content-Range": f"bytes {start}-{end}/{file_size}",
                "Accept-Ranges": "bytes",
                "Content-Length": str(chunk_size),
            },
        )

    # ✅ Pas de Range → retourne tout le fichier
    def iter_full():
        with open(video_path, "rb") as f:
            while chunk := f.read(1024 * 1024):
                yield chunk

    return StreamingResponse(
        iter_full(),
        status_code=200,
        media_type="video/mp4",
        headers={
            "Accept-Ranges": "bytes",
            "Content-Length": str(file_size),
        },
    )