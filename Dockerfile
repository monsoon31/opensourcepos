FROM php:8.2-apache AS ospos

# 1. Install Dependencies
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libzip-dev libonig-dev libjpeg62-turbo-dev \
    libfreetype6-dev unzip git \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install intl gd zip mysqli pdo_mysql mbstring bcmath

# 2. Setup Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Copy SEMUA file ke /app
WORKDIR /app
COPY . .

# 4. JURUS PAMUNGKAS: Cari file, pindah, dan install
# Kita gunakan perintah shell untuk mencari path composer.json secara otomatis
RUN ACTUAL_PATH=$(find . -name "composer.json" -printf '%h\n' | head -n 1) && \
    echo "File ketemu di path: $ACTUAL_PATH" && \
    cd "$ACTUAL_PATH" && \
    composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

# 5. Setup Apache (Kita buat dinamis juga)
RUN a2enmod rewrite && \
    ACTUAL_PATH=$(find . -name "composer.json" -printf '%h\n' | head -n 1) && \
    PUBLIC_DIR="/app/${ACTUAL_PATH#./}/public" && \
    sed -ri -e "s!/var/www/html!${PUBLIC_DIR}!g" /etc/apache2/sites-available/*.conf && \
    sed -ri -e "s!/var/www/!${PUBLIC_DIR}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 6. Permissions
RUN chown -R www-data:www-data /app

EXPOSE 80
