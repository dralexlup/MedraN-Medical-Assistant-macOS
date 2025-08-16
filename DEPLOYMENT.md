# 🚀 Jarvis AI Assistant - Deployment Guide

## 🌐 Making Your Jarvis System Publicly Available

### Option 1: Quick Tunnel (Temporary - Great for Testing)

#### Using ngrok (Recommended)
```bash
# Install ngrok
brew install ngrok

# Start ngrok tunnel
ngrok http 3000

# Your Jarvis will be available at: https://abc123.ngrok.io
```

#### Using Cloudflare Tunnel
```bash
# Install cloudflared
brew install cloudflared

# Create tunnel
cloudflared tunnel --url http://localhost:3000
```

### Option 2: Cloud Deployment (Permanent)

#### A. Railway (Easiest - Recommended)
1. Push your code to GitHub
2. Visit https://railway.app and sign in
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your `jarvis-plus-local` repository
5. Railway auto-detects Docker and deploys
6. Set environment variables in Railway dashboard:
   - `OPENAI_BASE_URL`: Your LM Studio server URL
   - `OPENAI_CHAT_MODEL`: google/gemma-3n-e4b
   - `MINIO_PASSWORD`: (secure password)

#### B. DigitalOcean App Platform
1. Create account at https://cloud.digitalocean.com
2. Create new App from GitHub repo
3. Configure as Docker container app
4. Set environment variables
5. Deploy

#### C. AWS ECS (Advanced)
1. Create ECS cluster
2. Build and push images to ECR
3. Create task definitions
4. Configure load balancer
5. Set up CloudFront distribution

### Option 3: Self-Hosted Server (Full Control)

#### Server Setup (Ubuntu 22.04)
```bash
# 1. Initial server setup
sudo apt update && sudo apt upgrade -y
sudo apt install docker.io docker-compose nginx certbot python3-certbot-nginx -y

# 2. Clone repository
git clone https://github.com/yourusername/jarvis-plus-local.git
cd jarvis-plus-local

# 3. Configure domain
sudo nano /etc/nginx/sites-available/jarvis
```

#### Nginx Configuration
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### SSL Setup
```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/jarvis /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com

# Start services
sudo docker-compose up -d
```

### Option 4: Production Deployment

#### Environment Variables
Create `.env` file:
```env
# API Configuration
OPENAI_BASE_URL=https://your-lm-studio-server.com/v1
OPENAI_CHAT_MODEL=google/gemma-3n-e4b

# Security
MINIO_PASSWORD=your-secure-password-here

# Optional: Authentication
AUTH_USERNAME=admin
AUTH_PASSWORD=your-auth-password
```

#### Production Compose
```bash
# Use production configuration
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

## 🔒 Security Considerations

### For Public Deployment:
1. **Change default passwords**
2. **Enable authentication** (add login to Streamlit)
3. **Use HTTPS** (SSL certificates)
4. **Firewall configuration**
5. **Rate limiting** (nginx)
6. **Monitor resources** (CPU, memory, disk)

### Authentication Setup (Optional)
```python
# Add to streamlit app.py
import streamlit_authenticator as stauth

# Simple password protection
if not st.session_state.get('authenticated'):
    password = st.text_input("Enter password:", type="password")
    if password == "your-secure-password":
        st.session_state.authenticated = True
        st.rerun()
    else:
        st.stop()
```

## 📊 Monitoring & Maintenance

### Health Checks
```bash
# API health
curl -f http://localhost:8080/healthz

# Web UI health
curl -f http://localhost:3000

# Container status
docker-compose ps
```

### Backup
```bash
# Backup data
docker run --rm -v jarvis-plus-local_chroma_data:/data -v $(pwd):/backup alpine tar czf /backup/chroma_backup.tar.gz -C /data .
docker run --rm -v jarvis-plus-local_minio_data:/data -v $(pwd):/backup alpine tar czf /backup/minio_backup.tar.gz -C /data .
```

### Updates
```bash
# Pull latest changes
git pull origin main

# Rebuild and redeploy
docker-compose up -d --build
```

## 🚨 Troubleshooting

### Common Issues:

1. **API not responding**: Check LM Studio connection and model loading
2. **ChromaDB errors**: Clear volumes and restart: `docker-compose down -v && docker-compose up -d`
3. **Memory issues**: Increase Docker memory limits
4. **Network issues**: Check firewall and port forwarding
5. **SSL issues**: Verify domain DNS and certificate renewal

### Performance Optimization:
- Use SSD storage for Docker volumes
- Configure appropriate memory limits
- Enable Docker BuildKit for faster builds
- Use Redis for caching (already included)

## 📞 Support
For issues, check:
1. Docker container logs: `docker-compose logs service-name`
2. API health endpoint: http://localhost:8080/healthz
3. Web UI health check in sidebar
