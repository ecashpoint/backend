#!/bin/bash

# Script para reiniciar un servicio específico
if [ -z "$1" ]; then
  echo "Uso: ./restart-service.sh <nombre-servicio>"
  echo ""
  echo "Servicios disponibles:"
  echo "  - kong-gateway"
  echo "  - keycloak"
  echo "  - konga-admin"
  echo "  - user-service"
  echo "  - kong-db"
  echo "  - keycloak-db"
  echo "  - konga-db"
  echo "  - postgres-users"
  exit 1
fi

SERVICE=$1

echo "🔄 Reiniciando ${SERVICE}..."

if ! podman ps -a --format "{{.Names}}" | grep -q "^${SERVICE}$"; then
  echo "❌ El servicio ${SERVICE} no existe"
  exit 1
fi

podman restart "${SERVICE}"

echo "✅ ${SERVICE} reiniciado"
echo ""
echo "📋 Estado:"
podman ps --filter "name=${SERVICE}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Mostrar logs recientes
echo ""
echo "📋 Logs recientes:"
podman logs --tail 20 "${SERVICE}"