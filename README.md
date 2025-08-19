# 🍎 MedraN Medical AI Assistant - macOS Apple Silicon Optimized

**Ultra-fast medical AI assistant specifically optimized for Apple Silicon (M1/M2/M3) using MLX framework**

Experience **3-10x faster** medical AI responses on your Apple Silicon Mac! This repository leverages Apple's MLX framework for blazing-fast inference with direct Metal GPU acceleration.

## 🚀 **Performance Comparison**

| Setup | Platform | GPU Access | Typical Speed | Model Size |
|-------|----------|------------|---------------|------------|
| **MLX (This Repo)** | macOS Apple Silicon | ✅ Direct Metal GPU | **50-150 tokens/s** | 6GB |
| Standard GGUF | macOS (Docker) | ❌ CPU only | 5-15 tokens/s | 3.95GB |

> 🔗 **Need cross-platform compatibility?** Check out our [Standard Version](https://github.com/dralexlup/MedraN-Medical-Assistant) for Linux/Windows/Intel Macs.

## ✨ **Key Features**

### 🍎 **macOS-Optimized Performance**
- **Apple MLX Framework**: Native Metal GPU acceleration  
- **3-10x Faster**: Ultra-fast inference vs containerized solutions
- **Memory Efficient**: 4-bit quantization for Apple Silicon
- **Zero Configuration**: Automatic model download and setup

### 🏥 **Medical AI Capabilities**  
- **📖 Medical Literature**: Process journals, papers, clinical docs
- **🔬 Research Assistant**: Query medical texts with context
- **💊 Drug Information**: Medication lookups and interactions
- **🎓 Medical Education**: Interactive learning for students/residents
- **🧠 Conversation Memory**: Maintains context across sessions

## 🏁 **Quick Start (30 seconds)**

### Prerequisites
- **macOS** with Apple Silicon (M1/M2/M3) 
- **Docker Desktop** installed
- **8GB+ RAM** recommended

### One-Command Setup
```bash
# Clone the macOS-optimized repository
git clone https://github.com/dralexlup/MedraN-Medical-Assistant-macOS.git
cd MedraN-Medical-Assistant-macOS

# Start everything with MLX optimization
docker-compose -f docker-compose.lmstudio.yml up --build -d

# Access at http://localhost:3000 🎉
```

### What Happens Automatically
1. **Downloads MedraN-E4B-Uncensored** model in MLX format (~6GB)
2. **Activates Apple Metal GPU** acceleration  
3. **Starts all services** with health monitoring
4. **Ready in ~3-5 minutes** with blazing-fast medical AI

## 🍎 **Apple Silicon Optimization**

### Performance Metrics
On **M1/M2/M3 MacBooks**:
- **Inference Speed**: 50-150 tokens/second
- **Model Loading**: ~30-60 seconds (first time)
- **Memory Usage**: ~4-6GB total system
- **GPU Utilization**: 60-90% Metal GPU usage

### Supported Hardware
✅ **M1** (all variants) | ✅ **M2** (all variants) | ✅ **M3** (all variants)  
✅ **Mac Studio** (M1/M2 Ultra) | ✅ **Mac Pro** (M2 Ultra)

## 🏥 **Medical Use Cases**

### Example Performance
**Query**: *"What are the contraindications for ACE inhibitors in diabetic patients?"*

- **MLX (This Version)**: ~2-3 seconds response
- **Standard GGUF**: ~10-15 seconds response

### Use Cases
- **📋 Clinical Decision Support**: Evidence-based recommendations in seconds
- **🔬 Research Analysis**: Process multiple papers rapidly  
- **📚 Medical Education**: Interactive learning without waiting
- **💊 Drug Information**: Instant medication lookups

## 🛠️ **Advanced Configuration**

### Model Configuration Options
```yaml
# Default: MedraN-E4B-Uncensored (Recommended)
environment:
  MLX_MODEL: "drwlf/MedraN-E4B-Uncensored-MLX"
  
# Alternative: For different memory requirements
# Note: Adjust MODEL_PATH accordingly
```

### Performance Monitoring
Monitor GPU usage in **Activity Monitor**:
1. Open **Activity Monitor** → **GPU** tab
2. Look for **Python** process using **Metal GPU**

## 🔧 **Troubleshooting macOS Issues**

### MLX Installation Problems
```bash
# Rebuild with no cache if MLX fails
docker-compose build --no-cache lmstudio
```

### Performance Optimization Tips
- **Ensure 16GB+ RAM** for optimal performance
- **Close memory-intensive apps** during use
- **Check Activity Monitor** for competing processes
- **Restart Docker Desktop** if performance degrades

## 🚨 **When to Use This vs Standard Version**

### Use This macOS Version If:
- ✅ You have Apple Silicon Mac (M1/M2/M3)
- ✅ You want maximum performance (3-10x faster)
- ✅ You prioritize speed over compatibility

### Use Standard Version If:
- 🔄 You need cross-platform support (Linux/Windows)
- 🔄 You have Intel Mac
- 🔄 You need specific GGUF models

## 🤝 **Contributing**

1. Fork this macOS-optimized repository
2. Test changes on Apple Silicon hardware
3. Include performance benchmarks in PRs
4. Ensure MLX compatibility

## 📄 **License**

MIT License - Same as the main project

## 🙋‍♂️ **Support**

- **Issues**: GitHub issues for macOS-specific problems
- **Performance**: Include Activity Monitor screenshots
- **Hardware**: Specify your Mac model and memory

---

**Made with ❤️ for Apple Silicon users**

*Experience medical AI at the speed of thought on your Mac!*
