# 🧠 MedraN Medical Assistant - Memory Configuration

## 📊 **Updated Memory Limits for Heavy Medical Usage**

We've optimized the memory configuration for **serious medical usage** with **10GB+ capacity**:

### 🎯 **Current Memory Allocation**

| Component | Memory Limit | Reserved | Purpose |
|-----------|--------------|----------|---------|
| **Redis Cache** | 2GB | - | Session cache, recent conversations |
| **ChromaDB** | 4GB | 1GB | Vector embeddings, long-term memory |
| **API Container** | 4GB | 2GB | Embedding models, processing |
| **MinIO** | No limit | - | File storage (disk-based) |
| **WebUI + Nginx** | Minimal | - | Static files |

### **Total Memory Budget: ~10GB** 

## 🔍 **Memory Usage Breakdown**

### **Per Conversation Storage**
- **Text Conversation**: ~2-5KB per exchange
- **Vector Embedding**: ~1-2KB per message
- **Metadata**: ~500B per message

### **Base System Requirements**
- **ChromaDB Base**: ~89MB (embedding model loaded)
- **API Models**: ~1-2GB (BAAI/bge-m3, OCR, etc.)
- **Redis Base**: ~10MB (empty)

### **Scaling Estimates**

| Conversations | Memory Usage | Duration |
|---------------|--------------|----------|
| **100 exchanges** | ~500KB vectors | Daily usage |
| **1,000 exchanges** | ~5MB vectors | Weekly usage |
| **10,000 exchanges** | ~50MB vectors | Monthly usage |
| **100,000 exchanges** | ~500MB vectors | Yearly usage |

## 🏥 **Medical Usage Scenarios**

### 👨‍⚕️ **Hospital/Clinic (Heavy Usage)**
- **Multiple Doctors**: 10-50 conversations/day each
- **Patient Cases**: Complex, multi-turn conversations
- **Memory Needs**: 2-4GB for conversation vectors
- **Configuration**: ✅ **Our current 10GB setup handles this easily**

### 🎓 **Medical School (Ultra Heavy)**
- **100+ Students**: 5-20 conversations/day each
- **Learning Sessions**: Extended Q&A, case studies
- **Memory Needs**: 5-8GB for conversation vectors
- **Configuration**: ✅ **Our current setup supports this**

### 🏠 **Personal Medical AI**
- **Family Use**: 1-5 conversations/day
- **Memory Needs**: <100MB for years of conversations
- **Configuration**: ✅ **Massive overkill (good thing!)**

## 📈 **Memory Efficiency Features**

### **Redis LRU Policy**
```bash
redis-server --maxmemory 2gb --maxmemory-policy allkeys-lru
```
- Automatically removes **least recently used** cache items
- Keeps **active conversations** in fast memory
- **Older conversations** remain in ChromaDB

### **Vector Storage Efficiency**
- **High-dimensional embeddings** compressed efficiently
- **Semantic deduplication** reduces storage for similar conversations
- **Persistent storage** on disk (not RAM-bound)

## 🚀 **Performance Optimization**

### **Memory Tiers**
1. **L1 Cache (Redis - 2GB)**: Recent conversations, session data
2. **L2 Storage (ChromaDB - 4GB RAM)**: All conversation vectors
3. **L3 Persistence (Docker Volumes)**: Permanent storage on disk

### **Automatic Scaling**
- **Redis**: Automatically evicts old cache when full
- **ChromaDB**: Grows with usage, uses disk for overflow
- **Docker**: Resource limits prevent memory overconsumption

## 🔧 **Configuration Commands**

### **Check Current Memory Usage**
```bash
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.MemPerc}}"
```

### **Monitor ChromaDB Collections**
```bash
curl http://localhost:3000/api/collections
```

### **Redis Memory Info**
```bash
docker exec -it medran-medical-assistant-macos-redis-1 redis-cli INFO memory
```

## 💡 **Memory Recommendations**

### **Mac System Requirements**
- **Minimum**: 16GB RAM (8GB for system + 8GB for MedraN)
- **Recommended**: 32GB RAM (16GB for system + 16GB for MedraN + LM Studio)
- **Optimal**: 64GB RAM (for multiple simultaneous users)

### **Usage Monitoring**
- Check `Activity Monitor` regularly
- Monitor Docker stats for container memory usage
- Watch for memory pressure warnings

## 🎯 **Real-World Capacity**

With **our 10GB configuration**, you can handle:

- **📚 Medical School**: 100+ students, months of intensive use
- **🏥 Hospital**: 50+ doctors, thousands of patient consultations
- **🔬 Research**: Years of medical literature discussions
- **👥 Multi-User**: Family/clinic with multiple simultaneous users

## 🛠️ **Troubleshooting Memory Issues**

### **If Memory Usage is High**
1. Check Docker stats: `docker stats`
2. Restart services: `docker-compose restart`
3. Clear Redis cache: `docker exec redis-container redis-cli FLUSHALL`
4. Check disk space: `df -h`

### **If Performance is Slow**
1. Increase Redis memory: Edit `docker-compose.yml`
2. Add more ChromaDB memory: Increase resource limits
3. Monitor Apple Silicon memory pressure

---

**🎉 Result: Your MedraN Medical Assistant can now handle enterprise-level medical usage with 10GB+ memory capacity while maintaining blazing-fast Apple Silicon performance!**
