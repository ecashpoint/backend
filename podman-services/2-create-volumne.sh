#!/bin/bash

# Crear volúmenes persistentes
echo "💾 Creando volúmenes..."

podman volume create kong-db 2>/dev/null || echo "kong-db ya existe"
podman volume create konga-db 2>/dev/null || echo "konga-db ya existe"
podman volume create keycloak-db 2>/dev/null || echo "keycloak-db ya existe"
podman volume create users-db 2>/dev/null || echo "users-db ya existe"

echo "✅ Volúmenes creados/verificados"
podman volume ls | grep -E "(kong|konga|keycloak|users)-db"