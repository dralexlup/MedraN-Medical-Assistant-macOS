#!/bin/bash

set -e

echo "🍎 Starting MLX-optimized server for macOS Apple Silicon..."

# Default model for automatic download (MedraN-E4B-Uncensored MLX format)
DEFAULT_MODEL_HF="drwlf/MedraN-E4B-Uncensored-MLX"
MODEL_PATH="/opt/models/mlx-model"

# Check if model exists, if not download it
if [ ! -d "$MODEL_PATH" ]; then
    echo "📦 No MLX model found at $MODEL_PATH"
    echo "🔄 Auto-downloading optimized MLX model for Apple Silicon..."
    echo "📝 Model: MedraN-E4B-Uncensored (Medical AI optimized, MLX format)"
    echo "📏 Size: ~6GB (specialized for medical and healthcare tasks)"
    
    # Create models directory
    mkdir -p /opt/models
    
    echo "⬇️ Downloading MLX model... This may take a few minutes."
    python -c "
from huggingface_hub import snapshot_download
import os
snapshot_download(
    repo_id='$DEFAULT_MODEL_HF',
    local_dir='$MODEL_PATH',
    local_dir_use_symlinks=False
)
print('✅ MLX model downloaded successfully!')
"
else
    echo "✅ Found existing MLX model at $MODEL_PATH"
fi

echo "📦 Model: $MODEL_PATH"
echo "🌐 Host: $HOST"
echo "🔌 Port: $PORT"
echo "🍎 Platform: macOS with Apple Metal GPU acceleration"

# Start the MLX server
exec python /opt/mlx-server.py
