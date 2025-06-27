# Traccar Docker Deployment

🚀 **Complete GPS tracking system supporting both local development and production VPS deployment**

## Quick Setup

### 🏠 Local Development
Perfect for testing and development on your local machine.

### 🌐 Production VPS
Complete deployment with SSL certificates and domain setup.

---

## 🚀 One-Click Setup

### Automated Setup Script
```bash
# Download and run the setup script
curl -fsSL https://raw.githubusercontent.com/miguelcarrascoq/traccar-docker/main/setup.sh | bash
```

**The script will ask you to choose:**
1. **Local Development** - Quick setup for localhost testing
2. **Production VPS** - Full deployment with domain and SSL

---

## 📋 Manual Setup

### 1. Clone Repository
```bash
git clone https://github.com/miguelcarrascoq/traccar-docker.git
cd traccar-docker
```

### 2. Choose Your Setup

#### 🏠 Local Development
```bash
# Option 1: Quick start (uses defaults)
./start-local.sh

# Option 2: Manual setup
cp .env.example .env
# Edit .env if needed, then:
docker compose up -d
# or: docker-compose up -d
```

#### 🌐 Production VPS
```bash
# Run interactive setup
./setup.sh
# Select option 2 for production
```

---

## 🌐 Access Your System

### Local Development
- **🎯 Frontend**: `http://localhost:3000`
- **⚙️ Backend API**: `http://localhost:8082`
- **👤 Admin Login**: `admin` / `admin`
- **📊 Database**: `http://localhost:8080` (phpMyAdmin)

### Production VPS
- **🎯 Traccar Web**: `https://your-domain.com`
- **👤 Admin Login**: `admin` / `admin` *(change immediately)*
- **📊 Database Admin**: `https://your-domain.com/phpmyadmin`

---

## 📱 GPS Device Configuration

### Local Development
- **Server**: `localhost` or your local IP
- **Port**: `5055` (and other protocol ports)

### Production
- **Server**: `your-domain.com`
- **Port**: `5055` (and other protocol ports)
- **Protocol**: HTTP/TCP as supported by your device

---

## ⚙️ Configuration

### Environment Variables
Edit `.env` file to customize:

```bash
# Deployment mode
DEPLOYMENT_MODE=local  # or 'production'

# Domain (production only)
DOMAIN=localhost
EMAIL=admin@localhost

# Database settings
MYSQL_ROOT_PASSWORD=root_password
MYSQL_PASSWORD=traccar_password

# Port configuration
FRONTEND_PORT=3000
BACKEND_PORT=8082
MYSQL_PORT=3306
PHPMYADMIN_PORT=8080
```

---

## 🛡️ Security Features (Production)

✅ **SSL/TLS encryption** (Let's Encrypt)  
✅ **Automatic certificate renewal**  
✅ **Security headers** (HSTS, CSP, etc.)  
✅ **Rate limiting** & **DDoS protection**  
✅ **Database access protection**

---

## 🔧 Management Commands

### Local Development
```bash
# View status
docker-compose ps

# View logs
docker-compose logs -f traccar-backend

# Restart services
docker-compose restart

# Stop services
docker-compose down
```

### Production
```bash
# View status
docker-compose -f docker-compose.yml -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs -f

# Restart services
docker-compose -f docker-compose.yml -f docker-compose.prod.yml restart

# Update system
git pull && docker-compose -f docker-compose.yml -f docker-compose.prod.yml pull && docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Database Backup
```bash
# Backup database
docker exec traccar-mysql mysqldump -u traccar -p traccar > backup.sql

# Restore database
docker exec -i traccar-mysql mysql -u traccar -p traccar < backup.sql
```

---

## 🆘 Troubleshooting

### SSL Certificate Issues (Production)
```bash
# Check certificate status
openssl s_client -connect your-domain.com:443 -servername your-domain.com

# Manually renew certificates
docker-compose -f docker-compose.yml -f docker-compose.prod.yml run --rm certbot renew
docker-compose -f docker-compose.yml -f docker-compose.prod.yml restart nginx
```

### Service Issues
```bash
# Check all services
docker-compose ps  # local
docker-compose -f docker-compose.yml -f docker-compose.prod.yml ps  # production

# View specific service logs
docker-compose logs traccar-backend
docker-compose logs nginx  # production only
```

### Port Conflicts (Local)
If you have port conflicts, edit `.env` file:
```bash
FRONTEND_PORT=3001
BACKEND_PORT=8083
MYSQL_PORT=3307
PHPMYADMIN_PORT=8081
```

---

## 📊 System Requirements

### Local Development
| Component | Minimum |
|-----------|---------|
| RAM | 1GB |
| Storage | 5GB |
| Docker | 20.10+ |

### Production VPS
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 2GB | 4GB+ |
| Storage | 20GB | 50GB+ |
| CPU | 1 core | 2+ cores |
| OS | Ubuntu 20.04+ | Ubuntu 22.04+ |

---

**Official Traccar Documentation:** <https://www.traccar.org/documentation/>

**Support:** For issues with this deployment, check the logs first, then create an issue in this repository.