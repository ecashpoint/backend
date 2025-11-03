==========================================

#!/bin/bash

if [ -z "$1" ]; then
    echo "❌ Uso: ./restore.sh <archivo_backup.tar.gz>"
    exit 1
fi

BACKUP_FILE=$1
TEMP_DIR="./temp_restore"

echo "📥 Restaurando backup..."

# Extraer backup
mkdir -p $TEMP_DIR
tar -xzf "$BACKUP_FILE" -C $TEMP_DIR

# Detener servicios
docker-compose down

# Limpiar volúmenes
docker volume rm mi-proyecto_postgres_data || true
docker volume rm mi-proyecto_postgres_puntos_data || true
docker volume rm mi-proyecto_postgres_marketing_data || true

# Levantar solo bases de datos
docker-compose up -d postgres postgres-puntos postgres-marketing

echo "⏳ Esperando a que las bases de datos estén listas..."
sleep 15

# Restaurar bases de datos
docker-compose exec -T postgres psql -U keycloak keycloak < \
  $TEMP_DIR/backups/keycloak_*.sql

docker-compose exec -T postgres-puntos psql -U postgres puntosdb < \
  $TEMP_DIR/backups/puntos_*.sql

docker-compose exec -T postgres-marketing psql -U postgres marketingdb < \
  $TEMP_DIR/backups/service2_*.sql

# Limpiar
rm -rf $TEMP_DIR

# Levantar todos los servicios
docker-compose up -d

echo "✅ Restauración completada"
