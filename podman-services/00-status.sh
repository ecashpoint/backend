#!/bin/bash

echo "📊 Estado de la Infraestructura"
echo "================================"
echo ""

# Contenedores
echo "📦 CONTENEDORES:"
podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "network=microservices-net"
echo ""

# Red
echo "🌐 RED:"
podman network inspect microservices-net 2>/dev/null | grep -A 1 "Name" || echo "Red no encontrada"
echo ""

# Volúmenes
echo "💾 VOLÚMENES:"
podman volume ls --format "table {{.Name}}\t{{.Mountpoint}}" | grep -E "(kong|konga|keycloak|users)-db"
echo ""

# Health checks
echo "🏥 HEALTH STATUS:"
for container in kong-gateway keycloak user-service; do
  if podman ps --format "{{.Names}}" | grep -q "^${container}$"; then
    health=$(podman inspect "${container}" --format='{{.State.Health.Status}}' 2>/dev/null || echo "no healthcheck")
    echo "   ${container}: ${health}"
  fi
done
echo ""

# URLs de acceso
echo "🌐 SERVICIOS:"
echo "   Kong Proxy:      http://localhost:8000"
echo "   Kong Admin:      http://localhost:8001"
echo "   Kong Admin GUI:  http://localhost:8002"
echo "   Konga UI:        http://localhost:1337"
echo "   Keycloak:        http://localhost:8180"
echo "   User Service:    http://localhost:8081"
echo ""

# Logs recientes
echo "📋 LOGS RECIENTES (últimas 5 líneas por servicio):"
for container in kong-gateway keycloak user-service; do
  if podman ps --format "{{.Names}}" | grep -q "^${container}$"; then
    echo ""
    echo "--- ${container} ---"
    podman logs --tail 5 "${container}" 2>&1 | head -5
  fi
done