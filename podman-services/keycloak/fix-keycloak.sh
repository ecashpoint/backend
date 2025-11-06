#!/bin/bash

echo "🔧 Reparando configuración de Keycloak para acceso público..."

# Solicitar IP pública o dominio
echo "Ingresa tu IP pública o dominio (ejemplo: 192.168.1.100 o ejemplo.com):"
read -r PUBLIC_HOST

if [ -z "$PUBLIC_HOST" ]; then
  echo "❌ Debes proporcionar una IP o dominio"
  exit 1
fi

echo ""
echo "📋 Configuración:"
echo "   Host público: $PUBLIC_HOST"
echo "   Puerto: 8180"
echo "   URL: http://$PUBLIC_HOST:8180"
echo ""
echo "¿Continuar? (y/N)"
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Cancelado"
  exit 0
fi

# Detener Keycloak actual
echo "🛑 Deteniendo Keycloak actual..."
podman stop keycloak 2>/dev/null
podman rm keycloak 2>/dev/null

# Reiniciar con nueva configuración
echo "🚀 Iniciando Keycloak con nueva configuración..."
podman run -d \
  --name keycloak \
  --network microservices-net \
  -e KC_DB=postgres \
  -e KC_DB_URL=jdbc:postgresql://keycloak-db:5432/keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=password \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_HTTP_PORT=8080 \
  -e KC_HOSTNAME="$PUBLIC_HOST" \
  -e KC_HOSTNAME_PORT=8180 \
  -e KC_HOSTNAME_STRICT=false \
  -e KC_HOSTNAME_STRICT_HTTPS=false \
  -e KC_HTTP_ENABLED=true \
  -e KC_PROXY=edge \
  -e KC_HEALTH_ENABLED=true \
  -p 8180:8080 \
  --restart unless-stopped \
  quay.io/keycloak/keycloak:23.0 start-dev

echo ""
echo "⏳ Esperando a que Keycloak inicie (puede tomar 30-60 segundos)..."
sleep 10

# Esperar a que Keycloak esté listo
attempt=0
max_attempts=30
while [ $attempt -lt $max_attempts ]; do
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:8180 | grep -q "200\|302\|303"; then
    echo "✅ Keycloak está listo!"
    break
  fi
  attempt=$((attempt + 1))
  echo "   Intento $attempt/$max_attempts..."
  sleep 2
done

if [ $attempt -eq $max_attempts ]; then
  echo "⚠️  Keycloak tardó más de lo esperado. Verifica los logs:"
  echo "   ./logs.sh keycloak"
  exit 1
fi

echo ""
echo "================================"
echo "✅ Keycloak configurado exitosamente"
echo ""
echo "🌐 Accede a:"
echo "   URL: http://$PUBLIC_HOST:8180"
echo "   Admin Console: http://$PUBLIC_HOST:8180/admin"
echo ""
echo "🔑 Credenciales:"
echo "   Usuario: admin"
echo "   Password: admin"
echo ""
echo "💡 Notas importantes:"
echo "   - Los servicios internos seguirán usando http://keycloak:8080"
echo "   - Los clientes externos usarán http://$PUBLIC_HOST:8180"
echo "   - Asegúrate de que el puerto 8180 esté abierto en tu firewall"
echo ""
echo "📋 Para ver logs: ./logs.sh keycloak -f"