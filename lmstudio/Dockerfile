# LM Studio containerized service
# Based on Ubuntu with CUDA support for GPU acceleration
FROM nvidia/cuda:12.1-devel-ubuntu22.04

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    git \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Install LM Studio CLI
# Note: This is a simplified approach - in practice you might need to:
# 1. Download the actual LM Studio CLI from their official source
# 2. Or use a compatible OpenAI API server like llama.cpp server or vllm
# For now, we'll use llama.cpp server as a drop-in replacement

# Install llama.cpp with CUDA support
WORKDIR /opt
RUN git clone https://github.com/ggerganov/llama.cpp.git && \
    cd llama.cpp && \
    mkdir build && cd build && \
    cmake .. -DLLAMA_CUBLAS=ON && \
    cmake --build . --config Release -j$(nproc) && \
    cp bin/server ../server

# Create a models directory
RUN mkdir -p /opt/models

# Set working directory
WORKDIR /opt/llama.cpp

# Copy startup script
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

# Expose the API port (compatible with OpenAI API)
EXPOSE 1234

# Environment variables
ENV MODEL_PATH=/opt/models/model.gguf
ENV HOST=0.0.0.0
ENV PORT=1234
ENV GPU_LAYERS=-1
ENV CONTEXT_SIZE=4096

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:1234/health || exit 1

# Start the server
CMD ["/opt/start.sh"]
