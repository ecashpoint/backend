#!/bin/bash

echo "🦍 Desplegando Kong Gateway + Database..."

# 1. Base de datos Kong
echo "📦 Iniciando Kong Database..."
podman run -d \
  --name kong-db \
  --network microservices-net \
  -e POSTGRES_USER=kong \
  -e POSTGRES_DB=kong \
  -e POSTGRES_PASSWORD=kong \
  -v kong-db:/var/lib/postgresql/data \
  --health-cmd "pg_isready -U kong" \
  --health-interval 10s \
  --health-timeout 5s \
  --health-retries 5 \
  postgres:15

# Esperar a que la BD esté lista
echo "⏳ Esperando a que Kong DB esté lista..."
sleep 10
until podman exec kong-db pg_isready -U kong > /dev/null 2>&1; do
  echo "   Esperando conexión a Kong DB..."
  sleep 2
done
echo "✅ Kong DB lista"

# 2. Migración de Kong
echo "🔄 Ejecutando migraciones de Kong..."
podman run --rm \
  --name kong-migration \
  --network microservices-net \
  -e KONG_DATABASE=postgres \
  -e KONG_PG_HOST=kong-db \
  -e KONG_PG_USER=kong \
  -e KONG_PG_PASSWORD=kong \
  kong:3.4 kong migrations bootstrap

# 3. Kong Gateway
echo "🚀 Iniciando Kong Gateway..."
podman run -d \
  --name kong-gateway \
  --network microservices-net \
  -e KONG_DATABASE=postgres \
  -e KONG_PG_HOST=kong-db \
  -e KONG_PG_USER=kong \
  -e KONG_PG_PASSWORD=kong \
  -e KONG_PROXY_ACCESS_LOG=/dev/stdout \
  -e KONG_ADMIN_ACCESS_LOG=/dev/stdout \
  -e KONG_PROXY_ERROR_LOG=/dev/stderr \
  -e KONG_ADMIN_ERROR_LOG=/dev/stderr \
  -e KONG_ADMIN_LISTEN=0.0.0.0:8001 \
  -e KONG_ADMIN_GUI_URL=http://localhost:8002 \
  -p 8000:8000 \
  -p 8443:8443 \
  -p 8001:8001 \
  -p 8002:8002 \
  --health-cmd "kong health" \
  --health-interval 10s \
  --health-timeout 10s \
  --health-retries 10 \
  --restart unless-stopped \
  kong:3.4

echo "✅ Kong desplegado"
echo "   - Proxy: http://localhost:8000"
echo "   - Admin API: http://localhost:8001"
echo "   - Admin GUI: http://localhost:8002"