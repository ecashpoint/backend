#!/bin/bash

echo "🔐 Desplegando Keycloak..."

# 1. Base de datos Keycloak
echo "📦 Iniciando Keycloak Database..."
podman run -d \
  --name keycloak-db \
  --network microservices-net \
  -e POSTGRES_DB=keycloak \
  -e POSTGRES_USER=keycloak \
  -e POSTGRES_PASSWORD=password \
  -v keycloak-db:/var/lib/postgresql/data \
  --health-cmd "pg_isready -U keycloak" \
  --health-interval 10s \
  --health-timeout 5s \
  --health-retries 5 \
  postgres:15

# Esperar a que la BD esté lista
echo "⏳ Esperando a que Keycloak DB esté lista..."
sleep 10
until podman exec keycloak-db pg_isready -U keycloak > /dev/null 2>&1; do
  echo "   Esperando conexión a Keycloak DB..."
  sleep 2
done
echo "✅ Keycloak DB lista"

# 2. Keycloak
# Detectar IP pública o usar variable de entorno
PUBLIC_IP="${PUBLIC_IP:-$(curl -s ifconfig.me 2>/dev/null || echo 'localhost')}"

echo "🚀 Iniciando Keycloak..."
echo "   Usando hostname: ${PUBLIC_IP}"

podman run -d \
  --name keycloak \
  --network microservices-net \
  -e KC_DB=postgres \
  -e KC_DB_URL=jdbc:postgresql://keycloak-db:5432/keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_HTTP_PORT=8080 \
  -e KC_HOSTNAME="${PUBLIC_IP}" \
  -e KC_HOSTNAME_PORT=8180 \
  -e KC_HOSTNAME_STRICT=false \
  -e KC_HOSTNAME_STRICT_HTTPS=false \
  -e KC_HTTP_ENABLED=true \
  -e KC_PROXY=edge \
  -p 8180:8080 \
  --restart unless-stopped \
  quay.io/keycloak/keycloak:23.0 start-dev

echo "✅ Keycloak desplegado"
echo "   - UI: http://localhost:8180"
echo "   - Admin: admin / admin"