
#!/bin/bash

echo "🏥 Verificando salud de los servicios..."
echo ""

check_service() {
    local name=$1
    local url=$2
    
    if curl -sf "$url" > /dev/null 2>&1; then
        echo "✅ $name: OK"
        return 0
    else
        echo "❌ $name: FAIL"
        return 1
    fi
}

# Verificar servicios
check_service "Keycloak" "http://localhost:9090/health/ready"
check_service "API Gateway" "http://localhost:8080/q/health/ready"
check_service "Service 1" "http://localhost:8081/q/health/ready"
check_service "Service 2" "http://localhost:8082/q/health/ready"
check_service "Prometheus" "http://localhost:9091/-/healthy"
check_service "Grafana" "http://localhost:3000/api/health"

echo ""
echo "🐳 Estado de contenedores:"
docker-compose ps