#!/bin/bash

# Quick local development start script
# For users who want to skip the interactive setup

set -e

echo "🚀 Starting Traccar Local Development"
echo "====================================="

# Check if .env exists, if not create it with defaults
if [ ! -f .env ]; then
    echo "📝 Creating default .env file..."
    cp .env.example .env
fi

# Check Docker Compose command
DOCKER_COMPOSE_CMD=""
if command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo "❌ Docker Compose not found. Please install Docker Desktop or docker-compose"
    exit 1
fi

echo "✅ Using: $DOCKER_COMPOSE_CMD"

# Start services
echo "🔧 Starting services..."
$DOCKER_COMPOSE_CMD up -d

echo ""
echo "✅ Traccar is starting!"
echo "======================"
echo ""
echo "📋 Access URLs:"
echo "   🌐 Frontend: http://localhost:3000"
echo "   ⚙️  Backend: http://localhost:8082"
echo "   📊 Database: http://localhost:8080 (phpMyAdmin)"
echo ""
echo "👤 Default Login: admin / admin"
echo ""
echo "📋 Management:"
echo "   View logs: $DOCKER_COMPOSE_CMD logs -f"
echo "   Stop: $DOCKER_COMPOSE_CMD down"
echo ""
