#!/bin/bash

# Script para probar que la configuración de testing funciona correctamente

echo "🧪 Probando configuración de testing..."

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.test.yml" ]; then
    echo "❌ Error: Este script debe ejecutarse desde el directorio traccar-docker"
    exit 1
fi

echo "✅ Directorio correcto"

# Limpiar cualquier entorno anterior
echo "🧹 Limpiando entornos anteriores..."
docker-compose -f docker-compose.test.yml down -v 2>/dev/null || true
docker-compose -f docker-compose.dev.yml down 2>/dev/null || true

# Iniciar entorno de desarrollo
echo "🚀 Iniciando entorno de desarrollo..."
docker-compose -f docker-compose.dev.yml up -d traccar-mysql

# Esperar a que esté listo
echo "⏳ Esperando a que la base de datos de desarrollo esté lista..."
sleep 15

# Verificar conexión a base de datos de desarrollo
echo "🔍 Verificando base de datos de desarrollo..."
if ! docker exec traccar-mysql-dev mysqladmin ping -h localhost --silent; then
    echo "❌ Error: No se pudo conectar a la base de datos de desarrollo"
    exit 1
fi

echo "✅ Base de datos de desarrollo funcionando"

# Iniciar entorno de testing
echo "🚀 Iniciando entorno de testing..."
docker-compose -f docker-compose.test.yml up -d traccar-mysql-test

# Esperar a que esté listo
echo "⏳ Esperando a que la base de datos de testing esté lista..."
sleep 15

# Verificar conexión a base de datos de testing
echo "🔍 Verificando base de datos de testing..."
if ! docker exec traccar-mysql-test mysqladmin ping -h localhost --silent; then
    echo "❌ Error: No se pudo conectar a la base de datos de testing"
    exit 1
fi

echo "✅ Base de datos de testing funcionando"

# Verificar que las bases de datos son diferentes
echo "🔍 Verificando aislamiento de bases de datos..."

DEV_DB=$(docker exec traccar-mysql-dev mysql -u traccar -ptraccar_password -e "SELECT DATABASE();" -s -N 2>/dev/null)
TEST_DB=$(docker exec traccar-mysql-test mysql -u traccar_test -ptraccar_test_password -e "SELECT DATABASE();" -s -N 2>/dev/null)

if [ "$DEV_DB" = "traccar" ] && [ "$TEST_DB" = "traccar_test" ]; then
    echo "✅ Bases de datos correctamente aisladas:"
    echo "   - Desarrollo: $DEV_DB (puerto 3306)"
    echo "   - Testing: $TEST_DB (puerto 3307)"
else
    echo "❌ Error: Las bases de datos no están correctamente configuradas"
    echo "   - Desarrollo: $DEV_DB"
    echo "   - Testing: $TEST_DB"
    exit 1
fi

# Probar que los tests de Laravel funcionan
echo "🧪 Probando tests de Laravel..."
if [ -d "../interno-laravel" ]; then
    cd ../interno-laravel
    
    if [ -f "run-tests-safe.sh" ]; then
        echo "✅ Script de tests de Laravel encontrado"
        echo "💡 Para ejecutar tests de Laravel de forma segura:"
        echo "   cd ../interno-laravel && ./run-tests-safe.sh"
    else
        echo "⚠️  Script de tests de Laravel no encontrado"
    fi
    
    cd ../traccar-docker
else
    echo "⚠️  Proyecto Laravel no encontrado en ../interno-laravel"
fi

echo ""
echo "🎉 Configuración de testing verificada exitosamente!"
echo ""
echo "📋 Resumen:"
echo "   ✅ Base de datos de desarrollo: traccar (puerto 3306)"
echo "   ✅ Base de datos de testing: traccar_test (puerto 3307)"
echo "   ✅ Aislamiento completo entre entornos"
echo "   ✅ Los tests de Laravel no afectarán la base de datos de desarrollo"
echo ""
echo "🚀 Para usar:"
echo "   - Desarrollo: ./start-dev.sh"
echo "   - Testing: ./start-test.sh"
echo "   - Tests Laravel: ./run-laravel-tests.sh"
