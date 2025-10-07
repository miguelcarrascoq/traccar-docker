#!/bin/bash

# Script para iniciar el entorno de testing de Traccar

echo "🧪 Iniciando entorno de testing de Traccar..."

# Crear directorios necesarios
mkdir -p traccar/logs-test traccar/data-test

# Verificar si existe .env
if [ ! -f .env ]; then
    echo "⚠️  No se encontró archivo .env. Creando uno básico..."
    cat > .env << EOF
# Configuración de desarrollo
FRONTEND_PORT=3000
BACKEND_PORT=8082
MYSQL_PORT=3306
PHPMYADMIN_PORT=8080

# Configuración de testing
BACKEND_TEST_PORT=8084
MYSQL_TEST_PORT=3307
PHPMYADMIN_TEST_PORT=8081

# Configuración de MySQL
MYSQL_ROOT_PASSWORD=root_password
MYSQL_DATABASE=traccar
MYSQL_USER=traccar
MYSQL_PASSWORD=traccar_password

# URLs de repositorios (personalizar según necesites)
GIT_FRONTEND_REPO_URL=https://github.com/traccar/traccar-web.git
GIT_BACKEND_REPO_URL=https://github.com/traccar/traccar.git

# URL de la API para el frontend
TRACCAR_WEB_URL=http://localhost:8082
EOF
    echo "✅ Archivo .env creado. Puedes editarlo según tus necesidades."
fi

# Iniciar servicios de testing
echo "🔧 Iniciando servicios de testing..."
docker-compose -f docker-compose.test.yml up -d

echo "📋 Estado de los servicios de testing:"
docker-compose -f docker-compose.test.yml ps

echo ""
echo "🎉 Entorno de testing iniciado!"
echo ""
echo "🌐 Servicios de testing disponibles:"
echo "   - Backend API (Test): http://localhost:8084"
echo "   - MySQL (Test): localhost:3307"
echo "   - phpMyAdmin (Test): http://localhost:8081"
echo ""
echo "🛠️  Para detener: ./stop-test.sh"
echo "📊 Para ver logs: docker-compose -f docker-compose.test.yml logs -f"
