from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

from routes.user_routes import user_router 
from routes.audio_routes import audio_router 
from routes.taule_analysis_routes import taule_analysis_router
from deep_learning.functions import load_prediction_model

app = FastAPI(title="MyGarage API")

# --- Middleware: CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Routers ---
app.include_router(user_router, prefix="/garage/user")
app.include_router(audio_router, prefix="/garage/audio")
app.include_router(taule_analysis_router, prefix="/garage/taule")

# --- Static Files ---
app.mount("/images", StaticFiles(directory="."), name="images")

# --- Lifecycle Events ---
@app.on_event("startup")
async def startup_event():
    """Load ML models into the application state during startup."""
    try:
        app.state.price_model = load_prediction_model()
        print("✅ Price prediction model loaded successfully.")
    except Exception as e:
        print(f"❌ Error loading price prediction model: {e}")
        # Raising an exception here prevents the app from starting if models fail
        raise HTTPException(status_code=500, detail="Failed to initialize AI models")