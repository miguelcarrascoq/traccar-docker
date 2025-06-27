#!/bin/bash

# Traccar Setup Script
# Supports both local development and production VPS deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Traccar Setup Script${NC}"
echo -e "${BLUE}=======================${NC}"

# Function to prompt for user input
prompt_input() {
    local prompt="$1"
    local var_name="$2"
    local default="$3"
    
    if [ -n "$default" ]; then
        read -p "$(echo -e "${YELLOW}$prompt [$default]:${NC} ")" input
        input=${input:-$default}
    else
        read -p "$(echo -e "${YELLOW}$prompt:${NC} ")" input
        while [ -z "$input" ]; do
            echo -e "${RED}This field is required!${NC}"
            read -p "$(echo -e "${YELLOW}$prompt:${NC} ")" input
        done
    fi
    
    eval "$var_name='$input'"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check docker compose (handles both docker-compose and docker compose)
docker_compose_cmd() {
    if command_exists docker-compose; then
        echo "docker-compose"
    elif docker compose version >/dev/null 2>&1; then
        echo "docker compose"
    else
        echo ""
    fi
}

# Select deployment mode
echo -e "${GREEN}� Deployment Mode Selection${NC}"
echo "1) Local Development (localhost, no SSL)"
echo "2) Production VPS (domain with SSL)"
echo ""
prompt_input "Select deployment mode (1 or 2)" MODE_CHOICE "1"

case $MODE_CHOICE in
    1)
        DEPLOYMENT_MODE="local"
        echo -e "${GREEN}🏠 Local Development Mode Selected${NC}"
        ;;
    2)
        DEPLOYMENT_MODE="production"
        echo -e "${GREEN}🌐 Production VPS Mode Selected${NC}"
        ;;
    *)
        echo -e "${RED}❌ Invalid choice. Defaulting to local development.${NC}"
        DEPLOYMENT_MODE="local"
        ;;
esac

echo ""
echo -e "${GREEN}� Configuration Setup${NC}"

# Common configuration
prompt_input "Enter MySQL root password" MYSQL_ROOT_PASSWORD "root_password"
prompt_input "Enter MySQL traccar password" MYSQL_PASSWORD "traccar_password"

# Mode-specific configuration
if [ "$DEPLOYMENT_MODE" = "production" ]; then
    # Check if running as root for production
    if [[ $EUID -eq 0 ]]; then
       echo -e "${RED}❌ Production setup should not be run as root${NC}"
       exit 1
    fi
    
    prompt_input "Enter your domain name (e.g., tracker.yourdomain.com)" DOMAIN
    prompt_input "Enter your email for SSL certificates" EMAIL
    TRACCAR_WEB_URL="https://$DOMAIN"
    FRONTEND_PORT="80"
    BACKEND_PORT="8082"
    MYSQL_PORT="3306"
    PHPMYADMIN_PORT="8080"
else
    # Local development defaults
    DOMAIN="localhost"
    EMAIL="admin@localhost"
    TRACCAR_WEB_URL="http://localhost:8082"
    FRONTEND_PORT="3000"
    BACKEND_PORT="8082"
    MYSQL_PORT="3306"
    PHPMYADMIN_PORT="8080"
fi

echo ""
echo -e "${GREEN}🔧 Installing Dependencies${NC}"

# Install Docker and Docker Compose
if ! command_exists docker; then
    echo -e "${BLUE}Installing Docker...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${YELLOW}⚠️  Please install Docker Desktop for Mac manually${NC}"
        echo -e "${YELLOW}   Download from: https://www.docker.com/products/docker-desktop${NC}"
        exit 1
    else
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
    fi
else
    echo -e "${GREEN}✅ Docker already installed${NC}"
fi

# Check Docker Compose
DOCKER_COMPOSE_CMD=$(docker_compose_cmd)
if [ -z "$DOCKER_COMPOSE_CMD" ]; then
    echo -e "${BLUE}Installing Docker Compose...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${YELLOW}Docker Compose should be included with Docker Desktop${NC}"
        echo -e "${YELLOW}Please restart Docker Desktop and try again${NC}"
        exit 1
    else
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        DOCKER_COMPOSE_CMD="docker-compose"
    fi
else
    echo -e "${GREEN}✅ Docker Compose available as: $DOCKER_COMPOSE_CMD${NC}"
