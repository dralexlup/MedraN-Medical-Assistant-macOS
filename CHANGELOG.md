# Changelog

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
