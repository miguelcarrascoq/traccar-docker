# Desarrollo con Código Fuente

Este documento explica cómo trabajar con el código fuente de Traccar antes de la compilación.

## 🎯 Alternativas Disponibles

### 1. Entorno de Desarrollo Completo (Recomendado)

Usa `docker-compose.dev.yml` para un entorno completo con hot-reload:

```bash
# Iniciar entorno de desarrollo
./start-dev.sh

# Detener entorno de desarrollo  
./stop-dev.sh
```

**Características:**
- ✅ Hot reload automático en frontend
- ✅ Código fuente editable en `./src/`
- ✅ MySQL y phpMyAdmin incluidos
- ✅ Configuración lista para desarrollo

**Archivos modificables:**
- `./src/traccar-web/` - Código del frontend
- `./src/traccar-backend/` - Código del backend

### 2. Clonar Fuentes Manualmente

Si solo necesitas el código fuente:

```bash
# Clonar repositorios
./clone-sources.sh
```

**Características:**
- ✅ Acceso directo al código fuente
- ✅ Control total sobre las versiones
- ✅ Ideal para desarrollo local con tu IDE

## 🚀 Inicio Rápido

### Para Desarrollo Completo:

1. **Configurar variables de entorno** (opcional):
   ```bash
   cp .env.example .env
   # Edita .env con tus configuraciones
   ```

2. **Iniciar entorno de desarrollo**:
   ```bash
   ./start-dev.sh
   ```

3. **Acceder a los servicios**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8082  
   - phpMyAdmin: http://localhost:8080

4. **Editar código**:
   - Frontend: `./src/traccar-web/`
   - Backend: `./src/traccar-backend/`

### Para Solo Código Fuente:

```bash
./clone-sources.sh
```

## 📁 Estructura de Archivos

```
traccar-docker/
├── src/                          # Código fuente (desarrollo)
│   ├── traccar-web/             # Frontend React
│   └── traccar-backend/         # Backend Java
├── docker-compose.yml           # Producción
├── docker-compose.dev.yml       # Desarrollo
├── Dockerfile.frontend.dev      # Frontend desarrollo
├── Dockerfile.backend.dev       # Backend desarrollo
├── Dockerfile.source           # Para clonar fuentes
├── start-dev.sh                # Iniciar desarrollo
├── stop-dev.sh                 # Detener desarrollo
└── clone-sources.sh            # Clonar solo fuentes
```

## 🛠️ Comandos Útiles

### Ver logs en tiempo real:
```bash
docker-compose -f docker-compose.dev.yml logs -f
```

### Reiniciar un servicio específico:
```bash
docker-compose -f docker-compose.dev.yml restart traccar-frontend-dev
```

### Acceder al contenedor:
```bash
docker exec -it traccar-frontend-dev sh
```

### Actualizar dependencias:
```bash
# Frontend
docker exec -it traccar-frontend-dev npm install

# Backend  
docker exec -it traccar-backend-dev mvn clean install
```

## 🔧 Personalización

### Variables de Entorno (.env):

```bash
# Puertos
FRONTEND_PORT=3000
BACKEND_PORT=8082
MYSQL_PORT=3306

# Repositorios Git
GIT_FRONTEND_REPO_URL=https://github.com/tu-org/traccar-web.git
GIT_BACKEND_REPO_URL=https://github.com/tu-org/traccar.git

# Credenciales (para repos privados)
GIT_USERNAME=tu_usuario
GIT_PASSWORD=tu_token_personal

# Ramas específicas
GIT_FRONTEND_BRANCH=feature/nueva-funcionalidad
GIT_BACKEND_BRANCH=develop
```

### Modificar Dockerfiles:

- `Dockerfile.frontend.dev` - Configuración frontend desarrollo
- `Dockerfile.backend.dev` - Configuración backend desarrollo
- `Dockerfile.source` - Cómo se clonan las fuentes

## 🐛 Troubleshooting

### El código no se actualiza automáticamente:
```bash
# Verificar que los volúmenes estén montados
docker-compose -f docker-compose.dev.yml ps
```

### Errores de permisos:
```bash
# Cambiar propietario de src/
sudo chown -R $USER:$USER src/
```

### Puertos ocupados:
```bash
# Cambiar puertos en .env
FRONTEND_PORT=3001
BACKEND_PORT=8083
```

## 📚 Recursos Adicionales

- [Traccar Documentation](https://www.traccar.org/documentation/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [React Development](https://reactjs.org/docs/getting-started.html)