fi

if ! command_exists git && [ "$DEPLOYMENT_MODE" = "production" ]; then
    echo -e "${BLUE}Installing Git...${NC}"
    sudo apt install -y git
fi

# Create .env file
echo -e "${GREEN}⚙️  Creating Configuration${NC}"
cat > .env << EOF
# Traccar Docker Environment Configuration
DEPLOYMENT_MODE=$DEPLOYMENT_MODE

# Domain Configuration
DOMAIN=$DOMAIN
EMAIL=$EMAIL

# Database Configuration
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_DATABASE=traccar
MYSQL_USER=traccar
MYSQL_PASSWORD=$MYSQL_PASSWORD

# Traccar Configuration
TRACCAR_WEB_URL=$TRACCAR_WEB_URL

# Port Configuration
FRONTEND_PORT=$FRONTEND_PORT
BACKEND_PORT=$BACKEND_PORT
MYSQL_PORT=$MYSQL_PORT
PHPMYADMIN_PORT=$PHPMYADMIN_PORT

# SSL Configuration
SSL_EMAIL=$EMAIL
EOF

if [ "$DEPLOYMENT_MODE" = "production" ]; then
    # Production deployment
    echo -e "${GREEN}🔧 Configuring for Production Deployment${NC}"
    
    # Update system packages for production
    echo -e "${BLUE}Updating system packages...${NC}"
    sudo apt update && sudo apt upgrade -y
    
    # Create production docker-compose override
    cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: traccar-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.prod.conf:/etc/nginx/nginx.conf:ro
      - ./certbot/conf:/etc/letsencrypt:ro
      - ./certbot/www:/var/www/certbot:ro
      - traccar_web:/usr/share/nginx/html:ro
    depends_on:
      - traccar-backend
      - traccar-frontend
    restart: unless-stopped
    networks:
      - traccar-network

  certbot:
    image: certbot/certbot
    container_name: traccar-certbot
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    depends_on:
      - nginx

  traccar-frontend:
    build:
      context: .
      dockerfile: Dockerfile.frontend
    container_name: traccar-frontend
    volumes:
      - traccar_web:/usr/share/nginx/html
    depends_on:
      - traccar-backend
    restart: unless-stopped
    networks:
      - traccar-network
    environment:
      - REACT_APP_API_URL=https://${DOMAIN}

volumes:
  traccar_web:
EOF
    # Create nginx production config
    mkdir -p nginx
    cat > nginx/nginx.prod.conf << EOF
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";

    # Rate limiting
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;

    # HTTP to HTTPS redirect
    server {
        listen 80;
        server_name $DOMAIN;
        
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }
        
        location / {
            return 301 https://\$server_name\$request_uri;
        }
    }

    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name $DOMAIN;
        
        ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
        
        # SSL configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        
        # HSTS
        add_header Strict-Transport-Security "max-age=63072000" always;

        root /usr/share/nginx/html;
        index index.html;

        # Frontend
        location / {
            try_files \$uri \$uri/ /index.html;
        }

        # API proxy
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://traccar-backend:8082/api/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        # phpMyAdmin
        location /phpmyadmin/ {
            proxy_pass http://traccar-phpmyadmin/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF

    # Create directories for SSL
    mkdir -p certbot/conf certbot/www

    echo -e "${GREEN}🚀 Starting Production Services${NC}"
    
    # Use base docker-compose + production overrides
    COMPOSE_FILES="-f docker-compose.yml -f docker-compose.prod.yml"
    
    # Start services
    echo -e "${BLUE}Starting database...${NC}"
    $DOCKER_COMPOSE_CMD $COMPOSE_FILES up -d traccar-mysql
    
    echo -e "${BLUE}Waiting for database to be ready...${NC}"
    sleep 30
    
    echo -e "${BLUE}Building and starting backend and frontend...${NC}"
    $DOCKER_COMPOSE_CMD $COMPOSE_FILES up -d traccar-backend traccar-frontend phpmyadmin
    
    echo -e "${BLUE}Starting nginx...${NC}"
    $DOCKER_COMPOSE_CMD $COMPOSE_FILES up -d nginx
    
    echo -e "${BLUE}Getting SSL certificate...${NC}"
    $DOCKER_COMPOSE_CMD $COMPOSE_FILES run --rm certbot certonly --webroot -w /var/www/certbot --force-renewal --email $EMAIL -d $DOMAIN --agree-tos
    
    echo -e "${BLUE}Restarting nginx with SSL...${NC}"
    $DOCKER_COMPOSE_CMD $COMPOSE_FILES restart nginx
    
    # Setup automatic SSL renewal
    echo -e "${GREEN}🔄 Setting up SSL Auto-renewal${NC}"
    (crontab -l 2>/dev/null; echo "0 12 * * * cd $(pwd) && $DOCKER_COMPOSE_CMD $COMPOSE_FILES run --rm certbot renew --quiet && $DOCKER_COMPOSE_CMD $COMPOSE_FILES restart nginx") | crontab -
    
    MANAGEMENT_COMPOSE="$DOCKER_COMPOSE_CMD $COMPOSE_FILES"
    
else
    # Local development
    echo -e "${GREEN}🔧 Configuring for Local Development${NC}"
    
    echo -e "${GREEN}🚀 Starting Local Development Services${NC}"
    
    # Use standard docker-compose
    COMPOSE_FILES="-f docker-compose.yml"
    
    # Start services
    echo -e "${BLUE}Starting database...${NC}"
    $DOCKER_COMPOSE_CMD $COMPOSE_FILES up -d traccar-mysql
    
    echo -e "${BLUE}Waiting for database to be ready...${NC}"
    sleep 20
    
    echo -e "${BLUE}Building and starting all services...${NC}"
    $DOCKER_COMPOSE_CMD $COMPOSE_FILES up -d
    
    MANAGEMENT_COMPOSE="$DOCKER_COMPOSE_CMD $COMPOSE_FILES"
fi

echo ""
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}==================${NC}"
echo ""

