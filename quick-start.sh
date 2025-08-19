#!/bin/bash

# MedraN Medical AI Assistant - Quick Start Script
# This script sets up everything automatically for complete beginners

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${PURPLE}🏥 MedraN Medical AI Assistant - Quick Start${NC}"
echo -e "${PURPLE}=============================================${NC}"
echo ""
echo -e "${CYAN}🚀 Setting up your complete medical AI assistant...${NC}"
echo -e "${CYAN}   This will be 100% ready to use in a few minutes!${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found!${NC}"
    echo -e "${YELLOW}💡 Please install Docker Desktop first:${NC}"
    echo -e "${BLUE}   - macOS/Windows: https://www.docker.com/products/docker-desktop${NC}"
    echo -e "${BLUE}   - Linux: https://docs.docker.com/engine/install/${NC}"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose not found!${NC}"
    echo -e "${YELLOW}💡 Please install Docker Compose or update Docker Desktop${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is installed and ready!${NC}"

# Detect system for optimal configuration
OS="$(uname -s)"
ARCH="$(uname -m)"

echo -e "${BLUE}🔍 Detected system: ${OS} ${ARCH}${NC}"

# Choose setup type
echo ""
echo -e "${YELLOW}📋 Choose your setup:${NC}"
echo -e "${CYAN}   1) 🔥 All-in-One (Recommended for beginners)${NC}"
echo -e "${CYAN}      - Everything included: AI model, web interface, voice chat${NC}"
echo -e "${CYAN}      - No external software needed${NC}"
echo -e "${CYAN}      - Automatically downloads AI model (~4GB)${NC}"
echo ""
echo -e "${CYAN}   2) 🔧 Use External LLM (Advanced users)${NC}"
echo -e "${CYAN}      - Requires LM Studio/Ollama running separately${NC}"
echo -e "${CYAN}      - More control over model selection${NC}"
echo ""
read -p "$(echo -e ${YELLOW}Choose option [1-2]:${NC} )" choice

case $choice in
    1)
        echo -e "${GREEN}🎯 Setting up All-in-One configuration...${NC}"
        USE_BUILTIN=true
        ;;
    2)
        echo -e "${GREEN}🎯 Setting up External LLM configuration...${NC}"
        USE_BUILTIN=false
        ;;
    *)
        echo -e "${GREEN}🎯 Invalid choice, using All-in-One (recommended)...${NC}"
        USE_BUILTIN=true
        ;;
esac

echo ""
echo -e "${BLUE}🏗️ Building and starting services...${NC}"

if [ "$USE_BUILTIN" = true ]; then
    # All-in-one setup
    echo -e "${CYAN}📦 Starting containerized setup with automatic model download...${NC}"
    echo -e "${YELLOW}⚡ This will download a ~6GB AI model on first run${NC}"
    echo -e "${YELLOW}☕ Grab a coffee - this might take 10-20 minutes depending on your internet${NC}"
    
    # Use the smart docker launcher with LM Studio
    if ./docker-start.sh -f docker-compose.lmstudio.yml up --build -d; then
        echo -e "${GREEN}✅ All-in-One setup completed!${NC}"
    else
        echo -e "${RED}❌ Setup failed. Check the logs above.${NC}"
        exit 1
    fi
else
    # External LLM setup
    echo -e "${CYAN}🔗 Starting with external LLM support...${NC}"
    echo -e "${YELLOW}⚠️  Make sure your LLM server (LM Studio/Ollama) is running on port 1234${NC}"
    
    if ./docker-start.sh up --build -d; then
        echo -e "${GREEN}✅ External LLM setup completed!${NC}"
    else
        echo -e "${RED}❌ Setup failed. Check the logs above.${NC}"
        exit 1
    fi
fi

# Wait a moment for services to initialize
echo -e "${BLUE}⏳ Waiting for services to initialize...${NC}"
sleep 10

# Check health
echo -e "${BLUE}🏥 Checking system health...${NC}"
for i in {1..30}; do
    if curl -s http://localhost:3000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ System is healthy and ready!${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${YELLOW}⚠️  Services are starting but may need more time...${NC}"
    fi
    sleep 2
done

echo ""
echo -e "${GREEN}🎉 MedraN Medical AI Assistant is ready!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo -e "${CYAN}🌐 Web Interface: ${GREEN}http://localhost:3000${NC}"
echo -e "${CYAN}📋 Features available:${NC}"
echo -e "${BLUE}   ✅ Chat with AI assistant${NC}"
echo -e "${BLUE}   ✅ Voice transcription (WAV, MP3, M4A, FLAC, OGG)${NC}"
echo -e "${BLUE}   ✅ Document upload and analysis (PDF)${NC}"
echo -e "${BLUE}   ✅ Medical literature processing${NC}"
echo -e "${BLUE}   ✅ Citation-backed responses${NC}"

if [ "$USE_BUILTIN" = true ]; then
    echo ""
    echo -e "${PURPLE}🤖 AI Model Information:${NC}"
    echo -e "${CYAN}   Model: Google Gemma 3n-E4B IT (Instruction Tuned)${NC}"
    echo -e "${CYAN}   Size: ~6GB (high quality with multimodal capabilities)${NC}"
    echo -e "${CYAN}   Capabilities: Medical Q&A, document analysis, voice chat, image understanding${NC}"
fi

echo ""
echo -e "${YELLOW}🔧 Management Commands:${NC}"
echo -e "${BLUE}   View logs:    docker compose logs -f${NC}"
echo -e "${BLUE}   Stop system:  docker compose down${NC}"
echo -e "${BLUE}   Restart:      docker compose restart${NC}"
echo ""
echo -e "${GREEN}🚀 Open http://localhost:3000 in your browser to get started!${NC}"
echo ""

# Optionally open browser
if command -v open &> /dev/null; then
    # macOS
    read -p "$(echo -e ${YELLOW}Open in browser now? [y/N]:${NC} )" open_browser
    if [[ $open_browser =~ ^[Yy]$ ]]; then
        open http://localhost:3000
    fi
elif command -v xdg-open &> /dev/null; then
    # Linux
    read -p "$(echo -e ${YELLOW}Open in browser now? [y/N]:${NC} )" open_browser
    if [[ $open_browser =~ ^[Yy]$ ]]; then
        xdg-open http://localhost:3000
    fi
fi

echo -e "${GREEN}✨ Enjoy your MedraN Medical AI Assistant!${NC}"
