from sqlalchemy import create_engine, Column, INTEGER, TEXT
from sqlalchemy.orm import sessionmaker, declarative_base
from pgvector.sqlalchemy import Vector

# --- Database Configuration ---
DB_URL = "postgresql+psycopg://postgres:qwerty@127.0.0.1:5432/MyGarage"
engine = create_engine(url=DB_URL)
SessionLocal = sessionmaker(bind=engine, autoflush=False)
Base = declarative_base()

# --- Model ---

class RagChunk(Base):
    """
    Model: RagChunk (chunk)
    Description: Stores text chunks and their corresponding vector embeddings 
    for RAG (Retrieval-Augmented Generation) purposes.
    """
    __tablename__ = "chunk"
    
    id = Column(INTEGER, primary_key=True, autoincrement=True)
    title = Column(TEXT)
    content = Column(TEXT)
    embedding = Column(Vector(1024))  # Vector dimension matches the embedding model

# --- Initialization ---
if __name__ == "__main__":
    Base.metadata.create_all(bind=engine)