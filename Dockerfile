FROM php:8.2-apache AS ospos
LABEL maintainer="jekkos"

# 1. Install sistem dependensi yang lebih lengkap (tambah libzip dan zip)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libicu-dev \
    libgd-dev \
    libzip-dev \
    unzip \
    zip \
    git \
    curl \
    && docker-php-ext-install mysqli bcmath intl gd zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod rewrite

# 2. Ambil Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# 3. Copy file composer dulu (Tips Pro: Ini mempercepat build karena cache)
COPY composer.json composer.lock* ./

# 4. Install dependensi (kita abaikan script untuk sementara agar tidak error)
RUN composer install --no-dev --no-scripts --no-interaction --optimize-autoloader

# 5. Baru copy sisa kodingannya
COPY --chown=www-data:www-data . /app

RUN chmod 750 /app/writable/logs /app/writable/uploads /app/writable/cache /app/public/uploads /app/public/uploads/item_pics \
    && chmod 640 /app/writable/uploads/importCustomers.csv \
    && ln -s /app/*[^public] /var/www \
    && rm -rf /var/www/html \
    && ln -nsf /app/public /var/www/html
