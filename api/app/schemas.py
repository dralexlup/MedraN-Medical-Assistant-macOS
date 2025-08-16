from pydantic import BaseModel, Field
from typing import List, Optional

class ChatRequest(BaseModel):
    query: str
    k: int = 6
    full_read: bool = False
    return_images: bool = True
    user_id: str = "alex"
    remember: bool = True

class IngestResponse(BaseModel):
    doc_id: str
    pages: int
    chunks: int

class SearchHit(BaseModel):
    doc_id: str
    title: str
    page: int
    section: Optional[str]
    snippet: str
    score: float
    figure_urls: List[str] = Field(default_factory=list)

class ChatResponse(BaseModel):
    answer: str
    citations: List[SearchHit] = Field(default_factory=list)
    images: List[str] = Field(default_factory=list)
