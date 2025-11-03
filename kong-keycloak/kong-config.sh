#!/bin/bash

echo "🦍 Esperando a que Kong esté listo..."
sleep 15

KONG_ADMIN_URL="http://localhost:8001"

echo "📝 Configurando servicios en Kong..."

# ============================================
# USER SERVICE
# ============================================
echo "👤 Configurando User Service..."

curl -i -X POST ${KONG_ADMIN_URL}/services \
  --data name=user-service \
  --data url=http://user-service:8081

curl -i -X POST ${KONG_ADMIN_URL}/services/user-service/routes \
  --data 'paths[]=/api/users_data' \
  --data 'name=user-route' \
  --data 'strip_path=false'

# ============================================
# PLUGINS GLOBALES
# ============================================
echo "🔌 Configurando plugins globales..."

# CORS
echo "🌐 Habilitando CORS..."
curl -i -X POST ${KONG_ADMIN_URL}/plugins \
  --data name=cors \
  --data config.origins=* \
  --data config.methods=GET \
  --data config.methods=POST \
  --data config.methods=PUT \
  --data config.methods=DELETE \
  --data config.methods=OPTIONS \
  --data config.headers=Accept \
  --data config.headers=Authorization \
  --data config.headers=Content-Type \
  --data config.exposed_headers=Authorization \
  --data config.credentials=true \
  --data config.max_age=3600

# Rate Limiting
echo "⏱️ Configurando Rate Limiting..."
curl -i -X POST ${KONG_ADMIN_URL}/plugins \
  --data name=rate-limiting \
  --data config.minute=100 \
  --data config.hour=1000 \
  --data config.policy=local

# Request Transformer (opcional - limpieza de headers)
echo "🔄 Configurando Request Transformer..."
curl -i -X POST ${KONG_ADMIN_URL}/plugins \
  --data name=request-transformer \
  --data config.remove.headers=X-Kong-Request-Id

# Logging
echo "📊 Configurando HTTP Log..."
curl -i -X POST ${KONG_ADMIN_URL}/plugins \
  --data name=file-log \
  --data config.path=/tmp/kong.log

# ============================================
# JWT PLUGIN (Se configurará después de Keycloak)
# ============================================
echo "🔐 JWT se configurará después de Keycloak..."

echo ""
echo "✅ Kong configurado exitosamente!"
echo ""
echo "📋 Resumen de endpoints:"
echo "   - User Service:    http://localhost:8000/api/users"
echo ""
echo "🎛️ Admin UIs:"
echo "   - Kong Admin API:  http://localhost:8001"
echo "   - Konga:           http://localhost:1337"
echo "   - Keycloak:        http://localhost:8180"
echo ""