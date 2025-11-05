#!/bin/bash

# Variables de configuración
KEYCLOAK_SECRET="${KEYCLOAK_SECRET:-your-keycloak-secret-here}"
CORS_ORIGINS="${CORS_ORIGINS:-http://localhost:3000,http://localhost:8000}"

echo "🚀 Desplegando Microservicios Quarkus..."

# 1. Base de datos de usuarios
echo "📦 Iniciando Users Database..."
podman run -d \
  --name postgres-users \
  --network microservices-net \
  -e POSTGRES_DB=userdb \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=password \
  -v users-db:/var/lib/postgresql/data \
  -p 5433:5432 \
  --health-cmd "pg_isready -U user" \
  --health-interval 10s \
  --health-timeout 5s \
  --health-retries 5 \
  postgres:15

# Esperar a que la BD esté lista
echo "⏳ Esperando a que Users DB esté lista..."
sleep 10
until podman exec postgres-users pg_isready -U user > /dev/null 2>&1; do
  echo "   Esperando conexión a Users DB..."
  sleep 2
done
echo "✅ Users DB lista"

# 2. User Service (Quarkus)
echo "🔨 Construyendo User Service..."
# Asegúrate de que la imagen esté construida
if ! podman image exists user-service:latest; then
  echo "⚠️  Construyendo imagen user-service..."
  podman build -t user-service:latest \
    -f user-service/src/main/docker/Dockerfile.native \
    .
fi

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

echo "✅ User Service desplegado"
echo "   - API: http://localhost:8081"