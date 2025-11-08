#!/bin/bash

# Variables de configuración
KEYCLOAK_SECRET="${KEYCLOAK_SECRET:-DpFiK95G8T8G1avCgWrSHRTGWLm13sAQ}"
CORS_ORIGINS="${CORS_ORIGINS:-http://localhost:3000,http://localhost:8000}"

echo "🔄 Reconstruyendo User Service..."

# 1. Detener y eliminar contenedor
echo "🛑 Deteniendo contenedor anterior..."
podman stop user-service 2>/dev/null || true
podman rm -f user-service 2>/dev/null || true

# 2. Reconstruir imagen
echo "🔨 Reconstruyendo imagen User Service..."
podman rmi user-service:latest 2>/dev/null || true
podman build -t user-service:latest \
  --no-cache \
  -f src/main/docker/Dockerfile.native \
  .

# 3. Reiniciar User Service
echo "🚀 Iniciando User Service..."
podman run -d \
  --name user-service \
  --network microservices-net \
  -e QUARKUS_HTTP_PORT=8081 \
  -e QUARKUS_DATASOURCE_JDBC_URL=jdbc:postgresql://postgres-users:5432/userdb \
  -e QUARKUS_DATASOURCE_USERNAME=user \
  -e QUARKUS_DATASOURCE_PASSWORD=password \
  -e QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION=update \
  -e QUARKUS_HIBERNATE_ORM_LOG_SQL=false \
  -e QUARKUS_OIDC_AUTH_SERVER_URL=http://keycloak:8080/realms/microservices \
  -e QUARKUS_OIDC_CLIENT_ID=kong-client \
  -e QUARKUS_OIDC_CREDENTIALS_SECRET="${KEYCLOAK_SECRET}" \
  -e QUARKUS_OIDC_TLS_VERIFICATION=none \
  -e QUARKUS_OIDC_APPLICATION_TYPE=service \
  -e QUARKUS_OIDC_CONNECTION_TIMEOUT=30S \
  -e QUARKUS_OIDC_ENABLED=true \
  -e MP_JWT_VERIFY_PUBLICKEY_LOCATION=http://keycloak:8080/realms/microservices/protocol/openid-connect/certs \
  -e MP_JWT_VERIFY_ISSUER=http://keycloak:8080/realms/microservices \
  -e QUARKUS_HTTP_AUTH_PERMISSION_AUTHENTICATED_PATHS=/* \
  -e QUARKUS_HTTP_AUTH_PERMISSION_AUTHENTICATED_POLICY=authenticated \
  -e QUARKUS_HTTP_CORS=true \
  -e QUARKUS_HTTP_CORS_ORIGINS="${CORS_ORIGINS}" \
  -e QUARKUS_HTTP_CORS_METHODS=GET,PUT,POST,DELETE,OPTIONS \
  -e QUARKUS_HTTP_CORS_HEADERS=accept,authorization,content-type \
  -e QUARKUS_HTTP_CORS_EXPOSED_HEADERS=Content-Disposition \
  -e QUARKUS_LOG_LEVEL=INFO \
  -e QUARKUS_LOG_CATEGORY_COM_EXAMPLE_LEVEL=INFO \
  -p 8081:8081 \
  --health-cmd "curl -f http://localhost:8081/health/ready || exit 1" \
  --health-interval 30s \
  --health-timeout 10s \
  --health-retries 3 \
  --health-start-period 60s \
  --cpus 1.0 \
  --memory 512m \
  --restart unless-stopped \
  user-service:latest

# 4. Verificar estado
echo ""
echo "⏳ Esperando que el servicio esté listo..."
sleep 5
podman ps --filter "name=user-service"

echo ""
echo "✅ Reconstrucción completada"
echo "   - API: http://localhost:8081"
echo "   - Health: http://localhost:8081/health"
echo ""
echo "💡 Para ver logs: podman logs -f user-service"