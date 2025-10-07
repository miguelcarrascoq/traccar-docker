#!/bin/bash

# Script para detener el entorno de testing de Traccar

echo "🛑 Deteniendo entorno de testing de Traccar..."

# Detener servicios de testing
docker-compose -f docker-compose.test.yml down

echo "✅ Entorno de testing detenido."
echo ""
echo "🔄 Para reiniciar: ./start-test.sh"
