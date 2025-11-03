
# ============================================
# scripts/dev-setup.sh
# Para desarrollo local sin Docker
# ============================================

#!/bin/bash

echo "💻 Configurando entorno de desarrollo..."

# Verificar Java
if ! command -v java &> /dev/null; then
    echo "❌ Java no encontrado. Instala Java 17+"
    exit 1
fi

echo "✅ Java $(java -version 2>&1 | head -n 1)"

# Verificar Maven
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven no encontrado. Instala Maven 3.8+"
    exit 1
fi

echo "✅ Maven $(mvn -version | head -n 1)"

# Iniciar solo infraestructura
echo "🚀 Iniciando Keycloak y PostgreSQL..."
docker-compose up -d postgres keycloak

echo "⏳ Esperando a Keycloak..."
sleep 60

# Configurar Keycloak
./keycloak-config.sh

echo ""
echo "✅ Infraestructura lista!"
echo ""
echo "Ahora puedes ejecutar los servicios localmente:"
echo "  cd api-gateway && ./mvnw quarkus:dev -Dquarkus.http.port=8080"
echo "  cd puntos && ./mvnw quarkus:dev -Dquarkus.http.port=8081"
echo "  cd marketing && ./mvnw quarkus:dev -Dquarkus.http.port=8082"