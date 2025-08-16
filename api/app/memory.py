import chromadb, time
from sentence_transformers import SentenceTransformer
from .settings import settings

_client = None
_mem_embed = None

def _get_client():
    global _client
    if _client is None:
        _host = settings.chroma_url.split("//")[1].split(":")[0]
        _port = int(settings.chroma_url.split(":")[-1])
        _client = chromadb.HttpClient(host=_host, port=_port)
    return _client

def _get_embed_model():
    global _mem_embed
    if _mem_embed is None:
        _mem_embed = SentenceTransformer(settings.embedding_model)
    return _mem_embed

def _mem_col(user_id: str):
    return _get_client().get_or_create_collection(f"mem_{user_id}")

def remember(user_id: str, role: str, text: str):
    col = _mem_col(user_id)
    ts = time.time()
    doc = f"[{role} @ {ts:.0f}] {text}"
    emb = _get_embed_model().encode([doc], normalize_embeddings=True).tolist()[0]
    col.upsert(
        ids=[f"{user_id}:{ts:.0f}"],
        embeddings=[emb],
        documents=[doc],
        metadatas=[{"user_id": user_id, "role": role, "ts": ts}],
    )

def recall(user_id: str, query: str, n: int = 6):
    col = _mem_col(user_id)
    q = _get_embed_model().encode([query], normalize_embeddings=True).tolist()
    try:
        res = col.query(query_embeddings=q, n_results=n)
    except Exception:
        return []
    return res.get("documents", [[]])[0] or []
