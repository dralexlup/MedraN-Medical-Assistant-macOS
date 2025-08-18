#!/bin/bash
# MedraN Medical AI Assistant - Mobile Model Conversion Script
# Convenient wrapper for converting models to mobile formats

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/convert_model.py"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if virtual environment is activated
check_venv() {
    if [[ -z "$VIRTUAL_ENV" ]]; then
        echo -e "${YELLOW}Warning: No virtual environment detected. Make sure MLC-LLM is installed.${NC}"
    fi
}

# Help function
show_help() {
    echo -e "${BLUE}MedraN Medical AI Assistant - Mobile Model Converter${NC}"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  convert MODEL_PATH     Convert a model for mobile deployment"
    echo "  list                   List all converted models"
    echo "  cleanup               Clean up temporary files"
    echo "  help                  Show this help message"
    echo ""
    echo "Options for convert:"
    echo "  --output NAME         Output name for converted model"
    echo "  --platform PLATFORM   Target platform (android, ios, opencl, vulkan)"
    echo "  --quantization METHOD  Quantization method (q4f16_1, q4f32_1, q8f16_1, q0f16, q0f32)"
    echo ""
    echo "Examples:"
    echo "  $0 convert microsoft/DialoGPT-medium"
    echo "  $0 convert /path/to/local/model --platform android --quantization q4f16_1"
    echo "  $0 convert huggingface/model --output my-mobile-model"
    echo "  $0 list"
    echo "  $0 cleanup"
    echo ""
    echo "Supported model architectures:"
    echo "  - Llama/Llama2/CodeLlama"
    echo "  - Gemma"
    echo "  - Phi"
    echo "  - Qwen"
    echo "  - And most other transformer models"
}

# Check if MLC-LLM is available
check_mlc() {
    if ! command -v mlc_llm &> /dev/null; then
        echo -e "${RED}Error: mlc_llm command not found. Please install MLC-LLM first.${NC}"
        echo "Install with: pip install --pre -U -f https://mlc.ai/wheels mlc-llm-nightly mlc-ai-nightly"
        exit 1
    fi
}

# Main script logic
main() {
    check_venv
    check_mlc
    
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    case "$1" in
        "help" | "-h" | "--help")
            show_help
            ;;
        "convert")
            if [ -z "$2" ]; then
                echo -e "${RED}Error: Model path is required for conversion${NC}"
                echo "Usage: $0 convert MODEL_PATH [OPTIONS]"
                exit 1
            fi
            
            shift  # Remove 'convert' from arguments
            python3 "$PYTHON_SCRIPT" convert "$@"
            ;;
        "list")
            python3 "$PYTHON_SCRIPT" list
            ;;
        "cleanup")
            python3 "$PYTHON_SCRIPT" cleanup
            ;;
        *)
            echo -e "${RED}Error: Unknown command '$1'${NC}"
            echo "Use '$0 help' for usage information."
            exit 1
            ;;
    esac
}

main "$@"
