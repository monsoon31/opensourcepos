FROM php:8.2-apache AS ospos

# 1. Install Extensions
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libzip-dev libonig-dev libjpeg62-turbo-dev \
    libfreetype6-dev unzip git \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install intl gd zip mysqli pdo_mysql mbstring bcmath

# 2. Ambil Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# 3. PAKSA COPY (Explicit copy akan mengabaikan .dockerignore)
COPY composer.json ./
COPY composer.lock ./

# 4. Jalankan Install
RUN composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

# 5. Copy sisa filenya
COPY . .

# 6. Konfigurasi Apache & Permissions
RUN a2enmod rewrite && \
    sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf && \
    chown -R www-data:www-data /var/www/html/writable /var/www/html/public/uploads

EXPOSE 80
