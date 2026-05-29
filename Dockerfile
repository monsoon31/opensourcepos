FROM php:8.1-apache AS ospos

# Set working directory
WORKDIR /app

# 1. Install System Dependencies & PHP Extensions (Wajib)
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install intl gd zip mysqli pdo_mysql mbstring bcmath

# 2. Aktifkan Apache Rewrite
RUN a2enmod rewrite

# 3. Ambil Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Copy SEMUA file dulu (Termasuk composer.json)
# Ini memastikan Composer pasti menemukan filenya
COPY . .

# 5. Jalankan Composer Install
RUN composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

# 6. Set Permissions
RUN chown -R www-data:www-data /app/writable /app/public/uploads

EXPOSE 80
