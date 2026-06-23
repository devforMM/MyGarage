from sqlalchemy import select
from sqlalchemy.orm import Session
from sentence_transformers import CrossEncoder

from chunking.chunks_bd import engine, RagChunk
from chunking.chunking_functions import embed

# --- Global Reranker instance ---
_reranker = None

def get_reranker():
    """Lazy initialization of the CrossEncoder reranker."""
    global _reranker
    if _reranker is None:
        _reranker = CrossEncoder("BAAI/bge-reranker-base", device="cuda")
    return _reranker

def search_function(query):
    """Performs vector similarity search (L2 distance) in the database."""
    with Session(engine) as session:
        query_vector = embed(query)
        stmt = (
            select(RagChunk.content, RagChunk.id, RagChunk.title)
            .order_by(RagChunk.embedding.l2_distance(query_vector))
            .limit(10)
        )
        return session.execute(stmt).all()

def format_results(results):
    """Converts database results into a list of dictionaries."""
    return [
        {"id": r.id, "content": r.content, "title": r.title}
        for r in results
    ]

def rerank_results(pairs, query):
    """Re-ranks search results using a CrossEncoder for higher precision."""
    reranker = get_reranker()
    
    # Calculate relevance scores
    scores = reranker.predict([(query, p["content"]) for p in pairs])
    for p, score in zip(pairs, scores):
        p["score"] = float(score)

    # Sort by score and pick top 3
    top_results = sorted(pairs, key=lambda x: x["score"], reverse=True)[:3]

    # Format context for LLM
    context = "\n\n".join([f"[{r['title']}]\n{r['content']}" for r in top_results])
    return {"content": context}

def retrieve_content(user_query):
    """Main pipeline: Search -> Format -> Rerank -> Return context."""
    raw_results = search_function(user_query)
    formatted = format_results(raw_results)
    return rerank_results(formatted, user_query)