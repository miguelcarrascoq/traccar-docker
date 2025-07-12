# 📊 Guía del Volumen MySQL Unificado

## 🎯 Descripción General

Este proyecto utiliza un **volumen MySQL unificado** que permite compartir los mismos datos entre el modo desarrollo y el modo local/producción. Esto significa que puedes cambiar entre modos sin perder tus datos.

### ✨ Características principales:
- 🔄 **Volumen compartido**: Mismo volumen para desarrollo y producción
- 💾 **Persistencia de datos**: Los datos se mantienen entre reinicios
- 🛠️ **Herramientas de gestión**: Script completo para backup, restore y más
- 🔧 **Migración automática**: Los datos existentes fueron migrados automáticamente

---

## 📋 Volumen Actual

**Nombre del volumen**: `traccar-docker_mysql_data`

**Usado por**:
- 🔨 Modo desarrollo (`./start-dev.sh`)
- 🚀 Modo local (`./start-local.sh`)

---

## 🛠️ Herramientas Disponibles

### 📦 mysql-volume-manager.sh

Script principal para gestionar el volumen MySQL. Ubicado en la raíz del proyecto.

#### Comandos disponibles:

```bash
# Mostrar ayuda completa
./mysql-volume-manager.sh help

# Ver información del volumen
./mysql-volume-manager.sh info

# Crear backup
./mysql-volume-manager.sh backup

# Restaurar desde backup
./mysql-volume-manager.sh restore archivo_backup.tar.gz

# Copiar a otro volumen
./mysql-volume-manager.sh copy nombre_nuevo_volumen

# Limpiar volumen (PELIGROSO)
./mysql-volume-manager.sh clean
```

---

## 📖 Guía de Uso Detallada

### 1. 📊 Verificar estado del volumen

```bash
./mysql-volume-manager.sh info
```

**Salida esperada**:
```
📊 Información del volumen MySQL:
   Nombre: traccar-docker_mysql_data
   Usado por: Desarrollo y Producción

✅ Volumen existe
📁 Contenido del volumen:
total 88652
drwxrwxrwt    8 999      ping          4096 Jul 12 01:45 .
drwxr-xr-x    1 root     root          4096 Jul 12 01:46 ..
-rw-r-----    1 root     root            56 Jul 12 01:45 auto.cnf
...

💾 Tamaño aproximado:
207.3M	/data
```

### 2. 📦 Crear backup

```bash
./mysql-volume-manager.sh backup
```

**Resultado**:
- Genera un archivo: `mysql_backup_YYYYMMDD_HHMMSS.tar.gz`
- El backup se guarda en el directorio actual
- Incluye todos los datos, configuraciones y esquemas

**Ejemplo**:
```bash
$ ./mysql-volume-manager.sh backup
🔄 Haciendo backup del volumen MySQL (traccar-docker_mysql_data)...
✅ Backup completado

$ ls mysql_backup_*
mysql_backup_20250712_094530.tar.gz
```

### 3. 📥 Restaurar desde backup

```bash
./mysql-volume-manager.sh restore mysql_backup_20250712_094530.tar.gz
```

**⚠️ IMPORTANTE**: Este comando sobrescribe todos los datos existentes.

**Proceso**:
1. El script muestra una advertencia
2. Solicita confirmación (y/N)
3. Limpia el volumen actual
4. Restaura los datos del backup

### 4. 📋 Copiar volumen

```bash
# Crear un nuevo volumen primero
docker volume create mi_backup_volumen

# Copiar los datos
./mysql-volume-manager.sh copy mi_backup_volumen
```

**Casos de uso**:
- Crear respaldos en diferentes volúmenes
- Migrar datos a otro entorno
- Duplicar datos para pruebas

### 5. 🗑️ Limpiar volumen

```bash
./mysql-volume-manager.sh clean
```

**⚠️ EXTREMADAMENTE PELIGROSO**: Elimina todos los datos.

**Proceso de seguridad**:
1. Muestra advertencia detallada
2. Requiere escribir exactamente "DELETE"
3. Solo entonces procede con la limpieza

---

## 🔄 Flujos de Trabajo Comunes

### Cambiar entre modos manteniendo datos

```bash
# Trabajando en desarrollo
./start-dev.sh

# Cambiar a modo local
./stop-dev.sh
./start-local.sh

# Los datos se mantienen automáticamente
```

