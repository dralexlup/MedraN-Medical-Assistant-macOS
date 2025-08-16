# 🐳 Docker Container Sharing Guide

## 📦 How to Share Your Jarvis Docker Containers

### Method 1: Docker Hub (Public Repository)

#### Step 1: Create Docker Hub Account
1. Go to https://hub.docker.com
2. Sign up for a free account
3. Note your username (e.g., `yourusername`)

#### Step 2: Login and Tag Images
```bash
# Login to Docker Hub
docker login

# Tag your images
docker tag jarvis-plus-local-api yourusername/jarvis-api:latest
docker tag jarvis-plus-local-webui yourusername/jarvis-webui:latest

# Push to Docker Hub
docker push yourusername/jarvis-api:latest
docker push yourusername/jarvis-webui:latest
```

#### Step 3: Create Shareable Docker Compose
```yaml
# docker-compose.public.yml
version: "3.9"
services:
  api:
    image: yourusername/jarvis-api:latest
    environment:
      OPENAI_BASE_URL: "http://host.docker.internal:1234/v1"
      OPENAI_API_KEY: "none"
      OPENAI_CHAT_MODEL: "google/gemma-3n-e4b"
      CHROMA_URL: "http://chroma:8000"
      REDIS_URL: "redis://redis:6379/0"
      MINIO_ENDPOINT: "http://minio:9000"
      MINIO_ACCESS_KEY: "minio"
      MINIO_SECRET_KEY: "minio12345"
      MINIO_BUCKET: "jarvisdocs"
      EMBEDDING_MODEL: "all-MiniLM-L6-v2"
      IMAGE_EMBEDDING_MODEL: "clip-ViT-B-32"
      MAX_CONTEXT_CHARS: "120000"
    volumes: [ "api_cache:/root/.cache" ]
    ports: [ "8080:8080" ]
    depends_on: [ chroma, redis, minio ]
    restart: unless-stopped

  webui:
    image: yourusername/jarvis-webui:latest
    ports: [ "3000:80" ]
    depends_on: [ api ]
    restart: unless-stopped

  chroma:
    image: chromadb/chroma:0.4.15
    environment:
      CHROMA_SERVER_HOST: 0.0.0.0
      CHROMA_SERVER_HTTP_PORT: 8000
      ALLOW_RESET: "TRUE"
    volumes: [ "chroma_data:/chroma" ]
    ports: [ "8001:8000" ]
    restart: unless-stopped

  redis:
    image: redis:7
    ports: [ "6379:6379" ]
    restart: unless-stopped

  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minio
      MINIO_ROOT_PASSWORD: minio12345
    volumes: [ "minio_data:/data" ]
    ports: [ "9000:9000", "9001:9001" ]
    restart: unless-stopped

volumes:
  chroma_data:
  minio_data:
  api_cache:
```

### Method 2: Export/Import Docker Images (File Sharing)

#### Export Your Images
```bash
# Export all your custom images to files
docker save jarvis-plus-local-api:latest | gzip > jarvis-api.tar.gz
docker save jarvis-plus-local-webui:latest | gzip > jarvis-webui.tar.gz

# Create a complete package
tar -czf jarvis-complete.tar.gz \
  jarvis-api.tar.gz \
  jarvis-webui.tar.gz \
  docker-compose.yml \
  README.md
```

#### Instructions for Recipients
```bash
# Extract and load images
tar -xzf jarvis-complete.tar.gz
docker load < jarvis-api.tar.gz
docker load < jarvis-webui.tar.gz

# Start the services
docker-compose up -d
```

### Method 3: GitHub + Docker Hub Automation

#### Step 1: Push Code to GitHub
```bash
git init
git add .
git commit -m "Initial Jarvis AI Assistant"
git branch -M main
git remote add origin https://github.com/yourusername/jarvis-plus-local.git
git push -u origin main
```

#### Step 2: Add GitHub Actions for Auto-Build
Create `.github/workflows/docker-build.yml`:
```yaml
name: Build and Push Docker Images

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Login to DockerHub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
    
    - name: Build and push API
      uses: docker/build-push-action@v4
      with:
        context: ./api
        push: true
        tags: yourusername/jarvis-api:latest
    
    - name: Build and push WebUI
      uses: docker/build-push-action@v4
      with:
        context: ./simple-ui
        push: true
        tags: yourusername/jarvis-webui:latest
```

### Method 4: Private Docker Registry

#### Using a Private Registry
```bash
# Run a local registry
docker run -d -p 5000:5000 --name registry registry:2

# Tag and push to private registry
docker tag jarvis-plus-local-api localhost:5000/jarvis-api
docker tag jarvis-plus-local-webui localhost:5000/jarvis-webui
docker push localhost:5000/jarvis-api
docker push localhost:5000/jarvis-webui
```

## 🚀 Easy One-Click Deployment Options

### Option 1: Railway
```bash
# Create railway.toml
[build]
builder = "DOCKER"

[deploy]
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10
```

### Option 2: Heroku with Docker
```bash
# Create heroku.yml
build:
  docker:
    web: simple-ui/Dockerfile
    api: api/Dockerfile
```

### Option 3: DigitalOcean App Platform
```yaml
# .do/app.yaml
name: jarvis-ai
services:
- name: api
  source_dir: api
  dockerfile_path: Dockerfile
  instance_count: 1
  instance_size_slug: basic-xxs
  
- name: webui
  source_dir: simple-ui
  dockerfile_path: Dockerfile
  instance_count: 1
  instance_size_slug: basic-xxs
```

## 📋 Complete Sharing Package

### Create a README for Recipients
```markdown
# 🤖 Jarvis AI Assistant

## Quick Start

1. **Install Docker**: https://docs.docker.com/get-docker/
2. **Download**: `git clone https://github.com/yourusername/jarvis-plus-local.git`
3. **Run**: `cd jarvis-plus-local && docker-compose up -d`
4. **Access**: http://localhost:3000

## Requirements
- Docker & Docker Compose
- 4GB RAM minimum
- 10GB disk space
- LM Studio (optional, for local LLM)

## Features
✅ Chat interface with memory
✅ Voice transcription 
✅ PDF document ingestion
✅ RAG (Retrieval Augmented Generation)
✅ Web-based UI
```

## 🔧 Environment Configuration

### Create .env.example
```env
# Copy to .env and customize
OPENAI_BASE_URL=http://localhost:1234/v1
OPENAI_CHAT_MODEL=google/gemma-3n-e4b
MINIO_SECRET_KEY=your-secure-password-here
```

## 📊 Resource Requirements

### Minimum System Requirements
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 10GB
- **Network**: Internet connection for model downloads

### Recommended for Production
- **CPU**: 4+ cores  
- **RAM**: 8GB+
- **Storage**: 50GB+ SSD
- **Network**: Stable broadband

## 🚨 Security Notes

When sharing publicly:
1. Change default passwords
2. Add authentication
3. Use environment variables for secrets
4. Enable HTTPS
5. Configure firewalls
6. Monitor resource usage

## 🧪 Testing Your Shared Version

Before sharing, test on a clean machine:
```bash
# Test the complete deployment
git clone YOUR_REPO_URL
cd jarvis-plus-local
docker-compose up -d

# Verify all services
curl http://localhost:8080/healthz
curl http://localhost:3000

# Test functionality
# Upload PDF, chat, voice transcription
```
