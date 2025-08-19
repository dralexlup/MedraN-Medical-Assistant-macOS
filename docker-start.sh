#!/bin/bash

# Smart Docker Compose launcher with automatic platform and GPU detection
# Detects Linux AMD64 with NVIDIA GPU, macOS with Apple Silicon, etc.

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Detecting platform and GPU configuration...${NC}"

# Check if user wants containerized LM Studio
USE_CONTAINERIZED_LM=false
for arg in "$@"; do
    if [[ "$arg" == *"docker-compose.lmstudio.yml"* ]]; then
        USE_CONTAINERIZED_LM=true
        echo -e "${GREEN}📦 Containerized LM Studio mode enabled${NC}"
        echo -e "${BLUE}✨ Plug-and-play setup: AI model will auto-download if needed${NC}"
        break
    fi
done

# Detect operating system
OS="$(uname -s)"
ARCH="$(uname -m)"

echo -e "${BLUE}Platform: ${OS} ${ARCH}${NC}"

# Initialize compose files array
COMPOSE_FILES=("-f" "docker-compose.yml")

# Platform-specific GPU detection
case "${OS}" in
    Linux*)
        echo -e "${BLUE}🐧 Linux detected${NC}"
        
        # Check for NVIDIA GPU
        if command -v nvidia-smi &> /dev/null; then
            echo -e "${GREEN}🎮 NVIDIA GPU detected!${NC}"
            nvidia-smi --query-gpu=name --format=csv,noheader
            
            # Check if Docker supports nvidia runtime
            if docker info 2>/dev/null | grep -i "runtimes" | grep -q "nvidia"; then
                echo -e "${GREEN}✅ NVIDIA Docker runtime available${NC}"
                COMPOSE_FILES+=("-f" "docker-compose.gpu.yml")
            else
                echo -e "${YELLOW}⚠️  NVIDIA Docker runtime not detected. Install nvidia-container-toolkit for GPU support.${NC}"
            fi
        else
            echo -e "${YELLOW}ℹ️  No NVIDIA GPU detected, using CPU${NC}"
        fi
        ;;
        
    Darwin*)
        echo -e "${BLUE}🍎 macOS detected${NC}"
        
        # Check if Apple Silicon
        if [[ "${ARCH}" == "arm64" ]]; then
            echo -e "${BLUE}🔧 Apple Silicon (${ARCH}) detected${NC}"
            echo -e "${YELLOW}ℹ️  Note: Docker Desktop on macOS does not support direct GPU access${NC}"
            echo -e "${YELLOW}ℹ️  GPU acceleration is not available through Docker containers${NC}"
            COMPOSE_FILES+=("-f" "docker-compose.mps.yml")
        else
            echo -e "${BLUE}💻 Intel Mac detected${NC}"
            echo -e "${YELLOW}ℹ️  Using CPU-only configuration${NC}"
        fi
        ;;
        
    CYGWIN*|MINGW32*|MSYS*|MINGW*)
        echo -e "${BLUE}🪟 Windows detected${NC}"
        echo -e "${YELLOW}ℹ️  Windows GPU detection not implemented yet${NC}"
        echo -e "${YELLOW}ℹ️  Using CPU-only configuration${NC}"
        ;;
        
    *)
        echo -e "${YELLOW}❓ Unknown OS: ${OS}${NC}"
        echo -e "${YELLOW}ℹ️  Using CPU-only configuration${NC}"
        ;;
esac

# Print final configuration
echo -e "${BLUE}📁 Using compose files:${NC}"
for file in "${COMPOSE_FILES[@]}"; do
    if [[ "$file" != "-f" ]]; then
        echo -e "${BLUE}  - $file${NC}"
    fi
done

# Execute docker compose with detected configuration
echo -e "${GREEN}🚀 Starting services...${NC}"
exec docker compose "${COMPOSE_FILES[@]}" "$@"
