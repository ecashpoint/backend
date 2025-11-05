# Kong + Keycloak + Microservicios Quarkus con Podman

Infraestructura completa de microservicios usando contenedores individuales de Podman.

## 📋 Requisitos

- Podman instalado
- Al menos 4GB RAM disponible
- Puertos libres: 8000, 8001, 8002, 1337, 8180, 8081, 5433

## 🚀 Inicio Rápido

### 1. Dar permisos de ejecución a los scripts

```bash
chmod +x *.sh
```

### 2. Configurar variables de entorno (opcional)

```bash
# Crear archivo .env o exportar variables
export KEYCLOAK_SECRET="tu-secret-de-keycloak"
export CORS_ORIGINS="http://localhost:3000,http://localhost:8000"
```

### 3. Desplegar toda la infraestructura

```bash
./deploy-all.sh
```

O desplegar componentes individuales:

```bash
./1-create-network.sh
./2-create-volumes.sh
./3-deploy-kong.sh
./4-deploy-konga.sh
./5-deploy-keycloak.sh
./6-deploy-microservices.sh
```

## 🎯 Servicios Disponibles

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| Kong Proxy | http://localhost:8000 | - |
| Kong Admin API | http://localhost:8001 | - |
| Kong Admin GUI | http://localhost:8002 | - |
| Konga UI | http://localhost:1337 | Crear en primer acceso |
| Keycloak | http://localhost:8180 | admin / admin |
| User Service | http://localhost:8081 | Requiere JWT |

## 🛠️ Comandos Útiles

### Ver estado de la infraestructura
```bash
./status.sh
```

### Ver logs de un servicio
```bash
./logs.sh kong-gateway
./logs.sh user-service --follow
```

### Reiniciar un servicio
```bash
./restart-service.sh kong-gateway
```

### Detener todo
```bash
./stop-all.sh
```

### Limpiar todo (incluye datos)
```bash
./cleanup.sh
```

## 🔧 Comandos Podman Individuales

### Listar contenedores
```bash
podman ps -a
```

### Ver logs
```bash
podman logs kong-gateway
podman logs -f user-service  # Seguir logs en tiempo real
```

### Acceder a un contenedor
```bash
podman exec -it kong-gateway bash
podman exec -it postgres-users psql -U user -d userdb
```

### Ver recursos
```bash
podman stats
```

### Inspeccionar contenedor
```bash
podman inspect kong-gateway
```

## 📊 Estructura de Red

```
microservices-net (bridge)
├── kong-db (PostgreSQL 15)
├── kong-gateway (Kong 3.4)
├── konga-db (PostgreSQL 11)
├── konga-admin (Konga)
├── keycloak-db (PostgreSQL 15)
├── keycloak (Keycloak 23.0)
├── postgres-users (PostgreSQL 15)
└── user-service (Quarkus Native)
```

## 💾 Volúmenes Persistentes

- `kong-db` - Datos de Kong
- `konga-db` - Datos de Konga
- `keycloak-db` - Datos de Keycloak
- `users-db` - Datos de usuarios

Para respaldar:
```bash
podman volume export kong-db > kong-db-backup.tar
```

Para restaurar:
```bash
podman volume import kong-db < kong-db-backup.tar
```

## 🔍 Troubleshooting

### Contenedor no inicia
```bash
# Ver logs detallados
./logs.sh <nombre-contenedor>

# Ver eventos del sistema
podman events --filter container=<nombre-contenedor>

# Inspeccionar estado
podman inspect <nombre-contenedor> | grep -A 10 State
```

### Problemas de red
```bash
# Recrear red
podman network rm microservices-net
podman network create microservices-net

# Ver conexiones
podman network inspect microservices-net
```

### Problemas de conectividad entre servicios
```bash
# Verificar DNS interno
podman exec kong-gateway ping -c 3 keycloak
podman exec user-service curl http://keycloak:8080/health
```

### Liberar recursos
```bash
# Limpiar contenedores detenidos
podman container prune -f

# Limpiar imágenes no usadas
podman image prune -a -f

# Limpiar todo
podman system prune -a -f --volumes
```

## 🔐 Configuración de Keycloak

1. Acceder a http://localhost:8180
2. Login: admin / admin
3. Crear realm: `microservices`
4. Crear client: `kong-client`
5. Configurar client:
   - Client Protocol: openid-connect
   - Access Type: confidential
   - Valid Redirect URIs: `*`
   - Copiar el secret del tab "Credentials"
6. Actualizar `KEYCLOAK_SECRET` en el script de microservicios

## 🌐 Configuración de Kong

1. Acceder a Konga: http://localhost:1337
2. Crear cuenta de administrador
3. Conectar a Kong Admin API: http://kong-gateway:8001
4. Agregar servicios y rutas

### Ejemplo: Agregar User Service a Kong
```bash
# Crear servicio
curl -i -X POST http://localhost:8001/services \
  --data name=user-service \
  --data url=http://user-service:8081

# Crear ruta
curl -i -X POST http://localhost:8001/services/user-service/routes \
  --data paths[]=/users
```

## 🧪 Testing

### Verificar Kong
```bash
curl http://localhost:8000
curl http://localhost:8001/services
```

### Verificar Keycloak
```bash
curl http://localhost:8180/health
```

### Verificar User Service
```bash
# Obtener token de Keycloak
TOKEN=$(curl -X POST http://localhost:8180/realms/microservices/protocol/openid-connect/token \
  -d "client_id=kong-client" \
  -d "client_secret=${KEYCLOAK_SECRET}" \
  -d "grant_type=client_credentials" | jq -r '.access_token')

# Llamar al servicio
curl -H "Authorization: Bearer ${TOKEN}" http://localhost:8081/api/users
```

## 📝 Notas

- Los contenedores se reinician automáticamente (`--restart unless-stopped`)
- Los datos persisten en volúmenes nombrados
- La red bridge permite comunicación entre contenedores por nombre
- Health checks configurados para verificar estado de servicios
- Límites de recursos configurados para el user-service (512MB RAM, 1 CPU)

## 🔄 Actualización de Servicios

Para actualizar un servicio:

```bash
# Detener y eliminar contenedor
podman stop user-service
podman rm user-service

# Reconstruir imagen
podman build -t user-service:latest -f user-service/src/main/docker/Dockerfile.native .

# Redesplegar
./6-deploy-microservices.sh
```

## 🆘 Soporte

Para más información sobre Podman:
```bash
podman --help
man podman-run
man podman-network
```