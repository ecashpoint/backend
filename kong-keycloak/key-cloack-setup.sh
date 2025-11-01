#!/bin/bash

echo "🔐 Esperando a que Keycloak esté listo..."
sleep 20

KEYCLOAK_URL="http://localhost:8180"
ADMIN_USER="admin"
ADMIN_PASS="admin"

# Obtener token de admin
echo "🎫 Obteniendo token de administrador..."
TOKEN=$(curl -s -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
  -d "client_id=admin-cli" \
  -d "username=${ADMIN_USER}" \
  -d "password=${ADMIN_PASS}" \
  -d "grant_type=password" | jq -r '.access_token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    echo "❌ Error: No se pudo obtener el token de administrador"
    exit 1
fi

echo "✅ Token obtenido"

# Crear Realm
echo "🌍 Creando realm 'microservices'..."
curl -s -X POST "${KEYCLOAK_URL}/admin/realms" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "realm": "microservices",
    "enabled": true,
    "displayName": "Microservices Realm",
    "accessTokenLifespan": 3600
  }'

# Crear Client para Kong
echo "🦍 Creando cliente 'kong-client'..."
curl -s -X POST "${KEYCLOAK_URL}/admin/realms/microservices/clients" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "kong-client",
    "enabled": true,
    "publicClient": false,
    "directAccessGrantsEnabled": true,
    "serviceAccountsEnabled": true,
    "standardFlowEnabled": true,
    "protocol": "openid-connect",
    "redirectUris": ["*"],
    "webOrigins": ["*"]
  }'

# Obtener el Client Secret
echo "🔑 Obteniendo Client Secret..."
CLIENT_SECRET=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/microservices/clients" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.[] | select(.clientId=="kong-client") | .secret')

if [ -z "$CLIENT_SECRET" ] || [ "$CLIENT_SECRET" = "null" ]; then
    # Si no existe, obtener el ID del cliente y regenerar el secret
    CLIENT_ID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/microservices/clients" \
      -H "Authorization: Bearer ${TOKEN}" | jq -r '.[] | select(.clientId=="kong-client") | .id')
    
    CLIENT_SECRET=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/microservices/clients/${CLIENT_ID}/client-secret" \
      -H "Authorization: Bearer ${TOKEN}" | jq -r '.value')
fi

echo "🔐 Client Secret: ${CLIENT_SECRET}"

# Crear Roles
echo "👥 Creando roles..."
curl -s -X POST "${KEYCLOAK_URL}/admin/realms/microservices/roles" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"name": "user", "description": "Usuario regular"}'

curl -s -X POST "${KEYCLOAK_URL}/admin/realms/microservices/roles" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"name": "admin", "description": "Administrador"}'

# Crear Usuario de prueba
echo "👤 Creando usuario de prueba..."
curl -s -X POST "${KEYCLOAK_URL}/admin/realms/microservices/users" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "enabled": true,
    "email": "test@example.com",
    "firstName": "Test",
    "lastName": "User",
    "credentials": [{
      "type": "password",
      "value": "test123",
      "temporary": false
    }]
  }'

# Asignar rol 'user' al usuario
USER_ID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/microservices/users?username=testuser" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.[0].id')

ROLE_ID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/microservices/roles" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.[] | select(.name=="user") | .id')

curl -s -X POST "${KEYCLOAK_URL}/admin/realms/microservices/users/${USER_ID}/role-mappings/realm" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "[{\"id\": \"${ROLE_ID}\", \"name\": \"user\"}]"

# Crear Usuario admin
echo "👤 Creando usuario admin..."
curl -s -X POST "${KEYCLOAK_URL}/admin/realms/microservices/users" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "enabled": true,
    "email": "admin@example.com",
    "firstName": "Admin",
    "lastName": "User",
    "credentials": [{
      "type": "password",
      "value": "admin123",
      "temporary": false
    }]
  }'

# Asignar rol 'admin' al usuario admin
ADMIN_USER_ID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/microservices/users?username=admin" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.[0].id')

ADMIN_ROLE_ID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/microservices/roles" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.[] | select(.name=="admin") | .id')

curl -s -X POST "${KEYCLOAK_URL}/admin/realms/microservices/users/${ADMIN_USER_ID}/role-mappings/realm" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "[{\"id\": \"${ADMIN_ROLE_ID}\", \"name\": \"admin\"}]"

echo ""
echo "✅ Keycloak configurado exitosamente!"
echo ""
echo "📋 Información importante:"
echo "   Realm: microservices"
echo "   Client ID: kong-client"
echo "   Client Secret: ${CLIENT_SECRET}"
echo ""
echo "👥 Usuarios de prueba:"
echo "   - testuser / test123 (rol: user)"
echo "   - admin / admin123 (rol: admin)"
echo ""
echo "🔗 URLs:"
echo "   - Keycloak Admin: ${KEYCLOAK_URL}"
echo "   - Token Endpoint: ${KEYCLOAK_URL}/realms/microservices/protocol/openid-connect/token"
echo ""