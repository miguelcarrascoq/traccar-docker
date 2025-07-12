# 🛠️ Herramientas de Gestión MySQL - Referencia Rápida

## 📋 Comandos Principales

### Información del volumen
```bash
./mysql-volume-manager.sh info
```
**Resultado**: Muestra estado, contenido y tamaño del volumen.

### Crear backup
```bash
./mysql-volume-manager.sh backup
```
**Resultado**: Genera `mysql_backup_YYYYMMDD_HHMMSS.tar.gz` en el directorio actual.

### Restaurar backup
```bash
./mysql-volume-manager.sh restore archivo_backup.tar.gz
```
**⚠️ Advertencia**: Sobrescribe todos los datos existentes.

### Copiar volumen
```bash
docker volume create nuevo_volumen
./mysql-volume-manager.sh copy nuevo_volumen
```
**Resultado**: Copia todos los datos al nuevo volumen.

### Limpiar volumen
```bash
./mysql-volume-manager.sh clean
```
**⚠️ PELIGROSO**: Elimina todos los datos. Requiere escribir "DELETE".

---

## 🚀 Casos de Uso Rápidos

### Backup de seguridad antes de cambios
```bash
./mysql-volume-manager.sh backup
# Resultado: mysql_backup_20250712_143022.tar.gz
```

### Cambiar entre modos sin perder datos
```bash
# De desarrollo a local
./stop-dev.sh
./start-local.sh

# De local a desarrollo  
./stop-local.sh
./start-dev.sh
```

### Recuperar datos después de error
```bash
./stop-local.sh  # o ./stop-dev.sh
./mysql-volume-manager.sh restore mysql_backup_20250712_143022.tar.gz
./start-local.sh  # o ./start-dev.sh
```

### Migrar a otra máquina
```bash
# Máquina origen
./mysql-volume-manager.sh backup
scp mysql_backup_*.tar.gz user@destino:/ruta/

# Máquina destino
./mysql-volume-manager.sh restore mysql_backup_*.tar.gz
```

---

## ⚡ Referencia de Opciones

| Comando | Descripción | Seguridad | Tiempo estimado |
|---------|-------------|-----------|-----------------|
| `info` | Ver información | ✅ Seguro | < 5 segundos |
| `backup` | Crear backup | ✅ Seguro | 30-60 segundos |
| `restore` | Restaurar backup | ⚠️ Destructivo | 60-120 segundos |
| `copy` | Copiar a otro volumen | ✅ Seguro | 60-120 segundos |
| `clean` | Limpiar volumen | 🚨 Peligroso | 10-30 segundos |

---

## 🔧 Troubleshooting Rápido

### Error: "Volumen no existe"
```bash
docker volume ls | grep traccar
# Si no aparece, iniciar una vez:
./start-local.sh && ./stop-local.sh
```

### Error: "Archivos corruptos"
```bash
./mysql-volume-manager.sh clean
./start-local.sh
```

### Error: "Sin espacio"
```bash
rm mysql_backup_*.tar.gz  # Eliminar backups antiguos
```

---

## 📊 Estado Actual del Sistema

**Volumen unificado**: `traccar-docker_mysql_data`  
**Modos soportados**: Desarrollo (`start-dev.sh`) y Local (`start-local.sh`)  
**Datos compartidos**: ✅ Sí, ambos modos usan el mismo volumen  
**Backups automáticos**: ❌ No, usar comando manual  

---

*Para documentación completa ver: [MYSQL-VOLUME-GUIDE.md](MYSQL-VOLUME-GUIDE.md)*
