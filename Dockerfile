FROM php:8.2-apache AS ospos

# 1. Set folder kerja di /var/www/html (Standar Apache)
WORKDIR /var/www/html

# 2. Install library sistem & PHP Extensions
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

# 5. Copy SEMUA file dari repo ke container
COPY . .

# 6. Jalankan Composer Install (Langsung di sini, karena filenya pasti di sini)
RUN composer install --no-dev --no-interaction --optimize-autoloader --ignore-platform-reqs

# 7. Set Permissions
RUN chown -R www-data:www-data /var/www/html/writable /var/www/html/public/uploads

# 8. Arahkan Document Root Apache ke folder public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

EXPOSE 80
