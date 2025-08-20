#!/bin/bash

# Test script for LM Studio integration

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing LM Studio Integration${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

echo -e "${YELLOW}1. Testing LM Studio Server Connection...${NC}"
if curl -s http://localhost:1234/v1/models >/dev/null 2>&1; then
    echo -e "${GREEN}✅ LM Studio server is running!${NC}"
    
    # Get model information
    MODEL_INFO=$(curl -s http://localhost:1234/v1/models 2>/dev/null)
    echo -e "${BLUE}📋 Available models:${NC}"
    echo "$MODEL_INFO" | grep -o '"id":"[^"]*' | cut -d'"' -f4 | sed 's/^/   • /'
    
    echo ""
    echo -e "${YELLOW}2. Testing Medical AI Query...${NC}"
    
    # Test a simple medical query
    RESPONSE=$(curl -s -X POST http://localhost:1234/v1/chat/completions \
        -H "Content-Type: application/json" \
        -d '{
            "model": "local-model",
            "messages": [
                {"role": "system", "content": "You are a medical AI assistant. Provide accurate, helpful medical information."},
                {"role": "user", "content": "What is hypertension?"}
            ],
            "max_tokens": 150,
            "temperature": 0.3
        }' 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$RESPONSE" ]; then
        echo -e "${GREEN}✅ Medical AI is responding!${NC}"
        echo -e "${BLUE}Sample response:${NC}"
        echo "$RESPONSE" | grep -o '"content":"[^"]*' | cut -d'"' -f4 | sed 's/^/   /'
        echo ""
        echo -e "${GREEN}🎉 LM Studio integration is working perfectly!${NC}"
        echo -e "${GREEN}Ready to start MedraN Medical Assistant!${NC}"
        echo ""
        echo -e "${BLUE}Next step: Run ./start-lmstudio.sh${NC}"
    else
        echo -e "${RED}❌ AI query failed${NC}"
        echo -e "${YELLOW}Check that your model is loaded and responding${NC}"
    fi
    
else
    echo -e "${RED}❌ LM Studio server not responding${NC}"
    echo ""
    echo -e "${YELLOW}Please ensure:${NC}"
    echo "   1. LM Studio is open"
    echo "   2. A model is loaded in the 'Local Server' tab"
    echo "   3. Server is started (should show 'Server running')"
    echo "   4. Server is on port 1234"
    echo ""
    echo -e "${BLUE}💡 Test manually: curl http://localhost:1234/v1/models${NC}"
fi

echo ""
