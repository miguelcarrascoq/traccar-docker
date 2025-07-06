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
# Allow DOCKER_CMD to be set from environment, otherwise find it
DOCKER_CMD="${DOCKER_CMD:-}"

# Find Docker command (check multiple possible locations)
if [ -z "$DOCKER_CMD" ]; then
    # First try: Check if 'docker' is available as a command (including aliases)
    if docker --version >/dev/null 2>&1; then
        DOCKER_CMD="docker"
        echo "✅ Found Docker in PATH (may be an alias)"
    # Second try: Check common locations for the Docker binary
    elif [ -x "/usr/local/bin/docker" ]; then
        DOCKER_CMD="/usr/local/bin/docker"
    elif [ -x "/opt/homebrew/bin/docker" ]; then
        DOCKER_CMD="/opt/homebrew/bin/docker"
    elif [ -x "$HOME/.docker/bin/docker" ]; then
        DOCKER_CMD="$HOME/.docker/bin/docker"
    else
        # Try to find docker anywhere in PATH
        DOCKER_PATH=$(find /usr /opt $HOME -name docker -type f -executable 2>/dev/null | head -n 1)
        if [ -n "$DOCKER_PATH" ]; then
            DOCKER_CMD="$DOCKER_PATH"
            echo "🔍 Found Docker at: $DOCKER_CMD"
        else
            echo "❌ Docker not found. Please install Docker"
            echo "💡 If Docker is installed, try running this script with the full path to docker:"
            echo "   DOCKER_CMD=/path/to/your/docker ./start-local.sh"
            exit 1
        fi
    fi
fi

# Function to check if command works
check_command() {
    "$@" >/dev/null 2>&1
}

# First check if docker-compose (v1) is available
if docker-compose --version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker-compose"
    echo "✅ Found docker-compose (v1)"
# Then check if docker compose (v2) is available
elif docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
    echo "✅ Found docker compose (v2)"
# Fallback to using DOCKER_CMD if it's set
elif [ -n "$DOCKER_CMD" ] && $DOCKER_CMD compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="$DOCKER_CMD compose"
    echo "✅ Found docker compose (v2) via DOCKER_CMD"
else
    echo "❌ Docker Compose not found"
    echo "💡 Make sure Docker is running or install docker-compose"
    echo "🔍 Debug info:"
    echo "   Docker command: $DOCKER_CMD"
    echo "   Docker version: $(docker --version 2>/dev/null || $DOCKER_CMD --version 2>/dev/null || echo 'not found')"
    echo "   Docker Compose version: $(docker compose version 2>/dev/null || $DOCKER_CMD compose version 2>/dev/null || echo 'not found')"
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
