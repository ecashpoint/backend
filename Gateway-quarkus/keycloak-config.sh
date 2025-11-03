
# ============================================
# keycloak-config.sh - Configuración de Keycloak
# ============================================

#!/bin/bash

set -e

KEYCLOAK_URL="http://localhost:9090"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin123"
REALM_NAME="mi-app"

echo "🔐 Configurando Keycloak..."

# Obtener token de admin
echo "  Obteniendo token de administrador..."
TOKEN=$(curl -s -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=${ADMIN_USER}" \
  -d "password=${ADMIN_PASSWORD}" \
  -d "grant_type=password" \
  -d "client_id=admin-cli" | jq -r '.access_token')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo "❌ Error al obtener token"
    exit 1
fi

echo "  ✓ Token obtenido"

# Crear Realm
echo "  Creando realm '$REALM_NAME'..."
curl -s -X POST "${KEYCLOAK_URL}/admin/realms" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "realm": "'${REALM_NAME}'",
    "enabled": true,
    "sslRequired": "none",
    "registrationAllowed": true,
    "loginWithEmailAllowed": true,
    "duplicateEmailsAllowed": false,
    "resetPasswordAllowed": true,
    "editUsernameAllowed": false,
    "bruteForceProtected": true
  }'

echo "  ✓ Realm creado"

# Crear roles
echo "  Creando roles..."
for role in user admin manager; do
  curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/roles" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"name": "'${role}'", "description": "Role '${role}'"}'
done

echo "  ✓ Roles creados"

# Crear cliente API Gateway
echo "  Creando cliente API Gateway..."
curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/clients" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "api-gateway",
    "enabled": true,
    "clientAuthenticatorType": "client-secret",
    "secret": "gateway-secret-123",
    "redirectUris": ["http://localhost:8080/*"],
    "webOrigins": ["+"],
    "protocol": "openid-connect",
    "publicClient": false,
    "serviceAccountsEnabled": true,
    "authorizationServicesEnabled": true,
    "directAccessGrantsEnabled": true,
    "standardFlowEnabled": true
  }'

echo "  ✓ Cliente API Gateway creado"

# Crear cliente Backend Service 1
echo "  Creando cliente Backend Service 1..."
curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/clients" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "backend-service-1",
    "enabled": true,
    "clientAuthenticatorType": "client-secret",
    "secret": "service1-secret-123",
    "redirectUris": ["http://localhost:8081/*"],
    "webOrigins": ["+"],
    "protocol": "openid-connect",
    "publicClient": false,
    "serviceAccountsEnabled": true,
    "directAccessGrantsEnabled": true,
    "bearerOnly": false
  }'

echo "  ✓ Cliente Backend Service 1 creado"

# Crear cliente Backend Service 2
echo "  Creando cliente Backend Service 2..."
curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/clients" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "backend-service-2",
    "enabled": true,
    "clientAuthenticatorType": "client-secret",
    "secret": "service2-secret-123",
    "redirectUris": ["http://localhost:8082/*"],
    "webOrigins": ["+"],
    "protocol": "openid-connect",
    "publicClient": false,
    "serviceAccountsEnabled": true,
    "directAccessGrantsEnabled": true,
    "bearerOnly": false
  }'

echo "  ✓ Cliente Backend Service 2 creado"

# Crear cliente Angular
echo "  Creando cliente Angular..."
curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/clients" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "angular-client",
    "enabled": true,
    "publicClient": true,
    "redirectUris": ["http://localhost:4200/*"],
    "webOrigins": ["http://localhost:4200"],
    "protocol": "openid-connect",
    "standardFlowEnabled": true,
    "implicitFlowEnabled": false,
    "directAccessGrantsEnabled": true
  }'

echo "  ✓ Cliente Angular creado"

# Crear cliente Android
echo "  Creando cliente Android..."
curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/clients" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "android-client",
    "enabled": true,
    "publicClient": true,
    "redirectUris": ["com.miapp://oauth2callback"],
    "protocol": "openid-connect",
    "standardFlowEnabled": true,
    "directAccessGrantsEnabled": true
  }'

echo "  ✓ Cliente Android creado"

# Crear cliente iOS
echo "  Creando cliente iOS..."
curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/clients" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "ios-client",
    "enabled": true,
    "publicClient": true,
    "redirectUris": ["com.miapp://oauth2callback"],
    "protocol": "openid-connect",
    "standardFlowEnabled": true,
    "directAccessGrantsEnabled": true
  }'

echo "  ✓ Cliente iOS creado"

# Crear usuarios de prueba
echo "  Creando usuarios de prueba..."

# Usuario admin
curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/users" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@miapp.com",
    "firstName": "Admin",
    "lastName": "User",
    "enabled": true,
    "emailVerified": true,
    "credentials": [{
      "type": "password",
      "value": "admin123",
      "temporary": false
    }]
  }'

# Obtener ID del usuario admin
ADMIN_ID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/users?username=admin" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.[0].id')

# Asignar rol admin
ADMIN_ROLE_ID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/roles/admin" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.id')

curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/users/${ADMIN_ID}/role-mappings/realm" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '[{"id": "'${ADMIN_ROLE_ID}'", "name": "admin"}]'

echo "  ✓ Usuario admin creado (admin/admin123)"

# Usuario normal
curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/users" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "usuario",
    "email": "usuario@miapp.com",
    "firstName": "Usuario",
    "lastName": "Normal",
    "enabled": true,
    "emailVerified": true,
    "credentials": [{
      "type": "password",
      "value": "user123",
      "temporary": false
    }]
  }'

# Obtener ID del usuario normal
USER_ID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/users?username=usuario" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.[0].id')

# Asignar rol user
USER_ROLE_ID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/roles/user" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.id')

curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/users/${USER_ID}/role-mappings/realm" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '[{"id": "'${USER_ROLE_ID}'", "name": "user"}]'

echo "  ✓ Usuario normal creado (usuario/user123)"

echo ""
echo "✅ Configuración de Keycloak completada!"
echo ""
echo "📋 Usuarios creados:"
echo "  - admin@miapp.com / admin123 (rol: admin)"
echo "  - usuario@miapp.com / user123 (rol: user)"
echo ""
echo "🔑 Clients creados:"
echo "  - api-gateway"
echo "  - backend-service-1"
echo "  - backend-service-2"
echo "  - angular-client"
echo "  - android-client"
echo "  - ios-client"