# Changelog

## [v2.1.0] - 2025-08-18 - 🚀 Major Bug Fixes & GPU Support

### 🚑 Critical Fixes
- **CLIP Model**: Fixed `'CLIPConfig' object has no attribute 'hidden_size'` error by updating image embedding model to `sentence-transformers/clip-ViT-B-32`
- **LLM Connection**: Fixed `httpx.ConnectError` with robust error handling and user-friendly messages
- **File Upload**: Increased reverse proxy file upload limit to **500MB** (`client_max_body_size`)
- **Timeouts**: Increased proxy timeouts to **300 seconds** for large documents and slow models

### 🎉 New Features & Performance
- **🚀 Automatic GPU Acceleration**: System now **auto-detects and uses GPUs** when available
  - CUDA GPUs (NVIDIA cards)
  - Apple Silicon MPS (M1/M2/M3 Macs)
  - CPU fallback when no GPU available
- **⚡ Faster Processing**: Document ingestion and embeddings are significantly faster on GPU systems
- **🧠 Smart Device Selection**: Models automatically use the best available compute device

### 🔧 Enhanced Error Handling & Logging
- **Connection Errors**: Clear error messages when LM Studio is not accessible
- **Image Processing**: Ingest continues even if image embedding fails
- **Better Logging**: Added detailed logging with status emojis for easier debugging
- **API Responses**: Proper HTTP 500 responses with detailed error information

### 📖 Documentation Updates
- **Troubleshooting Guide**: Comprehensive guide for common issues
- **GPU Support**: Documented automatic GPU detection and acceleration
- **Error Solutions**: Solutions for `httpx.ConnectError`, CLIP errors, and upload issues

### 🎯 User Experience Improvements
- **Large File Support**: Upload documents up to 500MB
- **More Reliable**: Robust error handling prevents system crashes
- **Faster on GPU**: Automatic GPU acceleration for better performance
- **Better Feedback**: Clear error messages help users resolve issues quickly

## [v2.0.0] - 2025-08-17 - 🚀 Reverse Proxy Architecture

### 🎉 Major Features
- **Added Nginx Reverse Proxy**: Single entry point on port 3000 for all services
- **Unified Access**: Web UI, API, and optional services all accessible via one port
- **Better Remote Access**: No more CORS issues, works from any IP address

### ✅ Improvements
- **Simplified Deployment**: Users only need to access `http://localhost:3000`
- **Enhanced Security**: All internal services are now isolated
- **Better User Experience**: Single port eliminates confusion

### 🔧 Technical Changes
- **ChromaDB**: Downgraded to v0.4.15 for compatibility with API
- **Environment Variables**: Added missing `OCR_MODEL` configuration
- **Model Configuration**: Updated with proper model identifiers
- **WebUI**: Now uses relative API paths for better portability

### 🚑 Bug Fixes
- Fixed ChromaDB connection errors (tenant compatibility issues)
- Resolved embedding model loading failures
- Fixed CORS issues for remote access

### 📖 Documentation Updates
- Updated README with new architecture diagrams
- Added single-port access examples
- Updated API endpoint documentation
- Improved troubleshooting guides

### 🛠️ Breaking Changes
- **Port Access**: Main access is now port 3000 instead of 3000/8080 split
- **API URLs**: API now accessible at `/api/*` instead of direct port 8080
- **Internal Services**: ChromaDB, Redis, MinIO no longer directly accessible

### 📋 Migration Guide
For existing users:
1. Update your bookmarks to use port 3000
2. Update API calls to use `/api/` prefix
3. Run `docker compose down && docker compose up -d --build`

### 🎯 New Access Points
- **Web UI**: `http://localhost:3000/`
- **API**: `http://localhost:3000/api/...`
- **Health Check**: `http://localhost:3000/health`
- **MinIO Console**: `http://localhost:3000/minio-console/` (optional)

---

## [v1.0.0] - Previous Release
- Initial release with multi-port architecture
- Separate ports for Web UI (3000) and API (8080)
- Basic Docker Compose setup
