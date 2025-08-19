#!/bin/bash

set -e

echo "🚀 Starting LM Studio compatible server..."

# Default model URL for automatic download (Google Gemma 3n-E4B-it)
DEFAULT_MODEL_URL="https://huggingface.co/bartowski/google_gemma-3n-E4B-it-GGUF/resolve/main/gemma-3n-E4B-it-Q4_K_M.gguf"
DEFAULT_MODEL_NAME="gemma-3n-E4B-it-Q4_K_M.gguf"

# Check if model exists, if not download a default one
if [ ! -f "$MODEL_PATH" ]; then
    echo "📦 No model found at $MODEL_PATH"
    echo "🔄 Auto-downloading default model for plug-and-play setup..."
    echo "📝 Model: Google Gemma 3n-E4B IT (Instruction Tuned)"
    echo "📏 Size: ~6GB (Q4_K_M quantization - good balance of quality and speed)"
    
    # Create models directory
    mkdir -p /opt/models
    
    # Download with progress
    echo "⬇️ Downloading model... This may take a few minutes depending on your connection."
    if wget --progress=bar:force:noscroll -O "$MODEL_PATH" "$DEFAULT_MODEL_URL"; then
        echo "✅ Model downloaded successfully!"
        echo "📁 Saved to: $MODEL_PATH"
    else
        echo "❌ Failed to download model. Please check your internet connection."
        echo "💡 You can manually download a GGUF model and place it at $MODEL_PATH"
        exit 1
    fi
else
    echo "✅ Found existing model at $MODEL_PATH"
fi

echo "📦 Model: $MODEL_PATH"
echo "🌐 Host: $HOST"
echo "🔌 Port: $PORT"
echo "🎮 GPU Layers: $GPU_LAYERS"
echo "📖 Context Size: $CONTEXT_SIZE"

# Check GPU availability
if command -v nvidia-smi &> /dev/null; then
    echo "🎮 NVIDIA GPU detected:"
    nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits
    GPU_ARGS="--n-gpu-layers $GPU_LAYERS"
else
    echo "💻 No GPU detected, using CPU"
    GPU_ARGS=""
fi

# Start the llama.cpp server with OpenAI API compatibility
exec ./server \
    --model "$MODEL_PATH" \
    --host "$HOST" \
    --port "$PORT" \
    --ctx-size "$CONTEXT_SIZE" \
    --api-key "none" \
    --threads $(nproc) \
    $GPU_ARGS \
    --verbose
