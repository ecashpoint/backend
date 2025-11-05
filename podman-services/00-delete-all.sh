#!/bin/bash

echo "🧹 Limpiando contenedores, volúmenes y red..."
echo "⚠️  Esto eliminará TODOS los datos. ¿Continuar? (y/N)"
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Cancelado"
  exit 0
fi

# Detener contenedores
echo "🛑 Deteniendo contenedores..."
./stop-all.sh

# Eliminar contenedores
echo "🗑️  Eliminando contenedores..."
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
    echo "   Eliminando ${container}..."
    podman rm -f "${container}" 2>/dev/null
  fi
done

# Eliminar volúmenes (opcional)
echo ""
echo "¿Eliminar volúmenes de datos? (y/N)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
  echo "🗑️  Eliminando volúmenes..."
  podman volume rm kong-db konga-db keycloak-db users-db 2>/dev/null
fi

# Eliminar red
echo "🗑️  Eliminando red..."
podman network rm microservices-net 2>/dev/null

echo "✅ Limpieza completada"