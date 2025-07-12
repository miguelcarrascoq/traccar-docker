#!/bin/bash

# Script para iniciar el entorno de desarrollo de Traccar

echo "🚀 Iniciando entorno de desarrollo de Traccar..."

# Crear directorio para código fuente
mkdir -p src/traccar-web src/traccar-backend

# Verificar si existe .env
if [ ! -f .env ]; then
    echo "⚠️  No se encontró archivo .env. Creando uno básico..."
    cat > .env << EOF
# Configuración de desarrollo
FRONTEND_PORT=3000
BACKEND_PORT=8082
MYSQL_PORT=3306
PHPMYADMIN_PORT=8080

# Configuración de MySQL
MYSQL_ROOT_PASSWORD=root_password
MYSQL_DATABASE=traccar
MYSQL_USER=traccar
MYSQL_PASSWORD=traccar_password

# URLs de repositorios (personalizar según necesites)
GIT_FRONTEND_REPO_URL=https://github.com/traccar/traccar-web.git
GIT_BACKEND_REPO_URL=https://github.com/traccar/traccar.git

# Credenciales Git (opcional, para repos privados)
# GIT_USERNAME=tu_usuario
# GIT_PASSWORD=tu_token

# Ramas específicas (opcional)
# GIT_FRONTEND_BRANCH=main
# GIT_BACKEND_BRANCH=main

# URL de la API para el frontend
TRACCAR_WEB_URL=http://localhost:8082
EOF
    echo "✅ Archivo .env creado. Puedes editarlo según tus necesidades."
fi

# Iniciar servicios
echo "🔧 Iniciando servicios..."
docker-compose -f docker-compose.dev.yml up -d

echo "📋 Estado de los servicios:"
docker-compose -f docker-compose.dev.yml ps

echo ""
echo "🎉 Entorno de desarrollo iniciado!"
echo ""
echo "📁 Código fuente disponible en:"
echo "   - Frontend: ./src/traccar-web/"
echo "   - Backend: ./src/traccar-backend/"
echo ""
echo "🌐 Servicios disponibles:"
echo "   - Frontend: http://localhost:3000"
echo "   - Backend API: http://localhost:8082"
echo "   - MySQL: localhost:3306"
echo "   - phpMyAdmin: http://localhost:8080"
echo ""
echo "🛠️  Para detener: ./stop-dev.sh"
echo "📊 Para ver logs: docker-compose -f docker-compose.dev.yml logs -f"
