#!/bin/bash

echo "🚀 Desplegando toda la infraestructura..."
echo "==========================================="

# 1. Red
./1-create-network.sh
echo ""

# 2. Volúmenes
./2-create-volumes.sh
echo ""

# 3. Kong
./3-deploy-kong.sh
echo ""

# 4. Konga
./4-deploy-konga.sh
echo ""

# 5. Keycloak
./5-deploy-keycloak.sh
echo ""

# 6. Microservicios
./6-deploy-microservices.sh
echo ""

echo "==========================================="
echo "✅ Despliegue completado"
echo ""
echo "📋 Estado de contenedores:"
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "🌐 Servicios disponibles:"
echo "   - Kong Proxy:      http://localhost:8000"
echo "   - Kong Admin:      http://localhost:8001"
echo "   - Kong Admin GUI:  http://localhost:8002"
echo "   - Konga UI:        http://localhost:1337"
echo "   - Keycloak:        http://localhost:8180"
echo "   - User Service:    http://localhost:8081"
echo ""
echo "💡 Tip: Ejecuta './status.sh' para ver el estado completo"