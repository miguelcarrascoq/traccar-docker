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
DOCKER_CMD=""

# Find Docker command
if command -v docker >/dev/null 2>&1; then
    DOCKER_CMD="docker"
else
    echo "❌ Docker not found. Please install Docker"
    exit 1
fi

# Function to check if command works
check_command() {
    "$@" >/dev/null 2>&1
}

# First check if docker-compose (v1) is available
if check_command docker-compose --version; then
    DOCKER_COMPOSE_CMD="docker-compose"
    echo "✅ Found docker-compose (v1)"
# Then check if docker compose (v2) is available
elif check_command $DOCKER_CMD --version && check_command $DOCKER_CMD compose version; then
    DOCKER_COMPOSE_CMD="$DOCKER_CMD compose"
    echo "✅ Found docker compose (v2)"
else
    echo "❌ Docker Compose not found"
    echo "💡 Make sure Docker is running or install docker-compose"
    echo "🔍 Debug info:"
    echo "   Docker command: $DOCKER_CMD"
    echo "   Docker version: $($DOCKER_CMD --version 2>/dev/null || echo 'not found')"
    echo "   Docker Compose version: $($DOCKER_CMD compose version 2>/dev/null || echo 'not found')"
    exit 1
fi

echo "🔧 Using: $DOCKER_COMPOSE_CMD"

# Start services
echo "🔧 Starting services..."

# Add Docker bin to PATH if it exists (for credential helpers)
DOCKER_BIN_PATH="${HOME}/.docker/bin"
if [ -d "$DOCKER_BIN_PATH" ]; then
    export PATH="$DOCKER_BIN_PATH:$PATH"
fi

if [[ "$DOCKER_COMPOSE_CMD" == *" "* ]]; then
    # Command contains spaces, need to split it
    eval "$DOCKER_COMPOSE_CMD up -d"
else
    $DOCKER_COMPOSE_CMD up -d
fi

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
