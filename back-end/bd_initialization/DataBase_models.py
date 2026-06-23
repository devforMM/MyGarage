from sqlalchemy import create_engine, Column, INTEGER, TEXT, ForeignKey, JSON
from sqlalchemy.orm import sessionmaker, declarative_base, relationship
from pgvector.sqlalchemy import Vector
import os
from dotenv import load_dotenv
load_dotenv()
DB_URL=os.getenv("DB_URL")
# --- Configuration de la base de données ---
engine = create_engine(url=DB_URL)
SessionLocal = sessionmaker(bind=engine, autoflush=False)
Base = declarative_base()

# --- Modèles (Tables) ---

class User(Base):
    """Modèle représentant un utilisateur du système."""
    __tablename__ = "user"
    
    id = Column(INTEGER, primary_key=True, nullable=False, autoincrement=True)
    email = Column(TEXT, nullable=False, unique=True)
    password = Column(TEXT, nullable=False)
    nom = Column(TEXT, nullable=False)
    prenom = Column(TEXT, nullable=False)
    num_tel = Column(TEXT, nullable=False)
    adresse = Column(TEXT, nullable=False)

    # Relations
    audio_issues = relationship(
        "AudioIssue",
        back_populates="user",
        foreign_keys="[AudioIssue.id_user]"
    )
    analyses_taule = relationship(
        "AnalyseTaule",
        back_populates="user",
        foreign_keys="[AnalyseTaule.id_user]"
    )


class AudioIssue(Base):
    """Modèle pour le suivi des pannes audio."""
    __tablename__ = "panne_audio"
    
    id = Column(INTEGER, primary_key=True, nullable=False, autoincrement=True)
    audio_path = Column(TEXT, nullable=False)
    classe = Column(TEXT, nullable=False)
    id_user = Column(INTEGER, ForeignKey("user.id"))
    
    # Relation vers l'utilisateur
    user = relationship(
        "User",
        back_populates="audio_issues",
        foreign_keys=[id_user]
    )


class AnalyseTaule(Base):
    """Modèle pour le stockage des analyses de tôlerie."""
    __tablename__ = "analyse_taule"
    
    id = Column(INTEGER, primary_key=True, nullable=False, autoincrement=True)
    analysed_path = Column(TEXT, nullable=False)
    original_path = Column(TEXT, nullable=False)
    type = Column(TEXT, nullable=False)
    detections = Column(JSON, nullable=False)
    id_user = Column(INTEGER, ForeignKey("user.id"), nullable=False)
    
    # Relation vers l'utilisateur
    user = relationship(
        "User",
        back_populates="analyses_taule",
        foreign_keys=[id_user]
    )

Base.metadata.create_all(bind=engine)