# 1. Gunakan PHP 8.2 (Sesuai requirement di composer.json kamu)
FROM php:8.2-apache AS ospos

# Set working directory utama
WORKDIR /app

# 2. Install System Dependencies & PHP Extensions
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

# 3. Aktifkan Apache Rewrite
RUN a2enmod rewrite

# 4. Ambil Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Copy SELURUH isi repo ke dalam folder /app
COPY . .

# 6. Pindah ke sub-folder tempat composer.json berada dan jalankan install
# Kita gunakan WORKDIR untuk pindah ke folder yang benar
WORKDIR /app/opensourcepos
RUN composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

# 7. Set Permissions untuk folder writable & uploads agar web bisa jalan
RUN chown -R www-data:www-data /app/opensourcepos/writable /app/opensourcepos/public/uploads

# 8. Sesuaikan Apache Document Root ke folder public OSPOS
# Karena file index.php ada di /app/opensourcepos/public
RUN sed -ri -e 's!/var/www/html!/app/opensourcepos/public!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!/app/opensourcepos/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

EXPOSE 80
