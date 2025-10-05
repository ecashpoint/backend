
# ============================================
# test-api.sh - Script para probar la API
# ============================================

#!/bin/bash

KEYCLOAK_URL="http://localhost:9090"
API_URL="http://localhost:8080"
REALM="mi-app"

echo "🧪 Probando API..."
echo ""

# Función para obtener token
get_token() {
    local username=$1
    local password=$2
    
    curl -s -X POST "${KEYCLOAK_URL}/realms/${REALM}/protocol/openid-connect/token" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "username=${username}" \
      -d "password=${password}" \
      -d "grant_type=password" \
      -d "client_id=angular-client" | jq -r '.access_token'
}

# Obtener token de admin
echo "🔐 Obteniendo token de admin..."
ADMIN_TOKEN=$(get_token "admin" "admin123")

if [ -z "$ADMIN_TOKEN" ] || [ "$ADMIN_TOKEN" == "null" ]; then
    echo "❌ Error al obtener token de admin"
    exit 1
fi

echo "✓ Token obtenido"
echo ""

# Test 1: Crear producto (solo admin)
echo "📦 Test 1: Crear producto (como admin)..."
RESPONSE=$(curl -s -X POST "${API_URL}/api/v1/productos" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Producto Test",
    "descripcion": "Descripción del producto",
    "precio": 99.99,
    "stock": 100,
    "categoria": "Electrónica"
  }')

echo "$RESPONSE" | jq '.'
echo ""

# Test 2: Listar productos (cualquier usuario)
echo "📋 Test 2: Listar productos (como admin)..."
curl -s -X GET "${API_URL}/api/v1/productos" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" | jq '.'
echo ""

# Obtener token de usuario normal
echo "🔐 Obteniendo token de usuario normal..."
USER_TOKEN=$(get_token "usuario" "user123")

echo "✓ Token obtenido"
echo ""

# Test 3: Listar productos como usuario normal
echo "📋 Test 3: Listar productos (como usuario normal)..."
curl -s -X GET "${API_URL}/api/v1/productos" \
  -H "Authorization: Bearer ${USER_TOKEN}" | jq '.'
echo ""

# Test 4: Intentar crear producto como usuario normal (debe fallar)
echo "❌ Test 4: Intentar crear producto (como usuario - debe fallar)..."
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "${API_URL}/api/v1/productos" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Producto No Autorizado",
    "descripcion": "No debería crearse",
    "precio": 10.00,
    "stock": 50,
    "categoria": "Test"
  }'
echo ""

# Test 5: Health check
echo "💚 Test 5: Health check..."
curl -s "${API_URL}/q/health/ready" | jq '.'
echo ""

echo "✅ Tests completados!"

# ============================================
# Makefile - Comandos útiles
# ============================================

.PHONY: help build up down logs clean test

help:
	@echo "Comandos disponibles:"
	@echo "  make build    - Construir proyectos"
	@echo "  make up       - Levantar servicios"
	@echo "  make down     - Detener servicios"
	@echo "  make logs     - Ver logs"
	@echo "  make clean    - Limpiar todo"
	@echo "  make test     - Probar API"
	@echo "  make setup    - Setup inicial completo"

build:
	@echo "🔨 Construyendo proyectos..."
	@for service in api-gateway service1 service2; do \
		cd $service && ./mvnw clean package -DskipTests && cd ..; \
	done

up:
	@echo "🚀 Levantando servicios..."
	@docker-compose up -d

down:
	@echo "🛑 Deteniendo servicios..."
	@docker-compose down

logs:
	@docker-compose logs -f

clean:
	@echo "🧹 Limpiando..."
	@docker-compose down -v
	@rm -rf */target
	@echo "✓ Limpieza completada"

test:
	@./test-api.sh

setup:
	@./setup.sh