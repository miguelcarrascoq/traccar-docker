# 📚 Índice de Documentación - Herramientas MySQL

Este directorio contiene documentación completa sobre las herramientas de gestión del volumen MySQL unificado.

## 📖 Documentos Disponibles

### 1. 🛠️ [mysql-volume-manager.sh](mysql-volume-manager.sh)
**Script principal de gestión**
- Backup y restore de volúmenes
- Copia entre volúmenes
- Información detallada
- Limpieza segura
- Ayuda integrada completa

### 2. 📋 [TOOLS-REFERENCE.md](TOOLS-REFERENCE.md)
**Referencia rápida de comandos**
- Comandos principales con ejemplos
- Casos de uso comunes
- Tabla de opciones
- Troubleshooting rápido
- Estado del sistema

### 3. 📊 [MYSQL-VOLUME-GUIDE.md](MYSQL-VOLUME-GUIDE.md)
**Guía completa del volumen MySQL**
- Descripción detallada del sistema
- Flujos de trabajo paso a paso
- Mejores prácticas
- Precauciones de seguridad
- Troubleshooting avanzado
- Historial de cambios

### 4. 📖 [README.md](README.md)
**Documentación principal del proyecto**
- Ahora incluye sección de herramientas MySQL
- Enlaces a documentación específica
- Integración con el resto del proyecto

## 🚀 Inicio Rápido

### Ver ayuda completa
```bash
./mysql-volume-manager.sh help
```

### Comandos más utilizados
```bash
# Ver estado actual
./mysql-volume-manager.sh info

# Crear backup
./mysql-volume-manager.sh backup

# Cambiar entre modos sin perder datos
./stop-dev.sh && ./start-local.sh
```

## 📋 Resumen de Características

### ✨ Características Principales
- 🔄 **Volumen unificado**: Mismo volumen para desarrollo y producción
- 💾 **Persistencia garantizada**: Los datos se mantienen entre cambios de modo
- 🛠️ **Herramientas completas**: Script con todas las funciones necesarias
- 📖 **Documentación detallada**: Guías paso a paso con ejemplos
- 🔒 **Operaciones seguras**: Confirmaciones para comandos destructivos

### 🎯 Volumen Actual
**Nombre**: `traccar-docker_mysql_data`  
**Tamaño**: ~207MB (con datos de prueba)  
**Compartido entre**:
- Modo desarrollo (`./start-dev.sh`)
- Modo local (`./start-local.sh`)

### 🛡️ Seguridad
- ⚠️ Advertencias claras para operaciones destructivas
- 🔐 Confirmación requerida para `restore` y `clean`
- 📝 Logs detallados de todas las operaciones
- 🚨 Validaciones antes de ejecutar comandos

## 📞 Soporte

### Obtener ayuda
1. **Script**: `./mysql-volume-manager.sh help`
2. **Referencia rápida**: Ver [TOOLS-REFERENCE.md](TOOLS-REFERENCE.md)
3. **Guía completa**: Ver [MYSQL-VOLUME-GUIDE.md](MYSQL-VOLUME-GUIDE.md)
4. **Troubleshooting**: Cada documento incluye sección de solución de problemas

### Comandos de diagnóstico
```bash
# Estado del volumen
./mysql-volume-manager.sh info

# Volúmenes disponibles
docker volume ls | grep traccar

# Servicios activos
docker-compose ps

# Logs del MySQL
docker logs traccar-mysql
```

---

## 📅 Historial

**Creación**: Julio 2025  
**Versión**: 1.0  
**Última actualización**: Julio 2025  

**Cambios principales**:
- ✅ Unificación de volúmenes desarrollo/producción
- ✅ Script de gestión completo
- ✅ Documentación exhaustiva
- ✅ Migración automática de datos existentes
- ✅ Medidas de seguridad implementadas

---

*Esta documentación se mantiene actualizada con cada versión del proyecto.*
