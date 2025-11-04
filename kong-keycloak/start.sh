#!/bin/bash
set -e

echo "Iniciando bases de datos..."
podman-compose up -d kong-database konga-database postgres-keycloak

echo "Esperando bases de datos..."
sleep 30

echo "Ejecutando migraciones..."
podman-compose run --rm kong-migration
podman-compose run --rm konga-prepare

echo "Iniciando servicios..."
podman-compose up -d kong keycloak konga

echo "Listo!"
podman-compose ps