if [ "$DEPLOYMENT_MODE" = "production" ]; then
    echo -e "${BLUE}🌐 Your Traccar system is available at:${NC}"
    echo -e "   ${GREEN}Web Interface:${NC} https://$DOMAIN"
    echo -e "   ${GREEN}Admin Login:${NC} admin / admin"
    echo -e "   ${GREEN}Database Admin:${NC} https://$DOMAIN/phpmyadmin"
    echo ""
    echo -e "${BLUE}📱 GPS Device Setup:${NC}"
    echo -e "   ${GREEN}Server:${NC} $DOMAIN"
    echo -e "   ${GREEN}Port:${NC} 5055 (and other protocol ports)"
    echo ""
    echo -e "${YELLOW}⚠️  Important:${NC}"
    echo -e "   • Change the default admin password immediately"
    echo -e "   • Configure your GPS devices to use the domain"
    echo -e "   • SSL certificates will auto-renew via cron"
else
    echo -e "${BLUE}🌐 Your Traccar system is available at:${NC}"
    echo -e "   ${GREEN}Web Interface:${NC} http://localhost:$FRONTEND_PORT"
    echo -e "   ${GREEN}Backend API:${NC} http://localhost:$BACKEND_PORT"
    echo -e "   ${GREEN}Admin Login:${NC} admin / admin"
    echo -e "   ${GREEN}Database Admin:${NC} http://localhost:$PHPMYADMIN_PORT"
    echo ""
    echo -e "${BLUE}📱 GPS Device Setup (Local Testing):${NC}"
    echo -e "   ${GREEN}Server:${NC} localhost or your-local-ip"
    echo -e "   ${GREEN}Port:${NC} 5055 (and other protocol ports)"
    echo ""
    echo -e "${YELLOW}⚠️  For production deployment, run:${NC}"
    echo -e "   ${GREEN}./setup.sh${NC} and select option 2"
fi

echo ""
echo -e "${BLUE}📋 Management Commands:${NC}"
echo -e "   ${GREEN}View logs:${NC} $MANAGEMENT_COMPOSE logs -f"
echo -e "   ${GREEN}Restart:${NC} $MANAGEMENT_COMPOSE restart"
echo -e "   ${GREEN}Status:${NC} $MANAGEMENT_COMPOSE ps"
echo -e "   ${GREEN}Stop:${NC} $MANAGEMENT_COMPOSE down"
echo ""

# Check if user needs to re-login for docker group
if ! groups $USER | grep -q docker 2>/dev/null; then
    echo -e "${YELLOW}⚠️  You may need to logout and login again for Docker permissions to take effect${NC}"
fi
