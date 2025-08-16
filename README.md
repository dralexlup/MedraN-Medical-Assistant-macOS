# 🏥 MedraN - Medical Assistant

A powerful, self-hosted medical AI assistant designed for healthcare professionals and medical students. Features advanced document processing with OCR preprocessing, RAG (Retrieval-Augmented Generation) for medical literature, and multi-modal search functionality tailored for medical documentation and research.

## ✨ Features

### 🏥 Medical-Specific Capabilities
- **📖 Medical Literature Processing**: Optimized for medical journals, research papers, and clinical documentation
- **🔬 Research Assistant**: Query complex medical texts and get contextual answers
- **📋 Clinical Documentation**: Process patient notes, medical reports, and diagnostic imaging reports
- **🎓 Medical Education**: Perfect for medical students and residents studying from textbooks and case studies
- **🔍 Symptom & Treatment Lookup**: Fast retrieval from medical knowledge bases

### 🤖 Core AI Features
- **🔍 Advanced OCR Processing**: Automatically enhances text extraction from medical documents, including scanned medical texts and complex layouts
- **📚 RAG (Retrieval-Augmented Generation)**: Upload medical documents and get contextual, citation-backed answers
- **🧠 Conversation Memory**: Maintains context across medical consultations and study sessions
- **🎙️ Voice Transcription**: Speech-to-text for medical dictation and note-taking
- **🖼️ Multi-modal Search**: Text and image retrieval from medical documents and imaging reports
- **🌐 Web Interface**: Clean, responsive UI designed for healthcare professionals
- **🐳 Docker-First**: Fully containerized for easy deployment in medical environments
- **🏗️ Multi-Architecture**: Builds natively on both AMD64 and ARM64 systems
- **🔧 Self-Hosted**: Complete control over sensitive medical data - fully HIPAA-compliant when properly configured

## 🚀 Quick Start

### Prerequisites

- **Docker** and **Docker Compose** installed
- **4GB+ RAM** recommended for optimal performance
- **Local LLM Server** (LM Studio, Ollama, or similar) running on port 1234

### 1. Clone & Run

```bash
git clone <repository-url>
cd medran-ai-assistant

# Start all services (builds images automatically for your architecture)
docker compose up --build -d
```

### 2. Access the System

- **Web UI**: http://localhost:3000
- **API**: http://localhost:8080
- **ChromaDB**: http://localhost:8001
- **MinIO Console**: http://localhost:9001

### 3. Upload Documents

1. Open the web UI at http://localhost:3000
2. Click "Upload Document" 
3. Select a PDF file
4. Wait for processing (OCR enhancement will automatically improve text extraction)
5. Start chatting with your documents!

## 🏥 Medical Use Cases

### For Healthcare Professionals
- **📋 Clinical Decision Support**: Upload medical guidelines and get evidence-based recommendations
- **🔬 Research Literature Review**: Process multiple research papers and extract key findings
- **📊 Case Study Analysis**: Upload patient cases and get diagnostic insights
- **💊 Drug Information**: Query pharmaceutical references for dosing, interactions, and contraindications

### For Medical Students & Residents
- **📚 Textbook Study Assistant**: Upload medical textbooks and get interactive Q&A
- **🎯 Exam Preparation**: Practice with case-based questions from your study materials
- **🧠 Concept Clarification**: Get detailed explanations of complex medical concepts
- **📖 Literature Review**: Quickly extract relevant information from research papers

### Example Medical Queries
```
"What are the contraindications for this medication?"
"Summarize the key findings from this clinical trial"
"What are the differential diagnoses for these symptoms?"
"Explain the pathophysiology of this condition"
"What are the current treatment guidelines for this disease?"
```

## 🛠️ Configuration

### Environment Variables

The system uses these key environment variables (configurable in `docker-compose.yml`):

```yaml
# LLM Configuration
OPENAI_BASE_URL: "http://host.docker.internal:1234/v1"  # Your local LLM server
OPENAI_CHAT_MODEL: "your-model-name"                     # Model name from your LLM server

# Model Configuration  
EMBEDDING_MODEL: "bge-m3"                                # Text embedding model
IMAGE_EMBEDDING_MODEL: "clip-ViT-L-14"                  # Image embedding model
OCR_MODEL: "microsoft/trocr-base-printed"               # OCR model for text extraction

# Storage
MINIO_BUCKET: "medrandocs"                              # Document storage bucket
MAX_CONTEXT_CHARS: "120000"                            # Maximum context window
```