### Backup antes de cambios importantes

```bash
# Crear backup de seguridad
./mysql-volume-manager.sh backup

# Hacer cambios o pruebas
./start-dev.sh
# ... trabajar ...

# Si algo sale mal, restaurar
./stop-dev.sh
./mysql-volume-manager.sh restore mysql_backup_YYYYMMDD_HHMMSS.tar.gz
./start-dev.sh
```

### Migrar datos a otra máquina

```bash
# En la máquina original
./mysql-volume-manager.sh backup
scp mysql_backup_*.tar.gz usuario@nueva-maquina:/ruta/proyecto/

# En la nueva máquina
./mysql-volume-manager.sh restore mysql_backup_YYYYMMDD_HHMMSS.tar.gz
```

---

## 🚨 Precauciones y Mejores Prácticas

### ✅ Recomendaciones

1. **Backup regular**: Crea backups antes de cambios importantes
2. **Parar servicios**: Siempre para Docker antes de operaciones destructivas
3. **Verificar espacio**: Los backups pueden ser grandes (>200MB)
4. **Nombres descriptivos**: Renombra backups importantes con nombres descriptivos

### ⚠️ Advertencias

1. **Comandos destructivos**: `restore` y `clean` eliminan datos existentes
2. **Confirmación requerida**: Lee siempre las advertencias antes de confirmar
3. **Volumen compartido**: Cambios afectan tanto desarrollo como producción
4. **Espacio en disco**: Verifica espacio disponible antes de backups

### 🚫 Problemas comunes

#### "Volumen no existe"
```bash
# Verificar volúmenes disponibles
docker volume ls | grep traccar

# Si el volumen no existe, iniciarlo una vez
./start-local.sh
./stop-local.sh
```

#### "Archivos de redo log corruptos"
```bash
# Limpiar y reiniciar
./mysql-volume-manager.sh clean
./start-local.sh
```

#### "Sin espacio en disco"
```bash
# Limpiar backups antiguos
rm mysql_backup_*.tar.gz

# O mover a otra ubicación
mkdir ~/backups-traccar
mv mysql_backup_*.tar.gz ~/backups-traccar/
```

---

## 📁 Estructura de Archivos

```
traccar-docker/
├── mysql-volume-manager.sh      # Script principal de gestión
├── MYSQL-VOLUME-GUIDE.md        # Esta guía
├── docker-compose.yml           # Configuración modo local
├── docker-compose.dev.yml       # Configuración modo desarrollo
├── start-local.sh               # Iniciar modo local
├── start-dev.sh                 # Iniciar modo desarrollo
└── mysql_backup_*.tar.gz        # Backups generados
```

---

## 🔧 Configuración Técnica

### Volúmenes Docker

```yaml
# En docker-compose.yml y docker-compose.dev.yml
volumes:
  mysql_data:    # Volumen unificado

services:
  traccar-mysql:
    volumes:
      - mysql_data:/var/lib/mysql    # Mismo volumen en ambos modos
```

### Archivos incluidos en backup

- Bases de datos MySQL completas
- Configuraciones del servidor
- Usuarios y permisos
- Esquemas y datos de Traccar
- Archivos de log binarios
- Certificados SSL generados

---

## 📞 Soporte y Troubleshooting

### Comandos de diagnóstico

```bash
# Ver todos los volúmenes de Traccar
docker volume ls | grep traccar

# Ver contenido detallado del volumen
./mysql-volume-manager.sh info

# Ver logs del MySQL
docker logs traccar-mysql

# Ver servicios activos
docker-compose ps
```

### Obtener ayuda

```bash
# Ayuda del script
./mysql-volume-manager.sh help

# Ayuda de Docker Compose
docker-compose --help

# Ver esta guía
cat MYSQL-VOLUME-GUIDE.md
```

---

## 📝 Historial de Cambios

### v1.0 (Julio 2025)
- ✅ Unificación de volúmenes desarrollo/producción
- ✅ Migración automática de datos existentes
- ✅ Script de gestión completo
- ✅ Documentación detallada
- ✅ Comandos de backup y restore
- ✅ Medidas de seguridad implementadas

---

*Este documento es parte del proyecto Traccar Docker y se actualiza regularmente.*
