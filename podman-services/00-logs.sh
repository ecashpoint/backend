#!/bin/bash

# Script para ver logs de un servicio
if [ -z "$1" ]; then
  echo "Uso: ./logs.sh <nombre-servicio> [--follow]"
  echo ""
  echo "Servicios disponibles:"
  podman ps --format "  - {{.Names}}" --filter "network=microservices-net"
  exit 1
fi

SERVICE=$1
FOLLOW_FLAG=""

if [ "$2" == "--follow" ] || [ "$2" == "-f" ]; then
  FOLLOW_FLAG="--follow"
fi

if ! podman ps -a --format "{{.Names}}" | grep -q "^${SERVICE}$"; then
  echo "❌ El servicio ${SERVICE} no existe"
  exit 1
fi

echo "📋 Logs de ${SERVICE}:"
echo "================================================"

if [ -n "$FOLLOW_FLAG" ]; then
  podman logs --follow --tail 50 "${SERVICE}"
else
  podman logs --tail 100 "${SERVICE}"
fi