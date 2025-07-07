#!/bin/bash

# Script to check the status of Traccar Docker containers and services

echo "🔍 Checking Traccar Docker System Status"
echo "========================================"

# Find Docker binary
DOCKER_BIN=$(which docker || echo "/Applications/Docker.app/Contents/Resources/bin/docker")

if [ ! -x "$DOCKER_BIN" ]; then
    echo "❌ Docker binary not found. Make sure Docker is installed."
    exit 1
fi

echo "🐳 Using Docker binary: $DOCKER_BIN"
echo ""

# Check Docker is running
if ! $DOCKER_BIN info &>/dev/null; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is running"
echo ""

echo "📊 Container Status:"
$DOCKER_BIN compose ps -a
echo ""

echo "🔄 Container Resource Usage:"
$DOCKER_BIN stats --no-stream
echo ""

# Check logs for errors
echo "🔍 Checking for errors in backend logs (last 10 lines):"
$DOCKER_BIN compose logs --tail=10 traccar-backend | grep -i "error\|exception" || echo "✅ No recent errors found"
echo ""

# Check if services are accessible
echo "🌐 Checking service accessibility:"
echo -n "- Frontend (http://localhost:3000): "
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000 || echo "Not accessible"

echo -n "- Backend (http://localhost:8082): "
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8082 || echo "Not accessible"

echo -n "- Database Admin (http://localhost:8080): "
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080 || echo "Not accessible"
echo ""

echo "📦 Docker Volumes:"
$DOCKER_BIN volume ls | grep traccar
echo ""

echo "✅ Status check complete"
