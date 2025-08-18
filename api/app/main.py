from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import hashlib

from .schemas import *
from .parsing import parse_pdf_to_sections
from .rag import upsert_text, upsert_images, search, call_llm
from .memory import remember, recall
from .tools import full_read_summarize

# ASR
from faster_whisper import WhisperModel
from .settings import settings
import tempfile, os

app = FastAPI(title="Jarvis-Docs (LM Studio)")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Lazy-load ASR model once
_asr_model = None
def _get_asr():
    global _asr_model
    if _asr_model is None:
        # Auto-detect device for ASR
        import torch
        if torch.cuda.is_available():
            device, compute_type = "cuda", "float16"
        else:
            device, compute_type = "cpu", "int8"
        _asr_model = WhisperModel(settings.asr_model, device=device, compute_type=compute_type)
        print(f"✅ Loaded ASR model on {device}")
    return _asr_model

@app.get("/healthz")
async def health():
    return {"ok": True}

@app.post("/ingest", response_model=IngestResponse)
async def ingest(file: UploadFile = File(...), title: str = Form(None)):
    try:
        data = await file.read()
        doc_id = hashlib.sha256(data).hexdigest()[:16]
        name = title or file.filename
        if not file.filename or not file.filename.lower().endswith(".pdf"):
            return JSONResponse({"error":"Only PDF files are supported"}, status_code=400)

        print(f"📄 Processing document: {name} ({len(data)} bytes)")
        parsed = parse_pdf_to_sections(data, name, doc_id)

        total_chunks = 0
        for page in parsed["pages"]:
            texts = [b["text"] for b in page["text_blocks"] if b["text"]]
            merged, buf = [], ""
            for c in texts:
                if len(buf) + len(c) < 1200:
                    buf += ("\n\n" + c) if buf else c
                else:
                    merged.append(buf); buf = c
            if buf: merged.append(buf)
            upsert_text(parsed["doc_id"], parsed["title"], page["page"], None, merged)
            total_chunks += len(merged)

        print(f"📄 Processed {len(parsed['pages'])} pages, {total_chunks} text chunks")
        
        # Try to process images, but don't fail the entire ingest if it fails
        try:
            upsert_images(parsed["images"])
            print(f"🖼️ Processed {len(parsed.get('images', []))} images")
        except Exception as img_error:
            print(f"⚠️ Warning: Image processing failed: {str(img_error)}")
            # Continue without failing the entire ingest
        
        return IngestResponse(doc_id=parsed["doc_id"], pages=len(parsed["pages"]), chunks=total_chunks)
    
    except Exception as e:
        print(f"❌ Ingest error: {str(e)}")
        return JSONResponse({"error": f"Document processing failed: {str(e)}"}, status_code=500)

@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    try:
        print(f"💬 Chat request: {req.query[:100]}...")
        
        # 1) recall memory
        mem = recall(req.user_id, req.query, n=6)

        # 2) retrieve from docs
        hits, img_urls = await search(req.query, k=req.k, want_images=req.return_images)
        ctx = mem + [h["snippet"] for h in hits]
        
        print(f"🔍 Found {len(hits)} document hits, {len(mem)} memory items")

        # 3) decide: full-read vs normal
        wants_full = req.full_read or ("read the entire" in req.query.lower() or "read whole" in req.query.lower())

        # Only use full-read if explicitly requested AND we have content
        if wants_full and (mem or hits):
            answer = await full_read_summarize(ctx, goal=req.query)
        else:
            # Normal chat with available context (memory + documents)
            answer = await call_llm(req.query, ctx)

        # 4) persist memory
        if req.remember:
            remember(req.user_id, "user", req.query)
            remember(req.user_id, "assistant", answer)

        print(f"✅ Chat completed successfully")
        return ChatResponse(
            answer=answer,
            citations=[SearchHit(**h) for h in hits],
            images=img_urls
        )
    
    except Exception as e:
        print(f"❌ Chat error: {str(e)}")
        return JSONResponse({"error": str(e)}, status_code=500)

@app.post("/transcribe")
async def transcribe(audio: UploadFile = File(...)):
    """Accepts WAV/MP3/M4A/FLAC; returns {'text': transcript}."""
    model = _get_asr()
    # write to temp file
    suffix = os.path.splitext(audio.filename or "")[-1] or ".wav"
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        tmp.write(await audio.read())
        tmp_path = tmp.name
    try:
        segments, info = model.transcribe(tmp_path)
        text = " ".join([seg.text for seg in segments]).strip()
        return {"text": text}
    finally:
        try: os.remove(tmp_path)
        except Exception: pass
