FROM php:8.2-apache AS ospos

# 1. Install Dependencies Super Lengkap (Menghindari Composer Exit Code 1)
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libzip-dev libonig-dev libjpeg62-turbo-dev \
    libfreetype6-dev libwebp-dev libxpm-dev unzip git \
    && rm -rf /var/lib/apt/lists/*

# 2. Install PHP Extensions dengan konfigurasi lengkap
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm \
    && docker-php-ext-install intl gd zip mysqli pdo_mysql mbstring bcmath

# 3. Setup Composer Environment (Naikkan RAM Limit)
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Copy file
WORKDIR /app
COPY . .

# 5. Eksekusi di folder yang benar dengan verbose mode
WORKDIR /app/opensourcepos

# Kita hapus vendor lama (jika ada) dan jalankan install dengan --verbose
# supaya kita bisa lihat error aslinya kalau gagal lagi
RUN rm -rf vendor && \
    composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs --verbose

# 6. Setup Apache
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT=/app/opensourcepos/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 7. Permissions
RUN chown -R www-data:www-data /app/opensourcepos/writable /app/opensourcepos/public/uploads

EXPOSE 80
