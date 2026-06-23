import ollama
from sqlalchemy.orm import Session
from sqlalchemy import text
from chunking.chunks_bd import engine, RagChunk

def embed(text_content):
    """Generates vector embeddings for a given text using Ollama."""
    response = ollama.embed(model="mxbai-embed-large:latest", input=text_content)
    return response.embeddings[0]

def create_chunk(part):
    """Creates a dictionary structure for a chunk with its embedding."""
    return {
        "title": part.splitlines()[0],
        "content": part,
        "embedding": embed(part)
    }

def extract_content(path):
    """Reads the raw text content from a file."""
    with open(path, "r", encoding="utf-8") as file:
        return file.read()

def insert_chunk(chunk):
    """Inserts a chunk into the database."""
    try:
        db_chunk = RagChunk(
            content=chunk["content"],
            title=chunk["title"],
            embedding=chunk["embedding"]
        )
        with Session(engine) as session:
            session.add(db_chunk)
            session.commit()
            print("Successfully inserted chunk.")
    except Exception as e:
        print(f"❌ Error inserting chunk: {e}")

def create_hnsw_index(table_name):
    """Creates an HNSW index for vector similarity search."""
    with engine.connect() as conn:
        conn.execute(
            text(f"CREATE INDEX idx_{table_name}_embedding ON {table_name} USING hnsw (embedding vector_l2_ops);")
        )
        conn.commit()