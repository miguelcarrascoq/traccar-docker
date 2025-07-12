#!/bin/bash
# =============================================================================
# Script de Gestión del Volumen MySQL de Traccar
# =============================================================================
# Este script permite gestionar el volumen MySQL compartido entre los modos
# de desarrollo y producción de Traccar.
#
# Autor: Sistema de desarrollo Traccar
# Fecha: Julio 2025
# Versión: 1.0
#
# IMPORTANTE: Tanto el modo desarrollo como producción usan el mismo volumen:
# traccar-docker_mysql_data
# =============================================================================

VOLUME_NAME="traccar-docker_mysql_data"

# Hacer backup del volumen
backup_mysql_volume() {
    echo "🔄 Haciendo backup del volumen MySQL ($VOLUME_NAME)..."
    docker run --rm \
        -v "$VOLUME_NAME:/source:ro" \
        -v "$(pwd):/backup" \
        alpine:latest \
        tar czf "/backup/mysql_backup_$(date +%Y%m%d_%H%M%S).tar.gz" -C /source .
    echo "✅ Backup completado"
}

# Restaurar backup al volumen
restore_mysql_volume() {
    if [ -z "$1" ]; then
        echo "❌ Error: Especifica el archivo de backup"
        echo "Uso: $0 restore <archivo_backup.tar.gz>"
        exit 1
    fi
    
    echo "🔄 Restaurando backup al volumen MySQL ($VOLUME_NAME)..."
    echo "⚠️  ADVERTENCIA: Esto sobrescribirá todos los datos existentes"
    read -p "¿Continuar? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Operación cancelada"
        exit 1
    fi
    
    docker run --rm \
        -v "$VOLUME_NAME:/target" \
        -v "$(pwd):/backup" \
        alpine:latest \
        sh -c "rm -rf /target/* && cd /target && tar xzf \"/backup/$1\""
    echo "✅ Restore completado"
}

# Copiar volumen a otro volumen
copy_mysql_volume() {
    if [ -z "$1" ]; then
        echo "❌ Error: Especifica el nombre del volumen destino"
        echo "Uso: $0 copy <nombre_volumen_destino>"
        exit 1
    fi
    
    echo "🔄 Copiando volumen MySQL ($VOLUME_NAME) a $1..."
    docker run --rm \
        -v "$VOLUME_NAME:/source:ro" \
        -v "$1:/target" \
        alpine:latest \
        sh -c "cp -r /source/* /target/"
    echo "✅ Copia completada"
}

# Mostrar información del volumen
show_mysql_volume_info() {
    echo "📊 Información del volumen MySQL:"
    echo "   Nombre: $VOLUME_NAME"
    echo "   Usado por: Desarrollo y Producción"
    echo ""
    
    # Verificar si el volumen existe
    if docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
        echo "✅ Volumen existe"
        echo "📁 Contenido del volumen:"
        docker run --rm -v "$VOLUME_NAME:/data" alpine:latest ls -la /data | head -10
        echo ""
        echo "💾 Tamaño aproximado:"
        docker run --rm -v "$VOLUME_NAME:/data" alpine:latest du -sh /data
    else
        echo "❌ Volumen no existe"
    fi
}

# Limpiar volumen (PELIGROSO)
clean_mysql_volume() {
    echo "⚠️  ADVERTENCIA: Esto eliminará TODOS los datos del volumen MySQL"
    echo "   Volumen: $VOLUME_NAME"
    echo "   Esto afectará tanto desarrollo como producción"
    echo ""
    read -p "¿Estás seguro? Escribe 'DELETE' para continuar: " -r
    echo
    if [[ $REPLY != "DELETE" ]]; then
        echo "❌ Operación cancelada"
        exit 1
    fi
    
    echo "🔄 Limpiando volumen MySQL..."
    docker run --rm -v "$VOLUME_NAME:/data" alpine:latest sh -c "rm -rf /data/*"
    echo "✅ Volumen limpiado"
}

case "$1" in
    backup)
        backup_mysql_volume
        ;;
    restore)
        restore_mysql_volume "$2"
        ;;
    copy)
        copy_mysql_volume "$2"
        ;;
    info)
        show_mysql_volume_info
        ;;
    clean)
        clean_mysql_volume
        ;;
    help|--help|-h)
        $0
        ;;
    *)
        echo "======================================================================================"
        echo "                     GESTOR DE VOLUMEN MYSQL - TRACCAR"
        echo "======================================================================================"
        echo ""
        echo "DESCRIPCIÓN:"
        echo "  Este script gestiona el volumen MySQL compartido entre desarrollo y producción."
        echo "  Volumen actual: $VOLUME_NAME"
        echo ""
        echo "USO:"
        echo "  $0 {backup|restore|copy|info|clean|help}"
        echo ""
        echo "COMANDOS DISPONIBLES:"
        echo ""
        echo "  📦 backup                    - Crear backup del volumen MySQL"
        echo "                                 Genera: mysql_backup_YYYYMMDD_HHMMSS.tar.gz"
        echo ""
        echo "  📥 restore <archivo.tar.gz>  - Restaurar backup al volumen"
        echo "                                 ⚠️ SOBRESCRIBE todos los datos existentes"
        echo ""
        echo "  📋 copy <volumen_destino>    - Copiar volumen a otro volumen Docker"
        echo "                                 Útil para duplicar datos o migrar"
        echo ""
        echo "  📊 info                      - Mostrar información detallada del volumen"
        echo "                                 Incluye: estado, contenido y tamaño"
        echo ""
        echo "  🗑️  clean                     - Limpiar completamente el volumen"
        echo "                                 ⚠️ ELIMINA todos los datos (PELIGROSO)"
        echo ""
        echo "  ❓ help                      - Mostrar esta ayuda detallada"
        echo ""
        echo "EJEMPLOS:"
        echo "  $0 backup                    # Crear backup automático"
        echo "  $0 restore backup.tar.gz    # Restaurar desde backup"
        echo "  $0 copy mi_backup_volumen    # Copiar a nuevo volumen"
        echo "  $0 info                      # Ver estado actual"
        echo ""
        echo "NOTAS IMPORTANTES:"
        echo "  • El volumen es compartido entre desarrollo (./start-dev.sh) y local (./start-local.sh)"
        echo "  • Los backups se guardan en el directorio actual"
        echo "  • Siempre para los servicios antes de operaciones destructivas"
        echo "  • Los comandos 'restore' y 'clean' requieren confirmación"
        echo ""
        echo "======================================================================================"
        exit 1
        ;;
esac
