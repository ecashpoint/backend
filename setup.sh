#!/bin/bash
# ============================================
# setup.sh - Script de inicialización
# ============================================

set -e

echo "🚀 Iniciando setup del proyecto..."

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker encontrado${NC}"

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose no está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker Compose encontrado${NC}"

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    echo -e "${YELLOW}📝 Creando archivo .env...${NC}"
    cat > .env << EOF
# Keycloak
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin123

# Database
POSTGRES_USER=keycloak
POSTGRES_PASSWORD=keycloak123
POSTGRES_DB=keycloak

# Secrets
GATEWAY_SECRET=$(openssl rand -base64 32)
PUNTOS_SECRET=$(openssl rand -base64 32)
MARKETING_SECRET=$(openssl rand -base64 32)

# URLs
KEYCLOAK_URL=http://keycloak:8080
GATEWAY_URL=http://api-gateway:8080
EOF
    echo -e "${GREEN}✓ Archivo .env creado${NC}"
fi

# Construir proyectos Quarkus
echo -e "${YELLOW}🔨 Construyendo proyectos...${NC}"

for service in api-gateway puntos marketing; do
    if [ -d "$service" ]; then
        echo -e "${YELLOW}  Construyendo $service...${NC}"
        cd $service
        ./mvnw clean package -DskipTests
        cd ..
        echo -e "${GREEN}  ✓ $service construido${NC}"
    fi
done

# Levantar servicios
echo -e "${YELLOW}🐳 Levantando contenedores...${NC}"
docker-compose up -d postgres

echo -e "${YELLOW}⏳ Esperando a que PostgreSQL esté listo...${NC}"
sleep 10

docker-compose up -d keycloak

echo -e "${YELLOW}⏳ Esperando a que Keycloak esté listo (60s)...${NC}"
sleep 60

echo -e "${GREEN}✓ Servicios base iniciados${NC}"

# Configurar Keycloak
echo -e "${YELLOW}⚙️  Configurando Keycloak...${NC}"
./keycloak-config.sh

# Levantar microservicios
echo -e "${YELLOW}🚀 Levantando microservicios...${NC}"
docker-compose up -d

echo -e "${GREEN}✅ Setup completado!${NC}"
echo ""
echo "📋 Servicios disponibles:"
echo "  - Keycloak: http://localhost:9090"
echo "    Usuario: admin / admin123"
echo "  - API Gateway: http://localhost:8080"
echo "  - Puntos: http://localhost:8081"
echo "  - Marketing: http://localhost:8082"
echo "  - Angular App: http://localhost:4200"
echo "  - Grafana: http://localhost:3000"
echo "    Usuario: admin / admin123"
echo "  - Prometheus: http://localhost:9091"
echo ""
echo "🔐 Realm: mi-app"
echo ""
echo "Para ver logs: docker-compose logs -f [servicio]"
echo "Para detener: docker-compose down"