### Supported LLM Servers

- **LM Studio**: Default configuration (port 1234)
- **Ollama**: Change `OPENAI_BASE_URL` to `http://host.docker.internal:11434/v1`
- **OpenAI Compatible APIs**: Any OpenAI-compatible endpoint

## 📋 API Endpoints

### Core Functionality

- `GET /healthz` - Health check
- `POST /ingest` - Upload and process documents (with OCR enhancement)
- `POST /chat` - Chat with your knowledge base
- `POST /transcribe` - Voice-to-text transcription

### Example Usage

```bash
# Upload a document
curl -X POST "http://localhost:8080/ingest" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@document.pdf" \
  -F "title=My Document"

# Chat with the document
curl -X POST "http://localhost:8080/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What are the main topics covered?",
    "user_id": "user123",
    "k": 6,
    "return_images": true,
    "remember": true
  }'
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web UI        │    │   FastAPI        │    │   LLM Server    │
│   (Port 3000)   │◄──►│   (Port 8080)    │◄──►│   (Port 1234)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                    ┌───────────┼───────────┐
                    │           │           │
            ┌───────▼────┐ ┌────▼────┐ ┌───▼──────┐
            │  ChromaDB  │ │  Redis  │ │  MinIO   │
            │ (Vectors)  │ │(Memory) │ │(Storage) │
            └────────────┘ └─────────┘ └──────────┘
```

## 🔧 Advanced Configuration

### Custom Models

You can customize the models by editing `docker-compose.yml`:

```yaml
environment:
  EMBEDDING_MODEL: "your-preferred-embedding-model"
  OCR_MODEL: "your-preferred-ocr-model"
  IMAGE_EMBEDDING_MODEL: "your-preferred-image-model"
```

### Resource Requirements

- **Minimal**: 2GB RAM, 2 CPU cores
- **Recommended**: 4GB RAM, 4 CPU cores
- **Production**: 8GB+ RAM, 8+ CPU cores

### GPU Support

To enable GPU acceleration, add to your `docker-compose.yml`:

```yaml
api:
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: 1
            capabilities: [gpu]
```

## 🐛 Troubleshooting

### Common Issues

1. **"Connection refused" errors**
   - Ensure your LLM server is running on port 1234
   - Check `host.docker.internal` resolves (Linux users may need to use host IP)

2. **Out of memory during model loading**
   - Increase Docker memory limits
   - Use smaller models (e.g., `all-MiniLM-L6-v2` for embeddings)

3. **Slow document processing**
   - OCR processing is CPU-intensive, consider reducing OCR usage or using GPU acceleration
   - Check container resource limits

### Logs

```bash
# View all service logs
docker compose logs -f

# View specific service logs  
docker compose logs -f api
docker compose logs -f chroma
```

## 📊 Performance

### OCR Enhancement

The system automatically uses OCR when it detects that it can significantly improve text extraction:

- **Smart Enhancement**: Only uses OCR when beneficial (20%+ text improvement)
- **Fallback**: Works without OCR if models fail to load
- **Logging**: Monitor OCR usage via API logs

### Benchmarks

On a modern system (M1 MacBook Pro):
- **Document Ingestion**: ~2-3 pages/second with OCR
- **Query Response**: ~500ms average
- **Memory Usage**: ~1.5GB per service

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `docker compose up --build`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

- **Issues**: Create an issue on GitHub
- **Documentation**: Check `DEPLOYMENT.md` for advanced deployment options
- **Community**: Join discussions in GitHub Discussions

## 🎯 Roadmap

- [ ] Web UI improvements and dark mode
- [ ] Support for more document formats (DOCX, TXT, etc.)
- [ ] Advanced OCR models (table extraction, formula recognition)
- [ ] Multi-language support
- [ ] Plugin system for custom tools
- [ ] Cloud deployment templates (AWS, GCP, Azure)

---

**Made with ❤️ for the open-source community**

*Self-hosted AI that respects your privacy and gives you full control over your data.*
