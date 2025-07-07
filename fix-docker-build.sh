#!/bin/bash

# Fix Docker credential helper issue and build containers

set -e

echo "🔧 Fixing Docker credential helper and building containers"
echo "=========================================================="

# Check if the --reset-db flag was passed
RESET_DB=false
for arg in "$@"; do
    if [ "$arg" == "--reset-db" ]; then
        RESET_DB=true
    fi
done

# Ensure Docker bin is in PATH
DOCKER_BIN_PATH="${HOME}/.docker/bin"
if [ -d "$DOCKER_BIN_PATH" ]; then
    echo "✅ Found Docker bin directory: $DOCKER_BIN_PATH"
    export PATH="$DOCKER_BIN_PATH:$PATH"
else
    echo "❌ Docker bin directory not found at $DOCKER_BIN_PATH"
    echo "💡 This might be because Docker Desktop installed the binaries in a different location."
fi

# Create user bin directory if it doesn't exist
USER_BIN="${HOME}/bin"
mkdir -p "$USER_BIN"
echo "✅ Ensured user bin directory exists: $USER_BIN"

# Find docker-credential-desktop
CRED_HELPER=$(find "${HOME}/.docker" -name "docker-credential-desktop" -type f -executable 2>/dev/null | head -n 1)

if [ -n "$CRED_HELPER" ]; then
    echo "✅ Found docker-credential-desktop at: $CRED_HELPER"
    
    # Create symlink in user's bin
    ln -sf "$CRED_HELPER" "$USER_BIN/docker-credential-desktop"
    echo "✅ Created symlink in $USER_BIN"
    
    # Add user bin to PATH
    export PATH="$USER_BIN:$PATH"
    echo "✅ Added $USER_BIN to PATH"
else
    echo "❌ Could not find docker-credential-desktop"
    echo "💡 You might need to reinstall Docker Desktop or manually locate the credential helper"
fi

# Check if credential helper is now in PATH
if command -v docker-credential-desktop >/dev/null 2>&1; then
    echo "✅ docker-credential-desktop is now in PATH: $(which docker-credential-desktop)"
else
    echo "❌ docker-credential-desktop still not found in PATH"
    echo "💡 Debug info:"
    echo "   PATH: $PATH"
    echo "   Credential helper location: $CRED_HELPER"
fi

# If --reset-db was passed, stop containers, remove volume, and restart
if [ "$RESET_DB" = true ]; then
    echo ""
    echo "🗄️ Resetting database (--reset-db flag detected)"
    echo "=========================================="
    echo ""
    
    # Stop containers if they are running
    if docker compose ps | grep -q "traccar"; then
        echo "Stopping containers..."
        docker compose down
    fi
    
    # Remove the MySQL volume
    if docker volume ls | grep -q "traccar-docker_mysql_data"; then
        echo "Removing MySQL data volume..."
        docker volume rm traccar-docker_mysql_data
    fi
    
    echo "Database reset complete. Will rebuild and restart containers."
fi

# Now run docker compose build and up
echo ""
echo "🚀 Building and starting Traccar containers"
echo "=========================================="
echo ""
docker compose build
echo ""
docker compose up -d

echo ""
echo "✅ Done! If there were any issues with credentials, please check the Docker Desktop settings."
echo "📋 Access URLs:"
echo "   🌐 Frontend: http://localhost:3000"
echo "   ⚙️ Backend: http://localhost:8082"
echo "   📊 Database: http://localhost:8080 (phpMyAdmin)"
echo ""
