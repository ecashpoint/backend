#!/bin/bash

echo "🛑 Deteniendo todos los contenedores..."

CONTAINERS=(
  "user-service"
  "postgres-users"
  "keycloak"
  "keycloak-db"
  "konga-admin"
  "konga-db"
  "kong-gateway"
  "kong-db"
)

for container in "${CONTAINERS[@]}"; do
  if podman ps -a --format "{{.Names}}" | grep -q "^${container}$"; then
    echo "   Deteniendo ${container}..."
    podman stop "${container}" 2>/dev/null
  fi
done

echo "✅ Todos los contenedores detenidos"
podman ps -a --format "table {{.Names}}\t{{.Status}}"