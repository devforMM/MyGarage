import logging
import pandas as pd
from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from bd_initialization.Bridge import get_session
from bd_initialization.DataBase_models import User
from models.models import RegisterRequest, LoginRequest, PredictionRequest
from server.server_utils import hash_password, create_token, get_curent__user, verify_password
from Agent.agent import generate

# Setup logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

user_router = APIRouter()

# --- Auth Endpoints ---

@user_router.post("/register")
def register_user(request: RegisterRequest, database: Session = Depends(get_session)):
    """Registers a new user in the system."""
    if database.query(User).filter(User.email == request.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    
    user = User(
        email=request.email,
        password=hash_password(request.password),
        nom=request.nom,
        prenom=request.prenom,
        num_tel=request.num_tel,
        adresse=request.adresse
    )
    database.add(user)
    database.commit()
    return {"message": "Registration successful"}

@user_router.post("/login")
def login_user(request: LoginRequest, database: Session = Depends(get_session)):
    """Authenticates a user and returns a bearer token."""
    user = database.query(User).filter(User.email == request.email).first()
    if not user or not verify_password(request.password, user.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    token = create_token({"id": user.id, "email": user.email})
    return {"access_token": token, "token_type": "bearer", "message": "Login successful"}

# --- Dashboard & Prediction ---

@user_router.get("/dashboard")
def get_dashboard(user: User = Depends(get_curent__user)):
    """Returns profile information for the authenticated user."""
    return {
        "id": user.id, "email": user.email, "nom": user.nom,
        "prenom": user.prenom, "num_tel": user.num_tel, "adresse": user.adresse
    }

@user_router.post("/predict")
def predict_price(inputs: PredictionRequest, request: Request, user: User = Depends(get_curent__user)):
    """Predicts vehicle price based on provided technical features."""
    try:
        df = pd.DataFrame([inputs.dict()])
        prediction = request.app.state.price_model.predict(df)
        return {"price": float(prediction[0])}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

# --- Chatbot Endpoint ---

@user_router.post("/chat")
async def chat_endpoint(request: Request):
    """Streams chatbot responses to the user."""
    data = await request.json()
    user_query = data.get("query", "").strip()
    
    if not user_query:
        raise HTTPException(status_code=400, detail="Query cannot be empty")
        
    logger.info(f"New chat request: {user_query}")
    
    return StreamingResponse(
        generate(user_query),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "Connection": "keep-alive", "X-Accel-Buffering": "no"}
    )