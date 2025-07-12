# Traccar Docker Deployment

🚀 **Complete GPS tracking system with one-click deployment for both local development and ## 🔧 Management Commands

### Local Development
```bash
docker compose up -d              # Start services
docker compose ps                 # View status  
docker compose logs -f            # View logs
docker compose restart            # Restart
docker compose down               # Stop
```

### Development Mode
```bash
# Start development environment
./start-dev.sh

# Stop development environment  
./stop-dev.sh

# View development logs
docker compose -f docker-compose.dev.yml logs -f
```# 🚀 Quick Start

### One-Click VPS Production Setup
```bash
# Download and run setup script
./setup.sh
```

### Local Development
```bash
git clone https://github.com/miguelcarrascoq/traccar-docker.git
cd traccar-docker
./start-local.sh
```

### Troubleshooting & Fixing Common Issues
```bash
# Check system status and container health
./check-status.sh
```

**The setup script automatically:**
- Downloads repository if needed
- Handles Docker installation  
- Configures environment variables
- Supports private repositories
- Works with both `docker compose` and `docker-compose`

---

## 🌐 Access Your System

| Environment | Frontend | Backend API | Database Admin | Default Login |
|------------|----------|-------------|----------------|---------------|
| **Local** | `http://localhost:3000` | `http://localhost:8082` | `http://localhost:8080` | admin / admin |
| **Development** | `http://localhost:3000` | `http://localhost:8082` | `http://localhost:8080` | admin / admin |

**📱 GPS Device Setup:** Use your domain or localhost with port `5055`

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

## 🛡️ Security Features
✅ Container isolation  
✅ Network security  
✅ Volume encryption support  
✅ Environment variable protection  

---

## �️ MySQL Volume Management Tools

**Unified Volume**: Both development and local modes now use the same MySQL volume (`traccar-docker_mysql_data`), allowing you to switch between modes without losing data.

### Quick Commands
```bash
# View volume information
./mysql-volume-manager.sh info

# Create backup
./mysql-volume-manager.sh backup

# Restore from backup
./mysql-volume-manager.sh restore backup_file.tar.gz

# Show all available commands
./mysql-volume-manager.sh help
```

**📖 Complete Documentation:**
- **[MySQL Volume Guide](MYSQL-VOLUME-GUIDE.md)** - Detailed guide with examples
- **[Tools Reference](TOOLS-REFERENCE.md)** - Quick command reference

### Benefits of Unified Volume
- ✅ **Switch modes seamlessly**: Development ↔ Local without data loss
- ✅ **Easy backups**: Create and restore complete database backups  
- ✅ **Data persistence**: All configurations, users, and devices preserved
- ✅ **Safe migrations**: Copy data between environments

---

## �🔧 Management Commands

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

**Database Connection:** Ensure MySQL container is healthy: `docker compose ps`  
**Build Failures:** Verify private repository credentials in `.env`  
**Container Issues:** Check container logs: `docker compose logs [service-name]`  

**Need Help?** Check logs first: `docker compose logs [service-name]`  
**Detailed Troubleshooting:** See `TROUBLESHOOTING.md` for comprehensive solutions

---

## 📊 System Requirements

| Component | Local/Development | 
|-----------|-------------------|
| **RAM** | 1GB (2GB recommended) |
| **Storage** | 5GB (10GB recommended) |
| **CPU** | 1 core (2+ recommended) |
| **OS** | Any with Docker |

---

**📖 Documentation:** [Traccar Official Docs](https://www.traccar.org/documentation/)  
**🔒 Private Repos:** See `PRIVATE-REPO-SETUP.md`  
**🐛 Issues:** Check logs first, then create an issue in this repository