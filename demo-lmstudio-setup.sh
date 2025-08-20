#!/bin/bash

# MedraN Medical Assistant - LM Studio Setup Demo
# This script shows users exactly what they need to do

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🍎 MedraN Medical Assistant - LM Studio Setup Guide${NC}"
echo -e "${BLUE}====================================================${NC}"
echo ""

echo -e "${GREEN}This is the MUCH simpler approach for Apple Silicon users!${NC}"
echo ""

echo -e "${YELLOW}📋 Quick Setup Steps:${NC}"
echo ""

echo -e "${BLUE}1. Install LM Studio:${NC}"
echo "   • Download from: https://lmstudio.ai/"
echo "   • Or via Homebrew: brew install --cask lm-studio"
echo ""

echo -e "${BLUE}2. Download a Medical Model:${NC}"
echo "   • Open LM Studio → 'Discover' tab"
echo "   • Search for recommended models:"
echo -e "     ${GREEN}• MedraN-E4B-Uncensored-GGUF${NC} (6GB) - Medical specialist"
echo -e "     ${GREEN}• Llama-3.1-8B-Instruct${NC} (4.6GB) - Great general medical"
echo -e "     ${GREEN}• Phi-3-mini-128k${NC} (2.3GB) - Fast and efficient"
echo ""

echo -e "${BLUE}3. Start LM Studio Server:${NC}"
echo "   • Go to 'Local Server' tab"
echo "   • Load your downloaded model"
echo "   • Click 'Start Server'"
echo "   • Verify it's running at http://localhost:1234"
echo ""

echo -e "${BLUE}4. Start MedraN Assistant:${NC}"
echo "   • Run: ./start-lmstudio.sh"
echo "   • Access at: http://localhost:3000"
echo ""

echo -e "${GREEN}🚀 Benefits of this approach:${NC}"
echo -e "   ⚡ ${GREEN}5-10x faster${NC} than containerized LLMs"
echo -e "   🧠 ${GREEN}50% less memory${NC} usage (6-8GB vs 12-16GB)"
echo -e "   🎯 ${GREEN}Direct model control${NC} - switch models anytime"
echo -e "   🍎 ${GREEN}Native Metal GPU${NC} acceleration"
echo -e "   🔧 ${GREEN}Super simple setup${NC} - no complex configurations"
echo ""

echo -e "${YELLOW}💡 Why LM Studio beats Docker containers on macOS:${NC}"
echo ""
echo -e "${RED}Docker Problems:${NC}"
echo "   • Limited GPU access (CPU-only inference)"
echo "   • High memory overhead (Docker Desktop + containers)"
echo "   • Complex multi-container setup"
echo "   • Slower model loading and inference"
echo ""
echo -e "${GREEN}LM Studio Benefits:${NC}"
echo "   • Direct Apple Metal GPU acceleration"
echo "   • Native macOS optimization"
echo "   • Simple GUI model management"
echo "   • Instant model switching"
echo "   • Built specifically for Apple Silicon"
echo ""

echo -e "${BLUE}🧠 Memory Usage Comparison:${NC}"
echo ""
echo "| Setup              | Memory Usage | Performance |"
echo "|--------------------|--------------|-----------  |"
echo "| LM Studio (This)   | 6-8GB        | ⚡⚡⚡⚡⚡     |"
echo "| Docker Containers  | 12-16GB      | ⚡⚡         |"
echo ""

echo -e "${YELLOW}Ready to get started?${NC}"
echo -e "${GREEN}1. Install LM Studio${NC}"
echo -e "${GREEN}2. Download a medical model${NC}"
echo -e "${GREEN}3. Start the server${NC}"
echo -e "${GREEN}4. Run: ./start-lmstudio.sh${NC}"
echo ""
echo -e "${BLUE}Experience medical AI at Apple Silicon speeds! 🚀${NC}"
