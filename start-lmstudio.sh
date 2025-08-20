#!/bin/bash

# MedraN Medical Assistant - LM Studio Integration Startup Script
# This script starts the medical assistant with LM Studio backend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🍎 MedraN Medical Assistant - LM Studio Integration${NC}"
echo -e "${BLUE}====================================================${NC}"
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This script is optimized for macOS!${NC}"
    echo -e "${YELLOW}💡 For other platforms, use the standard MedraN Medical Assistant${NC}"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

# Check if LM Studio is running by testing the API
echo -e "${YELLOW}🔍 Checking LM Studio connection...${NC}"
if ! curl -s http://localhost:1234/v1/models >/dev/null 2>&1; then
    echo -e "${RED}❌ LM Studio server not found!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Before running this script, please:${NC}"
    echo -e "${BLUE}   1. Download and install LM Studio: ${NC}https://lmstudio.ai/"
    echo -e "${BLUE}   2. Download a medical model (e.g., MedraN-E4B-Uncensored)${NC}"
    echo -e "${BLUE}   3. Go to 'Local Server' tab in LM Studio${NC}"
    echo -e "${BLUE}   4. Load your model and click 'Start Server'${NC}"
    echo -e "${BLUE}   5. Ensure server is running on http://localhost:1234${NC}"
    echo ""
    echo -e "${GREEN}💡 Quick test: ${NC}curl http://localhost:1234/v1/models"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ LM Studio server is running!${NC}"

# Get model info from LM Studio
MODEL_INFO=$(curl -s http://localhost:1234/v1/models 2>/dev/null || echo '{"data":[{"id":"unknown-model"}]}')
MODEL_NAME=$(echo "$MODEL_INFO" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -n "$MODEL_NAME" ] && [ "$MODEL_NAME" != "unknown-model" ]; then
    echo -e "${GREEN}📋 Loaded model: ${NC}$MODEL_NAME"
else
    echo -e "${YELLOW}⚠️  Could not detect model name (this is usually fine)${NC}"
fi

echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Shutting down MedraN services...${NC}"
    docker-compose -f docker-compose.lmstudio-simple.yml down
    echo -e "${GREEN}✅ All services stopped${NC}"
    echo -e "${BLUE}💡 LM Studio is still running - stop it manually if desired${NC}"
    exit 0
}

# Setup signal handlers
trap cleanup SIGINT SIGTERM

echo -e "${BLUE}🚀 Starting MedraN Medical Assistant...${NC}"
echo ""

# Start Docker services (API, WebUI, databases)
echo -e "${YELLOW}📦 Starting supporting services...${NC}"
docker-compose -f docker-compose.lmstudio-simple.yml up --build -d

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for services to initialize...${NC}"
sleep 10

# Check if services are healthy
echo -e "${YELLOW}🔍 Checking service health...${NC}"

# Wait for API to be ready (it connects to LM Studio)
API_READY=false
for i in {1..30}; do
    if curl -s http://localhost:3000/health >/dev/null 2>&1; then
        API_READY=true
        break
    fi
    echo -e "${YELLOW}   Waiting for API... (${i}/30)${NC}"
    sleep 2
done

if [ "$API_READY" = true ]; then
    echo -e "${GREEN}✅ All services are running!${NC}"
else
    echo -e "${RED}❌ Services may not be fully ready${NC}"
    echo -e "${YELLOW}💡 You can still try accessing the interface${NC}"
fi

echo ""
echo -e "${GREEN}🎉 MedraN Medical Assistant is now running!${NC}"
echo ""
echo -e "${BLUE}📍 Access Points:${NC}"
echo -e "   🌐 Web Interface: ${GREEN}http://localhost:3000${NC}"
echo -e "   🤖 LM Studio API: ${GREEN}http://localhost:1234${NC}"
echo -e "   📊 Service Health: ${GREEN}http://localhost:3000/health${NC}"
echo ""
echo -e "${BLUE}🍎 Apple Silicon Benefits:${NC}"
echo -e "   ⚡ ${GREEN}Native Metal GPU${NC} acceleration via LM Studio"
echo -e "   🧠 ${GREEN}Efficient memory${NC} usage (6-10GB total)"
echo -e "   🎯 ${GREEN}Direct model control${NC} in LM Studio"
echo -e "   🚀 ${GREEN}5-10x faster${NC} than containerized LLMs"
echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo -e "   • Keep this terminal open to see logs"
echo -e "   • Press Ctrl+C to stop MedraN services"
echo -e "   • Stop LM Studio manually when done"
echo -e "   • Try different models in LM Studio for variety"
echo ""
echo -e "${BLUE}🔍 Monitoring services...${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop MedraN services${NC}"
echo ""

# Follow container logs (non-blocking)
docker-compose -f docker-compose.lmstudio-simple.yml logs --follow --tail=50
