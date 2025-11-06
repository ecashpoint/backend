#!/bin/bash

# Script para desplegar Keycloak en modo producción con configuración pública

echo "🔐 Desplegando Keycloak (Modo Producción)..."
echo ""

# Solicitar configuración
read -p "Ingresa tu IP pública o dominio (ej: 192.168.1.100): " PUBLIC_HOST
read -p "Puerto externo (default: 8180): " PUBLIC_PORT
PUBLIC_PORT=${PUBLIC_PORT:-8180}

read -p "Usuario admin (default: admin): " ADMIN_USER
ADMIN_USER=${ADMIN_USER:-admin}

read -sp "Password admin (default: admin): " ADMIN_PASSWORD
echo ""
ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin}

echo ""
echo "📋 Configuración:"
echo "   Host: $PUBLIC_HOST"
echo "   Puerto: $PUBLIC_PORT"
echo "   URL: http://$PUBLIC_HOST:$PUBLIC_PORT"
echo "   Admin: $ADMIN_USER"
echo ""
read -p "¿Continuar? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelado"
  exit 1
fi

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
echo "🚀 Iniciando Keycloak..."
podman run -d \
  --name keycloak \
  --network microservices-net \
  -e KC_DB=postgres \
  -e KC_DB_URL=jdbc:postgresql://keycloak-db:5432/keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KEYCLOAK_ADMIN="$ADMIN_USER" \
  -e KEYCLOAK_ADMIN_PASSWORD="$ADMIN_PASSWORD" \
  -e KC_HTTP_PORT=8080 \
  -e KC_HOSTNAME="$PUBLIC_HOST" \
  -e KC_HOSTNAME_PORT="$PUBLIC_PORT" \
  -e KC_HOSTNAME_STRICT=false \
  -e KC_HOSTNAME_STRICT_HTTPS=false \
  -e KC_HTTP_ENABLED=true \
  -e KC_PROXY=edge \
  -e KC_HEALTH_ENABLED=true \
  -e KC_METRICS_ENABLED=true \
  -p "$PUBLIC_PORT:8080" \
  --restart unless-stopped \
  quay.io/keycloak/keycloak:23.0 start-dev

echo "⏳ Esperando a que Keycloak inicie..."
sleep 15

# Verificar que Keycloak esté listo
attempt=0
max_attempts=30
while [ $attempt -lt $max_attempts ]; do
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:$PUBLIC_PORT | grep -q "200\|302\|303"; then
    echo "✅ Keycloak está listo!"
    break
  fi
  attempt=$((attempt + 1))
  echo "   Intento $attempt/$max_attempts..."
  sleep 2
done

if [ $attempt -eq $max_attempts ]; then
  echo "⚠️  Keycloak tardó más de lo esperado."
  echo "Verifica los logs: ./logs.sh keycloak"
else
  echo ""
  echo "================================"
  echo "✅ Keycloak desplegado exitosamente"
  echo ""
  echo "🌐 URLs de acceso:"
  echo "   Principal: http://$PUBLIC_HOST:$PUBLIC_PORT"
  echo "   Admin Console: http://$PUBLIC_HOST:$PUBLIC_PORT/admin"
  echo "   Health: http://$PUBLIC_HOST:$PUBLIC_PORT/health"
  echo ""
  echo "🔑 Credenciales:"
  echo "   Usuario: $ADMIN_USER"
  echo "   Password: ****** (la que configuraste)"
  echo ""
  echo "📝 Próximos pasos:"
  echo "   1. Accede a la Admin Console"
  echo "   2. Crea un realm llamado 'microservices'"
  echo "   3. Crea un client llamado 'kong-client'"
  echo "   4. Configura el client como 'confidential'"
  echo "   5. Copia el secret y actualiza KEYCLOAK_SECRET"
  echo ""
  echo "💡 Para servicios internos, usa: http://keycloak:8080"
  echo "💡 Para acceso externo, usa: http://$PUBLIC_HOST:$PUBLIC_PORT"
fi