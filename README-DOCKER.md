# 🏥 MedraN Medical AI Assistant - Smart Docker Setup

This project features an intelligent Docker Compose setup that automatically detects your platform and configures GPU acceleration when available.

## 🎯 Quick Start

### Option 1: Smart Launcher (Recommended)
```bash
# Start all services with automatic platform/GPU detection
./docker-start.sh up -d

# View logs
./docker-start.sh logs

# Stop services
./docker-start.sh down
```

### Option 2: Use Helper Commands
```bash
# Load helper commands (optional)
source ./docker-commands.sh

# Use aliases
docker-up      # Start services
docker-status  # Show status
docker-logs    # View logs
docker-down    # Stop services
```

## 🖥️ Platform Support

### 🐧 Linux with NVIDIA GPU
- **Auto-detected**: NVIDIA GPU + Docker runtime support
- **Features**: Full CUDA acceleration for AI models
- **Config**: Automatically uses `docker-compose.gpu.yml`
- **Requirements**: `nvidia-container-toolkit` installed

### 🍎 macOS (Apple Silicon)
- **Auto-detected**: Apple Silicon (ARM64) architecture
- **Features**: Optimized for Apple Silicon, CPU-only processing
- **Config**: Uses `docker-compose.mps.yml` with MPS environment variables
- **Note**: Docker Desktop doesn't support GPU access on macOS

### 🪟 Windows
- **Status**: Basic support (CPU-only)
- **Future**: Windows GPU detection planned

## 📋 Available Services

All services are accessible through the reverse proxy at **http://localhost:3000**:

| Service | Internal Port | External Access | Description |
|---------|---------------|-----------------|-------------|
| **Web UI** | 80 | http://localhost:3000/ | Modern AI Assistant interface |
| **API** | 8080 | http://localhost:3000/api/ | RESTful API endpoints |
| **MinIO Console** | 9001 | http://localhost:3000/minio-console/ | Object storage management |
| **ChromaDB** | 8000 | Internal only | Vector database |
| **Redis** | 6379 | Internal only | Caching & session storage |

## 🧠 AI Models & Features

### Current Models
- **Chat**: Google Gemma (via LM Studio on host)
- **Embeddings**: BAAI/bge-m3
- **Image**: sentence-transformers/clip-ViT-B-32
- **OCR**: microsoft/trocr-base-printed
- **Speech**: Whisper small.en

### Features
- ✅ **Modern UI**: Glassmorphism design with dark mode
- ✅ **File Upload**: Drag-and-drop support
- ✅ **Multi-modal**: Text, images, documents, audio
- ✅ **Vector Search**: ChromaDB integration
- ✅ **Smart Caching**: Redis-based optimization
- ✅ **Platform Detection**: Auto GPU/CPU configuration

## 🔧 Configuration Files

### Core Docker Files
```
docker-compose.yml     # Base configuration
docker-compose.gpu.yml # NVIDIA GPU overrides (Linux)
docker-compose.mps.yml # Apple Silicon optimizations (macOS)
```

### Smart Launcher
```
docker-start.sh        # Main platform detection script
docker-commands.sh     # Helper aliases (optional)
```

## 🚨 Troubleshooting

### GPU Not Detected on Linux
```bash
# Install NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://nvidia.github.io/libnvidia-container/stable/deb/$(. /etc/os-release; echo $ID$VERSION_ID) /" | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update && sudo apt install -y nvidia-container-toolkit
sudo docker daemon reload
```

### Service Won't Start
```bash
# Check service status
./docker-start.sh ps

# View specific service logs
./docker-start.sh logs api
./docker-start.sh logs webui

# Rebuild if needed
./docker-start.sh build --no-cache
./docker-start.sh up -d
```

### API Connection Issues
```bash
# Test API directly
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"query": "Hello!"}'

# Check if LM Studio is running on host
curl http://localhost:1234/v1/models
```

## 📖 API Reference

### Chat Endpoint
```bash
POST http://localhost:3000/api/chat
Content-Type: application/json

{
  "query": "Your message here"
}
```

### Response
```json
{
  "answer": "AI response",
  "citations": [],
  "images": []
}
```

## 🏗️ Development

### Building Images
```bash
# Build all services
./docker-start.sh build

# Build specific service
./docker-start.sh build api

# Force rebuild (no cache)
./docker-start.sh build --no-cache
```

### Environment Variables
Key configuration is handled automatically, but you can override:

```bash
# In docker-compose.yml or environment
OPENAI_BASE_URL=http://host.docker.internal:1234/v1
CHROMA_URL=http://chroma:8000
REDIS_URL=redis://redis:6379/0
```

## 🔄 Updates & Maintenance

### Regular Updates
```bash
# Pull latest images
./docker-start.sh pull

# Rebuild and restart
./docker-start.sh build --no-cache
./docker-start.sh up -d
```

### Clean Up
```bash
# Stop and remove containers
./docker-start.sh down

# Remove volumes (WARNING: deletes data)
./docker-start.sh down -v

# Clean up Docker system
docker system prune -af
```

## 🎉 Success!

If you see this after running `./docker-start.sh up -d`:

```
🔍 Detecting platform and GPU configuration...
Platform: Darwin arm64
🍎 macOS detected
🔧 Apple Silicon (arm64) detected
📁 Using compose files:
  - docker-compose.yml
  - docker-compose.mps.yml
🚀 Starting services...
✔ All services running
```

**Your AI assistant is ready at: http://localhost:3000**

---

## 📞 Support

For issues or questions:
1. Check service logs: `./docker-start.sh logs`
2. Verify all containers are running: `./docker-start.sh ps`
3. Test API connectivity: `curl http://localhost:3000/api/chat`

The smart launcher handles platform detection automatically - just run `./docker-start.sh up -d` and you're ready to go!
