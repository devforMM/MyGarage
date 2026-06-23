from pydantic import BaseModel
from typing import Literal

# --- Authentication Schemas ---

class RegisterRequest(BaseModel):
    """Schema for user registration."""
    email: str
    password: str
    nom: str
    prenom: str
    num_tel: str
    adresse: str

class LoginRequest(BaseModel):
    """Schema for user login."""
    email: str
    password: str

# --- Prediction & Analysis Schemas ---

class PredictionRequest(BaseModel):
    """Schema for vehicle price prediction input."""
    year: int
    kilometres: float
    make: str
    model: str
    trim: str
    fuel: str
    transmission: str
    body_type: str
    doors: int
    seats: int
    engine_size: float
    engine_power: float
    drive_train: str
    color: str

# --- Chat & RAG Schemas ---

class ChatRequest(BaseModel):
    """Schema for chatbot queries."""
    query: str