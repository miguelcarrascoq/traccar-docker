#!/bin/bash

# Script simple para clonar el código fuente antes del desarrollo

echo "📥 Clonando código fuente para desarrollo..."

# Crear directorios
mkdir -p src

# Clonar frontend
echo "Clonando traccar-web..."
if [ ! -d "src/traccar-web" ]; then
    git clone https://github.com/traccar/traccar-web.git src/traccar-web
    echo "✅ Frontend clonado en src/traccar-web/"
else
    echo "⚠️  src/traccar-web ya existe. Para actualizar:"
    echo "   cd src/traccar-web && git pull"
fi

# Clonar backend
echo "Clonando traccar backend..."
if [ ! -d "src/traccar-backend" ]; then
    git clone https://github.com/traccar/traccar.git src/traccar-backend
    echo "✅ Backend clonado en src/traccar-backend/"
else
    echo "⚠️  src/traccar-backend ya existe. Para actualizar:"
    echo "   cd src/traccar-backend && git pull"
fi

echo ""
echo "🎉 Código fuente disponible:"
echo "   - Frontend: ./src/traccar-web/"
echo "   - Backend: ./src/traccar-backend/"
echo ""
echo "💡 Ahora puedes:"
echo "   1. Modificar el código en estos directorios"
echo "   2. Usar volúmenes de Docker para montarlos en contenedores"
echo "   3. Configurar tu IDE para trabajar con estos archivos"
