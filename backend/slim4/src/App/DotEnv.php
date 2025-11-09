<?php

declare(strict_types=1);

$baseDir = __DIR__ . '/../../';
$dotenv = Dotenv\Dotenv::createUnsafeImmutable($baseDir);
if (file_exists($baseDir . '.env')) {
    $dotenv->load();
}
$dotenv->required(['DB_HOST', 'DB_NAME', 'DB_USER', 'DB_PASS', 'DB_PORT' , 'URL_KEYCLOAK', 'KEYCLOAK_USER', 
'KEYCLOAK_PASSWORD', 'ENDPOINT_TOKEN', 'ENDPOINT_CREATE_USER', 'CLIENT_ID_ADMIN', 'GATEWAY_URL','KONG_CLIENT','CLIENT_SECRET']);
