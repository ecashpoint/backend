# 🚀 Proyecto Microservicios con Keycloak

Sistema completo de microservicios con autenticación centralizada usando Keycloak, API Gateway y múltiples clientes (Angular, Android, iOS).

## 📋 Requisitos Previos

- Docker & Docker Compose
- Java 17+
- Maven 3.8+
- Node.js 18+ (para Angular)
- jq (para scripts de configuración)

```bash
# Instalar jq en Ubuntu/Debian
sudo apt-get install jq

# Instalar jq en macOS
brew install jq
```

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────┐
│    Clientes (Angular, Android, iOS)         │
└──────────────────┬──────────────────────────┘
                   │ HTTPS
                   ↓
            ┌──────────────┐
            │ API Gateway  │ (Puerto 8080)
            │  (Quarkus)   │
            └──────┬───────┘
                   │
         ┌─────────┼─────────┐
         ↓         ↓         ↓
    ┌─────────┐ ┌─────────┐ ┌─────────┐
    │Service 1│ │Service 2│ │Service N│
    │  8081   │ │  8082   │ │  808X   │
    └─────────┘ └─────────┘ └─────────┘
         │         │         │
         └─────────┴─────────┘
                   │
            ┌──────────────┐
            │  Keycloak    │ (Puerto 9090)
            └──────────────┘
                   │
            ┌──────────────┐
            │  PostgreSQL  │
            └──────────────┘
```

## 🚀 Inicio Rápido

### 1. Clonar y Preparar

```bash
# Dar permisos a los scripts
chmod +x setup.sh keycloak-config.sh test-api.sh

# Ejecutar setup completo (construye, levanta y configura todo)
./setup.sh
```

El script automáticamente:
- ✅ Construye todos los microservicios
- ✅ Levanta PostgreSQL y Keycloak
- ✅ Configura el realm, clients y usuarios
- ✅ Inicia todos los servicios

### 2. Inicio Manual (paso a paso)

```bash
# 1. Construir proyectos
make build
# o
cd api-gateway && ./mvnw clean package -DskipTests && cd ..
cd puntos && ./mvnw clean package -DskipTests && cd ..
cd marketing && ./mvnw clean package -DskipTests && cd ..

# 2. Levantar infraestructura base
docker-compose up -d postgres keycloak

# 3. Esperar a que Keycloak esté listo (60 segundos aprox)
docker-compose logs -f keycloak

# 4. Configurar Keycloak
./keycloak-config.sh

# 5. Levantar microservicios
docker-compose up -d api-gateway puntos marketing
```

## 🔐 Configuración de Keycloak

### Realm: `mi-app`

### Usuarios de Prueba

| Usuario | Email | Contraseña | Roles |
|---------|-------|------------|-------|
| admin | admin@miapp.com | admin123 | admin |
| usuario | usuario@miapp.com | user123 | user |

### Clients Configurados

| Client ID | Tipo | Secret | Uso |
|-----------|------|--------|-----|
| api-gateway | confidential | gateway-secret-123 | API Gateway |
| backend-service-1 | confidential | service1-secret-123 | Microservicio 1 |
| backend-service-2 | confidential | service2-secret-123 | Microservicio 2 |
| angular-client | public | - | Frontend Angular |
| android-client | public | - | App Android |
| ios-client | public | - | App iOS |

## 🌐 Endpoints Disponibles

### Keycloak
- URL: http://localhost:9090
- Admin Console: http://localhost:9090/admin
- Credentials: admin / admin123

### API Gateway
- Base URL: http://localhost:8080
- Health: http://localhost:8080/q/health
- Metrics: http://localhost:8080/q/metrics

### Microservicio 1 (Productos)
- Base URL: http://localhost:8081/api/productos
- Direct Health: http://localhost:8081/q/health

### Microservicio 2 (Pedidos)
- Base URL: http://localhost:8082/api/pedidos
- Direct Health: http://localhost:8082/q/health

### Monitoring
- Grafana: http://localhost:3000 (admin / admin123)
- Prometheus: http://localhost:9091

## 🧪 Pruebas

### Ejecutar Tests Automáticos

```bash
./test-api.sh
```

### Pruebas Manuales con cURL

```bash
# 1. Obtener token de admin
TOKEN=$(curl -s -X POST "http://localhost:9090/realms/mi-app/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin" \
  -d "password=admin123" \
  -d "grant_type=password" \
  -d "client_id=angular-client" | jq -r '.access_token')

