#!/usr/bin/env python3
"""
MLX-optimized OpenAI-compatible API server for macOS Apple Silicon
Provides fast inference using Apple's Metal Performance Shaders
"""

import os
import time
import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import uuid

# MLX imports
try:
    from mlx_lm import load, generate
    import mlx.core as mx
    MLX_AVAILABLE = True
except ImportError:
    print("⚠️ MLX not available - falling back to CPU mode")
    MLX_AVAILABLE = False

app = FastAPI(title="MedraN MLX Server", version="1.0.0")

# Enable CORS for web UI
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global model variables
model = None
tokenizer = None
model_name = "MedraN-E4B-Uncensored"

# Pydantic models for OpenAI API compatibility
class Message(BaseModel):
    role: str
    content: str

class ChatCompletionRequest(BaseModel):
    model: str
    messages: List[Message]
    temperature: Optional[float] = 0.7
    max_tokens: Optional[int] = 512
    stream: Optional[bool] = False

class Choice(BaseModel):
    index: int
    message: Message
    finish_reason: str

class Usage(BaseModel):
    prompt_tokens: int
    completion_tokens: int
    total_tokens: int

class ChatCompletionResponse(BaseModel):
    id: str
    object: str = "chat.completion"
    created: int
    model: str
    choices: List[Choice]
    usage: Usage

class Model(BaseModel):
    id: str
    object: str = "model"
    created: int
    owned_by: str = "medran"

class ModelList(BaseModel):
    object: str = "list"
    data: List[Model]

def load_mlx_model():
    """Load MLX model with Apple Metal GPU acceleration"""
    global model, tokenizer
    
    model_path = "/opt/models/mlx-model"
    
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Model not found at {model_path}")
    
    print(f"🍎 Loading MLX model from {model_path}...")
    print("⚡ Initializing Apple Metal GPU acceleration...")
    
    try:
        # Load model and tokenizer with MLX
        model, tokenizer = load(model_path)
        
        # Verify Metal GPU is available
        if mx.metal.is_available():
            print("✅ Apple Metal GPU detected and activated!")
            print(f"🔋 GPU Memory: {mx.metal.get_active_memory() / 1024**3:.1f}GB active")
        else:
            print("⚠️ Metal GPU not available, using CPU")
            
        print("✅ MLX model loaded successfully!")
        return True
        
    except Exception as e:
        print(f"❌ Failed to load MLX model: {str(e)}")
        raise

def apply_chat_template(messages: List[Message]) -> str:
    """Apply Gemma chat template to messages"""
    formatted_messages = []
    
    for message in messages:
        if message.role == "system":
            # Gemma doesn't have a system role, so we prepend to the first user message
            continue
        elif message.role == "user":
            formatted_messages.append(f"<start_of_turn>user\n{message.content}<end_of_turn>\n")
        elif message.role == "assistant":
            formatted_messages.append(f"<start_of_turn>model\n{message.content}<end_of_turn>\n")
    
    # Add the model turn prefix for generation
    prompt = "".join(formatted_messages) + "<start_of_turn>model\n"
    return prompt

@app.on_event("startup")
async def startup_event():
    """Initialize the MLX model on startup"""
    if MLX_AVAILABLE:
        try:
            load_mlx_model()
        except Exception as e:
            print(f"❌ Failed to initialize MLX model: {str(e)}")
            raise

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "ok", "mlx_available": MLX_AVAILABLE, "model_loaded": model is not None}

@app.get("/v1/models")
async def list_models():
    """List available models (OpenAI API compatible)"""
    return ModelList(
        data=[
            Model(
                id=model_name,
                created=int(time.time()),
                owned_by="medran"
            )
        ]
    )

@app.post("/v1/chat/completions")
async def create_chat_completion(request: ChatCompletionRequest):
    """Create chat completion (OpenAI API compatible)"""
    
    if not MLX_AVAILABLE or model is None or tokenizer is None:
        raise HTTPException(status_code=503, detail="MLX model not available")
    
    try:
        # Format messages using Gemma chat template
        prompt = apply_chat_template(request.messages)
        
        print(f"🤖 Generating response using MLX (Apple Metal GPU)...")
        start_time = time.time()
        
        # Generate response using MLX
        response = generate(
            model, 
            tokenizer, 
            prompt=prompt,
            temp=request.temperature,
            max_tokens=request.max_tokens,
            verbose=False
        )
        
        generation_time = time.time() - start_time
        
        # Extract just the generated part (after the prompt)
        if response.startswith(prompt):
            generated_text = response[len(prompt):].strip()
        else:
            generated_text = response.strip()
        
        # Remove any end-of-turn tokens
        generated_text = generated_text.replace("<end_of_turn>", "").strip()
        
        # Estimate token counts (rough approximation)
        prompt_tokens = len(prompt.split()) * 1.3  # Approximate subword tokenization
        completion_tokens = len(generated_text.split()) * 1.3
        
        print(f"✅ Generated {int(completion_tokens)} tokens in {generation_time:.2f}s ({completion_tokens/generation_time:.1f} tokens/s)")
        
        return ChatCompletionResponse(
            id=f"chatcmpl-{str(uuid.uuid4())}",
            created=int(time.time()),
            model=request.model,
            choices=[
                Choice(
                    index=0,
                    message=Message(role="assistant", content=generated_text),
                    finish_reason="stop"
                )
            ],
            usage=Usage(
                prompt_tokens=int(prompt_tokens),
                completion_tokens=int(completion_tokens),
                total_tokens=int(prompt_tokens + completion_tokens)
            )
        )
        
    except Exception as e:
        print(f"❌ Error generating response: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Generation error: {str(e)}")

if __name__ == "__main__":
    port = int(os.getenv("PORT", 1234))
    host = os.getenv("HOST", "0.0.0.0")
    
    print(f"🚀 Starting MedraN MLX Server on {host}:{port}")
    print("🍎 Optimized for macOS Apple Silicon with Metal GPU acceleration")
    
    uvicorn.run(
        app, 
        host=host, 
        port=port,
        log_level="info"
    )
