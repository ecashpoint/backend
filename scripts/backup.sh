
#!/bin/bash

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "📦 Creando backup..."

mkdir -p $BACKUP_DIR

# Backup de base de datos de Keycloak
docker-compose exec -T postgres pg_dump -U keycloak keycloak > \
  "$BACKUP_DIR/keycloak_$TIMESTAMP.sql"

# Backup de configuración de Keycloak (realm)
docker-compose exec -T keycloak /opt/keycloak/bin/kc.sh export \
  --dir /tmp/export --realm mi-app

docker cp $(docker-compose ps -q keycloak):/tmp/export \
  "$BACKUP_DIR/realm_$TIMESTAMP"

# Backup de bases de datos de servicios
docker-compose exec -T postgres-puntos pg_dump -U postgres puntosdb > \
  "$BACKUP_DIR/puntos_$TIMESTAMP.sql"

docker-compose exec -T postgres-marketing pg_dump -U postgres marketingdb > \
  "$BACKUP_DIR/marketing_$TIMESTAMP.sql"

# Comprimir
tar -czf "$BACKUP_DIR/full_backup_$TIMESTAMP.tar.gz" \
  "$BACKUP_DIR/keycloak_$TIMESTAMP.sql" \
  "$BACKUP_DIR/realm_$TIMESTAMP" \
  "$BACKUP_DIR/puntos_$TIMESTAMP.sql" \
  "$BACKUP_DIR/marketing_$TIMESTAMP.sql"

# Limpiar archivos temporales
rm -rf "$BACKUP_DIR/keycloak_$TIMESTAMP.sql" \
       "$BACKUP_DIR/realm_$TIMESTAMP" \
       "$BACKUP_DIR/puntos_$TIMESTAMP.sql" \
       "$BACKUP_DIR/marketing_$TIMESTAMP.sql"

echo "✅ Backup completado: full_backup_$TIMESTAMP.tar.gz"
