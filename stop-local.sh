#!/bin/bash

# Quick script to stop Traccar local development containers

set -e

echo "🛑 Stopping Traccar Local Development"
echo "===================================="

# Check Docker Compose command
DOCKER_COMPOSE_CMD=""
# Allow DOCKER_CMD to be set from environment, otherwise find it
DOCKER_CMD="${DOCKER_CMD:-}"

# Find Docker command (check multiple possible locations)
if command -v docker >/dev/null 2>&1; then
    DOCKER_CMD="docker"
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
        echo "   DOCKER_CMD=/path/to/your/docker ./stop-local.sh"
        exit 1
    fi
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
    exit 1
fi

echo "🔧 Using: $DOCKER_COMPOSE_CMD"

# Stop services
echo "🔧 Stopping services..."

# Add Docker bin to PATH if it exists (for credential helpers)
DOCKER_BIN_PATH="${HOME}/.docker/bin"
if [ -d "$DOCKER_BIN_PATH" ]; then
    export PATH="$DOCKER_BIN_PATH:$PATH"
fi

if [[ "$DOCKER_COMPOSE_CMD" == *" "* ]]; then
    # Command contains spaces, need to split it
    eval "$DOCKER_COMPOSE_CMD down"
else
    $DOCKER_COMPOSE_CMD down
fi

echo ""
echo "✅ Traccar services stopped successfully!"
echo ""
