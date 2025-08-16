from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    openai_base_url: str
    openai_api_key: str = "none"
    openai_chat_model: str

    chroma_url: str
    redis_url: str
    minio_endpoint: str
    minio_access_key: str
    minio_secret_key: str
    minio_bucket: str = "jarvisdocs"

    # OCR model for document preprocessing (TrOCR)
    ocr_model: str = "microsoft/trocr-base-printed"
    
    # Embedding models for vector search (unchanged)
    embedding_model: str = "BAAI/bge-m3"
    image_embedding_model: str = "openai/clip-vit-large-patch14"
    max_context_chars: int = 120000

    # ASR model for /transcribe (faster-whisper)
    asr_model: str = "small.en"  # options: tiny/base/small/medium/large-v3, or multilingual variants

    class Config:
        env_prefix = ""
        case_sensitive = False

settings = Settings()
