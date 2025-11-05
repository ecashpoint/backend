#!/bin/bash

echo "🎨 Desplegando Konga Admin UI..."

# 1. Base de datos Konga
echo "📦 Iniciando Konga Database..."
podman run -d \
  --name konga-db \
  --network microservices-net \
  -e POSTGRES_DB=konga \
  -e POSTGRES_USER=konga \
  -e POSTGRES_PASSWORD=kongapass \
  -v konga-db:/var/lib/postgresql/data \
  --health-cmd "pg_isready -U konga" \
  --health-interval 10s \
  --health-timeout 5s \
  --health-retries 5 \
  --restart unless-stopped \
  postgres:11-alpine

# Esperar a que la BD esté lista
echo "⏳ Esperando a que Konga DB esté lista..."
sleep 8
until podman exec konga-db pg_isready -U konga > /dev/null 2>&1; do
  echo "   Esperando conexión a Konga DB..."
  sleep 2
done
echo "✅ Konga DB lista"

# 2. Preparación de Konga
echo "🔧 Preparando base de datos de Konga..."
podman run --rm \
  --name konga-prepare \
  --network microservices-net \
  pantsel/konga:latest \
  -c prepare -a postgres -u postgresql://konga:kongapass@konga-db:5432/konga

# 3. Konga Admin UI
echo "🚀 Iniciando Konga..."
podman run -d \
  --name konga-admin \
  --network microservices-net \
  -e NODE_ENV=production \
  -e DB_ADAPTER=postgres \
  -e DB_HOST=konga-db \
  -e DB_PORT=5432 \
  -e DB_USER=konga \
  -e DB_PASSWORD=kongapass \
  -e DB_DATABASE=konga \
  -e TOKEN_SECRET=algunos-secretos-aleatorios-2024 \
  -e NO_AUTH=false \
  -p 1337:1337 \
  --restart unless-stopped \
  pantsel/konga:latest

echo "✅ Konga desplegado"
echo "   - UI: http://localhost:1337"