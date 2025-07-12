#!/bin/bash

# Script para detener el entorno de desarrollo de Traccar

echo "🛑 Deteniendo entorno de desarrollo de Traccar..."

# Detener servicios
docker-compose -f docker-compose.dev.yml down

echo "✅ Entorno de desarrollo detenido."
echo ""
echo "📁 El código fuente se mantiene en:"
echo "   - Frontend: ./src/traccar-web/"
echo "   - Backend: ./src/traccar-backend/"
echo ""
echo "🔄 Para reiniciar: ./start-dev.sh"
