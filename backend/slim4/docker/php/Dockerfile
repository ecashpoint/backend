FROM php:8.2-fpm


# Actualizar paquetes e instalar 7zip, git, y utilidades
RUN apt-get update && apt-get install -y \
    p7zip-full \
    git \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar Composer
RUN curl -L -C - --progress-bar -o /usr/local/bin/composer https://getcomposer.org/composer.phar \
    && chmod 755 /usr/local/bin/composer

# Instalar extensiones de PHP
RUN docker-php-ext-install pdo_mysql mysqli

# Instalar y habilitar Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug