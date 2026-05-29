FROM php:8.2-apache AS ospos

# 1. Install Dependencies
RUN apt-get update && apt-get install -y \
    libicu-dev libpng-dev libzip-dev libonig-dev libjpeg62-turbo-dev \
    libfreetype6-dev unzip git \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install intl gd zip mysqli pdo_mysql mbstring bcmath

# 2. Ambil Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Copy semua file
WORKDIR /app
COPY . .

# 4. PINDAH KE FOLDER YANG ADA composer.json
# Berdasarkan tree kamu, filenya ada di folder opensourcepos
WORKDIR /app/opensourcepos

# 5. Jalankan install
RUN composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

# 6. Setup Apache (Arahkan ke public di dalam subfolder)
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /app/opensourcepos/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 7. Permissions
RUN chown -R www-data:www-data /app/opensourcepos/writable /app/opensourcepos/public/uploads

EXPOSE 80
