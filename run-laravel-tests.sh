#!/bin/bash

# Script para ejecutar tests de Laravel de forma segura
# Este script inicia el entorno de testing y ejecuta los tests de Laravel

echo "🧪 Ejecutando tests de Laravel de forma segura..."

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.test.yml" ]; then
    echo "❌ Error: Este script debe ejecutarse desde el directorio traccar-docker"
    exit 1
fi

# Verificar que el proyecto Laravel existe
if [ ! -d "../interno-laravel" ]; then
    echo "❌ Error: Proyecto Laravel no encontrado en ../interno-laravel"
    exit 1
fi

echo "✅ Proyecto Laravel encontrado"

# Iniciar el entorno de testing
echo "🚀 Iniciando entorno de testing..."
docker-compose -f docker-compose.test.yml up -d traccar-mysql-test

# Esperar a que la base de datos esté lista
echo "⏳ Esperando a que la base de datos de testing esté lista..."
sleep 10

# Verificar que la base de datos esté disponible
echo "🔍 Verificando conexión a la base de datos de testing..."
if ! docker exec traccar-mysql-test mysqladmin ping -h localhost --silent; then
    echo "❌ Error: No se pudo conectar a la base de datos de testing"
    exit 1
fi

echo "✅ Base de datos de testing lista"

# Ejecutar tests de Laravel
echo "🧪 Ejecutando tests de Laravel..."
cd ../interno-laravel

# Verificar que el script de tests seguro existe
if [ ! -f "run-tests-safe.sh" ]; then
    echo "❌ Error: Script run-tests-safe.sh no encontrado en el proyecto Laravel"
    exit 1
fi

# Ejecutar el script de tests seguro
./run-tests-safe.sh

# Volver al directorio original
cd ../traccar-docker

echo "✅ Tests de Laravel completados de forma segura"
echo "💡 Los tests usaron la base de datos de testing separada y no afectaron la base de datos de desarrollo"
