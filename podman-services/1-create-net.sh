#!/bin/bash

# Crear red para microservicios
echo "🌐 Creando red de microservicios..."
podman network create microservices-net 2>/dev/null || echo "Red ya existe"

echo "✅ Red creada/verificada"
podman network ls | grep microservices-net