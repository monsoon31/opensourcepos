FROM php:8.2-apache AS ospos
LABEL maintainer="jekkos"

# 1. Install system dependencies
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

# 2. Ambil Composer binary
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# 3. Copy seluruh isi repo ke folder /app dalam container
COPY --chown=www-data:www-data . /app

# 4. Jalankan Composer Install langsung di root /app
# --ignore-platform-reqs ditambahkan untuk menghindari error versi PHP/ext yang tidak pas saat build
RUN composer install --no-dev --no-scripts --no-interaction --optimize-autoloader --ignore-platform-reqs

# 5. Setup symlinks dan permissions (standar OSPOS)
RUN chmod 750 /app/writable/logs /app/writable/uploads /app/writable/cache /app/public/uploads /app/public/uploads/item_pics \
    && chmod 640 /app/writable/uploads/importCustomers.csv \
    && ln -s /app/*[^public] /var/www \
    && rm -rf /var/www/html \
    && ln -nsf /app/public /var/www/html

# --- Stage Dev tetap dibiarkan jika sewaktu-waktu kamu butuh ---
FROM ospos AS ospos_dev
ARG USERID
ARG GROUPID
RUN ( addgroup --gid ${GROUPID:-1000} ospos || true ) && ( adduser --uid ${USERID:-1000} --gid ${GROUPID:-1000} ospos || true )
