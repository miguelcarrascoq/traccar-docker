# Traccar Docker Deployment

🚀 **Complete GPS tracking system with one-click deployment for both local development and production VPS**

## 🚀 Quick Start

### One-Click VPS Production Setup
```bash
curl -fsSL https://raw.githubusercontent.com/miguelcarrascoq/traccar-docker/main/setup.sh | bash
```

### Local Development
```bash
git clone https://github.com/miguelcarrascoq/traccar-docker.git
cd traccar-docker
./start-local.sh
```

### Troubleshooting & Fixing Common Issues
```bash
# Fix Docker credential helper issues
./fix-docker-build.sh

# Reset database and fix migration issues
./fix-docker-build.sh --reset-db

# Check system status and container health
./check-status.sh
```

**The setup script automatically:**
- Downloads repository if needed
- Handles Docker installation  
- Configures SSL certificates (production)
- Supports private repositories
- Works with both `docker compose` and `docker-compose`

---

## 🌐 Access Your System

| Environment | Frontend | Backend API | Database Admin | Default Login |
|------------|----------|-------------|----------------|---------------|
| **Local** | `http://localhost:3000` | `http://localhost:8082` | `http://localhost:8080` | admin / admin |
| **Production** | `https://your-domain.com` | `https://your-domain.com/api` | `https://your-domain.com/phpmyadmin` | admin / admin |

**📱 GPS Device Setup:** Use your domain (production) or localhost (development) with port `5055`

---

## ⚙️ Configuration

### Environment Variables (`.env` file)
```bash
# Deployment
DEPLOYMENT_MODE=local  # or 'production'
DOMAIN=your-domain.com
EMAIL=your-email@domain.com

# Private Repositories (optional)
GIT_USERNAME=your-username
GIT_PASSWORD=your-token
GIT_BACKEND_REPO_URL=https://github.com/your-username/traccar-backend.git
GIT_FRONTEND_REPO_URL=https://github.com/your-username/traccar-frontend.git
GIT_BACKEND_BRANCH=feature-branch  # Optional - specific branch to use
GIT_FRONTEND_BRANCH=develop        # Optional - specific branch to use

# Database
MYSQL_ROOT_PASSWORD=secure_password
MYSQL_PASSWORD=traccar_password

# Ports (local only)
FRONTEND_PORT=3000
BACKEND_PORT=8082
MYSQL_PORT=3306
PHPMYADMIN_PORT=8080
```

### 🔒 Private Repository Support
- **Supported:** GitHub, GitLab, Bitbucket, self-hosted Git
- **Authentication:** Personal Access Tokens (recommended), SSH keys, username/password
- **Setup:** Run `./setup.sh` and select "Yes" for private repositories
- **Documentation:** See `PRIVATE-REPO-SETUP.md` for detailed configuration

---

## 🛡️ Production Features
✅ SSL/TLS encryption (Let's Encrypt)  
✅ Automatic certificate renewal  
✅ Security headers & rate limiting  
✅ DDoS protection  

---

## 🔧 Management Commands

### Local Development
```bash
docker compose up -d              # Start services
docker compose ps                 # View status  
docker compose logs -f            # View logs
docker compose restart            # Restart
docker compose down               # Stop
```

### Production
```bash
# Replace 'docker compose' with 'docker-compose' if needed
docker compose -f docker-compose.yml -f docker-compose.prod.yml [command]

# Quick update
git pull && docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

### Database Backup
```bash
# Backup
docker exec traccar-mysql mysqldump -u traccar -p traccar > backup.sql

# Restore  
docker exec -i traccar-mysql mysql -u traccar -p traccar < backup.sql
```

---

## 🆘 Troubleshooting

**Docker Auth Issues:** Run `./fix-docker-build.sh` to fix credential helper problems  
**Database Errors:** Run `./fix-docker-build.sh --reset-db` to reset the database  
**SSL Issues (Production):** Check `docker compose logs nginx` and certificate status  
**Build Failures:** Verify private repository credentials in `.env`  
**Database Connection:** Ensure MySQL container is healthy: `docker compose ps`

**Need Help?** Check logs first: `docker compose logs [service-name]`  
**Detailed Troubleshooting:** See `TROUBLESHOOTING.md` for comprehensive solutions

---

## 📊 System Requirements

| Component | Local Dev | Production VPS |
|-----------|-----------|----------------|
| **RAM** | 1GB | 2GB+ (4GB recommended) |
| **Storage** | 5GB | 20GB+ (50GB recommended) |
| **CPU** | 1 core | 1+ cores (2+ recommended) |
| **OS** | Any with Docker | Ubuntu 20.04+ |

---

**📖 Documentation:** [Traccar Official Docs](https://www.traccar.org/documentation/)  
**🔒 Private Repos:** See `PRIVATE-REPO-SETUP.md`  
**🐛 Issues:** Check logs first, then create an issue in this repository