# 2. Crear producto (solo admin)
curl -X POST "http://localhost:8080/api/v1/productos" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Laptop HP",
    "descripcion": "Laptop HP Core i7",
    "precio": 899.99,
    "stock": 50,
    "categoria": "Electrónica"
  }'

# 3. Listar productos
curl -X GET "http://localhost:8080/api/v1/productos" \
  -H "Authorization: Bearer $TOKEN"

# 4. Buscar por categoría
curl -X GET "http://localhost:8080/api/v1/productos?categoria=Electrónica" \
  -H "Authorization: Bearer $TOKEN"
```

### Prueba con Usuario Normal

```bash
# Obtener token de usuario
USER_TOKEN=$(curl -s -X POST "http://localhost:9090/realms/mi-app/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=usuario" \
  -d "password=user123" \
  -d "grant_type=password" \
  -d "client_id=angular-client" | jq -r '.access_token')

# Listar productos (debería funcionar)
curl -X GET "http://localhost:8080/api/v1/productos" \
  -H "Authorization: Bearer $USER_TOKEN"

# Intentar crear producto (debería fallar con 403)
curl -X POST "http://localhost:8080/api/v1/productos" \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Producto Test",
    "precio": 10.00,
    "stock": 1
  }'
```

## 📱 Integración con Clientes

### Angular

```typescript
// Instalación
npm install keycloak-angular keycloak-js

// app.config.ts
import { KeycloakService } from 'keycloak-angular';

function initializeKeycloak(keycloak: KeycloakService) {
  return () =>
    keycloak.init({
      config: {
        url: 'http://localhost:9090',
        realm: 'mi-app',
        clientId: 'angular-client'
      },
      initOptions: {
        onLoad: 'check-sso'
      }
    });
}

// Llamadas a API
const token = await this.keycloak.getToken();
this.http.get('http://localhost:8080/api/v1/productos', {
  headers: { Authorization: `Bearer ${token}` }
});
```

### Android

```kotlin
// build.gradle
implementation 'net.openid:appauth:0.11.1'

// Configuración
val serviceConfig = AuthorizationServiceConfiguration(
    Uri.parse("http://TU_IP:9090/realms/mi-app/protocol/openid-connect/auth"),
    Uri.parse("http://TU_IP:9090/realms/mi-app/protocol/openid-connect/token")
)

val authRequest = AuthorizationRequest.Builder(
    serviceConfig,
    "android-client",
    ResponseTypeValues.CODE,
    Uri.parse("com.miapp://oauth2callback")
).build()
```

### iOS

```swift
// Podfile
pod 'AppAuth'

// Configuración
let config = OIDServiceConfiguration(
    authorizationEndpoint: URL(string: "http://TU_IP:9090/realms/mi-app/protocol/openid-connect/auth")!,
    tokenEndpoint: URL(string: "http://TU_IP:9090/realms/mi-app/protocol/openid-connect/token")!
)

let request = OIDAuthorizationRequest(
    configuration: config,
    clientId: "ios-client",
    scopes: ["openid", "profile"],
    redirectURL: URL(string: "com.miapp://oauth2callback")!,
    responseType: OIDResponseTypeCode,
    additionalParameters: nil
)
```

## 🛠️ Comandos Útiles

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f api-gateway
docker-compose logs -f service1
docker-compose logs -f keycloak

# Reiniciar un servicio
docker-compose restart api-gateway

# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes (limpieza completa)
docker-compose down -v

# Ver estado de servicios
docker-compose ps

# Ejecutar comando en contenedor
docker-compose exec service1 bash
```

## 🔧 Desarrollo

### Agregar Nuevo Microservicio

1. Crear nuevo directorio `service3/`
2. Copiar estructura de `service1/`
3. Modificar `pom.xml` y configuraciones
4. Agregar al `docker-compose.yml`
5. Agregar cliente en Keycloak
6. Agregar rutas en API Gateway

### Hot Reload en Desarrollo

```bash
# En cada microservicio
./mvnw quarkus:dev

# API Gateway en modo dev
cd api-gateway
./mvnw quarkus:dev -Dquarkus.http.port=8080
```

## 📊 Monitoreo

### Métricas con Prometheus

```bash
# Ver métricas de API Gateway
curl http://localhost:8080/q/metrics

# Ver métricas de Service1
curl http://localhost:8081/q/metrics
```

### Dashboards en Grafana

1. Acceder a http://localhost:3000
2. Login: admin / admin123
3. Add Data Source → Prometheus
4. URL: http://prometheus:9090
5. Importar dashboards de Quarkus

## 🐛 Troubleshooting

### Keycloak no inicia

```bash
# Ver logs
docker-compose logs keycloak